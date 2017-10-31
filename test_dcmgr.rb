# test / sample code for Dcmgr Class
# by Kozo Komiya, Created at 2017/10/31
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
start_cmd2 =<<EOS
{
  "Req_id": 2,
  "Command": "start",
  "Param": {
    "Name": "hoge2",
    "CPU": 4,
    "Memory": 10,
    "SSH_pubkey": "ssh-key2"
  }
}
EOS

# listコマンド
list_cmd =<<EOS
{
  "Req_id": 3,
  "Command": "list"
}
EOS

# 削除コマンド
terminate_cmd =<<EOS
{
  "Req_id": 4,
  "Command": "terminate",
  "VM_id": 1
}
EOS

# 削除コマンド
terminate_cmd2 =<<EOS
{
  "Req_id": 5,
  "Command": "terminate",
  "VM_id": 2
}
EOS

# 全削除コマンド
barusu_cmd =<<EOS
{
  "Req_id": 7,
  "Command": "barusu"
}
EOS

# testのMain
dcmgr = Dcmgr.new
str = dcmgr.request(start_cmd)
puts str
str = dcmgr.request(start_cmd2)
puts str
str = dcmgr.request(list_cmd)
puts str
str = dcmgr.request(terminate_cmd)
puts str
str = dcmgr.request(terminate_cmd2)
puts str
str = dcmgr.request(list_cmd)
puts str
#str = dcmgr.request(barusu_cmd)
#puts str
