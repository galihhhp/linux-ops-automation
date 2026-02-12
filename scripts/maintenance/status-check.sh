#!/usr/bin/env bash
set -e

has_script() {
  [ -x "$1" ] && echo "true" || echo "false"
}

disk_pct() {
  df / 2>/dev/null | awk 'NR==2 {gsub(/%/,""); print $5}'
}

memory_pct() {
  local used total
  used=$(free 2>/dev/null | awk 'NR==2 {print $3}')
  total=$(free 2>/dev/null | awk 'NR==2 {print $2}')
  [ -n "${total}" ] && [ "${total}" -gt 0 ] && echo $((used * 100 / total)) || echo "0"
}

last_backup_age_seconds() {
  local f
  f=$(ls -t /var/backups/postgres_*.sql.gz 2>/dev/null | head -1)
  if [ -n "${f}" ] && [ -f "${f}" ]; then
    local now mtime
    now=$(date +%s)
    mtime=$(stat -c %Y "${f}" 2>/dev/null || echo 0)
    echo $((now - mtime))
  else
    echo "0"
  fi
}

last_backup_timestamp() {
  local f mtime
  f=$(ls -t /var/backups/postgres_*.sql.gz 2>/dev/null | head -1)
  if [ -n "${f}" ]; then
    mtime=$(stat -c %Y "${f}" 2>/dev/null)
    [ -n "${mtime}" ] && date -d "@${mtime}" -u +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || echo ""
  else
    echo ""
  fi
}

cat << EOF
{
  "status": "ok",
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "scripts": {
    "postgres_backup": $(has_script /opt/backup/scripts/postgres-backup.sh),
    "postgres_restore": $(has_script /opt/backup/scripts/postgres-restore.sh),
    "postgres_backup_full": $(has_script /opt/backup/scripts/postgres-backup-full.sh),
    "log_rotation": $(has_script /usr/local/bin/log-rotation.sh),
    "health_check": $(has_script /opt/monitoring/health-check.sh)
  },
  "system": {
    "disk_usage_pct": $(disk_pct),
    "memory_usage_pct": $(memory_pct)
  },
  "backup": {
    "last_local_timestamp": "$(last_backup_timestamp)",
    "last_local_age_seconds": $(last_backup_age_seconds)
  }
}
EOF
