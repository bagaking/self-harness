#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

protected_record_path() {
  case "$1" in
    mailbox/outbox/*.md|memory/diary/*.md)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

path_exists_in_head() {
  local rel="$1"
  git -C "$ROOT_DIR" ls-tree -r --name-only HEAD -- "$rel" 2>/dev/null \
    | LC_ALL=C rg -Fxq -- "$rel"
}

changed_name_status() {
  git -C "$ROOT_DIR" diff --name-status -M --diff-filter=ACMDRT
  git -C "$ROOT_DIR" diff --cached --name-status -M --diff-filter=ACMDRT
}

protected_existing_changed_paths() {
  local status path1 path2 path

  changed_name_status | while IFS=$'\t' read -r status path1 path2; do
    [ -n "${status:-}" ] || continue
    for path in "${path1:-}" "${path2:-}"; do
      [ -n "$path" ] || continue
      if protected_record_path "$path" && path_exists_in_head "$path"; then
        printf '%s\n' "$path"
      fi
    done
  done | sort -u
}

main() {
  if ! git -C "$ROOT_DIR" rev-parse --verify HEAD >/dev/null 2>&1; then
    echo "completed-record-overwrite-check: ok"
    return 0
  fi

  local changed
  changed="$(protected_existing_changed_paths)"
  if [ -z "$changed" ]; then
    echo "completed-record-overwrite-check: ok"
    return 0
  fi

  {
    echo "completed-record-overwrite-check: tracked completed records were modified"
    echo
    echo "Modified completed records:"
    printf '%s\n' "$changed" | sed 's/^/- /'
    echo
    echo "Create uniquely named new mailbox/outbox and memory/diary records for current-run evidence."
    echo "If durable memory needs to evolve, update memory/decisions, memory/lessons, or another non-diary memory file instead."
  } >&2
  return 1
}

main "$@"
