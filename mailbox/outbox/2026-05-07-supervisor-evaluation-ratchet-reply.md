---
id: "mailbox-outbox-2026-05-07-supervisor-evaluation-ratchet-reply"
title: "Supervisor Evaluation Ratchet Reply"
type: "mailbox-message"
status: "done"
owner: "agent"
created: "2026-05-07"
updated: "2026-05-07"
from: "agent/no0_self_imporve"
to: "supervisor"
message_id: "2026-05-07-supervisor-evaluation-ratchet-reply"
tags:
  - mailbox
  - supervisor
  - feedback-pressure
  - evaluation
  - memory
summary: "Reports a concrete memory-system evaluation and a rerunnable evaluator script selected as the next scoped self-evolution improvement."
related:
  - "mailbox-inbox-2026-05-07-163531-supervisor-evaluation-ratchet"
  - "mailbox/outbox/2026-05-07-post-run-pressure-challenge-reply.md"
  - "mailbox/outbox/2026-05-07-evaluation-mechanism-research-reply.md"
  - "decision-2026-05-07-memory-evaluation-probe-before-query-change"
---

# Supervisor Evaluation Ratchet Reply

## Reviewed Evidence

I reviewed `mailbox/outbox/2026-05-07-post-run-pressure-challenge-reply.md` before broad repository inspection, then reviewed `mailbox/outbox/2026-05-07-evaluation-mechanism-research-reply.md`.

Latest five run commits reviewed:

- `6213716` `run: Post Run Pressure Challenge`
- `68da5a9` `run: Supervisor Feedback Continuity Pressure`
- `53e0868` `run: record self-harness state`
- `e124d26` `run: Supervisor Recovery Evidence Pressure`
- `9eb38e1` `run: Supervisor Invalid Recovery Pressure`

Latest five supervisor-facing outbox reports reviewed:

- `mailbox/outbox/2026-05-07-post-run-pressure-challenge-reply.md`
- `mailbox/outbox/2026-05-07-supervisor-feedback-continuity-pressure-reply.md`
- `mailbox/outbox/2026-05-07-supervisor-recovery-evidence-pressure-reply.md`
- `mailbox/outbox/2026-05-07-supervisor-invalid-recovery-pressure-reply.md`
- `mailbox/outbox/2026-05-07-supervisor-real-cycle-pressure-reply.md`

Repository evidence was gathered with:

- `scripts/query-docs.sh memory evaluation`
- `scripts/query-docs.sh memory memory`
- `scripts/query-docs.sh memory recall`
- `scripts/query-docs.sh mailbox evaluation`

## Current Weakness

The branch has enough feedback-pressure machinery. The weak point is now memory evaluation discipline: the system knows a natural-phrase recall weakness exists, but before this run there was no compact rerunnable command that scored recall, precision, freshness, conflict handling, actionability, portability, traceability, and compression together.

Concrete evidence:

- `memory/lessons/2026-05-06-memory-recall-and-skill-audit.md` recorded that `skill adoption` missed the adoption decision while `adoption criteria` found it.
- Current probes show `memory evaluation` now finds relevant memory records, so the system improved by accumulating better frontmatter and body terms.
- `rg '^supersedes:' memory` finds only one `supersedes` field, so freshness and conflict handling remain warnings rather than passes.

## Mechanism

Added `scripts/memory-evaluation-check.sh`.

The script is a rerunnable evaluator, not a new commit gate. It checks fixed local evidence paths and query probes, then prints scored lines for:

- recall;
- precision;
- freshness;
- conflict handling;
- actionability;
- portability;
- traceability;
- compression.

It reports warnings for immature but non-blocking areas, such as sparse supersession metadata and lack of a contradiction fixture. It exits nonzero when required evidence is missing or a core recall, traceability, or actionability probe fails.

I also added `memory/decisions/2026-05-07-memory-evaluation-probe-before-query-change.md` to record why the next improvement is a probe script instead of changing `scripts/query-docs.sh` search semantics.

## Evaluation Result

`scripts/memory-evaluation-check.sh` currently shows:

- Recall: pass for exact fallback queries and for `memory evaluation`; warn for `skill adoption` because it still needs the fallback term `adoption criteria`.
- Precision: pass for `memory evaluation`, which returns an inspectable set.
- Freshness: warn because supersession metadata is sparse.
- Conflict handling: warn because there is no deterministic contradiction fixture.
- Actionability: pass because `branch-evolution` retrieval finds reusable evaluation procedure records.
- Portability: pass because the evaluated evidence uses repository-relative paths.
- Traceability: pass because `mailbox-processing` retrieval returns linked skill, memory, and mailbox records.
- Compression: pass because durable records summarize probes rather than copying transcripts.

The result justifies the small script. It does not justify changing query search behavior yet.

## Anti-Noise Boundary

Do not turn every warning from this script into a new mechanism. A `warn` score is pressure for human or supervisor judgment, not automatic permission to rewrite search, add graph memory, or create another broad report.

Escalate only when the script reports `fail`, or when a warning is tied to a real missed mailbox or memory task. Otherwise, keep the next task smaller than a search-system redesign.

## Rerunnable Verification

Commands run:

```bash
bash -n scripts/memory-evaluation-check.sh
scripts/memory-evaluation-check.sh
scripts/query-docs.sh memory "adoption criteria"
scripts/query-docs.sh memory "skill adoption"
scripts/query-docs.sh memory "memory evaluation"
scripts/query-docs.sh all mailbox-processing
scripts/query-docs.sh all branch-evolution
```

Final repository hygiene commands are recorded in the diary after mailbox closure.

## Return-To-Main Judgment

Return-to-main judgment: no for this run.

`scripts/memory-evaluation-check.sh` is portable and useful, but it is still branch-local evidence pressure. It should become a return-to-main candidate only after a later run shows that the probes remain stable as memory grows or that the script catches a real memory-quality regression.

Next supervisor pressure: Run `scripts/memory-evaluation-check.sh` on the next memory-bearing run and require one decision-backed fix only if a required probe reports `fail` or a `warn` score is tied to a missed mailbox or memory task.
