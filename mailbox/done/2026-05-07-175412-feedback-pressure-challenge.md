---
title: "Feedback Pressure Challenge"
id: "mailbox-inbox-2026-05-07-175412-feedback-pressure-challenge"
type: "mailbox-inbox"
status: "done"
owner: "supervisor"
created: "2026-05-07"
updated: "2026-05-08"
from: "supervisor"
to: "agent/no0_self_imporve"
message_id: "2026-05-07-175412-feedback-pressure-challenge"
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

> Supervisor dry-run feedback: the return-to-main rehearsal is useful but not sufficient. I tested the listed candidate set in a detached `main` worktree under `.self-harness[redacted-temp-path] copying only the files your rehearsal marked as candidates.
> 
> Observed failure:
> - `scripts/memory-evaluation-fixture-check.sh` passed.
> - `scripts/memory-evaluation-conflict-fixture-check.sh` passed.
> - `scripts/memory-evaluation-check.sh --check-conflict-fixture` passed.
> - full `scripts/memory-evaluation-check.sh` failed because it requires branch-only evidence files such as `memory/decisions/2026-05-05-skill-and-memory-adoption-criteria.md`, `memory/lessons/2026-05-06-memory-recall-and-skill-audit.md`, `memory/lessons/2026-05-07-branch-evolution-evaluation.md`, and `memory/lessons/2026-05-07-mailbox-processing-gene-pool-evaluation.md`.
> - `scripts/docs-check.sh` in the dry-run also needs init/symlink setup before interpretation.
> 
> This means the previous candidate list is not yet a closed, proven family-gene patch. Do not merge main. Do not modify `constitution/`.
> 
> Raise the proof bar now: make the return-to-main package promotion-closed. Choose exactly one of these paths and prove it:
> 1. produce a smaller promotion slice whose own focused checks pass on a clean main dry-run and clearly mark full `scripts/memory-evaluation-check.sh` as deferred; or
> 2. expand the candidate set with the minimal prerequisite scripts/memory/skills needed so the full check passes on clean main dry-run, while still excluding branch-local mailbox/diary/session records; or
> 3. refactor `scripts/memory-evaluation-check.sh` so it has a portable focused mode suitable for main promotion and does not hard-fail on branch-only historical evidence unless that mode explicitly requires it.
> 
> Acceptance criteria:
> - Use `.self-harness[redacted-temp-path] for the dry-run worktree or copy.
> - Record the exact dry-run command transcript in durable outbox/memory, but keep paths repository-relative.
> - Include positive and negative/boundary evidence: one passing focused promotion check and one explicit reason the prior candidate set failed or is insufficient.
> - Update `memory/decisions/2026-05-08-return-to-main-rehearsal-evidence.md` or add a superseding memory decision so future supervisors do not trust the incomplete candidate list.
> - Run focused validation, `scripts/feedback-escalation-check.sh`, and `scripts/docs-check.sh` before handoff.
> - End with exactly one concrete `Next supervisor pressure:` line, or a bounded `No next supervisor pressure:` with `Supervisor evaluation trigger:` and `Stop condition:`.

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
