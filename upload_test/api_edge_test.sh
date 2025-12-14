#!/bin/bash

PROJECT_ID= #"YOUR_PROJECT_ID"
BASE_URL="https://studio.edgeimpulse.com/v1/api"

echo "[TEST] Invalid API key"
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" \
  -H "x-api-key: INVALID_KEY" \
  -X POST \
  "$BASE_URL/$PROJECT_ID/jobs/train")

echo "HTTP CODE: $HTTP_CODE"

if [ "$HTTP_CODE" != "401" ]; then
  echo "[WARN] Expected 401 but got $HTTP_CODE"
else
  echo "[OK] Invalid token handled correctly"
fi

echo "[TEST] Timeout simulation"
curl --max-time 1 -s \
  -H "x-api-key: INVALID_KEY" \
  "$BASE_URL/$PROJECT_ID/jobs/train" || echo "[OK] Timeout handled"