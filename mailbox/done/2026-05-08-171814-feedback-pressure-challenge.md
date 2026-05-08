---
title: "Feedback Pressure Challenge"
id: "mailbox-inbox-2026-05-08-171814-feedback-pressure-challenge"
type: "mailbox-inbox"
status: "done"
owner: "supervisor"
created: "2026-05-08"
updated: "2026-05-08"
from: "supervisor"
to: "agent/no0_self_imporve"
message_id: "2026-05-08-171814-feedback-pressure-challenge"
tags:
  - supervisor
  - feedback-pressure
  - explicit-feedback
  - self-improvement
summary: "Turns explicit human feedback into one focused pressure task without waiting for idle-loop heuristics."
---

# Feedback Pressure Challenge

The supervisor generated this from explicit human feedback. This path exists so fresh feedback can create one focused inbox task even when the idle low-value heuristic would skip launching the agent.

## Feedback

> Post-commit supervisor review of d393408 found one blocking failure before accepting any stop condition. Current checkout passes continuous-supervisor-pressure, branch-stop-condition, feedback-escalation, run-linked map, docs, pending-inbox claim latency, and idle-stop-proof fixtures. But `scripts/supervisor-stable-copy-check.sh` fails in `check_idle_once_skips_launch`: its sandbox sets `SELF_HARNESS_AUTO_CHALLENGE=0` and installs a fake `codex` that must not be invoked, yet the supervisor logs `idle stop proof failed`, `idle agent launch required: stop proof failed`, then invokes codex and the fixture exits 99. This means the stable-copy fixture no longer proves the idle skip boundary after the stop-proof mechanism was added.
>
> Fix this narrow conflict. Decide whether the fixture should disable stop-proof for its idle-skip case, create enough sandbox history/markers for stop-proof to pass, or whether supervisor.sh needs a cleaner separation between auto-challenge and stop-proof behavior. Add or update a fixture so `scripts/supervisor-stable-copy-check.sh` passes and still catches accidental Codex launch in the intended idle-skip case. Also keep the existing stop-proof behavior covered by `scripts/idle-stop-proof-fixture-check.sh`; do not weaken real branch pressure just to satisfy the fixture.
>
> Acceptance: run `scripts/supervisor-stable-copy-check.sh`, `scripts/idle-stop-proof-fixture-check.sh`, `scripts/continuous-supervisor-pressure-check.sh`, `scripts/branch-stop-condition-check.sh --run-limit 5 --trigger-limit 8 --evidence-limit 3`, `scripts/feedback-escalation-check.sh`, and `scripts/docs-check.sh`. Return-to-main remains deferred unless the supervisor later verifies a checked-out idle loop. Do not modify constitution.

## Task

Use the feedback to raise the bar without creating generic churn.

1. Review the latest three branch outbox reports and latest three run commits before choosing a response.
2. Identify the exact way the current loop can still stop too early or lower the proof bar.
3. Produce exactly one focused mechanism or a bounded refusal:
   - a deterministic script check or supervisor-loop refinement;
   - a concise skill refinement;
   - a memory decision with a rerunnable query probe and trigger;
   - or a refusal that explains why automation would add noise and names one smaller useful task.
4. Prove the result with local evidence. Script changes need a positive check and a negative or edge-case check.
5. Include the strict return-to-main judgment. Default to branch-local or deferred unless the improvement is clearly portable, validated, and has no known degradation for the family genome.

## Acceptance Criteria

- Do not answer with a generic repository sweep or no-pending report.
- Do not modify `constitution/`.
- Keep durable paths repository-relative and scratch work under `.self-harness/tmp/`.
- Run `scripts/feedback-escalation-check.sh`, `scripts/docs-check.sh`, and focused validation before handoff.
- Include exactly one concrete `Next supervisor pressure:` line, or one bounded `No next supervisor pressure:` refusal with a concrete `Supervisor evaluation trigger:` plus a `Smaller useful task:` or `Stop condition:`.
