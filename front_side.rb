require 'sinatra'
require 'json'
require './dcmgr'

get '/' do
  erb :home
end

get '/vm/new' do
  erb :create
end

post '/vm' do
  start = set_start_params
  response = call_manager(start)
  @new_vm = conv_hash(response)
  @new_data = @new_vm['Param']
  erb :show
end

get '/vm' do
  list = set_list_params
  response = call_manager(list)
  @list = conv_hash(response)
  @data = @list['Param']
  erb :index
end

put '/vm/:id' do
  power = set_power_params
  response = call_manager(power)
  return response
end

delete '/vm/:id' do
  terminated = set_terminated_params
  response = call_manager(terminated)
  @deleted_vm = conv_hash(response)
  erb :delete
end

delete '/vm' do
  all_terminated = set_all_terminated_params
  response = call_manager(all_terminated)
  return response
end

private

def call_manager(command)
  # マネジャーを呼び出す
  dbmgr = Dcmgr.new
  response = dbmgr.request(command)
  return response
end

def set_start_params
  params[:CPU] = params[:CPU].to_i
  params[:Memory] = params[:Memory].to_i
  request = {}
  request["Req_id"] = 1
  request["Command"] = "start"
  request["Param"] = params
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

def conv_hash(json)
  hash = JSON.parse(json)
  hash
end
