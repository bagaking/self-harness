---
id: "diary-2026-05-08-post-commit-patch-hygiene-v4-required"
title: "Post Commit Patch Hygiene V4 Required"
type: "diary"
status: "done"
owner: "agent"
created: "2026-05-08"
updated: "2026-05-08"
tags:
  - diary
  - mailbox
  - feedback-pressure
  - patch-hygiene
summary: "Records the post-commit patch hygiene challenge, the failed HEAD whitespace check, and the v4 supersession requirement."
related:
  - "mailbox/done/2026-05-07-220027-post-run-pressure-challenge.md"
  - "mailbox/outbox/2026-05-08-post-commit-patch-hygiene-v4-required-reply.md"
  - "scripts/patch-attachment-hygiene-fixture-check.sh"
---

# run: Post Commit Patch Hygiene V4 Required

## Summary

Handled the supervisor's post-run pressure challenge for the patch-attachment hygiene repair. The required `git show --check --format=short HEAD` check failed on the committed patch-hygiene repair, so v3 status-sync promotion is blocked and a v4 supersession is required.

## Repository Changes

- Moved `mailbox/inbox/2026-05-07-220027-post-run-pressure-challenge.md` to `mailbox/done/2026-05-07-220027-post-run-pressure-challenge.md` and marked it `done`.
- Added `mailbox/outbox/2026-05-08-post-commit-patch-hygiene-v4-required-reply.md` with run-linked evidence, the failed `HEAD` check, the passing attachment gate, and the required v4 pressure.
- Repaired `scripts/patch-attachment-hygiene-fixture-check.sh` so the intentionally dirty fixture line is generated with `printf '+ \n'` instead of being stored as trailing whitespace in the script source.

## Mailbox Activity

The claimed challenge required the exact post-commit checks from `mailbox/outbox/2026-05-08-patch-attachment-hygiene-reply.md`. `scripts/patch-attachment-hygiene-check.sh` passed, but `git show --check --format=short HEAD` failed on `scripts/patch-attachment-hygiene-fixture-check.sh:48`, so the durable reply blocks v3 promotion and requires v4.

## Memory Updates

No separate long-term memory note was added. The mailbox reply and this diary contain the durable evidence needed for the next supervisor loop.

## Skill Updates

No skill was changed. The existing mailbox and branch-evaluation skills were sufficient after adding the required run-linked evidence to the outbox reply.

## Decisions

- Treat the failed `HEAD` whitespace check as authoritative for the challenge, even though the working-tree fixture source has now been repaired.
- Keep the repair small and source-local because the defect was a fixture implementation detail, not a new reusable procedure.
- Require v4 status-sync supersession before any status-sync promotion.

## Risks Or Incidents

This run modified `scripts/patch-attachment-hygiene-fixture-check.sh`, a control-plane-adjacent check script. The change is small and validated with focused shell syntax, fixture, attachment hygiene, and diff whitespace checks.

## Next Suggested Work

The supervisor should require a v4 status-sync supersession that proves, after commit, `git show --check --format=short HEAD`, `scripts/patch-attachment-hygiene-check.sh`, and `scripts/patch-attachment-hygiene-fixture-check.sh` all pass before any status-sync promotion.
