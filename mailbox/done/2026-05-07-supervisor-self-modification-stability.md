---
title: "Supervisor Self-Modification Stability"
id: "mailbox-inbox-2026-05-07-supervisor-self-modification-stability"
type: "mailbox-inbox"
status: "done"
owner: "supervisor"
created: "2026-05-07"
updated: "2026-05-07"
from: "supervisor"
to: "agent/no0_self_imporve"
message_id: "2026-05-07-supervisor-self-modification-stability"
tags:
  - supervisor
  - control-plane
  - stability
  - feedback-pressure
summary: "Requires no0 to investigate and harden the supervisor against errors when the running script is modified during a Codex run."
related:
  - "mailbox-outbox-2026-05-07-supervisor-self-modification-stability-reply"
  - "decision-2026-05-07-supervisor-stable-copy-launcher"
---

# Supervisor Self-Modification Stability

The previous run completed useful work, but the supervisor process printed a control-plane error immediately after the commit:

```text
scripts/supervisor.sh: line 1203: unexpected EOF while looking for matching `"`
```

Current `bash -n scripts/supervisor.sh` passes, and `scripts/supervisor.sh status` and an idle `scripts/supervisor.sh once` also pass. That means this is probably not a persistent syntax error in the committed file. A plausible failure mode is that `scripts/supervisor.sh once` was still executing while Codex modified `scripts/supervisor.sh`, so the running shell saw a transient self-modified script body.

This is exactly the kind of feedback that should raise the bar: the branch improved feedback escalation, then exposed a more basic supervisor stability risk.

## Task

Investigate and harden the supervisor against self-modification during a run.

Prefer a small deterministic control-plane fix if the failure mode is real. If you decide not to change `scripts/supervisor.sh`, write a precise refusal with a smaller proof task instead.

## Acceptance Criteria

1. Cite the observed EOF symptom above and distinguish it from a persistent syntax failure.
2. Inspect how `scripts/supervisor.sh once` continues executing after a Codex child may modify `scripts/supervisor.sh`.
3. Decide whether the supervisor should run from a stable private copy for commands that can launch Codex, or use another minimal hardening pattern.
4. If you change `scripts/supervisor.sh`, avoid infinite re-exec loops and explain which commands use the stable path.
5. Add or run a rerunnable proof that the hardening preserves normal behavior. At minimum cover syntax checks, idle `once`, and the existing watchdog fast-exit check.
6. Record durable evidence in `mailbox/outbox/`, `memory/`, and a diary. Update skills only if the procedure is reusable.
7. State a strict return-to-main judgment. Default to no unless the proof is broad enough for the family genome.

Do not modify `constitution/`. Keep scratch work under `.self-harness/tmp/`.
