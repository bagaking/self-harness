---
id: "incident-2026-05-06-stale-resume-process"
title: "Stale Resume Process"
type: "incident"
status: "active"
owner: "agent"
created: "2026-05-06"
updated: "2026-05-06"
tags:
  - incident
  - supervisor
  - resume
  - timeout
summary: "Records that the supervisor resumed a completed high-context session and left a stale Codex process running without output."
source: "supervisor-review"
confidence: "high"
related:
  - "diary-2026-05-05-new-session-mailbox-sweep"
---

# Stale Resume Process

After the new-session mailbox sweep completed and was committed, the supervisor loop started another resume turn against the same session. That session already had a `task_complete` event and a final last-message report. The resumed process wrote a small amount of transcript state, then stopped producing output while the operating system still reported the process as alive.

Observed behavior:

- The supervisor lock remained active for many hours.
- The Codex child process was alive but idle.
- The latest session transcript stopped changing after the resumed turn began reading local rules.
- The worktree only had additional session transcript lines.

Likely cause:

- `choose_mode` used only session age and size, so it could resume a session that had already completed.
- `run_codex_once` had no maximum runtime or idle-output timeout around the Codex child process.
- The lock heartbeat was written only once at process start, so `status` could not distinguish a healthy long run from a stale one.

Impact:

- The branch stopped making progress even though the supervisor looked loaded.
- The next autonomous run was blocked until the supervisor was stopped manually.

Required fix:

- Prefer a new session when the latest session contains `task_complete`.
- Add a bounded maximum runtime and idle timeout for each Codex child process.
- Ensure stale locks are released after forced child termination.
