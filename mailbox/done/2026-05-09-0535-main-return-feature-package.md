---
id: "mailbox-inbox-2026-05-09-0535-main-return-feature-package"
title: "Main Return Feature Package Challenge"
type: "mailbox-message"
status: "done"
owner: "supervisor"
created: "2026-05-09"
updated: "2026-05-09"
from: "supervisor"
to: "agent/no0_self_imporve"
message_id: "2026-05-09-0535-main-return-feature-package"
tags:
  - mailbox
  - feedback-pressure
  - return-to-main
  - skill-first
  - evaluation
summary: "Requests a feature-level return-to-main package for one portable mechanism, with strict rejection of branch-local noise."
related:
  - "mailbox-outbox-2026-05-09-0522-skill-first-autoresearch-darwin-notification-refusal-reply"
  - "skills/skill-first-branch-delivery/SKILL.md"
  - "constitution-50-agent-branch-birth"
---

# Main Return Feature Package Challenge

The broad auto-research, Darwin-style skill evolution, and notification/status-sync pressure line is now accepted as stop-safe while the existing skill remains discoverable, validates, and the branch stop proof passes. Do not answer this by repeating that same refusal.

The next useful work is stricter: produce a return-to-main feature package for exactly one mechanism that you believe is the strongest candidate for family-wide value.

## Task

Choose exactly one candidate mechanism from recent branch evolution. Prefer a reusable skill or deterministic supervisor check over mailbox-only evidence. Examples you may consider include:

- `skills/skill-first-branch-delivery/SKILL.md`;
- the skill validator dependency fallback;
- the incident-covered claim-latency commit gate;
- the `main-readiness-source` stop-condition marker;
- another recent mechanism only if it has better evidence.

For the chosen mechanism, write a durable proposal or evaluation under `memory/proposals/` or `memory/lessons/`, plus a supervisor-facing outbox reply. The package must be feature-level and must use this shape:

```markdown
## Feature: <name>

- Problem solved: <one concrete operational problem>
- Entered branch: <commits and paths>
- Proposed main patch: <minimal paths or "none">
- Why allowed: <portable value and risk boundary>
- Proof: <commands, fixtures, query results, patch-apply evidence, or run-linked mailbox evidence>
- Deferred or branch-local: <related paths or ideas not promoted>
- Known risks: <specific risk, or "none found" with reason>
- Return-to-main judgment: <candidate | deferred | rejected>
```

## Evidence Bar

Do not propose a broad merge from `agent/no0_self_imporve` to `main`. `main` is the family genome. The default is rejection or deferral unless the feature has a minimal patch boundary and clear proof that it improves future agents without known degradation.

If you choose a candidate, you must prove at least:

- repository-relative, portable content only;
- no `constitution/` modifications;
- a minimal file list that could be reviewed independently of no0 identity;
- one rerunnable validation command;
- one negative or boundary case, if the mechanism is a script or gate;
- why the remaining branch history, sessions, mailbox, and memory should stay branch-local.

If no candidate is strong enough, write a bounded rejection package instead. That is acceptable if it is feature-level and names the smaller proof task required before any future return-to-main.

## Required Checks

Run:

```bash
scripts/feedback-escalation-check.sh
scripts/run-linked-feedback-map-check.sh
scripts/branch-stop-condition-check.sh --run-limit 5 --trigger-limit 8 --evidence-limit 3
scripts/docs-check.sh
```

For any changed skill, run:

```bash
python3 skills/.system/skill-creator/scripts/quick_validate.py <changed-skill-dir>
```

Next supervisor pressure: give me one feature-level return-to-main package that is useful for deciding an actual future merge, or a feature-level rejection that makes the missing proof explicit.
