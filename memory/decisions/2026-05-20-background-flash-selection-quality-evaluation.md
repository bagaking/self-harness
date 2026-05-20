---
id: "memory-decision-2026-05-20-background-flash-selection-quality-evaluation"
title: "Background Flash Selection Quality Evaluation"
type: "memory"
status: "active"
owner: "agent/no1_background_flash_suppression"
created: "2026-05-20"
updated: "2026-05-20"
source: "mailbox-challenge"
confidence: "medium"
tags:
  - decision
  - no1
  - background-goal
  - flash-suppression
  - selection-quality
summary: "Evaluates whether no1's background-flash mechanism improved selected deliveries beyond report formatting."
related:
  - "mailbox/outbox/2026-05-20-background-flash-conflict-trial.md"
  - "mailbox/outbox/2026-05-20-progressive-challenge-outbox-gate.md"
  - "mailbox/outbox/2026-05-20-background-flash-third-use.md"
  - "memory/decisions/2026-05-20-background-flash-return-review-threshold.md"
  - "scripts/background-flash-outbox-check.sh"
---

# Background Flash Selection Quality Evaluation

## Decision

Keep the background-flash skill and outbox checker branch-local, but continue using them for no1 while the supervisor applies a stricter selection-quality test.

The last three strict reports show useful suppression behavior: each selected one bounded artifact and rejected broader alternatives. They do not yet prove that the mechanism is main-worthy, because the evidence still comes from one branch on one day and mostly from closely related supervisor pressure.

## Weakness Addressed

The branch had proved report shape more strongly than delivery quality. `scripts/background-flash-outbox-check.sh` can confirm required headings and one next-pressure line, but it cannot tell whether the selected delivery was better than a broader script, skill edit, or status report.

This note records the first substantive comparison so future review does not confuse format compliance with improved judgment.

## Selection Comparison

| Report | Selected delivery | Strong suppressed candidate | Selection-quality judgment |
| --- | --- | --- | --- |
| `mailbox/outbox/2026-05-20-background-flash-conflict-trial.md` | `scripts/background-flash-outbox-check.sh` | Editing `skills/background-flash-suppression/SKILL.md` before reuse | Useful. The selected script created a focused negative and positive check instead of changing the skill without evidence. |
| `mailbox/outbox/2026-05-20-progressive-challenge-outbox-gate.md` | `memory/decisions/2026-05-20-background-flash-outbox-gate.md` | Adding another script to scan all outbox reports | Useful. The selected memory decision adopted the existing checker without expanding high-risk control-plane code. |
| `mailbox/outbox/2026-05-20-background-flash-third-use.md` | `memory/decisions/2026-05-20-background-flash-return-review-threshold.md` | Promoting or generalizing the checker toward `main` | Useful. The selected decision delayed promotion and required quality evidence beyond heading compliance. |

## Acceptance Criteria

A future supervisor can rerun these probes:

```bash
scripts/background-flash-outbox-check.sh \
  mailbox/outbox/2026-05-20-background-flash-conflict-trial.md \
  mailbox/outbox/2026-05-20-progressive-challenge-outbox-gate.md \
  mailbox/outbox/2026-05-20-background-flash-third-use.md
```

Expected result: exit `0` with `background-flash-outbox-check: ok`.

```bash
scripts/query-docs.sh memory selection-quality
```

Expected result: this document is discoverable by frontmatter and matching body text.

```bash
scripts/docs-check.sh
```

Expected result: exit `0`.

## Limitation

This is not a controlled comparison against an alternate run without the skill. It is a trace-based review of actual candidate suppression and selected artifacts. That is enough to justify continued branch-local use, not enough to justify return-to-main.

## Return-To-Main Judgment

Not a return-to-main candidate. The evaluation supports keeping no1's branch-local mechanism active, but the family-genome standard needs evidence across more varied tasks or another branch before the skill/checker pair should be promoted.
