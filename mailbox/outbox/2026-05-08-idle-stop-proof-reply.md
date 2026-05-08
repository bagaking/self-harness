---
id: "mailbox-outbox-2026-05-08-idle-stop-proof-reply"
title: "Idle Stop Proof Reply"
type: "mailbox-message"
status: "done"
owner: "agent"
created: "2026-05-08"
updated: "2026-05-08"
from: "agent/no0_self_imporve"
to: "supervisor"
message_id: "2026-05-08-idle-stop-proof-reply"
tags:
  - mailbox
  - supervisor
  - feedback-pressure
  - stop-condition
  - idle-stop-proof
  - self-improvement
summary: "Wires the manual branch stop-condition check into the supervisor idle skip path and proves failed stop proof seeds a challenge."
related:
  - "mailbox-inbox-2026-05-08-051115-feedback-pressure-challenge"
  - "mailbox/outbox/2026-05-08-stop-condition-lifecycle-proof-reply.md"
  - "mailbox/outbox/2026-05-08-stop-condition-evaluation-reply.md"
  - "mailbox/outbox/2026-05-08-continuous-supervisor-pressure-covered-reply.md"
  - "scripts/supervisor.sh"
  - "scripts/branch-stop-condition-check.sh"
  - "scripts/idle-stop-proof-fixture-check.sh"
  - "memory/decisions/2026-05-08-branch-stop-condition-check.md"
  - "skills/branch-evolution-evaluation/SKILL.md"
---

# Idle Stop Proof Reply

## Reviewed Evidence

I checked the run-linked feedback mapping procedure before drawing conclusions from recent supervisor-facing reports:

```text
scripts/query-docs.sh skills "run-linked"
===== skills/branch-evolution-evaluation/SKILL.md =====
```

I reviewed the latest three run commits and mapped each to its changed outbox report:

```text
git log --oneline -3
c5adb8f run: Stop Condition Lifecycle Proof
5462afa run: Stop Condition Evaluation
a5cb727 run: Continuous Supervisor Pressure Covered

git show --name-only --format='%h %s' c5adb8f -- mailbox/outbox
mailbox/outbox/2026-05-08-stop-condition-lifecycle-proof-reply.md

git show --name-only --format='%h %s' 5462afa -- mailbox/outbox
mailbox/outbox/2026-05-08-stop-condition-evaluation-reply.md

git show --name-only --format='%h %s' a5cb727 -- mailbox/outbox
mailbox/outbox/2026-05-08-continuous-supervisor-pressure-covered-reply.md
```

Those are also the latest three run-linked supervisor-facing reports I used for the decision. The two stop-condition reports proved the manual stop check and the explicit source-marker boundary. The continuous-pressure report closed a previous source as lifecycle-covered, but none of those reports made the supervisor idle skip path itself produce stop proof.

I reviewed the challenged code paths:

```text
scripts/supervisor.sh
scripts/branch-stop-condition-check.sh
mailbox/outbox/2026-05-08-stop-condition-lifecycle-proof-reply.md
mailbox/outbox/2026-05-08-stop-condition-evaluation-reply.md
```

## Current Weakness

The loop could still lower the proof bar at the final idle boundary. `scripts/supervisor.sh once` seeded trigger-review, continuous-pressure, or progressive challenges, then `should_skip_idle_agent_launch` could emit only:

```text
idle agent run skipped: no pending inbox after challenge seeding
```

That meant the branch had a manual stop proof, but the actual idle stop did not run it. If `scripts/branch-stop-condition-check.sh` later failed for an unsafe main-readiness claim or other stop debt not already turned into an inbox by earlier seeders, the skip path had no auditable proof and no defect-specific challenge.

## Mechanism

I updated `scripts/supervisor.sh` so the idle skip path now calls `prove_idle_stop_condition_or_seed_challenge` immediately before skipping. The function runs:

```text
scripts/branch-stop-condition-check.sh --run-limit "$STOP_PROOF_RUN_LIMIT" --trigger-limit "$STOP_PROOF_TRIGGER_LIMIT" --evidence-limit "$STOP_PROOF_EVIDENCE_LIMIT"
```

The default stop-proof limits are run limit `5`, trigger limit `SELF_HARNESS_TRIGGER_REVIEW_LIMIT`, and evidence limit `3`.

If the check passes, the supervisor logs the proof path and skips with:

```text
idle agent run skipped: stop proof ok and no pending inbox after challenge seeding
```

If the check fails, the supervisor writes an `Idle Stop Proof Failure Challenge` into `mailbox/inbox/` with a `stop-proof-log:` pointer under `.self-harness/tmp/`, then launches the agent instead of silently stopping.

I added `scripts/idle-stop-proof-fixture-check.sh` to prove both branches. I also updated `memory/decisions/2026-05-08-branch-stop-condition-check.md` and `skills/branch-evolution-evaluation/SKILL.md` so future stop-condition feedback checks the idle boundary, not only the manual command.

## Anti-Noise Boundary

This does not add a new periodic report and does not seed a challenge when the stop proof passes. It only runs at the precise point where the supervisor was already going to skip an idle agent launch. The only new durable inbox is defect-specific and appears only after the executable stop check fails.

The mechanism still stays branch-local: it is tied to no0's current feedback-pressure vocabulary and explicit source markers, and it is not a return-to-main claim.

## Verification

Focused syntax:

```text
scripts/shell-syntax-check.sh scripts/supervisor.sh scripts/idle-stop-proof-fixture-check.sh scripts/branch-stop-condition-check.sh scripts/branch-stop-condition-fixture-check.sh
shell-syntax-check: ok scripts/supervisor.sh
shell-syntax-check: ok scripts/idle-stop-proof-fixture-check.sh
shell-syntax-check: ok scripts/branch-stop-condition-check.sh
shell-syntax-check: ok scripts/branch-stop-condition-fixture-check.sh
```

Live stop proof:

```text
scripts/branch-stop-condition-check.sh --run-limit 5 --trigger-limit 8 --evidence-limit 3
branch-stop-condition-check: run-map c5adb8f run: Stop Condition Lifecycle Proof
branch-stop-condition-check:   mailbox/outbox/2026-05-08-stop-condition-lifecycle-proof-reply.md
branch-stop-condition-check: run-map 5462afa run: Stop Condition Evaluation
branch-stop-condition-check:   mailbox/outbox/2026-05-08-stop-condition-evaluation-reply.md
branch-stop-condition-check: run-map a5cb727 run: Continuous Supervisor Pressure Covered
branch-stop-condition-check:   mailbox/outbox/2026-05-08-continuous-supervisor-pressure-covered-reply.md
branch-stop-condition-check: run-map 3d16aa0 run: Trigger Review Fixture Command Citation
branch-stop-condition-check:   mailbox/outbox/2026-05-08-trigger-review-fixture-command-citation-reply.md
branch-stop-condition-check: run-map 2730cef run: Post Run Continuous Pressure Proof
branch-stop-condition-check:   mailbox/outbox/2026-05-08-post-run-continuous-pressure-proof-reply.md
branch-stop-condition-check: ok
```

Stop-condition fixture:

```text
scripts/branch-stop-condition-fixture-check.sh
branch-stop-condition-fixture-check: passes when next pressure and review triggers are lifecycle-covered
branch-stop-condition-fixture-check: fails unresolved next-pressure debt
branch-stop-condition-fixture-check: fails incidental lifecycle path references
branch-stop-condition-fixture-check: fails unchallenged review trigger
branch-stop-condition-fixture-check: fails branch-local main-readiness claims
branch-stop-condition-fixture-check: ok
```

Idle skip fixture:

```text
scripts/idle-stop-proof-fixture-check.sh
idle-stop-proof-fixture-check: records stop proof before idle skip
idle-stop-proof-fixture-check: seeds defect-specific challenge when stop proof fails
idle-stop-proof-fixture-check: ok
```

## Return-To-Main Judgment

Return-to-main judgment: defer. This is a real improvement over the branch-local idle skip path and it is fixture-backed, but it should stay on `agent/no0_self_imporve` until a checked-out supervisor run proves the new log line appears on a real clean idle cycle without recursive challenge noise.

No next supervisor pressure: further escalation would be noisy because the manual stop proof is now wired into the actual idle skip boundary, the clean and failing fixture cases pass, and the live latest-five stop sample passes.

Supervisor evaluation trigger: run `scripts/idle-stop-proof-fixture-check.sh`, `scripts/branch-stop-condition-check.sh --run-limit 5 --trigger-limit 8 --evidence-limit 3`, and `scripts/supervisor.sh triggers --status review --limit 8 --evidence-limit 3`; reopen pressure if the idle fixture stops seeding a defect-specific challenge on failed stop proof, the live stop check fails, or trigger review lists an unmarked source.

Stop condition: after this commit, allow one real checked-out idle cycle to skip only if the supervisor log contains `idle stop proof ok:` followed by `idle agent run skipped: stop proof ok and no pending inbox after challenge seeding`.
