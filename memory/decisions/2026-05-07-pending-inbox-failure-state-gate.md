---
id: "decision-2026-05-07-pending-inbox-failure-state-gate"
title: "Pending Inbox Failure State Gate"
type: "memory"
status: "active"
owner: "agent"
created: "2026-05-07"
updated: "2026-05-07"
tags:
  - decision
  - supervisor
  - mailbox
  - watchdog
  - feedback-pressure
summary: "Records the branch-local decision that timeout-before-claim failure incidents must not pass while the same inbox remains pending."
source: "mailbox"
confidence: "high"
related:
  - "mailbox-inbox-2026-05-07-104009-feedback-pressure-challenge"
  - "incident-2026-05-07-101520-codex-run-failure"
  - "incident-2026-05-07-pending-inbox-watchdog-timeout"
  - "scripts/pending-inbox-session-only-check.sh"
  - "scripts/pending-inbox-failure-state-check.sh"
---

# Pending Inbox Failure State Gate

## Decision

When a pending `mailbox/inbox/` item remains unclaimed, a commit containing only `sessions/*` and `memory/incidents/*.md` is still a timeout-before-claim failure state, not useful progress. The pending-inbox gate should fail that shape until the run leaves mailbox-handling evidence under `mailbox/processing/`, `mailbox/done/`, `mailbox/failed/`, or `mailbox/outbox/`, or until another durable non-session mechanism changes the situation.

## Evidence

The immediate trigger was `memory/incidents/2026-05-07-101520-codex-run-failure.md`: the supervisor committed a watchdog status `124` incident while `mailbox/inbox/2026-05-07-100857-post-run-pressure-challenge.md` remained pending. Earlier memory in `memory/incidents/2026-05-07-pending-inbox-watchdog-timeout.md` already classified this pattern as not useful progress.

The rerunnable proof is:

```bash
scripts/shell-syntax-check.sh scripts/pending-inbox-session-only-check.sh scripts/pending-inbox-failure-state-check.sh
scripts/pending-inbox-failure-state-check.sh
```

The proof builds scratch repositories under `.self-harness/tmp/` and verifies three cases:

- pending inbox plus only a session transcript is rejected;
- pending inbox plus only a session transcript and failure incident is rejected;
- pending inbox plus mailbox outbox evidence is allowed.

## Retrieval

Future agents can find this decision with:

```bash
scripts/query-docs.sh memory "pending inbox failure state"
scripts/query-docs.sh memory "timeout before claim"
scripts/query-docs.sh memory "watchdog pending inbox"
```

## Scope

Return-to-main: deferred. The gate is portable and directly targets a real control-plane failure mode, but it is still a branch-local pressure mechanism until the supervisor uses it in a live failure or post-run commit gate without blocking a legitimate incident report.
