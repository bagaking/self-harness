---
title: "Feedback Pressure Challenge"
id: "mailbox-inbox-2026-05-08-061802-feedback-pressure-challenge"
type: "mailbox-inbox"
status: "done"
owner: "supervisor"
created: "2026-05-08"
updated: "2026-05-08"
from: "supervisor"
to: "agent/no0_self_imporve"
message_id: "2026-05-08-061802-feedback-pressure-challenge"
tags:
  - supervisor
  - feedback-pressure
  - explicit-feedback
  - self-improvement
summary: "Turns explicit human feedback into one focused pressure task without waiting for idle-loop heuristics."
related:
  - "mailbox/outbox/2026-05-08-continuous-pressure-lifecycle-marker-repair-reply.md"
---

# Feedback Pressure Challenge

The supervisor generated this from explicit human feedback. This path exists so fresh feedback can create one focused inbox task even when the idle low-value heuristic would skip launching the agent.

## Feedback

> Checked-out idle cycle exposed a false positive in the new feedback ratchet mechanism. After commit `090a0a5`, a clean checked-out loop logged `continuous pressure challenge skipped: all proof-debt sources already challenged` and then skipped idle. But `rg --fixed-strings "continuous-pressure-source: mailbox/outbox/2026-05-08-feedback-pressure-ratchet-reply.md"` shows the only match is inside `mailbox/outbox/2026-05-08-feedback-pressure-ratchet-reply.md` itself, in its `Next supervisor pressure:` sentence. That is not a durable lifecycle marker; it is the requirement asking for a future marker. Fix this narrow false positive. The repeat-suppression check must not treat source outbox prose as coverage for itself. Prefer restricting `has_existing_continuous_pressure_challenge_for_source` to actual lifecycle challenge/handled records, or requiring a line-level marker in inbox/processing/done/failed records that are not the source outbox. Add a fixture proving an outbox that merely asks for `continuous-pressure-source: <same-source>` still seeds exactly one continuous-pressure inbox, while a real lifecycle record suppresses repeats. Then prove with a checked-out idle cycle or an equivalent source-only idle seeding fixture. Keep return-to-main deferred and do not modify constitution.

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
