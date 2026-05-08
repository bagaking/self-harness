---
id: "mailbox-inbox-2026-05-09-0548-validator-main-surface-alternative"
title: "Validator Main Surface Alternative Challenge"
type: "mailbox-message"
status: "done"
owner: "supervisor"
created: "2026-05-09"
updated: "2026-05-09"
from: "supervisor"
to: "agent/no0_self_imporve"
message_id: "2026-05-09-0548-validator-main-surface-alternative"
tags:
  - mailbox
  - feedback-pressure
  - return-to-main
  - validation
  - main-surface
summary: "Requests a narrower alternative analysis for making skill validation useful on main without importing the whole skill-creator subtree."
related:
  - "memory/proposals/2026-05-09-skill-validator-fallback-return-package.md"
  - "mailbox-outbox-2026-05-09-main-return-feature-package-reply"
---

# Validator Main Surface Alternative Challenge

The previous feature package correctly deferred the skill quick-validator fallback because `origin/main` does not contain `skills/.system/skill-creator/`. Do not repeat that same deferred package.

The next useful question is narrower:

Could `main` get the value of skill validation through a smaller surface than importing the full `skills/.system/skill-creator/` subtree?

## Task

Evaluate exactly two alternatives:

1. Keep the validator inside `skills/.system/skill-creator/` and defer until that whole prerequisite subtree is accepted.
2. Extract or mirror only the minimal validator into a top-level script, for example `scripts/skill-quick-validate.py` or a shell wrapper, so `main` can validate skills without importing the whole skill-creator skill.

Do not implement either alternative unless the evidence clearly shows one is safe enough and you can prove it with a minimal patch. A feature-level proposal or rejection is acceptable.

## Required Output

Write a durable proposal or lesson plus an outbox reply with this shape:

```markdown
## Feature: minimal main skill validation surface

- Problem solved: <one concrete problem>
- Alternatives compared: <A vs B>
- Proposed main patch: <minimal paths or "none">
- Why allowed or deferred: <portable value and risk boundary>
- Proof: <commands, diff boundary, validation, negative case, or patch dry-run>
- Deferred or branch-local: <what stays on no0>
- Known risks: <specific risks>
- Return-to-main judgment: <candidate | deferred | rejected>
```

The output must answer:

- Is a top-level script smaller and cleaner than importing the skill-creator subtree?
- Would duplicating validator logic create drift risk?
- Can the top-level script be made source-of-truth without breaking branch skill workflows?
- What exact file list would be considered for `main` if this became a candidate?

## Required Checks

Run:

```bash
scripts/feedback-escalation-check.sh
scripts/run-linked-feedback-map-check.sh
scripts/branch-stop-condition-check.sh --run-limit 5 --trigger-limit 8 --evidence-limit 3
scripts/docs-check.sh
```

If you make a script change, also run the changed script against at least one valid skill and one invalid fixture under `.self-harness/tmp/`.

Next supervisor pressure: decide whether the validator has a smaller main surface than the skill-creator subtree, or prove that extracting it would add more drift risk than value.
