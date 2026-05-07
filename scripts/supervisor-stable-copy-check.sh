#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
WORK_DIR="${ROOT_DIR}/.self-harness/tmp/supervisor-stable-copy-check"

fail() {
  echo "supervisor-stable-copy-check: $*" >&2
  exit 1
}

log() {
  echo "supervisor-stable-copy-check: $*"
}

write_fake_codex() {
  local dir="$1"
  local replacement="${2:-invalid}"
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
    printf '%s\n' '  printf "Completed fake codex run\n" >"$output"'
    printf '%s\n' 'fi'
    printf '%s\n' 'printf "stable_path_present=%s\n" "${SELF_HARNESS_SUPERVISOR_STABLE_PATH:+yes}" > stable-env.txt'
    printf '%s\n' 'printf "root_present=%s\n" "${SELF_HARNESS_SUPERVISOR_ROOT:+yes}" >> stable-env.txt'
    case "$replacement" in
      invalid)
        printf '%s\n' 'printf "%s\n" '\''printf "broken quote'\'' > scripts/supervisor.sh'
        ;;
      valid)
        printf '%s\n' 'printf "%s\n" "#!/usr/bin/env bash" "set -euo pipefail" "echo valid replacement supervisor" > scripts/supervisor.sh'
        ;;
      *)
        fail "unknown fake Codex replacement mode: ${replacement}"
        ;;
    esac
    printf '%s\n' 'exit 0'
  } >"${dir}/codex"
  chmod +x "${dir}/codex"
}

write_fail_codex() {
  local dir="$1"
  mkdir -p "$dir"
  {
    printf '%s\n' '#!/usr/bin/env bash'
    printf '%s\n' 'echo "codex should not have been launched for idle once" >&2'
    printf '%s\n' 'exit 99'
  } >"${dir}/codex"
  chmod +x "${dir}/codex"
}

write_fake_git() {
  local dir="$1"
  mkdir -p "$dir"
  {
    printf '%s\n' '#!/usr/bin/env bash'
    printf '%s\n' 'if [ "${1:-}" = "-C" ]; then'
    printf '%s\n' '  shift 2'
    printf '%s\n' 'fi'
    printf '%s\n' 'case "$*" in'
    printf '%s\n' '  "branch --show-current")'
    printf '%s\n' '    echo "agent/stable-copy-check"'
    printf '%s\n' '    exit 0'
    printf '%s\n' '    ;;'
    printf '%s\n' '  "status --porcelain --untracked-files=all")'
    printf '%s\n' '    exit 0'
    printf '%s\n' '    ;;'
    printf '%s\n' '  *)'
    printf '%s\n' '    echo "unexpected fake git command: $*" >&2'
    printf '%s\n' '    exit 2'
    printf '%s\n' '    ;;'
    printf '%s\n' 'esac'
  } >"${dir}/git"
  chmod +x "${dir}/git"
}

prepare_common_sandbox() {
  local sandbox="$1"
  rm -rf "$sandbox"
  mkdir -p \
    "${sandbox}/scripts" \
    "${sandbox}/mailbox/inbox" \
    "${sandbox}/memory/diary" \
    "${sandbox}/bin"

  cp "${ROOT_DIR}/scripts/supervisor.sh" "${sandbox}/scripts/supervisor.sh"
  cp "${ROOT_DIR}/scripts/init.sh" "${sandbox}/scripts/init.sh"
}

run_with_timeout() {
  local seconds="$1"
  shift

  "$@" &
  local child="$!"
  local remaining="$seconds"
  while [ "$remaining" -gt 0 ]; do
    if ! kill -0 "$child" 2>/dev/null; then
      wait "$child"
      return "$?"
    fi
    sleep 1
    remaining=$((remaining - 1))
  done

  kill "$child" 2>/dev/null || true
  wait "$child" 2>/dev/null || true
  return 124
}

check_self_modified_once_survives() {
  local sandbox log_file status
  sandbox="${WORK_DIR}/self-modified-once"
  log_file="${WORK_DIR}/self-modified-once.log"
  prepare_common_sandbox "$sandbox"
  write_fake_codex "${sandbox}/bin" invalid
  printf '%s\n' 'pending stable-copy proof' >"${sandbox}/mailbox/inbox/pending-stable-copy-proof.md"

  set +e
  (
    cd "$sandbox"
    run_with_timeout 20 env \
      PATH="${sandbox}/bin:${PATH}" \
      SELF_HARNESS_AUTO_CHALLENGE=0 \
      SELF_HARNESS_SKIP_COMMIT=1 \
      SELF_HARNESS_CODEX_MAX_RUNTIME_SECONDS=0 \
      SELF_HARNESS_CODEX_IDLE_TIMEOUT_SECONDS=0 \
      SELF_HARNESS_CODEX_WATCHDOG_POLL_SECONDS=1 \
      bash scripts/supervisor.sh once
  ) >"$log_file" 2>&1
  status=$?
  set -e

  if [ "$status" -ne 0 ]; then
    sed -n '1,160p' "$log_file" >&2
    fail "self-modified once returned ${status}"
  fi

  if ! rg -q '^stable_path_present=$' "${sandbox}/stable-env.txt"; then
    sed -n '1,80p' "${sandbox}/stable-env.txt" >&2 || true
    fail "fake Codex child inherited the stable supervisor marker"
  fi

  if ! rg -q '^root_present=$' "${sandbox}/stable-env.txt"; then
    sed -n '1,80p' "${sandbox}/stable-env.txt" >&2 || true
    fail "fake Codex child inherited the stable supervisor root marker"
  fi

  if ! find "${sandbox}/.self-harness/run" -maxdepth 1 -type f -name 'supervisor-stable-*.sh' | rg -q .; then
    fail "stable supervisor copy was not created"
  fi

  log "self-modified once survived from stable private copy"
}

check_idle_once_skips_launch() {
  local sandbox log_file status
  sandbox="${WORK_DIR}/idle-once"
  log_file="${WORK_DIR}/idle-once.log"
  prepare_common_sandbox "$sandbox"
  write_fail_codex "${sandbox}/bin"
  write_fake_git "${sandbox}/bin"
  printf '%s\n' '---' >"${sandbox}/memory/diary/existing.md"
  printf '%s\n' 'id: "diary-stable-copy-check-existing"' >>"${sandbox}/memory/diary/existing.md"
  printf '%s\n' 'title: "Existing Diary"' >>"${sandbox}/memory/diary/existing.md"
  printf '%s\n' 'type: "diary"' >>"${sandbox}/memory/diary/existing.md"
  printf '%s\n' 'status: "active"' >>"${sandbox}/memory/diary/existing.md"
  printf '%s\n' 'owner: "agent"' >>"${sandbox}/memory/diary/existing.md"
  printf '%s\n' 'created: "2026-05-07"' >>"${sandbox}/memory/diary/existing.md"
  printf '%s\n' 'updated: "2026-05-07"' >>"${sandbox}/memory/diary/existing.md"
  printf '%s\n' 'tags: [diary]' >>"${sandbox}/memory/diary/existing.md"
  printf '%s\n' 'summary: "Existing scratch diary for idle launch proof."' >>"${sandbox}/memory/diary/existing.md"
  printf '%s\n' '---' >>"${sandbox}/memory/diary/existing.md"
  printf '%s\n' '# Existing Diary' >>"${sandbox}/memory/diary/existing.md"

  set +e
  (
    cd "$sandbox"
    run_with_timeout 20 env \
      PATH="${sandbox}/bin:${PATH}" \
      SELF_HARNESS_AUTO_CHALLENGE=0 \
      SELF_HARNESS_SKIP_COMMIT=1 \
      bash scripts/supervisor.sh once
  ) >"$log_file" 2>&1
  status=$?
  set -e

  if [ "$status" -ne 0 ]; then
    sed -n '1,160p' "$log_file" >&2
    fail "idle once returned ${status}"
  fi

  if ! rg -q 'idle agent run skipped: no pending inbox after challenge seeding' "$log_file"; then
    sed -n '1,160p' "$log_file" >&2
    fail "idle once did not report the launch skip"
  fi

  log "idle once skipped launch without invoking Codex"
}

check_loop_handoff_with_valid_source_change() {
  local sandbox log_file status
  sandbox="${WORK_DIR}/loop-valid-source-change"
  log_file="${WORK_DIR}/loop-valid-source-change.log"
  prepare_common_sandbox "$sandbox"
  write_fake_codex "${sandbox}/bin" valid
  printf '%s\n' 'pending stable-copy loop handoff proof' >"${sandbox}/mailbox/inbox/pending-loop-handoff-proof.md"

  set +e
  (
    cd "$sandbox"
    run_with_timeout 20 env \
      PATH="${sandbox}/bin:${PATH}" \
      SELF_HARNESS_AUTO_CHALLENGE=0 \
      SELF_HARNESS_SKIP_COMMIT=1 \
      SELF_HARNESS_CODEX_MAX_RUNTIME_SECONDS=0 \
      SELF_HARNESS_CODEX_IDLE_TIMEOUT_SECONDS=0 \
      SELF_HARNESS_CODEX_WATCHDOG_POLL_SECONDS=1 \
      SELF_HARNESS_INTERVAL_SECONDS=60 \
      bash scripts/supervisor.sh loop
  ) >"$log_file" 2>&1
  status=$?
  set -e

  if [ "$status" -ne 0 ]; then
    sed -n '1,180p' "$log_file" >&2
    fail "valid loop source-change handoff returned ${status}"
  fi

  if ! rg -q 'supervisor source changed during stable-copy loop and passed readiness check; exiting' "$log_file"; then
    sed -n '1,180p' "$log_file" >&2
    fail "loop did not exit after the checked-out supervisor changed to valid shell"
  fi

  log "loop exited after valid supervisor source change for restart handoff"
}

check_loop_blocks_invalid_source_change() {
  local sandbox log_file status
  sandbox="${WORK_DIR}/loop-invalid-source-change"
  log_file="${WORK_DIR}/loop-invalid-source-change.log"
  prepare_common_sandbox "$sandbox"
  write_fake_codex "${sandbox}/bin" invalid
  printf '%s\n' 'pending stable-copy invalid loop handoff proof' >"${sandbox}/mailbox/inbox/pending-loop-invalid-handoff-proof.md"

  set +e
  (
    cd "$sandbox"
    run_with_timeout 20 env \
      PATH="${sandbox}/bin:${PATH}" \
      SELF_HARNESS_AUTO_CHALLENGE=0 \
      SELF_HARNESS_SKIP_COMMIT=1 \
      SELF_HARNESS_CODEX_MAX_RUNTIME_SECONDS=0 \
      SELF_HARNESS_CODEX_IDLE_TIMEOUT_SECONDS=0 \
      SELF_HARNESS_CODEX_WATCHDOG_POLL_SECONDS=1 \
      SELF_HARNESS_INTERVAL_SECONDS=60 \
      bash scripts/supervisor.sh loop
  ) >"$log_file" 2>&1
  status=$?
  set -e

  if [ "$status" -ne 124 ]; then
    sed -n '1,220p' "$log_file" >&2
    fail "invalid loop source-change returned ${status}; expected timeout with stable copy still in control"
  fi

  if ! rg -q 'supervisor source changed during stable-copy loop but failed readiness check; keeping stable copy in control' "$log_file"; then
    sed -n '1,220p' "$log_file" >&2
    fail "loop did not report blocked handoff for invalid checked-out supervisor"
  fi

  if rg -q 'passed readiness check; exiting' "$log_file"; then
    sed -n '1,220p' "$log_file" >&2
    fail "loop treated invalid checked-out supervisor as a safe handoff"
  fi

  if [ ! -f "${sandbox}/scripts/supervisor.sh" ]; then
    fail "invalid fixture did not leave a checked-out supervisor file"
  fi

  if bash -n "${sandbox}/scripts/supervisor.sh" 2>/dev/null; then
    fail "invalid fixture did not create a syntactically invalid checked-out supervisor"
  fi

  log "loop blocked handoff after invalid supervisor source change"
}

main() {
  mkdir -p "$WORK_DIR"
  check_self_modified_once_survives
  check_idle_once_skips_launch
  check_loop_handoff_with_valid_source_change
  check_loop_blocks_invalid_source_change
  log "ok"
}

main "$@"
