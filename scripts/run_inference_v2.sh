#!/bin/bash
set -e  # 遇到任何錯誤就停止執行

# ===== logging 函數 =====
# ts() 取得時間戳
ts() { date +"%Y-%m-%d %H:%M:%S"; }

# log_info / log_warn / log_error：輸出不同等級的訊息
log_info()  { echo "[$(ts)] [INFO] $*"; }
log_warn()  { echo "[$(ts)] [WARN] $*"; }
log_error() { echo "[$(ts)] [ERROR] $*" >&2; }

# 記錄腳本啟動
log_info "script=run_inference_v2.sh status=START pid=$$"

# ===== 設定錯誤 trap =====
# 發生錯誤時印出行號、指令，並退出
trap 'log_error "發生錯誤，行號 $LINENO，指令：$BASH_COMMAND"; exit 1' ERR
log_info "script=run_inference_v2.sh trap=ERR_enabled"

# ===== 模型與資料夾參數 =====
# 支援三個參數：
# $1 模型檔案，預設 models/pd_v1.eim
# $2 輸入資料夾，預設 data/test
# $3 輸出資料夾，預設 results
MODEL_PATH="${1:-models/pd_v1.eim}"
INPUT_PATH="${2:-data/test}"
OUTPUT_PATH="${3:-results}"

# ===== 檢查模型檔案是否存在 =====
log_info "step=check_model model_path=$MODEL_PATH"
if [ ! -f "$MODEL_PATH" ]; then
    log_error "step=check_model status=FAIL reason=model_not_found"
    exit 2
fi
log_info "step=check_model status=OK"

# ===== 檢查輸入資料夾是否存在 =====
log_info "step=check_input_dir image_dir=$INPUT_PATH"
if [ ! -d "$INPUT_PATH" ]; then
    log_error "step=check_input_dir status=FAIL reason=dir_not_found"
    exit 3
fi

# ===== 建立輸出資料夾 =====
# 每次推論建立唯一資料夾，避免覆蓋
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
OUTPUT_DIR="$OUTPUT_PATH/${TIMESTAMP}"
mkdir -p "$OUTPUT_DIR"
log_info "step=prepare_output_dir output_dir=$OUTPUT_DIR status=OK"

# ===== 批次推論開始 =====
log_info "step=inference_batch status=START"

total=0       # 總圖片數量
done_count=0  # 已完成圖片數量

# ===== 計算總圖片數量 =====
for img in "$INPUT_PATH"/*.{jpg,JPG,jpeg,JPEG}; do
    [ -f "$img" ] && total=$((total+1))
done

# 沒有圖片就警告並退出
if [ "$total" -eq 0 ]; then
    log_warn "step=inference_batch message=no_images_found path=$INPUT_PATH"
    exit 0
fi

log_info "step=inference_batch total_images=$total"

# ===== 對每張圖片執行推論 =====
for img in "$INPUT_PATH"/*.{jpg,JPG,jpeg,JPEG}; do
    [ -f "$img" ] || continue  # 如果不是檔案就跳過

    done_count=$((done_count+1))   # 更新已完成數量
    BASENAME=$(basename "$img")    # 取得檔名
    OUTPUT_FILE="$OUTPUT_DIR/${BASENAME%.*}_result.jpg"  # 結果檔名

    # log 當前進度
    log_info "step=inference_batch progress=$done_count/$total current_image=$img"

    # 呼叫 Python 腳本做推論
    python3 scripts/classify_od.py "$MODEL_PATH" "$img" "$OUTPUT_FILE"

    # log 結果檔案
    log_info "step=inference_batch output_file=$OUTPUT_FILE"
done

# ===== 批次推論結束 =====
log_info "step=inference_batch status=END"
log_info "[INFO] 批次推論完成，結果都在 $OUTPUT_DIR"
log_info "script=run_inference_v2.sh status=END output_dir=$OUTPUT_DIR"

