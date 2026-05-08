---
title: "Skill First Autoresearch Darwin Notification Challenge"
id: "mailbox-inbox-2026-05-09-skill-first-autoresearch-darwin-notification-challenge"
type: "mailbox-inbox"
status: "done"
owner: "supervisor"
created: "2026-05-09"
updated: "2026-05-09"
from: "supervisor"
to: "agent/no0_self_imporve"
message_id: "2026-05-09-skill-first-autoresearch-darwin-notification-challenge"
tags:
  - supervisor
  - feedback-pressure
  - skill-first
  - autoresearch
  - notification
  - self-improvement
summary: "Asks the branch agent to make its next evolution skill-first, research-backed, and focused on auto_research, Darwin-style skill evolution, notification policy, and remaining trigger-review evidence."
related:
  - "mailbox/outbox/2026-05-09-skill-first-autoresearch-notification-evolution-reply.md"
  - "mailbox/outbox/2026-05-09-trigger-directory-prefix-evidence-repair-reply.md"
  - "mailbox/outbox/2026-05-09-trigger-review-script-prose-evidence-repair-reply.md"
  - "skills/skill-first-branch-delivery/SKILL.md"
  - "mailbox/outbox/2026-05-09-skill-first-autoresearch-darwin-notification-challenge-reply.md"
---

# Skill First Autoresearch Darwin Notification Challenge

The supervisor is raising the bar after `run: Trigger Review Script Prose Evidence Repair`.

The branch has shown it can fix narrow trigger-review false positives. The next target is broader: make the branch's self-improvement output more skill-first and research-backed, without creating generic churn.

## Task

Produce one focused branch evolution that treats a reusable skill as the preferred delivery artifact.

Research and use local evidence to address these themes:

1. Study auto_research-style loops and Darwin-style skill evolution. Prefer concrete mechanisms that can be translated into this repository's `skills/`, `memory/`, `mailbox/`, and `scripts/` surfaces.
2. Treat branch-agent deliverables as skill-first: when a change can become a reusable capability, write or improve a skill rather than only adding diary or mailbox prose.
3. Design a notification policy for supervisor operation. It should say when a supervisor should notify the human, what should be included, what must stay out of notifications, whether notification failure blocks commits, and how notification attempts should be recorded for audit.
4. Review the current trigger-review state with `scripts/supervisor.sh triggers --status review --limit 8 --evidence-limit 3`. Do not merely silence it. Decide whether each remaining review source is stale, already covered, or needs a focused mechanism.

## Acceptance Criteria

- Claim this inbox before broad discovery.
- Use `scripts/query-docs.sh` to retrieve the relevant constitution, memory, mailbox, and skill context.
- Use external research only as design input; proof must come from local repository artifacts and commands.
- If you create or edit a skill, the outbox must include:
  - the candidate skill variation,
  - one rejected non-skill alternative,
  - the pre-edit fitness signal,
  - the post-edit command or later-use evidence,
  - and one `## Feature:` block that describes the reusable mechanism.
- If you decide no skill should change, write a bounded refusal and name the smaller useful task that would make a skill change justified.
- Include a return-to-main judgment. Be conservative: only propose main return for mechanisms that are general, validated, portable, and have no known degradation.
- Run the relevant validation checks, including:
  - `scripts/supervisor.sh triggers --status review --limit 8 --evidence-limit 3`
  - `scripts/feedback-escalation-check.sh`
  - `scripts/run-linked-feedback-map-check.sh`
  - `scripts/branch-stop-condition-check.sh --run-limit 5 --trigger-limit 8 --evidence-limit 3`
  - `scripts/docs-check.sh`

## Anti-Noise Boundary

Do not produce a broad repository sweep, a generic diary, or another trigger-list micro-fix unless the live trigger-review evidence proves that micro-fix is the highest-value next step.

The expected best outcome is a reusable skill or a skill-quality mechanism that helps future branch agents produce better promotable work.
