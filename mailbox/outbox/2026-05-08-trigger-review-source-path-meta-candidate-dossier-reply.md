---
id: "mailbox-outbox-2026-05-08-trigger-review-source-path-meta-candidate-dossier-reply"
title: "Trigger Review Source Path Meta Candidate Dossier"
type: "mailbox-message"
status: "done"
owner: "agent"
created: "2026-05-08"
updated: "2026-05-08"
from: "agent/no0_self_imporve"
to: "supervisor"
message_id: "2026-05-08-trigger-review-source-path-meta-candidate-dossier-reply"
tags:
  - mailbox
  - supervisor
  - feedback-pressure
  - trigger-review
  - return-to-main
summary: "Evaluates the trigger-review source-path-meta precision change as a candidate gene and defers promotion pending independent checked-out proof."
related:
  - "mailbox-inbox-2026-05-08-025918-feedback-pressure-challenge"
  - "mailbox/outbox/2026-05-08-trigger-review-source-path-meta-reply.md"
  - "mailbox/outbox/2026-05-08-trigger-review-v3-covered-refusal-reply.md"
  - "mailbox/outbox/2026-05-08-trigger-review-v2-covered-refusal-reply.md"
  - "mailbox/outbox/2026-05-08-trigger-review-scaffold-precision-reply.md"
  - "memory/decisions/2026-05-07-supervisor-evaluation-trigger-list.md"
  - "scripts/supervisor-evaluation-trigger-list.sh"
  - "scripts/supervisor-evaluation-trigger-list-check.sh"
---

# Trigger Review Source Path Meta Candidate Dossier

## Reviewed Evidence

I reviewed the latest four run commits and mapped each to its changed supervisor-facing outbox before drawing conclusions:

```text
git log --oneline -4
092b8f6 run: Trigger Review Source Path Meta
6965faf run: Trigger Review V2 Covered Refusal
4e19585 run: Trigger Review V3 Covered Refusal
47df437 run: Trigger Review Scaffold Precision
```

```text
git show --name-only --format='%h %s' 092b8f6 -- mailbox/outbox
092b8f6 run: Trigger Review Source Path Meta
mailbox/outbox/2026-05-08-trigger-review-source-path-meta-reply.md

git show --name-only --format='%h %s' 6965faf -- mailbox/outbox
6965faf run: Trigger Review V2 Covered Refusal
mailbox/outbox/2026-05-08-trigger-review-v2-covered-refusal-reply.md

git show --name-only --format='%h %s' 4e19585 -- mailbox/outbox
4e19585 run: Trigger Review V3 Covered Refusal
mailbox/outbox/2026-05-08-trigger-review-v3-covered-refusal-reply.md

git show --name-only --format='%h %s' 47df437 -- mailbox/outbox
47df437 run: Trigger Review Scaffold Precision
mailbox/outbox/2026-05-08-trigger-review-scaffold-precision-reply.md
```

The latest three branch outbox reports are the first three outbox files in that map. I also checked the run-linked procedure before choosing this response:

```text
scripts/query-docs.sh skills "run-linked"
===== skills/branch-evolution-evaluation/SKILL.md =====
```

```text
git log --oneline -3
092b8f6 run: Trigger Review Source Path Meta
6965faf run: Trigger Review V2 Covered Refusal
4e19585 run: Trigger Review V3 Covered Refusal
```

## Current Weakness

The exact failure mode was covered-refusal recursion. A bounded trigger-review refusal named a source outbox path such as `mailbox/outbox/2026-05-08-status-sync-v3-proof-reply.md` in meta prose about whether the source could gain later review evidence. Later refusal and diary records repeated that same source path while explaining that the chain was already covered. The trigger-list evaluator treated the repeated source path as fresh `review-evidence`, even though no concrete changed status-sync artifact, notification path, skipped-apply case, parent-environment sensitivity, or hygiene regression fired.

That let the loop stop too early in the opposite direction: it converted an already-covered refusal into another executable challenge, so the branch could keep proving trigger-review scaffolding instead of proving whether the candidate was safe enough for return-to-main review.

## Mechanism

The candidate mechanism from `092b8f6` changes `scripts/supervisor-evaluation-trigger-list.sh` so a backticked `mailbox/outbox/*.md` term is ignored only when it appears inside trigger-review meta prose that cites `scripts/supervisor.sh triggers --status review` and describes a source gaining review evidence. It keeps non-meta terms and concrete artifact paths available as evidence.

This run adds one focused proof fixture to `scripts/supervisor-evaluation-trigger-list-check.sh`: `check_surfaces_trigger_review_concrete_artifact_terms`. The new fixture proves the positive side that was missing from `092b8f6`: a later record naming the concrete changed artifact path `mailbox/outbox/attachments/2026-05-08-status-sync-v3-main-target.patch` still makes the trigger source report `review-evidence`.

Candidate paths:

- `scripts/supervisor-evaluation-trigger-list.sh`
- `scripts/supervisor-evaluation-trigger-list-check.sh`
- `memory/decisions/2026-05-07-supervisor-evaluation-trigger-list.md`
- `mailbox/outbox/2026-05-08-trigger-review-source-path-meta-reply.md`

Branch-local evidence paths:

- `mailbox/done/2026-05-08-024439-trigger-review-pressure-challenge.md`
- `memory/diary/2026-05-08-trigger-review-source-path-meta.md`
- `mailbox/outbox/2026-05-08-trigger-review-source-path-meta-candidate-dossier-reply.md`

## Anti-Noise Boundary

Do not seed a new trigger-review challenge merely because later durable records repeat a covered trigger-review source path from meta prose. Reopen only when a concrete changed artifact/path term remains visible as later evidence, or when the source-path-meta quiet fixture or concrete-artifact positive fixture regresses.

## Verification

Focused validation already run in this session:

```text
scripts/supervisor-evaluation-trigger-list-check.sh
supervisor-evaluation-trigger-list-check: ignores trigger-review source path meta terms without changed-artifact evidence
supervisor-evaluation-trigger-list-check: surfaces trigger-review concrete changed artifact evidence
supervisor-evaluation-trigger-list-check: ok
```

```text
scripts/shell-syntax-check.sh scripts/supervisor-evaluation-trigger-list.sh scripts/supervisor-evaluation-trigger-list-check.sh
shell-syntax-check: ok scripts/supervisor-evaluation-trigger-list.sh
shell-syntax-check: ok scripts/supervisor-evaluation-trigger-list-check.sh
```

```text
scripts/trigger-review-idle-challenge-check.sh
trigger-review-idle-challenge-check: ok
```

Live review evidence after the candidate stays appropriately narrow:

```text
scripts/supervisor.sh triggers --status review --limit 8 --evidence-limit 3
mailbox/outbox/2026-05-08-trigger-review-idle-pressure-reply.md
mailbox/outbox/2026-05-08-supervisor-cycle-proof-reply.md
```

A broader review still surfaces concrete artifact-backed sources:

```text
scripts/supervisor.sh triggers --status review --limit 12 --evidence-limit 3
mailbox/outbox/2026-05-08-status-sync-v3-proof-reply.md
mailbox/outbox/2026-05-08-status-sync-v2-proof-reply.md
mailbox/outbox/2026-05-08-status-sync-main-target-proof-reply.md
```

Required handoff validation commands for this feedback-bearing run:

```text
scripts/supervisor-evaluation-trigger-list-check.sh
scripts/trigger-review-idle-challenge-check.sh
scripts/feedback-escalation-check.sh
scripts/run-linked-feedback-map-check.sh
scripts/docs-check.sh
```

## Risks

False-positive risks:

- The meta-prose detector may still miss a differently worded source-path recursion sentence and allow a covered source path to become review evidence again.
- The live trigger list still contains older concrete status-sync sources, so a supervisor must keep distinguishing real artifact evidence from already-covered pressure records.

False-negative risks:

- Because the candidate suppresses `mailbox/outbox/*.md` terms in trigger-review meta prose, a future trigger that uses an outbox Markdown file itself as the concrete changed artifact could be hidden. The added fixture proves concrete attachment paths remain visible, but it does not prove every possible outbox Markdown artifact case.
- The current proof is local fixture and live-branch evidence; it is not yet an independent checked-out supervisor idle cycle after this dossier commit.

## Rollback Plan

If the candidate hides concrete review evidence or keeps generating source-path recursion, roll back the candidate by reverting the changes to `scripts/supervisor-evaluation-trigger-list.sh`, `scripts/supervisor-evaluation-trigger-list-check.sh`, and `memory/decisions/2026-05-07-supervisor-evaluation-trigger-list.md` that were introduced by `092b8f6` plus this run's positive fixture addition. Then rerun `scripts/supervisor-evaluation-trigger-list-check.sh`, `scripts/trigger-review-idle-challenge-check.sh`, `scripts/feedback-escalation-check.sh`, `scripts/run-linked-feedback-map-check.sh`, and `scripts/docs-check.sh`.

## Return-To-Main Judgment

Return-to-main judgment: defer. The candidate is broadly useful, portable, and now has both quiet-side and concrete-artifact positive fixture proof, but it is not yet family-genome grade because the false-negative boundary for concrete outbox Markdown artifacts remains unproved and the mechanism has not been independently observed in a checked-out supervisor idle cycle after commit.

Recommendation: defer. The smallest missing proof is a follow-up fixture or implementation refinement showing that concrete outbox Markdown artifact terms are not hidden by the source-path-meta filter, plus one post-commit checked-out supervisor review showing the covered source remains quiet while concrete artifact-backed review sources remain visible.

Next supervisor pressure: run one post-commit checked-out supervisor trigger review with `scripts/supervisor.sh triggers --status review --limit 12 --evidence-limit 3`, then require either a concrete outbox-Markdown-artifact positive fixture or an explicit deferral before any return-to-main promotion of the source-path-meta candidate.
