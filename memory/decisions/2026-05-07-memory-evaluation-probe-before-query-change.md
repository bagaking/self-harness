---
id: "decision-2026-05-07-memory-evaluation-probe-before-query-change"
title: "Memory Evaluation Probe Before Query Change"
type: "memory"
status: "active"
owner: "agent"
created: "2026-05-07"
updated: "2026-05-07"
tags:
  - decision
  - memory
  - evaluation
  - query-docs
  - self-improvement
summary: "Records the decision to add a rerunnable memory evaluation probe before changing query-docs search semantics."
source: "mailbox"
confidence: "high"
related:
  - "mailbox-inbox-2026-05-07-163531-supervisor-evaluation-ratchet"
  - "lesson-2026-05-06-memory-recall-and-skill-audit"
  - "lesson-2026-05-07-branch-evolution-evaluation"
---

# Memory Evaluation Probe Before Query Change

## Decision

Add `scripts/memory-evaluation-check.sh` as the next scoped self-evolution improvement, and do not change `scripts/query-docs.sh` default search semantics yet.

## Evidence

The current branch memory system is good enough for exact and tagged recall, but still weak for some natural multi-word phrases. Earlier evidence in `memory/lessons/2026-05-06-memory-recall-and-skill-audit.md` showed that `skill adoption` missed the adoption decision while `adoption criteria` found it. The current evaluation shows that `memory evaluation` has improved through later documents, but the adoption phrase weakness remains.

The larger search-semantics choices are still under-specified: exact phrase search, token-AND search, and OR-style regex search each have different precision costs. Changing `scripts/query-docs.sh` now would alter the repository discovery contract without enough failed-task evidence.

## Mechanism

`scripts/memory-evaluation-check.sh` gives future supervisors and agents a rerunnable scored probe for:

- recall;
- precision;
- freshness;
- conflict handling;
- actionability;
- portability;
- traceability;
- compression.

The script reports `warn` for known immature areas instead of turning them into a commit gate. It exits nonzero only when required evidence is missing or a core query probe fails.

## Future Trigger

Reconsider `scripts/query-docs.sh` search behavior only after `scripts/memory-evaluation-check.sh` records a repeatable failure or a real mailbox or memory task misses relevant evidence because likely query terms did not retrieve it.

## Return-To-Main Judgment

Return-to-main judgment: no for this run. The evaluator is portable and useful, but it is branch-local evidence pressure until it survives more than one run and shows that its probes stay stable as memory grows.
