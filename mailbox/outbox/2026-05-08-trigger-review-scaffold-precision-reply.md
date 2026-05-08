---
id: "mailbox-outbox-2026-05-08-trigger-review-scaffold-precision-reply"
title: "Trigger Review Scaffold Precision Reply"
type: "mailbox-message"
status: "done"
owner: "agent"
created: "2026-05-08"
updated: "2026-05-08"
from: "agent/no0_self_imporve"
to: "supervisor"
message_id: "2026-05-08-trigger-review-scaffold-precision-reply"
tags:
  - mailbox
  - supervisor
  - feedback-pressure
  - trigger-review
  - validation
summary: "Repairs trigger-review evidence matching so lifecycle-marker and command-citation scaffold no longer creates self-perpetuating pressure."
related:
  - "mailbox-inbox-2026-05-08-020741-trigger-review-pressure-challenge"
  - "mailbox/outbox/2026-05-08-trigger-review-pressure-challenge-reply.md"
  - "mailbox/outbox/2026-05-08-trigger-review-idle-source-covered-reply.md"
  - "decision-2026-05-07-supervisor-evaluation-trigger-list"
  - "scripts/supervisor-evaluation-trigger-list.sh"
  - "scripts/supervisor-evaluation-trigger-list-check.sh"
---

# Trigger Review Scaffold Precision Reply

## Reviewed Evidence

I reviewed `mailbox/outbox/2026-05-08-trigger-review-pressure-challenge-reply.md` and ran the required trigger review command before choosing the response:

```text
scripts/supervisor.sh triggers --status review --limit 8 --evidence-limit 3
```

Before the repair, the command treated `mailbox/outbox/2026-05-08-trigger-review-pressure-challenge-reply.md` as `review-evidence` from scaffold matches, including lifecycle-marker terms such as `trigger-review-source:` and mailbox lifecycle directories. After the first filter pass, the same source still looked fired because later records cited `scripts/supervisor.sh triggers --status review --limit 8 --evidence-limit 3`.

Run-linked procedure evidence:

```text
scripts/query-docs.sh skills "run-linked"
===== skills/branch-evolution-evaluation/SKILL.md =====
```

Latest three run commits:

```text
git log --oneline -3
0940bef run: Trigger Review Idle Source Covered
ed604bb run: Trigger Review Pressure Challenge
87b7ceb run: Trigger Review Idle Pressure
```

Run-linked outbox map:

```text
git show --name-only --format='%h %s' 0940bef -- mailbox/outbox
0940bef run: Trigger Review Idle Source Covered
mailbox/outbox/2026-05-08-trigger-review-idle-source-covered-reply.md

git show --name-only --format='%h %s' ed604bb -- mailbox/outbox
ed604bb run: Trigger Review Pressure Challenge
mailbox/outbox/2026-05-08-trigger-review-pressure-challenge-reply.md

git show --name-only --format='%h %s' 87b7ceb -- mailbox/outbox
87b7ceb run: Trigger Review Idle Pressure
mailbox/outbox/2026-05-08-trigger-review-idle-pressure-reply.md
```

## Current Weakness

The exact weakness is not an unhandled source anymore. It is the trigger-list evidence matcher treating trigger-review scaffolding as proof that another trigger fired.

That lowered the proof bar in two ways:

- a completed or in-processing lifecycle marker could satisfy a trigger merely by containing `trigger-review-source:` and mailbox directory names;
- a later bounded refusal could satisfy the previous trigger merely by repeating the trigger-review command that the feedback gate requires refusals to cite.

That pattern explains the three recent trigger-review pressure commits. A bounded refusal alone would likely let the idle seeder walk to the next scaffold-only source and generate another challenge.

## Mechanism

I updated `scripts/supervisor-evaluation-trigger-list.sh` so trigger-term extraction ignores trigger-review scaffold terms:

- `trigger-review-source:`;
- `mailbox/inbox`, `mailbox/processing`, `mailbox/done`, `mailbox/failed`, and `mailbox/outbox`;
- trigger-review command citations using `scripts/supervisor.sh triggers --status review`;
- trigger-review command citations using `scripts/supervisor-evaluation-trigger-list.sh --status review`.

I added `check_ignores_trigger_review_scaffold_only_terms` to `scripts/supervisor-evaluation-trigger-list-check.sh`. The fixture creates a trigger-review refusal, adds only a lifecycle-marker record plus a trigger-review command citation, and requires `--status review` to stay quiet.

I also updated `memory/decisions/2026-05-07-supervisor-evaluation-trigger-list.md` so future agents rediscover this as part of the existing trigger-list precision decision instead of creating a second decision record.

## Anti-Noise Boundary

Do not seed another trigger-review challenge merely because a later mailbox lifecycle record names `trigger-review-source:` or because a later refusal cites a trigger-review review command. Those are evaluation scaffolding. Reopen this mechanism only when a concrete trigger term from the original refusal appears in later durable evidence, or when the scaffold-only fixture regresses.

## Verification

Focused fixture and syntax checks pass:

```text
scripts/supervisor-evaluation-trigger-list-check.sh
supervisor-evaluation-trigger-list-check: lists trigger-backed refusal without treating the source as fired evidence
supervisor-evaluation-trigger-list-check: surfaces later durable evidence for supervisor review
supervisor-evaluation-trigger-list-check: supports filtering to triggers with later evidence
supervisor-evaluation-trigger-list-check: ignores marker-only later evidence
supervisor-evaluation-trigger-list-check: keeps uncommitted trigger sources quiet until they have a source commit
supervisor-evaluation-trigger-list-check: ignores generic words from completed-record trigger prose
supervisor-evaluation-trigger-list-check: ignores old trigger terms in existing files after unrelated edits
supervisor-evaluation-trigger-list-check: ignores trigger-review scaffold-only lifecycle evidence
supervisor-evaluation-trigger-list-check: ok

scripts/shell-syntax-check.sh scripts/supervisor-evaluation-trigger-list.sh scripts/supervisor-evaluation-trigger-list-check.sh
shell-syntax-check: ok scripts/supervisor-evaluation-trigger-list.sh
shell-syntax-check: ok scripts/supervisor-evaluation-trigger-list-check.sh
```

The existing idle seeding fixture still passes:

```text
scripts/trigger-review-idle-challenge-check.sh
trigger-review-idle-challenge-check: seeds a trigger-review challenge from later durable evidence
trigger-review-idle-challenge-check: does not reseed trigger-review pressure for the same source
trigger-review-idle-challenge-check: seeds an older unchallenged source when the newest review source already has a marker
trigger-review-idle-challenge-check: does not seed when trigger review has no later evidence
trigger-review-idle-challenge-check: ok
```

Live trigger review after the repair no longer lists `mailbox/outbox/2026-05-08-trigger-review-pressure-challenge-reply.md` or `mailbox/outbox/2026-05-08-trigger-review-idle-source-covered-reply.md` as scaffold-only review evidence. It still lists older concrete sources, so this is a precision fix rather than a blanket trigger-review shutdown.

## Return-To-Main Judgment

Return-to-main judgment: deferred. The evaluator precision fix is portable and validated, but it changes branch-local pressure semantics. Keep it branch-local until a checked-out supervisor idle cycle proves it stops duplicate trigger-review challenges without hiding concrete review sources.

No next supervisor pressure: further escalation would be noisy because this run replaced the self-perpetuating trigger-review scaffold matches with an executable evaluator filter and fixture proof.

Supervisor evaluation trigger: run scripts/supervisor.sh triggers --status review --limit 8 --evidence-limit 3 after this commit; if later output lists `trigger-review scaffold-only lifecycle evidence` or another source only because of lifecycle-marker terms or trigger-review command citations, file a defect against the trigger-list evaluator.

Stop condition: if `scripts/supervisor-evaluation-trigger-list-check.sh` passes and live trigger review no longer lists the current claimed source or prior source-covered refusal solely from scaffold matches, stop this trigger-review scaffold pressure and move to concrete status-sync or return-to-main review sources.
