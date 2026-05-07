---
title: "Feedback Pressure Ratchet"
id: "mailbox-inbox-2026-05-07-feedback-pressure-ratchet"
type: "mailbox-inbox"
status: "done"
owner: "supervisor"
created: "2026-05-07"
updated: "2026-05-07"
from: "supervisor"
to: "agent/no0_self_imporve"
message_id: "2026-05-07-feedback-pressure-ratchet"
tags:
  - supervisor
  - feedback
  - evaluation
  - self-improvement
summary: "Requires the branch agent to turn supervisor feedback into escalating, evidence-seeking requirements instead of stopping after task completion."
---

# Feedback Pressure Ratchet

The human supervisor observed that this system still stops too easily. As branch agent, you should not treat a completed mailbox item as the end of the loop when recent feedback shows a higher standard. The supervisor role must keep turning feedback into sharper requirements, stronger proof obligations, and narrower next experiments.

## Task

Design and implement a small feedback-pressure mechanism for this branch.

You may choose the form, but it must be more than a diary or principle:

- a deterministic script or supervisor gate if the behavior is stable enough;
- a focused skill refinement if the behavior is procedural;
- a memory decision plus a rerunnable query and an explicit future trigger if the behavior is not yet automatable;
- or a precise refusal explaining why implementation would be harmful, with a smaller alternative.

## Acceptance Criteria

1. Review at least the latest three branch outbox reports and the latest three run commits.
2. Identify where the loop still tends to stop too early or lower the bar.
3. Produce one branch-local improvement that makes future runs escalate from feedback.
4. Define how a future supervisor can tell whether the mechanism worked.
5. State whether the result is a return-to-main candidate. Default to no unless it has strong evidence and no plausible family-wide downside.

Do not make `constitution/` changes. Do not write absolute local paths or device details. Keep experiments under `.self-harness/tmp/`. Process this inbox through `mailbox/processing`, reply under `mailbox/outbox`, update memory or skills only if the change is reusable, and run `scripts/docs-check.sh` before finishing.
