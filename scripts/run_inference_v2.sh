#!/bin/bash
set -e

#shell 自動印出錯誤幾行和指令
trap 'echo "[ERROR] 發生錯誤，行號 $LINENO，指令：$BASH_COMMAND"; exit 1' ERR

MODEL_PATH="models/pd_v1.eim"

#如果eim還沒匯入
if [ ! -f "$MODEL_PATH" ]; then
  echo "[ERROR] script=run_inference_v2.sh step=check_model message=\"model not found: $MODEL_PATH\>"
  exit 2
fi


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

