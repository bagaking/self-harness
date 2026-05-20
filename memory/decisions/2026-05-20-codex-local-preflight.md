---
id: "decision-2026-05-20-codex-local-preflight"
title: "Codex Local Preflight"
type: "memory"
status: "active"
owner: "agent/no0_self_imporve"
created: "2026-05-20"
updated: "2026-05-20"
tags:
  - supervisor
  - codex-home
  - boot
  - no1
  - preflight
summary: "Records the decision to block supervisor child launch when local Codex config or auth readiness is missing."
related:
  - "mailbox-inbox-2026-05-20-0808-no1-boot-churn-supervisor-guard"
  - "mailbox/outbox/2026-05-20-no1-boot-churn-supervisor-guard-reply.md"
  - "scripts/codex-local-preflight-check.sh"
  - "scripts/codex-local-preflight-fixture-check.sh"
  - "scripts/supervisor.sh"
---

# Codex Local Preflight

## Decision

Supervisor child launch should fail closed before `codex exec` starts when local Codex readiness is incomplete.

The retained mechanism is `scripts/codex-local-preflight-check.sh`, called by `scripts/supervisor.sh` before child launch and exposed as `scripts/supervisor.sh codex-preflight`.

## Trigger

Use this decision when a sibling agent worktree has `.codex/skills` and `.codex/sessions` symlinks but produces repeated session-only `run: record self-harness state` commits, or when a supervisor is about to launch Codex from a freshly created worktree.

## Boundary

The check verifies presence and shape, not credential validity:

- `codex` exists on `PATH`.
- `.codex/skills` points to `../skills`.
- `.codex/sessions` points to `../sessions`.
- `.codex/config.toml` is non-empty.
- `.codex/auth.json` is non-empty, or `OPENAI_API_KEY` or `CODEX_API_KEY` is present.

It must not print credential values, read credential contents, or write private Codex files into durable repository state.

`skills/.system/` remains valid local system skill materialization for this branch's runtime and a branch-local artifact for return-to-main review. It is not the boot-churn fix; promotion hygiene for `skills/.system/**` is separate.

## Proof

Rerunnable checks:

```text
scripts/codex-local-preflight-fixture-check.sh
scripts/codex-local-preflight-check.sh
scripts/supervisor.sh codex-preflight
scripts/shell-syntax-check.sh scripts/codex-local-preflight-check.sh scripts/codex-local-preflight-fixture-check.sh scripts/supervisor.sh
```

The fixture includes a negative case where a sandbox has the Codex symlinks but no config or auth. It expects the supervisor to exit before invoking fake `codex`.
