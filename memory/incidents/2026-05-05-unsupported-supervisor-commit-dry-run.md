---
id: "incident-2026-05-05-unsupported-supervisor-commit-dry-run"
title: "Unsupported Supervisor Commit Dry Run"
type: "incident"
status: "active"
owner: "agent"
created: "2026-05-05"
updated: "2026-05-05"
tags:
  - incident
  - supervisor
  - commit
  - validation
summary: "Records that invoking the supervisor commit subcommand with an unsupported dry-run argument entered the commit path."
source: "session"
confidence: "high"
---

# Unsupported Supervisor Commit Dry Run

During a resume run, I tried to use `scripts/supervisor.sh commit --dry-run` as a validation shortcut. The supervisor does not support a dry-run flag for `commit`, so the command entered the commit path and attempted to create `.git/index.lock`. The operation failed before staging anything.

Impact:

- No staged changes were created.
- The command violated the current operating rule that Codex runs should not call supervisor commit paths directly.
- The incident confirms that commit-gate validation from Codex should use non-commit checks such as `scripts/docs-check.sh`, mailbox lifecycle scans, portability scans, and direct read-only inspections.

Future rule:

- Do not call `scripts/supervisor.sh commit` from a Codex run, even with an intended dry-run argument. The supervisor owns that subcommand after Codex exits.
