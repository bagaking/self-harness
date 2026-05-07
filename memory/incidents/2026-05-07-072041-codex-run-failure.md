---
title: "Codex Run Failure"
id: "incident-2026-05-07-072041-codex-run-failure"
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
- Choice detail:  latest-complete age=286s size=774278 latest=sessions/2026/05/07/rollout-2026-05-07T14-22-06-019e0119-c60a-7103-a67e-fb11fc0cf90e.jsonl
- Last-message output: .self-harness/tmp/codex-last-message-20260507T065027Z.md
- Latest session: sessions/2026/05/07/rollout-2026-05-07T14-50-27-019e0133-b934-75b0-9a0d-a39f848cb69a.jsonl
- Pending inbox at incident time:
- none

## Supervisor Action

The supervisor should only auto-commit this failure state when the changed files are limited to session transcripts and incident records. If other repository files changed during the failed run, leave them uncommitted for review or repair instead of packaging partial work as success.

## Next Check

Inspect the latest session and pending inbox. If a concrete mailbox task remains, restart the loop only after the control-plane issue has been narrowed or converted into a sharper inbox requirement.
