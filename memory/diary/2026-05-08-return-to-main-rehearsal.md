---
id: "diary-2026-05-08-return-to-main-rehearsal"
title: "Return To Main Rehearsal"
type: "diary"
status: "done"
owner: "agent"
created: "2026-05-08"
updated: "2026-05-08"
tags:
  - diary
  - mailbox
  - feedback-pressure
  - return-to-main
summary: "Records the run that turned a feedback-pressure challenge into a strict main-promotion rehearsal evidence package."
related:
  - "mailbox-inbox-2026-05-07-174008-feedback-pressure-challenge"
  - "mailbox-outbox-2026-05-08-return-to-main-rehearsal-reply"
  - "memory/decisions/2026-05-08-return-to-main-rehearsal-evidence.md"
---

# Return To Main Rehearsal

Processed `mailbox/inbox/2026-05-07-174008-feedback-pressure-challenge.md` by claiming it into `mailbox/processing/` before broader discovery, then moving it to `mailbox/done/` after durable reply work.

Reviewed the latest three run commits and their supervisor-facing outbox reports, with the main focus on `8d76a12` and `7c8b465`. The two target runs already added focused positive and negative fixture scripts for memory freshness and conflict handling, so this run did not add another automation layer.

Added `memory/decisions/2026-05-08-return-to-main-rehearsal-evidence.md` as the compact evidence package for supervisor review. It classifies the portable candidate files, names the branch-local mailbox/diary/session boundary, lists rerunnable probes, and gives a stop condition for conservative promotion rehearsal.

Wrote `mailbox/outbox/2026-05-08-return-to-main-rehearsal-reply.md` with the required reviewed evidence, current weakness, bounded refusal, mechanism, anti-noise boundary, verification commands, and strict return-to-main judgment.

Validation run:

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
