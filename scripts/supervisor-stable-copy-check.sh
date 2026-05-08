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
    "${sandbox}/constitution" \
    "${sandbox}/scripts" \
    "${sandbox}/mailbox/inbox" \
    "${sandbox}/mailbox/processing" \
    "${sandbox}/mailbox/outbox" \
    "${sandbox}/mailbox/done" \
    "${sandbox}/mailbox/failed" \
    "${sandbox}/memory/diary" \
    "${sandbox}/bin"

  cp "${ROOT_DIR}/constitution/"*.md "${sandbox}/constitution/"
  cp "${ROOT_DIR}/scripts/"*.sh "${sandbox}/scripts/"
}

write_idle_skip_stop_safe_history() {
  local sandbox="$1"

  git -C "$sandbox" init -q
  git -C "$sandbox" checkout -q -b agent/stable-copy-check
  git -C "$sandbox" config user.name "Self Harness Fixture"
  git -C "$sandbox" config user.email "self-harness-fixture@example.invalid"

  {
    printf '%s\n' '/.codex/'
    printf '%s\n' '/.self-harness/'
  } >"${sandbox}/.gitignore"

  git -C "$sandbox" add --all -- .
  git -C "$sandbox" commit -q -m "fixture: stable copy idle baseline"

  cat >"${sandbox}/mailbox/outbox/2026-05-08-stable-copy-clean-stop-reply.md" <<'OUTBOX'
---
id: "mailbox-outbox-stable-copy-clean-stop-reply"
title: "Stable Copy Clean Stop Reply"
type: "mailbox-message"
status: "done"
owner: "agent"
created: "2026-05-08"
updated: "2026-05-08"
from: "agent/stable-copy-check"
to: "supervisor"
message_id: "stable-copy-clean-stop-reply"
tags:
  - mailbox
  - feedback-pressure
summary: "Fixture run-linked outbox that keeps stable-copy idle skip stop-safe."
related: []
---

# Stable Copy Clean Stop Reply

Return-to-main judgment: defer. This fixture remains branch-local.

No next supervisor pressure: further escalation would be noisy because this fixture only proves stable-copy idle skip can stop after the stop proof passes.

Supervisor evaluation trigger: run `scripts/supervisor-stable-copy-check.sh`; reopen only if the idle-skip fixture launches Codex or stops without a passing stop proof.

Stop condition: if the stable-copy idle fixture records a passing stop proof and does not invoke Codex, stop.
OUTBOX

  git -C "$sandbox" add --all -- .
  git -C "$sandbox" commit -q -m "run: Stable Copy Clean Stop Reply"
}

write_frontmatter_mailbox_message() {
  local file="$1"
  local id="$2"
  {
    printf '%s\n' '---'
    printf 'id: "%s"\n' "mailbox-inbox-${id}"
    printf '%s\n' 'title: "Stable Copy Fixture Message"'
    printf '%s\n' 'type: "mailbox-message"'
    printf '%s\n' 'status: "pending"'
    printf '%s\n' 'owner: "agent"'
    printf '%s\n' 'created: "2026-05-07"'
    printf '%s\n' 'updated: "2026-05-07"'
    printf '%s\n' 'tags:'
    printf '%s\n' '  - mailbox'
    printf '%s\n' 'summary: "Scratch mailbox input for stable-copy proof fixtures."'
    printf '%s\n' '---'
    printf '%s\n' ''
    printf '%s\n' '# Stable Copy Fixture Message'
  } >"$file"
}

write_fake_commit_path_git() {
  local dir="$1"
  local recovery_commit_status="${2:-0}"
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
    printf '%s\n' '  "log --format=%s -n 12")'
    printf '%s\n' '    exit 0'
    printf '%s\n' '    ;;'
    printf '%s\n' '  "diff --quiet -- constitution/")'
    printf '%s\n' '    exit 0'
    printf '%s\n' '    ;;'
    printf '%s\n' '  "diff --cached --quiet -- constitution/")'
    printf '%s\n' '    exit 0'
    printf '%s\n' '    ;;'
    printf '%s\n' '  "ls-files --others --exclude-standard -- constitution/")'
    printf '%s\n' '    exit 0'
    printf '%s\n' '    ;;'
    printf '%s\n' '  "diff --name-only")'
    printf '%s\n' '    echo "scripts/supervisor.sh"'
    printf '%s\n' '    exit 0'
    printf '%s\n' '    ;;'
    printf '%s\n' '  "diff --name-only --diff-filter=ACMR")'
    printf '%s\n' '    echo "scripts/supervisor.sh"'
    printf '%s\n' '    exit 0'
    printf '%s\n' '    ;;'
    printf '%s\n' '  "diff --name-only --diff-filter=ACMRT")'
    printf '%s\n' '    echo "scripts/supervisor.sh"'
    printf '%s\n' '    exit 0'
    printf '%s\n' '    ;;'
    printf '%s\n' '  "diff --cached --name-only")'
    printf '%s\n' '    exit 0'
    printf '%s\n' '    ;;'
    printf '%s\n' '  "diff --cached --name-only --diff-filter=ACMR")'
    printf '%s\n' '    exit 0'
    printf '%s\n' '    ;;'
    printf '%s\n' '  "diff --cached --name-only --diff-filter=ACMRT")'
    printf '%s\n' '    exit 0'
    printf '%s\n' '    ;;'
    printf '%s\n' '  "ls-files --others --exclude-standard")'
    printf '%s\n' '    if [ -d memory/incidents ]; then'
    printf '%s\n' '      find memory/incidents -maxdepth 1 -type f -name "*.md" | sort'
    printf '%s\n' '    fi'
    printf '%s\n' '    exit 0'
    printf '%s\n' '    ;;'
    printf '%s\n' '  "diff --name-only --cached")'
    printf '%s\n' '    exit 0'
    printf '%s\n' '    ;;'
    printf '%s\n' '  "status --porcelain --untracked-files=all")'
    printf '%s\n' '    echo " M scripts/supervisor.sh"'
    printf '%s\n' '    if [ -d memory/incidents ]; then'
    printf '%s\n' '      find memory/incidents -maxdepth 1 -type f -name "*.md" | sort | sed "s/^/?? /"'
    printf '%s\n' '    fi'
    printf '%s\n' '    exit 0'
    printf '%s\n' '    ;;'
    printf '%s\n' '  "add --all -- .")'
    printf '%s\n' '    exit 0'
    printf '%s\n' '    ;;'
    printf '%s\n' '  "diff --cached --quiet")'
    printf '%s\n' '    exit 1'
    printf '%s\n' '    ;;'
    printf '%s\n' '  commit\ -m\ incident:*)'
    printf '    exit %s\n' "$recovery_commit_status"
    printf '%s\n' '    ;;'
    printf '%s\n' '  *)'
    printf '%s\n' '    echo "unexpected fake git command: $*" >&2'
    printf '%s\n' '    exit 2'
    printf '%s\n' '    ;;'
    printf '%s\n' 'esac'
  } >"${dir}/git"
  chmod +x "${dir}/git"
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

  if bash -n "${sandbox}/scripts/supervisor.sh" 2>/dev/null; then
    fail "skip-commit fixture should leave invalid checked-out supervisor source for the handoff gate"
  fi

  log "self-modified once survived from stable private copy"
}

check_idle_once_skips_launch() {
  local sandbox log_file status
  sandbox="${WORK_DIR}/idle-once"
  log_file="${WORK_DIR}/idle-once.log"
  prepare_common_sandbox "$sandbox"
  write_fail_codex "${sandbox}/bin"
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
  write_idle_skip_stop_safe_history "$sandbox"

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

  if ! rg -q 'idle stop proof ok: \.self-harness/tmp/idle-stop-proof-' "$log_file"; then
    sed -n '1,160p' "$log_file" >&2
    fail "idle once did not record a passing stop proof"
  fi

  if ! rg -q 'idle agent run skipped: stop proof ok and no pending inbox after challenge seeding' "$log_file"; then
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
  write_frontmatter_mailbox_message "${sandbox}/mailbox/inbox/pending-loop-invalid-handoff-proof.md" "pending-loop-invalid-handoff-proof"

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

check_loop_commit_path_recovers_invalid_source_change() {
  local sandbox log_file status
  sandbox="${WORK_DIR}/loop-invalid-source-change-normal-commit"
  log_file="${WORK_DIR}/loop-invalid-source-change-normal-commit.log"
  prepare_common_sandbox "$sandbox"
  write_fake_codex "${sandbox}/bin" invalid
  write_fake_commit_path_git "${sandbox}/bin"
  write_frontmatter_mailbox_message "${sandbox}/mailbox/inbox/pending-loop-invalid-normal-commit-proof.md" "pending-loop-invalid-normal-commit-proof"

  set +e
  (
    cd "$sandbox"
    run_with_timeout 20 env \
      PATH="${sandbox}/bin:${PATH}" \
      SELF_HARNESS_AUTO_CHALLENGE=0 \
      SELF_HARNESS_CODEX_MAX_RUNTIME_SECONDS=0 \
      SELF_HARNESS_CODEX_IDLE_TIMEOUT_SECONDS=0 \
      SELF_HARNESS_CODEX_WATCHDOG_POLL_SECONDS=1 \
      SELF_HARNESS_INTERVAL_SECONDS=60 \
      bash scripts/supervisor.sh loop
  ) >"$log_file" 2>&1
  status=$?
  set -e

  if [ "$status" -ne 0 ]; then
    sed -n '1,260p' "$log_file" >&2
    fail "invalid normal-commit loop returned ${status}; expected recovery and clean handoff"
  fi

  if ! rg -q 'post-run commit gate failed; asking Codex session for one repair attempt' "$log_file"; then
    sed -n '1,260p' "$log_file" >&2
    fail "normal commit path did not invoke the commit-gate repair path"
  fi

  if ! rg -q 'shell-syntax-check: failed scripts/supervisor.sh' "$log_file"; then
    sed -n '1,260p' "$log_file" >&2
    fail "normal commit path did not detect the invalid checked-out supervisor through shell syntax validation"
  fi

  if ! rg -q 'recovered invalid checked-out supervisor source from stable copy' "$log_file"; then
    sed -n '1,260p' "$log_file" >&2
    fail "normal commit path did not recover invalid checked-out supervisor source"
  fi

  if ! rg -q 'committed invalid supervisor recovery incident' "$log_file"; then
    sed -n '1,260p' "$log_file" >&2
    fail "normal commit path did not mark recovery successful after the incident commit"
  fi

  if rg -q 'unexpected fake git command: add ' "$log_file"; then
    sed -n '1,260p' "$log_file" >&2
    fail "normal commit path staged changes through fake git; fixture no longer covers the command surface"
  fi

  if rg -q 'unexpected fake git command: commit ' "$log_file"; then
    sed -n '1,260p' "$log_file" >&2
    fail "normal commit path attempted a fake git commit; fixture no longer covers the command surface"
  fi

  if ! rg -q 'supervisor source recovered during stable-copy loop; exiting so the next start uses checked-out source' "$log_file"; then
    sed -n '1,260p' "$log_file" >&2
    fail "loop did not report the explicit recovered-source exit"
  fi

  if rg -q 'supervisor source changed during stable-copy loop but failed readiness check' "$log_file"; then
    sed -n '1,260p' "$log_file" >&2
    fail "normal commit path still left blocked invalid supervisor source after recovery"
  fi

  if rg -q 'unexpected fake git command' "$log_file"; then
    sed -n '1,260p' "$log_file" >&2
    fail "normal commit fixture did not cover the supervisor git command surface"
  fi

  if ! bash -n "${sandbox}/scripts/supervisor.sh" 2>/dev/null; then
    fail "normal commit recovery did not leave a syntactically valid checked-out supervisor"
  fi

  if ! find "${sandbox}/memory/incidents" -maxdepth 1 -type f -name '*invalid-supervisor-recovery.md' | rg -q .; then
    fail "normal commit recovery did not write an invalid-supervisor recovery incident"
  fi

  if ! rg -q 'Discarded Invalid Supervisor Diff' "${sandbox}"/memory/incidents/*invalid-supervisor-recovery.md; then
    fail "normal commit recovery incident did not include bounded discarded-source evidence"
  fi

  if ! rg -q 'broken quote' "${sandbox}"/memory/incidents/*invalid-supervisor-recovery.md; then
    fail "normal commit recovery incident did not capture the discarded invalid source excerpt"
  fi

  log "normal commit path recovered invalid supervisor source before safe handoff"
}

check_loop_recovery_commit_failure_is_not_safe_exit() {
  local sandbox log_file status
  sandbox="${WORK_DIR}/loop-recovery-commit-failure"
  log_file="${WORK_DIR}/loop-recovery-commit-failure.log"
  prepare_common_sandbox "$sandbox"
  write_fake_codex "${sandbox}/bin" invalid
  write_fake_commit_path_git "${sandbox}/bin" 73
  write_frontmatter_mailbox_message "${sandbox}/mailbox/inbox/pending-recovery-commit-failure-proof.md" "pending-recovery-commit-failure-proof"

  set +e
  (
    cd "$sandbox"
    run_with_timeout 20 env \
      PATH="${sandbox}/bin:${PATH}" \
      SELF_HARNESS_AUTO_CHALLENGE=0 \
      SELF_HARNESS_CODEX_MAX_RUNTIME_SECONDS=0 \
      SELF_HARNESS_CODEX_IDLE_TIMEOUT_SECONDS=0 \
      SELF_HARNESS_CODEX_WATCHDOG_POLL_SECONDS=1 \
      SELF_HARNESS_INTERVAL_SECONDS=60 \
      bash scripts/supervisor.sh loop
  ) >"$log_file" 2>&1
  status=$?
  set -e

  if [ "$status" -eq 0 ] || [ "$status" -eq 124 ]; then
    sed -n '1,300p' "$log_file" >&2
    fail "recovery commit failure loop returned ${status}; expected a bounded nonzero failure"
  fi

  if ! rg -q 'post-run recovery commit failed' "$log_file"; then
    sed -n '1,300p' "$log_file" >&2
    fail "recovery commit failure was not reported"
  fi

  if ! rg -q 'supervisor source recovery incident commit failed; exiting with failure for review' "$log_file"; then
    sed -n '1,300p' "$log_file" >&2
    fail "loop did not fail explicitly after recovery incident commit failure"
  fi

  if rg -q 'supervisor source recovered during stable-copy loop; exiting so the next start uses checked-out source' "$log_file"; then
    sed -n '1,300p' "$log_file" >&2
    fail "loop reported the recovered-source safe exit after the recovery commit failed"
  fi

  if rg -q 'committed invalid supervisor recovery incident' "$log_file"; then
    sed -n '1,300p' "$log_file" >&2
    fail "loop marked recovery committed even though the fake recovery commit failed"
  fi

  if ! bash -n "${sandbox}/scripts/supervisor.sh" 2>/dev/null; then
    fail "recovery commit failure should still restore parseable checked-out supervisor source before failing"
  fi

  if ! find "${sandbox}/memory/incidents" -maxdepth 1 -type f -name '*invalid-supervisor-recovery.md' | rg -q .; then
    fail "recovery commit failure did not leave an incident file for review"
  fi

  if ! rg -q 'Discarded Invalid Supervisor Diff' "${sandbox}"/memory/incidents/*invalid-supervisor-recovery.md; then
    fail "recovery commit failure incident did not include bounded discarded-source evidence"
  fi

  log "recovery commit failure exits nonzero without recovered-source safe handoff"
}

main() {
  mkdir -p "$WORK_DIR"
  check_self_modified_once_survives
  check_idle_once_skips_launch
  check_loop_handoff_with_valid_source_change
  check_loop_blocks_invalid_source_change
  check_loop_commit_path_recovers_invalid_source_change
  check_loop_recovery_commit_failure_is_not_safe_exit
  log "ok"
}

main "$@"
