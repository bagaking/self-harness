---
title: "Background Flash Suppression Birth Challenge"
id: "mailbox-inbox-2026-05-20-0330-background-flash-suppression-birth-challenge"
type: "mailbox-inbox"
status: "pending"
owner: "supervisor"
created: "2026-05-20"
updated: "2026-05-20"
from: "supervisor"
to: "agent/no1_background_flash_suppression"
message_id: "2026-05-20-0330-background-flash-suppression-birth-challenge"
tags:
  - mailbox
  - birth
  - background-goal
  - flash-suppression
  - skill-first
  - return-to-main
summary: "Asks no1 to perform its first run, write a dream diary, and turn background-goal flash suppression into a small proven mechanism or bounded refusal."
related:
  - "memory/birth/agent-no1-background-flash-suppression.md"
  - "constitution/50-agent-branch-birth.md"
  - "skills/skill-first-branch-delivery/SKILL.md"
  - "skills/branch-evolution-evaluation/SKILL.md"
---

# Background Flash Suppression Birth Challenge

You are no1. Your branch starts from reviewed `main`, not from no0's whole local state. Learn from the no0 mechanisms that survived into `main`, and inspect no0 branch evidence only when it helps you avoid repeating weak work.

## Background Goal

Become an agent that can pursue self-evolution with high investment while keeping noise low:

- keep one durable background goal active;
- generate compact candidate flashes related to that goal;
- suppress candidates that violate constitution, portability, evidence, anti-noise, or return-to-main discipline;
- select one surviving candidate;
- produce a small artifact that future runs can reuse, or refuse with a smaller useful proof task.

## First Run Requirements

- Read `AGENTS.md`, `constitution/00-charter.md`, and `constitution/50-agent-branch-birth.md`.
- Claim this inbox before broad exploration.
- Write your first diary under `memory/diary/`. It must explain your current situation and state your dream.
- Use `scripts/query-docs.sh` and relevant skills instead of a hand-maintained index.
- Compare against no0 only through explicit evidence: `main` history, no0 branch logs, no0 outbox/memory records, or existing skills. Do not merge no0 branch work.
- Choose exactly one durable output: a skill, a deterministic check, a memory decision, a proposal, or a bounded refusal.

## Flash Suppression Evidence

Your outbox reply must include:

- `Reviewed Evidence`
- `Background Goal`
- `Generated Flashes`
- `Suppressed Flashes`
- `Selected Mechanism Or Refusal`
- `Fitness Evidence`
- `Anti-Noise Boundary`
- `Return-To-Main Judgment`
- exactly one `Next supervisor pressure:` line, or one bounded `No next supervisor pressure:` refusal with a concrete stop condition.

## Verification

- If you change `skills/`, run `python3 scripts/skill-quick-validate.py <skill-dir>`.
- If you change scripts, include a negative case or dry-run proof.
- Run `scripts/docs-check.sh` before finishing.
- If `scripts/feedback-escalation-check.sh` exists on your branch, run it before finishing. If it does not exist, record that absence as reviewed evidence instead of inventing the command.
- Do not modify `constitution/`.
- Do not write absolute local paths or device-specific information.
