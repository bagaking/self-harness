#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
WORK_DIR="${ROOT_DIR}/.self-harness/tmp/feedback-refusal-trigger-check"

fail() {
  echo "feedback-refusal-trigger-check: $*" >&2
  exit 1
}

log() {
  echo "feedback-refusal-trigger-check: $*"
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
    "${sandbox}/memory/decisions" \
    "${sandbox}/memory/lessons" \
    "${sandbox}/memory/proposals" \
    "${sandbox}/memory/incidents" \
    "${sandbox}/skills"

  cp "${ROOT_DIR}/scripts/feedback-escalation-check.sh" "${sandbox}/scripts/"
  chmod +x "${sandbox}/scripts/feedback-escalation-check.sh"

  touch \
    "${sandbox}/mailbox/inbox/.gitkeep" \
    "${sandbox}/mailbox/processing/.gitkeep" \
    "${sandbox}/mailbox/outbox/.gitkeep" \
    "${sandbox}/mailbox/done/.gitkeep" \
    "${sandbox}/mailbox/failed/.gitkeep"

  git -C "$sandbox" init -q
  git -C "$sandbox" checkout -q -b agent/feedback-refusal-trigger-check
  git -C "$sandbox" config user.name "Self Harness Fixture"
  git -C "$sandbox" config user.email "self-harness-fixture@example.invalid"
  git -C "$sandbox" add --all -- .
  git -C "$sandbox" commit -q -m "fixture: initial feedback refusal trigger sandbox"
}

write_feedback_outbox_base() {
  local file="$1"
  local title="$2"
  local continuity="$3"

  cat >"$file" <<EOF
---
id: "mailbox-outbox-feedback-refusal-trigger-fixture"
title: "${title}"
type: "mailbox-message"
status: "done"
owner: "agent"
created: "2026-05-07"
updated: "2026-05-07"
from: "agent/feedback-refusal-trigger-check"
to: "supervisor"
message_id: "feedback-refusal-trigger-fixture"
tags:
  - mailbox
  - feedback-pressure
summary: "Fixture feedback-pressure report for feedback refusal trigger validation."
related: []
---

# ${title}

## Reviewed Evidence

Reviewed the latest three outbox reports and latest three run commits in this fixture.

## Current Weakness

The exact current weakness is that a feedback-pressure run can stop too early by treating a local anti-noise refusal as permission for the supervisor to stop evaluating.

## Refusal

Refused escalation because adding another generic mechanism in this fixture would be noisy and redundant.

## Anti-Noise

This fixture keeps the refusal local and asks for a concrete future evaluation signal instead of another broad repository sweep.

## Verification

Rerunnable verification is provided by \`scripts/feedback-refusal-trigger-check.sh\`.

## Return-To-Main

Return-to-main: no for this scratch fixture.

${continuity}
EOF
}

run_gate() {
  local sandbox="$1"
  local log_file="$2"
  set +e
  (
    cd "$sandbox"
    bash scripts/feedback-escalation-check.sh
  ) >"$log_file" 2>&1
  local status=$?
  set -e
  return "$status"
}

expect_failure() {
  local label="$1"
  local sandbox="$2"
  local log_file="$3"
  local expected="$4"
  local status

  if run_gate "$sandbox" "$log_file"; then
    status=0
  else
    status=$?
  fi

  [ "$status" -ne 0 ] || {
    sed -n '1,160p' "$log_file" >&2
    fail "${label}: expected feedback escalation gate to fail"
  }
  rg -q "$expected" "$log_file" || {
    sed -n '1,160p' "$log_file" >&2
    fail "${label}: failure output did not match ${expected}"
  }
}

expect_success() {
  local label="$1"
  local sandbox="$2"
  local log_file="$3"

  run_gate "$sandbox" "$log_file" || {
    sed -n '1,160p' "$log_file" >&2
    fail "${label}: expected feedback escalation gate to pass"
  }
  rg -q '^feedback-escalation-check: ok$' "$log_file" || {
    sed -n '1,160p' "$log_file" >&2
    fail "${label}: success output did not report ok"
  }
}

check_rejects_old_refusal_without_trigger() {
  local sandbox log_file
  sandbox="${WORK_DIR}/old-refusal"
  log_file="${WORK_DIR}/old-refusal.log"
  prepare_sandbox "$sandbox"
  write_feedback_outbox_base \
    "${sandbox}/mailbox/outbox/feedback-refusal-trigger-fixture.md" \
    "Old Refusal Without Trigger" \
    $'No next supervisor pressure: further escalation would be noisy because the fixture only needs a narrower task.\n\nStop condition: rerun when the feedback refusal gate changes.'

  expect_failure "old refusal without trigger" "$sandbox" "$log_file" "missing feedback continuity marker"
  log "rejects no-next refusal without supervisor evaluation trigger"
}

check_rejects_generic_trigger() {
  local sandbox log_file
  sandbox="${WORK_DIR}/generic-trigger"
  log_file="${WORK_DIR}/generic-trigger.log"
  prepare_sandbox "$sandbox"
  write_feedback_outbox_base \
    "${sandbox}/mailbox/outbox/feedback-refusal-trigger-fixture.md" \
    "Generic Trigger Refusal" \
    $'No next supervisor pressure: further escalation would be noisy because the fixture only needs a narrower task.\n\nSupervisor evaluation trigger: keep evaluating.\n\nStop condition: rerun when the feedback refusal gate changes.'

  expect_failure "generic trigger refusal" "$sandbox" "$log_file" "missing feedback continuity marker"
  log "rejects generic supervisor evaluation trigger"
}

check_rejects_trigger_backed_refusal_without_review() {
  local sandbox log_file
  sandbox="${WORK_DIR}/trigger-backed-refusal-without-review"
  log_file="${WORK_DIR}/trigger-backed-refusal-without-review.log"
  prepare_sandbox "$sandbox"
  write_feedback_outbox_base \
    "${sandbox}/mailbox/outbox/feedback-refusal-trigger-fixture.md" \
    "Trigger Backed Refusal Without Review" \
    $'No next supervisor pressure: further escalation would be noisy because this fixture already proved the refusal boundary.\n\nSupervisor evaluation trigger: reopen pressure if a changed feedback outbox with no next-pressure marker and no trigger-backed refusal passes this gate.\n\nStop condition: rerun when `scripts/feedback-escalation-check.sh` refusal-marker parsing changes.'

  expect_failure "trigger-backed refusal without review" "$sandbox" "$log_file" "missing feedback continuity marker"
  log "rejects trigger-backed no-next refusal without review command"
}

check_allows_reviewed_trigger_backed_refusal() {
  local sandbox log_file
  sandbox="${WORK_DIR}/reviewed-trigger-backed-refusal"
  log_file="${WORK_DIR}/reviewed-trigger-backed-refusal.log"
  prepare_sandbox "$sandbox"
  write_feedback_outbox_base \
    "${sandbox}/mailbox/outbox/feedback-refusal-trigger-fixture.md" \
    "Reviewed Trigger Backed Refusal" \
    $'No next supervisor pressure: further escalation would be noisy because this fixture already proved the refusal boundary and reviewed trigger-backed refusal candidates with `scripts/supervisor.sh triggers --status review`.\n\nSupervisor evaluation trigger: reopen pressure if a changed feedback outbox with no next-pressure marker and no trigger-backed refusal passes this gate.\n\nStop condition: rerun `scripts/supervisor.sh triggers --status review` and this fixture when `scripts/feedback-escalation-check.sh` refusal-marker parsing changes.'

  expect_success "reviewed trigger-backed refusal" "$sandbox" "$log_file"
  log "allows reviewed trigger-backed no-next refusal"
}

check_allows_next_pressure_marker() {
  local sandbox log_file
  sandbox="${WORK_DIR}/next-pressure"
  log_file="${WORK_DIR}/next-pressure.log"
  prepare_sandbox "$sandbox"
  write_feedback_outbox_base \
    "${sandbox}/mailbox/outbox/feedback-refusal-trigger-fixture.md" \
    "Next Pressure Marker" \
    "Next supervisor pressure: run the feedback refusal trigger fixture after the next feedback gate change and verify both negative refusal cases still fail."

  expect_success "next pressure marker" "$sandbox" "$log_file"
  log "allows concrete next supervisor pressure marker without refusal trigger"
}

main() {
  rm -rf "$WORK_DIR"
  mkdir -p "$WORK_DIR"
  check_rejects_old_refusal_without_trigger
  check_rejects_generic_trigger
  check_rejects_trigger_backed_refusal_without_review
  check_allows_reviewed_trigger_backed_refusal
  check_allows_next_pressure_marker
  log "ok"
}

main "$@"
