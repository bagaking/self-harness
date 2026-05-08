---
id: "decision-2026-05-09-skill-change-proof-fields"
title: "Skill Change Proof Fields"
type: "memory"
status: "active"
owner: "agent"
created: "2026-05-09"
updated: "2026-05-09"
tags:
  - decision
  - skills
  - fitness-evidence
  - feedback-pressure
  - branch-evolution
summary: "Records the branch-local rule that skills-changing branch-delivery outbox replies must include four inspectable proof fields."
source: "mailbox/processing/2026-05-08-184343-post-run-pressure-challenge.md"
confidence: "high"
related:
  - "mailbox-inbox-2026-05-08-184343-post-run-pressure-challenge"
  - "mailbox/outbox/2026-05-09-post-run-pressure-challenge-reply.md"
  - "mailbox/outbox/2026-05-09-research-backed-skill-evolution-proof-reply.md"
  - "skills/skill-first-branch-delivery/SKILL.md"
  - "memory/decisions/2026-05-09-research-backed-skill-evolution.md"
---

# Skill Change Proof Fields

## Decision

For branch-delivery tasks that change `skills/`, the supervisor-facing outbox reply must name four fields:

1. candidate skill variation;
2. one rejected non-skill alternative;
3. pre-edit fitness signal;
4. post-edit command or later-use evidence proving the skill improved.

If a run cannot produce those fields, it should write a focused refusal with the smaller useful next task instead of making a speculative skill edit.

## Rationale

`memory/decisions/2026-05-09-research-backed-skill-evolution.md` already required variation and fitness evidence, but the completed run also left a sharper supervisor pressure line that named exact outbox fields. Encoding the exact fields in `skills/skill-first-branch-delivery/SKILL.md` makes the requirement discoverable by the procedure that future skills-changing runs should already use.

The rejected alternative was a mailbox-only or memory-only reply. That would preserve the current challenge evidence but would not change future branch-delivery behavior.

## Fitness Evidence

Pre-edit probes returned no matching skill documents for the exact field phrases:

```text
scripts/query-docs.sh skills "candidate skill variation"
scripts/query-docs.sh skills "rejected non-skill alternative"
scripts/query-docs.sh skills "pre-edit fitness signal"
scripts/query-docs.sh skills "post-edit command"
```

After the skill update, the same probes find `skills/skill-first-branch-delivery/SKILL.md`.

`python3 skills/.system/skill-creator/scripts/quick_validate.py skills/skill-first-branch-delivery` is still blocked by `ModuleNotFoundError: No module named 'yaml'`; manual validation checked skill frontmatter, folder-name consistency, `agents/openai.yaml`, and placeholder scope.

## Freshness

This decision narrows `memory/decisions/2026-05-09-research-backed-skill-evolution.md` for skills-changing branch-delivery tasks. It does not supersede the broader research-backed loop; it adds the exact outbox proof fields required by the next-pressure challenge.

Return-to-main judgment: deferred. The rule is portable and low-risk, but it should be observed in at least one later independent skills-changing branch-delivery task before promotion.
