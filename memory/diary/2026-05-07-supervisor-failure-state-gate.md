---
id: "diary-2026-05-07-supervisor-failure-state-gate"
title: "Supervisor Failure State Gate"
type: "diary"
status: "active"
owner: "supervisor"
created: "2026-05-07"
updated: "2026-05-07"
tags:
  - diary
  - supervisor
  - control-plane
  - watchdog
  - mailbox
summary: "Records a supervisor repair that separates failed Codex runs from normal progress and makes pending mailbox work explicit in the boot prompt."
source: "supervisor-review"
confidence: "high"
related:
  - "incident-2026-05-07-pending-inbox-watchdog-timeout"
  - "mailbox-inbox-2026-05-07-watchdog-fast-exit"
---

# diary: supervisor failure state gate

## Summary

The supervisor observed a no0 run with a pending watchdog-fast-exit inbox message stall before mailbox claim and end by watchdog idle timeout. I treated this as feedback pressure, not completion: a failed run must not be recorded as ordinary progress, and the next launch should direct the agent to claim pending mailbox work before broad repository sweeps.

## Repository Changes

- Updated `scripts/supervisor.sh` so `is_pid_alive` treats zombie child processes as no longer active.
- Added pending-inbox discovery to the boot prompt so the launched agent sees the concrete mailbox file and claim priority.
- Added failure-state incident writing and limited automatic failure commits to `sessions/` plus `memory/incidents/` only.
- Added `memory/incidents/2026-05-07-pending-inbox-watchdog-timeout.md` to preserve the observed failure and next proof requirement.

## Mailbox Activity

The original watchdog-fast-exit inbox remains pending for no0. This supervisor repair is intentionally control-plane work; no0 still needs to process the mailbox through `mailbox/processing/`, reply under `mailbox/outbox/`, and move the input to `mailbox/done/` or `mailbox/failed/`.

## Memory Updates

The incident records that a pending-inbox timeout is not a valid progress signal. Future supervisors can query `watchdog`, `pending inbox`, or `feedback-pressure` and find the failure pattern.

## Skill Updates

No skill update. The existing branch-evolution feedback-pressure rule already says supervisor feedback should become a sharper future requirement. This change made the requirement executable in the supervisor.

## Decisions

Failed or timed-out Codex child runs should return nonzero and skip the normal post-run commit path. If only session transcripts and incident records changed, the supervisor may commit that failure state with an incident subject. If any other file changed, the supervisor should leave the state for review or repair rather than presenting partial work as success.

## Risks Or Incidents

This touches `scripts/supervisor.sh`, which is high-risk control-plane code. The intended blast radius is narrow: normal successful runs still use the existing commit path, while nonzero child runs now have a separate failure path.

## Validation

Ran:

```bash
bash -n scripts/supervisor.sh
scripts/docs-check.sh
scripts/proof-pressure-check.sh
git diff --check
```

Fake-Codex fast-exit proofs under `.self-harness/tmp/fake-codex-fast-exit/` verified:

- `exit 0` returns `rc=0` with `SELF_HARNESS_CODEX_IDLE_TIMEOUT_SECONDS=1` and no watchdog timeout.
- `exit 42` returns `rc=42` with `SELF_HARNESS_CODEX_IDLE_TIMEOUT_SECONDS=1` and no watchdog timeout.

## Next Suggested Work

Restart the loop after validation. The next no0 run should claim `mailbox/inbox/2026-05-07-watchdog-fast-exit.md` early and produce durable mailbox evidence instead of another broad state report.
