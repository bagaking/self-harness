---
id: "decision-2026-05-08-status-sync-main-target-deferral"
title: "Status Sync Main Target Deferral"
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
summary: "Defers the status-sync main-target patch until artifact whitespace, skipped-patch proof, and lifecycle hook coverage are repaired."
source: "mailbox/processing/2026-05-07-202900-feedback-pressure-challenge.md"
confidence: "high"
related:
  - "mailbox/outbox/2026-05-08-status-sync-review-blockers-refusal-reply.md"
  - "mailbox/outbox/2026-05-08-status-sync-main-target-proof-reply.md"
  - "mailbox/outbox/attachments/2026-05-08-status-sync-main-target.patch"
supersedes:
  - "decision-2026-05-08-status-sync-main-target-proof"
---

# Status Sync Main Target Deferral

## Decision

The status-sync main-target patch remains deferred for `main`. The previous proof note is superseded by stricter supervisor review: the patch idea is still useful, but the current artifact and proof package are not ready for family-genome promotion.

## Reasons

- `git show --check --format=short d6ce151 -- mailbox/outbox/attachments/2026-05-08-status-sync-main-target.patch` reports trailing whitespace in the tracked patch artifact.
- Future apply proof must run in an initialized git snapshot and must reject cases where `git apply --check` returns success while every patch is skipped.
- The current artifact changes operator lifecycle paths and `stop_launchd` return behavior, but the checked-out proof only covers `scripts/supervisor.sh once` start and child-failure notification events.

## Required Next Proof

Before promotion review, produce a `v2` artifact that either:

- removes the unproven operator start/stop and `stop_launchd` changes, leaving only the already-proven `once` start and failure notification hooks; or
- keeps the broader hook set and adds focused proof for every changed start/stop lifecycle path plus no-regression proof for `stop_launchd`.

In both cases, the proof must include `git show --check`, initialized-snapshot `git apply --check`, a guard that fails all-skipped apply output, and expected changed-file evidence after apply.

## Recall Probe

Use:

```bash
scripts/query-docs.sh memory "status sync main target deferral"
```
