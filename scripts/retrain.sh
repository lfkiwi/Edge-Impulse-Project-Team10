#!/usr/bin/env bash
set -e

echo "[RETRAIN] Retrain script started..."

# 確認參數
if [ $# -lt 1 ]; then
  echo "[RETRAIN][ERROR] Missing DATA_DIR argument"
  exit 10
fi

SCRIPT_DIR=$(dirname "$(realpath "$0")")
DATA_DIR="${1:-${SCRIPT_DIR}/../data/test}"


# 確認資料夾
if [ ! -d "$DATA_DIR" ]; then
  echo "[RETRAIN][ERROR] DATA_DIR not found: $DATA_DIR"
  exit 11
fi

echo "[RETRAIN] Using data directory: $DATA_DIR"

# 上傳影像資料（Object Detection）
echo "[RETRAIN] Uploading images..."

# 觸發訓練
echo "[RETRAIN] Triggering Edge Impulse training..."

sleep 1

echo "[RETRAIN] Simulate Retrain completed successfully."
exit 0
