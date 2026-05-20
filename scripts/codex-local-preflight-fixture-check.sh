#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
WORK_DIR="${ROOT_DIR}/.self-harness/tmp/codex-local-preflight-fixture"

fail() {
  echo "codex-local-preflight-fixture-check: $*" >&2
  exit 1
}

log() {
  echo "codex-local-preflight-fixture-check: $*"
}

write_fake_codex() {
  local dir="$1"
  mkdir -p "$dir"
  {
    printf '%s\n' '#!/usr/bin/env bash'
    printf '%s\n' 'if [ -n "${SELF_HARNESS_FAKE_CODEX_CALLED:-}" ]; then'
    printf '%s\n' '  printf "called\n" >"$SELF_HARNESS_FAKE_CODEX_CALLED"'
    printf '%s\n' 'fi'
    printf '%s\n' 'exit 0'
  } >"${dir}/codex"
  chmod +x "${dir}/codex"
}

prepare_codex_links() {
  local sandbox="$1"
  mkdir -p "${sandbox}/.codex" "${sandbox}/skills" "${sandbox}/sessions"
  ln -s ../skills "${sandbox}/.codex/skills"
  ln -s ../sessions "${sandbox}/.codex/sessions"
}

prepare_supervisor_sandbox() {
  local sandbox="$1"
  mkdir -p "${sandbox}/scripts"
  cp "${ROOT_DIR}/scripts/supervisor.sh" "${sandbox}/scripts/supervisor.sh"
  cp "${ROOT_DIR}/scripts/init.sh" "${sandbox}/scripts/init.sh"
  cp "${ROOT_DIR}/scripts/codex-local-preflight-check.sh" "${sandbox}/scripts/codex-local-preflight-check.sh"
  chmod +x "${sandbox}/scripts/"*.sh
  prepare_codex_links "$sandbox"
}

check_direct_preflight_ready() {
  local sandbox fake_bin log_file
  sandbox="${WORK_DIR}/ready"
  fake_bin="${WORK_DIR}/bin-ready"
  log_file="${WORK_DIR}/ready.log"

  rm -rf "$sandbox" "$fake_bin"
  prepare_codex_links "$sandbox"
  write_fake_codex "$fake_bin"
  printf '%s\n' 'model = "fixture"' >"${sandbox}/.codex/config.toml"
  printf '%s\n' '{"fixture":true}' >"${sandbox}/.codex/auth.json"

  PATH="${fake_bin}:${PATH}" \
    "${ROOT_DIR}/scripts/codex-local-preflight-check.sh" --root "$sandbox" \
    >"$log_file" 2>&1 || {
      sed -n '1,120p' "$log_file" >&2
      fail "ready fixture should pass"
    }

  rg -q 'codex-local-preflight-check: ok' "$log_file" \
    || fail "ready fixture did not report ok"

  log "ready fixture passed"
}

check_missing_config_auth_blocks_supervisor() {
  local sandbox fake_bin log_file called_file status
  sandbox="${WORK_DIR}/missing-config-auth"
  fake_bin="${WORK_DIR}/bin-missing"
  log_file="${WORK_DIR}/missing-config-auth.log"
  called_file="${WORK_DIR}/missing-codex-called"

  rm -rf "$sandbox" "$fake_bin" "$called_file"
  prepare_supervisor_sandbox "$sandbox"
  write_fake_codex "$fake_bin"

  set +e
  (
    cd "$sandbox"
    env -u OPENAI_API_KEY -u CODEX_API_KEY \
      PATH="${fake_bin}:${PATH}" \
      SELF_HARNESS_AUTO_CHALLENGE=0 \
      SELF_HARNESS_SKIP_COMMIT=1 \
      SELF_HARNESS_FAKE_CODEX_CALLED="$called_file" \
      scripts/supervisor.sh once
  ) >"$log_file" 2>&1
  status=$?
  set -e

  if [ "$status" -eq 0 ]; then
    sed -n '1,120p' "$log_file" >&2
    fail "missing config/auth fixture unexpectedly passed"
  fi

  if [ -f "$called_file" ]; then
    sed -n '1,120p' "$log_file" >&2
    fail "supervisor invoked codex despite failed preflight"
  fi

  rg -q 'codex-local-preflight-check: failed' "$log_file" \
    || fail "missing config/auth fixture did not report preflight failure"
  rg -q '\.codex/config\.toml is missing or empty' "$log_file" \
    || fail "missing config/auth fixture did not name missing config"
  rg -q '\.codex/auth\.json is missing or empty' "$log_file" \
    || fail "missing config/auth fixture did not name missing auth"

  log "missing config/auth blocked supervisor before codex launch"
}

main() {
  mkdir -p "$WORK_DIR"
  check_direct_preflight_ready
  check_missing_config_auth_blocks_supervisor
  log "ok"
}

main "$@"
