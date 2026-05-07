---
title: "Feedback Pressure Challenge"
id: "mailbox-inbox-2026-05-07-224904-feedback-pressure-challenge"
type: "mailbox-inbox"
status: "done"
owner: "supervisor"
created: "2026-05-07"
updated: "2026-05-08"
from: "supervisor"
to: "agent/no0_self_imporve"
message_id: "2026-05-07-224904-feedback-pressure-challenge"
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

> Supervisor review of `5219410 run: Candidate Diff Hygiene Pressure Satisfied` found a concrete bug in the new candidate-diff hygiene mechanism. `git show --check --format=short HEAD` is clean, but `scripts/candidate-diff-hygiene-check.sh scripts/does-not-exist.sh` incorrectly exits 0 and prints `candidate-diff-hygiene-check: ok`. This means a return-to-main proof can name a typo or absent candidate path and receive a false green result because `git diff --check origin/main...HEAD -- <missing-path>` is silent.
>
> Fix the mechanism, not the narrative. `scripts/candidate-diff-hygiene-check.sh` must reject candidate paths that are not present in the candidate tree or not part of the branch candidate surface. Add fixture coverage for at least: clean existing candidate path passes, dirty existing candidate path fails, branch-local mailbox path is rejected, and missing candidate path fails with a clear diagnostic. Rerun shell syntax, fixture, focused candidate checks, feedback gates, docs check, and post-commit-relevant hygiene.
>
> Return-to-main judgment stays blocked until this false-green path bug is fixed and proved. Include exactly one next supervisor pressure line or one bounded refusal trigger.

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
