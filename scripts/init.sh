#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

CODEX_DIR="${ROOT_DIR}/.codex"
SKILLS_DIR="${ROOT_DIR}/skills"
SESSIONS_DIR="${ROOT_DIR}/sessions"
PRIVATE_DIR="${ROOT_DIR}/.self-harness"

mkdir -p \
  "${CODEX_DIR}" \
  "${SKILLS_DIR}" \
  "${SESSIONS_DIR}" \
  "${PRIVATE_DIR}/scratch" \
  "${PRIVATE_DIR}/tmp" \
  "${PRIVATE_DIR}/run"

mkdir -p \
  "${ROOT_DIR}/memory/birth" \
  "${ROOT_DIR}/memory/diary" \
  "${ROOT_DIR}/memory/decisions" \
  "${ROOT_DIR}/memory/lessons" \
  "${ROOT_DIR}/memory/proposals" \
  "${ROOT_DIR}/memory/incidents" \
  "${ROOT_DIR}/mailbox/inbox" \
  "${ROOT_DIR}/mailbox/processing" \
  "${ROOT_DIR}/mailbox/outbox" \
  "${ROOT_DIR}/mailbox/done" \
  "${ROOT_DIR}/mailbox/failed"

ensure_symlink() {
  local link_path="$1"
  local link_target="$2"

  if [ -L "${link_path}" ]; then
    local current_target
    current_target="$(readlink "${link_path}")"
    if [ "${current_target}" = "${link_target}" ]; then
      echo "${link_path} already points to ${link_target}"
      return 0
    fi

    rm "${link_path}"
  elif [ -e "${link_path}" ]; then
    echo "Refusing to replace non-symlink path: ${link_path}" >&2
    return 1
  fi

  ln -s "${link_target}" "${link_path}"
  echo "Created ${link_path} -> ${link_target}"
}

ensure_symlink "${CODEX_DIR}/skills" "../skills"
ensure_symlink "${CODEX_DIR}/sessions" "../sessions"
