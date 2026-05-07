---
id: "decision-2026-05-08-notify-fixture-env-isolation"
title: "Notify Fixture Env Isolation"
type: "memory"
status: "superseded"
owner: "agent"
created: "2026-05-08"
updated: "2026-05-08"
tags:
  - supervisor
  - status
  - notification
  - fixture
  - return-to-main
summary: "Records that supervisor notification fixture cases must clear inherited notification environment before setting case-specific variables."
source: "mailbox/done/2026-05-07-193223-notify-fixture-env-isolation.md"
confidence: "high"
related:
  - "mailbox/outbox/2026-05-08-notify-fixture-env-isolation-reply.md"
  - "memory/decisions/2026-05-08-notify-fixture-complete-isolation.md"
  - "memory/decisions/2026-05-08-status-sync-return-to-main-deferral.md"
  - "scripts/supervisor-notify-fixture-check.sh"
superseded_by:
  - "memory/decisions/2026-05-08-notify-fixture-complete-isolation.md"
---

# Notify Fixture Env Isolation

Superseded by `memory/decisions/2026-05-08-notify-fixture-complete-isolation.md`, which expands the isolation contract from a fixed recipient/bin list to the complete `SELF_HARNESS_NOTIFY_*` namespace and records the per-process scratch requirement.

## Decision

`scripts/supervisor-notify-fixture-check.sh` must clear inherited notification variables inside each fixture case before invoking `scripts/supervisor-notify.sh`.

The isolation set is:

- `SELF_HARNESS_NOTIFY_CHAT_ID`
- `SELF_HARNESS_NOTIFY_USER_ID`
- `SELF_HARNESS_NOTIFY_LARK_BIN`
- `SELF_HARNESS_NOTIFY_AS`
- `SELF_HARNESS_NOTIFY_DRY_RUN`

Cases may then set only the variables they intentionally test. This prevents a parent supervisor environment from forcing the not-configured case into the send path.

## Promotion Boundary

This closes the fixture defect recorded during the status-sync return-to-main review, but it does not by itself make the broader status-sync slice ready for `main`. A future promotion still needs a fresh main-targeted patch whose `scripts/supervisor.sh` integration applies cleanly to `origin/main`.

## Recall Probe

Use:

```bash
scripts/query-docs.sh memory "notify fixture env isolation"
```
