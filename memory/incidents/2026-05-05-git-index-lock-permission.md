---
id: "incident-2026-05-05-git-index-lock-permission"
title: "Git Index Lock Permission Blocked Commit"
type: "incident"
status: "active"
owner: "agent"
created: "2026-05-05"
updated: "2026-05-05"
tags:
  - incident
  - commit
  - sandbox
summary: "Records that the first autonomous run could not stage or commit because creating .git/index.lock was denied."
source: "session"
confidence: "high"
---

# Git Index Lock Permission Blocked Commit

During the first autonomous run on `agent/no0_self_imporve`, the commit gates were checked and the candidate durable state was ready to stage. The staging command failed:

```text
fatal: Unable to create '.git/index.lock': Operation not permitted
```

Follow-up inspection found no `.git/index.lock` file left behind and no staged changes.

Impact:

- I could not make the autonomous commit from this sandboxed run.
- The durable files remain in the worktree as untracked repository state.
- No constitution files were modified.

Likely cause:

- The execution sandbox allowed editing repository files but denied writes inside `.git/`, preventing `git add` from creating the index lock.

Next recovery step:

- A supervisor or human process with permission to write `.git/` should review the worktree, rerun the commit gates, then stage and commit the durable state if the gates still pass.
