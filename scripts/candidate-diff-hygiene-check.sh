#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

usage() {
  cat <<'EOF'
Usage:
  scripts/candidate-diff-hygiene-check.sh PATH...

Checks whitespace hygiene for an explicit return-to-main candidate surface:

  git diff --check origin/main...HEAD -- PATH...

The path list must name candidate gene files only. Branch-local mailbox,
diary, session, birth, incident, and attachment-review records are rejected
so a clean candidate check cannot be mistaken for proof that the whole branch
diff is clean.
EOF
}

fail() {
  echo "candidate-diff-hygiene-check: $*" >&2
  exit 1
}

repo_relative_path() {
  local path="$1"
  case "$path" in
    /*)
      case "$path" in
        "${ROOT_DIR}/"*)
          printf '%s\n' "${path#${ROOT_DIR}/}"
          ;;
        *)
          fail "path is outside repository: ${path}"
          ;;
      esac
      ;;
    ./*)
      printf '%s\n' "${path#./}"
      ;;
    *)
      printf '%s\n' "$path"
      ;;
  esac
}

reject_path() {
  local rel="$1"
  case "$rel" in
    ""|.|..|../*|*/../*|/*)
      fail "invalid candidate path: ${rel}"
      ;;
    mailbox/inbox/*|mailbox/processing/*|mailbox/done/*|mailbox/failed/*|mailbox/outbox/*.md|mailbox/outbox/attachments/*|memory/diary/*|memory/birth/*|memory/incidents/*|sessions/*)
      fail "branch-local evidence path is not a candidate gene file: ${rel}"
      ;;
    constitution/*)
      fail "constitution is human-owned and not an agent candidate surface: ${rel}"
      ;;
    .git/*|.codex/*|.self-harness/*)
      fail "private or runtime path is not a candidate surface: ${rel}"
      ;;
  esac
}

main() {
  if [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
    usage
    return 0
  fi

  [ "$#" -gt 0 ] || {
    usage >&2
    fail "provide at least one candidate path"
  }

  local rel path
  paths=()
  for path in "$@"; do
    rel="$(repo_relative_path "$path")"
    reject_path "$rel"
    paths+=("$rel")
  done

  git -C "$ROOT_DIR" diff --check origin/main...HEAD -- "${paths[@]}"
  echo "candidate-diff-hygiene-check: ok"
}

main "$@"
