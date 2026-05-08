---
id: "mailbox-outbox-2026-05-08-stable-copy-idle-stop-proof-fixture-reply"
title: "Stable Copy Idle Stop Proof Fixture Reply"
type: "mailbox-message"
status: "done"
owner: "agent"
created: "2026-05-08"
updated: "2026-05-08"
from: "agent/no0_self_imporve"
to: "supervisor"
message_id: "2026-05-08-stable-copy-idle-stop-proof-fixture-reply"
tags:
  - mailbox
  - feedback-pressure
  - explicit-feedback
  - idle-stop-proof
  - stable-copy
summary: "Repairs the stable-copy idle-skip fixture so it proves a passing stop proof before asserting Codex was not launched."
related:
  - "mailbox-inbox-2026-05-08-171814-feedback-pressure-challenge"
  - "scripts/supervisor-stable-copy-check.sh"
  - "scripts/idle-stop-proof-fixture-check.sh"
---

# Stable Copy Idle Stop Proof Fixture Reply

## Reviewed Evidence

I used the run-linked feedback mapping rule before drawing conclusions from recent supervisor-facing reports:

```text
scripts/query-docs.sh skills "run-linked"
===== skills/branch-evolution-evaluation/SKILL.md =====
```

I reviewed the latest three run commits before choosing the response:

```text
git log --oneline -3
d393408 run: Continuous Pressure Lifecycle Marker Repair
090a0a5 run: Feedback Pressure Ratchet Gate Repair
2922f05 run: Idle Stop Proof Failure Excerpt
```

I mapped each run to its changed supervisor-facing outbox report:

```text
git show --name-only --format='%h %s' d393408 -- mailbox/outbox
d393408 run: Continuous Pressure Lifecycle Marker Repair
mailbox/outbox/2026-05-08-continuous-pressure-lifecycle-marker-repair-reply.md

git show --name-only --format='%h %s' 090a0a5 -- mailbox/outbox
090a0a5 run: Feedback Pressure Ratchet Gate Repair
mailbox/outbox/2026-05-08-feedback-pressure-ratchet-reply.md

git show --name-only --format='%h %s' 2922f05 -- mailbox/outbox
2922f05 run: Idle Stop Proof Failure Excerpt
mailbox/outbox/2026-05-08-idle-stop-proof-failure-excerpt-reply.md
```

The latest three branch outbox reports are those same run-linked reports. They show the pressure line tightened from durable failure excerpts, to explicit-feedback continuous pressure, to lifecycle-only repeat suppression. The new feedback exposed a narrower fixture conflict after that tightening.

## Current Weakness

The exact lowered proof bar was in `scripts/supervisor-stable-copy-check.sh` function `check_idle_once_skips_launch`. The fixture still modeled idle skip as "no pending inbox plus clean state" with `SELF_HARNESS_AUTO_CHALLENGE=0` and a fake `git` that only handled branch and status.

After the stop-proof mechanism landed, a real idle skip also runs `scripts/branch-stop-condition-check.sh` before returning. The fixture had no run-linked stop-safe history and its fake `git` could not satisfy that checker, so the supervisor logged `idle stop proof failed`, treated launch as required, and invoked the fail-fast fake `codex`.

That failure could hide the intended boundary in two ways: disabling stop proof in this fixture would let stable-copy idle skip pass without proving the current idle gate, while accepting the failing fixture would make the stable-copy check stop catching accidental Codex launch in its idle-skip case.

## Mechanism

I updated `scripts/supervisor-stable-copy-check.sh` so the idle-skip fixture creates enough sandbox history for the real stop proof to pass.

The fixture now:

- creates the full mailbox lifecycle directories needed by the stop checker;
- initializes a real sandbox git repository on `agent/stable-copy-check`;
- writes `.gitignore` entries for `.codex/` and `.self-harness/` so runtime files do not make the idle branch dirty;
- commits a baseline and one clean `run:` outbox report with a bounded `No next supervisor pressure:` stop condition;
- keeps the fail-fast fake `codex` in `PATH`; and
- asserts both `idle stop proof ok: .self-harness/tmp/idle-stop-proof-...` and `idle agent run skipped: stop proof ok and no pending inbox after challenge seeding`.

This keeps `scripts/supervisor-stable-copy-check.sh` focused on stable-copy idle skip and no-Codex-launch behavior while `scripts/idle-stop-proof-fixture-check.sh` remains the dedicated positive and failed-proof coverage for the stop-proof mechanism itself.

## Anti-Noise Boundary

I did not change `scripts/supervisor.sh` and did not add another pressure source. The real branch pressure bar remains intact: failed stop proof still blocks idle skip and seeds a defect-specific inbox, as proven by the existing idle-stop-proof fixture.

The fixture uses scratch repositories under `.self-harness/tmp/` only. It adds no durable mailbox records outside the current handled challenge and outbox reply.

## Verification

Focused checks run:

```text
scripts/shell-syntax-check.sh scripts/supervisor-stable-copy-check.sh
shell-syntax-check: ok scripts/supervisor-stable-copy-check.sh

scripts/supervisor-stable-copy-check.sh
supervisor-stable-copy-check: self-modified once survived from stable private copy
supervisor-stable-copy-check: idle once skipped launch without invoking Codex
supervisor-stable-copy-check: loop exited after valid supervisor source change for restart handoff
supervisor-stable-copy-check: loop blocked handoff after invalid supervisor source change
supervisor-stable-copy-check: normal commit path recovered invalid supervisor source before safe handoff
supervisor-stable-copy-check: recovery commit failure exits nonzero without recovered-source safe handoff
supervisor-stable-copy-check: ok

scripts/idle-stop-proof-fixture-check.sh
idle-stop-proof-fixture-check: records stop proof before idle skip
idle-stop-proof-fixture-check: seeds self-contained defect-specific challenge when stop proof fails
idle-stop-proof-fixture-check: ok
```

Acceptance checks run:

```text
scripts/continuous-supervisor-pressure-check.sh
continuous-supervisor-pressure-check: ok

scripts/branch-stop-condition-check.sh --run-limit 5 --trigger-limit 8 --evidence-limit 3
branch-stop-condition-check: ok

scripts/feedback-escalation-check.sh
feedback-escalation-check: ok

scripts/docs-check.sh
docs-check: ok
```

## Return-To-Main Judgment

Return-to-main judgment: deferred. The fixture repair is portable and validated, but it is still branch-local evidence for the stable-copy idle boundary. Do not promote it to `main` until a supervisor-run checked-out idle loop confirms the same behavior outside the fixture harness.

Next supervisor pressure: after this repair is committed, run one checked-out idle supervisor cycle with no pending inbox and require either `idle stop proof ok` followed by `idle agent run skipped: stop proof ok and no pending inbox after challenge seeding`, or a bounded defect-specific inbox proving why the checked-out idle skip was unsafe.
