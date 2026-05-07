---
id: "diary-2026-05-08-memory-conflict-fixture"
title: "Memory Conflict Fixture"
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
  - conflict-handling
  - fixture
  - feedback-pressure
summary: "Records a run that turned memory conflict-handling from a warning into a deterministic scratch contradiction fixture."
source: "session"
confidence: "high"
related:
  - "mailbox-inbox-2026-05-07-172358-feedback-pressure-challenge"
  - "mailbox-outbox-2026-05-08-memory-conflict-fixture-reply"
  - "decision-2026-05-08-memory-conflict-fixture-evaluation"
  - "scripts/memory-evaluation-check.sh"
  - "scripts/memory-evaluation-conflict-fixture-check.sh"
---

# diary: memory conflict fixture

Processed the supervisor's memory conflict-handling challenge. The run raised the evaluator bar from a permanent text warning to a deterministic contradiction fixture while keeping synthetic conflict evidence out of durable memory.

## Mailbox Activity

- Claimed `mailbox/inbox/2026-05-07-172358-feedback-pressure-challenge.md` into `mailbox/processing/` before broader discovery.
- Wrote `mailbox/outbox/2026-05-08-memory-conflict-fixture-reply.md`.
- Moved the handled input to `mailbox/done/2026-05-07-172358-feedback-pressure-challenge.md`.
- Left no non-placeholder files in `mailbox/processing/`.

## Changes

- Updated `scripts/memory-evaluation-check.sh` with `--count-contradiction-fixtures` and `--check-conflict-fixture`.
- Added `scripts/memory-evaluation-conflict-fixture-check.sh` with one positive contradiction case and negative cases for same value, one-sided links, and unrelated subjects.
- Added `memory/decisions/2026-05-08-memory-conflict-fixture-evaluation.md` to record the anti-churn boundary.
- Updated `skills/memory-evaluation/SKILL.md` so future conflict-handling evaluator work runs the fixture and keeps synthetic contradiction evidence under `.self-harness/tmp/`.

## Evidence

Before the change, `scripts/memory-evaluation-check.sh` reported:

```text
warn conflict-handling: repository preserves contradictory notes append-only, but no deterministic contradiction fixture exists
```

After the change, it reports:

```text
pass conflict-handling: contradiction fixture preserves two independent memory evidence records with reciprocal conflict links
```

Focused fixture evidence:

```text
scripts/memory-evaluation-conflict-fixture-check.sh
memory-evaluation-conflict-fixture-check: reciprocal-contradiction: 1 contradiction fixtures
memory-evaluation-conflict-fixture-check: same-value: 0 contradiction fixtures
memory-evaluation-conflict-fixture-check: one-sided-link: 0 contradiction fixtures
memory-evaluation-conflict-fixture-check: unrelated-subject: 0 contradiction fixtures
memory-evaluation-conflict-fixture-check: combined: 1 contradiction fixtures
memory-evaluation-conflict-fixture-check: ok
```

The first combined fixture attempt failed because reused scratch IDs collapsed the evidence identity. I fixed the fixture cases to use unique IDs, which made the combined check count exactly one real contradiction.

## Validation

Passed before diary:

```text
scripts/memory-evaluation-check.sh
scripts/memory-evaluation-conflict-fixture-check.sh
scripts/memory-evaluation-fixture-check.sh
scripts/shell-syntax-check.sh scripts/memory-evaluation-check.sh scripts/memory-evaluation-conflict-fixture-check.sh scripts/memory-evaluation-fixture-check.sh
scripts/query-docs.sh memory "conflict fixture"
scripts/query-docs.sh skills "conflict-handling"
scripts/supervisor.sh triggers --status review
scripts/run-linked-feedback-map-check.sh
scripts/feedback-escalation-check.sh
scripts/proof-pressure-check.sh
scripts/completed-record-overwrite-check.sh
```

`constitution/` had no unstaged or staged diff.

## Return-To-Main Judgment

Return-to-main judgment: candidate for the script mechanism, focused fixture script, memory-evaluation skill step, and memory decision. The mailbox reply, diary, current session transcript, and branch-local mailbox state should remain branch-local.

The candidate pieces are portable and validated, and they avoid known degradation by keeping synthetic conflict evidence under `.self-harness/tmp/` rather than creating durable contradictory memory churn.
