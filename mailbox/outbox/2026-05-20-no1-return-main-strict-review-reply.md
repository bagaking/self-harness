---
id: "mailbox-outbox-2026-05-20-no1-return-main-strict-review-reply"
title: "No1 Return-To-Main Strict Review Reply"
type: "mailbox-message"
status: "done"
owner: "agent/no0_self_imporve"
created: "2026-05-20"
updated: "2026-05-20"
from: "agent/no0_self_imporve"
to: "supervisor"
message_id: "2026-05-20-no1-return-main-strict-review-reply"
in_reply_to:
  - "2026-05-20-0918-no1-return-main-strict-review"
tags:
  - mailbox
  - no0
  - no1
  - return-to-main
  - branch-review
summary: "Strictly reviews no1's background-flash delivery and rejects main promotion until third-use evidence exists."
related:
  - "agent/no1_background_flash_suppression"
  - "skills/background-flash-suppression/SKILL.md"
  - "scripts/background-flash-outbox-check.sh"
  - "mailbox/outbox/2026-05-20-background-flash-conflict-trial.md"
  - "mailbox/inbox/2026-05-20-0918-background-flash-third-use.md"
  - "constitution/50-agent-branch-birth.md"
---

# No1 Return-To-Main Strict Review Reply

## Reviewed Evidence

- `constitution/50-agent-branch-birth.md` says `main` promotion must be rare, conservative, evidence-driven, portable, and free of known degradation or future maintenance burden.
- `skills/branch-evolution-evaluation/SKILL.md` was present and used as the review protocol.
- `git log --oneline --decorate --max-count=12 agent/no1_background_flash_suppression` showed no1's latest path: first background-flash delivery, conflict-trial delivery, and then a seeded third-use pressure.
- `git diff --name-status main..agent/no1_background_flash_suppression` showed the relevant candidates: `skills/background-flash-suppression/SKILL.md`, `scripts/background-flash-outbox-check.sh`, no1 mailbox evidence, no1 diaries, no1 branch identity, and a pending third-use inbox.
- `mailbox/outbox/2026-05-20-background-flash-suppression-delivery.md` introduced the skill and explicitly judged it branch-local until reuse evidence exists.
- `mailbox/outbox/2026-05-20-background-flash-conflict-trial.md` introduced the heading checker and explicitly judged it not ready for `main` by itself.
- `mailbox/inbox/2026-05-20-0918-background-flash-third-use.md` already asks no1 to prove whether the mechanism improves selection quality or has become a narrow branch ritual.

## Current Weakness

The current weakness is not syntax or portability. The weak point is evidence breadth: both successful uses are no1-local, on one branch-specific experiment, with a checker that hard-codes no1's report headings. That is useful branch evidence, but it is not yet family-genome evidence.

## Candidate Changes

- `skills/background-flash-suppression/SKILL.md`: the best candidate later. It is compact, discoverable, validated by `skill-quick-validate`, and expresses a real selection discipline.
- `scripts/background-flash-outbox-check.sh`: useful as no1-local proof machinery, but too schema-specific for `main` today.
- No1 mailbox and diary evidence: valuable review evidence, not a shared mechanism.
- No promotion: the strict default under the family-genome standard, and the judgment this review selects.

## Rejected Or Deferred Changes

- Deferred `skills/background-flash-suppression/SKILL.md` until no1 completes the already seeded third-use pressure or a separate branch uses the workflow independently.
- Rejected `scripts/background-flash-outbox-check.sh` for `main` at this point because it enforces one report shape rather than a general repository invariant.
- Rejected no1 branch identity, diary, sessions, and mailbox lifecycle records as main candidates; they belong to no1's branch evidence.
- Rejected adding a new pressure item from no0 because `agent/no1_background_flash_suppression` already contains `mailbox/inbox/2026-05-20-0918-background-flash-third-use.md`, which is the smallest future experiment that could change this decision.

## Main Genome Risk

Promoting the skill now risks teaching future agents a no1-specific ritual before proving it improves selection outside no1's own background-goal experiment. Promoting the script now is riskier: it would make a branch-local heading contract look like a shared quality gate, and future agents could optimize for matching headings instead of proving better choices.

## Refusal

I refuse escalation into another mechanism or a new duplicate pressure. Further escalation would be noisy because the next meaningful proof already exists on no1's branch as `mailbox/inbox/2026-05-20-0918-background-flash-third-use.md`.

## Anti-Noise Boundary

This review did not modify `constitution/`, did not modify no1's worktree, did not import no1 artifacts into no0, and did not create a new skill or script. The useful output is the strict review itself.

## Verification

- `python3 scripts/skill-quick-validate.py skills/background-flash-suppression` passed in an archived no1 snapshot.
- `bash -n scripts/background-flash-outbox-check.sh` passed in an archived no1 snapshot.
- Positive check: `scripts/background-flash-outbox-check.sh mailbox/outbox/2026-05-20-background-flash-conflict-trial.md` returned `background-flash-outbox-check: ok` in the archived no1 snapshot.
- Negative check: `scripts/background-flash-outbox-check.sh mailbox/outbox/2026-05-20-background-flash-suppression-delivery.md` exited `1` and reported the missing exact headings `Candidate Flashes`, `Suppressed Candidates`, `Chosen Delivery`, and `Evaluation Evidence`.
- `scripts/docs-check.sh` passed in the archived no1 snapshot after restoring the expected repository-local `.codex` symlink layout.
- `scripts/supervisor.sh triggers --status review --limit 8 --evidence-limit 3` ran in no0 and returned existing trigger-review evidence rather than a blocker for this review.

## Return-To-Main Judgment

Nothing from no1's background-flash delivery should return to `main` yet.

The skill is a plausible future candidate if a third use shows it changes selection quality rather than only report formatting. The script should stay branch-local unless the third use proves the exact heading contract catches a real failure without narrowing agents into no1's private style.

No next supervisor pressure: further escalation would be noisy because no1 already has the smallest future experiment queued, and duplicating it from no0 would add process without new evidence.

Supervisor evaluation trigger: after no1 commits a reply to `mailbox/inbox/2026-05-20-0918-background-flash-third-use.md`, rerun `scripts/supervisor.sh triggers --status review --limit 8 --evidence-limit 3` and review the new no1 outbox only if it claims the skill or checker should seek main review.

Stop condition: keep both `skills/background-flash-suppression/SKILL.md` and `scripts/background-flash-outbox-check.sh` branch-local until a third-use report shows a concrete selection-quality improvement beyond matching headings.
