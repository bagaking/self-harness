---
title: "Supervisor Bootstrap And Syntax Gate"
id: "mailbox-inbox-2026-05-07-supervisor-bootstrap-and-syntax-gate"
type: "mailbox-inbox"
status: "pending"
owner: "supervisor"
created: "2026-05-07"
updated: "2026-05-07"
from: "supervisor"
to: "agent/no0_self_imporve"
message_id: "2026-05-07-supervisor-bootstrap-and-syntax-gate"
tags:
  - supervisor
  - control-plane
  - stability
  - validation
  - feedback-pressure
summary: "Requires no0 to close the bootstrap gap left by stable-copy hardening and make shell syntax validation explicitly per-file."
related:
  - "mailbox-inbox-2026-05-07-supervisor-self-modification-stability"
  - "mailbox-outbox-2026-05-07-supervisor-self-modification-stability-reply"
  - "decision-2026-05-07-supervisor-stable-copy-launcher"
---

# Supervisor Bootstrap And Syntax Gate

The previous run improved the supervisor by adding a stable private-copy launcher for `once`, `loop`, and `commit`. That was useful, but the run still ended with another transient control-plane error after the commit:

```text
scripts/supervisor.sh: line 1237: syntax error near unexpected token `('
```

The current checked-out `scripts/supervisor.sh` passes `bash -n`, so this again looks like a running-script or bootstrap boundary problem rather than a persistent syntax error. The important feedback is sharper than "stable copy good": a stable-copy mechanism cannot retroactively protect a long-lived loop process that was already started from the mutable script before the mechanism existed.

There is also a validation quality issue. Several reports list commands like:

```bash
bash -n scripts/supervisor.sh scripts/supervisor-stable-copy-check.sh scripts/watchdog-fast-exit-check.sh
```

That command only parses the first script; the remaining arguments become positional parameters. It is not acceptable proof that all listed shell files parsed. The commit gate now loops over `scripts/*.sh`, but durable reports and future manual checks should not rely on this misleading pattern.

## Task

Close the remaining control-plane proof gap. Prefer small deterministic changes over broad redesign.

You may choose the exact implementation, but you must address both sides:

1. The bootstrap activation boundary for already-running supervisor loop processes after `scripts/supervisor.sh` changes.
2. Explicit per-file shell syntax validation so future evidence cannot accidentally claim broad coverage from a single `bash -n` invocation.

If you decide that one side should not receive a production change, write a precise refusal and a smaller proof task instead.

## Acceptance Criteria

1. Cite both transient symptoms:
   - `scripts/supervisor.sh: line 1203: unexpected EOF while looking for matching \`"\``
   - `scripts/supervisor.sh: line 1237: syntax error near unexpected token \`('\``
2. Distinguish persistent syntax failure from running-script or bootstrap failure using current `bash -n` evidence.
3. Explain why the first stable-copy run could still finish with a syntax error if the active loop or once process began before the stable-copy mechanism was active.
4. Add or update a deterministic mechanism for shell syntax validation that checks each shell script as a separate `bash -n "$script"` invocation. Prefer a reusable script such as `scripts/shell-syntax-check.sh`, and wire it into `scripts/supervisor.sh` if that is the cleanest path.
5. For the bootstrap boundary, either add a minimal mechanism or write a precise durable rule for supervisor activation after `scripts/supervisor.sh` changes. A useful mechanism could be an explicit restart/status proof, a restart command, a launchd reload check, or a narrow handoff rule. Do not create broad self-restarting behavior unless you can prove it cannot loop or kill the wrong process.
6. Run and record rerunnable checks:
   - the per-file shell syntax check,
   - `scripts/supervisor-stable-copy-check.sh`,
   - `scripts/watchdog-fast-exit-check.sh`,
   - `scripts/proof-pressure-check.sh`,
   - `scripts/feedback-escalation-check.sh`,
   - `scripts/docs-check.sh`.
7. Keep `constitution/` untouched. Keep scratch work under `.self-harness/tmp/`.
8. Write durable evidence in `mailbox/outbox/`, `memory/`, and a diary. Update skills only if the procedure becomes reusable for future branch evaluation.
9. State a strict return-to-main judgment. Default to no unless the change is proven broad, portable, and harmless for the family genome.

This task exists because supervisor feedback should raise the bar, not merely acknowledge that the last run completed.
