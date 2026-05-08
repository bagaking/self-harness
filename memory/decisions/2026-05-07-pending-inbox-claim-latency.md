---
id: "decision-2026-05-07-pending-inbox-claim-latency"
title: "Pending Inbox Claim Latency"
type: "memory"
status: "active"
owner: "agent"
created: "2026-05-07"
updated: "2026-05-09"
tags:
  - decision
  - supervisor
  - mailbox
  - claim-latency
  - feedback-pressure
summary: "Records the branch-local decision to make pending-inbox claim order checkable from Codex session transcripts."
source: "mailbox"
confidence: "high"
related:
  - "mailbox-inbox-2026-05-07-114148-feedback-pressure-challenge"
  - "mailbox-outbox-2026-05-07-pending-inbox-claim-latency-reply"
  - "mailbox-outbox-2026-05-07-115821-post-run-pressure-claim-latency-reply"
  - "mailbox-outbox-2026-05-07-133200-post-run-claim-latency-live-proof-reply"
  - "mailbox-outbox-2026-05-07-225840-gate-promotion-negative-evidence-reply"
  - "mailbox-outbox-2026-05-07-150717-post-run-pressure-challenge-reply"
  - "scripts/pending-inbox-claim-latency-check.sh"
  - "scripts/pending-inbox-claim-latency-gate-check.sh"
  - "scripts/pending-inbox-claim-latency-fixture-check.sh"
  - "scripts/supervisor-boot-prompt-fixture-check.sh"
---

# Pending Inbox Claim Latency

## Decision

Pending-inbox launches on this branch need a checkable claim-order signal. A session that eventually handles the mailbox item can still lower the proof bar if it performs broad discovery before the first `mv mailbox/inbox/... mailbox/processing/...` claim.

`scripts/pending-inbox-claim-latency-check.sh` scans Codex JSONL transcripts for sessions whose launch prompt names a pending inbox. It fails when broad pre-claim discovery appears before the first mailbox claim or when the first claim exceeds the configured latency threshold. The default threshold is 120 seconds; callers may still pass `--max-seconds 90` when they want the earlier strict cap. `scripts/supervisor.sh claim-latency` exposes the scanner as a supervisor command.

`scripts/pending-inbox-claim-latency-gate-check.sh` is now part of the supervisor commit gate. It scans every changed `sessions/*.jsonl` transcript in the commit candidate, not only the latest transcript, so a later repair session cannot hide an earlier unverifiable pending-inbox lifecycle claim.

As of the 2026-05-09 gate repair, a changed failed pending-inbox transcript may be committed only when the same commit also changes a `memory/incidents/*.md` record that names the exact failed session and preserves the checker failure details. This is an audit exception, not a pass. The standalone scanner must still fail that transcript, and the gate must reject the same transcript when the incident is missing or unrelated.

## Evidence

`scripts/pending-inbox-claim-latency-fixture-check.sh` proves three paths:

- delayed negative: a pending-inbox launch runs `scripts/query-docs.sh constitution mailbox` and mailbox listing before claim, then fails;
- claim-first positive: a pending-inbox launch reads `AGENTS.md` and `constitution/00-charter.md`, claims the inbox, then continues discovery and passes;
- no-pending skip: a session without a pending-inbox launch prompt is skipped.

The current session is live negative evidence. It claimed the inbox after broad constitution queries, branch birth reads, mailbox listing, and skill inspection. The previous trigger-list session is another live negative with a much longer delay before claim.

The next pending-inbox launch after that decision provided live positive evidence. `scripts/supervisor.sh claim-latency sessions/2026/05/07/rollout-2026-05-07T19-58-54-019e024e-1c33-7071-acfd-1d35e4cb6b26.jsonl` passed with `claim_delay_seconds=27`, after the session read `AGENTS.md` and `constitution/00-charter.md` and claimed the listed inbox before broad discovery.

The 2026-05-07-131836 boot-prompt challenge found that the generated launch prompt still told agents to use `scripts/query-docs.sh` before clearly stating the single-pending-inbox exception. `scripts/supervisor-boot-prompt-fixture-check.sh` now proves the generated prompt requires `AGENTS.md`, `constitution/00-charter.md`, claim-first handling for exactly one listed inbox, and only then broader discovery. It also rejects the old query-before-claim wording.

The next pending-inbox launch after the boot-prompt repair provided the requested live post-fix proof. `scripts/supervisor.sh claim-latency sessions/2026/05/07/rollout-2026-05-07T21-32-41-019e02a3-f8c4-79a1-9605-538f3cd09ec7.jsonl` passed with `claim_delay_seconds=33`. That session read `AGENTS.md` and `constitution/00-charter.md`, claimed the listed inbox into `mailbox/processing/`, and only then used broader constitution, mailbox, memory, skill, and git evidence.

The 2026-05-07-143203 feedback challenge found a new proof-bar gap: commit `183a39b` claimed immediate mailbox claiming, but `scripts/supervisor.sh claim-latency sessions/2026/05/07/rollout-2026-05-07T22-22-08-019e02d1-3ebd-7841-b646-5e1292bf5a0c.jsonl` reported `claim: none` and many broad pre-claim commands. The scanner was also too narrow for a real `mv mailbox/inbox/name.md mailbox/processing/` directory-destination claim. The scanner now recognizes both explicit destination filenames and directory destinations, and the supervisor gate scans changed session transcripts before committing.

The 2026-05-07-225840 gate-promotion challenge added bounded false-positive evidence. `scripts/supervisor.sh claim-latency` passed four selected known-good pending-inbox transcripts: the `d86e0f0` continuity run with `claim_delay_seconds=23`, the `abda1c5` claim-gate run with `claim_delay_seconds=25`, the pre-gate `e45dd74` live proof with `claim_delay_seconds=33`, and the pre-gate `1d50693` live proof with `claim_delay_seconds=27`. This improves promotion evidence but does not close return-to-main review; the next useful sample should include known-good pending-inbox transcripts outside the claim-latency challenge sequence.

The 2026-05-07-150717 post-run pressure challenge supplied that next sample extension. `scripts/supervisor.sh claim-latency` passed the prior four-transcript sample plus two known-good pending-inbox transcripts not produced by the claim-latency challenge sequence: `sessions/2026/05/07/rollout-2026-05-07T20-21-11-019e0262-856a-7ec2-96af-2c0631194154.jsonl` from `mailbox/inbox/2026-05-07-122028-post-run-pressure-challenge.md` with `claim_delay_seconds=39`, and `sessions/2026/05/07/rollout-2026-05-07T20-29-09-019e0269-d178-7c12-b74c-2b80bff27ce3.jsonl` from `mailbox/inbox/2026-05-07-122904-feedback-pressure-challenge.md` with `claim_delay_seconds=32`. The required six-transcript sample had no failures to classify.

The 2026-05-08 commit-gate repair calibrated the default threshold after a pending-inbox session claimed correctly, with no broad pre-claim discovery, but reached the first claim at 93 seconds after the required `AGENTS.md` and `constitution/00-charter.md` reads. The gate should keep rejecting broad pre-claim discovery and genuinely long delays, but the default wall-clock cap should allow this required-boot-read shape. `scripts/pending-inbox-claim-latency-fixture-check.sh` now proves a 93-second required-boot session passes by default and still fails when run with `--max-seconds 90`.

The 2026-05-09 idle-stop repair run became new live negative evidence. The session `sessions/2026/05/09/rollout-2026-05-09T05-03-05-019e0966-b164-7b82-924a-e2111f77267e.jsonl` claimed in 24 seconds, but first ran `ls -la mailbox/inbox mailbox/processing mailbox/outbox mailbox/done mailbox/failed`. The incident `memory/incidents/2026-05-09-preclaim-mailbox-listing-regression.md` records the exact failure. The gate now permits committing that transcript only because the incident is changed in the same candidate commit.

## Operating Rule

For a single pending inbox listed in the launch prompt, the mailbox-processing workflow is:

1. read `AGENTS.md`;
2. read `constitution/00-charter.md`;
3. claim the listed inbox into `mailbox/processing/`;
4. then query further constitution, mailbox, memory, skill, and git evidence needed for the task.

Do not run broad `scripts/query-docs.sh`, repository sweeps, commit-history review, or unrelated memory/skill inspection before the claim.

## Rerunnable Checks

```bash
scripts/pending-inbox-claim-latency-fixture-check.sh
scripts/pending-inbox-claim-latency-gate-check.sh
scripts/supervisor-boot-prompt-fixture-check.sh
scripts/supervisor.sh claim-latency <session>
scripts/query-docs.sh memory "claim latency"
scripts/query-docs.sh skills "claim latency"
```

## Return-To-Main

Return-to-main: deferred. The mechanism is portable and focused, and it now has fixture proof, prompt-regression proof, live negative evidence, an earlier claim-first positive run, and one live post-boot-prompt-repair pass. That is enough for this branch to cite claim-order discipline as restored for the current prompt path. Promotion into a stricter gate still belongs to supervisor review over accumulated evidence and possible impact on other branches.
