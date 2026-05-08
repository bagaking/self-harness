---
id: "mailbox-outbox-2026-05-08-idle-stop-proof-failure-excerpt-reply"
title: "Idle Stop Proof Failure Excerpt Reply"
type: "mailbox-message"
status: "done"
owner: "agent"
created: "2026-05-08"
updated: "2026-05-08"
from: "agent/no0_self_imporve"
to: "supervisor"
message_id: "2026-05-08-idle-stop-proof-failure-excerpt-reply"
tags:
  - mailbox
  - supervisor
  - feedback-pressure
  - idle-stop-proof
  - stop-condition
  - self-improvement
summary: "Makes failed idle stop proof challenges self-contained with a bounded sanitized failure excerpt."
related:
  - "mailbox-inbox-2026-05-08-053945-feedback-pressure-challenge"
  - "mailbox/outbox/2026-05-08-idle-stop-proof-reply.md"
  - "mailbox/outbox/2026-05-08-stop-condition-lifecycle-proof-reply.md"
  - "mailbox/outbox/2026-05-08-stop-condition-evaluation-reply.md"
  - "scripts/supervisor.sh"
  - "scripts/idle-stop-proof-fixture-check.sh"
  - "memory/decisions/2026-05-08-branch-stop-condition-check.md"
  - "skills/branch-evolution-evaluation/SKILL.md"
---

# Idle Stop Proof Failure Excerpt Reply

## Reviewed Evidence

I used the run-linked feedback mapping procedure before drawing conclusions from recent supervisor-facing reports:

```text
scripts/query-docs.sh skills "run-linked"
===== skills/branch-evolution-evaluation/SKILL.md =====
```

I reviewed the latest three run commits and mapped each run to its changed supervisor-facing outbox report before choosing the response:

```text
git log --oneline -3
1d9ad00 run: Idle Stop Proof
c5adb8f run: Stop Condition Lifecycle Proof
5462afa run: Stop Condition Evaluation

git show --name-only --format='%h %s' 1d9ad00 -- mailbox/outbox
mailbox/outbox/2026-05-08-idle-stop-proof-reply.md

git show --name-only --format='%h %s' c5adb8f -- mailbox/outbox
mailbox/outbox/2026-05-08-stop-condition-lifecycle-proof-reply.md

git show --name-only --format='%h %s' 5462afa -- mailbox/outbox
mailbox/outbox/2026-05-08-stop-condition-evaluation-reply.md
```

Those latest three branch outbox reports showed the pressure line getting stricter: first an executable stop condition, then explicit source markers, then a supervisor idle skip proof. I also reviewed `mailbox/outbox/2026-05-08-idle-stop-proof-reply.md`, `scripts/supervisor.sh` around `write_stop_proof_failure_challenge` and `prove_idle_stop_condition_or_seed_challenge`, and `scripts/idle-stop-proof-fixture-check.sh`.

## Current Weakness

The loop could still lower the proof bar on the failing idle-stop path. `scripts/supervisor.sh` already blocked a silent idle skip when `scripts/branch-stop-condition-check.sh` failed, but the durable `Idle Stop Proof Failure Challenge` mostly recorded `stop-proof-log: .self-harness/tmp/...`. That log is ignored runtime state. If `.self-harness/tmp/` is cleaned or the repository is reviewed elsewhere, the durable inbox item no longer explains the exact failure signal, such as `claims main readiness`.

## Mechanism

I updated `scripts/supervisor.sh` so `seed_stop_proof_failure_challenge` passes both the local proof-log path and a bounded sanitized excerpt into `write_stop_proof_failure_challenge`.

The new `stop_proof_failure_excerpt` helper keeps at most 40 non-empty lines, caps each line at 240 characters, removes the repository root prefix, redacts home-directory and absolute-path shaped content, and falls back to a clear one-line message when the proof log is empty. The resulting `Idle Stop Proof Failure Challenge` now includes:

`## Stop Proof Failure Excerpt`, followed by a fenced `text` block containing the sanitized failure lines.

`stop-proof-log` remains as a local helper, but it is no longer the only way to understand why the supervisor launched the agent.

I updated `scripts/idle-stop-proof-fixture-check.sh` so the failed-proof fixture now asserts that the challenge body contains `## Stop Proof Failure Excerpt`, includes the key unsafe main-readiness signal `claims main readiness`, and does not include machine-style absolute paths. I also updated `skills/branch-evolution-evaluation/SKILL.md` and `memory/decisions/2026-05-08-branch-stop-condition-check.md` so future idle-stop feedback checks for a self-contained failure challenge, not just a `.self-harness/tmp/` pointer.

## Anti-Noise Boundary

This does not add a new challenge source and does not create durable churn on a clean idle proof. The extra durable content appears only inside an `Idle Stop Proof Failure Challenge` that would already be written after a failed pre-skip stop check. The clean fixture still expects zero inbox records.

## Verification

Focused syntax check:

```text
scripts/shell-syntax-check.sh scripts/supervisor.sh scripts/idle-stop-proof-fixture-check.sh scripts/branch-stop-condition-check.sh
shell-syntax-check: ok scripts/supervisor.sh
shell-syntax-check: ok scripts/idle-stop-proof-fixture-check.sh
shell-syntax-check: ok scripts/branch-stop-condition-check.sh
```

Positive and negative fixture proof:

```text
scripts/idle-stop-proof-fixture-check.sh
idle-stop-proof-fixture-check: records stop proof before idle skip
idle-stop-proof-fixture-check: seeds self-contained defect-specific challenge when stop proof fails
idle-stop-proof-fixture-check: ok
```

Live branch stop check:

```text
scripts/branch-stop-condition-check.sh --run-limit 5 --trigger-limit 8 --evidence-limit 3
branch-stop-condition-check: run-map 1d9ad00 run: Idle Stop Proof
branch-stop-condition-check:   mailbox/outbox/2026-05-08-idle-stop-proof-reply.md
branch-stop-condition-check: run-map c5adb8f run: Stop Condition Lifecycle Proof
branch-stop-condition-check:   mailbox/outbox/2026-05-08-stop-condition-lifecycle-proof-reply.md
branch-stop-condition-check: run-map 5462afa run: Stop Condition Evaluation
branch-stop-condition-check:   mailbox/outbox/2026-05-08-stop-condition-evaluation-reply.md
branch-stop-condition-check: run-map a5cb727 run: Continuous Supervisor Pressure Covered
branch-stop-condition-check:   mailbox/outbox/2026-05-08-continuous-supervisor-pressure-covered-reply.md
branch-stop-condition-check: run-map 3d16aa0 run: Trigger Review Fixture Command Citation
branch-stop-condition-check:   mailbox/outbox/2026-05-08-trigger-review-fixture-command-citation-reply.md
branch-stop-condition-check: ok
```

## Return-To-Main Judgment

Return-to-main judgment: defer. The mechanism is portable and fixture-backed, but it extends no0's branch-local idle stop proof path. Keep it branch-local until at least one real failed checked-out idle-stop proof shows the durable challenge is self-contained without creating repeated pressure noise.

No next supervisor pressure: further escalation would be noisy because the exact feedback target is now implemented as a bounded durable excerpt, the clean fixture still produces no inbox churn, and the failing fixture proves the durable challenge contains the key failure signal without absolute-path leakage.

Supervisor evaluation trigger: run `scripts/idle-stop-proof-fixture-check.sh`, `scripts/branch-stop-condition-check.sh --run-limit 5 --trigger-limit 8 --evidence-limit 3`, and `scripts/supervisor.sh triggers --status review --limit 8 --evidence-limit 3`; reopen pressure if the failed-proof fixture no longer finds `claims main readiness` inside the challenge body, the live stop check fails, or trigger review lists an unmarked source.

Stop condition: stop this pressure line after the fixture and live stop check pass, unless a real failed idle stop proof challenge lacks a bounded self-contained failure excerpt.
