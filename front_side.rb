require 'sinatra'
require 'json'

get '/vm/new' do
  erb :create
end

post '/vm' do
  @name    = params[:Name]
  @cpu     = params[:CPU]
  @memory  = params[:Memory]
  @ssh_key = params[:SSH_pubkey]

  # 受け取ったparamsをjsonに突っ込む
  start = set_start_params

  call_manager(start)
  erb :show
end

get '/vm' do
  list = set_list_params
  call_manager(list)
end

put '/vm/:id' do
  power = set_power_params
  call_manager(power)
end

delete '/vm/:id' do
  terminated = get_terminated_params
  call_manager(terminated)
end

delete '/vm' do
  all_terminated = set_all_terminated_params
  call_manager(all_terminated)
end

private

def call_manager(command)
  # マネジャーを呼び出す
  #dbmgr = AccessLibrary.new
  #dbmgr.request(command)
end

def set_start_params
  request = {}
  request["Req_id"] = 1
  request["Command"] = "start"
  request["Params"] = params
  start = JSON.dump(request)
  return start
end

def set_list_params
  request = {}
  request["Req_id"]  = 1
  request["Command"] = "list"
  list = JSON.dump(request)
  return list
end

def set_power_params
  request = {}
  request["Req_id"] = 1
  request["Command"] = params[:power]
  request["VM_id"] = params[:id]
  power = JSON.dump(request)
  return power
end

def set_terminated_params
  request = {}
  request["Req_id"] = 1;
  request["Command"] = "terminate"
  request["VM_id"] = params[:id]
  terminated = JSON.dump(request)
  return terminated
end

def set_all_terminated_params
  request = {}
  request["Req_id"] = 1
  request["Command"] = "barusu"
  all_terminated = JSON.dump(request)
  return all_terminated
end
