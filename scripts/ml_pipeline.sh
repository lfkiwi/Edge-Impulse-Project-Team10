#!/bin/bash
set -e

# logging function
log_info() { echo "[INFO] $*"; }
log_error() { echo "[ERROR] $*" >&2; }

# 取得腳本所在的目錄
SCRIPT_DIR=$(dirname "$(realpath "$0")")
MODEL_PATH="${1:-${SCRIPT_DIR}/../models/pd_v1.eim}"  # 默認模型
DATA_DIR="${2:-${SCRIPT_DIR}/../data/test}"  # 默認資料夾

# ===== 確認模型檔案是否存在 =====
if [ ! -f "$MODEL_PATH" ]; then
  log_error "模型檔案未找到: $MODEL_PATH"
  exit 1
fi

# ===== 確認資料夾是否存在 =====
if [ ! -d "$DATA_DIR" ]; then
  log_error "DATA_DIR does not exist: $DATA_DIR"
  exit 2
fi

log_info "使用模型檔案: $MODEL_PATH"
log_info "使用模型檔案: $DATA_DIR"

# ===== 呼叫 retrain =====
log_info "開始 retrain..."
./scripts/retrain.sh "$DATA_DIR"
RETRAIN_RET=$?

# retrain 失敗
if [ $RETRAIN_RET -ne 0 ]; then
  log_error "Retrain failed with code $RET_CODE"
  exit 3
fi

# ===== 呼叫推論 =====
log_info "Retrain 成功，開始批次推論..."
./scripts/run_inference_v2.sh "$MODEL_PATH" "$DATA_DIR"  # 傳遞模型路徑和資料夾路徑
INFER_RET=$?

if [ $INFER_RET -ne 0 ]; then
    log_error "Inference 失敗"
    exit 4
fi

# ===== 呼叫 smoke_test =====
log_info "批次推論成功，開始smoke_test..."
./scripts/smoke_test.sh "$DATA_DIR"
SMOKE_RET=$?

if [ $SMOKE_RET -ne 0 ]; then
    log_error "SMOKE_TEST 失敗"
    exit 5
fi

# 成功
log_info "Pipeline finished successfully."
exit 0
