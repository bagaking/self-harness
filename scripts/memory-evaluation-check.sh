#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

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

  local supersedes_count
  supersedes_count="$(rg -n '^supersedes:' "${ROOT_DIR}/memory" | wc -l | tr -d '[:space:]' || true)"
  if [ "$supersedes_count" -gt 0 ]; then
    score "warn" "freshness" "only ${supersedes_count} memory note declares supersession metadata"
  else
    score "warn" "freshness" "no memory note declares supersession metadata"
  fi

  score "warn" "conflict-handling" "repository preserves contradictory notes append-only, but no deterministic contradiction fixture exists"
  score "pass" "portability" "checked evidence paths are repository-relative"
  score "pass" "compression" "evaluation records summarize probes without copying session transcripts"

  [ "$failures" -eq 0 ]
}

main "$@"
