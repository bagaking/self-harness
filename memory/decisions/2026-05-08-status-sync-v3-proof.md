---
id: "decision-2026-05-08-status-sync-v3-proof"
title: "Status Sync V3 Proof"
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
summary: "Records the v3 status-sync proof boundary after fixing fixture isolation and removing the unproved resume hook."
source: "mailbox/processing/2026-05-08-051721-status-sync-v2-review-blockers.md"
confidence: "high"
related:
  - "mailbox/outbox/2026-05-08-status-sync-v3-proof-reply.md"
  - "mailbox/outbox/attachments/2026-05-08-status-sync-v3-main-target.patch"
  - "memory/decisions/2026-05-08-status-sync-v2-proof.md"
supersedes:
  - "decision-2026-05-08-status-sync-v2-proof"
---

# Status Sync V3 Proof

The v3 status-sync candidate is `mailbox/outbox/attachments/2026-05-08-status-sync-v3-main-target.patch`.

This candidate supersedes v2 for the status notification proof boundary. It keeps the reduced child lifecycle surface, removes the unproved `resume` running notification hook, and proves `start` plus nonzero `failure` through a checked-out supervisor cycle fixture. The cycle fixture now clears inherited `SELF_HARNESS_NOTIFY_*` variables and runs both a clean environment case and a polluted parent notification environment case.

Future review should require all of these before promotion:

- `scripts/init.sh` in a clean `origin/main` snapshot.
- `git apply --check --index --verbose` with all five patch paths checked.
- An all-skipped negative guard that treats `git apply --check --verbose --exclude='*'` as rejection evidence when every path is skipped.
- `git apply --index --whitespace=error`.
- `git diff --check --cached`.
- Empty output from a search for a `resume` notification hook in the v3 artifact.
- `scripts/shell-syntax-check.sh` for every changed shell script.
- `scripts/supervisor-notify-fixture-check.sh`.
- `scripts/supervisor-notify-cycle-check.sh`, including both `clean-env` and `polluted-parent-env`.
- `scripts/docs-check.sh`.

Recall probe:

```text
scripts/query-docs.sh memory "status sync v3 proof"
```
