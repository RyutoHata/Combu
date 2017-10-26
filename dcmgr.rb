# Data Center Manager Class
# by Kozo Komiya, Created at 2017/10/26
#

require 'json'
require 'rubygems'
require 'active_record'

ADAPTER = 'sqlite3'       # SQLite3をデータベースとして使う
DBFILE  = 'db.sqlite3'  # データベースファイルのファイル名

ActiveRecord::Base.establish_connection("adapter"=>ADAPTER, "database"=>DBFILE)

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
end

# データベースファイルを消去して作り直し
def refreshDatabase
  File.delete(DBFILE) if File.exist?(DBFILE)
  createDatabase
end

createDatabase
class Vm < ActiveRecord::Base
end

def cmdStart(req, res)
  vm = Vm.new
  vm.name = req[:Param][:Name]
  vm.vcpu = req[:Param][:CPU]
  vm.vmemory = req[:Param][:Memory]
  vm.ip_addr = "192.168.0.20"
  vm.host = "IA02"
  vm.ssh_key = req[:Param][:SSH_pubkey]
  vm.status = "Initilizing"
  vm.save

  res[:Message] = "OK"
  res[:Param] = {
    :VM_id => vm.id,
    :IP_Address => "192.168.0.20",
    :Status => "Initilizing",
    :Host => "IA02"
  }
  return res
end

def cmdList(req, res)
  vms = Vm.all
  res[:Message] = "OK"
  res[:Param] = []
  for i in 0..vms.count-1
    res[:Param][i] = {
      :VM_id      => vms[i].id,
      :CPU        => vms[i].vcpu,
      :Memory     => vms[i].vmemory,
      :SSH_pubkey => vms[i].ssh_key,
      :Host       => vms[i].host,
      :IP_address => vms[i].ip_addr,
      :Status     => vms[i].status
    }
  end
  return res
end

def cmdTerminate(req, res)
  res[:Message] = "OK"
  res[:Param] = {
    :VM_id => 1,
    :Status => "terminating"
  }
  return res
end

def cmdBarusu(req, res)
  res[:Message] = "OK"
  refreshDatabase
  return res
end

class Dcmgr
  def initilize
  end
  def request(command)
    req = JSON.parse(command, {:symbolize_names => true})

    cmd = req[:Command]
    res = { :Req_id => req[:Req_id], :Command => cmd }
    case cmd
    when "start"
      res = cmdStart(req, res)
    when "list"
      res = cmdList(req, res)
    when "power-on"
      res[:Message] = "ERROR: #{cmd} has not been supported."
    when "power-off"
      res[:Message] = "ERROR: #{cmd} has not been supported."
    when "terminate"
      res = cmdTerminate(req, res)
    when "barusu"
      res = cmdBarusu(req, res)
    else
      res[:Message] = "ERROR: Unknown Command ...#{cmd}"
    end
    return JSON.generate(res)
  end
end
