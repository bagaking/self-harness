---
id: "mailbox-outbox-2026-05-07-feedback-pressure-nonstop-ratchet-reply"
title: "Feedback Pressure Nonstop Ratchet Reply"
type: "mailbox-message"
status: "done"
owner: "agent"
created: "2026-05-07"
updated: "2026-05-07"
from: "agent/no0_self_imporve"
to: "supervisor"
message_id: "2026-05-07-feedback-pressure-nonstop-ratchet-reply"
tags:
  - mailbox
  - supervisor
  - feedback-pressure
  - explicit-feedback
  - control-plane
summary: "Adds a supervisor feedback command that turns explicit human feedback into a focused inbox challenge without waiting for idle-loop heuristics."
related:
  - "mailbox-inbox-2026-05-07-175804-feedback-pressure-nonstop-ratchet"
  - "skills/branch-evolution-evaluation/SKILL.md"
  - "skills/mailbox-processing/SKILL.md"
  - "scripts/supervisor.sh"
---

# Feedback Pressure Nonstop Ratchet Reply

## Reviewed Evidence

Read `skills/branch-evolution-evaluation/SKILL.md`, `skills/mailbox-processing/SKILL.md`, and the latest three outbox reports before broad repository inspection:

- `mailbox/outbox/2026-05-07-093958-post-run-pressure-challenge-reply.md`
- `mailbox/outbox/2026-05-07-feedback-repair-skill-ratchet-reply.md`
- `mailbox/outbox/2026-05-07-post-run-sentinel-gate-verification-reply.md`

Reviewed latest three run commits:

- `cb8934e` `run: Post Run Pressure Challenge`
- `0e28f92` `run: Feedback Repair Skill Ratchet`
- `61fb336` `run: Post Run Sentinel Gate Verification`

Also inspected `scripts/supervisor.sh`, `scripts/feedback-escalation-check.sh`, `scripts/proof-pressure-check.sh`, and `scripts/pending-inbox-session-only-check.sh`.

## Current Weakness

The feedback loop still permitted premature stopping at the supervisor boundary. `seed_progressive_challenge_if_needed` only reacts to repeated low-value history, and `should_skip_idle_agent_launch` then skips a clean idle branch with no inbox. That avoids generic churn, but fresh human feedback has no deterministic ingestion path unless a supervisor manually writes a mailbox challenge first.

The too-low proof bar was therefore not inside the agent reply checklist; it was before launch. A supervisor could know new feedback exists, see no pending inbox and no low-value heuristic match, and let the branch sleep instead of converting the feedback into one reviewable demand.

## Mechanism

Updated `scripts/supervisor.sh` with a focused `feedback` subcommand:

```bash
scripts/supervisor.sh feedback [-F FILE] [--] FEEDBACK...
```

The command creates one `mailbox/inbox/*-feedback-pressure-challenge.md` item from explicit feedback when the current branch is an `agent/*` branch and no inbox is already pending. The generated challenge requires the next run to review recent outbox and commit evidence, name the exact stopping weakness, produce exactly one mechanism or bounded refusal, prove it locally, and state the strict return-to-main judgment.

The command refuses to add a challenge when an inbox already exists, so new feedback does not trample active work or create parallel generic churn.

## Anti-Noise

This is a supervisor-loop refinement, not an autonomous idle launcher. It does not make clean idle cycles keep waking the agent, and it does not relax the low-value heuristic. It only gives the supervisor a deterministic path to turn explicit feedback into one focused mailbox item when that feedback is available.

The pending-inbox guard is the main anti-noise boundary: if work already exists, the supervisor must handle or revise that work rather than stack another pressure message on top.

## Verification

Focused validation run:

```bash
bash -n scripts/supervisor.sh
scripts/shell-syntax-check.sh scripts/supervisor.sh
```

Scratch positive proof under `.self-harness/tmp/feedback-command-positive-175804`:

```bash
SELF_HARNESS_AUTO_CHALLENGE=0 scripts/supervisor.sh feedback "Human feedback: no0 still stops too easily; keep raising the bar from fresh feedback without waiting for low-value idle history."
find mailbox/inbox -maxdepth 1 -type f ! -name .gitkeep
```

Result: command exited `0` and wrote one `mailbox/inbox/*-feedback-pressure-challenge.md` with `feedback-pressure` and `explicit-feedback` tags plus the focused acceptance criteria.

Scratch pending-inbox edge proof under `.self-harness/tmp/feedback-command-pending-175804`:

```bash
touch mailbox/inbox/already-pending.md
SELF_HARNESS_AUTO_CHALLENGE=0 scripts/supervisor.sh feedback "Human feedback: should wait because work already exists."
```

Result: command exited `1` with `feedback challenge skipped: pending inbox already exists` and listed the existing inbox file.

Scratch empty-feedback proof under `.self-harness/tmp/feedback-command-empty-175804`:

```bash
SELF_HARNESS_AUTO_CHALLENGE=0 scripts/supervisor.sh feedback
```

Result: command exited `2` with `feedback: provide non-empty feedback text with arguments or -F FILE`.

Final handoff validation will run:

```bash
find mailbox/processing -maxdepth 1 -type f ! -name .gitkeep -print
find .self-harness/tmp -maxdepth 1 -type f \( -name 'outbox-*' -o -name '*.tmp' \) -print
scripts/feedback-escalation-check.sh
scripts/docs-check.sh
scripts/shell-syntax-check.sh scripts/supervisor.sh
```

## Return-To-Main Judgment

Return-to-main: deferred. The mechanism is portable, small, and locally validated, but it changes supervisor control-plane behavior and has only scratch evidence so far. It should stay branch-local until a real supervisor invocation proves that explicit feedback can be captured into an inbox without creating duplicate pressure or bypassing higher-priority pending work.

Next supervisor pressure: use `scripts/supervisor.sh feedback` for the next fresh human feedback item when no inbox is pending, then verify the generated `mailbox/inbox/*-feedback-pressure-challenge.md` becomes the next claimed task instead of an idle skip or generic sweep.

## Result

Acceptance criteria satisfied:

- Chose one focused supervisor-loop refinement.
- Did not modify `constitution/`.
- Kept durable content repository-relative and scratch evidence under `.self-harness/tmp/`.
- Proved positive, pending-inbox edge, and empty-feedback cases locally.
- Left strict return-to-main judgment as deferred pending live supervisor evidence.
