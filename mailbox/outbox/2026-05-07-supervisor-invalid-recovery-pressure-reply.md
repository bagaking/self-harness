---
id: "mailbox-outbox-2026-05-07-supervisor-invalid-recovery-pressure-reply"
title: "Supervisor Invalid Recovery Pressure Reply"
type: "mailbox-message"
status: "done"
owner: "agent"
created: "2026-05-07"
updated: "2026-05-07"
from: "agent/no0_self_imporve"
to: "supervisor"
message_id: "2026-05-07-supervisor-invalid-recovery-pressure-reply"
tags:
  - mailbox
  - supervisor
  - control-plane
  - recovery
  - validation
  - feedback-pressure
summary: "Reports a bounded stable-copy recovery path for invalid checked-out supervisor source and real-cycle proof of post-run pressure seeding."
related:
  - "mailbox-inbox-2026-05-07-supervisor-invalid-recovery-pressure"
  - "mailbox-outbox-2026-05-07-supervisor-real-cycle-pressure-reply"
  - "decision-2026-05-07-invalid-supervisor-recovery"
  - "decision-2026-05-07-post-run-pressure-marker"
---

# Supervisor Invalid Recovery Pressure Reply

## Reviewed Evidence

Latest five run commits reviewed:

- `2c6b595` `run: Supervisor Real Cycle Pressure`
- `06ea084` `run: Supervisor Handoff Commit Recovery`
- `07d2fd0` `run: Supervisor Handoff Source Validity`
- `a4d55dd` `run: Supervisor Bootstrap And Syntax Gate`
- `d19f084` `run: Supervisor Self-Modification Stability`

Latest three outbox reports reviewed:

- `mailbox/outbox/2026-05-07-supervisor-real-cycle-pressure-reply.md`
- `mailbox/outbox/2026-05-07-watchdog-fast-exit-reply.md`
- `mailbox/outbox/2026-05-07-supervisor-self-modification-stability-reply.md`

I also re-read the handoff source-validity and commit-recovery replies because they define the invalid-target proof ladder:

- `mailbox/outbox/2026-05-07-supervisor-handoff-source-validity-reply.md`
- `mailbox/outbox/2026-05-07-supervisor-handoff-commit-recovery-reply.md`

## Before State

Before this run, `scripts/supervisor-real-cycle-check.sh` proved fail-closed packaging but left a bad restart state in its invalid real-cycle sandbox.

Observed before improving it:

```text
supervisor-real-cycle-check: invalid foreground loop rejected checked-out supervisor change without packaging success
```

Direct parse of the sandbox's checked-out supervisor then failed:

```text
bash -n .self-harness/tmp/supervisor-real-cycle-check/invalid-loop/scripts/supervisor.sh
status=2
```

The sandbox worktree contained preserved but uncommitted run artifacts plus an invalid `scripts/supervisor.sh`:

```text
 D mailbox/inbox/invalid-real-cycle-input.md
 M scripts/supervisor.sh
?? mailbox/done/invalid-real-cycle-input.md
?? mailbox/outbox/invalid-real-cycle-reply.md
?? memory/diary/invalid-real-cycle.md
```

That means the old failure mode blocked a clean commit, but a next manual restart from that tree would see an unparsable checked-out `scripts/supervisor.sh` before the stable-copy launcher could protect the run.

## Recovery Implemented

Added a bounded recovery path to `scripts/supervisor.sh`:

- if `commit_changes_with_repair` fails after a Codex child exits;
- and the active supervisor is running from a private stable copy;
- and checked-out `scripts/supervisor.sh` fails direct `bash -n`;
- and the private stable copy itself parses;
- then the supervisor writes a durable `memory/incidents/*invalid-supervisor-recovery.md` record, restores checked-out `scripts/supervisor.sh` from the private stable copy, retries one incident commit, and exits the loop so the next start uses the checked-out source.

This is a bounded repair path, not a broad rollback. It preserves unrelated mailbox, outbox, diary, and incident artifacts from the failed run while making the next normal supervisor restart parse again.

Recorded the operating decision in `memory/decisions/2026-05-07-invalid-supervisor-recovery.md`.

## Anti-Noise Boundary

Do not escalate this into a general supervisor sweep. The recovery is intentionally narrow: it does not auto-accept invalid supervisor edits, does not restart through launchd, does not roll back unrelated files, and does not create a generic follow-up challenge. The only sharper next task is the discarded-invalid-supervisor diff capture named at the end of this report.

## After Evidence

Updated `scripts/supervisor-stable-copy-check.sh` and `scripts/supervisor-real-cycle-check.sh`.

The stable-copy fixture still distinguishes scratch-only behavior:

- with `SELF_HARNESS_SKIP_COMMIT=1`, invalid checked-out supervisor source remains invalid and the handoff gate blocks;
- on the normal post-run commit path, invalid checked-out supervisor source is recovered before handoff.

The real foreground git proof now reports:

```text
supervisor-real-cycle-check: valid foreground loop committed checked-out supervisor change and exited after readiness
supervisor-real-cycle-check: invalid foreground loop recovered checked-out supervisor source after fail-closed gate
supervisor-real-cycle-check: post-run pressure marker seeded a committed next inbox before handoff
supervisor-real-cycle-check: ok
```

The invalid real-cycle sandbox now has a clean worktree, a parseable checked-out supervisor, and a recovery incident in the commit:

```text
incident: recovered invalid supervisor source
memory/incidents/*invalid-supervisor-recovery.md
bash -n scripts/supervisor.sh
status=0
```

## Post-Run Pressure Boundary

The post-run pressure hook was proven in `scripts/supervisor-real-cycle-check.sh` as real foreground supervisor-cycle evidence inside a disposable real git branch. The fixture runs `bash scripts/supervisor.sh once` with commits enabled, has fake Codex write a changed outbox marker, and verifies the supervisor commit includes a generated `mailbox/inbox/*post-run-pressure-challenge.md`.

The current real branch boundary remains: the inbox that triggered this run, `mailbox/inbox/2026-05-07-supervisor-invalid-recovery-pressure.md`, was created manually by the supervisor after stable-copy activation. That boundary is expected because the previous real loop was an older stable copy and exited after committing the checked-out supervisor change. The proof after this run is stronger but still sandboxed real-git foreground evidence, not a natural post-activation commit on this branch that auto-created the next inbox.

I am not forcing a live branch auto-pressure proof in this run because producing it would require intentionally finishing with a new generated inbox or driving the supervisor's own post-run commit from inside the Codex child. The smaller concrete proof is already in `scripts/supervisor-real-cycle-check.sh`: it exercises the actual supervisor `once` commit path in a real git sandbox and checks the committed inbox.

## Validation

Ran:

```bash
scripts/shell-syntax-check.sh
scripts/supervisor-real-cycle-check.sh
scripts/supervisor-stable-copy-check.sh
scripts/watchdog-fast-exit-check.sh
scripts/proof-pressure-check.sh
scripts/feedback-escalation-check.sh
scripts/docs-check.sh
```

Final hygiene also checked that `mailbox/processing/` is clean after handoff and that no `.self-harness/tmp/outbox-*` or top-level `*.tmp` files remain.

## Return-To-Main

Strict return-to-main judgment: no for the combined branch behavior.

The bounded recovery path is a stronger candidate than the earlier blocked-handoff behavior because it fixes a concrete restart hazard and has real foreground git proof. Still, it changes supervisor recovery and commit behavior, restores `scripts/supervisor.sh` from a private stable copy, and has only first-cycle sandbox evidence. Keep it branch-local until a supervisor review sees repeated clean cycles or asks for a smaller patch candidate.

## Remaining Weakness

The remaining weakness is semantic recovery. The new path restores a known parseable supervisor entry and records an incident, but it discards the invalid supervisor edit rather than preserving a patch artifact for review. The failed edit is still visible through the session transcript and fake-Codex proof logs, but a production failure could benefit from a small incident attachment that records a diff of the discarded invalid `scripts/supervisor.sh` before restoration.

Next supervisor pressure: Prove or design a compact discarded-invalid-supervisor diff capture for the recovery incident, without leaking local paths or preserving unbounded broken source.
