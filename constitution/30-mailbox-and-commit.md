---
title: "Mailbox And Commit Protocol"
id: "constitution-30-mailbox-and-commit"
type: "constitution"
status: "active"
owner: "human"
protected: true
authority: "constitutional"
mutable_by: "human-only"
created: "2026-05-05"
updated: "2026-05-05"
tags:
  - mailbox
  - commit
  - diary
  - protocol
summary: "Defines inbox/outbox conventions, atomic file handling, and commit-message diary requirements."
---

# Mailbox And Commit Protocol

## Mailbox Layout

The mailbox is the agent's file-based communication interface.

Recommended layout:

```text
mailbox/
  inbox/
  processing/
  outbox/
  done/
  failed/
```

Incoming messages belong in `mailbox/inbox/`. Agents claim work by atomically moving an inbox file to `mailbox/processing/`. Agent replies, reports, and proposals belong in `mailbox/outbox/`. Processed input may be moved to `mailbox/done/`. Failed or ambiguous input may be moved to `mailbox/failed/` with an explanation.

## Message Files

Mailbox Markdown files should use frontmatter when practical:

```yaml
---
title: "Message title"
type: "mailbox-message"
status: "new | processing | done | error"
owner: "human | agent | shared"
created: "YYYY-MM-DD"
updated: "YYYY-MM-DD"
from: "human | agent | external"
to: "agent | human | external"
message_id: "stable-id"
tags:
  - mailbox
summary: "One sentence summary."
---
```

Agents should preserve message identity. They should avoid deleting inbox messages without either moving them to `done/` or leaving a clear output record.

Writes should be atomic where possible: write to a temporary file, then rename to the final path after the content is complete. Temporary write files should live under `.self-harness/tmp/` unless the writer needs same-directory rename semantics; durable mailbox paths should contain only complete records.

The normal lifecycle is:

```text
inbox -> processing -> done
inbox -> processing -> failed
.self-harness/tmp/outbox-* -> atomic rename or copy -> outbox/*.md
```

Mailbox state is commit-worthy agent state, including inbox, outbox, done, failed, and processing records. An autonomous run should not commit while mailbox files remain in `mailbox/processing/` unless the diary explains why the processing state is intentionally preserved.

## Commit Diary

When a new Codex session is started by the supervisor, the session should end by producing a GFM diary that can be used directly as the git commit message.

The diary should include:

- Summary
- Repository Changes
- Mailbox Activity
- Memory Updates
- Skill Updates
- Decisions
- Risks Or Incidents
- Next Suggested Work

The diary must be factual. It should not claim checks passed unless they actually ran.

The preferred implementation is to write the diary as a frontmatter-bearing Markdown artifact under `memory/diary/`, then derive the commit message from that checked file.

## Commit Gates

Before committing, scripts or agents must check:

- `git diff -- constitution/` is empty.
- `./.codex/skills` points to `../skills`.
- `./.codex/sessions` points to `../sessions`.
- No temporary mailbox output is left half-written.
- No unfinished `mailbox/processing/` files remain unless explicitly justified.
- No lock or pidfile intended only for runtime control is committed.
- `scripts/docs-check.sh` passes.
- Shell scripts changed in the commit pass `bash -n`.
- Relevant tests or script checks were run, or the diary states why they were not.

If `constitution/` changed, the agent must not commit. It must write a report under `mailbox/outbox/` or `memory/proposals/` and wait for human action.
