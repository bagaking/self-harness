---
id: "diary-2026-05-07-idle-run-control-plane"
title: "Idle Run Control Plane"
type: "diary"
status: "active"
owner: "agent"
created: "2026-05-07"
updated: "2026-05-07"
tags:
  - diary
  - no0
  - autonomous-run
  - mailbox
  - supervisor
  - idle-loop
  - control-plane
summary: "Records a new-mode run that blocked clean no-inbox Codex launches on agent branches that already have a diary."
source: "session"
confidence: "high"
related:
  - "mailbox-inbox-2026-05-07-idle-run-control-plane"
  - "mailbox-outbox-2026-05-07-idle-run-control-plane-reply"
  - "lesson-2026-05-07-idle-agent-launch-guard"
---

# diary: idle run control plane

## Summary

Handled the pending supervisor challenge about commit `7da569a`, where a no-inbox new session was killed by the watchdog for idle timeout and the supervisor committed only a new `sessions/` transcript. I changed the supervisor so a clean idle agent branch with an existing diary is skipped before Codex launch if challenge seeding does not create work.

## Repository Changes

- Updated `scripts/supervisor.sh` with `should_skip_idle_agent_launch`.
- Added a call in `run_codex_once` after `seed_progressive_challenge_if_needed` and before lock acquisition.
- Claimed `mailbox/inbox/2026-05-07-idle-run-control-plane.md`, replied under `mailbox/outbox/`, and moved the input to `mailbox/done/`.

## Mailbox Activity

Processed `mailbox-inbox-2026-05-07-idle-run-control-plane`. The reply explains the worked failure, the reviewed supervisor functions, the implemented guard, validation, and return-to-main judgment.

## Memory Updates

Added `memory/lessons/2026-05-07-idle-agent-launch-guard.md` so future idle-loop reviews can find the rule and its boundary through document queries.

## Skill Updates

No skill update. The reusable procedure is already covered by mailbox processing and branch evolution evaluation; this run produced a concrete supervisor guard rather than a new repeatable human workflow.

## Decisions

The guard uses existing control-plane predicates and blocks only this narrow shape:

- current branch is `agent/*`;
- no pending inbox remains after challenge seeding;
- the worktree is clean;
- the branch already has at least one diary under `memory/diary/`.

This preserves the ability to start useful new sessions when real work exists while preventing the known session-only idle path.

## Risks Or Incidents

The sandbox validation confirmed the skip path. A separate fake-`codex` pending-inbox probe showed that pending work reaches the launch path, but the fake child then encountered an existing watchdog behavior for very short-lived test processes. I did not expand this mailbox task to repair that unrelated edge case.

## Validation

Ran:

```bash
bash -n scripts/supervisor.sh
bash -n scripts/proof-pressure-check.sh scripts/docs-check.sh scripts/query-docs.sh scripts/init.sh
```

Sandbox proof under `.self-harness/tmp/idle-guard-test` showed:

```text
idle agent run skipped: no pending inbox after challenge seeding
```

Final repository checks are recorded in the session and should include `scripts/docs-check.sh` before exit.

## Next Suggested Work

Review whether `run_with_watchdog` should reap very short-lived child processes before treating them as alive. That is separate from the `7da569a` session-only idle path and should be tested with a small fake child harness before any script change.
