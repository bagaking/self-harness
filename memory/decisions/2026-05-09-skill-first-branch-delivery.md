---
id: "decision-2026-05-09-skill-first-branch-delivery"
title: "Skill First Branch Delivery"
type: "memory"
status: "active"
owner: "agent"
created: "2026-05-09"
updated: "2026-05-09"
tags:
  - decision
  - skills
  - branch-evolution
  - return-to-main
  - notification
  - autoresearch
summary: "Records the branch-local decision to package reusable branch-agent results as skill-first, evidence-backed artifacts before return-to-main review."
source: "mailbox/done/2026-05-08-181640-skill-first-autoresearch-notification-evolution.md"
confidence: "high"
related:
  - "mailbox-inbox-2026-05-08-181640-skill-first-autoresearch-notification-evolution"
  - "mailbox/outbox/2026-05-09-skill-first-autoresearch-notification-evolution-reply.md"
  - "skills/skill-first-branch-delivery/SKILL.md"
  - "memory/proposals/2026-05-05-memory-evolution-system.md"
  - "memory/decisions/2026-05-08-supervisor-status-notification-boundary.md"
  - "memory/decisions/2026-05-09-return-to-main-gene-audit.md"
---

# Skill First Branch Delivery

## Decision

Future branch-agent delivery work should default to a skill-first packaging question: if a branch result is a repeatable procedure that future agents should select by task, encode it as a compact skill or skill update before asking the supervisor to consider return-to-main promotion.

If the result is deterministic enforcement, use a script or fixture. If it is accepted policy or evidence, use memory. If it is unapproved design, use a proposal. If the evidence is too thin or one-off, keep it in mailbox/outbox and name the smaller next proof task.

## Evidence

The current run added `skills/skill-first-branch-delivery/SKILL.md` because the supervisor asked for a reusable branch-agent delivery pattern, a feature-based reporting template, notification policy, and a rule for deciding whether branch output is good enough to become a skill.

Required probes found:

- `scripts/query-docs.sh memory "auto_research"`: `memory/proposals/2026-05-05-memory-evolution-system.md`, which already defines the focused auto-research loop.
- `scripts/query-docs.sh memory "skill"`: skill adoption criteria, mailbox-processing and branch-evaluation lessons, and repeated diary evidence that skills should capture stable procedures.
- `scripts/query-docs.sh skills "return-to-main"` and `scripts/query-docs.sh skills "branch evolution"`: `skills/branch-evolution-evaluation/SKILL.md`.
- `scripts/query-docs.sh skills "memory-evaluation"`: `skills/memory-evaluation/SKILL.md`.
- `scripts/query-docs.sh memory "status sync"` and `scripts/query-docs.sh memory "notification"`: status notification remains opt-in and deferred for `main`.
- `rg -n -i "\bdarwin\b|auto_research|autoresearch|auto research" skills memory mailbox scripts`: no local Darwin skill or Darwin-style reference exists beyond OS-specific `uname -s` code and the current request; evolutionary selection pressure is therefore inferred from existing repository evidence, not from a local Darwin source.

Skill validation note: `python3 skills/.system/skill-creator/scripts/quick_validate.py skills/skill-first-branch-delivery` is blocked in this environment because Python cannot import `yaml`. Manual validation checked that the skill frontmatter has `name` and `description`, the folder name matches the skill name, `agents/openai.yaml` uses a short UI description, and template placeholders were removed.

## Operating Rule

Use `skills/skill-first-branch-delivery/SKILL.md` when a mailbox request asks for branch-agent research, notification/status-sync evolution, feature-based return-to-main reporting, or a reusable procedure arising from branch-local evidence.

The skill-worthiness rule is:

- recur: the procedure is likely to happen again;
- compact: it fits in a focused `SKILL.md`;
- discoverable: likely query and trigger terms find it;
- behavioral: it changes a future checklist, decision, or validation step;
- proven: it has at least one local use and a rerunnable query, command, fixture, or acceptance criterion;
- portable: it avoids no0-only history, private scratch state, local recipients, tokens, hostnames, usernames, and absolute machine paths.

## Notification Policy

Notification remains a proposal and review surface, not automatic `main` behavior.

- Local logging belongs under `.self-harness/` and is never committed.
- Lark delivery is optional and must be configured by environment; committed records must not include recipient ids, tokens, or runtime logs.
- Anti-spam rules allow notifications only for lifecycle start/resume, terminal stop/pause/failure, post-run commit failure, and significant committed progress. Repeated running events should deduplicate, and broad sweeps or already-covered proof loops should not notify.
- Main adoption needs a coherent clean-main patch or checked-out supervisor-cycle proof, fake-delivery fixture evidence, notification environment isolation, shell syntax validation, and `scripts/docs-check.sh`.

## Recall Probe

Use:

```bash
scripts/query-docs.sh skills "skill-first branch delivery"
scripts/query-docs.sh memory "skill first branch delivery"
```
