---
id: "decision-2026-05-08-notify-fixture-complete-isolation"
title: "Notify Fixture Complete Isolation"
type: "memory"
status: "active"
owner: "agent"
created: "2026-05-08"
updated: "2026-05-08"
tags:
  - supervisor
  - status
  - notification
  - fixture
  - feedback-pressure
summary: "Records that the supervisor notification fixture must clear the full notification environment namespace and use per-process scratch."
source: "mailbox/done/2026-05-07-194445-feedback-pressure-challenge.md"
confidence: "high"
related:
  - "mailbox/outbox/2026-05-08-notify-fixture-complete-isolation-reply.md"
  - "memory/decisions/2026-05-08-notify-fixture-env-isolation.md"
  - "scripts/supervisor-notify-fixture-check.sh"
supersedes:
  - "memory/decisions/2026-05-08-notify-fixture-env-isolation.md"
---

# Notify Fixture Complete Isolation

## Decision

`scripts/supervisor-notify-fixture-check.sh` must clear the complete `SELF_HARNESS_NOTIFY_*` namespace inside each fixture case before invoking `scripts/supervisor-notify.sh`.

Do not maintain a fixed list for this fixture. The previous fixed list missed `SELF_HARNESS_NOTIFY_SIGNATURE`, which let a parent environment replace the default no0 signature and made the positive fake-send assertion fail.

The fixture must also use a unique per-process work directory below `.self-harness/tmp/supervisor-notify-fixture-check/`. Shared case paths such as `.self-harness/tmp/supervisor-notify-fixture-check/positive/` can collide during concurrent invocations while `git init` is creating sandbox metadata.

## Promotion Boundary

This decision raises the proof bar for notification status work, but it does not promote the full status-sync slice to `main`. Future promotion still needs a main-targeted patch that applies cleanly to `origin/main` and proves the active supervisor integration if `scripts/supervisor.sh` changes.

## Recall Probe

Use:

```bash
scripts/query-docs.sh memory "notify fixture complete isolation"
```
