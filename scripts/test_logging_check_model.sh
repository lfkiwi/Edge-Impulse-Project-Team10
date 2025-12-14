<<<<<<< HEAD

=======
#!/bin/bash
set -e

# 驗證模型不存在時，run_inference_v2.sh 能正確印 log 並 exit 2

SCRIPT="scripts/run_inference_v2.sh"
MODEL="models/pd_v1.eim"
BACKUP="models/pd_v1.eim.bak_test"

echo "=== [TEST] check_model when model missing ==="

#模型暫時不存在
if [ -f "$MODEL" ]; then
  mv "$MODEL" "$BACKUP"
  echo "[TEST] renamed $MODEL -> $BACKUP (simulate missing model)"
else
  echo "[TEST] model file not found originally: $MODEL"
fi

#執行腳本並抓 exit code（用 set +e 避免測試腳本自己提前退出）
set +e
bash "$SCRIPT"
code=$?
set -e

echo "[TEST] exit_code=$code"

#還原模型檔名
if [ -f "$BACKUP" ]; then
  mv "$BACKUP" "$MODEL"
  echo "[TEST] restored $BACKUP -> $MODEL"
fi

#判斷結果（期望 exit 2）
if [ "$code" -eq 2 ]; then
  echo "=== [PASS] expected exit code 2 when model missing ==="
  exit 0
else
  echo "=== [FAIL] expected exit code 2, got $code ==="
  exit 1
fi
>>>>>>> 8d344ab (Add minimal log test for missing model case)
