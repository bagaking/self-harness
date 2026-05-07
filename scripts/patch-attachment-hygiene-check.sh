#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

patch_files() {
  if [ "$#" -gt 0 ]; then
    local path
    for path in "$@"; do
      case "$path" in
        /*)
          printf '%s\n' "$path"
          ;;
        *)
          printf '%s/%s\n' "$ROOT_DIR" "$path"
          ;;
      esac
    done
    return 0
  fi

  find "$ROOT_DIR/mailbox/outbox/attachments" \
    -maxdepth 1 \
    -type f \
    -name '*main-target*.patch' \
    -print 2>/dev/null \
    | sort
}

main() {
  local errors=0 file rel matches

  while IFS= read -r file; do
    [ -n "$file" ] || continue
    rel="${file#${ROOT_DIR}/}"

    if [ ! -f "$file" ]; then
      echo "patch-attachment-hygiene-check: missing ${rel}" >&2
      errors=$((errors + 1))
      continue
    fi

    matches="$(
      LC_ALL=C awk -v rel="$rel" '/[ \t]$/ {
        printf "%s:%d: trailing whitespace\n", rel, FNR
      }' "$file"
    )"
    if [ -n "$matches" ]; then
      printf '%s\n' "$matches"
      echo "patch-attachment-hygiene-check: trailing whitespace in ${rel}" >&2
      errors=$((errors + 1))
    fi
  done < <(patch_files "$@")

  if [ "$errors" -gt 0 ]; then
    return 1
  fi

  echo "patch-attachment-hygiene-check: ok"
}

main "$@"
