#!/usr/bin/env python3
import sys
import cv2
import numpy as np
from edge_impulse_linux.runner import ImpulseRunner

def main():
    if len(sys.argv) != 3:
        print("使用方式: python3 classify_od.py <model.eim> <圖片>")
        sys.exit(1)

    model_path = sys.argv[1]
    image_path = sys.argv[2]

    print(f"載入模型: {model_path}")
    print(f"載入圖片: {image_path}")

    # 初始化推論引擎
    runner = ImpulseRunner(model_path)
    try:
        model_info = runner.init()
        print(f"模型標籤: {model_info['model_parameters']['labels']}")

        # 取得模型標籤輸入尺寸
        width = model_info['model_parameters']['image_input_width']
        height = model_info['model_parameters']['image_input_height']

        # 讀取並處理圖片
        img = cv2.imread(image_path) #讀取圖片
        img_gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY) #轉成灰階
	# 調整大小並轉float32，展平成一維(符合模型輸入)
        img_processed = cv2.resize(img_gray, (width, height)).astype('float32').flatten()
        print(f"處理後圖片 shape: {img_processed.shape}")

        # 執行推論
        result = runner.classify(img_processed)

        # 顯示結果
        if 'bounding_boxes' in result['result']:
            for i, box in enumerate(result['result']['bounding_boxes']):
                print(f"物件 {i+1}: {box['label']} ({box['value']:.2f})")
    finally:
        runner.stop()

if __name__ == "__main__":
    main()
