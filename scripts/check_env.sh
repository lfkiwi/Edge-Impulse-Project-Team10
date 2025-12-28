#!/bin/bash
set -e

echo " 正在檢查執行環境..."

#檢查linux環境
echo "作業系統："
uname -a

#檢查必要指令
check_command() {
    local cmd=$1
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo "[ERROR] 未找到該指令： $cmd"
        exit 1
    else
        echo "[CORRECT] 確認找到指令： $cmd"
    fi
}

check_command python3
check_command node
check_command bash

#檢查python版本
echo " Python 版本："
python3 --version

#檢查虛擬環境
#venv/沒找到
if [ ! -d "venv" ]; then
    echo " 未找到 python 虛擬環境 (venv/)"
    exit 1
fi
#venv/bin/python沒找到
if [ ! -f "venv/bin/python" ]; then
    echo " 未找到venv/bin/python"
    exit 1
fi

echo "[CORRECT] 確認python虛擬環境存在"

#檢查模型檔（Web UI 訓練後）
if ! ls models/*.eim >/dev/null 2>&1; then
    echo " models/ 裡沒有 .eim 模型檔案"
    echo " 請從 Edge Impulse 將訓練後的模型檔案放入該資料夾中"
    exit 1
fi

echo "[CORRECT] 確認找到模型檔案"

echo "環境檢查完畢， 可開始執行腳本。"
