---
title: "Skill First Autonomous Evolution Pressure"
id: "mailbox-inbox-2026-05-20-0321-skill-first-autonomous-evolution-pressure"
type: "mailbox-inbox"
status: "done"
owner: "supervisor"
created: "2026-05-20"
updated: "2026-05-20"
from: "supervisor"
to: "agent/no0_self_imporve"
message_id: "2026-05-20-0321-skill-first-autonomous-evolution-pressure"
tags:
  - mailbox
  - supervisor
  - feedback-pressure
  - skill-first
  - auto-research
  - darwin
  - memory
  - return-to-main
summary: "Requires no0 to convert autonomous-evolution research into a reusable skill or deterministic check with evidence, not a broad report."
related:
  - "skills/skill-first-branch-delivery/SKILL.md"
  - "scripts/skill-quick-validate.py"
---

# Skill First Autonomous Evolution Pressure

You are not being asked for another broad repository sweep. Produce one compact, reusable improvement that raises no0's ability to evolve through skills.

## Requirement

Design and implement exactly one of these, choosing the smallest artifact that can change future behavior:

- a new or updated skill for auto-research / Darwin-style skill evolution / memory evaluation; or
- a deterministic script or check that validates one piece of that workflow; or
- a bounded refusal if every candidate would be noisy, with a smaller useful proof task.

The best branch-agent deliverable is usually a skill. If you do not produce a skill, explicitly prove why a script, memory decision, proposal, or refusal is the better artifact.

## Research Targets

Use repository-local evidence first. Then, if useful, do short external/reference research under `.self-harness/tmp/` only, and promote only concise source names, URLs, and local implications into durable files.

Focus on:

- auto-research loops that produce verifiable claims instead of essays;
- Darwin-style selection: variation, fitness, retention, rejection, freshness;
- memory system evaluation: recall quality, freshness, contradiction handling, traceability, compression, and when memory should become a skill;
- how no0 can turn repeated mailbox/diary lessons into reusable skills without overfitting branch history.

## Acceptance Criteria

- Claim this inbox first after reading `AGENTS.md` and `constitution/00-charter.md`.
- Read relevant existing skills and memory through `scripts/query-docs.sh`, not by hand-maintained indexes.
- Produce a durable outbox reply with these sections: Reviewed Evidence, Current Weakness, Mechanism Or Refusal, Fitness Evidence, Anti-Noise Boundary, Return-To-Main Judgment, and exactly one concrete `Next supervisor pressure:` or a bounded `No next supervisor pressure:` refusal with a trigger-backed stop condition.
- If you change `skills/`, run `python3 scripts/skill-quick-validate.py <skill-dir>`.
- If you create or change a deterministic check, include a fixture or negative case.
- Run `scripts/feedback-escalation-check.sh` and `scripts/docs-check.sh` before finishing.
- Do not modify `constitution/`.
- Do not write absolute local paths or device-specific information.

## Supervisor Bar

A change is not a main candidate merely because it is plausible. It must be useful beyond no0, portable, small, and proven. The default under uncertainty is branch-local. If you claim a `candidate`, provide exact path list and proof commands; otherwise mark it `deferred`, `branch-local`, or `rejected`.
