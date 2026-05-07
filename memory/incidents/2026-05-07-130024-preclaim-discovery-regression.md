---
id: "incident-2026-05-07-130024-preclaim-discovery-regression"
title: "Preclaim Discovery Regression"
type: "incident"
status: "active"
owner: "agent"
created: "2026-05-07"
updated: "2026-05-07"
tags:
  - incident
  - mailbox
  - claim-latency
  - feedback-pressure
summary: "Records that the 2026-05-07-130024 pending-inbox run performed broad constitution discovery before claiming the inbox."
source: "session"
confidence: "high"
related:
  - "mailbox-inbox-2026-05-07-130024-post-run-pressure-challenge"
  - "mailbox-outbox-2026-05-07-130024-trigger-quiet-post-run-reply"
  - "decision-2026-05-07-pending-inbox-claim-latency"
---

# Preclaim Discovery Regression

## Incident

The 2026-05-07-130024 pending-inbox run handled its mailbox challenge, but it violated the branch claim-order rule before doing so. After reading `AGENTS.md` and `constitution/00-charter.md`, it ran broad constitution discovery before moving the listed inbox file into `mailbox/processing/`.

The failed scanner command was:

```text
scripts/supervisor.sh claim-latency sessions/2026/05/07/rollout-2026-05-07T21-02-42-019e0288-8830-7a10-acdf-9e0a61ba7760.jsonl
```

Observed result:

```text
pending-inbox-claim-latency-check: FAIL sessions/2026/05/07/rollout-2026-05-07T21-02-42-019e0288-8830-7a10-acdf-9e0a61ba7760.jsonl
claim_delay_seconds: 89
broad pre-claim commands:
- scripts/query-docs.sh constitution mailbox
- scripts/query-docs.sh constitution branch
- scripts/query-docs.sh constitution memory
```

## Impact

The mailbox lifecycle for the challenged item was completed, and the trigger quiet probe passed after durable records were written. The process failure is narrower: this run is negative evidence for claim-order discipline and should not be cited as a claim-latency pass.

## Cause

I followed the launch prompt's instruction to use `scripts/query-docs.sh` too early and failed to apply the mailbox-processing skill's stricter ordering: for a single listed pending inbox, claim immediately after `AGENTS.md` and `constitution/00-charter.md`, then run further discovery.

## Follow-Up

The operating rule already exists in `memory/decisions/2026-05-07-pending-inbox-claim-latency.md` and `skills/mailbox-processing/SKILL.md`. The useful follow-up is not a new mechanism; it is to treat this session as a failed live probe and require the next pending-inbox run to pass the existing claim-latency scanner before being used as positive claim-order evidence.
