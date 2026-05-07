#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
WORK_DIR="${ROOT_DIR}/.self-harness/tmp/feedback-command-cycle-check"

fail() {
  echo "feedback-command-cycle-check: $*" >&2
  exit 1
}

log() {
  echo "feedback-command-cycle-check: $*"
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

write_fake_codex() {
  local dir="$1"
  mkdir -p "$dir"
  cat >"${dir}/codex" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

repo=""
output=""
while [ "$#" -gt 0 ]; do
  case "$1" in
    --cd)
      shift
      repo="${1:-}"
      ;;
    --output-last-message)
      shift
      output="${1:-}"
      ;;
  esac
  shift || break
done

if [ -z "$repo" ]; then
  repo="$(pwd)"
fi

cd "$repo"
mkdir -p .self-harness/tmp mailbox/done memory/diary
cat > .self-harness/tmp/fake-codex-prompt.txt
printf 'fake feedback cycle complete\n' >> .self-harness/tmp/fake-codex-invocations.log

if [ -n "$output" ]; then
  mkdir -p "$(dirname "$output")"
  printf 'Completed fake feedback cycle Codex run\n' >"$output"
fi

inbox_file="$(find mailbox/inbox -maxdepth 1 -type f -name '*feedback-pressure-challenge.md' | sort | head -1)"
if [ -z "$inbox_file" ]; then
  echo "fake codex: no feedback pressure inbox was available" >&2
  exit 3
fi

inbox_base="$(basename "$inbox_file" .md)"
sed 's/status: "pending"/status: "done"/' "$inbox_file" >"mailbox/done/$(basename "$inbox_file")"
rm -f "$inbox_file"

mkdir -p mailbox/outbox
cat > "mailbox/outbox/${inbox_base}-reply.md" <<OUTBOX
---
id: "mailbox-outbox-${inbox_base}-reply"
title: "Fake Feedback Cycle Reply"
type: "mailbox-message"
status: "done"
owner: "agent"
created: "2026-05-07"
updated: "2026-05-07"
from: "agent/feedback-cycle-check"
to: "supervisor"
message_id: "${inbox_base}-reply"
tags:
  - mailbox
  - feedback-pressure
summary: "Reports a fake feedback cycle that claimed a generated feedback pressure inbox."
related:
  - "mailbox-inbox-${inbox_base}"
---

# Fake Feedback Cycle Reply

## Reviewed Evidence

Reviewed the generated feedback pressure inbox and the fake launch prompt.

## Current Weakness

The exact current weakness under test is whether explicit feedback can seed an inbox that the next launch treats as claimed work instead of an idle skip.

## Refusal

Refused escalation in this scratch fixture because the useful evidence is the supervisor launch behavior, not another durable mechanism.

## Anti-Noise

This fixture avoids generic churn by moving only the generated feedback inbox through the mailbox lifecycle.

## Verification

Rerunnable verification is provided by \`scripts/feedback-command-cycle-check.sh\`.

## Return-To-Main

Return-to-main: no for this scratch fixture.

No next supervisor pressure: further escalation would be noisy because the fixture has already proved the generated inbox launch path.

Stop condition: rerun only if \`scripts/supervisor.sh feedback\` or \`build_pending_mailbox_prompt\` changes.
OUTBOX

cat > memory/diary/fake-feedback-cycle.md <<'DIARY'
---
id: "diary-fake-feedback-cycle"
title: "Fake Feedback Cycle"
type: "diary"
status: "active"
owner: "agent"
created: "2026-05-07"
updated: "2026-05-07"
tags:
  - diary
  - feedback-pressure
summary: "Records a fake Codex run that claimed a generated feedback pressure inbox."
source: "experiment"
confidence: "high"
related: []
---

# diary: fake feedback cycle

The fake Codex run claimed the generated feedback pressure inbox.
DIARY
EOF
  chmod +x "${dir}/codex"
}

prepare_sandbox() {
  local sandbox="$1"

  rm -rf "$sandbox"
  mkdir -p \
    "${sandbox}/bin" \
    "${sandbox}/constitution" \
    "${sandbox}/scripts" \
    "${sandbox}/mailbox/inbox" \
    "${sandbox}/mailbox/processing" \
    "${sandbox}/mailbox/outbox" \
    "${sandbox}/mailbox/done" \
    "${sandbox}/mailbox/failed" \
    "${sandbox}/memory/diary" \
    "${sandbox}/memory/decisions" \
    "${sandbox}/memory/lessons" \
    "${sandbox}/memory/proposals" \
    "${sandbox}/memory/incidents" \
    "${sandbox}/sessions" \
    "${sandbox}/skills"

  cp "${ROOT_DIR}/.gitignore" "${sandbox}/.gitignore"
  cp "${ROOT_DIR}/AGENTS.md" "${sandbox}/AGENTS.md"
  cp "${ROOT_DIR}/constitution/"*.md "${sandbox}/constitution/"
  cp "${ROOT_DIR}/scripts/"*.sh "${sandbox}/scripts/"
  chmod +x "${sandbox}/scripts/"*.sh
  write_fake_codex "${sandbox}/bin"

  git -C "$sandbox" init -q
  git -C "$sandbox" checkout -q -b agent/feedback-cycle-check
  git -C "$sandbox" config user.name "Self Harness Fixture"
  git -C "$sandbox" config user.email "self-harness-fixture@example.invalid"
  git -C "$sandbox" add --all -- .
  git -C "$sandbox" commit -q -m "fixture: initial feedback cycle sandbox"
}

commit_count() {
  git -C "$1" rev-list --count HEAD
}

assert_clean_worktree() {
  local sandbox="$1"
  local status
  status="$(git -C "$sandbox" status --porcelain --untracked-files=all)"
  [ -z "$status" ] || {
    printf '%s\n' "$status" >&2
    fail "$(basename "$sandbox"): expected a clean worktree"
  }
}

check_feedback_command_then_launch_claims_generated_inbox() {
  local sandbox feedback_log once_log status generated_count prompt
  sandbox="${WORK_DIR}/positive-cycle"
  feedback_log="${WORK_DIR}/positive-feedback.log"
  once_log="${WORK_DIR}/positive-once.log"
  prepare_sandbox "$sandbox"

  set +e
  (
    cd "$sandbox"
    SELF_HARNESS_AUTO_CHALLENGE=0 \
      bash scripts/supervisor.sh feedback \
      "Human feedback: prove explicit feedback creates the next claimed task instead of an idle skip."
  ) >"$feedback_log" 2>&1
  status=$?
  set -e

  if [ "$status" -ne 0 ]; then
    sed -n '1,160p' "$feedback_log" >&2
    fail "feedback command returned ${status}"
  fi

  generated_count="$(find "$sandbox/mailbox/inbox" -maxdepth 1 -type f -name '*feedback-pressure-challenge.md' | wc -l | tr -d '[:space:]')"
  [ "$generated_count" = "1" ] || fail "expected one generated feedback inbox before launch, found ${generated_count}"
  rg -q 'seeded feedback pressure challenge:' "$feedback_log" || fail "feedback command did not log challenge seeding"

  set +e
  (
    cd "$sandbox"
    run_with_timeout 30 env \
      PATH="${sandbox}/bin:${PATH}" \
      SELF_HARNESS_AUTO_CHALLENGE=0 \
      SELF_HARNESS_CODEX_MAX_RUNTIME_SECONDS=0 \
      SELF_HARNESS_CODEX_IDLE_TIMEOUT_SECONDS=0 \
      SELF_HARNESS_CODEX_WATCHDOG_POLL_SECONDS=1 \
      bash scripts/supervisor.sh once
  ) >"$once_log" 2>&1
  status=$?
  set -e

  if [ "$status" -ne 0 ]; then
    sed -n '1,220p' "$once_log" >&2
    fail "supervisor once returned ${status}"
  fi

  prompt="${sandbox}/.self-harness/tmp/fake-codex-prompt.txt"
  [ -f "$prompt" ] || fail "fake Codex did not capture a launch prompt"
  rg -q 'Pending mailbox before launch:' "$prompt" || fail "launch prompt omitted pending mailbox section"
  rg -q -- '- mailbox/inbox/.*feedback-pressure-challenge\.md' "$prompt" || fail "launch prompt did not include generated feedback inbox"
  rg -q 'Claim exactly one pending file by moving it from mailbox/inbox/ to mailbox/processing/' "$prompt" || fail "launch prompt omitted mailbox claim instruction"
  ! rg -q 'idle agent run skipped: no pending inbox after challenge seeding' "$once_log" || fail "supervisor skipped despite generated feedback inbox"
  [ ! -e "$sandbox/mailbox/inbox/"*feedback-pressure-challenge.md ] || fail "generated feedback inbox remained unclaimed after fake run"
  find "$sandbox/mailbox/done" -maxdepth 1 -type f -name '*feedback-pressure-challenge.md' | rg -q . || fail "fake run did not move generated feedback inbox to done"
  [ "$(wc -l <"${sandbox}/.self-harness/tmp/fake-codex-invocations.log" | tr -d '[:space:]')" = "1" ] || fail "expected one fake Codex invocation"
  [ "$(commit_count "$sandbox")" -eq 2 ] || fail "expected one supervisor commit after fake run"
  assert_clean_worktree "$sandbox"

  log "feedback command generated an inbox that the next launch prompted and claimed"
}

check_feedback_command_refuses_in_flight_processing() {
  local sandbox log_file status count
  sandbox="${WORK_DIR}/processing-guard"
  log_file="${WORK_DIR}/processing-guard.log"
  prepare_sandbox "$sandbox"

  cat >"${sandbox}/mailbox/processing/already-processing.md" <<'EOF'
---
id: "mailbox-processing-already-processing"
title: "Already Processing"
type: "mailbox-inbox"
status: "processing"
owner: "agent"
created: "2026-05-07"
updated: "2026-05-07"
from: "supervisor"
to: "agent/feedback-cycle-check"
message_id: "already-processing"
tags:
  - mailbox
summary: "Fixture in-flight processing item."
---

# Already Processing

This fixture represents claimed mailbox work.
EOF

  set +e
  (
    cd "$sandbox"
    SELF_HARNESS_AUTO_CHALLENGE=0 \
      bash scripts/supervisor.sh feedback \
      "Human feedback: do not stack pressure while processing is active."
  ) >"$log_file" 2>&1
  status=$?
  set -e

  [ "$status" -eq 1 ] || {
    sed -n '1,160p' "$log_file" >&2
    fail "processing guard returned ${status}, expected 1"
  }
  rg -q 'feedback challenge skipped: mailbox processing already exists' "$log_file" || fail "processing guard did not explain in-flight refusal"
  rg -q -- '- mailbox/processing/already-processing\.md' "$log_file" || fail "processing guard did not list processing file"
  count="$(find "$sandbox/mailbox/inbox" -maxdepth 1 -type f -name '*feedback-pressure-challenge.md' | wc -l | tr -d '[:space:]')"
  [ "$count" = "0" ] || fail "processing guard still generated ${count} feedback inbox files"

  log "feedback command refuses to stack pressure while mailbox processing is active"
}

main() {
  rm -rf "$WORK_DIR"
  mkdir -p "$WORK_DIR"
  check_feedback_command_then_launch_claims_generated_inbox
  check_feedback_command_refuses_in_flight_processing
  log "ok"
}

main "$@"
