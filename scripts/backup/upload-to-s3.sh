#!/usr/bin/env bash
set -e

BUCKET="${BACKUP_BUCKET:-}"
if [ -z "${BUCKET}" ]; then
  echo "BACKUP_BUCKET env var not set" >&2
  exit 1
fi

if [ -z "${1:-}" ]; then
  echo "Usage: $0 <file_to_upload>" >&2
  exit 1
fi

FILE="$1"
if [ ! -f "${FILE}" ]; then
  echo "File not found: ${FILE}" >&2
  exit 1
fi

if ! aws s3 cp "${FILE}" "s3://${BUCKET}/backups/$(basename "${FILE}")"; then
  echo "Upload failed" >&2
  exit 1
fi

echo "Uploaded to s3://${BUCKET}/backups/$(basename "${FILE}")"
