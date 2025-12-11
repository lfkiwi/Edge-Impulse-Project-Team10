import datetime
#導入py模組處理時間
def _format(level, script, step, message):
    #把輸入的資訊格式化成日誌字串。
    # timestamp 使用 ISO8601
    ts = datetime.datetime.now().astimezone().isoformat(timespec='seconds')
 　 # 取得時間，以當前時間 now() 建立datetime物件
    # 加上時區，用 astimezone() 把時間轉為「有時區資訊的本地時間」
    # 格式化，用 isoformat(timespec='seconds')轉成 ISO 8601 字串
    return f'{ts} [{level}] [script={script}] [step={step}] message="{message}"'
    #- 組合字串： 用 f-string 把時間戳、等級、腳本、步驟與訊息組成一致的日誌格式
def info(script, step, message):
  #封裝「資訊」等級函式
    print(_format("INFO", script, step, message))
  #呼叫 _format 產生字串，level 固定為 INFO，再用 print 輸出

def warn(script, step, message):
  #封裝「警告」等級函式
    print(_format("WARN", script, step, message))
  #封裝「錯誤」等級函式

def error(script, step, message):
 # 封裝一個輸出「警告」等級的便捷函式。
    print(_format("ERROR", script, step, message))
