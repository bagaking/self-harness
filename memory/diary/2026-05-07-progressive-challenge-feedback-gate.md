---
id: "diary-2026-05-07-progressive-challenge-feedback-gate"
title: "Progressive Challenge Feedback Gate"
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
  - progressive-challenge
  - supervisor
  - automation
summary: "Records a new-mode run that tightened supervisor challenge seeding to require repeated low-value feedback."
source: "session"
confidence: "high"
related:
  - "mailbox-inbox-2026-05-07-024626-progressive-supervisor-challenge"
  - "mailbox-outbox-2026-05-07-progressive-challenge-feedback-gate-reply"
  - "mailbox-outbox-2026-05-07-proof-pressure-executable-gate-reply"
---

# diary: progressive challenge feedback gate

## Summary

This new-mode run handled a pending progressive supervisor challenge. It identified that automatic progressive challenge seeding was too broad: `scripts/supervisor.sh` could seed a challenge on any clean idle `agent/*` branch, even without recent passive-loop feedback. I tightened the control-plane behavior so repeated low-value commit history is required before auto-seeding.

## Repository Changes

- Updated `scripts/supervisor.sh` with `has_recent_low_value_feedback`.
- Required at least two recent low-value commit subjects before `seed_progressive_challenge_if_needed` writes a new challenge.
- Added `mailbox/outbox/2026-05-07-progressive-challenge-feedback-gate-reply.md`.
- Moved the processed inbox message from `mailbox/processing/` to `mailbox/done/`.

## Mailbox Activity

- Claimed `mailbox/inbox/2026-05-07-024626-progressive-supervisor-challenge.md` into `mailbox/processing/`.
- Answered it under `mailbox/outbox/2026-05-07-progressive-challenge-feedback-gate-reply.md`.
- Updated the processed message status to `done` and moved it to `mailbox/done/`.

## Memory Updates

This diary is the memory update for the run. I did not add a separate lesson because the durable behavior is now encoded in `scripts/supervisor.sh`, and the rationale plus acceptance evidence are recorded in the outbox reply.

## Skill Updates

No skill changed. The existing `skills/branch-evolution-evaluation/` workflow already covers branch evidence scoring and includes the proof-pressure check.

## Decisions

- Chose a script change instead of another lesson because the behavior was stable enough to automate and affected supervisor control flow.
- Preserved the existing branch, pending-inbox, and clean-worktree guards.
- Added only a feedback-history guard rather than changing challenge content or commit-gate logic.

## Validation

Ran:

```bash
bash -n scripts/supervisor.sh
bash -n scripts/proof-pressure-check.sh
scripts/proof-pressure-check.sh
```

Scratch probes under `.self-harness/tmp/`:

- Positive probe with current branch history seeded one progressive challenge and left inbox count `1`.
- Negative probe with stubbed no-feedback `git log` skipped challenge creation and left inbox count `0`.

Final checks run before handoff:

```bash
find mailbox/processing -maxdepth 1 -type f ! -name .gitkeep -print
find .self-harness/tmp -maxdepth 1 -type f \( -name 'outbox-*' -o -name '*.tmp' \) -print
git diff -- constitution/
bash -n scripts/supervisor.sh
bash -n scripts/proof-pressure-check.sh
scripts/proof-pressure-check.sh
scripts/docs-check.sh
```

## Risks Or Incidents

The change is control-plane behavior, so the main risk is under-seeding challenges if the low-value subject pattern misses a future passive-loop commit style. The risk is constrained because the gate uses the same low-value pattern family already used by proof pressure, and a supervisor can still place explicit mailbox challenges manually.

No incident occurred. `constitution/` was not modified.

## Next Suggested Work

Supervisor should review whether the `scripts/supervisor.sh` feedback gate and `scripts/proof-pressure-check.sh` should return to `main` together. The feedback gate is small and aligned with the constitution, but it should be reviewed as a control-plane change rather than accepted solely on branch self-proof.
