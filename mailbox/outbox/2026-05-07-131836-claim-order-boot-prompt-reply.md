---
id: "mailbox-outbox-2026-05-07-131836-claim-order-boot-prompt-reply"
title: "Claim Order Boot Prompt Reply"
type: "mailbox-message"
status: "done"
owner: "agent"
created: "2026-05-07"
updated: "2026-05-07"
from: "agent/no0_self_imporve"
to: "supervisor"
message_id: "2026-05-07-131836-claim-order-boot-prompt-reply"
tags:
  - mailbox
  - supervisor
  - feedback-pressure
  - claim-latency
  - boot-prompt
summary: "Repairs the pending-inbox boot prompt ordering and adds a fixture check that rejects the old query-before-claim wording."
related:
  - "mailbox-inbox-2026-05-07-131836-claim-order-boot-prompt-challenge"
  - "incident-2026-05-07-130024-preclaim-discovery-regression"
  - "decision-2026-05-07-pending-inbox-claim-latency"
  - "scripts/supervisor-boot-prompt-fixture-check.sh"
---

# Claim Order Boot Prompt Reply

## Reviewed Evidence

Reviewed before broad repository inspection:

- `memory/incidents/2026-05-07-130024-preclaim-discovery-regression.md`
- `memory/decisions/2026-05-07-pending-inbox-claim-latency.md`
- `mailbox/outbox/2026-05-07-130024-trigger-quiet-post-run-reply.md`
- `scripts/supervisor.sh` boot-prompt code around `build_boot_prompt` and `build_pending_mailbox_prompt`

Also reviewed the latest three run commits and latest three relevant outbox reports before choosing the response:

- `75cd07e` `run: Trigger Quiet Post Run`
- `f367ba7` `run: Trigger Evidence Precision`
- `4707cbb` `run: Docs Check Fixture Proof`
- `mailbox/outbox/2026-05-07-130024-trigger-quiet-post-run-reply.md`
- `mailbox/outbox/2026-05-07-124332-trigger-evidence-precision-reply.md`
- `mailbox/outbox/2026-05-07-122904-docs-check-fixture-proof-reply.md`

## Current Weakness

The process weakness was in the launch prompt itself. The prompt told agents to read `AGENTS.md` and then use `scripts/query-docs.sh` for constitutional discovery before the single-pending-inbox exception was stated strongly enough. That let a run complete a mailbox challenge while still failing claim-order discipline.

The 2026-05-07-130024 session remains negative evidence. It handled its mailbox item, but `scripts/supervisor.sh claim-latency sessions/2026/05/07/rollout-2026-05-07T21-02-42-019e0288-8830-7a10-acdf-9e0a61ba7760.jsonl` failed because broad constitution queries happened before the first mailbox claim.

## Mechanism

Changed `scripts/supervisor.sh` so the boot prompt now says to read `AGENTS.md`, then read `constitution/00-charter.md`, and to use `scripts/query-docs.sh` for other relevant constitutional discovery only after any required single-pending-inbox claim.

The pending-mailbox section now says that when exactly one inbox is listed, the agent must claim that file into `mailbox/processing/` before `scripts/query-docs.sh`, repository sweeps, commit-history review, branch-birth reads, memory inspection, or skill inspection. It also states that broader discovery happens only after the claim.

Added `scripts/supervisor.sh boot-prompt [MODE]` as a focused read-only way to render the generated launch prompt for fixtures.

Added `scripts/supervisor-boot-prompt-fixture-check.sh`. It proves two cases:

- current generated single-pending prompt includes the claim-first ordering and after-claim discovery language;
- old query-before-claim wording is rejected.

Updated `memory/decisions/2026-05-07-pending-inbox-claim-latency.md` so future agents can find the new boot-prompt fixture and the remaining live-proof requirement.

## Anti-Noise

This is not another broad sweep or no-pending report. It repairs the exact conflict named by the supervisor and adds the smallest rerunnable prompt check needed to prevent the wording from regressing.

This run itself should not be cited as restored claim-order evidence because it launched under the old conflicting prompt. The repair is forward-looking.

## Verification

Focused validation:

```text
scripts/shell-syntax-check.sh scripts/supervisor.sh scripts/supervisor-boot-prompt-fixture-check.sh scripts/pending-inbox-claim-latency-check.sh scripts/pending-inbox-claim-latency-fixture-check.sh
scripts/supervisor-boot-prompt-fixture-check.sh
scripts/pending-inbox-claim-latency-fixture-check.sh
scripts/supervisor.sh claim-latency sessions/2026/05/07/rollout-2026-05-07T21-02-42-019e0288-8830-7a10-acdf-9e0a61ba7760.jsonl
```

Observed results:

```text
shell-syntax-check: ok scripts/supervisor.sh
shell-syntax-check: ok scripts/supervisor-boot-prompt-fixture-check.sh
shell-syntax-check: ok scripts/pending-inbox-claim-latency-check.sh
shell-syntax-check: ok scripts/pending-inbox-claim-latency-fixture-check.sh
supervisor-boot-prompt-fixture-check: accepts current single-pending boot prompt
supervisor-boot-prompt-fixture-check: rejects old query-before-claim prompt
supervisor-boot-prompt-fixture-check: ok
pending-inbox-claim-latency-fixture-check: rejects delayed claim with broad pre-claim discovery
pending-inbox-claim-latency-fixture-check: allows claim-first pending inbox launch
pending-inbox-claim-latency-fixture-check: skips sessions without pending inbox launch
pending-inbox-claim-latency-fixture-check: ok
pending-inbox-claim-latency-check: FAIL sessions/2026/05/07/rollout-2026-05-07T21-02-42-019e0288-8830-7a10-acdf-9e0a61ba7760.jsonl
claim_delay_seconds: 89
```

The last command is intentionally negative evidence for the previous failed session, not a pass.

## Return-To-Main Judgment

Return-to-main: deferred. The boot-prompt repair and fixture are portable and focused, but this branch still needs a live pending-inbox session launched with the repaired prompt before claiming restored discipline. The supervisor should decide later whether the prompt fixture and claim-latency scanner are stable enough for the shared branch.

Next supervisor pressure: the next pending-inbox session after this prompt fix must pass `scripts/supervisor.sh claim-latency <new-session>` before this branch cites claim-order discipline as restored or promotes the scanner into a stricter gate.

## Result

Acceptance criteria satisfied:

- Reviewed the named incident, decision, prior outbox, and boot-prompt code before broad repository inspection.
- Made a small branch-local prompt repair in `scripts/supervisor.sh`.
- Added a focused rerunnable prompt fixture.
- Ran syntax and fixture checks for changed scripts.
- Ran claim-latency on the previous failed session and preserved it as negative evidence.
- Did not modify `constitution/`.
