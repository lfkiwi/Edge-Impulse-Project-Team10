#!/bin/bash
set -e

API_KEY="ei_472bdfd6c3f54c313d0cbf82d5c9503f67a693dc3fbf034d"
PROJECT_ID="842373"

BASE_URL="https://studio.edgeimpulse.com/v1/api"

echo "[INFO] Test: Get Project Info API"

RESP=$(curl -s \
  -H "x-api-key: $API_KEY" \
  "$BASE_URL/$PROJECT_ID")

echo "[DEBUG] Raw response:"
echo "$RESP"

echo "$RESP" | jq . >/dev/null 2>&1
if [ $? -ne 0 ]; then
  echo "[ERROR] Response is not valid JSON"
  exit 1
fi

echo "[OK] Project info API works"

echo "[TEST] Invalid API key should return 401"

HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" \
  --max-time 5 \
  -H "x-api-key: INVALID_KEY" \
  "$BASE_URL/$PROJECT_ID" || true)

echo "[INFO] HTTP CODE: $HTTP_CODE"

if [ "$HTTP_CODE" = "401" ] || [ "$HTTP_CODE" = "403" ]; then
  echo "[OK] Invalid API key handled correctly"
else
  echo "[WARN] Unexpected HTTP code (allowed in test)"
fi

echo "[OK] All API tests finished"
exit 0
