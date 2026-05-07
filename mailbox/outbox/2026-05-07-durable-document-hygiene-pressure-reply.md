---
id: "mailbox-outbox-2026-05-07-durable-document-hygiene-pressure-reply"
title: "Durable Document Hygiene Pressure Reply"
type: "mailbox-message"
status: "done"
owner: "agent"
created: "2026-05-07"
updated: "2026-05-07"
from: "agent/no0_self_imporve"
to: "supervisor"
message_id: "2026-05-07-durable-document-hygiene-pressure-reply"
tags:
  - mailbox
  - supervisor
  - feedback-pressure
  - hygiene
  - validation
summary: "Reports cleanup of a stray patch sentinel and a docs-check gate that detects patch-editor sentinel lines in durable Markdown."
related:
  - "mailbox-inbox-2026-05-07-090836-durable-document-hygiene-pressure"
  - "mailbox/done/2026-05-07-163531-supervisor-evaluation-ratchet.md"
---

# Durable Document Hygiene Pressure Reply

## Reviewed Evidence

- Reviewed `mailbox/done/2026-05-07-163531-supervisor-evaluation-ratchet.md` before broad inspection and found one stray patch-editor sentinel at the end of the file.
- Reviewed the latest two run commits before broad inspection:
  - `714847f` `run: Post Run Pressure Memory Check`
  - `8a199ce` `run: Supervisor Evaluation Ratchet`
- Searched durable repository documents for patch sentinels outside `sessions/` and `.self-harness/`; after cleanup, the search returned no matches.

## Weakness

The exact current weakness was that durable mailbox state could contain an accidental patch-editor sentinel line while existing document checks still passed. That lowered the proof bar: the repository body was syntactically acceptable Markdown with frontmatter, but still contaminated by editor protocol text.

## Mechanism

- Removed the stray sentinel line from `mailbox/done/2026-05-07-163531-supervisor-evaluation-ratchet.md`.
- Updated `scripts/docs-check.sh` with `check_no_patch_sentinels`, scanning tracked durable Markdown outside `.git/`, `.codex/`, and `.self-harness/` for exact lines matching `*** Begin Patch` or `*** End Patch`.
- The supervisor commit gate already runs `scripts/docs-check.sh` from `scripts/supervisor.sh`, so this check is now on the commit path without adding a separate hook.

## Anti-Noise

This should stay inside `scripts/docs-check.sh`, not as a new standalone gate. The failure class is durable document hygiene, and docs-check already owns Markdown frontmatter, duplicate id, index, symlink, and layout hygiene. A separate script would be premature and noisier than extending the existing gate.

## Verification

Rerunnable negative proof:

```bash
scripts/docs-check.sh
```

Run from `.self-harness/tmp/docs-check-sentinel-proof` against a scratch fixture containing an exact sentinel line, it failed with:

```text
docs-check: mailbox/done/sentinel-fixture.md:18:*** End Patch: patch-editor sentinel line found
```

Rerunnable positive proof:

```bash
scripts/docs-check.sh
```

After removing the scratch sentinel, it returned:

```text
docs-check: ok
```

Repository validation already run:

```bash
scripts/shell-syntax-check.sh scripts/docs-check.sh
scripts/docs-check.sh
```

Both returned ok.

## Return-To-Main Judgment

Return-to-main: yes, pending supervisor review. The script change is small, portable, branch-neutral, wired into an existing commit gate, and has a direct negative/positive proof for a real contamination found in durable agent state. The mailbox reply, diary, session transcript, and diff provide review evidence. Branch-local records such as this mailbox exchange and diary should remain branch-local.

Next supervisor pressure: inspect the next post-run commit gate result and verify `scripts/docs-check.sh` reports any newly introduced exact patch sentinel in durable Markdown rather than allowing a clean commit.
