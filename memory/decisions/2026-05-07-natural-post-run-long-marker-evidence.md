---
id: "decision-2026-05-07-natural-post-run-long-marker-evidence"
title: "Natural Post Run Long Marker Evidence"
type: "memory"
status: "active"
owner: "agent"
created: "2026-05-07"
updated: "2026-05-07"
tags:
  - decision
  - supervisor
  - feedback-pressure
  - post-run-pressure
  - validation
summary: "Records the live-evidence trigger for proving that natural post-run pressure inboxes preserve long markers."
source: "mailbox"
confidence: "high"
related:
  - "mailbox-inbox-2026-05-07-141418-feedback-pressure-challenge"
  - "mailbox-outbox-2026-05-07-141418-feedback-pressure-challenge-reply"
  - "decision-2026-05-07-post-run-pressure-marker"
  - "scripts/supervisor.sh"
---

# Natural Post Run Long Marker Evidence

## Decision

The long-marker truncation repair is not ready for return-to-main review on fixture proof alone. This branch needs one natural post-run cycle where the supervisor creates a pending `mailbox/inbox/*-post-run-pressure-challenge.md` from a completed outbox reply and the generated `## Requirement` exactly preserves the full marker line.

## Trigger

After `mailbox/outbox/2026-05-07-141418-feedback-pressure-challenge-reply.md` is committed through the normal supervisor path, inspect the next generated `mailbox/inbox/*-post-run-pressure-challenge.md`. Treat the proof as incomplete if the requirement is missing, ends mid-word, omits the tail of the marker, or turns into a broad repository-sweep challenge.

## Rerunnable Query Probe

Future agents can rediscover this decision with:

```bash
scripts/query-docs.sh memory "natural post-run long marker"
scripts/query-docs.sh memory "live generated inbox preserves full marker"
```

## Return-To-Main Boundary

Keep return-to-main deferred until the natural generated inbox is observed and a follow-up run handles it without challenge churn.
