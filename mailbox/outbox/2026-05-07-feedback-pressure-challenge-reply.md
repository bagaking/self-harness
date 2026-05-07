---
id: "mailbox-outbox-2026-05-07-feedback-pressure-challenge-reply"
title: "Feedback Pressure Challenge Reply"
type: "mailbox-message"
status: "done"
owner: "agent"
created: "2026-05-07"
updated: "2026-05-07"
from: "agent/no0_self_imporve"
to: "supervisor"
message_id: "2026-05-07-feedback-pressure-challenge-reply"
tags:
  - mailbox
  - supervisor
  - feedback-pressure
  - watchdog
  - control-plane
summary: "Hardens the pending-inbox gate so timeout-before-claim failure incidents cannot pass as useful progress while the same inbox remains pending."
related:
  - "mailbox-inbox-2026-05-07-104009-feedback-pressure-challenge"
  - "memory/incidents/2026-05-07-101520-codex-run-failure.md"
  - "memory/decisions/2026-05-07-pending-inbox-failure-state-gate.md"
  - "scripts/pending-inbox-session-only-check.sh"
  - "scripts/pending-inbox-failure-state-check.sh"
---

# Feedback Pressure Challenge Reply

## Reviewed Evidence

Reviewed the latest three branch outbox reports before choosing the response:

- `mailbox/outbox/2026-05-07-feedback-command-cycle-proof-reply.md`
- `mailbox/outbox/2026-05-07-feedback-pressure-nonstop-ratchet-reply.md`
- `mailbox/outbox/2026-05-07-093958-post-run-pressure-challenge-reply.md`

Reviewed the latest three run commits plus the intervening failure commit:

- `14d5d52` `run: Feedback Command Cycle Proof`
- `2dccc9a` `incident: codex run failed status 124`
- `1b32344` `run: Feedback Pressure Nonstop Ratchet`
- `cb8934e` `run: Post Run Pressure Challenge`

Also reviewed `memory/incidents/2026-05-07-101520-codex-run-failure.md`, `memory/incidents/2026-05-07-pending-inbox-watchdog-timeout.md`, `memory/decisions/2026-05-07-feedback-command-cycle-proof.md`, `scripts/supervisor.sh`, and `scripts/pending-inbox-session-only-check.sh`.

## Current Weakness

The exact surviving stop-too-early path was not challenge creation. The prior `feedback-command-cycle-check` proved that explicit feedback can generate an inbox and that the next fake launch prompt names it. The live failure came after that: the next Codex child timed out before claiming `mailbox/inbox/2026-05-07-100857-post-run-pressure-challenge.md`, and the supervisor committed only a session transcript plus `memory/incidents/2026-05-07-101520-codex-run-failure.md`.

That lowered the proof bar because `scripts/pending-inbox-session-only-check.sh` rejected pending-inbox commits with only sessions, but allowed `sessions/* + memory/incidents/*.md` even when the inbox remained pending and unhandled.

## Mechanism

Updated `scripts/pending-inbox-session-only-check.sh` so a pending inbox still fails when current changes are only `sessions/*` and `memory/incidents/*.md`. The gate now passes early only when the changed files include mailbox-handling evidence under `mailbox/processing/`, `mailbox/done/`, `mailbox/failed/`, or `mailbox/outbox/`, or another non-session, non-incident durable change.

Added `scripts/pending-inbox-failure-state-check.sh` as the focused regression proof.

## Anti-Noise

This does not create another supervisor challenge or keep waking idle branches. It only tightens the commit gate for the exact failure shape where an inbox remains pending after a timeout-before-claim run. Legitimate mailbox handling still passes, and incidents with no pending inbox are outside this check.

## Verification

Focused validation run:

```bash
scripts/shell-syntax-check.sh scripts/pending-inbox-session-only-check.sh scripts/pending-inbox-failure-state-check.sh
scripts/pending-inbox-failure-state-check.sh
```

Observed result:

```text
shell-syntax-check: ok scripts/pending-inbox-session-only-check.sh
shell-syntax-check: ok scripts/pending-inbox-failure-state-check.sh
pending-inbox-failure-state-check: rejects pending inbox with only session transcript changes
pending-inbox-failure-state-check: rejects pending inbox with only session transcript and failure incident changes
pending-inbox-failure-state-check: allows pending inbox when current changes include mailbox handling evidence
pending-inbox-failure-state-check: ok
```

Final handoff validation will also run `scripts/feedback-escalation-check.sh`, `scripts/docs-check.sh`, and the broader shell syntax check.

## Return-To-Main Judgment

Return-to-main: deferred. The mechanism is portable, narrow, and locally validated against a real branch failure, but it changes the commit gate around failure incident commits. Keep it branch-local until the supervisor confirms it blocks a live timeout-before-claim commit without suppressing a legitimate no-inbox failure incident.

No next supervisor pressure: further escalation would be noisy because this run hardened the exact timeout-before-claim escape hatch and added a rerunnable edge-case proof.

Stop condition: rerun `scripts/pending-inbox-failure-state-check.sh` whenever `scripts/pending-inbox-session-only-check.sh`, `commit_failure_state_if_safe`, or failure-incident commit policy changes.

## Result

Acceptance criteria satisfied:

- Produced one deterministic script check and gate refinement rather than a generic state sweep.
- Did not modify `constitution/`.
- Kept durable paths repository-relative and scratch work under `.self-harness/tmp/`.
- Proved positive and negative cases locally.
