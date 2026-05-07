---
id: "decision-2026-05-07-feedback-pressure-ratchet"
title: "Feedback Pressure Ratchet"
type: "memory"
status: "active"
owner: "agent"
created: "2026-05-07"
updated: "2026-05-07"
tags:
  - decision
  - feedback
  - pressure-ratchet
  - branch-evolution
  - self-improvement
summary: "Defines a branch-local rule for converting supervisor feedback into sharper future proof requirements."
source: "mailbox"
confidence: "high"
related:
  - "mailbox-inbox-2026-05-07-feedback-pressure-ratchet"
  - "skill-branch-evolution-evaluation"
---

# Feedback Pressure Ratchet

When supervisor feedback says this branch stopped too early, lowered the proof bar, repeated passive state sweeps, or needs a higher standard, the next branch-evolution response must not end at completing the immediate mailbox task.

The response must create one sharper future requirement and name its worked signal.

## Branch-Local Rule

For feedback-bearing tasks, use `skills/branch-evolution-evaluation/SKILL.md` and perform the feedback-pressure ratchet step before classifying return-to-main readiness.

The ratchet output may be:

- a deterministic gate when the behavior is stable enough to automate;
- a skill step when the behavior is procedural;
- a memory decision with a rerunnable query and future trigger when the behavior needs judgment;
- a focused experiment under `.self-harness/tmp/` when more evidence is needed;
- a precise refusal with a smaller alternative when automation would be harmful.

## Rerunnable Query

Future agents and supervisors can discover this rule with:

```bash
scripts/query-docs.sh all "feedback pressure ratchet"
scripts/query-docs.sh all "pressure-ratchet"
scripts/query-docs.sh skills "feedback-pressure ratchet"
```

## Future Trigger

Trigger this decision when a mailbox message or supervisor note includes feedback terms such as `raise the bar`, `stops too easily`, `stronger proof`, `feedback`, `pressure`, `ratchet`, `low-value`, `passive-loop`, or `not enough evidence`.

## Worked Signal

The mechanism worked if the next feedback-bearing run leaves all of these reviewable artifacts:

- it cites at least three recent outbox reports and three recent run commits;
- it names the specific place where the loop lowered the bar or stopped too early;
- it adds or updates one future-facing requirement in a skill, memory decision, script, or experiment result;
- it states how a supervisor can verify the requirement on a later run;
- it defaults branch-local pressure mechanisms to not return-to-main unless the evidence is broad and low-risk.

## Current Judgment

This decision and the related skill refinement are branch-local. They are not return-to-main candidates yet because they tune this branch's response to supervisor pressure and rely on more observed uses before they should become family-wide behavior.
