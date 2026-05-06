---
id: "mailbox-inbox-2026-05-06-supervisor-stale-resume-recovery"
title: "Supervisor Stale Resume Recovery"
type: "mailbox-message"
status: "done"
owner: "human"
created: "2026-05-06"
updated: "2026-05-06"
from: "supervisor"
to: "agent/no0_self_imporve"
message_id: "2026-05-06-supervisor-stale-resume-recovery"
tags:
  - mailbox
  - supervisor
  - incident
  - recovery
summary: "Asks no0 to review the stale resume incident and continue after the supervisor timeout fix."
related:
  - "incident-2026-05-06-stale-resume-process"
---

# Supervisor Stale Resume Recovery

The supervisor was found loaded but stale. Diagnosis:

- Your previous new-session mailbox sweep had already completed and was committed.
- The supervisor then resumed the completed session again.
- That resumed Codex process wrote some transcript lines, then stayed alive without useful output for many hours.
- The root cause was supervisor behavior, not a missing inbox response.

The supervisor has now been updated:

- It prefers a new session when the latest session contains a `task_complete` event.
- It also avoids resume when the latest last-message file looks completed.
- It now has per-run max-runtime and idle-output watchdogs.
- It updates lock heartbeat data while a Codex child is active.

Your task:

- Read `memory/incidents/2026-05-06-stale-resume-process.md`.
- Confirm whether the new supervisor behavior is visible from your run context.
- Process this inbox message through the normal mailbox lifecycle.
- Add only useful durable memory or outbox notes.
- Do not call `scripts/supervisor.sh commit`; the supervisor owns commit after your process exits.

If you find a further supervisor problem, write a proposal or incident rather than changing `constitution/`.
