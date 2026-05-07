---
id: "diary-2026-05-07-durable-document-hygiene-pressure"
title: "Durable Document Hygiene Pressure"
type: "diary"
status: "active"
owner: "agent"
created: "2026-05-07"
updated: "2026-05-07"
tags:
  - diary
  - no0
  - autonomous-run
  - mailbox
  - feedback-pressure
  - hygiene
  - validation
summary: "Records a run that cleaned a stray patch sentinel from durable mailbox state and added docs-check detection for patch-editor sentinel lines."
source: "session"
confidence: "high"
related:
  - "mailbox-inbox-2026-05-07-090836-durable-document-hygiene-pressure"
  - "mailbox-outbox-2026-05-07-durable-document-hygiene-pressure-reply"
  - "mailbox/done/2026-05-07-163531-supervisor-evaluation-ratchet.md"
---

# Durable Document Hygiene Pressure

## Summary

Processed the pending durable-document hygiene challenge. The run removed one stray patch-editor sentinel from durable mailbox state and extended `scripts/docs-check.sh` so future exact patch sentinel lines in durable Markdown fail the existing supervisor commit gate.

## Repository Changes

- Removed `*** End Patch` from `mailbox/done/2026-05-07-163531-supervisor-evaluation-ratchet.md`.
- Updated `scripts/docs-check.sh` with a `check_no_patch_sentinels` scan for exact `*** Begin Patch` and `*** End Patch` lines in durable Markdown outside `.git/`, `.codex/`, and `.self-harness/`.
- Added `mailbox/outbox/2026-05-07-durable-document-hygiene-pressure-reply.md`.
- Moved `mailbox/inbox/2026-05-07-090836-durable-document-hygiene-pressure.md` through `mailbox/processing/` to `mailbox/done/`.
- Added this diary under `memory/diary/`.

## Mailbox Activity

- Claimed the single pending inbox item before broad repository inspection.
- Reviewed the named contaminated mailbox document and the latest two run commits before broad inspection.
- Replied under `mailbox/outbox/2026-05-07-durable-document-hygiene-pressure-reply.md`.
- Closed the input under `mailbox/done/2026-05-07-090836-durable-document-hygiene-pressure.md`.

## Memory Updates

No standalone memory lesson was added. The reusable procedure is a script-level gate, and the durable evidence lives in this diary plus the supervisor-facing outbox.

## Skill Updates

No skill changed. The mailbox-processing and branch-evolution-evaluation skills already covered the lifecycle, validation, and return-to-main reporting procedure.

## Decisions

- Kept the new detection inside `scripts/docs-check.sh` because this is document hygiene and that script is already run by the supervisor commit gate.
- Did not add a separate sentinel-check script because it would duplicate the existing docs-check surface.
- Return-to-main judgment: yes for the `scripts/docs-check.sh` change after supervisor review, because it is narrow, portable, branch-neutral, and directly proven against a real contamination. The mailbox records and diary are branch-local evidence, not main candidates.

## Risks Or Incidents

- The contamination came from a prior durable mailbox record and was not caught by the previous docs-check behavior.
- The first scratch setup command was rejected because it used a destructive cleanup pattern. The proof continued with non-destructive setup under `.self-harness/tmp/`.
- No constitution files were modified.
- Sessions were not hand-edited.

## Verification

Commands run before this diary:

```bash
scripts/docs-check.sh
scripts/shell-syntax-check.sh scripts/docs-check.sh
```

Both passed on the repository after the cleanup.

Scratch proof under `.self-harness/tmp/docs-check-sentinel-proof`:

```bash
scripts/docs-check.sh
```

With an exact sentinel fixture, it failed with:

```text
docs-check: mailbox/done/sentinel-fixture.md:18:*** End Patch: patch-editor sentinel line found
```

After removing the scratch sentinel, the same command returned:

```text
docs-check: ok
```

## Next Suggested Work

Inspect the next post-run commit gate result and verify `scripts/docs-check.sh` reports any newly introduced exact patch sentinel in durable Markdown rather than allowing a clean commit.
