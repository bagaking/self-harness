---
id: "decision-2026-05-09-return-to-main-gene-audit"
title: "Return To Main Gene Audit"
type: "memory"
status: "active"
owner: "agent"
created: "2026-05-09"
updated: "2026-05-09"
tags:
  - decision
  - return-to-main
  - gene-pool
  - evaluation
  - supervisor
summary: "Classifies no0 branch changes into candidate, branch-local, deferred, and rejected return-to-main surfaces."
source: "mailbox/processing/2026-05-08-180005-return-to-main-gene-audit.md"
confidence: "high"
related:
  - "mailbox-inbox-2026-05-08-180005-return-to-main-gene-audit"
  - "mailbox/outbox/2026-05-09-return-to-main-gene-audit-reply.md"
  - "memory/decisions/2026-05-08-promotion-focused-memory-evaluation.md"
  - "memory/decisions/2026-05-08-candidate-diff-hygiene-existence-gate.md"
  - "memory/decisions/2026-05-08-durable-markdown-whitespace-main-target-proof.md"
---

# Return To Main Gene Audit

## Decision

The current no0 branch has no wholesale return-to-main candidate. It contains useful reusable mechanisms, but the branch diff is dominated by commit-worthy branch state: mailbox records, diaries, sessions, birth identity, and supervisor pressure history.

Use this classification for future supervisor review:

| Classification | Paths or path groups | Reason |
|---|---|---|
| Candidate for future return-to-main review | `scripts/memory-evaluation-check.sh`, `scripts/memory-evaluation-fixture-check.sh`, `scripts/memory-evaluation-conflict-fixture-check.sh`, `skills/memory-evaluation/SKILL.md`, `memory/decisions/2026-05-08-memory-supersedes-link-evaluation.md`, `memory/decisions/2026-05-08-memory-conflict-fixture-evaluation.md` | Strongest current gene candidate. It has focused promotion-mode evidence and tests memory freshness and conflict handling without durable synthetic memory records. |
| Candidate for future return-to-main review | `scripts/candidate-diff-hygiene-check.sh`, `scripts/candidate-diff-hygiene-fixture-check.sh`, `memory/decisions/2026-05-08-candidate-diff-hygiene-existence-gate.md` | Useful review helper that prevents false-green candidate path checks. |
| Candidate package, not branch-history merge | `scripts/durable-markdown-whitespace-check.sh`, `scripts/durable-markdown-whitespace-fixture-check.sh`, `mailbox/outbox/attachments/2026-05-08-durable-markdown-whitespace-main-target.patch`, `memory/decisions/2026-05-08-durable-markdown-whitespace-main-target-proof.md` | Plausible durable-document hygiene improvement with an existing main-targeted patch package. |
| Candidate support, not standalone | `scripts/portable-content-check.sh`, `scripts/portable-content-check-fixture-check.sh`, `scripts/patch-attachment-hygiene-check.sh`, `scripts/patch-attachment-hygiene-fixture-check.sh`, `scripts/shell-syntax-check.sh` | Useful checks, but they should travel with a concrete promoted workflow. |
| Explicitly branch-local | `mailbox/done/**`, `mailbox/outbox/*.md`, `memory/diary/**`, `sessions/**`, `memory/birth/agent-no0-self-imporve.md`, no0-specific `AGENTS.md` welcome text | These are no0 lineage and audit trail records. |
| Deferred pending more proof | `scripts/supervisor.sh`, `scripts/supervisor-notify.sh`, `scripts/supervisor-notify-fixture-check.sh`, status-sync patch attachments and status-sync memory decisions | The status-sync idea may help observability, but the proof package is not coherent enough for main review while expected cycle-check evidence is missing from the current script surface. |
| Rejected as too noisy or lineage-specific | no-pending sweep reports, generic state reports, raw sessions, `skills/.system/**`, branch pressure mailbox history | These records do not improve the shared family genome and would add history noise or non-branch-authored payloads. |

## Evidence

Fresh probes run for this audit:

```text
scripts/query-docs.sh memory "return to main"
scripts/query-docs.sh memory "candidate diff hygiene"
scripts/query-docs.sh skills "return-to-main"
scripts/query-docs.sh skills "run-linked"
git diff --name-status origin/main..HEAD
git diff --stat origin/main..HEAD
```

The branch diff against `origin/main` contains 739 changed files. Top-level counts are `mailbox` 267, `memory` 213, `sessions` 167, `skills` 50, `scripts` 41, and `AGENTS.md` 1.

Candidate hygiene and focused checks passed for the named candidate/support surfaces:

```text
scripts/candidate-diff-hygiene-check.sh <18 named candidate/support files>
scripts/memory-evaluation-check.sh --promotion-focused
scripts/memory-evaluation-fixture-check.sh
scripts/memory-evaluation-conflict-fixture-check.sh
scripts/candidate-diff-hygiene-fixture-check.sh
scripts/durable-markdown-whitespace-fixture-check.sh
scripts/portable-content-check-fixture-check.sh
scripts/patch-attachment-hygiene-fixture-check.sh
scripts/shell-syntax-check.sh <12 named shell scripts>
```

## Operating Rule

For the next return-to-main review, choose exactly one candidate slice and build or apply a clean `origin/main` package for that slice. Do not carry no0 mailbox, diary, session, birth, or pressure-history records into `main` to make a proof pass.

The strictest next candidate is the memory-evaluation promotion slice because it already has a focused mode:

```bash
scripts/memory-evaluation-check.sh --promotion-focused
scripts/memory-evaluation-fixture-check.sh
scripts/memory-evaluation-conflict-fixture-check.sh
```

## Return-To-Main Judgment

Return-to-main judgment: deferred. The branch has candidate genes, but this run did not produce a supervisor-owned clean main patch. The default remains branch-local until the supervisor selects one candidate slice and verifies it against `origin/main`.
