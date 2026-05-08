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
   - When external references are requested, keep raw notes under `.self-harness/tmp/` and promote only short source names, URLs, and local implications into durable files.

2. Retrieve local evidence.
   - Run the task-specific `scripts/query-docs.sh` probes from the mailbox request.
   - Search for prior art with `rg`, including negative searches for named mechanisms such as `darwin`, `auto_research`, or `notification` when the request asks for them.
   - If no named local reference exists, say so. If a trustworthy external reference exists, compare its mechanism against this repository's constraints before inferring a bounded local rule.

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

## Research-Backed Skill Evolution Loop

Use this smallest loop when the artifact under consideration is a skill or skill update:

1. Question: ask one operational question, for example "What checklist change would make future branch-delivery reports less noisy?"
2. Evidence: gather required repository probes, negative searches, and any requested external reference. Extract claims only when they change a local rule.
3. Variation: write one candidate skill change and one explicit alternative, including "memory-only" or "refuse" when that is plausible. Keep the candidate's write surface to one skill unless a script or memory note is necessary for proof.
4. Fitness: choose a before-and-after signal before editing. Acceptable signals include `scripts/query-docs.sh` recall for likely terms, a focused fixture or validation command, mailbox acceptance criteria, an independent later use of the skill, or a patch/dry-run against the intended target.
5. Retention: keep the candidate only if it changes future behavior and the fitness signal is inspectable from repository-visible evidence. Otherwise record a bounded refusal or memory note.
6. Rejection: state what was deliberately not retained, such as broad essays, private scratch notes, branch identity, raw external clones, unvalidated rewrites, or changes that would create noisy self-modification.
7. Freshness: record whether the change supersedes, narrows, or merely adds evidence to older memory or skills. Prefer a new memory decision over rewriting completed mailbox or diary evidence.

For this repository, Darwin-style selection pressure means variation plus measured retention, not uncontrolled self-editing. External evolutionary-agent patterns are only useful when they can be reduced to local proof: an isolated candidate, a runnable or queryable fitness check, and a durable keep/reject decision.

## Skill Evolution Terms

- Variation: the smallest candidate behavior change, plus at least one non-skill alternative.
- Fitness evidence: a rerunnable command, query, fixture, acceptance criterion, or later independent use showing the skill is easier to find, more precise, safer, or more useful than before.
- Retention: the reviewed part that remains in `skills/`, `scripts/`, `memory/`, or `mailbox/outbox/` because it changed future behavior.
- Rejection: material left out because it is one-off, noisy, private, local to one lineage, unvalidated, or better suited to memory/proposal/outbox.
- Freshness: explicit relationship to older evidence, including superseded rules, deferrals, source dates, or conditions that should trigger reevaluation.

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
