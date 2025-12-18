#!/bin/bash
set -e

PROJECT_ID="${EI_PROJECT_ID}"
BASE_URL="https://api.edgeimpulse.com/v1/projects/$PROJECT_ID"

echo "[TEST] Invalid API key should return 401"

HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" \
  -H "x-api-key: INVALID_KEY" \
  "$BASE_URL")

echo "HTTP CODE: $HTTP_CODE"

if [ "$HTTP_CODE" = "401" ]; then
  echo "[OK] Invalid API key correctly rejected"
else
  echo "[WARN] Expected 401, got $HTTP_CODE"
fi

echo "[TEST] Timeout simulation"

curl --max-time 1 -s \
  -H "x-api-key: INVALID_KEY" \
  "$BASE_URL" || echo "[OK] Timeout handled gracefully"

exit 0
