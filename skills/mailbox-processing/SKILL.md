---
name: mailbox-processing
description: "Use when processing self-harness mailbox work in this repository: reading pending mailbox/inbox messages, claiming them through mailbox/processing, writing durable mailbox/outbox replies or reports, moving inputs to mailbox/done or mailbox/failed, and verifying no unfinished processing files remain."
---

# Mailbox Processing

Use this skill for autonomous runs or explicit requests that involve `mailbox/`. It turns the constitution's mailbox rules into a short operational workflow.

## Workflow

1. Read `AGENTS.md`, `constitution/00-charter.md`, and query relevant constitution docs before changing state:

```bash
scripts/query-docs.sh constitution mailbox
scripts/query-docs.sh constitution commit
```

2. Inspect mailbox state:

```bash
find mailbox/inbox mailbox/processing mailbox/done mailbox/outbox mailbox/failed -maxdepth 1 -type f | sort
```

3. If a pending inbox file exists, claim exactly the file being handled:

```bash
mv mailbox/inbox/<message>.md mailbox/processing/<message>.md
```

Do not claim unrelated messages. If multiple messages are present, process them one at a time unless the user asked for a batch report.

4. Read the processing copy and its related memory/mailbox records with `scripts/query-docs.sh` before answering. Preserve the message id and cite repository-relative paths.

5. Write durable results:

- Put replies, reports, and proposals under `mailbox/outbox/`.
- Move handled input to `mailbox/done/`.
- Move failed or ambiguous input to `mailbox/failed/` and write an outbox or incident explanation.
- Update `memory/` or `skills/` only when the mailbox work created a reusable lesson, decision, incident, or procedure.

6. Before finishing, verify mailbox hygiene:

```bash
find mailbox/processing -maxdepth 1 -type f ! -name .gitkeep -print
find .self-harness/tmp -maxdepth 1 -type f \( -name 'outbox-*' -o -name '*.tmp' \) -print
scripts/docs-check.sh
```

## Frontmatter

Mailbox output should include compact frontmatter with at least:

```yaml
---
id: "mailbox-outbox-YYYY-MM-DD-short-name"
title: "Short Title"
type: "mailbox-message"
status: "done"
owner: "agent"
created: "YYYY-MM-DD"
updated: "YYYY-MM-DD"
from: "agent/no0_self_imporve"
to: "human | supervisor"
message_id: "YYYY-MM-DD-short-name-reply"
tags:
  - mailbox
summary: "One sentence summary."
related:
  - "original-message-id"
---
```

For processed input, update the processing copy's `status` to `done` or `error`, set `updated`, and then move it to `mailbox/done/` or `mailbox/failed/`.

## Guardrails

- Never modify `constitution/` to answer mailbox work.
- Do not leave non-placeholder files in `mailbox/processing/` unless the diary explains why processing is intentionally preserved.
- Do not create no-pending sweep reports when a pending inbox message exists.
- Keep durable mailbox and memory content portable: repository-relative paths only, no local usernames, hostnames, home directories, or machine-specific absolute paths.
- Do not run `git add` or `git commit`; the supervisor owns staging and committing.
