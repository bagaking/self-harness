---
title: "Knowledge System"
id: "constitution-20-knowledge-system"
type: "constitution"
status: "active"
owner: "human"
protected: true
authority: "constitutional"
mutable_by: "human-only"
created: "2026-05-05"
updated: "2026-05-05"
tags:
  - knowledge
  - frontmatter
  - memory
  - search
summary: "Defines script-based document discovery, YAML frontmatter requirements, and the boundaries between constitution, memory, skills, and mailbox."
---

# Knowledge System

## No Manual Index

The repository must not depend on a manually maintained canonical index. Manual indexes become stale and create false confidence.

Discovery should be done by scripts. The baseline query interface is `scripts/query-docs.sh`, which searches Markdown documents and displays YAML frontmatter when present.

Agents should query first, then read the relevant full documents.

## Frontmatter Requirement

Repository Markdown documents created or materially edited by agents should include YAML frontmatter unless they are raw transcripts, generated logs, temporary files, or external content that should remain unmodified.

Recommended fields:

```yaml
---
id: "stable-unique-id"
title: "Short Human Name"
type: "constitution | memory | skill-note | mailbox-message | diary | proposal | incident"
status: "draft | active | superseded | archived"
owner: "human | agent | shared"
created: "YYYY-MM-DD"
updated: "YYYY-MM-DD"
tags:
  - example
summary: "One sentence summary for query output."
related: []
supersedes: []
---
```

Constitution documents must also include:

```yaml
protected: true
authority: "constitutional"
mutable_by: "human-only"
```

Agents should keep frontmatter factual and compact. The body remains the source of detail.

Memory documents should also include source and confidence when practical:

```yaml
source: "session | user | repo-review | experiment"
confidence: "low | medium | high"
```

## Directory Semantics

`constitution/` is human-owned, read-only, and authoritative.

`memory/` is agent-owned. It may contain diaries, lessons, decisions, proposals, incidents, and working notes. Memory is not automatically authoritative. Agents should treat old memory as evidence, not law.

`skills/` is agent-improvable procedural knowledge. A repeated method, checklist, API workflow, or operating trick belongs in a skill when it is reusable.

`mailbox/` is communication state and is part of the agent's own repository-visible body. It should be tracked when messages are durable and complete. Durable lessons learned from mailbox work should still be copied or summarized into `memory/` or `skills/`.

`sessions/` is transcript state and is part of the agent's own repository-visible body. It should be tracked so the self-harness can preserve and review its own conversation history. Agents may read it for context, but should not hand-edit session records.

`.self-harness/` is the only default ignored workspace for local private state, runtime locks, scratch files, temporary downloads, and work that is explicitly not meant to become part of the agent's recorded history. If a file matters to future agents, it belongs outside `.self-harness/` with frontmatter or an appropriate durable format.

Agents may use `.self-harness/tmp/` as an experiment yard. Suitable uses include cloning reference repositories, creating temporary projects, trying a proposed skill in isolation, or giving a subagent a disposable working directory for an experiment. Results from that area are not memory until they are deliberately summarized or promoted into a tracked path.

Repository documents should stay portable. Durable Markdown, scripts, and metadata should refer to project files with relative paths from the repository root. Do not record local hostnames, usernames, home directories, or machine-specific absolute paths in committed content.

## Query Contract

`scripts/query-docs.sh` should be treated as the default discovery tool. It should support searching at least these scopes:

- `constitution`
- `memory`
- `skills`
- `mailbox`
- `scripts`
- `all`

For each matching Markdown file, the script should print the relative path and any YAML frontmatter. If a query string is supplied, it should also print matching lines.

Agents should prefer:

```bash
scripts/query-docs.sh constitution supervisor
scripts/query-docs.sh memory mailbox
scripts/query-docs.sh all frontmatter
```

over browsing guessed paths or relying on a stale index.

The companion check interface is `scripts/docs-check.sh`. It should validate required frontmatter fields, detect malformed frontmatter, reject duplicate document ids, and fail when forbidden index files are introduced.
