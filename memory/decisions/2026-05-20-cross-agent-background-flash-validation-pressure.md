---
id: "memory-decision-2026-05-20-cross-agent-background-flash-validation-pressure"
title: "Cross-Agent Background Flash Validation Pressure"
type: "memory"
status: "active"
owner: "agent/no0_self_imporve"
created: "2026-05-20"
updated: "2026-05-20"
source: "mailbox-challenge"
confidence: "medium"
tags:
  - decision
  - no0
  - no1
  - feedback-pressure
  - background-flash
  - cross-agent-validation
summary: "Defines one branch-local pressure asking no1 to prove background-flash suppression on a non-mailbox task before any main-promotion review."
related:
  - "mailbox/done/2026-05-20-013834-feedback-pressure-challenge.md"
  - "mailbox/outbox/2026-05-20-no1-return-main-strict-review-reply.md"
  - "mailbox/outbox/2026-05-20-cross-agent-background-flash-validation-pressure-reply.md"
  - "agent/no1_background_flash_suppression"
---

# Cross-Agent Background Flash Validation Pressure

## Decision

No0 should treat no1's background-flash skill and checker as branch-local until no1 applies the workflow to a task outside mailbox processing, outbox report-shape repair, trigger review, or return-to-main review.

The next useful pressure is a non-mailbox task that asks no1 to choose exactly one small repository improvement from competing candidates, then prove that `skills/background-flash-suppression/SKILL.md` changed the selected delivery in substance.

## Weakness Addressed

The prior strict review could stop at "do not promote no1 yet" and accept no1's existing third-use pressure as sufficient. Later no1 evidence completed that mailbox/process-shaped selection-quality review, but the evidence still tested adjacent tasks: skill delivery, outbox heading enforcement, branch-local gate adoption, and return-review thresholding.

That proves disciplined report shape and conservative promotion judgment. It does not yet prove whether background-flash suppression improves choices on a different task type.

## Pressure Specification

The supervisor should seed no1 with one concrete task outside mailbox/process evaluation. A suitable challenge is:

```text
Use background-flash suppression on one non-mailbox repository improvement. Choose among at least four candidate flashes: one skill edit, one memory decision, one script/check idea, and one bounded refusal. The selected delivery must not be a mailbox lifecycle report, trigger-review triage, outbox format checker, or return-to-main review. Preserve the no-main-promotion default.
```

Concrete example target:

```text
Ask no1 to inspect its current branch for one durable improvement to make background-flash suppression easier to use on future coding or documentation tasks, without changing constitution and without adding another report-shape checker.
```

## Acceptance Criteria

The resulting no1 outbox should provide:

- Reviewed evidence from `AGENTS.md`, relevant constitution docs, `skills/background-flash-suppression/SKILL.md`, and the current no1 branch state.
- A background goal for the non-mailbox task.
- At least four candidate flashes that include a skill edit, memory decision, script/check idea, and bounded refusal.
- Suppression reasons that name concrete risks avoided, not only missing headings.
- Exactly one selected delivery outside mailbox/process evaluation.
- Rerunnable evidence for the selected delivery, such as `python3 scripts/skill-quick-validate.py <skill-dir>`, `scripts/shell-syntax-check.sh <script>`, a focused fixture, `scripts/query-docs.sh memory <term>`, or `scripts/docs-check.sh`.
- An explicit no-main-promotion default unless the new evidence is cross-task, portable, validated, and free of known family-genome risk.
- A comparison against the previous mailbox/process evidence explaining whether the mechanism changed a substantive choice or only reproduced the same report shape.

## Rerunnable Supervisor Probe

After no1 commits the non-mailbox task, the supervisor can review with:

```bash
scripts/query-docs.sh mailbox background-flash
scripts/query-docs.sh memory selection-quality
scripts/docs-check.sh
```

Expected result: the query output includes the new no1 evidence, the memory query finds no1's selection-quality decision, and documentation checks pass. If the new no1 report claims return-to-main readiness, the default response should still be no until the report demonstrates cross-task selection quality rather than format compliance.

## Return-To-Main Judgment

Not a return-to-main candidate. This is no0 branch-local pressure memory for supervising a sibling branch. It is useful evidence for the supervisor, but it should not be promoted to `main` unless a later human review decides cross-agent validation-pressure memory belongs in the family genome.
