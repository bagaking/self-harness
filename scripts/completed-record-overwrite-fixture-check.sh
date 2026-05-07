#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
WORK_DIR="${ROOT_DIR}/.self-harness/tmp/completed-record-overwrite-check"

fail() {
  echo "completed-record-overwrite-fixture-check: $*" >&2
  exit 1
}

log() {
  echo "completed-record-overwrite-fixture-check: $*"
}

write_doc() {
  local file="$1"
  local id="$2"
  local type="$3"
  local title="$4"
  mkdir -p "$(dirname "$file")"
  {
    printf '%s\n' '---'
    printf 'id: "%s"\n' "$id"
    printf 'title: "%s"\n' "$title"
    printf 'type: "%s"\n' "$type"
    printf '%s\n' 'status: "done"'
    printf '%s\n' 'owner: "agent"'
    printf '%s\n' 'created: "2026-05-07"'
    printf '%s\n' 'updated: "2026-05-07"'
    printf '%s\n' 'tags:'
    printf '%s\n' '  - fixture'
    printf 'summary: "Fixture document for %s."\n' "$title"
    printf '%s\n' '---'
    printf '%s\n' ''
    printf '# %s\n' "$title"
    printf '%s\n' ''
    printf '%s\n' 'Original completed record.'
  } >"$file"
}

prepare_sandbox() {
  local sandbox="$1"

  rm -rf "$sandbox"
  mkdir -p \
    "${sandbox}/scripts" \
    "${sandbox}/mailbox/outbox" \
    "${sandbox}/memory/diary" \
    "${sandbox}/memory/decisions"

  cp "${ROOT_DIR}/scripts/completed-record-overwrite-check.sh" "${sandbox}/scripts/"
  chmod +x "${sandbox}/scripts/completed-record-overwrite-check.sh"

  write_doc \
    "${sandbox}/mailbox/outbox/2026-05-07-existing-reply.md" \
    "mailbox-outbox-existing-reply" \
    "mailbox-message" \
    "Existing Reply"
  write_doc \
    "${sandbox}/memory/diary/2026-05-07-existing-diary.md" \
    "diary-existing" \
    "diary" \
    "Existing Diary"
  write_doc \
    "${sandbox}/memory/decisions/2026-05-07-existing-decision.md" \
    "decision-existing" \
    "memory" \
    "Existing Decision"

  git -C "$sandbox" init -q
  git -C "$sandbox" checkout -q -b agent/completed-record-overwrite-check
  git -C "$sandbox" config user.name "Self Harness Fixture"
  git -C "$sandbox" config user.email "self-harness-fixture@example.invalid"
  git -C "$sandbox" add --all -- .
  git -C "$sandbox" commit -q -m "fixture: completed records"
}

check_rejects_completed_record_modifications() {
  local sandbox log_file status
  sandbox="${WORK_DIR}/reject-existing"
  log_file="${WORK_DIR}/reject-existing.log"
  prepare_sandbox "$sandbox"

  {
    printf '%s\n' ''
    printf '%s\n' 'New run evidence written into the old outbox record.'
  } >>"${sandbox}/mailbox/outbox/2026-05-07-existing-reply.md"

  {
    printf '%s\n' ''
    printf '%s\n' 'New run evidence written into the old diary record.'
  } >>"${sandbox}/memory/diary/2026-05-07-existing-diary.md"

  set +e
  (
    cd "$sandbox"
    bash scripts/completed-record-overwrite-check.sh
  ) >"$log_file" 2>&1
  status=$?
  set -e

  if [ "$status" -eq 0 ]; then
    sed -n '1,160p' "$log_file" >&2
    fail "modified completed outbox and diary records were allowed"
  fi

  rg -q 'mailbox/outbox/2026-05-07-existing-reply.md' "$log_file" || {
    sed -n '1,160p' "$log_file" >&2
    fail "modified completed outbox record was not reported"
  }
  rg -q 'memory/diary/2026-05-07-existing-diary.md' "$log_file" || {
    sed -n '1,160p' "$log_file" >&2
    fail "modified completed diary record was not reported"
  }

  log "rejects modifications to existing completed outbox and diary records"
}

check_allows_new_records_and_decision_update() {
  local sandbox log_file
  sandbox="${WORK_DIR}/allow-new"
  log_file="${WORK_DIR}/allow-new.log"
  prepare_sandbox "$sandbox"

  write_doc \
    "${sandbox}/mailbox/outbox/2026-05-07-new-reply.md" \
    "mailbox-outbox-new-reply" \
    "mailbox-message" \
    "New Reply"
  write_doc \
    "${sandbox}/memory/diary/2026-05-07-new-diary.md" \
    "diary-new" \
    "diary" \
    "New Diary"

  {
    printf '%s\n' ''
    printf '%s\n' 'Updated durable decision evidence.'
  } >>"${sandbox}/memory/decisions/2026-05-07-existing-decision.md"

  (
    cd "$sandbox"
    bash scripts/completed-record-overwrite-check.sh
  ) >"$log_file" 2>&1

  rg -q 'completed-record-overwrite-check: ok' "$log_file" || {
    sed -n '1,160p' "$log_file" >&2
    fail "new outbox/diary plus memory decision update should pass"
  }

  log "allows new outbox and diary records while updating memory decisions"
}

main() {
  mkdir -p "$WORK_DIR"
  check_rejects_completed_record_modifications
  check_allows_new_records_and_decision_update
  log "ok"
}

main "$@"
