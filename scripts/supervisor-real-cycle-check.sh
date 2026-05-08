#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
WORK_DIR="${ROOT_DIR}/.self-harness/tmp/supervisor-real-cycle-check"

fail() {
  echo "supervisor-real-cycle-check: $*" >&2
  exit 1
}

log() {
  echo "supervisor-real-cycle-check: $*"
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

write_pending_message() {
  local file="$1"
  local id="$2"
  local title="$3"
  {
    printf '%s\n' '---'
    printf 'id: "mailbox-inbox-%s"\n' "$id"
    printf 'title: "%s"\n' "$title"
    printf '%s\n' 'type: "mailbox-inbox"'
    printf '%s\n' 'status: "pending"'
    printf '%s\n' 'owner: "supervisor"'
    printf '%s\n' 'created: "2026-05-07"'
    printf '%s\n' 'updated: "2026-05-07"'
    printf '%s\n' 'from: "supervisor"'
    printf '%s\n' 'to: "agent/real-cycle-check"'
    printf 'message_id: "%s"\n' "$id"
    printf '%s\n' 'tags:'
    printf '%s\n' '  - supervisor'
    printf '%s\n' '  - control-plane'
    printf '%s\n' 'summary: "Pending controlled supervisor cycle input."'
    printf '%s\n' '---'
    printf '\n# %s\n\nHandle this controlled supervisor cycle input.\n' "$title"
  } >"$file"
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
mkdir -p .self-harness/tmp
printf '%s\n' "${SELF_HARNESS_REAL_CYCLE_FAKE_MODE:-unset}" >> .self-harness/tmp/fake-codex-invocations.log

if [ -n "$output" ]; then
  mkdir -p "$(dirname "$output")"
  printf 'Completed fake real-cycle Codex run\n' >"$output"
fi

case "${SELF_HARNESS_REAL_CYCLE_FAKE_MODE:-}" in
  valid-loop)
    title="Valid Real Cycle"
    summary="Records a fake Codex run that made a syntactically valid supervisor source change."
    marker="valid-real-cycle"
    ;;
  invalid-loop)
    title="Invalid Real Cycle"
    summary="Records a fake Codex run that made an invalid supervisor source change."
    marker="invalid-real-cycle"
    ;;
  pressure-once)
    title="Post Run Pressure Marker"
    summary="Records a fake Codex run that declares a next supervisor pressure requirement."
    marker="pressure-real-cycle"
    ;;
  *)
    echo "unknown fake mode: ${SELF_HARNESS_REAL_CYCLE_FAKE_MODE:-}" >&2
    exit 2
    ;;
esac

mkdir -p mailbox/done mailbox/outbox memory/diary
if inbox_file="$(find mailbox/inbox -maxdepth 1 -type f ! -name .gitkeep | sort | head -1)" && [ -n "$inbox_file" ]; then
  done_file="mailbox/done/$(basename "$inbox_file")"
  sed 's/status: "pending"/status: "done"/' "$inbox_file" >"$done_file"
  rm -f "$inbox_file"
fi

cat >"memory/diary/${marker}.md" <<DIARY
---
id: "diary-${marker}"
title: "${title}"
type: "diary"
status: "active"
owner: "agent"
created: "2026-05-07"
updated: "2026-05-07"
tags:
  - diary
  - supervisor
  - control-plane
summary: "${summary}"
source: "experiment"
confidence: "high"
related: []
---

# diary: ${title}

${summary}
DIARY

case "${SELF_HARNESS_REAL_CYCLE_FAKE_MODE:-}" in
  valid-loop)
    cat >"mailbox/outbox/${marker}-reply.md" <<OUTBOX
---
id: "mailbox-outbox-${marker}-reply"
title: "Valid Real Cycle Reply"
type: "mailbox-message"
status: "done"
owner: "agent"
created: "2026-05-07"
updated: "2026-05-07"
from: "agent/real-cycle-check"
to: "supervisor"
message_id: "${marker}-reply"
tags:
  - mailbox
  - supervisor
  - control-plane
summary: "Reports a controlled valid supervisor source edit."
related: []
---

# Valid Real Cycle Reply

The fake run appended a valid marker to the checked-out supervisor source.
OUTBOX
    printf '\n# real-cycle valid supervisor marker\n' >> scripts/supervisor.sh
    ;;
  invalid-loop)
    cat >"mailbox/outbox/${marker}-reply.md" <<OUTBOX
---
id: "mailbox-outbox-${marker}-reply"
title: "Invalid Real Cycle Reply"
type: "mailbox-message"
status: "done"
owner: "agent"
created: "2026-05-07"
updated: "2026-05-07"
from: "agent/real-cycle-check"
to: "supervisor"
message_id: "${marker}-reply"
tags:
  - mailbox
  - supervisor
  - control-plane
summary: "Reports a controlled invalid supervisor source edit."
related: []
---

# Invalid Real Cycle Reply

The fake run appended invalid shell syntax to the checked-out supervisor source.
OUTBOX
    cat > scripts/supervisor.sh <<'BROKEN_SUPERVISOR'
#!/usr/bin/env bash
printf "unterminated real-cycle marker
BROKEN_SUPERVISOR
    ;;
  pressure-once)
    cat >"mailbox/outbox/${marker}-reply.md" <<OUTBOX
---
id: "mailbox-outbox-${marker}-reply"
title: "Post Run Pressure Marker Reply"
type: "mailbox-message"
status: "done"
owner: "agent"
created: "2026-05-07"
updated: "2026-05-07"
from: "agent/real-cycle-check"
to: "supervisor"
message_id: "${marker}-reply"
tags:
  - mailbox
  - supervisor
  - feedback-pressure
summary: "Declares unresolved follow-up pressure for the supervisor to seed."
related: []
---

# Post Run Pressure Marker Reply

## Reviewed Evidence

Reviewed one controlled sandbox run and its changed mailbox output.

\`\`\`text
scripts/query-docs.sh skills "run-linked"
===== skills/branch-evolution-evaluation/SKILL.md =====
\`\`\`

Acceptance-criteria ordering justification: this controlled fixture uses generated sandbox commits and outbox records, not the branch's latest run-linked report sample, because its acceptance criteria are to prove post-run pressure seeding and checked-out commit report evidence inside the sandbox.

## Current Weakness

The exact current weakness is that a completed feedback-bearing run can declare a narrower task and still leave no pending inbox for the next launch.

## Mechanism

The supervisor should convert this marker into a pending inbox before committing the completed run.

## Anti-Noise

This is a narrower task and a refused escalation path for broad, generic follow-up.

## Verification

Rerunnable verification is provided by scripts/supervisor-real-cycle-check.sh.

## Return-To-Main

Return-to-main is no for this scratch-only marker.

Next supervisor pressure: the next feedback-bearing run that uses \`No next supervisor pressure:\` must cite an observed \`scripts/supervisor.sh triggers --status review\` or \`scripts/supervisor-evaluation-trigger-list.sh --status review\` result before the refusal can be treated as compliant.
OUTBOX
    ;;
esac
EOF
  chmod +x "${dir}/codex"
}

prepare_sandbox() {
  local sandbox="$1"
  local message_id="$2"
  local title="$3"

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
  write_pending_message "${sandbox}/mailbox/inbox/${message_id}.md" "$message_id" "$title"

  git -C "$sandbox" init -q
  git -C "$sandbox" checkout -q -b agent/real-cycle-check
  git -C "$sandbox" config user.name "Self Harness Fixture"
  git -C "$sandbox" config user.email "self-harness-fixture@example.invalid"
  git -C "$sandbox" add --all -- .
  git -C "$sandbox" commit -q -m "fixture: initial real supervisor cycle sandbox"
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

assert_commit_gate_report_has_portable_content_ok() {
  local sandbox="$1"
  local report="${sandbox}/.self-harness/tmp/commit-gate-last-report.md"

  [ -f "$report" ] || fail "$(basename "$sandbox"): missing commit gate report"
  if ! rg -q '^portable-content-check: ok$' "$report"; then
    sed -n '1,220p' "$report" >&2
    fail "$(basename "$sandbox"): checked-out commit gate report did not include portable-content-check: ok"
  fi
}

check_valid_loop_commits_and_exits() {
  local sandbox log_file status
  sandbox="${WORK_DIR}/valid-loop"
  log_file="${WORK_DIR}/valid-loop.log"
  prepare_sandbox "$sandbox" "valid-real-cycle-input" "Valid Real Cycle Input"

  set +e
  (
    cd "$sandbox"
    run_with_timeout 30 env \
      PATH="${sandbox}/bin:${PATH}" \
      SELF_HARNESS_AUTO_CHALLENGE=0 \
      SELF_HARNESS_CODEX_MAX_RUNTIME_SECONDS=0 \
      SELF_HARNESS_CODEX_IDLE_TIMEOUT_SECONDS=0 \
      SELF_HARNESS_CODEX_WATCHDOG_POLL_SECONDS=1 \
      SELF_HARNESS_INTERVAL_SECONDS=60 \
      SELF_HARNESS_REAL_CYCLE_FAKE_MODE=valid-loop \
      bash scripts/supervisor.sh loop
  ) >"$log_file" 2>&1
  status=$?
  set -e

  if [ "$status" -ne 0 ]; then
    sed -n '1,220p' "$log_file" >&2
    fail "valid loop returned ${status}"
  fi

  [ "$(commit_count "$sandbox")" -eq 2 ] || fail "valid loop did not create exactly one supervisor commit"
  git -C "$sandbox" show --name-only --format= HEAD | rg -q '^scripts/supervisor.sh$' || fail "valid commit did not include scripts/supervisor.sh"
  rg -q 'supervisor source changed during stable-copy loop and passed readiness check; exiting' "$log_file" || {
    sed -n '1,220p' "$log_file" >&2
    fail "valid loop did not exit after readiness passed"
  }
  [ "$(wc -l <"${sandbox}/.self-harness/tmp/fake-codex-invocations.log" | tr -d '[:space:]')" = "1" ] || fail "valid loop invoked fake Codex more than once"
  assert_clean_worktree "$sandbox"

  log "valid foreground loop committed checked-out supervisor change and exited after readiness"
}

check_invalid_loop_recovers_checked_out_source() {
  local sandbox log_file status invocations
  sandbox="${WORK_DIR}/invalid-loop"
  log_file="${WORK_DIR}/invalid-loop.log"
  prepare_sandbox "$sandbox" "invalid-real-cycle-input" "Invalid Real Cycle Input"

  set +e
  (
    cd "$sandbox"
    run_with_timeout 30 env \
      PATH="${sandbox}/bin:${PATH}" \
      SELF_HARNESS_AUTO_CHALLENGE=0 \
      SELF_HARNESS_CODEX_MAX_RUNTIME_SECONDS=0 \
      SELF_HARNESS_CODEX_IDLE_TIMEOUT_SECONDS=0 \
      SELF_HARNESS_CODEX_WATCHDOG_POLL_SECONDS=1 \
      SELF_HARNESS_INTERVAL_SECONDS=60 \
      SELF_HARNESS_REAL_CYCLE_FAKE_MODE=invalid-loop \
      bash scripts/supervisor.sh loop
  ) >"$log_file" 2>&1
  status=$?
  set -e

  if [ "$status" -ne 0 ]; then
    sed -n '1,260p' "$log_file" >&2
    fail "invalid loop returned ${status}; expected bounded recovery and clean exit"
  fi

  [ "$(commit_count "$sandbox")" -eq 2 ] || fail "invalid loop did not create exactly one recovery incident commit"
  rg -q 'post-run commit gate failed; asking Codex session for one repair attempt' "$log_file" || {
    sed -n '1,260p' "$log_file" >&2
    fail "invalid loop did not trigger bounded repair path"
  }
  rg -q 'shell-syntax-check: failed scripts/supervisor.sh' "$log_file" || {
    sed -n '1,260p' "$log_file" >&2
    fail "invalid loop did not fail through shell syntax gate"
  }
  rg -q 'recovered invalid checked-out supervisor source from stable copy' "$log_file" || {
    sed -n '1,260p' "$log_file" >&2
    fail "invalid loop did not recover checked-out supervisor source"
  }
  rg -q 'supervisor source recovered during stable-copy loop; exiting so the next start uses checked-out source' "$log_file" || {
    sed -n '1,260p' "$log_file" >&2
    fail "invalid loop did not exit after explicit supervisor source recovery"
  }
  if rg -q 'supervisor source changed during stable-copy loop but failed readiness check; keeping stable copy in control' "$log_file"; then
    sed -n '1,260p' "$log_file" >&2
    fail "invalid loop still left stable copy in blocked handoff state after recovery"
  fi
  if rg -q 'passed readiness check; exiting' "$log_file"; then
    sed -n '1,260p' "$log_file" >&2
    fail "invalid loop treated the invalid edit as a normal readiness handoff"
  fi
  invocations="$(wc -l <"${sandbox}/.self-harness/tmp/fake-codex-invocations.log" | tr -d '[:space:]')"
  [ "$invocations" = "2" ] || fail "invalid loop expected exactly one repair attempt, got ${invocations} fake Codex invocations"
  local incident_rel
  incident_rel="$(git -C "$sandbox" show --name-only --format= HEAD | awk '/^memory\/incidents\/.*invalid-supervisor-recovery\.md$/ { print; exit }')"
  [ -n "$incident_rel" ] || fail "invalid recovery commit did not include a recovery incident"
  rg -q 'Discarded Invalid Supervisor Diff' "${sandbox}/${incident_rel}" || fail "invalid recovery incident did not include discarded-source evidence"
  rg -q 'unterminated real-cycle marker' "${sandbox}/${incident_rel}" || fail "invalid recovery incident did not capture the discarded invalid source excerpt"
  bash -n "${sandbox}/scripts/supervisor.sh" || fail "invalid recovery did not leave checked-out supervisor source valid"
  assert_clean_worktree "$sandbox"

  log "invalid foreground loop recovered checked-out supervisor source after fail-closed gate"
}

check_post_run_pressure_seeding() {
  local sandbox log_file status seeded_count seeded_file expected_requirement actual_requirement
  sandbox="${WORK_DIR}/post-run-pressure"
  log_file="${WORK_DIR}/post-run-pressure.log"
  expected_requirement='the next feedback-bearing run that uses `No next supervisor pressure:` must cite an observed `scripts/supervisor.sh triggers --status review` or `scripts/supervisor-evaluation-trigger-list.sh --status review` result before the refusal can be treated as compliant.'
  prepare_sandbox "$sandbox" "pressure-real-cycle-input" "Pressure Real Cycle Input"

  set +e
  (
    cd "$sandbox"
    run_with_timeout 30 env \
      PATH="${sandbox}/bin:${PATH}" \
      SELF_HARNESS_AUTO_CHALLENGE=1 \
      SELF_HARNESS_CODEX_MAX_RUNTIME_SECONDS=0 \
      SELF_HARNESS_CODEX_IDLE_TIMEOUT_SECONDS=0 \
      SELF_HARNESS_CODEX_WATCHDOG_POLL_SECONDS=1 \
      SELF_HARNESS_REAL_CYCLE_FAKE_MODE=pressure-once \
      bash scripts/supervisor.sh once
  ) >"$log_file" 2>&1
  status=$?
  set -e

  if [ "$status" -ne 0 ]; then
    sed -n '1,260p' "$log_file" >&2
    fail "post-run pressure once returned ${status}"
  fi

  [ "$(commit_count "$sandbox")" -eq 2 ] || fail "post-run pressure case did not create exactly one supervisor commit"
  rg -q 'seeded post-run pressure challenge:' "$log_file" || {
    sed -n '1,260p' "$log_file" >&2
    fail "post-run pressure case did not log challenge seeding"
  }
  seeded_count="$(find "$sandbox/mailbox/inbox" -maxdepth 1 -type f -name '*post-run-pressure-challenge.md' | wc -l | tr -d '[:space:]')"
  [ "$seeded_count" = "1" ] || fail "expected one committed post-run pressure inbox, found ${seeded_count}"
  assert_commit_gate_report_has_portable_content_ok "$sandbox"
  seeded_file="$(find "$sandbox/mailbox/inbox" -maxdepth 1 -type f -name '*post-run-pressure-challenge.md' | sort | head -1)"
  rg -q 'mailbox/outbox/pressure-real-cycle-reply\.md' "$seeded_file" || fail "post-run pressure inbox omitted source outbox path"
  rg -q 'Review `mailbox/outbox/pressure-real-cycle-reply\.md` before broad repository inspection\.' "$seeded_file" || fail "post-run pressure inbox omitted review source path"
  rg -q 'scratch work under `.self-harness/tmp/`' "$seeded_file" || fail "post-run pressure inbox omitted scratch path"
  actual_requirement="$(awk '
    /^## Requirement$/ { in_requirement = 1; next }
    /^## Acceptance Criteria$/ { exit }
    in_requirement && NF { print; exit }
  ' "$seeded_file")"
  [ "$actual_requirement" = "$expected_requirement" ] || {
    printf 'expected requirement: %s\n' "$expected_requirement" >&2
    printf 'actual requirement:   %s\n' "$actual_requirement" >&2
    fail "post-run pressure inbox requirement did not preserve the complete long marker"
  }
  if rg -q 'before the refusal can b$' "$seeded_file"; then
    fail "post-run pressure inbox still contains a mid-word truncated requirement"
  fi
  git -C "$sandbox" show --name-only --format= HEAD | rg -q '^mailbox/inbox/.*post-run-pressure-challenge\.md$' || fail "post-run pressure inbox was not included in the supervisor commit"
  assert_clean_worktree "$sandbox"

  log "post-run pressure marker preserved a complete long requirement and checked-out portable-content gate evidence"
}

main() {
  rm -rf "$WORK_DIR"
  mkdir -p "$WORK_DIR"
  check_valid_loop_commits_and_exits
  check_invalid_loop_recovers_checked_out_source
  check_post_run_pressure_seeding
  log "ok"
}

main "$@"
