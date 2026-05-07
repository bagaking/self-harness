#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

pending_inbox_files() {
  find "${ROOT_DIR}/mailbox/inbox" -maxdepth 1 -type f ! -name .gitkeep 2>/dev/null \
    | sort \
    | sed "s#^${ROOT_DIR}/##"
}

changed_files() {
  {
    git -C "$ROOT_DIR" diff --name-only
    git -C "$ROOT_DIR" diff --cached --name-only
    git -C "$ROOT_DIR" ls-files --others --exclude-standard
    git -C "$ROOT_DIR" status --porcelain --untracked-files=all \
      | sed -E 's/^...//; s/ -> /\n/g'
  } | awk 'NF' | sort -u
}

main() {
  local pending changed rel saw_change=0

  pending="$(pending_inbox_files)"
  if [ -z "$pending" ]; then
    echo "pending-inbox-session-only-check: ok"
    return 0
  fi

  changed="$(changed_files)"
  if [ -z "$changed" ]; then
    echo "pending-inbox-session-only-check: ok"
    return 0
  fi

  while IFS= read -r rel; do
    [ -n "$rel" ] || continue
    saw_change=1
    case "$rel" in
      sessions/*)
        ;;
      *)
        echo "pending-inbox-session-only-check: ok"
        return 0
        ;;
    esac
  done <<EOF
${changed}
EOF

  if [ "$saw_change" -eq 1 ]; then
    {
      echo "pending-inbox-session-only-check: pending inbox still exists, but the current changes are only session transcripts"
      echo
      echo "Pending inbox:"
      printf '%s\n' "$pending" | sed 's/^/- /'
      echo
      echo "Current changed files:"
      printf '%s\n' "$changed" | sed 's/^/- /'
      echo
      echo "A run with pending mailbox input must claim and handle an inbox item, write a failure incident, or leave a durable supervisor task. Do not commit a session-only state record as useful progress."
    } >&2
    return 1
  fi

  echo "pending-inbox-session-only-check: ok"
}

main "$@"
