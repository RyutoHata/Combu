#!/user/bin/python
#coding: UTF-8

#####
#バックで起動


import os
import time
import subprocess

#定義--------------------
WRITE_PATH = "/var/ia01/recv/@@@/"


#吐き出し-----------------
while 1:
    f = open(WRITE_PATH,"w")
    put = subprocess.check_output("virsh list --all")
    f.write(str(put))
    f.close()
    time.sleep(300)
