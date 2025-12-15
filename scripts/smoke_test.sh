#!/bin/bash

echo "===== Smoke Test: ML Pipeline ====="

# -- Test 1: 資料夾存在 --
echo "[TEST 1] Valid data directory"
./scripts/ml_pipeline.sh data/images
echo "回傳碼: $?"

# -- Test 2: 缺少參數 --
echo "[TEST 2] Missing argument"
./scripts/ml_pipeline.sh
echo "回傳碼: $?"


# -- Test 3: 資料夾不存在 --
echo "[TEST 3] Invalid data directory"
./scripts/ml_pipeline.sh data/nonexistent
echo "回傳碼: $?"

echo "===== Smoke Test Finished ====="
