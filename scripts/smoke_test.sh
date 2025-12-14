#!/usr/bin/env bash

PIPELINE_SCRIPT="scripts/ml_pipeline.sh"
TEST_DATA_DIR="data/images"
FAIL_COUNT=0

echo "===== Smoke Test: ML Pipeline ====="

# -- Test 1: 資料夾存在 --
echo "[TEST 1] Valid data directory"
bash "$PIPELINE_SCRIPT" "$TEST_DATA_DIR"
RET=$?

if [ $RET -eq 0 ]; then
  echo "[PASS] Test 1 succeeded"
else
  echo "[FAIL] Test 1 failed (code=$RET)"
  FAIL_COUNT=$((FAIL_COUNT + 1))
fi

echo

# -- Test 2: 缺少參數 --
echo "[TEST 2] Missing argument"
bash "$PIPELINE_SCRIPT"
RET=$?

if [ $RET -ne 0 ]; then
  echo "[PASS] Test 2 correctly failed (code=$RET)"
else
  echo "[FAIL] Test 2 should have failed"
  FAIL_COUNT=$((FAIL_COUNT + 1))
fi

echo

# -- Test 3: 資料夾不存在 --
echo "[TEST 3] Invalid data directory"
bash "$PIPELINE_SCRIPT" "not_exist_dir"
RET=$?

if [ $RET -ne 0 ]; then
  echo "[PASS] Test 3 correctly failed (code=$RET)"
else
  echo "[FAIL] Test 3 should have failed"
  FAIL_COUNT=$((FAIL_COUNT + 1))
fi

echo
echo "===== Smoke Test Finished ====="

if [ $FAIL_COUNT -eq 0 ]; then
  echo "[RESULT] All smoke tests passed！ "
  exit 0
else
  echo "[RESULT] $FAIL_COUNT test(s) failed. "
  exit 1
fi
