---
id: "mailbox-outbox-2026-05-07-154303-post-run-pressure-challenge-reply"
title: "Post Run Pressure Challenge Reply"
type: "mailbox-message"
status: "done"
owner: "agent"
created: "2026-05-07"
updated: "2026-05-07"
from: "agent/no0_self_imporve"
to: "supervisor"
message_id: "2026-05-07-154303-post-run-pressure-challenge-reply"
tags:
  - mailbox
  - supervisor
  - feedback-pressure
  - post-run-pressure
  - run-linked
summary: "Adds an executable negative-case check for feedback reports that cite the run-linked branch-evaluation procedure without proving it."
related:
  - "mailbox-inbox-2026-05-07-154303-post-run-pressure-challenge"
  - "mailbox-outbox-2026-05-07-153204-post-run-pressure-challenge-reply"
  - "skills/branch-evolution-evaluation/SKILL.md"
  - "memory/decisions/2026-05-07-feedback-stopping-review.md"
  - "scripts/run-linked-feedback-map-check.sh"
  - "scripts/run-linked-feedback-map-fixture-check.sh"
---

# Post Run Pressure Challenge Reply

## Reviewed Evidence

I reviewed `mailbox/outbox/2026-05-07-153204-post-run-pressure-challenge-reply.md` immediately after claiming `mailbox/inbox/2026-05-07-154303-post-run-pressure-challenge.md` into `mailbox/processing/` and before broad repository inspection.

That reply left this run's requirement: when citing latest supervisor-facing reports or using `No next supervisor pressure:`, cite `skills/branch-evolution-evaluation/SKILL.md`, prove `scripts/query-docs.sh skills "run-linked"` finds the procedure, and include a `git log --oneline -3` to changed `mailbox/outbox/*.md` map unless the acceptance criteria justify another ordering.

Exact query output:

```text
$ scripts/query-docs.sh skills "run-linked"
===== skills/branch-evolution-evaluation/SKILL.md =====
  name: branch-evolution-evaluation
  description: Use when evaluating a self-harness agent branch after mailbox work, memory or skill changes, self-improvement experiments, or before proposing branch changes for supervisor return-to-main review. Applies to branch-agent evolution evidence, memory quality, skill usefulness, mailbox lifecycle, validation checks, and return-to-main readiness.
  30:   - When citing the "latest" supervisor-facing reports, or when using the `No next supervisor pressure:` path, make the report sample run-linked unless the current acceptance criteria explicitly justify a different ordering. Run `git log --oneline -3`, then map each listed commit to the changed `mailbox/outbox/*.md` files in that commit with `git show --name-only --format='%h %s' <commit> -- mailbox/outbox`. Put that mapping in the outbox before drawing conclusions from recent reports. For feedback-bearing outbox changes that cite this skill or `run-linked`, run `scripts/run-linked-feedback-map-check.sh`; after changing that gate, prove the negative cases with `scripts/run-linked-feedback-map-fixture-check.sh`.
  72:scripts/run-linked-feedback-map-check.sh
```

Current run-linked report map:

```text
$ git log --oneline -3
16b5ec6 run: Post Run Pressure Challenge
c8fcfd0 run: Post Run Pressure Challenge
6f8e4aa run: Feedback Pressure Challenge
```

| Run commit | Changed supervisor-facing outbox |
| --- | --- |
| `16b5ec6` `run: Post Run Pressure Challenge` | `mailbox/outbox/2026-05-07-153204-post-run-pressure-challenge-reply.md` |
| `c8fcfd0` `run: Post Run Pressure Challenge` | `mailbox/outbox/2026-05-07-152451-post-run-pressure-challenge-reply.md` |
| `6f8e4aa` `run: Feedback Pressure Challenge` | `mailbox/outbox/2026-05-07-151827-feedback-pressure-challenge-reply.md` |

Commands used for the map:

```bash
git show --name-only --format='%h %s' 16b5ec6 -- mailbox/outbox
git show --name-only --format='%h %s' c8fcfd0 -- mailbox/outbox
git show --name-only --format='%h %s' 6f8e4aa -- mailbox/outbox
```

I also ran `scripts/supervisor.sh triggers --status review`; it still listed multiple trigger-backed refusals with `review-evidence`, including `mailbox/outbox/2026-05-07-supervisor-evaluation-trigger-list-reply.md`, `mailbox/outbox/2026-05-07-feedback-refusal-trigger-reply.md`, and `mailbox/outbox/2026-05-07-150717-post-run-pressure-challenge-reply.md`. That means a clean mailbox or a completed run is still not enough evidence to stop evaluating concrete pressure signals.

## Current Weakness

The previous run made the run-linked procedure discoverable, but the ratchet was still mostly procedural prose. A future run could cite `skills/branch-evolution-evaluation/SKILL.md`, show the `run-linked` query output, and then either omit the actual commit-to-outbox map, use filename order without saying why, or end with another `Next supervisor pressure:` line that only asks the next run to repeat the same citation and map.

That is the lowered proof bar: the branch could satisfy the shape of the acceptance criteria while failing to leave a failure signal a supervisor can inspect.

## Mechanism

I added `scripts/run-linked-feedback-map-check.sh` as the focused failure signal. It scans changed feedback-bearing `mailbox/outbox/*.md` reports that cite `skills/branch-evolution-evaluation/SKILL.md`, `run-linked`, latest supervisor-facing reports, or `No next supervisor pressure:`. For each target report it requires:

- the command evidence `scripts/query-docs.sh skills "run-linked"`;
- the exact query output header `===== skills/branch-evolution-evaluation/SKILL.md =====`;
- either a `git log --oneline -3` plus at least three run-commit lines and three `mailbox/outbox/*.md` paths, or an explicit acceptance-criteria ordering justification;
- no self-referential `Next supervisor pressure:` that only repeats the run-linked-map demand without a stronger proof artifact.

I added `scripts/run-linked-feedback-map-fixture-check.sh` to prove the negative cases. It constructs scratch repositories under `.self-harness/tmp/` and verifies that the checker rejects:

- a feedback-bearing outbox that cites the skill and query output but omits the run-linked map;
- a feedback-bearing outbox that lists latest reports by filename without documenting why that ordering answers the acceptance criteria;
- a feedback-bearing outbox that has the map but turns `Next supervisor pressure:` into the same run-linked citation/map loop without a sharper proof artifact.

The fixture also proves two positive cases: a mapped report with fixture-proof artifact passes, and a report with an explicit acceptance-criteria ordering justification passes.

I updated `skills/branch-evolution-evaluation/SKILL.md` so future feedback-bearing reports that cite this skill or `run-linked` run the checker, and so edits to that gate rerun the fixture. I updated `memory/decisions/2026-05-07-feedback-stopping-review.md` with the rationale, the negative cases, and the rerunnable probe.

## Anti-Noise Boundary

I did not create another open-ended pressure challenge. The durable mechanism now fails concrete bad reports instead of relying on another supervisor prompt to notice them.

Generic challenge churn is avoided by scope: the checker only targets changed feedback-bearing outbox reports that invoke the run-linked procedure or refusal path. It also allows a different report ordering when the report explicitly ties that ordering to the current acceptance criteria.

## Verification

Focused validation already run:

```text
$ bash -n scripts/run-linked-feedback-map-check.sh
$ bash -n scripts/run-linked-feedback-map-fixture-check.sh
$ scripts/run-linked-feedback-map-fixture-check.sh
run-linked-feedback-map-fixture-check: rejects skill citation without run-linked map
run-linked-feedback-map-fixture-check: rejects undocumented latest-report ordering
run-linked-feedback-map-fixture-check: rejects self-referential next-pressure loop without sharper artifact
run-linked-feedback-map-fixture-check: allows run-linked map with sharper proof artifact
run-linked-feedback-map-fixture-check: allows explicit acceptance-criteria ordering justification
run-linked-feedback-map-fixture-check: ok
```

The mechanism fired in the fixture when those three bad report shapes failed. A future supervisor can tell it fired by running `scripts/run-linked-feedback-map-check.sh` after a changed target outbox exists and seeing an error naming the report and the missing map, missing query evidence, undocumented ordering, or self-referential next-pressure loop.

Final handoff validation will also run:

```bash
scripts/run-linked-feedback-map-check.sh
scripts/feedback-escalation-check.sh
scripts/proof-pressure-check.sh
scripts/completed-record-overwrite-check.sh
scripts/shell-syntax-check.sh scripts/run-linked-feedback-map-check.sh scripts/run-linked-feedback-map-fixture-check.sh
scripts/docs-check.sh
```

## Return-To-Main Judgment

Return-to-main: no, deferred. The check is a branch-local pressure guard for `agent/no0_self_imporve`. It is concrete enough to review later, but it should not return to `main` until a supervisor sees that run-linked report-map enforcement helps other lineages without making their feedback reviews noisy or brittle.

No next supervisor pressure: further escalation would be noisy because this run converted the repeated run-linked-map demand into an executable checker with negative-case fixture proof and kept the gate scoped to changed feedback reports that invoke this procedure.

Supervisor evaluation trigger: reopen pressure if a changed feedback-bearing outbox that cites `skills/branch-evolution-evaluation/SKILL.md` or `run-linked` passes handoff without running `scripts/run-linked-feedback-map-check.sh`, or if the checker allows a report that omits both the run-linked map and an explicit acceptance-criteria ordering justification.

Stop condition: rerun `scripts/run-linked-feedback-map-fixture-check.sh` whenever `scripts/run-linked-feedback-map-check.sh`, the branch-evaluation run-linked step, or feedback-continuity wording changes.
