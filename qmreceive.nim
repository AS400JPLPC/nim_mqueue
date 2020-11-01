import posix, os
import strformat
import termkey
import terminal
from times import cpuTime
let QUEUE_NAME  = "/QMname"

var mqd_t : Mqd               # key mqreceive

var mqd_a : MqAttr            # attribut mqreceive


# mqd_a.mq_msgsize = MSGLEN from send  = 1024 
var tab: array[0..1024, char] # variable mqreceive buffer spécifique

var mq_priority: int          # variable mqreceive priority

var rcv : int                 # code retour mq_receive    nbr byte

var ctrl : int                # code retour mq_getattr    -1 error

var rlen* : int               # variable mqreceive len

var rcv_val: string           # zone de travail

var OK:bool = true            # working receive


# détricotte buffer mqueue 
func mqBuffer(a1: array[0..1024, char]) : string =
  var i = 0
  while a1[i] != '\x00':
      result.add( $a1[i] )
      inc(i)




proc main() =
  initScreen(24,132,"Test KEYBOARD")
  # initialize the queue attributes
  # create the message

  mqd_t =  mq_open(QUEUE_NAME , O_RDONLY, 0666, mqd_a.addr) 
  gotoXY(1,1)
  writeStyled(fmt"mqd_t--> {mqd_t}")

  if (mqd_t == -1 ) : quit(QuitFailure)
  
  ctrl = mq_getattr(mqd_t, mqd_a.addr)
  gotoXY(2,1)
  writeStyled(fmt"getattr-->  mqd_a.mq_flag={mqd_a.mq_flags} -- mqd_a.mq_maxmsg={mqd_a.mq_maxmsg} -- mqd_a.mq_msgsize={mqd_a.mq_msgsize} -- mqd_a.mq_curmsgs={ mqd_a.mq_curmsgs}")

  var nbrmsgrecu: int
  var line =5 
  while OK  == true :

    while mqd_a.mq_curmsgs == 0 :
      ctrl = mq_getattr(mqd_t, mqd_a.addr)
      sleep(300)
      gotoXY(3,1); writeStyled(fmt" {mqd_t} {ctrl}  nbr msg : mqd_a.mq_curmsgs={ mqd_a.mq_curmsgs}")

    ctrl = mq_getattr(mqd_t, mqd_a.addr)
    for i in 0..1024 :  tab[i] ='\x00'
    rlen = mqd_a.mq_msgsize
    mq_priority= 999
    rcv = mq_receive(mqd_t, tab.addr, rlen,mq_priority)
    rcv_val = mqBuffer(tab)
    inc(nbrmsgrecu)
    ctrl = mq_getattr(mqd_t, mqd_a.addr)
    #echo fmt"tab--> {$tab}"
    if line > 22 : 
      while line >= 5 :
        for y in 1 .. 80 :
          gotoXY(line,y) 
          writeStyled(" ")
        dec(line)
      line = 5
    gotoXY(line , 1 )
    writeStyled(fmt"rcv--> {line} nbr Msg: {nbrmsgrecu}  bytes_read={$rcv_val}<-- len={len(rcv_val)}  q_priority={mq_priority}")
    #echo fmt"getattr-->  mqd_a.mq_flag={mqd_a.mq_flags} -- mqd_a.mq_maxmsg={mqd_a.mq_maxmsg} -- mqd_a.mq_msgsize={mqd_a.mq_msgsize} -- mqd_a.mq_curmsgs={ mqd_a.mq_curmsgs}"
    inc(line)
    stdout.flushFile




    if rcv_val == "EXIT" :
      OK = false


  discard getFunc()
  # Only demo
  discard mq_unlink(QUEUE_NAME) # détache MQ
  discard mq_close(mqd_t)       # destroy MQ

main()