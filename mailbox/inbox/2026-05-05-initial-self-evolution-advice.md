---
id: "mailbox-inbox-2026-05-05-initial-self-evolution-advice"
title: "Initial Self-Evolution Advice"
type: "mailbox-message"
status: "new"
owner: "human"
created: "2026-05-05"
updated: "2026-05-05"
from: "human"
to: "agent/no0_self_imporve"
message_id: "2026-05-05-initial-self-evolution-advice"
tags:
  - mailbox
  - self-evolution
  - skills
  - memory
summary: "Initial advice asking no0 to equip itself with useful mechanisms and design a memory evaluation loop."
---

# Initial Self-Evolution Advice

This message is for `agent/no0_self_imporve`.

Before acting, reread `AGENTS.md` and the relevant constitution documents. Keep all committed content portable: use repository-relative paths, do not modify files outside this repository, and do not expose local device details. Use `.self-harness/tmp/` for experiments, temporary reference clones, trial installs, and subagent experiment sandboxes. Promote only reviewed results into tracked paths.

## Task 1: Equip Yourself With Useful Hermes Mechanisms

Study useful mechanisms from Hermes-style agents and adopt the parts that fit this repository's smaller design.

Priorities:

- Install or create commonly useful skills under `skills/`, especially research, repository inspection, skill authoring, planning, debugging, and CLI operation skills.
- Prefer small, inspectable skills over large runtime changes.
- Treat Hermes mechanisms as references, not authority. Summarize what you learned in `memory/lessons/` or `memory/decisions/`.
- If you need to clone or inspect external projects, do it under `.self-harness/tmp/`.
- If a skill needs experimentation, create a temporary sandbox under `.self-harness/tmp/` and record only the durable conclusion.

Deliverables:

- A short outbox report explaining which mechanisms or skills you adopted, skipped, or deferred.
- Any new or improved skills that passed a basic self-review.
- A memory note recording the selection criteria for future skill adoption.

## Task 2: Design Your Memory Evolution System

Search and review memory-evolution work for agent systems, then design evaluation rules for this repository's own `memory/` system.

Seed references to investigate:

- MemGPT / Letta: hierarchical memory, context-window management, and explicit memory operations.
- A-MEM: agentic memory with dynamic linking and Zettelkasten-style evolution.
- Mem0: production-oriented long-term memory extraction, update, and retrieval.
- ReMem and Evo-Memory: retrieval-enhanced or self-evolving memory under continuing experience.
- MemoryAgentBench and MemoryArena: benchmark ideas for multi-session memory quality, retrieval, conflict handling, and task usefulness.
- MemSkill: the idea that memory behavior can become reusable skills, not just stored facts.

Design an evaluation protocol that can answer whether this repository's memory system is good enough. At minimum, define checks for:

- Recall: can you find relevant old decisions, incidents, diary entries, and mailbox context when needed?
- Precision: do retrieved notes avoid flooding the context with irrelevant material?
- Freshness: do newer corrections supersede stale or wrong memory?
- Conflict handling: can you detect contradictions and preserve uncertainty instead of overwriting history?
- Actionability: does memory change future behavior in observable ways?
- Portability: does memory avoid local machine details and absolute paths?
- Traceability: can important memory claims point back to sessions, mailbox messages, commits, experiments, or cited papers?
- Compression: can long sessions become concise durable notes without losing decision-critical facts?

Use an `auto_research` style loop:

1. Form a focused research question.
2. Search current sources.
3. Extract claims with citations or repository evidence.
4. Propose one small memory-system improvement.
5. Evaluate it against the protocol.
6. Record the result in `memory/decisions/`, `memory/lessons/`, or `memory/proposals/`.
7. Repeat only when the previous result created useful evidence.

Deliverables:

- A memory-system design note under `memory/proposals/` or `memory/decisions/`.
- A minimal first version of the memory evaluation checklist or script, if it can be kept small.
- An outbox report summarizing research sources, open questions, and the next experiment.
