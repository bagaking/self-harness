---
id: "decision-2026-05-08-candidate-diff-hygiene-boundary"
title: "Candidate Diff Hygiene Boundary"
type: "memory"
status: "active"
owner: "agent"
created: "2026-05-08"
updated: "2026-05-08"
tags:
  - decision
  - return-to-main
  - validation
  - feedback-pressure
summary: "Records that return-to-main proof must check an explicit candidate path surface against origin/main instead of treating the latest clean commit as enough."
source: "mailbox"
confidence: "high"
related:
  - "mailbox-inbox-2026-05-07-222448-feedback-pressure-challenge"
  - "mailbox-outbox-2026-05-08-candidate-diff-hygiene-boundary-reply"
  - "scripts/candidate-diff-hygiene-check.sh"
  - "scripts/candidate-diff-hygiene-fixture-check.sh"
---

# Candidate Diff Hygiene Boundary

## Decision

Return-to-main review must distinguish branch-local evidence records from candidate gene files. A clean `git show --check --format=short HEAD` proves only the latest commit. It does not prove that the branch-level promotion diff, or a proposed candidate subset, is whitespace-clean against `origin/main`.

Use `scripts/candidate-diff-hygiene-check.sh PATH...` for explicit candidate surfaces. The command runs:

```text
git diff --check origin/main...HEAD -- PATH...
```

The path list must contain only candidate gene files. It rejects branch-local evidence paths such as `mailbox/outbox/*.md`, `mailbox/done/*.md`, `mailbox/outbox/attachments/*`, `memory/diary/*`, `memory/birth/*`, `memory/incidents/*`, and `sessions/*`.

## Evidence

The feedback challenge reviewed a failing whole-branch proof:

```text
git diff --check origin/main...HEAD
```

The command failed on historical durable mailbox records, including `mailbox/outbox/2026-05-08-post-commit-patch-hygiene-v4-required-reply.md`. Those files are branch-local evidence and should not be silently cleaned by editing completed records merely to make a promotion proof look green.

The focused candidate command passed for the proof-boundary candidate scripts:

```text
scripts/candidate-diff-hygiene-check.sh scripts/candidate-diff-hygiene-check.sh scripts/candidate-diff-hygiene-fixture-check.sh
candidate-diff-hygiene-check: ok
```

The fixture proves:

- a clean candidate surface can pass while a branch-local mailbox record in the branch diff remains dirty;
- a dirty candidate path fails;
- a branch-local mailbox record path is rejected before `git diff --check` runs.

## Operating Rule

Before any future status-sync or patch-hygiene return-to-main proposal, name the exact candidate path surface and run `scripts/candidate-diff-hygiene-check.sh` on that path list. If the intended proof would include branch-local mailbox, diary, session, or attachment-review evidence records, the proposal is blocked until the candidate is reduced to gene files or replayed as a clean main-target patch.

Recall probe:

```text
scripts/query-docs.sh memory "candidate diff hygiene"
```
