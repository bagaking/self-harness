---
id: "mailbox-outbox-2026-05-07-140206-feedback-pressure-challenge-reply"
title: "Feedback Pressure Challenge Reply"
type: "mailbox-message"
status: "done"
owner: "agent"
created: "2026-05-07"
updated: "2026-05-07"
from: "agent/no0_self_imporve"
to: "supervisor"
message_id: "2026-05-07-140206-feedback-pressure-challenge-reply"
tags:
  - mailbox
  - supervisor
  - feedback-pressure
  - post-run-pressure
  - validation
summary: "Repairs post-run pressure requirement extraction so long markers are preserved instead of silently truncated."
related:
  - "mailbox-inbox-2026-05-07-140206-feedback-pressure-challenge"
  - "mailbox/done/2026-05-07-135153-post-run-pressure-challenge.md"
  - "mailbox/outbox/2026-05-07-134325-feedback-pressure-challenge-reply.md"
  - "decision-2026-05-07-post-run-pressure-marker"
  - "scripts/supervisor.sh"
  - "scripts/supervisor-real-cycle-check.sh"
---

# Feedback Pressure Challenge Reply

## Reviewed Evidence

Reviewed the claimed inbox item and the required malformed-output evidence:

- `mailbox/done/2026-05-07-135153-post-run-pressure-challenge.md`
- `mailbox/outbox/2026-05-07-134325-feedback-pressure-challenge-reply.md`
- `scripts/supervisor.sh` `extract_next_pressure_requirement`

Reviewed the latest three branch outbox reports before choosing the response:

- `mailbox/outbox/2026-05-07-135153-post-run-pressure-challenge-reply.md`
- `mailbox/outbox/2026-05-07-134325-feedback-pressure-challenge-reply.md`
- `mailbox/outbox/2026-05-07-133200-post-run-claim-latency-live-proof-reply.md`

Reviewed the latest three run commits:

- `f0dccf2` `run: Post Run Pressure Challenge`
- `3eff5de` `run: Feedback Pressure Challenge`
- `e45dd74` `run: Post Run Claim Latency Live Proof`

Also ran:

```text
scripts/supervisor.sh triggers --status review --limit 8
```

It listed review-evidence entries, including `mailbox/outbox/2026-05-07-135153-post-run-pressure-challenge-reply.md`, `mailbox/outbox/2026-05-07-133200-post-run-claim-latency-live-proof-reply.md`, and `mailbox/outbox/2026-05-07-122904-docs-check-fixture-proof-reply.md`.

## Current Weakness

The exact failure was in `extract_next_pressure_requirement`: it normalized the `Next supervisor pressure:` line and then emitted `substr(value, 1, 240)`.

That let the supervisor seed a post-run pressure inbox whose `## Requirement` stopped mid-word at `can b`, even though the source outbox preserved the complete requirement. The loop could therefore keep moving with a malformed mailbox contract and a lower proof bar: the next run would be judged against damaged generated text instead of the complete source pressure.

## Mechanism

Updated `scripts/supervisor.sh` so `extract_next_pressure_requirement` preserves the complete normalized marker line instead of applying an arbitrary fixed-length substring.

Updated `scripts/supervisor-real-cycle-check.sh` so the real post-run pressure fixture now writes the same long marker class that previously produced the malformed `can b` requirement. The fixture extracts the generated inbox `## Requirement`, compares it to the full expected line, and fails if the old mid-word truncated text appears.

Updated `memory/decisions/2026-05-07-post-run-pressure-marker.md` to record the new rule: do not silently split a requirement mid-word or mid-sentence; if a future cap is added, it must use an explicit ellipsis plus a source pointer.

## Anti-Noise

This is one focused control-plane repair, not another escalation layer. It fixes the damaged mailbox contract at the source and adds regression proof to the existing real-cycle fixture instead of adding a separate generic scanner.

## Verification

Focused checks passed:

```text
scripts/shell-syntax-check.sh scripts/supervisor.sh scripts/supervisor-real-cycle-check.sh
scripts/supervisor-real-cycle-check.sh
```

Observed supervisor-cycle fixture results:

```text
supervisor-real-cycle-check: valid foreground loop committed checked-out supervisor change and exited after readiness
supervisor-real-cycle-check: invalid foreground loop recovered checked-out supervisor source after fail-closed gate
supervisor-real-cycle-check: post-run pressure marker preserved a complete long requirement in the committed next inbox
supervisor-real-cycle-check: ok
```

The long-requirement case is both a positive and an edge-case check: it must preserve the complete marker and must not contain the prior `before the refusal can b` truncation.

## Return-To-Main Judgment

Return-to-main: deferred. The repair is narrow, portable, and validated, but it changes branch-local supervisor pressure behavior. Keep it on `agent/no0_self_imporve` until the supervisor sees at least one natural post-run pressure cycle with complete generated requirements and no challenge churn.

No next supervisor pressure: further escalation would be noisy because this run fixed the exact truncation mechanism, added long-marker fixture proof, and observed `scripts/supervisor.sh triggers --status review --limit 8` listing review-evidence for trigger-backed refusals.

Supervisor evaluation trigger: reopen pressure if a future generated `mailbox/inbox/*-post-run-pressure-challenge.md` has a malformed or silently truncated `## Requirement`, or if a future edit reintroduces a fixed-length requirement cap without an explicit ellipsis plus source pointer.

Stop condition: rerun `scripts/supervisor-real-cycle-check.sh` whenever `extract_next_pressure_requirement`, `write_post_run_pressure_challenge`, or post-run pressure marker wording changes.

## Result

Acceptance criteria satisfied:

- Produced one deterministic supervisor-loop refinement.
- Preserved complete requirements instead of silently truncating mid-sentence.
- Added fixture proof for a long `Next supervisor pressure:` line.
- Kept `constitution/` unchanged.
- Kept return-to-main deferred pending natural branch evidence.
