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
GATE_REPORT="${TMP_DIR}/commit-gate-last-report.md"

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
  scripts/supervisor.sh commit [--allow-constitution] [-m MESSAGE | -F FILE] [-- PATH...]
  scripts/supervisor.sh start
  scripts/supervisor.sh stop
  scripts/supervisor.sh status

Environment:
  SELF_HARNESS_INTERVAL_SECONDS       Loop sleep interval. Default: 300.
  SELF_HARNESS_RESUME_MAX_AGE_SECONDS Latest-session age limit. Default: 21600.
  SELF_HARNESS_RESUME_MAX_BYTES       Latest-session size limit. Default: 600000.
  SELF_HARNESS_CODEX_ARGS             Extra args passed to codex exec/resume.
  SELF_HARNESS_SKIP_COMMIT            Set to 1 to skip post-run commits.
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
You are running inside the self-harness repository.

Mode: ${mode}

Read AGENTS.md first. Then use scripts/query-docs.sh to discover and read relevant constitution documents. Do not modify constitution/.

This repository is the agent itself. sessions/, mailbox/, memory/, and skills/ are commit-worthy agent state. Temporary or private work belongs only under .self-harness/.

Keep committed content portable: use repository-relative paths, do not modify files outside this repository, and do not expose local usernames, hostnames, home directories, or machine-specific absolute paths. Use .self-harness/tmp/ for experiments, reference clones, temporary projects, and subagent experiment sandboxes.

Primary task for this run:
- Inspect repository state.
- Read pending mailbox/inbox messages and produce durable replies or reports under mailbox/outbox.
- Update memory/ when useful.
- Improve skills/ only when a reusable procedure is discovered.
- Run scripts/docs-check.sh before finishing.
- If this is a new session, review the repository and write a GFM diary under memory/diary suitable for use as the commit message.
- Do not run git add or git commit yourself. The supervisor owns staging and committing after this Codex process exits.
EOF
}

latest_diary_file() {
  find "${ROOT_DIR}/memory/diary" -type f -name '*.md' 2>/dev/null \
    | sort \
    | tail -1
}

has_git_changes() {
  [ -n "$(git -C "$ROOT_DIR" status --porcelain --untracked-files=all)" ]
}

staged_or_changed_files() {
  {
    git -C "$ROOT_DIR" diff --name-only
    git -C "$ROOT_DIR" diff --cached --name-only
    git -C "$ROOT_DIR" ls-files --others --exclude-standard
  } | awk 'NF' | sort -u
}

is_portability_checked_path() {
  local rel="$1"
  case "$rel" in
    AGENTS.md|constitution/*.md|memory/*.md|memory/**/*.md|mailbox/*.md|mailbox/**/*.md|scripts/*.sh)
      return 0
      ;;
    skills/.system/*|sessions/*)
      return 1
      ;;
    skills/*.md|skills/**/*.md)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

check_portable_content() {
  local errors=0
  local file rel

  while IFS= read -r rel; do
    [ -n "$rel" ] || continue
    file="${ROOT_DIR}/${rel}"
    [ -f "$file" ] || continue
    is_portability_checked_path "$rel" || continue

    if LC_ALL=C rg -n --color never '(^|[^[:alnum:]_.-])(/Users|/home)/[^[:space:]`'"'"'"]+' "$file"; then
      errors=$((errors + 1))
    fi

    if LC_ALL=C rg -n --color never '(^|[^[:alnum:]_.-])(/private/tmp|/var/folders)/[^[:space:]`'"'"'"]+' "$file"; then
      errors=$((errors + 1))
    fi

    if LC_ALL=C rg -n --color never '(HOSTNAME|USER|USERNAME|LOGNAME|HOME)=[^[:space:]`'"'"'"]+' "$file"; then
      errors=$((errors + 1))
    fi

    if LC_ALL=C rg -n --color never '~/(Desktop|Documents|Downloads|Library|Movies|Music|Pictures|proj|Projects|workspace|work)/[^[:space:]`'"'"'"]*' "$file"; then
      errors=$((errors + 1))
    fi

  done < <(staged_or_changed_files)

  if [ "$errors" -gt 0 ]; then
    echo "commit gate failed: portable content check found local paths, device details, or outside-repo write instructions" >&2
    return 1
  fi
}

run_commit_gate() {
  local allow_constitution="${1:-0}"
  init_layout

  if [ "$allow_constitution" != "1" ] && ! git -C "$ROOT_DIR" diff --quiet -- constitution/; then
    echo "commit gate failed: constitution/ has unstaged changes" >&2
    return 1
  fi

  if find "${ROOT_DIR}/mailbox/processing" -maxdepth 1 -type f ! -name .gitkeep | rg -q .; then
    echo "commit gate failed: mailbox/processing contains unfinished files" >&2
    return 1
  fi

  if find "${ROOT_DIR}/mailbox" -type f \( -name '*.tmp' -o -name '*~' -o -name '.#*' -o -name 'outbox-*' \) | rg -q .; then
    echo "commit gate failed: mailbox contains temporary output files" >&2
    return 1
  fi

  check_portable_content

  "${ROOT_DIR}/scripts/docs-check.sh"

  local script
  for script in "${ROOT_DIR}"/scripts/*.sh; do
    [ -f "$script" ] || continue
    bash -n "$script"
  done
}

commit_changes() {
  local message=""
  local message_file=""
  local allow_constitution=0
  local paths=()

  while [ "$#" -gt 0 ]; do
    case "$1" in
      --allow-constitution)
        allow_constitution=1
        shift
        ;;
      -m|--message)
        [ "$#" -ge 2 ] || {
          echo "commit: missing message after $1" >&2
          return 2
        }
        message="$2"
        shift 2
        ;;
      -F|--message-file)
        [ "$#" -ge 2 ] || {
          echo "commit: missing file after $1" >&2
          return 2
        }
        message_file="$2"
        shift 2
        ;;
      --)
        shift
        while [ "$#" -gt 0 ]; do
          paths+=("$1")
          shift
        done
        ;;
      *)
        paths+=("$1")
        shift
        ;;
    esac
  done

  run_commit_gate "$allow_constitution"

  if ! has_git_changes; then
    log "commit: no changes"
    return 0
  fi

  if [ "${#paths[@]}" -gt 0 ]; then
    git -C "$ROOT_DIR" add -- "${paths[@]}"
  else
    git -C "$ROOT_DIR" add --all -- .
  fi

  if git -C "$ROOT_DIR" diff --cached --quiet; then
    log "commit: no staged changes"
    return 0
  fi

  if [ -n "$message_file" ]; then
    git -C "$ROOT_DIR" commit -F "$message_file"
  elif [ -n "$message" ]; then
    git -C "$ROOT_DIR" commit -m "$message"
  else
    message_file="$(latest_diary_file || true)"
    if [ -n "$message_file" ]; then
      git -C "$ROOT_DIR" commit -F "$message_file"
    else
      git -C "$ROOT_DIR" commit -m "run: record self-harness state"
    fi
  fi
}

build_gate_repair_prompt() {
  local report="$1"
  cat <<EOF
The supervisor commit gate failed after your previous run.

Read AGENTS.md and the relevant constitution files, then fix only the reported issues. Keep the repair small.

Rules to preserve:
- Use repository-relative paths in committed content.
- Do not modify files outside this repository.
- Do not expose local usernames, hostnames, home directories, or machine-specific absolute paths.
- Do not modify constitution/.
- Use .self-harness/tmp/ for experiments and temporary files.
- Run scripts/docs-check.sh before finishing.
- Do not run git add or git commit; the supervisor will commit after you exit.

Gate report:

$(sed 's/^/> /' "$report")
EOF
}

ask_session_to_repair_gate_once() {
  local report="$1"
  init_layout
  acquire_lock || return 1
  trap release_lock EXIT

  local output command prompt
  output="${TMP_DIR}/codex-gate-repair-$(date -u +%Y%m%dT%H%M%SZ).md"
  prompt="$(build_gate_repair_prompt "$report")"
  command="codex exec resume --last --all --output-last-message ${output} -"
  write_lock_info "repair" "$command" "$$"

  local extra_args=()
  if [ -n "${SELF_HARNESS_CODEX_ARGS:-}" ]; then
    # shellcheck disable=SC2206
    extra_args=(${SELF_HARNESS_CODEX_ARGS})
  fi

  export CODEX_HOME="$CODEX_HOME_DIR"

  local status=0
  set +e
  if [ "${#extra_args[@]}" -gt 0 ]; then
    printf '%s\n' "$prompt" | codex exec resume --last --all --output-last-message "$output" "${extra_args[@]}" -
  else
    printf '%s\n' "$prompt" | codex exec resume --last --all --output-last-message "$output" -
  fi
  status=$?
  set -e

  release_lock
  trap - EXIT
  return "$status"
}

commit_changes_with_repair() {
  local status=0
  commit_changes "$@" >"$GATE_REPORT" 2>&1 || status=$?
  if [ "$status" -eq 0 ]; then
    cat "$GATE_REPORT"
    return 0
  fi

  log "post-run commit gate failed; asking Codex session for one repair attempt"
  cat "$GATE_REPORT" >&2

  if ! ask_session_to_repair_gate_once "$GATE_REPORT"; then
    log "gate repair run failed"
    return "$status"
  fi

  commit_changes "$@"
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
    if [ "${#extra_args[@]}" -gt 0 ]; then
      printf '%s\n' "$prompt" | codex exec resume --last --all --output-last-message "$output" "${extra_args[@]}" -
    else
      printf '%s\n' "$prompt" | codex exec resume --last --all --output-last-message "$output" -
    fi
    status=$?
  else
    command="codex exec --cd ${ROOT_DIR} --output-last-message ${output} -"
    write_lock_info "$mode" "$command" "$$"
    if [ "${#extra_args[@]}" -gt 0 ]; then
      printf '%s\n' "$prompt" | codex exec --cd "$ROOT_DIR" --output-last-message "$output" "${extra_args[@]}" -
    else
      printf '%s\n' "$prompt" | codex exec --cd "$ROOT_DIR" --output-last-message "$output" -
    fi
    status=$?
  fi
  set -e

  release_lock
  trap - EXIT

  if [ "${SELF_HARNESS_SKIP_COMMIT:-0}" != "1" ]; then
    if ! commit_changes_with_repair; then
      log "post-run commit failed"
      return 1
    fi
  fi

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
  commit)
    shift
    commit_changes "$@"
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
