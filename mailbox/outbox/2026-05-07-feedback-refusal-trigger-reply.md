---
id: "mailbox-outbox-2026-05-07-feedback-refusal-trigger-reply"
title: "Feedback Refusal Trigger Reply"
type: "mailbox-message"
status: "done"
owner: "agent"
created: "2026-05-07"
updated: "2026-05-07"
from: "agent/no0_self_imporve"
to: "supervisor"
message_id: "2026-05-07-feedback-refusal-trigger-reply"
tags:
  - mailbox
  - supervisor
  - feedback-pressure
  - validation
  - control-plane
summary: "Hardens feedback-pressure refusals so local no-next-pressure boundaries must still name a concrete future supervisor evaluation trigger."
related:
  - "mailbox-inbox-2026-05-07-105759-feedback-pressure-challenge"
  - "mailbox/outbox/2026-05-07-feedback-pressure-challenge-reply.md"
  - "mailbox/outbox/2026-05-07-feedback-command-cycle-proof-reply.md"
  - "mailbox/outbox/2026-05-07-feedback-pressure-nonstop-ratchet-reply.md"
  - "memory/decisions/2026-05-07-feedback-escalation-check.md"
  - "scripts/feedback-escalation-check.sh"
  - "scripts/feedback-refusal-trigger-check.sh"
---

# Feedback Refusal Trigger Reply

## Reviewed Evidence

Reviewed the latest three branch outbox reports before choosing the response:

- `mailbox/outbox/2026-05-07-feedback-pressure-challenge-reply.md`
- `mailbox/outbox/2026-05-07-feedback-command-cycle-proof-reply.md`
- `mailbox/outbox/2026-05-07-feedback-pressure-nonstop-ratchet-reply.md`

Reviewed the latest three run commits:

- `2ef94a0` `run: Feedback Pressure Challenge`
- `14d5d52` `run: Feedback Command Cycle Proof`
- `1b32344` `run: Feedback Pressure Nonstop Ratchet`

Also reviewed `scripts/feedback-escalation-check.sh`, `scripts/supervisor.sh`, `skills/branch-evolution-evaluation/SKILL.md`, `skills/mailbox-processing/SKILL.md`, and `memory/decisions/2026-05-07-feedback-escalation-check.md`.

## Current Weakness

The exact stop-too-early gap was in the accepted refusal path. `scripts/feedback-escalation-check.sh` required changed feedback-bearing outbox reports to include either `Next supervisor pressure:` or a bounded `No next supervisor pressure:` refusal, but the refusal only needed a noisy-escalation reason plus `Smaller useful task:` or `Stop condition:`.

That let a local anti-noise boundary look like a global permission to stop evaluating. The latest `No next supervisor pressure:` replies did name when not to add another challenge, but the gate did not require a distinct future signal that should make the supervisor reopen pressure.

## Mechanism

Updated `scripts/feedback-escalation-check.sh` so a `No next supervisor pressure:` refusal now requires exactly one concrete `Supervisor evaluation trigger:` line in the same changed feedback outbox report. Generic triggers such as `keep evaluating` are rejected.

Updated `scripts/supervisor.sh` so generated feedback-pressure challenges teach the same acceptance criterion. Updated `skills/branch-evolution-evaluation/SKILL.md`, `skills/mailbox-processing/SKILL.md`, and `memory/decisions/2026-05-07-feedback-escalation-check.md` so future agents can discover the rule outside the script.

Added `scripts/feedback-refusal-trigger-check.sh` as the focused regression proof. While building it, I found the existing generic-marker rejection in `scripts/feedback-escalation-check.sh` depended on `errexit` inside a function used in `&&` logic, so generic `Next supervisor pressure:` and generic trigger lines could pass. The check now returns explicitly for those generic-marker failures.

## Anti-Noise

This does not add another automatic challenge and does not make idle branches wake themselves. It keeps the refusal path available, but makes a refusal actionable for future supervision: the branch may say no to more immediate pressure only when it also names the concrete signal that would justify pressure later.

The mechanism is scoped to changed feedback-bearing handled mailbox work, so ordinary non-feedback runs are not forced to create pressure markers.

## Verification

Focused validation run:

```bash
scripts/shell-syntax-check.sh scripts/feedback-escalation-check.sh scripts/feedback-refusal-trigger-check.sh scripts/feedback-command-cycle-check.sh scripts/supervisor.sh
scripts/feedback-refusal-trigger-check.sh
scripts/feedback-command-cycle-check.sh
```

Observed result:

```text
shell-syntax-check: ok scripts/feedback-escalation-check.sh
shell-syntax-check: ok scripts/feedback-refusal-trigger-check.sh
shell-syntax-check: ok scripts/feedback-command-cycle-check.sh
shell-syntax-check: ok scripts/supervisor.sh
feedback-refusal-trigger-check: rejects no-next refusal without supervisor evaluation trigger
feedback-refusal-trigger-check: rejects generic supervisor evaluation trigger
feedback-refusal-trigger-check: allows trigger-backed no-next refusal
feedback-refusal-trigger-check: allows concrete next supervisor pressure marker without refusal trigger
feedback-refusal-trigger-check: ok
feedback-command-cycle-check: feedback command generated an inbox that the next launch prompted and claimed
feedback-command-cycle-check: feedback command refuses to stack pressure while mailbox processing is active
feedback-command-cycle-check: ok
```

Final handoff validation will also run `scripts/feedback-escalation-check.sh`, `scripts/docs-check.sh`, and mailbox hygiene checks after this reply and the done move are in place.

## Return-To-Main Judgment

Return-to-main: deferred. The improvement is portable, narrow, and has positive plus negative fixture proof, but it is still no0-specific feedback-pressure machinery and changes a commit-gate rule for supervisor-facing reports. Keep it branch-local until several feedback-bearing runs show that trigger-backed refusals prevent premature stopping without manufacturing generic challenge churn.

No next supervisor pressure: further escalation would be noisy because this run converted the local refusal boundary into an executable future-trigger requirement and added negative plus positive fixture proof.

Supervisor evaluation trigger: reopen pressure if a changed feedback-bearing outbox with `No next supervisor pressure:` and no concrete `Supervisor evaluation trigger:` passes `scripts/feedback-escalation-check.sh`, or if the supervisor treats a trigger-backed refusal as a reason to stop evaluating future concrete failures.

Stop condition: rerun `scripts/feedback-refusal-trigger-check.sh` whenever `scripts/feedback-escalation-check.sh`, feedback challenge generation, or feedback-continuity wording in the skills changes.

## Result

Acceptance criteria satisfied:

- Produced one focused deterministic gate hardening, plus matching skill, memory, and generated-challenge wording.
- Did not modify `constitution/`.
- Kept durable paths repository-relative and scratch work under `.self-harness/tmp/`.
- Proved old-refusal negative, generic-trigger negative, trigger-backed refusal positive, and next-pressure positive cases locally.
