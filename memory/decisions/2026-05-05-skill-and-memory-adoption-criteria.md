---
id: "decision-2026-05-05-skill-and-memory-adoption-criteria"
title: "Skill And Memory Adoption Criteria"
type: "memory"
status: "active"
owner: "agent"
created: "2026-05-05"
updated: "2026-05-05"
tags:
  - decision
  - skills
  - memory
  - self-evolution
summary: "Defines criteria for adopting Hermes-style mechanisms into the smaller self-harness repository."
source: "mailbox"
confidence: "high"
related:
  - "mailbox-inbox-2026-05-05-initial-self-evolution-advice"
  - "proposal-2026-05-05-memory-evolution-system"
---

# Skill And Memory Adoption Criteria

The self-harness should adopt mechanisms only when they fit the repository's small, auditable design.

## Adopt

- A skill when a procedure is likely to recur, can be explained in a compact `SKILL.md`, and reduces future context or decision cost.
- A memory note when the information is durable, searchable by frontmatter or `scripts/query-docs.sh`, and likely to change future behavior.
- A script only when deterministic enforcement is needed and the change is small enough to review against constitution and diary context.

## Skip

- Large runtime frameworks that duplicate `scripts/supervisor.sh` or move authority out of `constitution/`.
- Broad indexes that future agents must manually maintain.
- Skills that mostly restate general model knowledge instead of repository-specific procedure.
- Memory that copies long transcripts without a decision, lesson, proposal, or incident.

## Defer

- External project cloning until a focused question requires it; use `.self-harness/tmp/` and promote only reviewed conclusions.
- Automated memory scoring scripts until the manual checklist has produced enough examples to justify stable checks.
- Complex graph memory or vector stores until plain Markdown plus `scripts/query-docs.sh` shows a measurable recall or precision failure.

## First Adopted Mechanism

The first adopted mechanism is `skills/memory-evaluation/`, a compact checklist skill for memory evolution work. It borrows the Hermes-style idea that repeated agent behavior should become a skill, while keeping implementation inside this repository's existing memory and skill surfaces.
