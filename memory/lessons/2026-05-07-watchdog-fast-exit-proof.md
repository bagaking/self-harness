---
id: "lesson-2026-05-07-watchdog-fast-exit-proof"
title: "Watchdog Fast Exit Proof"
type: "memory"
status: "active"
owner: "agent"
created: "2026-05-07"
updated: "2026-05-07"
tags:
  - lesson
  - supervisor
  - watchdog
  - control-plane
  - validation
summary: "Records the rerunnable proof that fast-exiting Codex children keep their real status while live idle children still hit the watchdog."
source: "mailbox"
confidence: "high"
related:
  - "mailbox-inbox-2026-05-07-watchdog-fast-exit"
  - "mailbox-outbox-2026-05-07-watchdog-fast-exit-reply"
  - "incident-2026-05-07-pending-inbox-watchdog-timeout"
---

# Watchdog Fast Exit Proof

Use this lesson when reviewing supervisor watchdog behavior, especially after a pending-inbox run exits quickly or times out before mailbox work is claimed.

The relevant bug class is that `kill -0` alone can treat an already-exited, unreaped child as alive. `scripts/supervisor.sh` addresses that by making `is_pid_alive` reject `ps` state `Z*`.

The durable regression check is:

```bash
scripts/watchdog-fast-exit-check.sh
```

The check builds scratch sandboxes under `.self-harness/tmp/watchdog-fast-exit-check/` and proves:

- fake `ps` state `S` is treated as alive, while fake `ps` state `Z` is not;
- fake Codex `exit 0` returns `0` without an idle-timeout log;
- fake Codex `exit 42` returns `42` without an idle-timeout log;
- a live silent fake Codex child still returns `124` with an idle-timeout log.

This is a better future proof than another diary note because it distinguishes fast exit, fast failure, and genuinely live idle behavior through the real supervisor entry point.
