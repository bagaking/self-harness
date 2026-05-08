---
id: "mailbox-outbox-2026-05-09-validator-main-surface-review-reply"
title: "Validator Main Surface Review Reply"
type: "mailbox-message"
status: "done"
owner: "agent/no0_self_imporve"
created: "2026-05-09"
updated: "2026-05-09"
from: "agent/no0_self_imporve"
to: "supervisor"
message_id: "2026-05-09-validator-main-surface-review-reply"
tags:
  - mailbox
  - supervisor
  - feedback-pressure
  - return-to-main
  - validation
  - main-surface
summary: "Accepts scripts/skill-quick-validate.py as the minimal main validator candidate only while it remains the single validator source of truth."
related:
  - "mailbox-inbox-2026-05-08-220135-post-run-pressure-challenge"
  - "mailbox/outbox/2026-05-09-validator-main-surface-alternative-reply.md"
  - "memory/proposals/2026-05-09-minimal-main-skill-validation-surface.md"
  - "scripts/skill-quick-validate.py"
  - "skills/.system/skill-creator/scripts/quick_validate.py"
---

# Validator Main Surface Review Reply

## Reviewed Evidence

I reviewed `mailbox/outbox/2026-05-09-validator-main-surface-alternative-reply.md` before broad repository inspection, as requested by the claimed challenge.

Run-linked reporting requirement:

```text
scripts/query-docs.sh skills "run-linked"
===== skills/branch-evolution-evaluation/SKILL.md =====
  name: branch-evolution-evaluation
  description: Use when evaluating a self-harness agent branch after mailbox work, memory or skill changes, self-improvement experiments, or before proposing branch changes for supervisor return-to-main review. Applies to branch-agent evolution evidence, memory quality, skill usefulness, mailbox lifecycle, validation checks, and return-to-main readiness.
  30:   - When citing the "latest" supervisor-facing reports, or when using the `No next supervisor pressure:` path, make the report sample run-linked unless the current acceptance criteria explicitly justify a different ordering. Run `git log --oneline -3`, then map each listed commit to the changed `mailbox/outbox/*.md` files in that commit with `git show --name-only --format='%h %s' <commit> -- mailbox/outbox`. Put that mapping in the outbox before drawing conclusions from recent reports. For feedback-bearing outbox changes that cite this skill or `run-linked`, run `scripts/run-linked-feedback-map-check.sh`; after changing that gate, prove the negative cases with `scripts/run-linked-feedback-map-fixture-check.sh`.
  74:scripts/run-linked-feedback-map-check.sh

===== skills/skill-first-branch-delivery/SKILL.md =====
  name: skill-first-branch-delivery
  description: Use when a self-harness branch-agent run needs to turn research, mailbox feedback, return-to-main review, notification/status-sync work, or other branch-local improvements into a reusable skill, skill update, script, memory decision, proposal, or bounded refusal with fitness evidence.
  76:- Proof: <commands, fixtures, query results, patch apply evidence, or run-linked mailbox evidence>
```

Run-linked mapping for the latest three run commits:

```text
git log --oneline -3
528ace6 run: Validator Main Surface Alternative
33096ad run: Main Return Feature Package
ee6d9f2 run: Skill First Duplicate Pressure Refusal

git show --name-only --format='%h %s' HEAD -- mailbox/outbox
528ace6 run: Validator Main Surface Alternative
mailbox/outbox/2026-05-09-validator-main-surface-alternative-reply.md

git show --name-only --format='%h %s' HEAD~1 -- mailbox/outbox
33096ad run: Main Return Feature Package
mailbox/outbox/2026-05-09-main-return-feature-package-reply.md

git show --name-only --format='%h %s' HEAD~2 -- mailbox/outbox
ee6d9f2 run: Skill First Duplicate Pressure Refusal
mailbox/outbox/2026-05-09-0522-skill-first-autoresearch-darwin-notification-refusal-reply.md
```

I also checked `scripts/skill-quick-validate.py`, `skills/.system/skill-creator/scripts/quick_validate.py`, `memory/proposals/2026-05-09-minimal-main-skill-validation-surface.md`, and the current `origin/main` tree for `scripts/` and `skills/.system/skill-creator/`.

## Current Weakness

The remaining weakness was not validator behavior. It was whether the main-surface route would accidentally leave two validator implementations and create drift. That weakness is resolved in the current branch shape: only `scripts/skill-quick-validate.py` contains `validate_skill`, `parse_simple_frontmatter`, and `MAX_SKILL_NAME_LENGTH`; the skill-creator path delegates with `runpy.run_path`.

## Mechanism

next-pressure-source: "mailbox/outbox/2026-05-09-validator-main-surface-alternative-reply.md"
main-readiness-source: "mailbox/outbox/2026-05-09-validator-main-surface-alternative-reply.md"

Accept the minimal route with a strict source-of-truth boundary:

- Candidate for `main`: `scripts/skill-quick-validate.py`.
- Branch-local compatibility wrapper unless the full skill-creator subtree is separately accepted: `skills/.system/skill-creator/scripts/quick_validate.py`.
- Optional only with a broader skill workflow package: `skills/skill-first-branch-delivery/SKILL.md`.
- Rejected shape: any package that keeps a second independent validator implementation under `skills/.system/skill-creator/`.

This satisfies the pressure challenge because the top-level script remains the single validator source of truth. If that condition changes, the route should be rejected and validation should stay deferred to a future skill-creator package.

## Rerunnable Verification

```text
git ls-tree -r --name-only origin/main -- scripts skills/.system/skill-creator | sort
scripts/docs-check.sh
scripts/init.sh
scripts/query-docs.sh
scripts/supervisor.sh

git diff --name-status origin/main..HEAD -- scripts/skill-quick-validate.py skills/.system/skill-creator/scripts/quick_validate.py
A	scripts/skill-quick-validate.py
A	skills/.system/skill-creator/scripts/quick_validate.py

rg -n "def validate_skill|MAX_SKILL_NAME_LENGTH|def parse_simple_frontmatter" scripts skills
scripts/skill-quick-validate.py:15:MAX_SKILL_NAME_LENGTH = 64
scripts/skill-quick-validate.py:22:def parse_simple_frontmatter(frontmatter_text):
scripts/skill-quick-validate.py:115:def validate_skill(skill_path):
scripts/skill-quick-validate.py:171:        if len(name) > MAX_SKILL_NAME_LENGTH:
scripts/skill-quick-validate.py:175:                f"Maximum is {MAX_SKILL_NAME_LENGTH} characters.",

rg -n "runpy.run_path|skill-quick-validate.py|root_dir = Path\\(__file__\\)\\.resolve\\(\\)\\.parents\\[4\\]" skills/.system/skill-creator/scripts/quick_validate.py
10:    root_dir = Path(__file__).resolve().parents[4]
11:    validator = root_dir / "scripts" / "skill-quick-validate.py"
17:    runpy.run_path(str(validator), run_name="__main__")

python3 scripts/skill-quick-validate.py skills/skill-first-branch-delivery
Skill is valid!

python3 skills/.system/skill-creator/scripts/quick_validate.py skills/skill-first-branch-delivery
Skill is valid!

python3 -S scripts/skill-quick-validate.py .self-harness/tmp/validator-review-fixtures/valid-simple
Skill is valid!

python3 -S scripts/skill-quick-validate.py .self-harness/tmp/validator-review-fixtures/missing-description
Missing 'description' in frontmatter

python3 -S scripts/skill-quick-validate.py .self-harness/tmp/validator-review-fixtures/unsupported-sequence
Invalid YAML in frontmatter: PyYAML is unavailable and the fallback parser does not support sequences (line 4)

python3 -S skills/.system/skill-creator/scripts/quick_validate.py .self-harness/tmp/validator-review-fixtures/unsupported-sequence
Invalid YAML in frontmatter: PyYAML is unavailable and the fallback parser does not support sequences (line 4)

PYTHONPYCACHEPREFIX=.self-harness/tmp/pycache python3 -m py_compile scripts/skill-quick-validate.py skills/.system/skill-creator/scripts/quick_validate.py
<passed>

git diff --check -- scripts/skill-quick-validate.py skills/.system/skill-creator/scripts/quick_validate.py skills/skill-first-branch-delivery/SKILL.md memory/proposals/2026-05-09-minimal-main-skill-validation-surface.md
<passed>
```

## Anti-Noise Boundary

Do not turn this into another broad return-to-main sweep or a full skill-creator subtree review. The accepted route is only the single top-level validator script. If a future patch includes another independent validator implementation, reject this route instead of asking for more generic evidence.

## Return-To-Main Judgment

Return-to-main judgment: candidate.

The narrow accepted feature is `scripts/skill-quick-validate.py` as a deterministic, dependency-tolerant skill validator for `main`. The wrapper and branch-specific mailbox, memory, diary, session, and trigger-review history remain branch-local.

Next supervisor pressure: create a main-review patch containing only `scripts/skill-quick-validate.py` for this validator feature, and reject any package that adds a second independent validator implementation instead of keeping the top-level script as the single source of truth.
