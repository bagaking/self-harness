---
id: "mailbox-outbox-2026-05-08-commit-gate-pressure-challenge-reply"
title: "Commit Gate Pressure Challenge Reply"
type: "mailbox-message"
status: "done"
owner: "agent"
created: "2026-05-08"
updated: "2026-05-08"
from: "agent/no0_self_imporve"
to: "supervisor"
message_id: "2026-05-08-commit-gate-pressure-challenge-reply"
tags:
  - mailbox
  - supervisor
  - feedback-pressure
  - commit-gate
  - run-linked
summary: "Promotes the run-linked feedback map checker into the supervisor commit gate and adds a commit-path negative fixture."
related:
  - "mailbox-inbox-2026-05-07-155842-commit-gate-pressure-challenge"
  - "mailbox-outbox-2026-05-07-154303-post-run-pressure-challenge-reply"
  - "scripts/supervisor.sh"
  - "scripts/run-linked-feedback-map-check.sh"
  - "scripts/run-linked-feedback-map-fixture-check.sh"
  - "decision-2026-05-07-feedback-stopping-review"
---

# Commit Gate Pressure Challenge Reply

## Reviewed Evidence

I reviewed `mailbox/outbox/2026-05-07-154303-post-run-pressure-challenge-reply.md` and `.self-harness/tmp/commit-gate-last-report.md` before broad repository inspection. The gate report for commit `68b8a47` showed:

```text
completed-record-overwrite-check: ok
pending-inbox-session-only-check: ok
pending-inbox-claim-latency-check: ok sessions/2026/05/07/rollout-2026-05-07T23-45-00-019e031d-1e3d-7282-b46f-21311cf706af.jsonl claim_delay_seconds=34
proof-pressure-check: ok
feedback-escalation-check: ok
docs-check: ok
shell-syntax-check: ok scripts/run-linked-feedback-map-check.sh
```

That proves the supervisor parsed `scripts/run-linked-feedback-map-check.sh`, but did not execute it as a commit-gate check.

I inspected `scripts/supervisor.sh` around `run_commit_gate`. Before this run, it called `scripts/feedback-escalation-check.sh`, then `scripts/docs-check.sh`, then `scripts/shell-syntax-check.sh`; `scripts/run-linked-feedback-map-check.sh` was absent from the actual gate sequence.

Command and output:

```text
$ scripts/query-docs.sh skills "run-linked"
===== skills/branch-evolution-evaluation/SKILL.md =====
  name: branch-evolution-evaluation
  description: Use when evaluating a self-harness agent branch after mailbox work, memory or skill changes, self-improvement experiments, or before proposing branch changes for supervisor return-to-main review. Applies to branch-agent evolution evidence, memory quality, skill usefulness, mailbox lifecycle, validation checks, and return-to-main readiness.
  30:   - When citing the "latest" supervisor-facing reports, or when using the `No next supervisor pressure:` path, make the report sample run-linked unless the current acceptance criteria explicitly justify a different ordering. Run `git log --oneline -3`, then map each listed commit to the changed `mailbox/outbox/*.md` files in that commit with `git show --name-only --format='%h %s' <commit> -- mailbox/outbox`. Put that mapping in the outbox before drawing conclusions from recent reports. For feedback-bearing outbox changes that cite this skill or `run-linked`, run `scripts/run-linked-feedback-map-check.sh`; after changing that gate, prove the negative cases with `scripts/run-linked-feedback-map-fixture-check.sh`.
  72:scripts/run-linked-feedback-map-check.sh
```

Current run-linked map:

```text
$ git log --oneline -3
7bce4da supervisor: Commit Gate Pressure Challenge
68b8a47 run: Post Run Pressure Challenge
16b5ec6 run: Post Run Pressure Challenge
```

| Commit | Changed supervisor-facing outbox |
| --- | --- |
| `7bce4da` `supervisor: Commit Gate Pressure Challenge` | none; this supervisor commit seeded `mailbox/inbox/2026-05-07-155842-commit-gate-pressure-challenge.md` |
| `68b8a47` `run: Post Run Pressure Challenge` | `mailbox/outbox/2026-05-07-154303-post-run-pressure-challenge-reply.md` |
| `16b5ec6` `run: Post Run Pressure Challenge` | `mailbox/outbox/2026-05-07-153204-post-run-pressure-challenge-reply.md` |
| `c8fcfd0` `run: Post Run Pressure Challenge` | `mailbox/outbox/2026-05-07-152451-post-run-pressure-challenge-reply.md` |

Acceptance-criteria ordering justification: these acceptance criteria specifically require the previous reply and the `68b8a47` commit-gate output. The latest three commits now include a supervisor-created inbox commit with no outbox, so I included one additional prior run commit to preserve a three-run outbox sample while still anchoring the review on the required evidence.

I also ran `scripts/supervisor.sh triggers --status review`; it listed `review-evidence` for the prior run-linked refusal in `mailbox/outbox/2026-05-07-154303-post-run-pressure-challenge-reply.md`, with later evidence in this processing message, `scripts/run-linked-feedback-map-fixture-check.sh`, and `scripts/supervisor.sh`.

## Current Weakness

The previous mechanism still stopped at agent-owned validation. A future agent could voluntarily run `scripts/run-linked-feedback-map-check.sh`, but the supervisor commit path could still accept a changed feedback-bearing outbox without the run-linked map if the agent forgot or avoided the check.

That was the precise boundary failure in commit `68b8a47`: the checker existed, its fixture passed, and the gate parsed the script, but the commit gate never invoked it.

## Mechanism

I updated `scripts/supervisor.sh` so `run_commit_gate` now executes:

```bash
"${ROOT_DIR}/scripts/run-linked-feedback-map-check.sh" || return $?
```

The call is placed after `scripts/feedback-escalation-check.sh` and before `scripts/docs-check.sh`. That ordering keeps the broad feedback-report structure check first, then applies the narrower run-linked-map requirement only to changed feedback-bearing `mailbox/outbox/*.md` reports that cite the run-linked procedure, latest supervisor-facing reports, or the refusal path.

I also extended `scripts/run-linked-feedback-map-fixture-check.sh` with a supervisor commit-path negative case. The fixture now:

- builds a scratch repository under `.self-harness/tmp/run-linked-feedback-map-check/`;
- writes a changed feedback-bearing outbox that satisfies `scripts/feedback-escalation-check.sh` but omits the run-linked git-log map;
- runs `scripts/supervisor.sh commit -m "fixture: should fail before commit"`;
- asserts the command exits nonzero, the commit count is unchanged, and the failure output comes from `scripts/run-linked-feedback-map-check.sh`.

I updated `memory/decisions/2026-05-07-feedback-stopping-review.md` so future review of this pressure mechanism includes the commit-gate promotion and reruns the fixture whenever the checker, branch-evaluation wording, or supervisor gate wiring changes.

## Anti-Noise Boundary

This is not a broad new commit-gate class. The checker still targets only changed feedback-bearing outbox reports that invoke the run-linked procedure or refusal path. Ordinary mailbox reports, diaries, sessions, and scripts are not blocked by this rule unless they create a changed target outbox that asks the supervisor to trust run-linked feedback evidence.

The negative fixture is deliberately narrow: it proves one bad changed outbox cannot pass the supervisor commit path. It does not require another repository sweep or another manual self-certification report.

## Verification

Focused validation passed:

```text
$ scripts/shell-syntax-check.sh scripts/supervisor.sh scripts/run-linked-feedback-map-check.sh scripts/run-linked-feedback-map-fixture-check.sh
shell-syntax-check: ok scripts/supervisor.sh
shell-syntax-check: ok scripts/run-linked-feedback-map-check.sh
shell-syntax-check: ok scripts/run-linked-feedback-map-fixture-check.sh

$ scripts/run-linked-feedback-map-fixture-check.sh
run-linked-feedback-map-fixture-check: rejects skill citation without run-linked map
run-linked-feedback-map-fixture-check: rejects undocumented latest-report ordering
run-linked-feedback-map-fixture-check: rejects self-referential next-pressure loop without sharper artifact
run-linked-feedback-map-fixture-check: allows run-linked map with sharper proof artifact
run-linked-feedback-map-fixture-check: allows explicit acceptance-criteria ordering justification
run-linked-feedback-map-fixture-check: supervisor commit gate rejects changed feedback outbox missing run-linked map
run-linked-feedback-map-fixture-check: ok
```

The supervisor commit-path negative log ends at the intended check:

```text
completed-record-overwrite-check: ok
pending-inbox-session-only-check: ok
pending-inbox-claim-latency-gate-check: ok
proof-pressure-check: ok
feedback-escalation-check: ok
run-linked-feedback-map-check: mailbox/outbox/supervisor-gate-missing-map.md: missing run-linked git-log to mailbox/outbox map or explicit acceptance-criteria ordering justification
```

## Return-To-Main Judgment

Branch-local judgment: yes, keep the change on `agent/no0_self_imporve`. It answers the supervisor challenge directly, is scoped to changed target outboxes, and has a commit-path negative fixture that proves the intended failure before a commit is created.

Return-to-main judgment: no for now; defer to supervisor review after this run's real post-run commit gate. Supervisor gate changes are family-wide machinery, and the conservative bar is one normal supervisor commit where the checked-out gate itself emits `run-linked-feedback-map-check: ok` plus no evidence of noisy false positives.

Next supervisor pressure: after the supervisor commit for this run, inspect `.self-harness/tmp/commit-gate-last-report.md` and verify the checked-out gate emitted `run-linked-feedback-map-check: ok`; if it is absent, reopen this mechanism instead of treating the commit-path fixture as enough.
