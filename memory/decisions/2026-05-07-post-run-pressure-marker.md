---
id: "decision-2026-05-07-post-run-pressure-marker"
title: "Post Run Pressure Marker"
type: "memory"
status: "active"
owner: "agent"
created: "2026-05-07"
updated: "2026-05-07"
tags:
  - decision
  - supervisor
  - feedback-pressure
  - control-plane
  - mailbox
summary: "Records the branch-local rule that an outbox marker can seed the next sharper inbox before supervisor commit."
source: "mailbox"
confidence: "high"
related:
  - "mailbox-inbox-2026-05-07-supervisor-real-cycle-pressure"
  - "mailbox-outbox-2026-05-07-supervisor-real-cycle-pressure-reply"
---

# Post Run Pressure Marker

## Decision

On this branch, a changed outbox report may declare:

```text
Next supervisor pressure: <specific follow-up requirement>
```

After a successful Codex child exits and before the supervisor commit, `scripts/supervisor.sh` converts the first changed outbox report with that marker into a pending `mailbox/inbox/*-post-run-pressure-challenge.md` when automatic challenges are enabled, the branch is `agent/*`, and no inbox is already pending.

## Reason

The previous pressure mechanisms worked before launch or at commit-gate review time. They did not give a completed run a deterministic way to say, "this is not the end; seed the next sharper requirement now." The marker keeps that choice explicit in the outbox report instead of making the supervisor infer unresolved weakness from broad text.

## Boundaries

- Do not seed when a pending inbox already exists.
- Do not scan historical outbox reports.
- Do not create a generic repository-state challenge.
- Do not treat the marker as a claim that the follow-up is solved.
- Keep generated challenges branch-local unless a human changes the global rules.

## Worked Signal

Rerun:

```bash
scripts/supervisor-real-cycle-check.sh
```

The post-run pressure fixture creates a changed outbox report with the marker, runs `scripts/supervisor.sh once` in a disposable real git sandbox, and verifies that the supervisor commit includes a generated `mailbox/inbox/*-post-run-pressure-challenge.md`.

As of the `2026-05-07-140206` feedback-pressure repair, the fixture also uses a long marker matching the prior malformed case and verifies that the generated `## Requirement` section preserves the complete line. The extractor must not split a requirement mid-word or mid-sentence merely to fit a fixed character count. If a future cap is added, it must emit an explicit ellipsis plus source pointer instead of a silent substring.

## Current Weakness

The marker improves automatic pressure but does not repair invalid checked-out supervisor source after a fail-closed gate. That remains the next control-plane weakness.
