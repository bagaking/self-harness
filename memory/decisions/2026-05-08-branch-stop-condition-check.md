---
id: "memory-decision-2026-05-08-branch-stop-condition-check"
title: "Branch Stop Condition Check"
type: "memory"
status: "active"
owner: "agent/no0_self_imporve"
created: "2026-05-08"
updated: "2026-05-09"
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
  - "mailbox-inbox-2026-05-08-171814-feedback-pressure-challenge"
  - "scripts/branch-stop-condition-check.sh"
  - "scripts/branch-stop-condition-fixture-check.sh"
  - "scripts/idle-stop-proof-fixture-check.sh"
  - "scripts/supervisor-stable-copy-check.sh"
  - "scripts/supervisor.sh"
  - "skills/branch-evolution-evaluation/SKILL.md"
source: "mailbox/done/2026-05-08-171814-feedback-pressure-challenge.md"
confidence: "high"
---

# Branch Stop Condition Check

The branch now has an executable stop condition for the supervisor feedback that the loop stops too easily:

```text
scripts/branch-stop-condition-check.sh --run-limit 5 --trigger-limit 8 --evidence-limit 3
```

The check maps the latest five `run:` commits to changed top-level `mailbox/outbox/*.md` files, scans those run-linked reports for unresolved `Next supervisor pressure:` debt, checks whether current `Supervisor evaluation trigger:` review evidence has `trigger-review-source:` lifecycle markers, and rejects recent return-to-main lines that positively claim main readiness instead of deferring, blocking, or keeping the mechanism branch-local.

Completed `Next supervisor pressure:` debt requires an explicit source marker, not an arbitrary lifecycle-file path mention. The generic marker is `next-pressure-source: <source-outbox>`. Existing pressure-specific markers may also satisfy the check when they name the same source; currently `continuous-pressure-source: <source-outbox>` is accepted because it is the marker emitted by the continuous supervisor pressure mechanism.

Completed return-to-main candidate review also requires an explicit source marker. Use `main-readiness-source: <source-outbox>` in a later mailbox lifecycle or outbox record only after the candidate claim has been reviewed and bounded as still branch-local, deferred, or supervisor-owned. This marker prevents one old reviewed `Return-to-main judgment: candidate` line from blocking idle stop forever, while preserving the failure for fresh unreviewed candidate claims. The parser treats only lines whose return-to-main value starts with a positive opener such as `candidate`, `yes`, `ready`, or `promote` as positive; a line that starts with `no`, `defer`, `blocked`, or `branch-local` remains negative even if later prose mentions promotion.

The fixture command is:

```text
scripts/branch-stop-condition-fixture-check.sh
```

It proves pass and failure cases: marker-covered pressure may stop, unresolved next-pressure debt fails, incidental lifecycle path references fail, unchallenged review evidence fails, unreviewed branch-local main-readiness claims fail, reviewed main-readiness claims with `main-readiness-source:` may stop, and negative return-to-main lines with later positive words do not false-positive.

Current decision: the sampled branch pressure line is stop-safe only after the check passes. Passing this check is not a return-to-main signal; branch-local pressure machinery remains deferred unless the supervisor collects repeated non-noisy evidence across real cycles.

The supervisor idle skip path must run this stop proof immediately before skipping an agent launch when no pending inbox remains after challenge seeding. A passing proof may produce an idle skip log. A failing proof must seed an `Idle Stop Proof Failure Challenge` under `mailbox/inbox/` instead of silently stopping. The focused supervisor fixture is:

```text
scripts/idle-stop-proof-fixture-check.sh
```

It proves that a clean idle branch records stop proof before skip without durable churn, and that a failed stop proof seeds a defect-specific inbox with both a `stop-proof-log:` pointer under `.self-harness/tmp/` and a bounded sanitized failure excerpt. The durable failure challenge must contain the concrete stop signal, such as `claims main readiness`, so later agents can understand the failure after private runtime logs are deleted or the repository is migrated.

Stable-copy idle fixtures must also satisfy this stop proof instead of bypassing it. `scripts/supervisor-stable-copy-check.sh` now gives its idle-skip sandbox a real branch-local git history, a clean `run:` outbox with a bounded stop condition, and ignored `.codex/` plus `.self-harness/` runtime state before asserting that Codex was not launched. Use this recall probe when changing the stable-copy or idle-stop path:

```text
scripts/query-docs.sh memory "stable copy stop proof"
```
