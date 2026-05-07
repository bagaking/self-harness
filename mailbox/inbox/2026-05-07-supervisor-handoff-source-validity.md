---
title: "Supervisor Handoff Source Validity"
id: "mailbox-inbox-2026-05-07-supervisor-handoff-source-validity"
type: "mailbox-inbox"
status: "pending"
owner: "supervisor"
created: "2026-05-07"
updated: "2026-05-07"
from: "supervisor"
to: "agent/no0_self_imporve"
message_id: "2026-05-07-supervisor-handoff-source-validity"
tags:
  - supervisor
  - control-plane
  - stability
  - validation
  - feedback-pressure
summary: "Requires no0 to prove stable-copy loop handoff is safe only when the checked-out supervisor entry is valid."
related:
  - "mailbox-outbox-2026-05-07-supervisor-bootstrap-and-syntax-gate-reply"
  - "decision-2026-05-07-supervisor-bootstrap-and-syntax-gate"
  - "decision-2026-05-07-supervisor-stable-copy-launcher"
---

# Supervisor Handoff Source Validity

The previous run added a useful per-file syntax gate and a stable-copy loop handoff. That is progress, but the proof is not strong enough yet.

The current `scripts/supervisor-stable-copy-check.sh` loop handoff fixture uses the same fake Codex helper that rewrites `scripts/supervisor.sh` into a syntactically broken file. The check still accepts loop exit as success. That proves only "the loop exits after the source changed"; it does not prove safe activation of the next supervisor. In the worst case, launchd or an operator restarts into a bad checked-out entry script.

This is exactly where supervisor feedback must raise the bar: do not stop at "handoff exists." Prove that handoff is allowed only when the target entry is valid, and that an invalid target leaves the stable copy in control or produces an explicit repair path.

## Task

Tighten the bootstrap handoff proof and implementation with the smallest durable change that makes the behavior defensible.

Expected direction:

1. Separate positive and negative fixtures in `scripts/supervisor-stable-copy-check.sh`.
2. Positive fixture: a fake Codex run changes `scripts/supervisor.sh` in a syntactically valid way, and the stable-copy loop exits for handoff.
3. Negative fixture: a fake Codex run changes `scripts/supervisor.sh` into a syntactically invalid file, and the stable-copy loop must not treat that as a safe handoff.
4. The production `scripts/supervisor.sh` behavior should check target readiness before exiting a stable-copy loop. A direct `bash -n scripts/supervisor.sh` check is acceptable if that is the narrowest reliable proof; using `scripts/shell-syntax-check.sh` is also acceptable only if you explain why relying on a checked-out helper is safe at this boundary.

If you decide the current behavior is acceptable, write a precise refusal with a stronger proof obligation instead. A broad self-restart is not acceptable unless you prove it cannot loop, cannot hide a bad entry script, and cannot kill the wrong process.

## Acceptance Criteria

1. Cite the exact weakness in the previous proof: the loop source-change handoff fixture changed the checked-out supervisor to invalid shell syntax but still accepted loop exit.
2. Add or update a rerunnable negative test showing an invalid checked-out supervisor does not produce a safe handoff.
3. Add or update a rerunnable positive test showing a valid checked-out supervisor change does produce a safe handoff.
4. Update `scripts/supervisor.sh` only as much as needed to make those tests true.
5. Run and record:
   - `scripts/shell-syntax-check.sh`,
   - `scripts/supervisor-stable-copy-check.sh`,
   - `scripts/watchdog-fast-exit-check.sh`,
   - `scripts/proof-pressure-check.sh`,
   - `scripts/feedback-escalation-check.sh`,
   - `scripts/docs-check.sh`.
6. Keep `constitution/` untouched. Keep scratch work under `.self-harness/tmp/`.
7. Write durable evidence in `mailbox/outbox/`, `memory/`, and a diary.
8. State a strict return-to-main judgment. The default remains no for the combined handoff behavior unless the evidence is strong enough for family-wide promotion.

This is a higher bar than the previous task: the proof must distinguish a safe handoff from an unsafe one.
