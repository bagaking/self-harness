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

  cat >"${sandbox}/scripts/example-trigger.sh" <<'SCRIPT'
#!/usr/bin/env bash
echo "example trigger baseline"
SCRIPT

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

check_ignores_generic_words_from_completed_record_trigger() {
  local sandbox log_file
  sandbox="${WORK_DIR}/completed-record-generic"
  log_file="${WORK_DIR}/completed-record-generic.log"
  prepare_sandbox "$sandbox"

  cat >"${sandbox}/mailbox/outbox/2026-05-07-trigger-refusal.md" <<'OUTBOX'
---
id: "mailbox-outbox-trigger-refusal"
title: "Completed Record Trigger Refusal"
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
summary: "Fixture completed-record trigger-backed refusal."
related: []
---

# Completed Record Trigger Refusal

No next supervisor pressure: further escalation would be noisy because the completed-record gate is already executable.

Supervisor evaluation trigger: reopen pressure if `scripts/supervisor.sh completed-records` fails during a later post-run commit attempt or if a tracked `mailbox/outbox/*.md` or `memory/diary/*.md` record is modified instead of creating a unique current-run file.

Stop condition: let the normal post-run commit gate enforce `scripts/completed-record-overwrite-check.sh` on the next supervisor commit attempt.
OUTBOX

  git -C "$sandbox" add --all -- .
  git -C "$sandbox" commit -q -m "fixture: completed record trigger"

  cat >"${sandbox}/mailbox/done/2026-05-07-generic-words.md" <<'DONE'
---
id: "mailbox-done-generic-words"
title: "Generic Words"
type: "mailbox-inbox"
status: "done"
owner: "supervisor"
created: "2026-05-07"
updated: "2026-05-07"
tags:
  - mailbox
summary: "Contains only generic words from a trigger sentence."
---

# Generic Words

The later durable record mentions creating.
DONE

  cat >"${sandbox}/memory/diary/generic-words.md" <<'DIARY'
---
id: "diary-generic-words"
title: "Generic Words"
type: "diary"
status: "active"
owner: "agent"
created: "2026-05-07"
updated: "2026-05-07"
tags:
  - diary
summary: "Contains only generic words from a trigger sentence."
---

# Generic Words

The later diary mentions modified and instead, but no concrete completed-record trigger term.
DIARY

  (
    cd "$sandbox"
    bash scripts/supervisor-evaluation-trigger-list.sh --limit 1 --status review
  ) >"$log_file" 2>&1

  rg -q 'no triggers matched status filter review' "$log_file" || {
    sed -n '1,160p' "$log_file" >&2
    fail "generic words should not make the completed-record trigger look fired"
  }
  log "ignores generic words from completed-record trigger prose"
}

check_existing_file_old_term_does_not_count_after_unrelated_edit() {
  local sandbox log_file
  sandbox="${WORK_DIR}/old-term-unrelated-edit"
  log_file="${WORK_DIR}/old-term-unrelated-edit.log"
  prepare_sandbox "$sandbox"

  cat >>"${sandbox}/scripts/example-trigger.sh" <<'SCRIPT'
# Existing concrete trigger term before the refusal source commit:
# scripts/example-trigger.sh
SCRIPT

  git -C "$sandbox" add --all -- .
  git -C "$sandbox" commit -q -m "fixture: existing trigger term"

  cat >"${sandbox}/mailbox/outbox/2026-05-08-old-term-trigger-refusal.md" <<'OUTBOX'
---
id: "mailbox-outbox-old-term-trigger-refusal"
title: "Trigger Refusal"
type: "mailbox-message"
status: "done"
owner: "agent"
created: "2026-05-07"
updated: "2026-05-07"
from: "agent/trigger-list-check"
to: "supervisor"
message_id: "old-term-trigger-refusal"
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

  git -C "$sandbox" add --all -- .
  git -C "$sandbox" commit -q -m "fixture: trigger refusal"

  cat >>"${sandbox}/scripts/example-trigger.sh" <<'SCRIPT'
echo "unrelated later edit"
SCRIPT

  (
    cd "$sandbox"
    bash scripts/supervisor-evaluation-trigger-list.sh --limit 1 --status review
  ) >"$log_file" 2>&1

  rg -q 'no triggers matched status filter review' "$log_file" || {
    sed -n '1,160p' "$log_file" >&2
    fail "old trigger term in an existing file should not count after an unrelated edit"
  }
  log "ignores old trigger terms in existing files after unrelated edits"
}

check_ignores_trigger_review_scaffold_only_terms() {
  local sandbox log_file
  sandbox="${WORK_DIR}/trigger-review-scaffold"
  log_file="${WORK_DIR}/trigger-review-scaffold.log"
  prepare_sandbox "$sandbox"

  cat >"${sandbox}/mailbox/outbox/2026-05-08-trigger-review-refusal.md" <<'OUTBOX'
---
id: "mailbox-outbox-trigger-review-refusal"
title: "Trigger Review Refusal"
type: "mailbox-message"
status: "done"
owner: "agent"
created: "2026-05-08"
updated: "2026-05-08"
from: "agent/trigger-list-check"
to: "supervisor"
message_id: "trigger-review-refusal"
tags:
  - mailbox
  - feedback-pressure
  - trigger-review
summary: "Fixture trigger-review refusal with scaffold-only trigger terms."
related: []
---

# Trigger Review Refusal

No next supervisor pressure: further escalation would be noisy because every actionable source is already lifecycle-covered.

Supervisor evaluation trigger: run `scripts/supervisor.sh triggers --status review --limit 8 --evidence-limit 3`; if it lists a `review-evidence` source with no matching `trigger-review-source:` marker anywhere under `mailbox/inbox`, `mailbox/processing`, `mailbox/done`, `mailbox/failed`, or `mailbox/outbox`, issue one defect-specific trigger-review activation challenge.

Stop condition: if every actionable source is already marked, stop.
OUTBOX

  git -C "$sandbox" add --all -- .
  git -C "$sandbox" commit -q -m "fixture: trigger review scaffold refusal"

  cat >"${sandbox}/mailbox/done/2026-05-08-trigger-review-pressure-challenge.md" <<'DONE'
---
id: "mailbox-done-trigger-review-pressure-challenge"
title: "Trigger Review Pressure Challenge"
type: "mailbox-inbox"
status: "done"
owner: "supervisor"
created: "2026-05-08"
updated: "2026-05-08"
from: "supervisor"
to: "agent/trigger-list-check"
message_id: "trigger-review-pressure-challenge"
tags:
  - mailbox
  - feedback-pressure
  - trigger-review
summary: "Fixture lifecycle marker for trigger-review source."
related:
  - "mailbox/outbox/2026-05-08-trigger-review-refusal.md"
trigger-review-source: "mailbox/outbox/2026-05-08-trigger-review-refusal.md"
---

# Trigger Review Pressure Challenge

trigger-review-source: mailbox/outbox/2026-05-08-trigger-review-refusal.md
The mailbox lifecycle marker mentions mailbox/inbox, mailbox/processing, mailbox/done, mailbox/failed, and mailbox/outbox only as scaffold.
It also says to run `scripts/supervisor.sh triggers --status review --limit 8 --evidence-limit 3`, but that command citation is trigger-review scaffold rather than concrete evidence that the prior trigger fired.
DONE

  (
    cd "$sandbox"
    bash scripts/supervisor-evaluation-trigger-list.sh --limit 1 --status review
  ) >"$log_file" 2>&1

  rg -q 'no triggers matched status filter review' "$log_file" || {
    sed -n '1,180p' "$log_file" >&2
    fail "trigger-review scaffold terms should not create review evidence"
  }
  log "ignores trigger-review scaffold-only lifecycle evidence"
}

check_ignores_trigger_review_source_path_meta_terms() {
  local sandbox log_file
  sandbox="${WORK_DIR}/trigger-review-source-path-meta"
  log_file="${WORK_DIR}/trigger-review-source-path-meta.log"
  prepare_sandbox "$sandbox"

  cat >"${sandbox}/mailbox/outbox/2026-05-08-trigger-review-covered-refusal.md" <<'OUTBOX'
---
id: "mailbox-outbox-trigger-review-covered-refusal"
title: "Trigger Review Covered Refusal"
type: "mailbox-message"
status: "done"
owner: "agent"
created: "2026-05-08"
updated: "2026-05-08"
from: "agent/trigger-list-check"
to: "supervisor"
message_id: "trigger-review-covered-refusal"
tags:
  - mailbox
  - feedback-pressure
  - trigger-review
summary: "Fixture trigger-review refusal with source-path meta trigger terms."
related: []
---

# Trigger Review Covered Refusal

No next supervisor pressure: further trigger-review escalation for the source would be noisy because the concrete evidence is already covered.

Supervisor evaluation trigger: run `scripts/supervisor.sh triggers --status review --limit 8 --evidence-limit 3`; if `mailbox/outbox/2026-05-08-status-sync-v3-proof-reply.md` gains new later evidence from a changed status-sync artifact, issue one defect-specific challenge.

Stop condition: if the source remains listed only with the same later evidence, stop.
OUTBOX

  git -C "$sandbox" add --all -- .
  git -C "$sandbox" commit -q -m "fixture: trigger review covered refusal"

  cat >"${sandbox}/mailbox/outbox/2026-05-08-later-covered-refusal.md" <<'OUTBOX'
---
id: "mailbox-outbox-later-covered-refusal"
title: "Later Covered Refusal"
type: "mailbox-message"
status: "done"
owner: "agent"
created: "2026-05-08"
updated: "2026-05-08"
from: "agent/trigger-list-check"
to: "supervisor"
message_id: "later-covered-refusal"
tags:
  - mailbox
  - feedback-pressure
summary: "Fixture later refusal that names only the covered source path."
related: []
---

# Later Covered Refusal

The older covered refusal remains tied to `mailbox/outbox/2026-05-08-status-sync-v3-proof-reply.md`, but this later record does not describe a changed status-sync artifact.
OUTBOX

  (
    cd "$sandbox"
    bash scripts/supervisor-evaluation-trigger-list.sh --limit 1 --status review
  ) >"$log_file" 2>&1

  rg -q 'no triggers matched status filter review' "$log_file" || {
    sed -n '1,180p' "$log_file" >&2
    fail "trigger-review source path meta terms should not create review evidence"
  }
  log "ignores trigger-review source path meta terms without changed-artifact evidence"
}

check_ignores_trigger_review_repeated_source_path_current_wording() {
  local sandbox log_file
  sandbox="${WORK_DIR}/trigger-review-repeated-source-path-current-wording"
  log_file="${WORK_DIR}/trigger-review-repeated-source-path-current-wording.log"
  prepare_sandbox "$sandbox"

  cat >"${sandbox}/mailbox/outbox/2026-05-08-trigger-review-source-path-meta.md" <<'OUTBOX'
---
id: "mailbox-outbox-trigger-review-source-path-meta"
title: "Trigger Review Source Path Meta"
type: "mailbox-message"
status: "done"
owner: "agent"
created: "2026-05-08"
updated: "2026-05-08"
from: "agent/trigger-list-check"
to: "supervisor"
message_id: "trigger-review-source-path-meta"
tags:
  - mailbox
  - feedback-pressure
  - trigger-review
summary: "Fixture trigger-review refusal using repeated-source wording."
related: []
---

# Trigger Review Source Path Meta

No next supervisor pressure: further escalation for `mailbox/outbox/2026-05-08-trigger-review-v3-covered-refusal-reply.md` would be noisy because the recursive source-path meta match is covered.

Supervisor evaluation trigger: run `scripts/supervisor.sh triggers --status review --limit 8 --evidence-limit 3` after this commit; if `mailbox/outbox/2026-05-08-trigger-review-v3-covered-refusal-reply.md` reappears only because a later record repeats `mailbox/outbox/2026-05-08-status-sync-v3-proof-reply.md`, file a defect against `scripts/supervisor-evaluation-trigger-list.sh`.

Stop condition: if only repeated source paths appear, stop.
OUTBOX

  git -C "$sandbox" add --all -- .
  git -C "$sandbox" commit -q -m "fixture: trigger review repeated source path"

  cat >"${sandbox}/mailbox/outbox/2026-05-08-later-dossier.md" <<'OUTBOX'
---
id: "mailbox-outbox-later-dossier"
title: "Later Dossier"
type: "mailbox-message"
status: "done"
owner: "agent"
created: "2026-05-08"
updated: "2026-05-08"
from: "agent/trigger-list-check"
to: "supervisor"
message_id: "later-dossier"
tags:
  - mailbox
  - feedback-pressure
summary: "Fixture later record that repeats only source-path meta terms."
related: []
---

# Later Dossier

The review discusses `mailbox/outbox/2026-05-08-trigger-review-v3-covered-refusal-reply.md`, repeats `mailbox/outbox/2026-05-08-status-sync-v3-proof-reply.md`, and cites `scripts/supervisor-evaluation-trigger-list.sh`, but it names no changed artifact.
OUTBOX

  (
    cd "$sandbox"
    bash scripts/supervisor-evaluation-trigger-list.sh --limit 1 --status review
  ) >"$log_file" 2>&1

  rg -q 'no triggers matched status filter review' "$log_file" || {
    sed -n '1,180p' "$log_file" >&2
    fail "repeated source-path wording should not create trigger-review evidence"
  }
  log "ignores trigger-review repeated source-path current wording"
}

check_surfaces_trigger_review_concrete_artifact_terms() {
  local sandbox log_file
  sandbox="${WORK_DIR}/trigger-review-concrete-artifact"
  log_file="${WORK_DIR}/trigger-review-concrete-artifact.log"
  prepare_sandbox "$sandbox"

  cat >"${sandbox}/mailbox/outbox/2026-05-08-trigger-review-concrete-artifact.md" <<'OUTBOX'
---
id: "mailbox-outbox-trigger-review-concrete-artifact"
title: "Trigger Review Concrete Artifact"
type: "mailbox-message"
status: "done"
owner: "agent"
created: "2026-05-08"
updated: "2026-05-08"
from: "agent/trigger-list-check"
to: "supervisor"
message_id: "trigger-review-concrete-artifact"
tags:
  - mailbox
  - feedback-pressure
  - trigger-review
summary: "Fixture trigger-review refusal with source-path meta plus a concrete artifact path."
related: []
---

# Trigger Review Concrete Artifact

No next supervisor pressure: further trigger-review escalation for the source would be noisy unless a concrete artifact changes.

Supervisor evaluation trigger: run `scripts/supervisor.sh triggers --status review --limit 8 --evidence-limit 3`; if `mailbox/outbox/2026-05-08-status-sync-v3-proof-reply.md` gains new later evidence from changed status-sync artifact `mailbox/outbox/attachments/2026-05-08-status-sync-v3-main-target.patch`, issue one defect-specific challenge.

Stop condition: if only the source path repeats, stop.
OUTBOX

  git -C "$sandbox" add --all -- .
  git -C "$sandbox" commit -q -m "fixture: trigger review concrete artifact"

  cat >"${sandbox}/mailbox/outbox/2026-05-08-later-concrete-artifact.md" <<'OUTBOX'
---
id: "mailbox-outbox-later-concrete-artifact"
title: "Later Concrete Artifact"
type: "mailbox-message"
status: "done"
owner: "agent"
created: "2026-05-08"
updated: "2026-05-08"
from: "agent/trigger-list-check"
to: "supervisor"
message_id: "later-concrete-artifact"
tags:
  - mailbox
  - feedback-pressure
summary: "Fixture later evidence naming a concrete changed artifact."
related: []
---

# Later Concrete Artifact

The changed status-sync artifact `mailbox/outbox/attachments/2026-05-08-status-sync-v3-main-target.patch` has a new hygiene finding.
OUTBOX

  (
    cd "$sandbox"
    bash scripts/supervisor-evaluation-trigger-list.sh --limit 1 --status review
  ) >"$log_file" 2>&1

  rg -q 'status: review-evidence' "$log_file" || {
    sed -n '1,180p' "$log_file" >&2
    fail "concrete changed artifact term should create review evidence"
  }
  rg -q 'mailbox/outbox/2026-05-08-later-concrete-artifact.md' "$log_file" || {
    sed -n '1,180p' "$log_file" >&2
    fail "later concrete artifact evidence should be named"
  }
  rg -q 'mailbox/outbox/attachments/2026-05-08-status-sync-v3-main-target.patch' "$log_file" || {
    sed -n '1,180p' "$log_file" >&2
    fail "matched concrete artifact term should be reported"
  }
  log "surfaces trigger-review concrete changed artifact evidence"
}

check_ignores_trigger_review_repeated_source_path_prose_wording() {
  local sandbox log_file
  sandbox="${WORK_DIR}/trigger-review-repeated-source-path-prose-wording"
  log_file="${WORK_DIR}/trigger-review-repeated-source-path-prose-wording.log"
  prepare_sandbox "$sandbox"

  cat >"${sandbox}/mailbox/outbox/2026-05-08-trigger-review-outbox-artifact.md" <<'OUTBOX'
---
id: "mailbox-outbox-trigger-review-outbox-artifact"
title: "Trigger Review Outbox Artifact"
type: "mailbox-message"
status: "done"
owner: "agent"
created: "2026-05-08"
updated: "2026-05-08"
from: "agent/trigger-list-check"
to: "supervisor"
message_id: "trigger-review-outbox-artifact"
tags:
  - mailbox
  - feedback-pressure
  - trigger-review
summary: "Fixture trigger-review refusal using repeated source-path prose wording."
related: []
---

# Trigger Review Outbox Artifact

No next supervisor pressure: further escalation would be noisy because the source-path recursion is already covered.

Supervisor evaluation trigger: after this repair is committed, run `scripts/supervisor.sh triggers --status review --limit 12 --evidence-limit 3` and `scripts/supervisor-evaluation-trigger-list-check.sh`; reopen only if `mailbox/outbox/2026-05-08-trigger-review-source-path-meta-reply.md` returns as review evidence from repeated source-path prose or the concrete outbox Markdown artifact fixture fails.

Stop condition: if only source-path prose repeats, stop.
OUTBOX

  git -C "$sandbox" add --all -- .
  git -C "$sandbox" commit -q -m "fixture: trigger review repeated source-path prose"

  cat >"${sandbox}/mailbox/outbox/2026-05-08-later-continuous-supervision.md" <<'OUTBOX'
---
id: "mailbox-outbox-later-continuous-supervision"
title: "Later Continuous Supervision"
type: "mailbox-message"
status: "done"
owner: "agent"
created: "2026-05-08"
updated: "2026-05-08"
from: "agent/trigger-list-check"
to: "supervisor"
message_id: "later-continuous-supervision"
tags:
  - mailbox
  - feedback-pressure
summary: "Fixture later report that repeats trigger-review source paths as review context."
related: []
---

# Later Continuous Supervision

The latest outbox chain shows that `mailbox/outbox/2026-05-08-trigger-review-source-path-meta-reply.md` was handled, while `mailbox/outbox/2026-05-08-trigger-review-source-path-meta-candidate-dossier-reply.md` still named deferred promotion debt.
OUTBOX

  (
    cd "$sandbox"
    bash scripts/supervisor-evaluation-trigger-list.sh --limit 1 --status review
  ) >"$log_file" 2>&1

  rg -q 'no triggers matched status filter review' "$log_file" || {
    sed -n '1,180p' "$log_file" >&2
    fail "repeated source-path prose wording should not create trigger-review evidence"
  }
  log "ignores trigger-review repeated source-path prose wording"
}

check_ignores_trigger_review_fixture_command_citation() {
  local sandbox log_file
  sandbox="${WORK_DIR}/trigger-review-fixture-command-citation"
  log_file="${WORK_DIR}/trigger-review-fixture-command-citation.log"
  prepare_sandbox "$sandbox"

  cat >"${sandbox}/mailbox/outbox/2026-05-08-trigger-review-outbox-artifact.md" <<'OUTBOX'
---
id: "mailbox-outbox-trigger-review-outbox-artifact"
title: "Trigger Review Outbox Artifact"
type: "mailbox-message"
status: "done"
owner: "agent"
created: "2026-05-08"
updated: "2026-05-08"
from: "agent/trigger-list-check"
to: "supervisor"
message_id: "trigger-review-outbox-artifact"
tags:
  - mailbox
  - feedback-pressure
  - trigger-review
summary: "Fixture trigger-review refusal using a fixture-check command citation."
related: []
---

# Trigger Review Outbox Artifact

No next supervisor pressure: further escalation would be noisy because the source-path recursion is already covered.

Supervisor evaluation trigger: after this repair is committed, run `scripts/supervisor.sh triggers --status review --limit 12 --evidence-limit 3` and `scripts/supervisor-evaluation-trigger-list-check.sh`; reopen only if `mailbox/outbox/2026-05-08-trigger-review-source-path-meta-reply.md` returns as review evidence from repeated source-path prose or the concrete outbox Markdown artifact fixture fails.

Stop condition: if only the fixture validation command is cited as passing proof, stop.
OUTBOX

  git -C "$sandbox" add --all -- .
  git -C "$sandbox" commit -q -m "fixture: trigger review fixture command citation"

  cat >"${sandbox}/mailbox/outbox/2026-05-08-later-proof.md" <<'OUTBOX'
---
id: "mailbox-outbox-later-proof"
title: "Later Proof"
type: "mailbox-message"
status: "done"
owner: "agent"
created: "2026-05-08"
updated: "2026-05-08"
from: "agent/trigger-list-check"
to: "supervisor"
message_id: "later-proof"
tags:
  - mailbox
  - feedback-pressure
summary: "Fixture later report that cites only the validation command as passing proof."
related: []
---

# Later Proof

Verification reran `scripts/supervisor-evaluation-trigger-list-check.sh` and the fixture suite passed. It does not report a concrete outbox Markdown artifact failure.
OUTBOX

  (
    cd "$sandbox"
    bash scripts/supervisor-evaluation-trigger-list.sh --limit 1 --status review
  ) >"$log_file" 2>&1

  rg -q 'no triggers matched status filter review' "$log_file" || {
    sed -n '1,180p' "$log_file" >&2
    fail "fixture validation command citation should not create trigger-review evidence"
  }
  log "ignores trigger-review fixture validation command citations"
}

check_surfaces_trigger_review_concrete_outbox_markdown_artifact_terms() {
  local sandbox log_file
  sandbox="${WORK_DIR}/trigger-review-concrete-outbox-markdown-artifact"
  log_file="${WORK_DIR}/trigger-review-concrete-outbox-markdown-artifact.log"
  prepare_sandbox "$sandbox"

  cat >"${sandbox}/mailbox/outbox/2026-05-08-trigger-review-concrete-outbox-markdown-artifact.md" <<'OUTBOX'
---
id: "mailbox-outbox-trigger-review-concrete-outbox-markdown-artifact"
title: "Trigger Review Concrete Outbox Markdown Artifact"
type: "mailbox-message"
status: "done"
owner: "agent"
created: "2026-05-08"
updated: "2026-05-08"
from: "agent/trigger-list-check"
to: "supervisor"
message_id: "trigger-review-concrete-outbox-markdown-artifact"
tags:
  - mailbox
  - feedback-pressure
  - trigger-review
summary: "Fixture trigger-review refusal with a concrete outbox Markdown artifact path."
related: []
---

# Trigger Review Concrete Outbox Markdown Artifact

No next supervisor pressure: further trigger-review escalation for the source would be noisy unless a concrete outbox Markdown artifact appears.

Supervisor evaluation trigger: run `scripts/supervisor.sh triggers --status review --limit 8 --evidence-limit 3`; if concrete outbox Markdown artifact `mailbox/outbox/2026-05-08-main-target-review-artifact.md` appears as later evidence, issue one artifact-specific review challenge.

Stop condition: if only source paths repeat, stop.
OUTBOX

  git -C "$sandbox" add --all -- .
  git -C "$sandbox" commit -q -m "fixture: trigger review concrete outbox markdown artifact"

  cat >"${sandbox}/mailbox/outbox/2026-05-08-main-target-review-artifact.md" <<'OUTBOX'
---
id: "mailbox-outbox-main-target-review-artifact"
title: "Main Target Review Artifact"
type: "mailbox-message"
status: "done"
owner: "agent"
created: "2026-05-08"
updated: "2026-05-08"
from: "agent/trigger-list-check"
to: "supervisor"
message_id: "main-target-review-artifact"
tags:
  - mailbox
summary: "Fixture concrete outbox Markdown artifact."
related: []
---

# Main Target Review Artifact

This is the concrete outbox Markdown artifact requested by the trigger.
OUTBOX

  (
    cd "$sandbox"
    bash scripts/supervisor-evaluation-trigger-list.sh --limit 1 --status review
  ) >"$log_file" 2>&1

  rg -q 'status: review-evidence' "$log_file" || {
    sed -n '1,180p' "$log_file" >&2
    fail "concrete outbox Markdown artifact term should create review evidence"
  }
  rg -q 'mailbox/outbox/2026-05-08-main-target-review-artifact.md' "$log_file" || {
    sed -n '1,180p' "$log_file" >&2
    fail "later concrete outbox Markdown artifact should be named"
  }
  log "surfaces trigger-review concrete outbox Markdown artifact evidence"
}

check_ignores_directory_prefix_trigger_prose_mentions() {
  local sandbox log_file
  sandbox="${WORK_DIR}/directory-prefix-prose"
  log_file="${WORK_DIR}/directory-prefix-prose.log"
  prepare_sandbox "$sandbox"

  cat >"${sandbox}/mailbox/outbox/2026-05-08-directory-prefix-trigger.md" <<'OUTBOX'
---
id: "mailbox-outbox-directory-prefix-trigger"
title: "Directory Prefix Trigger"
type: "mailbox-message"
status: "done"
owner: "agent"
created: "2026-05-08"
updated: "2026-05-08"
from: "agent/trigger-list-check"
to: "supervisor"
message_id: "directory-prefix-trigger"
tags:
  - mailbox
  - feedback-pressure
summary: "Fixture trigger using a directory-prefix term."
related: []
---

# Directory Prefix Trigger

No next supervisor pressure: further escalation would be noisy because only actual skills changes should reopen this source.

Supervisor evaluation trigger: reopen pressure if later durable evidence shows `skills/` changed without the required proof fields.

Stop condition: if later records only mention skill paths as prose, stop.
OUTBOX

  git -C "$sandbox" add --all -- .
  git -C "$sandbox" commit -q -m "fixture: directory prefix trigger"

  cat >"${sandbox}/mailbox/outbox/2026-05-08-later-prose.md" <<'OUTBOX'
---
id: "mailbox-outbox-later-prose"
title: "Later Prose"
type: "mailbox-message"
status: "done"
owner: "agent"
created: "2026-05-08"
updated: "2026-05-08"
from: "agent/trigger-list-check"
to: "supervisor"
message_id: "later-prose"
tags:
  - mailbox
  - feedback-pressure
summary: "Fixture later prose mentioning a skill path."
related: []
---

# Later Prose

This report mentions `skills/example/SKILL.md`, but it did not change a file under `skills/`.
OUTBOX

  (
    cd "$sandbox"
    bash scripts/supervisor-evaluation-trigger-list.sh --limit 1 --status review
  ) >"$log_file" 2>&1

  rg -q 'no triggers matched status filter review' "$log_file" || {
    sed -n '1,180p' "$log_file" >&2
    fail "directory-prefix trigger should ignore prose-only skill path mentions"
  }
  log "ignores directory-prefix trigger prose mentions"
}

check_surfaces_directory_prefix_changed_path() {
  local sandbox log_file
  sandbox="${WORK_DIR}/directory-prefix-path"
  log_file="${WORK_DIR}/directory-prefix-path.log"
  prepare_sandbox "$sandbox"

  cat >"${sandbox}/mailbox/outbox/2026-05-08-directory-prefix-trigger.md" <<'OUTBOX'
---
id: "mailbox-outbox-directory-prefix-trigger"
title: "Directory Prefix Trigger"
type: "mailbox-message"
status: "done"
owner: "agent"
created: "2026-05-08"
updated: "2026-05-08"
from: "agent/trigger-list-check"
to: "supervisor"
message_id: "directory-prefix-trigger"
tags:
  - mailbox
  - feedback-pressure
summary: "Fixture trigger using a directory-prefix term."
related: []
---

# Directory Prefix Trigger

No next supervisor pressure: further escalation would be noisy because actual skills changes should reopen this source.

Supervisor evaluation trigger: reopen pressure if later durable evidence shows `skills/` changed without the required proof fields.

Stop condition: if no skills path changes, stop.
OUTBOX

  git -C "$sandbox" add --all -- .
  git -C "$sandbox" commit -q -m "fixture: directory prefix trigger"

  mkdir -p "${sandbox}/skills/example"
  cat >"${sandbox}/skills/example/SKILL.md" <<'SKILL'
---
name: example
description: Fixture skill change.
---

# Example

Fixture skill change.
SKILL

  (
    cd "$sandbox"
    bash scripts/supervisor-evaluation-trigger-list.sh --limit 1 --status review
  ) >"$log_file" 2>&1

  rg -q 'status: review-evidence' "$log_file" || {
    sed -n '1,180p' "$log_file" >&2
    fail "directory-prefix changed path should create review evidence"
  }
  rg -q 'skills/example/SKILL.md' "$log_file" || {
    sed -n '1,180p' "$log_file" >&2
    fail "directory-prefix changed path evidence should be named"
  }
  log "surfaces directory-prefix changed paths"
}

check_ignores_supervisor_trigger_review_meta_prose() {
  local sandbox log_file
  sandbox="${WORK_DIR}/supervisor-trigger-review-meta"
  log_file="${WORK_DIR}/supervisor-trigger-review-meta.log"
  prepare_sandbox "$sandbox"

  cat >"${sandbox}/mailbox/outbox/2026-05-08-supervisor-script-trigger.md" <<'OUTBOX'
---
id: "mailbox-outbox-supervisor-script-trigger"
title: "Supervisor Script Trigger"
type: "mailbox-message"
status: "done"
owner: "agent"
created: "2026-05-08"
updated: "2026-05-08"
from: "agent/trigger-list-check"
to: "supervisor"
message_id: "supervisor-script-trigger"
tags:
  - mailbox
  - feedback-pressure
summary: "Fixture trigger using the supervisor script path."
related: []
---

# Supervisor Script Trigger

No next supervisor pressure: further escalation would be noisy because the supervisor script did not change.

Supervisor evaluation trigger: reopen pressure if later durable evidence shows a change to `scripts/supervisor.sh`.

Stop condition: if later records only cite trigger-review command or content-match meta prose, stop.
OUTBOX

  git -C "$sandbox" add --all -- .
  git -C "$sandbox" commit -q -m "fixture: supervisor script trigger"

  cat >"${sandbox}/mailbox/outbox/2026-05-08-later-meta.md" <<'OUTBOX'
---
id: "mailbox-outbox-later-meta"
title: "Later Meta"
type: "mailbox-message"
status: "done"
owner: "agent"
created: "2026-05-08"
updated: "2026-05-08"
from: "agent/trigger-list-check"
to: "supervisor"
message_id: "later-meta"
tags:
  - mailbox
  - feedback-pressure
summary: "Fixture later meta prose about trigger-review matching."
related: []
---

# Later Meta

The `scripts/supervisor.sh` content matches are ignored when the line is only trigger-review command citation prose.
OUTBOX

  (
    cd "$sandbox"
    bash scripts/supervisor-evaluation-trigger-list.sh --limit 1 --status review
  ) >"$log_file" 2>&1

  rg -q 'no triggers matched status filter review' "$log_file" || {
    sed -n '1,180p' "$log_file" >&2
    fail "supervisor trigger-review meta prose should not create review evidence"
  }
  log "ignores supervisor trigger-review meta prose"
}

main() {
  rm -rf "$WORK_DIR"
  mkdir -p "$WORK_DIR"
  check_lists_quiet_trigger_without_self_match
  check_lists_review_evidence_after_later_match
  check_status_filter
  check_ignores_marker_only_later_evidence
  check_uncommitted_trigger_stays_quiet
  check_ignores_generic_words_from_completed_record_trigger
  check_existing_file_old_term_does_not_count_after_unrelated_edit
  check_ignores_trigger_review_scaffold_only_terms
  check_ignores_trigger_review_source_path_meta_terms
  check_ignores_trigger_review_repeated_source_path_current_wording
  check_surfaces_trigger_review_concrete_artifact_terms
  check_ignores_trigger_review_repeated_source_path_prose_wording
  check_ignores_trigger_review_fixture_command_citation
  check_surfaces_trigger_review_concrete_outbox_markdown_artifact_terms
  check_ignores_directory_prefix_trigger_prose_mentions
  check_surfaces_directory_prefix_changed_path
  check_ignores_supervisor_trigger_review_meta_prose
  log "ok"
}

main "$@"
