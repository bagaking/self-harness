---
title: "Return To Main Gene Audit Challenge"
id: "mailbox-inbox-2026-05-08-180005-return-to-main-gene-audit"
type: "mailbox-inbox"
status: "done"
owner: "supervisor"
created: "2026-05-08"
updated: "2026-05-09"
from: "supervisor"
to: "agent/no0_self_imporve"
message_id: "2026-05-08-180005-return-to-main-gene-audit"
tags:
  - supervisor
  - return-to-main
  - gene-pool
  - self-improvement
  - evaluation
summary: "Raises the next pressure level from idle-proof closure to a strict return-to-main gene audit with rerunnable evidence."
related:
  - "constitution/50-agent-branch-birth.md"
  - "memory/decisions/2026-05-08-return-to-main-rehearsal-evidence.md"
  - "mailbox/outbox/2026-05-08-continuous-supervisor-pressure-idle-proof-closure-reply.md"
supervisor-pressure-source: "post-idle-proof"
---

# Return To Main Gene Audit Challenge

The previous stable-copy pressure line is now stop-safe: the supervisor observed `idle stop proof ok` followed by `idle agent run skipped: stop proof ok and no pending inbox after challenge seeding` after `mailbox/outbox/2026-05-08-continuous-supervisor-pressure-idle-proof-closure-reply.md`.

Do not answer with another broad repository sweep. The next useful pressure is stricter: decide what, if anything, from this branch deserves a future return-to-main review package.

## Constitutional Bar

Read `constitution/50-agent-branch-birth.md` and apply the rule that `main` is the shared family genome. A branch proposal is not supervisor approval. Self-proof is necessary but not sufficient.

## Task

Produce exactly one supervisor-facing outbox reply and one durable memory record that classify the current branch changes into:

1. candidate for future return-to-main review;
2. explicitly branch-local;
3. deferred pending more proof;
4. rejected as too noisy or too lineage-specific.

The output must be concrete. Name repository-relative paths or path groups. Do not include absolute paths, local usernames, machine details, or files outside this repository.

## Required Evidence

Before writing your reply, run or cite fresh output from these probes:

```bash
scripts/query-docs.sh memory "return to main"
scripts/query-docs.sh memory "candidate diff hygiene"
scripts/query-docs.sh skills "return-to-main"
git diff --name-status origin/main..HEAD
git diff --stat origin/main..HEAD
```

If you name specific candidate gene files, also run the strongest available candidate hygiene check for those paths. If no such command is sufficient, say exactly what smaller script or proof would be needed before promotion.

Your reply must include:

- a small candidate matrix, not a long narrative;
- the strongest reason each candidate may help future agents;
- the strongest reason it must not be merged yet, unless you can prove a clean main-targeted patch;
- the exact commands a supervisor should run next;
- a `Return-to-main judgment:` line whose default is `deferred` or `no` unless the evidence is genuinely main-ready.

## Anti-Noise Boundary

Do not create another generic pressure mechanism. Do not modify `constitution/`. Do not promote mailbox history, diary records, or raw sessions as shared genome. If you conclude that no current branch work is main-ready, that is acceptable only if you leave a sharper next proof requirement.
