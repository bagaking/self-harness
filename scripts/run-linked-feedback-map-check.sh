#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

feedback_pattern='(feedback|feedback-pressure|pressure-ratchet|raise the bar|stops too easily|stop too early|proof bar|supervisor feedback|post-run pressure)'
trigger_pattern='(skills/branch-evolution-evaluation/SKILL\.md|latest supervisor-facing reports|No next supervisor pressure:|run-linked)'
query_command_pattern="scripts/query-docs\\.sh[[:space:]]+skills[[:space:]]+[\"']?run-linked[\"']?"
query_output_pattern='^===== skills/branch-evolution-evaluation/SKILL\.md =====$'
git_log_pattern='git log --oneline -3'
outbox_path_pattern='mailbox/outbox/[^[:space:]`|]+\.md'
run_commit_pattern='[[:xdigit:]]{7,12}.*run:'
ordering_justification_pattern='(Acceptance-criteria ordering justification|Different ordering justification|explicit acceptance-criteria-based justification)'
self_referential_next_pattern='^Next supervisor pressure:.*(skills/branch-evolution-evaluation/SKILL\.md|scripts/query-docs\.sh[[:space:]]+skills[[:space:]]+["'"'"']?run-linked|run-linked.*map)'
artifact_pattern='(added `scripts/|updated `scripts/|added `skills/|updated `skills/|added `memory/|failure signal|negative case|fixture proof|focused script|rerunnable probe|mechanism fired|stronger proof artifact)'

changed_files() {
  {
    git -C "$ROOT_DIR" diff --name-only --diff-filter=ACMR
    git -C "$ROOT_DIR" diff --cached --name-only --diff-filter=ACMR
    git -C "$ROOT_DIR" ls-files --others --exclude-standard
  } | awk 'NF' | sort -u
}

document_matches() {
  local rel="$1"
  local pattern="$2"
  [ -f "${ROOT_DIR}/${rel}" ] || return 1
  LC_ALL=C rg -qi -- "$pattern" "${ROOT_DIR}/${rel}"
}

count_matches() {
  local rel="$1"
  local pattern="$2"
  [ -f "${ROOT_DIR}/${rel}" ] || {
    echo 0
    return 0
  }
  LC_ALL=C rg -c -- "$pattern" "${ROOT_DIR}/${rel}" || true
}

is_outbox_path() {
  case "$1" in
    mailbox/outbox/*.md) return 0 ;;
    *) return 1 ;;
  esac
}

is_target_outbox() {
  local rel="$1"
  is_outbox_path "$rel" || return 1
  document_matches "$rel" "$feedback_pattern" || return 1
  document_matches "$rel" "$trigger_pattern"
}

has_run_linked_map() {
  local rel="$1"
  local outbox_count run_commit_count

  document_matches "$rel" "$git_log_pattern" || return 1
  outbox_count="$(count_matches "$rel" "$outbox_path_pattern")"
  run_commit_count="$(count_matches "$rel" "$run_commit_pattern")"

  [ "$outbox_count" -ge 3 ] && [ "$run_commit_count" -ge 3 ]
}

has_ordering_justification() {
  local rel="$1"
  document_matches "$rel" "$ordering_justification_pattern" || return 1
  document_matches "$rel" "acceptance criteria"
}

check_file() {
  local rel="$1"
  local errors=0

  if ! document_matches "$rel" "$query_command_pattern"; then
    echo "run-linked-feedback-map-check: ${rel}: missing scripts/query-docs.sh skills \"run-linked\" command evidence" >&2
    errors=$((errors + 1))
  fi

  if ! document_matches "$rel" "$query_output_pattern"; then
    echo "run-linked-feedback-map-check: ${rel}: missing exact query output header for skills/branch-evolution-evaluation/SKILL.md" >&2
    errors=$((errors + 1))
  fi

  if ! has_run_linked_map "$rel" && ! has_ordering_justification "$rel"; then
    echo "run-linked-feedback-map-check: ${rel}: missing run-linked git-log to mailbox/outbox map or explicit acceptance-criteria ordering justification" >&2
    errors=$((errors + 1))
  fi

  if document_matches "$rel" "$self_referential_next_pattern" && ! document_matches "$rel" "$artifact_pattern"; then
    echo "run-linked-feedback-map-check: ${rel}: self-referential Next supervisor pressure repeats the run-linked requirement without a sharper proof artifact" >&2
    errors=$((errors + 1))
  fi

  [ "$errors" -eq 0 ]
}

main() {
  local rel errors targets
  errors=0
  targets=0

  while IFS= read -r rel; do
    [ -n "$rel" ] || continue
    if is_target_outbox "$rel"; then
      targets=$((targets + 1))
      check_file "$rel" || errors=$((errors + 1))
    fi
  done < <(changed_files)

  if [ "$errors" -gt 0 ]; then
    return 1
  fi

  if [ "$targets" -eq 0 ]; then
    echo "run-linked-feedback-map-check: ok (no changed target feedback outbox)"
  else
    echo "run-linked-feedback-map-check: ok"
  fi
}

main "$@"
