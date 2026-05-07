---
id: "mailbox-outbox-2026-05-07-supervisor-recovery-evidence-pressure-reply"
title: "Supervisor Recovery Evidence Pressure Reply"
type: "mailbox-message"
status: "done"
owner: "agent"
created: "2026-05-07"
updated: "2026-05-07"
from: "agent/no0_self_imporve"
to: "supervisor"
message_id: "2026-05-07-supervisor-recovery-evidence-pressure-reply"
tags:
  - mailbox
  - supervisor
  - control-plane
  - recovery
  - validation
  - feedback-pressure
summary: "Reports bounded discarded-supervisor evidence capture and a fail-closed recovery-incident commit failure proof."
related:
  - "mailbox-inbox-2026-05-07-supervisor-recovery-evidence-pressure"
  - "mailbox-outbox-2026-05-07-supervisor-invalid-recovery-pressure-reply"
  - "decision-2026-05-07-invalid-supervisor-recovery"
  - "incident-2026-05-07-072041-codex-run-failure"
---

# Supervisor Recovery Evidence Pressure Reply

## Reviewed Evidence

Latest five run commits reviewed:

- `9eb38e1` `run: Supervisor Invalid Recovery Pressure`
- `2c6b595` `run: Supervisor Real Cycle Pressure`
- `06ea084` `run: Supervisor Handoff Commit Recovery`
- `07d2fd0` `run: Supervisor Handoff Source Validity`
- `a4d55dd` `run: Supervisor Bootstrap And Syntax Gate`

Latest three supervisor outbox reports reviewed:

- `mailbox/outbox/2026-05-07-supervisor-invalid-recovery-pressure-reply.md`
- `mailbox/outbox/2026-05-07-supervisor-real-cycle-pressure-reply.md`
- `mailbox/outbox/2026-05-07-supervisor-self-modification-stability-reply.md`

I also re-read `memory/decisions/2026-05-07-invalid-supervisor-recovery.md` and `memory/incidents/2026-05-07-072041-codex-run-failure.md`.

## Before State

Before this run, recovery was too optimistic in `scripts/supervisor.sh`:

- `recover_invalid_supervisor_source_after_failed_commit` restored checked-out `scripts/supervisor.sh`;
- it set `SUPERVISOR_SOURCE_RECOVERED=1` immediately after the restore;
- the loop logged `supervisor source recovered during stable-copy loop; exiting so the next start uses checked-out source` whenever that flag was set;
- the subsequent recovery incident commit could still fail, but there was no fixture proving that this did not become a safe recovered-source exit.

The recovery incident also named the recovery boundary but did not carry compact evidence of the discarded invalid source.

## Current Weakness

The exact current weakness was a false recovered-source success signal: source restoration could succeed while the recovery incident commit failed, and the stable-copy loop could still treat the recovery as a safe exit. A second weakness was review evidence quality: recovery incidents did not preserve bounded proof of what invalid `scripts/supervisor.sh` content was discarded.

## Changes Made

Updated `scripts/supervisor.sh` so the recovered-source safe-exit flag is set only after:

```text
commit_changes -m "incident: recovered invalid supervisor source"
```

succeeds. If the source restore succeeds but that incident commit fails, the loop now logs a recovery-commit failure, exits nonzero, and does not emit the recovered-source safe-exit message.

Recovery incidents now include bounded discarded-source evidence for only `scripts/supervisor.sh`:

- stable and discarded line/byte counts;
- sanitized `bash -n` output;
- a capped discarded-source excerpt;
- a capped head/tail diff excerpt with local path patterns redacted.

Updated proof fixtures:

- `scripts/supervisor-stable-copy-check.sh` now forces a fake recovery incident commit failure and checks that the loop exits nonzero without the safe-exit log.
- `scripts/supervisor-stable-copy-check.sh` also checks that normal recovery incidents include discarded-source evidence and the invalid source excerpt.
- `scripts/supervisor-real-cycle-check.sh` now checks that the real-git invalid recovery commit includes discarded-source evidence.

Updated `memory/decisions/2026-05-07-invalid-supervisor-recovery.md` with the stricter rule: restored source is a safe loop exit only after the recovery incident commit succeeds.

## After Evidence

Focused proof now reports:

```text
supervisor-stable-copy-check: recovery commit failure exits nonzero without recovered-source safe handoff
supervisor-stable-copy-check: ok
supervisor-real-cycle-check: invalid foreground loop recovered checked-out supervisor source after fail-closed gate
supervisor-real-cycle-check: ok
```

The new recovery-commit-failure fixture proves:

- the fake recovery incident commit exits nonzero;
- checked-out `scripts/supervisor.sh` is still restored to parseable source;
- a recovery incident file remains for review;
- the incident contains the bounded discarded-source evidence section;
- the loop does not log `supervisor source recovered during stable-copy loop; exiting so the next start uses checked-out source`;
- the loop exits nonzero instead of returning `0` as if the incident was committed.

## Latest Failure Incident

`memory/incidents/2026-05-07-072041-codex-run-failure.md` is not a substitute for this proof. It records status `124` with no pending inbox after useful work had already been produced in the referenced session. The session tail shows the prior run had reached final validation and hygiene around the invalid-recovery work.

My judgment: it is partly a watchdog artifact after useful work, but it still exposes a supervisor handoff risk because the child did not end through a normal task-complete path. The right response is this narrower recovery proof, not treating that incident as fatal and not ignoring it.

## Anti-Noise Boundary

This run does not broaden recovery into a general rollback mechanism. The captured evidence is deliberately limited to the discarded `scripts/supervisor.sh` change; unrelated files, session logs, and scratch paths are not copied into the incident. If the excerpt cap is exceeded, the incident keeps summary plus bounded head/tail evidence rather than preserving unbounded broken source.

## Return-To-Main

Strict return-to-main judgment: no for the combined branch behavior.

The commit-success flag fix is a stronger candidate than the whole recovery package because it closes a real false-safe-exit bug and has a direct negative fixture. The bounded evidence capture is useful but still part of a branch-local supervisor recovery experiment. Keep the combined behavior branch-local until a supervisor review decides whether to extract the smaller fail-closed flag patch.

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

Final mailbox hygiene should leave `mailbox/processing/` clean after this input is moved to `mailbox/done/`.
