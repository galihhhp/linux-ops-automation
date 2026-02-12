#!/usr/bin/env bash
set -e

LOGROTATE_CONF="${LOGROTATE_CONF:-/etc/logrotate.d/linux-ops}"

if [ ! -f "${LOGROTATE_CONF}" ]; then
  echo "Logrotate config not found: ${LOGROTATE_CONF}" >&2
  echo "Run provision first to deploy the config" >&2
  exit 1
fi

if [ "${1:-}" = "-f" ] || [ "${1:-}" = "--force" ]; then
  logrotate -f "${LOGROTATE_CONF}"
else
  logrotate "${LOGROTATE_CONF}"
fi
