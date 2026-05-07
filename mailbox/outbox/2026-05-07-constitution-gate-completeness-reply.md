---
id: "mailbox-outbox-2026-05-07-constitution-gate-completeness-reply"
title: "Constitution Gate Completeness Reply"
type: "mailbox-message"
status: "done"
owner: "agent"
created: "2026-05-07"
updated: "2026-05-07"
from: "agent/no0_self_imporve"
to: "supervisor"
message_id: "2026-05-07-constitution-gate-completeness-reply"
tags:
  - mailbox
  - progressive-challenge
  - commit-gate
  - constitution
  - evaluation
summary: "Reports a narrow commit-gate fix that detects staged and untracked constitution changes, not only unstaged diffs."
related:
  - "mailbox-inbox-2026-05-07-030100-progressive-supervisor-challenge"
  - "lesson-2026-05-07-commit-gate-constitution-completeness"
  - "skill-branch-evolution-evaluation"
---

# Constitution Gate Completeness Reply

I handled the progressive supervisor challenge with a deterministic gate improvement, not another no-pending or repository-state report.

## Reviewed Evidence

Last five branch commits reviewed:

- `0519751` `run: Progressive Challenge Feedback Gate`
- `71c2cfe` `run: Proof Pressure Executable Gate`
- `ac98a17` `mailbox: demand executable proof-pressure gate`
- `e121d77` `run: Progressive Supervisor Challenge`
- `5039401` `Merge branch 'main' into agent/no0_self_imporve`

Last two mailbox outbox reports reviewed:

- `mailbox/outbox/2026-05-07-progressive-challenge-feedback-gate-reply.md`
- `mailbox/outbox/2026-05-07-proof-pressure-executable-gate-reply.md`

## Weakness Found

The recent work tightened passive-loop proof pressure, but the commit gate still had a narrower constitution check than the constitution requires. `scripts/supervisor.sh` only used `git diff --quiet -- constitution/`, which covers unstaged tracked changes. It did not explicitly cover staged changes or untracked files under `constitution/`.

That is a meaningful proof gap because `constitution/30-mailbox-and-commit.md` says the commit gate should ensure `git diff -- constitution/` is empty and `constitution/40-change-control.md` says supervisor scripts should refuse commits under `constitution/`. A staged constitution edit or a new constitution file could bypass the old unstaged-only check.

## Improvement Made

I updated `scripts/supervisor.sh` with `constitution_changes_present`, which checks:

- unstaged tracked changes with `git diff --quiet -- constitution/`;
- staged changes with `git diff --cached --quiet -- constitution/`;
- untracked files with `git ls-files --others --exclude-standard -- constitution/`.

I also updated `skills/branch-evolution-evaluation/SKILL.md` so future evaluations validate all three constitution-change surfaces instead of only printing an unstaged diff.

## Acceptance Criteria

- `bash -n scripts/supervisor.sh` passes.
- `bash -n scripts/proof-pressure-check.sh` passes.
- `scripts/proof-pressure-check.sh` passes on this worktree.
- A focused helper probe reports clean state as no constitution change and reports unstaged, staged, and untracked constitution scenarios as detected changes.
- `mailbox/processing/` is empty after this message is closed.
- `scripts/docs-check.sh` passes before final handoff.

## Rerunnable Evidence

Syntax and current-worktree checks:

```bash
bash -n scripts/supervisor.sh
bash -n scripts/proof-pressure-check.sh
scripts/proof-pressure-check.sh
```

Focused helper probe used a temporary copy of the script functions under `.self-harness/tmp/` and a shell stub for `git` to avoid touching the real index:

```bash
probe=.self-harness/tmp/supervisor-functions-constitution-gate-$(date +%s).sh
head -n 979 scripts/supervisor.sh > "$probe"
bash -lc '
  source "$1"
  set +e
  run_probe() {
    scenario="$1"
    git() {
      args="$*"
      case "$scenario:$args" in
        unstaged:*" diff --quiet -- constitution/"*) return 1 ;;
        staged:*" diff --cached --quiet -- constitution/"*) return 1 ;;
        staged:*" diff --quiet -- constitution/"*) return 0 ;;
        untracked:*" diff --quiet -- constitution/"*) return 0 ;;
        untracked:*" diff --cached --quiet -- constitution/"*) return 0 ;;
        untracked:*" ls-files --others --exclude-standard -- constitution/"*) printf "%s\n" "constitution/2099-probe.md"; return 0 ;;
        clean:*" diff --quiet -- constitution/"*) return 0 ;;
        clean:*" diff --cached --quiet -- constitution/"*) return 0 ;;
        clean:*" ls-files --others --exclude-standard -- constitution/"*) return 1 ;;
        *) command git "$@" ;;
      esac
    }
    constitution_changes_present
    status=$?
    unset -f git
    printf "%s status=%s\n" "$scenario" "$status"
  }
  run_probe clean
  run_probe unstaged
  run_probe staged
  run_probe untracked
' bash "$probe"
```

Observed output:

```text
clean status=1
unstaged status=0
staged status=0
untracked status=0
```

For this helper, exit status `0` means a constitution change is present and exit status `1` means no constitution change is present.

## Return-To-Main Judgment

This is a return-to-main candidate, but not self-approved. It is small, portable, deterministic, and enforces a human-owned constitutional boundary more completely than the previous gate. The supervisor should still review it strictly because it changes control-plane commit behavior.

The mailbox reply, diary, and branch-local session transcript are not return-to-main candidates.
