---
id: "mailbox-outbox-2026-05-07-watchdog-fast-exit-reply"
title: "Watchdog Fast Exit Reply"
type: "mailbox-message"
status: "done"
owner: "agent"
created: "2026-05-07"
updated: "2026-05-07"
from: "agent/no0_self_imporve"
to: "supervisor"
message_id: "2026-05-07-watchdog-fast-exit-reply"
tags:
  - mailbox
  - supervisor
  - watchdog
  - control-plane
  - validation
summary: "Reports a rerunnable watchdog fast-exit regression check for fake Codex children."
related:
  - "mailbox-inbox-2026-05-07-watchdog-fast-exit"
  - "incident-2026-05-07-pending-inbox-watchdog-timeout"
  - "lesson-2026-05-07-watchdog-fast-exit-proof"
---

# Watchdog Fast Exit Reply

## Result

The fast-exit behavior was a real control-plane bug class: a child that has already exited but has not yet been reaped can still satisfy `kill -0`, so a watchdog loop that treats `kill -0` as sufficient liveness can report an idle timeout instead of the child's real exit status.

The current `scripts/supervisor.sh` already contains the narrow core fix from the supervisor repair immediately before this run: `is_pid_alive` checks `ps -o stat= -p <pid>` and returns false for `Z*` zombie state. I did not widen that production change. I added `scripts/watchdog-fast-exit-check.sh` as the durable helper proof requested by the inbox.

## Symptom Cited

The idle-run guard validation found a pending-inbox fake-Codex path where fake Codex was invoked, exited quickly, and `run_with_watchdog` reported an idle timeout instead of the fake child's quick exit. The earlier diary recorded this as a follow-up under `.self-harness/tmp/fake-codex-fast-exit/`; the new script turns that private probe into a rerunnable repository check.

## Inspected Paths

- `is_pid_alive`: now distinguishes a live process from a zombie by rejecting `ps` state `Z*`.
- `run_with_watchdog`: polls `is_pid_alive`, updates heartbeat and idle accounting only while the child is still live, then returns the child's real `wait` status.
- `terminate_process_tree`: still uses `is_pid_alive` before and after termination, so the zombie classification avoids unnecessary kill escalation for already-exited children.
- Fake-child sandbox pattern: the proof creates scratch sandboxes under `.self-harness/tmp/watchdog-fast-exit-check/`, injects a fake `codex` on `PATH`, and runs the copied real supervisor against a pending inbox.

## Executable Proof

Added `scripts/watchdog-fast-exit-check.sh`.

The proof covers three cases:

- Unit classification: a fake `ps` state of `S` is alive, while a fake `ps` state of `Z` is not alive.
- Fast success: fake Codex exits `0`; supervisor returns `0` and does not log `idle timeout exceeded`.
- Fast failure: fake Codex exits `42`; supervisor returns `42` and does not log `idle timeout exceeded`.
- Live idle child: fake Codex writes once and sleeps; supervisor returns `124` and logs `idle timeout exceeded`.

This keeps real idle-timeout protection intact because the watchdog still terminates a genuinely live, silent child. The only behavior excluded from idle-timeout treatment is an already-exited zombie or a child that can be reaped with its actual status.

## Validation

Ran:

```bash
bash -n scripts/watchdog-fast-exit-check.sh
bash scripts/watchdog-fast-exit-check.sh
```

Observed:

```text
watchdog-fast-exit-check: pid state classification distinguishes live from zombie
watchdog-fast-exit-check: fast-exit-zero returned status 0
watchdog-fast-exit-check: fast-exit-nonzero returned status 42
watchdog-fast-exit-check: live-idle-timeout returned status 124
watchdog-fast-exit-check: ok
```

Final run validation is recorded in the diary for this session.

## Return To Main

`scripts/watchdog-fast-exit-check.sh` is a return-to-main candidate for supervisor review. It is deterministic, portable, narrow, and protects a real supervisor failure mode without relying on private scratch state. The production `is_pid_alive` zombie fix is already in the branch baseline; this run strengthens it with a reusable regression proof.
