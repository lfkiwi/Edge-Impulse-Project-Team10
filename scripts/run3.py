#!/usr/bin/env python3
import sys
import cv2
import numpy as np
from edge_impulse_linux.runner import ImpulseRunner
import os

def main():
    if len(sys.argv) != 4:
        print("使用方式: python3 classify_od.py <model.eim路徑> <圖片路徑> <輸出檔案路徑>")
        sys.exit(1)
    
    model_path = sys.argv[1]
    image_path = sys.argv[2]
    output_path = sys.argv[3]  # 指定輸出檔案
    
    print(f"載入模型: {model_path}")
    print(f"載入圖片: {image_path}")
    print(f"輸出檔案: {output_path}")
    
    runner = ImpulseRunner(model_path)
    
    try:
        model_info = runner.init()
        print(f"模型資訊:")
        print(f"  - 輸入寬度: {model_info['model_parameters']['image_input_width']}")
        print(f"  - 輸入高度: {model_info['model_parameters']['image_input_height']}")
        print(f"  - 標籤: {model_info['model_parameters']['labels']}")
        
        target_width = model_info['model_parameters']['image_input_width']
        target_height = model_info['model_parameters']['image_input_height']
        
        img = cv2.imread(image_path)
        if img is None:
            print(f"錯誤: 無法讀取圖片 {image_path}")
            sys.exit(1)
        
        img_rgb = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
        img_gray = cv2.cvtColor(img_rgb, cv2.COLOR_RGB2GRAY)
        img_resized = cv2.resize(img_gray, (target_width, target_height))
        img_float = img_resized.astype('float32')
        img_processed = img_float.flatten()
        
        result = runner.classify(img_processed)
        
        if 'bounding_boxes' in result['result']:
            boxes = result['result']['bounding_boxes']
            for box in boxes:
                x, y, w, h = box['x'], box['y'], box['width'], box['height']
                cv2.rectangle(img, (x, y), (x + w, y + h), (0, 255, 0), 2)
                cv2.putText(img, box['label'], (x, y - 10),
                            cv2.FONT_HERSHEY_SIMPLEX, 0.5, (0, 255, 0), 2)
        
        os.makedirs(os.path.dirname(output_path), exist_ok=True)
        cv2.imwrite(output_path, img)
        print(f"已將標註後圖片儲存為 {output_path}")
        
    finally:
        runner.stop()

if __name__ == "__main__":
    main()

