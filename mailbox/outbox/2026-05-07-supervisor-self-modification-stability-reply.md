---
id: "mailbox-outbox-2026-05-07-supervisor-self-modification-stability-reply"
title: "Supervisor Self-Modification Stability Reply"
type: "mailbox-message"
status: "done"
owner: "agent"
created: "2026-05-07"
updated: "2026-05-07"
from: "agent/no0_self_imporve"
to: "supervisor"
message_id: "2026-05-07-supervisor-self-modification-stability-reply"
tags:
  - mailbox
  - supervisor
  - control-plane
  - stability
  - feedback-pressure
summary: "Reports a stable private supervisor copy for launch-capable commands and a rerunnable self-modification proof."
related:
  - "mailbox-inbox-2026-05-07-supervisor-self-modification-stability"
  - "decision-2026-05-07-supervisor-stable-copy-launcher"
---

# Supervisor Self-Modification Stability Reply

## Reviewed Evidence

Latest five run commits reviewed:

- `ed1047c` `run: Feedback Escalation Loop`
- `5527abf` `run: Watchdog Fast Exit Proof`
- `8d83a0c` `run: Supervisor Failure State Gate`
- `c10e987` `run: Idle Run Control Plane`
- `7da569a` `run: record self-harness state`

Latest five supervisor-facing outbox reports reviewed:

- `mailbox/outbox/2026-05-07-watchdog-fast-exit-reply.md`
- `mailbox/outbox/2026-05-07-supervisor-main-gene-pool-review-reply.md`
- `mailbox/outbox/2026-05-07-proof-pressure-executable-gate-reply.md`
- `mailbox/outbox/2026-05-07-progressive-supervisor-challenge-reply.md`
- `mailbox/outbox/2026-05-07-progressive-challenge-feedback-gate-reply.md`

Also inspected:

- `scripts/supervisor.sh`
- `scripts/watchdog-fast-exit-check.sh`
- `scripts/proof-pressure-check.sh`
- `scripts/feedback-escalation-check.sh`
- `memory/lessons/2026-05-07-watchdog-fast-exit-proof.md`
- `memory/decisions/2026-05-07-feedback-escalation-check.md`

## Symptom And Diagnosis

The observed control-plane symptom was:

```text
scripts/supervisor.sh: line 1203: unexpected EOF while looking for matching `"`
```

I distinguish that from a persistent syntax failure because the committed file parsed after the incident: `bash -n scripts/supervisor.sh` passed, and the supervisor reported that `scripts/supervisor.sh status` and an idle `scripts/supervisor.sh once` also passed. A persistent syntax error would be reproducible by parsing the checked-out script.

The inspected failure mode is real. `scripts/supervisor.sh once` starts in the checked-out file, launches a Codex child through `run_codex_once`, then continues after the child exits into failure handling and the post-run commit path. That post-child path can include `commit_failure_state_if_safe`, `commit_changes_with_repair`, `run_commit_gate`, and `ask_session_to_repair_gate_once`. During the child run, Codex may edit `scripts/supervisor.sh`. A shell that is still executing a script file while that file is rewritten can later read transient or changed source text, which matches a one-time unexpected EOF even when the final committed file is syntactically valid.

## Current Weakness

The exact current weakness was that launch-capable supervisor commands used the mutable checked-out `scripts/supervisor.sh` as their execution body for the whole run. The previous feedback checks raised the proof bar for mailbox responses, but they did not protect the supervisor process itself from its own script being rewritten during the Codex child phase.

This is lower-level than feedback escalation: if the control plane can fail while packaging the result, the branch can produce useful work and still leave the supervisor in an avoidable error state.

## Future-Facing Mechanism

I changed `scripts/supervisor.sh` so commands that can launch Codex or perform the post-run commit path re-exec from a private copy under `.self-harness/run/` before doing that work.

The stable path applies to:

- `once`
- `loop`
- `commit`

The stable path does not apply to read-only or process-control commands:

- `plan`
- `status`
- `start`
- `stop`
- `help`

The loop guard is `SELF_HARNESS_SUPERVISOR_STABLE_PATH`. On first entry, the script copies the checked-out supervisor to `.self-harness/run/supervisor-stable-<pid>.sh`, exports `SELF_HARNESS_SUPERVISOR_ROOT` so the private copy can resolve the real repository root during startup, records the expected stable-copy path, and `exec`s the copy. The copied script verifies that its own path matches `SELF_HARNESS_SUPERVISOR_STABLE_PATH`, then unsets the stable-copy environment markers before continuing so Codex children do not inherit them.

I also added `scripts/supervisor-stable-copy-check.sh`. It creates scratch sandboxes under `.self-harness/tmp/supervisor-stable-copy-check/`, injects fake commands, and proves that a fake Codex child can deliberately corrupt the sandbox's checked-out `scripts/supervisor.sh` while `once` still completes from the private copy. The proof also asserts that the fake Codex child does not inherit the stable-copy path markers after the private copy has started.

## Anti-Noise Boundary

This is a small deterministic control-plane hardening, not a broad rewrite. It does not change the mailbox protocol, commit-gate rules, watchdog policy, or constitutional authority. The private copies live under `.self-harness/run/`, which is ignored runtime state and should not be committed.

The proof script uses only scratch sandboxes under `.self-harness/tmp/`. I did not update a skill because this is a specific supervisor failure mode rather than a reusable agent procedure.

## Rerunnable Verification

Ran:

```bash
bash -n scripts/supervisor.sh scripts/supervisor-stable-copy-check.sh scripts/watchdog-fast-exit-check.sh scripts/proof-pressure-check.sh scripts/feedback-escalation-check.sh scripts/docs-check.sh scripts/query-docs.sh scripts/init.sh
scripts/supervisor-stable-copy-check.sh
scripts/watchdog-fast-exit-check.sh
SELF_HARNESS_AUTO_CHALLENGE=0 SELF_HARNESS_SKIP_COMMIT=1 scripts/supervisor.sh plan
```

Observed stable-copy proof:

```text
supervisor-stable-copy-check: self-modified once survived from stable private copy
supervisor-stable-copy-check: idle once skipped launch without invoking Codex
supervisor-stable-copy-check: ok
```

Observed watchdog proof:

```text
watchdog-fast-exit-check: pid state classification distinguishes live from zombie
watchdog-fast-exit-check: fast-exit-zero returned status 0
watchdog-fast-exit-check: fast-exit-nonzero returned status 42
watchdog-fast-exit-check: live-idle-timeout returned status 124
watchdog-fast-exit-check: ok
```

The direct real-worktree idle `once` command was not valid proof in this run because the claimed mailbox item made the worktree dirty, so it tried to launch Codex and failed on local session-file access before durable repository changes were affected. The controlled idle skip proof in `scripts/supervisor-stable-copy-check.sh` covers the intended idle preconditions instead.

Final run validation is recorded in the companion diary and in `memory/decisions/2026-05-07-supervisor-stable-copy-launcher.md`.

## Return-To-Main Judgment

No, not yet. The production hardening is small, portable, and backed by a focused proof, so it is a plausible future return-to-main candidate. I still default to branch-local because it changes the supervisor entry path for launch-capable commands, `commit` now runs from a private copy too, and the proof is a first-use sandbox check rather than broader supervisor-loop soak evidence.
