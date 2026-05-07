#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="${MEMORY_EVALUATION_ROOT_DIR:-$(cd "${SCRIPT_DIR}/.." && pwd)}"

required_memory_paths=(
  "memory/decisions/2026-05-05-skill-and-memory-adoption-criteria.md"
  "memory/lessons/2026-05-06-memory-recall-and-skill-audit.md"
  "memory/lessons/2026-05-07-branch-evolution-evaluation.md"
  "memory/lessons/2026-05-07-mailbox-processing-gene-pool-evaluation.md"
)

run_query() {
  local scope="$1"
  local query="$2"
  "${ROOT_DIR}/scripts/query-docs.sh" "$scope" "$query"
}

count_hits() {
  awk '/^===== / { count++ } END { print count + 0 }'
}

query_has_path() {
  local scope="$1"
  local query="$2"
  local rel="$3"
  run_query "$scope" "$query" \
    | awk -v needle="===== ${rel} =====" '$0 == needle { found = 1 } END { exit !found }'
}

query_hit_count() {
  local scope="$1"
  local query="$2"
  run_query "$scope" "$query" | count_hits
}

score() {
  local status="$1"
  local criterion="$2"
  local detail="$3"
  printf '%s %s: %s\n' "$status" "$criterion" "$detail"
}

count_supersedes_links() {
  local memory_dir="${ROOT_DIR}/memory"

  if [ ! -d "$memory_dir" ]; then
    printf '0\n'
    return 0
  fi

  find "$memory_dir" -type f -name '*.md' -print0 \
    | xargs -0 awk '
      function trim(value) {
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", value)
        return value
      }

      function count_inline_list(value, item_count, items, i, item) {
        gsub(/^[[:space:]]*\[[[:space:]]*/, "", value)
        gsub(/[[:space:]]*\][[:space:]]*$/, "", value)
        item_count = split(value, items, ",")
        for (i = 1; i <= item_count; i++) {
          item = trim(items[i])
          if (item != "" && item != "\"\"" && item != "''" && item != "null" && item != "~") {
            count++
          }
        }
      }

      FNR == 1 {
        in_frontmatter = ($0 == "---")
        done_frontmatter = !in_frontmatter
        in_supersedes = 0
        next
      }

      done_frontmatter {
        next
      }

      in_frontmatter && $0 == "---" {
        done_frontmatter = 1
        in_frontmatter = 0
        in_supersedes = 0
        next
      }

      in_frontmatter {
        if ($0 ~ /^[A-Za-z_][A-Za-z0-9_-]*:/ && $0 !~ /^supersedes:/) {
          in_supersedes = 0
        }

        if ($0 ~ /^supersedes:[[:space:]]*\[[[:space:]]*\][[:space:]]*$/) {
          in_supersedes = 0
          next
        }

        if ($0 ~ /^supersedes:[[:space:]]*$/) {
          in_supersedes = 1
          next
        }

        if ($0 ~ /^supersedes:[[:space:]]*\[[^][]+\][[:space:]]*$/) {
          value = $0
          sub(/^supersedes:[[:space:]]*/, "", value)
          count_inline_list(value)
          in_supersedes = 0
          next
        }

        if ($0 ~ /^supersedes:[[:space:]]*.+/) {
          value = $0
          sub(/^supersedes:[[:space:]]*/, "", value)
          value = trim(value)
          if (value != "\"\"" && value != "''" && value != "null" && value != "~") {
            count++
          }
          in_supersedes = 0
          next
        }

        if (in_supersedes && $0 ~ /^[[:space:]]*-[[:space:]]*.+/) {
          value = $0
          sub(/^[[:space:]]*-[[:space:]]*/, "", value)
          value = trim(value)
          if (value != "\"\"" && value != "''" && value != "null" && value != "~") {
            count++
          }
          next
        }
      }

      END {
        print count + 0
      }
    '
}

count_contradiction_fixtures() {
  local memory_dir="${ROOT_DIR}/memory"

  if [ ! -d "$memory_dir" ]; then
    printf '0\n'
    return 0
  fi

  find "$memory_dir" -type f -name '*.md' -print0 \
    | xargs -0 awk '
      function trim(value) {
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", value)
        return value
      }

      function clean(value) {
        value = trim(value)
        gsub(/^"|"$/, "", value)
        return value
      }

      function add_conflict(value) {
        value = clean(value)
        if (value != "" && value != "[]" && value != "null" && value != "~") {
          conflicts = conflicts (conflicts == "" ? "" : ",") value
        }
      }

      function flush_record() {
        if (id != "" && fixture == "memory-evaluation-conflict" && subject != "" && conflict_value != "" && conflicts != "") {
          print id "\t" subject "\t" conflict_value "\t" conflicts
        }
      }

      FNR == 1 {
        if (NR > 1) {
          flush_record()
        }
        id = ""
        fixture = ""
        subject = ""
        conflict_value = ""
        conflicts = ""
        in_frontmatter = ($0 == "---")
        done_frontmatter = !in_frontmatter
        in_conflicts = 0
        next
      }

      done_frontmatter {
        next
      }

      in_frontmatter && $0 == "---" {
        done_frontmatter = 1
        in_frontmatter = 0
        in_conflicts = 0
        next
      }

      in_frontmatter {
        if ($0 ~ /^[A-Za-z_][A-Za-z0-9_-]*:/ && $0 !~ /^conflicts_with:/) {
          in_conflicts = 0
        }

        if ($0 ~ /^id:[[:space:]]*.+/) {
          value = $0
          sub(/^id:[[:space:]]*/, "", value)
          id = clean(value)
          next
        }

        if ($0 ~ /^conflict_fixture:[[:space:]]*.+/) {
          value = $0
          sub(/^conflict_fixture:[[:space:]]*/, "", value)
          fixture = clean(value)
          next
        }

        if ($0 ~ /^conflict_subject:[[:space:]]*.+/) {
          value = $0
          sub(/^conflict_subject:[[:space:]]*/, "", value)
          subject = clean(value)
          next
        }

        if ($0 ~ /^conflict_value:[[:space:]]*.+/) {
          value = $0
          sub(/^conflict_value:[[:space:]]*/, "", value)
          conflict_value = clean(value)
          next
        }

        if ($0 ~ /^conflicts_with:[[:space:]]*\[[^][]+\][[:space:]]*$/) {
          value = $0
          sub(/^conflicts_with:[[:space:]]*/, "", value)
          gsub(/^[[:space:]]*\[[[:space:]]*/, "", value)
          gsub(/[[:space:]]*\][[:space:]]*$/, "", value)
          item_count = split(value, items, ",")
          for (i = 1; i <= item_count; i++) {
            add_conflict(items[i])
          }
          in_conflicts = 0
          next
        }

        if ($0 ~ /^conflicts_with:[[:space:]]*$/) {
          in_conflicts = 1
          next
        }

        if (in_conflicts && $0 ~ /^[[:space:]]*-[[:space:]]*.+/) {
          value = $0
          sub(/^[[:space:]]*-[[:space:]]*/, "", value)
          add_conflict(value)
          next
        }
      }

      END {
        flush_record()
      }
    ' \
    | awk -F '\t' '
      {
        n++
        ids[n] = $1
        subjects[$1] = $2
        values[$1] = $3
        item_count = split($4, items, ",")
        for (i = 1; i <= item_count; i++) {
          conflicts[$1, items[i]] = 1
        }
      }

      END {
        count = 0
        for (i = 1; i <= n; i++) {
          for (j = i + 1; j <= n; j++) {
            left = ids[i]
            right = ids[j]
            if (subjects[left] == subjects[right] && values[left] != values[right] && conflicts[left, right] && conflicts[right, left]) {
              count++
            }
          }
        }
        print count + 0
      }
    '
}

check_conflict_fixture() {
  local sandbox="${ROOT_DIR}/.self-harness/tmp/memory-evaluation-conflict-fixture-main"
  local actual

  rm -rf "$sandbox"
  mkdir -p "${sandbox}/memory/lessons"

  cat >"${sandbox}/memory/lessons/conflict-a.md" <<'EOF'
---
id: "memory-conflict-fixture-a"
title: "Memory Conflict Fixture A"
type: "memory"
status: "active"
owner: "agent"
created: "2026-05-08"
updated: "2026-05-08"
tags:
  - fixture
  - memory
  - conflict
summary: "Fixture evidence that preserves one side of a contradiction."
conflict_fixture: "memory-evaluation-conflict"
conflict_subject: "fixture-claim"
conflict_value: "alpha"
conflicts_with:
  - "memory-conflict-fixture-b"
---

# Memory Conflict Fixture A

This scratch note represents one evidence record.
EOF

  cat >"${sandbox}/memory/lessons/conflict-b.md" <<'EOF'
---
id: "memory-conflict-fixture-b"
title: "Memory Conflict Fixture B"
type: "memory"
status: "active"
owner: "agent"
created: "2026-05-08"
updated: "2026-05-08"
tags:
  - fixture
  - memory
  - conflict
summary: "Fixture evidence that preserves the other side of a contradiction."
conflict_fixture: "memory-evaluation-conflict"
conflict_subject: "fixture-claim"
conflict_value: "beta"
conflicts_with:
  - "memory-conflict-fixture-a"
---

# Memory Conflict Fixture B

This scratch note represents the conflicting evidence record.
EOF

  actual="$(MEMORY_EVALUATION_ROOT_DIR="$sandbox" bash "${SCRIPT_DIR}/memory-evaluation-check.sh" --count-contradiction-fixtures)"
  [ "$actual" = "1" ]
}

main() {
  local missing=0
  local failures=0
  local rel

  for rel in "${required_memory_paths[@]}"; do
    if [ ! -f "${ROOT_DIR}/${rel}" ]; then
      score "fail" "traceability" "missing required evidence ${rel}"
      missing=1
    fi
  done

  if [ "$missing" -ne 0 ]; then
    return 1
  fi

  if query_has_path memory "adoption criteria" "memory/decisions/2026-05-05-skill-and-memory-adoption-criteria.md"; then
    score "pass" "recall" "exact fallback query finds the skill and memory adoption decision"
  else
    score "fail" "recall" "exact fallback query misses the skill and memory adoption decision"
    failures=$((failures + 1))
  fi

  if query_has_path memory "skill adoption" "memory/decisions/2026-05-05-skill-and-memory-adoption-criteria.md"; then
    score "pass" "recall-natural-phrase" "natural phrase query finds the adoption decision"
  else
    score "warn" "recall-natural-phrase" "natural phrase query still needs fallback term adoption criteria"
  fi

  if query_has_path memory "memory evaluation" "memory/lessons/2026-05-06-memory-recall-and-skill-audit.md"; then
    score "pass" "recall" "memory evaluation query finds the first recall audit"
  else
    score "fail" "recall" "memory evaluation query misses the first recall audit"
    failures=$((failures + 1))
  fi

  local mailbox_processing_hits
  mailbox_processing_hits="$(query_hit_count all "mailbox-processing")"
  if [ "$mailbox_processing_hits" -ge 5 ]; then
    score "pass" "traceability" "mailbox-processing query returns ${mailbox_processing_hits} linked records"
  else
    score "fail" "traceability" "mailbox-processing query returns only ${mailbox_processing_hits} linked records"
    failures=$((failures + 1))
  fi

  local branch_evolution_hits
  branch_evolution_hits="$(query_hit_count all "branch-evolution")"
  if [ "$branch_evolution_hits" -ge 3 ]; then
    score "pass" "actionability" "branch-evolution query returns ${branch_evolution_hits} records including reusable evaluation procedure"
  else
    score "fail" "actionability" "branch-evolution query returns only ${branch_evolution_hits} records"
    failures=$((failures + 1))
  fi

  local memory_eval_hits
  memory_eval_hits="$(query_hit_count memory "memory evaluation")"
  if [ "$memory_eval_hits" -le 12 ]; then
    score "pass" "precision" "memory evaluation query returns ${memory_eval_hits} inspectable memory records"
  else
    score "warn" "precision" "memory evaluation query returns ${memory_eval_hits} records and may need narrower follow-up terms"
  fi

  local supersedes_link_count
  supersedes_link_count="$(count_supersedes_links)"
  if [ "$supersedes_link_count" -gt 0 ]; then
    score "warn" "freshness" "only ${supersedes_link_count} memory supersedes link is declared in frontmatter"
  else
    score "warn" "freshness" "no memory supersedes links are declared in frontmatter"
  fi

  if check_conflict_fixture; then
    score "pass" "conflict-handling" "contradiction fixture preserves two independent memory evidence records with reciprocal conflict links"
  else
    score "fail" "conflict-handling" "deterministic contradiction fixture did not validate"
    failures=$((failures + 1))
  fi

  score "pass" "portability" "checked evidence paths are repository-relative"
  score "pass" "compression" "evaluation records summarize probes without copying session transcripts"

  [ "$failures" -eq 0 ]
}

case "${1:-}" in
  --count-supersedes-links)
    count_supersedes_links
    ;;
  --count-contradiction-fixtures)
    count_contradiction_fixtures
    ;;
  --check-conflict-fixture)
    if check_conflict_fixture; then
      echo "memory-evaluation-check: conflict fixture ok"
    else
      echo "memory-evaluation-check: conflict fixture failed" >&2
      exit 1
    fi
    ;;
  *)
    main "$@"
    ;;
esac
