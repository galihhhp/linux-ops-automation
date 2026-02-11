#!/usr/bin/env bash
set -e

DISK_THRESHOLD="${DISK_THRESHOLD:-90}"
MEMORY_THRESHOLD="${MEMORY_THRESHOLD:-90}"
HTTP_URL="${HTTP_URL:-}"
FAILED=0
MSG=""

check_disk() {
  local pct
  pct=$(df / 2>/dev/null | awk 'NR==2 {gsub(/%/,""); print $5}')
  if [ -n "${pct}" ] && [ "${pct}" -ge "${DISK_THRESHOLD}" ]; then
    MSG="${MSG}Disk usage ${pct}% >= ${DISK_THRESHOLD}%. "
    FAILED=1
  fi
}

check_memory() {
  local used total pct
  used=$(free | awk 'NR==2 {print $3}')
  total=$(free | awk 'NR==2 {print $2}')
  if [ -n "${total}" ] && [ "${total}" -gt 0 ]; then
    pct=$((used * 100 / total))
    if [ "${pct}" -ge "${MEMORY_THRESHOLD}" ]; then
      MSG="${MSG}Memory usage ${pct}% >= ${MEMORY_THRESHOLD}%. "
      FAILED=1
    fi
  fi
}

check_process() {
  local name="$1"
  if ! pgrep -x "${name}" >/dev/null 2>&1; then
    MSG="${MSG}Process ${name} not running. "
    FAILED=1
  fi
}

check_http() {
  local url="$1"
  if [ -z "${url}" ]; then return; fi
  if ! command -v curl >/dev/null 2>&1; then return; fi
  if ! curl -sf --connect-timeout 3 "${url}" >/dev/null 2>&1; then
    MSG="${MSG}HTTP ${url} unreachable. "
    FAILED=1
  fi
}

check_disk
check_memory
check_process postgres
check_http "${HTTP_URL}"

if [ "${FAILED}" -eq 0 ]; then
  echo "OK"
  exit 0
else
  echo "FAIL: ${MSG}"
  exit 1
fi
