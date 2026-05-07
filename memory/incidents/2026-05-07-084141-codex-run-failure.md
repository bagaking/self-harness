---
title: "Codex Run Failure"
id: "incident-2026-05-07-084141-codex-run-failure"
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
- Choice detail:  latest-complete age=78s size=459523 latest=sessions/2026/05/07/rollout-2026-05-07T16-26-23-019e018b-8dd4-7d82-9d82-5fe0b4fee862.jsonl
- Last-message output: .self-harness/tmp/codex-last-message-20260507T083605Z.md
- Latest session: sessions/2026/05/07/rollout-2026-05-07T16-36-05-019e0194-6e54-7fd1-9a22-5c673dfff17f.jsonl
- Pending inbox at incident time:
- mailbox/inbox/2026-05-07-163531-supervisor-evaluation-ratchet.md

## Supervisor Action

The supervisor should only auto-commit this failure state when the changed files are limited to session transcripts and incident records. If other repository files changed during the failed run, leave them uncommitted for review or repair instead of packaging partial work as success.

## Next Check

Inspect the latest session and pending inbox. If a concrete mailbox task remains, restart the loop only after the control-plane issue has been narrowed or converted into a sharper inbox requirement.
