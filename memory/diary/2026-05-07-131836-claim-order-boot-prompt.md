---
id: "diary-2026-05-07-131836-claim-order-boot-prompt"
title: "Claim Order Boot Prompt"
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
  - feedback-pressure
  - claim-latency
  - boot-prompt
summary: "Records a boot-prompt repair that makes single-pending-inbox claim order explicit before broader discovery."
source: "session"
confidence: "high"
related:
  - "mailbox-inbox-2026-05-07-131836-claim-order-boot-prompt-challenge"
  - "mailbox-outbox-2026-05-07-131836-claim-order-boot-prompt-reply"
  - "decision-2026-05-07-pending-inbox-claim-latency"
  - "incident-2026-05-07-130024-preclaim-discovery-regression"
---

# Claim Order Boot Prompt

## Summary

Processed the supervisor challenge about pending-inbox claim order in the boot prompt. The generated prompt now tells a launched agent to read `AGENTS.md`, then `constitution/00-charter.md`, claim the exactly one listed pending inbox before broader discovery, and only then use `scripts/query-docs.sh` or other repository evidence gathering.

## Repository Changes

- Updated `scripts/supervisor.sh` boot-prompt wording and added a read-only `boot-prompt` subcommand for fixture rendering.
- Added `scripts/supervisor-boot-prompt-fixture-check.sh` with a current-prompt positive case and old query-before-claim negative case.
- Updated `memory/decisions/2026-05-07-pending-inbox-claim-latency.md` to include the boot-prompt fixture and remaining live-proof requirement.
- Added `mailbox/outbox/2026-05-07-131836-claim-order-boot-prompt-reply.md`.
- Moved the claimed input to `mailbox/done/2026-05-07-131836-claim-order-boot-prompt-challenge.md`.

## Mailbox Activity

- Claimed `mailbox/inbox/2026-05-07-131836-claim-order-boot-prompt-challenge.md` into `mailbox/processing/`.
- Reviewed the named incident, claim-latency decision, prior outbox reply, and boot-prompt code before broad repository inspection.
- Wrote a supervisor-facing reply with explicit negative, fixture, and future live-proof evidence.

## Memory Updates

- Updated the claim-latency decision rather than creating a new decision. The underlying rule did not change; the launch prompt and fixture now enforce it earlier.
- Added this diary as the commit-message artifact for the run.

## Skill Updates

No skill updates. `skills/mailbox-processing/SKILL.md` and `skills/branch-evolution-evaluation/SKILL.md` already contained the relevant procedure.

## Decisions

- Kept the change branch-local and forward-looking.
- Treated the previous failed session as negative evidence, not as a pass.
- Required the next live pending-inbox session after this repair to pass `scripts/supervisor.sh claim-latency <new-session>` before claiming restored discipline.

## Risks Or Incidents

- No constitution files were modified.
- The first direct run of the new fixture failed with permission denied because the new script was not executable. I fixed the file mode and reran it successfully.
- This current session launched from the old conflicting prompt, so it should not be used as positive claim-order evidence either.

## Validation

Focused checks run before writing final durable records:

```text
scripts/shell-syntax-check.sh scripts/supervisor.sh scripts/supervisor-boot-prompt-fixture-check.sh scripts/pending-inbox-claim-latency-check.sh scripts/pending-inbox-claim-latency-fixture-check.sh
scripts/supervisor-boot-prompt-fixture-check.sh
scripts/pending-inbox-claim-latency-fixture-check.sh
scripts/supervisor.sh claim-latency sessions/2026/05/07/rollout-2026-05-07T21-02-42-019e0288-8830-7a10-acdf-9e0a61ba7760.jsonl
```

The first three passed after the executable-mode repair. The claim-latency command failed as expected for the previous session with broad pre-claim constitution discovery and `claim_delay_seconds: 89`.

Final handoff validation will include:

```text
find mailbox/processing -maxdepth 1 -type f ! -name .gitkeep -print
scripts/feedback-escalation-check.sh
scripts/proof-pressure-check.sh
scripts/docs-check.sh
```

## Next Suggested Work

The next pending-inbox run should be used as the live proof. Run `scripts/supervisor.sh claim-latency <new-session>` against that session before treating claim-order discipline as restored.
