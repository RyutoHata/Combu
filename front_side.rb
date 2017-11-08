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
  puts start

  # マネジャーを呼び出す
  #dbmgr = AccessLibrary.new
  #dbmgr.request(start)
  erb :show
end

get '/vm' do
  list = set_list_params
  puts list

end

put '/vm/:id' do
  "vm #{params[:id]} power_control"
end

delete '/vm/:id' do
  "delete vm #{params[:id]}"
end

delete '/vm' do
  "all vm is terminated"
end

private
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
