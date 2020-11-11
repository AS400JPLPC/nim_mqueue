** ÉTUDE MQUEUE** <br />
Jean-Pierre Laroche <br />

[man page mqueue](https://man7.org/linux/man-pages/man0/mqueue.h.0p.html)
https://github.com/SgtWiggles/ume   thank you that inspired me to set up a dedicated terminal<br />

<br />
tank you github for exemple open-source for etude<br />

**programme qmsend:**<br />
    &rarr;&nbsp;mq_open(QUEUE_NAME,O_RDWR or O_CREAT,0o640,mqd_a.addr)<br />
    &rarr;&nbsp;mq_send(mqd_t, bytes_send,runeLen($bytes_send),20)<br />

**programme qmreceive:**<br />
    &rarr;&nbsp;mq_open(QUEUE_NAME , O_RDONLY, 0666, mqd_a.addr)<br />
    &rarr;&nbsp;mq_receive(mqd_t, tab.addr, rlen,mq_priority)<br />