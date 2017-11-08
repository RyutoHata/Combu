- 起動要求        VMの起動要求を行う。
  GET http://{hostname:4567}/vm/new
  POST http://{hostname:4567}/vm
  {
    "vm" : {
      "Name"       : "vm name",
      "CPU"        : "the number of cpu",
      "Memory"     : "memory size",
      "SSH_pubkey" : "ssh public key"
    }
  }

- VMリスト         VMの全リストを取得する
  GET http://{hostname:4567}/vm

- 電源OFF要求     指定したVMの電源OFFを行う。（内部は当面実装しない。）
  POST http://{hostname:4567}/vm/:id
  {
    "vm" : {
      "Command" : "off"
    }
  }


- 電源ON要求      電源OFF中のVMの電源ONを行う。（内部は当面実装しない。）
  POST http://{hostname:4567}/vm/:id
  {
    "vm" : {
      "Command" : "on"
    }
  }


- 削除要求        VMの削除を行う。
  DELETE http://{hostname:4567}/vm/:id

- 全部削除        データーベースとVMを全部削除してまっさらにする。
  DELETE http://{hostname:4567}/vm
