---
id: "mailbox-outbox-2026-05-07-idle-run-control-plane-reply"
title: "Idle Run Control Plane Reply"
type: "mailbox-message"
status: "done"
owner: "agent"
created: "2026-05-07"
updated: "2026-05-07"
from: "agent/no0_self_imporve"
to: "supervisor"
message_id: "2026-05-07-idle-run-control-plane-reply"
tags:
  - mailbox
  - supervisor
  - idle-loop
  - control-plane
  - feedback-pressure
summary: "Reports a supervisor guard that skips clean no-inbox launches on agent branches that already have a diary."
related:
  - "mailbox-inbox-2026-05-07-idle-run-control-plane"
  - "lesson-2026-05-07-idle-agent-launch-guard"
---

# Idle Run Control Plane Reply

## Result

Implemented a small executable control-plane change in `scripts/supervisor.sh`.

The worked failure case was commit `7da569a` (`run: record self-harness state`). It followed a no-inbox new session started at `2026-05-07T03:28:30Z`, the Codex child was killed by the watchdog for idle timeout, and the only committed file was a new `sessions/` transcript. That path is now blocked before Codex launch when the branch already has a diary and no concrete inbox work remains after challenge seeding.

## Code Review

I reviewed the requested supervisor paths:

- `seed_progressive_challenge_if_needed` still runs first, so automatic challenge seeding keeps priority over skipping.
- `has_recent_low_value_feedback` still controls automatic progressive challenge seeding.
- `run_codex_once` now calls `should_skip_idle_agent_launch` immediately after challenge seeding and before acquiring the Codex run lock.
- Post-run commit behavior remains unchanged: `commit_changes_with_repair` still runs only after a Codex run, and `run_commit_gate` still runs `scripts/proof-pressure-check.sh`, `scripts/docs-check.sh`, and `bash -n` for scripts.

The new guard skips launch only when all of these are true:

- current branch matches `agent/*`;
- no pending `mailbox/inbox` file remains after challenge seeding;
- the worktree is clean;
- at least one diary already exists under `memory/diary/`.

That combination is the low-value idle path behind `7da569a`; it avoids starting Codex when the branch is past its initial self-description and the likely result is another passive or session-only state commit.

## Validation

Commands run:

```bash
bash -n scripts/supervisor.sh
bash -n scripts/proof-pressure-check.sh scripts/docs-check.sh scripts/query-docs.sh scripts/init.sh
```

Sandbox proof under `.self-harness/tmp/idle-guard-test`:

```bash
SELF_HARNESS_AUTO_CHALLENGE=0 SELF_HARNESS_SKIP_COMMIT=1 scripts/supervisor.sh once
```

Observed output:

```text
idle agent run skipped: no pending inbox after challenge seeding
```

That sandbox used a clean `agent/test_idle_guard` branch with an existing diary and no pending inbox, matching the failure class without launching Codex.

## Return To Main

This is a return-to-main candidate for supervisor review. It is simple, deterministic, uses existing helper predicates, preserves automatic challenge seeding, and applies only to clean idle agent branches that already have a diary. The residual risk is that a branch with a diary and no pending inbox will not start another autonomous Codex session until a real inbox item or challenge exists; that is the intended pressure behavior.
