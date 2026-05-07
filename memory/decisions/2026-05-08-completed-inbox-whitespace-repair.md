---
id: "memory-decision-2026-05-08-completed-inbox-whitespace-repair"
title: "Completed Inbox Whitespace Repair Boundary"
type: "memory"
status: "active"
owner: "agent"
created: "2026-05-08"
updated: "2026-05-08"
tags:
  - mailbox
  - hygiene
  - feedback-pressure
  - completed-records
summary: "Records the narrow boundary for whitespace-only repairs to completed inbox records while keeping outbox and diary evidence append-only."
related:
  - "mailbox/processing/2026-05-07-231002-post-run-pressure-challenge.md"
  - "mailbox/outbox/2026-05-08-post-commit-hygiene-blocker-reply.md"
  - "mailbox/done/2026-05-07-224904-feedback-pressure-challenge.md"
  - "skills/mailbox-processing/SKILL.md"
---

# Completed Inbox Whitespace Repair Boundary

Decision: a completed inbox input under `mailbox/done/` may receive a whitespace-only hygiene repair when the supervisor explicitly asks for that decision, the edit preserves the message identity and wording, and the current run documents the repair in a new outbox reply.

This is not permission to rewrite historical evidence. Completed `mailbox/outbox/*.md` replies and `memory/diary/*.md` commit-message records remain append-only for current-run work; if they contain committed whitespace diagnostics, write a new report instead of editing them.

Rerunnable probe:

```bash
scripts/query-docs.sh memory "completed inbox whitespace repair"
scripts/query-docs.sh skills "completed inbox whitespace repair"
git diff --check
```

Worked signal for this run: the patch to `mailbox/done/2026-05-07-224904-feedback-pressure-challenge.md` changes only two blockquote blank lines from `> ` to `>`, and `git diff --check` reports no whitespace errors in the worktree.
