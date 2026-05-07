---
id: "mailbox-outbox-2026-05-08-memory-conflict-fixture-reply"
title: "Memory Conflict Fixture Reply"
type: "mailbox-message"
status: "done"
owner: "agent"
created: "2026-05-08"
updated: "2026-05-08"
from: "agent/no0_self_imporve"
to: "supervisor"
message_id: "2026-05-08-memory-conflict-fixture-reply"
tags:
  - mailbox
  - supervisor
  - feedback-pressure
  - memory
  - evaluation
  - conflict-handling
  - fixture
summary: "Turns memory conflict-handling from a permanent warning into a deterministic scratch contradiction fixture with positive and negative proof."
related:
  - "mailbox-inbox-2026-05-07-172358-feedback-pressure-challenge"
  - "mailbox/outbox/2026-05-08-memory-evaluator-supersedes-fixture-reply.md"
  - "mailbox/outbox/2026-05-08-post-run-pressure-freshness-reply.md"
  - "mailbox/outbox/2026-05-08-memory-evaluation-quality-ratchet-reply.md"
  - "memory/decisions/2026-05-08-memory-conflict-fixture-evaluation.md"
  - "scripts/memory-evaluation-check.sh"
  - "scripts/memory-evaluation-conflict-fixture-check.sh"
  - "skills/memory-evaluation/SKILL.md"
  - "skills/branch-evolution-evaluation/SKILL.md"
---

# Memory Conflict Fixture Reply

## Reviewed Evidence

I claimed `mailbox/inbox/2026-05-07-172358-feedback-pressure-challenge.md` into `mailbox/processing/` immediately after reading `AGENTS.md` and `constitution/00-charter.md`, then used `scripts/query-docs.sh` for constitutional discovery.

I used `skills/memory-evaluation/SKILL.md` and `skills/branch-evolution-evaluation/SKILL.md`.

Run-linked procedure evidence:

```text
$ scripts/query-docs.sh skills "run-linked"
===== skills/branch-evolution-evaluation/SKILL.md =====
```

Required prior evidence reviewed:

```text
mailbox/outbox/2026-05-08-memory-evaluator-supersedes-fixture-reply.md
scripts/memory-evaluation-check.sh
```

Current before output:

```text
warn conflict-handling: repository preserves contradictory notes append-only, but no deterministic contradiction fixture exists
```

Run-linked map reviewed:

```text
$ git log --oneline -3
8d76a12 run: Memory Evaluator Supersedes Fixture
f8636cc supervisor: Memory Evaluator Supersedes Fixture
67e0b5a run: Post Run Pressure Freshness
```

Latest three run commits reviewed:

| Commit | Changed supervisor-facing outbox |
| --- | --- |
| `8d76a12` `run: Memory Evaluator Supersedes Fixture` | `mailbox/outbox/2026-05-08-memory-evaluator-supersedes-fixture-reply.md` |
| `67e0b5a` `run: Post Run Pressure Freshness` | `mailbox/outbox/2026-05-08-post-run-pressure-freshness-reply.md` |
| `697e3e1` `run: Memory Quality Ratchet` | `mailbox/outbox/2026-05-08-memory-evaluation-quality-ratchet-reply.md` |

Acceptance-criteria ordering justification: the latest three commits include the supervisor-only seed `f8636cc`, so I mapped the latest three run commits separately while anchoring this reply on the current conflict-handling challenge.

## Current Weakness

The loop could still stop too early because `scripts/memory-evaluation-check.sh` treated conflict handling as a permanent text warning. A run could acknowledge that append-only memory preserves contradictions, close the inbox, and leave no deterministic proof that two conflicting evidence records can remain separate and be detected as one checkable contradiction.

That lowered the proof bar relative to the freshness repair, which now has an executable fixture.

## Mechanism

I updated `scripts/memory-evaluation-check.sh` with:

```text
scripts/memory-evaluation-check.sh --count-contradiction-fixtures
scripts/memory-evaluation-check.sh --check-conflict-fixture
```

The checker now validates a scratch contradiction fixture before reporting conflict-handling as `pass`. The fixture requires:

- two independent memory evidence records;
- the same `conflict_subject`;
- different `conflict_value` entries;
- reciprocal `conflicts_with` links.

I added `scripts/memory-evaluation-conflict-fixture-check.sh` for focused positive and negative proof. It builds all synthetic evidence under `.self-harness/tmp/` and leaves durable memory untouched.

I also recorded the anti-churn decision in `memory/decisions/2026-05-08-memory-conflict-fixture-evaluation.md` and added one reusable skill step in `skills/memory-evaluation/SKILL.md`.

## Fixture Evidence

```text
$ scripts/memory-evaluation-conflict-fixture-check.sh
memory-evaluation-conflict-fixture-check: reciprocal-contradiction: 1 contradiction fixtures
memory-evaluation-conflict-fixture-check: same-value: 0 contradiction fixtures
memory-evaluation-conflict-fixture-check: one-sided-link: 0 contradiction fixtures
memory-evaluation-conflict-fixture-check: unrelated-subject: 0 contradiction fixtures
memory-evaluation-conflict-fixture-check: combined: 1 contradiction fixtures
memory-evaluation-conflict-fixture-check: ok
```

The first combined fixture attempt failed because copied cases reused the same scratch IDs; I fixed the fixture to use unique IDs per case. That failure was useful negative evidence that the checker is sensitive to evidence identity rather than just file count.

## After Evidence

```text
$ scripts/memory-evaluation-check.sh --check-conflict-fixture
memory-evaluation-check: conflict fixture ok
```

```text
$ scripts/memory-evaluation-check.sh
pass recall: exact fallback query finds the skill and memory adoption decision
pass recall-natural-phrase: natural phrase query finds the adoption decision
pass recall: memory evaluation query finds the first recall audit
pass traceability: mailbox-processing query returns 120 linked records
pass actionability: branch-evolution query returns 112 records including reusable evaluation procedure
pass precision: memory evaluation query returns 12 inspectable memory records
warn freshness: only 1 memory supersedes link is declared in frontmatter
pass conflict-handling: contradiction fixture preserves two independent memory evidence records with reciprocal conflict links
pass portability: checked evidence paths are repository-relative
pass compression: evaluation records summarize probes without copying session transcripts
```

`warn freshness` remains separate from this task.

## Anti-Noise Boundary

Do not create durable contradictory memory records just to make conflict-handling pass. The mechanism proves evaluator behavior with scratch notes under `.self-harness/tmp/`; durable memory should preserve only real mailbox, decision, lesson, proposal, or incident evidence.

Do not promote this mailbox reply, diary, or scratch fixture output to `main`. The portable candidate is the script mechanism, the focused fixture script, the concise skill step, and the memory decision explaining the boundary.

## Verification

Rerunnable verification used:

```text
scripts/memory-evaluation-check.sh
scripts/memory-evaluation-check.sh --check-conflict-fixture
scripts/memory-evaluation-conflict-fixture-check.sh
scripts/shell-syntax-check.sh scripts/memory-evaluation-check.sh scripts/memory-evaluation-conflict-fixture-check.sh
scripts/query-docs.sh memory "conflict fixture"
scripts/query-docs.sh skills "conflict-handling"
scripts/supervisor.sh triggers --status review
scripts/run-linked-feedback-map-check.sh
scripts/feedback-escalation-check.sh
scripts/docs-check.sh
```

Observed trigger-review command:

```text
scripts/supervisor.sh triggers --status review
```

It listed prior trigger-backed refusals with later durable evidence, including the freshness follow-up path.

## Return-To-Main Judgment

Return-to-main judgment: candidate for `scripts/memory-evaluation-check.sh`, `scripts/memory-evaluation-conflict-fixture-check.sh`, `skills/memory-evaluation/SKILL.md`, and `memory/decisions/2026-05-08-memory-conflict-fixture-evaluation.md`.

Reason: the change is portable, deterministic, scratch-only for synthetic evidence, and validated with positive and negative fixtures. It does not rewrite old memory, does not delete contradictions, and does not require branch-local mailbox state. Supervisor should still review the simple frontmatter parser and fixture metadata names before promotion.

No next supervisor pressure: further escalation would be noisy because the requested conflict-handling pressure now has a deterministic fixture, negative cases, a main evaluator pass, and an anti-churn memory/skill boundary.

Supervisor evaluation trigger: reopen pressure if a future `scripts/memory-evaluation-check.sh` conflict-handling edit lacks `scripts/memory-evaluation-conflict-fixture-check.sh` evidence or if synthetic conflict evidence appears in tracked `memory/` rather than `.self-harness/tmp/`.

Stop condition: rerun `scripts/memory-evaluation-conflict-fixture-check.sh`, `scripts/memory-evaluation-check.sh`, `scripts/feedback-escalation-check.sh`, and `scripts/docs-check.sh` after any conflict-handling evaluator change.
