#!/bin/bash
set -e
#logging/ shell負責流程 py負責程

#統一時間格式的 function
ts() { date +"%Y-%m-%d %H:%M:%S"; }

#log level function（INFO / WARN / ERROR）
log_info()  { echo "[$(ts)] [INFO] $*"; }
log_warn()  { echo "[$(ts)] [WARN] $*"; }
log_error() { echo "[$(ts)] [ERROR] $*" >&2; }

#腳本開始 log
log_info "script=run_inference_v2.sh status=START pid=$$"


#shell 自動印出錯誤幾行和指令
trap 'echo "[ERROR] 發生錯誤，行號 $LINENO，指令：$BASH_COMMAND"; exit 1' ERR

#確認 trap 已設定
log_info "script=run_inference_v2.sh trap=ERR_enabled"

MODEL_PATH="models/pd_v1.eim"

#model已開始
log_info "step=check_model model_path=$MODEL_PATH"


#如果eim還沒匯入
if [ ! -f "$MODEL_PATH" ]; then
    #錯誤原因
    log_error "step=check_model status=FAIL reason=model_not_found"
    
    #echo "[ERROR] script=run_inference_v2.sh step=check_model message=\"model not found: $MODEL_PATH\>"
    exit 2
fi

#model結束
log_info "step=check_model status=END"

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
OUTPUT_DIR="results/${TIMESTAMP}"
mkdir -p "$OUTPUT_DIR"

#輸出資料夾資訊
log_info "step=prepare_output_dir output_dir=$OUTPUT_DIR status=OK"

#step：inference_batch 開始
log_info "step=inference_batch status=START"

#圖片數量提示(batch進度)
total=0

for img in data/test/*.{jpg,JPG,jpeg,JPEG}; do
    [ -f "$img" ] || continue  # 沒有匹配檔案就跳過
    BASENAME=$(basename "$img")
    OUTPUT_FILE="$OUTPUT_DIR/${BASENAME%.*}_result.jpg"
    echo "[INFO] 推論 $img → $OUTPUT_FILE"
    python3 scripts/run3.py "$MODEL_PATH" "$img" "$OUTPUT_FILE"
done


#graph
if [ "$total" -eq 0 ]; then
    log_warn "step=inference_batch message=no_images_found path=data/test"
else
    log_info "step=inference_batch total_images=$total"
fi

done_count=0

for img in data/test/*.{jpg,JPG,jpeg,JPEG}; do
    [ -f "$img" ] || continue # 沒有匹配檔案就跳過
#知道目前跑到第幾張
    done_count=$((done_count+1))
    log_info "step=inference_batch progress=$done_count/$total current_image=$img"

    BASENAME=$(basename "$img")
    OUTPUT_FILE="$OUTPUT_DIR/${BASENAME%.*}_result.jpg"

# 明確印出輸出檔案路徑

    log_info "step=inference_batch output_file=$OUTPUT_FILE"

    echo "[INFO] 推論 $img -> $OUTPUT_FILE"
    python3 scripts/run3.py "$MODEL_PATH" "$img" "$OUTPUT_FILE"

#單張圖片完成提示
log_info "step=inference_batch status=END"

echo "[INFO] 批次推論完成，結果都在 $OUTPUT_DIR"

#結束log
log_info "script=run_inference_v2.sh status=END output_dir=$OUTPUT_DIR"
