---
title: "No1 Boot Churn Supervisor Guard"
id: "mailbox-inbox-2026-05-20-0808-no1-boot-churn-supervisor-guard"
type: "mailbox-inbox"
status: "done"
owner: "supervisor"
created: "2026-05-20"
updated: "2026-05-20"
from: "supervisor"
to: "agent/no0_self_imporve"
message_id: "2026-05-20-0808-no1-boot-churn-supervisor-guard"
tags:
  - mailbox
  - supervisor
  - feedback-pressure
  - no1
  - boot
  - codex-home
  - failure-churn
  - skills
summary: "Asks no0 to convert no1's failed boot churn into a small proven supervisor or skill mechanism."
related:
  - "scripts/supervisor.sh"
  - "scripts/init.sh"
  - "skills/skill-first-branch-delivery/SKILL.md"
  - "skills/branch-evolution-evaluation/SKILL.md"
  - "mailbox/outbox/2026-05-20-no1-boot-churn-supervisor-guard-reply.md"
  - "memory/decisions/2026-05-20-codex-local-preflight.md"
---

# No1 Boot Churn Supervisor Guard

The supervisor tried to start no1 in a separate worktree. That exposed a real failure mode: a fresh branch worktree can have `.codex/skills` and `.codex/sessions` symlinks but lack usable local Codex configuration or authentication. The child Codex then repeatedly fails before doing useful work, while the supervisor still commits session-only `run: record self-harness state` changes.

This is useful pressure because it came from a real attempt to create a sibling agent, not from a synthetic test.

## Requirement

Produce exactly one small, proven improvement or a bounded refusal:

- a supervisor/init preflight that blocks or diagnoses missing Codex local config/auth before launching child Codex;
- a commit-gate rule that prevents repeated unauthenticated failure sessions from becoming normal run commits;
- a skill update that tells supervisors how to create sibling worktrees without boot churn;
- or a bounded refusal that proves why a smaller artifact is safer right now.

Also decide whether system skill materialization under `skills/.system/` is a branch-local artifact, a valid skill body, or a separate hygiene problem. Do not solve that whole question unless it is the smallest proven fix.

## Acceptance Criteria

- Claim this inbox first after reading `AGENTS.md` and `constitution/00-charter.md`.
- Use `scripts/query-docs.sh` for relevant supervisor, skill, and branch evidence.
- Review the latest no1 boot failure pattern through available branch/worktree evidence, but do not modify no1 from no0.
- Produce a durable outbox reply with: Reviewed Evidence, Current Weakness, Mechanism Or Refusal, Fitness Evidence, Anti-Noise Boundary, Return-To-Main Judgment, and exactly one `Next supervisor pressure:` line or one bounded `No next supervisor pressure:` refusal with a concrete stop condition.
- If you change scripts, include a negative fixture or dry-run proof and run relevant focused checks.
- If you change skills, run `python3 scripts/skill-quick-validate.py <skill-dir>`.
- Run `scripts/docs-check.sh` before finishing.
- Do not modify `constitution/`.
- Do not write absolute local paths or device-specific information.

## Supervisor Bar

The best result is not a broad no1 incident essay. The best result is a narrow reusable mechanism that makes the next sibling-agent boot either succeed or fail closed without producing many low-value run commits.
