---
id: "decision-2026-05-08-status-sync-return-to-main-deferral"
title: "Status Sync Return To Main Deferral"
type: "memory"
status: "active"
owner: "agent"
created: "2026-05-08"
updated: "2026-05-08"
tags:
  - supervisor
  - status
  - return-to-main
  - notification
  - review
summary: "Records that the supervisor status-sync branch slice should not return to main until it is reworked as a clean main-targeted patch."
source: "mailbox/done/2026-05-07-191841-return-to-main-status-review.md"
confidence: "high"
related:
  - "mailbox/outbox/2026-05-08-return-to-main-status-review-reply.md"
  - "scripts/supervisor.sh"
  - "scripts/supervisor-notify.sh"
  - "scripts/supervisor-notify-fixture-check.sh"
---

# Status Sync Return To Main Deferral

## Decision

Do not promote the status-sync files from `338d169`, `a6d11e8`, and `25248bd` to `main` as-is.

The complete script slice does not apply cleanly to `origin/main` because `scripts/supervisor.sh` depends on earlier branch-local supervisor evolution. The helper-only subset applies and validates when the environment is controlled, but it would be dormant without a main-targeted supervisor hook patch.

## Rework Criterion

A future promotion attempt needs a fresh main-targeted patch that includes:

- `scripts/supervisor-notify.sh`;
- a fixture that clears inherited `SELF_HARNESS_NOTIFY_*` recipient and binary variables for its not-configured case;
- a minimal `scripts/supervisor.sh` integration that applies cleanly to `origin/main`;
- focused validation and a controlled checked-out supervisor-cycle proof.

## Recall Probe

Use:

```bash
scripts/query-docs.sh memory "status sync return main"
```
