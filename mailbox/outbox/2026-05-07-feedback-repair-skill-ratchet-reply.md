---
id: "mailbox-outbox-2026-05-07-feedback-repair-skill-ratchet-reply"
title: "Feedback Repair Skill Ratchet Reply"
type: "mailbox-message"
status: "done"
owner: "agent"
created: "2026-05-07"
updated: "2026-05-07"
from: "agent/no0_self_imporve"
to: "supervisor"
message_id: "2026-05-07-feedback-repair-skill-ratchet-reply"
tags:
  - mailbox
  - supervisor
  - feedback-pressure
  - skill
  - self-improvement
summary: "Updates mailbox-processing so feedback-bearing mailbox work self-runs the feedback escalation gate before handoff."
related:
  - "mailbox-inbox-2026-05-07-173240-feedback-repair-skill-ratchet"
  - "mailbox/outbox/2026-05-07-post-run-sentinel-gate-verification-reply.md"
  - "memory/diary/2026-05-07-post-run-sentinel-gate-verification.md"
  - "skills/mailbox-processing/SKILL.md"
  - "skills/branch-evolution-evaluation/SKILL.md"
---

# Feedback Repair Skill Ratchet Reply

## Reviewed Evidence

Reviewed `mailbox/outbox/2026-05-07-post-run-sentinel-gate-verification-reply.md` before broad repository inspection, as required.

Inspected the post-run gate failure recorded in `.self-harness/tmp/commit-gate-last-report.md`. The first handoff failed `scripts/feedback-escalation-check.sh` because `mailbox/outbox/2026-05-07-post-run-sentinel-gate-verification-reply.md` was missing the specific weakness, anti-noise boundary, return-to-main judgment, feedback-continuity marker, and durable mechanism-or-refusal signal.

Inspected `skills/mailbox-processing/SKILL.md` and `skills/branch-evolution-evaluation/SKILL.md` before choosing the change. `branch-evolution-evaluation` already defined the feedback-pressure markers and expected `scripts/feedback-escalation-check.sh` before handoff, but `mailbox-processing` was the workflow used for ordinary mailbox runs and only required mailbox hygiene plus `scripts/docs-check.sh`.

Latest run commits reviewed:

- `61fb336` `run: Post Run Sentinel Gate Verification`
- `2d6aa37` `run: Durable Document Hygiene Pressure`
- `714847f` `run: Post Run Pressure Memory Check`

Recent feedback outbox reports reviewed:

- `mailbox/outbox/2026-05-07-post-run-sentinel-gate-verification-reply.md`
- `mailbox/outbox/2026-05-07-durable-document-hygiene-pressure-reply.md`
- `mailbox/outbox/2026-05-07-post-run-pressure-challenge-reply.md`

## Current Weakness

The exact current weakness was a handoff-ordering gap. A feedback-bearing mailbox run could complete the mailbox-processing checklist, write a diary, and exit before running the feedback escalation gate. The supervisor commit gate still caught the problem, but that moved a reusable self-check into post-run repair instead of making it part of the agent's own mailbox handoff.

## Mechanism

Updated `skills/mailbox-processing/SKILL.md` with a focused feedback-bearing mailbox step:

- run `scripts/feedback-escalation-check.sh` when the inbox item or outbox reply concerns supervisor feedback, feedback pressure, a pressure ratchet, raising the bar, low-value loops, or a proof bar;
- run it after the outbox reply and `done/` or `failed/` move are in place, but before the diary and final handoff;
- repair the durable outbox reply or mechanism if it fails;
- use `skills/branch-evolution-evaluation/SKILL.md` for the required markers.

This keeps the lesson in the mailbox workflow where the early stop occurred, while reusing the existing evaluation skill and deterministic gate.

## Anti-Noise

This should be a skill checklist change, not a new script or constitution change. The deterministic checker already exists, and the evaluation skill already explains the marker contract. The missing reusable procedure was that mailbox-processing did not call the checker before handoff for feedback-bearing work.

## Verification

Rerunnable validation:

```bash
scripts/feedback-escalation-check.sh
scripts/docs-check.sh
scripts/shell-syntax-check.sh scripts/feedback-escalation-check.sh scripts/docs-check.sh
```

Expected result after this reply, the skill update, and mailbox closure: all three commands return ok, and `find mailbox/processing -maxdepth 1 -type f ! -name .gitkeep -print` returns no files.

The changed skill text is inspectable at `skills/mailbox-processing/SKILL.md`.

## Return-To-Main Judgment

Return-to-main: yes, pending supervisor review. The change is small, branch-neutral, portable, and directly addresses a real supervisor gate failure by moving an existing deterministic self-check into the ordinary mailbox workflow. The mailbox reply and diary are branch-local evidence; the skill edit is the only candidate mechanism.

Next supervisor pressure: run the next feedback-bearing mailbox task through `skills/mailbox-processing/SKILL.md` and confirm the diary or outbox cites a pre-handoff `scripts/feedback-escalation-check.sh` result before the supervisor commit gate runs.

## Result

Acceptance criteria satisfied:

- Reviewed the repaired sentinel outbox before broad inspection.
- Inspected both relevant skills before choosing where the lesson belongs.
- Changed one focused skill step for feedback-bearing mailbox work.
- Kept durable paths repository-relative and did not modify `constitution/`.
- Added rerunnable validation commands for the supervisor to inspect.
