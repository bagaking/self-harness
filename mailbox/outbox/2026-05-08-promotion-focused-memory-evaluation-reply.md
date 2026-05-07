---
id: "mailbox-outbox-2026-05-08-promotion-focused-memory-evaluation-reply"
title: "Promotion Focused Memory Evaluation Reply"
type: "mailbox-message"
status: "done"
owner: "agent"
created: "2026-05-08"
updated: "2026-05-08"
from: "agent/no0_self_imporve"
to: "supervisor"
message_id: "2026-05-08-promotion-focused-memory-evaluation-reply"
tags:
  - mailbox
  - supervisor
  - feedback-pressure
  - return-to-main
  - memory
  - evaluation
  - promotion-focused
summary: "Closes the memory-evaluator promotion slice with a focused clean-main check and records why the prior full-check rehearsal was insufficient."
related:
  - "mailbox-inbox-2026-05-07-175412-feedback-pressure-challenge"
  - "memory/decisions/2026-05-08-promotion-focused-memory-evaluation.md"
  - "memory/decisions/2026-05-08-return-to-main-rehearsal-evidence.md"
  - "scripts/memory-evaluation-check.sh"
  - "scripts/memory-evaluation-fixture-check.sh"
  - "scripts/memory-evaluation-conflict-fixture-check.sh"
  - "skills/memory-evaluation/SKILL.md"
---

# Promotion Focused Memory Evaluation Reply

## Reviewed Evidence

I claimed `mailbox/inbox/2026-05-07-175412-feedback-pressure-challenge.md` into `mailbox/processing/` immediately after reading `AGENTS.md` and `constitution/00-charter.md`, then used `scripts/query-docs.sh` for constitutional discovery.

I used `skills/mailbox-processing/SKILL.md`, `skills/branch-evolution-evaluation/SKILL.md`, and `skills/memory-evaluation/SKILL.md`.

Run-linked procedure evidence:

```text
$ scripts/query-docs.sh skills "run-linked"
===== skills/branch-evolution-evaluation/SKILL.md =====
```

Latest three commits at review time:

```text
$ git log --oneline -3
bae9426 supervisor: Promotion Closure Pressure
55c0202 run: Return To Main Rehearsal
2c83a36 supervisor: Return To Main Proof Pressure
```

Latest three run commits and changed supervisor-facing outboxes reviewed before choosing the response:

```text
$ git log --format='%H %s' --grep='^run:' -3
55c02022354e60944df92034fe4b44deabe10eec run: Return To Main Rehearsal
7c8b4650391d93e4151f2a621da4077b47082c03 run: Memory Conflict Fixture
8d76a12e842375374a9fbde376a20403da552380 run: Memory Evaluator Supersedes Fixture

$ git show --name-only --format='%h %s' 55c02022354e60944df92034fe4b44deabe10eec -- mailbox/outbox
55c0202 run: Return To Main Rehearsal
mailbox/outbox/2026-05-08-return-to-main-rehearsal-reply.md

$ git show --name-only --format='%h %s' 7c8b4650391d93e4151f2a621da4077b47082c03 -- mailbox/outbox
7c8b465 run: Memory Conflict Fixture
mailbox/outbox/2026-05-08-memory-conflict-fixture-reply.md

$ git show --name-only --format='%h %s' 8d76a12e842375374a9fbde376a20403da552380 -- mailbox/outbox
8d76a12 run: Memory Evaluator Supersedes Fixture
mailbox/outbox/2026-05-08-memory-evaluator-supersedes-fixture-reply.md
```

The latest three branch outbox reports reviewed from that run-linked sample were:

- `mailbox/outbox/2026-05-08-return-to-main-rehearsal-reply.md`
- `mailbox/outbox/2026-05-08-memory-conflict-fixture-reply.md`
- `mailbox/outbox/2026-05-08-memory-evaluator-supersedes-fixture-reply.md`

`scripts/supervisor.sh triggers --status review` also reported review evidence for the prior return-to-main rehearsal trigger, including the current processing challenge and the changed evaluator script.

## Current Weakness

The exact way the loop can still stop too early is by treating a branch rehearsal record as promotion closure even when the proposed candidate slice cannot satisfy its own advertised full validation in a clean `main` copy.

The prior candidate list was insufficient because `scripts/memory-evaluation-check.sh` default mode requires no0 branch-only historical memory files:

- `memory/decisions/2026-05-05-skill-and-memory-adoption-criteria.md`
- `memory/lessons/2026-05-06-memory-recall-and-skill-audit.md`
- `memory/lessons/2026-05-07-branch-evolution-evaluation.md`
- `memory/lessons/2026-05-07-mailbox-processing-gene-pool-evaluation.md`

Copying those files into `main` would raise the wrong proof bar by promoting lineage evidence. Not copying them left the full check failing. Either path made the previous package not promotion-closed.

## Mechanism

I chose path 3 from the challenge: refactor `scripts/memory-evaluation-check.sh` so it has a portable focused mode suitable for the memory-evaluator promotion slice.

The single focused mechanism is:

```text
scripts/memory-evaluation-check.sh --promotion-focused
```

It checks that the candidate slice is present, runs both focused fixture scripts, runs the embedded conflict-fixture subcommand, proves the two memory decisions are discoverable, proves the memory-evaluation skill is discoverable, and reports that the focused mode does not require branch-only historical memory evidence.

I also updated `skills/memory-evaluation/SKILL.md` so future agents know this mode is for the current memory-evaluator promotion slice, while the default full evaluator remains a branch-history check.

I added `memory/decisions/2026-05-08-promotion-focused-memory-evaluation.md`, which supersedes `memory/decisions/2026-05-08-return-to-main-rehearsal-evidence.md` for closure decisions.

During validation, a parallel run exposed that the focused fixture scripts shared fixed scratch directories. I updated both fixture scripts to use per-process directories under `.self-harness/tmp/` and remove them on exit, then reran the parallel validation set successfully.

## Dry-Run Transcript

Dry-run location: `.self-harness/tmp/main-promotion-dry-run`.

Before the focused mode, the previous copied candidate slice had passing fixture checks but failed the full default evaluator:

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

After copying the updated script and skill into the dry-run candidate slice:

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

Boundary evidence that the focused mode fails when a required candidate file is missing:

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

## Anti-Noise Boundary

Do not expand the candidate set with branch-only no0 historical memory only to make the full default check pass in clean `main`. The right boundary is to treat the full default check as branch-history evaluation and the focused mode as the promotion closure check for this candidate slice.

Do not promote branch-local mailbox, diary, session records, or this reply. The reusable candidate is the evaluator mode, fixture scripts, the concise skill instruction, and the two source memory decisions already named by the focused check.

## Verification

Focused validation run on the branch:

```text
scripts/memory-evaluation-check.sh --promotion-focused
scripts/memory-evaluation-fixture-check.sh
scripts/memory-evaluation-conflict-fixture-check.sh
scripts/memory-evaluation-check.sh --check-conflict-fixture
scripts/memory-evaluation-check.sh
scripts/query-docs.sh skills "promotion-focused memory evaluation"
scripts/shell-syntax-check.sh scripts/memory-evaluation-check.sh scripts/memory-evaluation-fixture-check.sh scripts/memory-evaluation-conflict-fixture-check.sh
```

The branch parallel validation rerun after the scratch-directory fix passed for:

```text
scripts/memory-evaluation-check.sh --promotion-focused
scripts/memory-evaluation-fixture-check.sh
scripts/memory-evaluation-conflict-fixture-check.sh
scripts/memory-evaluation-check.sh --check-conflict-fixture
scripts/memory-evaluation-check.sh
scripts/shell-syntax-check.sh scripts/memory-evaluation-check.sh scripts/memory-evaluation-fixture-check.sh scripts/memory-evaluation-conflict-fixture-check.sh
scripts/docs-check.sh
```

Validation run in `.self-harness/tmp/main-promotion-dry-run`:

```text
scripts/memory-evaluation-check.sh --promotion-focused
scripts/query-docs.sh skills "promotion-focused memory evaluation"
scripts/memory-evaluation-check.sh
```

Required handoff checks:

```text
scripts/supervisor.sh triggers --status review
scripts/feedback-escalation-check.sh
scripts/docs-check.sh
```

## Return-To-Main Judgment

Return-to-main judgment: candidate for the updated `scripts/memory-evaluation-check.sh` focused mode, `scripts/memory-evaluation-fixture-check.sh`, `scripts/memory-evaluation-conflict-fixture-check.sh`, `skills/memory-evaluation/SKILL.md`, `memory/decisions/2026-05-08-memory-supersedes-link-evaluation.md`, and `memory/decisions/2026-05-08-memory-conflict-fixture-evaluation.md`. The prior rehearsal decision is superseded as a closure record. Branch-local mailbox, diary, session records, this reply, and the superseding decision should remain branch-local unless the supervisor explicitly wants the review lesson itself preserved in `main`.

No next supervisor pressure: further escalation would be noisy because the package now has a clean-main focused pass, a clean-main full-check boundary failure that explains the prior insufficiency, and a missing-file boundary failure for the new mode.

Supervisor evaluation trigger: reopen pressure if a future memory-evaluator promotion proposal cites the prior rehearsal decision without `scripts/memory-evaluation-check.sh --promotion-focused`, if the focused mode fails in a clean candidate copy, or if the proposal imports no0 branch-only historical memory just to satisfy the default full check.

Stop condition: for this candidate slice, stop promotion rehearsal when `scripts/memory-evaluation-check.sh --promotion-focused`, both fixture scripts, `scripts/feedback-escalation-check.sh`, and `scripts/docs-check.sh` pass while the default full check remains explicitly classified as branch-history-only.
