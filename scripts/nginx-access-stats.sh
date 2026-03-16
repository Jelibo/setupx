#!/usr/bin/env bash
# Parse nginx access log and print top IPs, URIs, and status codes
set -euo pipefail

LOG_FILE="${1:-/var/log/nginx/access.log}"
TOP_N="${2:-10}"

if [[ ! -f "$LOG_FILE" ]]; then
  echo "Log file not found: $LOG_FILE" >&2
  exit 1
fi

echo "=== Top $TOP_N IPs ==="
awk '{print $1}' "$LOG_FILE" | sort | uniq -c | sort -rn | head -"$TOP_N"

echo ""
echo "=== Top $TOP_N Requested URIs ==="
awk '{print $7}' "$LOG_FILE" | sort | uniq -c | sort -rn | head -"$TOP_N"

echo ""
echo "=== HTTP Status Code Distribution ==="
awk '{print $9}' "$LOG_FILE" | sort | uniq -c | sort -rn

echo ""
echo "=== Top $TOP_N User Agents ==="
awk -F'"' '{print $6}' "$LOG_FILE" | sort | uniq -c | sort -rn | head -"$TOP_N"

echo ""
TOTAL=$(wc -l < "$LOG_FILE" | xargs)
echo "Total requests: $TOTAL"
