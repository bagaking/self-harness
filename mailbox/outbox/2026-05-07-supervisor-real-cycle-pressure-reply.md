---
id: "mailbox-outbox-2026-05-07-supervisor-real-cycle-pressure-reply"
title: "Supervisor Real Cycle Pressure Reply"
type: "mailbox-message"
status: "done"
owner: "agent"
created: "2026-05-07"
updated: "2026-05-07"
from: "agent/no0_self_imporve"
to: "supervisor"
message_id: "2026-05-07-supervisor-real-cycle-pressure-reply"
tags:
  - mailbox
  - supervisor
  - control-plane
  - feedback-pressure
  - validation
summary: "Reports real foreground supervisor-loop evidence and a post-run pressure seeding hook."
related:
  - "mailbox-inbox-2026-05-07-supervisor-real-cycle-pressure"
  - "decision-2026-05-07-post-run-pressure-marker"
  - "decision-2026-05-07-supervisor-commit-gate-fail-closed"
---

# Supervisor Real Cycle Pressure Reply

## Reviewed Evidence

Latest five run commits reviewed:

- `06ea084` `run: Supervisor Handoff Commit Recovery`
- `07d2fd0` `run: Supervisor Handoff Source Validity`
- `a4d55dd` `run: Supervisor Bootstrap And Syntax Gate`
- `d19f084` `run: Supervisor Self-Modification Stability`
- `ed1047c` `run: Feedback Escalation Loop`

Latest three outbox reports reviewed:

- `mailbox/outbox/2026-05-07-watchdog-fast-exit-reply.md`
- `mailbox/outbox/2026-05-07-supervisor-self-modification-stability-reply.md`
- `mailbox/outbox/2026-05-07-supervisor-main-gene-pool-review-reply.md`

Also reviewed the handoff source-validity and commit-recovery replies because they name the previous proof gap:

- `mailbox/outbox/2026-05-07-supervisor-handoff-source-validity-reply.md`
- `mailbox/outbox/2026-05-07-supervisor-handoff-commit-recovery-reply.md`

## Current Weakness

The exact remaining weakness after this run is operational recovery, not commit packaging. The supervisor now proves that a valid checked-out `scripts/supervisor.sh` edit is committed and handed off, and that an invalid checked-out edit is blocked by the normal gate and bounded repair path. It still does not automatically repair or roll back an invalid checked-out supervisor file after that failure. The stable copy can keep control and avoid packaging success, but a human or later task still has to decide the repair story.

## Real Supervisor-Cycle Evidence

Added `scripts/supervisor-real-cycle-check.sh`. It creates disposable real git repositories under `.self-harness/tmp/supervisor-real-cycle-check/`, installs the current supervisor scripts, injects a fake `codex`, and runs foreground `bash scripts/supervisor.sh loop` or `once` with commits enabled.

The valid loop proof uses a checked-out `scripts/supervisor.sh` edit that remains syntactically valid. Observed evidence:

- foreground loop returned `0`;
- sandbox commit count moved from one fixture commit to two commits;
- latest sandbox commit subject was `run: Valid Real Cycle`;
- the committed file list included `scripts/supervisor.sh`, handled mailbox input, an outbox reply, and a diary;
- loop logged the passed-readiness handoff and exited;
- fake Codex was invoked once;
- sandbox worktree was clean.

The invalid loop proof uses a fake Codex child that replaces checked-out `scripts/supervisor.sh` with invalid shell syntax. Observed evidence:

- foreground harness timed out while the stable copy stayed in control;
- sandbox commit count stayed at one fixture commit;
- the log included the bounded repair path and `shell-syntax-check: failed scripts/supervisor.sh`;
- the log included blocked handoff, not passed handoff;
- fake Codex was invoked exactly twice, meaning one run plus one repair attempt;
- invalid supervisor state was not packaged as successful progress.

## Mechanism

Updated `scripts/supervisor.sh` with a post-run pressure hook:

- changed outbox files may declare `Next supervisor pressure: ...`;
- after a successful Codex child and before the supervisor commit, the hook checks for that marker when no inbox is pending;
- on an agent branch, with automatic challenge behavior enabled, the supervisor writes `mailbox/inbox/<timestamp>-post-run-pressure-challenge.md`;
- the generated challenge points back to the outbox report and carries the declared narrower requirement as the next run's acceptance target.

This is narrower than always seeding a new challenge. It requires the completed run to explicitly name unresolved follow-up pressure in a changed outbox report.

## Anti-Noise

The hook does not inspect old reports, manufacture broad repository sweeps, or fire when an inbox already exists. A run has to write a changed outbox report with the exact marker before a next inbox is created. That keeps the mechanism branch-local, explicit, and reviewable.

The real-cycle proof also distinguishes scratch fixture evidence from real supervisor-cycle evidence: `scripts/supervisor-stable-copy-check.sh` remains a fixture check, while `scripts/supervisor-real-cycle-check.sh` uses real sandbox git commits through the foreground supervisor loop.

## Rerunnable Verification

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

Observed from the new check:

```text
supervisor-real-cycle-check: valid foreground loop committed checked-out supervisor change and exited after readiness
supervisor-real-cycle-check: invalid foreground loop rejected checked-out supervisor change without packaging success
supervisor-real-cycle-check: post-run pressure marker seeded a committed next inbox before handoff
supervisor-real-cycle-check: ok
```

## Return-To-Main

Strict return-to-main judgment: no for the combined branch behavior.

`scripts/supervisor-real-cycle-check.sh` is useful review evidence and `scripts/supervisor.sh` now has a more concrete automatic pressure hook, but the combined behavior changes branch supervision pressure and still leaves invalid checked-out supervisor recovery as a known weakness. Keep this branch-local until the supervisor has a clearer invalid-target recovery story and repeated real-cycle evidence.

Next supervisor pressure: Prove or design the invalid checked-out supervisor recovery story after fail-closed packaging, with a bounded repair, rollback, or durable incident path that does not leave the next manual restart pointed at invalid source.
