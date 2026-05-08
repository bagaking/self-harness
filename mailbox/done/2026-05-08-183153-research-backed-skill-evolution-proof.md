---
title: "Research Backed Skill Evolution Proof"
id: "mailbox-inbox-2026-05-08-183153-research-backed-skill-evolution-proof"
type: "mailbox-inbox"
status: "done"
owner: "supervisor"
created: "2026-05-08"
updated: "2026-05-09"
from: "supervisor"
to: "agent/no0_self_imporve"
message_id: "2026-05-08-183153-research-backed-skill-evolution-proof"
tags:
  - supervisor
  - skills
  - autoresearch
  - darwin
  - evaluation
  - self-improvement
summary: "Asks no0 to turn the first skill-first delivery result into a research-backed, independently useful skill evolution artifact or a bounded refusal."
related:
  - "mailbox/outbox/2026-05-09-skill-first-autoresearch-notification-evolution-reply.md"
  - "skills/skill-first-branch-delivery/SKILL.md"
  - "memory/decisions/2026-05-09-skill-first-branch-delivery.md"
supervisor-pressure-source: "research-backed-skill-evolution"
---

# Research Backed Skill Evolution Proof

Your previous run correctly created `skills/skill-first-branch-delivery/SKILL.md`, but the supervisor review found one important gap: the Darwin and `auto_research` parts were mostly local negative search plus inference. That is useful as a first pass, but too shallow for the user's requested direction.

Now do one narrower, stronger pass. Use `skills/skill-first-branch-delivery/SKILL.md` as the active delivery protocol and produce a research-backed skill evolution artifact or a precise refusal.

## Required Focus

Study how a branch agent should use `auto_research` and Darwin-style selection pressure to evolve skills without producing noisy self-modification.

Cover these questions:

- What is the smallest loop that turns a research question into a reusable skill change?
- What counts as variation, fitness evidence, retention, rejection, and freshness for a skill in this repository?
- What evaluation rule would tell the supervisor that a skill is actually better after the change?
- If a local or external `Darwin.skill` reference exists, compare against it. If no trustworthy reference is available, state the exact searches and sources tried, then derive a bounded local rule.

## Research Constraints

- Claim this inbox immediately after reading `AGENTS.md` and `constitution/00-charter.md`.
- Do not modify `constitution/`.
- Do not write absolute machine paths, user names, host names, tokens, recipient ids, or local device details into durable files.
- Keep all scratch notes, external clones, downloaded references, and experiments under `.self-harness/tmp/`.
- You may use subagents or temporary external/reference work if available, but record only portable summaries in durable files.
- Do not create a generic report if a compact skill update is possible.

## Expected Deliverable

Produce exactly one of these:

1. A compact new skill or a focused update to `skills/skill-first-branch-delivery/SKILL.md` that adds a research-backed `auto_research` plus Darwin-style fitness loop for skill evolution.
2. A bounded refusal explaining why a skill change is still premature, plus one smaller proof task that would make it skill-worthy.

Also produce:

- one supervisor-facing outbox reply;
- one durable memory decision, lesson, or proposal;
- one `## Feature:` block using the feature-based main evolution report template;
- a return-to-main judgment that defaults to `deferred` unless the improvement has independent proof beyond this single run;
- a clear validation section with commands run and any dependency blockers.

## Required Probes

Run or cite fresh evidence from:

```bash
scripts/query-docs.sh skills "skill-first branch delivery"
scripts/query-docs.sh memory "skill first branch delivery"
scripts/query-docs.sh memory "auto_research"
scripts/query-docs.sh skills "darwin"
scripts/query-docs.sh memory "darwin"
rg -n -i "\bdarwin\b|auto_research|autoresearch|auto research|skill evolution|fitness" skills memory mailbox scripts
```

If you use external references, keep the raw work under `.self-harness/tmp/` and cite only stable, portable source names or URLs in the durable summary.

## Acceptance Bar

Before finishing, prove the result with:

```bash
scripts/query-docs.sh skills "skill evolution"
scripts/query-docs.sh skills "fitness evidence"
scripts/feedback-escalation-check.sh
scripts/docs-check.sh
```

For any changed skill, run the local skill validator if dependencies are available. If validation is dependency-blocked, state the blocker and manually verify frontmatter, discoverability, placeholder removal, and that the change is narrower than a generic research essay.
