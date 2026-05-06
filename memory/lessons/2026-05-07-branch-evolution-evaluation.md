---
id: "lesson-2026-05-07-branch-evolution-evaluation"
title: "Branch Evolution Evaluation"
type: "memory"
status: "active"
owner: "agent"
created: "2026-05-07"
updated: "2026-05-07"
tags:
  - lesson
  - evaluation
  - branch
  - return-to-main
  - self-proof
  - memory
  - skills
summary: "Records a branch-evolution evaluation protocol and its first completed evaluation for supervisor review."
source: "mailbox"
confidence: "high"
related:
  - "mailbox-inbox-2026-05-07-evaluation-mechanism-research"
  - "lesson-2026-05-06-memory-recall-and-skill-audit"
  - "skill-branch-evolution-evaluation"
  - "skill-mailbox-processing"
  - "memory-evaluation"
---

# Branch Evolution Evaluation

## Focused Question

Which no0 branch changes are proven enough for supervisor return-to-main review, and what repeatable evaluation protocol should future branch agents use?

## Research Conclusions

Reviewed sources:

- MemoryAgentBench: https://arxiv.org/abs/2507.05257
- Voyager: https://arxiv.org/abs/2305.16291
- SWE-bench: https://arxiv.org/abs/2310.06770
- Agent-as-a-Judge: https://arxiv.org/abs/2410.10934

Practical conclusions for this repository:

- Memory evaluation should test more than storage. It should cover retrieval, learning from later evidence, long-range use, and outdated or conflicting information.
- Skill evaluation should ask whether the skill captures a repeatable executable procedure, is concise enough to load when needed, and changes future behavior.
- Self-improvement evaluation should use task artifacts, diffs, checks, and mailbox outcomes as evidence. Broad claims that a branch became better are not enough.
- Branch-to-main review should include process evidence, not only final files. Mailbox lifecycle, memory traceability, validation commands, and deferred failures all matter.

These conclusions are now encoded as `skills/branch-evolution-evaluation/`. The protocol belongs in a skill because it is a repeatable procedure for future branch runs. This completed evaluation belongs in `memory/lessons/` because it is evidence from one run and should be treated as a lesson, not as constitutional authority.

## Protocol Used

The first protocol evaluated:

- Recall
- Precision
- Freshness
- Conflict handling
- Actionability
- Portability
- Traceability
- Compression
- Skill usefulness
- Mailbox lifecycle
- Return-to-main readiness

Scores use `pass`, `warn`, `fail`, or `not applicable`.

## Evidence Commands

- `git log --oneline --decorate --graph --max-count=16` showed this branch on `agent/no0_self_imporve`, with `d5ee26b` as the last major accepted self-evolution run, followed by a merge from `main` and the 2026-05-07 evaluation mailbox request.
- `git diff --name-status d5ee26b..HEAD` showed only committed post-acceptance changes: `AGENTS.md`, `constitution/50-agent-branch-birth.md`, and `mailbox/inbox/2026-05-07-evaluation-mechanism-research.md`. The constitution changes came from `main`, not from this agent run, and are excluded from branch return-to-main candidates.
- `git diff --name-status origin/main..HEAD` showed the full no0 branch surface relative to `main`, including mailbox records, memory, sessions, and skills.
- `scripts/query-docs.sh skills branch-evolution` found `skills/branch-evolution-evaluation/SKILL.md`.
- `scripts/query-docs.sh skills return-to-main` found `skills/branch-evolution-evaluation/SKILL.md` with return-to-main criteria.
- `scripts/query-docs.sh memory "memory evaluation"` found the prior diary and lesson that recorded the earlier natural phrase recall weakness.
- `scripts/query-docs.sh memory "memory-evaluation"` found the adoption decision, diaries, lesson, and proposal around `skills/memory-evaluation/`.
- `scripts/query-docs.sh skills mailbox` found both `skills/mailbox-processing/` and the new branch evaluation skill.
- `scripts/query-docs.sh mailbox "evaluation mechanism"` found the claimed processing mailbox message.

Validation evidence:

- `git diff -- constitution/` was empty for this run.
- `find .self-harness/tmp -maxdepth 1 -type f \( -name 'outbox-*' -o -name '*.tmp' \) -print` produced no paths during the in-progress check.
- `python3 skills/.system/skill-creator/scripts/quick_validate.py skills/branch-evolution-evaluation` could not run because the local Python environment lacks the `yaml` module. I manually checked that the new skill has `name` and `description` frontmatter and no placeholder template text remains.
- `scripts/docs-check.sh` must be run after mailbox completion and diary writing; the diary records the final result.

## Criteria Results

- Recall: pass. Queries for `branch-evolution`, `return-to-main`, `mailbox`, `memory evaluation`, and `memory-evaluation` find the relevant skill, memory, or mailbox records.
- Precision: pass. Successful queries returned small result sets or clearly relevant multi-hit sets.
- Freshness: warn. New notes use `related`, but there is still no deterministic supersession or contradiction check.
- Conflict handling: warn. The repository preserves uncertainty in notes, but no actual conflict case was tested in this run.
- Actionability: pass. The run produced `skills/branch-evolution-evaluation/`, which changes future branch review behavior.
- Portability: pass. New durable content uses repository-relative paths and avoids local machine details.
- Traceability: pass. Claims point to mailbox input, skills, memory notes, git diff commands, validation commands, and cited research sources.
- Compression: pass. This note summarizes research and command evidence without copying transcripts or papers.
- Skill usefulness: pass with limited evidence. The new skill codifies the requested evaluation workflow and was used immediately, but it has only one completed run so far.
- Mailbox lifecycle: pass after final mailbox move. The message was claimed into `mailbox/processing/`, answered under `mailbox/outbox/`, and moved to `mailbox/done/`.
- Return-to-main readiness: pass for identified candidates, warn for newly created branch evaluation skill until it receives another use or supervisor accepts first-use evidence.

## Return-To-Main Review Candidates

Strong candidates:

- `skills/memory-evaluation/`: reusable across memory writing and evaluation tasks, used in multiple runs, and backed by `memory/proposals/2026-05-05-memory-evolution-system.md` plus `memory/lessons/2026-05-06-memory-recall-and-skill-audit.md`.
- `skills/mailbox-processing/`: reusable operational procedure for the repository mailbox lifecycle, used by this run and prior mailbox work, with clear validation and hygiene checks.
- `memory/decisions/2026-05-05-skill-and-memory-adoption-criteria.md`: compact operating decision that prevents premature heavy mechanisms and gives future agents a stable adoption gate.
- `memory/lessons/2026-05-06-memory-recall-and-skill-audit.md`: evidence-backed lesson with real query probes and a concrete skill audit.

Candidate with limited evidence:

- `skills/branch-evolution-evaluation/`: directly requested by the supervisor and used in this run. It is likely useful beyond no0, but a second future branch evaluation would strengthen the case before merging it broadly.

Evidence artifacts useful for review:

- `memory/lessons/2026-05-07-branch-evolution-evaluation.md`
- `mailbox/outbox/2026-05-07-evaluation-mechanism-research-reply.md`

## Branch-Local Or Deferred

- `memory/birth/agent-no0-self-imporve.md` and the first-diary dream are branch identity and should remain branch-local unless the supervisor wants examples of branch birth state.
- `memory/diary/*` and `sessions/*` are audit and timeline state. They are commit-worthy on the branch but not general reusable mechanisms.
- Routine no-pending mailbox sweep reports are branch audit state, not main-worthy improvements.
- `memory/incidents/2026-05-06-stale-resume-process.md` is useful evidence for the branch and supervisor history, but should be cherry-picked only if the supervisor wants incident traceability on `main`.
- `memory/proposals/2026-05-05-memory-evolution-system.md` remains a draft proposal. It should not be treated as an accepted mechanism beyond the concrete skill and decision artifacts already created.
- A deterministic evaluation script is deferred. The manual protocol has only one full branch-evaluation run; scripting it now would likely freeze immature semantics.

## Open Questions

- Should `skills/branch-evolution-evaluation/` return to `main` after this first successful use, or after a second independent branch evaluation confirms it generalizes?
- Should future query tooling add token-AND search to reduce natural multi-word recall misses, or should memory authors keep compensating with frontmatter terms and related ids?
- Should the large system skill bundle under `skills/.system/` be treated as branch runtime state or separately reviewed as shared infrastructure?
