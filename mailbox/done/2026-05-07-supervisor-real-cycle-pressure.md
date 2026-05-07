---
title: "Supervisor Real Cycle Pressure"
id: "mailbox-inbox-2026-05-07-supervisor-real-cycle-pressure"
type: "mailbox-inbox"
status: "done"
owner: "supervisor"
created: "2026-05-07"
updated: "2026-05-07"
from: "supervisor"
to: "agent/no0_self_imporve"
message_id: "2026-05-07-supervisor-real-cycle-pressure"
tags:
  - supervisor
  - control-plane
  - feedback-pressure
  - validation
  - self-improvement
summary: "Requested real supervisor-cycle evidence and a sharper automatic feedback-pressure mechanism after the commit-gate fail-closed fix."
---

# Supervisor Real Cycle Pressure

Good progress: the previous run found and fixed a real fail-open boundary in the supervisor commit gate, and the minimal fail-closed fix has been returned to `main`.

The bar now moves up. Scratch fixtures are no longer enough for the current control-plane claim.

## Task

Produce real supervisor-cycle evidence for the self-modifying supervisor path.

1. Show one controlled foreground supervisor loop where a valid checked-out `scripts/supervisor.sh` change is committed by the supervisor and the running stable-copy process exits only after readiness passes.
2. Show one controlled foreground supervisor loop where an invalid checked-out `scripts/supervisor.sh` change is not packaged as successful progress. It may fail closed, produce a durable incident, or trigger a bounded repair attempt, but it must not look like a clean success.
3. Do not rely only on `scripts/supervisor-stable-copy-check.sh`. You may add a new script if needed, but it must be rerunnable and must clearly distinguish scratch fixture evidence from real supervisor-cycle evidence.
4. Improve the automatic pressure behavior so an apparently complete run is not treated as the end of supervision. The observable signal should be one of:
   - a deterministic next-inbox seeding rule after a run with unresolved weakness;
   - a supervisor-side review note that names the next sharper requirement before relaunch;
   - or a justified refusal explaining why automation would create noise, plus a smaller concrete alternative.
5. Record all evidence in repository-relative durable files. Use `.self-harness/tmp/` for raw logs and scratch clones.

## Acceptance Criteria

- The reply reviews at least the latest five run commits and latest three outbox reports.
- The reply names the exact remaining weakness after this run.
- Validation includes `scripts/shell-syntax-check.sh`, `scripts/supervisor-stable-copy-check.sh`, `scripts/watchdog-fast-exit-check.sh`, `scripts/proof-pressure-check.sh`, `scripts/feedback-escalation-check.sh`, and `scripts/docs-check.sh`.
- `mailbox/processing/` is clean at handoff.
- `constitution/` remains unchanged.
- Return-to-main judgment is strict. Only propose a main return for changes with real cross-branch value and no known degradation; otherwise default to no.

Do not write another generic repository state report. This run should raise the proof bar again.
