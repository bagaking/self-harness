---
name: skill-first-branch-delivery
description: Use when a self-harness branch-agent run needs to turn research, mailbox feedback, return-to-main review, notification/status-sync work, or other branch-local improvements into a reusable skill, skill update, script, memory decision, proposal, or bounded refusal with fitness evidence.
---

# Skill First Branch Delivery

Use this skill after a branch-agent result looks reusable but before proposing it for `main`. The goal is to package one portable behavior improvement, not to move branch history wholesale.

Recall phrases: skill-first branch delivery; skill first branch delivery; skill adoption; mailbox lesson promotion; diary lesson promotion.

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

5. Triage live trigger-review pressure before adding mechanisms. Recall phrases: trigger-review triage; trigger review triage; live trigger review pressure.
   - Run the requested trigger-review command when a mailbox challenge names it, usually `scripts/supervisor.sh triggers --status review --limit 8 --evidence-limit 3`.
   - For each listed `review-evidence` source, classify it as stale, already covered, or mechanism-worthy. Stale means the source no longer appears or its trigger condition is false; already covered means later durable records satisfy the trigger and name a lifecycle/source marker; mechanism-worthy means the evidence exposes a repeatable false positive, missing gate, missing skill step, or changed control-plane surface.
   - Do not silence trigger output by adding broad ignore rules or generic outbox prose. Retain a script, skill, memory decision, or bounded refusal only when the classification has rerunnable proof.

## Research-Backed Skill Evolution Loop

Use this smallest loop when the artifact under consideration is a skill or skill update:

1. Question: ask one operational question, for example "What checklist change would make future branch-delivery reports less noisy?"
2. Evidence: gather required repository probes, negative searches, and any requested external reference. Extract claims only when they change a local rule.
3. Variation: write one candidate skill change and one explicit alternative, including "memory-only" or "refuse" when that is plausible. Keep the candidate's write surface to one skill unless a script or memory note is necessary for proof.
4. Fitness: choose a before-and-after signal before editing. Acceptable signals include `scripts/query-docs.sh` recall for likely terms, a focused fixture or validation command, mailbox acceptance criteria, an independent later use of the skill, or a patch/dry-run against the intended target.
5. Retention: keep the candidate only if it changes future behavior and the fitness signal is inspectable from repository-visible evidence. Otherwise record a bounded refusal or memory note.
6. Rejection: state what was deliberately not retained, such as broad essays, private scratch notes, branch identity, raw external clones, unvalidated rewrites, or changes that would create noisy self-modification.
7. Freshness: record whether the change supersedes, narrows, or merely adds evidence to older memory or skills. Prefer a new memory decision over rewriting completed mailbox or diary evidence.

When a branch-delivery task changes `skills/`, the outbox must name the candidate skill variation, one rejected non-skill alternative, the pre-edit fitness signal, and the post-edit command or later-use evidence proving the skill improved. If those fields cannot be produced, write a focused refusal with the smaller useful next task instead of making a speculative skill edit.

For this repository, Darwin-style selection pressure means variation plus measured retention, not uncontrolled self-editing. External evolutionary-agent patterns are only useful when they can be reduced to local proof: an isolated candidate, a runnable or queryable fitness check, and a durable keep/reject decision.

## Skill Evolution Terms

- Variation: the smallest candidate behavior change, plus at least one non-skill alternative.
- Fitness evidence: a rerunnable command, query, fixture, acceptance criterion, or later independent use showing the skill is easier to find, more precise, safer, or more useful than before.
- Retention: the reviewed part that remains in `skills/`, `scripts/`, `memory/`, or `mailbox/outbox/` because it changed future behavior.
- Rejection: material left out because it is one-off, noisy, private, local to one lineage, unvalidated, or better suited to memory/proposal/outbox.
- Freshness: explicit relationship to older evidence, including superseded rules, deferrals, source dates, or conditions that should trigger reevaluation.

6. Use this feature-based report template for future `main` evolution reports:

```markdown
## Feature: <name>

- Problem solved: <one concrete operational problem>
- Entered main: <paths or "none">
- Why allowed: <portable value and risk boundary>
- Proof: <commands, fixtures, query results, patch apply evidence, or run-linked mailbox evidence>
- Deferred or branch-local: <related paths or ideas not promoted>
- Return-to-main judgment: <candidate | deferred | rejected>
```

7. For notification or status-sync proposals, separate policy from delivery.
   - Local logging: allowed under `.self-harness/`; never commit runtime logs.
   - Optional Lark delivery: opt in only through environment/configuration; never commit recipient ids, tokens, or local device details.
   - Anti-spam: notify only on lifecycle start/resume, terminal stop/pause/failure, post-run commit failure, or significant committed progress; deduplicate repeated running events; do not notify for every file edit, broad sweep, or already-covered proof loop.
   - Message content: include event, status, branch, concise reason, optional bounded detail, UTC time, and supervisor signature. Exclude secrets, recipient identifiers, raw logs, local paths, hostnames, usernames, and large transcripts.
   - Failure policy: notification send failure must be logged but must not block commits or normal supervisor progress after local status recording succeeds. Recall phrase: notification failure blocks commits. Only malformed notification configuration or changed notification code should create a repair challenge.
   - Audit: durable reports should cite the relevant script, fixture, or `.self-harness/` log location generically; runtime notification attempts stay under `.self-harness/` and are never promoted to repository state.
   - Main proof: require fake-delivery fixtures, environment-isolation proof, shell syntax checks, docs checks, and a clean `origin/main` patch or checked-out supervisor cycle when supervisor hooks change.

8. Decide whether a branch output is skill-worthy.
   - Promote to a skill only when it is likely to recur, can fit in a compact `SKILL.md`, is discoverable by likely trigger terms, and reduces future context or decision cost.
   - Require at least one local use, query recall proof, and named validation or acceptance evidence.
   - Default to a proposal or mailbox report when the behavior is one-off, too broad, unproved, or tied to no0-only history.

## Skill Adoption From Repeated Lessons

Use this triage before turning repeated mailbox or diary lessons into a skill:

1. Promote only when the lesson has a stable task trigger, not just repeated branch history. Good triggers are user or supervisor phrases a future agent would actually see; weak triggers are current filenames, no0 identity, or a one-run incident.
2. Require behavior change: the candidate must add or narrow a checklist step, command choice, validation surface, or refusal condition. If it only summarizes completed evidence, keep it in `mailbox/outbox/` or `memory/`.
3. Decide the fitness signal before editing. For skill adoption, prefer `scripts/query-docs.sh skills "<likely phrase>"`, `python3 scripts/skill-quick-validate.py <skill-dir>`, and one mailbox acceptance field or later-use record showing the skill changed the response.
4. Memory should become a skill only when the remembered lesson is procedural, reusable across future tasks, compact enough for `SKILL.md`, and safer to recall as an active workflow than as background evidence.
5. Reject skill edits that overfit branch-local pressure, require private `.self-harness/tmp/` state, create broad "always escalate" rules, or lack a concrete stop condition.

9. Validate before handoff.
   - Run `scripts/feedback-escalation-check.sh` for feedback-bearing work.
   - Run `scripts/docs-check.sh` before finishing.
   - For changed skills, run `python3 scripts/skill-quick-validate.py <skill-dir>`. The older `python3 skills/.system/skill-creator/scripts/quick_validate.py <skill-dir>` command is a compatibility wrapper; prefer the top-level script as the source of truth.
