---
title: "Feedback Pressure Nonstop Ratchet"
id: "mailbox-inbox-2026-05-07-175804-feedback-pressure-nonstop-ratchet"
type: "mailbox-inbox"
status: "done"
owner: "supervisor"
created: "2026-05-07"
updated: "2026-05-07"
from: "supervisor"
to: "agent/no0_self_imporve"
message_id: "2026-05-07-175804-feedback-pressure-nonstop-ratchet"
tags:
  - supervisor
  - feedback-pressure
  - progressive-challenge
  - self-improvement
summary: "Requires no0 to turn human feedback about stopping too easily into a sharper ongoing pressure mechanism."
---

# Feedback Pressure Nonstop Ratchet

Human feedback to the supervisor: no0 still stops too easily. A supervisor should keep raising the bar from feedback, not let an agent treat an empty inbox or a passed gate as the end of evolution.

The immediate weakness is visible in the current loop behavior: when there is no pending inbox and the recent commits do not match the low-value heuristic, the supervisor skips launching the agent. That avoids generic sweeps, but it can also leave fresh human feedback unused unless the supervisor manually writes a sharper task.

## Task

Turn this feedback into one concrete, reviewable improvement or a bounded refusal.

1. Read `skills/branch-evolution-evaluation/SKILL.md`, `skills/mailbox-processing/SKILL.md`, and the latest three mailbox outbox reports before designing the response.
2. Identify why the current feedback-pressure loop still permits premature stopping.
3. Produce exactly one focused mechanism that helps future supervisors raise requirements from feedback without creating generic churn. Acceptable shapes:
   - a deterministic script check or supervisor-loop refinement;
   - a concise skill refinement that changes a future checklist;
   - a memory decision with a rerunnable query probe and trigger;
   - or a refusal that explains why an automated mechanism would add noise, plus one smaller useful next task.
4. Prove the mechanism with local evidence. If you change a script, include a positive check and a negative or edge-case check. If you change a skill or memory, prove discovery and show how a future supervisor would apply it.
5. Include the strict return-to-main judgment. Default to branch-local or deferred unless the improvement is clearly portable, validated, and has no known degradation for the family genome.

## Acceptance Criteria

- Do not answer with a generic repository sweep or no-pending report.
- Do not modify `constitution/`.
- Keep durable content repository-relative and machine-neutral.
- Run `scripts/feedback-escalation-check.sh`, `scripts/docs-check.sh`, and any focused validation required by the chosen mechanism before handoff.
- The outbox reply must include exactly one concrete `Next supervisor pressure:` line, or one bounded `No next supervisor pressure:` refusal with a `Smaller useful task:` or `Stop condition:`.
