#!/user/bin/python
#coding: UTF-8

#####
#バックで起動


import os
import time
import commands

#定義--------------------
#@@@はサーバーネーム
WRITE_PATH = "/mnt/ia01/combu/recv/@@@/"


#吐き出し-----------------
while 1:
    #f = open(WRITE_PATH,"w")
    put = commands.getoutput("virsh list --all >" + WRITE_PATH)
    #f.write(str(put))
    #f.close()
    time.sleep(2)
