---
id: "decision-2026-05-08-promotion-focused-memory-evaluation"
title: "Promotion Focused Memory Evaluation"
type: "memory"
status: "active"
owner: "agent"
created: "2026-05-08"
updated: "2026-05-08"
tags:
  - decision
  - memory
  - evaluation
  - return-to-main
  - promotion-focused
  - validation
  - feedback-pressure
summary: "Supersedes the incomplete return-to-main rehearsal by requiring a focused promotion mode for the memory-evaluator candidate slice."
source: "mailbox"
confidence: "high"
related:
  - "mailbox-inbox-2026-05-07-175412-feedback-pressure-challenge"
  - "mailbox-outbox-2026-05-08-promotion-focused-memory-evaluation-reply"
  - "decision-2026-05-08-return-to-main-rehearsal-evidence"
  - "scripts/memory-evaluation-check.sh"
  - "scripts/memory-evaluation-fixture-check.sh"
  - "scripts/memory-evaluation-conflict-fixture-check.sh"
  - "skills/memory-evaluation/SKILL.md"
supersedes:
  - "decision-2026-05-08-return-to-main-rehearsal-evidence"
---

# Promotion Focused Memory Evaluation

## Decision

The earlier return-to-main rehearsal evidence is not a closed promotion package by itself. It named the right reusable memory-evaluator candidates, but it still asked reviewers to run the default full `scripts/memory-evaluation-check.sh` in a clean `main` promotion copy. That full mode intentionally depends on no0 branch historical memory records, so it fails when only the listed candidate slice is copied.

For this memory-evaluator promotion slice, use:

```text
scripts/memory-evaluation-check.sh --promotion-focused
```

The default full `scripts/memory-evaluation-check.sh` remains a branch-history evaluation and is explicitly deferred in a clean `main` dry-run unless the supervisor chooses to promote the broader historical evidence set.

## Closed Candidate Slice

The focused promotion slice is:

- `scripts/memory-evaluation-check.sh`
- `scripts/memory-evaluation-fixture-check.sh`
- `scripts/memory-evaluation-conflict-fixture-check.sh`
- `skills/memory-evaluation/SKILL.md`
- `memory/decisions/2026-05-08-memory-supersedes-link-evaluation.md`
- `memory/decisions/2026-05-08-memory-conflict-fixture-evaluation.md`

This superseding decision is review evidence for this branch. It is not required inside the focused `main` candidate slice unless the supervisor wants to preserve the promotion-closure lesson itself.

## Dry-Run Evidence

Dry-run location: `.self-harness/tmp/main-promotion-dry-run`.

Before the focused mode, the copied candidate slice had positive fixture proof but failed the full default evaluator:

```text
$ scripts/memory-evaluation-fixture-check.sh
memory-evaluation-fixture-check: empty-supersedes-list: 0 supersedes links
memory-evaluation-fixture-check: body-supersedes-snippet: 0 supersedes links
memory-evaluation-fixture-check: non-empty-supersedes-list: 1 supersedes links
memory-evaluation-fixture-check: combined: 1 supersedes links
memory-evaluation-fixture-check: ok
$ scripts/memory-evaluation-conflict-fixture-check.sh
memory-evaluation-conflict-fixture-check: reciprocal-contradiction: 1 contradiction fixtures
memory-evaluation-conflict-fixture-check: same-value: 0 contradiction fixtures
memory-evaluation-conflict-fixture-check: one-sided-link: 0 contradiction fixtures
memory-evaluation-conflict-fixture-check: unrelated-subject: 0 contradiction fixtures
memory-evaluation-conflict-fixture-check: combined: 1 contradiction fixtures
memory-evaluation-conflict-fixture-check: ok
$ scripts/memory-evaluation-check.sh --check-conflict-fixture
memory-evaluation-check: conflict fixture ok
$ scripts/memory-evaluation-check.sh
fail traceability: missing required evidence memory/decisions/2026-05-05-skill-and-memory-adoption-criteria.md
fail traceability: missing required evidence memory/lessons/2026-05-06-memory-recall-and-skill-audit.md
fail traceability: missing required evidence memory/lessons/2026-05-07-branch-evolution-evaluation.md
fail traceability: missing required evidence memory/lessons/2026-05-07-mailbox-processing-gene-pool-evaluation.md
full_check_status=1
```

After the focused mode and skill guidance were copied into the dry-run, the focused promotion check passed while the full branch-history check still failed for the expected historical-evidence reason:

```text
$ scripts/memory-evaluation-check.sh --promotion-focused
pass promotion-file: scripts/memory-evaluation-check.sh exists
pass promotion-file: scripts/memory-evaluation-fixture-check.sh exists
pass promotion-file: scripts/memory-evaluation-conflict-fixture-check.sh exists
pass promotion-file: skills/memory-evaluation/SKILL.md exists
pass promotion-file: memory/decisions/2026-05-08-memory-supersedes-link-evaluation.md exists
pass promotion-file: memory/decisions/2026-05-08-memory-conflict-fixture-evaluation.md exists
pass promotion-freshness-fixture: supersedes fixture command passes
pass promotion-conflict-fixture: conflict fixture command passes
pass promotion-conflict-subcommand: embedded conflict fixture subcommand passes
pass promotion-recall: supersedes decision is discoverable
pass promotion-recall: conflict decision is discoverable
pass promotion-skill-recall: memory-evaluation skill is discoverable
pass promotion-skill-recall: promotion-focused memory evaluation guidance is discoverable
pass promotion-scope: focused mode does not require branch-only historical memory evidence
promotion_focused_status=0
$ scripts/query-docs.sh skills "promotion-focused memory evaluation"
===== skills/memory-evaluation/SKILL.md =====
  18:   - For promotion-focused memory evaluation review, run `scripts/memory-evaluation-check.sh --promotion-focused` on the candidate slice. Use the default full check only for branch-history evaluation because it intentionally requires no0 historical memory evidence.
$ scripts/memory-evaluation-check.sh
fail traceability: missing required evidence memory/decisions/2026-05-05-skill-and-memory-adoption-criteria.md
fail traceability: missing required evidence memory/lessons/2026-05-06-memory-recall-and-skill-audit.md
fail traceability: missing required evidence memory/lessons/2026-05-07-branch-evolution-evaluation.md
fail traceability: missing required evidence memory/lessons/2026-05-07-mailbox-processing-gene-pool-evaluation.md
full_check_status=1
```

Boundary proof: temporarily removing `skills/memory-evaluation/SKILL.md` from the dry-run candidate slice made the focused mode fail:

```text
$ mv skills/memory-evaluation/SKILL.md skills/memory-evaluation/SKILL.md.promotion-focused-backup
$ scripts/memory-evaluation-check.sh --promotion-focused
pass promotion-file: scripts/memory-evaluation-check.sh exists
pass promotion-file: scripts/memory-evaluation-fixture-check.sh exists
pass promotion-file: scripts/memory-evaluation-conflict-fixture-check.sh exists
fail promotion-file: missing skills/memory-evaluation/SKILL.md
pass promotion-file: memory/decisions/2026-05-08-memory-supersedes-link-evaluation.md exists
pass promotion-file: memory/decisions/2026-05-08-memory-conflict-fixture-evaluation.md exists
missing_skill_status=1
$ mv skills/memory-evaluation/SKILL.md.promotion-focused-backup skills/memory-evaluation/SKILL.md
```

## Boundary

Do not expand the candidate set with branch-only no0 historical memory only to make the full default evaluator pass in `main`. That would promote lineage evidence instead of the reusable evaluator mechanism.

Do not cite `memory/decisions/2026-05-08-return-to-main-rehearsal-evidence.md` as a closed promotion package unless the focused mode above passes in a clean promotion copy.

The focused fixture scripts now use per-process scratch directories under `.self-harness/tmp/` and clean them on exit. A parallel validation run exposed that fixed scratch directories could make the conflict fixture see a partially rewritten corpus from another evaluator process. The fix keeps parallel promotion validation from lowering the proof bar through test interference.

## Return-To-Main Judgment

Return-to-main judgment: candidate for the updated `scripts/memory-evaluation-check.sh` focused mode, the focused fixture scripts, the memory-evaluation skill guidance, and the two source memory decisions listed in the closed candidate slice. The previous rehearsal decision is superseded as a closure record. Branch-local mailbox, diary, session records, and this superseding decision should remain branch-local unless the supervisor explicitly wants the review lesson itself in `main`.
