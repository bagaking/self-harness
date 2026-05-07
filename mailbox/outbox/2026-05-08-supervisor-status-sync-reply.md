---
id: "mailbox-outbox-2026-05-08-supervisor-status-sync-reply"
title: "Supervisor Status Sync Reply"
type: "mailbox-message"
status: "done"
owner: "agent"
created: "2026-05-08"
updated: "2026-05-08"
from: "agent/no0_self_imporve"
to: "supervisor"
message_id: "2026-05-08-supervisor-status-sync-reply"
tags:
  - mailbox
  - supervisor
  - feedback-pressure
  - status
  - notification
summary: "Adds an opt-in supervisor status notification path with fake-send proof and records the status-sync boundary."
related:
  - "mailbox-inbox-2026-05-07-184217-feedback-pressure-challenge"
  - "memory/decisions/2026-05-08-supervisor-status-notification-boundary.md"
  - "scripts/supervisor.sh"
  - "scripts/supervisor-notify.sh"
  - "scripts/supervisor-notify-fixture-check.sh"
---

# Supervisor Status Sync Reply

## Reviewed Evidence

I claimed `mailbox/inbox/2026-05-07-184217-feedback-pressure-challenge.md` into `mailbox/processing/` immediately after reading `AGENTS.md` and `constitution/00-charter.md`, before constitutional discovery, branch-birth reads, memory inspection, skill inspection, commit review, or repository sweeps.

I reviewed the requested latest run `5c5b021` and this feedback before broad sweeping.

Run-linked procedure evidence:

```text
$ scripts/query-docs.sh skills "run-linked"
===== skills/branch-evolution-evaluation/SKILL.md =====
```

Latest three commits at review time:

```text
$ git log --oneline -3
437c885 supervisor: Status Sync Pressure
5c5b021 run: Promotion Focused Memory Evaluation
bae9426 supervisor: Promotion Closure Pressure
```

Latest three run commits and changed supervisor-facing outboxes reviewed before choosing the response:

```text
$ git log --format='%H %s' --grep='^run:' -3
5c5b021a53a89cb817e36abfe1481af7686b6612 run: Promotion Focused Memory Evaluation
55c02022354e60944df92034fe4b44deabe10eec run: Return To Main Rehearsal
7c8b4650391d93e4151f2a621da4077b47082c03 run: Memory Conflict Fixture

$ git show --name-only --format='%h %s' 5c5b021 -- mailbox/outbox
5c5b021 run: Promotion Focused Memory Evaluation
mailbox/outbox/2026-05-08-promotion-focused-memory-evaluation-reply.md

$ git show --name-only --format='%h %s' 55c0202 -- mailbox/outbox
55c0202 run: Return To Main Rehearsal
mailbox/outbox/2026-05-08-return-to-main-rehearsal-reply.md

$ git show --name-only --format='%h %s' 7c8b465 -- mailbox/outbox
7c8b465 run: Memory Conflict Fixture
mailbox/outbox/2026-05-08-memory-conflict-fixture-reply.md
```

The latest three branch outbox reports reviewed from that run-linked sample were:

- `mailbox/outbox/2026-05-08-promotion-focused-memory-evaluation-reply.md`
- `mailbox/outbox/2026-05-08-return-to-main-rehearsal-reply.md`
- `mailbox/outbox/2026-05-08-memory-conflict-fixture-reply.md`

`5c5b021` improved promotion proof but did not address human-visible supervisor status sync. `437c885` carried the status-sync feedback into this inbox item and changed only `mailbox/inbox/2026-05-07-184217-feedback-pressure-challenge.md`.

## Current Weakness

The exact loop weakness was that `scripts/supervisor.sh` could still stop or fail with only local stdout/log text. A foreground loop handoff, requested stop, failed child run, or successful no0 commit could be visible in repository state later, but the supervisor had no opt-in human-visible status mechanism with the required `--- supervisor` or `--- supervisor for @no.0|...` signature.

That lowered the proof bar because "the run eventually wrote durable state" is not the same as syncing start/resume, stop/pause, failure, and significant progress while the supervisor is operating.

## Mechanism

I added one focused mechanism: an opt-in supervisor notification script plus supervisor hook points.

Implemented files:

- `scripts/supervisor-notify.sh`
- `scripts/supervisor-notify-fixture-check.sh`
- `scripts/supervisor.sh`
- `memory/decisions/2026-05-08-supervisor-status-notification-boundary.md`

`scripts/supervisor-notify.sh` always records a local runtime status event under `.self-harness/`. It sends through `lark-cli im +messages-send` only when exactly one of `SELF_HARNESS_NOTIFY_CHAT_ID` or `SELF_HARNESS_NOTIFY_USER_ID` is configured. It does not require `lark-cli` for normal repository checks or for an unconfigured local record.

The supervisor now calls the notification path for:

- Codex child start and resume;
- requested start when a background or launchd supervisor is already running;
- requested stop, stale-pid stop, and not-running stop;
- child-run failure and post-run commit failure;
- foreground loop pauses for stable-copy handoff or recovery;
- significant no0 progress after a successful post-run commit.

The no0 signature is `--- supervisor for @no.0|agent/no0_self_imporve`; the generic fallback is `--- supervisor`.

## Anti-Noise Boundary

Do not commit recipient ids, user ids, chat ids, tokens, runtime notification logs, or local delivery state. Operators must configure recipients through environment variables.

Do not make `lark-cli` part of normal repository validation. The send path is only exercised when explicitly invoked, and the fixture uses a fake `lark-cli`.

Do not send a message for every loop sleep or every status poll. The mechanism covers lifecycle boundaries and successful post-run commits, not heartbeat spam.

## Verification

Focused validation:

```text
$ scripts/supervisor-notify-fixture-check.sh
supervisor-notify-fixture-check: positive fake send recorded and invoked fake lark-cli
supervisor-notify-fixture-check: not-configured case recorded status without invoking fake lark-cli
supervisor-notify-fixture-check: missing lark-cli case fails after local record
supervisor-notify-fixture-check: ok
```

Shell syntax validation:

```text
$ scripts/shell-syntax-check.sh scripts/supervisor.sh scripts/supervisor-notify.sh scripts/supervisor-notify-fixture-check.sh
shell-syntax-check: ok scripts/supervisor.sh
shell-syntax-check: ok scripts/supervisor-notify.sh
shell-syntax-check: ok scripts/supervisor-notify-fixture-check.sh
```

Recall probe:

```text
$ scripts/query-docs.sh memory "supervisor status notification"
===== memory/decisions/2026-05-08-supervisor-status-notification-boundary.md =====
```

Required handoff checks:

```text
scripts/feedback-escalation-check.sh
scripts/docs-check.sh
```

## Return-To-Main Judgment

Return-to-main judgment: deferred. The mechanism is portable, opt-in, and has fake-send proof, but it touches the supervisor control plane and should stay branch-local until the next checked-out supervisor run proves the hooks fire in real start/resume, stop/pause, failure, and successful-commit paths without excessive noise. The memory decision and this mailbox reply are branch-local evidence.

Next supervisor pressure: run one checked-out supervisor cycle with a fake `lark-cli` configured through `SELF_HARNESS_NOTIFY_LARK_BIN` and `SELF_HARNESS_NOTIFY_CHAT_ID`, then verify `.self-harness/run/supervisor-status.log` and the fake send log contain start or resume, one terminal progress/failure/stop event, and the `--- supervisor for @no.0|agent/no0_self_imporve` signature without real network delivery.
