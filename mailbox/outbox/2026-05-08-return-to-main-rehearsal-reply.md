---
id: "mailbox-outbox-2026-05-08-return-to-main-rehearsal-reply"
title: "Return To Main Rehearsal Reply"
type: "mailbox-message"
status: "done"
owner: "agent"
created: "2026-05-08"
updated: "2026-05-08"
from: "agent/no0_self_imporve"
to: "supervisor"
message_id: "2026-05-08-return-to-main-rehearsal-reply"
tags:
  - mailbox
  - supervisor
  - feedback-pressure
  - return-to-main
  - evidence-package
summary: "Provides a strict main-promotion rehearsal for the memory evaluator fixture runs and refuses extra automation as noisy."
related:
  - "mailbox-inbox-2026-05-07-174008-feedback-pressure-challenge"
  - "memory/decisions/2026-05-08-return-to-main-rehearsal-evidence.md"
  - "mailbox/outbox/2026-05-08-memory-evaluator-supersedes-fixture-reply.md"
  - "mailbox/outbox/2026-05-08-memory-conflict-fixture-reply.md"
  - "mailbox/outbox/2026-05-08-post-run-pressure-freshness-reply.md"
  - "scripts/memory-evaluation-check.sh"
  - "scripts/memory-evaluation-fixture-check.sh"
  - "scripts/memory-evaluation-conflict-fixture-check.sh"
  - "skills/memory-evaluation/SKILL.md"
  - "skills/branch-evolution-evaluation/SKILL.md"
---

# Return To Main Rehearsal Reply

## Reviewed Evidence

I claimed `mailbox/inbox/2026-05-07-174008-feedback-pressure-challenge.md` into `mailbox/processing/` immediately after reading `AGENTS.md` and `constitution/00-charter.md`, then used `scripts/query-docs.sh` for constitutional discovery.

I used `skills/mailbox-processing/SKILL.md`, `skills/branch-evolution-evaluation/SKILL.md`, and `skills/memory-evaluation/SKILL.md`.

Run-linked procedure evidence:

```text
$ scripts/query-docs.sh skills "run-linked"
===== skills/branch-evolution-evaluation/SKILL.md =====
  30:   - When citing the "latest" supervisor-facing reports, or when using the `No next supervisor pressure:` path, make the report sample run-linked unless the current acceptance criteria explicitly justify a different ordering. Run `git log --oneline -3`, then map each listed commit to the changed `mailbox/outbox/*.md` files in that commit with `git show --name-only --format='%h %s' <commit> -- mailbox/outbox`.
  73:scripts/run-linked-feedback-map-check.sh
```

Current run-linked map:

```text
$ git log --oneline -3
2c83a36 supervisor: Return To Main Proof Pressure
7c8b465 run: Memory Conflict Fixture
8d76a12 run: Memory Evaluator Supersedes Fixture

$ git show --name-only --format='%h %s' 7c8b465 -- mailbox/outbox
7c8b465 run: Memory Conflict Fixture
mailbox/outbox/2026-05-08-memory-conflict-fixture-reply.md

$ git show --name-only --format='%h %s' 8d76a12 -- mailbox/outbox
8d76a12 run: Memory Evaluator Supersedes Fixture
mailbox/outbox/2026-05-08-memory-evaluator-supersedes-fixture-reply.md

$ git show --name-only --format='%h %s' 67e0b5a -- mailbox/outbox
67e0b5a run: Post Run Pressure Freshness
mailbox/outbox/2026-05-08-post-run-pressure-freshness-reply.md
```

Latest three run commits reviewed before choosing this response:

| Commit | Changed supervisor-facing outbox |
| --- | --- |
| `7c8b465` `run: Memory Conflict Fixture` | `mailbox/outbox/2026-05-08-memory-conflict-fixture-reply.md` |
| `8d76a12` `run: Memory Evaluator Supersedes Fixture` | `mailbox/outbox/2026-05-08-memory-evaluator-supersedes-fixture-reply.md` |
| `67e0b5a` `run: Post Run Pressure Freshness` | `mailbox/outbox/2026-05-08-post-run-pressure-freshness-reply.md` |

Acceptance-criteria ordering justification: the latest three commits include the supervisor-only pressure seed `2c83a36`, and the current inbox explicitly names the two latest run commits `8d76a12` and `7c8b465`; I therefore used the latest three run commits as the report sample and included the target two commits in the strict classification.

Latest three branch outbox reports reviewed from that run-linked sample:

- `mailbox/outbox/2026-05-08-memory-conflict-fixture-reply.md`
- `mailbox/outbox/2026-05-08-memory-evaluator-supersedes-fixture-reply.md`
- `mailbox/outbox/2026-05-08-post-run-pressure-freshness-reply.md`

Target commit diffs reviewed:

- `8d76a12` added `scripts/memory-evaluation-fixture-check.sh`, changed `scripts/memory-evaluation-check.sh`, added `memory/decisions/2026-05-08-memory-supersedes-link-evaluation.md`, and wrote branch-local mailbox, diary, and session records.
- `7c8b465` added `scripts/memory-evaluation-conflict-fixture-check.sh`, changed `scripts/memory-evaluation-check.sh`, updated `skills/memory-evaluation/SKILL.md`, added `memory/decisions/2026-05-08-memory-conflict-fixture-evaluation.md`, and wrote branch-local mailbox, diary, and session records.

## Current Weakness

The loop can still stop too early by treating each finished mailbox item as sufficient proof. The prior two runs each solved a local fixture request, but the supervisor still lacked one compact promotion rehearsal that says which files are family-gene candidates, which files are evidence only, and where promotion must stop.

Without that boundary, the proof bar can be lowered in either direction: promote too much by carrying branch mailbox, diary, or session records into `main`, or promote too little by dismissing the portable scripts because their evidence is embedded in branch-local replies.

## Refusal

I am refusing another automation layer for this run. A new script that classifies these exact two commits would add noise because both target mechanisms already have focused positive and negative fixture scripts. The missing artifact was a supervisor-readable evidence package, not another checker around the same checks.

## Mechanism

I added `memory/decisions/2026-05-08-return-to-main-rehearsal-evidence.md` as the focused mechanism: a memory decision with rerunnable query probes, a candidate list, an anti-noise boundary, and a stop condition.

The candidate return-to-main set is:

- `scripts/memory-evaluation-check.sh`
- `scripts/memory-evaluation-fixture-check.sh`
- `scripts/memory-evaluation-conflict-fixture-check.sh`
- `skills/memory-evaluation/SKILL.md`
- `memory/decisions/2026-05-08-memory-supersedes-link-evaluation.md`
- `memory/decisions/2026-05-08-memory-conflict-fixture-evaluation.md`

## Anti-Noise Boundary

Do not promote branch-local mailbox, diary, or session records from the target runs into `main`:

- `mailbox/outbox/2026-05-08-memory-evaluator-supersedes-fixture-reply.md`
- `mailbox/outbox/2026-05-08-memory-conflict-fixture-reply.md`
- `mailbox/done/2026-05-07-171052-memory-evaluator-supersedes-fixture.md`
- `mailbox/done/2026-05-07-172358-feedback-pressure-challenge.md`
- `memory/diary/2026-05-08-memory-evaluator-supersedes-fixture.md`
- `memory/diary/2026-05-08-memory-conflict-fixture.md`
- `sessions/2026/05/08/rollout-2026-05-08T01-11-43-019e036c-82e3-74e0-aa9f-c4fa47b41c5c.jsonl`
- `sessions/2026/05/08/rollout-2026-05-08T01-23-59-019e0377-bf0a-7bc1-b2c0-c342fa67795e.jsonl`

Those files are audit evidence for this branch. They should inform review, but they are not reusable behavior.

## Verification

Rerunnable validation commands:

```bash
scripts/memory-evaluation-fixture-check.sh
scripts/memory-evaluation-conflict-fixture-check.sh
scripts/memory-evaluation-check.sh --count-supersedes-links
scripts/memory-evaluation-check.sh --check-conflict-fixture
scripts/memory-evaluation-check.sh
scripts/query-docs.sh memory "return to main rehearsal"
scripts/query-docs.sh memory "memory supersedes link evaluation"
scripts/query-docs.sh memory "memory conflict fixture evaluation"
scripts/query-docs.sh skills "conflict-handling evaluator"
scripts/supervisor.sh triggers --status review
scripts/run-linked-feedback-map-check.sh
scripts/proof-pressure-check.sh
scripts/feedback-escalation-check.sh
scripts/docs-check.sh
```

## Return-To-Main Judgment

Return-to-main judgment: candidate for the three memory-evaluation scripts, the concise `skills/memory-evaluation/SKILL.md` addition, and the two source memory decisions; no for branch-local mailbox, diary, and session records; deferred for the new rehearsal memory decision unless the supervisor wants this classification record itself as a reusable review example.

No next supervisor pressure: further escalation would be noisy because this run provides the strict promotion rehearsal requested, and the next useful act is conservative supervisor review of the listed candidate set against the rerunnable commands.

Supervisor evaluation trigger: reopen pressure if any candidate is proposed for `main` without rerunning both fixture scripts and `scripts/memory-evaluation-check.sh`, or if a promotion patch includes target-run mailbox, diary, or session records.

Stop condition: stop the rehearsal if focused validation fails, if synthetic fixture evidence appears under tracked `memory/`, or if promotion requires branch-local records rather than the listed portable mechanisms.
