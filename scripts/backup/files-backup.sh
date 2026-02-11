#!/usr/bin/env bash
set -e

BACKUP_DIR="${BACKUP_DIR:-/var/backups}"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)

if [ -z "${1:-}" ]; then
  echo "Usage: $0 <path_to_backup>" >&2
  exit 1
fi

SRC_PATH="$1"
BASENAME=$(basename "${SRC_PATH}" | tr '/' '_')
OUTPUT_FILE="${BACKUP_DIR}/files_${BASENAME}_${TIMESTAMP}.tar.gz"

mkdir -p "${BACKUP_DIR}"
tar -czf "${OUTPUT_FILE}" -C "$(dirname "${SRC_PATH}")" "$(basename "${SRC_PATH}")"
echo "${OUTPUT_FILE}"
