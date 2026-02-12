#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f /etc/default/backup ]; then
  set -a
  source /etc/default/backup
  set +a
fi

BACKUP_DIR="${BACKUP_DIR:-/var/backups}"
DB_NAME="${DB_NAME:-app_db}"
DB_USER="${DB_USER:-postgres}"
BUCKET="${BACKUP_BUCKET:-}"
S3_PREFIX="${S3_PREFIX:-backups}"

usage() {
  echo "Usage: $0 <s3_key|latest> [--no-drop]" >&2
  echo "  s3_key   - S3 object key (e.g. backups/postgres_app_db_20250112-020000.sql.gz)" >&2
  echo "  latest   - Use most recent backup for ${DB_NAME}" >&2
  echo "  --no-drop - Append to existing DB instead of drop/recreate" >&2
  exit 1
}

APPEND_MODE=false
S3_KEY=""

for arg in "$@"; do
  case "$arg" in
    --no-drop) APPEND_MODE=true ;;
    *)
      if [ -n "$S3_KEY" ]; then
        usage
      fi
      case "$arg" in
        latest) S3_KEY="latest" ;;
        backups/*) S3_KEY="$arg" ;;
        postgres_*.sql.gz) S3_KEY="${S3_PREFIX}/${arg}" ;;
        *) S3_KEY="$arg" ;;
      esac
      ;;
  esac
done

[ -z "$S3_KEY" ] && usage

if [ -z "$BUCKET" ] || ! command -v aws >/dev/null 2>&1; then
  echo "BACKUP_BUCKET must be set and aws CLI required for S3 restore" >&2
  exit 1
fi

if [ "$S3_KEY" = "latest" ]; then
  FILENAME=$(aws s3 ls "s3://${BUCKET}/${S3_PREFIX}/" 2>/dev/null | \
    grep "postgres_${DB_NAME}_" | \
    sort -k1,2 -r | \
    head -1 | \
    awk '{print $4}')
  if [ -z "$FILENAME" ]; then
    echo "No backup found for ${DB_NAME} in s3://${BUCKET}/${S3_PREFIX}/" >&2
    exit 1
  fi
  S3_KEY="${S3_PREFIX}/${FILENAME}"
  echo "Using latest: ${S3_KEY}"
fi

TMP_FILE=$(mktemp)
trap 'rm -f "${TMP_FILE}"' EXIT

if ! aws s3 cp "s3://${BUCKET}/${S3_KEY}" "${TMP_FILE}"; then
  echo "Failed to download s3://${BUCKET}/${S3_KEY}" >&2
  exit 1
fi

if [ "$APPEND_MODE" = false ]; then
  if [ "$(whoami)" = "root" ]; then
    sudo -u postgres psql -c "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname = '${DB_NAME}' AND pid <> pg_backend_pid();" postgres 2>/dev/null || true
    sudo -u postgres dropdb --if-exists "${DB_NAME}"
    sudo -u postgres createdb "${DB_NAME}"
  else
    psql -U "${DB_USER}" -d postgres -c "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname = '${DB_NAME}' AND pid <> pg_backend_pid();" 2>/dev/null || true
    dropdb -U "${DB_USER}" --if-exists "${DB_NAME}"
    createdb -U "${DB_USER}" "${DB_NAME}"
  fi
fi

if [ "$(whoami)" = "root" ]; then
  gunzip -c "${TMP_FILE}" | sudo -u postgres psql -d "${DB_NAME}" -q
else
  gunzip -c "${TMP_FILE}" | psql -U "${DB_USER}" -d "${DB_NAME}" -q
fi

echo "Restored ${DB_NAME} from ${S3_KEY}"
