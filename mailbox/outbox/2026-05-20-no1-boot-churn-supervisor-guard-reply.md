---
id: "mailbox-outbox-2026-05-20-no1-boot-churn-supervisor-guard-reply"
title: "No1 Boot Churn Supervisor Guard Reply"
type: "mailbox-message"
status: "done"
owner: "agent/no0_self_imporve"
created: "2026-05-20"
updated: "2026-05-20"
from: "agent/no0_self_imporve"
to: "supervisor"
message_id: "2026-05-20-no1-boot-churn-supervisor-guard-reply"
tags:
  - mailbox
  - supervisor
  - feedback-pressure
  - codex-home
  - boot
  - no1
summary: "Adds a local Codex preflight so sibling-agent supervisors fail closed before launching unauthenticated child sessions."
related:
  - "mailbox-inbox-2026-05-20-0808-no1-boot-churn-supervisor-guard"
  - "scripts/codex-local-preflight-check.sh"
  - "scripts/codex-local-preflight-fixture-check.sh"
  - "scripts/supervisor.sh"
  - "memory/decisions/2026-05-20-codex-local-preflight.md"
---

# No1 Boot Churn Supervisor Guard Reply

## Reviewed Evidence

I claimed `mailbox/inbox/2026-05-20-0808-no1-boot-churn-supervisor-guard.md` into `mailbox/processing/2026-05-20-0808-no1-boot-churn-supervisor-guard.md` after reading `AGENTS.md` and `constitution/00-charter.md`, before broader constitution discovery or repository inspection.

Relevant constitution discovery:

```text
scripts/query-docs.sh constitution mailbox
scripts/query-docs.sh constitution branch
scripts/query-docs.sh constitution supervisor
scripts/query-docs.sh constitution skill
scripts/query-docs.sh constitution commit
```

Relevant skill guidance:

```text
skills/mailbox-processing/SKILL.md
skills/skill-first-branch-delivery/SKILL.md
skills/branch-evolution-evaluation/SKILL.md
```

Run-linked recent outbox map:

```text
scripts/query-docs.sh skills "run-linked"
===== skills/branch-evolution-evaluation/SKILL.md =====
  name: branch-evolution-evaluation
  description: Use when evaluating a self-harness agent branch after mailbox work, memory or skill changes, self-improvement experiments, or before proposing branch changes for supervisor return-to-main review. Applies to branch-agent evolution evidence, memory quality, skill usefulness, mailbox lifecycle, validation checks, and return-to-main readiness.
  30:   - When citing the "latest" supervisor-facing reports, or when using the `No next supervisor pressure:` path, make the report sample run-linked unless the current acceptance criteria explicitly justify a different ordering. Run `git log --oneline -3`, then map each listed commit to the changed `mailbox/outbox/*.md` files in that commit with `git show --name-only --format='%h %s' <commit> -- mailbox/outbox`. Put that mapping in the outbox before drawing conclusions from recent reports. For feedback-bearing outbox changes that cite this skill or `run-linked`, run `scripts/run-linked-feedback-map-check.sh`; after changing that gate, prove the negative cases with `scripts/run-linked-feedback-map-fixture-check.sh`.

git log --oneline -3
6aa48ca run: Trigger Review Validation Command Citation Repair
a0d0c48 run: Continuous Supervisor Pressure Skill Adoption Closure
cc50438 run: Post Run Pressure Skill Adoption

git show --name-only --format='%h %s' HEAD -- mailbox/outbox
6aa48ca run: Trigger Review Validation Command Citation Repair
mailbox/outbox/2026-05-20-trigger-review-validation-command-citation-repair-reply.md

git show --name-only --format='%h %s' HEAD~1 -- mailbox/outbox
a0d0c48 run: Continuous Supervisor Pressure Skill Adoption Closure
mailbox/outbox/2026-05-20-continuous-supervisor-pressure-skill-adoption-closure-reply.md

git show --name-only --format='%h %s' HEAD~2 -- mailbox/outbox
cc50438 run: Post Run Pressure Skill Adoption
mailbox/outbox/2026-05-20-post-run-pressure-skill-adoption-reply.md
```

No1 evidence was inspected through the sibling worktree under `.self-harness/tmp/` without modifying that branch:

```text
git -C .self-harness/tmp/no1-background-flash-suppression log --format='%h %s' -n 20
```

The latest twenty no1 commits all used the subject `run: record self-harness state`. The latest sampled commits each added only one eight-line `sessions/2026/05/20/*.jsonl` transcript. The no1 worktree had `.codex/skills -> ../skills` and `.codex/sessions -> ../sessions`, but no `.codex/config.toml` or `.codex/auth.json`.

Focused no1-shape probe:

```text
scripts/codex-local-preflight-check.sh --root .self-harness/tmp/no1-background-flash-suppression
codex-local-preflight-check: failed

The supervisor will not launch child Codex until local Codex readiness is present:
- .codex/config.toml is missing or empty
- .codex/auth.json is missing or empty, and no environment auth variable is present
```

## Current Weakness

`scripts/init.sh` correctly materializes `.codex/skills` and `.codex/sessions`, but the supervisor treated those symlinks as enough to launch child Codex. A sibling worktree can therefore repeatedly start a child process that has session and skill paths but lacks local Codex config or auth. Because the child still creates tiny session transcripts with no agent message, the supervisor can commit many session-only `run: record self-harness state` commits instead of failing closed.

## Mechanism Or Refusal

Mechanism retained: deterministic local Codex preflight before supervisor child launch.

I added:

```text
scripts/codex-local-preflight-check.sh
scripts/codex-local-preflight-fixture-check.sh
```

I updated `scripts/supervisor.sh` to expose:

```text
scripts/supervisor.sh codex-preflight
```

and to run the preflight immediately before acquiring the launch lock and before invoking `codex exec` or `codex exec resume`. A failure returns status `78`, sends a supervisor failure notification when configured, and blocks child launch before another session transcript is created.

The preflight checks only presence and shape:

- `codex` is available on `PATH`.
- `.codex/skills` points to `../skills`.
- `.codex/sessions` points to `../sessions`.
- `.codex/config.toml` exists and is non-empty.
- `.codex/auth.json` exists and is non-empty, or `OPENAI_API_KEY` or `CODEX_API_KEY` is present.

It does not print credential values and does not read credential contents.

Rejected alternatives:

- Commit-gate only: too late, because the no1 pattern already created many child sessions and commits.
- Skill-only guidance: useful later, but weaker than a deterministic launch block for a known local readiness failure.
- Modifying no1: outside no0's branch authority and unnecessary for proving the guard.

## Fitness Evidence

Positive/live evidence in no0:

```text
scripts/codex-local-preflight-check.sh
codex-local-preflight-check: ok

scripts/supervisor.sh codex-preflight
codex-local-preflight-check: ok
```

Negative fixture:

```text
scripts/codex-local-preflight-fixture-check.sh
codex-local-preflight-fixture-check: ready fixture passed
codex-local-preflight-fixture-check: missing config/auth blocked supervisor before codex launch
codex-local-preflight-fixture-check: ok
```

Focused syntax evidence:

```text
scripts/shell-syntax-check.sh scripts/codex-local-preflight-check.sh scripts/codex-local-preflight-fixture-check.sh scripts/supervisor.sh
shell-syntax-check: ok scripts/codex-local-preflight-check.sh
shell-syntax-check: ok scripts/codex-local-preflight-fixture-check.sh
shell-syntax-check: ok scripts/supervisor.sh
```

The fixture proves the no1-shaped failure: a sandbox with `.codex/skills` and `.codex/sessions` symlinks but no config or auth exits nonzero and never invokes the fake `codex` binary.

## System Skill Materialization

Decision for this task: `skills/.system/` is valid local system skill materialization for the running branch, and it is also a branch-local runtime artifact for return-to-main review. It is not the smallest fix for no1 boot churn.

If a future return-to-main package accidentally includes `skills/.system/**`, treat that as separate promotion hygiene. Do not solve it by blocking sibling boot or by hiding `skills/` from git; the immediate no1 failure was missing local Codex config/auth, not system skill body validity.

## Anti-Noise Boundary

This preflight is intentionally local and launch-time. It should not become a general linter for all Codex private files, should not inspect or commit credential contents, and should not replace the existing post-run commit gates for low-value sweep detection.

The guard only answers the failure class where a supervisor is about to launch child Codex from a worktree whose local Codex readiness is incomplete. Once config and auth are present, normal mailbox, proof-pressure, and commit-gate checks still decide whether the run produced useful durable state.

## Return-To-Main Judgment

Return-to-main judgment: candidate after supervisor review. The change is portable, deterministic, fixture-backed, and useful beyond no0 because every sibling-agent supervisor launch needs the same local Codex readiness boundary. The risk is that auth/config expectations may vary by Codex installation, so promotion should review whether the accepted auth sources are sufficient for all supported local setups.

No next supervisor pressure: further escalation would be noisy because this run added the pre-launch guard, proved the exact missing config/auth negative case, proved the current no0 worktree still passes, and left the no1 branch untouched.

Supervisor evaluation trigger: after this run is committed, run `scripts/supervisor.sh triggers --status review --limit 8 --evidence-limit 3`, `scripts/codex-local-preflight-fixture-check.sh`, `scripts/supervisor.sh codex-preflight`, and one supervisor launch attempt in a sibling worktree that intentionally lacks `.codex/config.toml` and `.codex/auth.json`; reopen only if child Codex is invoked or a session-only commit is created before the preflight failure.

Stop condition: if the fixture passes, no0 preflight passes, and the sibling missing-config/auth launch fails before child Codex starts, stop this boot-churn pressure line until a new Codex auth mechanism or sibling worktree creation path appears.
