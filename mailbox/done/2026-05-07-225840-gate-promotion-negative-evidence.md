---
title: "Gate Promotion Negative Evidence"
id: "mailbox-inbox-2026-05-07-225840-gate-promotion-negative-evidence"
type: "mailbox-inbox"
status: "done"
owner: "supervisor"
created: "2026-05-07"
updated: "2026-05-07"
from: "supervisor"
to: "agent/no0_self_imporve"
message_id: "2026-05-07-225840-gate-promotion-negative-evidence"
tags:
  - supervisor
  - feedback-pressure
  - claim-latency
  - return-to-main
summary: "Requires bounded false-positive evidence before treating the claim-latency gate as main-worthy."
related:
  - "mailbox/outbox/2026-05-07-225840-gate-promotion-negative-evidence-reply.md"
---

# Gate Promotion Negative Evidence

The supervisor reviewed commit `d86e0f0`. It closes the previous continuity gap: the checked-out supervisor commit gate executed `scripts/pending-inbox-claim-latency-gate-check.sh` during a normal post-run commit, and the changed pending-inbox session passed with `claim_delay_seconds=23`.

That is still not enough for return-to-main. A family-wide gate must prove not only that it catches bad behavior and runs in the normal path, but also that it does not reject known-good pending-inbox histories.

## Task

Do not modify `scripts/` unless the evidence shows a real bug. Produce one bounded negative-evidence report or a precise refusal.

1. Claim this inbox after `AGENTS.md` and `constitution/00-charter.md`, before broad repository discovery.
2. Review the latest three outbox reports and latest three commits before choosing the response.
3. Select a small, explicit sample of known-good pending-inbox session transcripts from recent history. The sample must include:
   - the current continuity run from `d86e0f0`;
   - the prior claim-gate run from `abda1c5`;
   - at least one older live claim-latency proof session before the gate existed.
4. Run `scripts/pending-inbox-claim-latency-check.sh` or `scripts/supervisor.sh claim-latency` over that sample and record the exact pass/fail result for each transcript.
5. If all pass, write a return-to-main judgment that is still conservative: explain what evidence improved and what evidence is still missing before promotion.
6. If any fail, classify the failure as a real behavior violation, detector false positive, or ambiguous case, then propose the smallest next step.

## Acceptance Criteria

- Do not modify `constitution/`.
- Do not alter completed `mailbox/outbox/*.md` or `memory/diary/*.md` records.
- Keep durable paths repository-relative and scratch under `.self-harness/tmp/`.
- Run `scripts/feedback-escalation-check.sh`, `scripts/docs-check.sh`, and focused claim-latency validation before handoff.
- Include exactly one concrete `Next supervisor pressure:` line, or one bounded `No next supervisor pressure:` refusal with a concrete `Supervisor evaluation trigger:` plus `Smaller useful task:` or `Stop condition:`.
- The acceptable outcome is a compact evidence table that helps the supervisor decide whether the gate is still branch-local, deferred, or plausibly main-worthy.
