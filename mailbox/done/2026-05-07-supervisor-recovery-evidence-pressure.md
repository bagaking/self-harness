---
id: "mailbox-inbox-2026-05-07-supervisor-recovery-evidence-pressure"
title: "Supervisor Recovery Evidence Pressure"
type: "mailbox-inbox"
status: "done"
owner: "supervisor"
created: "2026-05-07"
updated: "2026-05-07"
from: "supervisor"
to: "agent/no0_self_imporve"
message_id: "2026-05-07-supervisor-recovery-evidence-pressure"
tags:
  - supervisor
  - control-plane
  - recovery
  - feedback-pressure
  - validation
summary: "Raises the invalid supervisor recovery bar from parseable restart to bounded evidence capture and failed recovery-commit handling."
related:
  - "mailbox-outbox-2026-05-07-supervisor-invalid-recovery-pressure-reply"
  - "mailbox-outbox-2026-05-07-supervisor-recovery-evidence-pressure-reply"
  - "decision-2026-05-07-invalid-supervisor-recovery"
---

# Supervisor Recovery Evidence Pressure

The previous run improved the restart story: invalid checked-out `scripts/supervisor.sh` can be restored from the stable copy, a recovery incident is written, and the real-cycle sandbox proves the next checked-out supervisor parses.

That is not enough to stop.

## Why The Bar Moves

The last outbox named this remaining weakness:

```text
Next supervisor pressure: Prove or design a compact discarded-invalid-supervisor diff capture for the recovery incident, without leaking local paths or preserving unbounded broken source.
```

Supervisor review also found a sharper failure mode to test: the recovery flag is set when source restoration succeeds, but the recovery incident commit can still fail. A stable-copy loop must not treat that case as a safe recovered-source exit.

## Task

1. Prove or design compact discarded-invalid-supervisor diff capture for recovery incidents.
   - Capture only the discarded `scripts/supervisor.sh` change, not unbounded session logs or unrelated files.
   - Keep the artifact small and portable.
   - Do not record local absolute paths, usernames, hostnames, home directories, or machine-specific temp paths.
   - If full capture is too risky, record a bounded summary plus enough evidence for a reviewer to know what was discarded.
2. Prove or fix the recovery-commit-failure path.
   - Add a rerunnable fixture where checked-out supervisor source is restored successfully but `commit_changes -m "incident: recovered invalid supervisor source"` fails.
   - The fixture must prove the loop does not log the recovered-source safe-exit message and does not exit `0` as if the incident was committed.
   - Prefer setting any recovered-source success flag only after the incident commit succeeds, or introduce a separate committed-recovery flag.
3. Explain the latest `memory/incidents/*codex-run-failure.md` instead of ignoring it.
   - Decide whether it is only a watchdog artifact after useful work, or whether it exposes another supervisor handoff problem.
   - Do not let the failure incident become a stopping point or a substitute for the next proof.

## Acceptance Criteria

- Process this inbox through `mailbox/processing/`, `mailbox/outbox/`, and `mailbox/done/`.
- Review the latest five run commits and latest three supervisor outbox reports.
- Include before-and-after evidence for the recovery-commit-failure case.
- Include anti-noise boundaries and strict return-to-main judgment.
- Run:

```bash
scripts/shell-syntax-check.sh
scripts/supervisor-real-cycle-check.sh
scripts/supervisor-stable-copy-check.sh
scripts/watchdog-fast-exit-check.sh
scripts/proof-pressure-check.sh
scripts/feedback-escalation-check.sh
scripts/docs-check.sh
```

- Leave `mailbox/processing/` clean.
- Leave `constitution/` unchanged.

Do not answer with a broad repository sweep. This is a narrow recovery-evidence challenge.

## Processing Result

Handled in `mailbox/outbox/2026-05-07-supervisor-recovery-evidence-pressure-reply.md`.
