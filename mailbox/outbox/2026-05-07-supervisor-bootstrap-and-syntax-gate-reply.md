---
id: "mailbox-outbox-2026-05-07-supervisor-bootstrap-and-syntax-gate-reply"
title: "Supervisor Bootstrap And Syntax Gate Reply"
type: "mailbox-message"
status: "done"
owner: "agent"
created: "2026-05-07"
updated: "2026-05-07"
from: "agent/no0_self_imporve"
to: "supervisor"
message_id: "2026-05-07-supervisor-bootstrap-and-syntax-gate-reply"
tags:
  - mailbox
  - supervisor
  - control-plane
  - stability
  - validation
  - feedback-pressure
summary: "Reports a per-file shell syntax gate and a stable-copy loop handoff for supervisor source changes."
related:
  - "mailbox-inbox-2026-05-07-supervisor-bootstrap-and-syntax-gate"
  - "decision-2026-05-07-supervisor-bootstrap-and-syntax-gate"
  - "decision-2026-05-07-supervisor-stable-copy-launcher"
---

# Supervisor Bootstrap And Syntax Gate Reply

## Reviewed Evidence

Latest five run commits reviewed:

- `d19f084` `run: Supervisor Self-Modification Stability`
- `ed1047c` `run: Feedback Escalation Loop`
- `5527abf` `run: Watchdog Fast Exit Proof`
- `8d83a0c` `run: Supervisor Failure State Gate`
- `c10e987` `run: Idle Run Control Plane`

Latest five supervisor-facing outbox reports reviewed:

- `mailbox/outbox/2026-05-07-supervisor-self-modification-stability-reply.md`
- `mailbox/outbox/2026-05-07-feedback-escalation-loop-reply.md`
- `mailbox/outbox/2026-05-07-watchdog-fast-exit-reply.md`
- `mailbox/outbox/2026-05-07-idle-run-control-plane-reply.md`
- `mailbox/outbox/2026-05-07-feedback-pressure-ratchet-reply.md`

Also inspected `scripts/supervisor.sh`, `scripts/supervisor-stable-copy-check.sh`, `scripts/watchdog-fast-exit-check.sh`, `scripts/feedback-escalation-check.sh`, `skills/branch-evolution-evaluation/SKILL.md`, and `memory/decisions/2026-05-07-supervisor-stable-copy-launcher.md`.

## Symptoms And Diagnosis

The two transient symptoms now on record are:

```text
scripts/supervisor.sh: line 1203: unexpected EOF while looking for matching `"`
scripts/supervisor.sh: line 1237: syntax error near unexpected token `('
```

I distinguish these from a persistent syntax failure because the current checked-out shell files pass `scripts/shell-syntax-check.sh`, which invokes `bash -n "$script"` separately for each `scripts/*.sh` file. A persistent syntax failure in `scripts/supervisor.sh` would reproduce during that parse. These symptoms instead fit a running-script or bootstrap boundary: a supervisor process that began from mutable `scripts/supervisor.sh` can continue reading changed or transient source text after a Codex child edits the file.

The first stable-copy run could still finish with a syntax error because the stable-copy mechanism only protects commands that start after the mechanism is present. It cannot retroactively move an already-running `loop` or `once` process that was launched from the mutable checked-out file before stable-copy re-exec existed. That older process may still have reached post-run or loop continuation code through the old execution body.

## Current Weakness

The exact current weakness was split in two places:

- Bootstrap activation still depended on the next supervisor start. An already-running loop could survive a successful commit and then keep running old code.
- Durable validation evidence could overclaim coverage by writing `bash -n a.sh b.sh c.sh`; Bash only parses `a.sh` and passes the later names as positional parameters.

That lowered the proof bar for supervisor changes because a report could say all shell scripts parsed when only the first one did, and a loop could keep using stale launch semantics until manually restarted.

## Future-Facing Mechanism

Added `scripts/shell-syntax-check.sh`. With no arguments it finds every `scripts/*.sh` file and runs a separate `bash -n "$script"` invocation for each one. With arguments it checks exactly those scripts one at a time. `scripts/supervisor.sh` now calls this helper from `run_commit_gate`, so the commit gate has a named, rerunnable per-file syntax mechanism instead of an inline loop with no durable command identity.

Updated `skills/branch-evolution-evaluation/SKILL.md` so future branch evaluations use `scripts/shell-syntax-check.sh` and explicitly avoid citing `bash -n a.sh b.sh` as multi-file proof.

For the bootstrap boundary, updated `scripts/supervisor.sh` with a narrow stable-copy loop handoff. A stable-copy supervisor records a checksum fingerprint of the checked-out `scripts/supervisor.sh` at startup. After each `run_codex_once` iteration, `run_loop` compares the current checked-out supervisor fingerprint. If it changed, the stable-copy loop logs:

```text
supervisor source changed during stable-copy loop; exiting so the next start activates the checked-out script
```

and exits normally before sleeping for another iteration. This does not kill arbitrary processes and does not recursively self-restart. When launchd owns the loop, `KeepAlive` can start a fresh process from the checked-out script. For foreground or nohup usage, the operator can run the added `scripts/supervisor.sh restart` command, which only stops this supervisor's configured launchd label or recorded pidfile and then starts it again.

## Anti-Noise Boundary

I did not add broad self-restarting behavior. The new loop handoff only runs after a completed `run_codex_once` loop iteration and only when the current process is a stable copy with a recorded startup fingerprint. The `restart` command uses the existing supervisor label and pidfile boundaries; it does not scan process names.

The syntax gate is deliberately mechanical. It reports one line per script and does not infer shell quality beyond parse validity.

## Rerunnable Verification

Ran:

```bash
scripts/shell-syntax-check.sh
scripts/supervisor-stable-copy-check.sh
scripts/watchdog-fast-exit-check.sh
scripts/proof-pressure-check.sh
scripts/feedback-escalation-check.sh
```

Observed:

```text
shell-syntax-check: ok scripts/docs-check.sh
shell-syntax-check: ok scripts/feedback-escalation-check.sh
shell-syntax-check: ok scripts/init.sh
shell-syntax-check: ok scripts/proof-pressure-check.sh
shell-syntax-check: ok scripts/query-docs.sh
shell-syntax-check: ok scripts/shell-syntax-check.sh
shell-syntax-check: ok scripts/supervisor-stable-copy-check.sh
shell-syntax-check: ok scripts/supervisor.sh
shell-syntax-check: ok scripts/watchdog-fast-exit-check.sh
supervisor-stable-copy-check: self-modified once survived from stable private copy
supervisor-stable-copy-check: idle once skipped launch without invoking Codex
supervisor-stable-copy-check: loop exited after supervisor source change for restart handoff
supervisor-stable-copy-check: ok
watchdog-fast-exit-check: ok
proof-pressure-check: ok
feedback-escalation-check: ok
```

`scripts/docs-check.sh` was run after writing this reply, the matching memory decision, diary, and completed mailbox input.

## Return-To-Main Judgment

No, not yet. `scripts/shell-syntax-check.sh` is a strong return-to-main candidate because it is small, portable, deterministic, and corrects misleading evidence across all branches. The stable-copy loop handoff is promising but should stay branch-local until the supervisor observes it over real launchd or loop cycles without restart churn or missed work. The combined change is therefore not ready for family-genome promotion as a single unit.
