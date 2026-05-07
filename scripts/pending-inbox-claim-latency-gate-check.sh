#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

changed_files() {
  {
    git -C "$ROOT_DIR" diff --name-only
    git -C "$ROOT_DIR" diff --cached --name-only
    git -C "$ROOT_DIR" ls-files --others --exclude-standard
  } | awk 'NF' | sort -u
}

changed_session_files() {
  changed_files | awk '/^sessions\/.*\.jsonl(\..*)?$/ { print }'
}

main() {
  local sessions=()
  local rel

  while IFS= read -r rel; do
    [ -n "$rel" ] || continue
    sessions+=("${ROOT_DIR}/${rel}")
  done < <(changed_session_files)

  if [ "${#sessions[@]}" -eq 0 ]; then
    echo "pending-inbox-claim-latency-gate-check: ok"
    return 0
  fi

  "${ROOT_DIR}/scripts/pending-inbox-claim-latency-check.sh" "${sessions[@]}"
}

main "$@"
