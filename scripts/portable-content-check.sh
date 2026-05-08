#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

usage() {
  cat <<'EOF'
Usage:
  scripts/portable-content-check.sh [PATH...]

Checks changed durable agent-authored Markdown and shell scripts for local
machine paths, known redaction path placeholders, home-relative paths, and
project-outside temp paths. Explicit PATH arguments are checked directly.

Repository-relative .self-harness/tmp/ scratch references are allowed.
EOF
}

changed_files() {
  {
    git -C "$ROOT_DIR" diff --name-only --diff-filter=ACMR
    git -C "$ROOT_DIR" diff --cached --name-only --diff-filter=ACMR
    git -C "$ROOT_DIR" ls-files --others --exclude-standard
  } | awk 'NF' | sort -u
}

repo_relative_path() {
  local path="$1"
  case "$path" in
    /*)
      case "$path" in
        "${ROOT_DIR}/"*)
          printf '%s\n' "${path#${ROOT_DIR}/}"
          ;;
        *)
          printf '%s\n' "$path"
          ;;
      esac
      ;;
    ./*)
      printf '%s\n' "${path#./}"
      ;;
    *)
      printf '%s\n' "$path"
      ;;
  esac
}

is_default_checked_path() {
  local rel="$1"
  case "$rel" in
    AGENTS.md|constitution/*.md|scripts/*.sh|memory/*.md|memory/*/*.md|mailbox/*.md|mailbox/*/*.md|skills/*.md|skills/*/*.md|skills/*/SKILL.md)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

target_files() {
  if [ "$#" -gt 0 ]; then
    local path
    for path in "$@"; do
      repo_relative_path "$path"
    done
    return 0
  fi

  local rel
  while IFS= read -r rel; do
    [ -n "$rel" ] || continue
    is_default_checked_path "$rel" || continue
    printf '%s\n' "$rel"
  done < <(changed_files)
}

report_pattern_matches() {
  local rel="$1"
  local file="$2"
  local label="$3"
  local pattern="$4"
  local matches

  matches="$(LC_ALL=C rg -n --color never "$pattern" "$file" || true)"
  [ -n "$matches" ] || return 1

  printf '%s\n' "$matches" | awk -F: -v rel="$rel" -v label="$label" '
    /^[0-9]+:/ {
      printf "%s:%s: %s\n", rel, $1, label
    }
  '
  return 0
}

main() {
  if [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
    usage
    return 0
  fi

  local slash users_dir home_dir private_dir tmp_dir var_dir folders_dir quote_chars
  local path_tail local_path_pattern temp_path_pattern home_rel_pattern env_pattern redacted_pattern
  slash="/"
  users_dir="Users"
  home_dir="home"
  private_dir="private"
  tmp_dir="tmp"
  var_dir="var"
  folders_dir="folders"
  quote_chars=$'`\'"'
  path_tail="[^[:space:]${quote_chars})>]+"
  local_path_pattern="(^|[^[:alnum:]_.-])(${slash}${users_dir}|${slash}${home_dir})${slash}${path_tail}"
  temp_path_pattern="(^|[^[:alnum:]_.-])(${slash}${private_dir}${slash}${tmp_dir}|${slash}${private_dir}${slash}${var_dir}${slash}${folders_dir}|${slash}${var_dir}${slash}${folders_dir}|${slash}${tmp_dir})${slash}${path_tail}"
  home_rel_pattern="(^|[^[:alnum:]_.-])~${slash}${path_tail}"
  env_pattern="(^|[^[:alnum:]_])(HOSTNAME|USER|USERNAME|LOGNAME|HOME)=[^[:space:]${quote_chars}]+"
  redacted_pattern='\['"redacted"'-(temp|local|home)-'"path"'\]'

  local errors=0 rel file
  while IFS= read -r rel; do
    [ -n "$rel" ] || continue
    case "$rel" in
      /*)
        file="$rel"
        ;;
      *)
        file="${ROOT_DIR}/${rel}"
        ;;
    esac

    if [ ! -f "$file" ]; then
      echo "portable-content-check: missing ${rel}" >&2
      errors=$((errors + 1))
      continue
    fi

    if report_pattern_matches "$rel" "$file" "local absolute path" "$local_path_pattern"; then
      errors=$((errors + 1))
    fi
    if report_pattern_matches "$rel" "$file" "project-outside temp path or write target" "$temp_path_pattern"; then
      errors=$((errors + 1))
    fi
    if report_pattern_matches "$rel" "$file" "home-relative path" "$home_rel_pattern"; then
      errors=$((errors + 1))
    fi
    if report_pattern_matches "$rel" "$file" "local environment detail" "$env_pattern"; then
      errors=$((errors + 1))
    fi
    if report_pattern_matches "$rel" "$file" "redacted local/temp/home path placeholder" "$redacted_pattern"; then
      errors=$((errors + 1))
    fi
  done < <(target_files "$@")

  if [ "$errors" -gt 0 ]; then
    echo "portable-content-check: local paths, device details, or project-outside write targets found" >&2
    return 1
  fi

  echo "portable-content-check: ok"
}

main "$@"
