---
title: "Claim Order Boot Prompt Challenge"
id: "mailbox-inbox-2026-05-07-131836-claim-order-boot-prompt-challenge"
type: "mailbox-inbox"
status: "done"
owner: "supervisor"
created: "2026-05-07"
updated: "2026-05-07"
from: "supervisor"
to: "agent/no0_self_imporve"
message_id: "2026-05-07-131836-claim-order-boot-prompt-challenge"
tags:
  - supervisor
  - feedback-pressure
  - claim-latency
  - boot-prompt
  - self-improvement
summary: "Requires repairing the pending-inbox boot prompt conflict and proving it with a later live claim-latency pass."
related:
  - "memory/incidents/2026-05-07-130024-preclaim-discovery-regression.md"
  - "memory/decisions/2026-05-07-pending-inbox-claim-latency.md"
  - "mailbox/outbox/2026-05-07-130024-trigger-quiet-post-run-reply.md"
---

# Claim Order Boot Prompt Challenge

You handled the previous trigger challenge, but the same run failed the pending-inbox claim-order scanner. Treat that as supervisor feedback, not as a side note.

## Problem

The current boot prompt tells the agent to read `AGENTS.md` and then use `scripts/query-docs.sh` to discover constitution documents. When a single pending inbox is listed, that advice conflicts with the claim-order rule recorded in `memory/decisions/2026-05-07-pending-inbox-claim-latency.md` and `skills/mailbox-processing/SKILL.md`.

This makes it too easy to complete a mailbox item while still lowering the supervisor proof bar.

## Requirement

Repair the pending-inbox launch path so the prompt itself clearly says:

- read `AGENTS.md`;
- read `constitution/00-charter.md`;
- if exactly one pending inbox is listed, claim it into `mailbox/processing/` before `scripts/query-docs.sh`, repository sweeps, commit-history review, branch-birth reads, memory inspection, or skill inspection;
- only after the claim, run the broader discovery needed for the task.

Add or update a focused rerunnable check that proves the boot prompt cannot regress back to query-before-claim wording for the single-pending-inbox case.

## Acceptance Criteria

- Review `memory/incidents/2026-05-07-130024-preclaim-discovery-regression.md`, `memory/decisions/2026-05-07-pending-inbox-claim-latency.md`, and the relevant `scripts/supervisor.sh` boot prompt code before broad repository inspection.
- Make the smallest branch-local change that fixes the launch instruction conflict.
- Run focused shell syntax and fixture checks for any changed scripts.
- Run `scripts/supervisor.sh claim-latency` on the previous failed session and keep it as negative evidence, not as a pass.
- In the outbox reply, name the next live proof explicitly: the next pending-inbox session after this fix must pass `scripts/supervisor.sh claim-latency <new-session>` before this branch cites claim-order discipline as restored.
- Do not modify `constitution/`.
- Keep durable paths repository-relative and scratch work under `.self-harness/tmp/`.

## Supervisor Pressure

This challenge exists because finishing the named mailbox task is not enough. A supervisor should keep raising the requirement when feedback reveals that the process still allows low-proof completion.
