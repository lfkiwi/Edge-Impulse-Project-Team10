#!/usr/bin/env python3
import sys
import cv2
import numpy as np
from pathlib import Path
from edge_impulse_linux.runner import ImpulseRunner
import os

#log 共用函式
from logger import info, warn, error

CONF_THRESHOLD = 0.5

# 等比例縮放 + padding 函式
def letterbox(image, target_w, target_h):
    h, w = image.shape[:2]
    scale = min(target_w / w, target_h / h)

    new_w = int(w * scale)
    new_h = int(h * scale)

    resized = cv2.resize(image, (new_w, new_h))

    # 如果是灰階，補回 channel 維度
    if resized.ndim == 2:
        resized = resized[:, :, None]

    pad_x = (target_w - new_w) // 2
    pad_y = (target_h - new_h) // 2

    padded = np.zeros((target_h, target_w, resized.shape[2]), dtype=resized.dtype)
    padded[pad_y:pad_y+new_h, pad_x:pad_x+new_w] = resized

    return padded, scale, pad_x, pad_y

# 批次推論(直接傳一整個資料夾)
def run_inference(runner, model_params, image_path: Path, output_path: Path):
    #確認資料夾存在
    output_path.parent.mkdir(parents=True, exist_ok=True)

    # 取得模型標籤輸入尺寸
    width = model_params["image_input_width"]
    height = model_params["image_input_height"]
    input_features = model_params["input_features_count"]

    expected_pixels = width * height
    channels = input_features // expected_pixels

    #圖片讀取前紀錄
    info("classify_od.py", "read_image", f"讀取圖片：{image_path}")

    # 讀取並處理圖片
    img = cv2.imread(str(image_path))
    if img is None:
        error("classify_od.py", "read_image", f"無法讀取圖片: {image_path}")
        raise RuntimeError(f"讀取圖片失敗，路徑: {image_path}")
    orig = img.copy()

    #開始前處理
    info("classify_od.py", "preprocess", "開始圖片前處理（轉灰階、resize、flatten）")

    if channels == 1:
        img = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
        img = img[:, :, None] # (H, W, channel維度)
    else:
        img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)

    # 等比例 resize + padding
    img_padded, scale, pad_x, pad_y = letterbox(img, width, height)
    # flatten
    img_input = img_padded.astype(np.float32).flatten()
    # 執行推論
    result = runner.classify(img_input)

    # 顯示結果
    count = 0
    if "bounding_boxes" in result["result"]:
        for box in result["result"]["bounding_boxes"]:
            if box["value"] < CONF_THRESHOLD:
                continue

            count += 1
            x = int((box["x"] - pad_x) / scale)
            y = int((box["y"] - pad_y) / scale)
            w = int(box["width"] / scale)
            h = int(box["height"] / scale)

            # 依圖片尺寸調整線寬
            line_thickness = max(int(max(orig.shape[0], orig.shape[1]) / 500), 1)

            cv2.rectangle(orig, (x, y), (x + w, y + h), (0, 0, 255), line_thickness)
            label = f"{box['label']} {box['value']:.2f}"

            # 假設圖片尺寸 h x w
            font_scale = max(orig.shape[0], orig.shape[1]) / 1000  # 可調整比例因子
            thickness = max(int(font_scale * 2), 1)

            cv2.putText(
                orig, label, (x, max(y - int(10 * font_scale), 20)),
                cv2.FONT_HERSHEY_SIMPLEX, font_scale,
                (0, 0, 255), thickness
            )
    else:
        warn("classify_od.py", "draw_boxes", "result['bounding_boxes'] 為空，沒有框可以畫")

    # 輸出圖片
    cv2.imwrite(str(output_path), orig)
    print(f"圖片 {image_path.name} 已儲存至 {output_path}")
    print(f"{image_path.name}: 偵測到人數 = {count}")
    return count


def main():
    #記錄流程啟動
    info("classify_od.py", "start", "開始執行推論流程")

    if len(sys.argv) != 4:
        #log錯誤參數
        error("classify_od.py", "args", "參數錯誤：需要 <model.eim> <image> <output>")

        print("使用方式: python3 classify_od.py <model.eim> <輸入圖片> <輸出圖片>")
        sys.exit(1)

    model_path = sys.argv[1]
    input_image = Path(sys.argv[2])
    output_image = Path(sys.argv[3])

    #把參數記錄進 log
    info("classify_od.py", "args", f"模型={model_path}, 圖片={input_image}, 輸出={output_image}")

    print(f"載入模型: {model_path}")
    print(f"載入圖片: {input_image}")

    #記錄開始初始化模型
    info("classify_od.py", "load_model", "建立 ImpulseRunner，準備初始化模型" ) 

    # 初始化推論引擎
    runner = ImpulseRunner(model_path)
    try:
        model_info = runner.init()
        #記錄模型初始化成功
        info("classify_od.py", "load_model", "模型初始化成功")
        params = model_info["model_parameters"]

        count = run_inference(
            runner,
            params,
            input_image,
            output_image
        )

        print(f"偵測圖片數量={count}")
        print(f"DETECTED={count}")

    finally:
        runner.stop()


if __name__ == "__main__":
    main()
