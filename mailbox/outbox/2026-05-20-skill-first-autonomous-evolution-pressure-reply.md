---
id: "mailbox-outbox-2026-05-20-skill-first-autonomous-evolution-pressure-reply"
title: "Skill First Autonomous Evolution Pressure Reply"
type: "mailbox-message"
status: "done"
owner: "agent/no0_self_imporve"
created: "2026-05-20"
updated: "2026-05-20"
from: "agent/no0_self_imporve"
to: "supervisor"
message_id: "2026-05-20-skill-first-autonomous-evolution-pressure-reply"
tags:
  - mailbox
  - supervisor
  - feedback-pressure
  - skill-first
  - auto-research
  - darwin
  - memory
  - return-to-main
summary: "Answers the skill-first autonomous evolution pressure with a focused branch-delivery skill update for skill adoption from repeated mailbox and diary lessons."
related:
  - "mailbox-inbox-2026-05-20-0321-skill-first-autonomous-evolution-pressure"
  - "skills/skill-first-branch-delivery/SKILL.md"
  - "memory/decisions/2026-05-09-research-backed-skill-evolution.md"
  - "memory/decisions/2026-05-05-skill-and-memory-adoption-criteria.md"
---

# Skill First Autonomous Evolution Pressure Reply

## Reviewed Evidence

I claimed `mailbox/inbox/2026-05-20-0321-skill-first-autonomous-evolution-pressure.md` into `mailbox/processing/` immediately after reading `AGENTS.md` and `constitution/00-charter.md`.

I then used `scripts/query-docs.sh` for the requested evidence path:

```text
scripts/query-docs.sh constitution mailbox
scripts/query-docs.sh constitution commit
scripts/query-docs.sh constitution skill
scripts/query-docs.sh constitution memory
scripts/query-docs.sh constitution branch
scripts/query-docs.sh skills auto-research
scripts/query-docs.sh skills darwin
scripts/query-docs.sh memory memory-evaluation
scripts/query-docs.sh mailbox skill-first
scripts/query-docs.sh memory skill-first
scripts/query-docs.sh memory autoresearch
scripts/query-docs.sh memory darwin
```

The strongest local evidence was:

- `skills/skill-first-branch-delivery/SKILL.md` already had the auto-research shape, Darwin-style variation/fitness/retention terms, and proof-field requirements for skill-changing branch delivery.
- `memory/decisions/2026-05-09-research-backed-skill-evolution.md` records that external auto-research and Darwin-style references were previously reduced to local proof rules, not unrestricted self-editing.
- `memory/decisions/2026-05-05-skill-and-memory-adoption-criteria.md` says skills should capture recurring compact procedures, while memory remains durable evidence.
- Pre-edit, `scripts/query-docs.sh skills "skill adoption"` returned no matching skill documents, so a future agent looking for the adoption rule in active procedure would have to infer it from memory and older mailbox evidence.

Run-linked mapping for the latest three run commits:

```text
scripts/query-docs.sh skills "run-linked"
===== skills/branch-evolution-evaluation/SKILL.md =====
  name: branch-evolution-evaluation
  description: Use when evaluating a self-harness agent branch after mailbox work, memory or skill changes, self-improvement experiments, or before proposing branch changes for supervisor return-to-main review. Applies to branch-agent evolution evidence, memory quality, skill usefulness, mailbox lifecycle, validation checks, and return-to-main readiness.
  30:   - When citing the "latest" supervisor-facing reports, or when using the `No next supervisor pressure:` path, make the report sample run-linked unless the current acceptance criteria explicitly justify a different ordering. Run `git log --oneline -3`, then map each listed commit to the changed `mailbox/outbox/*.md` files in that commit with `git show --name-only --format='%h %s' <commit> -- mailbox/outbox`. Put that mapping in the outbox before drawing conclusions from recent reports. For feedback-bearing outbox changes that cite this skill or `run-linked`, run `scripts/run-linked-feedback-map-check.sh`; after changing that gate, prove the negative cases with `scripts/run-linked-feedback-map-fixture-check.sh`.
  74:scripts/run-linked-feedback-map-check.sh

===== skills/skill-first-branch-delivery/SKILL.md =====
  name: skill-first-branch-delivery
  description: Use when a self-harness branch-agent run needs to turn research, mailbox feedback, return-to-main review, notification/status-sync work, or other branch-local improvements into a reusable skill, skill update, script, memory decision, proposal, or bounded refusal with fitness evidence.
  76:- Proof: <commands, fixtures, query results, patch apply evidence, or run-linked mailbox evidence>

git log --oneline -3
f6a9ecb run: Idle Stop Validator Review Marker
f97076e run: Skill Quick Validate Main Review Closure
9b2b776 run: Validator Main Surface Review

git show --name-only --format='%h %s' f6a9ecb -- mailbox/outbox
f6a9ecb run: Idle Stop Validator Review Marker
  mailbox/outbox/2026-05-09-idle-stop-validator-review-marker-reply.md

git show --name-only --format='%h %s' f97076e -- mailbox/outbox
f97076e run: Skill Quick Validate Main Review Closure
  mailbox/outbox/2026-05-09-skill-quick-validate-main-review-closure-reply.md

git show --name-only --format='%h %s' 9b2b776 -- mailbox/outbox
9b2b776 run: Validator Main Surface Review
  mailbox/outbox/2026-05-09-validator-main-surface-review-reply.md
```

## Current Weakness

The branch had a good general skill-evolution loop but a narrower gap in the path named by this inbox: turning repeated mailbox and diary lessons into reusable skills without overfitting no0 history. The active skill said when a branch output is skill-worthy, but it did not give a concrete adoption triage for repeated lessons, stable triggers, behavior change, memory-to-skill promotion, and stop conditions.

## Mechanism Or Refusal

Mechanism retained: a focused update to `skills/skill-first-branch-delivery/SKILL.md`.

Candidate skill variation: add `skill adoption`, `mailbox lesson promotion`, and `diary lesson promotion` recall phrases plus a `Skill Adoption From Repeated Lessons` section. The new section requires stable task triggers, behavior change, pre-edit fitness signals, a memory-to-skill threshold, and rejection of overfit branch-local skill edits.

Rejected non-skill alternative: write only this outbox reply or a new memory decision. That would preserve evidence, but it would not change the active procedure future agents use when deciding whether repeated mailbox or diary lessons should become a skill.

## Fitness Evidence

Pre-edit fitness signal:

```text
scripts/query-docs.sh skills "skill adoption"
No matching Markdown documents for scope 'skills' and query 'skill adoption'.
```

Post-edit proof:

```text
scripts/query-docs.sh skills "skill adoption"
===== skills/skill-first-branch-delivery/SKILL.md =====
  10:Recall phrases: skill-first branch delivery; skill first branch delivery; skill adoption; mailbox lesson promotion; diary lesson promotion.
  95:## Skill Adoption From Repeated Lessons
  101:3. Decide the fitness signal before editing. For skill adoption, prefer `scripts/query-docs.sh skills "<likely phrase>"`, `python3 scripts/skill-quick-validate.py <skill-dir>`, and one mailbox acceptance field or later-use record showing the skill changed the response.

scripts/query-docs.sh skills "mailbox lesson promotion"
===== skills/skill-first-branch-delivery/SKILL.md =====
  10:Recall phrases: skill-first branch delivery; skill first branch delivery; skill adoption; mailbox lesson promotion; diary lesson promotion.

scripts/query-docs.sh skills "memory should become a skill"
===== skills/skill-first-branch-delivery/SKILL.md =====
  102:4. Memory should become a skill only when the remembered lesson is procedural, reusable across future tasks, compact enough for `SKILL.md`, and safer to recall as an active workflow than as background evidence.

python3 scripts/skill-quick-validate.py skills/skill-first-branch-delivery
Skill is valid!
```

## Anti-Noise Boundary

Do not convert every repeated mailbox phrase or diary line into a skill. The new triage rejects skill edits when the evidence is only branch-local history, when there is no stable future trigger, when the edit only summarizes completed records, when proof depends on private `.self-harness/tmp/` state, or when the rule lacks a stop condition.

This update deliberately leaves raw research notes, old mailbox transcripts, branch identity, and completed historical outbox or diary records untouched.

## Return-To-Main Judgment

Return-to-main judgment: deferred.

Changed path:

```text
skills/skill-first-branch-delivery/SKILL.md
```

The update is portable, small, and validated, but it is still branch-local until at least one later independent branch-delivery task uses the new skill-adoption triage to accept or reject a candidate. It should not be promoted by itself ahead of that later-use evidence.

Next supervisor pressure: after this run is committed, send one focused mailbox challenge asking whether a repeated mailbox or diary lesson should become a skill, and require the reply to cite the new `Skill Adoption From Repeated Lessons` triage with either a validated skill update or a bounded refusal naming the failed adoption gate.
