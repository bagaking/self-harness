---
id: "mailbox-outbox-2026-05-07-proof-pressure-executable-gate-reply"
title: "Proof Pressure Executable Gate Reply"
type: "mailbox-message"
status: "done"
owner: "agent"
created: "2026-05-07"
updated: "2026-05-07"
from: "agent/no0_self_imporve"
to: "supervisor"
message_id: "2026-05-07-proof-pressure-executable-gate-reply"
tags:
  - mailbox
  - progressive-challenge
  - proof-pressure
  - automation
summary: "Reports the executable proof-pressure gate added for repeated no-pending and state-sweep commits."
related:
  - "mailbox-inbox-2026-05-07-proof-pressure-executable-gate"
  - "lesson-2026-05-07-progressive-challenge-proof-pressure"
  - "skill-branch-evolution-evaluation"
---

# Proof Pressure Executable Gate Reply

I implemented the executable guard instead of refusing automation.

## What Changed

- Added `scripts/proof-pressure-check.sh`.
- Integrated it into `scripts/supervisor.sh` inside `run_commit_gate`, after portability checks and before `scripts/docs-check.sh`.
- Updated `skills/branch-evolution-evaluation/SKILL.md` so future branch evaluations include the new proof-pressure check.
- Claimed `mailbox/inbox/2026-05-07-proof-pressure-executable-gate.md`, then completed it under `mailbox/done/`.

## Smallest Stable Check

The check is deliberately narrow. It only applies on `agent/*` branches, only after at least two recent low-value commit subjects, and only when the current pending commit is a pure sweep made from:

- `sessions/*`
- `memory/diary/*.md` whose first 120 lines match no-pending/state-sweep language
- `mailbox/outbox/*.md` whose first 120 lines match no-pending/state-sweep language

Any script, memory lesson, skill update, mailbox challenge reply, proposal, incident, or other substantive file causes the check to pass. This makes the gate pressure passive loops without blocking evidence-backed work.

The thresholds are environment-tunable:

- `SELF_HARNESS_PROOF_PRESSURE_RECENT_LIMIT`, default `12`
- `SELF_HARNESS_PROOF_PRESSURE_RECENT_THRESHOLD`, default `2`

## Acceptance Criteria

- `scripts/proof-pressure-check.sh` passes on this run because the current worktree contains real script and skill changes, not a pure sweep.
- In a scratch clone under `.self-harness/tmp/`, the same check fails when the only changed files are a copied no-pending outbox report, a copied no-pending diary, and a session file.
- In that same scratch clone, `SELF_HARNESS_PROOF_PRESSURE_RECENT_THRESHOLD=999 scripts/proof-pressure-check.sh` passes, proving the threshold control works.
- `scripts/supervisor.sh` calls `scripts/proof-pressure-check.sh` during `run_commit_gate`.
- Changed shell scripts pass `bash -n`.
- Final mailbox hygiene and `scripts/docs-check.sh` results are recorded in the diary for this run.

## Validation Commands

Already run:

```bash
bash -n scripts/proof-pressure-check.sh
bash -n scripts/supervisor.sh
bash -n scripts/proof-pressure-check.sh scripts/supervisor.sh scripts/docs-check.sh scripts/query-docs.sh scripts/init.sh
scripts/proof-pressure-check.sh
```

Scratch negative probe:

```bash
git clone --no-hardlinks . .self-harness/tmp/proof-pressure-probe-current
cp scripts/proof-pressure-check.sh .self-harness/tmp/proof-pressure-probe-current/scripts/proof-pressure-check.sh
chmod +x .self-harness/tmp/proof-pressure-probe-current/scripts/proof-pressure-check.sh
mkdir -p .self-harness/tmp/proof-pressure-probe-current/mailbox/outbox .self-harness/tmp/proof-pressure-probe-current/memory/diary .self-harness/tmp/proof-pressure-probe-current/sessions/probe
cp mailbox/outbox/2026-05-07-0955-new-mode-state-mailbox-report.md .self-harness/tmp/proof-pressure-probe-current/mailbox/outbox/2099-01-01-probe-new-mode-state-mailbox-report.md
cp memory/diary/2026-05-07-0955-new-mode-state-mailbox.md .self-harness/tmp/proof-pressure-probe-current/memory/diary/2099-01-01-probe-new-mode-state-mailbox.md
touch .self-harness/tmp/proof-pressure-probe-current/sessions/probe/session.jsonl
printf '%s\n' 'scripts/proof-pressure-check.sh' >> .self-harness/tmp/proof-pressure-probe-current/.git/info/exclude
scripts/proof-pressure-check.sh
SELF_HARNESS_PROOF_PRESSURE_RECENT_THRESHOLD=999 scripts/proof-pressure-check.sh
```

Observed outcomes:

- Current worktree: `proof-pressure-check: ok`.
- Scratch pure-sweep probe: exited `1` with `proof-pressure-check: repeated low-value state-sweep pattern detected`.
- Scratch high-threshold control: `proof-pressure-check: ok`.

## Return-To-Main Judgment

Candidate, but supervisor should review strictly. The implementation is small, deterministic, portable, and directly tied to an observed branch failure mode. It is potentially useful beyond this branch because the repeated passive-loop pattern can affect any `agent/*` branch.

The main risk is false positives if a future branch intentionally commits a session plus a compact no-pending report as a meaningful checkpoint. The risk is constrained because the gate requires repeated recent low-value subjects and a pure-sweep pending commit; adding a proposal, lesson, incident, skill, script change, or challenge reply makes the commit pass.
