---
title: "Feedback Pressure Continuous Supervision"
id: "mailbox-inbox-2026-05-08-032901-feedback-pressure-continuous-supervision"
type: "mailbox-inbox"
status: "done"
owner: "supervisor"
created: "2026-05-08"
updated: "2026-05-08"
from: "supervisor"
to: "agent/no0_self_imporve"
message_id: "2026-05-08-032901-feedback-pressure-continuous-supervision"
tags:
  - supervisor
  - feedback-pressure
  - continuous-supervision
  - self-improvement
summary: "Requires a stronger mechanism so idle supervisor cycles keep raising evidence-seeking pressure without noisy generic sweeps."
related:
  - "mailbox/outbox/2026-05-08-trigger-review-outbox-markdown-artifact-fixture-reply.md"
---

# Feedback Pressure Continuous Supervision

Human feedback: the supervisor still stops too easily. A clean run that merely says there is no pending inbox is not enough; the supervisor should keep raising requirements based on prior feedback and current branch weaknesses until the branch reaches a clearly defended target.

## Observed Weakness

After `b82ea07`, the checked-out trigger-review repair looked clean, but the loop skipped with no pending inbox. That behavior is technically clean yet operationally weak: it relies on the human or supervisor to hand-seed the next hard question.

## Requirement

Design and implement a narrowly bounded continuous-pressure mechanism, or write a focused refusal if implementation is not yet safe.

The mechanism should make idle supervisor cycles produce one higher-quality next challenge when recent branch work has unresolved promotion, proof, or feedback-pressure debt. It must avoid resurrecting generic no-pending sweeps or infinite self-reference loops.

## Acceptance Criteria

- Review the latest three run commits and their changed `mailbox/outbox/*.md` files before drawing conclusions.
- Explain why the current idle skip is insufficient, using only repository-relative evidence.
- Prefer an implemented deterministic check or supervisor behavior change with fixtures. If implementation is too risky, produce a concrete proposal plus a smaller executable probe.
- Preserve the anti-noise boundary: no generic repository sweep reports, no repeated challenge for an already-covered source, no automatic pressure when the only evidence is a completed clean stop condition.
- State a return-to-main judgment. Default to defer unless the proof is broad and low-risk enough for the family genome.
- End with exactly one `Next supervisor pressure:` line or one bounded `No next supervisor pressure:` refusal that includes a concrete `Supervisor evaluation trigger:` and `Stop condition:`.
- Keep all durable content repository-relative and leave experiments under `.self-harness/tmp/`.
