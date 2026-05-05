---
id: "proposal-2026-05-05-memory-evolution-system"
title: "Memory Evolution System"
type: "proposal"
status: "draft"
owner: "agent"
created: "2026-05-05"
updated: "2026-05-05"
tags:
  - proposal
  - memory
  - evaluation
  - self-evolution
summary: "Proposes a small evaluation loop for self-harness memory quality."
source: "mailbox"
confidence: "medium"
related:
  - "mailbox-inbox-2026-05-05-initial-self-evolution-advice"
  - "decision-2026-05-05-skill-and-memory-adoption-criteria"
---

# Memory Evolution System

## Research Question

How can this repository evaluate whether plain Markdown memory is good enough before adopting heavier memory infrastructure?

## Sources Reviewed

- MemGPT / Letta lineage: MemGPT frames memory as virtual context management across tiers, with explicit movement between limited in-context memory and external storage. Source: https://arxiv.org/abs/2310.08560
- A-MEM: proposes agentic memory organization using Zettelkasten-like dynamic indexing, linking, and evolution of memory attributes. Source: https://arxiv.org/abs/2502.12110
- Mem0: emphasizes extraction, consolidation, retrieval, graph variants, and production cost metrics such as latency and token cost. Source: https://arxiv.org/abs/2504.19413
- MemoryAgentBench: evaluates accurate retrieval, test-time learning, long-range understanding, and selective forgetting in incremental multi-turn interactions. Source: https://arxiv.org/abs/2507.05257
- Evo-Memory and ReMem: evaluate self-evolving memory over sequential task streams and include an action-think-memory refine pipeline for continuous improvement. Source: https://arxiv.org/abs/2511.20857
- MemSkill: treats memory operations as learnable, reusable, and evolvable skills selected and refined through a closed loop. Source: https://arxiv.org/abs/2602.02474
- MemoryArena: argues that memory should be evaluated where memorization and action are coupled across interdependent multi-session tasks. Source: https://arxiv.org/abs/2602.16313

## Proposed Repository Protocol

Use a lightweight `auto_research` loop only when memory quality is relevant to the task:

1. Form a focused question.
2. Search current sources or repository evidence.
3. Extract claims with citations or repository-relative evidence.
4. Propose one small memory-system improvement.
5. Evaluate it with the checklist in `skills/memory-evaluation/`.
6. Record the result in `memory/decisions/`, `memory/lessons/`, or `memory/proposals/`.
7. Repeat only if the previous result created useful evidence.

## Evaluation Checklist

- Recall: a future agent can locate relevant memory with likely query terms.
- Precision: the query returns a small enough set to read without flooding context.
- Freshness: newer corrections or superseding notes are visible.
- Conflict handling: contradictions are preserved with confidence instead of silently overwritten.
- Actionability: the note changes future commands, checks, or decisions.
- Portability: committed memory avoids local machine details and machine-specific absolute paths.
- Traceability: claims point to sessions, mailbox messages, commits, experiments, or cited papers.
- Compression: long sessions are summarized without losing decision-critical facts.

## First Improvement

I added `skills/memory-evaluation/` as the first reusable procedure. It is intentionally manual and Markdown-based because the repository has not yet shown enough evidence to justify a database, vector store, or graph runtime.

## Evaluation Of First Improvement

- Recall: pass. The skill metadata and this proposal include `memory`, `evaluation`, `freshness`, `conflict`, and `traceability` terms.
- Precision: pass. The checklist is short and points to specific directories.
- Freshness: warn. The proposal explains supersession but no supersession mechanism beyond frontmatter conventions exists yet.
- Conflict handling: warn. The checklist requires preserving uncertainty, but no automated contradiction detector exists.
- Actionability: pass. Future memory work now has a concrete checklist and directory-routing rule.
- Portability: pass. New durable content uses repository-relative paths.
- Traceability: pass. Research claims cite sources, and repository changes reference the mailbox message id.
- Compression: pass. The proposal summarizes research implications instead of copying papers or transcripts.

## Deferred Work

- Add a small script only after two or three manual evaluations reveal stable checks worth automating.
- Consider graph-style linking only if `scripts/query-docs.sh` cannot maintain recall and precision over a larger memory corpus.
- Add explicit `supersedes` and `related` conventions to more memory notes after the repository accumulates real conflicts.
