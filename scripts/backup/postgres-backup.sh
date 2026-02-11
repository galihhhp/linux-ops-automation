#!/usr/bin/env bash
set -e

BACKUP_DIR="${BACKUP_DIR:-/var/backups}"
DB_NAME="${DB_NAME:-app_db}"
DB_USER="${DB_USER:-postgres}"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
OUTPUT_FILE="${BACKUP_DIR}/postgres_${DB_NAME}_${TIMESTAMP}.sql.gz"

mkdir -p "${BACKUP_DIR}"
if [ "$(whoami)" = "root" ]; then
  sudo -u postgres pg_dump -d "${DB_NAME}" | gzip > "${OUTPUT_FILE}"
else
  pg_dump -U "${DB_USER}" -d "${DB_NAME}" | gzip > "${OUTPUT_FILE}"
fi
echo "${OUTPUT_FILE}"
