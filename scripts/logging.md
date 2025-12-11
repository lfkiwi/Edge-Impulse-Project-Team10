## Log 定義格式（Format）
{timestamp} [{LEVEL}] [script={script_name}] [step={step_name}] message="{content}"
#ex:2025-12-11T20:30:12+08:00 [INFO] [script=run3.py] [step=load_model] message="模型載入成功"

#timestamp時間戳：ISO8601，如 `2025-12-11T20:30:12+08:00`
#LEVEL：`INFO` 一般流程/ `WARN`非致命問題/ `ERROR`致命問題
#sript：目前執行的腳本名稱（例如 run3.py）
#step：流程階段（例如 load_model / preprocess / classify）
#message：實際訊息內容

