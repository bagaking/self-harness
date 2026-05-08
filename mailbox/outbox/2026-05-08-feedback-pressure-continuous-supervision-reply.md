---
id: "mailbox-outbox-2026-05-08-feedback-pressure-continuous-supervision-reply"
title: "Feedback Pressure Continuous Supervision Reply"
type: "mailbox-message"
status: "done"
owner: "agent"
created: "2026-05-08"
updated: "2026-05-08"
from: "agent/no0_self_imporve"
to: "supervisor"
message_id: "2026-05-08-feedback-pressure-continuous-supervision-reply"
tags:
  - mailbox
  - supervisor
  - feedback-pressure
  - continuous-supervision
  - self-improvement
summary: "Implements a bounded idle supervisor pressure mechanism for recent run-linked proof or promotion debt."
related:
  - "mailbox-inbox-2026-05-08-032901-feedback-pressure-continuous-supervision"
  - "mailbox/outbox/2026-05-08-trigger-review-outbox-markdown-artifact-fixture-reply.md"
  - "memory/decisions/2026-05-08-continuous-supervisor-pressure.md"
  - "scripts/supervisor.sh"
  - "scripts/continuous-supervisor-pressure-check.sh"
---

# Feedback Pressure Continuous Supervision Reply

## Reviewed Evidence

I reviewed the latest three run commits and mapped each to its changed supervisor-facing outbox file before drawing conclusions:

```text
scripts/query-docs.sh skills "run-linked"
===== skills/branch-evolution-evaluation/SKILL.md =====
```

```text
git log --oneline -3
b82ea07 run: Trigger Review Outbox Markdown Artifact Fixture
7b231ed run: Trigger Review Source Path Meta Candidate Dossier
092b8f6 run: Trigger Review Source Path Meta
```

```text
git show --name-only --format='%h %s' b82ea07 -- mailbox/outbox
b82ea07 run: Trigger Review Outbox Markdown Artifact Fixture
mailbox/outbox/2026-05-08-trigger-review-outbox-markdown-artifact-fixture-reply.md

git show --name-only --format='%h %s' 7b231ed -- mailbox/outbox
7b231ed run: Trigger Review Source Path Meta Candidate Dossier
mailbox/outbox/2026-05-08-trigger-review-source-path-meta-candidate-dossier-reply.md

git show --name-only --format='%h %s' 092b8f6 -- mailbox/outbox
092b8f6 run: Trigger Review Source Path Meta
mailbox/outbox/2026-05-08-trigger-review-source-path-meta-reply.md
```

The latest outbox chain shows the problem. `mailbox/outbox/2026-05-08-trigger-review-outbox-markdown-artifact-fixture-reply.md` ended with a bounded clean stop for source-path-meta recursion, while `mailbox/outbox/2026-05-08-trigger-review-source-path-meta-candidate-dossier-reply.md` still named deferred promotion debt and a concrete `Next supervisor pressure:` requirement.

## Current Weakness

The idle skip after `b82ea07` was insufficient because the supervisor had only two automatic pressure paths: trigger-review seeding and the older repeated-low-value heuristic. Once trigger-review looked clean and recent commit subjects were no longer generic sweep subjects, the loop could stop even though recent run-linked evidence still carried explicit proof or promotion debt.

That lowered the proof bar by making the human hand-seed the next hard question whenever the debt was not a fresh trigger-review source. A clean inbox is a hygiene fact, not evidence that branch promotion, post-commit proof, or main-targeted patch debt is resolved.

## Mechanism

I updated `scripts/supervisor.sh` so idle challenge seeding now has a bounded continuous-pressure step after trigger-review seeding and before the older repeated-low-value fallback.

The new step:

- scans only recent `run:` commits, limited by `SELF_HARNESS_CONTINUOUS_PRESSURE_LIMIT` with default `3`;
- considers only top-level `mailbox/outbox/*.md` files changed by those run commits;
- requires both a concrete `Next supervisor pressure:` marker and deferred proof or promotion language such as return-to-main deferral, post-commit proof, checked-out proof, main-targeted patch, candidate gene paths, or blocked promotion;
- writes one `mailbox/inbox/*-continuous-supervisor-pressure.md` challenge that preserves the exact source requirement;
- records `continuous-pressure-source: <source>` and refuses to reissue that same source if the marker already appears anywhere in the mailbox lifecycle.

I added `scripts/continuous-supervisor-pressure-check.sh` and `memory/decisions/2026-05-08-continuous-supervisor-pressure.md`.

## Anti-Noise Boundary

This is not a generic repository sweep trigger. It does not seed from arbitrary old history, non-run commits, completed clean stop conditions, or sources that already have a matching `continuous-pressure-source:` marker.

It also does not supersede trigger-review. Trigger-review still handles trigger-backed refusal evidence first. Continuous pressure only covers recent explicit proof or promotion debt that would otherwise be lost when trigger-review is clean or already lifecycle-covered.

## Verification

Focused fixture proof:

```text
scripts/continuous-supervisor-pressure-check.sh
continuous-supervisor-pressure-check: seeds from recent run-linked proof debt
continuous-supervisor-pressure-check: does not reseed the same continuous pressure source
continuous-supervisor-pressure-check: does not seed from completed clean stop condition
continuous-supervisor-pressure-check: ignores non-run deferred outbox debt
continuous-supervisor-pressure-check: ok
```

Regression proof:

```text
scripts/trigger-review-idle-challenge-check.sh
trigger-review-idle-challenge-check: ok
```

Syntax proof:

```text
scripts/shell-syntax-check.sh scripts/supervisor.sh scripts/continuous-supervisor-pressure-check.sh
shell-syntax-check: ok scripts/supervisor.sh
shell-syntax-check: ok scripts/continuous-supervisor-pressure-check.sh
```

Memory recall now has a direct query:

```text
scripts/query-docs.sh memory "continuous supervisor pressure"
memory/decisions/2026-05-08-continuous-supervisor-pressure.md
```

## Return-To-Main Judgment

Return-to-main judgment: defer. The mechanism is small, portable, and fixture-backed, but it changes supervisor idle behavior on a branch that has accumulated many local pressure mechanisms. It should stay branch-local until a checked-out idle supervisor cycle proves it seeds exactly one continuous-pressure inbox from recent unresolved proof debt and does not create repeat challenges after the source is handled.

Next supervisor pressure: after this run is committed, run a clean checked-out idle supervisor cycle or `scripts/continuous-supervisor-pressure-check.sh` plus `bash -c 'source scripts/supervisor.sh __self_harness_source_only; seed_progressive_challenge_if_needed'` with no pending inbox; require exactly one continuous-pressure inbox only if a recent run-linked source has unresolved proof or promotion debt and no matching `continuous-pressure-source:` marker.
