---
id: "lesson-2026-05-06-memory-recall-and-skill-audit"
title: "Memory Recall And Skill Audit"
type: "memory"
status: "active"
owner: "agent"
created: "2026-05-06"
updated: "2026-05-06"
tags:
  - lesson
  - memory
  - recall
  - precision
  - skills
  - mailbox
  - self-evolution
summary: "Records a first real memory recall evaluation and the skill audit that led to the mailbox-processing skill."
source: "mailbox"
confidence: "high"
related:
  - "mailbox-inbox-2026-05-06-self-evolution-acceptance-followup"
  - "proposal-2026-05-05-memory-evolution-system"
  - "decision-2026-05-05-skill-and-memory-adoption-criteria"
  - "skill-mailbox-processing"
---

# Memory Recall And Skill Audit

## Focused Question

Can a future session recover the branch's current operating lessons with `scripts/query-docs.sh`, and which small skill would reduce repeated autonomous-run work?

## Skill Audit

Current repository-owned skills before this run:

- `skills/memory-evaluation/`: useful and already triggered by memory, recall, freshness, conflict, traceability, compression, and durable memory-writing tasks.

Highest-value missing reusable workflows:

- Mailbox processing: recurring autonomous runs must inspect inbox state, claim messages, preserve message identity, write outbox replies, move input to done or failed, and verify no processing files remain. This workflow has repeated across multiple diaries and is directly part of the supervisor boot prompt.
- Repository inspection: useful, but most steps are already covered by `AGENTS.md`, constitution discovery, and ordinary shell inspection. A separate skill would risk restating broad operating rules before enough repeated pain exists.
- Supervisor incident review: useful after failures, but the current evidence is one stale-resume incident and one unsupported dry-run incident, not enough for a stable reusable skill.

Adopted:

- Added `skills/mailbox-processing/` as a small workflow skill for mailbox runs.

Skipped:

- Did not add broad planning, debugging, CLI, or repository-inspection skills. They are currently too general and would duplicate existing system behavior or constitution text.
- Did not clone external agent frameworks. The acceptance follow-up did not require external inspection when the local repeated workflow was already visible, and network-dependent reference work would be less useful than a concrete repository-specific skill.

Deferred:

- A repository-inspection skill can be reconsidered after future sessions show a repeated checklist that is not already covered by `AGENTS.md` plus `scripts/query-docs.sh`.
- A supervisor-incident skill can be reconsidered after another incident produces a stable review pattern.

## Memory Probes

Probe 1: recover the skill adoption decision.

- Command: `scripts/query-docs.sh memory "skill adoption"`
- Result: no matching Markdown documents.
- Expected evidence existed in `memory/decisions/2026-05-05-skill-and-memory-adoption-criteria.md`.
- Evaluation: fail for recall with natural phrase search. The query helper treats the supplied words as one regex phrase, and the document used the title phrase `Skill And Memory Adoption Criteria`, not the adjacent lowercase phrase `skill adoption`.

Probe 2: recover the same decision with a more exact phrase.

- Command: `scripts/query-docs.sh memory "adoption criteria"`
- Result: one relevant hit, `memory/decisions/2026-05-05-skill-and-memory-adoption-criteria.md`.
- Evaluation: pass for precision and traceability, but only when the search phrase matches the document's wording.

Probe 3: recover the stale resume incident.

- Command: `scripts/query-docs.sh memory "stale resume"`
- Result: two relevant hits, `memory/diary/2026-05-06-supervisor-stale-resume-recovery.md` and `memory/incidents/2026-05-06-stale-resume-process.md`.
- Evaluation: pass for recall and precision. The incident is discoverable by likely task terms, and the result set is small.

Probe 4: recover the first self-description.

- Command: `scripts/query-docs.sh memory "dream"`
- Result: two relevant hits, `memory/birth/agent-no0-self-imporve.md` and `memory/diary/2026-05-05-first-autonomous-run.md`.
- Evaluation: pass for recall and precision. The birth note and first diary both identify the dream requirement and answer.

Probe 5: recover memory evaluation context.

- Command: `scripts/query-docs.sh memory "memory evaluation"`
- Result: no matching Markdown documents.
- Follow-up command: `scripts/query-docs.sh memory "memory-evaluation"`
- Result: relevant hits in the adoption decision, prior diaries, and `memory/proposals/2026-05-05-memory-evolution-system.md`.
- Evaluation: warn. Hyphenated ids are searchable, but natural phrase recall fails for a likely future query.

## Checklist Result

- Recall: warn. Exact phrase and hyphenated-id queries work; some natural multi-word queries fail.
- Precision: pass. Successful probes returned small, readable result sets.
- Freshness: warn. Current notes use `related`, but few notes use `supersedes`; no conflict was found in this evaluation.
- Conflict handling: warn. The repository preserves old notes, but there is no deterministic contradiction check.
- Actionability: pass. The evaluation produced `skills/mailbox-processing/` and a concrete query weakness.
- Portability: pass. This note uses repository-relative paths only.
- Traceability: pass. Each result points to a command and repository files.
- Compression: pass. The note records probe outcomes without copying transcripts.

## Deterministic Helper Decision

A small query helper or `scripts/query-docs.sh` enhancement may eventually be justified, but this run does not change `scripts/` because the intended search semantics need a human-visible decision first. Reasonable options include splitting multi-word queries into AND terms, adding an explicit `--and` mode, or documenting that quoted phrases are exact phrase searches.

Evidence still missing before scripting:

- At least one more real mailbox or memory task where natural multi-word recall failure changes the work outcome, not just a probe result.
- A decision about whether default multi-word queries should mean exact phrase, OR-style regex, or AND-style token matching.
- A small compatibility check showing that any changed query behavior still finds the constitution and memory documents expected by existing diaries and skills.

Changing the default behavior could alter existing discovery expectations, so the safer outcome for this run is to record the evidence and improve future document wording.
