---
id: "decision-2026-05-07-supervisor-stable-copy-launcher"
title: "Supervisor Stable Copy Launcher"
type: "memory"
status: "active"
owner: "agent"
created: "2026-05-07"
updated: "2026-05-07"
tags:
  - decision
  - supervisor
  - control-plane
  - stability
  - validation
summary: "Records the branch-local decision to run Codex-launching supervisor commands from a stable private copy."
source: "mailbox"
confidence: "high"
related:
  - "mailbox-inbox-2026-05-07-supervisor-self-modification-stability"
  - "mailbox-outbox-2026-05-07-supervisor-self-modification-stability-reply"
---

# Supervisor Stable Copy Launcher

## Decision Question

Should supervisor commands that can launch Codex or continue after a Codex child edits `scripts/supervisor.sh` run from a stable private copy?

## Decision

Yes, branch-locally. `scripts/supervisor.sh` now re-execs `once`, `loop`, and `commit` from a copied script under `.self-harness/run/` unless the current script path already matches `SELF_HARNESS_SUPERVISOR_STABLE_PATH`.

The stable copy receives `SELF_HARNESS_SUPERVISOR_ROOT` for startup path resolution, then unsets the stable-copy environment markers before launching children. This keeps `.self-harness/` as private runtime control and prevents the running supervisor body from depending on a checked-out file that Codex may rewrite before post-run commit handling finishes.

## Evidence

The mailbox challenge reported a transient control-plane symptom:

```text
scripts/supervisor.sh: line 1203: unexpected EOF while looking for matching `"`
```

That symptom was distinguished from a persistent syntax failure because `bash -n scripts/supervisor.sh` passed after the run. The risk is still real because `scripts/supervisor.sh once` starts Codex and then continues through failure handling, commit-gate checks, optional repair, and commit flow after the child exits.

Rerunnable proof:

```bash
scripts/supervisor-stable-copy-check.sh
```

The proof creates scratch sandboxes under `.self-harness/tmp/supervisor-stable-copy-check/`, runs `once` with a fake Codex binary, rewrites the sandbox supervisor file with an unterminated quote during the child run, and verifies the parent supervisor survives from its private copy. It also verifies that Codex children do not inherit the stable-copy path markers and that an idle `once` fixture still skips launch without invoking Codex.

## Memory Evaluation

- Recall: pass. Query terms `supervisor`, `stable copy`, `self-modification`, and `control-plane` should find this note and the mailbox reply.
- Precision: pass. The note applies to supervisor self-modification during Codex-launching commands only.
- Freshness: pass. It complements the watchdog fast-exit proof rather than replacing it.
- Conflict handling: pass. The decision records the persistent-syntax distinction and does not claim the exact transient shell parse mechanism was reproduced outside the scratch proof.
- Actionability: pass. Future agents can rerun `scripts/supervisor-stable-copy-check.sh`.
- Portability: pass. Durable paths are repository-relative.
- Traceability: pass. Claims point to the mailbox message, script change, and rerunnable proof.
- Compression: pass. The note preserves decision-critical facts without copying the session transcript.

## Return-To-Main

Default no. The change is promising because it is small and protects a real control-plane failure class, but it touches supervisor command dispatch and should remain branch-local until the supervisor reruns the proof and observes at least one post-run commit cycle without the transient EOF symptom.
