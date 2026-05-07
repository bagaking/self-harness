---
name: mailbox-processing
description: "Use when processing self-harness mailbox work in this repository: reading pending mailbox/inbox messages, claiming them through mailbox/processing, writing durable mailbox/outbox replies or reports, moving inputs to mailbox/done or mailbox/failed, and verifying no unfinished processing files remain."
---

# Mailbox Processing

Use this skill for autonomous runs or explicit requests that involve `mailbox/`. It turns the constitution's mailbox rules into a short operational workflow.

## Workflow

1. Read `AGENTS.md` and `constitution/00-charter.md` before changing state. If the launch prompt lists a single pending inbox, claim that file immediately after the charter read and before broad discovery such as extra `scripts/query-docs.sh` calls, repository sweeps, commit history review, or unrelated memory/skill inspection.

After the claim, query the relevant constitution docs:

```bash
scripts/query-docs.sh constitution mailbox
scripts/query-docs.sh constitution commit
```

2. Inspect mailbox state when needed:

```bash
find mailbox/inbox mailbox/processing mailbox/done mailbox/outbox mailbox/failed -maxdepth 1 -type f | sort
```

3. If a pending inbox file exists and has not already been claimed, claim exactly the file being handled:

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

6. For feedback-bearing mailbox work, self-check escalation before handoff.

When the inbox item or outbox reply is about supervisor feedback, feedback pressure, a pressure ratchet, raising the bar, low-value loops, or a proof bar, run:

```bash
scripts/feedback-escalation-check.sh
```

Run it after the outbox reply and `done/` or `failed/` move are in place, but before the diary and final handoff. If it fails, repair the durable outbox reply or the chosen mechanism before finishing instead of relying on the supervisor commit gate to catch the gap. Use `skills/branch-evolution-evaluation/SKILL.md` for the expected feedback-continuity markers: reviewed evidence, current weakness, mechanism or refusal, anti-noise boundary, verification, return-to-main judgment, and exactly one concrete `Next supervisor pressure:` line or one bounded `No next supervisor pressure:` refusal with a concrete `Supervisor evaluation trigger:` plus `Smaller useful task:` or `Stop condition:`.

7. For post-commit proof challenges, do not claim future `HEAD` evidence.

If an inbox acceptance criterion says a check must pass after commit, run the requested command against the current `HEAD` and report that result. If it fails on already tracked history and repairing that history would modify an existing completed outbox or diary record, do not edit the historical record. Write a focused refusal or next-step report that names the smaller useful task, preserves the failed command output, and states which checks only become meaningful after the supervisor commits the current clean records. You may use `git diff --check` for current working-tree cleanliness, but do not present it as a substitute for a future `git show --check --format=short HEAD`.

8. Before finishing, verify mailbox hygiene:

```bash
find mailbox/processing -maxdepth 1 -type f ! -name .gitkeep -print
find .self-harness/tmp -maxdepth 1 -type f \( -name 'outbox-*' -o -name '*.tmp' \) -print
scripts/feedback-escalation-check.sh
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
