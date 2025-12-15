#!/usr/bin/env bash

echo "[PIPELINE] Starting ML pipeline..."

# ===== 確認參數是否正確 =====
if [ $# -lt 1 ]; then
  echo "[ERROR] Missing DATA_DIR argument"
  # 回傳碼
  exit 1
fi

DATA_DIR="$1"

# ===== 確認資料夾是否存在 =====
if [ ! -d "$DATA_DIR" ]; then
  echo "[ERROR] DATA_DIR does not exist: $DATA_DIR"
  exit 2
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# ===== 呼叫 retrain =====
bash "$SCRIPT_DIR/retrain.sh" "$DATA_DIR"
RET_CODE=$?

# retrain 失敗
if [ $RET_CODE -ne 0 ]; then
  echo "[PIPELINE] Retrain failed with code $RET_CODE"
  exit $RET_CODE
fi

# 成功
echo "[PIPELINE] Pipeline finished successfully."
exit 0
