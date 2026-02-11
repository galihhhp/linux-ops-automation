#!/usr/bin/env bash
set -e

if [ -n "${1:-}" ]; then
  PATTERN="$1"
  echo "=== Processes matching: ${PATTERN} ==="
  ps aux | grep -E "${PATTERN}" | grep -v grep || true
  echo ""
  echo "=== PIDs from pgrep ==="
  pgrep -a -f "${PATTERN}" || echo "None found"
else
  echo "=== Top 15 processes by CPU ==="
  ps aux --sort=-%cpu 2>/dev/null | head -16 || ps -eo pid,user,%cpu,%mem,comm --sort=-%cpu | head -16
fi
