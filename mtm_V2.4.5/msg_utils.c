/*
*	msg_utils.c
*
*	Utility to perform message queue releated functions.
*
*	ORIG: Hien T. Ly
*
* $Id:$
*
* $Log:	msg_utils.c,v $
 * Revision 1.2  07/02/02  thoniyim ()
 * Modified sca_msgrcv to check if the errno is E2BIG. If so, read the queue
 * again with the messageFlag set to MSG_NOERROR.
 * 
 * Revision 1.1  00/03/03  15:15:46  15:15:46  lyh ()
 * Initial revision
 * 
*
* $Revision: 1.1 $
*
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <sys/msg.h>
#include "scatype.h"

/*
*	Type definitions
*/
typedef struct {
	int	value;
	int	type;
	int	flag;
} st_timeout;

struct msgbuf
{
	long int mtype;		/* type of received/sent message */
	char mtext[1];		/* text of the message */
};

/*
*	sca_msgsnd
*
*	A wrapper function for the msgsnd() system call.
*	The msgsnd() call can be system interrupted. Here, we want
*	to retry the operation until we are able to send the message
*	or get a system error other than EINTR.
*/

int sca_msgsnd(int messageQueue, struct msgbuf *messagePointer,
	size_t messageLength, int messageFlag, st_timeout *timeout, int *return_code)
{
	int rc = -1;

	*return_code = SUCCESS;

	/*
	*	Make sure we have valid pointers here
	*/
	if ((messagePointer == (struct msgbuf *)NULL) || (timeout == (st_timeout *)NULL))
	{
#ifdef DEBUG
	fprintf(stdout,"sca_msgsnd: Called from %s line %d\n",__FILE__,__LINE__);
	fprintf(stdout,"sca_msgsnd: Invalid pointer(s) passed in function call\n");
	fflush(stdout);
#endif
		*return_code = EINVAL;
		return(rc);
	}

#ifdef DEBUG
	fprintf(stdout,"sca_msgsnd: Putting a message on queue %d\n",messageQueue);
	fprintf(stdout,"\tmessage size %d\n",messageLength);
	fprintf(stdout,"\tmessage flag %d\n",messageFlag);
	fflush(stdout);
#endif

	/*
	*	Start a loop so that we can send up to messageLength bytes
	*/
	for(;;)
	{
		rc = msgsnd(messageQueue, messagePointer, messageLength, messageFlag);
#ifdef DEBUG
        fprintf(stdout,"sca_msgsnd: rc = %d\n",rc);
        fprintf(stdout,"\terrno = %d\n",errno);
        fflush(stdout);
#endif
		if (rc < 0)
		{
			/* check for timeout */
			if (errno == EINTR)
			{
				if (timeout->flag == 1)
				{
					/* true timeout will cause a break */
					*return_code = ETIME;
					timeout->flag = 0;
					break;
				}
				else
					continue;
			}
			*return_code = errno;
			break;
		}
		break;
	}

#ifdef DEBUG
	if (*return_code != SUCCESS)
	{
		fprintf(stdout,"sca_msgsnd: failed with return code %d\n",*return_code);
		fflush(stdout);
	}
#endif

	return(rc);
}




/*
*	sca_msgrcv
*
*	A wrapper function for the msgrcv() system call.
*	The msgsnd() call can be system interrupted. Here, we want
*	to retry the operation until we are able to receive the message
*	or get a system error other than EINTR.
*/

int sca_msgrcv(int messageQueue, struct msgbuf *messagePointer,
	size_t messageLength, long int messageType, int messageFlag,
	st_timeout *timeout, int *return_code)
{
	int rc = -1;

	*return_code = SUCCESS;

	/*
	*	Make sure we have valid pointers here
	*/
	if ((messagePointer == (struct msgbuf *)NULL) || (timeout == (st_timeout *)NULL))
	{
#ifdef DEBUG
	fprintf(stdout,"sca_msgrcv: Called from %s line %d\n",__FILE__,__LINE__);
	fprintf(stdout,"sca_msgrcv: Invalid pointer(s) passed in function call\n");
	fflush(stdout);
#endif
		*return_code = EINVAL;
		return(rc);
	}

#ifdef DEBUG
	fprintf(stdout,"sca_msgrcv: Waiting for a message on queue %d\n",messageQueue);
	fprintf(stdout,"\tmessage size %d\n",messageLength);
	fprintf(stdout,"\tmessage type %d\n",messageType);
	fprintf(stdout,"\tmessage flag %d\n",messageFlag);
	fflush(stdout);
#endif

	/*
	*	Start a loop so that we can send up to messageLength bytes
	*/
	for(;;)
	{
		rc = msgrcv(messageQueue, messagePointer, messageLength, messageType, messageFlag);
		if (rc < 0)
		{
			/* check for timeout */
			if (errno == EINTR)
			{
				if (timeout->flag == 1)
				{
					/* true timeout will cause a break */
					*return_code = ETIME;
					timeout->flag = 0;
					break;
				}
				else
					continue;
			}
			else if (errno == E2BIG)
			{
				messageFlag = MSG_NOERROR;
				msgrcv(messageQueue, messagePointer, messageLength, messageType, messageFlag);
			}
			*return_code = errno;
			break;
		}
		break;
	}

#ifdef DEBUG
	if (*return_code != SUCCESS)
	{
		fprintf(stdout,"sca_msgrcv: failed with return code %d\n",*return_code);
		fflush(stdout);
	}
#endif

	return(rc);
}
