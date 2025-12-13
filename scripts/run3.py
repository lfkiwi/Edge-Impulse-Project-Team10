#!/usr/bin/env python3
import sys
import cv2
import numpy as np
from edge_impulse_linux.runner import ImpulseRunner
import os

#log 共用函式
from logger import info, warn, error


def main():

    #記錄流程啟動
    info("run3.py", "start", "開始執行推論流程")

    if len(sys.argv) != 4:

       #log錯誤參數
       error("run3.py", "args", "參數錯誤：需要 <model.eim> <image> <output>")
   
       print("使用方式: python3 classify_od.py <model.eim路徑> <圖片路徑> <輸出檔案路徑>")
       sys.exit(1)
    
    model_path = sys.argv[1]
    image_path = sys.argv[2]
    output_path = sys.argv[3]  # 指定輸出檔案

    #把參數記錄進 log
    info("run3.py", "args", f"模型={model_path}, 圖片={image_path}, 輸出={output_path}")

    print(f"載入模型: {model_path}")
    print(f"載入圖片: {image_path}")
    print(f"輸出檔案: {output_path}")
    
    runner = ImpulseRunner(model_path)

    #記錄開始初始化模型
    info("run3.py", "load_model", "建立 ImpulseRunner，準備初始化模型" ) 
    try:

        model_info = runner.init()
        #記錄模型初始化成功
        info("run3.py", "load_model", "模型初始化成功") 

        print(f"模型資訊:")
        print(f"  - 輸入寬度: {model_info['model_parameters']['image_input_width']}")
        print(f"  - 輸入高度: {model_info['model_parameters']['image_input_height']}")
        print(f"  - 標籤: {model_info['model_parameters']['labels']}")
        
        target_width = model_info['model_parameters']['image_input_width']
        target_height = model_info['model_parameters']['image_input_height']
        
        #圖片讀取前紀錄
        info("run3.py", "read_image", f"讀取圖片：{image_path}")
 
        img = cv2.imread(image_path)
        if img is None:
        
           #取失敗寫 ERROR log 
            error("run3.py", "read_image", f"錯誤：無法讀取圖片 {image_path}")
   
            print(f"錯誤: 無法讀取圖片 {image_path}")
            sys.exit(1)
        
        #開始前處理
        info("run3.py", "preprocess", "開始圖片前處理（轉灰階、resize、flatten）")
    
        img_rgb = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
        img_gray = cv2.cvtColor(img_rgb, cv2.COLOR_RGB2GRAY)
        img_resized = cv2.resize(img_gray, (target_width, target_height))
        img_float = img_resized.astype('float32')
        img_processed = img_float.flatten()
        
        result = runner.classify(img_processed)
        
        if 'bounding_boxes' in result['result']:
                boxes = result['result']['bounding_boxes']
                #偵測結果寫 info / warn            
                info("run3.py", "draw_boxes", f"偵測到 {len(boxes)} 個物體，開始畫框")
        else:
                warn("run3.py", "draw_boxes", "result['bounding_boxes'] 為空，沒有框可以畫")
 
        for box in boxes:
                x, y, w, h = box['x'], box['y'], box['width'], box['height']
                cv2.rectangle(img, (x, y), (x + w, y + h), (0, 255, 0), 2)
                cv2.putText(img, box['label'], (x, y - 10),
                            cv2.FONT_HERSHEY_SIMPLEX, 0.5, (0, 255, 0), 2)
        
        os.makedirs(os.path.dirname(output_path), exist_ok=True)
        cv2.imwrite(output_path, img)
        
        #輸出成功 log
        info("run3.py", "output", f"已將標註後圖片儲存為 {output_path}")

        print(f"已將標註後圖片儲存為 {output_path}")
        
    finally:
        #結束
        info("run3.py", "finish", "推論流程結束，釋放 runner")
        runner.stop()
 
if __name__ == "__main__":
    main()

