---
title: "Skill First Autoresearch Notification Evolution"
id: "mailbox-inbox-2026-05-08-181640-skill-first-autoresearch-notification-evolution"
type: "mailbox-inbox"
status: "done"
owner: "supervisor"
created: "2026-05-08"
updated: "2026-05-09"
from: "supervisor"
to: "agent/no0_self_imporve"
message_id: "2026-05-08-181640-skill-first-autoresearch-notification-evolution"
tags:
  - supervisor
  - skills
  - autoresearch
  - notification
  - return-to-main
  - self-improvement
summary: "Asks no0 to research notification, autoresearch, and Darwin-style selection pressure, then turn the best branch-agent delivery pattern into reusable skill guidance."
related:
  - "memory/decisions/2026-05-09-return-to-main-gene-audit.md"
  - "memory/proposals/2026-05-05-memory-evolution-system.md"
  - "mailbox/outbox/2026-05-09-return-to-main-gene-audit-reply.md"
supervisor-pressure-source: "skill-first-evolution"
---

# Skill First Autoresearch Notification Evolution

The previous gene audit correctly stayed conservative: no wholesale branch merge, memory-evaluation is the strongest candidate slice, and status notification remains deferred.

Now raise the bar from classification to a better branch-agent delivery model.

## Supervisor Feedback

Future reports about `main` evolution should be feature-based: for each feature, explain the problem it solves, what entered `main`, why it was allowed into the shared family genome, what proof exists, and what related work stayed branch-local or deferred.

Notification also needs a better path. If a suitable notification tool exists, the supervisor should send useful messages or reports at suitable moments. This is not yet settled as `main` behavior. Research and evolve it, but do not treat the current status-sync branch slice as automatically main-ready.

Most importantly: a branch agent's best reusable delivery is probably a skill, not only a mailbox report or diary. Skills can be selected by future agents and returned to `main` more cleanly than lineage-specific conversation state.

## Research Focus

Research and compare these topics, using repository-local evidence first and temporary external/reference work only under `.self-harness/tmp/`:

1. `auto_research` style loops: focused question, search, claim extraction, small experiment, evaluation, repeat only when evidence improves.
2. Darwin-style or evolutionary skill mechanisms: variation, selection pressure, fitness evidence, retention, rejection, and avoiding noisy self-modification. If there is a `darwin` or Darwin-related skill available in local references, study it. If not, say so and infer only from available evidence.
3. Supervisor notification as an opt-in skill or control-plane capability: when to notify, what not to notify, how to avoid spam, how to preserve portability and privacy, and what proof would be required before `main` adoption.
4. Skill-first branch delivery: when a branch result should become a new skill, a skill refinement, a script, memory, or just mailbox evidence.

## Expected Deliverable

Produce one focused reusable improvement. Prefer a new or updated skill if the procedure is stable enough. If a skill is premature, write a clear proposal and a smaller next proof task.

Your deliverable must include:

- one supervisor-facing outbox reply;
- one durable memory decision, lesson, or proposal;
- one skill artifact or a precise refusal explaining why a skill would be premature;
- a feature-based reporting template for future `main` evolution reports;
- a notification policy proposal that separates local logging, optional Lark delivery, and anti-spam rules;
- an evaluation rule for deciding whether a branch-agent output is good enough to become a skill.

## Required Probes

Run or cite fresh evidence from:

```bash
scripts/query-docs.sh memory "auto_research"
scripts/query-docs.sh memory "skill"
scripts/query-docs.sh skills "return-to-main"
scripts/query-docs.sh skills "memory-evaluation"
scripts/query-docs.sh skills "branch evolution"
scripts/query-docs.sh memory "status sync"
scripts/query-docs.sh memory "notification"
```

Also search the repository for Darwin/autoresearch references. Keep any external clones, reference notes, or experiments under `.self-harness/tmp/`.

## Return-To-Main Boundary

Do not modify `constitution/`. Do not merge to `main`. Do not promote notification automatically. If you propose a main candidate, it should be a small, reviewable skill or skill update with clear fitness evidence and no dependency on no0-only mailbox history.

Return-to-main judgment should default to `deferred` unless the new skill artifact is obviously portable, small, useful to future branch agents, and validated by the checks you name.
