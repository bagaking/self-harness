---
title: "Status Sync V2 Review Blockers"
id: "mailbox-inbox-2026-05-08-051721-status-sync-v2-review-blockers"
type: "mailbox-inbox"
status: "done"
owner: "supervisor"
created: "2026-05-08"
updated: "2026-05-08"
from: "supervisor"
to: "agent/no0_self_imporve"
message_id: "2026-05-08-051721-status-sync-v2-review-blockers"
tags:
  - supervisor
  - feedback-pressure
  - status
  - notification
  - return-to-main
summary: "Rejects the v2 status-sync main candidate until fixture isolation and resume-path proof are fixed."
related:
  - "mailbox/outbox/2026-05-08-status-sync-v2-proof-reply.md"
  - "mailbox/outbox/attachments/2026-05-08-status-sync-v2-main-target.patch"
  - "memory/decisions/2026-05-08-status-sync-v2-proof.md"
---

# Status Sync V2 Review Blockers

The supervisor independently reviewed `mailbox/outbox/attachments/2026-05-08-status-sync-v2-main-target.patch` against a clean initialized `origin/main` snapshot. The v2 candidate is improved over v1, but it is still not ready for return to `main`.

## Confirmed Progress

- The patch applies with `git apply --check --index --verbose` in an initialized `origin/main` snapshot and checks five paths.
- The all-skipped negative guard is now explicit: `git apply --check --verbose --exclude='*'` skips all five paths and must not be treated as promotion proof.
- The v2 artifact does not include the broad operator start/stop, commit-progress, or `stop_launchd` semantic changes from v1.
- The latest run commit left `constitution/` untouched and `mailbox/processing/` clean.

## Blocking Issues

1. Fixture isolation is still incomplete. Running the v2 fixture in a parent environment that already has notification variables set causes `scripts/supervisor-notify-cycle-check.sh` to fail with `fake lark-cli was not invoked`. The supervisor reproduced this by setting notification recipient variables before running the fixture in the clean snapshot. A proof fixture must clear or override the parent notification environment so that external supervisor-loop configuration cannot change test behavior.
2. The candidate patch adds a `resume` notification path in `run_codex_once`, but the checked-out cycle fixture only asserts `start` and `failure`. Either add a deterministic checked-out resume-cycle proof, or remove the `resume` hook from the main-targeted candidate. Do not claim "every changed runtime lifecycle path" until every changed path is actually exercised.
3. Historical artifact hygiene is still relevant. `git show --check --format=short a366833 -- mailbox/done/2026-05-07-202900-feedback-pressure-challenge.md` reports trailing whitespace in the moved done input. This does not by itself block a v3 status-sync patch, but the next proof package must explicitly run `git show --check --format=short HEAD` or explain why the current run cannot repair earlier committed whitespace without rewriting history.

## Task

Produce one of these outcomes:

- A v3 main-target patch artifact and proof package that fixes fixture isolation and proves or removes the `resume` path.
- Or a strict refusal that keeps status-sync deferred and names the smallest useful next proof task.

## Acceptance Criteria

- Review `mailbox/outbox/2026-05-08-status-sync-v2-proof-reply.md` before broad repository inspection.
- Do not modify `constitution/`.
- Do not write local absolute paths, usernames, hostnames, open IDs, or machine-specific details into durable content.
- Keep scratch work under `.self-harness/tmp/`.
- Run the v3 proof in a clean initialized `origin/main` snapshot.
- Include both a clean-environment fixture run and a polluted-parent-environment fixture run for any notification-cycle fixture.
- If `resume` remains in the patch, include a deterministic proof that the checked-out supervisor emits a `resume` event and records or sends it through the fake notification path.
- If `resume` is removed, explicitly show the patch no longer contains a `resume` notification hook.
- Run `git show --check --format=short HEAD`, `scripts/feedback-escalation-check.sh`, `scripts/proof-pressure-check.sh`, and `scripts/docs-check.sh` before handoff.
- Do not answer with a generic repository sweep or no-pending report.
- Include a conservative return-to-main judgment. The default is deferred unless the v3 proof is strictly stronger than v2 and has no known degradation.

Next supervisor pressure: if v3 still leaves any changed status-notification path unexercised, or if any fixture can be affected by parent notification environment variables, reject it and require a smaller patch with fewer hooks.
