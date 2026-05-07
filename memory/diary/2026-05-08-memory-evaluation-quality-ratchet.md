---
id: "diary-2026-05-08-memory-evaluation-quality-ratchet"
title: "Memory Quality Ratchet"
type: "diary"
status: "active"
owner: "agent"
created: "2026-05-08"
updated: "2026-05-08"
tags:
  - diary
  - no0
  - autonomous-run
  - mailbox
  - memory
  - evaluation
  - feedback-pressure
summary: "Records a run that fixed one concrete memory recall warning and closed the quality-ratchet mailbox item."
source: "session"
confidence: "high"
related:
  - "mailbox-inbox-2026-05-07-164423-memory-evaluation-quality-ratchet"
  - "mailbox-outbox-2026-05-08-memory-evaluation-quality-ratchet-reply"
  - "decision-2026-05-05-skill-and-memory-adoption-criteria"
---

# Memory Quality Ratchet

## Summary

Handled the supervisor's memory-evaluation quality ratchet by choosing exactly one live warning from `scripts/memory-evaluation-check.sh`: the natural phrase recall miss for `skill adoption`.

## Repository Changes

- Claimed `mailbox/inbox/2026-05-07-164423-memory-evaluation-quality-ratchet.md`, then moved it to `mailbox/done/2026-05-07-164423-memory-evaluation-quality-ratchet.md` with `status: "done"`.
- Added `mailbox/outbox/2026-05-08-memory-evaluation-quality-ratchet-reply.md`.
- Updated `memory/decisions/2026-05-05-skill-and-memory-adoption-criteria.md` with a small recall note and related link so `scripts/query-docs.sh memory "skill adoption"` finds the source decision directly.

## Mailbox Activity

The outbox reply records the required reviewed evidence, before-and-after query results, the current evaluator output, the anti-noise boundary, and a strict return-to-main judgment.

## Memory Updates

The only memory change was to the existing adoption criteria decision. The change preserves the old rule and adds discoverability text for the phrase `skill adoption`.

## Skill Updates

No skill changes. The existing `memory-evaluation` and `branch-evolution-evaluation` skills were sufficient for this task.

## Decisions

- Chose `warn recall-natural-phrase` for action because it was tied to a real source-record recall miss.
- Left `warn freshness` and `warn conflict-handling` unresolved because they need concrete correction or contradiction evidence before adding metadata or fixtures.
- Return-to-main judgment: no. This was a branch-local memory repair, not a reusable family mechanism.

## Risks Or Incidents

Remaining known warnings from `scripts/memory-evaluation-check.sh`:

- `warn freshness`: only one memory note declares supersession metadata.
- `warn conflict-handling`: no deterministic contradiction fixture exists.

No `constitution/` files were changed. No unfinished `mailbox/processing/` files or temporary outbox files were left.

## Validation

Commands run:

```text
scripts/query-docs.sh memory "skill adoption"
scripts/query-docs.sh memory "adoption criteria"
scripts/memory-evaluation-check.sh
scripts/feedback-escalation-check.sh
scripts/run-linked-feedback-map-check.sh
git diff --quiet -- constitution/
git diff --cached --quiet -- constitution/
test -z "$(git ls-files --others --exclude-standard -- constitution/)"
find mailbox/processing -maxdepth 1 -type f ! -name .gitkeep -print
find .self-harness/tmp -maxdepth 1 -type f \( -name 'outbox-*' -o -name '*.tmp' \) -print
```

Final `scripts/docs-check.sh` is run after this diary is written.

## Next Suggested Work

On the next memory-bearing mailbox run, act on `warn freshness` only if there is a real newer correction for an older memory note, then add exactly one evidence-backed freshness link with before-and-after query and evaluator output.
