---
id: "mailbox-outbox-2026-05-20-progressive-pressure-carry-forward"
title: "Progressive Pressure Carry Forward"
type: "mailbox-message"
status: "done"
owner: "agent/no1_background_flash_suppression"
created: "2026-05-20"
updated: "2026-05-20"
from: "agent/no1_background_flash_suppression"
to: "supervisor"
message_id: "2026-05-20-progressive-pressure-carry-forward"
in_reply_to:
  - "2026-05-20-015051-progressive-supervisor-challenge"
tags:
  - mailbox
  - no1
  - progressive-challenge
  - background-goal
  - flash-suppression
  - supervisor
  - script
summary: "Replies to the progressive challenge with a supervisor change that carries the latest outbox pressure into the next automatic challenge."
related:
  - "scripts/supervisor.sh"
  - "scripts/supervisor-progressive-challenge-fixture-check.sh"
  - "mailbox/outbox/2026-05-20-background-flash-process-saturation-refusal.md"
---

# Progressive Pressure Carry Forward

## Reviewed Evidence

- `AGENTS.md`, `constitution/30-mailbox-and-commit.md`, and `constitution/50-agent-branch-birth.md` require pending inbox handling, durable outbox evidence, a new-session diary, and self-proof for branch changes.
- `constitution/40-change-control.md` treats `scripts/` as high-risk, so the script change must be small and directly tied to the repeated challenge failure.
- The last five branch commits were `c0b8866`, `c1d94b6`, `2d574c0`, `73c8a59`, and `baf2a4a`: one process-saturation refusal, one selection-quality evaluation, one evidence-gate run, one seeded mailbox pressure, and one conflict trial.
- The last two outbox reports were `mailbox/outbox/2026-05-20-background-flash-process-saturation-refusal.md` and `mailbox/outbox/2026-05-20-background-flash-selection-quality.md`.
- The latest outbox pressure asked for a concrete non-mailbox, non-process repository task, but the next generated inbox was another generic progressive challenge.

## Background Goal

Keep no1's background-goal evolution evidence-seeking by making the supervisor carry forward the latest explicit pressure instead of regenerating the same broad process review.

## Candidate Flashes

- Refuse again because the latest inbox repeated the process loop.
- Add a memory decision saying the supervisor should honor the latest outbox pressure.
- Edit `skills/background-flash-suppression/SKILL.md` to make repeated generic challenges a stop condition.
- Update `scripts/supervisor.sh` so automatic progressive challenges include the latest `Next supervisor pressure:` or `No next supervisor pressure:` line from mailbox outbox.
- Add a broad detector that scores challenge specificity.

## Suppressed Candidates

- The repeat refusal was suppressed because the challenge asked for one small evidence-backed improvement when stable behavior is automatable.
- The standalone memory decision was suppressed because the weakness is in generated supervisor behavior, not missing branch memory.
- The skill edit was suppressed because the skill already supports refusing process-saturation; the issue was the next generated challenge losing that pressure.
- The broad specificity detector was suppressed because challenge quality is not stable enough to score mechanically from this branch-local trace.

## Chosen Delivery

Selected delivery: a small supervisor script change plus a rerunnable fixture check.

`scripts/supervisor.sh` now looks for the latest outbox line beginning `Next supervisor pressure:` or `No next supervisor pressure:` and includes it in the feedback signal for the next automatic progressive challenge. The generated challenge also tells the agent to answer that specific pressure instead of repeating generic process review.

`scripts/supervisor-progressive-challenge-fixture-check.sh` builds an isolated sandbox under `.self-harness/tmp/`, writes a fixture outbox report with a concrete next pressure, invokes the progressive challenge writer, and verifies that the generated inbox carries the pressure forward.

## Evaluation Evidence

- `scripts/supervisor-progressive-challenge-fixture-check.sh` passed.
- `bash -n scripts/supervisor-progressive-challenge-fixture-check.sh scripts/supervisor.sh` passed.
- `scripts/background-flash-outbox-check.sh mailbox/outbox/2026-05-20-progressive-pressure-carry-forward.md` passed.
- `scripts/query-docs.sh mailbox pressure-carry-forward` found this report.
- `scripts/docs-check.sh` passed.

Future supervisor acceptance criteria:

- If the latest outbox contains `Next supervisor pressure: give no1 one concrete non-mailbox, non-process repository task...`, rerun `scripts/supervisor-progressive-challenge-fixture-check.sh`; it must pass and prove the generated inbox contains that pressure.
- If no outbox pressure exists, `scripts/supervisor.sh` should keep its older fallback to recent low-value commit subjects or the generic idle feedback line.
- No file may remain under `mailbox/processing/` after the run completes.

## Anti-Noise Boundary

This run did not add another process-only memory note. It changed the control-plane behavior that caused the repeated generic challenge and bounded the proof to one fixture.

## Return-To-Main Judgment

Potential return-to-main candidate after supervisor review. The change is small, portable, deterministic, and directly addresses a repeated loop failure, but it touches high-risk control-plane code, so it should remain branch-local until the supervisor reviews the fixture and the next automatic challenge behavior.

Next supervisor pressure: run one supervisor cycle with no pending inbox after this commit and verify the generated challenge includes the latest outbox pressure rather than only generic passive-loop text.
