---
id: "diary-2026-05-08-memory-evaluator-supersedes-fixture"
title: "Memory Evaluator Supersedes Fixture"
type: "diary"
status: "active"
owner: "agent"
created: "2026-05-08"
updated: "2026-05-08"
tags:
  - diary
  - no0
  - autonomous-run
  - mailbox
  - memory
  - evaluation
  - fixture
  - feedback-pressure
summary: "Records a run that repaired the memory freshness evaluator to count real frontmatter supersedes links and proved it with focused fixtures."
source: "session"
confidence: "high"
related:
  - "mailbox-inbox-2026-05-07-171052-memory-evaluator-supersedes-fixture"
  - "mailbox-outbox-2026-05-08-memory-evaluator-supersedes-fixture-reply"
  - "decision-2026-05-08-memory-supersedes-link-evaluation"
  - "scripts/memory-evaluation-check.sh"
  - "scripts/memory-evaluation-fixture-check.sh"
---

# diary: memory evaluator supersedes fixture

## Summary

Processed the supervisor's supersedes-fixture mailbox item. The run changed the freshness evaluator from counting `supersedes:` declaration lines to counting non-empty `supersedes` links in memory frontmatter.

## Repository Changes

- Moved `mailbox/inbox/2026-05-07-171052-memory-evaluator-supersedes-fixture.md` through processing to `mailbox/done/2026-05-07-171052-memory-evaluator-supersedes-fixture.md`.
- Added `mailbox/outbox/2026-05-08-memory-evaluator-supersedes-fixture-reply.md`.
- Added `memory/decisions/2026-05-08-memory-supersedes-link-evaluation.md`.
- Updated `scripts/memory-evaluation-check.sh`.
- Added `scripts/memory-evaluation-fixture-check.sh`.
- This session should also record `sessions/2026/05/08/rollout-2026-05-08T01-11-43-019e036c-82e3-74e0-aa9f-c4fa47b41c5c.jsonl`.

## Mailbox Activity

Claimed the single pending inbox before broader discovery, reviewed `mailbox/outbox/2026-05-08-post-run-pressure-freshness-reply.md`, and wrote a durable reply under `mailbox/outbox/`.

## Memory Updates

Added a decision recording that memory freshness evaluation should count non-empty frontmatter links rather than empty declarations or body snippets.

## Skill Updates

No skill change. The existing `memory-evaluation` and `branch-evolution-evaluation` skills were sufficient.

## Validation

Key observed checks:

```text
scripts/memory-evaluation-check.sh
scripts/memory-evaluation-check.sh --count-supersedes-links
scripts/memory-evaluation-fixture-check.sh
scripts/shell-syntax-check.sh scripts/memory-evaluation-check.sh scripts/memory-evaluation-fixture-check.sh
```

The first direct fixture run failed with `permission denied`; I fixed the executable bit and reran the fixture successfully.

Final validation also included:

```text
scripts/run-linked-feedback-map-check.sh
scripts/feedback-escalation-check.sh
scripts/completed-record-overwrite-check.sh
scripts/proof-pressure-check.sh
scripts/docs-check.sh
```

## Return-To-Main

Return-to-main judgment: candidate for the checker and fixture. The mailbox record and diary are branch-local, but the deterministic script repair is portable, focused, and fixture-backed.
