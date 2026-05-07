#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

max_seconds=90
session_files=()

usage() {
  cat <<'EOF'
Usage:
  scripts/pending-inbox-claim-latency-check.sh [--max-seconds N] [SESSION...]

Checks Codex session transcripts for pending-inbox launches where broad
discovery commands happened before the first mailbox claim.

If no SESSION is supplied, the latest session transcript is checked.
EOF
}

fail_usage() {
  echo "pending-inbox-claim-latency-check: $*" >&2
  usage >&2
  exit 2
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --max-seconds)
      [ "$#" -ge 2 ] || fail_usage "missing value after --max-seconds"
      max_seconds="$2"
      shift 2
      ;;
    -h|--help|help)
      usage
      exit 0
      ;;
    *)
      session_files+=("$1")
      shift
      ;;
  esac
done

case "$max_seconds" in
  ''|*[!0-9]*)
    fail_usage "--max-seconds must be a non-negative integer"
    ;;
esac

if ! command -v jq >/dev/null 2>&1; then
  echo "pending-inbox-claim-latency-check: jq is required to parse session JSONL" >&2
  exit 2
fi

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

latest_session_file() {
  find "${ROOT_DIR}/sessions" -type f \( -name '*.jsonl' -o -name '*.jsonl.*' \) 2>/dev/null \
    | sort \
    | tail -1
}

timestamp_epoch() {
  local value="$1"
  local trimmed
  trimmed="$(printf '%s\n' "$value" | sed -E 's/\.[0-9]+Z$/Z/')"

  if date -u -j -f "%Y-%m-%dT%H:%M:%SZ" "$trimmed" +%s >/dev/null 2>&1; then
    date -u -j -f "%Y-%m-%dT%H:%M:%SZ" "$trimmed" +%s
    return 0
  fi

  date -u -d "$trimmed" +%s 2>/dev/null
}

session_start_timestamp() {
  jq -r 'select(.type == "session_meta") | .timestamp' "$1" | head -1
}

has_pending_inbox_prompt() {
  local file="$1"
  LC_ALL=C rg -q 'Pending mailbox before launch:' "$file" || return 1
  LC_ALL=C rg -q 'mailbox/inbox/[^[:space:]`"\\]+\.md' "$file"
}

function_call_rows() {
  local file="$1"
  jq -r '
    select(.type == "response_item" and .payload.type == "function_call")
    | .timestamp as $ts
    | .payload.name as $name
    | (.payload.arguments // "") as $raw
    | ($raw | fromjson? // {}) as $args
    | ($args.cmd // $args.patch // $raw // "")
    | tostring
    | gsub("\n"; " ")
    | [$ts, $name, .] | @tsv
  ' "$file"
}

is_claim_command() {
  local cmd="$1"
  LC_ALL=C rg -q '(^|[;&|[:space:]])mv[[:space:]]+mailbox/inbox/[^[:space:]]+\.md[[:space:]]+mailbox/processing/[^[:space:]]+\.md' <<<"$cmd"
}

is_broad_preclaim_command() {
  local cmd="$1"

  if LC_ALL=C rg -q '(^|[;&|[:space:]])scripts/query-docs\.sh[[:space:]]' <<<"$cmd"; then
    return 0
  fi

  if LC_ALL=C rg -q '(^|[;&|[:space:]])find[[:space:]]+(mailbox|memory|scripts|skills|constitution|sessions|\.)([[:space:]/]|$)' <<<"$cmd"; then
    return 0
  fi

  if LC_ALL=C rg -q '(^|[;&|[:space:]])rg[[:space:]]' <<<"$cmd"; then
    return 0
  fi

  if LC_ALL=C rg -q '(^|[;&|[:space:]])git[[:space:]]+(log|show|status|diff|grep|ls-files)([[:space:]]|$)' <<<"$cmd"; then
    return 0
  fi

  if LC_ALL=C rg -q '(^|[;&|[:space:]])ls([[:space:]]|$)' <<<"$cmd"; then
    return 0
  fi

  case "$cmd" in
    *constitution/10-*|*constitution/20-*|*constitution/30-*|*constitution/40-*|*constitution/50-*|*memory/*|*mailbox/outbox/*|*mailbox/done/*|*mailbox/failed/*|*skills/branch-evolution-evaluation*)
      return 0
      ;;
  esac

  return 1
}

scan_session() {
  local file="$1"
  local rel start_ts start_epoch claim_ts claim_epoch claim_delay=""
  local broad_commands="" claim_cmd="" status=0
  local ts name cmd

  if [ ! -f "$file" ]; then
    echo "pending-inbox-claim-latency-check: missing $(repo_relative_path "$file")" >&2
    return 1
  fi

  rel="$(repo_relative_path "$file")"

  if ! has_pending_inbox_prompt "$file"; then
    echo "pending-inbox-claim-latency-check: skip ${rel}: no pending-inbox launch prompt"
    return 0
  fi

  start_ts="$(session_start_timestamp "$file" || true)"
  if [ -n "$start_ts" ]; then
    start_epoch="$(timestamp_epoch "$start_ts" || true)"
  else
    start_epoch=""
  fi

  while IFS=$'\t' read -r ts name cmd; do
    [ -n "${ts:-}" ] || continue
    if is_claim_command "$cmd"; then
      claim_ts="$ts"
      claim_cmd="$cmd"
      break
    fi
    if is_broad_preclaim_command "$cmd"; then
      broad_commands="${broad_commands}- ${ts} ${cmd}"$'\n'
    fi
  done < <(function_call_rows "$file")

  if [ -z "$claim_cmd" ]; then
    echo "pending-inbox-claim-latency-check: FAIL ${rel}"
    echo "claim: none"
    echo "reason: pending-inbox launch did not claim mailbox/inbox before transcript end"
    if [ -n "$broad_commands" ]; then
      echo "broad pre-claim commands:"
      printf '%s' "$broad_commands"
    fi
    return 1
  fi

  if [ -n "${start_epoch:-}" ]; then
    claim_epoch="$(timestamp_epoch "$claim_ts" || true)"
    if [ -n "${claim_epoch:-}" ]; then
      claim_delay=$((claim_epoch - start_epoch))
      [ "$claim_delay" -lt 0 ] && claim_delay=""
    fi
  fi

  if [ -n "$broad_commands" ]; then
    status=1
  fi

  if [ -n "$claim_delay" ] && [ "$claim_delay" -gt "$max_seconds" ]; then
    status=1
  fi

  if [ "$status" -ne 0 ]; then
    echo "pending-inbox-claim-latency-check: FAIL ${rel}"
    echo "claim: ${claim_ts} ${claim_cmd}"
    [ -z "$claim_delay" ] || echo "claim_delay_seconds: ${claim_delay}"
    echo "max_seconds: ${max_seconds}"
    if [ -n "$broad_commands" ]; then
      echo "broad pre-claim commands:"
      printf '%s' "$broad_commands"
    fi
    if [ -n "$claim_delay" ] && [ "$claim_delay" -gt "$max_seconds" ]; then
      echo "latency: first claim exceeded max_seconds"
    fi
    return 1
  fi

  if [ -n "$claim_delay" ]; then
    echo "pending-inbox-claim-latency-check: ok ${rel} claim_delay_seconds=${claim_delay}"
  else
    echo "pending-inbox-claim-latency-check: ok ${rel}"
  fi
}

main() {
  local status=0 latest

  if [ "${#session_files[@]}" -eq 0 ]; then
    latest="$(latest_session_file || true)"
    [ -n "$latest" ] || {
      echo "pending-inbox-claim-latency-check: no session files found" >&2
      return 1
    }
    session_files+=("$latest")
  fi

  local session
  for session in "${session_files[@]}"; do
    scan_session "$session" || status=1
  done

  return "$status"
}

main "$@"
