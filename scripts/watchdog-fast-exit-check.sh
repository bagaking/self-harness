#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
WORK_DIR="${ROOT_DIR}/.self-harness/tmp/watchdog-fast-exit-check"

fail() {
  echo "watchdog-fast-exit-check: $*" >&2
  exit 1
}

log() {
  echo "watchdog-fast-exit-check: $*"
}

extract_function() {
  local name="$1"
  awk -v name="$name" '
    $0 == name "() {" {
      in_function = 1
    }
    in_function {
      print
      if ($0 == "}") {
        exit
      }
    }
  ' "${ROOT_DIR}/scripts/supervisor.sh"
}

write_fake_ps() {
  local dir="$1"
  mkdir -p "$dir"
  {
    printf '%s\n' '#!/usr/bin/env bash'
    printf '%s\n' 'if [ "${1:-}" = "-o" ] && [ "${2:-}" = "stat=" ] && [ "${3:-}" = "-p" ]; then'
    printf '%s\n' '  printf "%s\n" "${SELF_HARNESS_FAKE_PS_STAT:-S}"'
    printf '%s\n' '  exit 0'
    printf '%s\n' 'fi'
    printf '%s\n' 'echo "fake ps only supports: ps -o stat= -p <pid>" >&2'
    printf '%s\n' 'exit 2'
  } >"${dir}/ps"
  chmod +x "${dir}/ps"
}

check_pid_state_classification() {
  local fake_bin function_text
  fake_bin="${WORK_DIR}/unit-bin"
  rm -rf "$fake_bin"
  write_fake_ps "$fake_bin"

  function_text="$(extract_function is_pid_alive)"
  [ -n "$function_text" ] || fail "could not extract is_pid_alive from scripts/supervisor.sh"
  eval "$function_text"

  if ! PATH="${fake_bin}:${PATH}" SELF_HARNESS_FAKE_PS_STAT="S" is_pid_alive "$$"; then
    fail "is_pid_alive rejected a running pid with non-zombie ps state"
  fi

  if PATH="${fake_bin}:${PATH}" SELF_HARNESS_FAKE_PS_STAT="Z" is_pid_alive "$$"; then
    fail "is_pid_alive treated a zombie ps state as alive"
  fi

  log "pid state classification distinguishes live from zombie"
}

write_fake_codex() {
  local dir="$1"
  mkdir -p "$dir"
  {
    printf '%s\n' '#!/usr/bin/env bash'
    printf '%s\n' 'output=""'
    printf '%s\n' 'while [ "$#" -gt 0 ]; do'
    printf '%s\n' '  case "$1" in'
    printf '%s\n' '    --output-last-message)'
    printf '%s\n' '      shift'
    printf '%s\n' '      output="${1:-}"'
    printf '%s\n' '      ;;'
    printf '%s\n' '  esac'
    printf '%s\n' '  shift || break'
    printf '%s\n' 'done'
    printf '%s\n' 'if [ -n "$output" ]; then'
    printf '%s\n' '  mkdir -p "$(dirname "$output")"'
    printf '%s\n' '  printf "fake codex started\n" >"$output"'
    printf '%s\n' 'fi'
    printf '%s\n' 'case "${SELF_HARNESS_FAKE_CODEX_MODE:-exit}" in'
    printf '%s\n' '  exit)'
    printf '%s\n' '    exit "${SELF_HARNESS_FAKE_CODEX_STATUS:-0}"'
    printf '%s\n' '    ;;'
    printf '%s\n' '  sleep)'
    printf '%s\n' '    sleep "${SELF_HARNESS_FAKE_CODEX_SLEEP_SECONDS:-5}"'
    printf '%s\n' '    exit 0'
    printf '%s\n' '    ;;'
    printf '%s\n' '  *)'
    printf '%s\n' '    echo "unknown fake codex mode: ${SELF_HARNESS_FAKE_CODEX_MODE}" >&2'
    printf '%s\n' '    exit 2'
    printf '%s\n' '    ;;'
    printf '%s\n' 'esac'
  } >"${dir}/codex"
  chmod +x "${dir}/codex"
}

prepare_sandbox() {
  local sandbox="$1"
  rm -rf "$sandbox"
  mkdir -p \
    "${sandbox}/scripts" \
    "${sandbox}/mailbox/inbox" \
    "${sandbox}/bin"

  cp "${ROOT_DIR}/scripts/supervisor.sh" "${sandbox}/scripts/supervisor.sh"
  cp "${ROOT_DIR}/scripts/init.sh" "${sandbox}/scripts/init.sh"
  write_fake_codex "${sandbox}/bin"
  printf '%s\n' 'pending watchdog proof' >"${sandbox}/mailbox/inbox/pending-watchdog-proof.md"
  git -C "$sandbox" init -q
}

run_supervisor_case() {
  local name="$1"
  local expected_status="$2"
  local fake_mode="$3"
  local fake_status="$4"
  local sandbox log_file status

  sandbox="${WORK_DIR}/${name}"
  log_file="${WORK_DIR}/${name}.log"
  prepare_sandbox "$sandbox"

  set +e
  (
    cd "$sandbox"
    env \
      PATH="${sandbox}/bin:${PATH}" \
      SELF_HARNESS_AUTO_CHALLENGE=0 \
      SELF_HARNESS_SKIP_COMMIT=1 \
      SELF_HARNESS_CODEX_MAX_RUNTIME_SECONDS=0 \
      SELF_HARNESS_CODEX_IDLE_TIMEOUT_SECONDS=1 \
      SELF_HARNESS_CODEX_WATCHDOG_POLL_SECONDS=1 \
      SELF_HARNESS_FAKE_CODEX_MODE="$fake_mode" \
      SELF_HARNESS_FAKE_CODEX_STATUS="$fake_status" \
      SELF_HARNESS_FAKE_CODEX_SLEEP_SECONDS=5 \
      scripts/supervisor.sh once
  ) >"$log_file" 2>&1
  status=$?
  set -e

  if [ "$status" -ne "$expected_status" ]; then
    sed -n '1,120p' "$log_file" >&2
    fail "${name}: expected status ${expected_status}, got ${status}"
  fi

  case "$name" in
    fast-exit-*)
      if rg -q 'idle timeout exceeded' "$log_file"; then
        sed -n '1,120p' "$log_file" >&2
        fail "${name}: fast-exit child was reported as an idle timeout"
      fi
      ;;
    live-idle-timeout)
      if ! rg -q 'idle timeout exceeded' "$log_file"; then
        sed -n '1,120p' "$log_file" >&2
        fail "${name}: live silent child did not trigger idle-timeout protection"
      fi
      ;;
  esac

  log "${name} returned status ${status}"
}

main() {
  mkdir -p "$WORK_DIR"
  check_pid_state_classification
  run_supervisor_case fast-exit-zero 0 exit 0
  run_supervisor_case fast-exit-nonzero 42 exit 42
  run_supervisor_case live-idle-timeout 124 sleep 0
  log "ok"
}

main "$@"
