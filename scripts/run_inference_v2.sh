#!/bin/bash
set -e

# ===== logging =====
ts() { date +"%Y-%m-%d %H:%M:%S"; }
log_info()  { echo "[$(ts)] [INFO] $*"; }
log_warn()  { echo "[$(ts)] [WARN] $*"; }
log_error() { echo "[$(ts)] [ERROR] $*" >&2; }

log_info "script=run_inference_v2.sh status=START pid=$$"

trap 'log_error "發生錯誤，行號 $LINENO，指令：$BASH_COMMAND"; exit 1' ERR
log_info "script=run_inference_v2.sh trap=ERR_enabled"

# ===== model =====
MODEL_PATH="${1:-models/pd_v1.eim}"
INPUT_PATH="${2:-data/test}"
OUTPUT_PATH="${3:-results}"

log_info "step=check_model model_path=$MODEL_PATH"

if [ ! -f "$MODEL_PATH" ]; then
    log_error "step=check_model status=FAIL reason=model_not_found"
    exit 2
fi

log_info "step=check_model status=OK"

# ===== input dir =====
log_info "step=check_input_dir image_dir=$INPUT_PATH"
if [ ! -d "$INPUT_PATH" ]; then
    log_error "step=check_input_dir status=FAIL reason=dir_not_found"
    exit 3
fi

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
OUTPUT_DIR="results/${TIMESTAMP}"
mkdir -p "$OUTPUT_DIR"
log_info "step=prepare_output_dir output_dir=$OUTPUT_DIR status=OK"

# ===== batch inference =====
log_info "step=inference_batch status=START"

total=0
done_count=0

# 先數有幾張
for img in "$INPUT_PATH"/*.{jpg,JPG,jpeg,JPEG}; do
    [ -f "$img" ] && total=$((total+1))
done
if [ "$total" -eq 0 ]; then
    log_warn "step=inference_batch message=no_images_found path=$INPUT_PATH"
    exit 0
fi

log_info "step=inference_batch total_images=$total"
for img in "$INPUT_PATH"/*.{jpg,JPG,jpeg,JPEG}; do
    [ -f "$img" ] || continue
    done_count=$((done_count+1))
    BASENAME=$(basename "$img")
    OUTPUT_FILE="$OUTPUT_DIR/${BASENAME%.*}_result.jpg"

    log_info "step=inference_batch progress=$done_count/$total current_image=$img"
    python3 scripts/classify_od.py "$MODEL_PATH" "$img" "$OUTPUT_FILE"
    log_info "step=inference_batch output_file=$OUTPUT_FILE"
done

log_info "step=inference_batch status=END"
log_info "[INFO] 批次推論完成，結果都在 $OUTPUT_DIR"
log_info "script=run_inference_v2.sh status=END output_dir=$OUTPUT_DIR"
