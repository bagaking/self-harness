#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

run_limit=5
trigger_limit=8
evidence_limit=3

usage() {
  cat <<'EOF'
Usage:
  scripts/branch-stop-condition-check.sh [--run-limit N] [--trigger-limit N] [--evidence-limit N]

Checks whether the branch has enough recent feedback evidence for the supervisor
to stop instead of raising another pressure item. The stop condition is strict:
recent run-linked feedback must have no unresolved next-pressure debt, next
pressure sources must have explicit source markers instead of incidental path
mentions, review triggers must already have lifecycle markers, and recent
outbox reports must not claim main readiness.
EOF
}

fail_usage() {
  echo "branch-stop-condition-check: $*" >&2
  usage >&2
  exit 2
}

positive_integer() {
  case "$1" in
    ''|*[!0-9]*)
      return 1
      ;;
    *)
      [ "$1" -gt 0 ]
      ;;
  esac
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --run-limit)
      [ "$#" -ge 2 ] || fail_usage "missing value after --run-limit"
      positive_integer "$2" || fail_usage "--run-limit must be a positive integer"
      run_limit="$2"
      shift 2
      ;;
    --trigger-limit)
      [ "$#" -ge 2 ] || fail_usage "missing value after --trigger-limit"
      positive_integer "$2" || fail_usage "--trigger-limit must be a positive integer"
      trigger_limit="$2"
      shift 2
      ;;
    --evidence-limit)
      [ "$#" -ge 2 ] || fail_usage "missing value after --evidence-limit"
      positive_integer "$2" || fail_usage "--evidence-limit must be a positive integer"
      evidence_limit="$2"
      shift 2
      ;;
    -h|--help|help)
      usage
      exit 0
      ;;
    *)
      fail_usage "unknown argument: $1"
      ;;
  esac
done

document_matches() {
  local rel="$1"
  local pattern="$2"
  [ -f "${ROOT_DIR}/${rel}" ] || return 1
  LC_ALL=C rg -qi -- "$pattern" "${ROOT_DIR}/${rel}"
}

mailbox_marker_files() {
  find \
    "${ROOT_DIR}/mailbox/inbox" \
    "${ROOT_DIR}/mailbox/processing" \
    "${ROOT_DIR}/mailbox/done" \
    "${ROOT_DIR}/mailbox/failed" \
    "${ROOT_DIR}/mailbox/outbox" \
    -maxdepth 1 -type f -name '*.md' 2>/dev/null
}

has_named_source_marker_for_source() {
  local marker="$1"
  local source_rel="$2"
  local file

  while IFS= read -r file; do
    [ -n "$file" ] || continue
    if LC_ALL=C rg -q --fixed-strings "${marker}: \"${source_rel}\"" "$file" ||
       LC_ALL=C rg -q --fixed-strings "${marker}: ${source_rel}" "$file"; then
      return 0
    fi
  done < <(mailbox_marker_files)

  return 1
}

has_next_pressure_marker_for_source() {
  local source_rel="$1"

  has_named_source_marker_for_source "next-pressure-source" "$source_rel" && return 0
  has_named_source_marker_for_source "continuous-pressure-source" "$source_rel" && return 0

  return 1
}

has_trigger_review_marker_for_source() {
  local source_rel="$1"

  has_named_source_marker_for_source "trigger-review-source" "$source_rel"
}

has_main_readiness_marker_for_source() {
  local source_rel="$1"

  has_named_source_marker_for_source "main-readiness-source" "$source_rel"
}

extract_marker_value() {
  local marker="$1"
  local rel="$2"
  awk -v marker="$marker" '
    index($0, marker) == 1 {
      value = substr($0, length(marker) + 1)
      sub(/^[[:space:]]+/, "", value)
      gsub(/[[:space:]]+/, " ", value)
      sub(/[[:space:]]+$/, "", value)
      print value
      exit
    }
  ' "${ROOT_DIR}/${rel}"
}

append_unique() {
  local value="$1"
  local existing

  while IFS= read -r existing; do
    [ -n "$existing" ] || continue
    [ "$existing" = "$value" ] && return 0
  done <<EOF
${recent_outboxes_list}
EOF

  if [ -z "$recent_outboxes_list" ]; then
    recent_outboxes_list="$value"
  else
    recent_outboxes_list="${recent_outboxes_list}
${value}"
  fi
}

recent_run_commits() {
  git -C "$ROOT_DIR" log --format='%H%x09%h%x09%s' -n 128 2>/dev/null \
    | awk -F '\t' -v limit="$run_limit" '
      $3 ~ /^run:/ {
        print
        count++
        if (count >= limit) {
          exit
        }
      }
    '
}

commit_outbox_files() {
  local commit="$1"
  git -C "$ROOT_DIR" show --name-only --format= "$commit" -- mailbox/outbox 2>/dev/null \
    | awk '$0 ~ /^mailbox\/outbox\/[^\/]+\.md$/ { print }'
}

main_readiness_line_is_positive() {
  local line="$1"
  local value

  value="$(printf '%s\n' "$line" | sed -E 's/^[0-9]+://; s/^Return-to-main( judgment)?:[[:space:]]*//')"

  printf '%s\n' "$value" \
    | LC_ALL=C rg -qi '^(candidate|yes|ready|promot(e|ion)|main-worthy|main worthy|return.*main)' \
    && return 0

  printf '%s\n' "$value" \
    | LC_ALL=C rg -qi '^(defer|deferred|blocked|branch-local|no([[:space:].,]|$)|not ready|should not|stay off `?main`?)' \
    && return 1

  return 1
}

check_recent_outbox_stop_debt() {
  local rel line requirement
  local errors=0

  while IFS= read -r rel; do
    [ -n "$rel" ] || continue
    [ -f "${ROOT_DIR}/${rel}" ] || continue

    if document_matches "$rel" '^Next supervisor pressure:[[:space:]]*.'; then
      if ! has_next_pressure_marker_for_source "$rel"; then
        requirement="$(extract_marker_value "Next supervisor pressure:" "$rel")"
        echo "branch-stop-condition-check: unresolved proof debt in ${rel}" >&2
        echo "branch-stop-condition-check: expected next-pressure-source or pressure-specific source marker" >&2
        echo "branch-stop-condition-check: requirement: ${requirement}" >&2
        errors=$((errors + 1))
      fi
    fi

    while IFS= read -r line; do
      [ -n "$line" ] || continue
      if main_readiness_line_is_positive "$line"; then
        if ! has_main_readiness_marker_for_source "$rel"; then
          echo "branch-stop-condition-check: recent outbox claims main readiness without a stop-safe deferral in ${rel}" >&2
          echo "branch-stop-condition-check: expected main-readiness-source marker after review" >&2
          echo "branch-stop-condition-check: ${line}" >&2
          errors=$((errors + 1))
        fi
      fi
    done < <(LC_ALL=C rg -n '^Return-to-main( judgment)?:' "${ROOT_DIR}/${rel}" || true)
  done <<EOF
${recent_outboxes_list}
EOF

  [ "$errors" -eq 0 ]
}

trigger_review_sources() {
  "${ROOT_DIR}/scripts/supervisor-evaluation-trigger-list.sh" \
    --status review \
    --limit "$trigger_limit" \
    --evidence-limit "$evidence_limit" \
    | awk '
      /^[[:space:]]*-[[:space:]]source:[[:space:]]*/ {
        value = $0
        sub(/^[[:space:]]*-[[:space:]]source:[[:space:]]*/, "", value)
        print value
      }
    '
}

check_review_triggers_are_challenged() {
  local source_rel
  local errors=0

  while IFS= read -r source_rel; do
    [ -n "$source_rel" ] || continue
    if ! has_trigger_review_marker_for_source "$source_rel"; then
      echo "branch-stop-condition-check: unchallenged review trigger source ${source_rel}" >&2
      echo "branch-stop-condition-check: expected trigger-review-source marker in mailbox lifecycle" >&2
      errors=$((errors + 1))
    fi
  done < <(trigger_review_sources)

  [ "$errors" -eq 0 ]
}

main() {
  local commit short subject rel outbox_count commit_count errors
  recent_outboxes_list=""
  commit_count=0
  errors=0

  while IFS=$'\t' read -r commit short subject; do
    [ -n "$commit" ] || continue
    commit_count=$((commit_count + 1))
    outbox_count=0
    echo "branch-stop-condition-check: run-map ${short} ${subject}"
    while IFS= read -r rel; do
      [ -n "$rel" ] || continue
      outbox_count=$((outbox_count + 1))
      append_unique "$rel"
      echo "branch-stop-condition-check:   ${rel}"
    done < <(commit_outbox_files "$commit")
    if [ "$outbox_count" -eq 0 ]; then
      echo "branch-stop-condition-check: run commit ${short} has no changed top-level mailbox/outbox/*.md file" >&2
      errors=$((errors + 1))
    fi
  done < <(recent_run_commits)

  if [ "$commit_count" -eq 0 ]; then
    echo "branch-stop-condition-check: no recent run commits found" >&2
    return 1
  fi

  check_recent_outbox_stop_debt || errors=$((errors + 1))
  check_review_triggers_are_challenged || errors=$((errors + 1))

  if [ "$errors" -gt 0 ]; then
    return 1
  fi

  echo "branch-stop-condition-check: ok"
}

main "$@"
