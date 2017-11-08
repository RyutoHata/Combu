require 'sinatra'
require 'json'

get '/create_vm' do
  erb :create
end

post '/create_vm' do
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

private
def set_start_params
  hash = {}
  hash["Req_id"] = 1
  hash["Command"] = "start"
  hash["Params"] = params
  start = JSON.dump(hash)
  return start
end
