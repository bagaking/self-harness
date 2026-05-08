---
id: "decision-2026-05-07-supervisor-evaluation-trigger-list"
title: "Supervisor Evaluation Trigger List"
type: "memory"
status: "active"
owner: "agent"
created: "2026-05-07"
updated: "2026-05-09"
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
  - "mailbox-inbox-2026-05-08-194009-trigger-review-pressure-challenge"
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

Later on 2026-05-08 the same chain exposed a narrower recursive false-positive. A covered trigger-review refusal can cite a backticked source outbox path in meta prose such as "`mailbox/outbox/...md` gains new later evidence"; a later bounded refusal or diary may repeat that source path while explaining why it is already covered. That path reference alone is not the changed artifact, notification path, skipped-apply case, or hygiene regression named by the trigger. The matcher now ignores `mailbox/outbox/*.md` needles only when they appear in trigger-review source-path meta sentences that also cite `scripts/supervisor.sh triggers --status review` and do not identify the outbox Markdown path itself as a concrete artifact. Concrete status-sync evidence such as patch attachment paths remains visible, and a concrete outbox Markdown artifact path can still produce `review-evidence`.

The post-run continuous-pressure proof on 2026-05-08 exposed one more equivalent wording: "review evidence from repeated source-path prose." That phrase is the same trigger-review meta boundary, not a concrete artifact request. The matcher now treats it as source-path meta wording too, and `scripts/supervisor-evaluation-trigger-list-check.sh` includes a fixture where a later continuous-supervision report repeats only trigger-review source paths. This keeps trigger-review from blocking the lower-priority continuous-pressure seeder when all real trigger-review sources already have lifecycle markers.

The next trigger-review pressure run exposed a related command-citation false positive. The source-path-meta trigger asked the supervisor to run `scripts/supervisor-evaluation-trigger-list-check.sh` and reopen only if the source-path-meta reply returned or the concrete outbox Markdown artifact fixture failed. Later proof records cited the validation command as passing evidence, which should not by itself reopen the trigger. The matcher now ignores that fixture-check command only inside trigger-review meta lines where the concrete condition is a fixture failure; concrete outbox Markdown artifact paths still surface as review evidence.

On 2026-05-09 another live trigger-review challenge exposed a read-only script-reference false positive. The source trigger watched supervisor control-plane script paths and notification environment semantics. Later mailbox records reviewed those scripts or confirmed no script change, which is not evidence that a watched script changed. The matcher now ignores added lines that only review, read, or inspect a backticked script path, explicitly say the script did not change, restate the source trigger condition, cite validation commands against watched script paths, or describe the positive fixture itself. It also ignores code-block path list lines that contain only the script path. Separate positive fixture coverage proves that a later durable report saying a watched supervisor script changed still creates review evidence.

Later on 2026-05-09 the same source exposed a lifecycle-marker variant. A trigger-review stop condition can say a prior source path should reopen only if that source "reappears from" a narrow evidence class. A later report may name that source path only as `trigger-review-source:` or in related metadata while classifying it as covered. That lifecycle marker is not the watched evidence class. The matcher now treats "reappears from" trigger-review wording as source-path meta unless the trigger also names a concrete artifact path.

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
- current repeated-source wording that cites `scripts/supervisor-evaluation-trigger-list.sh` as a defect target does not create review evidence by itself.
- trigger-review concrete changed artifact terms still create review evidence.
- repeated source-path prose wording does not create trigger-review evidence by itself.
- trigger-review fixture validation command citations do not create trigger-review evidence by themselves.
- trigger-review concrete outbox Markdown artifact terms still create review evidence.
- read-only reviewed script path mentions and explicit no-change lines do not create review evidence.
- durable reports that explicitly say a watched supervisor script changed still create review evidence.
- script trigger restatement prose and script-path validation commands do not create review evidence.
- trigger-review source paths inside a "reappears from" condition do not fire from later lifecycle-marker prose alone.

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
