---
id: "decision-2026-05-08-portable-content-gate"
title: "Portable Content Gate"
type: "memory"
status: "active"
owner: "agent"
created: "2026-05-08"
updated: "2026-05-08"
tags:
  - decision
  - portability
  - commit-gate
  - feedback-pressure
summary: "Records the branch-local decision to make portable-content hygiene a focused commit-gate script with fixture proof."
source: "session"
confidence: "high"
related:
  - "mailbox-inbox-2026-05-08-003819-feedback-pressure-challenge"
  - "mailbox-outbox-2026-05-08-portable-content-gate-reply"
  - "mailbox-inbox-2026-05-08-005709-post-run-pressure-challenge"
  - "mailbox-outbox-2026-05-08-portable-content-gate-activation-repair-reply"
  - "scripts/portable-content-check.sh"
  - "scripts/portable-content-check-fixture-check.sh"
  - "scripts/supervisor-real-cycle-check.sh"
  - "scripts/supervisor.sh"
---

# Portable Content Gate

## Decision

Add `scripts/portable-content-check.sh` as the deterministic portability gate for changed durable Markdown and shell scripts, and call it from `scripts/supervisor.sh` through `check_portable_content`.

The gate rejects local absolute paths, project-outside temporary paths, home-relative paths, local environment details, and the redaction placeholder form that previously allowed non-portable proof records to look sanitized while still carrying project-outside path evidence. Repository-relative `.self-harness/tmp/` scratch references remain allowed.

## Why

The previous inline supervisor scan did not catch a durable proof command that wrote `scripts/init.sh` output to a project-outside temporary path. That let a functionally valid clean-main proof become unacceptable return-to-main evidence because the proof record itself was non-portable.

The loop could stop too early by treating a successful feature proof as sufficient even when its durable evidence contained a portability defect. A focused gate is the smallest durable mechanism because it blocks the class before commit rather than relying on later supervisor review to notice it.

## Proof

Focused proof:

```text
scripts/portable-content-check-fixture-check.sh
portable-content-check-fixture-check: positive repository-relative scratch path passed
portable-content-check-fixture-check: negative project-outside temp redirection failed as expected
portable-content-check-fixture-check: negative redacted path placeholder failed as expected
portable-content-check-fixture-check: ok
```

Direct current-surface proof:

```text
scripts/portable-content-check.sh
portable-content-check: ok
```

Shell syntax:

```text
scripts/shell-syntax-check.sh scripts/portable-content-check.sh scripts/portable-content-check-fixture-check.sh scripts/supervisor.sh
shell-syntax-check: ok scripts/portable-content-check.sh
shell-syntax-check: ok scripts/portable-content-check-fixture-check.sh
shell-syntax-check: ok scripts/supervisor.sh
```

## Boundary

This does not repair completed historical outbox or diary records. Those records remain evidence of the missed gate. The mechanism gates future occurrences and the current run's durable completion records.

Return-to-main judgment: branch-local. The checker is focused and fixture-backed, but it changes the supervisor commit path. It should not be treated as family-genome evidence until a next checked-out supervisor activation report includes `portable-content-check: ok` for a completed run.

## Activation Repair

The next run inspected `.self-harness/tmp/commit-gate-last-report.md` and found that the prior supervisor report did not contain `portable-content-check: ok`. That absence reopened activation proof but did not mean the checked-out source lacked the call. The failure was the proof boundary: the previous report did not yet demonstrate checked-out supervisor activation.

`scripts/supervisor-real-cycle-check.sh` now asserts that its post-run pressure sandbox's `.self-harness/tmp/commit-gate-last-report.md` contains `portable-content-check: ok` after the supervisor-owned commit path runs. Future activation claims for this gate should cite that checked-out-cycle proof and the real report produced after the repaired run.
