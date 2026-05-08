#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
WORK_DIR="${ROOT_DIR}/.self-harness/tmp/trigger-review-idle-challenge-check"

fail() {
  echo "trigger-review-idle-challenge-check: $*" >&2
  exit 1
}

log() {
  echo "trigger-review-idle-challenge-check: $*"
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
    "${sandbox}/memory/diary"

  printf '%s\n' '.self-harness/' >"${sandbox}/.gitignore"
  cp "${ROOT_DIR}/scripts/supervisor.sh" "${sandbox}/scripts/"
  cp "${ROOT_DIR}/scripts/supervisor-evaluation-trigger-list.sh" "${sandbox}/scripts/"
  chmod +x "${sandbox}/scripts/"*.sh

  git -C "$sandbox" init -q
  git -C "$sandbox" checkout -q -b agent/trigger-review-idle-check
  git -C "$sandbox" config user.name "Self Harness Fixture"
  git -C "$sandbox" config user.email "self-harness-fixture@example.invalid"

  cat >"${sandbox}/memory/diary/baseline.md" <<'DIARY'
---
id: "diary-trigger-review-idle-baseline"
title: "Trigger Review Idle Baseline"
type: "diary"
status: "active"
owner: "agent"
created: "2026-05-08"
updated: "2026-05-08"
tags:
  - diary
summary: "Fixture baseline diary."
---

# Trigger Review Idle Baseline

The fixture has a prior diary so an idle agent branch can otherwise skip.
DIARY

  git -C "$sandbox" add --all -- .
  git -C "$sandbox" commit -q -m "fixture: baseline"
}

add_trigger_source_commit() {
  local sandbox="$1"

  cat >"${sandbox}/mailbox/outbox/2026-05-08-trigger-review-source.md" <<'OUTBOX'
---
id: "mailbox-outbox-trigger-review-source"
title: "Trigger Review Source"
type: "mailbox-message"
status: "done"
owner: "agent"
created: "2026-05-08"
updated: "2026-05-08"
from: "agent/trigger-review-idle-check"
to: "supervisor"
message_id: "trigger-review-source"
tags:
  - mailbox
  - feedback-pressure
summary: "Fixture trigger-backed refusal."
related: []
---

# Trigger Review Source

No next supervisor pressure: further escalation would be noisy because this fixture only needs a later concrete signal.

Supervisor evaluation trigger: reopen pressure if `scripts/example-trigger.sh` changes while the idle loop has no pending inbox.

Stop condition: rerun the trigger-review idle fixture when idle challenge seeding changes.
OUTBOX

  git -C "$sandbox" add --all -- .
  git -C "$sandbox" commit -q -m "fixture: trigger source"
}

add_later_trigger_evidence_commit() {
  local sandbox="$1"

  cat >"${sandbox}/mailbox/done/2026-05-08-trigger-review-evidence.md" <<'DONE'
---
id: "mailbox-done-trigger-review-evidence"
title: "Trigger Review Evidence"
type: "mailbox-inbox"
status: "done"
owner: "supervisor"
created: "2026-05-08"
updated: "2026-05-08"
from: "supervisor"
to: "agent/trigger-review-idle-check"
message_id: "trigger-review-evidence"
tags:
  - mailbox
summary: "Fixture later durable evidence."
---

# Trigger Review Evidence

Later durable evidence mentions `scripts/example-trigger.sh`.
DONE

  git -C "$sandbox" add --all -- .
  git -C "$sandbox" commit -q -m "fixture: later trigger evidence"
}

add_existing_challenge_marker_commit() {
  local sandbox="$1"

  cat >"${sandbox}/mailbox/done/2026-05-08-existing-trigger-review-pressure-challenge.md" <<'DONE'
---
id: "mailbox-done-existing-trigger-review-pressure-challenge"
title: "Existing Trigger Review Pressure Challenge"
type: "mailbox-inbox"
status: "done"
owner: "supervisor"
created: "2026-05-08"
updated: "2026-05-08"
from: "supervisor"
to: "agent/trigger-review-idle-check"
message_id: "existing-trigger-review-pressure-challenge"
tags:
  - mailbox
  - feedback-pressure
summary: "Fixture completed trigger-review pressure challenge."
related:
  - "mailbox/outbox/2026-05-08-trigger-review-source.md"
trigger-review-source: "mailbox/outbox/2026-05-08-trigger-review-source.md"
---

# Existing Trigger Review Pressure Challenge

trigger-review-source: mailbox/outbox/2026-05-08-trigger-review-source.md
DONE

  git -C "$sandbox" add --all -- .
  git -C "$sandbox" commit -q -m "fixture: existing trigger review challenge"
}

add_second_trigger_source_and_evidence_commit() {
  local sandbox="$1"

  cat >"${sandbox}/mailbox/outbox/2026-05-08-second-trigger-review-source.md" <<'OUTBOX'
---
id: "mailbox-outbox-second-trigger-review-source"
title: "Second Trigger Review Source"
type: "mailbox-message"
status: "done"
owner: "agent"
created: "2026-05-08"
updated: "2026-05-08"
from: "agent/trigger-review-idle-check"
to: "supervisor"
message_id: "second-trigger-review-source"
tags:
  - mailbox
  - feedback-pressure
summary: "Fixture second trigger-backed refusal."
related: []
---

# Second Trigger Review Source

No next supervisor pressure: further escalation would be noisy because this fixture only needs a later second concrete signal.

Supervisor evaluation trigger: reopen pressure if `scripts/second-trigger.sh` changes while the idle loop has no pending inbox.

Stop condition: rerun the trigger-review idle fixture when idle challenge source selection changes.
OUTBOX

  git -C "$sandbox" add --all -- .
  git -C "$sandbox" commit -q -m "fixture: second trigger source"

  cat >"${sandbox}/mailbox/done/2026-05-08-second-trigger-review-evidence.md" <<'DONE'
---
id: "mailbox-done-second-trigger-review-evidence"
title: "Second Trigger Review Evidence"
type: "mailbox-inbox"
status: "done"
owner: "supervisor"
created: "2026-05-08"
updated: "2026-05-08"
from: "supervisor"
to: "agent/trigger-review-idle-check"
message_id: "second-trigger-review-evidence"
tags:
  - mailbox
summary: "Fixture second later durable evidence."
---

# Second Trigger Review Evidence

Later durable evidence mentions `scripts/second-trigger.sh`.
DONE

  git -C "$sandbox" add --all -- .
  git -C "$sandbox" commit -q -m "fixture: second trigger evidence"
}

run_seed() {
  local sandbox="$1"
  local log_file="$2"

  (
    cd "$sandbox"
    SELF_HARNESS_AUTO_CHALLENGE=1 \
      SELF_HARNESS_TRIGGER_REVIEW_LIMIT=5 \
      SELF_HARNESS_SUPERVISOR_ROOT="$sandbox" \
      bash -c 'source scripts/supervisor.sh __self_harness_source_only; seed_progressive_challenge_if_needed'
  ) >"$log_file" 2>&1
}

challenge_count() {
  find "$1/mailbox/inbox" -maxdepth 1 -type f -name '*trigger-review-pressure-challenge.md' \
    | wc -l \
    | tr -d '[:space:]'
}

check_seeds_from_trigger_review_evidence() {
  local sandbox log_file challenge
  sandbox="${WORK_DIR}/positive"
  log_file="${WORK_DIR}/positive.log"
  prepare_sandbox "$sandbox"
  add_trigger_source_commit "$sandbox"
  add_later_trigger_evidence_commit "$sandbox"

  run_seed "$sandbox" "$log_file"

  [ "$(challenge_count "$sandbox")" = "1" ] || {
    sed -n '1,160p' "$log_file" >&2
    fail "expected one trigger-review inbox challenge"
  }
  rg -q 'seeded trigger review challenge:' "$log_file" || {
    sed -n '1,160p' "$log_file" >&2
    fail "positive seed did not log trigger-review seeding"
  }
  challenge="$(find "$sandbox/mailbox/inbox" -maxdepth 1 -type f -name '*trigger-review-pressure-challenge.md' | sort | head -1)"
  rg -q 'trigger-review-source: "mailbox/outbox/2026-05-08-trigger-review-source.md"' "$challenge" || fail "generated challenge omitted source frontmatter"
  rg -q 'scripts/supervisor.sh triggers --status review --limit 5' "$challenge" || fail "generated challenge omitted rerunnable trigger-review command"

  log "seeds a trigger-review challenge from later durable evidence"
}

check_skips_when_source_already_challenged() {
  local sandbox log_file
  sandbox="${WORK_DIR}/already-challenged"
  log_file="${WORK_DIR}/already-challenged.log"
  prepare_sandbox "$sandbox"
  add_trigger_source_commit "$sandbox"
  add_later_trigger_evidence_commit "$sandbox"
  add_existing_challenge_marker_commit "$sandbox"

  run_seed "$sandbox" "$log_file"

  [ "$(challenge_count "$sandbox")" = "0" ] || {
    sed -n '1,160p' "$log_file" >&2
    fail "already-challenged source should not seed another inbox"
  }
  rg -q 'trigger review challenge skipped: all review-evidence sources already challenged' "$log_file" || {
    sed -n '1,160p' "$log_file" >&2
    fail "already-challenged case did not explain skip"
  }

  log "does not reseed trigger-review pressure for the same source"
}

check_seeds_older_unchallenged_source_after_newer_marker() {
  local sandbox log_file challenge
  sandbox="${WORK_DIR}/older-unchallenged"
  log_file="${WORK_DIR}/older-unchallenged.log"
  prepare_sandbox "$sandbox"
  add_trigger_source_commit "$sandbox"
  add_later_trigger_evidence_commit "$sandbox"
  add_second_trigger_source_and_evidence_commit "$sandbox"
  add_existing_challenge_marker_commit "$sandbox"

  run_seed "$sandbox" "$log_file"

  [ "$(challenge_count "$sandbox")" = "1" ] || {
    sed -n '1,160p' "$log_file" >&2
    fail "expected one trigger-review challenge for the older unchallenged source"
  }
  challenge="$(find "$sandbox/mailbox/inbox" -maxdepth 1 -type f -name '*trigger-review-pressure-challenge.md' | sort | head -1)"
  rg -q 'trigger-review-source: "mailbox/outbox/2026-05-08-second-trigger-review-source.md"' "$challenge" || {
    sed -n '1,180p' "$challenge" >&2
    fail "generated challenge did not target the older unchallenged source"
  }

  log "seeds an older unchallenged source when the newest review source already has a marker"
}

check_skips_without_review_evidence() {
  local sandbox log_file
  sandbox="${WORK_DIR}/quiet"
  log_file="${WORK_DIR}/quiet.log"
  prepare_sandbox "$sandbox"
  add_trigger_source_commit "$sandbox"

  run_seed "$sandbox" "$log_file"

  [ "$(challenge_count "$sandbox")" = "0" ] || {
    sed -n '1,160p' "$log_file" >&2
    fail "quiet trigger source should not seed a trigger-review inbox"
  }

  log "does not seed when trigger review has no later evidence"
}

main() {
  rm -rf "$WORK_DIR"
  mkdir -p "$WORK_DIR"
  check_seeds_from_trigger_review_evidence
  check_skips_when_source_already_challenged
  check_seeds_older_unchallenged_source_after_newer_marker
  check_skips_without_review_evidence
  log "ok"
}

main "$@"
