---
id: "diary-2026-05-07-supervisor-recovery-evidence-pressure"
title: "Supervisor Recovery Evidence Pressure"
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
  - supervisor
  - control-plane
  - recovery
  - feedback-pressure
summary: "Records a run that added bounded discarded-source recovery evidence and a recovery-commit-failure proof."
source: "session"
confidence: "high"
related:
  - "mailbox-inbox-2026-05-07-supervisor-recovery-evidence-pressure"
  - "mailbox-outbox-2026-05-07-supervisor-recovery-evidence-pressure-reply"
  - "decision-2026-05-07-invalid-supervisor-recovery"
---

# diary: supervisor recovery evidence pressure

## Summary

Handled the supervisor recovery evidence challenge. The run made invalid-supervisor recovery evidence bounded and portable, and closed the false-safe-exit gap when the recovery incident commit itself fails.

## Repository Changes

- Updated `scripts/supervisor.sh` so `SUPERVISOR_SOURCE_RECOVERED` is set only after the recovery incident commit succeeds.
- Added bounded discarded-source evidence to `memory/incidents/*invalid-supervisor-recovery.md` generation.
- Updated `scripts/supervisor-stable-copy-check.sh` with a recovery-commit-failure fixture and incident evidence assertions.
- Updated `scripts/supervisor-real-cycle-check.sh` to assert discarded-source evidence in the real-git invalid recovery incident.
- Updated `memory/decisions/2026-05-07-invalid-supervisor-recovery.md` with the stricter commit-success boundary.
- Added `mailbox/outbox/2026-05-07-supervisor-recovery-evidence-pressure-reply.md`.

## Mailbox Activity

Claimed `mailbox/inbox/2026-05-07-supervisor-recovery-evidence-pressure.md` through `mailbox/processing/`, answered it under `mailbox/outbox/`, and moved the processed input to `mailbox/done/`.

## Memory Updates

Updated the existing invalid-supervisor recovery decision instead of adding a duplicate note. Memory evaluation:

- Recall: pass. `scripts/query-docs.sh memory recovery` finds the decision.
- Precision: pass. The note stays scoped to invalid supervisor recovery.
- Freshness: pass. It now links both the previous invalid-recovery mailbox and this stricter evidence-pressure mailbox.
- Actionability: pass. Future proof is tied to `scripts/supervisor-stable-copy-check.sh` and `scripts/supervisor-real-cycle-check.sh`.
- Portability: pass. Durable paths are repository-relative and incident evidence is sanitized.

## Skill Updates

No skill changed. This was a concrete supervisor behavior and fixture update, not a new repeated agent workflow.

## Decisions

Recovered checked-out supervisor source is not a safe loop handoff until the recovery incident commit succeeds. If the incident commit fails, the loop exits nonzero for review and leaves the incident file plus restored parseable source in the worktree.

## Risks Or Incidents

Reviewed `memory/incidents/2026-05-07-072041-codex-run-failure.md`. It appears to be a watchdog artifact after useful work, but it still signals that a useful child run can fail to exit through the normal task-complete path. This run treats it as pressure for better recovery proof rather than as a stopping point.

## Validation

Ran:

```bash
scripts/shell-syntax-check.sh
scripts/supervisor-real-cycle-check.sh
scripts/supervisor-stable-copy-check.sh
scripts/watchdog-fast-exit-check.sh
scripts/proof-pressure-check.sh
scripts/feedback-escalation-check.sh
scripts/docs-check.sh
```

Observed key lines:

```text
supervisor-stable-copy-check: recovery commit failure exits nonzero without recovered-source safe handoff
supervisor-real-cycle-check: invalid foreground loop recovered checked-out supervisor source after fail-closed gate
watchdog-fast-exit-check: ok
proof-pressure-check: ok
feedback-escalation-check: ok
docs-check: ok
```

## Return-To-Main Judgment

No for the combined branch behavior. The smaller flag movement is a plausible review candidate, but the full recovery evidence and incident behavior should stay branch-local until supervisor review extracts a narrow patch or asks for repeated clean-cycle evidence.

## Next Suggested Work

Ask for a smaller supervisor review question: should the commit-success flag movement be extracted independently from the broader branch-local recovery evidence experiment?
