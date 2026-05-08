---
title: "Feedback Pressure Challenge"
id: "mailbox-inbox-2026-05-08-051115-feedback-pressure-challenge"
type: "mailbox-inbox"
status: "done"
owner: "supervisor"
created: "2026-05-08"
updated: "2026-05-08"
from: "supervisor"
to: "agent/no0_self_imporve"
message_id: "2026-05-08-051115-feedback-pressure-challenge"
tags:
  - supervisor
  - feedback-pressure
  - explicit-feedback
  - self-improvement
summary: "Turns explicit human feedback into one focused pressure task without waiting for idle-loop heuristics."
related:
  - "mailbox/outbox/2026-05-08-idle-stop-proof-reply.md"
  - "scripts/supervisor.sh"
  - "scripts/idle-stop-proof-fixture-check.sh"
  - "memory/decisions/2026-05-08-branch-stop-condition-check.md"
  - "skills/branch-evolution-evaluation/SKILL.md"
---

# Feedback Pressure Challenge

The supervisor generated this from explicit human feedback. This path exists so fresh feedback can create one focused inbox task even when the idle low-value heuristic would skip launching the agent.

## Feedback

> 上一轮已经证明 branch-stop-condition-check 可手动判断最近 run 是否 stop-safe，但当前 loop 在无 pending inbox 时仍只打印 `idle agent run skipped: no pending inbox after challenge seeding`，没有把 stop-condition check 作为 idle 停止前的可审计证据。请把这个差距当成新的更高要求：review scripts/supervisor.sh 的 idle skip 路径、scripts/branch-stop-condition-check.sh、最近两个 stop-condition outbox；然后实现一个克制的机制，优先让 idle skip 前产出可审计的 stop proof（例如运行 branch-stop-condition-check 并记录 ok，失败时不要静默 skip，而是 seed 一个 defect-specific challenge），并补一个正/负 fixture 证明 stop check 失败不会被静默当成 idle stop。若你认为自动运行会制造噪声，必须用 outbox 给出 bounded refusal，包含精确噪声成本、smaller useful task、rerunnable stop trigger。不要做泛化仓库 sweep，不要修改 constitution，严格判定 return-to-main。

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
