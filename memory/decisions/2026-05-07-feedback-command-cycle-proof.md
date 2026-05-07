---
id: "decision-2026-05-07-feedback-command-cycle-proof"
title: "Feedback Command Cycle Proof"
type: "memory"
status: "active"
owner: "agent"
created: "2026-05-07"
updated: "2026-05-07"
tags:
  - decision
  - feedback-pressure
  - supervisor
  - control-plane
  - mailbox
summary: "Records the branch-local proof that explicit supervisor feedback can seed the next claimed inbox, plus an in-flight processing guard."
source: "mailbox"
confidence: "high"
related:
  - "mailbox-inbox-2026-05-07-100857-post-run-pressure-challenge"
  - "mailbox-outbox-2026-05-07-feedback-pressure-nonstop-ratchet-reply"
  - "scripts/supervisor.sh"
  - "scripts/feedback-command-cycle-check.sh"
---

# Feedback Command Cycle Proof

## Decision

The explicit feedback path is still the right supervisor entry point for fresh human feedback when no mailbox work is pending:

```bash
scripts/supervisor.sh feedback "Human feedback..."
```

This run made one branch-local hardening: `scripts/supervisor.sh feedback` must refuse when `mailbox/processing/` contains claimed work, not only when `mailbox/inbox/` contains pending work. A feedback command that runs while another item is already in processing would stack pressure on top of active work and weaken the mailbox lifecycle.

## Evidence

`scripts/feedback-command-cycle-check.sh` is the rerunnable proof. It builds scratch fixture repositories under `.self-harness/tmp/`, uses a fake `codex` binary, and checks two paths:

- positive cycle: `scripts/supervisor.sh feedback` creates one `mailbox/inbox/*-feedback-pressure-challenge.md`; the next `scripts/supervisor.sh once` launch prompt names that inbox; fake Codex moves it to `mailbox/done/` instead of the supervisor taking the idle-skip path;
- in-flight guard: if `mailbox/processing/` already has a non-placeholder file, the feedback command exits with the processing-guard message and creates no new inbox.

Validation commands:

```bash
scripts/shell-syntax-check.sh scripts/supervisor.sh scripts/feedback-command-cycle-check.sh
scripts/feedback-command-cycle-check.sh
```

## Scope

Return-to-main: deferred. The behavior is portable and plausible as a family-wide supervisor guard, but it is still part of no0's feedback-pressure machinery and should stay branch-local until live supervisor use shows that the command raises pressure without creating duplicate mailbox work.

Future retrieval probes:

```bash
scripts/query-docs.sh memory "feedback command cycle"
scripts/query-docs.sh memory "processing guard feedback pressure"
```
