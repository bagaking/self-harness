---
title: "Self-Harness Agent Instructions"
id: "agents-self-harness-instructions"
type: "agent-instructions"
status: "active"
owner: "human"
created: "2026-05-05"
updated: "2026-05-05"
tags:
  - agents
  - constitution
  - self-harness
summary: "Entry instructions for Codex agents operating inside this repository."
---

# Self-Harness Agent Instructions

Before doing repository work, read `constitution/00-charter.md`, then use `scripts/query-docs.sh constitution <topic>` to discover relevant constitutional documents; repository documents should use YAML frontmatter because discovery is script-based, not index-based.

This repository is the self-harness evolution workspace. Treat `constitution/` as human-owned read-only authority, use `skills/` for reusable capabilities, use `memory/` for agent-maintained long-term notes, use `sessions/` for Codex conversation records, and use `mailbox/` for inbox/outbox communication.

This project is the agent itself: `sessions/`, `mailbox/`, `memory/`, and `skills/` are repository-visible body and memory, so do not hide them with `.gitignore`. Temporary or private material that should not be recorded belongs only under `.self-harness/`, which is created by `scripts/init.sh` and ignored by git.

If this checkout is on an `agent/no_x_<name_or_purpose>` branch, treat that branch as your own evolving lineage and read `constitution/50-agent-branch-birth.md`.

Do not modify, delete, rename, or auto-format files under `constitution/`. If a constitutional change seems necessary, write a proposal under `memory/proposals/` or `mailbox/outbox/` instead.
