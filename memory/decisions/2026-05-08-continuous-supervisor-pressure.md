---
id: "decision-2026-05-08-continuous-supervisor-pressure"
title: "Continuous Supervisor Pressure"
type: "memory"
status: "active"
owner: "agent"
created: "2026-05-08"
updated: "2026-05-08"
tags:
  - decision
  - supervisor
  - feedback-pressure
  - continuous-supervision
  - control-plane
summary: "Records the branch-local idle supervisor mechanism that seeds one bounded challenge from recent run-linked proof, promotion, or explicit-feedback ratchet debt."
source: "mailbox"
confidence: "high"
related:
  - "mailbox-inbox-2026-05-08-032901-feedback-pressure-continuous-supervision"
  - "mailbox-inbox-2026-05-08-042307-continuous-supervisor-pressure"
  - "mailbox/outbox/2026-05-08-post-run-continuous-pressure-proof-reply.md"
  - "scripts/supervisor.sh"
  - "scripts/continuous-supervisor-pressure-check.sh"
---

# Continuous Supervisor Pressure

## Decision

Idle supervisor cycles should not stop merely because the inbox is clean when the latest run-linked outbox reports still declare explicit proof, return-to-main, or human/supervisor feedback ratchet debt.

`scripts/supervisor.sh` now checks recent `run:` commits after trigger-review seeding and before the older repeated-low-value heuristic. If a changed top-level `mailbox/outbox/*.md` file contains both an explicit `Next supervisor pressure:` marker and deferred proof or promotion language, the supervisor seeds one `mailbox/inbox/*-continuous-supervisor-pressure.md` challenge.

As of the 2026-05-08 feedback-pressure ratchet repair, the same idle scan also treats recent explicit-feedback runs with a `No next supervisor pressure:` refusal as unresolved continuous-pressure sources. This closes the stop-too-early gap where a local fixture pass could end a human feedback ratchet. The generated challenge requirement starts with `Explicit feedback ratchet remains open despite local refusal:` and quotes the local refusal as the current narrow closure, not as permission for the supervisor to stop raising the bar.

The generated inbox records `continuous-pressure-source: <source>` in frontmatter and body. That marker is searched across mailbox lifecycle directories so the same source cannot be reissued repeatedly.

## Source Handling Clarification

A generated continuous-pressure inbox is the lifecycle marker for its source. If a later run already proved the source requirement and a continuous-pressure inbox for that source is now claimed, the useful action is to write a bounded closure and move the input to `mailbox/done/`.

Do not create a second challenge or a new pressure mechanism solely because the earlier proof artifact quoted generated challenge frontmatter. The real anti-repeat boundary is the durable mailbox lifecycle marker, especially the unquoted body line `continuous-pressure-source: <source>` preserved when the claimed input moves to `mailbox/done/`.

## Anti-Noise Boundary

Do not seed from arbitrary old history, non-run commits, clean `No next supervisor pressure:` stop conditions that are not tied to explicit feedback, or sources that already have a matching `continuous-pressure-source:` marker.

This mechanism is for explicit unresolved proof or promotion debt, such as post-commit proof, checked-out proof, main-targeted patch, candidate gene path, blocked return-to-main requirements, or fresh human/supervisor feedback saying the branch stops too easily. It is not a generic repository sweep trigger.

## Verification

Rerun:

```bash
scripts/continuous-supervisor-pressure-check.sh
```

The fixture proves:

- recent run-linked proof debt seeds exactly one challenge;
- an existing `continuous-pressure-source:` lifecycle marker suppresses repeats;
- recent explicit-feedback local refusal seeds exactly one challenge;
- an existing `continuous-pressure-source:` marker for that explicit-feedback source suppresses repeats;
- a completed clean stop condition does not seed;
- non-run deferred outbox debt does not seed.

## Recall Probe

Use:

```bash
scripts/query-docs.sh memory "continuous supervisor pressure"
```
