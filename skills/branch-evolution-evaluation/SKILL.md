---
name: branch-evolution-evaluation
description: Use when evaluating a self-harness agent branch after mailbox work, memory or skill changes, self-improvement experiments, or before proposing branch changes for supervisor return-to-main review. Applies to branch-agent evolution evidence, memory quality, skill usefulness, mailbox lifecycle, validation checks, and return-to-main readiness.
---

# Branch Evolution Evaluation

Use this skill to turn branch-local evolution into reviewable evidence. It is a repository-specific protocol, not a replacement for `constitution/`.

## Workflow

1. Establish scope.
   - Read `AGENTS.md`, `constitution/00-charter.md`, and `constitution/50-agent-branch-birth.md`.
   - Identify the baseline with `git log --oneline --decorate --graph --max-count=16`.
   - Compare both the relevant task baseline and `origin/main` when useful:

```bash
git diff --name-status <baseline>..HEAD
git diff --stat <baseline>..HEAD
git diff --name-status origin/main..HEAD
```

2. Retrieve repository evidence.
   - Use `scripts/query-docs.sh memory <topic>`, `scripts/query-docs.sh mailbox <topic>`, and `scripts/query-docs.sh skills <topic>`.
   - Read only the full files needed to evaluate the change.
   - Treat `constitution/` as human-owned authority, memory as evidence, mailbox as communication state, skills as reusable procedure, and sessions as transcript state that should not be hand-edited.

3. Apply the feedback-pressure ratchet when the task includes supervisor feedback, low-value loop feedback, or a request to raise the bar.
   - Review at least the latest three branch outbox reports and latest three run commits before choosing the response.
   - Identify where the loop still stops too early, lowers the proof bar, or treats a completed mailbox item as the end of pressure.
   - Convert the feedback into one sharper future requirement: a deterministic gate, a skill step, a memory decision with a rerunnable query and trigger, a focused experiment, or a justified refusal with a smaller alternative.
   - State the worked signal a future supervisor can inspect, such as a matching query result, validation command, mailbox acceptance criterion, or next-run behavior.
   - In the supervisor-facing outbox, include exactly one feedback-continuity path: either one concrete `Next supervisor pressure:` line, or one `No next supervisor pressure:` refusal that says why further escalation would be noisy and includes exactly one concrete `Supervisor evaluation trigger:` plus a `Smaller useful task:` or `Stop condition:`.
   - For feedback-bearing mailbox work, expect `scripts/feedback-escalation-check.sh` to pass before handoff. If escalation would add noise, write the refusal and smaller alternative in the outbox instead of adding a generic challenge.
   - Default return-to-main judgment to `no` for branch-local pressure mechanisms unless evidence shows broad value and no plausible family-wide downside.

4. Classify changes.
   - Candidate for return-to-main: useful beyond one branch or one session, portable, traceable, validated, and not dependent on private scratch state.
   - Branch-local: identity, diary, mailbox-only conversation state, raw sessions, or intentionally local lineage context.
   - Deferred: plausible but missing evidence, too broad, script-worthy but not stable, or risky without human decision.
   - Reject: noisy, non-portable, duplicate, constitution-modifying by agent, or unsupported by validation.

5. Score criteria as `pass`, `warn`, `fail`, or `not applicable`.
   - Recall: likely query terms find the relevant memory or skill.
   - Precision: discovery returns a small set a future agent can read.
   - Freshness: relationships, supersession, or scope make newer evidence visible.
   - Conflict handling: uncertainty and contradictions are preserved instead of overwritten.
   - Actionability: the change alters a future checklist, command, decision, or review gate.
   - Portability: durable content uses repository-relative paths and avoids local machine details.
   - Traceability: claims point to mailbox messages, memory notes, commands, commits, experiments, or cited sources.
   - Compression: durable notes summarize decision-critical facts without copying long transcripts.
   - Skill usefulness: a skill captures a repeated procedure, stays concise, and avoids restating broad model knowledge.
   - Mailbox lifecycle: input is claimed through `mailbox/processing/`, replied to under `mailbox/outbox/`, and moved to `mailbox/done/` or `mailbox/failed/`.
   - Return-to-main readiness: the result is useful beyond this branch, passes checks, and leaves evidence for supervisor review.
   - Feedback pressure: supervisor feedback is converted into a sharper future requirement with a worked signal.

6. Validate.

```bash
find mailbox/processing -maxdepth 1 -type f ! -name .gitkeep -print
find .self-harness/tmp -maxdepth 1 -type f \( -name 'outbox-*' -o -name '*.tmp' \) -print
git diff --quiet -- constitution/
git diff --cached --quiet -- constitution/
test -z "$(git ls-files --others --exclude-standard -- constitution/)"
scripts/proof-pressure-check.sh
scripts/feedback-escalation-check.sh
scripts/shell-syntax-check.sh
scripts/docs-check.sh
```

For changed shell scripts, run `scripts/shell-syntax-check.sh` so each shell file is parsed through a separate `bash -n "$script"` invocation. Use `scripts/shell-syntax-check.sh <script>...` for a focused subset. Do not cite `bash -n a.sh b.sh` as multi-file evidence, because Bash only parses the first script and treats the rest as positional parameters. For changed skills, run the local skill validator if dependencies are available; otherwise state that validation was manual and name the blocker.

7. Write durable evidence.
   - Put completed evaluations in `memory/lessons/` when they teach a reusable lesson.
   - Put accepted operating choices in `memory/decisions/`.
   - Put unapproved design changes in `memory/proposals/`.
   - Put reusable evaluation procedure changes in `skills/`.
   - Put mailbox replies and supervisor-facing reports in `mailbox/outbox/`.
   - Keep raw research logs, scratch prompts, and experiments under `.self-harness/tmp/`.

## Research Grounding

Use external research only to shape concrete repository checks. Prefer mechanisms that map to local evidence:

- Memory benchmarks suggest testing retrieval, update over time, long-range use, and forgetting or conflict behavior.
- Agent skill work suggests evaluating whether skills are repeatedly selected, executable, and improve future task performance.
- Software-agent benchmarks suggest grounding claims in task artifacts, diffs, tests, and issue-style acceptance evidence.
- Self-improvement work suggests requiring before-and-after evidence and keeping failed or deferred ideas visible.

Do not cite broad research as proof that a branch change works. Proof in this repository comes from local commands, mailbox outcomes, memory or skill probes, and reviewable diffs.
