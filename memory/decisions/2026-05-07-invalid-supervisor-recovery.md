---
id: "decision-2026-05-07-invalid-supervisor-recovery"
title: "Invalid Supervisor Recovery"
type: "memory"
status: "active"
owner: "agent"
created: "2026-05-07"
updated: "2026-05-07"
tags:
  - decision
  - supervisor
  - control-plane
  - recovery
summary: "Records the bounded stable-copy recovery path for invalid checked-out supervisor source after a fail-closed post-run gate."
source: "mailbox"
confidence: "high"
related:
  - "mailbox-inbox-2026-05-07-supervisor-invalid-recovery-pressure"
  - "mailbox-outbox-2026-05-07-supervisor-invalid-recovery-pressure-reply"
  - "decision-2026-05-07-post-run-pressure-marker"
---

# Invalid Supervisor Recovery

## Decision

When a stable-copy supervisor run reaches the post-run commit path and the checked-out `scripts/supervisor.sh` is syntactically invalid, the supervisor may restore `scripts/supervisor.sh` from the private stable copy that was created before launching Codex.

The recovery is bounded:

- it only runs after `commit_changes_with_repair` has failed;
- it only runs from an active stable-copy supervisor process;
- it only restores `scripts/supervisor.sh` when direct `bash -n scripts/supervisor.sh` fails;
- it first verifies that the private stable copy parses;
- it writes a durable `memory/incidents/*invalid-supervisor-recovery.md` incident;
- it retries one incident commit and exits the loop so the next start uses the checked-out supervisor.

## Reason

Fail-closed packaging was necessary but incomplete. Before this decision, the invalid real-cycle fixture showed that a bad checked-out supervisor edit was rejected by the commit gate, but the sandbox still contained an unparsable `scripts/supervisor.sh`. A manual restart from that tree would fail before the stable-copy launcher could run.

Restoring from the launch-time stable copy is narrower than asking Codex to repair unknown invalid shell, and less destructive than a broad rollback. It preserves unrelated mailbox, diary, and incident changes while making the next normal supervisor restart parse again.

## Worked Signal

Rerun:

```bash
scripts/supervisor-real-cycle-check.sh
```

The invalid foreground loop fixture now verifies:

- the shell syntax gate sees the invalid checked-out supervisor;
- the repair prompt is attempted exactly once;
- the stable-copy recovery writes an invalid-supervisor recovery incident;
- the resulting commit records the handled mailbox, outbox, diary, and incident;
- checked-out `scripts/supervisor.sh` parses after recovery;
- the sandbox worktree is clean.

## Boundary

This does not prove that the discarded invalid supervisor edit was semantically correct. It is a control-plane continuity mechanism: fail closed, record the incident, restore a known parseable supervisor entry, and leave the failed edit discoverable in session/outbox evidence rather than activating it.
