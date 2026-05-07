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

Each path must exist as a file in HEAD and be part of the branch candidate
surface against origin/main. Missing, unchanged, deleted, directory-only, or
branch-local evidence paths are rejected before the whitespace check runs.
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

require_candidate_surface_file() {
  local rel="$1"
  local object_type

  if ! git -C "$ROOT_DIR" cat-file -e "HEAD:${rel}" 2>/dev/null; then
    fail "candidate path is not present in HEAD: ${rel}"
  fi

  object_type="$(git -C "$ROOT_DIR" cat-file -t "HEAD:${rel}")"
  if [ "$object_type" != "blob" ]; then
    fail "candidate path must name a file in HEAD: ${rel}"
  fi

  if ! git -C "$ROOT_DIR" diff --name-only --diff-filter=ACMRT origin/main...HEAD -- "$rel" | rg -F -x -q -- "$rel"; then
    fail "candidate path is not part of the branch candidate surface: ${rel}"
  fi
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
  local -a paths
  paths=()
  for path in "$@"; do
    rel="$(repo_relative_path "$path")"
    reject_path "$rel"
    require_candidate_surface_file "$rel"
    paths+=("$rel")
  done

  git -C "$ROOT_DIR" diff --check origin/main...HEAD -- "${paths[@]}"
  echo "candidate-diff-hygiene-check: ok"
}

main "$@"
