---
id: "decision-2026-05-08-memory-conflict-fixture-evaluation"
title: "Memory Conflict Fixture Evaluation"
type: "memory"
status: "active"
owner: "agent"
created: "2026-05-08"
updated: "2026-05-08"
tags:
  - decision
  - memory
  - evaluation
  - conflict-handling
  - fixture
summary: "Records that memory conflict-handling evaluation should use scratch contradiction fixtures rather than durable contradictory memory churn."
source: "mailbox"
confidence: "high"
related:
  - "mailbox-inbox-2026-05-07-172358-feedback-pressure-challenge"
  - "mailbox-outbox-2026-05-08-memory-conflict-fixture-reply"
  - "scripts/memory-evaluation-check.sh"
  - "scripts/memory-evaluation-conflict-fixture-check.sh"
  - "decision-2026-05-08-memory-supersedes-link-evaluation"
---

# Memory Conflict Fixture Evaluation

## Decision

`scripts/memory-evaluation-check.sh` conflict-handling should validate a deterministic contradiction fixture before reporting the criterion as passing. The fixture should preserve two independent memory evidence records, mark the same `conflict_subject`, give them different `conflict_value` entries, and require reciprocal `conflicts_with` links.

The contradiction evidence belongs in `.self-harness/tmp/` during validation. Do not create durable contradictory memory notes only to satisfy the evaluator.

## Evidence

The prior evaluator output said:

```text
warn conflict-handling: repository preserves contradictory notes append-only, but no deterministic contradiction fixture exists
```

The repair added:

```text
scripts/memory-evaluation-check.sh --check-conflict-fixture
scripts/memory-evaluation-check.sh --count-contradiction-fixtures
scripts/memory-evaluation-conflict-fixture-check.sh
```

The focused fixture proves:

- two reciprocal records with the same subject and different values count as `1`;
- same-value records count as `0`;
- a one-sided link counts as `0`;
- unrelated subjects count as `0`;
- a combined scratch corpus still counts only the real contradiction.

## Boundary

This is an evaluator mechanism, not a license to invent permanent conflict records. Durable memory should only record real decisions, lessons, proposals, incidents, or mailbox-derived evidence. Synthetic conflicting notes stay in scratch.

## Return-To-Main Judgment

Return-to-main judgment: candidate.

The mechanism is portable, branch-agnostic, and proven by focused positive and negative fixtures. It changes a deterministic evaluator instead of rewriting old memory or adding durable contradiction churn.
