---
id: "decision-2026-05-07-completed-record-overwrite-check"
title: "Completed Record Overwrite Check"
type: "memory"
status: "active"
owner: "agent"
created: "2026-05-07"
updated: "2026-05-07"
tags:
  - decision
  - supervisor
  - mailbox
  - diary
  - feedback-pressure
  - validation
summary: "Records the branch-local decision to reject edits to already tracked completed outbox and diary records."
source: "mailbox"
confidence: "high"
related:
  - "mailbox-inbox-2026-05-07-120836-feedback-pressure-challenge"
  - "scripts/completed-record-overwrite-check.sh"
  - "scripts/completed-record-overwrite-fixture-check.sh"
---

# Completed Record Overwrite Check

## Decision

Completed `mailbox/outbox/*.md` replies and `memory/diary/*.md` commit-message artifacts are historical records. A later run should create uniquely named current-run files instead of editing already tracked records in those directories.

`scripts/completed-record-overwrite-check.sh` rejects tracked modifications, deletions, renames, copies, or type changes that touch existing paths under `mailbox/outbox/*.md` or `memory/diary/*.md`. It allows new outbox and diary records, and it allows updates to evolving memory such as `memory/decisions/*.md`.

The check is exposed as:

```bash
scripts/supervisor.sh completed-records
```

The supervisor commit gate also runs the check before pending-inbox, proof-pressure, feedback, docs, and shell-syntax checks.

## Evidence

Focused fixture proof:

```text
completed-record-overwrite-fixture-check: rejects modifications to existing completed outbox and diary records
completed-record-overwrite-fixture-check: allows new outbox and diary records while updating memory decisions
completed-record-overwrite-fixture-check: ok
```

Live worktree probe:

```text
completed-record-overwrite-check: ok
```

## Operating Rule

When a current run needs to report new evidence, use a unique outbox and diary filename, usually including the mailbox timestamp or message id. Treat existing outbox and diary files as append-forbidden unless a human explicitly asks to repair a historical record.

## Rerunnable Checks

```bash
scripts/completed-record-overwrite-fixture-check.sh
scripts/supervisor.sh completed-records
scripts/query-docs.sh memory "completed record overwrite"
scripts/query-docs.sh skills "completed record overwrite"
```

## Return-To-Main

Return-to-main: deferred. The rule is portable and has focused negative plus positive fixture proof, but it is newly branch-local and may need a human override path for rare historical-record repair. Keep it branch-local until supervisor review decides whether the family-wide commit gate should protect completed outbox and diary records this strictly.
