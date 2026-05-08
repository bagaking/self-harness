---
id: "proposal-2026-05-09-minimal-main-skill-validation-surface"
title: "Minimal Main Skill Validation Surface"
type: "proposal"
status: "candidate"
owner: "agent/no0_self_imporve"
created: "2026-05-09"
updated: "2026-05-09"
tags:
  - proposal
  - return-to-main
  - validation
  - skills
  - main-surface
summary: "Proposes a top-level skill validator as the smaller main surface, with the skill-creator validator path reduced to a compatibility wrapper."
source: "mailbox/processing/2026-05-09-0548-validator-main-surface-alternative.md"
confidence: "high"
related:
  - "mailbox-inbox-2026-05-09-0548-validator-main-surface-alternative"
  - "mailbox/outbox/2026-05-09-main-return-feature-package-reply.md"
  - "memory/proposals/2026-05-09-skill-validator-fallback-return-package.md"
  - "scripts/skill-quick-validate.py"
  - "skills/.system/skill-creator/scripts/quick_validate.py"
---

# Minimal Main Skill Validation Surface

## Feature: minimal main skill validation surface

- Problem solved: `main` has no skill validation command, while the branch's proven validator currently lives under a system-skill subtree that `origin/main` does not contain.
- Alternatives compared: A keeps the validator inside `skills/.system/skill-creator/` and defers until that whole subtree is accepted; B promotes the minimal validator as `scripts/skill-quick-validate.py` and keeps the old skill-creator path only as a compatibility wrapper on this branch.
- Proposed main patch: candidate file list is `scripts/skill-quick-validate.py`; optionally include `skills/skill-first-branch-delivery/SKILL.md` only if that skill is also being reviewed for `main`. Do not require the full `skills/.system/skill-creator/` subtree. The branch compatibility wrapper at `skills/.system/skill-creator/scripts/quick_validate.py` should remain branch-local unless the skill-creator subtree is separately accepted.
- Why allowed or deferred: The top-level script is smaller and cleaner than importing nine skill-creator files because it gives `main` one deterministic validation command without assets, generators, references, or a system skill. It is allowed as a candidate because the top-level script becomes the source of truth. It would be deferred or rejected if the supervisor wants validation to remain owned only by a future skill-creator package.
- Proof: `origin/main` contains `scripts/` but no `skills/.system/skill-creator/` path. `diff -u .self-harness/tmp/quick_validate.before scripts/skill-quick-validate.py` shows only docstring and usage text changes from the proven branch validator. `python3 scripts/skill-quick-validate.py skills/skill-first-branch-delivery` and `python3 skills/.system/skill-creator/scripts/quick_validate.py skills/skill-first-branch-delivery` both pass. Positive fixture `.self-harness/tmp/validator-main-surface-fixtures/valid-simple` passes; negative fixtures `missing-description` and `unsupported-sequence` fail closed with the expected errors. `PYTHONPYCACHEPREFIX=.self-harness/tmp/pycache python3 -m py_compile scripts/skill-quick-validate.py skills/.system/skill-creator/scripts/quick_validate.py` passes.
- Deferred or branch-local: the full `skills/.system/skill-creator/` subtree, no0 mailbox history, diaries, sessions, trigger-review reports, and branch stop-condition machinery stay branch-local. The wrapper is branch-local compatibility unless its containing subtree is separately accepted.
- Known risks: A copied validator would create drift if both paths stayed active. This proposal avoids that by making `scripts/skill-quick-validate.py` the source of truth and reducing `skills/.system/skill-creator/scripts/quick_validate.py` to a wrapper. The top-level script still encodes a conservative fallback parser; unsupported complex YAML fails closed when PyYAML is unavailable.
- Return-to-main judgment: candidate.

## Answers

- Is a top-level script smaller and cleaner than importing the skill-creator subtree? Yes. `origin/main` already has `scripts/`, and the candidate adds one script instead of importing the nine-file skill-creator subtree.
- Would duplicating validator logic create drift risk? Yes. That is why the implemented branch patch does not keep two copies of the logic.
- Can the top-level script be made source-of-truth without breaking branch skill workflows? Yes. The previous command path now delegates to `scripts/skill-quick-validate.py`, and the direct plus compatibility commands both validate the same skill and fixtures.
- What exact file list would be considered for `main` if this became a candidate? Primary: `scripts/skill-quick-validate.py`. Optional with a broader skill workflow package: `skills/skill-first-branch-delivery/SKILL.md`. Excluded unless separately accepted: `skills/.system/skill-creator/`.
