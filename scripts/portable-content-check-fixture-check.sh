#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
WORK_DIR="${ROOT_DIR}/.self-harness/tmp/portable-content-check"

fail() {
  echo "portable-content-check-fixture-check: $*" >&2
  exit 1
}

log() {
  echo "portable-content-check-fixture-check: $*"
}

reset_work_dir() {
  rm -rf "$WORK_DIR"
  mkdir -p "$WORK_DIR/repo/scripts" "$WORK_DIR/repo/mailbox/outbox"
  cp "${ROOT_DIR}/scripts/portable-content-check.sh" "$WORK_DIR/repo/scripts/"
  chmod +x "$WORK_DIR/repo/scripts/portable-content-check.sh"
  (
    cd "$WORK_DIR/repo"
    git init -q
    git config user.email self-harness-fixture@example.invalid
    git config user.name self-harness-fixture
    git add scripts/portable-content-check.sh
    git commit -q -m baseline
  )
}

write_clean_markdown() {
  cat >"$WORK_DIR/repo/mailbox/outbox/clean.md" <<'EOF'
---
id: "fixture-clean"
title: "Fixture Clean"
type: "mailbox-message"
status: "done"
owner: "agent"
created: "2026-05-08"
updated: "2026-05-08"
tags:
  - fixture
summary: "Clean fixture."
---

# Clean

Allowed scratch proof:

```text
mkdir -p .self-harness/tmp/proof
scripts/init.sh > .self-harness/tmp/init-proof.log
```
EOF
}

write_dirty_temp_markdown() {
  local slash tmp_dir
  slash="/"
  tmp_dir="tmp"
  cat >"$WORK_DIR/repo/mailbox/outbox/dirty-temp.md" <<'EOF'
---
id: "fixture-dirty-temp"
title: "Fixture Dirty Temp"
type: "mailbox-message"
status: "done"
owner: "agent"
created: "2026-05-08"
updated: "2026-05-08"
tags:
  - fixture
summary: "Dirty temp fixture."
---

# Dirty Temp

EOF
  printf '%s%s%s%s\n' 'scripts/init.sh >' "$slash" "$tmp_dir" '/portable-fixture.log' \
    >>"$WORK_DIR/repo/mailbox/outbox/dirty-temp.md"
}

write_dirty_redacted_markdown() {
  local marker
  marker="[redacted-"temp"-path]"
  cat >"$WORK_DIR/repo/mailbox/outbox/dirty-redacted.md" <<'EOF'
---
id: "fixture-dirty-redacted"
title: "Fixture Dirty Redacted"
type: "mailbox-message"
status: "done"
owner: "agent"
created: "2026-05-08"
updated: "2026-05-08"
tags:
  - fixture
summary: "Dirty redacted fixture."
---

# Dirty Redacted

EOF
  printf 'A proof command wrote outside the repository at `%s`.\n' "$marker" \
    >>"$WORK_DIR/repo/mailbox/outbox/dirty-redacted.md"
}

check_positive_allowed_scratch() {
  local log_file="${WORK_DIR}/positive.log"
  reset_work_dir
  write_clean_markdown

  (
    cd "$WORK_DIR/repo"
    scripts/portable-content-check.sh
  ) >"$log_file" 2>&1 || {
    cat "$log_file" >&2
    fail "repository-relative scratch path should pass"
  }

  rg -q '^portable-content-check: ok$' "$log_file" \
    || fail "positive output did not report ok"
  log "positive repository-relative scratch path passed"
}

check_negative_temp_redirection() {
  local log_file="${WORK_DIR}/negative-temp.log"
  reset_work_dir
  write_dirty_temp_markdown

  set +e
  (
    cd "$WORK_DIR/repo"
    scripts/portable-content-check.sh
  ) >"$log_file" 2>&1
  local status=$?
  set -e

  [ "$status" -ne 0 ] || {
    cat "$log_file" >&2
    fail "project-outside temp redirection unexpectedly passed"
  }

  rg -q 'mailbox/outbox/dirty-temp.md:[0-9]+: project-outside temp path or write target' "$log_file" \
    || fail "negative temp output did not name the dirty line"
  log "negative project-outside temp redirection failed as expected"
}

check_negative_redacted_placeholder() {
  local log_file="${WORK_DIR}/negative-redacted.log"
  reset_work_dir
  write_dirty_redacted_markdown

  set +e
  (
    cd "$WORK_DIR/repo"
    scripts/portable-content-check.sh
  ) >"$log_file" 2>&1
  local status=$?
  set -e

  [ "$status" -ne 0 ] || {
    cat "$log_file" >&2
    fail "redacted path placeholder unexpectedly passed"
  }

  rg -q 'mailbox/outbox/dirty-redacted.md:[0-9]+: redacted local/temp/home path placeholder' "$log_file" \
    || fail "negative redacted output did not name the dirty line"
  log "negative redacted path placeholder failed as expected"
}

check_positive_allowed_scratch
check_negative_temp_redirection
check_negative_redacted_placeholder

log "ok"
