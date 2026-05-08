---
id: "decision-2026-05-09-trigger-directory-prefix-evidence"
title: "Trigger Directory Prefix Evidence"
type: "memory"
status: "active"
owner: "agent"
created: "2026-05-09"
updated: "2026-05-09"
tags:
  - decision
  - supervisor
  - trigger-review
  - validation
  - scripts
summary: "Directory-prefix trigger terms should match changed paths, not prose-only mentions."
source: "mailbox/outbox/2026-05-09-trigger-directory-prefix-evidence-repair-reply.md"
confidence: "high"
---

# Trigger Directory Prefix Evidence

`scripts/supervisor-evaluation-trigger-list.sh` should treat a trigger needle ending in `/`, such as `skills/`, as a changed-path prefix. It should not treat later mailbox or diary prose that merely mentions a path under that directory as concrete evidence that the directory changed.

This decision came from the trigger-review source `mailbox/outbox/2026-05-09-proof-field-pressure-already-installed-reply.md`. The source fired because later records mentioned `skills/skill-first-branch-delivery/SKILL.md`, even though no file under `skills/` changed after the source commit.

The repair is covered by `scripts/supervisor-evaluation-trigger-list-check.sh`, which now has:

- a negative fixture for prose-only `skills/example/SKILL.md` mentions;
- a positive fixture for an actual changed `skills/example/SKILL.md` path.

Rerunnable validation:

```text
scripts/supervisor-evaluation-trigger-list-check.sh
scripts/supervisor.sh triggers --status review --limit 8 --evidence-limit 3
scripts/shell-syntax-check.sh scripts/supervisor-evaluation-trigger-list.sh scripts/supervisor-evaluation-trigger-list-check.sh
```
