#!/bin/bash
set -e

if [ -z "$API_KEY" ] || [ -z "$PROJECT_ID" ]; then
  echo "[WARN] API_KEY or PROJECT_ID not set, skip API test"
  exit 0
fi

API_KEY="${EI_API_KEY}"
PROJECT_ID="${EI_PROJECT_ID}"

BASE_URL="https://studio.edgeimpulse.com/v1/api"

echo "[INFO] Test: Training API"
TRAIN_RESPONSE=$(curl -s -X POST \
  -H "x-api-key: $API_KEY" \
  "$BASE_URL/$PROJECT_ID/jobs/train")

echo "$TRAIN_RESPONSE" | jq .

SUCCESS=$(echo "$TRAIN_RESPONSE" | jq -r '.success')

if [ "$SUCCESS" != "true" ]; then
  echo "[ERROR] Training API failed"
  exit 1
fi

echo "[INFO] Training API OK"

echo "[INFO] Test: Download model API"
curl -s -L \
  -H "x-api-key: $API_KEY" \
  "$BASE_URL/$PROJECT_ID/deployment/download?type=linux" \
  -o test_model.eim

if [ ! -f test_model.eim ]; then
  echo "[ERROR] Model download failed"
  exit 2
fi

echo "[INFO] Model downloaded successfully"
exit 0
