#!/usr/bin/env bash
set -e

BACKUP_DIR="${BACKUP_DIR:-/var/backups}"
MIN_DISK_FREE_PCT="${MIN_DISK_FREE_PCT:-10}"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)

if [ -z "${1:-}" ]; then
  echo "Usage: $0 <path_to_backup>" >&2
  exit 1
fi

SRC_PATH="$1"
BASENAME=$(basename "${SRC_PATH}" | tr '/' '_')
OUTPUT_FILE="${BACKUP_DIR}/files_${BASENAME}_${TIMESTAMP}.tar.gz"

mkdir -p "${BACKUP_DIR}"

FREE_PCT=$(df "${BACKUP_DIR}" 2>/dev/null | awk 'NR==2 {gsub(/%/,""); print 100 - $5}')
if [ -n "${FREE_PCT}" ] && [ "${FREE_PCT}" -lt "${MIN_DISK_FREE_PCT}" ]; then
  echo "Aborting: ${FREE_PCT}% disk free on ${BACKUP_DIR} (minimum ${MIN_DISK_FREE_PCT}%)" >&2
  exit 1
fi
tar -czf "${OUTPUT_FILE}" -C "$(dirname "${SRC_PATH}")" "$(basename "${SRC_PATH}")"
echo "${OUTPUT_FILE}"
