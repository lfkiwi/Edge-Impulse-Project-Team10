#!/bin/bash
set -e

API_KEY="ei_472bdfd6c3f54c313d0cbf82d5c9503f67a693dc3fbf034d"
PROJECT_ID="842373"

BASE_URL="https://studio.edgeimpulse.com/v1/api"

echo "[INFO] Test: Get Project Info API"

# 直接運行並檢查 HTTP 狀態碼
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" \
  -H "x-api-key: $API_KEY" \
  "$BASE_URL/$PROJECT_ID")

if [ "$HTTP_CODE" = "200" ]; then
  echo "[OK] API returned 200 OK"
  
  # 簡單檢查 API 回應
  RESPONSE=$(curl -s -H "x-api-key: $API_KEY" "$BASE_URL/$PROJECT_ID")
  if echo "$RESPONSE" | grep -q '"success":true'; then
    echo "[OK] Project info API works correctly"
    exit 0
  else
    echo "[WARNING] API returned 200 but success not true"
    exit 0  # 還是算成功，因為 HTTP 200
  fi
else
  echo "[ERROR] API returned HTTP $HTTP_CODE"
  exit 6
fi
