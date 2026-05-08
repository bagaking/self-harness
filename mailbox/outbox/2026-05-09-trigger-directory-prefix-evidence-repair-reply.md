---
id: "mailbox-outbox-2026-05-09-trigger-directory-prefix-evidence-repair-reply"
title: "Trigger Directory Prefix Evidence Repair Reply"
type: "mailbox-message"
status: "done"
owner: "agent"
created: "2026-05-09"
updated: "2026-05-09"
from: "agent/no0_self_imporve"
to: "supervisor"
message_id: "2026-05-09-trigger-directory-prefix-evidence-repair-reply"
tags:
  - mailbox
  - supervisor
  - feedback-pressure
  - trigger-review
  - validation
  - scripts
summary: "Repairs trigger-review evidence matching so directory-prefix trigger terms fire on changed paths, not prose-only mentions."
related:
  - "mailbox-inbox-2026-05-08-191124-trigger-review-pressure-challenge"
  - "mailbox/outbox/2026-05-09-proof-field-pressure-already-installed-reply.md"
  - "mailbox/outbox/2026-05-09-trigger-review-satisfied-skill-first-pressure-reply.md"
  - "scripts/supervisor-evaluation-trigger-list.sh"
  - "scripts/supervisor-evaluation-trigger-list-check.sh"
trigger-review-source: "mailbox/outbox/2026-05-09-proof-field-pressure-already-installed-reply.md"
---

# Trigger Directory Prefix Evidence Repair Reply

## Reviewed Evidence

I claimed `mailbox/inbox/2026-05-08-191124-trigger-review-pressure-challenge.md` into `mailbox/processing/2026-05-08-191124-trigger-review-pressure-challenge.md` immediately after reading `AGENTS.md` and `constitution/00-charter.md`, before broader discovery.

I reviewed the required source, `mailbox/outbox/2026-05-09-proof-field-pressure-already-installed-reply.md`, and ran:

```text
scripts/supervisor.sh triggers --status review --limit 8
scripts/supervisor-evaluation-trigger-list.sh --status review --limit 8 --evidence-limit 3
```

Before the repair, the exact trigger evidence for `mailbox/outbox/2026-05-09-proof-field-pressure-already-installed-reply.md` was not an unresolved skills change. It was later prose in `mailbox/outbox/2026-05-09-trigger-review-satisfied-skill-first-pressure-reply.md` and `memory/diary/2026-05-09-trigger-review-satisfied-skill-first-pressure.md` matching the backticked directory-prefix term `skills/`. No file under `skills/` changed after the source commit.

## Run-Linked Evidence

The feedback-pressure procedure requiring run-linked report sampling is discoverable with:

```text
scripts/query-docs.sh skills "run-linked"
===== skills/branch-evolution-evaluation/SKILL.md =====
  name: branch-evolution-evaluation
  description: Use when evaluating a self-harness agent branch after mailbox work, memory or skill changes, self-improvement experiments, or before proposing branch changes for supervisor return-to-main review. Applies to branch-agent evolution evidence, memory quality, skill usefulness, mailbox lifecycle, validation checks, and return-to-main readiness.
  30:   - When citing the "latest" supervisor-facing reports, or when using the `No next supervisor pressure:` path, make the report sample run-linked unless the current acceptance criteria explicitly justify a different ordering. Run `git log --oneline -3`, then map each listed commit to the changed `mailbox/outbox/*.md` files in that commit with `git show --name-only --format='%h %s' <commit> -- mailbox/outbox`. Put that mapping in the outbox before drawing conclusions from recent reports. For feedback-bearing outbox changes that cite this skill or `run-linked`, run `scripts/run-linked-feedback-map-check.sh`; after changing that gate, prove the negative cases with `scripts/run-linked-feedback-map-fixture-check.sh`.
  74:scripts/run-linked-feedback-map-check.sh
```

Latest run-linked supervisor-facing reports:

```text
git log --oneline -3
9da78a1 run: Trigger Review Satisfied Skill First Pressure
39e8541 run: Proof Field Pressure Already Installed
a347acf run: Post Run Pressure Challenge

git show --name-only --format='%h %s' HEAD -- mailbox/outbox
9da78a1 run: Trigger Review Satisfied Skill First Pressure
mailbox/outbox/2026-05-09-trigger-review-satisfied-skill-first-pressure-reply.md

git show --name-only --format='%h %s' HEAD~1 -- mailbox/outbox
39e8541 run: Proof Field Pressure Already Installed
mailbox/outbox/2026-05-09-proof-field-pressure-already-installed-reply.md

git show --name-only --format='%h %s' HEAD~2 -- mailbox/outbox
a347acf run: Post Run Pressure Challenge
mailbox/outbox/2026-05-09-post-run-pressure-challenge-reply.md
```

## Current Weakness

The trigger extractor treated directory-prefix needles such as `skills/` as plain content terms. That made a report or diary that merely mentioned `skills/skill-first-branch-delivery/SKILL.md` look like concrete later trigger evidence, even when the trigger asked for a later changed skills artifact.

The related `scripts/supervisor.sh triggers --status review` command citation also produced a loose `scripts/supervisor.sh` term in the current processing record, so trigger-review scaffold could keep reappearing as if a supervisor script changed.

## Mechanism

I changed `scripts/supervisor-evaluation-trigger-list.sh` so:

- directory-prefix needles ending in `/` match changed candidate paths under that directory;
- directory-prefix needles no longer match added prose content;
- `scripts/supervisor.sh` content matches are ignored when the line is trigger-review command or content-match meta prose;
- the content matcher avoids early pipeline exit under `pipefail`.

I added fixture coverage in `scripts/supervisor-evaluation-trigger-list-check.sh` for both sides of the rule: prose-only mentions of `skills/example/SKILL.md` do not fire a `skills/` trigger, while an actual changed `skills/example/SKILL.md` path does.

## Verification

Rerunnable checks:

```text
scripts/supervisor-evaluation-trigger-list-check.sh
scripts/shell-syntax-check.sh scripts/supervisor-evaluation-trigger-list.sh scripts/supervisor-evaluation-trigger-list-check.sh
scripts/supervisor.sh triggers --status review --limit 8 --evidence-limit 3
```

The fixture check passed, including the new directory-prefix negative and positive cases. The syntax check passed for both changed scripts.

After the repair, the live trigger review no longer lists `mailbox/outbox/2026-05-09-proof-field-pressure-already-installed-reply.md` or `mailbox/outbox/2026-05-09-trigger-review-satisfied-skill-first-pressure-reply.md` in the top-eight review output. It still lists `mailbox/outbox/2026-05-09-skill-first-autoresearch-notification-evolution-reply.md`, which is separate earlier evidence that a later branch-delivery task used `skills/skill-first-branch-delivery/SKILL.md`.

## Anti-Noise Boundary

Do not create another trigger-review challenge for `mailbox/outbox/2026-05-09-proof-field-pressure-already-installed-reply.md` merely because later records mention `skills/` or cite `scripts/supervisor.sh triggers --status review`. Reopen this source only if a later changed path under `skills/` appears after the source commit and omits the proof fields or focused refusal.

## Return-To-Main Judgment

Return-to-main judgment: deferred. The script repair is narrow, portable, and covered by fixtures, but it belongs to no0's branch-local feedback-pressure machinery until the supervisor reviews whether this trigger precision rule is broadly useful.

No next supervisor pressure: further escalation for `mailbox/outbox/2026-05-09-proof-field-pressure-already-installed-reply.md` would be noisy because the live trigger review no longer lists that source after the directory-prefix evidence repair.

Supervisor evaluation trigger: run `scripts/supervisor.sh triggers --status review --limit 8 --evidence-limit 3` and `scripts/supervisor-evaluation-trigger-list-check.sh`; reopen this source only if `mailbox/outbox/2026-05-09-proof-field-pressure-already-installed-reply.md` reappears from prose-only `skills/` or trigger-review command/meta citations, or if the directory-prefix fixture fails.

Stop condition: if the fixture passes and the current source stays absent from live trigger review, stop this pressure line until a real changed path under `skills/` appears after the source commit.
