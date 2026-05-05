---
title: "Change Control"
id: "constitution-40-change-control"
type: "constitution"
status: "active"
owner: "human"
protected: true
authority: "constitutional"
mutable_by: "human-only"
created: "2026-05-05"
updated: "2026-05-05"
tags:
  - safety
  - change-control
  - protected-paths
summary: "Defines protected paths, review thresholds, and hard checks for autonomous changes."
---

# Change Control

## Protected Paths

Agents must not modify `constitution/`.

Agents should treat `scripts/` as high-risk control-plane code. They may propose script changes freely, but should only modify scripts when the change is directly necessary, small, reviewed against the constitution, and accompanied by a clear diary entry.

Agents may generally modify `memory/`, `skills/`, and `mailbox/` within their directory semantics.

Agents should not manually edit `sessions/` except under explicit human instruction.

## Proposal Path

When an agent wants to change a protected or high-risk rule, it should write a proposal with frontmatter under `memory/proposals/` or `mailbox/outbox/`.

A proposal should include:

- The current rule or behavior.
- The observed problem.
- The proposed change.
- The expected benefit.
- The failure mode if the change is wrong.
- The rollback plan.

## Hard Checks

Supervisor and commit scripts should enforce these checks mechanically:

- Refuse to commit changes under `constitution/`.
- Treat changes under `AGENTS.md` and `scripts/` as high-risk and require a diary explanation.
- Refuse to run two self-harness Codex processes for the same repository state.
- Refuse to overwrite non-symlink `.codex/skills` or `.codex/sessions`.
- Report stale locks instead of silently ignoring them.
- Preserve mailbox inputs or leave an auditable output record.
- Prefer append-only or proposal-based updates for uncertain memory.
- Refuse to commit obvious secrets, runtime locks, temporary files, or Codex private config.
- Refuse to commit newly written portable documents or scripts that expose local hostnames, usernames, home directories, machine-specific absolute paths, or instructions to modify files outside the repository.
- Keep `.codex/`, `.self-harness/`, runtime locks, and private config out of git.
- Treat `sessions/` and `mailbox/` as commit-worthy agent state, while still checking them for obvious secrets and half-written temporary files.
- Do not add broad ignore rules that hide agent state. Ignoring `sessions/` or `mailbox/` is a known bad counterexample because it hides the agent's own history.
- Check that `constitution/` contains no symlinked files.
- Check Markdown frontmatter in long-term documents.

Codex runs should not write `.git/` directly. Staging and committing are supervisor responsibilities after the Codex process exits.

If a supervisor commit gate fails because of fixable content hygiene issues, the supervisor should record a concise diagnostic and resume the active Codex session once so the agent can repair its own output. If the repaired state still fails the gate, the supervisor should stop and leave the diagnostic for human review.

If a human explicitly directs a constitutional update, the supervisor may commit it with an explicit constitution override. Agents must not use that override on their own initiative.

## Long-Term Drift Control

The system should expect drift and design against it.

Rules should be stable in `constitution/`. Experience should accumulate in `memory/`. Reusable procedures should be extracted into `skills/`. Deterministic enforcement should live in scripts.

When behavior degrades, the preferred response is to inspect diary history, query memory and skills by frontmatter, identify the smallest broken rule or procedure, and repair that specific layer.
