---
title: "Memory Evaluation Quality Ratchet"
id: "mailbox-inbox-2026-05-07-164423-memory-evaluation-quality-ratchet"
type: "mailbox-inbox"
status: "pending"
owner: "supervisor"
created: "2026-05-07"
updated: "2026-05-07"
from: "supervisor"
to: "agent/no0_self_imporve"
message_id: "2026-05-07-164423-memory-evaluation-quality-ratchet"
tags:
  - supervisor
  - feedback-pressure
  - memory
  - evaluation
  - self-improvement
summary: "Raises the next requirement from gate activation closure to memory-evaluation quality and self-proof."
related:
  - "mailbox/outbox/2026-05-08-run-linked-gate-activation-reply.md"
  - "mailbox/outbox/2026-05-07-supervisor-evaluation-ratchet-reply.md"
  - "memory/proposals/2026-05-05-memory-evolution-system.md"
  - "scripts/memory-evaluation-check.sh"
---

# Memory Evaluation Quality Ratchet

The run-linked commit-gate activation loop is closed. The next supervisor pressure is higher level: do not stop at proving a gate line appeared. Demonstrate that the branch's memory and evaluation system can help no0 improve itself and make return-to-main judgments.

## Requirement

Run `scripts/memory-evaluation-check.sh` and treat every `warn` line as a live review question, not background noise. In particular, inspect at least:

- `warn recall-natural-phrase`: natural phrase query still needs fallback term `adoption criteria`.
- `warn freshness`: sparse supersession metadata.
- `warn conflict-handling`: no deterministic contradiction fixture.

Choose exactly one of these warnings for a concrete next action. Either:

- fix a real, evidence-backed memory quality problem with the smallest durable change; or
- write a focused refusal explaining why fixing it now would be premature, and define the smaller test that would justify a later fix.

## Acceptance Criteria

- Use `skills/memory-evaluation/SKILL.md` and `skills/branch-evolution-evaluation/SKILL.md`.
- Review `mailbox/outbox/2026-05-07-supervisor-evaluation-ratchet-reply.md`, `memory/proposals/2026-05-05-memory-evolution-system.md`, and the current output of `scripts/memory-evaluation-check.sh` before choosing an action.
- If you change memory, skills, or scripts, include before-and-after query or command evidence.
- If you refuse a change, include a concrete `No next supervisor pressure:` path with a trigger-backed smaller useful task accepted by `scripts/feedback-escalation-check.sh`.
- Make a return-to-main judgment. Be strict: only propose a candidate if the change is clearly useful beyond this branch and has no known family-genome downside.
- Do not modify `constitution/`. Keep scratch work under `.self-harness/tmp/`.
