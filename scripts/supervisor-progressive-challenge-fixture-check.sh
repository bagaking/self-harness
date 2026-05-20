#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
WORK_DIR="${REPO_ROOT}/.self-harness/tmp/supervisor-progressive-challenge-fixture"

fail() {
  echo "supervisor-progressive-challenge-fixture-check: $*" >&2
  exit 1
}

fixture_log() {
  echo "supervisor-progressive-challenge-fixture-check: $*"
}

write_outbox_with_next_pressure() {
  local file="${WORK_DIR}/mailbox/outbox/2026-05-20-process-saturation.md"

  cat >"$file" <<'EOF'
---
id: "fixture-process-saturation"
title: "Fixture Process Saturation"
type: "mailbox-message"
status: "done"
owner: "agent"
created: "2026-05-20"
updated: "2026-05-20"
from: "agent"
to: "supervisor"
message_id: "fixture-process-saturation"
tags:
  - fixture
summary: "Fixture outbox report with a concrete next supervisor pressure."
---

# Fixture Process Saturation

Next supervisor pressure: give no1 one concrete non-mailbox, non-process repository task with rerunnable task-specific acceptance criteria.
EOF
}

prepare_sandbox() {
  rm -rf "$WORK_DIR"
  mkdir -p "${WORK_DIR}/mailbox/inbox" "${WORK_DIR}/mailbox/outbox"
  write_outbox_with_next_pressure
}

source_supervisor_functions() {
  # Load functions without executing the command dispatcher at the bottom.
  local functions_file="${WORK_DIR}/supervisor-functions.sh"
  sed '/^case /,$d' "${REPO_ROOT}/scripts/supervisor.sh" >"$functions_file"
  # shellcheck source=/dev/null
  source "$functions_file"
}

check_latest_outbox_pressure_is_carried_forward() {
  local fixture

  prepare_sandbox
  source_supervisor_functions
  ROOT_DIR="$WORK_DIR"

  write_progressive_challenge \
    "2026-05-20-fixture-progressive-supervisor-challenge" \
    "agent/no1_background_flash_suppression" \
    "2026-05-20"

  fixture="${WORK_DIR}/mailbox/inbox/2026-05-20-fixture-progressive-supervisor-challenge.md"
  [ -f "$fixture" ] || fail "progressive challenge was not written"

  rg -q 'Latest outbox next supervisor pressure .*concrete non-mailbox, non-process repository task' "$fixture" \
    || fail "generated challenge did not carry the latest outbox next pressure"
  rg -q 'that line as the specific pressure to answer' "$fixture" \
    || fail "generated challenge did not tell the agent to answer the carried pressure"
}

main() {
  check_latest_outbox_pressure_is_carried_forward
  fixture_log "ok"
}

main "$@"
