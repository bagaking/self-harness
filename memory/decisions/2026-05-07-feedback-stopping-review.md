---
id: "decision-2026-05-07-feedback-stopping-review"
title: "Feedback Stopping Review"
type: "memory"
status: "active"
owner: "agent"
created: "2026-05-07"
updated: "2026-05-07"
tags:
  - decision
  - feedback-pressure
  - supervisor
  - stopping
  - return-to-main
summary: "Defines when a feedback-bearing no-next-pressure refusal is a local anti-noise boundary and when it must become a higher-level supervisor challenge."
source: "mailbox"
confidence: "high"
related:
  - "mailbox-inbox-2026-05-07-151827-feedback-pressure-challenge"
  - "mailbox-inbox-2026-05-07-152451-post-run-pressure-challenge"
  - "decision-2026-05-07-feedback-escalation-check"
  - "mailbox-outbox-2026-05-07-supervisor-evaluation-trigger-list-reply"
  - "mailbox-outbox-2026-05-07-151827-feedback-pressure-challenge-reply"
  - "mailbox-outbox-2026-05-07-150717-post-run-pressure-challenge-reply"
  - "mailbox-outbox-2026-05-07-225840-gate-promotion-negative-evidence-reply"
---

# Feedback Stopping Review

## Decision

A feedback-bearing `No next supervisor pressure:` refusal is valid only as a local anti-noise boundary. It is not permission for the supervisor loop to stop evaluating the branch.

A refusal is reviewable when all of these are true:

- It answers the current mailbox acceptance criteria with evidence, not a generic repository sweep.
- It explains why another immediate challenge would add noise.
- It names a concrete future evaluation signal through the existing trigger-backed refusal path.
- It cites a rerunnable trigger review command such as `scripts/supervisor.sh triggers --status review`.
- It leaves return-to-main deferred unless the improvement is portable, validated beyond one branch-local case, and has no known family-genome downside.

The refusal must become a higher-level challenge when any of these are true:

- Fresh human or supervisor feedback says the branch stopped too easily, lowered the proof bar, or treated task completion as sufficient supervision.
- `scripts/supervisor.sh triggers --status review` reports `review-evidence` for a trigger-backed refusal whose matched evidence points to a live weakness.
- The latest run commits add more examples for an already-proven narrow mechanism while the meta-level stopping rule remains unreviewed.
- The latest supervisor-facing outbox reports end with local refusals but do not define what evidence the next supervisor should inspect.
- A return-to-main candidate is proposed from branch-local proof without a stricter family-genome review record.
- A review says the sampled "latest supervisor-facing reports" came from filename order or another undocumented ordering rather than the reports tied to the latest run commits.

## Correction

The phrase "latest supervisor-facing reports" is ambiguous unless the ordering is stated. For feedback-bearing stopping review, prefer recent run-linked reports: inspect `git log --oneline -3`, then use each run commit's changed `mailbox/outbox/*.md` report as the report sample. A different ordering, such as lexicographic filename order or filesystem discovery order, is valid only when the outbox report explicitly justifies why that ordering answers the current acceptance criteria.

This corrects `mailbox/outbox/2026-05-07-151827-feedback-pressure-challenge-reply.md`, which listed three supervisor-facing reports that were useful but were not the reports tied to the latest three run commits named in the same reply.

## Evidence To Inspect

Future supervisors should inspect these signals before accepting a feedback-bearing stop:

- `scripts/supervisor.sh triggers --status review` for trigger-backed refusals with later durable evidence.
- The latest three run commits with `git log --oneline -3`, then the changed files named in those commit messages.
- The latest three supervisor-facing `mailbox/outbox/*.md` reports linked from those run commits, especially their current weakness, anti-noise boundary, validation, and return-to-main sections.
- The current feedback-bearing outbox report for exactly one continuity path: either a concrete `Next supervisor pressure:` line or a bounded local refusal accepted by `scripts/feedback-escalation-check.sh`.
- Any memory decision or skill change cited as the mechanism, discovered through `scripts/query-docs.sh memory "feedback stopping review"` or a similarly specific query.

## Rerunnable Probe

Use this probe when reviewing whether the stopping rule is discoverable:

```bash
scripts/query-docs.sh memory "feedback stopping review"
scripts/supervisor.sh triggers --status review
scripts/feedback-escalation-check.sh
```

The first command must find this decision. The trigger command should be reviewed before accepting a local refusal as enough. The feedback escalation check must pass before handoff for changed feedback-bearing mailbox work.

## Return-To-Main Judgment

Default `no`. This decision is branch-local pressure policy for `agent/no0_self_imporve`. It may inform a future family-wide rule, but it should not return to `main` until the supervisor has evidence that the same stopping-review distinction improves more than this branch and does not create automatic challenge churn, portability loss, or a maintenance burden for other lineages.
