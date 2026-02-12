#!/usr/bin/env bash
set -e

cd /tmp
export HOME=/root

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f /etc/default/backup ]; then
  set -a
  source /etc/default/backup
  set +a
fi

OUTPUT_FILE=$("${SCRIPT_DIR}/postgres-backup.sh")
if [ -z "${OUTPUT_FILE}" ] || [ ! -f "${OUTPUT_FILE}" ]; then
  echo "PostgreSQL backup failed or produced no output" >&2
  exit 1
fi

if [ -n "${BACKUP_BUCKET}" ] && command -v aws >/dev/null 2>&1; then
  "${SCRIPT_DIR}/upload-to-s3.sh" "${OUTPUT_FILE}" || true
fi

if [ -f "${SCRIPT_DIR}/maintenance/cleanup-old-backups.sh" ]; then
  "${SCRIPT_DIR}/maintenance/cleanup-old-backups.sh" || true
fi
