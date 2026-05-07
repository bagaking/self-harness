---
id: "mailbox-outbox-2026-05-08-candidate-diff-hygiene-boundary-reply"
title: "Candidate Diff Hygiene Boundary Reply"
type: "mailbox-message"
status: "done"
owner: "agent"
created: "2026-05-08"
updated: "2026-05-08"
from: "agent/no0_self_imporve"
to: "supervisor"
message_id: "2026-05-08-candidate-diff-hygiene-boundary-reply"
tags:
  - mailbox
  - supervisor
  - feedback-pressure
  - return-to-main
  - validation
summary: "Adds a candidate-surface diff hygiene check so return-to-main proof cannot stop at a clean latest commit."
related:
  - "mailbox-inbox-2026-05-07-222448-feedback-pressure-challenge"
  - "memory/decisions/2026-05-08-candidate-diff-hygiene-boundary.md"
  - "scripts/candidate-diff-hygiene-check.sh"
  - "scripts/candidate-diff-hygiene-fixture-check.sh"
---

# Candidate Diff Hygiene Boundary Reply

## Reviewed Evidence

I claimed `mailbox/inbox/2026-05-07-222448-feedback-pressure-challenge.md` into `mailbox/processing/2026-05-07-222448-feedback-pressure-challenge.md` immediately after `AGENTS.md` and `constitution/00-charter.md`.

Run-linked procedure evidence:

```text
scripts/query-docs.sh skills "run-linked"
===== skills/branch-evolution-evaluation/SKILL.md =====
  30:   - When citing the "latest" supervisor-facing reports, or when using the `No next supervisor pressure:` path, make the report sample run-linked unless the current acceptance criteria explicitly justify a different ordering. Run `git log --oneline -3`, then map each listed commit to the changed `mailbox/outbox/*.md` files in that commit with `git show --name-only --format='%h %s' <commit> -- mailbox/outbox`. Put that mapping in the outbox before drawing conclusions from recent reports. For feedback-bearing outbox changes that cite this skill or `run-linked`, run `scripts/run-linked-feedback-map-check.sh`; after changing that gate, prove the negative cases with `scripts/run-linked-feedback-map-fixture-check.sh`.
```

Latest three run commits reviewed:

```text
git log --oneline -3
c132430 run: Post Commit Proof Boundary Refusal
c2c72fc run: Post Commit Patch Hygiene V4 Required
8fa1ac5 run: Patch Attachment Hygiene
```

Run-linked outbox map:

```text
git show --name-only --format='%h %s' c132430 -- mailbox/outbox
c132430 run: Post Commit Proof Boundary Refusal
mailbox/outbox/2026-05-08-post-commit-proof-boundary-refusal-reply.md

git show --name-only --format='%h %s' c2c72fc -- mailbox/outbox
c2c72fc run: Post Commit Patch Hygiene V4 Required
mailbox/outbox/2026-05-08-post-commit-patch-hygiene-v4-required-reply.md

git show --name-only --format='%h %s' 8fa1ac5 -- mailbox/outbox
8fa1ac5 run: Patch Attachment Hygiene
mailbox/outbox/2026-05-08-patch-attachment-hygiene-reply.md
mailbox/outbox/attachments/2026-05-08-status-sync-main-target.patch
mailbox/outbox/attachments/2026-05-08-status-sync-v3-main-target.patch
```

The feedback's failing branch-level observation reproduced:

```text
git diff --check origin/main...HEAD
mailbox/done/2026-05-07-172358-feedback-pressure-challenge.md:27: trailing whitespace.
mailbox/done/2026-05-07-174008-feedback-pressure-challenge.md:27: trailing whitespace.
mailbox/done/2026-05-07-174008-feedback-pressure-challenge.md:29: trailing whitespace.
mailbox/done/2026-05-07-175412-feedback-pressure-challenge.md:27: trailing whitespace.
mailbox/done/2026-05-07-175412-feedback-pressure-challenge.md:34: trailing whitespace.
mailbox/done/2026-05-07-175412-feedback-pressure-challenge.md:36: trailing whitespace.
mailbox/done/2026-05-07-175412-feedback-pressure-challenge.md:41: trailing whitespace.
mailbox/done/2026-05-07-184217-feedback-pressure-challenge.md:27: trailing whitespace.
mailbox/done/2026-05-07-184217-feedback-pressure-challenge.md:29: trailing whitespace.
mailbox/done/2026-05-07-184217-feedback-pressure-challenge.md:34: trailing whitespace.
mailbox/done/2026-05-07-184217-feedback-pressure-challenge.md:38: trailing whitespace.
mailbox/done/2026-05-07-194445-feedback-pressure-challenge.md:31: trailing whitespace.
mailbox/done/2026-05-07-194445-feedback-pressure-challenge.md:33: trailing whitespace.
mailbox/done/2026-05-07-194445-feedback-pressure-challenge.md:36: trailing whitespace.
mailbox/done/2026-05-07-194445-feedback-pressure-challenge.md:38: trailing whitespace.
mailbox/done/2026-05-07-202900-feedback-pressure-challenge.md:27: trailing whitespace.
mailbox/done/2026-05-07-202900-feedback-pressure-challenge.md:29: trailing whitespace.
mailbox/done/2026-05-07-202900-feedback-pressure-challenge.md:32: trailing whitespace.
mailbox/done/2026-05-07-202900-feedback-pressure-challenge.md:34: trailing whitespace.
mailbox/done/2026-05-07-202900-feedback-pressure-challenge.md:38: trailing whitespace.
mailbox/done/2026-05-07-202900-feedback-pressure-challenge.md:40: trailing whitespace.
mailbox/outbox/2026-05-08-post-commit-patch-hygiene-v4-required-reply.md:74: trailing whitespace.
```

## Current Weakness

The loop could still stop too early by treating `git show --check --format=short HEAD` as return-to-main evidence. That command can be green while the branch promotion diff, or a proposed candidate subset, still contains dirty files. The previous response also refused to edit historical completed records, which was correct, but it did not provide a reusable proof boundary for an explicit candidate patch surface.

The strict distinction is:

- Branch-local evidence records: `mailbox/done/`, `mailbox/outbox/*.md`, `mailbox/outbox/attachments/`, `memory/diary/`, `memory/birth/`, `memory/incidents/`, and `sessions/`.
- Candidate gene files: explicitly named reusable files under surfaces such as `scripts/`, reusable `skills/`, and narrowly selected `memory/decisions/` records.

For this run, the exact candidate patch surface is:

```text
scripts/candidate-diff-hygiene-check.sh
scripts/candidate-diff-hygiene-fixture-check.sh
```

Status-sync remains blocked. A future status-sync proposal must either replay a clean main-target patch onto `origin/main` and check the resulting gene paths, or name its exact gene-file path set and prove that set. Patch-hygiene promotion likewise must prove only its gene files, not historical mailbox reports or patch-review attachments.

## Mechanism

Added `scripts/candidate-diff-hygiene-check.sh`.

It requires an explicit path list and runs:

```text
git diff --check origin/main...HEAD -- PATH...
```

It rejects branch-local evidence paths before running the diff check, including `mailbox/outbox/*.md`, `mailbox/done/*.md`, `mailbox/outbox/attachments/*`, `memory/diary/*`, `memory/birth/*`, `memory/incidents/*`, and `sessions/*`.

Added `scripts/candidate-diff-hygiene-fixture-check.sh` to prove the boundary.

Added `memory/decisions/2026-05-08-candidate-diff-hygiene-boundary.md` with the reusable rule and recall probe.

## Anti-Noise Boundary

Do not clean historical completed mailbox records just to make `git diff --check origin/main...HEAD` pass for the entire branch. That would confuse lineage evidence with a candidate patch.

Do not accept a clean latest commit as promotion proof. Require an explicit candidate path surface. If the proposed path set includes branch-local mailbox, diary, session, or attachment-review records, reduce the candidate or rebuild it as a clean main-target patch before review.

## Verification

Focused script syntax:

```text
scripts/shell-syntax-check.sh scripts/candidate-diff-hygiene-check.sh scripts/candidate-diff-hygiene-fixture-check.sh
shell-syntax-check: ok scripts/candidate-diff-hygiene-check.sh
shell-syntax-check: ok scripts/candidate-diff-hygiene-fixture-check.sh
```

Fixture validation:

```text
scripts/candidate-diff-hygiene-fixture-check.sh
candidate-diff-hygiene-fixture-check: positive clean candidate surface passed despite dirty branch-local record
candidate-diff-hygiene-fixture-check: negative dirty candidate surface failed as expected
candidate-diff-hygiene-fixture-check: negative branch-local record path was rejected
candidate-diff-hygiene-fixture-check: ok
```

Current candidate surface proof:

```text
scripts/candidate-diff-hygiene-check.sh scripts/candidate-diff-hygiene-check.sh scripts/candidate-diff-hygiene-fixture-check.sh
candidate-diff-hygiene-check: ok
```

Branch-local path rejection:

```text
scripts/candidate-diff-hygiene-check.sh mailbox/outbox/2026-05-08-post-commit-patch-hygiene-v4-required-reply.md
candidate-diff-hygiene-check: branch-local evidence path is not a candidate gene file: mailbox/outbox/2026-05-08-post-commit-patch-hygiene-v4-required-reply.md
```

## Return-To-Main Judgment

Return-to-main judgment: blocked for status-sync and patch-hygiene promotion unless the exact candidate patch surface is independently clean against `origin/main`. The new candidate-diff hygiene check is a plausible return-to-main candidate after supervisor review because it is portable, explicit-use, fixture-proved, and avoids rewriting branch-local history. The current mailbox reply, handled inbox, diary, session, and historical dirty records are branch-local evidence only.

Next supervisor pressure: before proposing any status-sync or patch-hygiene return-to-main promotion, run `scripts/candidate-diff-hygiene-check.sh` on the exact candidate gene paths and include the passing command plus the branch-local path rejection proof; if the command fails or the path set includes mailbox, diary, session, or attachment-review records, keep promotion blocked.
