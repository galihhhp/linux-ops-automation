#!/usr/bin/env bash
set -e

LOG_PATH="${1:-/var/log/syslog}"
LINES="${2:-50}"

if [ ! -f "${LOG_PATH}" ] && [ ! -c "${LOG_PATH}" ]; then
  if command -v journalctl >/dev/null 2>&1; then
    echo "=== journalctl (last ${LINES} lines, errors/warnings) ==="
    journalctl -p err -n "${LINES}" --no-pager 2>/dev/null || true
    echo ""
    journalctl -p warning -n "${LINES}" --no-pager 2>/dev/null || true
  else
    echo "Log path not found: ${LOG_PATH}" >&2
    exit 1
  fi
else
  echo "=== Errors/Warnings in ${LOG_PATH} (last ${LINES} matching lines) ==="
  grep -iE 'error|warn|fail|critical' "${LOG_PATH}" 2>/dev/null | tail -"${LINES}" || echo "No matches or unreadable"
  echo ""
  echo "=== Last ${LINES} lines ==="
  tail -"${LINES}" "${LOG_PATH}" 2>/dev/null
fi
