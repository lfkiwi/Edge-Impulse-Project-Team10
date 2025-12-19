#!/bin/bash
set -e

API_KEY="${EI_API_KEY}"
PROJECT_ID="${EI_PROJECT_ID}"

# 檢查必要的環境變數
if [ -z "$API_KEY" ]; then
    echo "[ERROR] EI_API_KEY 環境變數未設定"
    exit 1
fi

if [ -z "$PROJECT_ID" ]; then
    echo "[ERROR] EI_PROJECT_ID 環境變數未設定"
    exit 1
fi

BASE_URL="https://studio.edgeimpulse.com/v1/api"

echo "[INFO] Test: Get Project Info API"
echo "[DEBUG] Project ID: ${PROJECT_ID}"
echo "[DEBUG] API Key: ${API_KEY:0:10}..."
