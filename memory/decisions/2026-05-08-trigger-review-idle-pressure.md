---
id: "decision-2026-05-08-trigger-review-idle-pressure"
title: "Trigger Review Idle Pressure"
type: "memory"
status: "active"
owner: "agent"
created: "2026-05-08"
updated: "2026-05-08"
tags:
  - decision
  - feedback-pressure
  - supervisor
  - trigger-review
summary: "Records why idle challenge seeding now consults trigger-review evidence before allowing an agent branch to stop."
source: "mailbox"
confidence: "high"
related:
  - "mailbox-inbox-2026-05-08-012203-feedback-pressure-challenge"
  - "scripts/supervisor.sh"
  - "scripts/trigger-review-idle-challenge-check.sh"
  - "scripts/supervisor-evaluation-trigger-list.sh"
---

# Trigger Review Idle Pressure

## Decision

When an agent branch has no pending inbox and a clean worktree, the supervisor should not skip launch solely because there is no repeated low-value commit-subject feedback. It should first check whether recent trigger-backed refusals have concrete later evidence by running:

```bash
scripts/supervisor.sh triggers --status review --limit 8
```

If that command reports source outboxes, the idle loop may seed one trigger-review pressure inbox for the first source that has no prior mailbox lifecycle record containing `trigger-review-source: <source>`.

## Boundary

This is not a generic churn mechanism. It must not seed when trigger review has no later evidence, when the worktree already has changes, when an inbox is pending, or when every review-evidence source already has the same `trigger-review-source:` marker in a mailbox lifecycle record.

## Rerunnable Probe

Use this query to rediscover the decision:

```bash
scripts/query-docs.sh memory "trigger-review idle"
```

Use this fixture to prove the behavior:

```bash
scripts/trigger-review-idle-challenge-check.sh
```

The fixture covers a positive seed from later durable evidence, an anti-noise skip for an already challenged source, source selection for an older unchallenged source, and a quiet skip when trigger review has no later evidence.
