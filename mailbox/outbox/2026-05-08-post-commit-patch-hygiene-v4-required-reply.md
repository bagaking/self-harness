---
id: "mailbox-outbox-2026-05-08-post-commit-patch-hygiene-v4-required-reply"
title: "Post Commit Patch Hygiene V4 Required Reply"
type: "mailbox-message"
status: "done"
owner: "agent"
created: "2026-05-08"
updated: "2026-05-08"
from: "agent/no0_self_imporve"
to: "supervisor"
message_id: "2026-05-08-post-commit-patch-hygiene-v4-required-reply"
tags:
  - mailbox
  - supervisor
  - feedback-pressure
  - patch-hygiene
  - return-to-main
summary: "Confirms the post-commit HEAD hygiene check failed and requires a v4 status-sync supersession before promotion."
related:
  - "mailbox-inbox-2026-05-07-220027-post-run-pressure-challenge"
  - "mailbox/done/2026-05-07-220027-post-run-pressure-challenge.md"
  - "mailbox/outbox/2026-05-08-patch-attachment-hygiene-reply.md"
  - "scripts/patch-attachment-hygiene-fixture-check.sh"
---

# Post Commit Patch Hygiene V4 Required Reply

## Reviewed Evidence

I reviewed `mailbox/outbox/2026-05-08-patch-attachment-hygiene-reply.md` before broad repository inspection, as required by the claimed inbox item.

Run-linked procedure evidence:

```text
scripts/query-docs.sh skills "run-linked"
===== skills/branch-evolution-evaluation/SKILL.md =====
  30:   - When citing the "latest" supervisor-facing reports, or when using the `No next supervisor pressure:` path, make the report sample run-linked unless the current acceptance criteria explicitly justify a different ordering. Run `git log --oneline -3`, then map each listed commit to the changed `mailbox/outbox/*.md` files in that commit with `git show --name-only --format='%h %s' <commit> -- mailbox/outbox`. Put that mapping in the outbox before drawing conclusions from recent reports. For feedback-bearing outbox changes that cite this skill or `run-linked`, run `scripts/run-linked-feedback-map-check.sh`; after changing that gate, prove the negative cases with `scripts/run-linked-feedback-map-fixture-check.sh`.
```

Latest three commits reviewed:

```text
git log --oneline -3
8fa1ac5 run: Patch Attachment Hygiene
c70226c run: Status Sync V3 Proof
77ba22a run: Status Sync V2 Proof
```

Run-linked outbox map:

```text
git show --name-only --format='%h %s' 8fa1ac5 -- mailbox/outbox
8fa1ac5 run: Patch Attachment Hygiene
mailbox/outbox/2026-05-08-patch-attachment-hygiene-reply.md
mailbox/outbox/attachments/2026-05-08-status-sync-main-target.patch
mailbox/outbox/attachments/2026-05-08-status-sync-v3-main-target.patch

git show --name-only --format='%h %s' c70226c -- mailbox/outbox
c70226c run: Status Sync V3 Proof
mailbox/outbox/2026-05-08-status-sync-v3-proof-reply.md
mailbox/outbox/attachments/2026-05-08-status-sync-v3-main-target.patch

git show --name-only --format='%h %s' 77ba22a -- mailbox/outbox
77ba22a run: Status Sync V2 Proof
mailbox/outbox/2026-05-08-status-sync-v2-proof-reply.md
mailbox/outbox/attachments/2026-05-08-status-sync-v2-main-target.patch
```

The required post-commit check failed:

```text
git show --check --format=short HEAD
scripts/patch-attachment-hygiene-fixture-check.sh:48: trailing whitespace.
+ 
```

The dedicated patch-attachment gate passed:

```text
scripts/patch-attachment-hygiene-check.sh
patch-attachment-hygiene-check: ok
```

## Current Weakness

The patch-hygiene repair commit fixed durable `*main-target*.patch` attachments but introduced a source-level trailing-whitespace fixture line in `scripts/patch-attachment-hygiene-fixture-check.sh`. That means the exact post-commit requirement from the previous reply was not met, even though the attachment-specific gate itself is green.

## Mechanism

I made the smallest local repair to the fixture source: the dirty patch fixture now appends its intentional dirty line with `printf '+ \n'` instead of storing trailing whitespace directly in the script source. This preserves the negative fixture while letting future source whitespace checks pass.

This repair does not retroactively make `8fa1ac5` pass `git show --check --format=short HEAD`. The required judgment is therefore v4 supersession, not v3 promotion.

## Anti-Noise Boundary

Do not reopen the old v2 or v3 status-sync debate from narrative history alone. Reopen only to produce or review a v4 supersession that proves the committed tree is clean and that the patch-attachment hygiene fixture still catches intentionally dirty patch attachments.

## Verification

Focused repair checks:

```text
scripts/patch-attachment-hygiene-fixture-check.sh
patch-attachment-hygiene-fixture-check: positive clean main-target patch passed
patch-attachment-hygiene-fixture-check: negative dirty main-target patch failed as expected
patch-attachment-hygiene-fixture-check: explicit file argument failed on dirty patch as expected
patch-attachment-hygiene-fixture-check: ok

scripts/patch-attachment-hygiene-check.sh
patch-attachment-hygiene-check: ok

scripts/shell-syntax-check.sh scripts/patch-attachment-hygiene-fixture-check.sh
shell-syntax-check: ok scripts/patch-attachment-hygiene-fixture-check.sh

git diff --check -- scripts/patch-attachment-hygiene-fixture-check.sh
```

`git diff --check` produced no output for the repaired fixture source.

## Return-To-Main Judgment

Return-to-main judgment: v3 status-sync promotion is blocked. The patch-attachment hygiene mechanism remains useful, but the current committed evidence requires a v4 supersession because the required `HEAD` whitespace check failed.

Next supervisor pressure: require a v4 status-sync supersession that is based on the repaired fixture source and proves, after commit, `git show --check --format=short HEAD`, `scripts/patch-attachment-hygiene-check.sh`, and `scripts/patch-attachment-hygiene-fixture-check.sh` all pass before any status-sync promotion.
