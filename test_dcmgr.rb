# test / sample code for Dcmgr Class
# by Kozo Komiya, Created at 2017/10/26
#

require './dcmgr.rb'

# JSON形式の文字列でstartコマンドを作る。
start_cmd =<<EOS
{
  "Req_id": 1,
  "Command": "start",
  "Param": {
    "Name": "hoge",
    "CPU": 1,
    "Memory": 8,
    "SSH_pubkey": "ssh-key"
  }
}
EOS

# listコマンドを作る。
list_cmd =<<EOS
{
  "Req_id": 2,
  "Command": "list"
}
EOS

# 削除コマンド
poweroff_cmd =<<EOS
{
  "Req_id": 3,
  "Command": "power-off",
  "VM_id": 1
}
EOS

poweron_cmd =<<EOS
{
  "Req_id": 4,
  "Command": "power-on",
  "VM_id": 1
}
EOS

# 削除コマンド
terminate_cmd =<<EOS
{
  "Req_id": 5,
  "Command": "terminate",
  "VM_id": 1
}
EOS

# 全削除コマンド
barusu_cmd =<<EOS
{
  "Req_id": 6,
  "Command": "barusu"
}
EOS

# testのMain
dcmgr = Dcmgr.new
str = dcmgr.request(start_cmd)
puts str
str = dcmgr.request(list_cmd)
puts str
str = dcmgr.request(poweron_cmd)
puts str
str = dcmgr.request(poweroff_cmd)
puts str
str = dcmgr.request(terminate_cmd)
puts str
str = dcmgr.request(barusu_cmd)
puts str
