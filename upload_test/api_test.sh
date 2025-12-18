#!/bin/bash
set -e

API_KEY="${EI_API_KEY}"
PROJECT_ID="${EI_PROJECT_ID}"

if [ -z "$API_KEY" ] || [ -z "$PROJECT_ID" ]; then
  echo "[WARN] EI_API_KEY or EI_PROJECT_ID not set, skip API test"
  exit 0
fi

BASE_URL="https://api.edgeimpulse.com/v1"
PROJECT_URL="$BASE_URL/projects/$PROJECT_ID"

echo "[INFO] Test: Get Project Info API"

RESPONSE=$(curl -s \
  -H "x-api-key: $API_KEY" \
  "$PROJECT_URL")

echo "[DEBUG] Raw response:"
echo "$RESPONSE"

# 確保是 JSON
if ! echo "$RESPONSE" | jq . >/dev/null 2>&1; then
  echo "[ERROR] API response is not valid JSON"
  exit 5
fi

PROJECT_NAME=$(echo "$RESPONSE" | jq -r '.name')

if [ "$PROJECT_NAME" = "null" ] || [ -z "$PROJECT_NAME" ]; then
  echo "[ERROR] Failed to get project info"
  exit 6
fi

echo "[INFO] Project info OK: $PROJECT_NAME"
exit 0
