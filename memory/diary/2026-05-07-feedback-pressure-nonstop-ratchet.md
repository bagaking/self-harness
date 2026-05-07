---
id: "diary-2026-05-07-feedback-pressure-nonstop-ratchet"
title: "Feedback Pressure Nonstop Ratchet"
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
  - feedback-pressure
  - supervisor
  - control-plane
summary: "Records a run that added an explicit supervisor feedback command for seeding focused feedback-pressure challenges."
source: "session"
confidence: "high"
related:
  - "mailbox-inbox-2026-05-07-175804-feedback-pressure-nonstop-ratchet"
  - "mailbox-outbox-2026-05-07-feedback-pressure-nonstop-ratchet-reply"
  - "scripts/supervisor.sh"
---

# diary: feedback pressure nonstop ratchet

## Summary

Processed the pending supervisor challenge `mailbox/inbox/2026-05-07-175804-feedback-pressure-nonstop-ratchet.md`. The run added a focused supervisor `feedback` subcommand so explicit human feedback can become one reviewable feedback-pressure inbox without waiting for low-value idle history.

## Repository Changes

- Updated `scripts/supervisor.sh` with `scripts/supervisor.sh feedback [-F FILE] [--] FEEDBACK...`.
- Added `mailbox/outbox/2026-05-07-feedback-pressure-nonstop-ratchet-reply.md`.
- Moved the handled inbox item to `mailbox/done/2026-05-07-175804-feedback-pressure-nonstop-ratchet.md`.
- Added this diary under `memory/diary/`.

## Mailbox Activity

Claimed `mailbox/inbox/2026-05-07-175804-feedback-pressure-nonstop-ratchet.md` through `mailbox/processing/`, answered it under `mailbox/outbox/`, and completed it under `mailbox/done/`.

The outbox reply includes exactly one `Next supervisor pressure:` line and records positive, pending-inbox edge, and empty-feedback proof for the new command.

## Memory Updates

No standalone memory decision was added. The mechanism is already durable in `scripts/supervisor.sh`, and the mailbox reply plus this diary carry the review evidence.

## Skill Updates

No skill changed. Existing `skills/mailbox-processing/SKILL.md` and `skills/branch-evolution-evaluation/SKILL.md` were sufficient for the feedback-bearing mailbox workflow.

## Decisions

The current stop-too-easily gap was at the supervisor ingestion boundary: `seed_progressive_challenge_if_needed` only reacts to repeated low-value history, while `should_skip_idle_agent_launch` can skip a clean idle branch with no pending inbox. Fresh human feedback therefore still required manual inbox authoring.

I chose a supervisor-loop refinement instead of another agent-side checklist. The new command is explicit, guarded, and branch-local: it creates one focused feedback-pressure challenge only when run by the supervisor on an `agent/*` branch with no pending inbox. If an inbox already exists, it refuses to stack new pressure.

Return-to-main: deferred. The change is portable and locally validated, but it changes control-plane behavior and needs a real supervisor invocation before promotion to the family genome.

## Risks Or Incidents

The main risk is that explicit feedback text could be too broad and still produce a challenge. The generated acceptance criteria constrain the next run to exactly one mechanism or bounded refusal, and the pending-inbox guard prevents duplicate pressure while work is already waiting.

No incident occurred. `constitution/` was not modified.

## Validation

Focused checks run:

```bash
bash -n scripts/supervisor.sh
scripts/shell-syntax-check.sh scripts/supervisor.sh
scripts/feedback-escalation-check.sh
scripts/docs-check.sh
```

Results:

```text
shell-syntax-check: ok scripts/supervisor.sh
feedback-escalation-check: ok
docs-check: ok
```

Scratch positive proof under `.self-harness/tmp/feedback-command-positive-175804` exited `0` and wrote one `mailbox/inbox/*-feedback-pressure-challenge.md`.

Scratch pending-inbox edge proof under `.self-harness/tmp/feedback-command-pending-175804` exited `1` with `feedback challenge skipped: pending inbox already exists`.

Scratch empty-feedback proof under `.self-harness/tmp/feedback-command-empty-175804` exited `2` with `feedback: provide non-empty feedback text with arguments or -F FILE`.

Mailbox hygiene check printed no unfinished processing files before diary creation.

## Next Suggested Work

Use the new supervisor command on the next fresh human feedback item when no inbox is pending, then verify the generated feedback-pressure inbox is claimed by the next run instead of producing an idle skip or generic sweep.
