#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
WORK_DIR="${ROOT_DIR}/.self-harness/tmp/durable-markdown-whitespace-check"

fail() {
  echo "durable-markdown-whitespace-fixture-check: $*" >&2
  exit 1
}

log() {
  echo "durable-markdown-whitespace-fixture-check: $*"
}

reset_work_dir() {
  rm -rf "$WORK_DIR"
  mkdir -p "$WORK_DIR/repo/scripts" "$WORK_DIR/repo/mailbox/outbox"
}

copy_checks() {
  cp "${ROOT_DIR}/scripts/durable-markdown-whitespace-check.sh" "$WORK_DIR/repo/scripts/"
  cp "${ROOT_DIR}/scripts/supervisor.sh" "$WORK_DIR/repo/scripts/"
  chmod +x "$WORK_DIR/repo/scripts/durable-markdown-whitespace-check.sh"
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

> quoted line
>
> next quoted line

```text
+>
+ diagnostic without trailing blanks
```
EOF
}

write_dirty_markdown() {
  cat >"$WORK_DIR/repo/mailbox/outbox/dirty.md" <<'EOF'
---
id: "fixture-dirty"
title: "Fixture Dirty"
type: "mailbox-message"
status: "done"
owner: "agent"
created: "2026-05-08"
updated: "2026-05-08"
tags:
  - fixture
summary: "Dirty fixture."
---

# Dirty

EOF
  printf '> \n' >>"$WORK_DIR/repo/mailbox/outbox/dirty.md"
  printf '+ \n' >>"$WORK_DIR/repo/mailbox/outbox/dirty.md"
}

check_positive_clean_markdown() {
  local log_file="${WORK_DIR}/positive.log"
  reset_work_dir
  copy_checks
  write_clean_markdown

  (
    cd "$WORK_DIR/repo"
    scripts/durable-markdown-whitespace-check.sh mailbox/outbox/clean.md
  ) >"$log_file" 2>&1 || {
    cat "$log_file" >&2
    fail "clean markdown should pass"
  }

  rg -q '^durable-markdown-whitespace-check: ok$' "$log_file" \
    || fail "positive output did not report ok"
  log "positive clean durable markdown passed"
}

check_negative_dirty_markdown() {
  local log_file="${WORK_DIR}/negative.log"
  reset_work_dir
  copy_checks
  write_dirty_markdown

  set +e
  (
    cd "$WORK_DIR/repo"
    scripts/durable-markdown-whitespace-check.sh mailbox/outbox/dirty.md
  ) >"$log_file" 2>&1
  local status=$?
  set -e

  [ "$status" -ne 0 ] || {
    cat "$log_file" >&2
    fail "dirty markdown unexpectedly passed"
  }

  rg -q 'mailbox/outbox/dirty.md:[0-9]+: trailing whitespace' "$log_file" \
    || fail "negative output did not name dirty markdown lines"
  rg -q 'durable-markdown-whitespace-check: trailing whitespace in mailbox/outbox/dirty.md' "$log_file" \
    || fail "negative output did not explain trailing whitespace"
  log "negative quote-marker and diff-marker blanks failed as expected"
}

check_markdown_quote_blank_lines() {
  local log_file="${WORK_DIR}/markdown-quote.log"
  reset_work_dir
  copy_checks

  (
    cd "$WORK_DIR/repo"
    bash -c 'source scripts/supervisor.sh __self_harness_source_only >/dev/null 2>&1; printf "alpha\n\nbeta  \n   \n" | markdown_quote'
  ) >"$log_file" 2>&1

  cat >"${WORK_DIR}/expected-markdown-quote.log" <<'EOF'
> alpha
>
> beta
>
EOF

  cmp -s "$log_file" "${WORK_DIR}/expected-markdown-quote.log" || {
    echo "expected:" >&2
    cat "${WORK_DIR}/expected-markdown-quote.log" >&2
    echo "actual:" >&2
    cat "$log_file" >&2
    fail "markdown_quote did not normalize blank or trailing-space lines"
  }

  LC_ALL=C rg -n '[[:blank:]]$' "$log_file" && fail "markdown_quote emitted trailing whitespace"
  log "markdown_quote blank-line normalization passed"
}

check_positive_clean_markdown
check_negative_dirty_markdown
check_markdown_quote_blank_lines

log "ok"
