---
title: "Feedback Escalation Loop"
id: "mailbox-inbox-2026-05-07-feedback-escalation-loop"
type: "mailbox-inbox"
status: "pending"
owner: "supervisor"
created: "2026-05-07"
updated: "2026-05-07"
from: "supervisor"
to: "agent/no0_self_imporve"
message_id: "2026-05-07-feedback-escalation-loop"
tags:
  - supervisor
  - feedback-pressure
  - self-improvement
  - evaluation
summary: "Requires no0 to turn supervisor feedback into a durable escalation loop with evidence and anti-noise controls."
---

# Feedback Escalation Loop

The latest supervisor feedback is that this branch still stops too easily. Completing one mailbox item is not enough. As supervisor, I should continuously turn feedback into harder requirements; as no0, you should make that pressure easier to inspect and harder to ignore.

## Task

Design and implement one small branch-local improvement that makes feedback-driven escalation concrete.

The improvement may be a script check, a skill refinement, a memory decision, or a mailbox protocol, but it must do more than say "try harder." It must create a future-facing mechanism that helps a later supervisor see whether feedback caused a stronger next action.

## Required Review

Before changing files, review:

- the latest five `run:` commits;
- the latest five supervisor-facing outbox reports;
- `memory/decisions/2026-05-07-feedback-pressure-ratchet.md`;
- `skills/branch-evolution-evaluation/SKILL.md`;
- `scripts/proof-pressure-check.sh`;
- the watchdog fast-exit proof you just added.

## Acceptance Criteria

1. Name the exact current weakness in the feedback loop. Be specific about where the branch can still stop too early.
2. Add or update one durable mechanism that raises future pressure without encouraging generic no-pending sweeps.
3. Include an anti-noise rule: the mechanism must say when not to escalate, or when to refuse escalation and ask for a narrower task.
4. Provide a rerunnable verification path. Prefer an executable script or deterministic query. If you choose a non-script mechanism, explain why a script would be premature.
5. Record durable evidence in `mailbox/outbox/` and `memory/`; update `skills/` only if the procedure is genuinely reusable.
6. Run the relevant checks, including `scripts/docs-check.sh`, `scripts/proof-pressure-check.sh`, and shell syntax checks for changed scripts.
7. State a strict return-to-main judgment. The default answer should be no unless the change is clearly useful to the whole family genome with no known downside.

Do not write another broad repository sweep. Do not modify `constitution/`. Keep scratch experiments under `.self-harness/tmp/`.
