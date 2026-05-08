#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
WORK_DIR="${ROOT_DIR}/.self-harness/tmp/supervisor-evaluation-trigger-list"

limit=10
evidence_limit=3
status_filter="all"

usage() {
  cat <<'EOF'
Usage:
  scripts/supervisor-evaluation-trigger-list.sh [--limit N] [--evidence-limit N] [--status all|review|quiet]

Lists recent feedback-pressure refusals that include `Supervisor evaluation trigger:`
and searches later durable repository evidence for matching trigger terms.
EOF
}

fail_usage() {
  echo "supervisor-evaluation-trigger-list: $*" >&2
  usage >&2
  exit 2
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --limit)
      [ "$#" -ge 2 ] || fail_usage "missing value after --limit"
      limit="$2"
      shift 2
      ;;
    --evidence-limit)
      [ "$#" -ge 2 ] || fail_usage "missing value after --evidence-limit"
      evidence_limit="$2"
      shift 2
      ;;
    --status)
      [ "$#" -ge 2 ] || fail_usage "missing value after --status"
      status_filter="$2"
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

case "$limit" in
  ''|*[!0-9]*)
    fail_usage "--limit must be a non-negative integer"
    ;;
esac

case "$evidence_limit" in
  ''|*[!0-9]*)
    fail_usage "--evidence-limit must be a non-negative integer"
    ;;
esac

case "$status_filter" in
  all|review|quiet)
    ;;
  *)
    fail_usage "--status must be all, review, or quiet"
    ;;
esac

repo_relative_path() {
  local path="$1"
  case "$path" in
    "${ROOT_DIR}/"*)
      printf '%s\n' "${path#${ROOT_DIR}/}"
      ;;
    *)
      printf '%s\n' "$path"
      ;;
  esac
}

extract_marker_value() {
  local marker="$1"
  local file="$2"
  awk -v marker="$marker" '
    index($0, marker) == 1 {
      value = substr($0, length(marker) + 1)
      sub(/^[[:space:]]+/, "", value)
      gsub(/[[:space:]]+/, " ", value)
      sub(/[[:space:]]+$/, "", value)
      print value
      exit
    }
  ' "$file"
}

has_trigger_backed_refusal() {
  local file="$1"
  [ -n "$(extract_marker_value "No next supervisor pressure:" "$file")" ] || return 1
  [ -n "$(extract_marker_value "Supervisor evaluation trigger:" "$file")" ] || return 1
}

source_commit_for_path() {
  local rel="$1"
  git -C "$ROOT_DIR" log --diff-filter=A --format=%H -- "$rel" 2>/dev/null | tail -1
}

staged_or_changed_files() {
  {
    git -C "$ROOT_DIR" diff --name-only --diff-filter=ACMR
    git -C "$ROOT_DIR" diff --cached --name-only --diff-filter=ACMR
    git -C "$ROOT_DIR" ls-files --others --exclude-standard
  } | awk 'NF'
}

is_candidate_evidence_path() {
  case "$1" in
    scripts/supervisor-evaluation-trigger-list.sh|scripts/supervisor-evaluation-trigger-list-check.sh)
      return 1
      ;;
    mailbox/inbox/*.md|mailbox/processing/*.md|mailbox/done/*.md|mailbox/failed/*.md|mailbox/outbox/*.md)
      return 0
      ;;
    memory/incidents/*.md|memory/diary/*.md|memory/decisions/*.md|memory/lessons/*.md)
      return 0
      ;;
    scripts/*.sh|skills/*)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

candidate_files_after_source() {
  local source_rel="$1"
  local source_commit="$2"

  if [ -z "$source_commit" ]; then
    return 0
  fi

  {
    git -C "$ROOT_DIR" diff --name-only --diff-filter=ACMR "${source_commit}..HEAD" -- mailbox memory scripts skills 2>/dev/null || true
    staged_or_changed_files
  } | awk 'NF' | sort -u | while IFS= read -r rel; do
    [ "$rel" != "$source_rel" ] || continue
    [ -f "${ROOT_DIR}/${rel}" ] || continue
    is_candidate_evidence_path "$rel" || continue
    printf '%s\n' "$rel"
  done
}

write_trigger_needles() {
  local trigger="$1"
  local out_file="$2"

  printf '%s\n' "$trigger" | awk '
    function context_tail(value, width, start) {
      start = length(value) - width + 1
      if (start < 1) {
        start = 1
      }
      return substr(value, start)
    }
    function has_concrete_outbox_artifact_prefix(lower_prefix, tail) {
      tail = context_tail(lower_prefix, 120)
      return (tail ~ /(concrete|changed|proof|target|patch|outbox markdown|outbox-markdown|markdown)[^`]{0,80}(artifact|record|file|path)/ ||
              tail ~ /(artifact|record|file|path)[^`]{0,80}(concrete|changed|proof|target|patch|outbox markdown|outbox-markdown|markdown)/)
    }
    function is_trigger_review_meta_needle(lower_value, lower_prefix) {
      if (!trigger_review_meta) {
        return 0
      }
      if (lower_value ~ /^mailbox\/outbox\/[^[:space:]]+\.md$/ &&
          !has_concrete_outbox_artifact_prefix(lower_prefix)) {
        return 1
      }
      if (lower_value == "scripts/supervisor-evaluation-trigger-list.sh" &&
          context_tail(lower_prefix, 80) ~ /defect against[[:space:]]*$/) {
        return 1
      }
      return 0
    }
    function is_ignored_needle(lower_value, lower_prefix) {
      if (lower_value == "no next supervisor pressure:" ||
          lower_value == "supervisor evaluation trigger:" ||
          lower_value == "next supervisor pressure:" ||
          lower_value == "task_complete" ||
          lower_value == "review-evidence" ||
          lower_value == "trigger-review-source:" ||
          lower_value == "mailbox/inbox" ||
          lower_value == "mailbox/processing" ||
          lower_value == "mailbox/done" ||
          lower_value == "mailbox/failed" ||
          lower_value == "mailbox/outbox") {
        return 1
      }
      if (lower_value ~ /^scripts\/supervisor\.sh[[:space:]]+triggers/ &&
          lower_value ~ /--status[[:space:]]+review/) {
        return 1
      }
      if (lower_value ~ /^scripts\/supervisor-evaluation-trigger-list\.sh/ &&
          lower_value ~ /--status[[:space:]]+review/) {
        return 1
      }
      if (lower_value == "scripts/supervisor-evaluation-trigger-list-check.sh" &&
          trigger_review_meta &&
          lower_text ~ /fixture[^.]{0,80}fail/) {
        return 1
      }
      if (is_trigger_review_meta_needle(lower_value, lower_prefix)) {
        return 1
      }
      return 0
    }
    {
      text = $0
      lower_text = tolower(text)
      trigger_review_meta = (lower_text ~ /scripts\/supervisor\.sh[[:space:]]+triggers/ && lower_text ~ /(gains new later evidence|review-evidence source|review evidence from repeated source-path prose|trigger-review source|reappears only because[^.]*later record[^.]*repeats|listed only because[^.]*repeats|source-path meta)/)
      while (match(text, /`[^`]+`/)) {
        value = substr(text, RSTART + 1, RLENGTH - 2)
        lower_value = tolower(value)
        lower_prefix = tolower(substr(text, 1, RSTART - 1))
        if (length(value) > 0 && !is_ignored_needle(lower_value, lower_prefix) && value ~ /[.\/:_ -]/) {
          print value
        }
        text = substr(text, RSTART + RLENGTH)
      }
    }
  ' | awk 'NF && !seen[tolower($0)]++ { print; count++; if (count >= 10) exit }' >"$out_file"
}

file_added_after_source() {
  local rel="$1"
  local source_commit="$2"

  [ -n "$source_commit" ] || return 1

  if git -C "$ROOT_DIR" cat-file -e "${source_commit}:${rel}" 2>/dev/null; then
    return 1
  fi

  return 0
}

needle_matches_changed_path() {
  local rel="$1"
  local needle="$2"

  case "$needle" in
    */)
      case "$rel" in
        "$needle"*) return 0 ;;
      esac
      ;;
  esac

  return 1
}

content_stream_contains_needle() {
  local needle="$1"

  awk -v needle="$needle" '
    BEGIN {
      lower_needle = tolower(needle)
      found = 0
    }
    function should_ignore_content_match(lower_line) {
      if (lower_needle ~ /\/$/) {
        return 1
      }
      if (lower_needle == "scripts/supervisor.sh" &&
          lower_line ~ /scripts\/supervisor\.sh[[:space:]]+triggers/ &&
          lower_line ~ /--status[[:space:]]+review/) {
        return 1
      }
      if (lower_needle == "scripts/supervisor.sh" &&
          lower_line ~ /(command citation|content match|content matches|trigger-review command|trigger review command)/) {
        return 1
      }
      return 0
    }
    {
      if (found) {
        next
      }
      lower_line = tolower($0)
      if (index(lower_line, lower_needle) > 0) {
        if (should_ignore_content_match(lower_line)) {
          next
        }
        found = 1
      }
    }
    END {
      exit(found ? 0 : 1)
    }
  '
}

added_content_contains() {
  local rel="$1"
  local needle="$2"
  local source_commit="$3"

  {
    if [ -n "$source_commit" ]; then
      git -C "$ROOT_DIR" diff --no-ext-diff --unified=0 "${source_commit}..HEAD" -- "$rel" 2>/dev/null || true
    fi
    git -C "$ROOT_DIR" diff --no-ext-diff --unified=0 -- "$rel" 2>/dev/null || true
    git -C "$ROOT_DIR" diff --cached --no-ext-diff --unified=0 -- "$rel" 2>/dev/null || true
  } | awk '/^\+/ && $0 !~ /^\+\+\+ / { print substr($0, 2) }' | content_stream_contains_needle "$needle"
}

path_or_file_contains() {
  local rel="$1"
  local needle="$2"
  local source_commit="$3"
  [ -n "$needle" ] || return 1

  if needle_matches_changed_path "$rel" "$needle"; then
    return 0
  fi

  if printf '%s\n' "$rel" | LC_ALL=C rg -Fqi -- "$needle"; then
    if file_added_after_source "$rel" "$source_commit" ||
       ! git -C "$ROOT_DIR" ls-files --error-unmatch "$rel" >/dev/null 2>&1; then
      return 0
    fi
  fi

  if ! git -C "$ROOT_DIR" ls-files --error-unmatch "$rel" >/dev/null 2>&1; then
    content_stream_contains_needle "$needle" <"${ROOT_DIR}/${rel}"
    return $?
  fi

  added_content_contains "$rel" "$needle" "$source_commit"
}

write_matching_evidence() {
  local source_rel="$1"
  local source_commit="$2"
  local needles_file="$3"
  local out_file="$4"
  local rel needle terms count

  : >"$out_file"
  count=0

  while IFS= read -r rel; do
    [ -n "$rel" ] || continue
    terms=""
    while IFS= read -r needle; do
      if path_or_file_contains "$rel" "$needle" "$source_commit"; then
        if [ -z "$terms" ]; then
          terms="$needle"
        else
          terms="${terms}; ${needle}"
        fi
      fi
    done <"$needles_file"

    [ -n "$terms" ] || continue
    printf '%s\t%s\n' "$rel" "$terms" >>"$out_file"
    count=$((count + 1))
    [ "$evidence_limit" -eq 0 ] && continue
    [ "$count" -lt "$evidence_limit" ] || break
  done < <(candidate_files_after_source "$source_rel" "$source_commit")
}

status_allowed() {
  local status="$1"
  case "$status_filter" in
    all)
      return 0
      ;;
    review)
      [ "$status" = "review-evidence" ]
      ;;
    quiet)
      [ "$status" = "no-later-evidence" ]
      ;;
  esac
}

print_trigger_record() {
  local rel="$1"
  local file="${ROOT_DIR}/${rel}"
  local trigger boundary bounded source_commit status
  local needles_file evidence_file evidence_count

  trigger="$(extract_marker_value "Supervisor evaluation trigger:" "$file")"
  boundary="$(extract_marker_value "No next supervisor pressure:" "$file")"
  bounded="$(extract_marker_value "Stop condition:" "$file")"
  if [ -z "$bounded" ]; then
    bounded="$(extract_marker_value "Smaller useful task:" "$file")"
  fi

  source_commit="$(source_commit_for_path "$rel" || true)"
  needles_file="${WORK_DIR}/needles.$$"
  evidence_file="${WORK_DIR}/evidence.$$"
  write_trigger_needles "$trigger" "$needles_file"
  write_matching_evidence "$rel" "$source_commit" "$needles_file" "$evidence_file"
  evidence_count="$(wc -l <"$evidence_file" | tr -d '[:space:]')"

  if [ "$evidence_count" -gt 0 ]; then
    status="review-evidence"
  else
    status="no-later-evidence"
  fi

  status_allowed "$status" || return 1

  printf -- '- source: %s\n' "$rel"
  printf '  status: %s\n' "$status"
  printf '  trigger: %s\n' "$trigger"
  printf '  boundary: %s\n' "$boundary"
  if [ -n "$bounded" ]; then
    printf '  bounded: %s\n' "$bounded"
  fi
  if [ "$evidence_count" -gt 0 ]; then
    printf '  evidence:\n'
    awk -F '\t' '{ printf "    - %s (matched: %s)\n", $1, $2 }' "$evidence_file"
  else
    printf '  evidence: none found after source commit\n'
  fi

  return 0
}

main() {
  mkdir -p "$WORK_DIR"
  rm -f "${WORK_DIR}/needles.$$" "${WORK_DIR}/evidence.$$"
  trap 'rm -f "${WORK_DIR}/needles.$$" "${WORK_DIR}/evidence.$$"' EXIT

  local file rel seen printed
  seen=0
  printed=0

  while IFS= read -r file; do
    [ -n "$file" ] || continue
    has_trigger_backed_refusal "$file" || continue
    rel="$(repo_relative_path "$file")"
    seen=$((seen + 1))
    if [ "$limit" -ne 0 ] && [ "$seen" -gt "$limit" ]; then
      break
    fi
    if print_trigger_record "$rel"; then
      printed=$((printed + 1))
    fi
  done < <(find "${ROOT_DIR}/mailbox/outbox" -maxdepth 1 -type f -name '*.md' | sort -r)

  if [ "$seen" -eq 0 ]; then
    echo "supervisor-evaluation-trigger-list: no supervisor evaluation triggers found"
    return 0
  fi

  if [ "$printed" -eq 0 ]; then
    echo "supervisor-evaluation-trigger-list: no triggers matched status filter ${status_filter}"
    return 0
  fi
}

main "$@"
