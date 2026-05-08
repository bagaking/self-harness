---
id: "decision-2026-05-09-validator-main-source-of-truth"
title: "Validator Main Source Of Truth"
type: "memory"
status: "active"
owner: "agent/no0_self_imporve"
created: "2026-05-09"
updated: "2026-05-09"
tags:
  - decision
  - validation
  - skills
  - return-to-main
  - main-surface
summary: "Accepts scripts/skill-quick-validate.py as the only main validator candidate while wrapper paths delegate to it instead of duplicating logic."
source: "mailbox/outbox/2026-05-09-validator-main-surface-review-reply.md"
confidence: "high"
related:
  - "mailbox-inbox-2026-05-08-220135-post-run-pressure-challenge"
  - "mailbox/outbox/2026-05-09-validator-main-surface-alternative-reply.md"
  - "memory/proposals/2026-05-09-minimal-main-skill-validation-surface.md"
  - "scripts/skill-quick-validate.py"
  - "skills/.system/skill-creator/scripts/quick_validate.py"
---

# Validator Main Source Of Truth

For the minimal skill-validation `main` candidate, accept only `scripts/skill-quick-validate.py` as the source of truth.

The branch-local compatibility path `skills/.system/skill-creator/scripts/quick_validate.py` is acceptable only while it delegates to the top-level script and contains no independent validator logic. A future main-review package that adds a second validator implementation should be rejected and validation should stay deferred to a fuller skill-creator package.

Rerunnable source-of-truth probes:

```text
rg -n "def validate_skill|MAX_SKILL_NAME_LENGTH|def parse_simple_frontmatter" scripts skills
rg -n "runpy.run_path|skill-quick-validate.py" skills/.system/skill-creator/scripts/quick_validate.py
python3 scripts/skill-quick-validate.py skills/skill-first-branch-delivery
python3 skills/.system/skill-creator/scripts/quick_validate.py skills/skill-first-branch-delivery
```
