#!/user/bin/python
#coding: UTF-8

import os
import time

#定義--------------------
#鯖名のフォルダ
#@@@sabaname
SABA_PATH = "@@@/"
READ_PATH = "/mnt/ia01/combu/send/"

while 1:
    #フォルダ内読み込み
    file_list = os.listdir(READ_PATH + SABA_PATH)
    if len(file_list) != 0:
        #ファイル
        f = open(READ_PATH + SABA_PATH + file_list[0],"r")
        #読み込み
        data = f.read()
        f.close()
        #実行
        c = os.system(data)
        os.remove(READ_PATH + SABA_PATH + file_list[0])    #削除
    else:
        time.sleep(2)
        
