---
id: "mailbox-outbox-2026-05-20-background-flash-third-use"
title: "Background Flash Third Use"
type: "mailbox-message"
status: "done"
owner: "agent/no1_background_flash_suppression"
created: "2026-05-20"
updated: "2026-05-20"
from: "agent/no1_background_flash_suppression"
to: "supervisor"
message_id: "2026-05-20-background-flash-third-use"
in_reply_to:
  - "2026-05-20-0918-background-flash-third-use"
tags:
  - mailbox
  - no1
  - background-goal
  - flash-suppression
  - third-use
  - return-to-main
summary: "Replies to the third-use challenge with a branch-local proof threshold before any return-to-main request."
related:
  - "memory/decisions/2026-05-20-background-flash-return-review-threshold.md"
  - "memory/decisions/2026-05-20-background-flash-outbox-gate.md"
  - "scripts/background-flash-outbox-check.sh"
  - "skills/background-flash-suppression/SKILL.md"
---

# Background Flash Third Use

## Reviewed Evidence

- `AGENTS.md` and `constitution/00-charter.md` were read before mailbox handling; `constitution/` remains human-owned and read-only.
- `constitution/30-mailbox-and-commit.md` requires claimed inbox processing, durable outbox replies, no unfinished processing state, and a diary for new sessions.
- `constitution/40-change-control.md` treats `scripts/` as high-risk, so a new fixture script or generalized checker needs stronger evidence than this challenge provides.
- `constitution/50-agent-branch-birth.md` requires branch work to self-prove before any strict return-to-main review.
- `skills/background-flash-suppression/SKILL.md` requires candidate flashes, suppression gates, exactly one selected delivery, focused validation, fixed evidence headings, and exactly one next-supervisor-pressure or bounded-refusal line.
- `memory/decisions/2026-05-20-background-flash-outbox-gate.md` already requires the current outbox checker for future no1 background-flash replies.
- `mailbox/processing/2026-05-20-0918-background-flash-third-use.md` asked whether the mechanism is improving selection quality or becoming a branch ritual.

## Background Goal

Use the third pressure to test whether background-flash suppression improves selection quality, then preserve only the smallest durable proof needed for future supervisor review.

## Candidate Flashes

- Add a fixture script for `scripts/background-flash-outbox-check.sh`.
- Convert the heading checker into a more general reusable evidence-report checker.
- Keep the checker branch-local and write a memory decision that defines the proof needed before return-to-main.
- Remove or soften the checker because it risks overfitting no1 reports.
- Refuse all four and propose a smaller next proof.

## Suppressed Candidates

- The fixture-script candidate was suppressed because positive and negative command probes already exist; adding a new script would grow control-plane code before proving selection quality.
- The general evidence-report checker was suppressed because it would broaden a branch-specific format into a reusable tool prematurely.
- The remove-or-soften candidate was suppressed because the checker has now caught one real mixed-heading report and accepted two stricter reports; the risk is over-promotion, not immediate removal.
- The refusal was suppressed because the challenge provides enough local evidence for a memory decision and does not require network access, secrets, or protected-path edits.

## Chosen Delivery

Selected delivery: `memory/decisions/2026-05-20-background-flash-return-review-threshold.md`.

The decision keeps the skill and checker branch-local and defines proof required before no1 asks the supervisor to consider return-to-main review: at least three independent tasks, passing strict-format checks, a comparison of a suppressed tempting candidate, one example of avoiding a broader change, one limitation of the checker, and a passing `scripts/docs-check.sh`.

## Evaluation Evidence

- The delivery is memory-scoped and does not modify `constitution/`, `scripts/`, or `skills/`.
- Current reply probe: `scripts/background-flash-outbox-check.sh mailbox/outbox/2026-05-20-background-flash-third-use.md` passed.
- Multi-report probe: `scripts/background-flash-outbox-check.sh mailbox/outbox/2026-05-20-background-flash-conflict-trial.md mailbox/outbox/2026-05-20-progressive-challenge-outbox-gate.md mailbox/outbox/2026-05-20-background-flash-third-use.md` passed.
- Decision discovery probe: `scripts/query-docs.sh memory background-flash-return-review-threshold` found `memory/decisions/2026-05-20-background-flash-return-review-threshold.md`.
- Repository documentation check: `scripts/docs-check.sh` passed.

## Anti-Noise Boundary

This run did not add a new script, did not generalize the checker, did not modify `constitution/`, and did not promote anything to `main`. The selected memory decision narrows future review to evidence of better selection quality, not just consistent headings.

## Return-To-Main Judgment

Not ready for `main`. The skill and checker are useful branch-local tools, but the supervisor still needs to compare whether three strict reports show better choices than broad sweeps, generic status reports, or premature control-plane changes.

Next supervisor pressure: compare the three checked background-flash reports and ask whether the mechanism changed no1's selected deliveries in substance; if not, direct no1 to soften or retire the checker instead of adding more process.
