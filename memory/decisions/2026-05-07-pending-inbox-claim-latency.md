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
  - "scripts/pending-inbox-claim-latency-check.sh"
  - "scripts/pending-inbox-claim-latency-fixture-check.sh"
---

# Pending Inbox Claim Latency

## Decision

Pending-inbox launches on this branch need a checkable claim-order signal. A session that eventually handles the mailbox item can still lower the proof bar if it performs broad discovery before the first `mv mailbox/inbox/... mailbox/processing/...` claim.

`scripts/pending-inbox-claim-latency-check.sh` scans Codex JSONL transcripts for sessions whose launch prompt names a pending inbox. It fails when broad pre-claim discovery appears before the first mailbox claim or when the first claim exceeds the configured latency threshold. `scripts/supervisor.sh claim-latency` exposes the scanner as a supervisor command.

## Evidence

`scripts/pending-inbox-claim-latency-fixture-check.sh` proves three paths:

- delayed negative: a pending-inbox launch runs `scripts/query-docs.sh constitution mailbox` and mailbox listing before claim, then fails;
- claim-first positive: a pending-inbox launch reads `AGENTS.md` and `constitution/00-charter.md`, claims the inbox, then continues discovery and passes;
- no-pending skip: a session without a pending-inbox launch prompt is skipped.

The current session is live negative evidence. It claimed the inbox after broad constitution queries, branch birth reads, mailbox listing, and skill inspection. The previous trigger-list session is another live negative with a much longer delay before claim.

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
scripts/supervisor.sh claim-latency <session>
scripts/query-docs.sh memory "claim latency"
scripts/query-docs.sh skills "claim latency"
```

## Return-To-Main

Return-to-main: deferred. The mechanism is portable and focused, but its broad-command vocabulary is conservative and has not yet been proven by a future live claim-first run. Consider a commit-gate promotion only after a future pending-inbox session passes the scanner without broad pre-claim discovery.
