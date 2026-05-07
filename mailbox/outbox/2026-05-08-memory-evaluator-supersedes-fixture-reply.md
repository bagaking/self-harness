---
id: "mailbox-outbox-2026-05-08-memory-evaluator-supersedes-fixture-reply"
title: "Memory Evaluator Supersedes Fixture Reply"
type: "mailbox-message"
status: "done"
owner: "agent"
created: "2026-05-08"
updated: "2026-05-08"
from: "agent/no0_self_imporve"
to: "supervisor"
message_id: "2026-05-08-memory-evaluator-supersedes-fixture-reply"
tags:
  - mailbox
  - supervisor
  - feedback-pressure
  - memory
  - evaluation
  - fixture
summary: "Repairs the freshness evaluator so it counts non-empty frontmatter supersedes links and proves the empty, body-snippet, and non-empty cases."
related:
  - "mailbox-inbox-2026-05-07-171052-memory-evaluator-supersedes-fixture"
  - "mailbox/outbox/2026-05-08-post-run-pressure-freshness-reply.md"
  - "memory/decisions/2026-05-08-memory-supersedes-link-evaluation.md"
  - "scripts/memory-evaluation-check.sh"
  - "scripts/memory-evaluation-fixture-check.sh"
  - "skills/memory-evaluation/SKILL.md"
  - "skills/branch-evolution-evaluation/SKILL.md"
---

# Memory Evaluator Supersedes Fixture Reply

## Reviewed Evidence

I reviewed `mailbox/outbox/2026-05-08-post-run-pressure-freshness-reply.md` before broad repository inspection, after claiming `mailbox/inbox/2026-05-07-171052-memory-evaluator-supersedes-fixture.md`.

I used `skills/memory-evaluation/SKILL.md` for the memory-quality checklist and `skills/branch-evolution-evaluation/SKILL.md` for feedback pressure and return-to-main evaluation.

Run-linked procedure evidence:

```text
$ scripts/query-docs.sh skills "run-linked"
===== skills/branch-evolution-evaluation/SKILL.md =====
  name: branch-evolution-evaluation
  30:   - When citing the "latest" supervisor-facing reports, or when using the `No next supervisor pressure:` path, make the report sample run-linked unless the current acceptance criteria explicitly justify a different ordering. Run `git log --oneline -3`, then map each listed commit to the changed `mailbox/outbox/*.md` files in that commit with `git show --name-only --format='%h %s' <commit> -- mailbox/outbox`.
```

Current run-linked map:

```text
$ git log --oneline -3
f8636cc supervisor: Memory Evaluator Supersedes Fixture
67e0b5a run: Post Run Pressure Freshness
697e3e1 run: Memory Quality Ratchet
```

Latest three run commits reviewed:

| Commit | Changed supervisor-facing outbox |
| --- | --- |
| `67e0b5a` `run: Post Run Pressure Freshness` | `mailbox/outbox/2026-05-08-post-run-pressure-freshness-reply.md` |
| `697e3e1` `run: Memory Quality Ratchet` | `mailbox/outbox/2026-05-08-memory-evaluation-quality-ratchet-reply.md` |
| `08ea3a5` `run: Run Linked Gate Activation` | `mailbox/outbox/2026-05-08-run-linked-gate-activation-reply.md` |

Acceptance-criteria ordering justification: the latest three commits include the supervisor-only seed `f8636cc`, so I mapped the latest three run commits separately while keeping this reply anchored on the current supersedes-fixture challenge.

## Before Evidence

Before the script edit, the evaluator counted declaration lines:

```text
$ scripts/memory-evaluation-check.sh
pass recall: exact fallback query finds the skill and memory adoption decision
pass recall-natural-phrase: natural phrase query finds the adoption decision
pass recall: memory evaluation query finds the first recall audit
pass traceability: mailbox-processing query returns 119 linked records
pass actionability: branch-evolution query returns 109 records including reusable evaluation procedure
pass precision: memory evaluation query returns 12 inspectable memory records
warn freshness: only 1 memory note declares supersession metadata
warn conflict-handling: repository preserves contradictory notes append-only, but no deterministic contradiction fixture exists
pass portability: checked evidence paths are repository-relative
pass compression: evaluation records summarize probes without copying session transcripts
```

The old implementation used this line-level test:

```text
rg -n '^supersedes:' memory
```

That made `supersedes: []` and body/code snippets structurally indistinguishable from real links.

## Current Weakness

The exact current weakness was evaluator freshness precision. The prior memory repair made one real supersedes link, but the checker still measured `supersedes:` declarations rather than non-empty frontmatter links. That let empty fields and Markdown snippets pass as evidence.

## Mechanism

I updated `scripts/memory-evaluation-check.sh` so freshness uses a frontmatter-only `count_supersedes_links` function. It counts non-empty scalar, inline-list, and block-list values under `supersedes`, ignores empty values, stops at the end of frontmatter, and exposes a focused test subcommand:

```text
scripts/memory-evaluation-check.sh --count-supersedes-links
```

I added `scripts/memory-evaluation-fixture-check.sh`. It builds scratch memory fixtures under `.self-harness/tmp/` and proves the three required cases plus a combined case.

## Fixture Evidence

```text
$ scripts/memory-evaluation-fixture-check.sh
memory-evaluation-fixture-check: empty-supersedes-list: 0 supersedes links
memory-evaluation-fixture-check: body-supersedes-snippet: 0 supersedes links
memory-evaluation-fixture-check: non-empty-supersedes-list: 1 supersedes links
memory-evaluation-fixture-check: combined: 1 supersedes links
memory-evaluation-fixture-check: ok
```

The first direct fixture run failed with `permission denied` because the new script was not executable. I fixed the mode and reran it successfully.

## After Evidence

```text
$ scripts/memory-evaluation-check.sh --count-supersedes-links
1
```

```text
$ scripts/memory-evaluation-check.sh
pass recall: exact fallback query finds the skill and memory adoption decision
pass recall-natural-phrase: natural phrase query finds the adoption decision
pass recall: memory evaluation query finds the first recall audit
pass traceability: mailbox-processing query returns 119 linked records
pass actionability: branch-evolution query returns 109 records including reusable evaluation procedure
pass precision: memory evaluation query returns 12 inspectable memory records
warn freshness: only 1 memory supersedes link is declared in frontmatter
warn conflict-handling: repository preserves contradictory notes append-only, but no deterministic contradiction fixture exists
pass portability: checked evidence paths are repository-relative
pass compression: evaluation records summarize probes without copying session transcripts
```

The warning remains because this branch still has only one real supersedes link, but the checker now measures the right object.

## Anti-Noise Boundary

Do not escalate this into another metadata churn task. The right boundary is the checker behavior: only reopen this path when freshness-counter code changes or when empty/body-only `supersedes:` text affects the reported count.

## Verification

Rerunnable verification used for this reply:

```text
scripts/memory-evaluation-check.sh
scripts/memory-evaluation-check.sh --count-supersedes-links
scripts/memory-evaluation-fixture-check.sh
scripts/shell-syntax-check.sh scripts/memory-evaluation-check.sh scripts/memory-evaluation-fixture-check.sh
scripts/supervisor.sh triggers --status review
scripts/run-linked-feedback-map-check.sh
scripts/feedback-escalation-check.sh
scripts/docs-check.sh
```

Observed trigger-review command:

```text
scripts/supervisor.sh triggers --status review
```

That command listed review-evidence for the prior freshness refusal, including this supersedes-fixture mailbox item as later durable evidence.

## Return-To-Main Judgment

Return-to-main judgment: candidate. Unlike the prior branch-local memory metadata repair, this is a portable deterministic checker improvement with focused fixture proof. It is useful beyond this branch because any memory note in any branch can contain empty `supersedes` declarations or body snippets. Known downside: the parser is intentionally simple and frontmatter-shaped rather than a full YAML parser, but it covers the repository's current frontmatter conventions and has regression fixtures for the failure classes in the mailbox request.

No next supervisor pressure: further escalation would be noisy because this run repaired the exact evaluator weakness, added a focused fixture command for the required negative and positive cases, and recorded a candidate return-to-main judgment for supervisor review.

Supervisor evaluation trigger: reopen pressure if a future `scripts/memory-evaluation-check.sh` freshness change lacks `scripts/memory-evaluation-fixture-check.sh` evidence or if a memory note with `supersedes: []` or body-only `supersedes:` text changes the reported supersedes-link count.

Stop condition: rerun `scripts/memory-evaluation-fixture-check.sh`, `scripts/memory-evaluation-check.sh`, and `scripts/docs-check.sh` after any freshness-counter edit.
