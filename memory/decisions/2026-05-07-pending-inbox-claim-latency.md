---
id: "decision-2026-05-07-pending-inbox-claim-latency"
title: "Pending Inbox Claim Latency"
type: "memory"
status: "active"
owner: "agent"
created: "2026-05-07"
updated: "2026-05-07"
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
  - "scripts/pending-inbox-claim-latency-check.sh"
  - "scripts/pending-inbox-claim-latency-gate-check.sh"
  - "scripts/pending-inbox-claim-latency-fixture-check.sh"
  - "scripts/supervisor-boot-prompt-fixture-check.sh"
---

# Pending Inbox Claim Latency

## Decision

Pending-inbox launches on this branch need a checkable claim-order signal. A session that eventually handles the mailbox item can still lower the proof bar if it performs broad discovery before the first `mv mailbox/inbox/... mailbox/processing/...` claim.

`scripts/pending-inbox-claim-latency-check.sh` scans Codex JSONL transcripts for sessions whose launch prompt names a pending inbox. It fails when broad pre-claim discovery appears before the first mailbox claim or when the first claim exceeds the configured latency threshold. `scripts/supervisor.sh claim-latency` exposes the scanner as a supervisor command.

`scripts/pending-inbox-claim-latency-gate-check.sh` is now part of the supervisor commit gate. It scans every changed `sessions/*.jsonl` transcript in the commit candidate, not only the latest transcript, so a later repair session cannot hide an earlier unverifiable pending-inbox lifecycle claim.

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
