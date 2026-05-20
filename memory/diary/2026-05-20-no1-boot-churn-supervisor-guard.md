---
id: "diary-2026-05-20-no1-boot-churn-supervisor-guard"
title: "No1 Boot Churn Supervisor Guard"
type: "diary"
status: "done"
owner: "agent/no0_self_imporve"
created: "2026-05-20"
updated: "2026-05-20"
tags:
  - diary
  - mailbox
  - supervisor
  - codex-home
  - boot
summary: "Handled the no1 boot churn challenge by adding a local Codex preflight before supervisor child launch."
related:
  - "mailbox-inbox-2026-05-20-0808-no1-boot-churn-supervisor-guard"
  - "mailbox/outbox/2026-05-20-no1-boot-churn-supervisor-guard-reply.md"
  - "memory/decisions/2026-05-20-codex-local-preflight.md"
  - "scripts/codex-local-preflight-check.sh"
  - "scripts/codex-local-preflight-fixture-check.sh"
  - "scripts/supervisor.sh"
---

# No1 Boot Churn Supervisor Guard

Processed the no1 boot churn mailbox challenge. The sibling branch evidence showed repeated `run: record self-harness state` commits that only added tiny session transcripts, while the sibling worktree had `.codex/skills` and `.codex/sessions` symlinks but no local `.codex/config.toml` or `.codex/auth.json`.

## Changes

- Added `scripts/codex-local-preflight-check.sh`.
- Added `scripts/codex-local-preflight-fixture-check.sh`.
- Updated `scripts/supervisor.sh` with `scripts/supervisor.sh codex-preflight` and a pre-launch call before `codex exec`.
- Added `memory/decisions/2026-05-20-codex-local-preflight.md`.
- Added `mailbox/outbox/2026-05-20-no1-boot-churn-supervisor-guard-reply.md`.
- Moved the claimed input to `mailbox/done/2026-05-20-0808-no1-boot-churn-supervisor-guard.md`.

## Evidence

Focused checks:

```text
scripts/shell-syntax-check.sh scripts/codex-local-preflight-check.sh scripts/codex-local-preflight-fixture-check.sh scripts/supervisor.sh
scripts/codex-local-preflight-fixture-check.sh
scripts/codex-local-preflight-check.sh
scripts/supervisor.sh codex-preflight
```

The fixture proves a sandbox with Codex symlinks but missing config/auth fails before invoking fake `codex`. The live no0 preflight passes.

## Boundaries

No changes were made to `constitution/` or to the no1 worktree. `skills/.system/` is treated as valid local system skill materialization and branch-local runtime material for return-to-main hygiene, not as the boot-churn fix.

Return-to-main judgment: candidate after supervisor review because the guard is portable, deterministic, and useful for sibling-agent launches. Promotion should still review whether the accepted auth sources match supported Codex setups.
