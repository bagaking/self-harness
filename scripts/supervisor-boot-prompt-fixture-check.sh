#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
WORK_DIR="${ROOT_DIR}/.self-harness/tmp/supervisor-boot-prompt-fixture-check"

fail() {
  echo "supervisor-boot-prompt-fixture-check: $*" >&2
  exit 1
}

log() {
  echo "supervisor-boot-prompt-fixture-check: $*"
}

require_contains() {
  local file="$1"
  local pattern="$2"
  LC_ALL=C rg -q -- "$pattern" "$file" || {
    echo "supervisor-boot-prompt-fixture-check: missing prompt text: ${pattern}" >&2
    return 1
  }
}

require_absent() {
  local file="$1"
  local pattern="$2"
  if LC_ALL=C rg -q -- "$pattern" "$file"; then
    echo "supervisor-boot-prompt-fixture-check: forbidden prompt text present: ${pattern}" >&2
    return 1
  fi
}

line_number() {
  local file="$1"
  local pattern="$2"
  awk -v pattern="$pattern" 'index($0, pattern) { print NR; exit }' "$file"
}

validate_single_pending_prompt() {
  local prompt="$1"
  local claim_line after_claim_line errors=0

  require_contains "$prompt" 'Read AGENTS.md first, then read constitution/00-charter.md' || errors=$((errors + 1))
  require_contains "$prompt" 'after any single pending-inbox claim required below' || errors=$((errors + 1))
  require_contains "$prompt" 'Pending mailbox before launch:' || errors=$((errors + 1))
  require_contains "$prompt" '- mailbox/inbox/only-pending.md' || errors=$((errors + 1))
  require_contains "$prompt" 'if exactly one pending inbox is listed' || errors=$((errors + 1))
  require_contains "$prompt" 'claim that file into mailbox/processing/ before scripts/query-docs.sh' || errors=$((errors + 1))
  require_contains "$prompt" 'repository sweeps, commit-history review, branch-birth reads, memory inspection, or skill inspection' || errors=$((errors + 1))
  require_contains "$prompt" 'Only after the claim, run the broader discovery needed for the task.' || errors=$((errors + 1))
  require_absent "$prompt" 'Read AGENTS.md first. Then use scripts/query-docs.sh to discover and read relevant constitution documents.' || errors=$((errors + 1))

  claim_line="$(line_number "$prompt" 'if exactly one pending inbox is listed')"
  after_claim_line="$(line_number "$prompt" 'Only after the claim')"
  if [ -z "$claim_line" ]; then
    echo "supervisor-boot-prompt-fixture-check: missing single-pending claim line" >&2
    errors=$((errors + 1))
  elif [ -z "$after_claim_line" ]; then
    echo "supervisor-boot-prompt-fixture-check: missing after-claim discovery line" >&2
    errors=$((errors + 1))
  elif [ "$claim_line" -ge "$after_claim_line" ]; then
    echo "supervisor-boot-prompt-fixture-check: after-claim discovery line appears before single-pending claim instruction" >&2
    errors=$((errors + 1))
  fi

  [ "$errors" -eq 0 ]
}

write_old_conflicting_prompt() {
  local file="$1"
  cat >"$file" <<'EOF'
You are running inside the self-harness repository.

Mode: new

Read AGENTS.md first. Then use scripts/query-docs.sh to discover and read relevant constitution documents. Do not modify constitution/.

Pending mailbox before launch:
- mailbox/inbox/only-pending.md

Mailbox priority:
- After reading AGENTS.md and constitution/00-charter.md, inspect the listed pending inbox before any broad repository sweep.
- Claim exactly one pending file by moving it from mailbox/inbox/ to mailbox/processing/.
- If there is only one pending file, claim that file first and handle its acceptance criteria.
EOF
}

check_real_single_pending_prompt() {
  local sandbox prompt
  sandbox="${WORK_DIR}/single-pending"
  prompt="${WORK_DIR}/single-pending.prompt"

  rm -rf "$sandbox"
  mkdir -p "${sandbox}/mailbox/inbox"
  : >"${sandbox}/mailbox/inbox/only-pending.md"

  SELF_HARNESS_SUPERVISOR_ROOT="$sandbox" \
    bash "${ROOT_DIR}/scripts/supervisor.sh" boot-prompt new >"$prompt"

  validate_single_pending_prompt "$prompt"
  log "accepts current single-pending boot prompt"
}

check_rejects_old_query_before_claim_prompt() {
  local prompt
  prompt="${WORK_DIR}/old-conflicting.prompt"
  write_old_conflicting_prompt "$prompt"

  if validate_single_pending_prompt "$prompt" >/dev/null 2>&1; then
    fail "old query-before-claim prompt unexpectedly passed"
  fi

  log "rejects old query-before-claim prompt"
}

main() {
  rm -rf "$WORK_DIR"
  mkdir -p "$WORK_DIR"
  check_real_single_pending_prompt
  check_rejects_old_query_before_claim_prompt
  log "ok"
}

main "$@"
