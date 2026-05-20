#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  scripts/background-flash-outbox-check.sh FILE [FILE...]

Checks that a background-flash-suppression outbox reply contains the evidence
headings required by skills/background-flash-suppression/SKILL.md, plus exactly
one next-supervisor-pressure or bounded-refusal line.
EOF
}

if [ "$#" -eq 0 ]; then
  usage >&2
  exit 2
fi

required_headings=(
  "Reviewed Evidence"
  "Background Goal"
  "Candidate Flashes"
  "Suppressed Candidates"
  "Chosen Delivery"
  "Evaluation Evidence"
  "Anti-Noise Boundary"
  "Return-To-Main Judgment"
)

errors=0

error() {
  echo "background-flash-outbox-check: $*" >&2
  errors=$((errors + 1))
}

count_pattern() {
  local pattern="$1"
  local file="$2"

  if rg -q "$pattern" "$file"; then
    rg "$pattern" "$file" | wc -l | tr -d ' '
  else
    printf '0'
  fi
}

check_file() {
  local file="$1"

  if [ ! -f "$file" ]; then
    error "${file}: file not found"
    return
  fi

  local heading
  for heading in "${required_headings[@]}"; do
    if ! rg -q "^#{1,6}[[:space:]]+${heading}[[:space:]]*$" "$file"; then
      error "${file}: missing heading '${heading}'"
    fi
  done

  local next_count no_next_count next_total
  next_count="$(count_pattern '^Next supervisor pressure:' "$file")"
  no_next_count="$(count_pattern '^No next supervisor pressure:' "$file")"
  next_total=$((next_count + no_next_count))

  if [ "$next_total" -ne 1 ]; then
    error "${file}: expected exactly one next supervisor pressure or refusal line, found ${next_total}"
  fi
}

for file in "$@"; do
  check_file "$file"
done

if [ "$errors" -gt 0 ]; then
  exit 1
fi

echo "background-flash-outbox-check: ok"
