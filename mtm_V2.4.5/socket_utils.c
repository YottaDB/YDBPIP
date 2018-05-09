/*
*	socket_utils
*
*	Utility to perform socket related functions.
*
*	ORIG: Hien T. Ly
*
* $Id:$
*
* $Log:	socket_utils.c,v $
 * Revision 1.5  00/07/07  12:08:34  12:08:34  lyh ()
 * replaced ENOTREADY with EINVAL
 * replaced return; with return(FAILURE); in sca_select()
 * This will resolve compiler warning when porting to other platforms.
 * 
 * Revision 1.4  00/07/06  17:18:38  17:18:38  lyh ()
 * Removed certain restrictions for tcp client (MTM v2.0.1)
 * 
 * Revision 1.3  00/03/23  10:50:26  10:50:26  lyh ()
 * Put in a check for valid pointers
 * 
 * Revision 1.2  00/03/13  15:15:43  15:15:43  lyh ()
 * Check for valid pointers
 * 
 * Revision 1.1  00/03/03  15:17:10  15:17:10  lyh ()
 * Initial revision
 * 
*
* $Revision: 1.5 $
*
*/

#include <stdio.h>
#include <netdb.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <sys/socketvar.h>
#include <sys/errno.h>
#include "scatype.h"

/*
*	Type definitions
*/

typedef struct {
	int	value;
	int	type;
	int	flag;
} st_timeout;

/*
*	Local definition
*/
#define MAX_CONNECT_RETRY	100


/*
*	sca_connect
*
*	A wrapper function for the connect() system call.
*	The connect() call can be system interrupted. Here, we want
*	to retry the operation until we are able to connect or get
*	a system error other than EINTR.
*
*	The only way to get out of the loop is that we get a properly
*	connected socket, or a timeout. It's important to set up the
*	timer before calling this routine so that we can timeout if
*	we fail indefinitely on the system calls.
*/
int sca_connect(void *socketAddress, size_t socketLength, st_timeout *timeout, int *return_code)
{
	struct protoent		*protocol_data;
	int			rc;
	int			optbuff = 1;
	int			mySocket = FAILURE;
	int			retry_count = 0;

	*return_code = SUCCESS;

	/*
	*	Make sure we have valid pointers here
	*/
	if ((socketAddress == (void *)NULL) || (timeout == (st_timeout *)NULL))
	{
#ifdef DEBUG
	fprintf(stdout,"sca_connect: Called from %s line %d\n",__FILE__,__LINE__);
	fprintf(stdout,"sca_connect: Invalid pointer(s) passed in function call\n");
	fflush(stdout);
#endif
		*return_code = EINVAL;
		return(FAILURE);
	}

	/*
	*	Get the protocol number
	*/
	protocol_data = getprotobyname("TCP");

	do
	{
		/*
		*	Close allocated socket
		*/
		if (mySocket != FAILURE)
		{
			close(mySocket);
			mySocket = FAILURE;
		}

		/*
		*	Test retry count
		*/
		if (retry_count > MAX_CONNECT_RETRY)
		{
			mySocket = FAILURE;
			*return_code = errno;
			break;
		}
		retry_count++;

		/*
		*	Allocate socket
		*/
		if((mySocket = socket(	AF_INET, 
					SOCK_STREAM, 
					protocol_data->p_proto)) == FAILURE)
		{
#ifdef DEBUG
	fprintf(stdout,"sca_connect: Failed to allocate socket\n");
	fflush(stdout);
#endif
			continue;
		}

		/*
		*	Set socket REUSEADDR option
		*/
		if((rc = setsockopt(mySocket, 
				    SOL_SOCKET, 
				    SO_REUSEADDR,
				    (void *)&optbuff,
				    sizeof(optbuff))) == FAILURE)
		{
#ifdef DEBUG
	fprintf(stdout,"sca_connect: Failed to set option SO_REUSEADDR for socket %d\n",mySocket);
	fflush(stdout);
#endif
			continue;
		}

		/*
		*	Set socket KEEPALIVE option
		*/
		if((rc = setsockopt(mySocket, 
				    SOL_SOCKET, 
				    SO_KEEPALIVE,
				    (void *)&optbuff,
				    sizeof(optbuff))) == FAILURE)
		{
#ifdef DEBUG
	fprintf(stdout,"sca_connect: Failed to set option SO_KEEPALIVE for socket %d\n",mySocket);
	fflush(stdout);
#endif
			continue;
		}

		/*
		*	Perform connect call
		*/
		rc = connect(mySocket, socketAddress, socketLength);

		/*
		*	If the connect() call failed due timeout, we will
		*	terminate the loop.
		*/
		if (rc < 0)
		{
			/*
			*	Check if we have a GTM_TIMER. If so, it's a
			*	"true" timeout, and we should return.
			*/
			if (errno == EINTR)
			{
				if (timeout->flag == 1)
				{
					*return_code = ETIME;
					break;
				}
				else
					continue;
			}

			/*
			*	If errno is not EINTR, we have a valid error.
			*/
#ifdef DEBUG
	fprintf(stdout,"sca_connect: Failed connect() system call, error is %d\n",errno);
	fflush(stdout);
#endif
			*return_code = errno;
			break;
		}

		/*
		*	Everything is ok, break the loop
		*/
		break;

	} while(0);

#ifdef DEBUG
	if (*return_code == SUCCESS)
	{
		fprintf(stdout,"sca_connect: connected socket %d\n",mySocket);
		fflush(stdout);
	}
	else
	{
		fprintf(stdout,"sca_connect: failed with return code %d\n",*return_code);
		fflush(stdout);
	}
#endif

	return(mySocket);
}



/*
*	sca_accept
*
*	A wrapper function for the accept() system call.
*	The accept() call can be system interrupted. Here, we want
*	to retry the operation until we are able to send the message
*	or get a system error other than EINTR.
*/
int sca_accept(int listenSd, struct sockaddr *socketAddress, size_t *addressLength, st_timeout *timeout, int *return_code)
{
	int		rc;
	int		mySocket = FAILURE;
	fd_set		readSet;

	*return_code = SUCCESS;

	/*
	*	Make sure we have valid pointers here
	*/
	if ((socketAddress == (struct sockaddr *)NULL) || 
		(addressLength == (size_t *)NULL) || 
		(timeout == (st_timeout *)NULL))
	{
#ifdef DEBUG
	fprintf(stdout,"sca_accept: Called from %s line %d\n",__FILE__,__LINE__);
	fprintf(stdout,"sca_accept: Invalid pointer(s) passed in function call\n");
	fflush(stdout);
#endif
		*return_code = EINVAL;
		return(FAILURE);
	}

	for(;;)
	{
		/*
		*	Wait for listening socket to be ready.
		*/
		FD_ZERO(&readSet);

		FD_SET(listenSd, &readSet);

		rc = sca_select(listenSd+1, &readSet, (fd_set *)NULL,
			(fd_set *)NULL, timeout, return_code);

		if (rc <= 0)
			break;

		/*
		*	ok, listening socket is ready...
		*/
		if (FD_ISSET(listenSd, &readSet))
		{
			mySocket = accept(listenSd, 
				socketAddress,
				(socklen_t *)addressLength);
			/*
			*	We could catch an interrupt here.
			*	So check if it's a timeout.
			*/
			if (mySocket < 0)
			{
				/* check for timeout */
				if (errno == EINTR)
				{
					if (timeout->flag == 1)
					{
						*return_code = ETIME;
						timeout->flag = 0;
						break;
					}
					else
						continue;
				}
				/* other errors on accept() call */
				*return_code = errno;
				break;
			}

			/*
			*	if mySocket is 0, the client probably dropped
			*	the connection request. Otherwise, we have a
			*	valid connected socket. Break out of the loop
			*	in either case.
			*/
			break;
		}
	}

#ifdef DEBUG
	if (*return_code != SUCCESS)
	{
		fprintf(stdout,"sca_accept: failed with return code %d\n",*return_code);
		fflush(stdout);
	}
#endif

	return(mySocket);
}

/*
*	sca_send
*
*	A wrapper function for the send() system call.
*	The send() call can be system interrupted. Here, we want
*	to retry the operation until we are able to send the message
*	or get a system error other than EINTR.
*/
int sca_send(int socketDescriptor, char *messagePointer, 
	size_t messageLength, int socketFlags, st_timeout *timeout, int *return_code)
{
	fd_set writeSet;
	int	rc;
	int	sendn = 0;	/* number of bytes sent */

	*return_code = SUCCESS;

	/*
	*	Make sure we have valid pointers here
	*/
	if ((messagePointer == (char *)NULL) || (timeout == (st_timeout *)NULL))
	{
#ifdef DEBUG
	fprintf(stdout,"sca_send: Called from %s line %d\n",__FILE__,__LINE__);
	fprintf(stdout,"sca_send: Invalid pointer(s) passed in function call\n");
	fflush(stdout);
#endif
		*return_code = EINVAL;
		return(FAILURE);
	}

	/*
	*	Start a loop so that we can send up to messageLength bytes
	*/
	for(;;)
	{
		/*
		*	Wait for socket to be ready for write operation.
		*/
		FD_ZERO(&writeSet);

		FD_SET(socketDescriptor, &writeSet);

		rc = sca_select(socketDescriptor+1, (fd_set *)NULL, &writeSet,
			(fd_set *)NULL, timeout, return_code);

		if (rc <= 0)
			break;

		/*
		*	ok, socket is ready for write...
		*/
		if (FD_ISSET(socketDescriptor, &writeSet))
		{
			rc = send(socketDescriptor, (void *)&messagePointer[sendn],
					messageLength-sendn, socketFlags);
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

				break;
			}
			else if (rc > 0)
			{
				sendn += rc;
				if (sendn >= messageLength)
				{
					rc = sendn;
					break;
				}
			} 
			else
			{
				/* socket disconnect? */
				break;
			}
		}
	}

#ifdef DEBUG
	if (*return_code != SUCCESS)
	{
		fprintf(stdout,"sca_send: failed with return code %d\n",*return_code);
		fflush(stdout);
	}
#endif

	return(rc);
}




/*
*	sca_recv
*
*	A wrapper function for the recv() system call.
*	The recv() call can be system interrupted. Here, we want
*	to retry the operation until we are able to receive the message,
*	get a system error other than EINTR, or a timeout.
*
*/
int sca_recv(int socketDescriptor, char *messagePointer, 
	size_t messageLength, int socketFlags, st_timeout *timeout, int *return_code)
{
	fd_set  readSet;
	int 	rc;
	int	recvn = 0;		/* number of bytes received */

	*return_code = SUCCESS;

	/*
	*	Make sure we have valid pointers here
	*/
	if ((messagePointer == (char *)NULL) || (timeout == (st_timeout *)NULL))
	{
#ifdef DEBUG
	fprintf(stdout,"sca_recv: Called from %s line %d\n",__FILE__,__LINE__);
	fprintf(stdout,"sca_recv: Invalid pointer(s) passed in function call\n");
	fflush(stdout);
#endif
		*return_code = EINVAL;
		return(FAILURE);
	}

	/*
	*	Start a loop so that we can read up to messageLength bytes
	*/
	for(;;)
	{
		/*
		*	Wait for socket to be ready for read operation.
		*/
		FD_ZERO(&readSet);

		FD_SET(socketDescriptor, &readSet);

		rc = sca_select(socketDescriptor+1, &readSet, (fd_set *)NULL,
			(fd_set *)NULL, timeout, return_code);

		if (rc <= 0)
			break;

		/*
		*	ok, socket is ready for read...
		*/
		if (FD_ISSET(socketDescriptor, &readSet))
		{
			rc = recv(socketDescriptor, 
				(void *)&messagePointer[recvn],
				messageLength-recvn, socketFlags);
			/*
			*	We could catch an interrupt here.
			*	So check if it's a timeout.
			*/
			if (rc < 0)
			{
				/* check for timeout */
				if (errno == EINTR)
				{
					if (timeout->flag == 1)
					{
						*return_code = ETIME;
						timeout->flag = 0;
						break;
					}
					else
						continue;
				}
				/* other errors on recv() call */
				break;
			}
			else if (rc > 0)
			{
				recvn += rc;
				if (recvn >= messageLength)
				{
					rc = recvn;
					break;
				}
			} 
			else
			{
				/* socket disconnect? */
				break;
			}
		}
	}

#ifdef DEBUG
	if ((*return_code != SUCCESS) || (rc == 0))
	{
		fprintf(stdout,"sca_recv: failed to read socket descriptor %d\n",socketDescriptor);
		fprintf(stdout,"\treturn code  = %d\n",*return_code);
		fprintf(stdout,"\texpected message length = %d\n",messageLength);
		fprintf(stdout,"\tnumber of bytes read so far = %d\n",recvn);
		fprintf(stdout,"\tvalue to be returned = %d\n",rc);
		fflush(stdout);
	}
#endif

	return(rc);
}




/*
*	sca_select
*
*	A wrapper function for the select() system call.
*	The select() call can be system interrupted. Here, we want
*	to retry the operation until the socket is ready,
*	get a system error other than EINTR, or a timeout.
*
*/
int sca_select(int maxDescriptor, fd_set *readSet, fd_set *writeSet, fd_set *exceptSet, st_timeout *timeout, int *return_code)
{
	int rc;
	struct timeval sTimeout;
	struct timeval *pTimeout = (struct timeval *)NULL;

	/*
	*	Make sure at least one of (read, write, except) is non-NULL.
	*	Otherwise, what are we listening on?
	*/
	if ((readSet == (fd_set *)NULL) && 
		(writeSet == (fd_set *)NULL) && 
		(exceptSet == (fd_set *)NULL))
	{
#ifdef DEBUG
	fprintf(stdout,"sca_select: Called from %s line %d\n",__FILE__,__LINE__);
	fprintf(stdout,"sca_select: One of (read/write/except) sets must be non-NULL\n");
	fflush(stdout);
#endif
		*return_code = EINVAL;
		return(FAILURE);
	}

	/*
	*	Did we get a valid timeout pointer?
	*/
	if (timeout == (st_timeout *)NULL)
	{
#ifdef DEBUG
	fprintf(stdout,"sca_select: Called from %s line %d\n",__FILE__,__LINE__);
	fprintf(stdout,"sca_select: Invalid pointer(s) passed in function call\n");
	fflush(stdout);
#endif
		*return_code = EINVAL;
		return(FAILURE);
	}

	/*
	*	If timeout value is 0, we'll return immediately on the select().
	*	If it's > 0, we'll wait for the specified time.
	*	If it's < 0, we'll wait until a socket is ready.
	*/
	if (timeout->value >= 0)
	{
		memset(&sTimeout, 0, sizeof(sTimeout));
		sTimeout.tv_sec = timeout->value;
		pTimeout = &sTimeout;
	}

	for (;;)
	{
		rc = select(maxDescriptor, readSet, writeSet,
			exceptSet, pTimeout);

		if (rc < 0)
		{
			/*
			*	Check if we have a GTM_TIMER. If so, it's a
			*	"true" timeout, and we should return.
			*/
			if (errno == EINTR)
			{
				if (timeout->flag == 1)
				{
					rc = 0;
					break;
				}
				else
					continue;
			}

			/*
			*	If errno is not EINTR, we have a valid error.
			*	Break the loop and return at this point.
			*/
			break;
		}

		/*
		*	At this point rc can either be 0 or positive.
		*	If rc is 0, that means the select() call is
		*	timed out by the selectTimeout value. If rc is
		*	positive, then we have something ready for
		*	read/write operation. we'll break the loop in
		*	either case.
		*/
		break;
	}

	if (rc == 0)
	{
		/*
		*	Either a GTM_TIMER or the actual timeout on the select()
		*	call causes rc to become 0
		*/
		*return_code = ETIME;
		timeout->flag = 0;
	}

	return(rc);
}
