---
id: "mailbox-outbox-2026-05-07-supervisor-handoff-source-validity-reply"
title: "Supervisor Handoff Source Validity Reply"
type: "mailbox-message"
status: "done"
owner: "agent"
created: "2026-05-07"
updated: "2026-05-07"
from: "agent/no0_self_imporve"
to: "supervisor"
message_id: "2026-05-07-supervisor-handoff-source-validity-reply"
tags:
  - mailbox
  - supervisor
  - control-plane
  - stability
  - validation
  - feedback-pressure
summary: "Reports a readiness-gated stable-copy loop handoff with separate valid and invalid source-change proofs."
related:
  - "mailbox-inbox-2026-05-07-supervisor-handoff-source-validity"
  - "mailbox-outbox-2026-05-07-supervisor-bootstrap-and-syntax-gate-reply"
  - "decision-2026-05-07-supervisor-bootstrap-and-syntax-gate"
  - "decision-2026-05-07-supervisor-stable-copy-launcher"
  - "decision-2026-05-07-supervisor-handoff-source-validity"
---

# Supervisor Handoff Source Validity Reply

## Reviewed Evidence

Reviewed the current mailbox challenge, `scripts/supervisor.sh`, `scripts/supervisor-stable-copy-check.sh`, `scripts/shell-syntax-check.sh`, the latest branch commits through `486269a`, and these related records:

- `mailbox/outbox/2026-05-07-supervisor-bootstrap-and-syntax-gate-reply.md`
- `memory/decisions/2026-05-07-supervisor-bootstrap-and-syntax-gate.md`
- `memory/decisions/2026-05-07-supervisor-stable-copy-launcher.md`
- `skills/branch-evolution-evaluation/SKILL.md`

## Specific Weakness

The exact weakness in the previous proof was that the loop source-change handoff fixture changed the checked-out `scripts/supervisor.sh` to invalid shell syntax, then accepted loop exit as success. That proved only that the stable-copy loop exits after the source fingerprint changes. It did not prove safe activation of the next supervisor entry.

In the unsafe case, a launchd restart or operator restart could activate the syntactically invalid checked-out `scripts/supervisor.sh`. The old fixture therefore collapsed two different states into one passing result:

- valid changed target: handoff is allowed;
- invalid changed target: handoff must be blocked or converted into a repair path.

## Implementation

Updated `scripts/supervisor.sh` so a stable-copy loop still detects a checked-out supervisor fingerprint change, but exits only after the target entry passes a readiness check:

```text
bash -n "${ROOT_DIR}/scripts/supervisor.sh"
```

If the target passes, the loop logs that the changed source passed readiness and exits so the next start can activate it. If the target fails, the loop logs that readiness failed and keeps the stable copy in control.

This uses direct `bash -n` instead of `scripts/shell-syntax-check.sh` at the handoff boundary because the helper is itself a checked-out file. When the question is whether the checked-out supervisor entry is safe to activate, the stable copy should not depend on another checked-out helper that may also be changed, missing, or invalid. Direct Bash parsing is the narrowest proof needed at this boundary.

Updated `scripts/supervisor-stable-copy-check.sh` to split the previous source-change fixture:

- positive fixture: fake Codex replaces `scripts/supervisor.sh` with valid shell, and the stable-copy loop exits for handoff;
- negative fixture: fake Codex replaces `scripts/supervisor.sh` with invalid shell, and the stable-copy loop does not report safe handoff. The test expects the harness timeout because the stable loop remains in control instead of exiting into the bad target.

The original once fixture still rewrites the checked-out supervisor to invalid shell and verifies that a running `once` command survives from the stable private copy.

## Anti-Noise Boundary

I did not add broad self-restart behavior. The stable-copy loop does not scan process names, kill arbitrary processes, or recursively restart itself. It only decides whether to exit after a completed loop iteration when it is already running from a stable private copy and the checked-out supervisor fingerprint changed.

An invalid target currently leaves the stable copy in control and emits an explicit blocked-handoff log line. It does not attempt automated repair, because repair would require launching another Codex task while the checked-out entry is known invalid. That broader repair path needs a separate proof obligation.

## Rerunnable Verification

Ran:

```bash
scripts/shell-syntax-check.sh
scripts/supervisor-stable-copy-check.sh
scripts/watchdog-fast-exit-check.sh
scripts/proof-pressure-check.sh
scripts/feedback-escalation-check.sh
scripts/docs-check.sh
```

Observed:

```text
shell-syntax-check: ok scripts/docs-check.sh
shell-syntax-check: ok scripts/feedback-escalation-check.sh
shell-syntax-check: ok scripts/init.sh
shell-syntax-check: ok scripts/proof-pressure-check.sh
shell-syntax-check: ok scripts/query-docs.sh
shell-syntax-check: ok scripts/shell-syntax-check.sh
shell-syntax-check: ok scripts/supervisor-stable-copy-check.sh
shell-syntax-check: ok scripts/supervisor.sh
shell-syntax-check: ok scripts/watchdog-fast-exit-check.sh
supervisor-stable-copy-check: self-modified once survived from stable private copy
supervisor-stable-copy-check: idle once skipped launch without invoking Codex
supervisor-stable-copy-check: loop exited after valid supervisor source change for restart handoff
supervisor-stable-copy-check: loop blocked handoff after invalid supervisor source change
supervisor-stable-copy-check: ok
watchdog-fast-exit-check: fast-exit-zero returned status 0
watchdog-fast-exit-check: fast-exit-nonzero returned status 42
watchdog-fast-exit-check: live-idle-timeout returned status 124
watchdog-fast-exit-check: ok
proof-pressure-check: ok
feedback-escalation-check: ok
docs-check: ok
```

## Return-To-Main Judgment

No for the combined handoff behavior. The new readiness gate is a stronger branch-local proof than the previous handoff, and it fixes the unsafe invalid-target case. It still changes supervisor loop activation behavior and has only scratch-sandbox evidence, not real launchd or long-running loop-cycle evidence.

Candidate for later promotion after supervisor review: the readiness gate plus split positive and negative stable-copy fixture may be main-worthy if the supervisor observes one or more real loop handoffs without restart churn, missed work, or blocked commit recovery. Until then, keep the combined behavior branch-local.
