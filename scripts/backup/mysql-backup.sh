#!/usr/bin/env bash
set -e

BACKUP_DIR="${BACKUP_DIR:-/var/backups}"
DB_NAME="${DB_NAME:-app_db}"
DB_USER="${DB_USER:-root}"
DB_HOST="${DB_HOST:-localhost}"
MIN_DISK_FREE_PCT="${MIN_DISK_FREE_PCT:-10}"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
OUTPUT_FILE="${BACKUP_DIR}/mysql_${DB_NAME}_${TIMESTAMP}.sql.gz"

if ! command -v mysqldump >/dev/null 2>&1; then
  echo "MySQL backup skipped: mysqldump not installed" >&2
  exit 0
fi

mkdir -p "${BACKUP_DIR}"

FREE_PCT=$(df "${BACKUP_DIR}" 2>/dev/null | awk 'NR==2 {gsub(/%/,""); print 100 - $5}')
if [ -n "${FREE_PCT}" ] && [ "${FREE_PCT}" -lt "${MIN_DISK_FREE_PCT}" ]; then
  echo "Aborting: ${FREE_PCT}% disk free on ${BACKUP_DIR} (minimum ${MIN_DISK_FREE_PCT}%)" >&2
  exit 1
fi
mysqldump -h "${DB_HOST}" -u "${DB_USER}" "${DB_NAME}" 2>/dev/null | gzip > "${OUTPUT_FILE}" || {
  echo "MySQL backup failed: check credentials and that MySQL is running" >&2
  exit 1
}
echo "${OUTPUT_FILE}"
