#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
WORK_DIR="${ROOT_DIR}/.self-harness/tmp/supervisor-evaluation-trigger-list-check"

fail() {
  echo "supervisor-evaluation-trigger-list-check: $*" >&2
  exit 1
}

log() {
  echo "supervisor-evaluation-trigger-list-check: $*"
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
    "${sandbox}/memory/diary" \
    "${sandbox}/memory/decisions" \
    "${sandbox}/memory/lessons" \
    "${sandbox}/skills"

  cp "${ROOT_DIR}/scripts/supervisor-evaluation-trigger-list.sh" "${sandbox}/scripts/"
  chmod +x "${sandbox}/scripts/supervisor-evaluation-trigger-list.sh"

  cat >"${sandbox}/mailbox/outbox/2026-05-07-trigger-refusal.md" <<'OUTBOX'
---
id: "mailbox-outbox-trigger-refusal"
title: "Trigger Refusal"
type: "mailbox-message"
status: "done"
owner: "agent"
created: "2026-05-07"
updated: "2026-05-07"
from: "agent/trigger-list-check"
to: "supervisor"
message_id: "trigger-refusal"
tags:
  - mailbox
  - feedback-pressure
summary: "Fixture trigger-backed refusal."
related: []
---

# Trigger Refusal

No next supervisor pressure: further escalation would be noisy because this fixture only needs a future concrete signal.

Supervisor evaluation trigger: reopen pressure if `scripts/example-trigger.sh` changes while a pending inbox remains unclaimed.

Stop condition: rerun the trigger list check when trigger discovery changes.
OUTBOX

  touch \
    "${sandbox}/mailbox/inbox/.gitkeep" \
    "${sandbox}/mailbox/processing/.gitkeep" \
    "${sandbox}/mailbox/outbox/.gitkeep" \
    "${sandbox}/mailbox/done/.gitkeep" \
    "${sandbox}/mailbox/failed/.gitkeep"

  git -C "$sandbox" init -q
  git -C "$sandbox" checkout -q -b agent/trigger-list-check
  git -C "$sandbox" config user.name "Self Harness Fixture"
  git -C "$sandbox" config user.email "self-harness-fixture@example.invalid"
  git -C "$sandbox" add --all -- .
  git -C "$sandbox" commit -q -m "fixture: trigger refusal"
}

check_lists_quiet_trigger_without_self_match() {
  local sandbox log_file
  sandbox="${WORK_DIR}/quiet"
  log_file="${WORK_DIR}/quiet.log"
  prepare_sandbox "$sandbox"

  (
    cd "$sandbox"
    bash scripts/supervisor-evaluation-trigger-list.sh --limit 1
  ) >"$log_file" 2>&1

  rg -q 'source: mailbox/outbox/2026-05-07-trigger-refusal.md' "$log_file" || {
    sed -n '1,120p' "$log_file" >&2
    fail "quiet trigger source was not listed"
  }
  rg -q 'status: no-later-evidence' "$log_file" || {
    sed -n '1,120p' "$log_file" >&2
    fail "quiet trigger should not use its own outbox as evidence"
  }
  rg -q 'evidence: none found after source commit' "$log_file" || {
    sed -n '1,120p' "$log_file" >&2
    fail "quiet trigger did not report absence of later evidence"
  }
  log "lists trigger-backed refusal without treating the source as fired evidence"
}

check_lists_review_evidence_after_later_match() {
  local sandbox log_file
  sandbox="${WORK_DIR}/review"
  log_file="${WORK_DIR}/review.log"
  prepare_sandbox "$sandbox"

  cat >"${sandbox}/mailbox/processing/2026-05-07-unclaimed-example.md" <<'PROCESSING'
---
id: "mailbox-processing-unclaimed-example"
title: "Unclaimed Example"
type: "mailbox-inbox"
status: "pending"
owner: "supervisor"
created: "2026-05-07"
updated: "2026-05-07"
tags:
  - mailbox
summary: "Fixture active evidence."
---

# Unclaimed Example

The pending inbox remains unclaimed after `scripts/example-trigger.sh` changed.
PROCESSING

  (
    cd "$sandbox"
    bash scripts/supervisor-evaluation-trigger-list.sh --limit 1
  ) >"$log_file" 2>&1

  rg -q 'status: review-evidence' "$log_file" || {
    sed -n '1,160p' "$log_file" >&2
    fail "later matching evidence was not surfaced"
  }
  rg -q 'mailbox/processing/2026-05-07-unclaimed-example.md' "$log_file" || {
    sed -n '1,160p' "$log_file" >&2
    fail "later matching processing file was not named"
  }
  rg -q 'scripts/example-trigger.sh' "$log_file" || {
    sed -n '1,160p' "$log_file" >&2
    fail "matched trigger term was not reported"
  }
  log "surfaces later durable evidence for supervisor review"
}

check_status_filter() {
  local sandbox log_file
  sandbox="${WORK_DIR}/filter"
  log_file="${WORK_DIR}/filter.log"
  prepare_sandbox "$sandbox"

  (
    cd "$sandbox"
    bash scripts/supervisor-evaluation-trigger-list.sh --status review
  ) >"$log_file" 2>&1

  rg -q 'no triggers matched status filter review' "$log_file" || {
    sed -n '1,120p' "$log_file" >&2
    fail "review status filter should hide quiet triggers"
  }
  log "supports filtering to triggers with later evidence"
}

check_ignores_marker_only_later_evidence() {
  local sandbox log_file
  sandbox="${WORK_DIR}/marker-only"
  log_file="${WORK_DIR}/marker-only.log"
  prepare_sandbox "$sandbox"

  cat >"${sandbox}/memory/incidents/marker-only.md" <<'INCIDENT'
---
id: "incident-marker-only"
title: "Marker Only"
type: "incident"
status: "active"
owner: "supervisor"
created: "2026-05-07"
updated: "2026-05-07"
tags:
  - incident
summary: "Mentions feedback marker names without the concrete trigger term."
---

# Marker Only

This durable evidence mentions `No next supervisor pressure:` and `Supervisor evaluation trigger:`, but does not mention the script path from the trigger.
INCIDENT

  (
    cd "$sandbox"
    bash scripts/supervisor-evaluation-trigger-list.sh --status review
  ) >"$log_file" 2>&1

  rg -q 'no triggers matched status filter review' "$log_file" || {
    sed -n '1,160p' "$log_file" >&2
    fail "marker-only evidence should not make a trigger look fired"
  }
  log "ignores marker-only later evidence"
}

check_uncommitted_trigger_stays_quiet() {
  local sandbox log_file
  sandbox="${WORK_DIR}/uncommitted"
  log_file="${WORK_DIR}/uncommitted.log"
  prepare_sandbox "$sandbox"

  cat >"${sandbox}/mailbox/outbox/2026-05-07-uncommitted-trigger.md" <<'OUTBOX'
---
id: "mailbox-outbox-uncommitted-trigger"
title: "Uncommitted Trigger"
type: "mailbox-message"
status: "done"
owner: "agent"
created: "2026-05-07"
updated: "2026-05-07"
from: "agent/trigger-list-check"
to: "supervisor"
message_id: "uncommitted-trigger"
tags:
  - mailbox
  - feedback-pressure
summary: "Fixture uncommitted trigger-backed refusal."
related: []
---

# Uncommitted Trigger

No next supervisor pressure: further escalation would be noisy because the source is not committed yet.

Supervisor evaluation trigger: reopen pressure if `scripts/uncommitted-trigger.sh` appears in later durable evidence.

Stop condition: rerun after this source has a source commit.
OUTBOX

  cat >"${sandbox}/memory/diary/uncommitted-trigger.md" <<'DIARY'
---
id: "diary-uncommitted-trigger"
title: "Uncommitted Trigger"
type: "diary"
status: "active"
owner: "agent"
created: "2026-05-07"
updated: "2026-05-07"
tags:
  - diary
summary: "Mentions scripts/uncommitted-trigger.sh in the same uncommitted change set."
---

# Uncommitted Trigger

Same-run evidence mentions `scripts/uncommitted-trigger.sh`.
DIARY

  (
    cd "$sandbox"
    bash scripts/supervisor-evaluation-trigger-list.sh --status review
  ) >"$log_file" 2>&1

  rg -q 'no triggers matched status filter review' "$log_file" || {
    sed -n '1,160p' "$log_file" >&2
    fail "uncommitted trigger should not be marked review-evidence from same-run files"
  }
  log "keeps uncommitted trigger sources quiet until they have a source commit"
}

main() {
  rm -rf "$WORK_DIR"
  mkdir -p "$WORK_DIR"
  check_lists_quiet_trigger_without_self_match
  check_lists_review_evidence_after_later_match
  check_status_filter
  check_ignores_marker_only_later_evidence
  check_uncommitted_trigger_stays_quiet
  log "ok"
}

main "$@"
