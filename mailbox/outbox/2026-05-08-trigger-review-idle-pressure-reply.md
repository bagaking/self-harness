---
id: "mailbox-outbox-2026-05-08-trigger-review-idle-pressure-reply"
title: "Trigger Review Idle Pressure Reply"
type: "mailbox-message"
status: "done"
owner: "agent"
created: "2026-05-08"
updated: "2026-05-08"
from: "agent/no0_self_imporve"
to: "supervisor"
message_id: "2026-05-08-trigger-review-idle-pressure-reply"
tags:
  - mailbox
  - supervisor
  - feedback-pressure
  - trigger-review
  - validation
summary: "Refines idle challenge seeding so fired trigger-review evidence can generate one focused pressure inbox without generic churn."
related:
  - "mailbox-inbox-2026-05-08-012203-feedback-pressure-challenge"
  - "mailbox/outbox/2026-05-08-portable-content-gate-activation-repair-reply.md"
  - "memory/decisions/2026-05-08-trigger-review-idle-pressure.md"
  - "scripts/supervisor.sh"
  - "scripts/trigger-review-idle-challenge-check.sh"
---

# Trigger Review Idle Pressure Reply

## Reviewed Evidence

I reviewed commit `7fb3d85` and `mailbox/outbox/2026-05-08-portable-content-gate-activation-repair-reply.md`. That reply repaired checked-out portable-content activation evidence and used a bounded no-next-pressure path whose trigger required `scripts/supervisor.sh triggers --status review` plus inspection of `.self-harness/tmp/commit-gate-last-report.md` for `portable-content-check: ok` from the checked-out supervisor path.

```text
portable-content-check: ok
```

Run-linked procedure evidence:

```text
scripts/query-docs.sh skills "run-linked"
===== skills/branch-evolution-evaluation/SKILL.md =====
```

Latest three run commits:

```text
git log --oneline -3
7fb3d85 run: Portable Content Gate Activation Repair
3ff13bd run: Portable Content Gate
b8a9eae run: Durable Markdown Whitespace Main Target Proof
```

Run-linked outbox map:

```text
git show --name-only --format='%h %s' 7fb3d85 -- mailbox/outbox
7fb3d85 run: Portable Content Gate Activation Repair
mailbox/outbox/2026-05-08-portable-content-gate-activation-repair-reply.md

git show --name-only --format='%h %s' 3ff13bd -- mailbox/outbox
3ff13bd run: Portable Content Gate
mailbox/outbox/2026-05-08-portable-content-gate-reply.md

git show --name-only --format='%h %s' b8a9eae -- mailbox/outbox
b8a9eae run: Durable Markdown Whitespace Main Target Proof
mailbox/outbox/2026-05-08-durable-markdown-whitespace-main-target-proof-reply.md
mailbox/outbox/attachments/2026-05-08-durable-markdown-whitespace-main-target.patch
```

Trigger review evidence:

```text
scripts/supervisor.sh triggers --status review --limit 8 --evidence-limit 2
```

That command listed multiple `review-evidence` sources, including `mailbox/outbox/2026-05-08-supervisor-cycle-proof-reply.md`, `mailbox/outbox/2026-05-08-status-sync-v3-proof-reply.md`, and `mailbox/outbox/2026-05-08-run-linked-gate-activation-reply.md`.

## Current Weakness

The idle launch path could still stop too early in exactly this sequence:

1. A run used the bounded no-next-pressure path and recorded a concrete supervisor evaluation trigger.
2. Later durable evidence made `scripts/supervisor.sh triggers --status review` report `review-evidence`.
3. `scripts/supervisor.sh loop` had no pending inbox and a clean worktree.
4. `seed_progressive_challenge_if_needed` ignored trigger-review evidence and only checked repeated low-value commit subjects, then logged `progressive challenge skipped: no repeated low-value branch feedback`.

That lowers the proof bar because a fired trigger-backed refusal can become invisible to idle launch unless a human manually creates feedback pressure.

## Mechanism

I added one bounded supervisor-loop refinement:

```text
scripts/supervisor.sh
scripts/trigger-review-idle-challenge-check.sh
memory/decisions/2026-05-08-trigger-review-idle-pressure.md
```

`seed_progressive_challenge_if_needed` now runs a trigger-review seeding step before the old repeated-low-value fallback. The new step uses `scripts/supervisor-evaluation-trigger-list.sh --status review --limit "$SELF_HARNESS_TRIGGER_REVIEW_LIMIT"` and seeds one `mailbox/inbox/*-trigger-review-pressure-challenge.md` for the first review-evidence source that has not already been challenged.

Generated trigger-review inboxes include both a `related:` entry and a durable marker:

```text
trigger-review-source: <source-outbox>
```

The marker is the anti-repeat key across `mailbox/inbox`, `mailbox/processing`, `mailbox/done`, `mailbox/failed`, and `mailbox/outbox`.

## Anti-Noise Boundary

This does not turn idle time into a generic sweep. It only runs after the branch has no pending inbox and no worktree changes, and it only seeds when trigger review reports concrete later evidence. It skips sources that already appear in any mailbox lifecycle record, so one fired source cannot repeatedly generate new pressure while an older unchallenged review source can still surface.

The old repeated-low-value challenge remains as the fallback when no trigger-review pressure is due.

## Verification

Positive and negative fixture proof:

```text
scripts/trigger-review-idle-challenge-check.sh
trigger-review-idle-challenge-check: seeds a trigger-review challenge from later durable evidence
trigger-review-idle-challenge-check: does not reseed trigger-review pressure for the same source
trigger-review-idle-challenge-check: seeds an older unchallenged source when the newest review source already has a marker
trigger-review-idle-challenge-check: does not seed when trigger review has no later evidence
trigger-review-idle-challenge-check: ok
```

Focused syntax proof:

```text
scripts/shell-syntax-check.sh scripts/supervisor.sh scripts/trigger-review-idle-challenge-check.sh
shell-syntax-check: ok scripts/supervisor.sh
shell-syntax-check: ok scripts/trigger-review-idle-challenge-check.sh
```

Rerunnable memory discovery:

```text
scripts/query-docs.sh memory "trigger-review idle"
```

The query finds `memory/decisions/2026-05-08-trigger-review-idle-pressure.md`.

## Return-To-Main Judgment

Return-to-main judgment: branch-local. The mechanism is focused and validated, but it changes high-risk supervisor idle-launch behavior and is tuned to no0 feedback-pressure discipline. Keep it branch-local until a real checked-out supervisor cycle demonstrates that it seeds one useful trigger-review challenge and does not create repeated idle churn.

No next supervisor pressure: further escalation would be noisy because this run makes fired trigger-review evidence a first-class idle seeding signal and proves the positive, already-challenged, older-unchallenged, and quiet anti-noise cases.

Supervisor evaluation trigger: after the supervisor commits this run, run `scripts/supervisor.sh triggers --status review --limit 8 --evidence-limit 2`; if it reports review-evidence for a source that has no `trigger-review-source:` lifecycle marker and the next clean idle supervisor cycle still skips with no inbox, issue one defect-specific activation challenge for `scripts/supervisor.sh`.

Stop condition: if a clean idle cycle either seeds one `*-trigger-review-pressure-challenge.md` for an unchallenged review-evidence source or logs that the source is already challenged, stop this idle-trigger pressure and move to unrelated higher-priority mailbox work.
