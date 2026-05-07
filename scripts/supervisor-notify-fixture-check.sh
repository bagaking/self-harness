#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
WORK_DIR="${ROOT_DIR}/.self-harness/tmp/supervisor-notify-fixture-check"

fail() {
  echo "supervisor-notify-fixture-check: $*" >&2
  exit 1
}

log() {
  echo "supervisor-notify-fixture-check: $*"
}

clear_notification_env() {
  unset SELF_HARNESS_NOTIFY_CHAT_ID
  unset SELF_HARNESS_NOTIFY_USER_ID
  unset SELF_HARNESS_NOTIFY_LARK_BIN
  unset SELF_HARNESS_NOTIFY_AS
  unset SELF_HARNESS_NOTIFY_DRY_RUN
}

write_fake_lark_cli() {
  local dir="$1"
  mkdir -p "$dir"
  cat >"${dir}/lark-cli" <<'EOF'
#!/usr/bin/env bash
{
  printf 'argc=%s\n' "$#"
  i=0
  for arg in "$@"; do
    i=$((i + 1))
    printf 'arg_%02d=%s\n' "$i" "$arg"
  done
} >>"${SELF_HARNESS_FAKE_LARK_LOG:?}"
exit "${SELF_HARNESS_FAKE_LARK_STATUS:-0}"
EOF
  chmod +x "${dir}/lark-cli"
}

run_positive_fake_send() {
  local sandbox fake_bin fake_log output status_log
  sandbox="${WORK_DIR}/positive"
  fake_bin="${sandbox}/bin"
  fake_log="${sandbox}/fake-lark.log"
  output="${sandbox}/notify.out"
  status_log="${sandbox}/.self-harness/run/supervisor-status.log"

  rm -rf "$sandbox"
  mkdir -p "$fake_bin"
  write_fake_lark_cli "$fake_bin"

  (
    cd "$sandbox"
    git init -q
    git checkout -b agent/no0_self_imporve >/dev/null 2>&1
    clear_notification_env
    env \
      PATH="${fake_bin}:${PATH}" \
      SELF_HARNESS_SUPERVISOR_ROOT="$sandbox" \
      SELF_HARNESS_FAKE_LARK_LOG="$fake_log" \
      SELF_HARNESS_NOTIFY_CHAT_ID="fixture-chat-id" \
      bash "${ROOT_DIR}/scripts/supervisor-notify.sh" \
        --event start \
        --status running \
        --reason "fixture start" \
        --body "proof body"
  ) >"$output"

  [ -f "$fake_log" ] || fail "positive fake send did not invoke lark-cli"
  LC_ALL=C rg -q 'arg_01=im' "$fake_log" || fail "fake lark command did not use im"
  LC_ALL=C rg -q 'arg_02=\+messages-send' "$fake_log" || fail "fake lark command did not use +messages-send"
  LC_ALL=C rg -q 'arg_[0-9]+=--chat-id' "$fake_log" || fail "fake lark command did not include --chat-id"
  LC_ALL=C rg -q 'arg_[0-9]+=fixture-chat-id' "$fake_log" || fail "fake lark command did not include fixture chat id"
  LC_ALL=C rg -q -- '--- supervisor for @no\.0\|agent/no0_self_imporve' "$fake_log" || fail "fake lark message missed no0 supervisor signature"
  LC_ALL=C rg -q 'Event: start' "$fake_log" || fail "fake lark message missed event"
  LC_ALL=C rg -q 'Status: running' "$fake_log" || fail "fake lark message missed status"
  [ -f "$status_log" ] || fail "positive fake send did not write local status log"
  LC_ALL=C rg -q 'event=start' "$status_log" || fail "status log missed start event"
  LC_ALL=C rg -q 'status=running' "$status_log" || fail "status log missed running state"
  log "positive fake send recorded and invoked fake lark-cli"
}

run_not_configured_case() {
  local sandbox fake_bin fake_log output status_log
  sandbox="${WORK_DIR}/not-configured"
  fake_bin="${sandbox}/bin"
  fake_log="${sandbox}/fake-lark.log"
  output="${sandbox}/notify.out"
  status_log="${sandbox}/.self-harness/run/supervisor-status.log"

  rm -rf "$sandbox"
  mkdir -p "$fake_bin"
  write_fake_lark_cli "$fake_bin"

  (
    cd "$sandbox"
    git init -q
    git checkout -b agent/no0_self_imporve >/dev/null 2>&1
    clear_notification_env
    env \
      PATH="${fake_bin}:${PATH}" \
      SELF_HARNESS_SUPERVISOR_ROOT="$sandbox" \
      SELF_HARNESS_FAKE_LARK_LOG="$fake_log" \
      bash "${ROOT_DIR}/scripts/supervisor-notify.sh" \
        --event stop \
        --status stopped \
        --reason "not configured proof"
  ) >"$output"

  [ ! -f "$fake_log" ] || fail "not-configured case unexpectedly invoked lark-cli"
  [ -f "$status_log" ] || fail "not-configured case did not write local status log"
  LC_ALL=C rg -q 'event=stop' "$status_log" || fail "status log missed stop event"
  LC_ALL=C rg -q 'status=stopped' "$status_log" || fail "status log missed stopped state"
  LC_ALL=C rg -q 'lark send skipped: not configured' "$output" || fail "not-configured output did not explain skipped send"
  log "not-configured case recorded status without invoking fake lark-cli"
}

run_missing_lark_case() {
  local sandbox output status=0
  sandbox="${WORK_DIR}/missing-lark"
  output="${sandbox}/notify.out"

  rm -rf "$sandbox"
  mkdir -p "$sandbox"

  set +e
  (
    cd "$sandbox"
    git init -q
    git checkout -b agent/no0_self_imporve >/dev/null 2>&1
    clear_notification_env
    env \
      SELF_HARNESS_SUPERVISOR_ROOT="$sandbox" \
      SELF_HARNESS_NOTIFY_LARK_BIN="definitely-missing-lark-cli" \
      SELF_HARNESS_NOTIFY_CHAT_ID="fixture-chat-id" \
      bash "${ROOT_DIR}/scripts/supervisor-notify.sh" \
        --event failure \
        --status failed \
        --reason "missing lark proof"
  ) >"$output" 2>&1
  status=$?
  set -e

  [ "$status" -eq 1 ] || fail "missing-lark case expected status 1, got ${status}"
  LC_ALL=C rg -q 'not found; status was recorded but not sent' "$output" || fail "missing-lark case did not explain missing lark-cli"
  log "missing lark-cli case fails after local record"
}

main() {
  rm -rf "$WORK_DIR"
  mkdir -p "$WORK_DIR"
  run_positive_fake_send
  run_not_configured_case
  run_missing_lark_case
  log "ok"
}

main "$@"
