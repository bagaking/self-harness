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
DEFAULT_CODEX_WATCHDOG_POLL_SECONDS=10
DEFAULT_AUTO_CHALLENGE=1
NEXT_PRESSURE_MARKER_PATTERN='^Next supervisor pressure:[[:space:]]*.'

SUPERVISOR_STABLE_COPY_ACTIVE=0
SUPERVISOR_SOURCE_FINGERPRINT_AT_START=""
SUPERVISOR_STABLE_SOURCE_PATH=""
SUPERVISOR_SOURCE_RECOVERED=0
SUPERVISOR_RECOVERY_COMMIT_FAILED=0

INTERVAL_SECONDS="${SELF_HARNESS_INTERVAL_SECONDS:-$DEFAULT_INTERVAL_SECONDS}"
RESUME_MAX_AGE_SECONDS="${SELF_HARNESS_RESUME_MAX_AGE_SECONDS:-$DEFAULT_RESUME_MAX_AGE_SECONDS}"
RESUME_MAX_BYTES="${SELF_HARNESS_RESUME_MAX_BYTES:-$DEFAULT_RESUME_MAX_BYTES}"
CODEX_MAX_RUNTIME_SECONDS="${SELF_HARNESS_CODEX_MAX_RUNTIME_SECONDS:-$DEFAULT_CODEX_MAX_RUNTIME_SECONDS}"
CODEX_IDLE_TIMEOUT_SECONDS="${SELF_HARNESS_CODEX_IDLE_TIMEOUT_SECONDS:-$DEFAULT_CODEX_IDLE_TIMEOUT_SECONDS}"
CODEX_WATCHDOG_POLL_SECONDS="${SELF_HARNESS_CODEX_WATCHDOG_POLL_SECONDS:-$DEFAULT_CODEX_WATCHDOG_POLL_SECONDS}"
AUTO_CHALLENGE="${SELF_HARNESS_AUTO_CHALLENGE:-$DEFAULT_AUTO_CHALLENGE}"

command_needs_stable_supervisor() {
  case "${1:-}" in
    once|loop|commit|restart)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

current_supervisor_script_path() {
  local current_dir
  current_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  printf '%s/%s\n' "$current_dir" "$(basename "${BASH_SOURCE[0]}")"
}

file_fingerprint() {
  local file="$1"
  [ -f "$file" ] || return 1
  cksum "$file" | awk '{ print $1 ":" $2 }'
}

run_from_stable_supervisor_copy_if_needed() {
  command_needs_stable_supervisor "${1:-}" || return 0

  local current_script
  current_script="$(current_supervisor_script_path)"
  if [ -n "${SELF_HARNESS_SUPERVISOR_STABLE_PATH:-}" ] && [ "$current_script" = "$SELF_HARNESS_SUPERVISOR_STABLE_PATH" ]; then
    SUPERVISOR_STABLE_COPY_ACTIVE=1
    SUPERVISOR_STABLE_SOURCE_PATH="$current_script"
    SUPERVISOR_SOURCE_FINGERPRINT_AT_START="$(file_fingerprint "${ROOT_DIR}/scripts/supervisor.sh" || true)"
    unset SELF_HARNESS_SUPERVISOR_STABLE_PATH
    unset SELF_HARNESS_SUPERVISOR_ROOT
    return 0
  fi

  mkdir -p "$RUN_DIR"

  local source_script stable_script tmp_script
  source_script="${ROOT_DIR}/scripts/supervisor.sh"
  stable_script="${RUN_DIR}/supervisor-stable-$$.sh"
  tmp_script="${stable_script}.tmp"

  cp "$source_script" "$tmp_script"
  chmod +x "$tmp_script"
  mv "$tmp_script" "$stable_script"

  export SELF_HARNESS_SUPERVISOR_STABLE_PATH="$stable_script"
  export SELF_HARNESS_SUPERVISOR_ROOT="$ROOT_DIR"
  exec "${BASH:-bash}" "$stable_script" "$@"
}

run_from_stable_supervisor_copy_if_needed "$@"

usage() {
  cat <<'EOF'
Usage:
  scripts/supervisor.sh plan
  scripts/supervisor.sh once
  scripts/supervisor.sh loop
  scripts/supervisor.sh feedback [-F FILE] [--] FEEDBACK...
  scripts/supervisor.sh triggers [--limit N] [--evidence-limit N] [--status all|review|quiet]
  scripts/supervisor.sh claim-latency [--max-seconds N] [SESSION...]
  scripts/supervisor.sh commit [--allow-constitution] [-m MESSAGE | -F FILE] [-- PATH...]
  scripts/supervisor.sh start
  scripts/supervisor.sh stop
  scripts/supervisor.sh restart
  scripts/supervisor.sh status

Environment:
  SELF_HARNESS_INTERVAL_SECONDS       Loop sleep interval. Default: 300.
  SELF_HARNESS_RESUME_MAX_AGE_SECONDS Latest-session age limit. Default: 21600.
  SELF_HARNESS_RESUME_MAX_BYTES       Latest-session size limit. Default: 600000.
  SELF_HARNESS_CODEX_MAX_RUNTIME_SECONDS Max seconds for one Codex child. Default: 1800.
  SELF_HARNESS_CODEX_IDLE_TIMEOUT_SECONDS Max seconds without session/log output. Default: 300.
  SELF_HARNESS_CODEX_WATCHDOG_POLL_SECONDS Watchdog poll interval. Default: 10.
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
  local state
  [ -n "$pid" ] || return 1
  kill -0 "$pid" 2>/dev/null || return 1

  if state="$(ps -o stat= -p "$pid" 2>/dev/null)" && [ -n "$state" ]; then
    case "${state#"${state%%[![:space:]]*}"}" in
      Z*)
        return 1
        ;;
    esac
  fi

  return 0
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
  pending_inbox_files | rg -q .
}

pending_inbox_files() {
  find "${ROOT_DIR}/mailbox/inbox" -maxdepth 1 -type f ! -name .gitkeep 2>/dev/null \
    | sort \
    | sed "s#^${ROOT_DIR}/##"
}

has_pending_processing() {
  pending_processing_files | rg -q .
}

pending_processing_files() {
  find "${ROOT_DIR}/mailbox/processing" -maxdepth 1 -type f ! -name .gitkeep 2>/dev/null \
    | sort \
    | sed "s#^${ROOT_DIR}/##"
}

recent_low_value_subjects() {
  git -C "$ROOT_DIR" log --format=%s -n 12 2>/dev/null \
    | rg -i '^(run: (record self-harness state|new mode|new session no pending|new run state)|run: .*?(no pending|mailbox sweep|state mailbox|repository state|repository inspection))' \
    | head -6 \
    || true
}

has_recent_low_value_feedback() {
  [ "$(recent_low_value_subjects | wc -l | tr -d '[:space:]')" -ge 2 ]
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

  if ! has_recent_low_value_feedback; then
    log "progressive challenge skipped: no repeated low-value branch feedback"
    return 0
  fi

  local branch id date_value
  branch="$(current_branch)"
  id="$(date -u +"%Y-%m-%d-%H%M%S-progressive-supervisor-challenge")"
  date_value="$(date -u +"%Y-%m-%d")"
  write_progressive_challenge "$id" "$branch" "$date_value"
  log "seeded progressive challenge: mailbox/inbox/${id}.md"
}

read_feedback_command_input() {
  local file="" args=()

  while [ "$#" -gt 0 ]; do
    case "$1" in
      -F|--file)
        [ "$#" -ge 2 ] || {
          echo "feedback: missing file after $1" >&2
          return 2
        }
        file="$2"
        shift 2
        ;;
      --)
        shift
        break
        ;;
      *)
        args+=("$1")
        shift
        ;;
    esac
  done

  while [ "$#" -gt 0 ]; do
    args+=("$1")
    shift
  done

  if [ -n "$file" ]; then
    if [ "$file" = "-" ]; then
      cat
    else
      cat "$file"
    fi
  fi

  if [ "${#args[@]}" -gt 0 ]; then
    printf '%s\n' "${args[*]}"
  fi
}

markdown_quote() {
  sed 's/^/> /'
}

text_has_nonspace() {
  LC_ALL=C rg -q '[^[:space:]]'
}

write_feedback_pressure_challenge() {
  local id="$1"
  local branch="$2"
  local date_value="$3"
  local feedback="$4"
  local file="${ROOT_DIR}/mailbox/inbox/${id}.md"

  cat >"$file" <<EOF
---
title: "Feedback Pressure Challenge"
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
  - feedback-pressure
  - explicit-feedback
  - self-improvement
summary: "Turns explicit human feedback into one focused pressure task without waiting for idle-loop heuristics."
---

# Feedback Pressure Challenge

The supervisor generated this from explicit human feedback. This path exists so fresh feedback can create one focused inbox task even when the idle low-value heuristic would skip launching the agent.

## Feedback

$(printf '%s\n' "$feedback" | markdown_quote)

## Task

Use the feedback to raise the bar without creating generic churn.

1. Review the latest three branch outbox reports and latest three run commits before choosing a response.
2. Identify the exact way the current loop can still stop too early or lower the proof bar.
3. Produce exactly one focused mechanism or a bounded refusal:
   - a deterministic script check or supervisor-loop refinement;
   - a concise skill refinement;
   - a memory decision with a rerunnable query probe and trigger;
   - or a refusal that explains why automation would add noise and names one smaller useful task.
4. Prove the result with local evidence. Script changes need a positive check and a negative or edge-case check.
5. Include the strict return-to-main judgment. Default to branch-local or deferred unless the improvement is clearly portable, validated, and has no known degradation for the family genome.

## Acceptance Criteria

- Do not answer with a generic repository sweep or no-pending report.
- Do not modify \`constitution/\`.
- Keep durable paths repository-relative and scratch work under \`.self-harness/tmp/\`.
- Run \`scripts/feedback-escalation-check.sh\`, \`scripts/docs-check.sh\`, and focused validation before handoff.
- Include exactly one concrete \`Next supervisor pressure:\` line, or one bounded \`No next supervisor pressure:\` refusal with a concrete \`Supervisor evaluation trigger:\` plus a \`Smaller useful task:\` or \`Stop condition:\`.
EOF
}

create_feedback_pressure_challenge() {
  init_layout

  case "${1:-}" in
    -h|--help|help)
      usage
      return 0
      ;;
  esac

  if ! is_agent_branch; then
    echo "feedback challenge skipped: current branch is not an agent branch" >&2
    return 1
  fi

  if has_pending_inbox; then
    echo "feedback challenge skipped: pending inbox already exists" >&2
    pending_inbox_files | sed 's/^/- /' >&2
    return 1
  fi

  if has_pending_processing; then
    echo "feedback challenge skipped: mailbox processing already exists" >&2
    pending_processing_files | sed 's/^/- /' >&2
    return 1
  fi

  local feedback
  feedback="$(read_feedback_command_input "$@" | sanitize_recovery_evidence)"
  if ! printf '%s' "$feedback" | text_has_nonspace; then
    echo "feedback: provide non-empty feedback text with arguments or -F FILE" >&2
    return 2
  fi

  local branch id date_value
  branch="$(current_branch)"
  id="$(date -u +"%Y-%m-%d-%H%M%S-feedback-pressure-challenge")"
  date_value="$(date -u +"%Y-%m-%d")"

  write_feedback_pressure_challenge "$id" "$branch" "$date_value" "$feedback"
  log "seeded feedback pressure challenge: mailbox/inbox/${id}.md"
}

list_supervisor_evaluation_triggers() {
  init_layout
  "${ROOT_DIR}/scripts/supervisor-evaluation-trigger-list.sh" "$@"
}

check_pending_inbox_claim_latency() {
  init_layout
  "${ROOT_DIR}/scripts/pending-inbox-claim-latency-check.sh" "$@"
}

changed_outbox_files_with_next_pressure_marker() {
  local rel file
  while IFS= read -r rel; do
    [ -n "$rel" ] || continue
    case "$rel" in
      mailbox/outbox/*.md)
        file="${ROOT_DIR}/${rel}"
        [ -f "$file" ] || continue
        if LC_ALL=C rg -q -- "$NEXT_PRESSURE_MARKER_PATTERN" "$file"; then
          printf '%s\n' "$rel"
          return 0
        fi
        ;;
    esac
  done < <(staged_or_changed_files)
}

extract_next_pressure_requirement() {
  local rel="$1"
  awk '
    /^Next supervisor pressure:[[:space:]]*/ {
      value = $0
      sub(/^Next supervisor pressure:[[:space:]]*/, "", value)
      gsub(/[[:space:]]+/, " ", value)
      sub(/^[[:space:]]+/, "", value)
      sub(/[[:space:]]+$/, "", value)
      print substr(value, 1, 240)
      exit
    }
  ' "${ROOT_DIR}/${rel}"
}

write_post_run_pressure_challenge() {
  local source_rel="$1"
  local requirement="$2"
  local branch="$3"
  local date_value="$4"
  local id="$5"
  local file="${ROOT_DIR}/mailbox/inbox/${id}.md"

  cat >"$file" <<EOF
---
title: "Post Run Pressure Challenge"
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
  - feedback-pressure
  - post-run-pressure
  - self-improvement
summary: "Seeds the next sharper requirement declared by the completed feedback-bearing run."
related:
  - "${source_rel}"
---

# Post Run Pressure Challenge

The completed run declared unresolved follow-up pressure in \`${source_rel}\`. The supervisor generated this inbox item before committing so the next foreground loop has a concrete target instead of treating the previous reply as the end of supervision.

## Requirement

${requirement}

## Acceptance Criteria

- Review \`${source_rel}\` before broad repository inspection.
- Either satisfy the requirement with rerunnable evidence or write a focused refusal that names the smaller useful next task.
- Do not replace this with a generic no-pending or repository-state report.
- Keep durable paths repository-relative and scratch work under \`.self-harness/tmp/\`.
EOF
}

seed_post_run_pressure_challenge_if_needed() {
  [ "$AUTO_CHALLENGE" = "1" ] || return 0
  is_agent_branch || return 0
  has_pending_inbox && return 0

  local source_rel requirement branch date_value id
  source_rel="$(changed_outbox_files_with_next_pressure_marker | head -1)"
  [ -n "$source_rel" ] || return 0

  requirement="$(extract_next_pressure_requirement "$source_rel")"
  [ -n "$requirement" ] || return 0

  branch="$(current_branch)"
  date_value="$(date -u +"%Y-%m-%d")"
  id="$(date -u +"%Y-%m-%d-%H%M%S-post-run-pressure-challenge")"
  write_post_run_pressure_challenge "$source_rel" "$requirement" "$branch" "$date_value" "$id"
  log "seeded post-run pressure challenge: mailbox/inbox/${id}.md from ${source_rel}"
}

should_skip_idle_agent_launch() {
  is_agent_branch || return 1
  has_pending_inbox && return 1
  has_git_changes && return 1
  [ -n "$(latest_diary_file || true)" ] || return 1
  return 0
}

build_boot_prompt() {
  local mode="$1"
  local mailbox_section
  mailbox_section="$(build_pending_mailbox_prompt)"
  cat <<EOF
You are running inside the self-harness repository.

Mode: ${mode}

Read AGENTS.md first. Then use scripts/query-docs.sh to discover and read relevant constitution documents. Do not modify constitution/.

This repository is the agent itself. sessions/, mailbox/, memory/, and skills/ are commit-worthy agent state. Temporary or private work belongs only under .self-harness/.

Keep committed content portable: use repository-relative paths, do not modify files outside this repository, and do not expose local usernames, hostnames, home directories, or machine-specific absolute paths. Use .self-harness/tmp/ for experiments, reference clones, temporary projects, and subagent experiment sandboxes.

${mailbox_section}

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

build_pending_mailbox_prompt() {
  local pending
  pending="$(pending_inbox_files | sed 's/^/- /')"
  if [ -z "$pending" ]; then
    cat <<'EOF'
Pending mailbox before launch:
- none
EOF
    return 0
  fi

  cat <<EOF
Pending mailbox before launch:
${pending}

Mailbox priority:
- After reading AGENTS.md and constitution/00-charter.md, inspect the listed pending inbox before any broad repository sweep.
- Claim exactly one pending file by moving it from mailbox/inbox/ to mailbox/processing/.
- If there is only one pending file, claim that file first and handle its acceptance criteria.
- A run with pending inbox that exits without a processing, done, failed, or outbox record is not useful progress.
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
  local file rel slash users_dir home_dir private_dir tmp_dir var_dir folders_dir quote_chars local_path_pattern temp_path_pattern env_pattern home_rel_pattern
  slash="/"
  users_dir="Users"
  home_dir="home"
  private_dir="private"
  tmp_dir="tmp"
  var_dir="var"
  folders_dir="folders"
  quote_chars=$'`\'"'
  local_path_pattern="(^|[^[:alnum:]_.-])(${slash}${users_dir}|${slash}${home_dir})${slash}[^[:space:]${quote_chars}]+"
  temp_path_pattern="(^|[^[:alnum:]_.-])(${slash}${private_dir}${slash}${tmp_dir}|${slash}${var_dir}${slash}${folders_dir})${slash}[^[:space:]${quote_chars}]+"
  env_pattern="(^|[^[:alnum:]_])(HOSTNAME|USER|USERNAME|LOGNAME|HOME)=[^[:space:]${quote_chars}]+"
  home_rel_pattern="~${slash}(Desktop|Documents|Downloads|Library|Movies|Music|Pictures|proj|Projects|workspace|work)${slash}[^[:space:]${quote_chars}]*"

  while IFS= read -r rel; do
    [ -n "$rel" ] || continue
    file="${ROOT_DIR}/${rel}"
    [ -f "$file" ] || continue
    is_portability_checked_path "$rel" || continue

    if LC_ALL=C rg -n --color never "$local_path_pattern" "$file"; then
      errors=$((errors + 1))
    fi

    if LC_ALL=C rg -n --color never "$temp_path_pattern" "$file"; then
      errors=$((errors + 1))
    fi

    if LC_ALL=C rg -n --color never "$env_pattern" "$file"; then
      errors=$((errors + 1))
    fi

    if LC_ALL=C rg -n --color never "$home_rel_pattern" "$file"; then
      errors=$((errors + 1))
    fi

  done < <(staged_or_changed_files)

  if [ "$errors" -gt 0 ]; then
    echo "commit gate failed: portable content check found local paths, device details, or outside-repo write instructions" >&2
    return 1
  fi
}

constitution_changes_present() {
  ! git -C "$ROOT_DIR" diff --quiet -- constitution/ && return 0
  ! git -C "$ROOT_DIR" diff --cached --quiet -- constitution/ && return 0
  git -C "$ROOT_DIR" ls-files --others --exclude-standard -- constitution/ | rg -q .
}

run_commit_gate() {
  local allow_constitution="${1:-0}"
  init_layout

  if [ "$allow_constitution" != "1" ] && constitution_changes_present; then
    echo "commit gate failed: constitution/ has staged, unstaged, or untracked changes" >&2
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

  "${ROOT_DIR}/scripts/pending-inbox-session-only-check.sh" || return $?

  "${ROOT_DIR}/scripts/proof-pressure-check.sh" || return $?

  "${ROOT_DIR}/scripts/feedback-escalation-check.sh" || return $?

  "${ROOT_DIR}/scripts/docs-check.sh" || return $?

  "${ROOT_DIR}/scripts/shell-syntax-check.sh" || return $?
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

write_invalid_supervisor_recovery_incident() {
  local trigger="$1"
  local stable_source="$2"
  local invalid_source="$3"
  local date_value id file

  date_value="$(date -u +"%Y-%m-%d")"
  id="$(date -u +"%Y-%m-%d-%H%M%S-invalid-supervisor-recovery")"
  file="${ROOT_DIR}/memory/incidents/${id}.md"
  mkdir -p "${ROOT_DIR}/memory/incidents"

  cat >"$file" <<EOF
---
title: "Invalid Supervisor Source Recovery"
id: "incident-${id}"
type: "incident"
status: "active"
owner: "supervisor"
created: "${date_value}"
updated: "${date_value}"
tags:
  - incident
  - supervisor
  - control-plane
  - recovery
summary: "Records a stable-copy recovery that restored invalid checked-out supervisor source after the post-run commit gate failed."
---

# Invalid Supervisor Source Recovery

## Summary

The post-run commit path failed while the checked-out \`scripts/supervisor.sh\` was syntactically invalid. The stable supervisor copy restored \`scripts/supervisor.sh\` from the launch-time valid copy before retrying a bounded incident commit.

## Trigger

${trigger}

## Recovery Boundary

- Restored path: \`scripts/supervisor.sh\`
- Source of restored content: the private stable copy created before the Codex child ran
- Unrelated worktree changes: preserved
- Constitution changes: not allowed

## Next Check

Inspect the run's mailbox output, diary, and this incident together. The recovery makes the next normal restart parse the checked-out supervisor again; it does not prove that the discarded invalid supervisor edit was semantically correct.

$(bounded_discarded_supervisor_diff_section "$stable_source" "$invalid_source")
EOF
}

sanitize_recovery_evidence() {
  local slash users_dir home_dir private_dir tmp_dir var_dir folders_dir
  slash="/"
  users_dir="Users"
  home_dir="home"
  private_dir="private"
  tmp_dir="tmp"
  var_dir="var"
  folders_dir="folders"
  sed -E \
    -e "s#(${slash}${users_dir}|${slash}${home_dir})${slash}[^[:space:]]+#[redacted-local-path]#g" \
    -e "s#(${slash}${private_dir}${slash}${tmp_dir}|${slash}${private_dir}${slash}${var_dir}${slash}${folders_dir}|${slash}${var_dir}${slash}${folders_dir}|${slash}${tmp_dir})${slash}[^[:space:]]+#[redacted-temp-path]#g" \
    -e 's#(HOSTNAME|USER|USERNAME|LOGNAME|HOME)=[^[:space:]]+#\1=[redacted]#g' \
    -e "s#~${slash}(Desktop|Documents|Downloads|Library|Movies|Music|Pictures|proj|Projects|workspace|work)${slash}[^[:space:]]*#[redacted-home-path]#g"
}

bounded_discarded_supervisor_diff_section() {
  local stable_source="$1"
  local invalid_source="$2"
  local max_lines="${SELF_HARNESS_RECOVERY_DIFF_MAX_LINES:-120}"
  local max_chars="${SELF_HARNESS_RECOVERY_DIFF_MAX_CHARS:-12000}"
  local head_lines=80
  local tail_lines=40
  local stable_lines invalid_lines stable_bytes invalid_bytes syntax_status diff_file total_lines

  stable_lines="$(wc -l <"$stable_source" | tr -d '[:space:]')"
  invalid_lines="$(wc -l <"$invalid_source" | tr -d '[:space:]')"
  stable_bytes="$(wc -c <"$stable_source" | tr -d '[:space:]')"
  invalid_bytes="$(wc -c <"$invalid_source" | tr -d '[:space:]')"

  syntax_status="failed"
  if bash -n "$invalid_source" >/dev/null 2>&1; then
    syntax_status="passed"
  fi

  cat <<EOF
## Discarded Invalid Supervisor Diff

This bounded evidence compares only \`scripts/supervisor.sh\` from the launch-time stable copy with the discarded invalid checked-out source. It is sanitized for local path patterns and capped at ${max_lines} lines or ${max_chars} characters.

### Summary

- Stable source lines: ${stable_lines}
- Stable source bytes: ${stable_bytes}
- Discarded source lines: ${invalid_lines}
- Discarded source bytes: ${invalid_bytes}
- Discarded source syntax: ${syntax_status}

### Syntax Output

EOF

  set +e
  bash -n "$invalid_source" 2>&1 \
    | sanitize_recovery_evidence \
    | awk -v max_lines=20 -v max_chars=2000 '
      {
        if (lines < max_lines && chars + length($0) + 1 <= max_chars) {
          print "    " $0
          lines += 1
          chars += length($0) + 1
        } else if (!truncated) {
          print "    ... [truncated syntax output]"
          truncated = 1
        }
      }
      END {
        if (lines == 0) {
          print "    (no syntax output)"
        }
      }
    '
  set -e

  cat <<'EOF'

### Discarded Source Excerpt

EOF

  sed -n '1,40p' "$invalid_source" \
    | sanitize_recovery_evidence \
    | awk -v max_chars=4000 '
      {
        if (chars + length($0) + 1 <= max_chars) {
          print "    " $0
          chars += length($0) + 1
          emitted = 1
        } else if (!truncated) {
          print "    ... [truncated discarded source excerpt]"
          truncated = 1
        }
      }
      END {
        if (!emitted) {
          print "    (discarded source was empty)"
        }
      }
    '

  cat <<'EOF'

### Diff Excerpt

EOF

  diff_file="${TMP_DIR}/supervisor-recovery-diff-$$.tmp"
  set +e
  diff -u \
    --label 'scripts/supervisor.sh (launch-time stable copy)' \
    --label 'scripts/supervisor.sh (discarded invalid source)' \
    "$stable_source" "$invalid_source" 2>&1 \
    | sanitize_recovery_evidence \
    >"$diff_file"
  set -e

  total_lines="$(wc -l <"$diff_file" | tr -d '[:space:]')"
  if [ "$total_lines" -le "$max_lines" ]; then
    awk -v max_chars="$max_chars" '
      BEGIN {
        chars = 0
      }
      {
        if (chars + length($0) + 1 <= max_chars) {
          print "    " $0
          chars += length($0) + 1
          emitted = 1
        } else if (!truncated) {
          print "    ... [truncated: recovery diff excerpt exceeded " max_chars " characters]"
          truncated = 1
        }
      }
      END {
        if (!emitted) {
          print "    (no textual diff emitted)"
        }
      }
    ' "$diff_file"
  else
    {
      head -n "$head_lines" "$diff_file"
      printf '... [truncated middle: showing first %s and last %s of %s diff lines]\n' "$head_lines" "$tail_lines" "$total_lines"
      tail -n "$tail_lines" "$diff_file"
    } | awk -v max_chars="$max_chars" '
      {
        if (chars + length($0) + 1 <= max_chars) {
          print "    " $0
          chars += length($0) + 1
          emitted = 1
        } else if (!truncated) {
          print "    ... [truncated: recovery diff excerpt exceeded " max_chars " characters]"
          truncated = 1
        }
      }
      END {
        if (!emitted) {
          print "    (no textual diff emitted)"
        }
      }
    '
  fi
  rm -f "$diff_file"
}

recover_invalid_supervisor_source_after_failed_commit() {
  local trigger="$1"
  local source_script tmp_script

  [ "$SUPERVISOR_STABLE_COPY_ACTIVE" = "1" ] || return 1
  [ -n "$SUPERVISOR_STABLE_SOURCE_PATH" ] || return 1

  source_script="${ROOT_DIR}/scripts/supervisor.sh"
  [ -f "$source_script" ] || return 1
  [ -f "$SUPERVISOR_STABLE_SOURCE_PATH" ] || return 1

  if bash -n "$source_script" >/dev/null 2>&1; then
    return 1
  fi

  if ! bash -n "$SUPERVISOR_STABLE_SOURCE_PATH" >/dev/null 2>&1; then
    log "invalid supervisor recovery skipped: stable copy did not parse"
    return 1
  fi

  write_invalid_supervisor_recovery_incident "$trigger" "$SUPERVISOR_STABLE_SOURCE_PATH" "$source_script"

  tmp_script="${TMP_DIR}/supervisor-recovery-$$.sh"
  cp "$SUPERVISOR_STABLE_SOURCE_PATH" "$tmp_script"
  chmod +x "$tmp_script"
  mv "$tmp_script" "$source_script"

  log "recovered invalid checked-out supervisor source from stable copy"
  return 0
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

write_run_failure_incident() {
  local status="$1"
  local mode="$2"
  local detail="$3"
  local output="$4"
  local date_value id file latest rel_output rel_latest pending

  date_value="$(date -u +"%Y-%m-%d")"
  id="$(date -u +"%Y-%m-%d-%H%M%S-codex-run-failure")"
  file="${ROOT_DIR}/memory/incidents/${id}.md"
  rel_output="$(repo_relative_path "$output")"
  latest="$(latest_session_file || true)"
  if [ -n "$latest" ]; then
    rel_latest="$(repo_relative_path "$latest")"
  else
    rel_latest="none"
  fi
  pending="$(pending_inbox_files | sed 's/^/- /')"
  if [ -z "$pending" ]; then
    pending="- none"
  fi

  cat >"$file" <<EOF
---
title: "Codex Run Failure"
id: "incident-${id}"
type: "incident"
status: "active"
owner: "supervisor"
created: "${date_value}"
updated: "${date_value}"
tags:
  - incident
  - supervisor
  - codex-run
  - watchdog
summary: "Records a Codex child run that exited nonzero before producing a normal diary-backed commit."
---

# Codex Run Failure

## Summary

The supervisor child run exited with status ${status}. This incident exists so a failed or timed-out run is not disguised as ordinary progress.

## Run Context

- Mode: ${mode}
- Choice detail: ${detail}
- Last-message output: ${rel_output}
- Latest session: ${rel_latest}
- Pending inbox at incident time:
${pending}

## Supervisor Action

The supervisor should only auto-commit this failure state when the changed files are limited to session transcripts and incident records. If other repository files changed during the failed run, leave them uncommitted for review or repair instead of packaging partial work as success.

## Next Check

Inspect the latest session and pending inbox. If a concrete mailbox task remains, restart the loop only after the control-plane issue has been narrowed or converted into a sharper inbox requirement.
EOF

  repo_relative_path "$file"
}

changed_files_are_failure_state_only() {
  local rel saw_file
  saw_file=0
  while IFS= read -r rel; do
    [ -n "$rel" ] || continue
    saw_file=1
    case "$rel" in
      sessions/*|memory/incidents/*.md)
        ;;
      *)
        return 1
        ;;
    esac
  done < <(staged_or_changed_files)

  [ "$saw_file" -eq 1 ]
}

commit_failure_state_if_safe() {
  local status="$1"
  local mode="$2"
  local detail="$3"
  local output="$4"
  local rel paths=()

  write_run_failure_incident "$status" "$mode" "$detail" "$output" >/dev/null

  if ! changed_files_are_failure_state_only; then
    log "codex run failed; failure incident written but automatic commit skipped because non-failure files changed"
    return 0
  fi

  while IFS= read -r rel; do
    [ -n "$rel" ] || continue
    paths+=("$rel")
  done < <(staged_or_changed_files)

  [ "${#paths[@]}" -gt 0 ] || return 0
  commit_changes -m "incident: codex run failed status ${status}" -- "${paths[@]}"
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
    sleep "$CODEX_WATCHDOG_POLL_SECONDS"
    if ! is_pid_alive "$child"; then
      break
    fi
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

  if should_skip_idle_agent_launch; then
    log "idle agent run skipped: no pending inbox after challenge seeding"
    return 0
  fi

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

  if [ "$status" -ne 0 ]; then
    if [ "${SELF_HARNESS_SKIP_COMMIT:-0}" != "1" ]; then
      commit_failure_state_if_safe "$status" "$mode" "$detail" "$output" || log "failure-state commit failed"
    fi
    return "$status"
  fi

  if [ "${SELF_HARNESS_SKIP_COMMIT:-0}" != "1" ]; then
    seed_post_run_pressure_challenge_if_needed
    if ! commit_changes_with_repair; then
      if recover_invalid_supervisor_source_after_failed_commit "post-run commit gate failed after Codex child exit"; then
        if commit_changes -m "incident: recovered invalid supervisor source"; then
          SUPERVISOR_SOURCE_RECOVERED=1
          log "committed invalid supervisor recovery incident"
          return 0
        fi
        SUPERVISOR_RECOVERY_COMMIT_FAILED=1
        log "post-run recovery commit failed"
      fi
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
    if [ "$SUPERVISOR_RECOVERY_COMMIT_FAILED" = "1" ]; then
      log "supervisor source recovery incident commit failed; exiting with failure for review"
      return 1
    fi
    if [ "$SUPERVISOR_SOURCE_RECOVERED" = "1" ]; then
      log "supervisor source recovered during stable-copy loop; exiting so the next start uses checked-out source"
      return 0
    fi
    if stable_supervisor_source_changed; then
      if stable_supervisor_handoff_ready; then
        log "supervisor source changed during stable-copy loop and passed readiness check; exiting so the next start activates the checked-out script"
        return 0
      fi
      log "supervisor source changed during stable-copy loop but failed readiness check; keeping stable copy in control"
    fi
    sleep "$INTERVAL_SECONDS"
  done
}

stable_supervisor_source_changed() {
  [ "$SUPERVISOR_STABLE_COPY_ACTIVE" = "1" ] || return 1
  [ -n "$SUPERVISOR_SOURCE_FINGERPRINT_AT_START" ] || return 1

  local current_fingerprint
  current_fingerprint="$(file_fingerprint "${ROOT_DIR}/scripts/supervisor.sh" || true)"
  [ -n "$current_fingerprint" ] || return 1
  [ "$current_fingerprint" != "$SUPERVISOR_SOURCE_FINGERPRINT_AT_START" ]
}

stable_supervisor_handoff_ready() {
  local source_script
  source_script="${ROOT_DIR}/scripts/supervisor.sh"
  [ -f "$source_script" ] || return 1
  bash -n "$source_script"
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

restart_background() {
  init_layout
  stop_background
  start_background
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
  feedback)
    shift
    create_feedback_pressure_challenge "$@"
    ;;
  triggers)
    shift
    list_supervisor_evaluation_triggers "$@"
    ;;
  claim-latency)
    shift
    check_pending_inbox_claim_latency "$@"
    ;;
  start)
    start_background
    ;;
  stop)
    stop_background
    ;;
  restart)
    restart_background
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
