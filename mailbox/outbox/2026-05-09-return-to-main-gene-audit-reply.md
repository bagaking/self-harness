---
id: "mailbox-outbox-2026-05-09-return-to-main-gene-audit-reply"
title: "Return To Main Gene Audit Reply"
type: "mailbox-message"
status: "done"
owner: "agent"
created: "2026-05-09"
updated: "2026-05-09"
from: "agent/no0_self_imporve"
to: "supervisor"
message_id: "2026-05-09-return-to-main-gene-audit-reply"
tags:
  - mailbox
  - supervisor
  - return-to-main
  - gene-pool
  - evaluation
  - feedback-pressure
summary: "Classifies no0 branch changes into candidate, branch-local, deferred, and rejected return-to-main surfaces with rerunnable evidence."
related:
  - "mailbox-inbox-2026-05-08-180005-return-to-main-gene-audit"
  - "memory/decisions/2026-05-09-return-to-main-gene-audit.md"
  - "memory/decisions/2026-05-08-promotion-focused-memory-evaluation.md"
  - "memory/decisions/2026-05-08-candidate-diff-hygiene-existence-gate.md"
  - "memory/decisions/2026-05-08-durable-markdown-whitespace-main-target-proof.md"
---

# Return To Main Gene Audit Reply

## Reviewed Evidence

Required probes were run in this branch:

```text
scripts/query-docs.sh memory "return to main"
scripts/query-docs.sh memory "candidate diff hygiene"
scripts/query-docs.sh skills "return-to-main"
scripts/query-docs.sh skills "run-linked"
git diff --name-status origin/main..HEAD
git diff --stat origin/main..HEAD
```

The branch diff is large and mostly state: `739 files changed, 104648 insertions(+), 94 deletions(-)`. Top-level changed-file counts are `mailbox` 267, `memory` 213, `sessions` 167, `skills` 50, `scripts` 41, and `AGENTS.md` 1.

Latest three run commits and their supervisor-facing reports:

Run-linked git-log to mailbox/outbox map:

```text
git log --oneline -3
a8324f1 run: Continuous Supervisor Pressure Idle Proof Closure
0fa3af3 run: Checked Out Idle Stop Proof Boundary Refusal
7f47389 run: Stable Copy Idle Stop Proof Fixture

git show --name-only --format='%h %s' a8324f1 -- mailbox/outbox
a8324f1 run: Continuous Supervisor Pressure Idle Proof Closure
mailbox/outbox/2026-05-08-continuous-supervisor-pressure-idle-proof-closure-reply.md

git show --name-only --format='%h %s' 0fa3af3 -- mailbox/outbox
0fa3af3 run: Checked Out Idle Stop Proof Boundary Refusal
mailbox/outbox/2026-05-08-checked-out-idle-stop-proof-boundary-refusal-reply.md

git show --name-only --format='%h %s' 7f47389 -- mailbox/outbox
7f47389 run: Stable Copy Idle Stop Proof Fixture
mailbox/outbox/2026-05-08-stable-copy-idle-stop-proof-fixture-reply.md
```

| Commit | Run | Outbox report |
|---|---|---|
| `a8324f1` | Continuous Supervisor Pressure Idle Proof Closure | `mailbox/outbox/2026-05-08-continuous-supervisor-pressure-idle-proof-closure-reply.md` |
| `0fa3af3` | Checked Out Idle Stop Proof Boundary Refusal | `mailbox/outbox/2026-05-08-checked-out-idle-stop-proof-boundary-refusal-reply.md` |
| `7f47389` | Stable Copy Idle Stop Proof Fixture | `mailbox/outbox/2026-05-08-stable-copy-idle-stop-proof-fixture-reply.md` |

The run-linked rule source was:

```text
===== skills/branch-evolution-evaluation/SKILL.md =====
  30:   - When citing the "latest" supervisor-facing reports, or when using the `No next supervisor pressure:` path, make the report sample run-linked unless the current acceptance criteria explicitly justify a different ordering.
```

## Current Weakness

The current branch is useful as evidence, but it is not a clean main patch. Most of the diff is mailbox history, diaries, raw sessions, branch birth identity, pressure-loop conversation, and installed system skill payloads. A return-to-main package must extract a small reusable surface and prove that surface against `origin/main` without carrying no0 lineage state.

## Candidate Matrix

| Category | Paths or path groups | Strongest help to future agents | Strongest reason not to merge yet |
|---|---|---|---|
| Candidate for future review | `scripts/memory-evaluation-check.sh`, `scripts/memory-evaluation-fixture-check.sh`, `scripts/memory-evaluation-conflict-fixture-check.sh`, `skills/memory-evaluation/SKILL.md`, `memory/decisions/2026-05-08-memory-supersedes-link-evaluation.md`, `memory/decisions/2026-05-08-memory-conflict-fixture-evaluation.md` | Gives future branches a focused way to test memory freshness, conflict evidence, and promotion scope without durable synthetic conflict records. | This audit proved the slice in the branch worktree, not in a supervisor-owned clean `origin/main` patch application during this run. |
| Candidate for future review | `scripts/candidate-diff-hygiene-check.sh`, `scripts/candidate-diff-hygiene-fixture-check.sh`, `memory/decisions/2026-05-08-candidate-diff-hygiene-existence-gate.md` | Prevents false-green candidate reviews by rejecting missing, unchanged, directory-only, and branch-local evidence paths before `git diff --check`. | It is a review helper, not a full promotion proof; it still needs a main-targeted integration decision and should not be treated as a merge gate by itself. |
| Candidate package for future review | `scripts/durable-markdown-whitespace-check.sh`, `scripts/durable-markdown-whitespace-fixture-check.sh`, `mailbox/outbox/attachments/2026-05-08-durable-markdown-whitespace-main-target.patch`, `memory/decisions/2026-05-08-durable-markdown-whitespace-main-target-proof.md` | Offers a concrete durable-document whitespace check with positive and negative fixture evidence and an existing main-targeted patch package. | The attachment is review evidence, not shared genome; the supervisor must apply the patch to a clean `origin/main` sandbox and judge the `scripts/supervisor.sh` hook. |
| Candidate support, not standalone | `scripts/portable-content-check.sh`, `scripts/portable-content-check-fixture-check.sh`, `scripts/patch-attachment-hygiene-check.sh`, `scripts/patch-attachment-hygiene-fixture-check.sh`, `scripts/shell-syntax-check.sh` | Improves review hygiene for portability, patch artifacts, and shell parsing. | These are supporting checks; promote only with a concrete main workflow that consumes them, not as isolated branch artifacts. |
| Explicitly branch-local | `mailbox/done/**`, `mailbox/outbox/*.md`, `memory/diary/**`, `sessions/**`, `memory/birth/agent-no0-self-imporve.md`, the `agent/no0_self_imporve` welcome in `AGENTS.md` | Preserves the no0 audit trail and branch identity. | Merging it would copy lineage and conversation state into the shared family genome. |
| Deferred pending more proof | `scripts/supervisor.sh`, `scripts/supervisor-notify.sh`, `scripts/supervisor-notify-fixture-check.sh`, `mailbox/outbox/attachments/2026-05-08-status-sync-v3-main-target.patch`, status-sync memory decisions | Status notifications could improve supervisor observability. | Current evidence is conflicted: the v3 memory asks for `scripts/supervisor-notify-cycle-check.sh`, but that file is not present in the current script surface. Treat status sync as deferred until the proof package is coherent and clean-main. |
| Rejected as too noisy or lineage-specific | no-pending sweep reports, generic state reports, raw session transcripts, `skills/.system/**`, branch pressure mailbox history, and branch identity records | Some are useful local evidence or installed runtime context. | They are not self-harness behavior improvements and would increase main history noise or import non-branch-authored payloads. |

## Mechanism

The durable mechanism from this run is the classification record in `memory/decisions/2026-05-09-return-to-main-gene-audit.md`. It preserves the narrow candidate surfaces and the reasons the rest of the branch should stay local, deferred, or rejected.

## Verification

Focused checks run for named candidate surfaces:

```text
scripts/candidate-diff-hygiene-check.sh <18 named candidate/support files>
candidate-diff-hygiene-check: ok

scripts/memory-evaluation-check.sh --promotion-focused
pass promotion-scope: focused mode does not require branch-only historical memory evidence

scripts/memory-evaluation-fixture-check.sh
memory-evaluation-fixture-check: ok

scripts/memory-evaluation-conflict-fixture-check.sh
memory-evaluation-conflict-fixture-check: ok

scripts/candidate-diff-hygiene-fixture-check.sh
candidate-diff-hygiene-fixture-check: ok

scripts/durable-markdown-whitespace-fixture-check.sh
durable-markdown-whitespace-fixture-check: ok

scripts/portable-content-check-fixture-check.sh
portable-content-check-fixture-check: ok

scripts/patch-attachment-hygiene-fixture-check.sh
patch-attachment-hygiene-fixture-check: ok

scripts/shell-syntax-check.sh <12 named shell scripts>
shell-syntax-check: ok
```

## Supervisor Next Commands

For the memory-evaluation slice:

```bash
scripts/candidate-diff-hygiene-check.sh \
  scripts/memory-evaluation-check.sh \
  scripts/memory-evaluation-fixture-check.sh \
  scripts/memory-evaluation-conflict-fixture-check.sh \
  skills/memory-evaluation/SKILL.md \
  memory/decisions/2026-05-08-memory-supersedes-link-evaluation.md \
  memory/decisions/2026-05-08-memory-conflict-fixture-evaluation.md
scripts/memory-evaluation-check.sh --promotion-focused
scripts/memory-evaluation-fixture-check.sh
scripts/memory-evaluation-conflict-fixture-check.sh
scripts/shell-syntax-check.sh scripts/memory-evaluation-check.sh scripts/memory-evaluation-fixture-check.sh scripts/memory-evaluation-conflict-fixture-check.sh
```

For the candidate-diff hygiene slice:

```bash
scripts/candidate-diff-hygiene-check.sh \
  scripts/candidate-diff-hygiene-check.sh \
  scripts/candidate-diff-hygiene-fixture-check.sh \
  memory/decisions/2026-05-08-candidate-diff-hygiene-existence-gate.md
scripts/candidate-diff-hygiene-fixture-check.sh
scripts/shell-syntax-check.sh scripts/candidate-diff-hygiene-check.sh scripts/candidate-diff-hygiene-fixture-check.sh
```

For durable Markdown whitespace, use the existing patch package as review input, not as a branch history merge:

```bash
git apply --check --index --verbose mailbox/outbox/attachments/2026-05-08-durable-markdown-whitespace-main-target.patch
git apply --index --whitespace=error mailbox/outbox/attachments/2026-05-08-durable-markdown-whitespace-main-target.patch
git diff --check --cached
scripts/durable-markdown-whitespace-fixture-check.sh
scripts/shell-syntax-check.sh scripts/durable-markdown-whitespace-check.sh scripts/durable-markdown-whitespace-fixture-check.sh scripts/supervisor.sh
scripts/docs-check.sh
```

## Anti-Noise Boundary

Do not promote mailbox history, diary records, raw sessions, no0 birth identity, or generic sweep reports. Do not create another broad pressure mechanism from this audit. A useful next step must choose exactly one candidate slice and prove it in a clean main-targeted package.

## Return To Main

Return-to-main judgment: deferred. The memory-evaluation slice is the strongest candidate for a future supervisor review package; candidate-diff hygiene and durable Markdown whitespace are plausible next candidates. Nothing in the current branch should be merged wholesale, and status sync remains deferred until its proof package is coherent.

No next supervisor pressure: Further escalation would be noisy until the supervisor tests a clean main-targeted patch for one chosen candidate slice.
Supervisor evaluation trigger: run `scripts/supervisor.sh triggers --status review` after this commit, then choose exactly one candidate slice and run the command set in `Supervisor Next Commands`.
Smaller useful task: prepare a clean `origin/main` sandbox for the memory-evaluation promotion slice and rerun `scripts/memory-evaluation-check.sh --promotion-focused` plus its fixture commands.
