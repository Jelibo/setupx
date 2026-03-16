#!/usr/bin/env bash
# Smoke-test a list of HTTP endpoints and report status
set -euo pipefail

ENDPOINTS_FILE="${1:-endpoints.txt}"
TIMEOUT="${TIMEOUT:-10}"
PASS=0
FAIL=0

if [[ ! -f "$ENDPOINTS_FILE" ]]; then
  cat <<'EOF'
Usage: ./healthcheck-endpoints.sh [endpoints-file]

endpoints-file format (one per line):
  https://api.example.com/health
  https://app.example.com/
  200 https://api.example.com/actuator/health   # optional expected status code
EOF
  exit 1
fi

while IFS= read -r line || [[ -n "$line" ]]; do
  [[ "$line" =~ ^#.*$ || -z "$line" ]] && continue

  # Parse optional expected status code prefix
  if [[ "$line" =~ ^([0-9]{3})[[:space:]]+(https?://.+)$ ]]; then
    EXPECTED="${BASH_REMATCH[1]}"
    URL="${BASH_REMATCH[2]}"
  else
    EXPECTED="200"
    URL="$line"
  fi

  HTTP_CODE=$(curl -o /dev/null -s -w "%{http_code}" \
    --max-time "$TIMEOUT" "$URL" || echo "000")

  if [[ "$HTTP_CODE" == "$EXPECTED" ]]; then
    printf "  [PASS] %s  (%s)\n" "$URL" "$HTTP_CODE"
    ((PASS++))
  else
    printf "  [FAIL] %s  (expected %s, got %s)\n" "$URL" "$EXPECTED" "$HTTP_CODE"
    ((FAIL++))
  fi
done < "$ENDPOINTS_FILE"

echo ""
echo "Results: $PASS passed, $FAIL failed."
[[ "$FAIL" -eq 0 ]]
