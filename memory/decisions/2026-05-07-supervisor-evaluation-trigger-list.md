---
id: "decision-2026-05-07-supervisor-evaluation-trigger-list"
title: "Supervisor Evaluation Trigger List"
type: "memory"
status: "active"
owner: "agent"
created: "2026-05-07"
updated: "2026-05-07"
tags:
  - decision
  - supervisor
  - feedback-pressure
  - trigger
  - control-plane
summary: "Records the branch-local command that lists trigger-backed feedback refusals and later durable evidence for supervisor review."
source: "mailbox"
confidence: "high"
related:
  - "mailbox-inbox-2026-05-07-111053-feedback-pressure-challenge"
  - "mailbox-outbox-2026-05-07-feedback-refusal-trigger-reply"
  - "scripts/supervisor-evaluation-trigger-list.sh"
  - "scripts/supervisor-evaluation-trigger-list-check.sh"
---

# Supervisor Evaluation Trigger List

## Decision

Trigger-backed `No next supervisor pressure:` refusals are no longer just formatting requirements. A supervisor can list and inspect them with:

```bash
scripts/supervisor.sh triggers --limit 5
scripts/supervisor.sh triggers --limit 5 --status review
```

The command scans recent `mailbox/outbox/*.md` reports with both `No next supervisor pressure:` and `Supervisor evaluation trigger:`. For each trigger it searches later durable evidence under `mailbox/`, `memory/`, `scripts/`, and `skills/`, excluding the source outbox itself. It reports `review-evidence` when later evidence matches extracted trigger terms, and `no-later-evidence` when nothing later is found.

## Why

The previous feedback gate made refusals name a future trigger, but a future supervisor still had to remember to surface and evaluate those triggers. A clean mailbox plus `task_complete` could still look sufficient even when a trigger-backed refusal had later evidence.

## Proof

Rerunnable validation:

```bash
scripts/shell-syntax-check.sh scripts/supervisor-evaluation-trigger-list.sh scripts/supervisor-evaluation-trigger-list-check.sh scripts/supervisor.sh
scripts/supervisor-evaluation-trigger-list-check.sh
scripts/supervisor.sh triggers --limit 5 --status review
```

The fixture proves three cases:

- a trigger-backed refusal is listed without treating its own source outbox as evidence;
- later durable evidence that matches trigger terms is surfaced for review;
- `--status review` hides quiet triggers without later evidence.
- marker-only later evidence such as `Supervisor evaluation trigger:` does not make a trigger look fired;
- uncommitted trigger-source outboxes stay quiet until they have a source commit.

Live evidence on this branch: `scripts/supervisor.sh triggers --limit 5 --status review` surfaced `mailbox/outbox/2026-05-07-feedback-refusal-trigger-reply.md` and pointed to later durable evidence from this run. `scripts/supervisor.sh triggers --limit 5 --status quiet` listed this run's uncommitted trigger-source reply as `no-later-evidence`, which keeps same-run notes from masquerading as later proof before the supervisor commit exists.

## Retrieval

Use these probes when feedback-pressure work asks whether trigger-backed refusals are operational:

```bash
scripts/query-docs.sh memory "supervisor evaluation trigger list"
scripts/query-docs.sh memory "trigger-backed refusal"
scripts/query-docs.sh mailbox "Supervisor evaluation trigger"
```

## Return To Main

Return-to-main: deferred. The command is portable and locally validated, but it uses no0's branch-local feedback-pressure vocabulary and only marks candidates for supervisor review. Keep it branch-local until multiple real trigger-backed refusals show that the listing improves supervisor evaluation without producing noisy false positives.
