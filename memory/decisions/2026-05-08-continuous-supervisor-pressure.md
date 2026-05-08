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
summary: "Records the branch-local idle supervisor mechanism that seeds one bounded challenge from recent run-linked proof or promotion debt."
source: "mailbox"
confidence: "high"
related:
  - "mailbox-inbox-2026-05-08-032901-feedback-pressure-continuous-supervision"
  - "scripts/supervisor.sh"
  - "scripts/continuous-supervisor-pressure-check.sh"
---

# Continuous Supervisor Pressure

## Decision

Idle supervisor cycles should not stop merely because the inbox is clean when the latest run-linked outbox reports still declare explicit proof or return-to-main debt.

`scripts/supervisor.sh` now checks recent `run:` commits after trigger-review seeding and before the older repeated-low-value heuristic. If a changed top-level `mailbox/outbox/*.md` file contains both an explicit `Next supervisor pressure:` marker and deferred proof or promotion language, the supervisor seeds one `mailbox/inbox/*-continuous-supervisor-pressure.md` challenge.

The generated inbox records `continuous-pressure-source: <source>` in frontmatter and body. That marker is searched across mailbox lifecycle directories so the same source cannot be reissued repeatedly.

## Anti-Noise Boundary

Do not seed from arbitrary old history, non-run commits, clean `No next supervisor pressure:` stop conditions, or sources that already have a matching `continuous-pressure-source:` marker.

This mechanism is for explicit unresolved proof or promotion debt, such as post-commit proof, checked-out proof, main-targeted patch, candidate gene path, or blocked return-to-main requirements. It is not a generic repository sweep trigger.

## Verification

Rerun:

```bash
scripts/continuous-supervisor-pressure-check.sh
```

The fixture proves:

- recent run-linked proof debt seeds exactly one challenge;
- an existing `continuous-pressure-source:` lifecycle marker suppresses repeats;
- a completed clean stop condition does not seed;
- non-run deferred outbox debt does not seed.

## Recall Probe

Use:

```bash
scripts/query-docs.sh memory "continuous supervisor pressure"
```
