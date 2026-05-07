---
id: "decision-2026-05-07-supervisor-bootstrap-and-syntax-gate"
title: "Supervisor Bootstrap And Syntax Gate"
type: "memory"
status: "active"
owner: "agent"
created: "2026-05-07"
updated: "2026-05-07"
tags:
  - decision
  - supervisor
  - control-plane
  - stability
  - validation
summary: "Records the branch-local decision to add per-file shell syntax validation and a stable-copy loop handoff."
source: "mailbox"
confidence: "high"
related:
  - "mailbox-inbox-2026-05-07-supervisor-bootstrap-and-syntax-gate"
  - "mailbox-outbox-2026-05-07-supervisor-bootstrap-and-syntax-gate-reply"
  - "decision-2026-05-07-supervisor-stable-copy-launcher"
---

# Supervisor Bootstrap And Syntax Gate

## Decision

Use `scripts/shell-syntax-check.sh` as the reusable shell syntax proof for this branch. The script runs a separate `bash -n "$script"` invocation for each shell file, either for every `scripts/*.sh` file by default or for the explicit files passed as arguments.

`scripts/supervisor.sh` now calls this helper from `run_commit_gate`.

For supervisor bootstrap activation, a stable-copy loop now exits after a completed run when the checked-out `scripts/supervisor.sh` fingerprint differs from the fingerprint recorded when the stable copy started. That creates a narrow handoff point so the next launch activates the checked-out supervisor body instead of letting a stable-copy loop continue indefinitely on stale code.

## Rationale

Two symptoms were transient rather than persistent parse failures:

```text
scripts/supervisor.sh: line 1203: unexpected EOF while looking for matching `"`
scripts/supervisor.sh: line 1237: syntax error near unexpected token `('
```

The distinction matters because current per-file syntax validation passes, while a persistent syntax error would reproduce immediately under `bash -n "$script"`. The likely failure class is a running supervisor process or bootstrap boundary, especially when the loop or once command began before stable-copy launch existed.

The syntax evidence issue is independent: `bash -n scripts/a.sh scripts/b.sh` parses only `scripts/a.sh`. The second script name is not parsed, so reports must not cite that shape as broad shell validation.

## Rerunnable Verification

Use:

```bash
scripts/shell-syntax-check.sh
scripts/supervisor-stable-copy-check.sh
scripts/query-docs.sh all "Supervisor Bootstrap And Syntax Gate"
```

The stable-copy check includes a loop handoff fixture that edits the checked-out supervisor during a fake Codex run and verifies that the stable-copy loop exits after the source fingerprint changes.

## Memory Evaluation

- Recall: pass. Query terms `bootstrap`, `syntax gate`, `shell syntax`, `stable copy`, and `supervisor` should find this decision and the outbox reply.
- Precision: pass. The note applies to shell parse validation and supervisor activation after supervisor source changes.
- Freshness: pass. It supersedes earlier multi-file `bash -n` evidence without replacing the stable-copy launcher decision.
- Conflict handling: pass. It records both transient symptoms and preserves the distinction from persistent syntax failure.
- Actionability: pass. Future runs can execute the named scripts.
- Portability: pass. Durable paths are repository-relative.
- Traceability: pass. Claims point to the mailbox message, script changes, and rerunnable checks.
- Compression: pass. It keeps the durable lesson short and leaves detailed evidence in the outbox reply.

## Return-To-Main

Default no for the combined change. The syntax helper alone is a strong candidate for supervisor review; the loop handoff should remain branch-local until it has real loop-cycle evidence.
