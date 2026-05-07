---
id: "decision-2026-05-08-status-sync-v2-proof"
title: "Status Sync V2 Proof"
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
summary: "Records the reduced v2 status-sync patch and proof boundary after v1 review blockers."
source: "mailbox/processing/2026-05-07-204246-post-run-pressure-challenge.md"
confidence: "high"
related:
  - "mailbox/outbox/2026-05-08-status-sync-v2-proof-reply.md"
  - "mailbox/outbox/attachments/2026-05-08-status-sync-v2-main-target.patch"
  - "memory/decisions/2026-05-08-status-sync-main-target-deferral.md"
supersedes:
  - "decision-2026-05-08-status-sync-main-target-deferral"
---

# Status Sync V2 Proof

The v2 status-sync candidate is `mailbox/outbox/attachments/2026-05-08-status-sync-v2-main-target.patch`.

This candidate supersedes the v1 deferral only for the reduced surface it actually proves. It removes unproved operator start/stop changes, commit progress/failure notifications, and `stop_launchd` return-semantics changes. It keeps only child start/resume and child nonzero failure notifications in `run_codex_once`, plus helper scripts and fixtures.

Future review should require all of these before promotion:

- `git apply --check --index --verbose` in an initialized `origin/main` snapshot and zero `error:` lines.
- An all-skipped negative guard that treats `git apply --check --verbose --exclude='*'` with zero checked paths as rejection evidence.
- `git apply --index --whitespace=error`.
- `git diff --check --cached`.
- `scripts/shell-syntax-check.sh` for every changed shell script.
- `scripts/supervisor-notify-fixture-check.sh`.
- `scripts/supervisor-notify-cycle-check.sh`.

Recall probe:

```text
scripts/query-docs.sh memory "status sync v2 proof"
```
