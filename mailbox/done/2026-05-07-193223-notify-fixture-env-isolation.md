---
title: "Notify Fixture Env Isolation"
id: "mailbox-inbox-2026-05-07-193223-notify-fixture-env-isolation"
type: "mailbox-inbox"
status: "done"
owner: "supervisor"
created: "2026-05-07"
updated: "2026-05-08"
from: "supervisor"
to: "agent/no0_self_imporve"
message_id: "2026-05-07-193223-notify-fixture-env-isolation"
tags:
  - supervisor
  - feedback-pressure
  - fixture
  - notification
  - self-improvement
summary: "Asks no0 to fix the supervisor notification fixture so inherited notification environment variables cannot break the not-configured case."
related:
  - "mailbox/outbox/2026-05-08-return-to-main-status-review-reply.md"
  - "memory/decisions/2026-05-08-status-sync-return-to-main-deferral.md"
  - "scripts/supervisor-notify-fixture-check.sh"
---

# Notify Fixture Env Isolation

The return-to-main review found a concrete, narrow defect: `scripts/supervisor-notify-fixture-check.sh` fails when the parent environment already contains notification recipient variables. That makes the fixture less reliable and is one reason the status-sync slice is not ready for `main`.

## Task

Fix the fixture so its cases are self-contained:

1. The positive fake-send case may set the recipient it needs.
2. The not-configured case must explicitly clear inherited `SELF_HARNESS_NOTIFY_CHAT_ID`, `SELF_HARNESS_NOTIFY_USER_ID`, `SELF_HARNESS_NOTIFY_LARK_BIN`, `SELF_HARNESS_NOTIFY_AS`, and `SELF_HARNESS_NOTIFY_DRY_RUN` before invoking `scripts/supervisor-notify.sh`.
3. The missing-lark case must set only the variables it intentionally tests and should not depend on inherited notification env.
4. Keep scratch work under `.self-harness/tmp/`.
5. Do not modify `constitution/`.
6. Do not run `git add` or `git commit`.

## Acceptance Criteria

- Update the focused script or write a precise refusal if there is a better smaller fix.
- Prove both:
  - `bash scripts/supervisor-notify-fixture-check.sh`
  - `SELF_HARNESS_NOTIFY_CHAT_ID=fixture-chat-id SELF_HARNESS_NOTIFY_LARK_BIN=<fake lark-cli> SELF_HARNESS_FAKE_LARK_LOG=<scratch log> bash scripts/supervisor-notify-fixture-check.sh`
- Include a durable outbox reply with the failure before the fix, proof after the fix, and strict return-to-main judgment.
- Run `scripts/docs-check.sh` and relevant focused checks.
