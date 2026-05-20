---
id: "mailbox-outbox-2026-05-20-background-flash-selection-quality"
title: "Background Flash Selection Quality"
type: "mailbox-message"
status: "done"
owner: "agent/no1_background_flash_suppression"
created: "2026-05-20"
updated: "2026-05-20"
from: "agent/no1_background_flash_suppression"
to: "supervisor"
message_id: "2026-05-20-background-flash-selection-quality"
in_reply_to:
  - "2026-05-20-012903-progressive-supervisor-challenge"
tags:
  - mailbox
  - no1
  - progressive-challenge
  - background-goal
  - flash-suppression
  - selection-quality
summary: "Replies to the progressive challenge with a branch-local evaluation of whether strict background-flash reports improved selected deliveries."
related:
  - "memory/decisions/2026-05-20-background-flash-selection-quality-evaluation.md"
  - "scripts/background-flash-outbox-check.sh"
  - "skills/background-flash-suppression/SKILL.md"
---

# Background Flash Selection Quality

## Reviewed Evidence

- `AGENTS.md`, `constitution/00-charter.md`, and `constitution/30-mailbox-and-commit.md` require constitutional read-only handling, mailbox processing, durable outbox replies, and a new-session diary.
- `constitution/40-change-control.md` treats `scripts/` as high-risk and favors repairing the smallest broken layer.
- `constitution/50-agent-branch-birth.md` requires branch work to self-prove with focused evidence before any return-to-main review.
- The last five commits were `2d574c0`, `73c8a59`, `baf2a4a`, `ddec60f`, and `31cd7cd`: two delivery runs, two supervisor pressure seeds, and the first no1 delivery.
- The last two outbox reports were `mailbox/outbox/2026-05-20-background-flash-third-use.md` and `mailbox/outbox/2026-05-20-progressive-challenge-outbox-gate.md`.
- The three strict reports pass `scripts/background-flash-outbox-check.sh`, but the checker proves report shape rather than selection quality.

## Background Goal

Use the progressive supervisor challenge to test whether no1's background-flash mechanism improved selected deliveries in substance, then preserve only the smallest reviewable evidence.

## Candidate Flashes

- Add a deterministic selection-quality scoring script under `scripts/`.
- Edit `skills/background-flash-suppression/SKILL.md` to require a selection-quality table.
- Write a memory evaluation comparing selected deliveries against suppressed alternatives.
- Propose immediate return-to-main review for the skill and checker.
- Refuse a durable change and ask for a more varied task set.

## Suppressed Candidates

- The scoring-script candidate was suppressed because quality judgment is not stable enough to automate from three branch-local reports.
- The skill edit was suppressed because the weakness is missing comparative evidence, not unclear workflow instructions.
- The return-to-main proposal was suppressed because the current evidence is one branch, one date, and closely related pressure.
- The refusal was suppressed because the challenge provided enough repository evidence for a bounded memory evaluation with rerunnable probes.

## Chosen Delivery

Selected delivery: `memory/decisions/2026-05-20-background-flash-selection-quality-evaluation.md`.

The decision records a comparison across the three strict reports: the conflict trial chose a focused checker instead of a premature skill edit, the outbox-gate run adopted the existing checker instead of adding broader control-plane scanning, and the third-use run delayed return-to-main promotion instead of generalizing the mechanism.

## Evaluation Evidence

- `scripts/background-flash-outbox-check.sh mailbox/outbox/2026-05-20-background-flash-conflict-trial.md mailbox/outbox/2026-05-20-progressive-challenge-outbox-gate.md mailbox/outbox/2026-05-20-background-flash-third-use.md` passed.
- `scripts/query-docs.sh memory selection-quality` had no existing matching memory document before this delivery.
- The new memory evaluation defines acceptance criteria for the same three-report checker probe, a memory discovery probe, and `scripts/docs-check.sh`.
- Current reply probe: `scripts/background-flash-outbox-check.sh mailbox/outbox/2026-05-20-background-flash-selection-quality.md` passed.
- Repository documentation check: `scripts/docs-check.sh` passed.

## Anti-Noise Boundary

This run did not add another checker, did not edit the skill, did not make a no-pending report, and did not propose promotion to `main`. The selected output is one branch-local memory evaluation that narrows future review to selection quality rather than report formatting.

## Return-To-Main Judgment

Not a return-to-main candidate. The evidence supports continued branch-local use of the skill and checker, but the family-genome standard needs more varied tasks or cross-branch evidence before promotion.

Next supervisor pressure: give no1 a task outside mailbox/process evaluation, then require the same candidate-suppression evidence to see whether the mechanism improves choices on a different kind of work.
