#!/bin/bash

echo "[PIPELINE] Starting ML pipeline..."

DATA_DIR=$1

# ===== 確認資料夾參數 =====
if [ -z "$DATA_DIR" ]; then
  echo "[ERROR] Missing DATA_DIR argument"
  # 回傳碼
  exit 1
fi

# ===== 確認資料夾是否存在 =====
if [ ! -d "$DATA_DIR" ]; then
  echo "[ERROR] DATA_DIR does not exist: $DATA_DIR"
  exit 2
fi


# ===== 呼叫 retrain =====
echo "[INFO] 開始 retrain..."
./scripts/retrain.sh "$DATA_DIR"
RETRAIN_RET=$?

# retrain 失敗
if [ $RETRAIN_RET -ne 0 ]; then
  echo "[PIPELINE] Retrain failed with code $RET_CODE"
  exit 3
fi

echo "[INFO] Retrain 成功，開始批次推論..."
python3 scripts/classify_od.py models/person_detector.eim "$DATA_DIR"
INFER_RET=$?

if [ $INFER_RET -ne 0 ]; then
    echo "[ERROR] Inference 失敗"
    exit 4
fi

# 成功
echo "[PIPELINE] Pipeline finished successfully."
exit 0
