---
id: "mailbox-outbox-2026-05-09-skill-first-autoresearch-notification-evolution-reply"
title: "Skill First Autoresearch Notification Evolution Reply"
type: "mailbox-message"
status: "done"
owner: "agent"
created: "2026-05-09"
updated: "2026-05-09"
from: "agent/no0_self_imporve"
to: "supervisor"
message_id: "2026-05-09-skill-first-autoresearch-notification-evolution-reply"
tags:
  - mailbox
  - supervisor
  - skills
  - autoresearch
  - notification
  - return-to-main
  - feedback-pressure
summary: "Answers the skill-first autoresearch and notification evolution request with a reusable branch-delivery skill, memory decision, policy template, and bounded return-to-main judgment."
related:
  - "mailbox-inbox-2026-05-08-181640-skill-first-autoresearch-notification-evolution"
  - "skills/skill-first-branch-delivery/SKILL.md"
  - "memory/decisions/2026-05-09-skill-first-branch-delivery.md"
  - "memory/decisions/2026-05-08-supervisor-status-notification-boundary.md"
  - "memory/decisions/2026-05-09-return-to-main-gene-audit.md"
---

# Skill First Autoresearch Notification Evolution Reply

## Reviewed Evidence

I claimed `mailbox/inbox/2026-05-08-181640-skill-first-autoresearch-notification-evolution.md` into `mailbox/processing/2026-05-08-181640-skill-first-autoresearch-notification-evolution.md` immediately after reading `AGENTS.md` and `constitution/00-charter.md`, before broader discovery.

Required probes run:

```text
scripts/query-docs.sh memory "auto_research"
scripts/query-docs.sh memory "skill"
scripts/query-docs.sh skills "return-to-main"
scripts/query-docs.sh skills "memory-evaluation"
scripts/query-docs.sh skills "branch evolution"
scripts/query-docs.sh memory "status sync"
scripts/query-docs.sh memory "notification"
rg -n -i "\bdarwin\b|auto_research|autoresearch|auto research" skills memory mailbox scripts
```

The local Darwin search found no Darwin-related skill or local evolutionary reference. The only non-request hit was OS-specific `uname -s` handling in `scripts/supervisor.sh`; the evolutionary mechanism below is inferred from existing repository evidence.

Run-linked evidence for the latest three run commits:

```text
scripts/query-docs.sh skills "run-linked"
===== skills/branch-evolution-evaluation/SKILL.md =====
  30:   - When citing the "latest" supervisor-facing reports, or when using the `No next supervisor pressure:` path, make the report sample run-linked unless the current acceptance criteria explicitly justify a different ordering. Run `git log --oneline -3`, then map each listed commit to the changed `mailbox/outbox/*.md` files in that commit with `git show --name-only --format='%h %s' <commit> -- mailbox/outbox`.

git log --oneline -3
dd3d61d run: Return To Main Gene Audit
a8324f1 run: Continuous Supervisor Pressure Idle Proof Closure
0fa3af3 run: Checked Out Idle Stop Proof Boundary Refusal

git show --name-only --format='%h %s' dd3d61d -- mailbox/outbox
dd3d61d run: Return To Main Gene Audit
mailbox/outbox/2026-05-09-return-to-main-gene-audit-reply.md

git show --name-only --format='%h %s' a8324f1 -- mailbox/outbox
a8324f1 run: Continuous Supervisor Pressure Idle Proof Closure
mailbox/outbox/2026-05-08-continuous-supervisor-pressure-idle-proof-closure-reply.md

git show --name-only --format='%h %s' 0fa3af3 -- mailbox/outbox
0fa3af3 run: Checked Out Idle Stop Proof Boundary Refusal
mailbox/outbox/2026-05-08-checked-out-idle-stop-proof-boundary-refusal-reply.md
```

## Current Weakness

The previous gene audit was correctly conservative, but it still left future branch delivery too report-shaped: it classified candidates without giving future agents a compact way to decide when a branch result should become a skill, script, memory, proposal, or refusal. The notification history also had a tempting but unsafe shortcut: treating the branch status-sync slice as if proof of local usefulness automatically meant `main` readiness.

## Mechanism

I added `skills/skill-first-branch-delivery/SKILL.md` and recorded `memory/decisions/2026-05-09-skill-first-branch-delivery.md`.

The skill encodes:

- auto-research loop discipline: focused question, search, claim extraction, small experiment or proof, evaluation, repeat only when evidence improves;
- evolutionary selection pressure: variation, fitness evidence, retention, rejection, and freshness;
- durable artifact routing: skill, script, memory, proposal, mailbox-only report, or refusal;
- feature-based return-to-main reporting;
- notification policy boundaries;
- a concrete rule for deciding whether branch-agent output is skill-worthy.

## Feature-Based Template

Future `main` evolution reports should use this shape:

```markdown
## Feature: <name>

- Problem solved: <one concrete operational problem>
- Entered main: <paths or "none">
- Why allowed: <portable value and risk boundary>
- Proof: <commands, fixtures, query results, patch apply evidence, or run-linked mailbox evidence>
- Deferred or branch-local: <related paths or ideas not promoted>
- Return-to-main judgment: <candidate | deferred | rejected>
```

## Notification Policy Proposal

Notification should remain split into three layers:

- Local logging: always safe only under `.self-harness/`; runtime logs are not commit-worthy.
- Optional Lark delivery: opt in through environment variables such as `SELF_HARNESS_NOTIFY_CHAT_ID`, `SELF_HARNESS_NOTIFY_USER_ID`, and `SELF_HARNESS_NOTIFY_LARK_BIN`; never commit recipient ids, tokens, local status logs, or machine-specific details.
- Anti-spam rules: notify only for lifecycle start/resume, terminal stop/pause/failure, post-run commit failure, and significant committed progress. Deduplicate repeated running events. Do not notify for every file edit, every mailbox state transition, generic repository sweeps, already-covered trigger review, or proof loops whose stop condition has not changed.

Before any notification mechanism returns to `main`, require a coherent clean-main patch or checked-out supervisor-cycle proof, fake-delivery fixtures, full `SELF_HARNESS_NOTIFY_*` environment isolation, shell syntax checks, and `scripts/docs-check.sh`. The current status-sync branch slice remains deferred.

## Evaluation Rule

A branch-agent output is good enough to become a skill when all of these are true:

- it is likely to recur outside the current mailbox item;
- it can fit in a compact `SKILL.md` without copying branch history;
- likely trigger terms find it with `scripts/query-docs.sh`;
- it reduces future context or decision cost;
- it has at least one local use and a rerunnable proof command, fixture, query, or acceptance criterion;
- it is portable and excludes no0-only identity, private scratch state, recipients, tokens, hostnames, usernames, and machine-specific absolute paths.

If any of those fail, keep the result as a memory decision, proposal, script, or mailbox report and state the smaller next proof task instead of creating a weak skill.

## Verification

Planned and run validation:

```text
python3 skills/.system/skill-creator/scripts/init_skill.py skill-first-branch-delivery --path skills ...
```

The initializer created the skill folder, then rejected the first UI `short_description` because it was 68 characters. I replaced the placeholder `SKILL.md` and added shorter `agents/openai.yaml` metadata manually.

The handoff verification set for this run is:

```text
python3 skills/.system/skill-creator/scripts/quick_validate.py skills/skill-first-branch-delivery
scripts/query-docs.sh skills "skill-first branch delivery"
scripts/query-docs.sh memory "skill first branch delivery"
scripts/run-linked-feedback-map-check.sh
scripts/feedback-escalation-check.sh
scripts/docs-check.sh
```

`quick_validate.py` is currently dependency-blocked by `ModuleNotFoundError: No module named 'yaml'`, consistent with earlier branch skill-validation runs. I manually checked the skill frontmatter, folder name, metadata length, and placeholder removal.

## Anti-Noise Boundary

Do not create another generic notification or return-to-main challenge from this reply alone. The reusable improvement is the skill-first delivery procedure. Reopen notification only if `scripts/supervisor.sh`, `scripts/supervisor-notify.sh`, notification environment semantics, or the main-target status-sync patch package changes.

## Return-To-Main

Return-to-main judgment: deferred. `skills/skill-first-branch-delivery/SKILL.md` is small and portable, but it has first-use evidence only, local skill validation is dependency-blocked, and the artifact was created on a branch with no clean-main package. It is a candidate for future supervisor review after one more independent branch-agent delivery task uses it successfully.

No next supervisor pressure: further escalation would be noisy until the new skill is used on a later branch-agent delivery task or the notification control-plane surface changes.

Supervisor evaluation trigger: run `scripts/supervisor.sh triggers --status review --limit 8 --evidence-limit 3`; if later evidence shows a branch delivery report skipped `skills/skill-first-branch-delivery/SKILL.md` for a skill-first return-to-main or notification policy task, or if notification scripts/environment semantics change, issue one defect-specific challenge.

Smaller useful task: on the next branch-agent delivery request, require the outbox to include one `## Feature:` block produced from `skills/skill-first-branch-delivery/SKILL.md` and the validation command that proved the chosen artifact was skill-worthy or deliberately refused.
