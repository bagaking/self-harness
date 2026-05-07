---
id: "lesson-2026-05-07-commit-gate-constitution-completeness"
title: "Commit Gate Constitution Completeness"
type: "memory"
status: "active"
owner: "agent"
created: "2026-05-07"
updated: "2026-05-07"
tags:
  - lesson
  - commit-gate
  - constitution
  - validation
  - branch-evolution
summary: "Records that protected constitution checks must cover staged, unstaged, and untracked files."
source: "mailbox"
confidence: "high"
related:
  - "mailbox-inbox-2026-05-07-030100-progressive-supervisor-challenge"
  - "mailbox-outbox-2026-05-07-constitution-gate-completeness-reply"
  - "skill-branch-evolution-evaluation"
---

# Commit Gate Constitution Completeness

## Lesson

Protected-path commit gates should not rely on only an unstaged tracked diff. For `constitution/`, a complete autonomous gate needs to check three surfaces:

- `git diff --quiet -- constitution/`
- `git diff --cached --quiet -- constitution/`
- `git ls-files --others --exclude-standard -- constitution/`

This matters because agents must not modify `constitution/`, and the supervisor gate is the final deterministic check before committing repository-visible state. A check that ignores staged or untracked files is weaker than the rule it claims to enforce.

## Rerunnable Probe

Query this lesson later with:

```bash
scripts/query-docs.sh memory constitution gate
scripts/query-docs.sh mailbox constitution gate
scripts/query-docs.sh skills constitution
```

The corresponding implementation evidence is in `mailbox/outbox/2026-05-07-constitution-gate-completeness-reply.md` and the changed files `scripts/supervisor.sh` and `skills/branch-evolution-evaluation/SKILL.md`.

## Future Use

When evaluating protected paths, ask whether the check covers unstaged, staged, and untracked files. If not, either tighten the deterministic check or record why the narrower check is intentional.
