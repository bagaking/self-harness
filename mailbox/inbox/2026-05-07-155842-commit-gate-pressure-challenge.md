---
title: "Commit Gate Pressure Challenge"
id: "mailbox-inbox-2026-05-07-155842-commit-gate-pressure-challenge"
type: "mailbox-inbox"
status: "pending"
owner: "supervisor"
created: "2026-05-07"
updated: "2026-05-07"
from: "supervisor"
to: "agent/no0_self_imporve"
message_id: "2026-05-07-155842-commit-gate-pressure-challenge"
tags:
  - supervisor
  - feedback-pressure
  - post-run-pressure
  - commit-gate
  - run-linked
summary: "Raises the run-linked feedback map check from agent-level validation toward supervisor commit-gate enforcement."
related:
  - "mailbox/outbox/2026-05-07-154303-post-run-pressure-challenge-reply.md"
  - "scripts/run-linked-feedback-map-check.sh"
  - "scripts/supervisor.sh"
---

# Commit Gate Pressure Challenge

The previous run created `scripts/run-linked-feedback-map-check.sh` and proved it with `scripts/run-linked-feedback-map-fixture-check.sh`. That was a real improvement over prompt-only pressure.

But the supervisor's actual commit gate for commit `68b8a47` did not run `scripts/run-linked-feedback-map-check.sh`; the post-run gate output showed `completed-record-overwrite-check`, `pending-inbox-session-only-check`, `pending-inbox-claim-latency-check`, `proof-pressure-check`, `feedback-escalation-check`, `docs-check`, and `shell-syntax-check`, but no `run-linked-feedback-map-check: ok`.

## Fresh Supervisor Feedback

You still stop too early when a check is only written into a skill and voluntarily run by the agent. If the check is meant to protect supervisor-facing feedback reports, then the next proof bar is whether the supervisor commit path enforces it automatically.

Raise the bar again. Either:

- promote `scripts/run-linked-feedback-map-check.sh` into the supervisor commit gate with a focused fixture or rerunnable proof that the gate blocks a bad changed feedback outbox; or
- write a focused refusal proving that promotion would be noisy or unsafe, and propose a narrower mechanism that still prevents agent-only self-certification.

Do not treat the existence of the checker or the passing fixture from the previous run as sufficient. The new question is whether this mechanism survives the supervisor commit boundary.

## Acceptance Criteria

- Review `mailbox/outbox/2026-05-07-154303-post-run-pressure-challenge-reply.md` and the `68b8a47` commit-gate output before broad repository inspection.
- Inspect `scripts/supervisor.sh` around `run_commit_gate`.
- If you promote the checker, update the supervisor gate and provide a negative fixture or direct rerunnable proof that a changed feedback-bearing outbox missing the run-linked map fails before commit.
- If you refuse promotion, the refusal must identify a concrete false-positive or maintenance risk and provide a smaller alternative that still moves enforcement out of agent-only self-report.
- State return-to-main judgment separately from branch-local judgment. Be very conservative: supervisor gate changes are only main-worthy if they are broadly useful and low-risk.
- Keep durable paths repository-relative and scratch work under `.self-harness/tmp/`.
