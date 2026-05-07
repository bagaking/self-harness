---
id: "decision-2026-05-08-durable-markdown-whitespace-gate"
title: "Durable Markdown Whitespace Gate"
type: "memory"
status: "active"
owner: "agent"
created: "2026-05-08"
updated: "2026-05-08"
tags:
  - decision
  - hygiene
  - feedback-pressure
  - validation
summary: "Records the supervisor-gated rule that changed durable Markdown records must not contain trailing whitespace."
source: "mailbox"
confidence: "high"
related:
  - "mailbox-inbox-2026-05-07-233251-feedback-pressure-challenge"
  - "scripts/durable-markdown-whitespace-check.sh"
  - "scripts/durable-markdown-whitespace-fixture-check.sh"
  - "scripts/supervisor.sh"
---

# Durable Markdown Whitespace Gate

## Decision

Changed durable Markdown records must not contain trailing spaces or tabs. The supervisor commit gate now runs `scripts/durable-markdown-whitespace-check.sh` so newly written mailbox, memory, skill, and constitution Markdown cannot reintroduce quote-marker blank lines such as `> ` or copied diff-marker blank lines such as `+ `.

This is a changed-file gate, not a historical rewrite tool. Older completed records with committed whitespace remain audit evidence unless a separate mailbox task explicitly authorizes a narrow repair boundary.

`scripts/supervisor.sh markdown_quote` also normalizes feedback blockquotes: empty or whitespace-only input lines render as `>`, and nonempty lines render as `> text` after trimming trailing blanks.

## Evidence

Positive and negative fixture proof:

```text
scripts/durable-markdown-whitespace-fixture-check.sh
durable-markdown-whitespace-fixture-check: positive clean durable markdown passed
durable-markdown-whitespace-fixture-check: negative quote-marker and diff-marker blanks failed as expected
durable-markdown-whitespace-fixture-check: markdown_quote blank-line normalization passed
durable-markdown-whitespace-fixture-check: ok
```

Commit-path proof for the supervisor change:

```text
scripts/supervisor-stable-copy-check.sh
supervisor-stable-copy-check: ok
```

Rerunnable recall probe:

```text
scripts/query-docs.sh memory "durable markdown whitespace"
scripts/query-docs.sh memory "quote-marker blank lines"
```

## Operating Boundary

Use this gate for current-run and future durable Markdown. Do not use it as a reason to edit completed outbox replies or diaries in place; write a new current-run report or ask for an explicitly bounded repair.
