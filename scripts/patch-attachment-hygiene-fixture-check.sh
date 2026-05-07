#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
WORK_DIR="${ROOT_DIR}/.self-harness/tmp/patch-attachment-hygiene-check"

fail() {
  echo "patch-attachment-hygiene-fixture-check: $*" >&2
  exit 1
}

log() {
  echo "patch-attachment-hygiene-fixture-check: $*"
}

reset_work_dir() {
  rm -rf "$WORK_DIR"
  mkdir -p "$WORK_DIR/repo/scripts" "$WORK_DIR/repo/mailbox/outbox/attachments"
}

copy_check() {
  cp "${ROOT_DIR}/scripts/patch-attachment-hygiene-check.sh" "$WORK_DIR/repo/scripts/"
  chmod +x "$WORK_DIR/repo/scripts/patch-attachment-hygiene-check.sh"
}

write_clean_patch() {
  cat >"$WORK_DIR/repo/mailbox/outbox/attachments/clean-main-target.patch" <<'PATCH'
diff --git a/example.txt b/example.txt
new file mode 100644
index 0000000..ac2dd81
--- /dev/null
+++ b/example.txt
@@ -0,0 +1 @@
+clean line
PATCH
}

write_dirty_patch() {
  cat >"$WORK_DIR/repo/mailbox/outbox/attachments/dirty-main-target.patch" <<'PATCH'
diff --git a/example.txt b/example.txt
new file mode 100644
index 0000000..43e8b46
--- /dev/null
+++ b/example.txt
@@ -0,0 +1,2 @@
+clean line
PATCH
  printf '+ \n' >>"$WORK_DIR/repo/mailbox/outbox/attachments/dirty-main-target.patch"
}

check_positive() {
  local log_file="${WORK_DIR}/positive.log"
  reset_work_dir
  copy_check
  write_clean_patch

  (
    cd "$WORK_DIR/repo"
    scripts/patch-attachment-hygiene-check.sh
  ) >"$log_file" 2>&1 || {
    cat "$log_file" >&2
    fail "clean main-target patch should pass"
  }

  rg -q '^patch-attachment-hygiene-check: ok$' "$log_file" \
    || fail "positive output did not report ok"
  log "positive clean main-target patch passed"
}

check_negative() {
  local log_file="${WORK_DIR}/negative.log"
  reset_work_dir
  copy_check
  write_dirty_patch

  set +e
  (
    cd "$WORK_DIR/repo"
    scripts/patch-attachment-hygiene-check.sh
  ) >"$log_file" 2>&1
  local status=$?
  set -e

  [ "$status" -ne 0 ] || {
    cat "$log_file" >&2
    fail "dirty main-target patch unexpectedly passed"
  }

  rg -q 'mailbox/outbox/attachments/dirty-main-target.patch:[0-9]+: trailing whitespace' "$log_file" \
    || fail "negative output did not name the dirty patch line"
  rg -q 'patch-attachment-hygiene-check: trailing whitespace in mailbox/outbox/attachments/dirty-main-target.patch' "$log_file" \
    || fail "negative output did not explain trailing whitespace"
  log "negative dirty main-target patch failed as expected"
}

check_explicit_file_argument() {
  local log_file="${WORK_DIR}/explicit.log"
  reset_work_dir
  copy_check
  write_dirty_patch

  set +e
  (
    cd "$WORK_DIR/repo"
    scripts/patch-attachment-hygiene-check.sh mailbox/outbox/attachments/dirty-main-target.patch
  ) >"$log_file" 2>&1
  local status=$?
  set -e

  [ "$status" -ne 0 ] || {
    cat "$log_file" >&2
    fail "explicit dirty patch unexpectedly passed"
  }

  rg -q 'mailbox/outbox/attachments/dirty-main-target.patch:[0-9]+: trailing whitespace' "$log_file" \
    || fail "explicit output did not name the dirty patch line"
  log "explicit file argument failed on dirty patch as expected"
}

check_positive
check_negative
check_explicit_file_argument

log "ok"
