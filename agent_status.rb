require 'socket'
HOSTNAME = Socket.gethostname[0..3]

#AL_HOME_PATH = "/home/exports/combu/"
AL_HOME_PATH = "/mnt/ia01/combu/"
#AL_HOME_PATH = './../'

AL_SEND_PATH = AL_HOME_PATH + 'send/'
AL_RECV_PATH = AL_HOME_PATH + 'recv/'


while true
  sleep(2)
  system "virsh list --all > #{AL_RECV_PATH}#{HOSTNAME}"
end
