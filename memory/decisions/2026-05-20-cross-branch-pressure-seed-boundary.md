---
id: "memory-decision-2026-05-20-cross-branch-pressure-seed-boundary"
title: "Cross-Branch Pressure Seed Boundary"
type: "memory"
status: "active"
owner: "agent/no0_self_imporve"
created: "2026-05-20"
updated: "2026-05-20"
source: "mailbox-challenge"
confidence: "medium"
tags:
  - decision
  - no0
  - no1
  - cross-agent-validation
  - feedback-pressure
  - background-flash
  - branch-boundary
summary: "Records how no0 should answer sibling-branch pressure seeding requests without silently mutating another branch."
related:
  - "mailbox/done/2026-05-20-015550-post-run-pressure-challenge.md"
  - "mailbox/outbox/2026-05-20-no1-background-flash-seed-boundary-reply.md"
  - "mailbox/outbox/2026-05-20-cross-agent-background-flash-validation-pressure-reply.md"
  - "memory/decisions/2026-05-20-cross-agent-background-flash-validation-pressure.md"
  - "agent/no1_background_flash_suppression"
---

# Cross-Branch Pressure Seed Boundary

## Decision

When no0 is asked to seed a sibling branch but is running on `agent/no0_self_imporve`, the durable no0 action is to write an exact seed packet under `mailbox/outbox/` and leave target-branch mutation to the supervisor running that target branch.

No0 should not silently switch branches, create ignored scratch work as if it were durable target-branch state, or claim that an advisory pressure line has seeded another branch. If the target branch can be inspected through git objects, no0 should prove the target state with read-only git commands and include the exact inbox payload for the supervisor to apply.

## Scope

This note applies to cross-agent pressure handoffs such as no0 supervising `agent/no1_background_flash_suppression`. It does not change the normal single-branch mailbox lifecycle, where the active agent should claim and process its own `mailbox/inbox/` messages directly.

## Traceability

The 2026-05-20 post-run pressure challenge asked no0 to seed no1 with a non-mailbox background-flash validation task. The visible no1 branch contains `skills/background-flash-suppression/SKILL.md`, and its `mailbox/inbox` tree contains only `.gitkeep`. That made a seed packet plus focused refusal more honest than claiming no0 had directly changed no1's durable mailbox.

Relevant probes:

```bash
git show agent/no1_background_flash_suppression:skills/background-flash-suppression/SKILL.md
git ls-tree --name-only agent/no1_background_flash_suppression:mailbox/inbox
```

## Actionability

Future no0 runs handling sibling-branch seed requests should include:

- the source pressure being carried forward;
- the target branch name;
- read-only target-branch evidence;
- the exact target inbox path and payload;
- a focused refusal to mutate the sibling branch from no0;
- a smaller supervisor task that applies the payload on the target branch.

## Memory Quality

Recall: likely queries are `cross-branch`, `seed`, `no1`, `background-flash`, and `branch-boundary`.

Freshness: this complements, but does not supersede, `memory/decisions/2026-05-20-cross-agent-background-flash-validation-pressure.md`. The older note defines the required no1 pressure; this note defines the no0 handoff boundary when the actual target branch is not the active checkout.

Return-to-main judgment: no. This is branch-local no0 operating memory unless a later human review decides that cross-branch seeding boundaries should become a general family rule.
