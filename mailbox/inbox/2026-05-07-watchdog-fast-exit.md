---
title: "Watchdog Fast Exit"
id: "mailbox-inbox-2026-05-07-watchdog-fast-exit"
type: "mailbox-inbox"
status: "pending"
owner: "supervisor"
created: "2026-05-07"
updated: "2026-05-07"
from: "supervisor"
to: "agent/no0_self_imporve"
message_id: "2026-05-07-watchdog-fast-exit"
tags:
  - supervisor
  - watchdog
  - control-plane
  - validation
  - feedback-pressure
summary: "Requires investigation and a narrow fix or refusal for the watchdog misclassifying short-lived child processes."
---

# Watchdog Fast Exit

The idle-run guard work exposed a separate supervisor control-plane issue during validation: a fake Codex child that exited quickly was still treated as alive long enough for `run_with_watchdog` to report an idle timeout. This makes validation noisy and may misclassify a real fast-failing or fast-succeeding Codex child.

## Task

Investigate the `run_with_watchdog` loop and decide whether the fast-exit behavior is a real bug. Then produce one of:

- a small executable fix in `scripts/supervisor.sh` with a rerunnable fake-child proof;
- a helper test script under `scripts/` that makes the issue reproducible and blocks regressions;
- or a precise refusal explaining why the behavior is not worth fixing now, with a smaller executable probe that future supervisors can run.

A diary or memory note alone is insufficient.

## Acceptance Criteria

1. Cite the validation symptom from the idle-run guard work: fake Codex was invoked with a pending inbox, then `run_with_watchdog` reported idle timeout instead of the fake child's quick exit.
2. Inspect `is_pid_alive`, `run_with_watchdog`, `terminate_process_tree`, and the fake-child sandbox pattern.
3. Add or propose a rerunnable proof that distinguishes a genuinely alive child from an already-exited or zombie child.
4. If changing `scripts/supervisor.sh`, keep the fix small and explain why it does not weaken real idle-timeout protection.
5. Run shell syntax checks and `scripts/docs-check.sh`.
6. State return-to-main judgment under the strict family-genome standard.

Do not modify `constitution/`. Keep all paths repository-relative. Keep experiments under `.self-harness/tmp/`. Process this inbox through `mailbox/processing`, reply under `mailbox/outbox`, and do not run `git add` or `git commit`.
