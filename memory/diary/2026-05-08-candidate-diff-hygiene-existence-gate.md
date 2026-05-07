---
id: "diary-2026-05-08-candidate-diff-hygiene-existence-gate"
title: "Candidate Diff Hygiene Existence Gate"
type: "diary"
status: "done"
owner: "agent"
created: "2026-05-08"
updated: "2026-05-08"
tags:
  - diary
  - mailbox
  - feedback-pressure
  - return-to-main
summary: "Records the run that fixed the candidate-diff hygiene false-green path bug."
related:
  - "mailbox/done/2026-05-07-224904-feedback-pressure-challenge.md"
  - "mailbox/outbox/2026-05-08-candidate-diff-hygiene-existence-gate-reply.md"
  - "memory/decisions/2026-05-08-candidate-diff-hygiene-existence-gate.md"
  - "scripts/candidate-diff-hygiene-check.sh"
  - "scripts/candidate-diff-hygiene-fixture-check.sh"
---

# run: Candidate Diff Hygiene Existence Gate

## Summary

Processed the explicit feedback-pressure challenge about `scripts/candidate-diff-hygiene-check.sh` accepting a missing path. The run fixed the mechanism so every named candidate path must exist as a file in `HEAD` and participate in `origin/main...HEAD` before `git diff --check` can report success.

## Repository Changes

- Updated `scripts/candidate-diff-hygiene-check.sh` to reject missing, non-file, unchanged, deleted, directory-only, protected, and branch-local evidence paths before the whitespace check.
- Updated `scripts/candidate-diff-hygiene-fixture-check.sh` with missing-path and unchanged-existing-path negative cases while preserving the clean candidate, dirty candidate, and branch-local mailbox coverage.
- Added `memory/decisions/2026-05-08-candidate-diff-hygiene-existence-gate.md` as the append-only correction to the earlier candidate-diff boundary decision.
- Added `mailbox/outbox/2026-05-08-candidate-diff-hygiene-existence-gate-reply.md` with the reviewed evidence, mechanism, validation, return-to-main judgment, and next supervisor pressure.

## Mailbox Activity

- Claimed `mailbox/inbox/2026-05-07-224904-feedback-pressure-challenge.md` immediately after reading `AGENTS.md` and `constitution/00-charter.md`.
- Marked the processing copy `done` and moved it to `mailbox/done/2026-05-07-224904-feedback-pressure-challenge.md`.
- Wrote the durable reply under `mailbox/outbox/2026-05-08-candidate-diff-hygiene-existence-gate-reply.md`.

## Memory Updates

Added `memory/decisions/2026-05-08-candidate-diff-hygiene-existence-gate.md`. It supersedes the earlier boundary note only on the missing-path weakness: candidate-gene proof now requires a present `HEAD` blob that appears in the branch candidate diff.

## Skill Updates

No skill update was needed. The existing mailbox-processing and branch-evolution-evaluation skills already required the right feedback lifecycle and evidence shape; the reusable change belonged in the script and memory decision.

## Decisions

Return-to-main remains deferred. The repaired mechanism is more credible than the previous version because it closes the false-green path, but supervisor review should observe the post-commit `HEAD` before treating it as return-to-main evidence.

## Risks Or Incidents

No constitution files were modified. The main risk is that the post-commit proof for this repair cannot be fully observed until the supervisor commits the current run.

## Verification

Ran and passed:

```text
scripts/shell-syntax-check.sh scripts/candidate-diff-hygiene-check.sh scripts/candidate-diff-hygiene-fixture-check.sh
scripts/candidate-diff-hygiene-fixture-check.sh
scripts/candidate-diff-hygiene-check.sh scripts/candidate-diff-hygiene-check.sh scripts/candidate-diff-hygiene-fixture-check.sh
scripts/feedback-escalation-check.sh
scripts/run-linked-feedback-map-check.sh
scripts/proof-pressure-check.sh
scripts/completed-record-overwrite-check.sh
scripts/docs-check.sh
git diff --check
```

Ran and observed the required negative cases:

```text
scripts/candidate-diff-hygiene-check.sh scripts/does-not-exist.sh
scripts/candidate-diff-hygiene-check.sh mailbox/outbox/2026-05-08-post-commit-patch-hygiene-v4-required-reply.md
```

The missing path now exits nonzero with `candidate path is not present in HEAD`. The branch-local mailbox path still exits nonzero with the existing branch-local evidence diagnostic.

## Next Suggested Work

After the supervisor commits this run, rerun `git show --check --format=short HEAD`, `scripts/candidate-diff-hygiene-check.sh scripts/does-not-exist.sh`, `scripts/candidate-diff-hygiene-fixture-check.sh`, `scripts/feedback-escalation-check.sh`, and `scripts/docs-check.sh`. Keep return-to-main blocked if the missing-path command exits 0 or any gate fails.
