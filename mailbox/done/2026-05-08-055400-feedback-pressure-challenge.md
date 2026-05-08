---
title: "Feedback Pressure Challenge"
id: "mailbox-inbox-2026-05-08-055400-feedback-pressure-challenge"
type: "mailbox-inbox"
status: "done"
owner: "supervisor"
created: "2026-05-08"
updated: "2026-05-08"
from: "supervisor"
to: "agent/no0_self_imporve"
message_id: "2026-05-08-055400-feedback-pressure-challenge"
tags:
  - supervisor
  - feedback-pressure
  - explicit-feedback
  - self-improvement
summary: "Turns explicit human feedback into one focused pressure task without waiting for idle-loop heuristics."
related:
  - "mailbox/outbox/2026-05-08-feedback-pressure-ratchet-reply.md"
---

# Feedback Pressure Challenge

The supervisor generated this from explicit human feedback. This path exists so fresh feedback can create one focused inbox task even when the idle low-value heuristic would skip launching the agent.

## Feedback

> Human/supervisor feedback: 这次提交 `2922f05 run: Idle Stop Proof Failure Excerpt` 解决了 failed idle stop proof challenge 的自包含问题，但它的 outbox 仍用 `No next supervisor pressure:` 结束，并把 stop condition 绑定到这一条局部压力线。最新的人类反馈是：agent 很容易停下来；supervisor 应该不断根据 feedback 提出更高要求。请不要做泛化 sweep，也不要修改 constitution。请设计并实现一个克制、可审计的持续反馈压力机制，让明确的人类/监督者 feedback 在 durable mailbox 或 memory 中形成可查询的未闭环压力源，直到后续 run 用更高层级证据关闭；局部 fixture pass 只能关闭当前子问题，不能自动关闭整个人类 feedback ratchet。机制要证明：1. 最近明确 feedback 可以被查询/识别为还需要下一轮更高要求；2. 完成当前子问题时，outbox 必须给出下一层可审计压力，或者给出非常窄的 bounded refusal 且提供 supervisor 可运行的 trigger；3. clean idle 仍不产生无意义 churn；4. return-to-main 继续严格 defer，除非能证明对家族基因百分百有益且无劣化。请复核最新三个 run commits/outbox，运行 feedback-escalation、branch-stop-condition、idle-stop-proof 和相关 fixture，并把结论写入 outbox/memory。

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
