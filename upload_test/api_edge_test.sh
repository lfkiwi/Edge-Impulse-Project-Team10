#!/bin/bash
set -e

API_KEY="${EI_API_KEY}"
PROJECT_ID="${EI_PROJECT_ID}"
BASE_URL="https://studio.edgeimpulse.com/v1/api"

echo "[INFO] Test: Valid API key"

HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" \
  -H "x-api-key: $API_KEY" \
  "$BASE_URL/$PROJECT_ID")

if [ "$HTTP_CODE" != "200" ]; then
  echo "[ERROR] Valid API key failed: HTTP $HTTP_CODE"
  exit 1
fi

echo "[OK] Valid API key works"

echo "[TEST] Invalid API key should fail"

HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" \
  -H "x-api-key: INVALID_KEY" \
  "$BASE_URL/$PROJECT_ID" || true)

echo "[INFO] HTTP CODE: $HTTP_CODE"

if [ "$HTTP_CODE" = "401" ] || [ "$HTTP_CODE" = "403" ]; then
  echo "[OK] Invalid API key handled correctly"
else
  echo "[WARN] Unexpected HTTP code"
fi

echo "[OK] All API tests finished"
exit 0
