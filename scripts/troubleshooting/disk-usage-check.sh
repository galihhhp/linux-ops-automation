#!/usr/bin/env bash
set -e

echo "=== Disk usage (df -h) ==="
df -h

echo ""
echo "=== Top 10 directories by size (du) ==="
du -hx / 2>/dev/null | sort -rh | head -20 || du -sh /* 2>/dev/null
