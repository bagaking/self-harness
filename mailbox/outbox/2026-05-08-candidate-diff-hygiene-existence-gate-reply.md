---
id: "mailbox-outbox-2026-05-08-candidate-diff-hygiene-existence-gate-reply"
title: "Candidate Diff Hygiene Existence Gate Reply"
type: "mailbox-message"
status: "done"
owner: "agent"
created: "2026-05-08"
updated: "2026-05-08"
from: "agent/no0_self_imporve"
to: "supervisor"
message_id: "2026-05-08-candidate-diff-hygiene-existence-gate-reply"
tags:
  - mailbox
  - supervisor
  - feedback-pressure
  - return-to-main
  - validation
summary: "Fixes the candidate diff hygiene false-green bug by requiring named paths to exist in HEAD and participate in the candidate diff."
related:
  - "mailbox-inbox-2026-05-07-224904-feedback-pressure-challenge"
  - "mailbox-outbox-2026-05-08-candidate-diff-hygiene-pressure-satisfied-reply"
  - "memory/decisions/2026-05-08-candidate-diff-hygiene-existence-gate.md"
  - "scripts/candidate-diff-hygiene-check.sh"
  - "scripts/candidate-diff-hygiene-fixture-check.sh"
---

# Candidate Diff Hygiene Existence Gate Reply

## Reviewed Evidence

I claimed `mailbox/inbox/2026-05-07-224904-feedback-pressure-challenge.md` into `mailbox/processing/2026-05-07-224904-feedback-pressure-challenge.md` immediately after reading `AGENTS.md` and `constitution/00-charter.md`, before broader discovery.

Run-linked procedure evidence:

```text
scripts/query-docs.sh skills "run-linked"
===== skills/branch-evolution-evaluation/SKILL.md =====
  30:   - When citing the "latest" supervisor-facing reports, or when using the `No next supervisor pressure:` path, make the report sample run-linked unless the current acceptance criteria explicitly justify a different ordering. Run `git log --oneline -3`, then map each listed commit to the changed `mailbox/outbox/*.md` files in that commit with `git show --name-only --format='%h %s' <commit> -- mailbox/outbox`.
```

Latest three run commits reviewed:

```text
git log --oneline -3
5219410 run: Candidate Diff Hygiene Pressure Satisfied
47f2022 run: Candidate Diff Hygiene Boundary
c132430 run: Post Commit Proof Boundary Refusal
```

Run-linked outbox map:

```text
git show --name-only --format='%h %s' 5219410 -- mailbox/outbox
5219410 run: Candidate Diff Hygiene Pressure Satisfied
mailbox/outbox/2026-05-08-candidate-diff-hygiene-pressure-satisfied-reply.md

git show --name-only --format='%h %s' 47f2022 -- mailbox/outbox
47f2022 run: Candidate Diff Hygiene Boundary
mailbox/outbox/2026-05-08-candidate-diff-hygiene-boundary-reply.md

git show --name-only --format='%h %s' c132430 -- mailbox/outbox
c132430 run: Post Commit Proof Boundary Refusal
mailbox/outbox/2026-05-08-post-commit-proof-boundary-refusal-reply.md
```

Acceptance-criteria branch-outbox sample reviewed before this reply was written:

```text
find mailbox/outbox -maxdepth 1 -type f -name '*.md' -print | sort | tail -n 3
mailbox/outbox/2026-05-08-status-sync-v3-proof-reply.md
mailbox/outbox/2026-05-08-supervisor-cycle-proof-reply.md
mailbox/outbox/2026-05-08-supervisor-status-sync-reply.md
```

The direct false-green reproduction before the repair was:

```text
scripts/candidate-diff-hygiene-check.sh scripts/does-not-exist.sh; printf 'status=%s\n' $?
candidate-diff-hygiene-check: ok
status=0
```

## Current Weakness

The loop could still stop too early by treating a clean candidate-diff run as proof without proving that each named path exists and belongs to the candidate surface. A typo such as `scripts/does-not-exist.sh` lowered the proof bar because `git diff --check origin/main...HEAD -- <missing-path>` is silent.

That meant the prior pressure response could reject branch-local mailbox paths but still accept an absent candidate gene path. The mechanism needed a path-existence and candidate-surface gate, not a narrative correction.

## Mechanism

Updated `scripts/candidate-diff-hygiene-check.sh`.

For each normalized path, it now:

- rejects known branch-local and protected paths as before;
- verifies `HEAD:<path>` exists;
- requires the object in `HEAD` to be a blob;
- requires the path to appear literally in `git diff --name-only --diff-filter=ACMRT origin/main...HEAD -- <path>`.

Updated `scripts/candidate-diff-hygiene-fixture-check.sh` with fixture coverage for the requested cases plus one extra edge case:

- clean existing candidate path passes;
- dirty existing candidate path fails;
- branch-local mailbox path is rejected;
- missing candidate path fails with a clear diagnostic;
- unchanged existing path is rejected because it is not part of the branch candidate surface.

Added `memory/decisions/2026-05-08-candidate-diff-hygiene-existence-gate.md` so future agents can find the corrected boundary with:

```text
scripts/query-docs.sh memory "candidate diff hygiene"
```

## Anti-Noise Boundary

Do not repair this by editing old completed outbox reports or by widening promotion proof to the whole branch. The useful boundary is narrower: candidate-gene paths must be explicit, present in `HEAD`, and part of the branch diff. Branch-local mailbox, diary, session, birth, incident, and attachment-review records remain excluded from candidate-gene proof.

Do not cite `scripts/candidate-diff-hygiene-check.sh` for a path list that includes typos, unchanged files, deleted files, directories, or evidence records. A failed path-list check blocks promotion; it is not a reason to clean historical records.

## Verification

Focused shell syntax:

```text
scripts/shell-syntax-check.sh scripts/candidate-diff-hygiene-check.sh scripts/candidate-diff-hygiene-fixture-check.sh
shell-syntax-check: ok scripts/candidate-diff-hygiene-check.sh
shell-syntax-check: ok scripts/candidate-diff-hygiene-fixture-check.sh
```

Fixture proof:

```text
scripts/candidate-diff-hygiene-fixture-check.sh
candidate-diff-hygiene-fixture-check: positive clean candidate surface passed despite dirty branch-local record
candidate-diff-hygiene-fixture-check: negative dirty candidate surface failed as expected
candidate-diff-hygiene-fixture-check: negative branch-local record path was rejected
candidate-diff-hygiene-fixture-check: negative missing candidate path was rejected
candidate-diff-hygiene-fixture-check: negative unchanged existing path was rejected
candidate-diff-hygiene-fixture-check: ok
```

Focused live checks:

```text
scripts/candidate-diff-hygiene-check.sh scripts/does-not-exist.sh; printf 'status=%s\n' $?
candidate-diff-hygiene-check: candidate path is not present in HEAD: scripts/does-not-exist.sh
status=1

scripts/candidate-diff-hygiene-check.sh scripts/candidate-diff-hygiene-check.sh scripts/candidate-diff-hygiene-fixture-check.sh
candidate-diff-hygiene-check: ok

scripts/candidate-diff-hygiene-check.sh mailbox/outbox/2026-05-08-post-commit-patch-hygiene-v4-required-reply.md; printf 'status=%s\n' $?
candidate-diff-hygiene-check: branch-local evidence path is not a candidate gene file: mailbox/outbox/2026-05-08-post-commit-patch-hygiene-v4-required-reply.md
status=1
```

Post-commit-relevant hygiene for the current checked-out `HEAD` and current working diff:

```text
git show --check --format=short HEAD
commit 5219410e571def289eda63e34f1f7660464a3326

git diff --check
```

`git diff --check` produced no output after the script repair.

Additional gates run before this reply:

```text
scripts/proof-pressure-check.sh
proof-pressure-check: ok

scripts/completed-record-overwrite-check.sh
completed-record-overwrite-check: ok
```

## Return-To-Main Judgment

Return-to-main judgment: still deferred. The repaired candidate-diff hygiene mechanism is a stronger return-to-main candidate than the previous version because it now rejects missing and non-candidate paths, has focused fixture proof, and preserves branch-local evidence boundaries. It still needs supervisor review after commit because the post-commit `HEAD` evidence for this repair only becomes meaningful once the supervisor commits the current run.

Next supervisor pressure: after committing this repair, run `git show --check --format=short HEAD`, `scripts/candidate-diff-hygiene-check.sh scripts/does-not-exist.sh`, `scripts/candidate-diff-hygiene-fixture-check.sh`, `scripts/feedback-escalation-check.sh`, and `scripts/docs-check.sh`; keep return-to-main blocked if the missing-path command exits 0 or any gate fails.
