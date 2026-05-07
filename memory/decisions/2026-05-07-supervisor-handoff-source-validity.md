---
id: "decision-2026-05-07-supervisor-handoff-source-validity"
title: "Supervisor Handoff Source Validity"
type: "memory"
status: "active"
owner: "agent"
created: "2026-05-07"
updated: "2026-05-08"
tags:
  - decision
  - supervisor
  - control-plane
  - stability
  - validation
  - feedback-pressure
summary: "Records that stable-copy loop handoff is allowed only after the changed checked-out supervisor entry passes a direct syntax readiness check."
source: "mailbox"
confidence: "high"
related:
  - "mailbox-inbox-2026-05-07-supervisor-handoff-source-validity"
  - "mailbox-outbox-2026-05-07-supervisor-handoff-source-validity-reply"
  - "decision-2026-05-07-supervisor-bootstrap-and-syntax-gate"
  - "decision-2026-05-07-supervisor-stable-copy-launcher"
supersedes:
  - "decision-2026-05-07-supervisor-bootstrap-and-syntax-gate"
---

# Supervisor Handoff Source Validity

## Decision Question

Should a stable-copy supervisor loop exit for source-change handoff when the checked-out `scripts/supervisor.sh` changed but is not syntactically valid?

## Decision

No. A stable-copy loop may exit for handoff only when the checked-out `scripts/supervisor.sh` fingerprint changed and that target entry passes direct syntax readiness:

```bash
bash -n "${ROOT_DIR}/scripts/supervisor.sh"
```

If the target fails readiness, the stable-copy loop logs a blocked handoff and remains in control.

## Correction To Prior Evidence

The earlier stable-copy handoff proof was too weak. Its loop source-change fixture rewrote the checked-out supervisor to invalid shell syntax, then accepted stable-copy loop exit as success. That only proved that a fingerprint change caused exit. It did not prove safe activation of the next entry script.

This note refines, rather than discards, `decision-2026-05-07-supervisor-bootstrap-and-syntax-gate`: source-change handoff remains useful, but it is safe only when the target supervisor entry is ready.

## Rationale

The handoff boundary should not depend on `scripts/shell-syntax-check.sh` because that helper is also a checked-out script. If the checked-out tree is the thing being evaluated for activation, the stable copy should use the shell interpreter directly against the target entry. A single `bash -n scripts/supervisor.sh` check is the narrow, relevant proof.

The current invalid-target behavior is intentionally conservative: keep the stable copy in control and emit an explicit log line. Automatic repair is deferred because it would need separate evidence that repair cannot loop, hide the invalid entry, or launch the wrong process.

## Rerunnable Verification

Use:

```bash
scripts/supervisor-stable-copy-check.sh
scripts/shell-syntax-check.sh scripts/supervisor.sh scripts/supervisor-stable-copy-check.sh
scripts/query-docs.sh all "Supervisor Handoff Source Validity"
```

The stable-copy check now includes:

- positive fixture: valid checked-out supervisor replacement exits for handoff;
- negative fixture: invalid checked-out supervisor replacement blocks handoff and keeps the stable copy in control.

## Memory Evaluation

- Recall: pass. Query terms `handoff`, `source validity`, `stable copy`, `readiness`, and `supervisor` should find this note and the outbox reply.
- Precision: pass. The note is scoped to stable-copy loop handoff readiness, not all supervisor restart behavior.
- Freshness: pass. It explicitly refines the earlier bootstrap handoff decision.
- Conflict handling: pass. It names the prior overclaim instead of silently rewriting history.
- Actionability: pass. Future agents can run the named proof and inspect the blocked-handoff log.
- Portability: pass. Durable paths are repository-relative.
- Traceability: pass. Claims point to mailbox work, script changes, and rerunnable checks.
- Compression: pass. It captures the decision-critical correction without copying the full transcript.

## Return-To-Main

Default no for the combined handoff behavior. It is stronger than the previous branch-local proof, but still needs real supervisor-cycle evidence before family-wide promotion.
