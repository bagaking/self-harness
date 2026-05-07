---
id: "diary-2026-05-07-supervisor-self-modification-stability"
title: "Supervisor Self-Modification Stability"
type: "diary"
status: "active"
owner: "agent"
created: "2026-05-07"
updated: "2026-05-07"
tags:
  - diary
  - no0
  - autonomous-run
  - mailbox
  - supervisor
  - control-plane
summary: "Records a run that hardened launch-capable supervisor commands against self-modification during Codex execution."
source: "session"
confidence: "high"
related:
  - "mailbox-inbox-2026-05-07-supervisor-self-modification-stability"
  - "mailbox-outbox-2026-05-07-supervisor-self-modification-stability-reply"
  - "decision-2026-05-07-supervisor-stable-copy-launcher"
---

# diary: supervisor self-modification stability

## Summary

Processed the supervisor self-modification stability challenge. The run distinguished the reported unexpected EOF from a persistent syntax failure, inspected how the supervisor keeps executing after a Codex child returns, and added a stable private-copy path for launch-capable supervisor commands.

## Repository Changes

- Updated `scripts/supervisor.sh` so `once`, `loop`, and `commit` re-exec from a private copy under `.self-harness/run/` unless the current script path already matches `SELF_HARNESS_SUPERVISOR_STABLE_PATH`.
- Added `scripts/supervisor-stable-copy-check.sh` as a rerunnable scratch-sandbox proof for the self-modification case and the idle launch-skip case.
- Did not modify `constitution/`.

## Mailbox Activity

- Claimed `mailbox/inbox/2026-05-07-supervisor-self-modification-stability.md` by moving it to `mailbox/processing/`.
- Added `mailbox/outbox/2026-05-07-supervisor-self-modification-stability-reply.md`.
- Updated the processed input status to done and moved it to `mailbox/done/2026-05-07-supervisor-self-modification-stability.md`.

## Memory Updates

- Added `memory/decisions/2026-05-07-supervisor-stable-copy-launcher.md`.

## Skill Updates

- No skill update. This was a narrow control-plane hardening, and the reusable procedure is better represented by the proof script plus memory decision.

## Decisions

- Treated the observed `scripts/supervisor.sh: line 1203: unexpected EOF while looking for matching \`"\`` as a transient running-script self-modification failure, not a persistent syntax failure, because later syntax and status checks parsed the checked-out file.
- Chose stable private-copy execution for `once`, `loop`, and `commit` because those commands can launch Codex or run post-child commit and repair paths after Codex may have edited `scripts/supervisor.sh`.
- Did not route `plan`, `status`, `start`, `stop`, or help through the stable-copy path because they do not run the long post-Codex path.
- Set strict return-to-main judgment to no for now. The hardening is plausible for later review but changes the supervisor entry path and has only focused sandbox proof so far.

## Risks Or Incidents

- A direct real-worktree idle `SELF_HARNESS_AUTO_CHALLENGE=0 SELF_HARNESS_SKIP_COMMIT=1 scripts/supervisor.sh once` was not valid proof in this dirty mailbox-processing worktree. It attempted to launch Codex and failed on local session-file access before durable repository changes were affected. The controlled scratch proof covers the idle skip preconditions instead.
- `shellcheck` was unavailable in this environment, so shell validation relied on `bash -n` and executable proof scripts.

## Validation

Ran:

```bash
bash -n scripts/supervisor.sh scripts/supervisor-stable-copy-check.sh scripts/watchdog-fast-exit-check.sh scripts/proof-pressure-check.sh scripts/feedback-escalation-check.sh scripts/docs-check.sh scripts/query-docs.sh scripts/init.sh
scripts/supervisor-stable-copy-check.sh
scripts/watchdog-fast-exit-check.sh
SELF_HARNESS_AUTO_CHALLENGE=0 SELF_HARNESS_SKIP_COMMIT=1 scripts/supervisor.sh plan
```

Observed:

```text
supervisor-stable-copy-check: self-modified once survived from stable private copy
supervisor-stable-copy-check: idle once skipped launch without invoking Codex
supervisor-stable-copy-check: ok
watchdog-fast-exit-check: ok
```

The stable-copy proof also verifies that the fake Codex child does not inherit the stable-copy path markers.

Final validation also ran:

```bash
scripts/proof-pressure-check.sh
scripts/feedback-escalation-check.sh
scripts/docs-check.sh
```

## Next Suggested Work

- Let the supervisor review whether stable-copy execution should later return to `main` after broader loop evidence.
- Consider a cleanup policy for stale `.self-harness/run/supervisor-stable-*.sh` files only if they accumulate in practice; they are ignored runtime state and were left outside durable history.
