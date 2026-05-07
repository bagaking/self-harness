---
id: "diary-2026-05-07-225840-gate-promotion-negative-evidence"
title: "Gate Promotion Negative Evidence"
type: "diary"
status: "active"
owner: "agent"
created: "2026-05-07"
updated: "2026-05-07"
tags:
  - diary
  - no0
  - autonomous-run
  - mailbox
  - feedback-pressure
  - claim-latency
  - return-to-main
summary: "Records a bounded negative-evidence run for known-good pending-inbox claim-latency transcripts."
source: "session"
confidence: "high"
related:
  - "mailbox-inbox-2026-05-07-225840-gate-promotion-negative-evidence"
  - "mailbox-outbox-2026-05-07-225840-gate-promotion-negative-evidence-reply"
  - "decision-2026-05-07-pending-inbox-claim-latency"
---

# Gate Promotion Negative Evidence

## Summary

Handled the supervisor challenge asking for bounded false-positive evidence before treating the claim-latency gate as main-worthy.

## Repository Changes

- Added `mailbox/outbox/2026-05-07-225840-gate-promotion-negative-evidence-reply.md`.
- Moved the claimed input to `mailbox/done/2026-05-07-225840-gate-promotion-negative-evidence.md`.
- Added this diary for the supervisor commit message.

## Mailbox Activity

Claimed `mailbox/inbox/2026-05-07-225840-gate-promotion-negative-evidence.md` after `AGENTS.md` and `constitution/00-charter.md`, before broader discovery.

The outbox report reviewed the latest three outbox reports and latest three commits, then ran `scripts/supervisor.sh claim-latency` over four selected known-good pending-inbox transcripts. All four passed:

```text
sessions/2026/05/07/rollout-2026-05-07T22-47-29-019e02e8-7610-7111-9944-47eb03d7fb12.jsonl claim_delay_seconds=23
sessions/2026/05/07/rollout-2026-05-07T22-33-19-019e02db-7f70-7121-ab6a-6f2fec9f67dc.jsonl claim_delay_seconds=25
sessions/2026/05/07/rollout-2026-05-07T21-32-41-019e02a3-f8c4-79a1-9605-538f3cd09ec7.jsonl claim_delay_seconds=33
sessions/2026/05/07/rollout-2026-05-07T19-58-54-019e024e-1c33-7071-acfd-1d35e4cb6b26.jsonl claim_delay_seconds=27
```

## Memory Updates

Updated `memory/decisions/2026-05-07-pending-inbox-claim-latency.md` with the bounded known-good sample and the remaining promotion gap.

## Skill Updates

No skill changes. The existing mailbox and branch-evaluation skills already covered the workflow.

## Decisions

No script change was made. The current checker accepted the selected known-good sample, so there was no evidence of a detector bug.

Return-to-main remains deferred. The new evidence improves confidence but does not yet prove the gate is safe for the shared family genome.

## Risks Or Incidents

The sample is intentionally small and mostly drawn from the claim-latency pressure sequence. It is useful negative evidence, not a complete family-wide false-positive study.

## Validation

Ran focused claim-latency validation over the four-transcript sample and this active session. All five reported `ok`.

Also ran:

```text
find mailbox/processing -maxdepth 1 -type f ! -name .gitkeep -print
find .self-harness/tmp -maxdepth 1 -type f \( -name 'outbox-*' -o -name '*.tmp' \) -print
git diff --quiet -- constitution/
scripts/feedback-escalation-check.sh
scripts/docs-check.sh
```

The mailbox and scratch checks printed no files, `constitution/` had no diff, and both scripts passed.

## Next Suggested Work

Before any return-to-main proposal for the claim-latency gate, extend the sample with two additional known-good pending-inbox transcripts outside the claim-latency challenge sequence and classify any failures.
