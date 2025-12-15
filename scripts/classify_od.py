#!/usr/bin/env python3
import sys
import cv2
import numpy as np
from pathlib import Path
from edge_impulse_linux.runner import ImpulseRunner

CONF_THRESHOLD = 0.5
RESULT_DIR = Path("results")

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
def run_inference(runner, model_params, image_path: Path):
    # 取得模型標籤輸入尺寸
    width = model_params["image_input_width"]
    height = model_params["image_input_height"]
    input_features = model_params["input_features_count"]

    expected_pixels = width * height
    channels = input_features // expected_pixels

    # 讀取並處理圖片
    img = cv2.imread(str(image_path))
    orig = img.copy()

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

    # 輸出圖片到資料夾
    RESULT_DIR.mkdir(exist_ok=True)
    out_path = RESULT_DIR / f"{image_path.stem}_result.jpg"
    cv2.imwrite(str(out_path), orig)

    print(f"{image_path.name}: 偵測到人數 = {count}")
    return count


def main():
    if len(sys.argv) != 3:
        print("使用方式: python3 classify_od.py <model.eim> <圖片>")
        sys.exit(1)

    model_path = sys.argv[1]
    input_path = Path(sys.argv[2])

    print(f"載入模型: {model_path}")
    print(f"載入圖片: {input_path}")

    # 初始化推論引擎
    runner = ImpulseRunner(model_path)
    try:
        model_info = runner.init()
        params = model_info["model_parameters"]

        if input_path.is_file():
            run_inference(runner, params, input_path)
        elif input_path.is_dir():
            images = sorted(
                p for p in input_path.iterdir()
                if p.suffix.lower() in [".jpg", ".png", ".jpeg"]
            )
            if not images:
                print("資料夾內沒有圖片")
                return
            total = 0
            for img_path in images:
                total += run_inference(runner, params, img_path)
            print(f"\n總偵測人數: {total}")

        else:
            print("輸入不是有效的檔案或資料夾")

    finally:
        runner.stop()


if __name__ == "__main__":
    main()
