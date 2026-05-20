---
title: "Background Flash Conflict Trial"
id: "mailbox-inbox-2026-05-20-0908-background-flash-conflict-trial"
type: "mailbox-inbox"
status: "done"
owner: "supervisor"
created: "2026-05-20"
updated: "2026-05-20"
from: "supervisor"
to: "agent/no1_background_flash_suppression"
message_id: "2026-05-20-0908-background-flash-conflict-trial"
tags:
  - mailbox
  - supervisor
  - no1
  - background-goal
  - flash-suppression
  - conflict-trial
summary: "Requires no1 to reuse its new background flash suppression skill on conflicting improvement candidates and prove it selects one without creating process churn."
related:
  - "skills/background-flash-suppression/SKILL.md"
  - "mailbox/outbox/2026-05-20-background-flash-suppression-delivery.md"
  - "memory/diary/2026-05-20-no1-background-flash-suppression-first-delivery.md"
---

# Background Flash Conflict Trial

Your first delivery created `skills/background-flash-suppression/SKILL.md`. This second pressure tests whether the skill actually improves your next choice.

## Conflict Set

Use `skills/background-flash-suppression/SKILL.md` to choose exactly one of these plausible improvements:

1. Improve `skills/background-flash-suppression/SKILL.md` itself to make the workflow more testable.
2. Add a tiny script that checks an outbox reply contains the suppression evidence headings.
3. Write a memory decision describing when this skill should return to `main`.
4. Add a proposal for repository-level handling of runtime-materialized `skills/.system/`.
5. Refuse all four with a smaller proof if none is ready.

## Acceptance Criteria

- Claim this inbox first after reading `AGENTS.md` and `constitution/00-charter.md`.
- Explicitly invoke and follow `skills/background-flash-suppression/SKILL.md`.
- Generate 3-5 candidate flashes from the conflict set, suppress all but one, and deliver only the selected candidate.
- The outbox reply must include all evidence headings required by the skill.
- Prove the selected candidate with the closest focused command.
- Do not modify `constitution/`.
- Do not write absolute local paths or local device details.
- Do not add another generic self-description or broad repository sweep.
- Do not promote the skill to `main`; at most provide evidence for supervisor review.

## Supervisor Bar

This is a reuse trial. The best outcome is not more framework. The best outcome is a small selected improvement plus clear evidence that the skill caused you to reject tempting alternatives.
