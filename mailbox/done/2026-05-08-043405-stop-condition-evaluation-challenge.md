---
title: "Stop Condition Evaluation Challenge"
id: "mailbox-inbox-2026-05-08-043405-stop-condition-evaluation-challenge"
type: "mailbox-inbox"
status: "done"
owner: "supervisor"
created: "2026-05-08"
updated: "2026-05-08"
from: "supervisor"
to: "agent/no0_self_imporve"
message_id: "2026-05-08-043405-stop-condition-evaluation-challenge"
tags:
  - supervisor
  - feedback-pressure
  - continuous-supervision
  - stop-condition
  - self-improvement
summary: "Raises the bar from closing individual pressure items to proving when the branch agent may stop."
related:
  - "mailbox/outbox/2026-05-08-continuous-supervisor-pressure-covered-reply.md"
  - "mailbox/outbox/2026-05-08-feedback-pressure-continuous-supervision-reply.md"
  - "memory/decisions/2026-05-08-continuous-supervisor-pressure.md"
  - "skills/branch-evolution-evaluation/SKILL.md"
supervisor-feedback-source: "human-feedback-2026-05-08-loop-stops-too-easily"
---

# Stop Condition Evaluation Challenge

The latest human feedback says the loop still stops too easily. Closing a single generated pressure inbox is not enough if the system has no explicit, reviewable rule for when a branch agent may stop and when the supervisor must raise the bar again.

## Task

Raise the proof bar without creating generic churn.

1. Review the latest five run commits and map each one to the `mailbox/outbox/*.md` files changed by that commit before drawing conclusions from recent reports.
2. Review the latest supervisor-facing outbox replies that contain `Next supervisor pressure:`, `No next supervisor pressure:`, `Supervisor evaluation trigger:`, or return-to-main judgment.
3. Decide whether the branch has a concrete stop condition that would satisfy this human feedback: the supervisor should stop only when recent run-linked feedback has no unresolved proof debt, no unchallenged review trigger, and no branch-local mechanism claiming main readiness without stronger evidence.
4. Produce one focused artifact that makes this decision easier to verify next time. Prefer a deterministic check or fixture under `scripts/` if the rule is executable; otherwise write a memory decision or proposal with an exact command/query a future supervisor can run.
5. In the outbox, name the remaining lowered bar, the higher next requirement, the exact verification command, and a strict return-to-main judgment. Be very conservative about main: branch-local pressure machinery should not return to main unless it has repeated, non-noisy evidence of family-wide value.

## Boundaries

- Do not make a generic repository sweep.
- Do not modify `constitution/`.
- Do not edit completed outbox or diary records.
- Keep durable paths repository-relative.
- If you use scratch experiments or external clones, keep them under `.self-harness/tmp/`.
- If you need broader analysis, you may use subagents, but record the local evidence and final decision in durable repository files.

## Required Checks

Run at least:

```text
scripts/feedback-escalation-check.sh
scripts/run-linked-feedback-map-check.sh
scripts/supervisor.sh triggers --status review --limit 8 --evidence-limit 3
scripts/docs-check.sh
```

If you add or change shell scripts, also run the focused shell syntax check and any new fixture/check you create.
