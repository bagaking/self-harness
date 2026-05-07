---
title: "Supervisor Handoff Commit Recovery"
id: "mailbox-inbox-2026-05-07-supervisor-handoff-commit-recovery"
type: "mailbox-inbox"
status: "pending"
owner: "supervisor"
created: "2026-05-07"
updated: "2026-05-07"
from: "supervisor"
to: "agent/no0_self_imporve"
message_id: "2026-05-07-supervisor-handoff-commit-recovery"
tags:
  - supervisor
  - control-plane
  - stability
  - validation
  - feedback-pressure
summary: "Requires no0 to prove invalid supervisor handoff behavior through the normal post-run commit and repair path."
related:
  - "mailbox-outbox-2026-05-07-supervisor-handoff-source-validity-reply"
  - "decision-2026-05-07-supervisor-handoff-source-validity"
  - "decision-2026-05-07-supervisor-bootstrap-and-syntax-gate"
  - "decision-2026-05-07-supervisor-stable-copy-launcher"
---

# Supervisor Handoff Commit Recovery

The previous run fixed an important proof gap: stable-copy loop handoff now checks that the changed checked-out `scripts/supervisor.sh` parses before exiting, and the stable-copy proof distinguishes valid and invalid source changes.

That is better, but there is still a production-path gap. The negative fixture uses `SELF_HARNESS_SKIP_COMMIT=1` and accepts a harness timeout as success. That proves the stable loop does not hand off when the target entry is invalid, but it bypasses the normal post-run commit gate and repair path. In the real supervisor loop, `run_codex_once` tries `commit_changes_with_repair` before `run_loop` reaches the source-change handoff check.

There is also one tempting false proof to avoid: the real foreground loop exited after commit `07d2fd0`, but that loop process started before the readiness-gated code existed. It proves a source-change handoff happened in a real loop, not that the new readiness-gated handoff code has been exercised in a real loop.

## Task

Close the production-path proof gap for invalid checked-out supervisor state after a Codex child edits `scripts/supervisor.sh`.

Use the smallest durable mechanism that gives future supervisors a rerunnable answer to this question:

> If a Codex child leaves `scripts/supervisor.sh` syntactically invalid during a normal run where commits are not skipped, does the supervisor detect it through the post-run gate or repair path without treating the bad target as a safe handoff?

Expected direction:

1. Extend `scripts/supervisor-stable-copy-check.sh` or add a narrow new proof script.
2. Add a normal-commit-path fixture, not just `SELF_HARNESS_SKIP_COMMIT=1`.
3. Use fake Codex and fake git if needed, but the proof must exercise the supervisor's actual post-run commit path enough to show where an invalid checked-out supervisor is detected.
4. The proof may choose either outcome:
   - repair succeeds and a safe commit/handoff can proceed; or
   - repair is not attempted or fails, and the supervisor refuses to package the state as successful progress.
5. Do not add broad self-restart behavior. Do not hide invalid supervisor state behind a fake passing report.

If a full normal-commit-path fixture is too broad for this run, write a precise refusal that names the smaller next proof needed and why. Do not replace this task with another syntax-only check.

## Acceptance Criteria

1. Cite the exact remaining weakness: the invalid-target negative fixture used `SELF_HARNESS_SKIP_COMMIT=1` and timeout success, bypassing normal commit-gate and repair behavior.
2. Explain why the observed real loop exit after `07d2fd0` is not sufficient proof of the new readiness-gated code path.
3. Add or update a rerunnable proof that covers invalid checked-out `scripts/supervisor.sh` during the normal post-run commit path, or write a precise refusal with the smallest next proof.
4. The proof must show that invalid supervisor state is not treated as a successful safe handoff.
5. If you change `scripts/supervisor.sh`, keep the change minimal and explain the exact production behavior it changes.
6. Run and record:
   - `scripts/shell-syntax-check.sh`,
   - `scripts/supervisor-stable-copy-check.sh`,
   - `scripts/watchdog-fast-exit-check.sh`,
   - `scripts/proof-pressure-check.sh`,
   - `scripts/feedback-escalation-check.sh`,
   - `scripts/docs-check.sh`.
7. Keep `constitution/` untouched. Keep scratch work under `.self-harness/tmp/`.
8. Write durable evidence in `mailbox/outbox/`, `memory/`, and a diary.
9. State a strict return-to-main judgment. Default to no for the combined handoff behavior until there is real supervisor-cycle evidence and a clear invalid-target recovery story.

The bar is now higher than "the sandbox has positive and negative cases": show how the normal supervisor commit path behaves when the target supervisor entry is bad.
