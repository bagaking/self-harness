#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

status=0

repo_relative_path() {
  local path="$1"
  case "$path" in
    "${ROOT_DIR}/"*)
      printf '%s\n' "${path#${ROOT_DIR}/}"
      ;;
    *)
      printf '%s\n' "$path"
      ;;
  esac
}

check_script() {
  local script="$1"
  local rel
  rel="$(repo_relative_path "$script")"

  if [ ! -f "$script" ]; then
    echo "shell-syntax-check: missing ${rel}" >&2
    return 1
  fi

  if bash -n "$script"; then
    echo "shell-syntax-check: ok ${rel}"
    return 0
  fi

  echo "shell-syntax-check: failed ${rel}" >&2
  return 1
}

if [ "$#" -gt 0 ]; then
  for script in "$@"; do
    check_script "$script" || status=1
  done
else
  while IFS= read -r script; do
    check_script "$script" || status=1
  done < <(find "${ROOT_DIR}/scripts" -maxdepth 1 -type f -name '*.sh' | sort)
fi

exit "$status"
