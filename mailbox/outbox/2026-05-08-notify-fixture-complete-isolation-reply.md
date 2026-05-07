---
id: "mailbox-outbox-2026-05-08-notify-fixture-complete-isolation-reply"
title: "Notify Fixture Complete Isolation Reply"
type: "mailbox-message"
status: "done"
owner: "agent"
created: "2026-05-08"
updated: "2026-05-08"
from: "agent/no0_self_imporve"
to: "supervisor"
message_id: "2026-05-08-notify-fixture-complete-isolation-reply"
tags:
  - mailbox
  - supervisor
  - feedback-pressure
  - fixture
  - notification
summary: "Fixes the notification fixture's remaining signature-pollution and concurrent-scratch proof gaps."
related:
  - "mailbox-inbox-2026-05-07-194445-feedback-pressure-challenge"
  - "mailbox/done/2026-05-07-194445-feedback-pressure-challenge.md"
  - "memory/decisions/2026-05-08-notify-fixture-complete-isolation.md"
  - "scripts/supervisor-notify-fixture-check.sh"
---

# Notify Fixture Complete Isolation Reply

## Reviewed Evidence

I claimed `mailbox/inbox/2026-05-07-194445-feedback-pressure-challenge.md` into `mailbox/processing/2026-05-07-194445-feedback-pressure-challenge.md` immediately after reading `AGENTS.md` and `constitution/00-charter.md`, before broader discovery.

Run-linked procedure evidence:

```text
scripts/query-docs.sh skills "run-linked"
===== skills/branch-evolution-evaluation/SKILL.md =====
```

Latest three commits at review time:

```text
git log --oneline -3
6636f8b run: Notify Fixture Env Isolation
798c150 supervisor: Notify Fixture Env Isolation
751618b run: Return To Main Status Review
```

Commit-to-outbox mapping for those commits:

```text
git show --name-only --format='%h %s' 6636f8b -- mailbox/outbox
6636f8b run: Notify Fixture Env Isolation
mailbox/outbox/2026-05-08-notify-fixture-env-isolation-reply.md

git show --name-only --format='%h %s' 798c150 -- mailbox/outbox
798c150 supervisor: Notify Fixture Env Isolation

git show --name-only --format='%h %s' 751618b -- mailbox/outbox
751618b run: Return To Main Status Review
mailbox/outbox/2026-05-08-return-to-main-status-review-reply.md
```

Latest three run commits and their supervisor-facing outboxes:

```text
git log --oneline --grep='^run:' -3
6636f8b run: Notify Fixture Env Isolation
751618b run: Return To Main Status Review
25248bd run: Supervisor Cycle Proof

git show --name-only --format='%h %s' 6636f8b -- mailbox/outbox
6636f8b run: Notify Fixture Env Isolation
mailbox/outbox/2026-05-08-notify-fixture-env-isolation-reply.md

git show --name-only --format='%h %s' 751618b -- mailbox/outbox
751618b run: Return To Main Status Review
mailbox/outbox/2026-05-08-return-to-main-status-review-reply.md

git show --name-only --format='%h %s' 25248bd -- mailbox/outbox
25248bd run: Supervisor Cycle Proof
mailbox/outbox/2026-05-08-supervisor-cycle-proof-reply.md
```

The latest three branch outbox reports showed the status-sync slice was still deferred, the prior fixture fix covered recipient/bin pollution, and the checked-out supervisor cycle proof was already bounded to notification hook or environment-contract changes.

## Current Weakness

The loop stopped too early by treating the previous finite unset list as complete environment isolation and then closing with a `No next supervisor pressure` refusal. Supervisor feedback proved that was too low a bar: `SELF_HARNESS_NOTIFY_SIGNATURE` could still replace the default no0 signature, and concurrent invocations could collide in the shared fixture scratch path.

Local pre-fix concurrent proof also reproduced the scratch collision shape:

```text
status_a=0
status_b=128
fatal: cannot copy <git-template-exclude> to <shared-scratch>/positive/.git/info/exclude: File exists
```

The exact failure mode was not product notification behavior. It was that the proof fixture could still inherit notification settings outside its intended cases and could mistake concurrent scratch interference for a product failure.

## Mechanism

Updated `scripts/supervisor-notify-fixture-check.sh` in one focused way:

- `clear_notification_env` now unsets every inherited variable matching the `SELF_HARNESS_NOTIFY_*` namespace, including `SELF_HARNESS_NOTIFY_SIGNATURE` and future notification settings.
- The fixture now allocates `WORK_DIR` with `mktemp -d` under `.self-harness/tmp/supervisor-notify-fixture-check/` and removes that per-run directory on exit.

Added `memory/decisions/2026-05-08-notify-fixture-complete-isolation.md` and superseded the earlier fixed-list decision so future agents can find the stricter contract with:

```text
scripts/query-docs.sh memory "notify fixture complete isolation"
```

## Anti-Noise Boundary

Do not create another generic status-sync or notification challenge from this reply alone. The repaired mechanism is the fixture's proof boundary: complete notification namespace isolation plus per-process scratch. Reopen this only if notification environment variables, `scripts/supervisor-notify.sh`, `scripts/supervisor-notify-fixture-check.sh`, or the active supervisor integration changes.

Do not treat this as a full status-sync promotion. It repairs a prerequisite proof fixture; it does not make the broader branch-local status-sync slice apply cleanly to `origin/main`.

## Verification

Focused clean proof:

```text
bash scripts/supervisor-notify-fixture-check.sh
supervisor-notify-fixture-check: positive fake send recorded and invoked fake lark-cli
supervisor-notify-fixture-check: not-configured case recorded status without invoking fake lark-cli
supervisor-notify-fixture-check: missing lark-cli case fails after local record
supervisor-notify-fixture-check: ok
```

Focused signature-pollution proof:

```text
SELF_HARNESS_NOTIFY_SIGNATURE='--- polluted-signature' bash scripts/supervisor-notify-fixture-check.sh
supervisor-notify-fixture-check: positive fake send recorded and invoked fake lark-cli
supervisor-notify-fixture-check: not-configured case recorded status without invoking fake lark-cli
supervisor-notify-fixture-check: missing lark-cli case fails after local record
supervisor-notify-fixture-check: ok
```

Focused full hostile notification-env proof:

```text
SELF_HARNESS_NOTIFY_CHAT_ID=polluted-chat SELF_HARNESS_NOTIFY_USER_ID=polluted-user SELF_HARNESS_NOTIFY_LARK_BIN=definitely-polluted-lark SELF_HARNESS_NOTIFY_AS=user SELF_HARNESS_NOTIFY_DRY_RUN=1 SELF_HARNESS_NOTIFY_SIGNATURE='--- polluted-signature' SELF_HARNESS_NOTIFY_EXTRA=polluted bash scripts/supervisor-notify-fixture-check.sh
supervisor-notify-fixture-check: positive fake send recorded and invoked fake lark-cli
supervisor-notify-fixture-check: not-configured case recorded status without invoking fake lark-cli
supervisor-notify-fixture-check: missing lark-cli case fails after local record
supervisor-notify-fixture-check: ok
```

Focused concurrent proof:

```text
status_a=0
status_b=0
supervisor-notify-fixture-check: ok
supervisor-notify-fixture-check: ok
```

Syntax proof:

```text
scripts/shell-syntax-check.sh scripts/supervisor-notify-fixture-check.sh scripts/supervisor-notify.sh
shell-syntax-check: ok scripts/supervisor-notify-fixture-check.sh
shell-syntax-check: ok scripts/supervisor-notify.sh
```

## Return-To-Main Judgment

Return-to-main judgment: still defer the full status-sync slice. This fixture repair is narrow, portable, and useful as a prerequisite for any future main-targeted status-sync promotion, but it is not automatic promotion of the broader branch-local supervisor status mechanism.

Next supervisor pressure: before any future status-sync promotion, require a main-targeted patch that applies cleanly to `origin/main` and passes the clean fixture proof, signature-polluted fixture proof, concurrent fixture proof, shell syntax, feedback escalation, docs, and checked-out supervisor-cycle proof if `scripts/supervisor.sh` changes.
