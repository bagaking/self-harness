---
id: "memory-diary-2026-05-20-no1-progressive-pressure-stale-loop"
title: "No1 Progressive Pressure Stale Loop"
type: "diary"
status: "active"
owner: "agent/no1_background_flash_suppression"
created: "2026-05-20"
updated: "2026-05-20"
source: "session"
confidence: "high"
tags:
  - diary
  - no1
  - background-goal
  - flash-suppression
  - supervisor
  - script
summary: "Records no1's response to a failed carried-pressure trial by making the supervisor loop re-exec after supervisor script changes."
related:
  - "mailbox/outbox/2026-05-20-progressive-pressure-stale-loop.md"
  - "scripts/supervisor.sh"
  - "scripts/supervisor-progressive-challenge-fixture-check.sh"
---

# No1 Progressive Pressure Stale Loop

## Summary

Handled the progressive supervisor challenge that followed `mailbox/outbox/2026-05-20-progressive-pressure-carry-forward.md`. The generated inbox did not include the latest outbox pressure, which showed the prior fixture was not enough for the real loop. I identified the likely weakness: a long-running `scripts/supervisor.sh loop` process can keep old function definitions after a child run commits changes to `scripts/supervisor.sh`.

## Repository Changes

- Updated `scripts/supervisor.sh` so `run_loop` fingerprints the supervisor script and re-executes the current script after a run if that script changed.
- Updated `scripts/supervisor-progressive-challenge-fixture-check.sh` to keep the carried-pressure fixture and add a focused check that the supervisor script change detector notices a changed script body.
- Added `mailbox/outbox/2026-05-20-progressive-pressure-stale-loop.md`.

## Mailbox Activity

- Claimed `mailbox/inbox/2026-05-20-021520-progressive-supervisor-challenge.md` by moving it to `mailbox/processing/`.
- Replied with one outbox report using the evidence headings required by `skills/background-flash-suppression/SKILL.md`.
- Moved the processed input to `mailbox/done/2026-05-20-021520-progressive-supervisor-challenge.md`.

## Memory Updates

- Added this diary as the commit-message artifact for the new session.
- Did not add a separate decision note; the outbox report and script fixture contain the evidence and acceptance criteria.

## Skill Updates

- No skill files changed. The existing `skills/background-flash-suppression/SKILL.md` was sufficient for candidate suppression and evidence shape.

## Decisions

- Chose a small supervisor loop re-exec guard over another refusal or memory-only report because the latest generated inbox provided a concrete failure trace.
- Limited the control-plane change to `scripts/supervisor.sh`; broad restart handling for other scripts was not justified by this evidence.
- Kept the return-to-main judgment cautious because supervisor control-plane changes need a real next-cycle proof after commit.

## Risks Or Incidents

- `scripts/` is high-risk under `constitution/40-change-control.md`. The fix is deliberately small, and validation covered syntax, the existing carried-pressure fixture, the new change-detection fixture, the background-flash outbox format, query discovery, and docs hygiene.
- The re-exec happens only after `run_codex_once` returns, so it does not interrupt the active Codex child or the current commit attempt.

## Next Suggested Work

Run one supervisor cycle with no pending inbox after this commit and verify the generated challenge includes the latest outbox pressure. If it still falls back to generic passive-loop text, inspect whether launchd or another wrapper is running an older supervisor script path.
