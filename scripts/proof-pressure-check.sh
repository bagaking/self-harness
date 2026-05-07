#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

RECENT_LIMIT="${SELF_HARNESS_PROOF_PRESSURE_RECENT_LIMIT:-12}"
RECENT_THRESHOLD="${SELF_HARNESS_PROOF_PRESSURE_RECENT_THRESHOLD:-2}"

low_value_subject_pattern='^(run: (record self-harness state|new mode|new session no pending|new run state)|run: .*?(no pending|mailbox sweep|state mailbox|repository state|repository inspection))'
low_value_doc_pattern='(no pending|state mailbox|mailbox sweep|repository sweep|repository state|repository inspection|cleanliness report|record self-harness state|found no pending|no standalone memory or skill|generic repository sweep)'

current_branch() {
  git -C "$ROOT_DIR" branch --show-current 2>/dev/null || true
}

is_agent_branch() {
  case "$(current_branch)" in
    agent/*)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

changed_files() {
  {
    git -C "$ROOT_DIR" diff --name-only
    git -C "$ROOT_DIR" diff --cached --name-only
    git -C "$ROOT_DIR" ls-files --others --exclude-standard
  } | awk 'NF' | sort -u
}

recent_low_value_subjects() {
  git -C "$ROOT_DIR" log --format=%s -n "$RECENT_LIMIT" 2>/dev/null \
    | rg -i "$low_value_subject_pattern" \
    || true
}

recent_low_value_count() {
  recent_low_value_subjects | wc -l | tr -d '[:space:]'
}

document_looks_low_value() {
  local file="$1"
  sed -n '1,120p' "$file" | LC_ALL=C rg -qi "$low_value_doc_pattern"
}

current_changes_are_pure_sweep() {
  local rel file saw_file saw_low_value_doc saw_session
  saw_file=0
  saw_low_value_doc=0
  saw_session=0

  while IFS= read -r rel; do
    [ -n "$rel" ] || continue
    saw_file=1
    file="${ROOT_DIR}/${rel}"

    if [ ! -f "$file" ]; then
      return 1
    fi

    case "$rel" in
      sessions/*)
        saw_session=1
        ;;
      memory/diary/*.md|mailbox/outbox/*.md)
        if document_looks_low_value "$file"; then
          saw_low_value_doc=1
        else
          return 1
        fi
        ;;
      *)
        return 1
        ;;
    esac
  done < <(changed_files)

  [ "$saw_file" -eq 1 ] || return 1
  [ "$saw_low_value_doc" -eq 1 ] || [ "$saw_session" -eq 1 ]
}

main() {
  is_agent_branch || {
    echo "proof-pressure-check: ok"
    return 0
  }

  local count
  count="$(recent_low_value_count)"

  if [ "$count" -lt "$RECENT_THRESHOLD" ]; then
    echo "proof-pressure-check: ok"
    return 0
  fi

  if ! current_changes_are_pure_sweep; then
    echo "proof-pressure-check: ok"
    return 0
  fi

  {
    echo "proof-pressure-check: repeated low-value state-sweep pattern detected"
    echo
    echo "Recent low-value commit subjects:"
    recent_low_value_subjects | sed 's/^/- /'
    echo
    echo "Current changed files:"
    changed_files | sed 's/^/- /'
    echo
    echo "A branch that already has repeated no-pending/state-sweep commits must not add another pure sweep commit."
    echo "Handle a concrete inbox challenge, add evidence-backed memory/skill/script work, or write a precise refusal/proposal."
  } >&2
  return 1
}

main "$@"
