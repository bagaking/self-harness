---
title: "Feedback Pressure Challenge"
id: "mailbox-inbox-2026-05-07-124332-feedback-pressure-challenge"
type: "mailbox-inbox"
status: "done"
owner: "supervisor"
created: "2026-05-07"
updated: "2026-05-07"
from: "supervisor"
to: "agent/no0_self_imporve"
message_id: "2026-05-07-124332-feedback-pressure-challenge"
tags:
  - supervisor
  - feedback-pressure
  - explicit-feedback
  - self-improvement
summary: "Asks no0 to tighten trigger-review evidence precision after a live false positive."
---

# Feedback Pressure Challenge

The supervisor generated this from explicit feedback after reviewing the latest branch run.

## Feedback

Supervisor feedback: the latest docs-check fixture proof passed, but `scripts/supervisor.sh triggers --status review` now exposes a precision bug in the trigger review queue.

The command listed `mailbox/outbox/2026-05-07-122028-completed-records-post-run-pass-reply.md` as `review-evidence`. The later evidence it cited included generic matches such as:

- `mailbox/done/2026-05-07-122904-feedback-pressure-challenge.md` matched `creating`;
- `memory/diary/2026-05-07-122904-docs-check-fixture-proof.md` matched `modified` and `instead`;
- `scripts/supervisor.sh` matched `instead`, `creating`, and some real path terms.

That is not enough to prove the completed-record trigger fired. It is noisy evidence matching. The completed-record trigger should need meaningful terms, or a conjunction of specific terms, not standalone generic English words from the trigger sentence.

Raise the bar by tightening the trigger evidence mechanism so the review queue does not promote generic-token matches into `review-evidence`.

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

- Add or update a focused fixture or live regression that proves the completed-record trigger does not become `review-evidence` from unrelated later durable docs that only contain generic words such as `creating`, `modified`, or `instead`.
- Preserve the existing positive trigger-list fixture: later evidence containing the concrete trigger path must still surface as `review-evidence`.
- Do not answer with a generic repository sweep or no-pending report.
- Do not modify `constitution/`.
- Keep durable paths repository-relative and scratch work under `.self-harness/tmp/`.
- Run `scripts/supervisor-evaluation-trigger-list-check.sh`, `scripts/feedback-escalation-check.sh`, `scripts/docs-check.sh`, and focused validation before handoff.
- Include exactly one concrete `Next supervisor pressure:` line, or one bounded `No next supervisor pressure:` refusal with a concrete `Supervisor evaluation trigger:` plus a `Smaller useful task:` or `Stop condition:`.
