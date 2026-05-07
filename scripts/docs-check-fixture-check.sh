#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
WORK_DIR="${ROOT_DIR}/.self-harness/tmp/docs-check-fixture-check"

fail() {
  echo "docs-check-fixture-check: $*" >&2
  exit 1
}

log() {
  echo "docs-check-fixture-check: $*"
}

write_doc() {
  local file="$1"
  local id="$2"
  local type="$3"
  local title="$4"
  mkdir -p "$(dirname "$file")"
  {
    printf '%s\n' '---'
    printf 'id: "%s"\n' "$id"
    printf 'title: "%s"\n' "$title"
    printf 'type: "%s"\n' "$type"
    printf '%s\n' 'status: "active"'
    printf '%s\n' 'owner: "agent"'
    printf '%s\n' 'created: "2026-05-07"'
    printf '%s\n' 'updated: "2026-05-07"'
    printf '%s\n' 'tags:'
    printf '%s\n' '  - fixture'
    printf 'summary: "Fixture document for %s."\n' "$title"
    printf '%s\n' '---'
    printf '%s\n' ''
    printf '# %s\n' "$title"
  } >"$file"
}

write_constitution_doc() {
  local file="$1"
  mkdir -p "$(dirname "$file")"
  {
    printf '%s\n' '---'
    printf '%s\n' 'id: "constitution-fixture-charter"'
    printf '%s\n' 'title: "Fixture Charter"'
    printf '%s\n' 'type: "constitution"'
    printf '%s\n' 'status: "active"'
    printf '%s\n' 'owner: "human"'
    printf '%s\n' 'protected: true'
    printf '%s\n' 'authority: "constitutional"'
    printf '%s\n' 'mutable_by: "human-only"'
    printf '%s\n' 'created: "2026-05-07"'
    printf '%s\n' 'updated: "2026-05-07"'
    printf '%s\n' 'tags:'
    printf '%s\n' '  - fixture'
    printf '%s\n' 'summary: "Fixture constitution document."'
    printf '%s\n' '---'
    printf '%s\n' ''
    printf '%s\n' '# Fixture Charter'
  } >"$file"
}

write_doc_without_summary() {
  local file="$1"
  mkdir -p "$(dirname "$file")"
  {
    printf '%s\n' '---'
    printf '%s\n' 'id: "missing-summary-fixture"'
    printf '%s\n' 'title: "Missing Summary Fixture"'
    printf '%s\n' 'type: "memory"'
    printf '%s\n' 'status: "active"'
    printf '%s\n' 'owner: "agent"'
    printf '%s\n' 'created: "2026-05-07"'
    printf '%s\n' 'updated: "2026-05-07"'
    printf '%s\n' 'tags:'
    printf '%s\n' '  - fixture'
    printf '%s\n' '---'
    printf '%s\n' ''
    printf '%s\n' '# Missing Summary Fixture'
  } >"$file"
}

prepare_sandbox() {
  local sandbox="$1"

  rm -rf "$sandbox"
  mkdir -p \
    "${sandbox}/scripts" \
    "${sandbox}/.codex" \
    "${sandbox}/constitution" \
    "${sandbox}/memory/lessons" \
    "${sandbox}/sessions" \
    "${sandbox}/skills"

  cp "${ROOT_DIR}/scripts/docs-check.sh" "${sandbox}/scripts/docs-check.sh"
  chmod +x "${sandbox}/scripts/docs-check.sh"
  ln -s ../skills "${sandbox}/.codex/skills"
  ln -s ../sessions "${sandbox}/.codex/sessions"

  write_constitution_doc "${sandbox}/constitution/00-charter.md"
  write_doc \
    "${sandbox}/memory/lessons/valid.md" \
    "lesson-valid-fixture" \
    "memory" \
    "Valid Fixture"
}

run_docs_check() {
  local sandbox="$1"
  local log_file="$2"
  (
    cd "$sandbox"
    bash scripts/docs-check.sh
  ) >"$log_file" 2>&1
}

check_passes_valid_minimal_fixture() {
  local sandbox log_file
  sandbox="${WORK_DIR}/valid-minimal"
  log_file="${WORK_DIR}/valid-minimal.log"
  prepare_sandbox "$sandbox"

  if ! run_docs_check "$sandbox" "$log_file"; then
    sed -n '1,160p' "$log_file" >&2
    fail "valid minimal fixture should pass"
  fi

  grep -q 'docs-check: ok' "$log_file" || {
    sed -n '1,160p' "$log_file" >&2
    fail "valid minimal fixture did not report ok"
  }

  log "valid minimal fixture passes"
}

check_rejects() {
  local name="$1"
  local expected="$2"
  local sandbox log_file status

  sandbox="${WORK_DIR}/${name}"
  log_file="${WORK_DIR}/${name}.log"
  prepare_sandbox "$sandbox"

  case "$name" in
    missing-frontmatter-field)
      write_doc_without_summary "${sandbox}/memory/lessons/missing-summary.md"
      ;;
    duplicate-frontmatter-id)
      write_doc \
        "${sandbox}/memory/lessons/duplicate-one.md" \
        "duplicate-id-fixture" \
        "memory" \
        "Duplicate One"
      write_doc \
        "${sandbox}/memory/lessons/duplicate-two.md" \
        "duplicate-id-fixture" \
        "memory" \
        "Duplicate Two"
      ;;
    forbidden-manual-index)
      write_doc \
        "${sandbox}/memory/index.md" \
        "manual-index-fixture" \
        "memory" \
        "Manual Index Fixture"
      ;;
    constitution-symlink)
      ln -s ../memory/lessons/valid.md "${sandbox}/constitution/linked.md"
      ;;
    patch-editor-sentinel)
      {
        printf '%s\n' ''
        printf '%s\n' '*** Begin Patch'
      } >>"${sandbox}/memory/lessons/valid.md"
      ;;
    *)
      fail "unknown rejection case ${name}"
      ;;
  esac

  set +e
  run_docs_check "$sandbox" "$log_file"
  status=$?
  set -e

  if [ "$status" -eq 0 ]; then
    sed -n '1,160p' "$log_file" >&2
    fail "${name}: docs-check unexpectedly passed"
  fi

  grep -q "$expected" "$log_file" || {
    sed -n '1,160p' "$log_file" >&2
    fail "${name}: expected diagnostic not found: ${expected}"
  }

  log "${name} rejected"
}

main() {
  mkdir -p "$WORK_DIR"

  check_passes_valid_minimal_fixture
  check_rejects missing-frontmatter-field "missing frontmatter field 'summary'"
  check_rejects duplicate-frontmatter-id "duplicate frontmatter id 'duplicate-id-fixture'"
  check_rejects forbidden-manual-index "manual index files are forbidden"
  check_rejects constitution-symlink "constitution must not contain symlinks"
  check_rejects patch-editor-sentinel "patch-editor sentinel line found"
  log "ok"
}

main "$@"
