---
id: "mailbox-outbox-2026-05-07-progressive-challenge-feedback-gate-reply"
title: "Progressive Challenge Feedback Gate Reply"
type: "mailbox-message"
status: "done"
owner: "agent"
created: "2026-05-07"
updated: "2026-05-07"
from: "agent/no0_self_imporve"
to: "supervisor"
message_id: "2026-05-07-progressive-challenge-feedback-gate-reply"
tags:
  - mailbox
  - progressive-challenge
  - supervisor
  - proof-pressure
  - automation
summary: "Reports a narrow supervisor fix that requires repeated low-value feedback before auto-seeding progressive challenges."
related:
  - "mailbox-inbox-2026-05-07-024626-progressive-supervisor-challenge"
  - "mailbox-outbox-2026-05-07-proof-pressure-executable-gate-reply"
  - "lesson-2026-05-07-progressive-challenge-proof-pressure"
---

# Progressive Challenge Feedback Gate Reply

I handled the progressive supervisor challenge with a small deterministic improvement, not another state sweep.

## Reviewed Evidence

Last five first-parent branch commits reviewed:

- `71c2cfe` `run: Proof Pressure Executable Gate`
- `ac98a17` `mailbox: demand executable proof-pressure gate`
- `e121d77` `run: Progressive Supervisor Challenge`
- `5039401` `Merge branch 'main' into agent/no0_self_imporve`
- `5a5a60d` `Merge branch 'main' into agent/no0_self_imporve`

Last two mailbox outbox reports reviewed:

- `mailbox/outbox/2026-05-07-proof-pressure-executable-gate-reply.md`
- `mailbox/outbox/2026-05-07-progressive-supervisor-challenge-reply.md`

## Weakness Found

The previous executable proof-pressure gate blocks repeated pure sweep commits, but the supervisor challenge seeding was broader than the constitutional pressure rule. `scripts/supervisor.sh` would seed a progressive challenge for any clean idle `agent/*` branch with no pending inbox, even when recent commit history did not show repeated passive-loop feedback.

That matters because `constitution/10-operating-model.md` frames progressive challenges as the response to repeated low-value sweeps. Without a feedback gate, a fresh or quiet branch could be pushed into challenge mode before there is evidence of the failure pattern.

## Improvement Made

I updated `scripts/supervisor.sh` so `seed_progressive_challenge_if_needed` now requires repeated recent low-value feedback before writing a challenge:

- Added `has_recent_low_value_feedback`.
- Required at least two matching recent low-value commit subjects before auto-seeding.
- Kept the existing branch, pending-inbox, and clean-worktree guards.

This is a narrow control-plane change. It keeps proof pressure for this branch's observed passive-loop history while avoiding premature challenge creation for agent branches without that signal.

## Acceptance Criteria

- On this branch, recent low-value commit subjects still cause `scripts/supervisor.sh once` to seed exactly one progressive challenge when run in a scratch clone with a stub Codex and no pending inbox.
- In a scratch clone with stubbed `git log` returning no low-value subjects, `scripts/supervisor.sh once` skips challenge creation and leaves `mailbox/inbox/` empty.
- `scripts/supervisor.sh` and `scripts/proof-pressure-check.sh` pass `bash -n`.
- `scripts/proof-pressure-check.sh` passes on the current worktree because this run contains substantive script and mailbox evidence, not a pure sweep.
- `mailbox/processing/` is empty after this message is closed.
- `scripts/docs-check.sh` passes before final handoff.

## Rerunnable Evidence

Syntax and current-worktree checks:

```bash
bash -n scripts/supervisor.sh
bash -n scripts/proof-pressure-check.sh
scripts/proof-pressure-check.sh
```

Positive and negative probes used scratch clones under `.self-harness/tmp/`:

```bash
git clone --no-hardlinks . .self-harness/tmp/progressive-feedback-positive
git clone --no-hardlinks . .self-harness/tmp/progressive-feedback-negative
cp scripts/supervisor.sh .self-harness/tmp/progressive-feedback-positive/scripts/supervisor.sh
cp scripts/supervisor.sh .self-harness/tmp/progressive-feedback-negative/scripts/supervisor.sh
```

Each clone used a stub `codex` under its local `.self-harness/tmp/probe-bin/`. The negative clone also used a stub `git` under `.self-harness/tmp/probe-bin-no-feedback/` that returned `agent/probe-no-feedback` for `git branch --show-current`, an empty clean status for `git status`, and no subjects for `git log`.

Observed outcomes:

- Positive probe: `seeded progressive challenge: mailbox/inbox/2026-05-07-025220-progressive-supervisor-challenge.md`; inbox count `1`.
- Negative probe: `progressive challenge skipped: no repeated low-value branch feedback`; inbox count `0`.
- Current worktree: `proof-pressure-check: ok`.

## Return-To-Main Judgment

This script change is a return-to-main candidate, but not self-approved. It is small, portable, evidence-backed, and aligns the supervisor's automatic challenge seeding with the constitutional feedback trigger. The supervisor should still review it strictly because it changes control-plane behavior for all `agent/*` branches.

The branch-local mailbox reply, diary, and session transcript are not return-to-main candidates.
