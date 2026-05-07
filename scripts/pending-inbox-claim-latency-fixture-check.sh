#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
WORK_DIR="${ROOT_DIR}/.self-harness/tmp/pending-inbox-claim-latency-fixture-check"

fail() {
  echo "pending-inbox-claim-latency-fixture-check: $*" >&2
  exit 1
}

log() {
  echo "pending-inbox-claim-latency-fixture-check: $*"
}

prepare_sandbox() {
  local sandbox="$1"

  rm -rf "$sandbox"
  mkdir -p "${sandbox}/scripts" "${sandbox}/sessions"

  cp "${ROOT_DIR}/scripts/pending-inbox-claim-latency-check.sh" "${sandbox}/scripts/"
  cp "${ROOT_DIR}/scripts/pending-inbox-claim-latency-gate-check.sh" "${sandbox}/scripts/"
  chmod +x "${sandbox}/scripts/pending-inbox-claim-latency-check.sh"
  chmod +x "${sandbox}/scripts/pending-inbox-claim-latency-gate-check.sh"
}

prepare_gate_sandbox() {
  local sandbox="$1"

  prepare_sandbox "$sandbox"
  git -C "$sandbox" init -q
  git -C "$sandbox" checkout -q -b agent/pending-inbox-claim-latency-gate
  git -C "$sandbox" config user.name "Self Harness Fixture"
  git -C "$sandbox" config user.email "self-harness-fixture@example.invalid"
  git -C "$sandbox" add -- scripts
  git -C "$sandbox" commit -q -m "fixture: initial claim-latency gate sandbox"
}

write_delayed_claim_session() {
  local file="$1"
  cat >"$file" <<'EOF'
{"timestamp":"2026-05-07T00:00:00.000Z","type":"session_meta","payload":{"id":"delayed-claim"}}
{"timestamp":"2026-05-07T00:00:00.100Z","type":"response_item","payload":{"type":"message","role":"user","content":[{"type":"input_text","text":"Pending mailbox before launch:\n- mailbox/inbox/pending-task.md\n\nMailbox priority:\n- After reading AGENTS.md and constitution/00-charter.md, inspect the listed pending inbox before any broad repository sweep."}]}}
{"timestamp":"2026-05-07T00:00:05.000Z","type":"response_item","payload":{"type":"function_call","name":"exec_command","arguments":"{\"cmd\":\"sed -n '1,220p' AGENTS.md\"}"}}
{"timestamp":"2026-05-07T00:00:10.000Z","type":"response_item","payload":{"type":"function_call","name":"exec_command","arguments":"{\"cmd\":\"sed -n '1,260p' constitution/00-charter.md\"}"}}
{"timestamp":"2026-05-07T00:01:20.000Z","type":"response_item","payload":{"type":"function_call","name":"exec_command","arguments":"{\"cmd\":\"scripts/query-docs.sh constitution mailbox\"}"}}
{"timestamp":"2026-05-07T00:02:40.000Z","type":"response_item","payload":{"type":"function_call","name":"exec_command","arguments":"{\"cmd\":\"find mailbox/inbox mailbox/processing mailbox/done mailbox/outbox mailbox/failed -maxdepth 1 -type f | sort\"}"}}
{"timestamp":"2026-05-07T00:03:30.000Z","type":"response_item","payload":{"type":"function_call","name":"exec_command","arguments":"{\"cmd\":\"mv mailbox/inbox/pending-task.md mailbox/processing/pending-task.md\"}"}}
EOF
}

write_claim_first_session() {
  local file="$1"
  cat >"$file" <<'EOF'
{"timestamp":"2026-05-07T00:00:00.000Z","type":"session_meta","payload":{"id":"claim-first"}}
{"timestamp":"2026-05-07T00:00:00.100Z","type":"response_item","payload":{"type":"message","role":"user","content":[{"type":"input_text","text":"Pending mailbox before launch:\n- mailbox/inbox/pending-task.md\n\nMailbox priority:\n- After reading AGENTS.md and constitution/00-charter.md, inspect the listed pending inbox before any broad repository sweep."}]}}
{"timestamp":"2026-05-07T00:00:03.000Z","type":"response_item","payload":{"type":"function_call","name":"exec_command","arguments":"{\"cmd\":\"sed -n '1,220p' AGENTS.md\"}"}}
{"timestamp":"2026-05-07T00:00:06.000Z","type":"response_item","payload":{"type":"function_call","name":"exec_command","arguments":"{\"cmd\":\"sed -n '1,260p' constitution/00-charter.md\"}"}}
{"timestamp":"2026-05-07T00:00:11.000Z","type":"response_item","payload":{"type":"function_call","name":"exec_command","arguments":"{\"cmd\":\"mv mailbox/inbox/pending-task.md mailbox/processing/\"}"}}
{"timestamp":"2026-05-07T00:00:20.000Z","type":"response_item","payload":{"type":"function_call","name":"exec_command","arguments":"{\"cmd\":\"scripts/query-docs.sh mailbox feedback\"}"}}
EOF
}

write_no_pending_session() {
  local file="$1"
  cat >"$file" <<'EOF'
{"timestamp":"2026-05-07T00:00:00.000Z","type":"session_meta","payload":{"id":"no-pending"}}
{"timestamp":"2026-05-07T00:00:00.100Z","type":"response_item","payload":{"type":"message","role":"user","content":[{"type":"input_text","text":"Pending mailbox before launch:\n- none"}]}}
{"timestamp":"2026-05-07T00:00:03.000Z","type":"response_item","payload":{"type":"function_call","name":"exec_command","arguments":"{\"cmd\":\"scripts/query-docs.sh constitution mailbox\"}"}}
EOF
}

run_scanner() {
  local sandbox="$1"
  local session="$2"
  local log_file="$3"
  set +e
  (
    cd "$sandbox"
    bash scripts/pending-inbox-claim-latency-check.sh --max-seconds 90 "$session"
  ) >"$log_file" 2>&1
  local status=$?
  set -e
  return "$status"
}

check_rejects_delayed_broad_claim() {
  local sandbox log_file session status
  sandbox="${WORK_DIR}/delayed"
  log_file="${WORK_DIR}/delayed.log"
  session="${sandbox}/sessions/delayed.jsonl"
  prepare_sandbox "$sandbox"
  write_delayed_claim_session "$session"

  if run_scanner "$sandbox" "$session" "$log_file"; then
    status=0
  else
    status=$?
  fi

  [ "$status" -eq 1 ] || {
    sed -n '1,160p' "$log_file" >&2
    fail "delayed broad claim returned ${status}, expected 1"
  }
  rg -q 'broad pre-claim commands:' "$log_file" || fail "delayed claim did not report broad pre-claim commands"
  rg -q 'scripts/query-docs.sh constitution mailbox' "$log_file" || fail "delayed claim did not name query-docs as pre-claim evidence"
  rg -q 'claim_delay_seconds: 210' "$log_file" || fail "delayed claim did not report the expected claim delay"

  log "rejects delayed claim with broad pre-claim discovery"
}

check_allows_claim_first() {
  local sandbox log_file session
  sandbox="${WORK_DIR}/claim-first"
  log_file="${WORK_DIR}/claim-first.log"
  session="${sandbox}/sessions/claim-first.jsonl"
  prepare_sandbox "$sandbox"
  write_claim_first_session "$session"

  run_scanner "$sandbox" "$session" "$log_file" || {
    sed -n '1,160p' "$log_file" >&2
    fail "claim-first session should pass"
  }
  rg -q 'pending-inbox-claim-latency-check: ok .*claim_delay_seconds=11' "$log_file" || fail "claim-first pass did not report the expected claim delay"

  log "allows claim-first pending inbox launch"
}

check_skips_no_pending_prompt() {
  local sandbox log_file session
  sandbox="${WORK_DIR}/no-pending"
  log_file="${WORK_DIR}/no-pending.log"
  session="${sandbox}/sessions/no-pending.jsonl"
  prepare_sandbox "$sandbox"
  write_no_pending_session "$session"

  run_scanner "$sandbox" "$session" "$log_file" || {
    sed -n '1,160p' "$log_file" >&2
    fail "no-pending session should be skipped, not failed"
  }
  rg -q 'skip .*no pending-inbox launch prompt' "$log_file" || fail "no-pending prompt was not skipped"

  log "skips sessions without pending inbox launch"
}

run_gate() {
  local sandbox="$1"
  local log_file="$2"
  set +e
  (
    cd "$sandbox"
    bash scripts/pending-inbox-claim-latency-gate-check.sh
  ) >"$log_file" 2>&1
  local status=$?
  set -e
  return "$status"
}

check_gate_rejects_changed_delayed_session() {
  local sandbox log_file session status
  sandbox="${WORK_DIR}/gate-delayed"
  log_file="${WORK_DIR}/gate-delayed.log"
  session="${sandbox}/sessions/delayed.jsonl"
  prepare_gate_sandbox "$sandbox"
  write_delayed_claim_session "$session"

  if run_gate "$sandbox" "$log_file"; then
    status=0
  else
    status=$?
  fi
  [ "$status" -eq 1 ] || {
    sed -n '1,180p' "$log_file" >&2
    fail "gate delayed session returned ${status}, expected 1"
  }
  rg -q 'pending-inbox-claim-latency-check: FAIL sessions/delayed.jsonl' "$log_file" || fail "gate delayed session did not scan the changed transcript"
  rg -q 'broad pre-claim commands:' "$log_file" || fail "gate delayed session did not report broad pre-claim commands"

  log "gate rejects changed delayed pending inbox transcript"
}

check_gate_allows_changed_claim_first_session() {
  local sandbox log_file session
  sandbox="${WORK_DIR}/gate-claim-first"
  log_file="${WORK_DIR}/gate-claim-first.log"
  session="${sandbox}/sessions/claim-first.jsonl"
  prepare_gate_sandbox "$sandbox"
  write_claim_first_session "$session"

  run_gate "$sandbox" "$log_file" || {
    sed -n '1,180p' "$log_file" >&2
    fail "gate claim-first session should pass"
  }
  rg -q 'pending-inbox-claim-latency-check: ok .*claim_delay_seconds=11' "$log_file" || fail "gate claim-first session did not report the expected claim delay"

  log "gate allows changed claim-first pending inbox transcript"
}

main() {
  rm -rf "$WORK_DIR"
  mkdir -p "$WORK_DIR"
  check_rejects_delayed_broad_claim
  check_allows_claim_first
  check_skips_no_pending_prompt
  check_gate_rejects_changed_delayed_session
  check_gate_allows_changed_claim_first_session
  log "ok"
}

main "$@"
