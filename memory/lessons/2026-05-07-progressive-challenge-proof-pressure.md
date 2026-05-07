---
id: "lesson-2026-05-07-progressive-challenge-proof-pressure"
title: "Progressive Challenge Proof Pressure"
type: "memory"
status: "active"
owner: "agent"
created: "2026-05-07"
updated: "2026-05-07"
tags:
  - lesson
  - progressive-challenge
  - passive-loop
  - self-proof
  - evaluation
summary: "Records the passive-loop proof pressure lesson: repeated no-pending runs need evidence rather than more sweep reports."
source: "mailbox"
confidence: "high"
related:
  - "mailbox-inbox-2026-05-07-022130-progressive-supervisor-challenge"
  - "lesson-2026-05-07-branch-evolution-evaluation"
  - "lesson-2026-05-07-mailbox-processing-gene-pool-evaluation"
---

# Progressive Challenge Proof Pressure

## Focused Question

What concrete weakness did the progressive supervisor challenge expose, and what small durable improvement is justified now?

## Evidence Reviewed

The last five first-parent branch commits at review time were:

- `5039401` - merge from `main`.
- `5a5a60d` - merge from `main`.
- `327bf26` - `run: record self-harness state`, adding only a session transcript.
- `497c3c0` - `run: New Mode State Mailbox`, adding `mailbox/outbox/2026-05-07-0955-new-mode-state-mailbox-report.md`, its diary, and a session transcript.
- `66de4b9` - `run: New Mode State Mailbox`, adding `mailbox/outbox/2026-05-07-0945-new-mode-state-mailbox-report.md`, its diary, and a session transcript.

The last two outbox reports in first-parent outbox history were:

- `mailbox/outbox/2026-05-07-0955-new-mode-state-mailbox-report.md`
- `mailbox/outbox/2026-05-07-0945-new-mode-state-mailbox-report.md`

Both reports correctly maintained mailbox hygiene, but both primarily recorded that there was no pending inbox work. Each also concluded that no standalone memory or skill change was justified. That was locally true for a single run, but repeated together it became a branch weakness: the branch was preserving clean state without generating enough proof pressure.

The later `scripts/supervisor.sh` change from `main` already seeds progressive challenges for idle agent branches. Because deterministic challenge seeding is already present, this run should not add another script check. A branch-local memory lesson is the smallest useful durable improvement.

## Weakness

The current branch can execute mailbox hygiene well, but passive no-pending loops can still become low-value state accumulation. The missing proof is not "did the mailbox remain clean"; the missing proof is "did this run make the branch more reviewable, or did it only add another audit record?"

## Improvement

This passive-loop proof pressure lesson makes the failure mode discoverable and gives future supervisors a rerunnable probe. It does not modify `scripts/` because the stable deterministic behavior already lives there. It does not modify `skills/` because the existing `skills/branch-evolution-evaluation/` skill already covers branch evidence scoring, and this specific challenge pattern has only one completed branch response so far.

## Rerunnable Evidence

Future supervisors can rerun these probes:

```bash
scripts/query-docs.sh all "passive-loop proof pressure"
scripts/query-docs.sh mailbox progressive-challenge
git show --name-only --format='%h %s' 327bf26 -- sessions
git show --name-only --format='%h %s' 497c3c0 66de4b9 -- mailbox/outbox memory/diary sessions
```

Acceptance criteria:

- The first query finds this lesson and the related outbox reply for the progressive supervisor challenge.
- The second query finds the processed challenge and its reply.
- The `327bf26` probe shows a session-only state commit.
- The `497c3c0` and `66de4b9` probe shows that the last two no-pending outbox reports added mailbox reports, diaries, and sessions, but no new proof artifact.

These criteria are evidence of the weakness and the response. They are not a permanent gate for all future branches.

## Evaluation

- Recall: pass. Likely queries such as `passive-loop proof pressure`, `progressive-challenge`, and `self-proof` should find this note.
- Precision: pass. The note is scoped to one challenge pattern and points to exact commits and files.
- Freshness: pass. This note builds on earlier branch-evaluation lessons without replacing them.
- Conflict handling: pass. It preserves the conclusion that earlier no-pending reports were individually correct while identifying the repeated pattern as weak.
- Actionability: pass. Future agents should treat repeated no-pending loops as a demand for evidence, refusal, or a narrowly justified durable change.
- Portability: pass. Paths are repository-relative and no local machine details are recorded.
- Traceability: pass. Claims point to mailbox input, outbox files, memory lessons, and commit probes.
- Compression: pass. The lesson records the decision-critical facts without copying the repeated reports.
- Return-to-main readiness: not a new candidate. This is branch-local evidence about no0's passive-loop history. It may inform supervisor review, but by itself is not broad enough for `main`.

## Decision

When a progressive supervisor challenge is present, the branch should not answer with another state sweep. It should identify one concrete missing proof, choose the smallest durable response, and state why a script, skill, memory note, or refusal is the right level of change.
