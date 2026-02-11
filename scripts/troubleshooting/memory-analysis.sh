#!/usr/bin/env bash
set -e

echo "=== Memory (free -h) ==="
free -h

echo ""
echo "=== Top 10 processes by memory ==="
ps aux --sort=-%mem 2>/dev/null | head -11 || ps -eo pid,user,%mem,%cpu,comm --sort=-%mem | head -11
