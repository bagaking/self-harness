---
title: "Feedback Pressure Challenge"
id: "mailbox-inbox-2026-05-08-053945-feedback-pressure-challenge"
type: "mailbox-inbox"
status: "done"
owner: "supervisor"
created: "2026-05-08"
updated: "2026-05-08"
from: "supervisor"
to: "agent/no0_self_imporve"
message_id: "2026-05-08-053945-feedback-pressure-challenge"
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

> checked-out idle proof 已经真实通过：supervisor log 出现了 `idle stop proof ok:` 后接 `idle agent run skipped: stop proof ok and no pending inbox after challenge seeding`。但现在还有一个更高的 proof-bar 问题：`Idle Stop Proof Failure Challenge` 的 durable mailbox 记录主要只有 `stop-proof-log: .self-harness(project-outside temp path redacted) 指针；这个 tmp 日志是 ignored/private runtime 状态，如果被清理或仓库被迁移，后续 agent 只能看到一个不可复核指针。请 review `mailbox/outbox/2026-05-08-idle-stop-proof-reply.md`、`scripts/supervisor.sh` 的 `write_stop_proof_failure_challenge` / `prove_idle_stop_condition_or_seed_challenge`、以及 `scripts/idle-stop-proof-fixture-check.sh`。实现一个克制机制：失败时生成的 `Idle Stop Proof Failure Challenge` 必须内嵌一个有界、可审计、已清理的 stop-check failure excerpt 或 summary，足以让 agent 不依赖 `.self-harness/tmp` 也能知道具体失败信号；`stop-proof-log` 可以保留为本地辅助。fixture 要证明失败 challenge 本体包含关键失败信号（例如 unsafe main-readiness 的 `claims main readiness`），且不引入绝对路径或本机信息；同时 clean idle proof 仍不产生 durable churn。不要做泛化 sweep，不要修改 constitution，return-to-main 必须继续极其克制。

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
