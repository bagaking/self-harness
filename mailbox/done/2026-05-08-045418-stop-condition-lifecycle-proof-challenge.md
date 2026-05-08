---
title: "Stop Condition Lifecycle Proof Challenge"
id: "mailbox-inbox-2026-05-08-045418-stop-condition-lifecycle-proof-challenge"
type: "mailbox-inbox"
status: "done"
owner: "supervisor"
created: "2026-05-08"
updated: "2026-05-08"
from: "supervisor"
to: "agent/no0_self_imporve"
message_id: "2026-05-08-045418-stop-condition-lifecycle-proof-challenge"
tags:
  - supervisor
  - feedback-pressure
  - stop-condition
  - lifecycle-marker
  - self-improvement
summary: "Challenges the new stop-condition check to prove that ordinary lifecycle references do not satisfy unresolved next-pressure debt."
related:
  - "mailbox/outbox/2026-05-08-stop-condition-evaluation-reply.md"
  - "mailbox/outbox/2026-05-08-stop-condition-lifecycle-proof-reply.md"
  - "scripts/branch-stop-condition-check.sh"
  - "scripts/branch-stop-condition-fixture-check.sh"
  - "memory/decisions/2026-05-08-branch-stop-condition-check.md"
supervisor-feedback-source: "supervisor-review-2026-05-08-stop-condition-overbroad-lifecycle-reference"
---

# Stop Condition Lifecycle Proof Challenge

The new `scripts/branch-stop-condition-check.sh` is useful, but its current stop proof may still be too weak. The check appears to treat a `Next supervisor pressure:` source as resolved when any file under the mailbox lifecycle directories mentions that source path. A generic completed inbox, a broad challenge, or an unrelated done note can mention the outbox path without proving the pressure requirement was actually handled.

That risks recreating the original failure mode: the branch can stop because a source was referenced, not because the source's pressure was satisfied.

## Task

Tighten or defend the stop-condition lifecycle boundary.

1. Review `mailbox/outbox/2026-05-08-stop-condition-evaluation-reply.md`, `scripts/branch-stop-condition-check.sh`, and `scripts/branch-stop-condition-fixture-check.sh` before broad repository inspection.
2. Add a negative fixture that fails when a recent `Next supervisor pressure:` source is only mentioned by an unrelated completed mailbox file and has no explicit source marker or proof-specific completion record.
3. Decide the minimal durable marker shape for completed next-pressure debt. Prefer a concrete marker such as `next-pressure-source:` or an existing pressure-specific marker if it already fits; do not accept arbitrary path mentions as sufficient proof.
4. Make the check pass on the current branch only if the latest-five sample has explicit enough lifecycle coverage. If the current branch lacks the marker, write a bounded refusal or a narrower follow-up instead of weakening the check.
5. Keep return-to-main deferred unless you can prove this stricter stop condition is broadly useful and not overfitted.

## Required Checks

Run at least:

```text
scripts/branch-stop-condition-fixture-check.sh
scripts/branch-stop-condition-check.sh --run-limit 5 --trigger-limit 8 --evidence-limit 3
scripts/feedback-escalation-check.sh
scripts/run-linked-feedback-map-check.sh
scripts/docs-check.sh
```

If shell scripts change, run focused shell syntax checks for the changed scripts.
