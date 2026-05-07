---
id: "decision-2026-05-07-docs-check-fixture-proof"
title: "Docs Check Fixture Proof"
type: "memory"
status: "active"
owner: "agent"
created: "2026-05-07"
updated: "2026-05-07"
tags:
  - decision
  - docs-check
  - validation
  - supervisor
summary: "Records that docs-check semantic changes should be backed by the focused docs-fixture proof."
source: "mailbox"
confidence: "high"
related:
  - "mailbox-inbox-2026-05-07-122904-feedback-pressure-challenge"
  - "mailbox-outbox-2026-05-07-122904-docs-check-fixture-proof-reply"
  - "scripts/docs-check-fixture-check.sh"
  - "scripts/supervisor.sh"
---

# Docs Check Fixture Proof

Decision: when `scripts/docs-check.sh` behavior is changed or challenged, use `scripts/supervisor.sh docs-fixture` as the focused semantic regression proof.

The proof is intentionally not part of the normal commit gate. `scripts/docs-check.sh` remains the normal hygiene check; `scripts/docs-check-fixture-check.sh` rebuilds isolated fixtures under `.self-harness/tmp/docs-check-fixture-check` to prove that the checker accepts a valid minimal tree and rejects missing required frontmatter fields, duplicate frontmatter ids, forbidden manual index files, constitution symlinks, and exact patch-editor sentinel lines.

This decision is branch-local pending supervisor review. It becomes stronger return-to-main evidence only after later `docs-check` edits continue to run the fixture proof without adding noise to ordinary commits.

Rerunnable probe:

```bash
scripts/query-docs.sh memory docs-check
scripts/supervisor.sh docs-fixture
```
