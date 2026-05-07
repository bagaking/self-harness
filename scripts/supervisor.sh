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
LAUNCHD_LABEL="com.bagaking.self-harness.supervisor"
LAUNCHD_PLIST="${RUN_DIR}/${LAUNCHD_LABEL}.plist"

CODEX_HOME_DIR="${ROOT_DIR}/.codex"
SESSIONS_DIR="${ROOT_DIR}/sessions"

DEFAULT_INTERVAL_SECONDS=300
DEFAULT_RESUME_MAX_AGE_SECONDS=21600
DEFAULT_RESUME_MAX_BYTES=600000
DEFAULT_CODEX_MAX_RUNTIME_SECONDS=1800
DEFAULT_CODEX_IDLE_TIMEOUT_SECONDS=300
DEFAULT_AUTO_CHALLENGE=1

INTERVAL_SECONDS="${SELF_HARNESS_INTERVAL_SECONDS:-$DEFAULT_INTERVAL_SECONDS}"
RESUME_MAX_AGE_SECONDS="${SELF_HARNESS_RESUME_MAX_AGE_SECONDS:-$DEFAULT_RESUME_MAX_AGE_SECONDS}"
RESUME_MAX_BYTES="${SELF_HARNESS_RESUME_MAX_BYTES:-$DEFAULT_RESUME_MAX_BYTES}"
CODEX_MAX_RUNTIME_SECONDS="${SELF_HARNESS_CODEX_MAX_RUNTIME_SECONDS:-$DEFAULT_CODEX_MAX_RUNTIME_SECONDS}"
CODEX_IDLE_TIMEOUT_SECONDS="${SELF_HARNESS_CODEX_IDLE_TIMEOUT_SECONDS:-$DEFAULT_CODEX_IDLE_TIMEOUT_SECONDS}"
AUTO_CHALLENGE="${SELF_HARNESS_AUTO_CHALLENGE:-$DEFAULT_AUTO_CHALLENGE}"

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
  SELF_HARNESS_CODEX_MAX_RUNTIME_SECONDS Max seconds for one Codex child. Default: 1800.
  SELF_HARNESS_CODEX_IDLE_TIMEOUT_SECONDS Max seconds without session/log output. Default: 300.
  SELF_HARNESS_AUTO_CHALLENGE     Set to 0 to skip automatic progressive challenges on idle agent branches.
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
heartbeat_epoch: $(date +%s)
repo: ${ROOT_DIR}
codex_home: ${CODEX_HOME_DIR}
EOF
}

update_lock_heartbeat() {
  [ -f "$LOCK_INFO" ] || return 0
  local tmp
  tmp="${LOCK_INFO}.tmp"
  awk -v ts="$(timestamp)" -v epoch="$(date +%s)" '
    /^heartbeat_at:/ { print "heartbeat_at: " ts; next }
    /^heartbeat_epoch:/ { print "heartbeat_epoch: " epoch; seen_epoch=1; next }
    { print }
    END {
      if (!seen_epoch) {
        print "heartbeat_epoch: " epoch
      }
    }
  ' "$LOCK_INFO" >"$tmp"
  mv "$tmp" "$LOCK_INFO"
}

latest_session_file() {
  find "$SESSIONS_DIR" -type f \( -name '*.jsonl' -o -name '*.jsonl.*' \) 2>/dev/null \
    | sort \
    | tail -1
}

latest_last_message_file() {
  find "$TMP_DIR" -maxdepth 1 -type f -name 'codex-last-message-*.md' 2>/dev/null \
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

session_has_task_complete() {
  local file="$1"
  [ -f "$file" ] || return 1
  tail -200 "$file" | rg -q '"type":"task_complete"'
}

last_message_looks_complete() {
  local file="$1"
  [ -f "$file" ] || return 1
  sed -n '1,40p' "$file" | rg -qi '^(Completed|Processed|Done|No pending|Finished)'
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

  if session_has_task_complete "$latest"; then
    echo "new latest-complete age=${age}s size=${size} latest=${latest#${ROOT_DIR}/}"
    return 0
  fi

  local last_message
  last_message="$(latest_last_message_file || true)"
  if [ -n "$last_message" ] && last_message_looks_complete "$last_message"; then
    echo "new last-message-complete age=${age}s size=${size} latest=${latest#${ROOT_DIR}/} last_message=${last_message#${ROOT_DIR}/}"
    return 0
  fi

  if [ "$age" -le "$RESUME_MAX_AGE_SECONDS" ] && [ "$size" -le "$RESUME_MAX_BYTES" ]; then
    echo "resume age=${age}s size=${size} latest=${latest#${ROOT_DIR}/}"
  else
    echo "new age=${age}s size=${size} latest=${latest#${ROOT_DIR}/}"
  fi
}

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

has_pending_inbox() {
  find "${ROOT_DIR}/mailbox/inbox" -maxdepth 1 -type f ! -name .gitkeep 2>/dev/null \
    | rg -q .
}

recent_low_value_subjects() {
  git -C "$ROOT_DIR" log --format=%s -n 12 2>/dev/null \
    | rg -i '^(run: (record self-harness state|new mode|new session no pending|new run state)|run: .*?(no pending|mailbox sweep|state mailbox|repository state|repository inspection))' \
    | head -6 \
    || true
}

write_progressive_challenge() {
  local id="$1"
  local branch="$2"
  local date_value="$3"
  local file="${ROOT_DIR}/mailbox/inbox/${id}.md"
  local recent
  recent="$(recent_low_value_subjects | sed 's/^/- /')"
  if [ -z "$recent" ]; then
    recent="- No explicit next inbox task exists; the supervisor must turn idle time into a harder question instead of another passive sweep."
  fi

  cat >"$file" <<EOF
---
title: "Progressive Supervisor Challenge"
id: "mailbox-inbox-${id}"
type: "mailbox-inbox"
status: "pending"
owner: "supervisor"
created: "${date_value}"
updated: "${date_value}"
from: "supervisor"
to: "${branch}"
message_id: "${id}"
tags:
  - supervisor
  - progressive-challenge
  - self-improvement
  - evaluation
summary: "Asks the branch agent to turn idle loop feedback into a harder, evidence-seeking self-improvement task."
---

# Progressive Supervisor Challenge

The supervisor generated this because no pending inbox message was available. A passive run would likely produce another broad state sweep or stop at a low-demand status report, which is not enough progress.

Feedback signal:

${recent}

## Task

Use the recent passive-loop feedback to raise the bar for yourself.

1. Review the last five branch commits and the last two mailbox outbox reports.
2. Identify one concrete weakness, bottleneck, or missing proof in the current branch.
3. Produce one small, evidence-backed improvement or refusal:
   - a deterministic check under scripts/ if the behavior is stable enough to automate;
   - a focused skill refinement if a repeated procedure is clear;
   - a memory lesson or decision with a rerunnable query probe;
   - or a proposal explaining why no durable change should be made yet.
4. Record acceptance criteria and the exact evidence a future supervisor can rerun.
5. State whether anything is a return-to-main candidate under the strict family-genome standard. Default to no unless proof is unusually strong.

Do not make a no-pending mailbox report or generic repository sweep the primary result of this run. Keep scratch work under .self-harness/tmp/, keep durable content repository-relative, and run scripts/docs-check.sh before finishing.
EOF
}

seed_progressive_challenge_if_needed() {
  [ "$AUTO_CHALLENGE" = "1" ] || return 0
  is_agent_branch || return 0
  has_pending_inbox && return 0

  if [ -n "$(git -C "$ROOT_DIR" status --porcelain --untracked-files=all)" ]; then
    log "progressive challenge skipped: worktree has existing changes"
    return 0
  fi

  local branch id date_value
  branch="$(current_branch)"
  id="$(date -u +"%Y-%m-%d-%H%M%S-progressive-supervisor-challenge")"
  date_value="$(date -u +"%Y-%m-%d")"
  write_progressive_challenge "$id" "$branch" "$date_value"
  log "seeded progressive challenge: mailbox/inbox/${id}.md"
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
- Treat repeated no-pending or repository-state reports as insufficient progress. If a supervisor challenge is present, handle it instead of writing another broad sweep.
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

latest_staged_diary_file() {
  git -C "$ROOT_DIR" diff --cached --name-only --diff-filter=AM \
    | awk '/^memory\/diary\/.*\.md$/ { print }' \
    | sort \
    | tail -1
}

frontmatter_scalar() {
  local key="$1"
  local file="$2"
  awk -v key="$key" '
    NR == 1 {
      if ($0 != "---") {
        exit
      }
      in_frontmatter = 1
      next
    }
    in_frontmatter && $0 == "---" {
      exit
    }
    in_frontmatter && index($0, key ":") == 1 {
      value = substr($0, length(key) + 2)
      sub(/^[[:space:]]+/, "", value)
      if (value ~ /^".*"$/) {
        sub(/^"/, "", value)
        sub(/"$/, "", value)
      }
      print value
      exit
    }
  ' "$file"
}

sanitize_commit_line() {
  tr '\n' ' ' \
    | sed -E 's/[[:space:]]+/ /g; s/^[[:space:]]+//; s/[[:space:]]+$//' \
    | cut -c 1-72
}

write_default_commit_message_file() {
  local diary rel_diary title summary subject message_file
  rel_diary="$(latest_staged_diary_file || true)"
  if [ -n "$rel_diary" ]; then
    diary="${ROOT_DIR}/${rel_diary}"
    title="$(frontmatter_scalar title "$diary" | sanitize_commit_line)"
    summary="$(frontmatter_scalar summary "$diary" | sanitize_commit_line)"
  fi

  if [ -n "${title:-}" ]; then
    subject="run: ${title}"
  else
    subject="run: record self-harness state"
  fi

  message_file="${TMP_DIR}/commit-message-$(date -u +%Y%m%dT%H%M%SZ).txt"
  {
    printf '%s\n\n' "$subject"
    if [ -n "${summary:-}" ]; then
      printf '%s\n\n' "$summary"
    fi
    if [ -n "${rel_diary:-}" ]; then
      printf 'Diary: %s\n\n' "$rel_diary"
    fi
    printf 'Changed files:\n'
    git -C "$ROOT_DIR" diff --cached --name-only | sed 's/^/- /'
  } >"$message_file"

  echo "$message_file"
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

  check_portable_content || return $?

  "${ROOT_DIR}/scripts/docs-check.sh" || return $?

  local script
  for script in "${ROOT_DIR}"/scripts/*.sh; do
    [ -f "$script" ] || continue
    bash -n "$script" || return $?
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

  run_commit_gate "$allow_constitution" || return $?

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
    message_file="$(write_default_commit_message_file)"
    git -C "$ROOT_DIR" commit -F "$message_file"
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

latest_activity_epoch() {
  local output="$1"
  local latest session_mtime output_mtime log_mtime max_mtime
  max_mtime=0

  latest="$(latest_session_file || true)"
  if [ -n "$latest" ] && [ -f "$latest" ]; then
    session_mtime="$(file_mtime_epoch "$latest")"
    [ "$session_mtime" -gt "$max_mtime" ] && max_mtime="$session_mtime"
  fi

  if [ -f "$output" ]; then
    output_mtime="$(file_mtime_epoch "$output")"
    [ "$output_mtime" -gt "$max_mtime" ] && max_mtime="$output_mtime"
  fi

  if [ -f "$LOOP_LOG" ]; then
    log_mtime="$(file_mtime_epoch "$LOOP_LOG")"
    [ "$log_mtime" -gt "$max_mtime" ] && max_mtime="$log_mtime"
  fi

  if [ "$max_mtime" -eq 0 ]; then
    date +%s
  else
    echo "$max_mtime"
  fi
}

terminate_process_tree() {
  local pid="$1"
  [ -n "$pid" ] || return 0
  if ! is_pid_alive "$pid"; then
    return 0
  fi

  local children child
  children="$(pgrep -P "$pid" 2>/dev/null || true)"
  kill "$pid" 2>/dev/null || true
  for child in $children; do
    kill "$child" 2>/dev/null || true
  done
  sleep 5

  if is_pid_alive "$pid"; then
    kill -9 "$pid" 2>/dev/null || true
  fi
  for child in $children; do
    kill -9 "$child" 2>/dev/null || true
  done
}

run_with_watchdog() {
  local output="$1"
  local prompt_file="$2"
  shift 2

  local start now last_activity idle child status
  start="$(date +%s)"
  last_activity="$(date +%s)"

  "$@" <"$prompt_file" &
  child=$!

  while is_pid_alive "$child"; do
    sleep 10
    update_lock_heartbeat
    now="$(date +%s)"
    last_activity="$(latest_activity_epoch "$output")"
    idle=$((now - last_activity))

    if [ "$CODEX_MAX_RUNTIME_SECONDS" -gt 0 ] && [ $((now - start)) -gt "$CODEX_MAX_RUNTIME_SECONDS" ]; then
      log "codex watchdog: max runtime exceeded; terminating pid=${child}"
      terminate_process_tree "$child"
      wait "$child" 2>/dev/null || true
      return 124
    fi

    if [ "$CODEX_IDLE_TIMEOUT_SECONDS" -gt 0 ] && [ "$idle" -gt "$CODEX_IDLE_TIMEOUT_SECONDS" ]; then
      log "codex watchdog: idle timeout exceeded (${idle}s); terminating pid=${child}"
      terminate_process_tree "$child"
      wait "$child" 2>/dev/null || true
      return 124
    fi
  done

  wait "$child"
  status=$?
  return "$status"
}

run_codex_once() {
  init_layout
  seed_progressive_challenge_if_needed
  acquire_lock || return 0
  trap release_lock EXIT

  local choice mode detail prompt output prompt_file command
  choice="$(choose_mode)"
  mode="${choice%% *}"
  detail="${choice#${mode}}"
  output="${TMP_DIR}/codex-last-message-$(date -u +%Y%m%dT%H%M%SZ).md"
  prompt_file="${TMP_DIR}/codex-prompt-$(date -u +%Y%m%dT%H%M%SZ).txt"
  prompt="$(build_boot_prompt "$mode")"
  printf '%s\n' "$prompt" >"$prompt_file"

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
      run_with_watchdog "$output" "$prompt_file" codex exec resume --last --all --output-last-message "$output" "${extra_args[@]}" -
    else
      run_with_watchdog "$output" "$prompt_file" codex exec resume --last --all --output-last-message "$output" -
    fi
    status=$?
  else
    command="codex exec --cd ${ROOT_DIR} --output-last-message ${output} -"
    write_lock_info "$mode" "$command" "$$"
    if [ "${#extra_args[@]}" -gt 0 ]; then
      run_with_watchdog "$output" "$prompt_file" codex exec --cd "$ROOT_DIR" --output-last-message "$output" "${extra_args[@]}" -
    else
      run_with_watchdog "$output" "$prompt_file" codex exec --cd "$ROOT_DIR" --output-last-message "$output" -
    fi
    status=$?
  fi
  set -e
  rm -f "$prompt_file"

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

launchd_domain() {
  echo "gui/$(id -u)"
}

launchd_available() {
  [ "$(uname -s)" = "Darwin" ] && command -v launchctl >/dev/null 2>&1
}

launchd_is_loaded() {
  launchd_available || return 1
  launchctl print "$(launchd_domain)/${LAUNCHD_LABEL}" >/dev/null 2>&1
}

plist_escape() {
  sed \
    -e 's/&/\&amp;/g' \
    -e 's/</\&lt;/g' \
    -e 's/>/\&gt;/g' \
    -e 's/"/\&quot;/g' \
    -e "s/'/\&apos;/g"
}

write_launchd_plist() {
  local script_path path_value
  script_path="${ROOT_DIR}/scripts/supervisor.sh"
  path_value="${PATH:-/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin}"

  cat >"$LAUNCHD_PLIST" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>$(printf '%s' "$LAUNCHD_LABEL" | plist_escape)</string>
  <key>ProgramArguments</key>
  <array>
    <string>$(printf '%s' "$script_path" | plist_escape)</string>
    <string>loop</string>
  </array>
  <key>WorkingDirectory</key>
  <string>$(printf '%s' "$ROOT_DIR" | plist_escape)</string>
  <key>EnvironmentVariables</key>
  <dict>
    <key>PATH</key>
    <string>$(printf '%s' "$path_value" | plist_escape)</string>
  </dict>
  <key>StandardOutPath</key>
  <string>$(printf '%s' "$LOOP_LOG" | plist_escape)</string>
  <key>StandardErrorPath</key>
  <string>$(printf '%s' "$LOOP_LOG" | plist_escape)</string>
  <key>RunAtLoad</key>
  <true/>
  <key>KeepAlive</key>
  <true/>
</dict>
</plist>
EOF
}

start_launchd() {
  init_layout
  if launchd_is_loaded; then
    echo "supervisor already loaded: ${LAUNCHD_LABEL}"
    echo "log: $LOOP_LOG"
    return 0
  fi

  write_launchd_plist
  launchctl bootstrap "$(launchd_domain)" "$LAUNCHD_PLIST"
  launchctl kickstart -k "$(launchd_domain)/${LAUNCHD_LABEL}"
  echo "started supervisor via launchd: ${LAUNCHD_LABEL}"
  echo "log: $LOOP_LOG"
}

stop_launchd() {
  if ! launchd_available; then
    return 1
  fi

  if launchd_is_loaded; then
    launchctl bootout "$(launchd_domain)" "$LAUNCHD_PLIST" 2>/dev/null \
      || launchctl bootout "$(launchd_domain)/${LAUNCHD_LABEL}" 2>/dev/null \
      || true
    echo "stopped launchd supervisor: ${LAUNCHD_LABEL}"
  fi
}

start_background() {
  init_layout
  if launchd_available; then
    start_launchd
    return 0
  fi

  if [ -f "$PID_FILE" ] && is_pid_alive "$(cat "$PID_FILE")"; then
    echo "supervisor already running: pid=$(cat "$PID_FILE")"
    return 0
  fi
  nohup "${ROOT_DIR}/scripts/supervisor.sh" loop >>"$LOOP_LOG" 2>&1 &
  echo "$!" >"$PID_FILE"
  echo "started supervisor: pid=$!"
  echo "log: $LOOP_LOG"
}

stop_background() {
  stop_launchd || true

  if [ ! -f "$PID_FILE" ]; then
    if ! launchd_is_loaded; then
      echo "supervisor is not running"
    fi
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
  if launchd_is_loaded; then
    echo "supervisor: loaded via launchd (${LAUNCHD_LABEL})"
  elif [ -f "$PID_FILE" ] && is_pid_alive "$(cat "$PID_FILE")"; then
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
