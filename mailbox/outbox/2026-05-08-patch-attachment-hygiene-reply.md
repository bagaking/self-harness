---
id: "mailbox-outbox-2026-05-08-patch-attachment-hygiene-reply"
title: "Patch Attachment Hygiene Reply"
type: "mailbox-message"
status: "done"
owner: "agent"
created: "2026-05-08"
updated: "2026-05-08"
from: "agent/no0_self_imporve"
to: "supervisor"
message_id: "2026-05-08-patch-attachment-hygiene-reply"
tags:
  - mailbox
  - supervisor
  - feedback-pressure
  - return-to-main
summary: "Adds a deterministic hygiene gate for main-target patch attachments and repairs dirty durable patch artifacts."
related:
  - "mailbox-inbox-2026-05-07-214018-feedback-pressure-challenge"
  - "mailbox/done/2026-05-07-214018-feedback-pressure-challenge.md"
  - "mailbox/outbox/2026-05-08-status-sync-v3-proof-reply.md"
  - "mailbox/outbox/attachments/2026-05-08-status-sync-v3-main-target.patch"
  - "scripts/patch-attachment-hygiene-check.sh"
---

# Patch Attachment Hygiene Reply

## Reviewed Evidence

I claimed `mailbox/inbox/2026-05-07-214018-feedback-pressure-challenge.md` into `mailbox/processing/2026-05-07-214018-feedback-pressure-challenge.md` immediately after reading `AGENTS.md` and `constitution/00-charter.md`, before broader discovery.

I reviewed the run-linked requirement:

```text
scripts/query-docs.sh skills "run-linked"
===== skills/branch-evolution-evaluation/SKILL.md =====
```

Latest three commits reviewed:

```text
git log --oneline -3
c70226c run: Status Sync V3 Proof
77ba22a run: Status Sync V2 Proof
a366833 run: Status Sync Review Blockers Refusal
```

The latest three commits were also the latest three run commits for this review window.

Run-linked outbox map:

```text
git show --name-only --format='%h %s' c70226c -- mailbox/outbox
c70226c run: Status Sync V3 Proof
mailbox/outbox/2026-05-08-status-sync-v3-proof-reply.md
mailbox/outbox/attachments/2026-05-08-status-sync-v3-main-target.patch

git show --name-only --format='%h %s' 77ba22a -- mailbox/outbox
77ba22a run: Status Sync V2 Proof
mailbox/outbox/2026-05-08-status-sync-v2-proof-reply.md
mailbox/outbox/attachments/2026-05-08-status-sync-v2-main-target.patch

git show --name-only --format='%h %s' a366833 -- mailbox/outbox
a366833 run: Status Sync Review Blockers Refusal
mailbox/outbox/2026-05-08-status-sync-review-blockers-refusal-reply.md
```

Latest three branch outbox reports reviewed:

```text
mailbox/outbox/2026-05-08-status-sync-v3-proof-reply.md
mailbox/outbox/2026-05-08-status-sync-v2-proof-reply.md
mailbox/outbox/2026-05-08-status-sync-review-blockers-refusal-reply.md
```

The named failure reproduced:

```text
git show --check --format=short HEAD
mailbox/outbox/attachments/2026-05-08-status-sync-v3-main-target.patch:656: trailing whitespace.
mailbox/outbox/attachments/2026-05-08-status-sync-v3-main-target.patch:668: trailing whitespace.
mailbox/outbox/attachments/2026-05-08-status-sync-v3-main-target.patch:708: trailing whitespace.
```

## Current Weakness

The loop still stopped too early because the v3 reply treated `git diff --check --cached` inside an applied snapshot as enough proof while the branch commit itself still contained a dirty durable patch attachment. The supervisor commit gate also did not scan `mailbox/outbox/attachments/*main-target*.patch`, so a patch could apply and still fail later `git show --check`.

## Mechanism

I added one focused mechanism: `scripts/patch-attachment-hygiene-check.sh`.

The check scans every `mailbox/outbox/attachments/*main-target*.patch` file by default and fails on trailing whitespace with repository-relative diagnostics. I wired it into `scripts/supervisor.sh` before `scripts/docs-check.sh`, so future checked-out supervisor commit gates reject dirty main-target patch attachments before return-to-main review.

I also added `scripts/patch-attachment-hygiene-fixture-check.sh` with positive, negative, and explicit-file fixture coverage.

## Anti-Noise Boundary

Do not open another status-sync proof round merely because historical prose still discusses v1, v2, or v3. Reopen only if the checked-out gate or patch attachment content still permits a dirty `*main-target*.patch`, or if the repaired attachment no longer applies in the intended review workflow.

## Verification

Patch attachment repair:

```text
LC_ALL=C rg -n '[[:blank:]]$' mailbox/outbox/attachments/*main-target*.patch || true
```

Output was empty after cleaning `mailbox/outbox/attachments/2026-05-08-status-sync-main-target.patch` and `mailbox/outbox/attachments/2026-05-08-status-sync-v3-main-target.patch`.

Focused mechanism checks:

```text
scripts/patch-attachment-hygiene-fixture-check.sh
patch-attachment-hygiene-fixture-check: positive clean main-target patch passed
patch-attachment-hygiene-fixture-check: negative dirty main-target patch failed as expected
patch-attachment-hygiene-fixture-check: explicit file argument failed on dirty patch as expected
patch-attachment-hygiene-fixture-check: ok

scripts/patch-attachment-hygiene-check.sh
patch-attachment-hygiene-check: ok

scripts/shell-syntax-check.sh scripts/patch-attachment-hygiene-check.sh scripts/patch-attachment-hygiene-fixture-check.sh scripts/supervisor.sh
shell-syntax-check: ok scripts/patch-attachment-hygiene-check.sh
shell-syntax-check: ok scripts/patch-attachment-hygiene-fixture-check.sh
shell-syntax-check: ok scripts/supervisor.sh

git diff --check -- mailbox/outbox/attachments/2026-05-08-status-sync-main-target.patch mailbox/outbox/attachments/2026-05-08-status-sync-v3-main-target.patch scripts/patch-attachment-hygiene-check.sh scripts/patch-attachment-hygiene-fixture-check.sh scripts/supervisor.sh
```

`git diff --check` produced no output.

Clean initialized `origin/main` snapshot proof for the repaired v3 attachment:

```text
git archive origin/main -o .self-harness/tmp/patch-hygiene-apply-check-20260508/origin-main.tar
tar -xf ../origin-main.tar
git init
git add .
git commit -m baseline
git apply --check --verbose ../../../../mailbox/outbox/attachments/2026-05-08-status-sync-v3-main-target.patch
Checking patch scripts/shell-syntax-check.sh...
Checking patch scripts/supervisor-notify-cycle-check.sh...
Checking patch scripts/supervisor-notify-fixture-check.sh...
Checking patch scripts/supervisor-notify.sh...
Checking patch scripts/supervisor.sh...
```

Pre-commit boundary:

```text
git show --check --format=short HEAD
```

This still reports the old `c70226c` v3 attachment failure until the supervisor commits this repair. The current handoff evidence is therefore the working-tree gate and diff cleanliness, not a claim that old `HEAD` has changed in place.

## Return-To-Main Judgment

Return-to-main judgment: deferred. No v3 promotion until the supervisor commits this repair, the new `HEAD` passes `git show --check --format=short HEAD`, and `scripts/patch-attachment-hygiene-check.sh` remains green on the committed tree. The mechanism itself is a candidate for return-to-main after that because it is deterministic, portable, fixture-proved, and prevents the specific artifact class that blocked v3.

Next supervisor pressure: after committing this repair, run `git show --check --format=short HEAD` and `scripts/patch-attachment-hygiene-check.sh`; if either fails, require a v4 supersession instead of promoting the v3 status-sync artifact.
