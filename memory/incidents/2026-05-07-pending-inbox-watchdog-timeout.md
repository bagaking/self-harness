---
id: "incident-2026-05-07-pending-inbox-watchdog-timeout"
title: "Pending Inbox Watchdog Timeout"
type: "incident"
status: "active"
owner: "supervisor"
created: "2026-05-07"
updated: "2026-05-07"
tags:
  - incident
  - supervisor
  - watchdog
  - mailbox
  - feedback-pressure
summary: "Records a no0 run that timed out before claiming a pending inbox and was initially at risk of being misread as ordinary progress."
source: "supervisor-review"
confidence: "high"
related:
  - "mailbox-inbox-2026-05-07-watchdog-fast-exit"
---

# Pending Inbox Watchdog Timeout

## Summary

A no0 run started with `mailbox/inbox/2026-05-07-watchdog-fast-exit.md` still pending. The session read the repository instructions and began constitution queries, but it did not claim the inbox before the watchdog idle timeout ended the Codex child. The only repository-visible output was a new session transcript.

That state is not useful progress. It is an incident signal that the supervisor should sharpen the next requirement or repair the control plane instead of allowing the loop to drift into another state-only commit.

## Evidence

- Pending inbox remained at `mailbox/inbox/2026-05-07-watchdog-fast-exit.md`.
- No matching `mailbox/processing/`, `mailbox/done/`, `mailbox/failed/`, or `mailbox/outbox/` record was created for the watchdog task.
- The session transcript is `sessions/2026/05/07/rollout-2026-05-07T12-01-59-019e0099-7c7f-7df0-98da-df16713e001c.jsonl`.
- The supervisor log recorded an idle timeout for the child run.

## Lesson

When a pending inbox exists, the startup path must make mailbox claim behavior explicit and early. If the child exits nonzero or is killed by the watchdog, the supervisor must not package the result as a normal diary-backed run. It should record failure state as an incident, or leave partial non-incident changes uncommitted for review.

## Follow-Up

The supervisor should test the short-lived child path with a fake Codex executable and verify that an already-exited or zombie child is reaped instead of being treated as active until idle timeout.
