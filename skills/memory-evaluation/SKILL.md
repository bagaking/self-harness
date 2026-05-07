---
name: memory-evaluation
description: Use when evaluating, evolving, or writing durable agent memory in this repository, especially for mailbox requests about memory quality, recall, freshness, conflict handling, traceability, compression, or deciding whether a lesson belongs in memory or a reusable skill.
---

# Memory Evaluation

## Purpose

Use this skill to keep `memory/` useful under repeated sessions. It turns long interaction traces into small, portable, evidence-backed notes and checks whether memory is helping future behavior.

## Workflow

1. State the focused memory question in one sentence.
2. Retrieve evidence with `scripts/query-docs.sh memory <topic>` and, when needed, `scripts/query-docs.sh mailbox <topic>` or `scripts/query-docs.sh all <topic>`.
3. When the task asks for a concrete memory-system evaluation, run `scripts/memory-evaluation-check.sh` after reading context. Treat `warn` scores as judgment pressure, not automatic permission to rewrite search or memory policy.
4. Read only the relevant full files. Treat old memory as evidence, not law.
5. Classify each candidate claim as decision, lesson, proposal, incident, diary context, or mailbox context.
6. Apply the checklist below with `pass`, `warn`, or `fail` notes.
7. Write or update the smallest durable artifact under the right directory:
   - `memory/decisions/` for accepted operating choices.
   - `memory/lessons/` for reusable observations.
   - `memory/proposals/` for unapproved design changes.
   - `memory/incidents/` for failures or degraded behavior.
   - `skills/` only when the procedure is reusable across future tasks.
8. Keep committed content portable: repository-relative paths only, no local usernames, hostnames, home directories, or machine-specific absolute paths.

## Evaluation Checklist

- Recall: can a future agent find the note with `scripts/query-docs.sh` using likely task terms?
- Precision: does the note avoid pulling unrelated context into future sessions?
- Freshness: does it say whether it supersedes, corrects, or depends on older memory?
- Conflict handling: does it preserve uncertainty instead of overwriting contradictory evidence?
- Actionability: does it change a future command, checklist, decision, or review gate?
- Portability: does it avoid local machine details and outside-repository paths?
- Traceability: does each important claim point to a session, mailbox message, commit, experiment, or cited source?
- Compression: does it preserve decision-critical facts without copying long transcripts?

## Memory Write Rules

- Prefer append-only notes or explicit supersession over rewriting history.
- Use YAML frontmatter required by `constitution/20-knowledge-system.md`.
- Include `source` and `confidence` for memory documents when practical.
- Use citations for web research and mark research-derived claims separately from repository evidence.
- If a note describes a repeated procedure, add or update a skill only after the procedure is concrete enough to reuse.
