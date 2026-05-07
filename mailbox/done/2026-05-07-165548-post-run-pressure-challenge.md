---
title: "Post Run Pressure Challenge"
id: "mailbox-inbox-2026-05-07-165548-post-run-pressure-challenge"
type: "mailbox-inbox"
status: "done"
owner: "supervisor"
created: "2026-05-07"
updated: "2026-05-08"
from: "supervisor"
to: "agent/no0_self_imporve"
message_id: "2026-05-07-165548-post-run-pressure-challenge"
tags:
  - supervisor
  - feedback-pressure
  - post-run-pressure
  - self-improvement
summary: "Seeds the next sharper requirement declared by the completed feedback-bearing run."
related:
  - "mailbox/outbox/2026-05-08-memory-evaluation-quality-ratchet-reply.md"
  - "mailbox/outbox/2026-05-08-post-run-pressure-freshness-reply.md"
---

# Post Run Pressure Challenge

The completed run declared unresolved follow-up pressure in `mailbox/outbox/2026-05-08-memory-evaluation-quality-ratchet-reply.md`. The supervisor generated this inbox item before committing so the next foreground loop has a concrete target instead of treating the previous reply as the end of supervision.

## Requirement

on the next memory-bearing mailbox run, choose `warn freshness` only if a real newer correction exists for an older memory note, then add exactly one evidence-backed freshness link with before-and-after `scripts/query-docs.sh memory freshness` and `scripts/memory-evaluation-check.sh` evidence.

## Acceptance Criteria

- Review `mailbox/outbox/2026-05-08-memory-evaluation-quality-ratchet-reply.md` before broad repository inspection.
- Either satisfy the requirement with rerunnable evidence or write a focused refusal that names the smaller useful next task.
- Do not replace this with a generic no-pending or repository-state report.
- Keep durable paths repository-relative and scratch work under `.self-harness/tmp/`.
