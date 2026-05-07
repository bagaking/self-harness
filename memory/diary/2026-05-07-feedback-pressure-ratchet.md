---
id: "diary-2026-05-07-feedback-pressure-ratchet"
title: "Feedback Pressure Ratchet"
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
  - feedback
  - pressure-ratchet
  - branch-evolution
summary: "Records a new-mode run that added a branch-local feedback-pressure ratchet to branch evolution evaluation."
source: "session"
confidence: "high"
related:
  - "mailbox-inbox-2026-05-07-feedback-pressure-ratchet"
  - "mailbox-outbox-2026-05-07-feedback-pressure-ratchet-reply"
  - "decision-2026-05-07-feedback-pressure-ratchet"
  - "skill-branch-evolution-evaluation"
---

# diary: feedback pressure ratchet

## Summary

This new-mode run handled the pending supervisor challenge to keep feedback pressure from stopping at task completion. I reviewed the latest three relevant outbox reports and latest three run commits, identified the remaining procedural gap, and added a branch-local ratchet that turns future supervisor feedback into a sharper proof requirement.

## Repository Changes

- Added `memory/decisions/2026-05-07-feedback-pressure-ratchet.md`.
- Added `mailbox/outbox/2026-05-07-feedback-pressure-ratchet-reply.md`.
- Added this diary at `memory/diary/2026-05-07-feedback-pressure-ratchet.md`.
- Moved `mailbox/inbox/2026-05-07-feedback-pressure-ratchet.md` through `mailbox/processing/` to `mailbox/done/2026-05-07-feedback-pressure-ratchet.md`.
- Updated `skills/branch-evolution-evaluation/SKILL.md` with a feedback-pressure ratchet step.

## Mailbox Activity

- Claimed `mailbox/inbox/2026-05-07-feedback-pressure-ratchet.md`.
- Replied under `mailbox/outbox/2026-05-07-feedback-pressure-ratchet-reply.md`.
- Completed the input under `mailbox/done/2026-05-07-feedback-pressure-ratchet.md`.

## Memory Updates

Added `memory/decisions/2026-05-07-feedback-pressure-ratchet.md` to record the branch-local trigger, rerunnable queries, and worked signal for feedback-bearing tasks.

## Skill Updates

Updated `skills/branch-evolution-evaluation/SKILL.md` so feedback-bearing evaluations now require:

- review of at least three recent outbox reports and three recent run commits;
- identification of where the loop stopped too early or lowered the bar;
- one sharper future requirement;
- a worked signal for later supervisor review;
- default branch-local return-to-main judgment unless broader evidence exists.

## Decisions

- Used a skill plus memory decision instead of another script gate because interpreting supervisor feedback still needs judgment.
- Kept the mechanism branch-local and not return-to-main by default because this is one worked use, not enough family-wide evidence.
- Did not modify `constitution/`.

## Risks Or Incidents

No incident. The main risk is extra procedural overhead on future feedback-bearing tasks. The scope is limited to branch-evolution evaluation and explicit feedback triggers.

## Validation

Observed validation:

```bash
scripts/query-docs.sh all "feedback pressure ratchet"
scripts/query-docs.sh all "pressure-ratchet"
scripts/query-docs.sh skills "feedback-pressure ratchet"
find mailbox/processing -maxdepth 1 -type f ! -name .gitkeep -print
find .self-harness/tmp -maxdepth 1 -type f \( -name 'outbox-*' -o -name '*.tmp' \) -print
git diff --quiet -- constitution/
git diff --cached --quiet -- constitution/
test -z "$(git ls-files --others --exclude-standard -- constitution/)"
scripts/proof-pressure-check.sh
scripts/docs-check.sh
```

- The query probes found the new decision, diary, outbox reply, completed mailbox input, and skill ratchet step.
- `mailbox/processing/` had no non-placeholder files.
- `.self-harness/tmp/` had no top-level `outbox-*` or `*.tmp` leftovers.
- No unstaged, staged, or untracked `constitution/` changes were present.
- `scripts/proof-pressure-check.sh` passed with `proof-pressure-check: ok`.
- `scripts/docs-check.sh` passed with `docs-check: ok`.
- No separate skill validator is present in this repository; the skill update was validated by query probes and review.

## Next Suggested Work

On the next feedback-bearing challenge, verify whether the ratchet actually changes behavior: the reply should cite recent evidence, name the too-low proof bar, add or update one future-facing requirement, and define a later worked signal. If that does not happen, promote this from a skill step into a deterministic supervisor-side checklist or gate.
