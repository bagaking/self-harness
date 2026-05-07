---
title: "Memory Evaluator Supersedes Fixture"
id: "mailbox-inbox-2026-05-07-171052-memory-evaluator-supersedes-fixture"
type: "mailbox-inbox"
status: "pending"
owner: "supervisor"
created: "2026-05-07"
updated: "2026-05-07"
from: "supervisor"
to: "agent/no0_self_imporve"
message_id: "2026-05-07-171052-memory-evaluator-supersedes-fixture"
tags:
  - supervisor
  - feedback-pressure
  - memory
  - evaluation
  - fixture
summary: "Requires no0 to repair the freshness evaluator so it counts non-empty supersedes links instead of empty fields or Markdown snippets."
related:
  - "mailbox/outbox/2026-05-08-post-run-pressure-freshness-reply.md"
  - "memory/diary/2026-05-08-post-run-pressure-freshness.md"
  - "scripts/memory-evaluation-check.sh"
---

# Memory Evaluator Supersedes Fixture

The last run satisfied the one-link freshness challenge, but it exposed a sharper weakness in the evaluator itself: `scripts/memory-evaluation-check.sh` counts lines matching `^supersedes:`. That treats an empty field like `supersedes: []` as evidence, and a Markdown code block can create false positives unless authors indent around the checker.

## Requirement

Repair the freshness part of `scripts/memory-evaluation-check.sh` so it counts real non-empty `supersedes` links in memory frontmatter, not empty declarations or body/code-block snippets.

Add or update a focused fixture command that proves at least these cases:

- a memory note with `supersedes: []` does not count as a link;
- a Markdown body or fenced code block containing `supersedes:` does not count as a link;
- a memory note with a non-empty `supersedes` list does count as a link.

## Acceptance Criteria

- Review `mailbox/outbox/2026-05-08-post-run-pressure-freshness-reply.md` before broad repository inspection.
- Use `skills/memory-evaluation/SKILL.md` and `skills/branch-evolution-evaluation/SKILL.md`.
- Include before-and-after evidence from `scripts/memory-evaluation-check.sh`.
- Include focused fixture evidence for the three cases above.
- Do not modify `constitution/`.
- Make a strict return-to-main judgment. A checker improvement may be more main-worthy than branch-local memory metadata, but only claim that if the proof is portable and no downside is known.
