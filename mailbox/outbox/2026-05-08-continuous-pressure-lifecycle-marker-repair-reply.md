---
id: "mailbox-outbox-2026-05-08-continuous-pressure-lifecycle-marker-repair-reply"
title: "Continuous Pressure Lifecycle Marker Repair Reply"
type: "mailbox-message"
status: "done"
owner: "agent"
created: "2026-05-08"
updated: "2026-05-08"
from: "agent/no0_self_imporve"
to: "supervisor"
message_id: "2026-05-08-continuous-pressure-lifecycle-marker-repair-reply"
tags:
  - mailbox
  - feedback-pressure
  - continuous-supervision
  - self-improvement
summary: "Repairs the continuous-pressure repeat suppression false positive by excluding source outbox prose from lifecycle marker coverage."
related:
  - "mailbox-inbox-2026-05-08-061802-feedback-pressure-challenge"
  - "mailbox/outbox/2026-05-08-feedback-pressure-ratchet-reply.md"
  - "scripts/supervisor.sh"
  - "scripts/continuous-supervisor-pressure-check.sh"
  - "memory/decisions/2026-05-08-continuous-supervisor-pressure.md"
---

# Continuous Pressure Lifecycle Marker Repair Reply

## Reviewed Evidence

I reviewed the latest three run commits before choosing the response:

```text
scripts/query-docs.sh skills "run-linked"
===== skills/branch-evolution-evaluation/SKILL.md =====
```

```text
git log --oneline -3
090a0a5 run: Feedback Pressure Ratchet Gate Repair
2922f05 run: Idle Stop Proof Failure Excerpt
1d9ad00 run: Idle Stop Proof
```

I mapped those commits to their changed supervisor-facing outbox reports:

```text
git show --name-only --format='%h %s' 090a0a5 -- mailbox/outbox
090a0a5 run: Feedback Pressure Ratchet Gate Repair
mailbox/outbox/2026-05-08-feedback-pressure-ratchet-reply.md

git show --name-only --format='%h %s' 2922f05 -- mailbox/outbox
2922f05 run: Idle Stop Proof Failure Excerpt
mailbox/outbox/2026-05-08-idle-stop-proof-failure-excerpt-reply.md

git show --name-only --format='%h %s' 1d9ad00 -- mailbox/outbox
1d9ad00 run: Idle Stop Proof
mailbox/outbox/2026-05-08-idle-stop-proof-reply.md
```

The latest three branch outbox reports were the same run-linked files. The newest report asked the next clean checked-out idle cycle to seed one continuous-pressure inbox for `mailbox/outbox/2026-05-08-feedback-pressure-ratchet-reply.md`, or find a later durable lifecycle marker for that same source. The human feedback showed the only matching marker was inside that source report's own prose, so the anti-repeat check was treating the requirement as if it had already been handled.

## Current Weakness

The exact stop-too-early path was `scripts/supervisor.sh` function `has_existing_continuous_pressure_challenge_for_source`. It scanned `mailbox/outbox/` along with real lifecycle directories and looked for the raw fixed string `continuous-pressure-source: <source>`.

That lowered the proof bar because a source outbox could suppress its own future challenge merely by asking for a future marker in its final pressure sentence. A clean idle cycle could then log that all proof-debt sources were already challenged even though no inbox, processing, done, or failed lifecycle record had ever carried the marker.

## Mechanism

I updated `scripts/supervisor.sh` so continuous-pressure repeat suppression searches only actual lifecycle records under:

```text
mailbox/inbox/
mailbox/processing/
mailbox/done/
mailbox/failed/
```

The new helper `file_has_continuous_pressure_source_marker` parses marker lines and accepts quoted or unquoted values, but it no longer scans `mailbox/outbox/`. This preserves real repeat suppression while preventing source prose from covering itself.

I also updated `scripts/continuous-supervisor-pressure-check.sh` with an edge-case fixture: a run-linked outbox report whose own pressure sentence asks for a future `continuous-pressure-source` marker naming itself. The fixture now requires that source to seed exactly one continuous-pressure inbox. The existing done-marker fixture still proves real lifecycle records suppress repeats.

I updated `memory/decisions/2026-05-08-continuous-supervisor-pressure.md` so future agents can rediscover the boundary with:

```text
scripts/query-docs.sh memory "source outbox prose"
```

## Anti-Noise Boundary

This repair does not add a new pressure source and does not broaden seeding criteria. It only corrects the anti-repeat boundary. Completed lifecycle records still suppress repeats; source outbox reports no longer do.

The source-only idle seeding fixture is the equivalent proof for the checked-out idle path because it sources `scripts/supervisor.sh` in a sandbox, enables auto-challenge, creates recent `run:` commits, and invokes `seed_progressive_challenge_if_needed` with no pending inbox.

## Verification

Focused checks run:

```text
scripts/shell-syntax-check.sh scripts/supervisor.sh scripts/continuous-supervisor-pressure-check.sh
shell-syntax-check: ok scripts/supervisor.sh
shell-syntax-check: ok scripts/continuous-supervisor-pressure-check.sh

scripts/continuous-supervisor-pressure-check.sh
continuous-supervisor-pressure-check: seeds from recent run-linked proof debt
continuous-supervisor-pressure-check: does not treat source outbox marker request as lifecycle coverage
continuous-supervisor-pressure-check: seeds from recent explicit-feedback local refusal
continuous-supervisor-pressure-check: does not reseed the same continuous pressure source
continuous-supervisor-pressure-check: does not reseed the same explicit-feedback source
continuous-supervisor-pressure-check: does not seed from completed clean stop condition
continuous-supervisor-pressure-check: ignores non-run deferred outbox debt
continuous-supervisor-pressure-check: ok

scripts/feedback-escalation-check.sh
feedback-escalation-check: ok

scripts/branch-stop-condition-check.sh --run-limit 5 --trigger-limit 8 --evidence-limit 3
branch-stop-condition-check: ok

scripts/run-linked-feedback-map-check.sh
run-linked-feedback-map-check: ok (no changed target feedback outbox)

scripts/idle-stop-proof-fixture-check.sh
idle-stop-proof-fixture-check: records stop proof before idle skip
idle-stop-proof-fixture-check: seeds self-contained defect-specific challenge when stop proof fails
idle-stop-proof-fixture-check: ok
```

## Return-To-Main Judgment

Return-to-main judgment: deferred. This is a narrow, portable, fixture-backed repair to a real false positive, but it changes the branch-local continuous-pressure idle behavior. Keep it branch-local until the supervisor sees one checked-out idle cycle use the repaired boundary without creating duplicate continuous-pressure inboxes.

No next supervisor pressure: further escalation would be noisy because the false positive now has an executable edge-case fixture, real lifecycle markers still suppress repeats, and the source-only idle seeding path proves source outbox prose no longer covers itself.

Supervisor evaluation trigger: run `scripts/supervisor.sh triggers --status review --limit 8 --evidence-limit 3` and `scripts/continuous-supervisor-pressure-check.sh`; reopen only if source outbox prose again suppresses a missing lifecycle challenge or the fixture stops proving both source-prose seeding and done-marker suppression.

Stop condition: stop this pressure line after `scripts/continuous-supervisor-pressure-check.sh`, `scripts/feedback-escalation-check.sh`, and `scripts/docs-check.sh` pass with the claimed inbox moved to `mailbox/done/`.
