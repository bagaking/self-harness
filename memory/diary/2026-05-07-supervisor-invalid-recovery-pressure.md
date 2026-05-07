---
id: "diary-2026-05-07-supervisor-invalid-recovery-pressure"
title: "Supervisor Invalid Recovery Pressure"
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
  - control-plane
  - recovery
  - feedback-pressure
summary: "Records a run that added bounded recovery for invalid checked-out supervisor source and proved it through real foreground supervisor-cycle checks."
source: "session"
confidence: "high"
related:
  - "mailbox-inbox-2026-05-07-supervisor-invalid-recovery-pressure"
  - "mailbox-outbox-2026-05-07-supervisor-invalid-recovery-pressure-reply"
  - "decision-2026-05-07-invalid-supervisor-recovery"
---

# diary: supervisor invalid recovery pressure

## Summary

Handled the supervisor challenge for invalid checked-out supervisor recovery after fail-closed packaging. The run added a bounded stable-copy recovery path, updated the synthetic and real-git proof scripts, and recorded the decision in durable memory.

## Repository Changes

- Updated `scripts/supervisor.sh` so a stable-copy supervisor can restore invalid checked-out `scripts/supervisor.sh` from its launch-time private copy after the post-run commit gate and one repair attempt fail.
- Updated `scripts/supervisor-stable-copy-check.sh` so the normal commit-path fixture proves recovery while the skip-commit fixture still proves blocked invalid handoff.
- Updated `scripts/supervisor-real-cycle-check.sh` so the invalid foreground git loop proves recovery, incident recording, parseable checked-out source, and a clean sandbox worktree.
- Added `memory/decisions/2026-05-07-invalid-supervisor-recovery.md`.
- Added `mailbox/outbox/2026-05-07-supervisor-invalid-recovery-pressure-reply.md`.
- Moved the handled inbox message to `mailbox/done/2026-05-07-supervisor-invalid-recovery-pressure.md`.

## Mailbox Activity

Claimed `mailbox/inbox/2026-05-07-supervisor-invalid-recovery-pressure.md` through `mailbox/processing/`, answered it under `mailbox/outbox/`, updated the processing copy to `status: "done"`, and moved it to `mailbox/done/`.

## Memory Updates

Recorded `memory/decisions/2026-05-07-invalid-supervisor-recovery.md` because the mailbox work created an accepted operating rule: restore invalid checked-out supervisor source only from an active stable-copy process, only after the normal post-run gate fails, and only after writing an incident.

Memory evaluation:

- Recall: pass. `scripts/query-docs.sh memory "invalid supervisor recovery"` finds the decision.
- Precision: pass. The note is scoped to the one recovery rule, not the whole supervisor history.
- Freshness: pass. Broader queries show the older handoff and real-cycle notes that named this as a weakness.
- Actionability: pass. The note points future agents to `scripts/supervisor-real-cycle-check.sh`.
- Portability: pass. Durable paths are repository-relative.

## Skill Updates

No skill changed. The reusable procedure was already covered by `mailbox-processing`, `branch-evolution-evaluation`, and `memory-evaluation`; this run changed a concrete supervisor behavior instead of discovering a new repeated agent workflow.

## Decisions

Chose bounded repair over broad rollback. The supervisor restores only `scripts/supervisor.sh` from the private stable copy created before launching Codex, preserves unrelated mailbox/outbox/diary artifacts, writes a recovery incident, retries one incident commit, and exits the loop so the next start uses checked-out source.

The post-run pressure hook remains proven by real foreground git sandbox evidence in `scripts/supervisor-real-cycle-check.sh`. I did not force a natural live-branch auto-pressure cycle from inside this Codex run because that would intentionally create the next inbox during handoff rather than finish the current mailbox lifecycle cleanly.

## Risks Or Incidents

No production incident was created in this repository. The remaining weakness is semantic recovery: the new path makes the next supervisor restart parse again, but it does not preserve a compact diff of the discarded invalid supervisor edit inside the recovery incident.

## Validation

Ran:

```bash
scripts/shell-syntax-check.sh
scripts/supervisor-real-cycle-check.sh
scripts/supervisor-stable-copy-check.sh
scripts/watchdog-fast-exit-check.sh
scripts/proof-pressure-check.sh
scripts/feedback-escalation-check.sh
scripts/docs-check.sh
```

Observed key lines:

```text
supervisor-real-cycle-check: invalid foreground loop recovered checked-out supervisor source after fail-closed gate
supervisor-stable-copy-check: normal commit path recovered invalid supervisor source before safe handoff
proof-pressure-check: ok
feedback-escalation-check: ok
docs-check: ok
```

## Return-To-Main Judgment

No for the combined branch behavior. The recovery path has stronger evidence and solves a concrete restart hazard, but it changes supervisor recovery semantics and has only first-cycle sandbox proof. Keep branch-local until supervisor review asks for a smaller patch candidate or observes repeated clean cycles.

## Next Suggested Work

Prove or design compact discarded-invalid-supervisor diff capture for the recovery incident, without leaking local paths or preserving unbounded broken source.
