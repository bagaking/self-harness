---
id: "proposal-2026-05-09-skill-validator-fallback-return-package"
title: "Skill Validator Fallback Return Package"
type: "proposal"
status: "deferred"
owner: "agent"
created: "2026-05-09"
updated: "2026-05-09"
tags:
  - proposal
  - return-to-main
  - skills
  - validation
  - branch-evolution
summary: "Packages the skill quick-validator dependency fallback as a single feature-level return-to-main candidate, deferred on prerequisite main surface."
source: "mailbox/processing/2026-05-09-0535-main-return-feature-package.md"
confidence: "high"
related:
  - "mailbox-inbox-2026-05-09-0535-main-return-feature-package"
  - "mailbox/outbox/2026-05-09-main-return-feature-package-reply.md"
  - "skills/.system/skill-creator/scripts/quick_validate.py"
  - "mailbox/outbox/2026-05-09-skill-validator-dependency-challenge-reply.md"
  - "memory/diary/2026-05-09-skill-validator-dependency-fix.md"
---

# Skill Validator Fallback Return Package

## Feature: skill quick-validator dependency fallback

- Problem solved: Skill changes repeatedly could not satisfy their required validation proof because `skills/.system/skill-creator/scripts/quick_validate.py` failed when PyYAML was unavailable.
- Entered branch: `6ee0ccd` added the bundled skill-creator subtree, including `skills/.system/skill-creator/scripts/quick_validate.py`; `8136f42` changed that script to keep PyYAML when available and fall back to a conservative local parser when it is not.
- Proposed main patch: none for this package. `origin/main` does not currently contain `skills/.system/skill-creator/`, so the fallback cannot be promoted as an isolated one-file patch without first accepting a separate system skill-creator subtree package. If that prerequisite is accepted, the minimal follow-up path is `skills/.system/skill-creator/scripts/quick_validate.py`.
- Why allowed: The mechanism is portable and deterministic: it adds no dependency installation, writes no private state, touches no `constitution/` file, and fails closed for unsupported YAML shapes when PyYAML is unavailable. The risk boundary is limited to a helper validator script, not mailbox lifecycle, branch identity, sessions, or supervisor policy.
- Proof: `python3 skills/.system/skill-creator/scripts/quick_validate.py skills/skill-first-branch-delivery` passes; `python3 skills/.system/skill-creator/scripts/quick_validate.py skills/.system/skill-creator` passes; `python3 skills/.system/skill-creator/scripts/quick_validate.py .self-harness/tmp/return-package-skill-validator-fixtures/valid-simple` passes. Negative fixtures under `.self-harness/tmp/return-package-skill-validator-fixtures/` fail as expected: `missing-description` reports `Missing 'description' in frontmatter`, and `unsupported-sequence` reports that the fallback does not support nested or multiline values without PyYAML. `git diff --check` also passed.
- Deferred or branch-local: `skills/skill-first-branch-delivery/SKILL.md`, branch stop-condition checks, trigger-review checks, mailbox evidence, diaries, raw sessions, notification/status-sync proposals, and no0 identity state stay branch-local. They are either broader than this one mechanism, branch-specific evidence, or separate candidates needing their own package.
- Known risks: Deferred main surface. `origin/main` currently has no `skills/.system/skill-creator/` path, so promoting this fallback alone would either create an orphaned file or smuggle a much larger system-skill addition into a supposedly minimal patch. Functional risk is low inside the branch because unsupported frontmatter fails closed when PyYAML is unavailable.
- Return-to-main judgment: deferred.

## Review Notes

- Portability: durable references use repository-relative paths only.
- Constitution boundary: `git diff -- constitution/` is empty for the current worktree.
- Minimal file list for future review: after the prerequisite skill-creator subtree exists on `main`, review only `skills/.system/skill-creator/scripts/quick_validate.py` for this feature.
- Branch-local exclusion: the remaining branch delta contains mailbox history, sessions, diaries, skills, scripts, and proposals accumulated by `agent/no0_self_imporve`; none should be merged wholesale.
