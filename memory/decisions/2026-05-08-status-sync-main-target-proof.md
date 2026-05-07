---
id: "decision-2026-05-08-status-sync-main-target-proof"
title: "Status Sync Main Target Proof"
type: "memory"
status: "active"
owner: "agent"
created: "2026-05-08"
updated: "2026-05-08"
tags:
  - supervisor
  - status
  - notification
  - return-to-main
  - feedback-pressure
summary: "Records that a fresh status-sync patch artifact was built against origin/main and proved in an initialized scratch snapshot."
source: "mailbox/processing/2026-05-07-195430-post-run-pressure-challenge.md"
confidence: "high"
related:
  - "mailbox/outbox/2026-05-08-status-sync-main-target-proof-reply.md"
  - "mailbox/outbox/attachments/2026-05-08-status-sync-main-target.patch"
  - "memory/decisions/2026-05-08-status-sync-return-to-main-deferral.md"
  - "memory/decisions/2026-05-08-notify-fixture-complete-isolation.md"
supersedes: []
---

# Status Sync Main Target Proof

## Decision

The earlier status-sync return-to-main deferral is narrowed but not automatically reversed. This run produced a fresh patch artifact, `mailbox/outbox/attachments/2026-05-08-status-sync-main-target.patch`, from an `origin/main` snapshot and proved the patched snapshot after normal `scripts/init.sh` layout initialization.

The patch is still supervisor-review material, not an autonomous merge. It changes high-risk control-plane behavior in `scripts/supervisor.sh`, adds notification helpers, and needs supervisor judgment before any return to `main`.

## Evidence

The scratch proof used an extracted `origin/main` snapshot under `.self-harness/tmp/`, initialized it, applied the main-targeted status-sync files, and ran:

```bash
bash scripts/supervisor-notify-fixture-check.sh
SELF_HARNESS_NOTIFY_SIGNATURE='--- polluted-signature' bash scripts/supervisor-notify-fixture-check.sh
bash scripts/supervisor-notify-fixture-check.sh  # two concurrent instances
scripts/shell-syntax-check.sh scripts/supervisor.sh scripts/supervisor-notify.sh scripts/supervisor-notify-fixture-check.sh scripts/supervisor-notify-cycle-check.sh
bash scripts/supervisor-notify-cycle-check.sh
bash scripts/init.sh >/dev/null && scripts/docs-check.sh
```

## Recall Probe

Use:

```bash
scripts/query-docs.sh memory "status sync main target proof"
```
