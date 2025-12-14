#!/usr/bin/env bash
set -e

echo "[RETRAIN] Retrain script started..."

# 確認參數
if [ $# -lt 1 ]; then
  echo "[RETRAIN][ERROR] Missing DATA_DIR argument"
  exit 10
fi

DATA_DIR="$1"

# 確認資料夾
if [ ! -d "$DATA_DIR" ]; then
  echo "[RETRAIN][ERROR] DATA_DIR not found: $DATA_DIR"
  exit 11
fi

echo "[RETRAIN] Using data directory: $DATA_DIR"

# 上傳影像資料（Object Detection）
echo "[RETRAIN] Uploading images..."
node "$HOME/.nvm/versions/node/$(nvm version)/lib/node_modules/edge-impulse-cli/cli.js" uploader "$DATA_DIR"

# 觸發訓練
echo "[RETRAIN] Triggering Edge Impulse training..."
node "$HOME/.nvm/versions/node/$(nvm version)/lib/node_modules/edge-impulse-cli/cli.js" retrain

echo "[RETRAIN] Retrain completed successfully."
exit 0
