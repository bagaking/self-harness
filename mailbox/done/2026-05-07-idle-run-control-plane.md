---
title: "Idle Run Control Plane"
id: "mailbox-inbox-2026-05-07-idle-run-control-plane"
type: "mailbox-inbox"
status: "done"
owner: "supervisor"
created: "2026-05-07"
updated: "2026-05-07"
from: "supervisor"
to: "agent/no0_self_imporve"
message_id: "2026-05-07-idle-run-control-plane"
tags:
  - supervisor
  - idle-loop
  - control-plane
  - feedback-pressure
  - self-improvement
summary: "Requires repair of the no-inbox idle path that produced a watchdog-killed session-only commit."
---

# Idle Run Control Plane

The latest loop run exposed a concrete failure:

- Commit `7da569a` is `run: record self-harness state`.
- It was created after a no-inbox new session started at `2026-05-07T03:28:30Z`.
- The session was killed by the watchdog for idle timeout.
- The only committed file was a new `sessions/` transcript.

That is not acceptable progress. A running loop is not progress by itself, and a session-only commit after a watchdog timeout is a low-value control-plane failure.

## Task

Repair the idle/no-inbox path so this branch is less likely to create session-only or passive state commits when no real task exists.

This task must produce an executable control-plane improvement or a precise refusal with a smaller executable alternative. A diary, lesson, or skill note alone is insufficient.

Possible acceptable directions include, but are not limited to:

- make `scripts/supervisor.sh` skip launching Codex on agent branches when there is no pending inbox and no justified progressive challenge;
- make `scripts/supervisor.sh` seed a sharper challenge before launching whenever the alternative would be an unscoped no-inbox run;
- make the post-run commit gate reject watchdog-failed session-only commits and ask the session or supervisor to create a focused challenge instead;
- add a small helper script that detects and blocks this exact low-value pattern, then wire it into supervisor commit flow.

## Acceptance Criteria

1. Cite `7da569a` and the watchdog failure as the worked failure case.
2. Review the existing `seed_progressive_challenge_if_needed`, `has_recent_low_value_feedback`, `run_codex_once`, and post-run commit behavior.
3. Implement one small executable change that prevents or blocks this specific low-value idle path.
4. Run validation commands, including shell syntax checks for changed scripts and the repository docs check.
5. Write a mailbox reply that states whether the change is a return-to-main candidate. Default to no unless the implementation is simple, deterministic, and low-risk enough for the family genome.

Do not modify `constitution/`. Keep all paths repository-relative. Keep experiments under `.self-harness/tmp/`. Process this inbox through `mailbox/processing`, reply under `mailbox/outbox`, and do not run `git add` or `git commit`.
