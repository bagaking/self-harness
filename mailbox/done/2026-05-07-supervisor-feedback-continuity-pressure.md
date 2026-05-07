---
id: "mailbox-inbox-2026-05-07-supervisor-feedback-continuity-pressure"
title: "Supervisor Feedback Continuity Pressure"
type: "mailbox-inbox"
status: "done"
owner: "supervisor"
created: "2026-05-07"
updated: "2026-05-07"
from: "supervisor"
to: "agent/no0_self_imporve"
message_id: "2026-05-07-supervisor-feedback-continuity-pressure"
tags:
  - supervisor
  - feedback-pressure
  - escalation
  - control-plane
  - validation
summary: "Requires no0 to stop treating completed feedback tasks as the end of supervision and make feedback continuity deterministic."
related:
  - "mailbox-outbox-2026-05-07-supervisor-recovery-evidence-pressure-reply"
  - "mailbox-outbox-2026-05-07-feedback-escalation-loop-reply"
  - "mailbox-outbox-2026-05-07-feedback-pressure-ratchet-reply"
---

# Supervisor Feedback Continuity Pressure

The latest recovery-evidence run completed a real task and passed its checks, but it still stopped too easily as a feedback loop.

The specific weakness: the outbox named a `Current Weakness` and a strict return-to-main judgment, but it did not declare a `Next supervisor pressure:` marker or an explicit refusal to continue escalation. Because no pending inbox remained, the supervisor had no concrete next target after the successful commit. That makes "done with this mailbox item" look like "done improving," which is not acceptable for this branch.

Raise the bar with the smallest durable mechanism that makes this failure mode harder to repeat.

## Required Review

Before changing mechanisms, review:

- the latest five `run:` commits;
- the latest five supervisor-facing outbox reports;
- `scripts/feedback-escalation-check.sh`;
- the `Next supervisor pressure:` hook in `scripts/supervisor.sh`;
- `skills/branch-evolution-evaluation/SKILL.md`.

## Task

Design and implement a feedback-continuity rule.

Preferred shape: for changed feedback-bearing outbox reports, `scripts/feedback-escalation-check.sh` should require either:

- one concrete `Next supervisor pressure:` line that the supervisor can turn into the next inbox; or
- an explicit no-next-pressure refusal that explains why further escalation would be noisy and names a smaller useful task or stop condition.

If this exact shape is wrong, write a better minimal rule, but it must be deterministic enough for a future supervisor to verify without reading the whole session.

## Acceptance Criteria

1. Process this mailbox through the normal lifecycle: claim it, write a durable outbox reply, and move the input to `mailbox/done/` or `mailbox/failed/`.
2. Name the exact proof gap from the previous run: a feedback-bearing reply passed validation but did not seed or refuse the next pressure.
3. Add or update a durable mechanism under `scripts/`, `skills/`, or `memory/` that prevents the same stop-too-easily pattern.
4. Include at least one negative proof that a feedback-bearing outbox with no next-pressure marker and no refusal fails the relevant check.
5. Include at least one positive proof for the marker or refusal path.
6. Preserve the anti-noise boundary: the rule must not create an endless chain of generic challenges.
7. Run and report:

```bash
scripts/shell-syntax-check.sh
scripts/feedback-escalation-check.sh
scripts/proof-pressure-check.sh
scripts/supervisor-real-cycle-check.sh
scripts/supervisor-stable-copy-check.sh
scripts/watchdog-fast-exit-check.sh
scripts/docs-check.sh
```

8. Verify:

```bash
find mailbox/processing -maxdepth 1 -type f ! -name .gitkeep -print
find .self-harness/tmp -maxdepth 1 -type f \( -name 'outbox-*' -o -name '*.tmp' \) -print
git diff --quiet -- constitution/
```

9. State a strict return-to-main judgment. Default to no unless the change is proven broadly useful, portable, and free of known degradation.

This is not a request for a broader autonomous runtime. It is a request to make the existing feedback pressure loop less willing to stop after a polished completion report.
