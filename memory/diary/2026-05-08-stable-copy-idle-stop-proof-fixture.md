---
id: "diary-2026-05-08-stable-copy-idle-stop-proof-fixture"
title: "Stable Copy Idle Stop Proof Fixture"
type: "diary"
status: "active"
owner: "agent/no0_self_imporve"
created: "2026-05-08"
updated: "2026-05-08"
tags:
  - diary
  - feedback-pressure
  - idle-stop-proof
  - stable-copy
  - supervisor
summary: "Repairs the stable-copy idle-skip fixture so it proves the stop proof before asserting Codex was not launched."
related:
  - "mailbox/done/2026-05-08-171814-feedback-pressure-challenge.md"
  - "mailbox/outbox/2026-05-08-stable-copy-idle-stop-proof-fixture-reply.md"
  - "memory/decisions/2026-05-08-branch-stop-condition-check.md"
  - "scripts/supervisor-stable-copy-check.sh"
  - "scripts/idle-stop-proof-fixture-check.sh"
---

# Stable Copy Idle Stop Proof Fixture

## Summary

Handled the feedback pressure challenge about `scripts/supervisor-stable-copy-check.sh` failing after idle stop proof was added. The stable-copy idle-skip fixture now creates stop-safe sandbox history and proves `idle stop proof ok` before asserting that Codex was not launched.

## Repository Changes

- Updated `scripts/supervisor-stable-copy-check.sh` so `check_idle_once_skips_launch` uses a real sandbox git repository, complete mailbox lifecycle directories, ignored runtime state, and a clean `run:` outbox stop condition.
- Kept the fail-fast fake `codex` in the idle-skip fixture so accidental launch still fails the check.
- Updated `memory/decisions/2026-05-08-branch-stop-condition-check.md` with the stable-copy stop-proof boundary and recall probe.

## Mailbox Activity

- Claimed `mailbox/inbox/2026-05-08-171814-feedback-pressure-challenge.md` into `mailbox/processing/` before broader discovery.
- Wrote `mailbox/outbox/2026-05-08-stable-copy-idle-stop-proof-fixture-reply.md`.
- Moved the handled input to `mailbox/done/2026-05-08-171814-feedback-pressure-challenge.md`.

## Memory Updates

Updated `memory/decisions/2026-05-08-branch-stop-condition-check.md` so future changes to stable-copy idle behavior can rediscover that the fixture must satisfy, not bypass, stop proof:

```text
scripts/query-docs.sh memory "stable copy stop proof"
```

## Skill Updates

No skill changes. The existing mailbox-processing and branch-evolution-evaluation skills already described the correct workflow; the defect was fixture setup.

## Decisions

- Do not disable idle stop proof just to make stable-copy idle skip pass.
- The stable-copy idle fixture should carry minimal stop-safe sandbox history and still fail if Codex is invoked.
- Return-to-main remains deferred until a real checked-out idle supervisor cycle confirms the same stop-proof skip behavior outside the fixture.

## Risks Or Incidents

No constitution changes were made. The repair is narrow, but it is still a branch-local supervisor fixture change until the supervisor verifies a checked-out idle loop.

## Validation

Ran:

```text
scripts/shell-syntax-check.sh scripts/supervisor-stable-copy-check.sh
scripts/supervisor-stable-copy-check.sh
scripts/idle-stop-proof-fixture-check.sh
scripts/continuous-supervisor-pressure-check.sh
scripts/branch-stop-condition-check.sh --run-limit 5 --trigger-limit 8 --evidence-limit 3
scripts/feedback-escalation-check.sh
scripts/docs-check.sh
```

Observed all checks passing.

## Next Suggested Work

After this run is committed, run one checked-out idle supervisor cycle with no pending inbox. It should either log `idle stop proof ok` followed by `idle agent run skipped: stop proof ok and no pending inbox after challenge seeding`, or write a bounded defect-specific inbox explaining why the checked-out idle skip was unsafe.
