#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
CODEX_HOME_DIR="${ROOT_DIR}/.codex"

usage() {
  cat <<'EOF'
Usage:
  scripts/codex-local-preflight-check.sh [--root DIR] [--codex-home DIR]

Checks the local Codex readiness needed before the supervisor launches a child
Codex process. The check only reports file presence and environment-auth
presence; it never prints token values or reads credential contents.
EOF
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --root)
      [ "$#" -ge 2 ] || {
        echo "codex-local-preflight-check: missing directory after --root" >&2
        exit 2
      }
      ROOT_DIR="$(cd "$2" && pwd)"
      CODEX_HOME_DIR="${ROOT_DIR}/.codex"
      shift 2
      ;;
    --codex-home)
      [ "$#" -ge 2 ] || {
        echo "codex-local-preflight-check: missing directory after --codex-home" >&2
        exit 2
      }
      CODEX_HOME_DIR="$(cd "$2" 2>/dev/null && pwd || printf '%s\n' "$2")"
      shift 2
      ;;
    -h|--help|help)
      usage
      exit 0
      ;;
    *)
      echo "codex-local-preflight-check: unknown argument: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

repo_relative_path() {
  local path="$1"
  case "$path" in
    "${ROOT_DIR}/"*)
      printf '%s\n' "${path#${ROOT_DIR}/}"
      ;;
    "${ROOT_DIR}")
      printf '.\n'
      ;;
    *)
      printf '%s\n' "$path"
      ;;
  esac
}

codex_relative_path() {
  local path="$1"
  case "$path" in
    "${CODEX_HOME_DIR}/"*)
      printf '%s/%s\n' "$(repo_relative_path "$CODEX_HOME_DIR")" "${path#${CODEX_HOME_DIR}/}"
      ;;
    *)
      repo_relative_path "$path"
      ;;
  esac
}

issues=()

add_issue() {
  issues+=("$1")
}

if ! command -v codex >/dev/null 2>&1; then
  add_issue "codex CLI is not available on PATH"
fi

if [ ! -d "$CODEX_HOME_DIR" ]; then
  add_issue "$(repo_relative_path "$CODEX_HOME_DIR") is missing"
fi

check_symlink_target() {
  local link_path="$1"
  local expected_target="$2"
  local rel
  rel="$(codex_relative_path "$link_path")"

  if [ ! -L "$link_path" ]; then
    add_issue "${rel} is missing or is not a symlink"
    return 0
  fi

  local current_target
  current_target="$(readlink "$link_path")"
  if [ "$current_target" != "$expected_target" ]; then
    add_issue "${rel} points to ${current_target}, expected ${expected_target}"
  fi
}

check_symlink_target "${CODEX_HOME_DIR}/skills" "../skills"
check_symlink_target "${CODEX_HOME_DIR}/sessions" "../sessions"

if [ ! -s "${CODEX_HOME_DIR}/config.toml" ]; then
  add_issue "$(codex_relative_path "${CODEX_HOME_DIR}/config.toml") is missing or empty"
fi

has_auth_source=0
if [ -s "${CODEX_HOME_DIR}/auth.json" ]; then
  has_auth_source=1
fi
if [ -n "${OPENAI_API_KEY:-}" ] || [ -n "${CODEX_API_KEY:-}" ]; then
  has_auth_source=1
fi

if [ "$has_auth_source" -ne 1 ]; then
  add_issue "$(codex_relative_path "${CODEX_HOME_DIR}/auth.json") is missing or empty, and no environment auth variable is present"
fi

if [ "${#issues[@]}" -gt 0 ]; then
  {
    echo "codex-local-preflight-check: failed"
    echo
    echo "The supervisor will not launch child Codex until local Codex readiness is present:"
    for issue in "${issues[@]}"; do
      printf -- '- %s\n' "$issue"
    done
    echo
    echo "Run scripts/init.sh, then configure local Codex config and auth for this worktree before starting scripts/supervisor.sh once or loop."
  } >&2
  exit 78
fi

echo "codex-local-preflight-check: ok"
