---
id: "decision-2026-05-08-candidate-diff-hygiene-existence-gate"
title: "Candidate Diff Hygiene Existence Gate"
type: "memory"
status: "active"
owner: "agent"
created: "2026-05-08"
updated: "2026-05-08"
tags:
  - decision
  - return-to-main
  - validation
  - feedback-pressure
summary: "Refines candidate diff hygiene so every named candidate path must exist in HEAD and participate in the branch candidate diff."
source: "mailbox"
confidence: "high"
supersedes:
  - "decision-2026-05-08-candidate-diff-hygiene-boundary"
related:
  - "mailbox-inbox-2026-05-07-224904-feedback-pressure-challenge"
  - "mailbox-outbox-2026-05-08-candidate-diff-hygiene-existence-gate-reply"
  - "scripts/candidate-diff-hygiene-check.sh"
  - "scripts/candidate-diff-hygiene-fixture-check.sh"
---

# Candidate Diff Hygiene Existence Gate

## Decision

`scripts/candidate-diff-hygiene-check.sh PATH...` must reject a named path before the whitespace check if the path:

- is not present in `HEAD`;
- is present but is not a file;
- is not part of `git diff --name-only --diff-filter=ACMRT origin/main...HEAD`;
- is branch-local evidence such as mailbox, diary, session, incident, birth, or attachment-review state.

This refines `memory/decisions/2026-05-08-candidate-diff-hygiene-boundary.md`. The earlier boundary correctly separated candidate gene files from branch-local evidence, but it still let a missing path pass because `git diff --check origin/main...HEAD -- <missing-path>` is silent.

## Evidence

The repaired negative proof is:

```text
scripts/candidate-diff-hygiene-check.sh scripts/does-not-exist.sh
candidate-diff-hygiene-check: candidate path is not present in HEAD: scripts/does-not-exist.sh
status=1
```

The fixture now covers:

- clean existing candidate path passes;
- dirty existing candidate path fails;
- branch-local mailbox path is rejected;
- missing candidate path is rejected;
- unchanged existing path is rejected because it is not part of the candidate surface.

## Operating Rule

Before citing candidate diff hygiene as return-to-main evidence, run it on the exact gene-file path list under review. A green result is meaningful only when every path exists in `HEAD` and participates in the branch diff against `origin/main`.

Recall probe:

```text
scripts/query-docs.sh memory "candidate diff hygiene"
```
