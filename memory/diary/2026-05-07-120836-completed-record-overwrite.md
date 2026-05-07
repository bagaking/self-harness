---
id: "diary-2026-05-07-120836-completed-record-overwrite"
title: "Completed Record Overwrite"
type: "diary"
status: "active"
owner: "agent"
created: "2026-05-07"
updated: "2026-05-07"
tags:
  - diary
  - no0
  - autonomous-run
  - mailbox
  - feedback-pressure
  - completed-records
summary: "Records a feedback-pressure run that made completed outbox and diary overwrites checkable."
source: "session"
confidence: "high"
related:
  - "mailbox-inbox-2026-05-07-120836-feedback-pressure-challenge"
  - "mailbox-outbox-2026-05-07-120836-completed-record-overwrite-reply"
  - "decision-2026-05-07-completed-record-overwrite-check"
---

# Completed Record Overwrite

## Summary

Processed explicit supervisor feedback about the prior run overwriting completed historical outbox and diary records. The run added a deterministic check that rejects edits to already tracked completed `mailbox/outbox/*.md` and `memory/diary/*.md` records.

## Repository Changes

- Added `scripts/completed-record-overwrite-check.sh`.
- Added `scripts/completed-record-overwrite-fixture-check.sh`.
- Exposed the check as `scripts/supervisor.sh completed-records`.
- Wired the check into the supervisor commit gate.
- Hardened `scripts/docs-check.sh` to avoid a reproducible local `rg` segmentation fault by collecting Markdown files once and using `grep`/`awk` for simple checks.
- Updated `skills/branch-evolution-evaluation/SKILL.md` for completed-record overwrite feedback.
- Added `memory/decisions/2026-05-07-completed-record-overwrite-check.md`.
- Added `mailbox/outbox/2026-05-07-120836-completed-record-overwrite-reply.md`.

## Mailbox Activity

- Claimed `mailbox/inbox/2026-05-07-120836-feedback-pressure-challenge.md` into `mailbox/processing/`.
- Wrote the supervisor-facing reply under a unique `120836` outbox path.
- Moved the handled input to `mailbox/done/`.

## Memory Updates

Recorded the completed-record overwrite rule in `memory/decisions/2026-05-07-completed-record-overwrite-check.md`.

## Skill Updates

Updated `skills/branch-evolution-evaluation/SKILL.md` so future completed-record overwrite feedback evaluations run `scripts/supervisor.sh completed-records` or `scripts/completed-record-overwrite-check.sh`, and prove behavior with `scripts/completed-record-overwrite-fixture-check.sh`.

## Decisions

Existing tracked outbox replies and diary artifacts are treated as completed historical records. Current-run evidence should use uniquely named new files; evolving memory may still update decision and lesson files.

Return-to-main is deferred because this is a strict branch-local commit-gate rule until the supervisor decides whether the family should protect completed outbox and diary records the same way.

## Risks Or Incidents

The new check may be too strict for rare intentional historical-record repairs. That is why promotion to `main` is deferred rather than claimed.

## Validation

Focused proof:

```text
completed-record-overwrite-fixture-check: rejects modifications to existing completed outbox and diary records
completed-record-overwrite-fixture-check: allows new outbox and diary records while updating memory decisions
completed-record-overwrite-fixture-check: ok
completed-record-overwrite-check: ok
shell-syntax-check: ok scripts/completed-record-overwrite-check.sh
shell-syntax-check: ok scripts/completed-record-overwrite-fixture-check.sh
shell-syntax-check: ok scripts/supervisor.sh
shell-syntax-check: ok scripts/docs-check.sh
```

Final validation also ran:

```text
feedback-escalation-check: ok
proof-pressure-check: ok
docs-check: ok
constitution-clean
```

Mailbox hygiene checks found no unfinished non-placeholder files in `mailbox/processing/` and no temporary outbox or `.tmp` files directly under `.self-harness/tmp/`.

## Next Suggested Work

Next supervisor pressure: run `scripts/supervisor.sh completed-records` during the next post-run commit attempt and require a pass before treating restored historical outbox or diary records as durable evidence.
