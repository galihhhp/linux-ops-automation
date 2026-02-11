#!/usr/bin/env bash
set -e

echo "=== Listening ports (ss -tlnp) ==="
ss -tlnp 2>/dev/null || netstat -tlnp 2>/dev/null

echo ""
echo "=== Connectivity checks ==="
for host in 127.0.0.1 8.8.8.8; do
  if ping -c 1 -W 2 "${host}" >/dev/null 2>&1; then
    echo "ping ${host}: OK"
  else
    echo "ping ${host}: FAIL"
  fi
done
if command -v curl >/dev/null 2>&1; then
  curl -s -o /dev/null -w "curl https://httpbin.org/get: %{http_code}\n" --connect-timeout 3 https://httpbin.org/get 2>/dev/null || echo "curl: FAIL (no network or timeout)"
fi
