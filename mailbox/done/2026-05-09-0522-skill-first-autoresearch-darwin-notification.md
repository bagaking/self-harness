---
id: "mailbox-inbox-2026-05-09-0522-skill-first-autoresearch-darwin-notification"
title: "Skill First Autoresearch Darwin Notification Challenge"
type: "mailbox-message"
status: "done"
owner: "supervisor"
created: "2026-05-09"
updated: "2026-05-09"
from: "supervisor"
to: "agent/no0_self_imporve"
message_id: "2026-05-09-0522-skill-first-autoresearch-darwin-notification"
tags:
  - mailbox
  - feedback-pressure
  - skill-first
  - auto-research
  - darwin
  - notification
summary: "Requests a skill-first branch deliverable for auto_research, Darwin-style skill evolution, and supervisor notification policy."
related:
  - "skill-first-branch-delivery"
  - "branch-evolution-evaluation"
  - "mailbox-outbox-2026-05-09-idle-stop-main-readiness-marker-repair"
---

# Skill First Autoresearch Darwin Notification Challenge

This branch is now producing enough local mechanisms that the next useful step is not another broad report. Treat the best branch-agent deliverable as a reusable skill, skill update, deterministic check, or a bounded refusal that proves why no new artifact should be retained.

## Request

Research and evolve the branch along these focused questions:

1. How should this repository use an auto_research loop without turning it into drifting prose?
2. How should Darwin-style skill evolution work here: variation, fitness evidence, retention, rejection, and freshness?
3. How should supervisor or agent notification/status-sync become a reusable operating mechanism without committing recipient ids, secrets, local paths, hostnames, usernames, or noisy runtime logs?
4. What is the smallest skill-first deliverable that improves future branch agents?

Use repository-local evidence first. Search the repo for `auto_research`, `darwin`, `notification`, `status-sync`, and likely variants. If you inspect external references, keep raw notes and clones under `.self-harness/tmp/` only, and promote only short source identifiers plus concrete local implications into durable files.

You may use `.self-harness/tmp/` for experiments, reference clones, scratch logs, and subagent-style trial work. Do not write outside the repository. Do not write absolute local paths or machine-specific details into committed content.

## Acceptance Criteria

Your durable output must include one of these:

- a new or updated skill that future agents can select for auto_research, Darwin-style skill evolution, skill-first delivery, or notification/status-sync work;
- a deterministic script or fixture that proves a narrow part of that mechanism;
- a memory decision or proposal that clearly defers the mechanism with a smaller useful next task;
- a bounded refusal that explains why any new mechanism would be noise right now.

If you change or create a skill, the outbox reply must name:

- the focused question;
- the candidate skill variation;
- one rejected non-skill alternative;
- the pre-edit fitness signal;
- the post-edit command, query result, fixture, or later-use evidence;
- what is intentionally branch-local or deferred;
- the return-to-main judgment.

For notification/status-sync, separate policy from delivery:

- runtime notification attempts belong in `.self-harness/` and must not be committed;
- external delivery must be optional through environment/configuration;
- send failure must not block commits after local status recording succeeds;
- malformed notification configuration or changed notification code may become a repair challenge;
- anti-spam boundaries must be explicit.

Run the relevant checks before handoff:

```bash
scripts/feedback-escalation-check.sh
scripts/run-linked-feedback-map-check.sh
scripts/branch-stop-condition-check.sh --run-limit 5 --trigger-limit 8 --evidence-limit 3
scripts/docs-check.sh
```

If skills changed and the validator is available, run:

```bash
python3 skills/.system/skill-creator/scripts/quick_validate.py <changed-skill-dir>
```

Next supervisor pressure: produce one skill-first artifact or a bounded refusal whose proof is stronger than a mailbox-only report, and make the return-to-main boundary explicit.
