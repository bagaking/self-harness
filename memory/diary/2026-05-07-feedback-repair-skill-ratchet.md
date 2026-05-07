---
id: "diary-2026-05-07-feedback-repair-skill-ratchet"
title: "Feedback Repair Skill Ratchet"
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
  - skill
summary: "Records a mailbox run that moved the feedback escalation self-check into the mailbox-processing workflow."
source: "session"
confidence: "high"
related:
  - "mailbox-inbox-2026-05-07-173240-feedback-repair-skill-ratchet"
  - "mailbox-outbox-2026-05-07-feedback-repair-skill-ratchet-reply"
  - "skills/mailbox-processing/SKILL.md"
---

# Feedback Repair Skill Ratchet

## Summary

Processed the pending feedback repair skill ratchet. The run identified that the prior feedback-bearing mailbox handoff stopped before running `scripts/feedback-escalation-check.sh`; the supervisor commit gate caught the problem later, but the mailbox workflow itself did not require the self-check.

## Repository Changes

- Updated `skills/mailbox-processing/SKILL.md` with a focused feedback-bearing mailbox step that runs `scripts/feedback-escalation-check.sh` before diary and final handoff.
- Added `mailbox/outbox/2026-05-07-feedback-repair-skill-ratchet-reply.md`.
- Moved `mailbox/inbox/2026-05-07-173240-feedback-repair-skill-ratchet.md` through `mailbox/processing/` to `mailbox/done/`.
- Added this diary under `memory/diary/`.

## Mailbox Activity

- Claimed exactly one pending inbox file.
- Reviewed `mailbox/outbox/2026-05-07-post-run-sentinel-gate-verification-reply.md` before broad repository inspection.
- Inspected the recorded post-run failure in `.self-harness/tmp/commit-gate-last-report.md`.
- Replied under `mailbox/outbox/2026-05-07-feedback-repair-skill-ratchet-reply.md`.
- Closed the input under `mailbox/done/2026-05-07-173240-feedback-repair-skill-ratchet.md`.

## Memory Updates

Only this diary was added. The reusable lesson belongs in the mailbox-processing skill because it changes a future workflow step.

## Skill Updates

`skills/mailbox-processing/SKILL.md` now tells feedback-bearing mailbox runs to run `scripts/feedback-escalation-check.sh` after durable mailbox output and closure are in place, but before the diary and final handoff. It points to `skills/branch-evolution-evaluation/SKILL.md` for the expected feedback-continuity markers.

## Decisions

- Chose a skill update instead of a new script because the deterministic checker and evaluation marker contract already existed.
- Kept the change narrow to feedback-bearing mailbox work: supervisor feedback, feedback pressure, pressure ratchets, raising the bar, low-value loops, and proof-bar work.
- Proposed the skill edit as return-to-main candidate pending supervisor review because it is branch-neutral, small, and tied to a real gate failure.

## Risks Or Incidents

- The skill adds one extra command to feedback-bearing mailbox handoff. That is intentional, but future agents should avoid expanding it into generic challenge churn.
- No `constitution/` files were modified.

## Verification

Pre-diary feedback gate:

```text
feedback-escalation-check: ok
```

Final repository validation is run after this diary is complete.

## Next Suggested Work

Run the next feedback-bearing mailbox task through `skills/mailbox-processing/SKILL.md` and confirm the diary or outbox cites a pre-handoff `scripts/feedback-escalation-check.sh` result before the supervisor commit gate runs.
