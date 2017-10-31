# Data Center Manager Class
# by Kozo Komiya, Created at 2017/10/26
#

require 'json'
require 'rubygems'
require 'active_record'

ADAPTER = 'sqlite3'       # SQLite3をデータベースとして使う
DBFILE  = 'db.sqlite3'    # データベースファイルのファイル名

# Access Lib
# VMのホストの数
SC_VMHOST_NUM = 3
# VMのホスト名
SC_VMHOSTNAME = ['IA02', 'IA03', 'IA04']
# 割り当て可能なMEMORYの量
SC_AVAILABLE_VMEM = [16, 16, 16]
# 割り当て可能なCPUの数
SC_AVAILABLE_VCPU = [ 8,  8,  8]

# VMとのコマンドの受け渡しを行うホームディレクトリ
AL_HOME_PATH = './'                       # 開発環境用
#SC_HOME_PATH = "/home/export/combu/"      # 本番環境用
AL_SEND_PATH = AL_HOME_PATH + 'send/'     # 起動リクエストを置く
AL_RECV_PATH = AL_HOME_PATH + 'recv/'     # virsh list --all の出力を置く

$VM_ID = 1 unless defined? $VM_ID

# Access Library class
#   VMの起動コマンドの隠蔽を行う
class AccessLibrary
  def self.Start(host, rid, param)
    # host: VMのホスト名
    # param: [Name, CPU, Memory, vm_name, ip_addr, ssh_key]
    if not SC_VMHOSTNAME.include?(host) then
      STDERR.puts "AccessLibrary::Start invalid host name (#{host})"
      return
    end
    File.open(AL_SEND_PATH + host + "/" + rid.to_s, mode = "w") do |f|
      f.write(["Start", param].join(", "))
    end
  end
  def self.terminate(host, rid, name)
    File.open(AL_SEND_PATH + host + "/" + rid.to_s, mode = "w") do |f|
      f.write(["Terminate", name].join(", "))
    end
  end
  def self.list
  end
end



# DBファイルがなければデータベースを作る。
def createDatabase
  return if File.exist?(DBFILE)
  ActiveRecord::Base.establish_connection(:adapter => ADAPTER, :database => DBFILE)
  ActiveRecord::Migration.create_table :vms do |t|
    t.string :name
    t.integer :vcpu
    t.integer :vmemory
    t.string :ip_addr
    t.string :host
    t.string :status
    t.string :ssh_key
    t.timestamps
  end
  $VM_ID = 1
end

# データベースファイルを消去して作り直し
def refreshDatabase
  File.delete(DBFILE) if File.exist?(DBFILE)
  createDatabase
end


# dcmgr.rbが読み込まれるときに実行される
#
ActiveRecord::Base.establish_connection("adapter"=>ADAPTER, "database"=>DBFILE)
createDatabase
class Vm < ActiveRecord::Base
end


# Data Center Manager Class
#
#
class Dcmgr
  def initilize
  end

  def scheduler(vcpu, vmem)
    #return "Message", "VM HOSTNAME", "Assigned IP Adress"
    random = Random.new
    host = SC_VMHOSTNAME[random.rand(0..2)]
    ip = "192.168.0." + random.rand(20..100).to_s
    return "OK", host, ip  #dummy
  end

  # Dcmgr用メソッド
  def cmdStart(req, res)
    rid = req[:Req_id]
    vcpu = req[:Param][:CPU]
    vmem = req[:Param][:Memory]
    ssh = req[:Param][:SSH_pubkey]
    mes, host, ip_addr = scheduler(vcpu, vmem)
    if mes == "OK" then
      param = ['v' + $VM_ID.to_s, vcpu, vmem, ip_addr, ssh]
      AccessLibrary::Start(host, rid, param)
      vm = Vm.new
      vm.name = req[:Param][:Name]
      vm.vcpu = vcpu
      vm.vmemory = vmem
      vm.ip_addr = ip_addr
      vm.host = host
      vm.ssh_key = ssh
      vm.status = "Initilizing"
      vm.id = $VM_ID
      vm.save
      res[:Message] = mes;
      res[:Param] = {
        :VM_id => vm.id,
        :IP_Address => ip_addr,
        :Status => "Initilizing",
        :Host => host
      }
      $VM_ID += 1
    end

    return res
  end

  def cmdList(req, res)
    @vms = Vm.all
    res[:Message] = "OK"
    res[:Param] = []
    for i in 0..@vms.count-1
      res[:Param][i] = {
        :VM_id      => @vms[i].id,
        :CPU        => @vms[i].vcpu,
        :Memory     => @vms[i].vmemory,
        :SSH_pubkey => @vms[i].ssh_key,
        :Host       => @vms[i].host,
        :IP_address => @vms[i].ip_addr,
        :Status     => @vms[i].status
      }
    end
    return res
  end

  def cmdTerminate(req, res)


    res[:Message] = "OK"
    res[:Param] = {
      :VM_id => req[:VM_id],
      :Status => "terminating"
    }
    return res
  end

  def cmdBarusu(req, res)
    res[:Message] = "OK"
    refreshDatabase
    return res
  end

  def request(command)
    req = JSON.parse(command, {:symbolize_names => true})
    c = req[:Command]
    res = { :Req_id => req[:Req_id], :Command => c }
    case c
    when "start"
      res = cmdStart(req, res)
    when "list"
      res = cmdList(req, res)
    when "power-on"
      res[:Message] = "ERROR: #{c} has not been supported."
    when "power-off"
      res[:Message] = "ERROR: #{c} has not been supported."
    when "terminate"
      res = cmdTerminate(req, res)
    when "barusu"
      res = cmdBarusu(req, res)
    else
      res[:Message] = "ERROR: Unknown Command ...#{c}"
    end
    return JSON.generate(res)
  end
end
