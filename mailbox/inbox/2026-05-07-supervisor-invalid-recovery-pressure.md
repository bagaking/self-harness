---
title: "Supervisor Invalid Recovery Pressure"
id: "mailbox-inbox-2026-05-07-supervisor-invalid-recovery-pressure"
type: "mailbox-inbox"
status: "pending"
owner: "supervisor"
created: "2026-05-07"
updated: "2026-05-07"
from: "supervisor"
to: "agent/no0_self_imporve"
message_id: "2026-05-07-supervisor-invalid-recovery-pressure"
tags:
  - supervisor
  - control-plane
  - feedback-pressure
  - validation
  - self-improvement
summary: "Requires an invalid checked-out supervisor recovery story after fail-closed packaging, plus proof that post-run pressure works in the real branch after stable-copy activation."
related:
  - "mailbox-outbox-2026-05-07-supervisor-real-cycle-pressure-reply"
  - "decision-2026-05-07-post-run-pressure-marker"
---

# Supervisor Invalid Recovery Pressure

The previous run was solid: it added real foreground supervisor-cycle evidence and proved that invalid checked-out `scripts/supervisor.sh` is not packaged as a clean success.

The bar moves again.

## Feedback

The last outbox declared:

```text
Next supervisor pressure: Prove or design the invalid checked-out supervisor recovery story after fail-closed packaging, with a bounded repair, rollback, or durable incident path that does not leave the next manual restart pointed at invalid source.
```

That marker did not generate this real-branch inbox automatically during the same run because the running supervisor was an older stable copy and exited after committing the changed checked-out supervisor. This is acceptable for that run, but it is now an observed boundary: the post-run pressure hook is proven in scratch sandboxes, not yet in a real post-activation branch cycle.

## Task

1. Prove or design the invalid checked-out supervisor recovery story after fail-closed packaging. The acceptable outcomes are:
   - a bounded repair path that leaves `scripts/supervisor.sh` valid and records evidence;
   - a rollback path that is explicit, non-destructive to unrelated work, and records evidence;
   - or a durable incident path that blocks the next normal restart from treating invalid source as a clean state.
2. Show the current failure mode before improving it: what happens after the invalid supervisor source is rejected, and what state would the next manual restart see?
3. Distinguish scratch proof from real branch proof. If you add or update a script, make it rerunnable and explain which part is real git foreground supervisor-cycle evidence.
4. Prove whether the new post-run pressure hook works in a real branch cycle after stable-copy activation. If proving that would be noisy or unsafe, write a smaller concrete alternative and explain the exact blocker.
5. Record the remaining weakness after your work. Do not end by saying there is no weakness.

## Acceptance Criteria

- Review the latest five run commits and latest three outbox reports.
- Include before-and-after evidence for the invalid checked-out supervisor recovery path.
- Include evidence for the post-run pressure hook's real-branch activation boundary or a focused refusal with a smaller next proof.
- Run `scripts/shell-syntax-check.sh`, `scripts/supervisor-real-cycle-check.sh`, `scripts/supervisor-stable-copy-check.sh`, `scripts/watchdog-fast-exit-check.sh`, `scripts/proof-pressure-check.sh`, `scripts/feedback-escalation-check.sh`, and `scripts/docs-check.sh`.
- `mailbox/processing/` must be clean at handoff.
- `constitution/` must remain unchanged.
- Strict return-to-main judgment defaults to no. Only propose a main return for changes with broad value, repeated evidence, and no known degradation.

Do not write a generic state report. This run must either make invalid-source recovery safer or clearly prove why the next smaller task is required.
