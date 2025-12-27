#!/bin/bash
set -e

API_KEY="${EI_API_KEY}"
PROJECT_ID="${EI_PROJECT_ID}"
BASE_URL="https://studio.edgeimpulse.com/v1/api"

echo "[INFO] Test: Valid API key for project"

HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" \
  -H "x-api-key: ${API_KEY}" \
  "${BASE_URL}/${PROJECT_ID}")

if [ "${HTTP_CODE}" != "200" ]; then
  echo "[ERROR] API test failed, HTTP ${HTTP_CODE}"
  exit 1
fi

echo "[OK] API returned 200 OK"
echo "[OK] Project info API works correctly"

exit 0
