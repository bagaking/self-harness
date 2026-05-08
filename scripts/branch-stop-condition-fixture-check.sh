#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
WORK_DIR="${ROOT_DIR}/.self-harness/tmp/branch-stop-condition-fixture-check"

fail() {
  echo "branch-stop-condition-fixture-check: $*" >&2
  exit 1
}

log() {
  echo "branch-stop-condition-fixture-check: $*"
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

  cp "${ROOT_DIR}/scripts/branch-stop-condition-check.sh" "${sandbox}/scripts/"
  cp "${ROOT_DIR}/scripts/supervisor-evaluation-trigger-list.sh" "${sandbox}/scripts/"
  chmod +x "${sandbox}/scripts/branch-stop-condition-check.sh"
  chmod +x "${sandbox}/scripts/supervisor-evaluation-trigger-list.sh"

  git -C "$sandbox" init -q
  git -C "$sandbox" checkout -q -b agent/branch-stop-condition-fixture
  git -C "$sandbox" config user.name "Self Harness Fixture"
  git -C "$sandbox" config user.email "self-harness-fixture@example.invalid"

  cat >"${sandbox}/memory/diary/baseline.md" <<'DIARY'
---
id: "diary-branch-stop-condition-baseline"
title: "Branch Stop Condition Baseline"
type: "diary"
status: "active"
owner: "agent"
created: "2026-05-08"
updated: "2026-05-08"
tags:
  - diary
summary: "Fixture baseline diary."
---

# Branch Stop Condition Baseline

The fixture has a baseline commit before run-linked outbox records.
DIARY

  git -C "$sandbox" add --all -- .
  git -C "$sandbox" commit -q -m "fixture: baseline"
}

commit_all() {
  local sandbox="$1"
  local subject="$2"

  git -C "$sandbox" add --all -- .
  git -C "$sandbox" commit -q -m "$subject"
}

write_review_source() {
  local sandbox="$1"

  cat >"${sandbox}/mailbox/outbox/2026-05-08-review-source.md" <<'OUTBOX'
---
id: "mailbox-outbox-review-source"
title: "Review Source"
type: "mailbox-message"
status: "done"
owner: "agent"
created: "2026-05-08"
updated: "2026-05-08"
from: "agent/branch-stop-condition-fixture"
to: "supervisor"
message_id: "review-source"
tags:
  - mailbox
  - feedback-pressure
summary: "Fixture trigger-backed refusal."
related: []
---

# Review Source

Return-to-main judgment: defer. This fixture remains branch-local.

No next supervisor pressure: further escalation would be noisy because the fixture only needs trigger review when concrete evidence appears.

Supervisor evaluation trigger: reopen pressure if `scripts/example-trigger.sh` changes after this source.

Stop condition: if the trigger source has a lifecycle marker, stop.
OUTBOX
}

write_trigger_marker() {
  local sandbox="$1"

  cat >"${sandbox}/mailbox/done/2026-05-08-trigger-marker.md" <<'DONE'
---
id: "mailbox-done-trigger-marker"
title: "Trigger Marker"
type: "mailbox-inbox"
status: "done"
owner: "supervisor"
created: "2026-05-08"
updated: "2026-05-08"
from: "supervisor"
to: "agent/branch-stop-condition-fixture"
message_id: "trigger-marker"
tags:
  - mailbox
related:
  - "mailbox/outbox/2026-05-08-review-source.md"
trigger-review-source: "mailbox/outbox/2026-05-08-review-source.md"
summary: "Fixture completed trigger-review challenge."
---

# Trigger Marker

trigger-review-source: mailbox/outbox/2026-05-08-review-source.md
DONE
}

write_resolved_next_source() {
  local sandbox="$1"

  cat >"${sandbox}/mailbox/outbox/2026-05-08-resolved-next.md" <<'OUTBOX'
---
id: "mailbox-outbox-resolved-next"
title: "Resolved Next"
type: "mailbox-message"
status: "done"
owner: "agent"
created: "2026-05-08"
updated: "2026-05-08"
from: "agent/branch-stop-condition-fixture"
to: "supervisor"
message_id: "resolved-next"
tags:
  - mailbox
  - feedback-pressure
summary: "Fixture next-pressure source with lifecycle coverage."
related: []
---

# Resolved Next

Return-to-main judgment: defer. This fixture is not a main candidate.

Next supervisor pressure: prove the resolved next-pressure source has a lifecycle marker.
OUTBOX

  cat >"${sandbox}/mailbox/done/2026-05-08-resolved-next-marker.md" <<'DONE'
---
id: "mailbox-done-resolved-next-marker"
title: "Resolved Next Marker"
type: "mailbox-inbox"
status: "done"
owner: "supervisor"
created: "2026-05-08"
updated: "2026-05-08"
from: "supervisor"
to: "agent/branch-stop-condition-fixture"
message_id: "resolved-next-marker"
tags:
  - mailbox
related:
  - "mailbox/outbox/2026-05-08-resolved-next.md"
next-pressure-source: "mailbox/outbox/2026-05-08-resolved-next.md"
summary: "Fixture lifecycle marker for next-pressure debt."
---

# Resolved Next Marker

next-pressure-source: mailbox/outbox/2026-05-08-resolved-next.md

mailbox/outbox/2026-05-08-resolved-next.md
DONE
}

check_passes_clean_stop() {
  local sandbox log_file
  sandbox="${WORK_DIR}/clean"
  log_file="${WORK_DIR}/clean.log"
  prepare_sandbox "$sandbox"

  write_review_source "$sandbox"
  commit_all "$sandbox" "run: Review Source"
  write_trigger_marker "$sandbox"
  commit_all "$sandbox" "fixture: trigger marker"
  cat >"${sandbox}/scripts/example-trigger.sh" <<'SCRIPT'
#!/usr/bin/env bash
echo example
SCRIPT
  commit_all "$sandbox" "fixture: later trigger evidence"
  write_resolved_next_source "$sandbox"
  commit_all "$sandbox" "run: Resolved Next"

  (
    cd "$sandbox"
    scripts/branch-stop-condition-check.sh --run-limit 5 --trigger-limit 8 --evidence-limit 3
  ) >"$log_file" 2>&1 || {
    sed -n '1,180p' "$log_file" >&2
    fail "clean stop fixture should pass"
  }
  rg -q '^branch-stop-condition-check: ok$' "$log_file" || {
    sed -n '1,180p' "$log_file" >&2
    fail "clean stop fixture did not report ok"
  }

  log "passes when next pressure and review triggers are lifecycle-covered"
}

check_fails_unresolved_next_pressure() {
  local sandbox log_file
  sandbox="${WORK_DIR}/unresolved-next"
  log_file="${WORK_DIR}/unresolved-next.log"
  prepare_sandbox "$sandbox"

  cat >"${sandbox}/mailbox/outbox/2026-05-08-unresolved-next.md" <<'OUTBOX'
---
id: "mailbox-outbox-unresolved-next"
title: "Unresolved Next"
type: "mailbox-message"
status: "done"
owner: "agent"
created: "2026-05-08"
updated: "2026-05-08"
from: "agent/branch-stop-condition-fixture"
to: "supervisor"
message_id: "unresolved-next"
tags:
  - mailbox
  - feedback-pressure
summary: "Fixture unresolved next-pressure source."
related: []
---

# Unresolved Next

Return-to-main judgment: defer. This fixture is not a main candidate.

Next supervisor pressure: this requirement has no lifecycle marker.
OUTBOX
  commit_all "$sandbox" "run: Unresolved Next"

  if (
    cd "$sandbox"
    scripts/branch-stop-condition-check.sh --run-limit 5 --trigger-limit 8 --evidence-limit 3
  ) >"$log_file" 2>&1; then
    sed -n '1,180p' "$log_file" >&2
    fail "unresolved next-pressure fixture should fail"
  fi
  rg -q 'unresolved proof debt' "$log_file" || {
    sed -n '1,180p' "$log_file" >&2
    fail "unresolved next-pressure failure did not name proof debt"
  }

  log "fails unresolved next-pressure debt"
}

check_fails_incidental_lifecycle_reference() {
  local sandbox log_file
  sandbox="${WORK_DIR}/incidental-reference"
  log_file="${WORK_DIR}/incidental-reference.log"
  prepare_sandbox "$sandbox"

  cat >"${sandbox}/mailbox/outbox/2026-05-08-incidental-reference-source.md" <<'OUTBOX'
---
id: "mailbox-outbox-incidental-reference-source"
title: "Incidental Reference Source"
type: "mailbox-message"
status: "done"
owner: "agent"
created: "2026-05-08"
updated: "2026-05-08"
from: "agent/branch-stop-condition-fixture"
to: "supervisor"
message_id: "incidental-reference-source"
tags:
  - mailbox
  - feedback-pressure
summary: "Fixture next-pressure source without a real source marker."
related: []
---

# Incidental Reference Source

Return-to-main judgment: defer. This fixture is not a main candidate.

Next supervisor pressure: this requirement is only mentioned by an unrelated done file.
OUTBOX

  cat >"${sandbox}/mailbox/done/2026-05-08-unrelated-done.md" <<'DONE'
---
id: "mailbox-done-unrelated-done"
title: "Unrelated Done"
type: "mailbox-inbox"
status: "done"
owner: "supervisor"
created: "2026-05-08"
updated: "2026-05-08"
from: "supervisor"
to: "agent/branch-stop-condition-fixture"
message_id: "unrelated-done"
tags:
  - mailbox
related:
  - "mailbox/outbox/2026-05-08-incidental-reference-source.md"
summary: "Fixture unrelated done record that only mentions the source path."
---

# Unrelated Done

This completed mailbox file mentions mailbox/outbox/2026-05-08-incidental-reference-source.md,
but it does not carry next-pressure-source or a pressure-specific source marker.
DONE
  commit_all "$sandbox" "run: Incidental Reference Source"

  if (
    cd "$sandbox"
    scripts/branch-stop-condition-check.sh --run-limit 5 --trigger-limit 8 --evidence-limit 3
  ) >"$log_file" 2>&1; then
    sed -n '1,180p' "$log_file" >&2
    fail "incidental lifecycle reference fixture should fail"
  fi
  rg -q 'expected next-pressure-source or pressure-specific source marker' "$log_file" || {
    sed -n '1,180p' "$log_file" >&2
    fail "incidental lifecycle reference failure did not name explicit marker requirement"
  }

  log "fails incidental lifecycle path references"
}

check_fails_unchallenged_review_trigger() {
  local sandbox log_file
  sandbox="${WORK_DIR}/unchallenged-trigger"
  log_file="${WORK_DIR}/unchallenged-trigger.log"
  prepare_sandbox "$sandbox"

  write_review_source "$sandbox"
  commit_all "$sandbox" "run: Review Source"
  cat >"${sandbox}/scripts/example-trigger.sh" <<'SCRIPT'
#!/usr/bin/env bash
echo example
SCRIPT
  commit_all "$sandbox" "fixture: later trigger evidence"

  if (
    cd "$sandbox"
    scripts/branch-stop-condition-check.sh --run-limit 5 --trigger-limit 8 --evidence-limit 3
  ) >"$log_file" 2>&1; then
    sed -n '1,180p' "$log_file" >&2
    fail "unchallenged review-trigger fixture should fail"
  fi
  rg -q 'unchallenged review trigger source' "$log_file" || {
    sed -n '1,180p' "$log_file" >&2
    fail "unchallenged review-trigger failure did not name source"
  }

  log "fails unchallenged review trigger"
}

check_fails_main_readiness_claim() {
  local sandbox log_file
  sandbox="${WORK_DIR}/main-readiness"
  log_file="${WORK_DIR}/main-readiness.log"
  prepare_sandbox "$sandbox"

  cat >"${sandbox}/mailbox/outbox/2026-05-08-main-readiness.md" <<'OUTBOX'
---
id: "mailbox-outbox-main-readiness"
title: "Main Readiness"
type: "mailbox-message"
status: "done"
owner: "agent"
created: "2026-05-08"
updated: "2026-05-08"
from: "agent/branch-stop-condition-fixture"
to: "supervisor"
message_id: "main-readiness"
tags:
  - mailbox
  - feedback-pressure
summary: "Fixture unsafe main-readiness claim."
related: []
---

# Main Readiness

Return-to-main judgment: candidate for the branch-local pressure mechanism.
OUTBOX
  commit_all "$sandbox" "run: Main Readiness"

  if (
    cd "$sandbox"
    scripts/branch-stop-condition-check.sh --run-limit 5 --trigger-limit 8 --evidence-limit 3
  ) >"$log_file" 2>&1; then
    sed -n '1,180p' "$log_file" >&2
    fail "main-readiness fixture should fail"
  fi
  rg -q 'claims main readiness' "$log_file" || {
    sed -n '1,180p' "$log_file" >&2
    fail "main-readiness failure did not name unsafe claim"
  }

  log "fails branch-local main-readiness claims"
}

main() {
  rm -rf "$WORK_DIR"
  mkdir -p "$WORK_DIR"

  check_passes_clean_stop
  check_fails_unresolved_next_pressure
  check_fails_incidental_lifecycle_reference
  check_fails_unchallenged_review_trigger
  check_fails_main_readiness_claim

  log "ok"
}

main "$@"
