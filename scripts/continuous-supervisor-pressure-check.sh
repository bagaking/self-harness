#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
WORK_DIR="${ROOT_DIR}/.self-harness/tmp/continuous-supervisor-pressure-check"

fail() {
  echo "continuous-supervisor-pressure-check: $*" >&2
  exit 1
}

log() {
  echo "continuous-supervisor-pressure-check: $*"
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
  git -C "$sandbox" checkout -q -b agent/continuous-pressure-check
  git -C "$sandbox" config user.name "Self Harness Fixture"
  git -C "$sandbox" config user.email "self-harness-fixture@example.invalid"

  cat >"${sandbox}/memory/diary/baseline.md" <<'DIARY'
---
id: "diary-continuous-pressure-baseline"
title: "Continuous Pressure Baseline"
type: "diary"
status: "active"
owner: "agent"
created: "2026-05-08"
updated: "2026-05-08"
tags:
  - diary
summary: "Fixture baseline diary."
---

# Continuous Pressure Baseline

The fixture has a prior diary so an idle agent branch can otherwise skip.
DIARY

  git -C "$sandbox" add --all -- .
  git -C "$sandbox" commit -q -m "fixture: baseline"
}

commit_deferred_run_outbox() {
  local sandbox="$1"

  cat >"${sandbox}/mailbox/outbox/2026-05-08-deferred-proof-reply.md" <<'OUTBOX'
---
id: "mailbox-outbox-deferred-proof-reply"
title: "Deferred Proof Reply"
type: "mailbox-message"
status: "done"
owner: "agent"
created: "2026-05-08"
updated: "2026-05-08"
from: "agent/continuous-pressure-check"
to: "supervisor"
message_id: "deferred-proof-reply"
tags:
  - mailbox
  - feedback-pressure
  - return-to-main
summary: "Fixture run that leaves explicit proof debt."
related: []
---

# Deferred Proof Reply

## Return-To-Main Judgment

Return-to-main judgment: defer. The candidate is useful, but it still needs checked-out proof before promotion.

Next supervisor pressure: require a main-targeted patch that applies cleanly to `origin/main` and passes the focused fixture before promotion.
OUTBOX

  git -C "$sandbox" add --all -- .
  git -C "$sandbox" commit -q -m "run: Deferred Proof Reply"
}

commit_self_referential_deferred_run_outbox() {
  local sandbox="$1"

  cat >"${sandbox}/mailbox/outbox/2026-05-08-self-referential-deferred-proof-reply.md" <<'OUTBOX'
---
id: "mailbox-outbox-self-referential-deferred-proof-reply"
title: "Self Referential Deferred Proof Reply"
type: "mailbox-message"
status: "done"
owner: "agent"
created: "2026-05-08"
updated: "2026-05-08"
from: "agent/continuous-pressure-check"
to: "supervisor"
message_id: "self-referential-deferred-proof-reply"
tags:
  - mailbox
  - feedback-pressure
  - return-to-main
summary: "Fixture run whose source prose asks for its own future continuous-pressure marker."
related: []
---

# Self Referential Deferred Proof Reply

## Return-To-Main Judgment

Return-to-main judgment: defer. The candidate needs checked-out proof before promotion.

Next supervisor pressure: after this repair is committed, require either exactly one continuous-pressure inbox for this source, or a durable `continuous-pressure-source: mailbox/outbox/2026-05-08-self-referential-deferred-proof-reply.md` lifecycle marker.
OUTBOX

  git -C "$sandbox" add --all -- .
  git -C "$sandbox" commit -q -m "run: Self Referential Deferred Proof Reply"
}

commit_clean_stop_run_outbox() {
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
from: "agent/continuous-pressure-check"
to: "supervisor"
message_id: "clean-stop-reply"
tags:
  - mailbox
summary: "Fixture run with a clean stop condition and no unresolved pressure."
related: []
---

# Clean Stop Reply

No next supervisor pressure: further escalation would be noisy because the fixture has no unresolved proof debt.

Supervisor evaluation trigger: run `scripts/supervisor.sh triggers --status review`; reopen only if new evidence appears.

Stop condition: if no review evidence appears, stop.
OUTBOX

  git -C "$sandbox" add --all -- .
  git -C "$sandbox" commit -q -m "run: Clean Stop Reply"
}

commit_explicit_feedback_refusal_outbox() {
  local sandbox="$1"

  cat >"${sandbox}/mailbox/outbox/2026-05-08-explicit-feedback-refusal-reply.md" <<'OUTBOX'
---
id: "mailbox-outbox-explicit-feedback-refusal-reply"
title: "Explicit Feedback Refusal Reply"
type: "mailbox-message"
status: "done"
owner: "agent"
created: "2026-05-08"
updated: "2026-05-08"
from: "agent/continuous-pressure-check"
to: "supervisor"
message_id: "explicit-feedback-refusal-reply"
tags:
  - mailbox
  - feedback-pressure
  - explicit-feedback
summary: "Fixture run that locally refuses more pressure despite explicit feedback."
related: []
---

# Explicit Feedback Refusal Reply

## Reviewed Evidence

Human/supervisor feedback said the branch stops too easily and needs higher pressure.

## Return-To-Main Judgment

Return-to-main judgment: defer. The current fixture is branch-local.

No next supervisor pressure: further escalation would be noisy because the local fixture passed.

Supervisor evaluation trigger: run `scripts/supervisor.sh triggers --status review`; reopen if later evidence appears.

Stop condition: stop only the local fixture pressure.
OUTBOX

  git -C "$sandbox" add --all -- .
  git -C "$sandbox" commit -q -m "run: Explicit Feedback Refusal Reply"
}

commit_non_run_deferred_outbox() {
  local sandbox="$1"

  cat >"${sandbox}/mailbox/outbox/2026-05-08-non-run-deferred-proof-reply.md" <<'OUTBOX'
---
id: "mailbox-outbox-non-run-deferred-proof-reply"
title: "Non Run Deferred Proof Reply"
type: "mailbox-message"
status: "done"
owner: "agent"
created: "2026-05-08"
updated: "2026-05-08"
from: "agent/continuous-pressure-check"
to: "supervisor"
message_id: "non-run-deferred-proof-reply"
tags:
  - mailbox
  - feedback-pressure
  - return-to-main
summary: "Fixture non-run commit with explicit proof debt."
related: []
---

# Non Run Deferred Proof Reply

Return-to-main judgment: defer. This non-run record should not drive the run-linked idle scan.

Next supervisor pressure: require a main-targeted patch before promotion.
OUTBOX

  git -C "$sandbox" add --all -- .
  git -C "$sandbox" commit -q -m "supervisor: Non Run Deferred Proof Reply"
}

commit_existing_continuous_marker() {
  local sandbox="$1"
  local source_rel="${2:-mailbox/outbox/2026-05-08-deferred-proof-reply.md}"

  cat >"${sandbox}/mailbox/done/2026-05-08-existing-continuous-pressure.md" <<'DONE'
---
id: "mailbox-done-existing-continuous-pressure"
title: "Existing Continuous Pressure"
type: "mailbox-inbox"
status: "done"
owner: "supervisor"
created: "2026-05-08"
updated: "2026-05-08"
from: "supervisor"
to: "agent/continuous-pressure-check"
message_id: "existing-continuous-pressure"
tags:
  - mailbox
  - feedback-pressure
related:
  - "__SOURCE_REL__"
continuous-pressure-source: "__SOURCE_REL__"
summary: "Fixture completed continuous pressure challenge."
---

# Existing Continuous Pressure

continuous-pressure-source: __SOURCE_REL__
DONE
  sed -i.bak "s#__SOURCE_REL__#${source_rel}#g" "${sandbox}/mailbox/done/2026-05-08-existing-continuous-pressure.md"
  rm -f "${sandbox}/mailbox/done/2026-05-08-existing-continuous-pressure.md.bak"

  git -C "$sandbox" add --all -- .
  git -C "$sandbox" commit -q -m "fixture: existing continuous pressure marker"
}

run_seed() {
  local sandbox="$1"
  local log_file="$2"

  (
    cd "$sandbox"
    SELF_HARNESS_AUTO_CHALLENGE=1 \
      SELF_HARNESS_TRIGGER_REVIEW_LIMIT=5 \
      SELF_HARNESS_CONTINUOUS_PRESSURE_LIMIT=3 \
      SELF_HARNESS_SUPERVISOR_ROOT="$sandbox" \
      bash -c 'source scripts/supervisor.sh __self_harness_source_only; seed_progressive_challenge_if_needed'
  ) >"$log_file" 2>&1
}

challenge_count() {
  find "$1/mailbox/inbox" -maxdepth 1 -type f -name '*continuous-supervisor-pressure.md' \
    | wc -l \
    | tr -d '[:space:]'
}

check_seeds_from_recent_run_debt() {
  local sandbox log_file challenge
  sandbox="${WORK_DIR}/positive"
  log_file="${WORK_DIR}/positive.log"
  prepare_sandbox "$sandbox"
  commit_deferred_run_outbox "$sandbox"

  run_seed "$sandbox" "$log_file"

  [ "$(challenge_count "$sandbox")" = "1" ] || {
    sed -n '1,160p' "$log_file" >&2
    fail "expected one continuous pressure inbox challenge"
  }
  rg -q 'seeded continuous pressure challenge:' "$log_file" || {
    sed -n '1,160p' "$log_file" >&2
    fail "positive seed did not log continuous pressure seeding"
  }
  challenge="$(find "$sandbox/mailbox/inbox" -maxdepth 1 -type f -name '*continuous-supervisor-pressure.md' | sort | head -1)"
  rg -q 'continuous-pressure-source: "mailbox/outbox/2026-05-08-deferred-proof-reply.md"' "$challenge" || fail "generated challenge omitted source frontmatter"
  rg -q 'require a main-targeted patch that applies cleanly to `origin/main`' "$challenge" || fail "generated challenge omitted exact source requirement"

  log "seeds from recent run-linked proof debt"
}

check_source_outbox_marker_request_does_not_suppress_seed() {
  local sandbox log_file challenge
  sandbox="${WORK_DIR}/self-referential-source"
  log_file="${WORK_DIR}/self-referential-source.log"
  prepare_sandbox "$sandbox"
  commit_self_referential_deferred_run_outbox "$sandbox"

  run_seed "$sandbox" "$log_file"

  [ "$(challenge_count "$sandbox")" = "1" ] || {
    sed -n '1,160p' "$log_file" >&2
    fail "source outbox prose must not suppress its own continuous pressure inbox"
  }
  rg -q 'seeded continuous pressure challenge:' "$log_file" || {
    sed -n '1,160p' "$log_file" >&2
    fail "self-referential source did not log continuous pressure seeding"
  }
  challenge="$(find "$sandbox/mailbox/inbox" -maxdepth 1 -type f -name '*continuous-supervisor-pressure.md' | sort | head -1)"
  rg -q 'continuous-pressure-source: "mailbox/outbox/2026-05-08-self-referential-deferred-proof-reply.md"' "$challenge" || fail "generated self-referential challenge omitted source frontmatter"

  log "does not treat source outbox marker request as lifecycle coverage"
}

check_seeds_from_recent_explicit_feedback_refusal() {
  local sandbox log_file challenge
  sandbox="${WORK_DIR}/explicit-feedback-refusal"
  log_file="${WORK_DIR}/explicit-feedback-refusal.log"
  prepare_sandbox "$sandbox"
  commit_explicit_feedback_refusal_outbox "$sandbox"

  run_seed "$sandbox" "$log_file"

  [ "$(challenge_count "$sandbox")" = "1" ] || {
    sed -n '1,160p' "$log_file" >&2
    fail "expected one continuous pressure inbox for explicit feedback refusal"
  }
  rg -q 'seeded continuous pressure challenge:' "$log_file" || {
    sed -n '1,160p' "$log_file" >&2
    fail "explicit feedback refusal did not log continuous pressure seeding"
  }
  challenge="$(find "$sandbox/mailbox/inbox" -maxdepth 1 -type f -name '*continuous-supervisor-pressure.md' | sort | head -1)"
  rg -q 'continuous-pressure-source: "mailbox/outbox/2026-05-08-explicit-feedback-refusal-reply.md"' "$challenge" || fail "generated explicit-feedback challenge omitted source frontmatter"
  rg -q 'Explicit feedback ratchet remains open despite local refusal:' "$challenge" || fail "generated explicit-feedback challenge omitted ratchet requirement"

  log "seeds from recent explicit-feedback local refusal"
}

check_skips_when_source_already_challenged() {
  local sandbox log_file
  sandbox="${WORK_DIR}/already-challenged"
  log_file="${WORK_DIR}/already-challenged.log"
  prepare_sandbox "$sandbox"
  commit_deferred_run_outbox "$sandbox"
  commit_existing_continuous_marker "$sandbox"

  run_seed "$sandbox" "$log_file"

  [ "$(challenge_count "$sandbox")" = "0" ] || {
    sed -n '1,160p' "$log_file" >&2
    fail "already-challenged source should not seed another inbox"
  }
  rg -q 'continuous pressure challenge skipped: all proof-debt sources already challenged' "$log_file" || {
    sed -n '1,160p' "$log_file" >&2
    fail "already-challenged case did not explain skip"
  }

  log "does not reseed the same continuous pressure source"
}

check_skips_explicit_feedback_refusal_already_challenged() {
  local sandbox log_file
  sandbox="${WORK_DIR}/explicit-feedback-already-challenged"
  log_file="${WORK_DIR}/explicit-feedback-already-challenged.log"
  prepare_sandbox "$sandbox"
  commit_explicit_feedback_refusal_outbox "$sandbox"
  commit_existing_continuous_marker "$sandbox" "mailbox/outbox/2026-05-08-explicit-feedback-refusal-reply.md"

  run_seed "$sandbox" "$log_file"

  [ "$(challenge_count "$sandbox")" = "0" ] || {
    sed -n '1,160p' "$log_file" >&2
    fail "already-challenged explicit feedback source should not seed another inbox"
  }
  rg -q 'continuous pressure challenge skipped: all proof-debt sources already challenged' "$log_file" || {
    sed -n '1,160p' "$log_file" >&2
    fail "already-challenged explicit feedback case did not explain skip"
  }

  log "does not reseed the same explicit-feedback source"
}

check_skips_clean_stop_condition() {
  local sandbox log_file
  sandbox="${WORK_DIR}/clean-stop"
  log_file="${WORK_DIR}/clean-stop.log"
  prepare_sandbox "$sandbox"
  commit_clean_stop_run_outbox "$sandbox"

  run_seed "$sandbox" "$log_file"

  [ "$(challenge_count "$sandbox")" = "0" ] || {
    sed -n '1,160p' "$log_file" >&2
    fail "clean stop should not seed continuous pressure"
  }
  rg -q 'progressive challenge skipped: no repeated low-value branch feedback' "$log_file" || {
    sed -n '1,160p' "$log_file" >&2
    fail "clean stop did not reach quiet idle boundary"
  }

  log "does not seed from completed clean stop condition"
}

check_skips_non_run_debt() {
  local sandbox log_file
  sandbox="${WORK_DIR}/non-run"
  log_file="${WORK_DIR}/non-run.log"
  prepare_sandbox "$sandbox"
  commit_non_run_deferred_outbox "$sandbox"

  run_seed "$sandbox" "$log_file"

  [ "$(challenge_count "$sandbox")" = "0" ] || {
    sed -n '1,160p' "$log_file" >&2
    fail "non-run debt should not seed continuous pressure"
  }
  rg -q 'progressive challenge skipped: no repeated low-value branch feedback' "$log_file" || {
    sed -n '1,160p' "$log_file" >&2
    fail "non-run debt did not reach quiet idle boundary"
  }

  log "ignores non-run deferred outbox debt"
}

main() {
  rm -rf "$WORK_DIR"
  mkdir -p "$WORK_DIR"
  check_seeds_from_recent_run_debt
  check_source_outbox_marker_request_does_not_suppress_seed
  check_seeds_from_recent_explicit_feedback_refusal
  check_skips_when_source_already_challenged
  check_skips_explicit_feedback_refusal_already_challenged
  check_skips_clean_stop_condition
  check_skips_non_run_debt
  log "ok"
}

main "$@"
