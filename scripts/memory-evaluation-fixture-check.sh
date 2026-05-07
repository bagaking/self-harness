#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
WORK_DIR="${ROOT_DIR}/.self-harness/tmp/memory-evaluation-fixture-check-$$"

fail() {
  echo "memory-evaluation-fixture-check: $*" >&2
  exit 1
}

log() {
  echo "memory-evaluation-fixture-check: $*"
}

prepare_sandbox() {
  local sandbox="$1"
  rm -rf "$sandbox"
  mkdir -p "${sandbox}/memory/lessons"
}

run_count() {
  local sandbox="$1"
  MEMORY_EVALUATION_ROOT_DIR="$sandbox" \
    bash "${ROOT_DIR}/scripts/memory-evaluation-check.sh" --count-supersedes-links
}

expect_count() {
  local label="$1"
  local expected="$2"
  local sandbox="${WORK_DIR}/${label}"
  local actual

  prepare_sandbox "$sandbox"

  case "$label" in
    empty-supersedes-list)
      cat >"${sandbox}/memory/lessons/empty.md" <<'EOF'
---
id: "memory-evaluation-fixture-empty"
title: "Empty Supersedes Fixture"
type: "memory"
status: "active"
owner: "agent"
created: "2026-05-08"
updated: "2026-05-08"
tags:
  - fixture
summary: "Fixture memory note with an empty supersedes declaration."
supersedes: []
---

# Empty Supersedes Fixture
EOF
      ;;
    body-supersedes-snippet)
      cat >"${sandbox}/memory/lessons/body.md" <<'EOF'
---
id: "memory-evaluation-fixture-body"
title: "Body Supersedes Fixture"
type: "memory"
status: "active"
owner: "agent"
created: "2026-05-08"
updated: "2026-05-08"
tags:
  - fixture
summary: "Fixture memory note with supersedes text only in the body."
---

# Body Supersedes Fixture

This body mentions supersedes:

```yaml
supersedes:
  - "body-only-fixture"
```
EOF
      ;;
    non-empty-supersedes-list)
      cat >"${sandbox}/memory/lessons/non-empty.md" <<'EOF'
---
id: "memory-evaluation-fixture-non-empty"
title: "Non Empty Supersedes Fixture"
type: "memory"
status: "active"
owner: "agent"
created: "2026-05-08"
updated: "2026-05-08"
tags:
  - fixture
summary: "Fixture memory note with a real supersedes link."
supersedes:
  - "memory-evaluation-fixture-older"
---

# Non Empty Supersedes Fixture
EOF
      ;;
    combined)
      expect_count empty-supersedes-list 0 >/dev/null
      expect_count body-supersedes-snippet 0 >/dev/null
      expect_count non-empty-supersedes-list 1 >/dev/null
      cp -R "${WORK_DIR}/empty-supersedes-list/memory/lessons/empty.md" "${sandbox}/memory/lessons/"
      cp -R "${WORK_DIR}/body-supersedes-snippet/memory/lessons/body.md" "${sandbox}/memory/lessons/"
      cp -R "${WORK_DIR}/non-empty-supersedes-list/memory/lessons/non-empty.md" "${sandbox}/memory/lessons/"
      ;;
    *)
      fail "unknown fixture case ${label}"
      ;;
  esac

  actual="$(run_count "$sandbox")"
  [ "$actual" = "$expected" ] || {
    fail "${label}: expected ${expected} supersedes links, got ${actual}"
  }

  log "${label}: ${actual} supersedes links"
}

main() {
  mkdir -p "$WORK_DIR"
  trap 'rm -rf "$WORK_DIR"' EXIT

  expect_count empty-supersedes-list 0
  expect_count body-supersedes-snippet 0
  expect_count non-empty-supersedes-list 1
  expect_count combined 1
  log "ok"
}

main "$@"
