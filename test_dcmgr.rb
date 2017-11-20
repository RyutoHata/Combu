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
    "Memory": 512,
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
    "CPU": 2,
    "Memory": 1024,
    "SSH_pubkey": "ssh-key2"
  }
}
EOS

poweroff_cmd =<<EOS
{
  "Req_id": 7,
  "Command": "power-off",
  "VM_id": 1
}
EOS

poweron_cmd =<<EOS
{
  "Req_id": 7,
  "Command": "power-on",
  "VM_id": 1
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
  "Req_id": 24,
  "Command": "terminate",
  "VM_id": 1
}
EOS

# 削除コマンド
terminate_cmd2 =<<EOS
{
  "Req_id": 25,
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

def dummy_recv1
  File.open(AL_RECV_PATH + "IA02", mode = "w") do |f|
    f.puts "Id    Name                           State"
    f.puts "----------------------------------------------------"
    f.puts "1     v1                             running"
  end
end

def dummy_recv2
  File.open(AL_RECV_PATH + "IA02", mode = "w") do |f|
    f.puts "Id    Name                           State"
    f.puts "----------------------------------------------------"
    f.puts "1     v1                             running"
    f.puts "2     v2                             running"
  end
end

def dummy_recv3
  File.open(AL_RECV_PATH + "IA02", mode = "w") do |f|
    f.puts "Id    Name                           State"
    f.puts "----------------------------------------------------"
    f.puts "2     v2                             running"
  end
end

def dummy_recv5
  File.open(AL_RECV_PATH + "IA02", mode = "w") do |f|
    f.puts "Id    Name                           State"
    f.puts "----------------------------------------------------"
    f.puts "1     v1                             shut off"
    f.puts "2     v2                             running"
  end
end

def dummy_recv4
  File.open(AL_RECV_PATH + "IA02", mode = "w") do |f|
    f.puts "Id    Name                           State"
    f.puts "----------------------------------------------------"
  end
end

# testのMain
dcmgr = Dcmgr.new
str = dcmgr.request(start_cmd)
print "test_dcmgr.rb : "
puts str
STDIN.gets

dummy_recv1
str = dcmgr.request(start_cmd2)
print "test_dcmgr.rb : "
puts str
STDIN.gets

dummy_recv2
str = dcmgr.request(list_cmd)
print "test_dcmgr.rb : "
puts str
STDIN.gets

str = dcmgr.request(poweroff_cmd)
print "test_dcmgr.rb : "
puts str
STDIN.gets

dummy_recv5
str = dcmgr.request(list_cmd)
print "test_dcmgr.rb : "
puts str
STDIN.gets

str = dcmgr.request(poweron_cmd)
print "test_dcmgr.rb : "
puts str
STDIN.gets

dummy_recv2
str = dcmgr.request(list_cmd)
print "test_dcmgr.rb : "
puts str
STDIN.gets

dummy_recv3
str = dcmgr.request(terminate_cmd2)
print "test_dcmgr.rb : "
puts str
STDIN.gets

str = dcmgr.request(terminate_cmd)
print "test_dcmgr.rb : "
puts str
STDIN.gets

dummy_recv4
str = dcmgr.request(list_cmd)
print "test_dcmgr.rb : "
puts str
STDIN.gets






#str = dcmgr.request(barusu_cmd)
#puts str
