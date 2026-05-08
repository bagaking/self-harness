---
id: "mailbox-outbox-2026-05-08-feedback-pressure-ratchet-reply"
title: "Feedback Pressure Ratchet Reply"
type: "mailbox-message"
status: "done"
owner: "agent"
created: "2026-05-08"
updated: "2026-05-08"
from: "agent/no0_self_imporve"
to: "supervisor"
message_id: "2026-05-08-feedback-pressure-ratchet-reply"
tags:
  - mailbox
  - feedback-pressure
  - explicit-feedback
  - continuous-supervision
summary: "Keeps explicit human or supervisor feedback open as continuous pressure after a local no-next-pressure refusal."
related:
  - "mailbox-inbox-2026-05-08-055400-feedback-pressure-challenge"
  - "scripts/supervisor.sh"
  - "scripts/continuous-supervisor-pressure-check.sh"
  - "memory/decisions/2026-05-08-continuous-supervisor-pressure.md"
  - "skills/branch-evolution-evaluation/SKILL.md"
---

# Feedback Pressure Ratchet Reply

## Reviewed Evidence

I used the run-linked feedback mapping rule before drawing conclusions from recent supervisor-facing reports:

```text
scripts/query-docs.sh skills "run-linked"
===== skills/branch-evolution-evaluation/SKILL.md =====
```

Latest three run commits and their changed outbox reports:

```text
git log --oneline -3
2922f05 run: Idle Stop Proof Failure Excerpt
1d9ad00 run: Idle Stop Proof
c5adb8f run: Stop Condition Lifecycle Proof

git show --name-only --format='%h %s' 2922f05 -- mailbox/outbox
mailbox/outbox/2026-05-08-idle-stop-proof-failure-excerpt-reply.md

git show --name-only --format='%h %s' 1d9ad00 -- mailbox/outbox
mailbox/outbox/2026-05-08-idle-stop-proof-reply.md

git show --name-only --format='%h %s' c5adb8f -- mailbox/outbox
mailbox/outbox/2026-05-08-stop-condition-lifecycle-proof-reply.md
```

The latest report, `mailbox/outbox/2026-05-08-idle-stop-proof-failure-excerpt-reply.md`, fixed self-contained failed idle stop proof evidence but ended with a local `No next supervisor pressure:` refusal. The new feedback says that is too narrow: local fixture success must not close the broader human feedback ratchet that the agent stops too easily.

## Current Weakness

The exact stop-too-early path was in the idle continuous-pressure scan. It only recognized recent `Next supervisor pressure:` plus deferred proof or promotion debt. A recent explicit-feedback run could use `No next supervisor pressure:` after satisfying one local subproblem, and then a clean idle cycle could treat the mailbox as stop-safe even though the durable feedback source still asked for higher requirements.

That lowered the proof bar because the branch could close a local fixture and implicitly close the whole feedback ratchet.

## Mechanism

I updated `scripts/supervisor.sh` so `seed_continuous_pressure_challenge_if_needed` also treats recent run-linked explicit-feedback outbox reports with `No next supervisor pressure:` as continuous-pressure sources until a later mailbox lifecycle file names that outbox with `continuous-pressure-source: <source-outbox>`.

For those sources, the generated inbox requirement begins:

```text
Explicit feedback ratchet remains open despite local refusal:
```

I updated `scripts/continuous-supervisor-pressure-check.sh` with positive and repeat-suppression fixtures for this case, and updated `memory/decisions/2026-05-08-continuous-supervisor-pressure.md` plus `skills/branch-evolution-evaluation/SKILL.md` so future runs can rediscover the rule with:

```text
scripts/query-docs.sh memory "continuous supervisor pressure"
scripts/query-docs.sh skills "run-linked"
```

## Anti-Noise Boundary

The scan is still bounded to recent `run:` commits and top-level `mailbox/outbox/*.md` reports. It does not seed from non-run commits, arbitrary old history, or clean `No next supervisor pressure:` stop conditions that are not tied to explicit feedback. A matching `continuous-pressure-source:` lifecycle marker suppresses repeats.

Clean idle still avoids churn: the fixture keeps the existing clean-stop and non-run-debt no-seed cases.

## Verification

Focused checks run:

```text
scripts/shell-syntax-check.sh scripts/supervisor.sh scripts/continuous-supervisor-pressure-check.sh
shell-syntax-check: ok scripts/supervisor.sh
shell-syntax-check: ok scripts/continuous-supervisor-pressure-check.sh

scripts/continuous-supervisor-pressure-check.sh
continuous-supervisor-pressure-check: seeds from recent run-linked proof debt
continuous-supervisor-pressure-check: seeds from recent explicit-feedback local refusal
continuous-supervisor-pressure-check: does not reseed the same continuous pressure source
continuous-supervisor-pressure-check: does not reseed the same explicit-feedback source
continuous-supervisor-pressure-check: does not seed from completed clean stop condition
continuous-supervisor-pressure-check: ignores non-run deferred outbox debt
continuous-supervisor-pressure-check: ok

scripts/branch-stop-condition-check.sh --run-limit 5 --trigger-limit 8 --evidence-limit 3
branch-stop-condition-check: ok

scripts/idle-stop-proof-fixture-check.sh
idle-stop-proof-fixture-check: records stop proof before idle skip
idle-stop-proof-fixture-check: seeds self-contained defect-specific challenge when stop proof fails
idle-stop-proof-fixture-check: ok
```

## Return-To-Main Judgment

Return-to-main judgment: deferred. The mechanism is branch-local, validated, and directly answers the current feedback, but it changes idle pressure behavior for this lineage. Keep it off `main` until a later checked-out supervisor cycle proves it creates exactly one useful follow-up for an explicit-feedback local refusal and no challenge churn on clean idle.

Next supervisor pressure: after this repair is committed, run a clean checked-out idle supervisor cycle with no pending inbox and require either exactly one `mailbox/inbox/*-continuous-supervisor-pressure.md` for this explicit-feedback source, or a durable `continuous-pressure-source: mailbox/outbox/2026-05-08-feedback-pressure-ratchet-reply.md` lifecycle marker that proves a higher-level follow-up already covered it.
