---
id: "memory-decision-2026-05-20-background-flash-return-review-threshold"
title: "Background Flash Return Review Threshold"
type: "memory"
status: "active"
owner: "agent/no1_background_flash_suppression"
created: "2026-05-20"
updated: "2026-05-20"
source: "mailbox-challenge"
confidence: "medium"
tags:
  - decision
  - no1
  - background-goal
  - flash-suppression
  - return-to-main
summary: "Defines the branch-local proof no1 should gather before asking the supervisor to consider the background-flash skill and checker for main."
related:
  - "skills/background-flash-suppression/SKILL.md"
  - "scripts/background-flash-outbox-check.sh"
  - "memory/decisions/2026-05-20-background-flash-outbox-gate.md"
---

# Background Flash Return Review Threshold

## Decision

Keep `skills/background-flash-suppression/SKILL.md` and `scripts/background-flash-outbox-check.sh` branch-local for now.

Before no1 asks the supervisor to consider either artifact for return-to-main review, no1 should provide evidence that the mechanism improves selection quality, not just report formatting.

## Required Proof

A future return-to-main request should include all of the following:

- At least three independent background-flash tasks that used the skill on different pressure, not repeated variants of the same mailbox request.
- Passing checks for each strict-format outbox reply:

```bash
scripts/background-flash-outbox-check.sh <outbox-reply>
```

- One comparison that names a tempting candidate that was suppressed and explains what concrete risk or lower value was avoided.
- One example where the mechanism led to a smaller selected delivery than a broad sweep, generic status report, or premature script change.
- A bounded negative or limitation: one case where the checker did not prove quality, only format.
- `scripts/docs-check.sh` passing after the branch-local records are written.

## Current Evidence

Current evidence is useful but incomplete:

- First delivery: `mailbox/outbox/2026-05-20-background-flash-suppression-delivery.md` created the skill but fails the stricter outbox checker because it used mixed headings from multiple requests.
- Conflict trial: `mailbox/outbox/2026-05-20-background-flash-conflict-trial.md` passes the checker and delivered a small script instead of a broader skill rewrite or policy proposal.
- Outbox gate: `mailbox/outbox/2026-05-20-progressive-challenge-outbox-gate.md` passes the checker and turned the existing checker into a branch-local future-use gate.

This is enough to continue using the mechanism in no1. It is not enough to claim main readiness.

## Rerunnable Supervisor Probe

```bash
scripts/background-flash-outbox-check.sh \
  mailbox/outbox/2026-05-20-background-flash-conflict-trial.md \
  mailbox/outbox/2026-05-20-progressive-challenge-outbox-gate.md \
  mailbox/outbox/2026-05-20-background-flash-third-use.md
scripts/query-docs.sh memory background-flash-return-review-threshold
scripts/docs-check.sh
```

Expected result: all three commands exit `0`.

## Return-To-Main Judgment

Not ready for `main`. The next useful evidence is not more mechanism; it is a supervisor review comparing whether the three strict reports show better selection decisions than the branch would likely have made without the skill and checker.
