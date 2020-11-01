#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <errno.h>
#include <mqueue.h>
#include <iostream>
#include "common.h"

int main(int argc, char **argv)
{
    mqd_t mq;

    char buffer[MAX_SIZE + 1];
    

    int must_stop = 0;

 

    /* create the message queue */
    mq = mq_open(QUEUE_NAME, O_RDONLY);
    CHECK((mqd_t)-1 != mq);
    

    do {
        ssize_t bytes_read;

        /* receive the message */
        bytes_read = mq_receive(mq, buffer, MAX_SIZE, NULL);
        CHECK(bytes_read >= 0);
        
		wprintf(L"bytes_read: %d \n",bytes_read);
		
        buffer[bytes_read] = '\0';
        if (! strncmp(buffer, MSG_STOP, strlen(MSG_STOP)))
        {
            wprintf(L"Received: %s \n",buffer);
            must_stop = 1;
        }
        else
        {
            wprintf(L"Received: %s \n",buffer);
        }
    } while (!must_stop);

    /* cleanup */
    //CHECK((mqd_t)-1 != mq_close(mq));
    //CHECK((mqd_t)-1 != mq_unlink(QUEUE_NAME));

    return 0;
}
