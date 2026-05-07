---
title: "Operating Model"
id: "constitution-10-operating-model"
type: "constitution"
status: "active"
owner: "human"
protected: true
authority: "constitutional"
mutable_by: "human-only"
created: "2026-05-05"
updated: "2026-05-07"
tags:
  - operating-model
  - supervisor
  - codex
  - lifecycle
summary: "Defines the minimal runtime loop for launching Codex, choosing resume or new sessions, and keeping repository state coherent."
---

# Operating Model

## Runtime Shape

The self-harness uses Codex itself as the agent runtime. Scripts provide only the deterministic control plane needed to start Codex, prevent duplicate runs, expose local state, and enforce hard repository boundaries.

The local Codex home is `./.codex`. Initialization must keep these symlinks valid:

- `./.codex/skills -> ../skills`
- `./.codex/sessions -> ../sessions`

The existing `scripts/init.sh` is the idempotent setup entry point for these links. The current supervisor entry point is `scripts/supervisor.sh`.

## Supervisor Loop

The supervisor script should run as a small, reentrant state machine:

```text
idle
  -> acquire_repo_lock
  -> verify_layout
  -> inspect_active_codex
  -> inspect_latest_session
  -> choose_resume_or_new
  -> launch_codex_with_project_home
  -> process_mailbox
  -> update_memory_and_skills
  -> write_gfm_diary
  -> codex_exit
  -> run_commit_gate
  -> commit_or_report
  -> release_lock
```

Failure states must be explicit:

- `lock_stale`
- `dirty_forbidden_paths`
- `mailbox_conflict`
- `codex_exit_nonzero`
- `commit_gate_failed`
- `layout_invalid`
- `session_state_unknown`

In failure states, the supervisor should write a report under `memory/incidents/` or `mailbox/outbox/` and avoid making an autonomous commit unless the commit gate explicitly allows the failure report.

The supervisor must be boring and conservative. It should not try to become an agent.

Codex produces durable repository state. The supervisor owns staging and committing after the Codex process exits. Codex runs should not call `git add` or `git commit` directly; this keeps `.git/` writes in the deterministic control plane and lets the supervisor include the completed session transcript in the same commit.

The supervisor is still responsible for pressure. A running loop is not progress by itself. When branch feedback shows that the agent is producing low-value sweeps, repeated no-pending mailbox reports, or other passive state records, the supervisor should convert that feedback into a narrower and harder mailbox challenge before launching another run. Good challenges ask for proof, comparison, evaluation, failed-case analysis, or a small reusable improvement; they should not merely ask the agent to inspect the repository again.

If there is no pending inbox message and recent commits are only state sweeps, the supervisor should prefer creating a progressive challenge under `mailbox/inbox/` over letting the next run produce another no-pending report. The challenge must remain branch-local unless a human explicitly changes global rules. The supervisor should record why the next demand is higher than the previous one.

## Resume Versus New

Resume is preferred only when it is likely to preserve useful context without causing context-window exhaustion. Until an exact parser exists, the supervisor may use conservative heuristics such as session recency, file size, message count, and last known completion status.

New sessions are preferred when the previous session is old, too large, clearly completed, interrupted in an unknown state, or close to context exhaustion.

When starting a new session, the boot prompt must require the agent to:

- Read `AGENTS.md` and the relevant constitutional documents.
- Use `scripts/query-docs.sh` instead of relying on hand-maintained indexes.
- Inspect repository state before acting.
- Read pending `mailbox/inbox/` messages.
- Write replies or reports under `mailbox/outbox/`.
- Update `memory/` when useful.
- Improve `skills/` only when a reusable procedure is discovered.
- Treat repeated no-pending or repository-state reports as insufficient progress; if no inbox is pending, explain what harder self-improvement question should be sent to the supervisor rather than manufacturing another broad sweep.
- Avoid all modifications under `constitution/`.
- Produce a GFM diary suitable for use as the git commit message.
- Leave staging and committing to `scripts/supervisor.sh`.

## Process Identity

The supervisor must distinguish self-harness Codex processes from unrelated user Codex processes. It should not rely only on process names.

Recommended identity signals include:

- A repository-local lock file.
- The intended `CODEX_HOME` or equivalent home/config setting.
- The repository root path.
- A pidfile with command-line metadata.
- A heartbeat timestamp.

If the lock says a process is active but the process is gone, the supervisor may recover the lock. If the process exists but the heartbeat is stale, it should report the condition rather than blindly killing work.

The lock should record at least:

```yaml
pid: 12345
command: "codex ..."
session_id: "..."
mode: "resume | new"
started_at: "YYYY-MM-DDTHH:MM:SSZ"
heartbeat_at: "YYYY-MM-DDTHH:MM:SSZ"
repo: "/absolute/path/to/repo"
codex_home: "/absolute/path/to/repo/.codex"
```

Lock acquisition must be atomic. Rerunning the supervisor must be safe: it should either observe the current run, recover clearly stale state, or produce an incident report.
