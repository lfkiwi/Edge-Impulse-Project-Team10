# 人類辨識

## 說明
偵測圖片中的物體是否為人類，是的話會分別標示出來

## 事先安裝
Python 以及讓圖片處理（OpenCV）能運作的底層檔案。
```bash
sudo apt-get update && sudo apt-get install -y python3 python3-pip libgl1 libglib2.0-0
```
Python 執行套件
```bash
pip3 install opencv-python numpy edge_impulse_linux
```
## 使用
1. **在專案根目錄建立 models 資料夾**
   ```bash
   mkdir -p models
   ```
2. **下載圖片模組訓練.eim檔**
[Edge Impulse](https://studio.edgeimpulse.com/studio/842373 "游標顯示")

點選clone project --> 複製完之後點選左邊Deployment --> 搜尋欄尋找linux(x86) --> 點選build --> 獲得.eim檔

將你從Edge Impulse下載下來的模型檔案（.eim 檔）。改名成 pd_v1.eim

請打開終端機，確認已經進入你的專案資料夾，並且啟動了虛擬環境 (source venv/bin/activate)。

3. **丟圖片**
把你要測試的所有照片（.jpg 檔），全部放進 data/test 這個資料夾。

建議：每次要跑新的一批照片前，先把 data/test 裡面的舊照片刪掉，才不會搞混。

4. **執行**
在終端機輸入這行指令
```bash
./scripts/ml_pipeline.sh
```
5. **收結果** 
執行完畢後，會看到終端機顯示： [INFO] 批次推論完成，結果都在 results/2025xxxx_xxxxxx
打開results資料夾，會看到一個「最新時間」的資料夾
點進去，那就是這一次執行的成果。

## 系統需求
-Linux OS (推薦使用Ubuntu)
-Python 3.x
edge_impulse_linux >= 1.0.7
opencv-python >= 4.5.1.48
numpy >= 1.21.0
## 預覽
results資料夾
點進去，會看到裡面的照片都已經被AI畫上紅色的框框和分數。
![](https://github.com/lfkiwi/Edge-Impulse-Project-Team10/blob/758ee944b7dec392ef981a56bfcddceaa8279c11/results/20251218_014659/test3_result.jpg)
