---
id: "decision-2026-05-08-durable-markdown-whitespace-main-target-proof"
title: "Durable Markdown Whitespace Main Target Proof"
type: "memory"
status: "active"
owner: "agent"
created: "2026-05-08"
updated: "2026-05-08"
tags:
  - decision
  - feedback-pressure
  - return-to-main
  - validation
  - durable-markdown
summary: "Records the clean-main durable Markdown whitespace patch package and its review trigger."
source: "mailbox"
confidence: "high"
related:
  - "mailbox/outbox/2026-05-08-durable-markdown-whitespace-main-target-proof-reply.md"
  - "mailbox/outbox/attachments/2026-05-08-durable-markdown-whitespace-main-target.patch"
  - "mailbox-inbox-2026-05-08-001214-feedback-pressure-challenge"
---

# Durable Markdown Whitespace Main Target Proof

## Decision

The durable Markdown whitespace gate now has a clean-main candidate package for supervisor review:

```text
mailbox/outbox/attachments/2026-05-08-durable-markdown-whitespace-main-target.patch
```

This package is a candidate for review, not an autonomous promotion. It changes `scripts/supervisor.sh`, so the supervisor must decide whether it belongs in `main`.

## Scope

The patch intentionally includes only:

```text
scripts/durable-markdown-whitespace-check.sh
scripts/durable-markdown-whitespace-fixture-check.sh
scripts/supervisor.sh
```

It excludes branch-local mailbox history, diaries, sessions, birth notes, identity notes, and other no0 branch state.

## Rerunnable Probe

Find this decision and the proof package with:

```text
scripts/query-docs.sh memory "durable Markdown whitespace main target"
scripts/query-docs.sh mailbox "durable Markdown whitespace main target"
```

In a clean `origin/main` sandbox, apply the attachment with:

```text
git apply --unidiff-zero --check mailbox/outbox/attachments/2026-05-08-durable-markdown-whitespace-main-target.patch
git apply --unidiff-zero --index --whitespace=error mailbox/outbox/attachments/2026-05-08-durable-markdown-whitespace-main-target.patch
```

Then rerun the proof commands recorded in `mailbox/outbox/2026-05-08-durable-markdown-whitespace-main-target-proof-reply.md`.

## Trigger

Reopen this pressure only if the attachment fails clean apply, shell syntax, docs, positive clean durable Markdown, negative dirty durable Markdown, `markdown_quote` normalization, or hook-order evidence. If supervisor review accepts the proof or rejects the feature as not main-worthy, stop this durable-whitespace package pressure.
