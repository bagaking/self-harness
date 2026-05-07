---
id: "mailbox-outbox-2026-05-08-notify-fixture-env-isolation-reply"
title: "Notify Fixture Env Isolation Reply"
type: "mailbox-message"
status: "done"
owner: "agent"
created: "2026-05-08"
updated: "2026-05-08"
from: "agent/no0_self_imporve"
to: "supervisor"
message_id: "2026-05-08-notify-fixture-env-isolation-reply"
tags:
  - mailbox
  - supervisor
  - feedback-pressure
  - fixture
  - notification
summary: "Fixes the supervisor notification fixture so each case clears inherited notification environment before setting case-specific variables."
related:
  - "mailbox-inbox-2026-05-07-193223-notify-fixture-env-isolation"
  - "mailbox/outbox/2026-05-08-return-to-main-status-review-reply.md"
  - "memory/decisions/2026-05-08-status-sync-return-to-main-deferral.md"
  - "memory/decisions/2026-05-08-notify-fixture-env-isolation.md"
  - "scripts/supervisor-notify-fixture-check.sh"
---

# Notify Fixture Env Isolation Reply

## Reviewed Evidence

I claimed `mailbox/inbox/2026-05-07-193223-notify-fixture-env-isolation.md` into `mailbox/processing/2026-05-07-193223-notify-fixture-env-isolation.md` immediately after reading `AGENTS.md` and `constitution/00-charter.md`, before broader constitutional discovery, branch-birth reads, memory inspection, skill inspection, commit-history review, or repository sweeps.

Run-linked procedure evidence:

```text
scripts/query-docs.sh skills "run-linked"
===== skills/branch-evolution-evaluation/SKILL.md =====
```

Latest three commits at review time:

```text
git log --oneline -3
798c150 supervisor: Notify Fixture Env Isolation
751618b run: Return To Main Status Review
b217702 supervisor: Status Return-To-Main Review
```

Latest-commit mailbox/outbox mapping:

```text
git show --name-only --format='%h %s' 798c150 -- mailbox/outbox

git show --name-only --format='%h %s' 751618b -- mailbox/outbox
751618b run: Return To Main Status Review
mailbox/outbox/2026-05-08-return-to-main-status-review-reply.md

git show --name-only --format='%h %s' b217702 -- mailbox/outbox
```

Recent run-linked run commits:

```text
git log --oneline --grep='^run:' -3
751618b run: Return To Main Status Review
25248bd run: Supervisor Cycle Proof
338d169 run: Supervisor Status Sync
```

The current supervisor challenge directly implements the blocker recorded in `mailbox/outbox/2026-05-08-return-to-main-status-review-reply.md`: the notification fixture could fail when a parent environment already configured notification recipients.

## Current Weakness

Before this patch, `scripts/supervisor-notify-fixture-check.sh` used `env` overlays inside each case but did not clear inherited notification variables first. That let a parent `SELF_HARNESS_NOTIFY_CHAT_ID` and `SELF_HARNESS_NOTIFY_LARK_BIN` force the fixture's not-configured case down the send path, so the case no longer proved the "record status without sending" behavior.

Failure before the fix:

```text
SELF_HARNESS_NOTIFY_CHAT_ID=fixture-chat-id SELF_HARNESS_NOTIFY_LARK_BIN=<scratch fake lark-cli> SELF_HARNESS_FAKE_LARK_LOG=<scratch log> bash scripts/supervisor-notify-fixture-check.sh
supervisor-notify-fixture-check: fake lark command did not use im
```

## Mechanism

Updated `scripts/supervisor-notify-fixture-check.sh` with a `clear_notification_env` helper that unsets:

- `SELF_HARNESS_NOTIFY_CHAT_ID`
- `SELF_HARNESS_NOTIFY_USER_ID`
- `SELF_HARNESS_NOTIFY_LARK_BIN`
- `SELF_HARNESS_NOTIFY_AS`
- `SELF_HARNESS_NOTIFY_DRY_RUN`

Each fixture subshell now calls that helper after entering its sandbox and before invoking `scripts/supervisor-notify.sh`. The positive case then sets only its fake-send recipient, fake log, and sandbox root; the not-configured case leaves recipients unset; the missing-lark case sets only the missing binary and the recipient needed to exercise that failure.

I also added `memory/decisions/2026-05-08-notify-fixture-env-isolation.md` so future status-sync promotion reviews can find this boundary with:

```text
scripts/query-docs.sh memory "notify fixture env isolation"
```

## Anti-Noise Boundary

Do not add another checked-out supervisor cycle for this exact fixture repair. The defect was in fixture isolation, not in the supervisor lifecycle hook, and the prior checked-out cycle proof remains the activation evidence unless `scripts/supervisor.sh`, `scripts/supervisor-notify.sh`, or the notification environment contract changes again.

Do not make real notification recipients part of repository validation. The proof uses scratch fake delivery under `.self-harness/tmp/`; durable records keep only repository-relative command shapes and normalized placeholders.

## Verification

Focused clean fixture proof:

```text
bash scripts/supervisor-notify-fixture-check.sh
supervisor-notify-fixture-check: positive fake send recorded and invoked fake lark-cli
supervisor-notify-fixture-check: not-configured case recorded status without invoking fake lark-cli
supervisor-notify-fixture-check: missing lark-cli case fails after local record
supervisor-notify-fixture-check: ok
```

Focused hostile inherited-env proof:

```text
SELF_HARNESS_NOTIFY_CHAT_ID=fixture-chat-id SELF_HARNESS_NOTIFY_LARK_BIN=<scratch fake lark-cli> SELF_HARNESS_FAKE_LARK_LOG=<scratch log> bash scripts/supervisor-notify-fixture-check.sh
supervisor-notify-fixture-check: positive fake send recorded and invoked fake lark-cli
supervisor-notify-fixture-check: not-configured case recorded status without invoking fake lark-cli
supervisor-notify-fixture-check: missing lark-cli case fails after local record
supervisor-notify-fixture-check: ok
```

Focused shell syntax:

```text
scripts/shell-syntax-check.sh scripts/supervisor-notify-fixture-check.sh scripts/supervisor-notify.sh
shell-syntax-check: ok scripts/supervisor-notify-fixture-check.sh
shell-syntax-check: ok scripts/supervisor-notify.sh
```

## Return-To-Main Judgment

Return-to-main judgment: defer the broader status-sync slice, but this fixture repair is a main-worthy prerequisite if the supervisor later asks for a fresh main-targeted status-sync patch. The repair is narrow, portable, and validated, but it does not by itself solve the earlier `scripts/supervisor.sh` apply failure against `origin/main`.

No next supervisor pressure: further escalation would be noisy until there is a fresh main-targeted status-sync patch or a real supervisor run reports missing or incorrect notification status.

Supervisor evaluation trigger: after any later patch changes `scripts/supervisor.sh`, `scripts/supervisor-notify.sh`, or notification fixture behavior, run `scripts/supervisor.sh triggers --status review` and require the review to include a clean inherited-env fixture proof plus any needed `origin/main` apply check.

Stop condition: if no status-sync code or notification environment contract changes, do not create another notification fixture isolation challenge for this same helper.
