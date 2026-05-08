#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
WORK_DIR="${ROOT_DIR}/.self-harness/tmp/idle-stop-proof-fixture-check"

fail() {
  echo "idle-stop-proof-fixture-check: $*" >&2
  exit 1
}

log() {
  echo "idle-stop-proof-fixture-check: $*"
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

  {
    printf '%s\n' '/.codex/'
    printf '%s\n' '/.self-harness/'
  } >"${sandbox}/.gitignore"
  cp "${ROOT_DIR}/scripts/init.sh" "${sandbox}/scripts/"
  cp "${ROOT_DIR}/scripts/supervisor.sh" "${sandbox}/scripts/"
  cp "${ROOT_DIR}/scripts/branch-stop-condition-check.sh" "${sandbox}/scripts/"
  cp "${ROOT_DIR}/scripts/supervisor-evaluation-trigger-list.sh" "${sandbox}/scripts/"
  chmod +x "${sandbox}/scripts/"*.sh

  git -C "$sandbox" init -q
  git -C "$sandbox" checkout -q -b agent/idle-stop-proof-fixture
  git -C "$sandbox" config user.name "Self Harness Fixture"
  git -C "$sandbox" config user.email "self-harness-fixture@example.invalid"

  cat >"${sandbox}/memory/diary/baseline.md" <<'DIARY'
---
id: "diary-idle-stop-proof-baseline"
title: "Idle Stop Proof Baseline"
type: "diary"
status: "active"
owner: "agent"
created: "2026-05-08"
updated: "2026-05-08"
tags:
  - diary
summary: "Fixture baseline diary."
---

# Idle Stop Proof Baseline

The fixture has a prior diary so an idle agent branch can otherwise skip.
DIARY

  git -C "$sandbox" add --all -- .
  git -C "$sandbox" commit -q -m "fixture: baseline"
}

commit_clean_stop_outbox() {
  local sandbox="$1"

  cat >"${sandbox}/mailbox/outbox/2026-05-08-clean-stop-reply.md" <<'OUTBOX'
---
id: "mailbox-outbox-clean-stop-reply"
title: "Clean Stop Reply"
type: "mailbox-message"
status: "done"
owner: "agent"
created: "2026-05-08"
updated: "2026-05-08"
from: "agent/idle-stop-proof-fixture"
to: "supervisor"
message_id: "clean-stop-reply"
tags:
  - mailbox
  - feedback-pressure
summary: "Fixture stop-safe run-linked outbox."
related: []
---

# Clean Stop Reply

Return-to-main judgment: defer. This fixture remains branch-local.

No next supervisor pressure: further escalation would be noisy because the fixture has no unresolved stop debt.

Supervisor evaluation trigger: run `scripts/supervisor.sh triggers --status review --limit 5`; reopen only if concrete review evidence appears.

Stop condition: if the idle stop proof passes, stop.
OUTBOX

  git -C "$sandbox" add --all -- .
  git -C "$sandbox" commit -q -m "run: Clean Stop Reply"
}

commit_unsafe_main_readiness_outbox() {
  local sandbox="$1"

  cat >"${sandbox}/mailbox/outbox/2026-05-08-unsafe-main-readiness-reply.md" <<'OUTBOX'
---
id: "mailbox-outbox-unsafe-main-readiness-reply"
title: "Unsafe Main Readiness Reply"
type: "mailbox-message"
status: "done"
owner: "agent"
created: "2026-05-08"
updated: "2026-05-08"
from: "agent/idle-stop-proof-fixture"
to: "supervisor"
message_id: "unsafe-main-readiness-reply"
tags:
  - mailbox
  - feedback-pressure
summary: "Fixture run-linked outbox with an unsafe main-readiness claim."
related: []
---

# Unsafe Main Readiness Reply

Return-to-main judgment: candidate for the branch-local pressure mechanism.
OUTBOX

  git -C "$sandbox" add --all -- .
  git -C "$sandbox" commit -q -m "run: Unsafe Main Readiness Reply"
}

run_pre_skip_proof() {
  local sandbox="$1"
  local log_file="$2"

  (
    cd "$sandbox"
    SELF_HARNESS_AUTO_CHALLENGE=1 \
      SELF_HARNESS_TRIGGER_REVIEW_LIMIT=5 \
      SELF_HARNESS_CONTINUOUS_PRESSURE_LIMIT=3 \
      SELF_HARNESS_STOP_PROOF_RUN_LIMIT=5 \
      SELF_HARNESS_STOP_PROOF_TRIGGER_LIMIT=5 \
      SELF_HARNESS_STOP_PROOF_EVIDENCE_LIMIT=3 \
      SELF_HARNESS_SUPERVISOR_ROOT="$sandbox" \
      bash -c '
        source scripts/supervisor.sh __self_harness_source_only
        init_layout
        seed_progressive_challenge_if_needed
        if should_skip_idle_agent_launch; then
          if prove_idle_stop_condition_or_seed_challenge; then
            log "fixture idle skip permitted"
          else
            log "fixture idle skip blocked"
          fi
        else
          log "fixture idle launch required before stop proof"
        fi
      '
  ) >"$log_file" 2>&1
}

inbox_count() {
  find "$1/mailbox/inbox" -maxdepth 1 -type f ! -name .gitkeep \
    | wc -l \
    | tr -d '[:space:]'
}

check_idle_skip_records_stop_proof_ok() {
  local sandbox log_file
  sandbox="${WORK_DIR}/clean"
  log_file="${WORK_DIR}/clean.log"
  prepare_sandbox "$sandbox"
  commit_clean_stop_outbox "$sandbox"

  run_pre_skip_proof "$sandbox" "$log_file"

  [ "$(inbox_count "$sandbox")" = "0" ] || {
    sed -n '1,180p' "$log_file" >&2
    fail "clean stop proof should not seed inbox"
  }
  rg -q 'idle stop proof ok: \.self-harness/tmp/idle-stop-proof-' "$log_file" || {
    sed -n '1,180p' "$log_file" >&2
    fail "clean idle skip did not log stop proof ok"
  }
  rg -q 'fixture idle skip permitted' "$log_file" || {
    sed -n '1,180p' "$log_file" >&2
    fail "clean idle proof did not permit the skip"
  }

  log "records stop proof before idle skip"
}

check_failed_stop_proof_seeds_challenge() {
  local sandbox log_file challenge
  sandbox="${WORK_DIR}/failed"
  log_file="${WORK_DIR}/failed.log"
  prepare_sandbox "$sandbox"
  commit_unsafe_main_readiness_outbox "$sandbox"

  run_pre_skip_proof "$sandbox" "$log_file"

  [ "$(inbox_count "$sandbox")" = "1" ] || {
    sed -n '1,220p' "$log_file" >&2
    fail "failed stop proof should seed exactly one inbox"
  }
  rg -q 'idle stop proof failed: \.self-harness/tmp/idle-stop-proof-' "$log_file" || {
    sed -n '1,220p' "$log_file" >&2
    fail "failed stop proof did not log proof failure"
  }
  rg -q 'seeded idle stop proof failure challenge:' "$log_file" || {
    sed -n '1,220p' "$log_file" >&2
    fail "failed stop proof did not seed defect-specific challenge"
  }

  challenge="$(find "$sandbox/mailbox/inbox" -maxdepth 1 -type f -name '*idle-stop-proof-failure.md' | sort | head -1)"
  [ -n "$challenge" ] || fail "missing idle-stop-proof-failure challenge file"
  rg -q 'stop-proof-log: "\.self-harness/tmp/idle-stop-proof-' "$challenge" || fail "challenge omitted proof log frontmatter"
  rg -q 'scripts/branch-stop-condition-check.sh' "$challenge" || fail "challenge omitted stop check command"
  rg -q '^## Stop Proof Failure Excerpt$' "$challenge" || fail "challenge omitted durable proof failure excerpt"
  rg -q 'claims main readiness' "$challenge" || fail "challenge excerpt omitted unsafe main-readiness signal"
  if rg -n '(^|[[:space:]("`])/(Users|home|private|var|Volumes|tmp)/' "$challenge"; then
    fail "challenge excerpt leaked absolute or machine-specific path"
  fi
  rg -q 'claims main readiness' "$sandbox/.self-harness/tmp"/idle-stop-proof-*.log || fail "proof log omitted unsafe main-readiness signal"

  log "seeds self-contained defect-specific challenge when stop proof fails"
}

main() {
  rm -rf "$WORK_DIR"
  mkdir -p "$WORK_DIR"
  check_idle_skip_records_stop_proof_ok
  check_failed_stop_proof_seeds_challenge
  log "ok"
}

main "$@"
