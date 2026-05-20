---
id: "mailbox-outbox-2026-05-20-background-flash-conflict-trial"
title: "Background Flash Conflict Trial"
type: "mailbox-message"
status: "done"
owner: "agent/no1_background_flash_suppression"
created: "2026-05-20"
updated: "2026-05-20"
from: "agent/no1_background_flash_suppression"
to: "supervisor"
message_id: "2026-05-20-background-flash-conflict-trial"
in_reply_to:
  - "2026-05-20-010745-progressive-supervisor-challenge"
  - "2026-05-20-0908-background-flash-conflict-trial"
tags:
  - mailbox
  - no1
  - background-goal
  - flash-suppression
  - conflict-trial
  - script
summary: "Reports the conflict-trial selection of one focused heading checker for background flash suppression outbox evidence."
related:
  - "skills/background-flash-suppression/SKILL.md"
  - "scripts/background-flash-outbox-check.sh"
  - "mailbox/outbox/2026-05-20-background-flash-suppression-delivery.md"
---

# Background Flash Conflict Trial

## Reviewed Evidence

- `AGENTS.md` and `constitution/00-charter.md` keep `constitution/` human-owned and read-only.
- `constitution/30-mailbox-and-commit.md` requires durable outbox replies, processed mailbox state, and a diary for a new session.
- `constitution/40-change-control.md` treats `scripts/` as high risk, so a script change must be small, directly necessary, and validated.
- `constitution/50-agent-branch-birth.md` requires branch work to self-prove with focused evidence before any return-to-main review.
- `skills/background-flash-suppression/SKILL.md` requires three to five candidate flashes, suppression gates, exactly one selected delivery, focused validation, and the evidence headings used in this report.
- `git log --oneline --decorate --max-count=5` showed the recent branch path: conflict-trial mailbox seed, first no1 delivery, initial pressure seed, merge from `main`, and the local Codex preflight mechanism.
- `find mailbox/outbox -maxdepth 1 -type f -name '*.md' | sort | tail -n 2` showed only one prior outbox report in this branch, `mailbox/outbox/2026-05-20-background-flash-suppression-delivery.md`.
- The previous outbox report validated the skill as a first delivery but used mixed heading labels from two inbox requests. That made it a useful negative fixture for the stricter current skill headings.

## Background Goal

Use the background flash suppression workflow on a real conflict set, reject tempting alternatives, and deliver one small improvement with rerunnable evidence.

## Candidate Flashes

- Improve `skills/background-flash-suppression/SKILL.md` itself to make the workflow more testable.
- Add a tiny script that checks a background-flash outbox reply contains the required suppression evidence headings.
- Write a memory decision describing when this skill should return to `main`.
- Add a proposal for repository-level handling of runtime-materialized `skills/.system/`.
- Refuse all four with a smaller proof if none is ready.

## Suppressed Candidates

- The skill-edit candidate was suppressed because the current problem is not unclear instructions; it is whether the required report shape can be checked on a concrete artifact.
- The memory-decision candidate was suppressed because return-to-main guidance would be premature without a second successful reuse and a rerunnable check.
- The `skills/.system/` proposal was suppressed because it is broader repository policy, not the smallest proof for this conflict trial.
- The bounded-refusal candidate was suppressed because a local, focused, non-network validation target was available.

## Chosen Delivery

Selected delivery: `scripts/background-flash-outbox-check.sh`.

The script checks one or more Markdown files for the eight evidence headings required by `skills/background-flash-suppression/SKILL.md` and for exactly one `Next supervisor pressure:` or `No next supervisor pressure:` line. This keeps the trial small: it validates the report shape without changing the skill, adding a broad proposal, or turning the workflow into a larger framework.

## Evaluation Evidence

- `bash -n scripts/background-flash-outbox-check.sh` passed.
- Negative case: `scripts/background-flash-outbox-check.sh mailbox/outbox/2026-05-20-background-flash-suppression-delivery.md` exited `1` and reported the missing exact headings `Candidate Flashes`, `Suppressed Candidates`, `Chosen Delivery`, and `Evaluation Evidence`.
- Positive case: `scripts/background-flash-outbox-check.sh mailbox/outbox/2026-05-20-background-flash-conflict-trial.md` passed after this report was written.
- Repository documentation check: `scripts/docs-check.sh` passed.

## Anti-Noise Boundary

This run did not modify `constitution/`, did not add another generic identity note, did not expand the skill before reuse, and did not write a repository-wide policy proposal. The selected script only checks the evidence format for the specific background flash suppression workflow.

## Return-To-Main Judgment

Not ready for `main` by itself. The script is portable, small, and locally validated, but it is still branch-specific evidence for no1's trial. A future supervisor can consider returning it only if the heading contract remains useful after another independent branch-agent report uses the same workflow.

Next supervisor pressure: ask no1 to run `scripts/background-flash-outbox-check.sh` against the next background-flash outbox reply before `docs-check`, then decide whether the exact heading contract is stable enough to keep or should stay branch-local.
