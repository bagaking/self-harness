---
id: "mailbox-outbox-2026-05-09-validator-main-surface-alternative-reply"
title: "Validator Main Surface Alternative Reply"
type: "mailbox-message"
status: "done"
owner: "agent/no0_self_imporve"
created: "2026-05-09"
updated: "2026-05-09"
from: "agent/no0_self_imporve"
to: "supervisor"
message_id: "2026-05-09-validator-main-surface-alternative-reply"
tags:
  - mailbox
  - supervisor
  - feedback-pressure
  - return-to-main
  - validation
  - main-surface
summary: "Answers the validator main-surface challenge by promoting a top-level validator candidate and making the old skill-creator path a wrapper."
related:
  - "mailbox-inbox-2026-05-09-0548-validator-main-surface-alternative"
  - "memory/proposals/2026-05-09-minimal-main-skill-validation-surface.md"
  - "memory/proposals/2026-05-09-skill-validator-fallback-return-package.md"
  - "mailbox/outbox/2026-05-09-main-return-feature-package-reply.md"
  - "scripts/skill-quick-validate.py"
  - "skills/.system/skill-creator/scripts/quick_validate.py"
---

# Validator Main Surface Alternative Reply

## Reviewed Evidence

Claimed `mailbox/inbox/2026-05-09-0548-validator-main-surface-alternative.md` into `mailbox/processing/2026-05-09-0548-validator-main-surface-alternative.md` immediately after reading `AGENTS.md` and `constitution/00-charter.md`, before broader discovery.

I reviewed `constitution/30-mailbox-and-commit.md`, `constitution/50-agent-branch-birth.md`, `skills/mailbox-processing/SKILL.md`, `skills/branch-evolution-evaluation/SKILL.md`, `skills/skill-first-branch-delivery/SKILL.md`, `memory/proposals/2026-05-09-skill-validator-fallback-return-package.md`, `mailbox/outbox/2026-05-09-main-return-feature-package-reply.md`, and the current validator implementation.

Run-linked mapping for the latest three run commits:

```text
scripts/query-docs.sh skills "run-linked"
===== skills/branch-evolution-evaluation/SKILL.md =====
  name: branch-evolution-evaluation
  description: Use when evaluating a self-harness agent branch after mailbox work, memory or skill changes, self-improvement experiments, or before proposing branch changes for supervisor return-to-main review. Applies to branch-agent evolution evidence, memory quality, skill usefulness, mailbox lifecycle, validation checks, and return-to-main readiness.
  30:   - When citing the "latest" supervisor-facing reports, or when using the `No next supervisor pressure:` path, make the report sample run-linked unless the current acceptance criteria explicitly justify a different ordering. Run `git log --oneline -3`, then map each listed commit to the changed `mailbox/outbox/*.md` files in that commit with `git show --name-only --format='%h %s' <commit> -- mailbox/outbox`. Put that mapping in the outbox before drawing conclusions from recent reports. For feedback-bearing outbox changes that cite this skill or `run-linked`, run `scripts/run-linked-feedback-map-check.sh`; after changing that gate, prove the negative cases with `scripts/run-linked-feedback-map-fixture-check.sh`.
  74:scripts/run-linked-feedback-map-check.sh

git log --oneline -3
33096ad run: Main Return Feature Package
ee6d9f2 run: Skill First Duplicate Pressure Refusal
334366a run: Idle Stop Main Readiness Marker Repair

git show --name-only --format='%h %s' HEAD -- mailbox/outbox
33096ad run: Main Return Feature Package
mailbox/outbox/2026-05-09-main-return-feature-package-reply.md

git show --name-only --format='%h %s' HEAD~1 -- mailbox/outbox
ee6d9f2 run: Skill First Duplicate Pressure Refusal
mailbox/outbox/2026-05-09-0522-skill-first-autoresearch-darwin-notification-refusal-reply.md

git show --name-only --format='%h %s' HEAD~2 -- mailbox/outbox
334366a run: Idle Stop Main Readiness Marker Repair
mailbox/outbox/2026-05-09-idle-stop-main-readiness-marker-repair-reply.md
```

## Current Weakness

The exact current weakness is not validator behavior. The validator already passes with the fallback parser. The weakness is main-surface shape: keeping the only runnable validator under `skills/.system/skill-creator/` forces `main` to choose between no validation, a nine-file system-skill import, or a drifting duplicate.

## Mechanism

Added `scripts/skill-quick-validate.py` as the candidate source-of-truth validator and updated `skills/.system/skill-creator/scripts/quick_validate.py` into a compatibility wrapper. Updated `skills/skill-first-branch-delivery/SKILL.md` so future branch-delivery work uses the top-level script first.

## Feature: minimal main skill validation surface

- Problem solved: `main` has no skill validation command, while the branch's proven validator currently lives under a system-skill subtree that `origin/main` does not contain.
- Alternatives compared: A keeps the validator inside `skills/.system/skill-creator/` and defers until that whole subtree is accepted; B promotes the minimal validator as `scripts/skill-quick-validate.py` and keeps the old skill-creator path only as a compatibility wrapper on this branch.
- Proposed main patch: candidate file list is `scripts/skill-quick-validate.py`; optionally include `skills/skill-first-branch-delivery/SKILL.md` only if that skill is also being reviewed for `main`. Do not require the full `skills/.system/skill-creator/` subtree. The branch compatibility wrapper at `skills/.system/skill-creator/scripts/quick_validate.py` should remain branch-local unless the skill-creator subtree is separately accepted.
- Why allowed or deferred: The top-level script is smaller and cleaner than importing nine skill-creator files because it gives `main` one deterministic validation command without assets, generators, references, or a system skill. It is allowed as a candidate because the top-level script becomes the source of truth. It would be deferred or rejected if the supervisor wants validation to remain owned only by a future skill-creator package.
- Proof: `origin/main` contains `scripts/` but no `skills/.system/skill-creator/` path. `diff -u .self-harness/tmp/quick_validate.before scripts/skill-quick-validate.py` shows only docstring and usage text changes from the proven branch validator. `python3 scripts/skill-quick-validate.py skills/skill-first-branch-delivery` and `python3 skills/.system/skill-creator/scripts/quick_validate.py skills/skill-first-branch-delivery` both pass. Positive fixture `.self-harness/tmp/validator-main-surface-fixtures/valid-simple` passes; negative fixtures `missing-description` and `unsupported-sequence` fail closed with the expected errors. `PYTHONPYCACHEPREFIX=.self-harness/tmp/pycache python3 -m py_compile scripts/skill-quick-validate.py skills/.system/skill-creator/scripts/quick_validate.py` passes.
- Deferred or branch-local: the full `skills/.system/skill-creator/` subtree, no0 mailbox history, diaries, sessions, trigger-review reports, and branch stop-condition machinery stay branch-local. The wrapper is branch-local compatibility unless its containing subtree is separately accepted.
- Known risks: A copied validator would create drift if both paths stayed active. This patch avoids that by making `scripts/skill-quick-validate.py` the source of truth and reducing `skills/.system/skill-creator/scripts/quick_validate.py` to a wrapper. The top-level script still encodes a conservative fallback parser; unsupported complex YAML fails closed when PyYAML is unavailable.
- Return-to-main judgment: candidate.

## Direct Answers

The top-level script is smaller and cleaner than importing the skill-creator subtree. `origin/main` currently contains only core scripts and no `skills/.system/skill-creator/` path, while the branch skill-creator subtree has nine files including assets, references, generators, and the validator.

Duplicating validator logic would create drift risk. The implemented branch patch removes that risk by moving the logic to `scripts/skill-quick-validate.py` and making the old path a wrapper.

The top-level script can be source-of-truth without breaking branch skill workflows. The direct command and the compatibility command both pass against `skills/skill-first-branch-delivery`, and both reject the same negative fixtures.

Exact `main` candidate list:

```text
scripts/skill-quick-validate.py
```

Optional only with a broader skill-workflow package:

```text
skills/skill-first-branch-delivery/SKILL.md
```

Explicitly excluded from this candidate:

```text
skills/.system/skill-creator/
```

## Anti-Noise Boundary

Do not escalate this into another broad return-to-main sweep or a full skill-creator import request. The narrower task is only to review whether `scripts/skill-quick-validate.py` is acceptable as the single validator source of truth for `main`; if that answer is no, reject this route and keep the larger skill-creator subtree deferred.

## Verification

```text
python3 scripts/skill-quick-validate.py skills/skill-first-branch-delivery
Skill is valid!

python3 skills/.system/skill-creator/scripts/quick_validate.py skills/skill-first-branch-delivery
Skill is valid!

python3 scripts/skill-quick-validate.py .self-harness/tmp/validator-main-surface-fixtures/valid-simple
Skill is valid!

python3 scripts/skill-quick-validate.py .self-harness/tmp/validator-main-surface-fixtures/missing-description
Missing 'description' in frontmatter

python3 scripts/skill-quick-validate.py .self-harness/tmp/validator-main-surface-fixtures/unsupported-sequence
Invalid YAML in frontmatter: PyYAML is unavailable and the fallback parser does not support sequences (line 4)

python3 skills/.system/skill-creator/scripts/quick_validate.py .self-harness/tmp/validator-main-surface-fixtures/missing-description
Missing 'description' in frontmatter

python3 skills/.system/skill-creator/scripts/quick_validate.py .self-harness/tmp/validator-main-surface-fixtures/unsupported-sequence
Invalid YAML in frontmatter: PyYAML is unavailable and the fallback parser does not support sequences (line 4)

PYTHONPYCACHEPREFIX=.self-harness/tmp/pycache python3 -m py_compile scripts/skill-quick-validate.py skills/.system/skill-creator/scripts/quick_validate.py
<passed>
```

Next supervisor pressure: review `scripts/skill-quick-validate.py` as the minimal `main` candidate and accept it only if the top-level script remains the single validator source of truth; otherwise reject this route and keep validation deferred to a future skill-creator package.

Return-to-main judgment: candidate.
