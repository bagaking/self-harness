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
summary: "Records a branch-local executable check that makes feedback-bearing mailbox work prove its escalation and continuity boundary, including reviewed trigger-backed refusal paths."
source: "mailbox"
confidence: "high"
related:
  - "mailbox-inbox-2026-05-07-feedback-escalation-loop"
  - "decision-2026-05-07-feedback-pressure-ratchet"
  - "skill-branch-evolution-evaluation"
  - "mailbox-inbox-2026-05-07-134325-feedback-pressure-challenge"
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
- a return-to-main judgment;
- exactly one feedback-continuity path.

It also requires a changed durable mechanism under `scripts/`, `skills/`, or memory, unless the outbox explicitly refuses escalation and asks for a narrower task.

The feedback-continuity path must be one of:

- one concrete `Next supervisor pressure:` line that the supervisor can turn into the next inbox;
- one `No next supervisor pressure:` refusal that explains why further escalation would be noisy and includes one concrete `Supervisor evaluation trigger:`, either `Smaller useful task:` or `Stop condition:`, and a rerunnable trigger-backed refusal review command such as `scripts/supervisor.sh triggers --status review`.

Generic next-pressure lines such as `raise the bar`, `improve`, `sweep`, or `inspect repository` are rejected. A report should not include both continuity paths.

The refusal trigger matters because a local anti-noise boundary is not permission for the supervisor loop to stop evaluating. A refusal must name the future signal that would make more pressure useful again, such as a failing gate, a changed supervisor path, a repeated missed claim, or a concrete evaluation warning tied to real task loss.

Fresh human feedback on 2026-05-07 showed a second refusal-path gap after `e45dd74`: a feedback-bearing run could write a compliant `No next supervisor pressure:` reply while never surfacing the trigger-backed refusal review queue that is supposed to keep those refusals operational. The gate now requires the refusal path itself to cite `scripts/supervisor.sh triggers --status review` or `scripts/supervisor-evaluation-trigger-list.sh --status review`, so a local anti-noise boundary has to leave a worked supervisor review signal in the same report.

## Anti-Noise Rule

Do not escalate just because an inbox uses the word `feedback`. If the available evidence is too broad, stale, or likely to create another generic no-pending sweep, the correct output is a supervisor-facing refusal that names the smaller task needed next. The script accepts that explicit refusal path and does not require a mechanism change.

The check also does nothing when the current change set contains no changed feedback-bearing handled mailbox work. That prevents the mechanism from manufacturing new challenges during ordinary non-feedback tasks.

The continuity rule is also anti-noise: it allows a bounded refusal, and it rejects generic next-pressure text that would create an endless chain of vague challenges.

## Rerunnable Verification

Use:

```bash
bash -n scripts/feedback-escalation-check.sh
scripts/feedback-escalation-check.sh
scripts/query-docs.sh all "feedback escalation check"
scripts/query-docs.sh memory "feedback escalation"
```

The supervisor commit gate also runs `scripts/feedback-escalation-check.sh` through `scripts/supervisor.sh`.

Continuity fixtures used during the 2026-05-07 pressure run:

- negative fixture: a changed feedback outbox with all old required sections but no next-pressure marker and no refusal failed with `missing feedback continuity marker`;
- marker-positive fixture: the same report plus one concrete `Next supervisor pressure:` line passed;
- old-refusal negative fixture: the same report plus one `No next supervisor pressure:` line and `Smaller useful task:` but no `Supervisor evaluation trigger:` failed;
- trigger-backed-without-review negative fixture: the same report plus one `No next supervisor pressure:` line, one concrete `Supervisor evaluation trigger:`, and `Stop condition:` failed when it did not include a trigger-review command;
- reviewed-refusal-positive fixture: the same report plus one `No next supervisor pressure:` line, one concrete `Supervisor evaluation trigger:`, `Stop condition:`, and `scripts/supervisor.sh triggers --status review` passed.

## Return-To-Main Judgment

Default `no`. This should remain branch-local for now. It is executable and portable, but it enforces no0-specific feedback pressure vocabulary and has only one live use. It may become a return-to-main candidate only after repeated feedback-bearing runs show that it catches weak reports without blocking useful non-feedback work.
