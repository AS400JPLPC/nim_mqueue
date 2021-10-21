import termkey
import strformat
import posix
import unicode


let QUEUE_NAME  = "/QMname"   # slash required

# term -> cat cat /proc/sys/fs/mqueue/msg_max
let MAX_NMSG    = 10          # nbr max de message

# term -> cat /proc/sys/fs/mqueue/msgsize_max
let MSGLEN:int   = 1024       # msg text length --> Linux default 8192  /  1024 AS400 --> UDS

var mqd_t : Mqd               # code retour mq_open       -1 error
var mqd_a : MqAttr            # attribut mqreceive

var bytes_send :cstring       # variable mq_receive


var send:cint                 # code retour mq_receive    -1 error

var ctrl : int                # code retour mq_getattr    -1 error


proc getRep() :string =
  stdin.flushFile
  onCursor()
  var chx :string
  var keyc :TKey
  gotoXY(20,1)
  writeStyled(fmt"Input  q = exit or F3 : ?")
  while true:
    gotoXY(20,50)
    (keyc, chx)  = getTKey()
    gotoXY(20,1)
    writeStyled(fmt"Input  q = exit or Enter > {$keyc}   {chx}")
    result = chx
    if keyc == TKey.Enter : return "Enter"
    if chx == "q": return
    stdout.flushFile

proc main() =
  #init terminal
  initTerm(24,132,"Test KEYBOARD")
  setBackgroundColor(bgBlue)
  eraseTerm()
  onCursor()

  # initialize the queue attributes

  mqd_a.mq_flags = 0         # 0 Normal

  mqd_a.mq_maxmsg = MAX_NMSG # max message next wait

  mqd_a.mq_msgsize = MSGLEN   # len mq_msgsize global général

  mqd_a.mq_curmsgs = 0        # nbr message dans la mq



  # Only demo
  #discard mq_unlink(QUEUE_NAME) # détache MQ
  #discard mq_close(mqd_t)       # destroy MQ

  # create the message
  mqd_t =  mq_open(cstring(QUEUE_NAME),O_RDWR or O_CREAT,0o640,mqd_a.addr ) # umask 640 Linux manuel
  gotoXY(5,10)
  writeStyled(fmt"mqd_t--> {mqd_t}")

  var choix : string
  # send message for test
  while choix != "q":

    bytes_send = cstring(fmt"Bonjour")
    send = mq_send(mqd_t, bytes_send,runeLen($bytes_send),20)
    gotoXY(7,10);
    writeStyled(fmt"{bytes_send}   {runeLen($bytes_send)}")

    for i in 1..4:
      bytes_send = ""
      bytes_send = cstring(fmt"message num:{$i}")
      send = mq_send(mqd_t, bytes_send,runeLen($bytes_send), 20)
      gotoXY(i+8,10)
      writeStyled(fmt"{bytes_send}   {runeLen($bytes_send)}")

    bytes_send = ""
    bytes_send = cstring(fmt"ôêèéîà123456")
    send = mq_send(mqd_t, bytes_send,len($bytes_send), 20);
    gotoXY(6,10)
    writeStyled(fmt"{bytes_send}   {runeLen($bytes_send)}   {len($bytes_send)}")

    choix = getRep()

  bytes_send = ""
  bytes_send = cstring(fmt"EXIT")
  send = mq_send(mqd_t, bytes_send,runeLen($bytes_send), 10);
  gotoXY(22,1)
  writeStyled(fmt"{bytes_send}   {runeLen($bytes_send)}")

  ctrl = mq_getattr(mqd_t, mqd_a.addr)
  gotoXY(24,1)
  writeStyled(fmt"ctrl--> {ctrl}  ")
  writeStyled(fmt"getattr-->  mqd_a.mq_flag={mqd_a.mq_flags} -- mqd_a.mq_maxmsg={mqd_a.mq_maxmsg} -- mqd_a.mq_msgsize={mqd_a.mq_msgsize} -- mqd_a.mq_curmsgs={ mqd_a.mq_curmsgs}")

  discard getFunc()
main()