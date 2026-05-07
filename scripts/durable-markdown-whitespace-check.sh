#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

usage() {
  cat <<'EOF'
Usage:
  scripts/durable-markdown-whitespace-check.sh [PATH...]

Checks durable changed Markdown files for trailing spaces or tabs. With no
arguments, the check scans changed repository Markdown records that are meant
to be committed as durable agent state. Explicit PATH arguments are checked
directly.
EOF
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

is_durable_markdown_path() {
  local rel="$1"
  case "$rel" in
    constitution/*.md|mailbox/*.md|mailbox/inbox/*.md|mailbox/processing/*.md|mailbox/done/*.md|mailbox/failed/*.md|mailbox/outbox/*.md|memory/*.md|memory/*/*.md|skills/*/SKILL.md|skills/*/*.md)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

changed_durable_markdown_files() {
  {
    git -C "$ROOT_DIR" diff --name-only --diff-filter=ACMRT
    git -C "$ROOT_DIR" diff --cached --name-only --diff-filter=ACMRT
    git -C "$ROOT_DIR" ls-files --others --exclude-standard
  } | sort -u | while IFS= read -r rel; do
    [ -n "$rel" ] || continue
    is_durable_markdown_path "$rel" || continue
    [ -f "${ROOT_DIR}/${rel}" ] || continue
    printf '%s\n' "$rel"
  done
}

target_files() {
  if [ "$#" -gt 0 ]; then
    local path rel
    for path in "$@"; do
      rel="$(repo_relative_path "$path")"
      printf '%s\n' "$rel"
    done
    return 0
  fi

  changed_durable_markdown_files
}

main() {
  if [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
    usage
    return 0
  fi

  local errors=0 rel file matches

  while IFS= read -r rel; do
    [ -n "$rel" ] || continue
    file="${ROOT_DIR}/${rel}"

    if [ ! -f "$file" ]; then
      echo "durable-markdown-whitespace-check: missing ${rel}" >&2
      errors=$((errors + 1))
      continue
    fi

    case "$rel" in
      *.md|*/SKILL.md)
        ;;
      *)
        continue
        ;;
    esac

    matches="$(
      LC_ALL=C awk -v rel="$rel" '/[ \t]$/ {
        printf "%s:%d: trailing whitespace\n", rel, FNR
      }' "$file"
    )"
    if [ -n "$matches" ]; then
      printf '%s\n' "$matches"
      echo "durable-markdown-whitespace-check: trailing whitespace in ${rel}" >&2
      errors=$((errors + 1))
    fi
  done < <(target_files "$@")

  if [ "$errors" -gt 0 ]; then
    return 1
  fi

  echo "durable-markdown-whitespace-check: ok"
}

main "$@"
