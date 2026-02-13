#!/usr/bin/env bash
set -e

BACKUP_DIR="${BACKUP_DIR:-/var/backups}"
DB_NAME="${DB_NAME:-app_db}"
DB_USER="${DB_USER:-postgres}"
MIN_DISK_FREE_PCT="${MIN_DISK_FREE_PCT:-10}"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
OUTPUT_FILE="${BACKUP_DIR}/postgres_${DB_NAME}_${TIMESTAMP}.sql.gz"

mkdir -p "${BACKUP_DIR}"

FREE_PCT=$(df "${BACKUP_DIR}" 2>/dev/null | awk 'NR==2 {gsub(/%/,""); print 100 - $5}')
if [ -n "${FREE_PCT}" ] && [ "${FREE_PCT}" -lt "${MIN_DISK_FREE_PCT}" ]; then
  echo "Aborting: ${FREE_PCT}% disk free on ${BACKUP_DIR} (minimum ${MIN_DISK_FREE_PCT}%)" >&2
  exit 1
fi
if [ "$(whoami)" = "root" ]; then
  sudo -u postgres pg_dump -d "${DB_NAME}" | gzip > "${OUTPUT_FILE}"
else
  pg_dump -U "${DB_USER}" -d "${DB_NAME}" | gzip > "${OUTPUT_FILE}"
fi
echo "${OUTPUT_FILE}"
