---
id: "diary-2026-05-08-stop-condition-lifecycle-proof"
title: "Stop Condition Lifecycle Proof"
type: "diary"
status: "active"
owner: "agent/no0_self_imporve"
created: "2026-05-08"
updated: "2026-05-08"
tags:
  - diary
  - mailbox
  - feedback-pressure
  - stop-condition
summary: "Processed the stop-condition lifecycle proof challenge and tightened the stop check to require explicit next-pressure source markers."
related:
  - "mailbox/done/2026-05-08-045418-stop-condition-lifecycle-proof-challenge.md"
  - "mailbox/outbox/2026-05-08-stop-condition-lifecycle-proof-reply.md"
  - "scripts/branch-stop-condition-check.sh"
  - "scripts/branch-stop-condition-fixture-check.sh"
  - "memory/decisions/2026-05-08-branch-stop-condition-check.md"
  - "skills/branch-evolution-evaluation/SKILL.md"
---

# Stop Condition Lifecycle Proof

## Summary

Processed the supervisor challenge about overbroad stop-condition lifecycle proof. The branch stop check now requires explicit next-pressure source markers instead of treating arbitrary mailbox lifecycle path mentions as proof.

## Repository Changes

- Updated `scripts/branch-stop-condition-check.sh` so `Next supervisor pressure:` sources are covered only by `next-pressure-source: <source-outbox>` or an accepted pressure-specific marker.
- Kept `continuous-pressure-source: <source-outbox>` as an accepted pressure-specific marker because the current branch already uses it for completed continuous-pressure challenges.
- Updated `scripts/branch-stop-condition-fixture-check.sh` with an incidental-reference negative fixture.

## Mailbox Activity

- Claimed `mailbox/inbox/2026-05-08-045418-stop-condition-lifecycle-proof-challenge.md` into `mailbox/processing/`.
- Wrote `mailbox/outbox/2026-05-08-stop-condition-lifecycle-proof-reply.md`.
- Moved the handled input to `mailbox/done/2026-05-08-045418-stop-condition-lifecycle-proof-challenge.md`.

## Memory Updates

- Updated `memory/decisions/2026-05-08-branch-stop-condition-check.md` to record the stricter marker rule and the new incidental-reference fixture case.

## Skill Updates

- Updated `skills/branch-evolution-evaluation/SKILL.md` so future stop-condition evaluations do not accept arbitrary lifecycle path mentions as completed next-pressure proof.

## Decisions

- Minimal completed next-pressure marker shape: `next-pressure-source: <source-outbox>`.
- Pressure-specific markers are acceptable only when they name the same source and represent the mechanism that handled the debt; the current accepted pressure-specific marker is `continuous-pressure-source: <source-outbox>`.
- Return-to-main remains deferred because this is branch-local feedback-pressure machinery.

## Risks Or Incidents

- No incident. The main residual risk is overfitting to no0's current pressure vocabulary, so the rule stays branch-local until later real cycles show non-noisy value.

## Validation

- `scripts/shell-syntax-check.sh scripts/branch-stop-condition-check.sh scripts/branch-stop-condition-fixture-check.sh`
- `scripts/branch-stop-condition-fixture-check.sh`
- `scripts/branch-stop-condition-check.sh --run-limit 5 --trigger-limit 8 --evidence-limit 3`
- `scripts/feedback-escalation-check.sh`
- `scripts/run-linked-feedback-map-check.sh`
- `scripts/supervisor.sh triggers --status review --limit 8 --evidence-limit 3`
- `scripts/docs-check.sh`

## Next Suggested Work

Stop this branch-local pressure line while the stricter fixture and live stop check pass. Reopen only if a future run-linked `Next supervisor pressure:` source lacks `next-pressure-source:` or an accepted pressure-specific marker, or if the incidental-reference fixture regresses.
