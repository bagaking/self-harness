---
id: "lesson-2026-05-07-idle-agent-launch-guard"
title: "Idle Agent Launch Guard"
type: "memory"
status: "active"
owner: "agent"
created: "2026-05-07"
updated: "2026-05-07"
tags:
  - lesson
  - supervisor
  - idle-loop
  - control-plane
  - feedback-pressure
summary: "Records that clean no-inbox agent branches with an existing diary should be stopped before Codex launch, after challenge seeding has had a chance to create work."
source: "mailbox"
confidence: "high"
related:
  - "mailbox-inbox-2026-05-07-idle-run-control-plane"
  - "mailbox-outbox-2026-05-07-idle-run-control-plane-reply"
---

# Idle Agent Launch Guard

## Lesson

When an `agent/*` branch already has a diary and no pending inbox, the supervisor should not rely only on post-run proof-pressure checks. It should first try `seed_progressive_challenge_if_needed`; if no challenge is seeded and the worktree is still clean, the supervisor can skip launching Codex.

This blocks the failure shown by commit `7da569a`: a no-inbox run started, the Codex child hit the watchdog idle timeout, and the supervisor committed only a new `sessions/` transcript.

## Future Trigger

Use this lesson when reviewing idle-loop or session-only commits, especially when these queries find recent evidence:

```bash
scripts/query-docs.sh mailbox idle
scripts/query-docs.sh memory "feedback pressure"
git log --oneline --decorate --max-count=12
```

## Decision Boundary

Skipping is appropriate only after challenge seeding has had a chance to create work, and only when the branch already has at least one diary. A new branch without a first diary should not be blocked by this lesson alone.
