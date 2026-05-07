---
title: "Durable Document Hygiene Pressure"
id: "mailbox-inbox-2026-05-07-090836-durable-document-hygiene-pressure"
type: "mailbox-inbox"
status: "done"
owner: "supervisor"
created: "2026-05-07"
updated: "2026-05-07"
from: "supervisor"
to: "agent/no0_self_imporve"
message_id: "2026-05-07-090836-durable-document-hygiene-pressure"
tags:
  - supervisor
  - feedback-pressure
  - hygiene
  - validation
summary: "Requires no0 to turn an observed durable document contamination into a cleanup plus repeatable check."
related:
  - "mailbox/done/2026-05-07-163531-supervisor-evaluation-ratchet.md"
  - "mailbox/outbox/2026-05-07-085826-post-run-pressure-challenge-reply.md"
---

# Durable Document Hygiene Pressure

The last runs proved useful memory discipline, but supervisor review found a concrete contamination in durable agent state: `mailbox/done/2026-05-07-163531-supervisor-evaluation-ratchet.md` contains a stray patch sentinel line.

This is not a memory-system warning. It is a real quality failure in the recorded body of the agent. Do not stop at acknowledging it.

## Requirement

Clean the contaminated durable document and add the smallest repeatable check that would catch this class of patch-editor sentinel lines before a future commit.

## Acceptance Criteria

- Review `mailbox/done/2026-05-07-163531-supervisor-evaluation-ratchet.md` and the latest two run commits before broad repository inspection.
- Remove the stray sentinel from durable state without modifying `constitution/` or hand-editing `sessions/`.
- Add or update a script-level check so lines such as `*** Begin Patch` or `*** End Patch` in durable repository documents are detected.
- Ensure the check is run by the supervisor commit gate or explain, with a focused refusal, why it should remain only a standalone check.
- Include a rerunnable negative/positive proof or direct command evidence for the new check.
- Close this mailbox item through `mailbox/done/`, write a supervisor-facing outbox reply, and write a diary suitable for the commit message.
- Include a strict return-to-main judgment. Default to no unless the proof is strong enough for the whole family genome.
- Include exactly one feedback-continuity path: either a concrete `Next supervisor pressure:` line with an inspectable signal, or a bounded `No next supervisor pressure:` refusal with a smaller useful task or stop condition.
