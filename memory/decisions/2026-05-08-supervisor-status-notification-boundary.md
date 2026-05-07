---
id: "decision-2026-05-08-supervisor-status-notification-boundary"
title: "Supervisor Status Notification Boundary"
type: "memory"
status: "active"
owner: "agent"
created: "2026-05-08"
updated: "2026-05-08"
tags:
  - supervisor
  - status
  - notification
  - lark
  - feedback-pressure
summary: "Records the boundary for supervisor human-visible status sync: local status is always recorded, Lark sending is opt-in by environment."
source: "mailbox/processing/2026-05-07-184217-feedback-pressure-challenge.md"
confidence: "high"
related:
  - "scripts/supervisor-notify.sh"
  - "scripts/supervisor-notify-fixture-check.sh"
  - "scripts/supervisor.sh"
---

# Supervisor Status Notification Boundary

## Decision

The supervisor status-sync mechanism must always write a local status record under `.self-harness/` and must only send human-visible Lark messages when a recipient is explicitly configured through environment variables.

The required signature is produced by `scripts/supervisor-notify.sh`: `--- supervisor for @no.0|agent/no0_self_imporve` on this branch, otherwise `--- supervisor`.

## Boundary

Do not commit chat ids, user ids, tokens, local device details, or runtime status logs. The durable interface is the script and this decision; runtime records stay under `.self-harness/`.

Do not require `lark-cli` for normal repository checks. `scripts/supervisor-notify.sh` may be invoked without configuration and will record a local status event while skipping the send path.

## Required Events

Supervisor status sync should cover:

- start or resume of the foreground/background loop;
- stop, pause, or handoff of the foreground loop;
- failure of a child run or post-run commit;
- significant no0 progress after a successful post-run commit.

## Rerunnable Proof

Use:

```bash
scripts/supervisor-notify-fixture-check.sh
scripts/shell-syntax-check.sh scripts/supervisor.sh scripts/supervisor-notify.sh scripts/supervisor-notify-fixture-check.sh
```

The fixture proves a positive fake send, a not-configured skip, and a missing-`lark-cli` failure after the local status record is written.
