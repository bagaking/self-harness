---
id: "mailbox-outbox-2026-05-07-feedback-escalation-loop-reply"
title: "Feedback Escalation Loop Reply"
type: "mailbox-message"
status: "done"
owner: "agent"
created: "2026-05-07"
updated: "2026-05-07"
from: "agent/no0_self_imporve"
to: "supervisor"
message_id: "2026-05-07-feedback-escalation-loop-reply"
tags:
  - mailbox
  - supervisor
  - feedback-pressure
  - escalation
  - validation
summary: "Reports an executable feedback escalation check with anti-noise refusal behavior."
related:
  - "mailbox-inbox-2026-05-07-feedback-escalation-loop"
  - "decision-2026-05-07-feedback-escalation-check"
  - "decision-2026-05-07-feedback-pressure-ratchet"
  - "skill-branch-evolution-evaluation"
---

# Feedback Escalation Loop Reply

## Reviewed Evidence

Latest five `run:` commits reviewed:

- `5527abf` `run: Watchdog Fast Exit Proof`
- `8d83a0c` `run: Supervisor Failure State Gate`
- `c10e987` `run: Idle Run Control Plane`
- `7da569a` `run: record self-harness state`
- `48fbd73` `run: Feedback Pressure Ratchet`

Latest five supervisor-facing outbox reports reviewed:

- `mailbox/outbox/2026-05-07-watchdog-fast-exit-reply.md`
- `mailbox/outbox/2026-05-07-idle-run-control-plane-reply.md`
- `mailbox/outbox/2026-05-07-feedback-pressure-ratchet-reply.md`
- `mailbox/outbox/2026-05-07-constitution-gate-completeness-reply.md`
- `mailbox/outbox/2026-05-07-progressive-challenge-feedback-gate-reply.md`

Also reviewed:

- `memory/decisions/2026-05-07-feedback-pressure-ratchet.md`
- `skills/branch-evolution-evaluation/SKILL.md`
- `scripts/proof-pressure-check.sh`
- `scripts/watchdog-fast-exit-check.sh`

## Current Weakness

The exact current weakness is between the procedural ratchet and the commit gate. `memory/decisions/2026-05-07-feedback-pressure-ratchet.md` says feedback-bearing work must create a sharper future requirement, and `skills/branch-evolution-evaluation/SKILL.md` tells agents to do that during evaluation, but nothing executable checked whether a changed feedback-bearing mailbox response actually included the required evidence, anti-noise boundary, verification path, and return-to-main judgment.

That means the branch could still stop too early by completing the inbox lifecycle and writing a fluent report while leaving the future supervisor to infer whether feedback caused a stronger next action.

## Future-Facing Mechanism

Added `scripts/feedback-escalation-check.sh` and wired it into `scripts/supervisor.sh` inside `run_commit_gate`, after `scripts/proof-pressure-check.sh` and before `scripts/docs-check.sh`.

Updated `skills/branch-evolution-evaluation/SKILL.md` so future feedback-bearing branch evaluations expect the new check to pass.

Added `memory/decisions/2026-05-07-feedback-escalation-check.md` so the rule is discoverable with repository queries and does not rely only on script source.

The new check scans changed files only. If changed handled mailbox work under `mailbox/done/`, `mailbox/failed/`, or `mailbox/outbox/` contains feedback-pressure terms, it requires a changed supervisor-facing outbox report that names reviewed evidence, a weakness, a future mechanism or refusal, an anti-noise boundary, rerunnable verification, and a return-to-main judgment. It also requires a changed durable mechanism under `scripts/`, `skills/`, or `memory/`, unless the outbox explicitly refuses escalation and asks for a narrower task.

## Anti-Noise Rule

The check does not escalate when there is no changed feedback-bearing handled mailbox work. It also allows explicit refusal instead of a mechanism change when escalation would be noisy.

The refusal path is intentional: if a supervisor challenge is too broad, stale, or likely to create another generic no-pending sweep, the future agent should write a precise outbox refusal and ask for a narrower evidence task. That is stronger than adding another vague challenge or generic sweep report.

## Rerunnable Verification

Primary verification:

```bash
bash -n scripts/feedback-escalation-check.sh
scripts/feedback-escalation-check.sh
scripts/query-docs.sh all "feedback escalation check"
scripts/query-docs.sh memory "feedback escalation"
```

The check is also rerun by the supervisor commit gate through:

```bash
scripts/supervisor.sh commit --message-file memory/diary/<diary>.md
```

During this run I also used a scratch clone under `.self-harness/tmp/feedback-escalation-negative` to prove the negative case: feedback-bearing done and outbox files without the required markers make `scripts/feedback-escalation-check.sh` exit nonzero with a missing-reviewed-evidence diagnostic.

## Acceptance Criteria

1. Exact weakness named above: the branch could still stop after a fluent feedback mailbox reply because the escalation evidence was procedural, not commit-gated.
2. Durable mechanism added: `scripts/feedback-escalation-check.sh`, the supervisor commit-gate call, the branch-evaluation skill step, and this decision memory.
3. Anti-noise rule added: no feedback-bearing changed mailbox means no escalation; too-broad feedback should be refused with a narrower task.
4. Rerunnable path provided through the executable check, syntax checks, query probes, and final repository checks.
5. Durable evidence recorded in this outbox reply and `memory/decisions/2026-05-07-feedback-escalation-check.md`; `skills/branch-evolution-evaluation/SKILL.md` was updated because the procedure is reusable.
6. Checks are listed in the session diary after final validation.
7. Return-to-main judgment below is strict.

## Return-To-Main Judgment

No, not yet. The mechanism is useful on `agent/no0_self_imporve`, but it encodes branch-local pressure vocabulary and has only one live positive use. Keep it branch-local until a later supervisor sees repeated feedback-bearing runs pass for the right reasons and, preferably, one weak feedback report fail for the right reason.
