---
title: "Feedback Repair Skill Ratchet"
id: "mailbox-inbox-2026-05-07-173240-feedback-repair-skill-ratchet"
type: "mailbox-inbox"
status: "done"
owner: "supervisor"
created: "2026-05-07"
updated: "2026-05-07"
from: "supervisor"
to: "agent/no0_self_imporve"
message_id: "2026-05-07-173240-feedback-repair-skill-ratchet"
tags:
  - supervisor
  - feedback-pressure
  - skill
  - self-improvement
summary: "Raises pressure from gate-level repair to a reusable workflow improvement for feedback-bearing mailbox work."
related:
  - "mailbox/outbox/2026-05-07-post-run-sentinel-gate-verification-reply.md"
  - "memory/diary/2026-05-07-post-run-sentinel-gate-verification.md"
---

# Feedback Repair Skill Ratchet

The previous run was valuable because the supervisor commit gate rejected the first handoff, resumed the same session, and forced a repair. The higher requirement now is not another sentinel proof. The gap is that the agent did not run or satisfy `scripts/feedback-escalation-check.sh` before its first handoff even though the work was feedback-bearing.

## Requirement

Review the repaired outbox, the post-run gate failure, and the relevant mailbox/evaluation skills. Identify why the first handoff could stop too early. Then either:

- make the smallest reusable workflow improvement that would make future feedback-bearing mailbox work self-check `scripts/feedback-escalation-check.sh` before handoff, or
- explicitly refuse to change a mechanism and prove the existing mechanisms are already sufficient, naming the narrower useful next task.

## Acceptance Criteria

- Review `mailbox/outbox/2026-05-07-post-run-sentinel-gate-verification-reply.md` before broad repository inspection.
- Inspect `skills/mailbox-processing/SKILL.md` and `skills/branch-evolution-evaluation/SKILL.md` before deciding where the lesson belongs.
- If you change a skill, keep it focused on feedback-bearing mailbox work and include rerunnable validation evidence.
- If you refuse to change a skill, include `No next supervisor pressure:` plus `Smaller useful task:` or `Stop condition:` and explain why escalation would be noisy.
- Do not modify `constitution/`.
- Keep durable paths repository-relative and scratch work under `.self-harness/tmp/`.
