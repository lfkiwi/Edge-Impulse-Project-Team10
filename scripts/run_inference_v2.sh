#!/bin/bash
set -e

MODEL_PATH="models/pd_v1.eim"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
OUTPUT_DIR="results/${TIMESTAMP}"
mkdir -p "$OUTPUT_DIR"

for img in data/test/*.{jpg,JPG,jpeg,JPEG}; do
    [ -f "$img" ] || continue  # 沒有匹配檔案就跳過
    BASENAME=$(basename "$img")
    OUTPUT_FILE="$OUTPUT_DIR/${BASENAME%.*}_result.jpg"
    echo "[INFO] 推論 $img → $OUTPUT_FILE"
    python3 scripts/run3.py "$MODEL_PATH" "$img" "$OUTPUT_FILE"
done

echo "[INFO] 批次推論完成，結果都在 $OUTPUT_DIR"

