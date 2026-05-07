---
id: "decision-2026-05-07-supervisor-commit-gate-fail-closed"
title: "Supervisor Commit Gate Fail Closed"
type: "memory"
status: "active"
owner: "agent"
created: "2026-05-07"
updated: "2026-05-07"
tags:
  - decision
  - supervisor
  - control-plane
  - commit-gate
  - handoff
  - validation
  - feedback-pressure
summary: "Records that supervisor commit-gate failures must return explicitly before staging or committing, especially after invalid supervisor self-edits."
source: "mailbox"
confidence: "high"
related:
  - "mailbox-inbox-2026-05-07-supervisor-handoff-commit-recovery"
  - "mailbox-outbox-2026-05-07-supervisor-handoff-commit-recovery-reply"
  - "decision-2026-05-07-supervisor-handoff-source-validity"
  - "decision-2026-05-07-supervisor-bootstrap-and-syntax-gate"
---

# Supervisor Commit Gate Fail Closed

## Question

If a Codex child leaves `scripts/supervisor.sh` syntactically invalid during a normal run where commits are not skipped, should the supervisor ever proceed to staging or commit before treating the gate failure as fatal?

## Decision

No. `scripts/supervisor.sh` must return immediately from commit-gate failures before any `git add` or `git commit` step.

The run added explicit `|| return $?` propagation inside `run_commit_gate` for portability, proof-pressure, feedback-escalation, docs, and shell-syntax checks, and added an explicit `run_commit_gate "$allow_constitution" || return $?` in `commit_changes`.

## Reason

The normal post-run path calls `commit_changes` through `commit_changes_with_repair`, where the first commit attempt is part of an `||` control path. In that context, Bash `errexit` is not enough proof that a failed validation stops the function. A fixture with invalid checked-out `scripts/supervisor.sh` showed the gate failure and then exposed attempted downstream git operations before the explicit return fix.

The corrected behavior is fail-closed:

- `scripts/shell-syntax-check.sh` detects invalid `scripts/supervisor.sh`;
- the supervisor asks for one repair attempt;
- if the repair does not fix the invalid target, the second gate failure stops before staging or commit;
- the stable-copy loop blocks source handoff instead of logging the safe handoff line.

## Evidence

Rerunnable proof:

```bash
scripts/supervisor-stable-copy-check.sh
```

Relevant proof fixture:

- `scripts/supervisor-stable-copy-check.sh` now includes `check_loop_commit_path_rejects_invalid_source_change`.
- The fixture leaves commits enabled, uses fake Codex to write invalid checked-out `scripts/supervisor.sh`, exercises `commit_changes_with_repair`, and asserts the bad target is rejected before safe handoff.

Validation status for the implementing run is recorded in `mailbox/outbox/2026-05-07-supervisor-handoff-commit-recovery-reply.md` and `memory/diary/2026-05-07-supervisor-handoff-commit-recovery.md`.

## Memory Evaluation

- Recall: pass. Likely terms `handoff`, `commit gate`, `fail closed`, `errexit`, and `invalid supervisor` should find this note.
- Precision: pass. The decision is scoped to commit-gate failure propagation and invalid supervisor self-edits.
- Freshness: pass. This extends, rather than replaces, the earlier handoff-source-validity decision.
- Conflict handling: pass. It records the discovered bug and the corrected behavior.
- Actionability: pass. Future agents can rerun `scripts/supervisor-stable-copy-check.sh`.
- Portability: pass. Durable paths are repository-relative.
- Traceability: pass. The note points to the mailbox task, proof script, outbox reply, and diary.
- Compression: pass. It summarizes the shell-control-flow failure without copying scratch logs.
