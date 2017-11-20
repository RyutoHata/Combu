# Data Center Manager Class
# by Kozo Komiya, Created at 2017/10/26
#

require 'json'
require 'active_record'
require 'socket'

ADAPTER = 'sqlite3'       # SQLite3をデータベースとして使う
DBFILE  = 'db.sqlite3'    # データベースファイルのファイル名

# Access Lib
# VMのホストの数
SC_VMHOST_NUM = 3
# VMのホスト名
SC_VMHOSTNAME = ['IA02', 'IA03', 'IA04']
# 割り当て可能なMEMORYの量
SC_AVAILABLE_VMEM = [16384, 16384, 16384]
# 割り当て可能なCPUの数
SC_AVAILABLE_VCPU = [ 8,  8,  8]
# 割り当て可能なIPアドレスのリスト
SC_AVAILABLE_IP = [
  "192.168.0.20",
  "192.168.0.21",
  "192.168.0.22",
  "192.168.0.23",
  "192.168.0.24",
  "192.168.0.25",
  "192.168.0.26",
  "192.168.0.27",
  "192.168.0.28",
  "192.168.0.29",
  "192.168.0.30",
]
# 割り当てIPのカウンタ  0で初期化
$SC_IP_COUNTER = 0

# リクエストID
$REQ_ID = 1

# VMとのコマンドの受け渡しを行うホームディレクトリ
if Socket.gethostname[0..3] == 'IA01'
  AL_HOME_PATH = "/home/exports/combu/"      # 本番環境用
else
  AL_HOME_PATH = './../'                       # 開発環境用
end

AL_SEND_PATH = AL_HOME_PATH + 'send/'     # 起動リクエストを置く
AL_RECV_PATH = AL_HOME_PATH + 'recv/'     # virsh list --all の出力を置く

$VM_ID = 1 unless defined? $VM_ID

# Access Library class
#   VMの起動コマンドの隠蔽を行う
class AccessLibrary
  def self.Start(host, rid, param)
    # host: VMのホスト名
    # param: [Name, CPU, Memory, vm_name, ip_addr, ssh_key]
    if not SC_VMHOSTNAME.include?(host)
      STDERR.puts "AccessLibrary::Start invalid host name (#{host})"
      return
    end
    File.open(AL_SEND_PATH + host + "/" + rid.to_s, mode = "w") do |f|
      f.write("/home/kvm/start.sh \"" + [param].join("\" \"") + "\"")
      f.puts
    end
  end
  def self.terminate(host, rid, name)
    File.open(AL_SEND_PATH + host + "/" + rid.to_s, mode = "w") do |f|
      f.write("/home/kvm/terminate.sh \"#{name}\"")
      f.puts
    end
  end
  def self.readVMStatus
    stat = {}
    for h in SC_VMHOSTNAME do
      begin
        File.open(AL_RECV_PATH + h, mode = "r") do |f|
          2.times{ f.gets }  #2行読み飛ばし
          while s = f.gets do
            t = s.split(' ')
            stat[t[1]] = t[2]
          end
        end
      rescue Errno::ENOENT
        # ファイルが見つからなければ無視
      end
    end
    return stat
  end
  def self.list
  end
end


# DBファイルがなければデータベースを作る。
def createDatabase
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
end

# データベースファイルを消去して作り直し
def refreshDatabase
  File.delete(DBFILE) if File.exist?(DBFILE)
  createDatabase
end


# dcmgr.rbが読み込まれるときに実行される
#
ActiveRecord::Base.establish_connection("adapter"=>ADAPTER, "database"=>DBFILE)
createDatabase if not File.exist?(DBFILE)
class Vm < ActiveRecord::Base
end
vm = Vm.last
$VM_ID = 1
$VM_ID = vm.id + 1 if vm

# Data Center Manager Class
#
#
class Dcmgr
  def initilize
  end

  def dbUpdate
    vm_stat = AccessLibrary::readVMStatus
    Vm.all.each do |vm|
      if vm.status == "Initilizing"
        if vm_stat["v#{vm.id}"] == "running"
          vm.status = "Running"
          vm.save
        end
      elsif vm.status == "Terminating"
        if not vm_stat["v#{vm.id}"]
          vm.status = "Terminated"
          vm.save
        end
      end
    end
  end

  def scheduler(vcpu, vmem)
    #return "Message", "VM HOSTNAME", "Assigned IP Adress"
    @vms = Vm.where.not(status: "Terminated")

    #割り当てるIPアドレスを決める
    cnt = $SC_IP_COUNTER
    max_cnt = SC_AVAILABLE_IP.count

    ip = ""
    for i in 0..max_cnt do
      if not @vms.exists?(:ip_addr => SC_AVAILABLE_IP[cnt])
        ip = SC_AVAILABLE_IP[cnt]
        break
      else
        cnt = cnt + 1
        if cnt >= max_cnt then cnt = 0 end
      end
    end
    if ip == ""
      return "No Available IP Address", "", "", ""
    end
    cnt = cnt + 1
    if cnt >= max_cnt then cnt = 0 end
    $SC_IP_COUNTER = cnt

    avmem = Marshal.load(Marshal.dump(SC_AVAILABLE_VMEM))
    avcpu = Marshal.load(Marshal.dump(SC_AVAILABLE_VCPU))
    for vm in @vms
      hid = SC_VMHOSTNAME.index(vm.host)
      avcpu[hid] -= vm.vcpu
      avmem[hid] -= vm.vmemory
    end
    cpu_max = 0
    cpu_max_index = -1
    for i in 0 .. SC_VMHOSTNAME.count-1
      if avcpu[i] > vcpu && avmem[i] > vmem
        if cpu_max < avcpu[i]
          cpu_max = avcpu[i]
          cpu_max_index = i
        end
      end
    end
    if cpu_max_index == -1
      return "No Available Host Resource", "", "", ""
    end
    # MACアドレスは乱数で決める。多分重ならない
    rn = Random.new
    mac_addr = sprintf("02:%02x:%02x:%02x:%02x:%02x", rn.rand(0..255),
      rn.rand(0..255), rn.rand(0..255), rn.rand(0..255), rn.rand(0..255))
    return "OK", SC_VMHOSTNAME[cpu_max_index], ip, mac_addr
  end

  # Dcmgr用メソッド
  def cmdStart(req, res)
    rid = req[:Req_id]
    vcpu = req[:Param][:CPU]
    vmem = req[:Param][:Memory]
    ssh = req[:Param][:SSH_pubkey]
    vmhost = req[:Param][:Name]
    mes, host, ip_addr, mac_addr = scheduler(vcpu, vmem)
    if mes == "OK"
      param = ['v' + $VM_ID.to_s, vcpu, vmem, ip_addr, vmhost, ssh]
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
    vm = Vm.find(req[:VM_id])
    if vm.status == "Running" or vm.status == "Initilizing"
      res[:Message] = "OK"
      res[:Param] = {
        :VM_id => req[:VM_id],
        :Status => "Terminating"
      }
      vm.status = "Terminating"
      vm.save
      AccessLibrary::terminate(vm.host, req[:Req_id], "v" + req[:VM_id].to_s)
    else
      res[:Message] = "The VM is not running"
    end
    return res
  end

  def cmdBarusu(req, res)
    res[:Message] = "OK"
    refreshDatabase
    return res
  end

  def request(command)
    dbUpdate

    req = JSON.parse(command, {:symbolize_names => true})

    #Req_idはdcmgrが振り直すことにする。
    req[:Req_id] = $REQ_ID
    $REQ_ID += 1

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
