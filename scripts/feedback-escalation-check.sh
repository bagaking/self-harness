#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

feedback_pattern='(feedback|feedback-pressure|feedback escalation|escalation loop|pressure-ratchet|raise the bar|stops too easily|stop too early|low-value|passive-loop|passive loop|proof bar|stronger next action|harder requirement|supervisor feedback)'
reviewed_evidence_pattern='(^##[[:space:]].*(Reviewed Evidence|Evidence Reviewed)|latest (three|five).*outbox|latest (three|five).*run commit|latest [0-9]+.*outbox|latest [0-9]+.*run commit)'
weakness_pattern='(^##[[:space:]].*(Weakness|Current Weakness|Proof Bar|Gap)|exact current weakness|stops? too early|lowered the proof bar)'
mechanism_pattern='(^##[[:space:]].*(Improvement|Mechanism|Requirement|Gate|Decision|Refusal)|future-facing mechanism|future requirement|durable mechanism|added `scripts/|updated `scripts/|added `skills/|updated `skills/|added `memory/)'
anti_noise_pattern='(^##[[:space:]].*Anti-Noise|anti-noise|when not to escalate|do not escalate|refuse escalation|refused escalation|narrower task|script would be premature)'
verification_pattern='(^##[[:space:]].*(Verification|Validation|Rerunnable Evidence|How To Tell It Worked)|rerunnable verification|scripts/[[:alnum:]_.-]+\.sh|bash -n)'
return_pattern='(^##[[:space:]].*Return[- ]?To[- ]?Main|return-to-main|return to main)'
refusal_pattern='(refuse escalation|refused escalation|narrower task|script would be premature|do not escalate)'

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

is_handled_mailbox_path() {
  case "$1" in
    mailbox/done/*.md|mailbox/failed/*.md|mailbox/outbox/*.md)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

is_outbox_path() {
  case "$1" in
    mailbox/outbox/*.md)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

is_mechanism_path() {
  case "$1" in
    scripts/*.sh|skills/*|memory/decisions/*.md|memory/lessons/*.md|memory/proposals/*.md|memory/incidents/*.md)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

any_outbox_matches() {
  local pattern="$1"
  local rel
  for rel in "${feedback_outbox_files[@]}"; do
    document_matches "$rel" "$pattern" && return 0
  done
  return 1
}

print_list() {
  local rel
  for rel in "$@"; do
    printf '  - %s\n' "$rel" >&2
  done
}

require_outbox_marker() {
  local label="$1"
  local pattern="$2"
  if any_outbox_matches "$pattern"; then
    return 0
  fi
  echo "feedback-escalation-check: missing ${label} in changed feedback outbox report" >&2
  return 1
}

main() {
  local rel errors
  feedback_files=()
  feedback_outbox_files=()
  mechanism_files=()

  while IFS= read -r rel; do
    [ -n "$rel" ] || continue

    if is_handled_mailbox_path "$rel" && document_matches "$rel" "$feedback_pattern"; then
      feedback_files+=("$rel")
    fi

    if is_outbox_path "$rel" && document_matches "$rel" "$feedback_pattern"; then
      feedback_outbox_files+=("$rel")
    fi

    if is_mechanism_path "$rel"; then
      mechanism_files+=("$rel")
    fi
  done < <(changed_files)

  if [ "${#feedback_files[@]}" -eq 0 ]; then
    echo "feedback-escalation-check: ok"
    return 0
  fi

  if [ "${#feedback_outbox_files[@]}" -eq 0 ]; then
    echo "feedback-escalation-check: changed feedback-bearing mailbox work needs a supervisor-facing outbox report" >&2
    echo "feedback-escalation-check: feedback-bearing changed files:" >&2
    print_list "${feedback_files[@]}"
    return 1
  fi

  errors=0
  require_outbox_marker "reviewed evidence" "$reviewed_evidence_pattern" || errors=$((errors + 1))
  require_outbox_marker "specific weakness" "$weakness_pattern" || errors=$((errors + 1))
  require_outbox_marker "future-facing mechanism or refusal" "$mechanism_pattern" || errors=$((errors + 1))
  require_outbox_marker "anti-noise boundary" "$anti_noise_pattern" || errors=$((errors + 1))
  require_outbox_marker "rerunnable verification" "$verification_pattern" || errors=$((errors + 1))
  require_outbox_marker "return-to-main judgment" "$return_pattern" || errors=$((errors + 1))

  if [ "${#mechanism_files[@]}" -eq 0 ] && ! any_outbox_matches "$refusal_pattern"; then
    echo "feedback-escalation-check: feedback-bearing work must change a durable mechanism or explicitly refuse escalation and ask for a narrower task" >&2
    errors=$((errors + 1))
  fi

  if [ "$errors" -gt 0 ]; then
    echo "feedback-escalation-check: feedback-bearing changed files:" >&2
    print_list "${feedback_files[@]}"
    echo "feedback-escalation-check: changed feedback outbox reports:" >&2
    print_list "${feedback_outbox_files[@]}"
    return 1
  fi

  echo "feedback-escalation-check: ok"
}

main "$@"
