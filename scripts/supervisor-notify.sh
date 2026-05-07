#!/usr/bin/env bash
set -euo pipefail

if [ -n "${SELF_HARNESS_SUPERVISOR_ROOT:-}" ]; then
  ROOT_DIR="$SELF_HARNESS_SUPERVISOR_ROOT"
  SCRIPT_DIR="${ROOT_DIR}/scripts"
else
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
fi

PRIVATE_DIR="${ROOT_DIR}/.self-harness"
RUN_DIR="${PRIVATE_DIR}/run"
STATUS_LOG="${RUN_DIR}/supervisor-status.log"

EVENT=""
STATE=""
REASON=""
BODY=""
BRANCH=""

usage() {
  cat <<'EOF'
Usage:
  scripts/supervisor-notify.sh --event EVENT --status STATUS --reason REASON [--body TEXT] [--branch BRANCH]

Records a supervisor status event locally. If SELF_HARNESS_NOTIFY_CHAT_ID or
SELF_HARNESS_NOTIFY_USER_ID is configured, also sends the status through
lark-cli im +messages-send.

Configuration:
  SELF_HARNESS_NOTIFY_CHAT_ID       Optional chat recipient for lark-cli.
  SELF_HARNESS_NOTIFY_USER_ID       Optional direct-message recipient for lark-cli.
  SELF_HARNESS_NOTIFY_AS            lark-cli identity, default bot.
  SELF_HARNESS_NOTIFY_LARK_BIN      lark-cli binary, default lark-cli.
  SELF_HARNESS_NOTIFY_SIGNATURE     Optional explicit signature line.
  SELF_HARNESS_NOTIFY_DRY_RUN       Set to 1 to pass --dry-run to lark-cli.
  SELF_HARNESS_NOTIFY_DISABLE       Set to 1 to skip recording and sending.
EOF
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --event)
      [ "$#" -ge 2 ] || {
        echo "supervisor-notify: missing value for --event" >&2
        exit 2
      }
      EVENT="$2"
      shift 2
      ;;
    --status|--state)
      [ "$#" -ge 2 ] || {
        echo "supervisor-notify: missing value for $1" >&2
        exit 2
      }
      STATE="$2"
      shift 2
      ;;
    --reason)
      [ "$#" -ge 2 ] || {
        echo "supervisor-notify: missing value for --reason" >&2
        exit 2
      }
      REASON="$2"
      shift 2
      ;;
    --body|--detail)
      [ "$#" -ge 2 ] || {
        echo "supervisor-notify: missing value for $1" >&2
        exit 2
      }
      BODY="$2"
      shift 2
      ;;
    --branch)
      [ "$#" -ge 2 ] || {
        echo "supervisor-notify: missing value for --branch" >&2
        exit 2
      }
      BRANCH="$2"
      shift 2
      ;;
    -h|--help|help)
      usage
      exit 0
      ;;
    *)
      echo "supervisor-notify: unknown argument: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

if [ "${SELF_HARNESS_NOTIFY_DISABLE:-0}" = "1" ]; then
  echo "supervisor-notify: disabled"
  exit 0
fi

[ -n "$EVENT" ] || {
  echo "supervisor-notify: --event is required" >&2
  exit 2
}
[ -n "$STATE" ] || {
  echo "supervisor-notify: --status is required" >&2
  exit 2
}
[ -n "$REASON" ] || {
  echo "supervisor-notify: --reason is required" >&2
  exit 2
}

timestamp() {
  date -u +"%Y-%m-%dT%H:%M:%SZ"
}

current_branch() {
  git -C "$ROOT_DIR" branch --show-current 2>/dev/null || true
}

single_line() {
  tr '\n\t' '  ' | sed -E 's/[[:space:]]+/ /g; s/^[[:space:]]+//; s/[[:space:]]+$//'
}

signature_line() {
  if [ -n "${SELF_HARNESS_NOTIFY_SIGNATURE:-}" ]; then
    printf '%s\n' "$SELF_HARNESS_NOTIFY_SIGNATURE"
    return 0
  fi

  case "$BRANCH" in
    agent/no0_self_imporve)
      printf '%s\n' "--- supervisor for @no.0|${BRANCH}"
      ;;
    *)
      printf '%s\n' "--- supervisor"
      ;;
  esac
}

if [ -z "$BRANCH" ]; then
  BRANCH="$(current_branch)"
fi
[ -n "$BRANCH" ] || BRANCH="unknown"

TS="$(timestamp)"
SIGNATURE="$(signature_line)"

mkdir -p "$RUN_DIR"
{
  printf '%s\t' "$TS"
  printf 'event=%s\t' "$(printf '%s' "$EVENT" | single_line)"
  printf 'status=%s\t' "$(printf '%s' "$STATE" | single_line)"
  printf 'branch=%s\t' "$(printf '%s' "$BRANCH" | single_line)"
  printf 'reason=%s\n' "$(printf '%s' "$REASON" | single_line)"
} >>"$STATUS_LOG"

message="$(
  cat <<EOF
Self-harness supervisor status
Event: ${EVENT}
Status: ${STATE}
Branch: ${BRANCH}
Reason: ${REASON}
EOF
)"

if [ -n "$BODY" ]; then
  message="$(
    cat <<EOF
${message}
Detail: ${BODY}
EOF
  )"
fi

message="$(
  cat <<EOF
${message}
Time: ${TS}
${SIGNATURE}
EOF
)"

chat_id="${SELF_HARNESS_NOTIFY_CHAT_ID:-}"
user_id="${SELF_HARNESS_NOTIFY_USER_ID:-}"

if [ -z "$chat_id" ] && [ -z "$user_id" ]; then
  echo "supervisor-notify: recorded ${EVENT}; lark send skipped: not configured"
  exit 0
fi

if [ -n "$chat_id" ] && [ -n "$user_id" ]; then
  echo "supervisor-notify: configure only one of SELF_HARNESS_NOTIFY_CHAT_ID or SELF_HARNESS_NOTIFY_USER_ID" >&2
  exit 2
fi

lark_bin="${SELF_HARNESS_NOTIFY_LARK_BIN:-lark-cli}"
if ! command -v "$lark_bin" >/dev/null 2>&1; then
  echo "supervisor-notify: ${lark_bin} not found; status was recorded but not sent" >&2
  exit 1
fi

identity="${SELF_HARNESS_NOTIFY_AS:-bot}"
idempotency_key="self-harness-${EVENT}-${TS}"
idempotency_key="$(printf '%s' "$idempotency_key" | tr -c 'A-Za-z0-9_.:-' '-')"

cmd=("$lark_bin" im +messages-send --as "$identity")
if [ -n "$chat_id" ]; then
  cmd+=(--chat-id "$chat_id")
else
  cmd+=(--user-id "$user_id")
fi
cmd+=(--text "$message" --idempotency-key "$idempotency_key")

if [ "${SELF_HARNESS_NOTIFY_DRY_RUN:-0}" = "1" ]; then
  cmd+=(--dry-run)
fi

"${cmd[@]}"
echo "supervisor-notify: recorded and sent ${EVENT}"
