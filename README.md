---
id: "readme-self-harness"
title: "Bagaking Self-Harness"
type: "readme"
status: "active"
owner: "shared"
created: "2026-05-08"
updated: "2026-05-08"
tags:
  - readme
  - self-harness
  - codex
summary: "Repository-facing overview of the self-harness workspace, scripts, boundaries, and current operating status."
---

# Bagaking Self-Harness

This repository is a small, file-based evolution workspace for Codex-driven
agents. It treats the repository itself as durable agent state: instructions,
constitutional rules, mailbox messages, memory notes, reusable skills, and
session records may be reviewed as part of git history after redaction and
commit-gate checks.

The project does not try to provide a full agent runtime. Codex is the runtime.
The scripts in `scripts/` are the control plane for layout setup, document
discovery, documentation checks, supervisor launches, and commit-gate checks.

## Current State

This is an early self-harness workspace, not a production-ready automation
platform.

What is present now:

- Human-owned constitutional rules under `constitution/`.
- Repository boot instructions in `AGENTS.md`.
- Shell and Python scripts for initialization, document querying, documentation
  validation, skill validation, and supervisor orchestration.
- Durable state directories for mailbox and memory.
- Local-only runtime space created by `scripts/init.sh` under `.self-harness/`
  and `.codex/`.

What is intentionally not promised:

- No general-purpose agent runtime independent of Codex.
- No guarantee that supervisor behavior is safe for unattended production use.
- No guarantee that every script works outside the expected local developer
  environment.
- No manual canonical document index. Discovery is script-based.
- No agent authority to modify `constitution/`.

## Repository Layout

```text
AGENTS.md              Short boot instructions for agents.
constitution/          Human-owned, read-only local authority.
mailbox/               File-based inbox, processing, outbox, done, and failed state.
memory/                Agent-authored durable notes, diaries, lessons, proposals, and incidents.
scripts/               Deterministic setup, query, validation, supervisor, and helper scripts.
skills/                Reusable agent capabilities; created by init when absent.
sessions/              Codex session records; created by init when absent.
.codex/                Local Codex home with symlinks to skills and sessions; ignored by git.
.self-harness/         Local private scratch, runtime locks, temp files, and logs; ignored by git.
```

Important ownership rules:

- `constitution/` is human-owned and read-only for agents.
- `scripts/` is high-risk control-plane code; change it only for small,
  directly necessary, reviewed changes.
- `memory/`, `mailbox/`, `skills/`, and reviewed `sessions/` records are
  repository-visible agent state and should not be hidden with broad ignore
  rules. Session records must still be checked for secrets and local-machine
  details before publication.
- Temporary, private, or experimental work belongs under `.self-harness/`.
- Durable repository content should use repository-relative paths and avoid
  machine-specific details.

## Common Commands

Initialize the local layout:

```bash
scripts/init.sh
```

This creates expected durable directories when absent, creates `.self-harness/`
scratch/run directories, and ensures:

```text
.codex/skills -> ../skills
.codex/sessions -> ../sessions
```

Query Markdown documents by scope and text:

```bash
scripts/query-docs.sh constitution supervisor
scripts/query-docs.sh memory mailbox
scripts/query-docs.sh all frontmatter
```

Run documentation checks:

```bash
scripts/docs-check.sh
```

The docs check validates required Markdown frontmatter outside exempted paths,
detects duplicate document ids, rejects forbidden `index.md` files, checks that
`constitution/` has no symlinks, and verifies the `.codex` symlinks created by
`scripts/init.sh`.

Validate one skill directory:

```bash
python3 scripts/skill-quick-validate.py skills/example-skill
```

This checks basic `SKILL.md` frontmatter shape. PyYAML is optional; without it,
the script falls back to a conservative parser that supports only simple YAML
mappings.

Inspect supervisor plan or status:

```bash
scripts/supervisor.sh plan
scripts/supervisor.sh status
```

Run one supervised Codex pass:

```bash
scripts/supervisor.sh once
```

Start or stop the supervisor loop:

```bash
scripts/supervisor.sh start
scripts/supervisor.sh stop
```

On macOS with `launchctl`, `start` uses launchd. Otherwise it starts a
background loop with a pidfile under `.self-harness/run/`.

Run the supervisor commit gate and commit staged or unstaged repository changes:

```bash
scripts/supervisor.sh commit
```

Agents should not call `git add` or `git commit` directly during supervised
runs. The supervisor is responsible for staging, commit-gate checks, and
committing after Codex exits. This command stages all unignored repository
changes, so inspect `git status --short` first when running it manually.

## Environment Notes

The scripts assume a local developer environment with:

- Bash.
- `git`.
- `rg` from ripgrep for document query and check helpers.
- `python3` for `scripts/skill-quick-validate.py`.
- Codex CLI for `scripts/supervisor.sh once`, `loop`, resume, and repair flows.
- macOS `launchctl` only if using launchd-backed `scripts/supervisor.sh start`.

Supervisor behavior can be adjusted with environment variables documented by:

```bash
scripts/supervisor.sh --help
```

Notable variables include loop interval, resume heuristics, Codex runtime and
idle timeouts, automatic progressive challenge behavior, extra Codex arguments,
and post-run commit skipping.

## Boundaries

`constitution/` is the highest local repository authority after platform,
system, developer, and explicit user instructions. Agents must not modify,
delete, rename, move, or auto-format files under `constitution/`. If a
constitutional change seems necessary, write a proposal under `memory/proposals/`
or `mailbox/outbox/` instead.

The self-harness is designed to stay small:

- Deterministic control belongs in `scripts/`.
- Evolving behavior belongs in `skills/` and `memory/`.
- Communication belongs in `mailbox/`.
- Human intent and hard boundaries belong in `constitution/`.
- Local private state belongs only in `.self-harness/`.

The repository should remain portable. Durable files should avoid absolute local
paths, hostnames, usernames, home directories, secrets, runtime locks, and
temporary scratch output.
