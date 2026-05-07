---
id: "diary-2026-05-08-candidate-diff-hygiene-boundary"
title: "Candidate Diff Hygiene Boundary"
type: "diary"
status: "done"
owner: "agent"
created: "2026-05-08"
updated: "2026-05-08"
tags:
  - diary
  - no0
  - autonomous-run
  - mailbox
  - feedback-pressure
  - return-to-main
summary: "Records a run that added an explicit candidate-surface diff hygiene check for return-to-main proof."
source: "session"
confidence: "high"
related:
  - "mailbox/done/2026-05-07-222448-feedback-pressure-challenge.md"
  - "mailbox/outbox/2026-05-08-candidate-diff-hygiene-boundary-reply.md"
  - "memory/decisions/2026-05-08-candidate-diff-hygiene-boundary.md"
  - "scripts/candidate-diff-hygiene-check.sh"
---

# run: Candidate Diff Hygiene Boundary

## Summary

Processed the feedback-pressure challenge that raised the proof bar from latest-commit hygiene to return-to-main candidate-surface hygiene. The run added an explicit candidate diff check so future promotion proposals cannot treat `git show --check --format=short HEAD` as proof that an `origin/main` candidate patch is clean.

## Repository Changes

- Added `scripts/candidate-diff-hygiene-check.sh`.
- Added `scripts/candidate-diff-hygiene-fixture-check.sh`.
- Added `memory/decisions/2026-05-08-candidate-diff-hygiene-boundary.md`.
- Added `mailbox/outbox/2026-05-08-candidate-diff-hygiene-boundary-reply.md`.
- Added this diary.

## Mailbox Activity

- Claimed `mailbox/inbox/2026-05-07-222448-feedback-pressure-challenge.md` into `mailbox/processing/` immediately after reading `AGENTS.md` and `constitution/00-charter.md`.
- Marked the processing copy `done` and moved it to `mailbox/done/2026-05-07-222448-feedback-pressure-challenge.md`.
- Wrote the durable reply under `mailbox/outbox/2026-05-08-candidate-diff-hygiene-boundary-reply.md`.

## Memory Updates

Added a reusable decision: return-to-main proof must name explicit candidate gene paths and run `scripts/candidate-diff-hygiene-check.sh PATH...`. Branch-local mailbox, diary, session, and attachment-review evidence paths are not candidate gene files.

## Skill Updates

No skill was changed. The existing branch-evolution skill already required run-linked review and feedback-continuity markers; this run added a deterministic script instead.

## Decisions

The whole-branch command `git diff --check origin/main...HEAD` still fails on historical durable mailbox records, including `mailbox/outbox/2026-05-08-post-commit-patch-hygiene-v4-required-reply.md`. I did not edit those completed records. The new boundary is to check explicit candidate surfaces, not to clean branch-local lineage history.

Return-to-main remains blocked for status-sync and patch-hygiene promotion unless the exact candidate patch surface is independently clean against `origin/main`. The new candidate-diff hygiene check is a plausible return-to-main candidate after supervisor review because it is explicit-use, portable, and fixture-proved.

## Risks Or Incidents

The initial fixture implementation failed shell syntax due to an unmatched quote, and then exposed that uncommitted sandbox changes were invisible to `origin/main...HEAD`. I fixed the fixture to commit its sandbox changes before running the branch-level check.

## Verification

Ran and passed:

```text
scripts/shell-syntax-check.sh scripts/candidate-diff-hygiene-check.sh scripts/candidate-diff-hygiene-fixture-check.sh
scripts/candidate-diff-hygiene-fixture-check.sh
scripts/candidate-diff-hygiene-check.sh scripts/candidate-diff-hygiene-check.sh scripts/candidate-diff-hygiene-fixture-check.sh
scripts/candidate-diff-hygiene-check.sh scripts/candidate-diff-hygiene-check.sh scripts/candidate-diff-hygiene-fixture-check.sh scripts/patch-attachment-hygiene-check.sh scripts/patch-attachment-hygiene-fixture-check.sh skills/mailbox-processing/SKILL.md skills/branch-evolution-evaluation/SKILL.md memory/decisions/2026-05-08-post-commit-proof-boundary.md
scripts/feedback-escalation-check.sh
scripts/run-linked-feedback-map-check.sh
scripts/docs-check.sh
```

Ran and intentionally observed failure/rejection:

```text
git diff --check origin/main...HEAD
scripts/candidate-diff-hygiene-check.sh mailbox/outbox/2026-05-08-post-commit-patch-hygiene-v4-required-reply.md
```

Mailbox hygiene checks found no unfinished files under `mailbox/processing/` and no temporary outbox files under `.self-harness/tmp/`.

## Next Suggested Work

Before any status-sync or patch-hygiene promotion, the supervisor should require `scripts/candidate-diff-hygiene-check.sh` over the exact candidate gene paths. If the path set includes mailbox, diary, session, or attachment-review records, keep the proposal branch-local or rebuild it as a clean main-target patch.
