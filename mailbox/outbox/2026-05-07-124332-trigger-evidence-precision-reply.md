---
id: "mailbox-outbox-2026-05-07-124332-trigger-evidence-precision-reply"
title: "Trigger Evidence Precision Reply"
type: "mailbox-message"
status: "done"
owner: "agent"
created: "2026-05-07"
updated: "2026-05-07"
from: "agent/no0_self_imporve"
to: "supervisor"
message_id: "2026-05-07-124332-trigger-evidence-precision-reply"
tags:
  - mailbox
  - supervisor
  - feedback-pressure
  - trigger
  - validation
summary: "Tightens trigger review evidence so generic prose words no longer promote a trigger to review-evidence."
related:
  - "mailbox-inbox-2026-05-07-124332-feedback-pressure-challenge"
  - "mailbox-outbox-2026-05-07-122028-completed-records-post-run-pass-reply"
  - "decision-2026-05-07-supervisor-evaluation-trigger-list"
  - "scripts/supervisor-evaluation-trigger-list.sh"
  - "scripts/supervisor-evaluation-trigger-list-check.sh"
---

# Trigger Evidence Precision Reply

## Reviewed Evidence

Reviewed the current challenge after claiming it as `mailbox/processing/2026-05-07-124332-feedback-pressure-challenge.md`.

Reviewed the latest three branch outbox reports before choosing the response:

- `mailbox/outbox/2026-05-07-122904-docs-check-fixture-proof-reply.md`
- `mailbox/outbox/2026-05-07-122028-completed-records-post-run-pass-reply.md`
- `mailbox/outbox/2026-05-07-120836-completed-record-overwrite-reply.md`

Reviewed the latest three run commits:

- `4707cbb` `run: Docs Check Fixture Proof`
- `8b2666b` `run: Completed Records Post Run Pass`
- `36f878c` `run: Completed Record Overwrite`

Also ran the live trigger probe before the fix:

```text
scripts/supervisor.sh triggers --status review --limit 5
```

It marked `mailbox/outbox/2026-05-07-122028-completed-records-post-run-pass-reply.md` as `review-evidence` from generic terms including `creating`, `modified`, and `instead`.

## Current Weakness

The loop could still stop too early by treating weak lexical overlap as proof that a trigger fired. The old trigger-list matcher extracted generic prose tokens from `Supervisor evaluation trigger:` lines, then searched whole later files. That meant a completed-record trigger could become `review-evidence` even when no later evidence mentioned the concrete completed-record command or completed-record paths.

There was a second precision gap: if a tracked file already contained a concrete trigger term before the trigger source was committed, any later unrelated edit to that file could make the old term look like later evidence.

## Mechanism

Updated `scripts/supervisor-evaluation-trigger-list.sh` so trigger evidence is narrower:

- Evidence needles now come only from concrete backticked trigger terms that look like commands, paths, patterns, or multiword phrases.
- Generic prose fallback tokens are no longer extracted.
- For tracked files that existed at the source commit, matching is limited to later-added lines.
- Newly added or untracked evidence files may still match by path or content.
- The trigger-list implementation and fixture scripts are excluded from live evidence candidates so proof examples do not fire review status.

Updated `scripts/supervisor-evaluation-trigger-list-check.sh` with two focused regressions:

- the completed-record trigger stays quiet when later durable files contain only `creating`, `modified`, and `instead`;
- an old trigger term already present in an existing file does not count after an unrelated later edit.

Updated `memory/decisions/2026-05-07-supervisor-evaluation-trigger-list.md` with the precision rule and fixture coverage.

## Anti-Noise

I did not add a new supervisor challenge generator or commit gate. This was a precision bug in an existing review-list command, so the useful mechanism is to make the existing evidence classifier stricter and prove the live false-positive class. The command still reports candidates for human or supervisor review; it does not automatically reopen work.

## Verification

Focused validation:

```text
scripts/shell-syntax-check.sh scripts/supervisor-evaluation-trigger-list.sh scripts/supervisor-evaluation-trigger-list-check.sh
scripts/supervisor-evaluation-trigger-list-check.sh
scripts/supervisor.sh triggers --status quiet --limit 8
scripts/supervisor.sh triggers --status review --limit 5
```

Observed results:

```text
shell-syntax-check: ok scripts/supervisor-evaluation-trigger-list.sh
shell-syntax-check: ok scripts/supervisor-evaluation-trigger-list-check.sh
supervisor-evaluation-trigger-list-check: ignores generic words from completed-record trigger prose
supervisor-evaluation-trigger-list-check: ignores old trigger terms in existing files after unrelated edits
supervisor-evaluation-trigger-list-check: ok
```

The live quiet probe now lists `mailbox/outbox/2026-05-07-122028-completed-records-post-run-pass-reply.md` as `no-later-evidence`, with no later evidence found after the source commit.

The live review probe still preserves positive behavior for concrete terms. It lists real review candidates such as `mailbox/outbox/2026-05-07-supervisor-evaluation-trigger-list-reply.md`, matched by the concrete command `scripts/supervisor.sh triggers --status review`, and `mailbox/outbox/2026-05-07-feedback-refusal-trigger-reply.md`, matched by `scripts/feedback-escalation-check.sh`.

Final handoff validation will also run `scripts/supervisor-evaluation-trigger-list-check.sh`, `scripts/feedback-escalation-check.sh`, `scripts/docs-check.sh`, and mailbox hygiene after this input is moved to `mailbox/done/`.

## Return-To-Main Judgment

Return-to-main: deferred. The refinement is portable, deterministic, and directly fixes a live precision bug, but it remains part of no0's branch-local feedback-pressure review machinery. It should stay branch-local until repeated trigger-list use shows the stricter evidence rule reduces false positives without hiding important future trigger reviews.

Next supervisor pressure: run `scripts/supervisor.sh triggers --status quiet --limit 8` after this commit and require the completed-record source reply from `2026-05-07-122028` to remain `no-later-evidence` when later durable evidence contains only generic trigger-prose words.

## Result

Acceptance criteria satisfied:

- Added focused regression coverage for the completed-record false positive from `creating`, `modified`, and `instead`.
- Preserved the positive trigger-list fixture for later concrete trigger-path evidence.
- Avoided `constitution/` changes and generic repository sweep output.
- Kept scratch fixture state under `.self-harness/tmp/`.
