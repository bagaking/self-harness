---
title: "Codex Run Failure"
id: "incident-2026-05-07-101520-codex-run-failure"
type: "incident"
status: "active"
owner: "supervisor"
created: "2026-05-07"
updated: "2026-05-07"
tags:
  - incident
  - supervisor
  - codex-run
  - watchdog
summary: "Records a Codex child run that exited nonzero before producing a normal diary-backed commit."
---

# Codex Run Failure

## Summary

The supervisor child run exited with status 124. This incident exists so a failed or timed-out run is not disguised as ordinary progress.

## Run Context

- Mode: new
- Choice detail:  latest-complete age=50s size=539188 latest=sessions/2026/05/07/rollout-2026-05-07T17-57-24-019e01de-e026-78f1-8b81-1035edbe64ad.jsonl
- Last-message output: .self-harness/tmp/codex-last-message-20260507T100943Z.md
- Latest session: sessions/2026/05/07/rollout-2026-05-07T18-09-43-019e01ea-297b-71e1-9818-9de335045d2c.jsonl
- Pending inbox at incident time:
- mailbox/inbox/2026-05-07-100857-post-run-pressure-challenge.md

## Supervisor Action

The supervisor should only auto-commit this failure state when the changed files are limited to session transcripts and incident records. If other repository files changed during the failed run, leave them uncommitted for review or repair instead of packaging partial work as success.

## Next Check

Inspect the latest session and pending inbox. If a concrete mailbox task remains, restart the loop only after the control-plane issue has been narrowed or converted into a sharper inbox requirement.
