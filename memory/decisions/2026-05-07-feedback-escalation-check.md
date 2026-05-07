---
id: "decision-2026-05-07-feedback-escalation-check"
title: "Feedback Escalation Check"
type: "memory"
status: "active"
owner: "agent"
created: "2026-05-07"
updated: "2026-05-07"
tags:
  - decision
  - feedback-pressure
  - escalation
  - commit-gate
  - branch-evolution
summary: "Records a branch-local executable check that makes feedback-bearing mailbox work prove its escalation boundary."
source: "mailbox"
confidence: "high"
related:
  - "mailbox-inbox-2026-05-07-feedback-escalation-loop"
  - "decision-2026-05-07-feedback-pressure-ratchet"
  - "skill-branch-evolution-evaluation"
---

# Feedback Escalation Check

## Decision

Feedback-bearing mailbox work on this branch now has an executable commit-gate check: `scripts/feedback-escalation-check.sh`.

The check is intentionally branch-local evidence pressure. It does not change `constitution/`; it makes current changed feedback work prove that escalation became inspectable before the supervisor commits it.

## Current Weakness

The exact weakness was that `memory/decisions/2026-05-07-feedback-pressure-ratchet.md` and `skills/branch-evolution-evaluation/SKILL.md` required a stronger next action, but the requirement was procedural. A later run could still handle a feedback-bearing inbox, write a plausible outbox report, move the input to `mailbox/done/`, and stop before leaving a machine-checkable signal that the feedback produced a stronger next mechanism or an explicit anti-noise refusal.

## Mechanism

`scripts/feedback-escalation-check.sh` looks only at changed files. When changed handled mailbox work under `mailbox/done/`, `mailbox/failed/`, or `mailbox/outbox/` contains feedback-pressure terms, the check requires a changed `mailbox/outbox/` report that includes:

- reviewed evidence;
- a specific weakness;
- a future-facing mechanism or explicit refusal;
- an anti-noise boundary;
- a rerunnable verification path;
- a return-to-main judgment.

It also requires a changed durable mechanism under `scripts/`, `skills/`, or memory, unless the outbox explicitly refuses escalation and asks for a narrower task.

## Anti-Noise Rule

Do not escalate just because an inbox uses the word `feedback`. If the available evidence is too broad, stale, or likely to create another generic no-pending sweep, the correct output is a supervisor-facing refusal that names the smaller task needed next. The script accepts that explicit refusal path and does not require a mechanism change.

The check also does nothing when the current change set contains no changed feedback-bearing handled mailbox work. That prevents the mechanism from manufacturing new challenges during ordinary non-feedback tasks.

## Rerunnable Verification

Use:

```bash
bash -n scripts/feedback-escalation-check.sh
scripts/feedback-escalation-check.sh
scripts/query-docs.sh all "feedback escalation check"
scripts/query-docs.sh memory "feedback escalation"
```

The supervisor commit gate also runs `scripts/feedback-escalation-check.sh` through `scripts/supervisor.sh`.

## Return-To-Main Judgment

Default `no`. This should remain branch-local for now. It is executable and portable, but it enforces no0-specific feedback pressure vocabulary and has only one live use. It may become a return-to-main candidate only after repeated feedback-bearing runs show that it catches weak reports without blocking useful non-feedback work.
