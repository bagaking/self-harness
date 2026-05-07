#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
WORK_DIR="${ROOT_DIR}/.self-harness/tmp/memory-evaluation-conflict-fixture-check"

fail() {
  echo "memory-evaluation-conflict-fixture-check: $*" >&2
  exit 1
}

log() {
  echo "memory-evaluation-conflict-fixture-check: $*"
}

prepare_sandbox() {
  local sandbox="$1"
  rm -rf "$sandbox"
  mkdir -p "${sandbox}/memory/lessons"
}

write_note() {
  local file="$1"
  local id="$2"
  local title="$3"
  local subject="$4"
  local value="$5"
  local conflicts_with="${6:-}"

  {
    cat <<EOF
---
id: "${id}"
title: "${title}"
type: "memory"
status: "active"
owner: "agent"
created: "2026-05-08"
updated: "2026-05-08"
tags:
  - fixture
  - memory
  - conflict
summary: "Scratch memory evidence for conflict fixture validation."
conflict_fixture: "memory-evaluation-conflict"
conflict_subject: "${subject}"
conflict_value: "${value}"
EOF
    if [ -n "$conflicts_with" ]; then
      cat <<EOF
conflicts_with:
  - "${conflicts_with}"
EOF
    fi
    cat <<EOF
---

# ${title}

This scratch note is independent evidence for the conflict fixture.
EOF
  } >"$file"
}

run_count() {
  local sandbox="$1"
  MEMORY_EVALUATION_ROOT_DIR="$sandbox" \
    bash "${ROOT_DIR}/scripts/memory-evaluation-check.sh" --count-contradiction-fixtures
}

expect_count() {
  local label="$1"
  local expected="$2"
  local sandbox="${WORK_DIR}/${label}"
  local actual

  prepare_sandbox "$sandbox"

  case "$label" in
    reciprocal-contradiction)
      write_note "${sandbox}/memory/lessons/a.md" "memory-conflict-fixture-positive-a" "Memory Conflict Fixture A" "fixture-claim" "alpha" "memory-conflict-fixture-positive-b"
      write_note "${sandbox}/memory/lessons/b.md" "memory-conflict-fixture-positive-b" "Memory Conflict Fixture B" "fixture-claim" "beta" "memory-conflict-fixture-positive-a"
      ;;
    same-value)
      write_note "${sandbox}/memory/lessons/a.md" "memory-conflict-fixture-same-a" "Memory Conflict Fixture A" "fixture-claim" "alpha" "memory-conflict-fixture-same-b"
      write_note "${sandbox}/memory/lessons/b.md" "memory-conflict-fixture-same-b" "Memory Conflict Fixture B" "fixture-claim" "alpha" "memory-conflict-fixture-same-a"
      ;;
    one-sided-link)
      write_note "${sandbox}/memory/lessons/a.md" "memory-conflict-fixture-one-sided-a" "Memory Conflict Fixture A" "fixture-claim" "alpha" "memory-conflict-fixture-one-sided-b"
      write_note "${sandbox}/memory/lessons/b.md" "memory-conflict-fixture-one-sided-b" "Memory Conflict Fixture B" "fixture-claim" "beta"
      ;;
    unrelated-subject)
      write_note "${sandbox}/memory/lessons/a.md" "memory-conflict-fixture-unrelated-a" "Memory Conflict Fixture A" "fixture-claim-a" "alpha" "memory-conflict-fixture-unrelated-b"
      write_note "${sandbox}/memory/lessons/b.md" "memory-conflict-fixture-unrelated-b" "Memory Conflict Fixture B" "fixture-claim-b" "beta" "memory-conflict-fixture-unrelated-a"
      ;;
    combined)
      expect_count reciprocal-contradiction 1 >/dev/null
      expect_count same-value 0 >/dev/null
      expect_count one-sided-link 0 >/dev/null
      expect_count unrelated-subject 0 >/dev/null
      cp "${WORK_DIR}/reciprocal-contradiction/memory/lessons/a.md" "${sandbox}/memory/lessons/reciprocal-a.md"
      cp "${WORK_DIR}/reciprocal-contradiction/memory/lessons/b.md" "${sandbox}/memory/lessons/reciprocal-b.md"
      cp "${WORK_DIR}/same-value/memory/lessons/a.md" "${sandbox}/memory/lessons/same-a.md"
      cp "${WORK_DIR}/same-value/memory/lessons/b.md" "${sandbox}/memory/lessons/same-b.md"
      cp "${WORK_DIR}/one-sided-link/memory/lessons/a.md" "${sandbox}/memory/lessons/one-sided-a.md"
      cp "${WORK_DIR}/one-sided-link/memory/lessons/b.md" "${sandbox}/memory/lessons/one-sided-b.md"
      cp "${WORK_DIR}/unrelated-subject/memory/lessons/a.md" "${sandbox}/memory/lessons/unrelated-a.md"
      cp "${WORK_DIR}/unrelated-subject/memory/lessons/b.md" "${sandbox}/memory/lessons/unrelated-b.md"
      ;;
    *)
      fail "unknown fixture case ${label}"
      ;;
  esac

  actual="$(run_count "$sandbox")"
  [ "$actual" = "$expected" ] || {
    fail "${label}: expected ${expected} contradiction fixtures, got ${actual}"
  }

  log "${label}: ${actual} contradiction fixtures"
}

main() {
  mkdir -p "$WORK_DIR"

  expect_count reciprocal-contradiction 1
  expect_count same-value 0
  expect_count one-sided-link 0
  expect_count unrelated-subject 0
  expect_count combined 1
  log "ok"
}

main "$@"
