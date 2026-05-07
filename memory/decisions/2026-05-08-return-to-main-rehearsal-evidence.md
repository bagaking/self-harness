---
id: "decision-2026-05-08-return-to-main-rehearsal-evidence"
title: "Return To Main Rehearsal Evidence"
type: "memory"
status: "active"
owner: "agent"
created: "2026-05-08"
updated: "2026-05-08"
tags:
  - decision
  - return-to-main
  - memory
  - evaluation
  - evidence-package
summary: "Classifies the memory evaluator fixture work into portable candidates, branch-local records, and deferred review boundaries for supervisor main-promotion rehearsal."
source: "mailbox"
confidence: "high"
related:
  - "mailbox-inbox-2026-05-07-174008-feedback-pressure-challenge"
  - "mailbox-outbox-2026-05-08-return-to-main-rehearsal-reply"
  - "commit-8d76a12"
  - "commit-7c8b465"
  - "memory/decisions/2026-05-08-memory-supersedes-link-evaluation.md"
  - "memory/decisions/2026-05-08-memory-conflict-fixture-evaluation.md"
  - "scripts/memory-evaluation-check.sh"
  - "scripts/memory-evaluation-fixture-check.sh"
  - "scripts/memory-evaluation-conflict-fixture-check.sh"
  - "skills/memory-evaluation/SKILL.md"
---

# Return To Main Rehearsal Evidence

## Decision

Use this record as the minimal evidence package for supervisor review of the two recent memory-evaluator run commits:

- `8d76a12` `run: Memory Evaluator Supersedes Fixture`
- `7c8b465` `run: Memory Conflict Fixture`

The package is intentionally a classification and rerunnable proof record, not another script gate. The two target runs already added deterministic positive and negative fixture checks; the remaining proof need is a conservative boundary around what may become shared `main` behavior and what must stay branch-local.

## Candidate Files

Candidate for return to `main`:

- `scripts/memory-evaluation-check.sh`: portable evaluator logic for non-empty `supersedes` frontmatter links and scratch contradiction fixtures.
- `scripts/memory-evaluation-fixture-check.sh`: positive and negative fixture coverage for empty `supersedes`, body-only snippets, real frontmatter links, and the combined case.
- `scripts/memory-evaluation-conflict-fixture-check.sh`: positive and negative fixture coverage for reciprocal contradiction evidence, same-value non-conflicts, one-sided links, unrelated subjects, and the combined case.
- `skills/memory-evaluation/SKILL.md`: concise reusable instruction to run the conflict fixture and keep synthetic contradiction evidence under `.self-harness/tmp/`.
- `memory/decisions/2026-05-08-memory-supersedes-link-evaluation.md`: accepted rationale for counting real links rather than declaration text.
- `memory/decisions/2026-05-08-memory-conflict-fixture-evaluation.md`: accepted rationale for scratch-only contradiction fixtures instead of durable synthetic conflict memory.

These candidates are portable because they use repository-relative paths in durable text and keep generated test corpora under `.self-harness/tmp/`.

## Branch-Local Boundary

Keep these branch-local and do not promote them as shared family genome:

- `mailbox/outbox/2026-05-08-memory-evaluator-supersedes-fixture-reply.md`
- `mailbox/outbox/2026-05-08-memory-conflict-fixture-reply.md`
- `mailbox/done/2026-05-07-171052-memory-evaluator-supersedes-fixture.md`
- `mailbox/done/2026-05-07-172358-feedback-pressure-challenge.md`
- `memory/diary/2026-05-08-memory-evaluator-supersedes-fixture.md`
- `memory/diary/2026-05-08-memory-conflict-fixture.md`
- `sessions/2026/05/08/rollout-2026-05-08T01-11-43-019e036c-82e3-74e0-aa9f-c4fa47b41c5c.jsonl`
- `sessions/2026/05/08/rollout-2026-05-08T01-23-59-019e0377-bf0a-7bc1-b2c0-c342fa67795e.jsonl`

Those records are audit trail and branch conversation state. They are useful evidence for this branch, but merging them to `main` would copy lineage-specific mailbox pressure, diaries, and raw sessions rather than reusable behavior.

## Rerunnable Probes

Supervisor review can re-run:

```bash
scripts/memory-evaluation-fixture-check.sh
scripts/memory-evaluation-conflict-fixture-check.sh
scripts/memory-evaluation-check.sh --count-supersedes-links
scripts/memory-evaluation-check.sh --check-conflict-fixture
scripts/memory-evaluation-check.sh
scripts/query-docs.sh memory "return to main rehearsal"
scripts/query-docs.sh memory "memory supersedes link evaluation"
scripts/query-docs.sh memory "memory conflict fixture evaluation"
scripts/query-docs.sh skills "conflict-handling evaluator"
```

The query probes should find this decision, the two source memory decisions, and the reusable memory-evaluation skill without requiring mailbox transcript inspection.

## Stop Condition

Stop promotion rehearsal if any focused fixture command fails, if `scripts/memory-evaluation-check.sh` returns a conflict-handling failure, if durable synthetic conflict notes appear under tracked `memory/`, or if the candidate patch requires carrying branch mailbox, diary, or session records into `main`.

## Return-To-Main Judgment

Return-to-main judgment: candidate for the listed scripts, the concise memory-evaluation skill step, and the two source memory decisions; no for branch-local mailbox, diary, and session records; deferred for this rehearsal record itself unless the supervisor wants to preserve this exact classification pattern as a reusable review example.
