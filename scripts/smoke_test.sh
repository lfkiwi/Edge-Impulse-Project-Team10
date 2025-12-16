#!/bin/bash
set -e

# logging function
log_info() { echo "[INFO] $*"; }
log_error() { echo "[ERROR] $*" >&2; }

log_info "===== Smoke Test: ML Pipeline ====="

# 取得腳本所在的目錄
SCRIPT_DIR=$(dirname "$(realpath "$0")")
# 設定RESULT_DIR為相對於腳本所在目錄的路徑
RESULT_DIR="${SCRIPT_DIR}/../results"
LATEST_DIR=$(ls -td $RESULT_DIR/*/ | head -n 1)  # 取得最新的資料夾

# -- Test 1: 資料夾是否有結果資料夾 --
if [  ! -d "$RESULT_DIR" ]; then
    log_error "資料夾 $RESULT_DIR 不存在，沒有推論結果"
    exit 1
fi

# -- Test 2: 資料夾是否有結果圖片 --
result_images=$(find "$LATEST_DIR" -type f \( -name "*_result.jpg" -o -name "*_result.JPG" -o -name "*_result.jpeg" -o -name "*_result.JPEG" \) 2>/dev/null)
if [ -z "$result_images" ]; then
    log_error "沒有找到輸出圖片"
    exit 2
fi

# -- Test 3: 每一張結果圖片是否能夠打開 --
for img in $result_images; do
    log_info "測試圖片: $img"

# 使用 Python 來檢查圖片是否能打開
    python3 - <<EOF
import cv2
image = cv2.imread("$img")
if image is None:
    raise Exception("無法讀取結果圖片: $img")
EOF

    if [ $? -ne 0 ]; then
        log_error "無法讀取結果圖片: $img"
        exit 3
    fi
done

log_info "===== Smoke Test Pass ====="
exit 0
