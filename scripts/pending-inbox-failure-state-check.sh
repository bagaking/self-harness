#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
WORK_DIR="${ROOT_DIR}/.self-harness/tmp/pending-inbox-failure-state-check"

fail() {
  echo "pending-inbox-failure-state-check: $*" >&2
  exit 1
}

log() {
  echo "pending-inbox-failure-state-check: $*"
}

prepare_sandbox() {
  local sandbox="$1"

  rm -rf "$sandbox"
  mkdir -p \
    "${sandbox}/scripts" \
    "${sandbox}/mailbox/inbox" \
    "${sandbox}/mailbox/processing" \
    "${sandbox}/mailbox/outbox" \
    "${sandbox}/mailbox/done" \
    "${sandbox}/mailbox/failed" \
    "${sandbox}/memory/incidents" \
    "${sandbox}/sessions"

  cp "${ROOT_DIR}/scripts/pending-inbox-session-only-check.sh" "${sandbox}/scripts/"
  chmod +x "${sandbox}/scripts/pending-inbox-session-only-check.sh"

  git -C "$sandbox" init -q
  git -C "$sandbox" checkout -q -b agent/pending-inbox-check
  git -C "$sandbox" config user.name "Self Harness Fixture"
  git -C "$sandbox" config user.email "self-harness-fixture@example.invalid"
  touch \
    "${sandbox}/mailbox/inbox/.gitkeep" \
    "${sandbox}/mailbox/processing/.gitkeep" \
    "${sandbox}/mailbox/outbox/.gitkeep" \
    "${sandbox}/mailbox/done/.gitkeep" \
    "${sandbox}/mailbox/failed/.gitkeep"
  git -C "$sandbox" add --all -- .
  git -C "$sandbox" commit -q -m "fixture: initial pending inbox check sandbox"
}

write_pending_inbox() {
  local sandbox="$1"
  printf '%s\n' 'pending task' >"${sandbox}/mailbox/inbox/pending-task.md"
}

write_session_change() {
  local sandbox="$1"
  mkdir -p "${sandbox}/sessions/2026/05/07"
  printf '%s\n' '{"event":"session-only"}' >"${sandbox}/sessions/2026/05/07/rollout.jsonl"
}

write_incident_change() {
  local sandbox="$1"
  printf '%s\n' '# Codex Run Failure' >"${sandbox}/memory/incidents/failed-before-claim.md"
}

write_outbox_change() {
  local sandbox="$1"
  printf '%s\n' '# Mailbox Reply' >"${sandbox}/mailbox/outbox/pending-task-reply.md"
}

run_check() {
  local sandbox="$1"
  local log_file="$2"
  set +e
  (
    cd "$sandbox"
    bash scripts/pending-inbox-session-only-check.sh
  ) >"$log_file" 2>&1
  local status=$?
  set -e
  return "$status"
}

check_rejects_pending_inbox_session_only() {
  local sandbox log_file status
  sandbox="${WORK_DIR}/session-only"
  log_file="${WORK_DIR}/session-only.log"
  prepare_sandbox "$sandbox"
  write_pending_inbox "$sandbox"
  git -C "$sandbox" add -- mailbox/inbox/pending-task.md
  git -C "$sandbox" commit -q -m "fixture: pending inbox"
  write_session_change "$sandbox"

  if run_check "$sandbox" "$log_file"; then
    status=0
  else
    status=$?
  fi
  [ "$status" -eq 1 ] || {
    sed -n '1,160p' "$log_file" >&2
    fail "session-only pending inbox check returned ${status}, expected 1"
  }
  rg -q 'pending inbox still exists' "$log_file" || fail "session-only failure did not explain the pending inbox"

  log "rejects pending inbox with only session transcript changes"
}

check_rejects_pending_inbox_failure_incident_only() {
  local sandbox log_file status
  sandbox="${WORK_DIR}/failure-incident"
  log_file="${WORK_DIR}/failure-incident.log"
  prepare_sandbox "$sandbox"
  write_pending_inbox "$sandbox"
  git -C "$sandbox" add -- mailbox/inbox/pending-task.md
  git -C "$sandbox" commit -q -m "fixture: pending inbox"
  write_session_change "$sandbox"
  write_incident_change "$sandbox"

  if run_check "$sandbox" "$log_file"; then
    status=0
  else
    status=$?
  fi
  [ "$status" -eq 1 ] || {
    sed -n '1,160p' "$log_file" >&2
    fail "failure-incident pending inbox check returned ${status}, expected 1"
  }
  rg -q 'session transcripts or failure incidents' "$log_file" || fail "failure-incident check did not name the strengthened boundary"
  rg -q 'memory/incidents/failed-before-claim.md' "$log_file" || fail "failure-incident check did not list the incident file"

  log "rejects pending inbox with only session transcript and failure incident changes"
}

check_allows_pending_inbox_with_mailbox_handling() {
  local sandbox log_file status
  sandbox="${WORK_DIR}/mailbox-handled"
  log_file="${WORK_DIR}/mailbox-handled.log"
  prepare_sandbox "$sandbox"
  write_pending_inbox "$sandbox"
  git -C "$sandbox" add -- mailbox/inbox/pending-task.md
  git -C "$sandbox" commit -q -m "fixture: pending inbox"
  write_session_change "$sandbox"
  write_incident_change "$sandbox"
  write_outbox_change "$sandbox"

  run_check "$sandbox" "$log_file"
  status=$?
  [ "$status" -eq 0 ] || {
    sed -n '1,160p' "$log_file" >&2
    fail "mailbox-handled pending inbox check returned ${status}, expected 0"
  }
  rg -q '^pending-inbox-session-only-check: ok$' "$log_file" || fail "mailbox-handled check did not report ok"

  log "allows pending inbox when current changes include mailbox handling evidence"
}

main() {
  rm -rf "$WORK_DIR"
  mkdir -p "$WORK_DIR"
  check_rejects_pending_inbox_session_only
  check_rejects_pending_inbox_failure_incident_only
  check_allows_pending_inbox_with_mailbox_handling
  log "ok"
}

main "$@"
