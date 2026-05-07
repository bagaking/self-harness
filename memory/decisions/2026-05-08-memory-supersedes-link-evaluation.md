---
id: "decision-2026-05-08-memory-supersedes-link-evaluation"
title: "Memory Supersedes Link Evaluation"
type: "memory"
status: "active"
owner: "agent"
created: "2026-05-08"
updated: "2026-05-08"
tags:
  - decision
  - memory
  - evaluation
  - freshness
  - fixture
summary: "Records that memory freshness evaluation should count non-empty frontmatter supersedes links, not declarations or body snippets."
source: "mailbox"
confidence: "high"
related:
  - "mailbox-inbox-2026-05-07-171052-memory-evaluator-supersedes-fixture"
  - "mailbox-outbox-2026-05-08-memory-evaluator-supersedes-fixture-reply"
  - "decision-2026-05-07-memory-evaluation-probe-before-query-change"
  - "scripts/memory-evaluation-check.sh"
  - "scripts/memory-evaluation-fixture-check.sh"
---

# Memory Supersedes Link Evaluation

## Decision

`scripts/memory-evaluation-check.sh` freshness scoring should count real non-empty `supersedes` links in memory frontmatter. It should not count an empty declaration such as `supersedes: []`, and it should ignore `supersedes:` text in Markdown bodies or fenced code blocks.

## Evidence

The prior freshness run exposed the weakness: the checker reported `warn freshness: only 1 memory note declares supersession metadata` because it counted lines matching `^supersedes:` under `memory/`. That was not enough to distinguish a true link from an empty field or body text.

The repair added a frontmatter-only counter and the command:

```text
scripts/memory-evaluation-check.sh --count-supersedes-links
```

The focused fixture command is:

```text
scripts/memory-evaluation-fixture-check.sh
```

It proves:

- `supersedes: []` counts as `0`;
- a Markdown body or fenced code block containing `supersedes:` counts as `0`;
- a non-empty frontmatter `supersedes` list counts as `1`;
- the combined fixture still counts only the real link.

## Return-To-Main Judgment

Return-to-main judgment: candidate.

This checker repair is portable, branch-agnostic, and backed by a focused fixture. It improves a deterministic script rather than only branch-local metadata. Supervisor review should still decide promotion, but no known downside is visible after `scripts/memory-evaluation-check.sh`, `scripts/memory-evaluation-fixture-check.sh`, focused shell syntax validation, feedback checks, and `scripts/docs-check.sh` pass.
