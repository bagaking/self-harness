#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
WORK_DIR="${ROOT_DIR}/.self-harness/tmp/run-linked-feedback-map-check"

fail() {
  echo "run-linked-feedback-map-fixture-check: $*" >&2
  exit 1
}

log() {
  echo "run-linked-feedback-map-fixture-check: $*"
}

prepare_sandbox() {
  local sandbox="$1"

  rm -rf "$sandbox"
  mkdir -p "${sandbox}/scripts" "${sandbox}/mailbox/outbox"

  cp "${ROOT_DIR}/scripts/run-linked-feedback-map-check.sh" "${sandbox}/scripts/"
  chmod +x "${sandbox}/scripts/run-linked-feedback-map-check.sh"

  git -C "$sandbox" init -q
  git -C "$sandbox" checkout -q -b agent/run-linked-feedback-map-check
  git -C "$sandbox" config user.name "Self Harness Fixture"
  git -C "$sandbox" config user.email "self-harness-fixture@example.invalid"
  touch "${sandbox}/mailbox/outbox/.gitkeep"
  git -C "$sandbox" add --all -- .
  git -C "$sandbox" commit -q -m "fixture: initial run-linked map sandbox"
}

write_feedback_outbox() {
  local file="$1"
  local title="$2"
  local body="$3"

  cat >"$file" <<EOF
---
id: "mailbox-outbox-run-linked-map-fixture"
title: "${title}"
type: "mailbox-message"
status: "done"
owner: "agent"
created: "2026-05-07"
updated: "2026-05-07"
from: "agent/run-linked-feedback-map-check"
to: "supervisor"
message_id: "run-linked-map-fixture"
tags:
  - mailbox
  - feedback-pressure
summary: "Fixture feedback-pressure report for run-linked map validation."
related:
  - "skills/branch-evolution-evaluation/SKILL.md"
---

# ${title}

## Reviewed Evidence

This feedback-pressure fixture cites skills/branch-evolution-evaluation/SKILL.md and reviews latest supervisor-facing reports.

${body}
EOF
}

run_gate() {
  local sandbox="$1"
  local log_file="$2"
  set +e
  (
    cd "$sandbox"
    bash scripts/run-linked-feedback-map-check.sh
  ) >"$log_file" 2>&1
  local status=$?
  set -e
  return "$status"
}

expect_failure() {
  local label="$1"
  local sandbox="$2"
  local log_file="$3"
  local expected="$4"
  local status

  if run_gate "$sandbox" "$log_file"; then
    status=0
  else
    status=$?
  fi

  [ "$status" -ne 0 ] || {
    sed -n '1,160p' "$log_file" >&2
    fail "${label}: expected run-linked map gate to fail"
  }
  rg -q "$expected" "$log_file" || {
    sed -n '1,160p' "$log_file" >&2
    fail "${label}: failure output did not match ${expected}"
  }
}

expect_success() {
  local label="$1"
  local sandbox="$2"
  local log_file="$3"

  run_gate "$sandbox" "$log_file" || {
    sed -n '1,160p' "$log_file" >&2
    fail "${label}: expected run-linked map gate to pass"
  }
  rg -q '^run-linked-feedback-map-check: ok' "$log_file" || {
    sed -n '1,160p' "$log_file" >&2
    fail "${label}: success output did not report ok"
  }
}

query_evidence_block() {
  cat <<'EOF'
Command and output:

```text
$ scripts/query-docs.sh skills "run-linked"
===== skills/branch-evolution-evaluation/SKILL.md =====
  name: branch-evolution-evaluation
  30:   - When citing the "latest" supervisor-facing reports, make the report sample run-linked.
```
EOF
}

run_linked_map_block() {
  cat <<'EOF'
Command and output:

```text
$ git log --oneline -3
abc1234 run: Current Feedback
def5678 run: Previous Feedback
fed9876 run: Older Feedback
```

| Run commit | Changed supervisor-facing outbox |
| --- | --- |
| `abc1234` `run: Current Feedback` | `mailbox/outbox/current-feedback.md` |
| `def5678` `run: Previous Feedback` | `mailbox/outbox/previous-feedback.md` |
| `fed9876` `run: Older Feedback` | `mailbox/outbox/older-feedback.md` |
EOF
}

check_rejects_skill_citation_without_map() {
  local sandbox log_file body
  sandbox="${WORK_DIR}/without-map"
  log_file="${WORK_DIR}/without-map.log"
  prepare_sandbox "$sandbox"
  body="$(query_evidence_block)"
  body="${body}"$'\n\n## Mechanism\n\nThe report says the skill exists but gives no run-linked commit map.'
  write_feedback_outbox "${sandbox}/mailbox/outbox/without-map.md" "Without Run Linked Map" "$body"

  expect_failure "skill citation without map" "$sandbox" "$log_file" "missing run-linked git-log"
  log "rejects skill citation without run-linked map"
}

check_rejects_undocumented_ordering() {
  local sandbox log_file body
  sandbox="${WORK_DIR}/undocumented-ordering"
  log_file="${WORK_DIR}/undocumented-ordering.log"
  prepare_sandbox "$sandbox"
  body="$(query_evidence_block)"
  body="${body}"$'\n\nLatest reports by filename:\n\n- mailbox/outbox/a.md\n- mailbox/outbox/b.md\n- mailbox/outbox/c.md\n\nThe report lists files by filename without explaining why that ordering answers this mailbox requirement.'
  write_feedback_outbox "${sandbox}/mailbox/outbox/undocumented-ordering.md" "Undocumented Ordering" "$body"

  expect_failure "undocumented ordering" "$sandbox" "$log_file" "missing run-linked git-log"
  log "rejects undocumented latest-report ordering"
}

check_rejects_self_referential_next_pressure() {
  local sandbox log_file body
  sandbox="${WORK_DIR}/self-referential-next-pressure"
  log_file="${WORK_DIR}/self-referential-next-pressure.log"
  prepare_sandbox "$sandbox"
  body="$(query_evidence_block)"
  body="${body}"$'\n\n'"$(run_linked_map_block)"
  body="${body}"$'\n\nNext supervisor pressure: on the next feedback-bearing run, cite skills/branch-evolution-evaluation/SKILL.md, show scripts/query-docs.sh skills "run-linked", and include the run-linked report map.'
  write_feedback_outbox "${sandbox}/mailbox/outbox/self-referential-next-pressure.md" "Self Referential Next Pressure" "$body"

  expect_failure "self-referential next pressure" "$sandbox" "$log_file" "self-referential Next supervisor pressure"
  log "rejects self-referential next-pressure loop without sharper artifact"
}

check_allows_run_linked_map_with_artifact() {
  local sandbox log_file body
  sandbox="${WORK_DIR}/mapped-with-artifact"
  log_file="${WORK_DIR}/mapped-with-artifact.log"
  prepare_sandbox "$sandbox"
  body="$(query_evidence_block)"
  body="${body}"$'\n\n'"$(run_linked_map_block)"
  body="${body}"$'\n\n## Mechanism\n\nAdded `scripts/run-linked-feedback-map-check.sh` and fixture proof as the stronger proof artifact.\n\nNo next supervisor pressure: further escalation would be noisy because the fixture now rejects the stable negative cases.'
  write_feedback_outbox "${sandbox}/mailbox/outbox/mapped-with-artifact.md" "Mapped With Artifact" "$body"

  expect_success "mapped report with artifact" "$sandbox" "$log_file"
  log "allows run-linked map with sharper proof artifact"
}

check_allows_explicit_ordering_justification() {
  local sandbox log_file body
  sandbox="${WORK_DIR}/explicit-ordering-justification"
  log_file="${WORK_DIR}/explicit-ordering-justification.log"
  prepare_sandbox "$sandbox"
  body="$(query_evidence_block)"
  body="${body}"$'\n\nAcceptance-criteria ordering justification: these acceptance criteria ask for the generated source challenge rather than the latest run commit, so this fixture documents the different ordering explicitly.\n\n## Mechanism\n\nAdded `memory/decisions/example.md` as a bounded proof artifact.'
  write_feedback_outbox "${sandbox}/mailbox/outbox/explicit-ordering-justification.md" "Explicit Ordering Justification" "$body"

  expect_success "explicit ordering justification" "$sandbox" "$log_file"
  log "allows explicit acceptance-criteria ordering justification"
}

prepare_supervisor_gate_sandbox() {
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
    "${sandbox}/memory/decisions" \
    "${sandbox}/memory/lessons" \
    "${sandbox}/memory/proposals" \
    "${sandbox}/memory/incidents" \
    "${sandbox}/sessions" \
    "${sandbox}/skills"

  cp "${ROOT_DIR}/AGENTS.md" "${sandbox}/AGENTS.md"
  cp "${ROOT_DIR}/constitution/"*.md "${sandbox}/constitution/"
  cp "${ROOT_DIR}/scripts/"*.sh "${sandbox}/scripts/"
  chmod +x "${sandbox}/scripts/"*.sh
  if [ -f "${ROOT_DIR}/.gitignore" ]; then
    cp "${ROOT_DIR}/.gitignore" "${sandbox}/.gitignore"
  fi

  git -C "$sandbox" init -q
  git -C "$sandbox" checkout -q -b agent/run-linked-supervisor-gate
  git -C "$sandbox" config user.name "Self Harness Fixture"
  git -C "$sandbox" config user.email "self-harness-fixture@example.invalid"
  git -C "$sandbox" add --all -- .
  git -C "$sandbox" commit -q -m "fixture: initial supervisor gate sandbox"
}

write_supervisor_gate_bad_outbox() {
  local file="$1"

  cat >"$file" <<'EOF'
---
id: "mailbox-outbox-supervisor-gate-missing-run-linked-map"
title: "Supervisor Gate Missing Run Linked Map"
type: "mailbox-message"
status: "done"
owner: "agent"
created: "2026-05-07"
updated: "2026-05-07"
from: "agent/run-linked-supervisor-gate"
to: "supervisor"
message_id: "supervisor-gate-missing-run-linked-map"
tags:
  - mailbox
  - feedback-pressure
summary: "Fixture feedback-pressure report that must be blocked by the supervisor commit gate."
related:
  - "skills/branch-evolution-evaluation/SKILL.md"
  - "scripts/run-linked-feedback-map-check.sh"
---

# Supervisor Gate Missing Run Linked Map

## Reviewed Evidence

This feedback-pressure fixture cites skills/branch-evolution-evaluation/SKILL.md, latest supervisor-facing reports, and the run-linked procedure.

Command and output:

\`\`\`text
$ scripts/query-docs.sh skills "run-linked"
===== skills/branch-evolution-evaluation/SKILL.md =====
  name: branch-evolution-evaluation
  30:   - When citing the "latest" supervisor-facing reports, make the report sample run-linked.
\`\`\`

## Current Weakness

The proof bar is still lower if a changed feedback-bearing outbox can reach the supervisor commit path while omitting the run-linked git-log to mailbox/outbox map.

## Mechanism

This scratch report intentionally omits the map so `scripts/supervisor.sh commit` must reject it through `scripts/run-linked-feedback-map-check.sh`.

## Anti-Noise

No next supervisor pressure: further escalation would be noisy because this fixture is a focused negative case for the commit gate.

I refuse escalation beyond this narrower task in the scratch fixture; the only intended failure is the omitted run-linked map.

Supervisor evaluation trigger: reopen if `scripts/supervisor.sh commit` accepts a changed feedback-pressure outbox that cites run-linked without a map.

Stop condition: `scripts/supervisor.sh triggers --status review` can review trigger-backed refusals before treating this fixture path as complete.

## Verification

Rerunnable verification is `scripts/run-linked-feedback-map-fixture-check.sh`.

## Return-To-Main

Return-to-main is not applicable inside this scratch fixture.
EOF
}

check_supervisor_commit_gate_rejects_missing_map() {
  local sandbox log_file status before_count after_count
  sandbox="${WORK_DIR}/supervisor-commit-gate"
  log_file="${WORK_DIR}/supervisor-commit-gate.log"
  prepare_supervisor_gate_sandbox "$sandbox"
  write_supervisor_gate_bad_outbox "${sandbox}/mailbox/outbox/supervisor-gate-missing-map.md"

  before_count="$(git -C "$sandbox" rev-list --count HEAD)"
  set +e
  (
    cd "$sandbox"
    bash scripts/supervisor.sh commit -m "fixture: should fail before commit"
  ) >"$log_file" 2>&1
  status=$?
  set -e
  after_count="$(git -C "$sandbox" rev-list --count HEAD)"

  [ "$status" -ne 0 ] || {
    sed -n '1,220p' "$log_file" >&2
    fail "supervisor commit gate accepted a feedback outbox without a run-linked map"
  }
  [ "$before_count" = "$after_count" ] || fail "supervisor commit gate created a commit after rejecting the missing map"
  rg -q 'run-linked-feedback-map-check: mailbox/outbox/supervisor-gate-missing-map\.md: missing run-linked git-log' "$log_file" || {
    sed -n '1,220p' "$log_file" >&2
    fail "supervisor commit gate failure did not come from the run-linked map check"
  }

  log "supervisor commit gate rejects changed feedback outbox missing run-linked map"
}

main() {
  rm -rf "$WORK_DIR"
  mkdir -p "$WORK_DIR"
  check_rejects_skill_citation_without_map
  check_rejects_undocumented_ordering
  check_rejects_self_referential_next_pressure
  check_allows_run_linked_map_with_artifact
  check_allows_explicit_ordering_justification
  check_supervisor_commit_gate_rejects_missing_map
  log "ok"
}

main "$@"
