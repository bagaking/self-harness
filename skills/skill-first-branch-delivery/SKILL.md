---
name: skill-first-branch-delivery
description: Use when a self-harness branch-agent run needs to turn research, mailbox feedback, return-to-main review, notification/status-sync work, or other branch-local improvements into a reusable skill, skill update, script, memory decision, proposal, or bounded refusal with fitness evidence.
---

# Skill First Branch Delivery

Use this skill after a branch-agent result looks reusable but before proposing it for `main`. The goal is to package one portable behavior improvement, not to move branch history wholesale.

Recall phrases: skill-first branch delivery; skill first branch delivery.

## Workflow

1. State the focused question.
   - Use the auto-research shape: focused question, repository search, claim extraction, small experiment or proof, evaluation, repeat only when the last step produced stronger evidence.
   - Prefer repository-local evidence. Put external/reference clones or experiments under `.self-harness/tmp/`.

2. Retrieve local evidence.
   - Run the task-specific `scripts/query-docs.sh` probes from the mailbox request.
   - Search for prior art with `rg`, including negative searches for named mechanisms such as `darwin`, `auto_research`, or `notification` when the request asks for them.
   - If no named local reference exists, say so and infer only from available repository evidence.

3. Choose the durable artifact.
   - New or updated skill: use for repeatable judgment or workflow that future agents should select by task.
   - Script: use for deterministic checks, gates, fixtures, or hygiene rules.
   - Memory decision or lesson: use for accepted policy, durable evaluation, or branch-local evidence.
   - Proposal: use for unapproved design, policy, or control-plane change.
   - Mailbox-only report: use when evidence is not stable enough to change future behavior.
   - Refusal: use when a skill or script would only add noise; include the smaller useful proof task.

4. Apply evolutionary selection pressure.
   - Variation: name the candidate behavior and at least one alternative.
   - Fitness: define the command, query, fixture, or future acceptance criterion that would prove it helped.
   - Retention: keep only the smallest artifact that changes future behavior.
   - Rejection: explicitly leave branch-local, noisy, private, lineage-specific, or unproved material out of `main`.
   - Freshness: record supersession or deferral when newer evidence corrects an older candidate.

5. Use this feature-based report template for future `main` evolution reports:

```markdown
## Feature: <name>

- Problem solved: <one concrete operational problem>
- Entered main: <paths or "none">
- Why allowed: <portable value and risk boundary>
- Proof: <commands, fixtures, query results, patch apply evidence, or run-linked mailbox evidence>
- Deferred or branch-local: <related paths or ideas not promoted>
- Return-to-main judgment: <candidate | deferred | rejected>
```

6. For notification or status-sync proposals, separate policy from delivery.
   - Local logging: allowed under `.self-harness/`; never commit runtime logs.
   - Optional Lark delivery: opt in only through environment/configuration; never commit recipient ids, tokens, or local device details.
   - Anti-spam: notify only on lifecycle start/resume, terminal stop/pause/failure, post-run commit failure, or significant committed progress; deduplicate repeated running events; do not notify for every file edit, broad sweep, or already-covered proof loop.
   - Main proof: require fake-delivery fixtures, environment-isolation proof, shell syntax checks, docs checks, and a clean `origin/main` patch or checked-out supervisor cycle when supervisor hooks change.

7. Decide whether a branch output is skill-worthy.
   - Promote to a skill only when it is likely to recur, can fit in a compact `SKILL.md`, is discoverable by likely trigger terms, and reduces future context or decision cost.
   - Require at least one local use, query recall proof, and named validation or acceptance evidence.
   - Default to a proposal or mailbox report when the behavior is one-off, too broad, unproved, or tied to no0-only history.

8. Validate before handoff.
   - Run `scripts/feedback-escalation-check.sh` for feedback-bearing work.
   - Run `scripts/docs-check.sh` before finishing.
   - For changed skills, run `python3 skills/.system/skill-creator/scripts/quick_validate.py <skill-dir>` if the local dependencies allow it; otherwise record the blocker and manually check frontmatter and placeholder removal.
