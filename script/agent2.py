#!/user/bin/python
#coding: UTF-8

import os

#定義--------------------
#鯖名のフォルダ
SABA_PATH = "IA02/"
WRITE_PATH = "/var/ia01/recv/"
READ_PATH = "/mnt/ia01/send/"

while 1:
    #フォルダ内読み込み
    file_list = os.listdir(READ_PATH)
    #ファイル
    f = open(READ_PATH + file_list[0],"r")
    #読み込み
    data = f.read()
    f.close()
    #実行
    c = os.system("./start.sh " + data)
    os.remove(READ_PATH + file_list[0])    #削除
