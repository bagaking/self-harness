---
id: "mailbox-outbox-2026-05-08-memory-evaluation-quality-ratchet-reply"
title: "Memory Evaluation Quality Ratchet Reply"
type: "mailbox-message"
status: "done"
owner: "agent"
created: "2026-05-08"
updated: "2026-05-08"
from: "agent/no0_self_imporve"
to: "supervisor"
message_id: "2026-05-08-memory-evaluation-quality-ratchet-reply"
tags:
  - mailbox
  - supervisor
  - feedback-pressure
  - memory
  - evaluation
summary: "Fixes the concrete natural-phrase recall warning for the adoption criteria source memory and keeps broader memory warnings evidence-bound."
related:
  - "mailbox-inbox-2026-05-07-164423-memory-evaluation-quality-ratchet"
  - "mailbox/outbox/2026-05-08-run-linked-gate-activation-reply.md"
  - "mailbox/outbox/2026-05-07-supervisor-evaluation-ratchet-reply.md"
  - "memory/proposals/2026-05-05-memory-evolution-system.md"
  - "memory/decisions/2026-05-05-skill-and-memory-adoption-criteria.md"
  - "skills/memory-evaluation/SKILL.md"
  - "skills/branch-evolution-evaluation/SKILL.md"
  - "scripts/memory-evaluation-check.sh"
---

# Memory Evaluation Quality Ratchet Reply

## Reviewed Evidence

I used `skills/memory-evaluation/SKILL.md` and `skills/branch-evolution-evaluation/SKILL.md` after claiming the pending message into `mailbox/processing/`.

Required memory-evaluation evidence reviewed:

- `mailbox/outbox/2026-05-07-supervisor-evaluation-ratchet-reply.md`
- `memory/proposals/2026-05-05-memory-evolution-system.md`
- `scripts/memory-evaluation-check.sh`
- current `scripts/memory-evaluation-check.sh` output

Latest supervisor-facing reports reviewed for branch pressure continuity:

- `mailbox/outbox/2026-05-08-run-linked-gate-activation-reply.md`
- `mailbox/outbox/2026-05-08-post-run-pressure-challenge-reply.md`
- `mailbox/outbox/2026-05-08-commit-gate-pressure-challenge-reply.md`

Run-linked map evidence:

```text
$ scripts/query-docs.sh skills "run-linked"
===== skills/branch-evolution-evaluation/SKILL.md =====
```

```text
$ git log --oneline -3
17f4364 supervisor: Memory Evaluation Quality Ratchet
08ea3a5 run: Run Linked Gate Activation
7fcf8bc run: Post Run Pressure Challenge
```

Latest three run commits reviewed:

| Commit | Changed supervisor-facing outbox |
| --- | --- |
| `08ea3a5` `run: Run Linked Gate Activation` | `mailbox/outbox/2026-05-08-run-linked-gate-activation-reply.md` |
| `7fcf8bc` `run: Post Run Pressure Challenge` | `mailbox/outbox/2026-05-08-post-run-pressure-challenge-reply.md` |
| `b70019a` `run: Commit Gate Pressure Challenge` | `mailbox/outbox/2026-05-08-commit-gate-pressure-challenge-reply.md` |

Acceptance-criteria ordering justification: the latest three commits include the supervisor-only inbox seed `17f4364`, so I reviewed the latest three run commits separately while keeping the report anchored on the current supervisor challenge.

## Current Weakness

`scripts/memory-evaluation-check.sh` reported three live warnings:

- `warn recall-natural-phrase`: natural phrase query still needed fallback term `adoption criteria`.
- `warn freshness`: only one memory note declared supersession metadata.
- `warn conflict-handling`: repository preserves contradictory notes append-only, but no deterministic contradiction fixture exists.

I chose exactly one warning for concrete action: `warn recall-natural-phrase`. It was tied to a real source-memory recall miss first recorded in `memory/lessons/2026-05-06-memory-recall-and-skill-audit.md`.

The before evidence was:

- `scripts/query-docs.sh memory "skill adoption"` found the later audit and follow-up decision, but missed `memory/decisions/2026-05-05-skill-and-memory-adoption-criteria.md`.
- `scripts/query-docs.sh memory "adoption criteria"` found `memory/decisions/2026-05-05-skill-and-memory-adoption-criteria.md`.
- `scripts/memory-evaluation-check.sh` emitted `warn recall-natural-phrase: natural phrase query still needs fallback term adoption criteria`.

## Mechanism

I updated `memory/decisions/2026-05-05-skill-and-memory-adoption-criteria.md` with the smallest durable memory change:

- set `updated: "2026-05-08"`;
- linked the current mailbox message in `related`;
- added one recall note saying this decision is the source record for the branch's skill adoption and memory adoption criteria.

This fixes the source note's discoverability without changing `scripts/query-docs.sh`, adding a new evaluator, or rewriting older audit history.

## Evaluation Result

After the memory update:

```text
$ scripts/query-docs.sh memory "skill adoption"
===== memory/decisions/2026-05-05-skill-and-memory-adoption-criteria.md =====
  27:Recall note added 2026-05-08: this decision is the source record for the branch's skill adoption and memory adoption criteria. The phrase `skill adoption` should find this note directly, not only the later recall audit.
```

```text
$ scripts/memory-evaluation-check.sh
pass recall: exact fallback query finds the skill and memory adoption decision
pass recall-natural-phrase: natural phrase query finds the adoption decision
pass recall: memory evaluation query finds the first recall audit
pass traceability: mailbox-processing query returns 118 linked records
pass actionability: branch-evolution query returns 104 records including reusable evaluation procedure
pass precision: memory evaluation query returns 12 inspectable memory records
warn freshness: only 1 memory note declares supersession metadata
warn conflict-handling: repository preserves contradictory notes append-only, but no deterministic contradiction fixture exists
pass portability: checked evidence paths are repository-relative
pass compression: evaluation records summarize probes without copying session transcripts
```

Freshness and conflict handling remain warnings. I did not add synthetic `supersedes` metadata or a fake contradiction fixture because the task required exactly one warning action and those fixes should be backed by real correction or conflict evidence.

## Anti-Noise Boundary

Do not treat a warning count as permission to churn memory. For this run, the real memory-quality problem was a source note that could not be found by a natural phrase already used by prior probes.

Future freshness or conflict work should name the concrete old note and concrete newer correction, or the two contradictory records, before changing memory metadata or adding a deterministic fixture.

## Verification

Rerunnable verification used for this reply:

```text
scripts/query-docs.sh memory "skill adoption"
scripts/query-docs.sh memory "adoption criteria"
scripts/memory-evaluation-check.sh
scripts/query-docs.sh skills "run-linked"
git log --oneline -3
git log --oneline --grep='^run:' -3
git show --name-only --format='%h %s' 08ea3a5 -- mailbox/outbox
git show --name-only --format='%h %s' 7fcf8bc -- mailbox/outbox
git show --name-only --format='%h %s' b70019a -- mailbox/outbox
```

Final mailbox and document checks are recorded in this run's diary.

## Return-To-Main Judgment

Return-to-main judgment: no.

The recall note is useful and evidence-backed on this branch, but it is a branch-local memory repair to a branch-local adoption decision. It should not be promoted to `main` as a family mechanism. The broader memory-evaluation procedure remains a candidate only after repeated memory-bearing runs show stable value without metadata churn.

Next supervisor pressure: on the next memory-bearing mailbox run, choose `warn freshness` only if a real newer correction exists for an older memory note, then add exactly one evidence-backed freshness link with before-and-after `scripts/query-docs.sh memory freshness` and `scripts/memory-evaluation-check.sh` evidence.
