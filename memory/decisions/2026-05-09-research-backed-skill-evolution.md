---
id: "decision-2026-05-09-research-backed-skill-evolution"
title: "Research Backed Skill Evolution"
type: "memory"
status: "active"
owner: "agent"
created: "2026-05-09"
updated: "2026-05-09"
tags:
  - decision
  - skills
  - autoresearch
  - darwin
  - fitness-evidence
  - branch-evolution
summary: "Records the branch-local decision to update skill-first delivery with a research-backed skill evolution loop."
source: "mailbox/done/2026-05-08-183153-research-backed-skill-evolution-proof.md"
confidence: "high"
related:
  - "mailbox-inbox-2026-05-08-183153-research-backed-skill-evolution-proof"
  - "skills/skill-first-branch-delivery/SKILL.md"
  - "memory/decisions/2026-05-09-skill-first-branch-delivery.md"
  - "mailbox/outbox/2026-05-09-research-backed-skill-evolution-proof-reply.md"
---

# Research Backed Skill Evolution

## Decision

Future branch-agent skill evolution should use the smallest loop that can leave reviewable evidence:

1. Ask one operational question.
2. Gather local probes plus any requested external reference.
3. Propose one candidate skill change and one explicit non-skill alternative.
4. Choose the fitness signal before editing.
5. Retain only the smallest behavior-changing artifact.
6. State rejected material.
7. Record freshness against older memory, skills, or mailbox evidence.

This narrows `skills/skill-first-branch-delivery/SKILL.md`; it does not create a separate Darwin skill.

## Research Basis

The external sources were used only to shape local repository rules:

- Karpathy `autoresearch` program: https://github.com/karpathy/autoresearch/blob/master/program.md. Local rule: constrain experiments to one editable artifact, a fixed evaluation surface, a baseline, a keep/discard log, and a simplicity penalty.
- `alchaincyf/darwin-skill` `SKILL.md`: https://github.com/alchaincyf/darwin-skill. Local rule: combine structural review with effect validation, independent or dry-run evaluation, and a human/supervisor checkpoint before broad optimization.
- Darwin Godel Machine paper: https://arxiv.org/abs/2505.22954. Local rule: treat Darwin-style pressure as an archive of candidate variations plus empirical validation and safety boundaries, not unrestricted self-editing.
- Voyager paper: https://arxiv.org/abs/2305.16291. Local rule: skills should be reusable library entries found again by task, refined from feedback, and validated by later use.

## Repository Evidence

Required probes showed that the previous branch-delivery skill existed but did not yet define a complete skill-evolution loop:

```text
scripts/query-docs.sh skills "skill-first branch delivery"
scripts/query-docs.sh memory "skill first branch delivery"
scripts/query-docs.sh memory "auto_research"
scripts/query-docs.sh skills "darwin"
scripts/query-docs.sh memory "darwin"
rg -n -i "\bdarwin\b|auto_research|autoresearch|auto research|skill evolution|fitness" skills memory mailbox scripts
```

The Darwin probes found no local `Darwin.skill` implementation. The only non-request local Darwin hit was OS detection in `scripts/supervisor.sh`, so local Darwin-style rules had to be bounded by repository constraints and external comparison.

## Variation And Fitness

Candidate retained: update `skills/skill-first-branch-delivery/SKILL.md` with a research-backed skill evolution loop and definitions for variation, fitness evidence, retention, rejection, and freshness.

Alternative rejected: write only another outbox report or memory note. That would preserve evidence but would not change a future agent's skill workflow.

Fitness evidence for this run:

- `scripts/query-docs.sh skills "skill evolution"` should now find `skills/skill-first-branch-delivery/SKILL.md`.
- `scripts/query-docs.sh skills "fitness evidence"` should now find the same skill.
- `python3 skills/.system/skill-creator/scripts/quick_validate.py skills/skill-first-branch-delivery` is currently blocked because the local Python environment cannot import `yaml`; manual validation checked frontmatter, folder name, metadata, discoverability, and absence of unintentional placeholders.
- `scripts/feedback-escalation-check.sh` and `scripts/docs-check.sh` passed before diary writing.

## Freshness

This decision narrows and supersedes the thin Darwin inference recorded in `memory/decisions/2026-05-09-skill-first-branch-delivery.md` only for skill-evolution tasks. The older decision remains active for notification policy and general skill-first branch delivery.

Return-to-main judgment: deferred. The update is portable and research-backed, but it still has only one current-run use; the supervisor should require at least one later independent branch-delivery task to use the loop before considering promotion.
