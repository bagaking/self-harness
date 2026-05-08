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

changed_incident_files() {
  changed_files | awk '/^memory\/incidents\/[^\/]+\.md$/ { print }'
}

incident_for_failed_session() {
  local session_rel="$1"
  local incident

  while IFS= read -r incident; do
    [ -n "$incident" ] || continue
    [ -f "${ROOT_DIR}/${incident}" ] || continue

    if LC_ALL=C rg -q --fixed-strings "pending-inbox-claim-latency-check: FAIL ${session_rel}" "${ROOT_DIR}/${incident}" &&
       LC_ALL=C rg -q --fixed-strings "${session_rel}" "${ROOT_DIR}/${incident}"; then
      if LC_ALL=C rg -q --fixed-strings 'broad pre-claim commands:' "${ROOT_DIR}/${incident}" ||
         LC_ALL=C rg -q --fixed-strings 'reason:' "${ROOT_DIR}/${incident}"; then
        printf '%s\n' "$incident"
        return 0
      fi
    fi
  done < <(changed_incident_files)

  return 1
}

scan_session_for_gate() {
  local rel="$1"
  local session="${ROOT_DIR}/${rel}"
  local output status incident

  set +e
  output="$("${ROOT_DIR}/scripts/pending-inbox-claim-latency-check.sh" "$session" 2>&1)"
  status=$?
  set -e

  if [ "$status" -eq 0 ]; then
    printf '%s\n' "$output"
    return 0
  fi

  incident="$(incident_for_failed_session "$rel" || true)"
  if [ -n "$incident" ]; then
    echo "pending-inbox-claim-latency-gate-check: incident-covered failure ${rel} covered_by=${incident}"
    return 0
  fi

  printf '%s\n' "$output"
  return "$status"
}

main() {
  local sessions=()
  local rel
  local status=0

  while IFS= read -r rel; do
    [ -n "$rel" ] || continue
    sessions+=("$rel")
  done < <(changed_session_files)

  if [ "${#sessions[@]}" -eq 0 ]; then
    echo "pending-inbox-claim-latency-gate-check: ok"
    return 0
  fi

  for rel in "${sessions[@]}"; do
    scan_session_for_gate "$rel" || status=1
  done

  return "$status"
}

main "$@"
