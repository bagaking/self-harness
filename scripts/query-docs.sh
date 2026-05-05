#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

usage() {
  cat <<'EOF'
Usage:
  scripts/query-docs.sh [scope] [query...]

Scopes:
  constitution  memory  skills  mailbox  scripts  all

Examples:
  scripts/query-docs.sh constitution supervisor
  scripts/query-docs.sh memory mailbox
  scripts/query-docs.sh all frontmatter
EOF
}

scope="all"
if [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
  usage
  exit 0
fi

case "${1:-}" in
  constitution|memory|skills|mailbox|scripts|all)
    scope="$1"
    shift
    ;;
esac

query="$*"

dirs_for_scope() {
  case "$scope" in
    constitution) printf '%s\n' "${ROOT_DIR}/constitution" ;;
    memory) printf '%s\n' "${ROOT_DIR}/memory" ;;
    skills) printf '%s\n' "${ROOT_DIR}/skills" ;;
    mailbox) printf '%s\n' "${ROOT_DIR}/mailbox" ;;
    scripts) printf '%s\n' "${ROOT_DIR}/scripts" ;;
    all)
      printf '%s\n' \
        "${ROOT_DIR}/constitution" \
        "${ROOT_DIR}/memory" \
        "${ROOT_DIR}/skills" \
        "${ROOT_DIR}/mailbox" \
        "${ROOT_DIR}/scripts"
      ;;
    *)
      echo "Unknown scope: ${scope}" >&2
      exit 2
      ;;
  esac
}

has_frontmatter() {
  [ -f "$1" ] && [ "$(sed -n '1p' "$1")" = "---" ]
}

print_frontmatter() {
  local file="$1"
  if has_frontmatter "$file"; then
    awk '
      NR == 1 { next }
      /^---$/ { exit }
      { print "  " $0 }
    ' "$file"
  else
    echo "  (no frontmatter)"
  fi
}

matches_query() {
  local file="$1"
  if [ -z "$query" ]; then
    return 0
  fi
  rg -qi -- "$query" "$file"
}

print_match_lines() {
  local file="$1"
  if [ -n "$query" ]; then
    rg -n -i -- "$query" "$file" | sed 's/^/  /' || true
  fi
}

found=0
while IFS= read -r dir; do
  [ -d "$dir" ] || continue
  while IFS= read -r file; do
    [ -f "$file" ] || continue
    if matches_query "$file"; then
      rel="${file#${ROOT_DIR}/}"
      echo "===== ${rel} ====="
      print_frontmatter "$file"
      print_match_lines "$file"
      echo
      found=1
    fi
  done < <(find "$dir" -type f -name '*.md' | sort)
done < <(dirs_for_scope)

if [ "$found" -eq 0 ]; then
  if [ -n "$query" ]; then
    echo "No matching Markdown documents for scope '${scope}' and query '${query}'."
  else
    echo "No Markdown documents found for scope '${scope}'."
  fi
fi
