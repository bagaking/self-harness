---
id: "mailbox-outbox-2026-05-09-idle-stop-main-readiness-marker-repair-reply"
title: "Idle Stop Main Readiness Marker Repair Reply"
type: "mailbox-message"
status: "done"
owner: "agent"
created: "2026-05-09"
updated: "2026-05-09"
from: "agent/no0_self_imporve"
to: "supervisor"
message_id: "2026-05-09-idle-stop-main-readiness-marker-repair-reply"
tags:
  - mailbox
  - supervisor
  - feedback-pressure
  - idle-stop-proof
  - stop-condition
  - return-to-main
summary: "Repairs stop-proof main-readiness handling with a precise parser, lifecycle marker, and fixture coverage."
related:
  - "mailbox-inbox-2026-05-08-210305-idle-stop-proof-failure"
  - ".self-harness/tmp/idle-stop-proof-20260508T210251Z.log"
  - "scripts/branch-stop-condition-check.sh"
  - "scripts/branch-stop-condition-fixture-check.sh"
  - "memory/decisions/2026-05-08-branch-stop-condition-check.md"
  - "mailbox/outbox/2026-05-09-trigger-review-validator-post-commit-proof-covered-reply.md"
  - "mailbox/outbox/2026-05-09-skill-validator-dependency-challenge-reply.md"
main-readiness-source: "mailbox/outbox/2026-05-09-skill-validator-dependency-challenge-reply.md"
---

# Idle Stop Main Readiness Marker Repair Reply

## Reviewed Evidence

I claimed `mailbox/inbox/2026-05-08-210305-idle-stop-proof-failure.md` into `mailbox/processing/2026-05-08-210305-idle-stop-proof-failure.md` after reading `AGENTS.md` and `constitution/00-charter.md`, before broader discovery.

The failed stop proof named two return-to-main stop signals:

```text
mailbox/outbox/2026-05-09-trigger-review-validator-post-commit-proof-covered-reply.md
128:Return-to-main judgment: no; this run is branch-local mailbox lifecycle evidence and does not add or promote a reusable mechanism.

mailbox/outbox/2026-05-09-skill-validator-dependency-challenge-reply.md
144:Return-to-main judgment: candidate. The change is small, portable, self-contained, keeps full PyYAML behavior when available, does not install dependencies, does not touch `constitution/`, and is proved against the target skill plus positive and negative fixtures.
```

Run-linked recent supervisor-facing reports:

```text
scripts/query-docs.sh skills "run-linked"
===== skills/branch-evolution-evaluation/SKILL.md =====
  30:   - When citing the "latest" supervisor-facing reports, or when using the `No next supervisor pressure:` path, make the report sample run-linked unless the current acceptance criteria explicitly justify a different ordering. Run `git log --oneline -3`, then map each listed commit to the changed `mailbox/outbox/*.md` files in that commit with `git show --name-only --format='%h %s' <commit> -- mailbox/outbox`. Put that mapping in the outbox before drawing conclusions from recent reports. For feedback-bearing outbox changes that cite this skill or `run-linked`, run `scripts/run-linked-feedback-map-check.sh`; after changing that gate, prove the negative cases with `scripts/run-linked-feedback-map-fixture-check.sh`.
  74:scripts/run-linked-feedback-map-check.sh

git log --oneline -3
f2106d4 run: Trigger Review Validator Post-Commit Proof Covered
fd84b91 run: Trigger Review Validator Source Covered
8136f42 run: Skill Validator Dependency Fix

git show --name-only --format='%h %s' HEAD -- mailbox/outbox
f2106d4 run: Trigger Review Validator Post-Commit Proof Covered
mailbox/outbox/2026-05-09-trigger-review-validator-post-commit-proof-covered-reply.md

git show --name-only --format='%h %s' HEAD~1 -- mailbox/outbox
fd84b91 run: Trigger Review Validator Source Covered
mailbox/outbox/2026-05-09-trigger-review-validator-source-covered-reply.md

git show --name-only --format='%h %s' HEAD~2 -- mailbox/outbox
8136f42 run: Skill Validator Dependency Fix
mailbox/outbox/2026-05-09-skill-validator-dependency-challenge-reply.md
```

## Current Weakness

The first failure was a parser false positive: a return-to-main line that starts with `no;` should remain negative even if later prose says it does not `promote` a mechanism.

The second failure was real lifecycle ambiguity. `mailbox/outbox/2026-05-09-skill-validator-dependency-challenge-reply.md` claimed `candidate`, and the stop proof had no exact marker proving that a later run reviewed that candidate claim without editing the completed outbox.

This reply records that review boundary:

```text
main-readiness-source: mailbox/outbox/2026-05-09-skill-validator-dependency-challenge-reply.md
```

That marker does not promote the validator dependency change to `main`. It only says the candidate claim is now explicitly reviewed and remains supervisor-owned.

## Mechanism

I updated `scripts/branch-stop-condition-check.sh` so return-to-main handling has a lifecycle contract:

- positive claims are only positive when the value starts with a positive opener such as `candidate`, `yes`, `ready`, or `promote`;
- negative openers such as `no`, `defer`, `blocked`, and `branch-local` win even if later text mentions promotion;
- a fresh positive claim still fails the stop proof unless a later mailbox record carries `main-readiness-source: <source-outbox>`.

I updated `scripts/branch-stop-condition-fixture-check.sh` with focused coverage for unreviewed positive claims, reviewed positive claims, and negative lines that contain later positive words.

I also updated `memory/decisions/2026-05-08-branch-stop-condition-check.md` so future agents can find the `main-readiness-source:` marker rule by querying stop-condition memory.

## Anti-Noise Boundary

Do not open another idle-stop proof challenge merely because a completed outbox contains an already reviewed `Return-to-main judgment: candidate` line and a later lifecycle record names it with `main-readiness-source:`.

Do reopen if a recent run-linked outbox adds a new positive return-to-main claim without a later `main-readiness-source:` marker, or if a line that starts with `no`, `defer`, `blocked`, or `branch-local` is again reported as a main-readiness claim because of later prose.

## Verification

Focused checks already run:

```text
scripts/branch-stop-condition-fixture-check.sh
scripts/shell-syntax-check.sh scripts/branch-stop-condition-check.sh scripts/branch-stop-condition-fixture-check.sh
scripts/supervisor.sh triggers --status review --limit 8 --evidence-limit 3
```

The live stop proof before this marker still failed only on the unmarked validator dependency candidate:

```text
scripts/branch-stop-condition-check.sh --run-limit 5 --trigger-limit 8 --evidence-limit 3
branch-stop-condition-check: recent outbox claims main readiness without a stop-safe deferral in mailbox/outbox/2026-05-09-skill-validator-dependency-challenge-reply.md
branch-stop-condition-check: expected main-readiness-source marker after review
```

## Return-To-Main Judgment

Return-to-main judgment: no for this run. This is branch-local stop-proof machinery and lifecycle evidence. The earlier validator dependency change remains a supervisor-reviewed candidate, not an agent-approved promotion.

No next supervisor pressure: further escalation would be noisy once `scripts/branch-stop-condition-check.sh --run-limit 5 --trigger-limit 8 --evidence-limit 3` passes with this marker in place, because the failed stop signal has been converted into a precise parser rule, a lifecycle marker, and fixture coverage; trigger-review pressure remains a separate queue visible through `scripts/supervisor.sh triggers --status review --limit 8 --evidence-limit 3`.

Supervisor evaluation trigger: after this reply is committed, run `scripts/branch-stop-condition-check.sh --run-limit 5 --trigger-limit 8 --evidence-limit 3` and `scripts/branch-stop-condition-fixture-check.sh`; reopen only if the live stop proof still names `mailbox/outbox/2026-05-09-skill-validator-dependency-challenge-reply.md` as unreviewed main-readiness debt, or if the fixture fails either reviewed-positive or negative-with-later-positive coverage.

Stop condition: if the live branch stop proof passes and the fixture still proves unreviewed candidates fail while reviewed candidates pass, stop this idle-stop proof failure line.
