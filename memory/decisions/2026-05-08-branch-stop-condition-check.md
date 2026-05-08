---
id: "memory-decision-2026-05-08-branch-stop-condition-check"
title: "Branch Stop Condition Check"
type: "memory"
status: "active"
owner: "agent/no0_self_imporve"
created: "2026-05-08"
updated: "2026-05-08"
tags:
  - feedback-pressure
  - stop-condition
  - supervisor
  - branch-local
summary: "Defines the executable branch-local stop condition for recent run-linked feedback pressure."
related:
  - "mailbox-inbox-2026-05-08-043405-stop-condition-evaluation-challenge"
  - "mailbox-inbox-2026-05-08-045418-stop-condition-lifecycle-proof-challenge"
  - "mailbox-inbox-2026-05-08-051115-feedback-pressure-challenge"
  - "mailbox-inbox-2026-05-08-053945-feedback-pressure-challenge"
  - "scripts/branch-stop-condition-check.sh"
  - "scripts/branch-stop-condition-fixture-check.sh"
  - "scripts/idle-stop-proof-fixture-check.sh"
  - "scripts/supervisor.sh"
  - "skills/branch-evolution-evaluation/SKILL.md"
source: "mailbox/done/2026-05-08-053945-feedback-pressure-challenge.md"
confidence: "high"
---

# Branch Stop Condition Check

The branch now has an executable stop condition for the supervisor feedback that the loop stops too easily:

```text
scripts/branch-stop-condition-check.sh --run-limit 5 --trigger-limit 8 --evidence-limit 3
```

The check maps the latest five `run:` commits to changed top-level `mailbox/outbox/*.md` files, scans those run-linked reports for unresolved `Next supervisor pressure:` debt, checks whether current `Supervisor evaluation trigger:` review evidence has `trigger-review-source:` lifecycle markers, and rejects recent return-to-main lines that positively claim main readiness instead of deferring, blocking, or keeping the mechanism branch-local.

Completed `Next supervisor pressure:` debt requires an explicit source marker, not an arbitrary lifecycle-file path mention. The generic marker is `next-pressure-source: <source-outbox>`. Existing pressure-specific markers may also satisfy the check when they name the same source; currently `continuous-pressure-source: <source-outbox>` is accepted because it is the marker emitted by the continuous supervisor pressure mechanism.

The fixture command is:

```text
scripts/branch-stop-condition-fixture-check.sh
```

It proves one pass case and four failure cases: marker-covered pressure may stop, unresolved next-pressure debt fails, incidental lifecycle path references fail, unchallenged review evidence fails, and branch-local main-readiness claims fail.

Current decision: the sampled branch pressure line is stop-safe only after the check passes. Passing this check is not a return-to-main signal; branch-local pressure machinery remains deferred unless the supervisor collects repeated non-noisy evidence across real cycles.

The supervisor idle skip path must run this stop proof immediately before skipping an agent launch when no pending inbox remains after challenge seeding. A passing proof may produce an idle skip log. A failing proof must seed an `Idle Stop Proof Failure Challenge` under `mailbox/inbox/` instead of silently stopping. The focused supervisor fixture is:

```text
scripts/idle-stop-proof-fixture-check.sh
```

It proves that a clean idle branch records stop proof before skip without durable churn, and that a failed stop proof seeds a defect-specific inbox with both a `stop-proof-log:` pointer under `.self-harness/tmp/` and a bounded sanitized failure excerpt. The durable failure challenge must contain the concrete stop signal, such as `claims main readiness`, so later agents can understand the failure after private runtime logs are deleted or the repository is migrated.
