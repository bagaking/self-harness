#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

PRIVATE_DIR="${ROOT_DIR}/.self-harness"
RUN_DIR="${PRIVATE_DIR}/run"
LOG_DIR="${PRIVATE_DIR}/logs"
TMP_DIR="${PRIVATE_DIR}/tmp"
LOCK_DIR="${RUN_DIR}/supervisor.lock"
LOCK_INFO="${LOCK_DIR}/info"
PID_FILE="${RUN_DIR}/supervisor.pid"
LOOP_LOG="${LOG_DIR}/supervisor.log"

CODEX_HOME_DIR="${ROOT_DIR}/.codex"
SESSIONS_DIR="${ROOT_DIR}/sessions"

DEFAULT_INTERVAL_SECONDS=300
DEFAULT_RESUME_MAX_AGE_SECONDS=21600
DEFAULT_RESUME_MAX_BYTES=600000

INTERVAL_SECONDS="${SELF_HARNESS_INTERVAL_SECONDS:-$DEFAULT_INTERVAL_SECONDS}"
RESUME_MAX_AGE_SECONDS="${SELF_HARNESS_RESUME_MAX_AGE_SECONDS:-$DEFAULT_RESUME_MAX_AGE_SECONDS}"
RESUME_MAX_BYTES="${SELF_HARNESS_RESUME_MAX_BYTES:-$DEFAULT_RESUME_MAX_BYTES}"

usage() {
  cat <<'EOF'
Usage:
  scripts/supervisor.sh plan
  scripts/supervisor.sh once
  scripts/supervisor.sh loop
  scripts/supervisor.sh start
  scripts/supervisor.sh stop
  scripts/supervisor.sh status

Environment:
  SELF_HARNESS_INTERVAL_SECONDS       Loop sleep interval. Default: 300.
  SELF_HARNESS_RESUME_MAX_AGE_SECONDS Latest-session age limit. Default: 21600.
  SELF_HARNESS_RESUME_MAX_BYTES       Latest-session size limit. Default: 600000.
  SELF_HARNESS_CODEX_ARGS             Extra args passed to codex exec/resume.
EOF
}

timestamp() {
  date -u +"%Y-%m-%dT%H:%M:%SZ"
}

log() {
  printf '[%s] %s\n' "$(timestamp)" "$*"
}

init_layout() {
  "${ROOT_DIR}/scripts/init.sh" >/dev/null
  mkdir -p "$RUN_DIR" "$LOG_DIR" "$TMP_DIR"
}

is_pid_alive() {
  local pid="$1"
  [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null
}

active_lock_pid() {
  [ -f "$LOCK_INFO" ] || return 1
  awk -F: '/^pid:/ { gsub(/^[[:space:]]+/, "", $2); print $2; exit }' "$LOCK_INFO"
}

acquire_lock() {
  if mkdir "$LOCK_DIR" 2>/dev/null; then
    return 0
  fi

  local pid
  pid="$(active_lock_pid || true)"
  if is_pid_alive "$pid"; then
    log "another self-harness run is active: pid=${pid}"
    return 1
  fi

  log "recovering stale supervisor lock"
  rm -rf "$LOCK_DIR"
  mkdir "$LOCK_DIR"
}

release_lock() {
  rm -rf "$LOCK_DIR"
}

write_lock_info() {
  local mode="$1"
  local command="$2"
  local pid="$3"
  cat >"$LOCK_INFO" <<EOF
pid: ${pid}
command: ${command}
mode: ${mode}
started_at: $(timestamp)
heartbeat_at: $(timestamp)
repo: ${ROOT_DIR}
codex_home: ${CODEX_HOME_DIR}
EOF
}

latest_session_file() {
  find "$SESSIONS_DIR" -type f \( -name '*.jsonl' -o -name '*.jsonl.*' \) 2>/dev/null \
    | sort \
    | tail -1
}

file_mtime_epoch() {
  local file="$1"
  if stat -f %m "$file" >/dev/null 2>&1; then
    stat -f %m "$file"
  else
    stat -c %Y "$file"
  fi
}

file_size_bytes() {
  local file="$1"
  if stat -f %z "$file" >/dev/null 2>&1; then
    stat -f %z "$file"
  else
    stat -c %s "$file"
  fi
}

choose_mode() {
  local latest
  latest="$(latest_session_file || true)"
  if [ -z "$latest" ]; then
    echo "new no-session"
    return 0
  fi

  local now mtime age size
  now="$(date +%s)"
  mtime="$(file_mtime_epoch "$latest")"
  age=$((now - mtime))
  size="$(file_size_bytes "$latest")"

  if [ "$age" -le "$RESUME_MAX_AGE_SECONDS" ] && [ "$size" -le "$RESUME_MAX_BYTES" ]; then
    echo "resume age=${age}s size=${size} latest=${latest#${ROOT_DIR}/}"
  else
    echo "new age=${age}s size=${size} latest=${latest#${ROOT_DIR}/}"
  fi
}

build_boot_prompt() {
  local mode="$1"
  cat <<EOF
You are running inside the self-harness repository at ${ROOT_DIR}.

Mode: ${mode}

Read AGENTS.md first. Then use scripts/query-docs.sh to discover and read relevant constitution documents. Do not modify constitution/.

This repository is the agent itself. sessions/, mailbox/, memory/, and skills/ are commit-worthy agent state. Temporary or private work belongs only under .self-harness/.

Primary task for this run:
- Inspect repository state.
- Read pending mailbox/inbox messages and produce durable replies or reports under mailbox/outbox.
- Update memory/ when useful.
- Improve skills/ only when a reusable procedure is discovered.
- Run scripts/docs-check.sh before any autonomous commit.
- If this is a new session, review the repository and write a GFM diary under memory/diary suitable for use as the commit message.
- Commit only when the commit gates in constitution/30-mailbox-and-commit.md are satisfied.
EOF
}

run_codex_once() {
  init_layout
  acquire_lock || return 0
  trap release_lock EXIT

  local choice mode detail prompt output command
  choice="$(choose_mode)"
  mode="${choice%% *}"
  detail="${choice#${mode}}"
  output="${TMP_DIR}/codex-last-message-$(date -u +%Y%m%dT%H%M%SZ).md"
  prompt="$(build_boot_prompt "$mode")"

  log "choice: ${mode}${detail}"

  local extra_args=()
  if [ -n "${SELF_HARNESS_CODEX_ARGS:-}" ]; then
    # shellcheck disable=SC2206
    extra_args=(${SELF_HARNESS_CODEX_ARGS})
  fi

  export CODEX_HOME="$CODEX_HOME_DIR"

  local status=0
  set +e
  if [ "$mode" = "resume" ]; then
    command="codex exec resume --last --all --output-last-message ${output} -"
    write_lock_info "$mode" "$command" "$$"
    printf '%s\n' "$prompt" | codex exec resume --last --all --output-last-message "$output" "${extra_args[@]}" -
    status=$?
  else
    command="codex exec --cd ${ROOT_DIR} --output-last-message ${output} -"
    write_lock_info "$mode" "$command" "$$"
    printf '%s\n' "$prompt" | codex exec --cd "$ROOT_DIR" --output-last-message "$output" "${extra_args[@]}" -
    status=$?
  fi
  set -e

  release_lock
  trap - EXIT
  return "$status"
}

run_loop() {
  init_layout
  while true; do
    local status=0
    run_codex_once || status=$?
    if [ "$status" -ne 0 ]; then
      log "run failed with status ${status}"
    fi
    sleep "$INTERVAL_SECONDS"
  done
}

start_background() {
  init_layout
  if [ -f "$PID_FILE" ] && is_pid_alive "$(cat "$PID_FILE")"; then
    echo "supervisor already running: pid=$(cat "$PID_FILE")"
    return 0
  fi
  nohup "$0" loop >>"$LOOP_LOG" 2>&1 &
  echo "$!" >"$PID_FILE"
  echo "started supervisor: pid=$!"
  echo "log: $LOOP_LOG"
}

stop_background() {
  if [ ! -f "$PID_FILE" ]; then
    echo "supervisor is not running"
    return 0
  fi
  local pid
  pid="$(cat "$PID_FILE")"
  if is_pid_alive "$pid"; then
    kill "$pid"
    echo "stopped supervisor: pid=$pid"
  else
    echo "removing stale pidfile: pid=$pid"
  fi
  rm -f "$PID_FILE"
}

status() {
  init_layout
  if [ -f "$PID_FILE" ] && is_pid_alive "$(cat "$PID_FILE")"; then
    echo "supervisor: running pid=$(cat "$PID_FILE")"
  else
    echo "supervisor: stopped"
  fi

  if [ -f "$LOCK_INFO" ]; then
    echo
    echo "active lock:"
    sed 's/^/  /' "$LOCK_INFO"
  fi

  echo
  echo "next choice: $(choose_mode)"
}

case "${1:-}" in
  plan)
    init_layout
    choose_mode
    ;;
  once)
    run_codex_once
    ;;
  loop)
    run_loop
    ;;
  start)
    start_background
    ;;
  stop)
    stop_background
    ;;
  status)
    status
    ;;
  -h|--help|help|"")
    usage
    ;;
  *)
    echo "Unknown command: $1" >&2
    usage >&2
    exit 2
    ;;
esac
