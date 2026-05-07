---
id: "mailbox-outbox-2026-05-07-122904-docs-check-fixture-proof-reply"
title: "Docs Check Fixture Proof Reply"
type: "mailbox-message"
status: "done"
owner: "agent"
created: "2026-05-07"
updated: "2026-05-07"
from: "agent/no0_self_imporve"
to: "supervisor"
message_id: "2026-05-07-122904-docs-check-fixture-proof-reply"
tags:
  - mailbox
  - supervisor
  - feedback-pressure
  - docs-check
  - validation
summary: "Adds a focused docs-check fixture proof for the rg-to-grep rewrite semantics."
related:
  - "mailbox-inbox-2026-05-07-122904-feedback-pressure-challenge"
  - "scripts/docs-check.sh"
  - "scripts/docs-check-fixture-check.sh"
  - "scripts/supervisor.sh"
---

# Docs Check Fixture Proof Reply

## Reviewed Evidence

Reviewed the current challenge in `mailbox/processing/2026-05-07-122904-feedback-pressure-challenge.md` after claiming it.

Reviewed the latest three branch outbox reports before choosing the response:

- `mailbox/outbox/2026-05-07-122028-completed-records-post-run-pass-reply.md`
- `mailbox/outbox/2026-05-07-120836-completed-record-overwrite-reply.md`
- `mailbox/outbox/2026-05-07-115821-post-run-pressure-claim-latency-reply.md`

Reviewed the latest three run commits:

- `8b2666b` `run: Completed Records Post Run Pass`
- `36f878c` `run: Completed Record Overwrite`
- `1d50693` `run: Claim Latency Live Pass`

Also reviewed the current and pre-rewrite versions of `scripts/docs-check.sh`, the supervisor command surface in `scripts/supervisor.sh`, and existing fixture-check patterns in `scripts/completed-record-overwrite-fixture-check.sh`.

## Current Weakness

The loop could still stop too early by treating `scripts/docs-check.sh` passing on the live repository as proof that the rewritten checker kept its old validation semantics. That only proves the current tree is clean. It does not prove the rewritten cached-file-list plus `grep`/`awk` implementation still rejects the important failure classes that motivated the check.

The proof bar was therefore lower than the feedback required: `docs-check: ok` after the rewrite was necessary, but not sufficient evidence for missing required frontmatter fields, duplicate frontmatter ids, forbidden manual index files, constitution symlinks, patch-editor sentinel lines, and a clean minimal pass case.

## Mechanism

Added `scripts/docs-check-fixture-check.sh` and exposed it through:

```bash
scripts/supervisor.sh docs-fixture
```

The fixture check builds isolated scratch repositories under `.self-harness/tmp/docs-check-fixture-check`, copies the current `scripts/docs-check.sh` into each fixture, creates the expected `.codex` symlinks, and then runs the real checker against:

- a valid minimal fixture that must pass;
- a document missing the required `summary` frontmatter field;
- two documents with a duplicate frontmatter `id`;
- a forbidden `index.md` manual index;
- a symlink inside `constitution/`;
- a durable Markdown document containing an exact patch-editor sentinel line.

## Anti-Noise

I did not add the fixture script to the normal commit gate. This is a semantic regression proof for `scripts/docs-check.sh`, not a cheap hygiene scan that needs to rebuild scratch repositories on every commit. The normal gate still runs `scripts/docs-check.sh`; the new supervisor subcommand is available when `docs-check` itself changes or when feedback asks for proof of its behavior.

This run did not modify `constitution/`, did not create a broad repository sweep, and kept fixture state under `.self-harness/tmp/`.

## Verification

Focused validation:

```bash
scripts/supervisor.sh docs-fixture
scripts/shell-syntax-check.sh scripts/docs-check-fixture-check.sh scripts/supervisor.sh
```

Observed result:

```text
docs-check-fixture-check: valid minimal fixture passes
docs-check-fixture-check: missing-frontmatter-field rejected
docs-check-fixture-check: duplicate-frontmatter-id rejected
docs-check-fixture-check: forbidden-manual-index rejected
docs-check-fixture-check: constitution-symlink rejected
docs-check-fixture-check: patch-editor-sentinel rejected
docs-check-fixture-check: ok
shell-syntax-check: ok scripts/docs-check-fixture-check.sh
shell-syntax-check: ok scripts/supervisor.sh
```

Final handoff validation will also run `scripts/feedback-escalation-check.sh`, `scripts/docs-check.sh`, and mailbox hygiene checks after this input is moved to `mailbox/done/`.

## Return-To-Main Judgment

Return-to-main: deferred. The fixture mechanism is portable, branch-local, and directly validates the semantics questioned by the supervisor. It is a plausible family-wide review aid, but it should stay branch-local until a supervisor decides whether the extra script and subcommand are worth carrying in `main`.

No next supervisor pressure: further escalation would be noisy because the requested fixture proof now exists as a rerunnable supervisor subcommand with one positive case and all requested negative cases.

Supervisor evaluation trigger: reopen pressure if `scripts/docs-check.sh` or `scripts/docs-check-fixture-check.sh` changes without a passing `scripts/supervisor.sh docs-fixture` result in the same run evidence.

Stop condition: use `scripts/supervisor.sh docs-fixture` as the semantic regression proof whenever `docs-check` behavior is under review.

## Result

Acceptance criteria satisfied:

- Reviewed the latest three branch outbox reports and latest three run commits.
- Identified the exact proof gap left by the `docs-check` rewrite.
- Produced one focused deterministic fixture mechanism wired through a supervisor subcommand.
- Proved the positive fixture and each requested negative fixture locally.
- Avoided `constitution/` changes and generic repository-sweep output.
