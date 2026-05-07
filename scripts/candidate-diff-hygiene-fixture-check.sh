#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
WORK_DIR="${ROOT_DIR}/.self-harness/tmp/candidate-diff-hygiene-check"

fail() {
  echo "candidate-diff-hygiene-fixture-check: $*" >&2
  exit 1
}

log() {
  echo "candidate-diff-hygiene-fixture-check: $*"
}

prepare_sandbox() {
  local sandbox="$1"

  rm -rf "$sandbox"
  mkdir -p "$sandbox/scripts" "$sandbox/mailbox/outbox" "$sandbox/memory/diary"
  cp "${ROOT_DIR}/scripts/candidate-diff-hygiene-check.sh" "$sandbox/scripts/"
  chmod +x "$sandbox/scripts/candidate-diff-hygiene-check.sh"

  git -C "$sandbox" init -q
  git -C "$sandbox" checkout -q -b main
  git -C "$sandbox" config user.name "Self Harness Fixture"
  git -C "$sandbox" config user.email "self-harness-fixture@example.invalid"

  printf '%s\n' '# Fixture' >"$sandbox/README.md"
  git -C "$sandbox" add --all -- .
  git -C "$sandbox" commit -q -m "fixture: main baseline"
  git -C "$sandbox" branch origin/main
  git -C "$sandbox" checkout -q -b agent/candidate-diff-hygiene
}

check_positive_clean_candidate_with_dirty_branch_record() {
  local sandbox log_file
  sandbox="${WORK_DIR}/positive"
  log_file="${WORK_DIR}/positive.log"
  prepare_sandbox "$sandbox"

  printf '%s\n' 'candidate helper' >"$sandbox/scripts/helper.sh"
  printf '%s\n' 'done line  ' >"$sandbox/mailbox/outbox/2026-05-08-dirty-record.md"
  git -C "$sandbox" add --all -- .
  git -C "$sandbox" commit -q -m "fixture: clean candidate and dirty branch record"

  (
    cd "$sandbox"
    scripts/candidate-diff-hygiene-check.sh scripts/helper.sh
  ) >"$log_file" 2>&1 || {
    sed -n '1,160p' "$log_file" >&2
    fail "clean candidate path should pass even when a branch-local record is dirty"
  }

  rg -q '^candidate-diff-hygiene-check: ok$' "$log_file" || {
    sed -n '1,160p' "$log_file" >&2
    fail "positive output did not report ok"
  }
  log "positive clean candidate surface passed despite dirty branch-local record"
}

check_negative_dirty_candidate() {
  local sandbox log_file status
  sandbox="${WORK_DIR}/dirty-candidate"
  log_file="${WORK_DIR}/dirty-candidate.log"
  prepare_sandbox "$sandbox"

  printf '%s\n' 'candidate helper  ' >"$sandbox/scripts/helper.sh"
  git -C "$sandbox" add --all -- .
  git -C "$sandbox" commit -q -m "fixture: dirty candidate"

  set +e
  (
    cd "$sandbox"
    scripts/candidate-diff-hygiene-check.sh scripts/helper.sh
  ) >"$log_file" 2>&1
  status=$?
  set -e

  [ "$status" -ne 0 ] || {
    sed -n '1,160p' "$log_file" >&2
    fail "dirty candidate path unexpectedly passed"
  }

  rg -q 'scripts/helper.sh:[0-9]+: trailing whitespace' "$log_file" || {
    sed -n '1,160p' "$log_file" >&2
    fail "dirty candidate output did not name the failing path"
  }
  log "negative dirty candidate surface failed as expected"
}

check_negative_branch_local_path() {
  local sandbox log_file status
  sandbox="${WORK_DIR}/branch-local"
  log_file="${WORK_DIR}/branch-local.log"
  prepare_sandbox "$sandbox"

  printf '%s\n' 'branch record' >"$sandbox/mailbox/outbox/2026-05-08-record.md"
  git -C "$sandbox" add --all -- .
  git -C "$sandbox" commit -q -m "fixture: branch-local record"

  set +e
  (
    cd "$sandbox"
    scripts/candidate-diff-hygiene-check.sh mailbox/outbox/2026-05-08-record.md
  ) >"$log_file" 2>&1
  status=$?
  set -e

  [ "$status" -ne 0 ] || {
    sed -n '1,160p' "$log_file" >&2
    fail "branch-local mailbox path unexpectedly passed"
  }

  rg -q 'branch-local evidence path is not a candidate gene file: mailbox/outbox/2026-05-08-record.md' "$log_file" || {
    sed -n '1,160p' "$log_file" >&2
    fail "branch-local rejection did not name the path"
  }
  log "negative branch-local record path was rejected"
}

check_positive_clean_candidate_with_dirty_branch_record
check_negative_dirty_candidate
check_negative_branch_local_path

log "ok"
