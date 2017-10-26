# Data Center Manager Class
# by Kozo Komiya, Created at 2017/10/26
#

require 'json'

def cmdStart(req, res)
  res["Message"] = "OK"
  res["Param"] = {
    "VM_id" => 1,
    "IP_Address" => "192.168.0.20",
    "Status" => "Initilizing"
  }
  return res
end

def cmdList(req, res)
  res["Message"] = "OK"
  res["Param"] = [ {
    "VM_id" => 1,
    "CPU" => 2,
    "Memory" => 4,
    "SSH_pubkey" => "ssh-key 1",
    "IP_Address" => "192.168.0.20",
    "Status" => "Running"
  },
  {
    "VM_id" => 1,
    "CPU" => 2,
    "Memory" => 4,
    "SSH_pubkey" => "ssh-key 1",
    "IP_Address" => "192.168.0.22",
    "Status" => "Initilizing"
  }]
  return res
end

def cmdTerminate(req, res)
  res["Message"] = "OK"
  res["Param"] = {
    "VM_id" => 1,
    "Status": "terminating"
  }
  return res
end

def cmdBarusu(req, res)
  res["Message"] = "OK"
  return res
end

# dummy version
class Dcmgr
  def request(command)
    req = JSON.parse(command)
    cmd = req["Command"]
    res = { "Req_id" => req["Req_id"], "Command" => cmd }
    case cmd
    when "start"
      res = cmdStart(req, res)
    when "list"
      res = cmdList(req, res)
    when "power-on"
      res["Message"] = "ERROR: #{cmd} has not been supported."
    when "power-off"
      res["Message"] = "ERROR: #{cmd} has not been supported."
    when "terminate"
      res = cmdTerminate(req, res)
    when "barusu"
      res = cmdBarusu(req, res)
    else
      res["Message"] = "ERROR: Unknown Command ...#{cmd}"
    end
    return JSON.generate(res)
  end
end
