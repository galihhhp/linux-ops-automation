#!/usr/bin/env bash
set -e

RETENTION_DAYS="${RETENTION_DAYS:-7}"
BACKUP_DIR="${BACKUP_DIR:-/var/backups}"
BUCKET="${BACKUP_BUCKET:-}"

find "${BACKUP_DIR}" -type f \( -name "*.sql.gz" -o -name "*.tar.gz" \) -mtime +${RETENTION_DAYS} -delete

if [ -n "${BUCKET}" ] && command -v aws >/dev/null 2>&1; then
  CUTOFF=$(date -d "-${RETENTION_DAYS} days" +%s 2>/dev/null || true)
  if [ -n "${CUTOFF}" ]; then
    aws s3 ls "s3://${BUCKET}/backups/" --recursive 2>/dev/null | while read -r line; do
      DATE_PART=$(echo "$line" | awk '{print $1, $2}')
      KEY=$(echo "$line" | awk '{print $4}')
      if [ -n "${KEY}" ]; then
        OBJ_TS=$(date -d "${DATE_PART}" +%s 2>/dev/null || echo 0)
        if [ "${OBJ_TS}" -lt "${CUTOFF}" ] 2>/dev/null; then
          aws s3 rm "s3://${BUCKET}/${KEY}" 2>/dev/null || true
        fi
      fi
    done
  fi
fi
