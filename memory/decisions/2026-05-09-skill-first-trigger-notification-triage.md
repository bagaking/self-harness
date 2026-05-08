---
id: "decision-2026-05-09-skill-first-trigger-notification-triage"
title: "Skill First Trigger Notification Triage"
type: "memory"
status: "active"
owner: "agent"
created: "2026-05-09"
updated: "2026-05-09"
tags:
  - decision
  - skills
  - trigger-review
  - notification
  - autoresearch
  - darwin
  - feedback-pressure
summary: "Records the branch-local decision to update skill-first delivery with trigger-review triage and concrete notification failure-policy rules."
source: "mailbox/processing/2026-05-09-skill-first-autoresearch-darwin-notification-challenge.md"
confidence: "high"
related:
  - "mailbox-inbox-2026-05-09-skill-first-autoresearch-darwin-notification-challenge"
  - "mailbox/outbox/2026-05-09-skill-first-autoresearch-darwin-notification-challenge-reply.md"
  - "skills/skill-first-branch-delivery/SKILL.md"
  - "memory/decisions/2026-05-09-research-backed-skill-evolution.md"
  - "memory/decisions/2026-05-08-supervisor-status-notification-boundary.md"
---

# Skill First Trigger Notification Triage

## Decision

Future skill-first branch delivery should not treat live trigger-review output as a reason for either generic silence or automatic new mechanisms. The branch-delivery skill now requires a three-way classification for each review source:

- stale: the source no longer appears or the trigger condition is false;
- already covered: later durable records satisfy the trigger and name a lifecycle/source marker;
- mechanism-worthy: the evidence exposes a repeatable false positive, missing gate, missing skill step, or changed control-plane surface.

Notification/status-sync proposals must also state notification content, excluded content, failure policy, and audit boundary. A notification send failure after local status recording succeeds should be logged but should not block commits or ordinary supervisor progress.

## Variation And Fitness

Candidate retained: update `skills/skill-first-branch-delivery/SKILL.md` with trigger-review triage and notification failure-policy rules.

Alternative rejected: mailbox-only reply. It would record this run's reasoning but would not improve the future branch-delivery checklist.

Pre-edit fitness:

```text
scripts/query-docs.sh skills "trigger-review triage"
scripts/query-docs.sh skills "notification failure blocks commits"
```

Both queries returned no matching skill documents before the edit.

Post-edit fitness:

```text
scripts/query-docs.sh skills "trigger-review triage"
scripts/query-docs.sh skills "notification failure blocks commits"
```

Both queries now find `skills/skill-first-branch-delivery/SKILL.md`.

## Freshness

This narrows `memory/decisions/2026-05-09-research-backed-skill-evolution.md` and `memory/decisions/2026-05-09-skill-first-branch-delivery.md` only for trigger-review and notification-policy delivery work. It does not supersede the general auto-research or Darwin-style skill evolution loop.

Return-to-main judgment: deferred candidate. The rule is portable and query-discoverable, but it needs one later independent branch-delivery use before it should be considered for promotion.
