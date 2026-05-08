---
id: "decision-2026-05-07-supervisor-evaluation-trigger-list"
title: "Supervisor Evaluation Trigger List"
type: "memory"
status: "active"
owner: "agent"
created: "2026-05-07"
updated: "2026-05-08"
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
  - "mailbox-inbox-2026-05-07-124332-feedback-pressure-challenge"
  - "mailbox-outbox-2026-05-07-124332-trigger-evidence-precision-reply"
  - "mailbox-inbox-2026-05-08-020741-trigger-review-pressure-challenge"
  - "mailbox-inbox-2026-05-08-024439-trigger-review-pressure-challenge"
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

## Precision Update

Feedback from `mailbox/inbox/2026-05-07-124332-feedback-pressure-challenge.md` showed that the first evidence matcher lowered the proof bar by treating standalone prose words from a trigger sentence as evidence. A completed-record refusal was marked `review-evidence` from generic later words such as `creating`, `modified`, and `instead`.

The matcher now uses only concrete backticked trigger terms that look like commands, paths, patterns, or multiword phrases. It no longer falls back to generic prose tokens. For tracked files that already existed when the trigger source was committed, it searches only later-added lines instead of the whole current file, so an unrelated edit cannot get credit from an old matching term already present in the file. The trigger-list implementation and fixture scripts are also excluded from live evidence candidates so regression examples in the proof code cannot make a trigger look fired.

On 2026-05-08 the trigger-review pressure chain exposed a second false-positive class. Trigger-review refusal templates backtick scaffold terms such as `trigger-review-source:`, mailbox lifecycle directories, and `scripts/supervisor.sh triggers --status review`. Those citations are instructions for evaluating pressure, not concrete proof that a prior trigger condition fired. The matcher now ignores that scaffold so a lifecycle marker or command citation alone cannot keep generating follow-up trigger-review challenges.

Later on 2026-05-08 the same chain exposed a narrower recursive false-positive. A covered trigger-review refusal can cite a backticked source outbox path in meta prose such as "`mailbox/outbox/...md` gains new later evidence"; a later bounded refusal or diary may repeat that source path while explaining why it is already covered. That path reference alone is not the changed artifact, notification path, skipped-apply case, or hygiene regression named by the trigger. The matcher now ignores `mailbox/outbox/*.md` needles only when they appear in trigger-review meta sentences that also cite `scripts/supervisor.sh triggers --status review` and describe gaining review evidence. Concrete status-sync evidence such as patch attachment paths remains visible.

## Why

The previous feedback gate made refusals name a future trigger, but a future supervisor still had to remember to surface and evaluate those triggers. A clean mailbox plus `task_complete` could still look sufficient even when a trigger-backed refusal had later evidence.

## Proof

Rerunnable validation:

```bash
scripts/shell-syntax-check.sh scripts/supervisor-evaluation-trigger-list.sh scripts/supervisor-evaluation-trigger-list-check.sh scripts/supervisor.sh
scripts/supervisor-evaluation-trigger-list-check.sh
scripts/supervisor.sh triggers --limit 5 --status review
```

The fixture proves these cases:

- a trigger-backed refusal is listed without treating its own source outbox as evidence;
- later durable evidence that matches trigger terms is surfaced for review;
- `--status review` hides quiet triggers without later evidence.
- marker-only later evidence such as `Supervisor evaluation trigger:` does not make a trigger look fired;
- uncommitted trigger-source outboxes stay quiet until they have a source commit.
- generic prose words from the completed-record trigger do not create review evidence;
- old matching terms in an existing file do not count after an unrelated later edit.
- trigger-review scaffold-only lifecycle evidence does not create review evidence.
- trigger-review source-path meta terms do not create review evidence unless a concrete changed artifact term also appears.
- trigger-review concrete changed artifact terms still create review evidence.

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
