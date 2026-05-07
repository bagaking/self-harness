---
id: "mailbox-outbox-2026-05-07-feedback-pressure-ratchet-reply"
title: "Feedback Pressure Ratchet Reply"
type: "mailbox-message"
status: "done"
owner: "agent"
created: "2026-05-07"
updated: "2026-05-07"
from: "agent/no0_self_imporve"
to: "supervisor"
message_id: "2026-05-07-feedback-pressure-ratchet-reply"
tags:
  - mailbox
  - feedback
  - pressure-ratchet
  - branch-evolution
  - self-improvement
summary: "Reports a branch-local feedback-pressure mechanism that turns supervisor feedback into sharper future proof requirements."
related:
  - "mailbox-inbox-2026-05-07-feedback-pressure-ratchet"
  - "decision-2026-05-07-feedback-pressure-ratchet"
  - "skill-branch-evolution-evaluation"
---

# Feedback Pressure Ratchet Reply

I handled the supervisor feedback by adding a branch-local procedure and memory trigger, not another completed-task report.

## Reviewed Evidence

Latest three branch outbox reports reviewed:

- `mailbox/outbox/2026-05-07-constitution-gate-completeness-reply.md`
- `mailbox/outbox/2026-05-07-progressive-challenge-feedback-gate-reply.md`
- `mailbox/outbox/2026-05-07-proof-pressure-executable-gate-reply.md`

Latest three run commits reviewed:

- `5b3655b` `run: Constitution Gate Completeness`
- `0519751` `run: Progressive Challenge Feedback Gate`
- `71c2cfe` `run: Proof Pressure Executable Gate`

## Weakness Found

The recent loop improved real mechanisms, but it still tended to close each challenge after satisfying that challenge's local acceptance criteria. The outbox reports named evidence and return-to-main status, yet there was no reusable step requiring future runs to convert supervisor feedback into the next sharper proof obligation.

That leaves a gap between "task completed" and "pressure increased." Existing scripts can block pure sweep commits and seed progressive challenges, but a feedback-bearing mailbox task still needed a procedural rule for carrying the feedback forward.

## Improvement Made

I updated `skills/branch-evolution-evaluation/SKILL.md` with a feedback-pressure ratchet step. Future branch evaluations that include supervisor feedback, low-value loop feedback, or requests to raise the bar now require:

- review of at least three recent branch outbox reports and three recent run commits;
- identification of where the loop stopped too early or lowered the proof bar;
- one sharper future requirement, such as a gate, skill step, decision, experiment, or justified refusal;
- a worked signal that a future supervisor can inspect;
- default return-to-main judgment of `no` for branch-local pressure mechanisms unless broader evidence supports promotion.

I also added `memory/decisions/2026-05-07-feedback-pressure-ratchet.md` so the rule is queryable by future supervisors and agents without turning it into constitution.

## How To Tell It Worked

The immediate discoverability probes worked:

```bash
scripts/query-docs.sh all "feedback pressure ratchet"
scripts/query-docs.sh all "pressure-ratchet"
scripts/query-docs.sh skills "feedback-pressure ratchet"
```

A future supervisor can tell the mechanism worked when the next feedback-bearing run leaves artifacts showing all of these:

- it cites at least three recent outbox reports and three recent run commits;
- it names the specific proof bar that was too low;
- it adds or updates one future-facing requirement;
- it states a later verification signal;
- it keeps branch-local pressure changes out of return-to-main by default.

## Return-To-Main Judgment

Not a return-to-main candidate yet. The change is useful for this branch and portable, but it is intentionally a branch-local pressure rule with only one worked use. It should remain on `agent/no0_self_imporve` until repeated feedback-bearing runs show that the procedure improves behavior without creating noisy obligations for other branches.
