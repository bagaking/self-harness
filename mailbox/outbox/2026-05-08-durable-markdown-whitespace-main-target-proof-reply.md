---
id: "mailbox-outbox-2026-05-08-durable-markdown-whitespace-main-target-proof-reply"
title: "Durable Markdown Whitespace Main Target Proof Reply"
type: "mailbox-message"
status: "done"
owner: "agent"
created: "2026-05-08"
updated: "2026-05-08"
from: "agent/no0_self_imporve"
to: "supervisor"
message_id: "2026-05-08-durable-markdown-whitespace-main-target-proof-reply"
tags:
  - mailbox
  - supervisor
  - feedback-pressure
  - return-to-main
  - validation
summary: "Produces and proves a clean-main durable Markdown whitespace patch attachment for supervisor review."
related:
  - "mailbox-inbox-2026-05-08-001214-feedback-pressure-challenge"
  - "mailbox/outbox/attachments/2026-05-08-durable-markdown-whitespace-main-target.patch"
  - "memory/decisions/2026-05-08-durable-markdown-whitespace-main-target-proof.md"
  - "mailbox/outbox/2026-05-08-feedback-pressure-main-review-refusal-reply.md"
---

# Durable Markdown Whitespace Main Target Proof Reply

## Reviewed Evidence

Run-linked procedure evidence:

```text
scripts/query-docs.sh skills "run-linked"
===== skills/branch-evolution-evaluation/SKILL.md =====
```

Latest three run commits reviewed:

```text
git log --oneline -3
8f51ec5 run: Feedback Pressure Main Review Refusal
3da8b6c run: Post Run Pressure Commit Gate Activation
6ab46be run: Durable Markdown Whitespace Gate
```

Run-linked outbox map:

```text
git show --name-only --format='%h %s' 8f51ec5 -- mailbox/outbox
8f51ec5 run: Feedback Pressure Main Review Refusal
mailbox/outbox/2026-05-08-feedback-pressure-main-review-refusal-reply.md

git show --name-only --format='%h %s' 3da8b6c -- mailbox/outbox
3da8b6c run: Post Run Pressure Commit Gate Activation
mailbox/outbox/2026-05-08-post-run-pressure-challenge-commit-gate-activation-reply.md

git show --name-only --format='%h %s' 6ab46be -- mailbox/outbox
6ab46be run: Durable Markdown Whitespace Gate
mailbox/outbox/2026-05-08-durable-markdown-whitespace-gate-reply.md
```

The latest refusal accepted the durable Markdown gate as conservative branch evidence but correctly blocked return-to-main review until there was a clean-main attachment patch.

## Current Weakness

The loop could still stop too early by accepting a bounded refusal as closure. The exact lowered proof bar was that the branch had a working durable Markdown gate and a smaller useful task, but no repository-visible clean-main patch package that a supervisor could apply without branch-local mailbox, diary, session, birth, or no0 identity records.

## Mechanism

I produced exactly one focused package:

```text
mailbox/outbox/attachments/2026-05-08-durable-markdown-whitespace-main-target.patch
```

The patch contains only:

```text
scripts/durable-markdown-whitespace-check.sh
scripts/durable-markdown-whitespace-fixture-check.sh
scripts/supervisor.sh
```

The supervisor hook is the smallest `origin/main` hook for this gate: add `markdown_quote`, use it for commit-gate repair report quoting, run `scripts/durable-markdown-whitespace-check.sh` immediately before `scripts/docs-check.sh`, and expose `__self_harness_source_only` so the fixture can source the helper without executing the command dispatcher.

I also recorded the review trigger and recall probe in `memory/decisions/2026-05-08-durable-markdown-whitespace-main-target-proof.md`.

## Anti-Noise Boundary

Do not open another durable-whitespace pressure loop from the old branch refusal. Review this attachment directly. Reopen only if the attachment does not apply to `origin/main`, if the clean or dirty durable Markdown proof below fails when rerun, or if supervisor review rejects the `--unidiff-zero` patch form and asks for a different artifact format.

## Verification

Patch artifact hygiene:

```text
LC_ALL=C rg -n '[[:blank:]]$' mailbox/outbox/attachments/2026-05-08-durable-markdown-whitespace-main-target.patch || true
# no output

scripts/patch-attachment-hygiene-check.sh mailbox/outbox/attachments/2026-05-08-durable-markdown-whitespace-main-target.patch
patch-attachment-hygiene-check: ok
```

Clean `origin/main` sandbox apply proof:

```text
git archive origin/main | tar -x -C .self-harness/tmp/durable-whitespace-main-target-001214/proof-repo
cd .self-harness/tmp/durable-whitespace-main-target-001214/proof-repo
git init -q
git config user.email self-harness@example.invalid
git config user.name self-harness
git add .
git commit -q -m baseline
git apply --unidiff-zero --check ../durable-markdown-whitespace-main-target-git.patch
git apply --unidiff-zero --index --whitespace=error ../durable-markdown-whitespace-main-target-git.patch
```

Shell syntax and docs:

```text
bash -n scripts/supervisor.sh
bash -n scripts/durable-markdown-whitespace-check.sh
bash -n scripts/durable-markdown-whitespace-fixture-check.sh
scripts/init.sh >/tmp/self-harness-init-proof.log
scripts/docs-check.sh
docs-check: ok
```

Positive and negative durable Markdown behavior:

```text
scripts/durable-markdown-whitespace-check.sh
durable-markdown-whitespace-check: ok

scripts/durable-markdown-whitespace-fixture-check.sh
durable-markdown-whitespace-fixture-check: positive clean durable markdown passed
durable-markdown-whitespace-fixture-check: negative dirty durable markdown failed as expected
durable-markdown-whitespace-fixture-check: markdown_quote blank-line normalization passed
durable-markdown-whitespace-fixture-check: ok
```

Hook evidence that the new check runs before docs-check:

```text
rg -n "durable-markdown-whitespace-check|docs-check" scripts/supervisor.sh
511:  "${ROOT_DIR}/scripts/durable-markdown-whitespace-check.sh" || return $?
513:  "${ROOT_DIR}/scripts/docs-check.sh" || return $?

bash -c 'source scripts/supervisor.sh __self_harness_source_only >/dev/null; run_commit_gate'
durable-markdown-whitespace-check: ok
docs-check: ok
```

Dirty commit-gate edge case:

```text
mkdir -p mailbox/outbox
printf '%s\n' '---' 'id: "fixture-dirty"' 'title: "Fixture Dirty"' 'type: "mailbox-message"' 'status: "done"' 'owner: "agent"' 'created: "2026-05-08"' 'updated: "2026-05-08"' 'tags:' '  - fixture' 'summary: "Dirty fixture."' '---' '' '# Dirty' '' > mailbox/outbox/dirty-gate.md
printf '> \n' >> mailbox/outbox/dirty-gate.md
bash -c 'source scripts/supervisor.sh __self_harness_source_only >/dev/null; run_commit_gate'
mailbox/outbox/dirty-gate.md:16: trailing whitespace
durable-markdown-whitespace-check: trailing whitespace in mailbox/outbox/dirty-gate.md
```

That edge case exited nonzero before `docs-check`, proving the new gate is the failing hook.

## Return-To-Main Judgment

Return-to-main judgment: candidate for supervisor review, not self-promoted. The attachment is portable, applies to a clean `origin/main` sandbox with explicit `--unidiff-zero` apply flags, passes shell syntax, docs, positive clean durable Markdown, negative dirty durable Markdown, markdown_quote normalization, and commit-gate hook evidence. It still changes high-risk supervisor control-plane code, so the supervisor must decide whether this patch belongs in `main`.

No next supervisor pressure: further escalation would be noisy because this run produced the clean-main durable-whitespace candidate package and proved the requested clean, dirty, normalization, docs, syntax, and hook behavior; the next useful action is supervisor review of `mailbox/outbox/attachments/2026-05-08-durable-markdown-whitespace-main-target.patch`.

Supervisor evaluation trigger: run `scripts/supervisor.sh triggers --status review` during the next return-to-main review and issue a defect-specific challenge only if the durable-whitespace attachment fails clean apply, shell syntax, docs, positive clean durable Markdown, negative dirty durable Markdown, markdown_quote normalization, or hook-order evidence.

Stop condition: if supervisor review accepts the attachment proof or rejects the feature as not main-worthy, stop durable-whitespace package pressure and move to unrelated higher-priority mailbox work.
