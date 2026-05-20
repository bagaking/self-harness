---
name: background-flash-suppression
description: Use when a branch agent needs to keep one stable self-improvement goal active, generate compact candidate actions, suppress noisy or unprovable candidates, and deliver exactly one small evidence-backed repository improvement.
---

# Background Flash Suppression

Use this skill when a branch agent has a broad self-evolution pressure and must convert it into one reviewable delivery without drifting into a repository sweep, philosophical note, or unbounded plan.

## Required Inputs

- The active background goal in one sentence.
- The triggering evidence: mailbox request, diary pressure, failing check, incident, or supervisor challenge.
- The relevant constitutional or memory constraints discovered with `scripts/query-docs.sh`.

If any input is missing, do not invent a broad task. Ask for the missing pressure or write a bounded refusal with the smallest useful proof that can still be run.

## Workflow

1. Restate the background goal in concrete review terms.
2. Generate three to five candidate flashes. Each flash must name one possible durable output: `skill`, `memory`, `mailbox`, `script`, `proposal`, or `refusal`.
3. Suppress every candidate that fails any gate:
   - **Constitution:** would edit `constitution/` or bypass the mailbox and commit protocol.
   - **Portability:** would record local usernames, hostnames, home directories, absolute machine paths, or private scratch state.
   - **Evidence:** cannot be validated by a focused check, comparison, example, or explicit reviewed source in the same run.
   - **Anti-noise:** is a broad sweep, generic status report, duplicate no-pending mailbox report, or abstract self-description.
   - **Return-to-main:** is too branch-specific, too large, or too weakly proven for a supervisor to review.
4. Select exactly one surviving candidate. If multiple survive, choose the smallest one with the clearest validation.
5. Deliver only that selected candidate. Record suppressed candidates in the outbox or diary, not as additional artifacts.
6. Run the closest focused validation:
   - skills: `python3 scripts/skill-quick-validate.py <skill-dir>`
   - scripts: syntax check plus a negative or dry-run case
   - memory or mailbox only: `scripts/docs-check.sh`
7. Finish with a durable outbox or diary evidence block.

## Evidence Block

Use these headings when reporting the result:

- `Reviewed Evidence`
- `Background Goal`
- `Candidate Flashes`
- `Suppressed Candidates`
- `Chosen Delivery`
- `Evaluation Evidence`
- `Anti-Noise Boundary`
- `Return-To-Main Judgment`
- exactly one `Next supervisor pressure:` line, or one bounded `No next supervisor pressure:` refusal with a concrete stop condition

## Stop Conditions

Stop and refuse instead of delivering a change when:

- the only available candidates require modifying protected paths;
- all candidates depend on unavailable external evidence;
- validation would require secrets, network access, or private machine state;
- the delivery would mainly create more process around the absence of work.

The refusal must still identify one smaller proof the supervisor could request next.
