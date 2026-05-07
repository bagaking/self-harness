---
id: "decision-2026-05-08-post-commit-proof-boundary"
title: "Post Commit Proof Boundary"
type: "memory"
status: "active"
owner: "agent"
created: "2026-05-08"
updated: "2026-05-08"
tags:
  - decision
  - mailbox
  - feedback-pressure
  - validation
  - commit
summary: "Records that Codex runs must not claim post-commit proof for a supervisor commit that does not exist yet."
source: "mailbox"
confidence: "high"
related:
  - "mailbox-inbox-2026-05-07-220837-post-run-pressure-challenge"
  - "mailbox/outbox/2026-05-08-post-commit-patch-hygiene-v4-required-reply.md"
  - "skills/mailbox-processing/SKILL.md"
---

# Post Commit Proof Boundary

## Decision

When a mailbox challenge requires a check to pass after commit, a Codex run can only report evidence from the current committed `HEAD` and from the uncommitted working tree. It must not claim that a future supervisor commit passed.

If the requested post-commit command fails on already committed history, the current run should report the failure and preserve a smaller useful next task. Editing an already tracked completed outbox or diary record to clean historical `HEAD` evidence conflicts with `memory/decisions/2026-05-07-completed-record-overwrite-check.md`; create current-run records instead.

## Evidence

The v4 pressure run requested:

```text
git show --check --format=short HEAD
scripts/patch-attachment-hygiene-check.sh
scripts/patch-attachment-hygiene-fixture-check.sh
```

`scripts/patch-attachment-hygiene-check.sh` and `scripts/patch-attachment-hygiene-fixture-check.sh` passed in the working tree, but `git show --check --format=short HEAD` failed on an already committed outbox report line in `mailbox/outbox/2026-05-08-post-commit-patch-hygiene-v4-required-reply.md`.

## Operating Rule

For future post-commit proof challenges:

- Run the requested post-commit command against the current `HEAD`.
- If `HEAD` fails, refuse promotion and name the exact failing path.
- Use `git diff --check` only as current working-tree cleanliness evidence.
- Defer promotion until the supervisor commits the current run and the requested post-commit command passes against that new `HEAD`.

## Rerunnable Checks

```bash
git show --check --format=short HEAD
git diff --check
scripts/patch-attachment-hygiene-check.sh
scripts/patch-attachment-hygiene-fixture-check.sh
scripts/query-docs.sh memory "post commit proof"
```
