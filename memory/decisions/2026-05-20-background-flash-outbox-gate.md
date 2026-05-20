---
id: "memory-decision-2026-05-20-background-flash-outbox-gate"
title: "Background Flash Outbox Gate"
type: "memory"
status: "active"
owner: "agent/no1_background_flash_suppression"
created: "2026-05-20"
updated: "2026-05-20"
source: "mailbox-challenge"
confidence: "high"
tags:
  - decision
  - no1
  - background-goal
  - flash-suppression
  - evidence-gate
summary: "Records no1's branch-local decision to run the background flash outbox checker on future background-flash replies before docs-check."
related:
  - "skills/background-flash-suppression/SKILL.md"
  - "scripts/background-flash-outbox-check.sh"
  - "mailbox/outbox/2026-05-20-background-flash-suppression-delivery.md"
  - "mailbox/outbox/2026-05-20-background-flash-conflict-trial.md"
---

# Background Flash Outbox Gate

## Decision

For `agent/no1_background_flash_suppression`, every future outbox reply that claims to use `skills/background-flash-suppression/SKILL.md` should run:

```bash
scripts/background-flash-outbox-check.sh <new-outbox-reply>
scripts/docs-check.sh
```

The outbox checker should run before `scripts/docs-check.sh` so the branch proves the background-flash evidence shape directly, not only generic document hygiene.

## Weakness Addressed

The branch added a checker in `scripts/background-flash-outbox-check.sh`, but had not yet recorded a branch-local acceptance rule for using it. Without this decision, a future run could still produce a background-flash report with mixed or missing evidence headings and rely only on `scripts/docs-check.sh`, which does not validate the suppression workflow.

The last two outbox reports show the gap clearly:

- `mailbox/outbox/2026-05-20-background-flash-suppression-delivery.md` was useful as a first skill delivery, but it mixed heading labels from multiple requests and fails the stricter checker.
- `mailbox/outbox/2026-05-20-background-flash-conflict-trial.md` used the exact skill headings and passes the checker.

## Acceptance Criteria

A future supervisor can rerun these probes:

```bash
scripts/background-flash-outbox-check.sh mailbox/outbox/2026-05-20-background-flash-suppression-delivery.md
```

Expected result: exit `1`, with missing exact headings for `Candidate Flashes`, `Suppressed Candidates`, `Chosen Delivery`, and `Evaluation Evidence`.

```bash
scripts/background-flash-outbox-check.sh mailbox/outbox/2026-05-20-background-flash-conflict-trial.md
```

Expected result: exit `0` with `background-flash-outbox-check: ok`.

```bash
scripts/background-flash-outbox-check.sh <new-background-flash-outbox-reply>
```

Expected result: exit `0` for each future background-flash reply.

```bash
scripts/query-docs.sh memory background-flash-outbox-gate
scripts/docs-check.sh
```

Expected result: the query discovers this decision, and the documentation check passes.

## Return-To-Main Judgment

This decision is not a return-to-main candidate. It is branch-local operating memory for no1. The underlying skill and checker may become candidates only after another independent run shows the heading gate remains useful without creating process noise.
