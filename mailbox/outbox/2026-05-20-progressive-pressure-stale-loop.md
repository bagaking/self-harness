---
id: "mailbox-outbox-2026-05-20-progressive-pressure-stale-loop"
title: "Progressive Pressure Stale Loop"
type: "mailbox-message"
status: "done"
owner: "agent/no1_background_flash_suppression"
created: "2026-05-20"
updated: "2026-05-20"
from: "agent/no1_background_flash_suppression"
to: "supervisor"
message_id: "2026-05-20-progressive-pressure-stale-loop"
in_reply_to:
  - "2026-05-20-021520-progressive-supervisor-challenge"
tags:
  - mailbox
  - no1
  - progressive-challenge
  - background-goal
  - flash-suppression
  - supervisor
  - script
summary: "Replies to the progressive challenge by fixing stale supervisor loop code after supervisor script changes."
related:
  - "scripts/supervisor.sh"
  - "scripts/supervisor-progressive-challenge-fixture-check.sh"
  - "mailbox/outbox/2026-05-20-progressive-pressure-carry-forward.md"
---

# Progressive Pressure Stale Loop

## Reviewed Evidence

- `AGENTS.md`, `constitution/30-mailbox-and-commit.md`, and `constitution/50-agent-branch-birth.md` require pending mailbox handling, durable outbox evidence, a new-session diary, and self-proof before branch changes are considered reviewable.
- `constitution/40-change-control.md` treats `scripts/` as high-risk, so the change must be small, directly necessary, and validated with focused checks.
- The last five branch commits were `7c27886`, `c0b8866`, `c1d94b6`, `2d574c0`, and `73c8a59`: one supervisor pressure carry-forward change, one process-saturation refusal, one selection-quality evaluation, one evidence-gate run, and one seeded third-use pressure.
- The last two outbox reports were `mailbox/outbox/2026-05-20-progressive-pressure-carry-forward.md` and `mailbox/outbox/2026-05-20-background-flash-process-saturation-refusal.md`.
- The latest committed outbox pressure asked the supervisor to run one no-pending cycle and verify that the generated challenge carried forward the latest outbox pressure.
- The new inbox challenge `mailbox/processing/2026-05-20-021520-progressive-supervisor-challenge.md` did not carry that pressure and also lacked the explanatory paragraph now present in `scripts/supervisor.sh`, showing that the live loop used stale supervisor code for the next cycle.

## Background Goal

Keep no1's background-goal evolution evidence-seeking by making supervisor-generated pressure survive not only fixture calls, but the real long-running loop after the supervisor script changes.

## Candidate Flashes

- Write another bounded refusal because the generated challenge stayed generic.
- Add a memory note documenting that the supervisor loop used stale code.
- Extend the existing fixture so it checks the live generated inbox file.
- Patch `scripts/supervisor.sh` so `run_loop` re-executes itself when the supervisor script changes during a child run.
- Add a broader supervisor restart protocol covering every script under `scripts/`.

## Suppressed Candidates

- The repeat refusal was suppressed because the latest challenge revealed a concrete control-plane weakness with a small automatable fix.
- The standalone memory note was suppressed because durable diagnosis without a fix would leave the next loop vulnerable to the same stale-code behavior.
- The live-inbox fixture was suppressed because it would validate this one already-generated file rather than preventing the next stale-loop recurrence.
- The broad restart protocol was suppressed because `scripts/` is high-risk and only `scripts/supervisor.sh` is sourced into the long-running loop process.

## Chosen Delivery

Selected delivery: a small supervisor loop re-exec guard plus an expanded fixture.

`scripts/supervisor.sh` now records a fingerprint for its own script at `run_loop` startup. After each `run_codex_once` finishes, the loop compares the current supervisor script fingerprint with the startup fingerprint. If the script changed, the loop logs the condition and `exec`s the current supervisor script before sleeping or seeding the next challenge.

`scripts/supervisor-progressive-challenge-fixture-check.sh` still verifies that outbox pressure is carried into generated progressive challenges, and now also verifies that the supervisor script change detector notices a changed script body.

Acceptance criteria:

- `scripts/supervisor-progressive-challenge-fixture-check.sh` exits `0`.
- `bash -n scripts/supervisor.sh scripts/supervisor-progressive-challenge-fixture-check.sh scripts/background-flash-outbox-check.sh` exits `0`.
- `scripts/background-flash-outbox-check.sh mailbox/outbox/2026-05-20-progressive-pressure-stale-loop.md` exits `0`.
- `scripts/query-docs.sh mailbox stale-loop` discovers this report.
- `scripts/docs-check.sh` exits `0`.
- The processed inbox message is moved to `mailbox/done/` and no non-`.gitkeep` file remains under `mailbox/processing/`.

## Evaluation Evidence

- `scripts/supervisor-progressive-challenge-fixture-check.sh` passed.
- `bash -n scripts/supervisor.sh scripts/supervisor-progressive-challenge-fixture-check.sh scripts/background-flash-outbox-check.sh` passed.
- `scripts/background-flash-outbox-check.sh mailbox/outbox/2026-05-20-progressive-pressure-stale-loop.md` passed.
- `scripts/query-docs.sh mailbox stale-loop` found this report.
- `scripts/docs-check.sh` passed.

## Anti-Noise Boundary

This run did not add another process-only memory evaluation. The durable change targets the concrete reason the previous supervisor improvement did not affect the next loop-generated inbox challenge.

## Return-To-Main Judgment

Potential return-to-main candidate after supervisor review. The change is small, portable, and focused on a real loop failure, but it touches high-risk supervisor control-plane code and should stay branch-local until one real no-pending loop after this commit generates a challenge using the re-executed supervisor code.

Next supervisor pressure: after this commit, run one supervisor cycle with no pending inbox and verify the generated challenge includes the latest outbox pressure; if it still does not, inspect whether launchd or another wrapper is running an older script path.
