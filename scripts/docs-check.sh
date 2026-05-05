#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

required_fields=(id title type status owner created updated tags summary)
errors=0

error() {
  echo "docs-check: $*" >&2
  errors=$((errors + 1))
}

has_frontmatter() {
  [ -f "$1" ] && [ "$(sed -n '1p' "$1")" = "---" ]
}

frontmatter() {
  awk '
    NR == 1 { next }
    /^---$/ { exit }
    { print }
  ' "$1"
}

field_exists() {
  local field="$1"
  rg -q "^${field}:" <<<"$2"
}

extract_id() {
  awk -F: '/^id:/ { sub(/^[[:space:]]+/, "", $2); gsub(/^"|"$/, "", $2); print $2; exit }' <<<"$1"
}

check_markdown_file() {
  local file="$1"
  local rel="${file#${ROOT_DIR}/}"

  case "$rel" in
    sessions/*) return 0 ;;
    skills/*) return 0 ;;
  esac

  if ! has_frontmatter "$file"; then
    error "${rel}: missing YAML frontmatter"
    return 0
  fi

  local fm
  fm="$(frontmatter "$file")"
  for field in "${required_fields[@]}"; do
    if ! field_exists "$field" "$fm"; then
      error "${rel}: missing frontmatter field '${field}'"
    fi
  done

  if [[ "$rel" == constitution/* ]]; then
    field_exists "protected" "$fm" || error "${rel}: constitution file missing protected:true"
    field_exists "authority" "$fm" || error "${rel}: constitution file missing authority"
    field_exists "mutable_by" "$fm" || error "${rel}: constitution file missing mutable_by"
  fi
}

check_no_forbidden_indexes() {
  while IFS= read -r file; do
    local rel="${file#${ROOT_DIR}/}"
    case "$rel" in
      */index.md|index.md)
        error "${rel}: manual index files are forbidden; use scripts/query-docs.sh"
        ;;
    esac
  done < <(find "$ROOT_DIR" \
    -path "$ROOT_DIR/.git" -prune -o \
    -path "$ROOT_DIR/.codex" -prune -o \
    -type f -name '*.md' -print)
}

check_no_constitution_symlinks() {
  [ -d "$ROOT_DIR/constitution" ] || {
    error "constitution/: missing directory"
    return
  }
  while IFS= read -r path; do
    error "${path#${ROOT_DIR}/}: constitution must not contain symlinks"
  done < <(find "$ROOT_DIR/constitution" -type l -print)
}

check_duplicate_ids() {
  local seen_file
  seen_file="$(mktemp)"
  trap 'rm -f "$seen_file"' RETURN

  while IFS= read -r file; do
    has_frontmatter "$file" || continue
    local fm id rel
    fm="$(frontmatter "$file")"
    id="$(extract_id "$fm")"
    [ -n "$id" ] || continue
    rel="${file#${ROOT_DIR}/}"
    if rg -q "^${id} " "$seen_file"; then
      error "${rel}: duplicate frontmatter id '${id}'"
    else
      printf '%s %s\n' "$id" "$rel" >>"$seen_file"
    fi
  done < <(find "$ROOT_DIR" \
    -path "$ROOT_DIR/.git" -prune -o \
    -path "$ROOT_DIR/.codex" -prune -o \
    -type f -name '*.md' -print)
}

check_layout() {
  [ -L "$ROOT_DIR/.codex/skills" ] || error ".codex/skills: expected symlink"
  [ -L "$ROOT_DIR/.codex/sessions" ] || error ".codex/sessions: expected symlink"
  [ "$(readlink "$ROOT_DIR/.codex/skills" 2>/dev/null || true)" = "../skills" ] || error ".codex/skills: expected target ../skills"
  [ "$(readlink "$ROOT_DIR/.codex/sessions" 2>/dev/null || true)" = "../sessions" ] || error ".codex/sessions: expected target ../sessions"
}

while IFS= read -r file; do
  check_markdown_file "$file"
done < <(find "$ROOT_DIR" \
  -path "$ROOT_DIR/.git" -prune -o \
  -path "$ROOT_DIR/.codex" -prune -o \
  -type f -name '*.md' -print)

check_no_forbidden_indexes
check_no_constitution_symlinks
check_duplicate_ids
check_layout

if [ "$errors" -gt 0 ]; then
  exit 1
fi

echo "docs-check: ok"
