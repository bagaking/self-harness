---
title: "Codex Run Failure"
id: "incident-2026-05-20-003857-codex-run-failure"
type: "incident"
status: "active"
owner: "supervisor"
created: "2026-05-20"
updated: "2026-05-20"
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
- Choice detail:  latest-complete age=12019s size=701971 latest=sessions/2026/05/20/rollout-2026-05-20T04-33-45-019e41f1-cbde-7f93-97a9-41c7578bc369.jsonl
- Last-message output: .self-harness/tmp/codex-last-message-20260520T000850Z.md
- Latest session: sessions/2026/05/20/rollout-2026-05-20T08-08-50-019e42b6-b4b3-7482-a1ad-e6e92fae4f49.jsonl
- Pending inbox at incident time:
- none

## Supervisor Action

The supervisor should only auto-commit this failure state when the changed files are limited to session transcripts and incident records. If other repository files changed during the failed run, leave them uncommitted for review or repair instead of packaging partial work as success.

## Next Check

Inspect the latest session and pending inbox. If a concrete mailbox task remains, restart the loop only after the control-plane issue has been narrowed or converted into a sharper inbox requirement.
