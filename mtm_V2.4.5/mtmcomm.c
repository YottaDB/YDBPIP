/*
*	mtmcomm.c - Sanchez Message Transport Manager for UNIX
*
*	Copyright(c)1992 Sanchez Computer Associates, Inc.
*	All Rights Reserved
*
*	ORIG:	Sara G. Walters - 11 Jan 1995
*
*	DESC:
*
*   $Id: mtmcomm.c,v 1.1 2000/06/01 00:45:35 lyh Exp lyh $
*   $Log:	mtmcomm.c,v $
 * Revision 2.23  09/05/18  paulj CR-41191
 * Modifed mtm_skt_accept to not to log an error for a connection
 * reset. 
 *
 * Revision 2.22  07/07/23  thoniyim
 * Modified tcp_client_connect to check the msgflag and if set, send a 
 * message to the server on successful connection to the client.
 *
 * Revision 2.21  07/03/12  thoniyim
 * Modified mtm_skt_accept to check if MTMAsyncMode is set and MTMTcpClient
 * is not null. If so, the MTM is started with the -h option set. Copy
 * MTMTcpClient to MTMAsyncClient and don't overwrite it.
 * (MTM V2.4.5)
 *
 * Revision 2.20  05/02/25  thoniyim
 * Modified mtm_skt_accept to free the MTMAsyncClient and allocate the new 
 * IP/port when a second connection arrives. It may be that the connection 
 * broke off without a chance to call Disconnect or free the MTMAsyncClient.
 * (MTM V2.4.2)
 *
 * Revision 2.19  05/01/18  thoniyim
 * Modified to send an unsolicited message to a connected client in ASYNC MTM
 * (MTM V2.4.1)
 *
 * Revision 2.18  04/08/16  yurkovicg ()
 * Modified mtm_skt_recv to process >64K messages in a bby MTM.
 *
 * Revision 2.17  04/02/04  thoniyim ()
 * Changed the flags MTMSignalFlags.cntrl_msg and
 * MTMSignalFlags.server_msg to counters
 *
 * Revision 2.16  00/07/07  11:58:46  11:58:46  lyh ()
 * added string.h for strlen() - resolve sompiler warning when porting
 * to other platforms.
 * 
 * Revision 2.15  00/07/06  17:17:48  17:17:48  lyh ()
 * Removed certain restrictions for tcp client (MTM v2.0.1)
 * 
 * Revision 2.13  00/06/02  13:26:26  13:26:26  lyh ()
 * Changes as a result of porting to other platforms
 * 
 * Revision 2.12  00/05/15  13:58:03  13:58:03  lyh ()
 * Correct a bug with offline log-on message
 * 
 * Revision 2.11  00/05/11  09:15:41  09:15:41  lyh ()
 * Added an error code 1 in the error message going back to the client
 * 
 * Revision 2.10  00/04/18  16:38:10  16:38:10  lyh ()
 * only log message if return_code from sca_recv is non-zero
 * 
 * Revision 2.9  00/04/06  16:57:53  16:57:53  lyh ()
 * same fix, different place
 * 
 * Revision 2.8  00/04/06  16:52:28  16:52:28  lyh ()
 * don't log error if client drops connection
 * 
 * Revision 2.7  00/03/30  13:42:03  13:42:03  lyh ()
 * Minor correction
 * 
 * Revision 2.6  00/03/29  09:35:11  09:35:11  lyh ()
 * Changed length format to pattern matching instead of using option
 * 
 * Revision 2.5  00/03/23  10:36:12  10:36:12  lyh ()
 * Added logic not to accept more client connection requests if we reach
 * maximum number of of connected clients
 * 
 * Revision 2.4  00/03/14  14:19:08  14:19:08  lyh ()
 * Correct fflush statement
 * 
 * Revision 2.3  00/03/13  14:21:18  14:21:18  lyh ()
 * Check pointer to avoid segment violation error
 * 
 * Revision 2.2  00/03/03  15:11:15  15:11:15  lyh ()
 * sand comber release
 * 
 * Revision 2.1  00/01/17  11:16:10  11:16:10  lyh ()
 * storm trooper release
 * 
 * Revision 1.3  99/12/29  18:33:57  18:33:57  lyh ()
 * added heartbeat auto echo
 * 
 * Revision 1.2  99/12/27  15:59:27  15:59:27  lyh ()
 * added variable length size
 * 
 * Revision 1.1  99/12/20  16:31:54  16:31:54  lyh ()
 * Initial revision
 * 
 * Revision 1.6  96/04/26  15:10:54  15:10:54  zengf (Fan Zeng)
 * final fix
 * 
 * Revision 1.5  96/04/25  16:13:07  16:13:07  zengf (Fan Zeng)
 * fix client message bug.
 * 
 * Revision 1.4  96/04/17  15:16:41  15:16:41  zengf (Fan Zeng)
 * Fixed stats.
 * 
 * Revision 1.3  96/04/10  17:21:25  17:21:25  zengf (Fan Zeng)
 * General cleaning up
 * 
 * Revision 1.2  96/03/13  10:02:14  10:02:14  zengf (Fan Zeng)
 * prepare for removing signals
 * 
 * Revision 1.1  96/02/28  17:28:10  17:28:10  zengf (Fan Zeng)
 * Initial revision
 * 
 * Revision 1.4  95/08/11  14:41:39  14:41:39  rcs ()
 * Benchmark testing bug fixes
 * 
 * Revision 1.3  95/07/19  14:22:50  14:22:50  rcs ()
 * Bug fixes as a result of MTM System Test
 * 
 * Revision 1.2  95/05/22  15:14:02  15:14:02  sca ()
 * I VMS
 * 
*   $Revision: 2.16 $
*
*/
#include	<ctype.h>
#include	<stdio.h>
#include	<errno.h>
#include	<time.h>
#include	<netdb.h>
#include	<string.h>
#include	<stdlib.h>
#include	<sys/ipc.h>
#include	<sys/socket.h>
#include	<sys/types.h>
#include	<sys/select.h> 
#include	<netinet/in.h>
#include	<netdb.h>
#include	<arpa/inet.h>
#include	<sys/ioctl.h>
#include	"mtm.h"
#include	"mtmprototypes.h"
#include	"mtmerrno.h"
#include	"mtmext.h"

/*
 *	Static Prototypes
 */

static void mtm_reset_client_data(MTM_CLIENT_ROUTING_TABLE *);

/*
 *	Local Prototypes
 */
void mtm_tcp_recv();
void mtm_tcp_send();

/*
 *	mtm_skt_init:
 *	[module number i.e. Future] [module name]
 *
 *	Description:
 *		Initial the listening socket.
 *
 *	Returns:
 *
 */
RETURNSTATUS
mtm_skt_init(void)
{
   	RETURNSTATUS 		rc = SUCCESS;
	struct sockaddr_in	server_addr;
	struct protoent		*protocol_data;
	SLONG                   optbuff = 1;
	int			mySocket;
	size_t			option_len;

#ifdef DEBUG
	fprintf(stdout,"mtm_skt_init: Start of routine\n");
	fflush(stdout);
#endif

	MTMListenSd = DISCONNECTED;

	memset((char *)&server_addr,0,sizeof(server_addr));
	server_addr.sin_family = AF_INET;
	server_addr.sin_port = htons(MTMInternetPort);
	if (MTMRootIp[0] == '\0')
		server_addr.sin_addr.s_addr = htonl(INADDR_ANY);
	else
		server_addr.sin_addr.s_addr = inet_addr(MTMRootIp);

	do
	{
		/*
		 *	Get the protocol number
		 */
		if ( (protocol_data = getprotobyname("TCP")) == (struct protoent *)NULL )
		{
#ifdef DEBUG
	fprintf(stdout,"mtm_skt_init: Function getprotobyname() failed, errno = %d\n",errno);
	fflush(stdout);
#endif
			rc = errno;
			break;
		}

		/*
		 *	Allocate a socket
		 */
		if((mySocket = socket(AF_INET, 
					SOCK_STREAM, 
					0)) == FAILURE)
		{
#ifdef DEBUG
	fprintf(stdout,"mtm_skt_init: Function socket() failed, errno = %d\n",errno);
	fflush(stdout);
#endif
			rc = errno;
			break;
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
	fprintf(stdout,"mtm_skt_init: Function setsockopt() REUSEADDR failed, errno = %d\n",errno);
	fflush(stdout);
#endif
			rc = errno;
			break;
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
	fprintf(stdout,"mtm_skt_init: Function setsockopt() KEEPALIVE failed, errno = %d\n",errno);
	fflush(stdout);
#endif
			rc = errno;
			break;
		}

		/*
		 *	Bind the socket
		 */
		if((rc = bind(mySocket,
				(const void *)&server_addr,
				sizeof(struct sockaddr_in))) == FAILURE)
		{
#ifdef DEBUG
	fprintf(stdout,"mtm_skt_init: Function bind() failed, errno = %d\n",errno);
	fflush(stdout);
#endif
			rc = errno;
			break;
		}

		/*
		 *	Make socket a listen socket
		 */
		if((rc = listen(mySocket,MTMMaxClient)) == FAILURE)
		{
#ifdef DEBUG
	fprintf(stdout,"mtm_skt_init: Function listen() failed, errno = %d\n",errno);
	fflush(stdout);
#endif
			rc = errno;
			break;
		}

		/*
		 *	If we get here, then everything is ok.
		 */
		rc = SUCCESS;
		break;

	} while(0);

	/*
	 *	Check for error
	 */
	if (rc != SUCCESS)
	{
		MTM_EFD(rc);
		rc = FAILURE;
		if (mySocket > 0)
			close(mySocket);
	}
	else
	{
		MTMListenSd = mySocket;
		FD_SET(MTMListenSd,&MTMReadMask);
	}

#ifdef DEBUG
	fprintf(stdout,"mtm_skt_init: End of routine - returning rc %d\n",rc);
	fflush(stdout);
#endif

	return rc;
}

/*
 *	mtm_skt_connect:
 *	[module number i.e. Future] [module name]
 *
 *	Description:
 *	Processes client connect or disconnect requests
 *
 *	Returns:
 *
 */
RETURNSTATUS
mtm_skt_connect(void)
{
	RETURNSTATUS 	rc = SUCCESS;

	/*
	*	Check to see if any connection requests are pending.
	*/
	if((rc = mtm_skt_accept()) != SUCCESS)
	{
		MTM_EFD(0);
		return FAILURE;
	}

	return SUCCESS;
}

/*
*	mtm_skt_accept:
*	[module number i.e. Future] [module name]
*
*	Description:
*	Processes client connection requests
*
*	Returns:
*
*/
RETURNSTATUS
mtm_skt_accept(void)
{
	RETURNSTATUS 		rc = SUCCESS;
	SLONG 			accept_sd = DISCONNECTED;
	struct sockaddr_in 	socket_addr;
	unsigned long 		addrlen = 0;
	int 			flag = FALSE;
	register int 		i = 0;
	char			*ip_address = (char *)NULL;
	struct timeval		time_val;
	struct timezone		time_zone;
	char 			*host;
	SLONG			optbuff = 1;
	int			return_code;
        st_tcpclient    	*temp;

	addrlen = sizeof(struct sockaddr_in);

	/*
	*	Put the listen socket into non-blocking mode
	*/
	flag = TRUE;
	if((rc = ioctl(MTMListenSd,FIONBIO,&flag)) == FAILURE)
	{
		MTM_EFD(errno);
		return FAILURE;
	}

	/*
	*	Accept the connection request(s)
	*/
#ifdef DEBUG
	(void)fprintf(stdout,"mtm_skt_accept:Calling accept connection\n");
	(void)fflush(stdout);
#endif

	MTMTimeout.value = 10;

	sca_SetupTimer((void *)mtm_skt_accept, &MTMTimeout, (void *)mtm_alarm_catcher);

	accept_sd = sca_accept(MTMListenSd,
			(struct sockaddr *)&socket_addr,
			&addrlen,
			&MTMTimeout,
			&return_code);

	sca_CancelTimer((void *)mtm_skt_accept, &MTMTimeout);

	/*
	*	Always put listen socket back in blocking mode
	*/
	flag = FALSE;
	if((rc = ioctl(MTMListenSd,FIONBIO,&flag)) == FAILURE)
	{
		MTM_EFD(errno);
		if (accept_sd > 0)
			close(accept_sd);
		return FAILURE;
	}

	if (accept_sd < 0)
	{
#ifdef DEBUG
	(void)fprintf(stdout,"mtm_skt_accept: sca_accept() failed, return_code = %d\n",return_code);
	(void)fflush(stdout);
#endif
		MTM_EFD(return_code);
		if ((return_code == EAGAIN) || (return_code == EWOULDBLOCK))
		{
			/* Did we remember to enable the listen socket? */
			mtm_enable_sd();
		}
		return FAILURE;
	}
	else if (accept_sd == 0)
	{
#ifdef DEBUG
	(void)fprintf(stdout,"mtm_skt_accept: client probably dropped connection request\n");
	(void)fflush(stdout);
#endif
		return SUCCESS;
	}

	/*
	*	At this point, we have a valid connected socket.
	*/
#ifdef DEBUG
	(void)fprintf(stdout,"mtm_skt_accept: socket created %d\n",accept_sd);
	(void)fflush(stdout);
#endif

	/*
	 * Check ip address to see if a valid client
	 */
	if (MTMValidClients != NULL)
	{
		host = MTMValidClients;
		while (host != NULL)
		{
			if (strcmp (((MTM_VALID_CLIENT *)host)->ip_address,
				     inet_ntoa(socket_addr.sin_addr)) == 0)
				break;
			host = ((MTM_VALID_CLIENT *)host)->next;
		}
		
		if (host == NULL)
		{
			MTM_EFD(MTM_INVALID_CLIENT_CONNECT);
			close(accept_sd);
			return FAILURE;
		}
	}

	/*
	*	Set KEEPALIVE option on the new socket
	*/
	if((rc = setsockopt(accept_sd,
				SOL_SOCKET,
				SO_KEEPALIVE,
				(void *)&optbuff,
				sizeof(optbuff))) == FAILURE)
	{
		MTM_EFD(errno);
		close(accept_sd);
		return FAILURE;
	}

	/*
	*	Put the new socket into blocking mode
	*/
	flag = FALSE;
	if((rc = ioctl(accept_sd,FIONBIO,&flag)) == FAILURE)
	{
		MTM_EFD(errno);
		close(accept_sd);
		return FAILURE;
	}

	/*
	*	Find a free slot in the routing table.
	*/
#ifdef DEBUG
	(void)fprintf(stdout,"mtm_skt_accept:Client Port number %d\n",socket_addr.sin_port);
	(void)fflush(stdout);
#endif
	for(i = MTMTcpCount; i < MTMMaxClient; i++)
	{
		if(MTMRoutingTbl[i].sd == DISCONNECTED)
			break;
	}

	if(i < MTMMaxClient) 
	{
		MTMRoutingTbl[i].sd = accept_sd;
		MTMRoutingTbl[i].port = socket_addr.sin_port;
		ip_address = inet_ntoa(socket_addr.sin_addr);
		(void)memcpy(MTMRoutingTbl[i].ip_address,ip_address,IP_ADDR_LEN);

#ifdef DEBUG
        fprintf(stdout,"Assigning values to MTMAsyncClient\n");
        fflush(stdout);
#endif
 
		if (MTMAsyncMode == TRUE)
        	{
			if (MTMTcpClient != NULL)
				MTMAsyncClient = MTMTcpClient;
			else
			{
				/*
				* Allocate memory for TCP client structure
				*/
				temp = (st_tcpclient *)malloc(sizeof(st_tcpclient));
				if (temp == NULL)
				{
					MTM_EFD(errno);
					return;
				}
 
				/*
				* Initialize new memory block
				*/
				memset(temp,0,sizeof(st_tcpclient));
 
				strcpy(temp->hostAddr,ip_address);
				temp->portNum = socket_addr.sin_port;
				temp->maxSd = 1;
				temp->usedSd = 0;
				temp->next = (st_tcpclient *)NULL;
				temp->clientSd[0] = i;
 
				/*
				* Insert the new memory block in MTMAsyncClient 
				* in an unsorted order.
				*/
				if (MTMAsyncClient == (st_tcpclient *)NULL)
					MTMAsyncClient = temp;
				else
				{
					free(MTMAsyncClient);
					MTMAsyncClient = temp;
#if DEBUG
	fprintf(stdout,"mtm_skt_accept : Connection reset\n");
	MTM_EFD(MTM_CLIENT_ASYNC_TABLE_ERROR);
#endif
				}
			}
		} 
		/*
		*	Get the connect time
		*/
		gettimeofday(&time_val, &time_zone);
		MTMRoutingTbl[i].time_connected = time_val.tv_sec;
	}
	else
	{
		MTM_EFD(MTM_CLIENT_ROUTING_TABLE_FULL);
		close(accept_sd);
		return FAILURE;
	}

#ifdef DEBUG
	(void)fprintf(stdout,"mtm_skt_accept:Assign slot %d\n",i);
	(void)fprintf(stdout,"mtm_skt_accept:SD %d\n",MTMRoutingTbl[i].sd);
	(void)fprintf(stdout,"mtm_skt_accept:PORT %d\n",MTMRoutingTbl[i].port);
	(void)fflush(stdout);
#endif
	/*
	*	Put the socket into the select read mask
	*/
	FD_SET(accept_sd,&MTMReadMask);

	return SUCCESS;
}

/*
*	mtm_skt_recv:
*	[module number i.e. Future] [module name]
*
*	Description:
*	Receives message from a socket
*
*	Returns:
*
*/
RETURNSTATUS
mtm_skt_recv( 	char *msg,
		MTM_CLIENT_ROUTING_TABLE *client_routing)
{
	RETURNSTATUS 	rc = SUCCESS;
	char		len_field[32];	/* a reasonable message length */
	SLONG		msg_length = 0;
	char 		*ptr = (char *)NULL;			
	char 		*mtext = (char *)NULL;			
	char		server_type_name[MAX_NAME_LEN+1];
	register int 	i;
	time_t		cal_time;
	SLONG		header_size, body_size;
	SLONG		return_code;
	MTM_MSG_HEADER	*pHeader;

	/*
	*	Check if message header is usable
	*/
	pHeader = (MTM_MSG_HEADER *)msg;
	if (pHeader == NULL)
	{
		MTM_EFD(EFAULT);
		return FAILURE;
	}

	memset(len_field, 0, sizeof(len_field));

	mtext = (msg + sizeof(MTM_MSG_HEADER));

	MTMTimeout.value = MTM_DEFAULT_TIMEOUT;

	/*
	*	First, get the message header
	*/
	sca_SetupTimer((void *)mtm_skt_recv, &MTMTimeout, (void *)mtm_alarm_catcher);

	header_size = MTMLength.hsize;

	rc = sca_recv(client_routing->sd,
		len_field,
		header_size,
		0,
		&MTMTimeout,
		&return_code);

	sca_CancelTimer((void *)mtm_skt_recv, &MTMTimeout);

	if (rc <= 0) 
	{
#ifdef DEBUG
	fprintf(stdout,"mtm_skt_recv: failed to read message header\n");
	fprintf(stdout,"mtm_skt_recv: socket %d, rc %d, errno %d\n",client_routing->sd,rc,return_code);
	fflush(stdout);
#endif
		if ((return_code == ENOTCONN) || 
		    (return_code == ECONNRESET) ||
		    (return_code == ENOMSG) ||
		    (return_code == EWOULDBLOCK) ||
		    (rc == 0))
		{
			/*
			*	Disconnect has occurred.
			*	Release the socket.
			*/
#ifdef DEBUG
	(void)fprintf(stdout,"mtm_skt_recv:*******Closing Client SD %d\n",client_routing->sd);
	(void)fflush(stdout);
#endif
			if((rc = close(client_routing->sd)) != SUCCESS)
			{
				MTM_EFD(errno);
			}
			(void)mtm_reset_client_data(client_routing);
			return ECONNRESET;
		}

		/*
		*	Other errors. Simply return FAILURE
		*/
		if (return_code)
			MTM_EFD(return_code);
		return FAILURE;
	}

	/*
	*	At this point, we have len_field defined
	*/
#ifdef DEBUG
	fprintf(stdout,"mtm_skt_recv: dumping message header\n");
	fflush(stdout);
	LV(header_size,len_field);
#endif

	msg_length = mtm_length (len_field, &MTMLength);

	/*
	*	Now, attempt to find the length of the entire message
	*/

	/* 
	 If we are in a standard bby MTM and the message approaches 64K, use special header format. 
	 At this time, only Big Endian is supported, because it is the default header format and the 
	 existing client tools all use Big Endian.
	*/
	if ((header_size==2) && (msg_length==0) && (MTMLength.format=='b')) 
	{
		int j;
		int len_length = 0;
		char len_read[256];

		sca_SetupTimer((void *)mtm_skt_recv, &MTMTimeout, (void *)mtm_alarm_catcher);
		
		/* Get next byte.  It will be the length of the length. */
		rc = sca_recv(client_routing->sd,
			len_read,
			1,
			0,
			&MTMTimeout,
			&return_code);

		sca_CancelTimer((void *)mtm_skt_recv, &MTMTimeout);

		if (rc <= 0) 
		{
			if ((return_code == ENOTCONN) || 
			    (return_code == ECONNRESET) ||
			    (return_code == ENOMSG) ||
			    (return_code == EWOULDBLOCK) ||
			    (rc == 0))
			{
				/*
				*	Disconnect has occurred.
				*	Release the socket.
				*/
				if((rc = close(client_routing->sd)) != SUCCESS)
				{
					MTM_EFD(errno);
				}
				(void)mtm_reset_client_data(client_routing);
				return ECONNRESET;
			}

			/*
			*	Other errors. Simply return FAILURE
			*/
			if (return_code)
				MTM_EFD(return_code);
			return FAILURE;
		}

		len_length = len_length << 8;
		len_length = len_length | (len_read[0] & 0xFF);

#ifdef DEBUG
	fprintf(stdout,"mtm_skt_recv: 64k section - len_length is %d\n",len_length);
	fflush(stdout);
#endif

		/* length of length equals zero.  error */
		/* if (len_length==0) break; */

		/* Now read the next len_length bytes for true message size. */

		memset(len_read,0,sizeof(len_read));

		sca_SetupTimer((void *)mtm_skt_recv, &MTMTimeout, (void *)mtm_alarm_catcher);
		
		rc = sca_recv(client_routing->sd,
			len_read,
			len_length,
			0,
			&MTMTimeout,
			&return_code);

		sca_CancelTimer((void *)mtm_skt_recv, &MTMTimeout);

		if (rc <= 0) 
		{
			if ((return_code == ENOTCONN) || 
			    (return_code == ECONNRESET) ||
			    (return_code == ENOMSG) ||
			    (return_code == EWOULDBLOCK) ||
			    (rc == 0))
			{
				/*
				*	Disconnect has occurred.
				*	Release the socket.
				*/
				if((rc = close(client_routing->sd)) != SUCCESS)
				{
					MTM_EFD(errno);
				}
				(void)mtm_reset_client_data(client_routing);
				return ECONNRESET;
			}

			/*
			*	Other errors. Simply return FAILURE
			*/
			if (return_code)
				MTM_EFD(return_code);
			return FAILURE;
		}
		msg_length=0;
		for (j = 0; j < len_length; j++)
		{
			msg_length = msg_length << 8;
			msg_length = msg_length | (len_read[j] & 0xFF);
		}
		/* Now remove the length of the length and 1 extra byte. Official header size (2) will be removed later. */
		msg_length=msg_length-len_length-1;
#ifdef DEBUG
	fprintf(stdout,"mtm_skt_recv: 64k section - msg_length is %d\n",msg_length);
	fflush(stdout);
#endif
			
	}

#ifdef DEBUG
	(void)fprintf(stdout,"mtm_skt_recv: Message length is %d\n",msg_length);
	(void)fflush(stdout);
#endif

	/*
	*	Return if message length is invalid
	*/
	if (msg_length < header_size)
	{
#ifdef DEBUG
	(void)fprintf(stdout,"mtm_skt_recv: Invalid message length %d, header length %d\n",msg_length, header_size);
	(void)fflush(stdout);
#endif
		return FAILURE;
	}

	/*
	*	Body size is msg_length - header_size
	*	Return if invalid body size
	*/
	body_size = msg_length - header_size;
	if (body_size <= 0)
	{
		/*
		*	An exception is made if we are in async mode.
		*	A message body of size 0 is thought as a
		*	heartbeat message. In that case, we should
		*	echo the heartbeat back to the client. The
		*	server does not have to know about the heartbeat.
		*/
		if ((MTMAsyncMode == TRUE) && (body_size == 0))
		{
			/* ding! ding! ding! ding! */
			if (MTMLogFp != NULL)
			{
				time(&cal_time);
				fprintf(MTMLogFp, "\nHeartbeat msg received\n");
				fprintf(MTMLogFp, "Current time: %s\n\n",
						  ctime(&cal_time));
				fflush(MTMLogFp);
			}

			/*
			*	Auto echo
			*/
			pHeader->return_code = SUCCESS;
			pHeader->reason_code = SUCCESS;
			pHeader->length = MTMLength.hsize;
			if(mtm_skt_send(msg) == FAILURE)
			{
				MTM_EFD(MTM_SEND_FAILED);
			}
		}
		else
		{
			if (MTMLogFp != NULL)
			{
				fprintf(MTMLogFp,"mtm_skt_recv: invalid message size from socket %d\n",client_routing->sd);
				fflush(MTMLogFp);
			}
		}
		return FAILURE;
	}

	/*
	*	If the length is embedded, keep the message intact by
	*	copying it to mtext. The message body can go in
	*	mtext[header_size]. Otherwise, the message body
	*	will start at mtext[0].
	*/
	ptr = mtext;
	if ((MTMLength.tcount != 0) || (MTMLength.lcount != 0))
	{
		memcpy(mtext, len_field, header_size);
		ptr = &mtext[header_size];
	}

	/*
	*	Now get the rest of the message off the socket
	*/
	MTMTimeout.value = MTM_DEFAULT_TIMEOUT;

	sca_SetupTimer((void *)mtm_skt_recv, &MTMTimeout, (void *)mtm_alarm_catcher);

	rc = sca_recv(client_routing->sd,
		ptr,
		body_size,
		0,
		&MTMTimeout,
		&return_code);

	sca_CancelTimer((void *)mtm_skt_recv, &MTMTimeout);

	if (rc <= 0) 
	{
#ifdef DEBUG
	fprintf(stdout,"mtm_skt_recv: failed to read message body\n");
	fprintf(stdout,"mtm_skt_recv: socket %d, rc %d, errno %d\n",client_routing->sd,rc,return_code);
	fflush(stdout);
#endif
		if ((return_code == ENOTCONN) || 
		    (return_code == ECONNRESET) ||
		    (return_code == ENOMSG) ||
		    (return_code == EWOULDBLOCK) ||
		    (rc == 0))
		{
			/*
			*	Disconnect has occurred.
			*	Release the socket.
			*/
#ifdef DEBUG
	(void)fprintf(stdout,"mtm_skt_recv:*******Closing Client SD %d\n",client_routing->sd);
	(void)fflush(stdout);
#endif
			if((rc = close(client_routing->sd)) != SUCCESS)
			{
				MTM_EFD(errno);
			}
			(void)mtm_reset_client_data(client_routing);
			return ECONNRESET;
		}

		/*
		*	Other errors. Simply return FAILURE
		*/
		if (return_code)
			MTM_EFD(return_code);
		return FAILURE;
	}

	/*
	*	At this point, we have ptr defined
	*/
#ifdef DEBUG
	fprintf(stdout,"mtm_skt_recv: dumping message body\n");
	fflush(stdout);
	LV(body_size,ptr);
#endif

	/*
	*	Client Message has been received.
	*	Setup message header.
	*	Send client msg to the Message Transport Manager.
	*/
	pHeader->sd = client_routing->sd;
	pHeader->port = client_routing->port;
	pHeader->mtm_process_id = MTMProcessId;

	/*
	*	Again, check for embedded length.
	*	If so, the message length will be msg_length.
	*	Otherwize, the message length will be body_size
	*/
	if ((MTMLength.lcount != 0) || (MTMLength.tcount !=0))
	{
		/*
		*	msg_length should equal header_size + body_size
		*	and that will be the final length
		*/
		if (msg_length != (header_size + body_size))
		{
			fprintf(stdout,"mtm_skt_recv: unmatched message length %d, header size %d, body size %d\n",msg_length, header_size, body_size);
			fflush(stdout);
			msg_length = header_size + body_size;
		}
	}
	else
	{
		msg_length = body_size;
	}

	/*
	*	Do we really need this terminator?
	*/
	ptr[msg_length] = '\0';

	if (MTMAsyncMode == TRUE)
	{
		/*
		*	Looks like we have to forward the client message
		*	to the server. If we can't find a suitable server,
		*	send an error message back to the client.
		*/
		pHeader->srv_type = mtm_find_any_server();
		if (pHeader->srv_type == FAILURE)
		{
			/* no server found - yuk!!! */
			pHeader->return_code = FAILURE;
			pHeader->reason_code = MTM_NO_ACTIVE_SRVS;
			if(mtm_skt_send(msg) == FAILURE)
			{
				MTM_EFD(MTM_SEND_FAILED);
			}
			MTM_EFD(MTM_NO_ACTIVE_SRVS);
			return FAILURE;
		}
	}
	else
	{
		/*
 		*	Parse the client message to get the server_type_name
 		*	and the message field which are separared by <FS>
 		*/
		for(i = 0; i < msg_length; i++)
		{
			if(ptr[i] == RECORD_DELIMITER)
				break;
		}

		/* 
 		*	if no server type field, or server type field too long,
		*	or server type field is null, return failure
 		*/
		if((i == msg_length) || (i > MAX_NAME_LEN) || (i <= 1))
		{
#ifdef DEBUG
	fprintf(stdout,"mtm_skt_recv: Invalid server type\n");
	fflush(stdout);
	LV(i, ptr);
#endif
			MTM_EFD(MTM_INVALID_MSG);
			return FAILURE;
		}

		/* 
 		*	Copy in the server type. Remember to terminate the string.
 		*/
		memcpy(server_type_name, ptr, i);
		server_type_name[i] = '\0';

		/*
		*	Now we have to shift (left) the message by i + 1 bytes.
		*	If we ever get a SIGSEGV, this would be the place to check!
		*/
		memmove(ptr, &ptr[i+1], msg_length);

		/*
		*	Do we have such server connected to MTM?
		*/
		pHeader->srv_type = mtm_get_server_type (server_type_name, FALSE);
		if (pHeader->srv_type == FAILURE)
		{
			pHeader->return_code = FAILURE;
			pHeader->reason_code = MTM_NO_ACTIVE_SRVS;
			if(mtm_skt_send(msg) == FAILURE)
			{
				MTM_EFD(MTM_SEND_FAILED);
			}
			MTM_EFD(MTM_NO_ACTIVE_SRVS);
			return FAILURE;
		}

		/*
		*	After stripping out the server type, the message
		*	length is now: msg_length - i - 1
		*	where i is the size of server type.
		*	Note: the - 1 is there to advance the pointer
		*	passed the <FS> character
		*	Check the message length again to make sure that
		*	we still have a valid message body.
		*/
		msg_length = msg_length - i - 1;
		if (msg_length < 1)
		{
#ifdef DEBUG
	fprintf(stdout,"mtm_skt_recv: Invalid final message length %d\n", msg_length);
	fflush(stdout);
#endif
			MTM_EFD(MTM_INVALID_MSG);
			return FAILURE;
		}
	}

	/*
	*	Set up the message for the server.
	*/
	pHeader->length = msg_length;
	client_routing->srv_type = pHeader->srv_type;

#ifdef DEBUG
	fprintf(stdout,"mtm_skt_recv: Received a valid client message\n");
	LV(msg_length,ptr);
	fflush(stdout);
#endif

	return SUCCESS;
}

/*
*	mtm_skt_send:
*	[module number i.e. Future] [module name]
*
*	Description:
*	This module sends a message on a socket.
*
*	Returns:
*	SUCCESS or FAILURE is the return value.
*/
RETURNSTATUS
mtm_skt_send(char *msg)
{
	RETURNSTATUS			rc = SUCCESS;
	register int 			i;
	char				*ptr;
	char				len_str[32];
	char				errmsg[MAX_ERR_MSG_LEN];
	MTM_MSG_HEADER			*pHeader;
	MTM_CLIENT_ROUTING_TABLE	*client_rt;
	SLONG				return_code;

	/*
	*	Check if message header is usable
	*/
	pHeader = (MTM_MSG_HEADER *)msg;
	if (pHeader == NULL)
	{
		MTM_EFD(EFAULT);
		return FAILURE;
	}

#ifdef DEBUG
	(void)fprintf(stdout,"mtm_skt_send: Client Sd %d\n",pHeader->sd);
	(void)fprintf(stdout,"mtm_skt_send: Return Code %d\n",pHeader->return_code);
	(void)fprintf(stdout,"mtm_skt_send: Reason Code %d\n",pHeader->reason_code);
	(void)fprintf(stdout,"mtm_skt_send: Client Port %d\n",pHeader->port); 
	(void)fflush(stdout);
#endif

	/*
	*	Can't send if socket is no good.
	*/
	if (pHeader->sd == DISCONNECTED)
	{
		MTM_EFD(ENOTCONN);
		return FAILURE;
	}

	/*
	*	Try to find the client table entry
	*/
	for(i=0;i<MTMMaxClient;i++)
	{
		/*
		*	Unique Client address consists of IP and port number
		*/
		if ((MTMRoutingTbl[i].port == pHeader->port) &&
			(MTMRoutingTbl[i].sd == pHeader->sd))
		{
			client_rt = &MTMRoutingTbl[i];
			break;
		}
	}

	/*
	*	Log an error and return if we can't find it
	*/
	if(i == MTMMaxClient)
	{
		MTM_EFD(ECONNRESET);
		return FAILURE;
	}

	/*
	*	Init error message
	*/
	memset(errmsg,0,sizeof(errmsg));

	/*
	*	Are we returning a real reply or just an error message?
	*/
	if (pHeader->return_code == FAILURE)
	{
		/*
		*	Format error message. We can format other types
		*	of error message here.
		*/
		switch (pHeader->reason_code)
		{
			case MTM_NO_ACTIVE_SRVS:
				sprintf(errmsg, "1%s", MTM_NO_SRV_TYPE_STR);
				break;
			default:
				errmsg[0] = '1';
				break;
		}
		pHeader->length = MTMLength.hsize + strlen (errmsg);
		ptr = msg + sizeof (MTM_MSG_HEADER);
		mtm_slength(len_str,(SLONG)pHeader->length,&MTMLength);
		memcpy(ptr, len_str, MTMLength.hsize);
		ptr += MTMLength.hsize;
		strcpy (ptr, errmsg);
	}

	/*
	*	Dump the message we are about to send to the client.
	*/
#ifdef DEBUG
	fprintf(stdout,"mtm_skt_send: ready to send message to client socket %d\n",pHeader->sd);
	LV(pHeader->length, msg+sizeof(MTM_MSG_HEADER)); 
	(void)fflush(stdout);
#endif

	/*
	*	Set the timer here
	*/
	MTMTimeout.value = 10;

	sca_SetupTimer((void *)mtm_skt_send, &MTMTimeout, (void *)mtm_alarm_catcher);

	/*
	*	Send the message to the client
	*/
	rc = sca_send(pHeader->sd,
			(char *)(msg+sizeof(MTM_MSG_HEADER)),
			pHeader->length,
			(int)0,
			&MTMTimeout,
			&return_code);

#ifdef DEBUG
	(void)fprintf(stdout,"mtm_skt_send: sca_send result = %d\n",rc);
	(void)fprintf(stdout,"mtm_skt_send: sca_send return_code = %d\n",return_code);
	fflush(stdout);
#endif
	/*
	*	Cancel the timer here
	*/
	sca_CancelTimer((void *)mtm_skt_send, &MTMTimeout);

	/*
	*	Check for error
	*/
	if (rc <= 0)
	{
#ifdef DEBUG
	fprintf(stdout,"mtm_skt_send: failed to send message to client\n");
	fprintf(stdout,"mtm_skt_send: socket %d, rc %d, errno %d\n",pHeader->sd,rc,return_code);
	fflush(stdout);
#endif
		if ((return_code == ENOTCONN) || 
		    (return_code == ECONNRESET) ||
		    (return_code == ENOMSG) ||
		    (return_code == EWOULDBLOCK) ||
		    (rc == 0))
		{
			/*
			*	Disconnect has occurred.
			*	Release the socket.
			*/
#ifdef DEBUG
	(void)fprintf(stdout,"mtm_skt_send:*******Closing Client SD %d\n",pHeader->sd);
	(void)fflush(stdout);
#endif
			if((rc = close(pHeader->sd)) != SUCCESS)
			{
				MTM_EFD(errno);
			}
			(void)mtm_reset_client_data(client_rt);
			return ECONNRESET;
		}

		/*
		*	Other errors. Simply return FAILURE
		*/
		MTM_EFD(return_code);
		return FAILURE;
	}

	/*
	*	All done - no error
	*/
	return SUCCESS;
}

/*
*	mtm_reset_client_data
*	[module number i.e. Future] [module name]
*
*	Description:
*	Set client table data to default when a disconnect occurs.
*
*	Returns:
*	SUCCESS or FAILURE
*/
static void
mtm_reset_client_data(MTM_CLIENT_ROUTING_TABLE *client_rt)
{
	MTM_CLIENT_TABLE * client_srv= (MTM_CLIENT_TABLE *)NULL;

	/*
	*	Check if input is usable
	*/
	if (client_rt == NULL)
	{
		MTM_EFD(EFAULT);
		return;
	}

	if (client_rt->srv_type != DISCONNECTED)
	{
		if(MTMSrvTbl[client_rt->srv_type].current_client_connects)
			MTMSrvTbl[client_rt->srv_type].current_client_connects--;
		if (client_rt->cl_tbl_index != DISCONNECTED)
		{
			/*
			*	Clear out the entry for this client in the 
			*	server client table.
			*/
			client_srv = 
				&MTMSrvTbl[client_rt->srv_type].cl_tbl[client_rt->cl_tbl_index];
			/*
			*	Check if table entry is usable
			*/
			if (client_srv == NULL)
			{
				MTM_EFD(EFAULT);
				return;
			}
			client_srv->state = DISCONNECTED;
			client_srv->time_connected = 0;
			client_srv->ip_address[0] = '\0';
			client_srv->sd = DISCONNECTED;
			client_srv->port = DISCONNECTED;
			client_srv->srv_pid = 0;
			client_srv->recv_time = 0;
			client_srv->microsecs_recv_time = 0;
			client_srv->total_resp_time = 0;
			client_srv->min_resp_time = MIN_RESP_DEFAULT;
			client_srv->max_resp_time = 0;
			client_srv->reqst_msgs = 0;
			client_srv->resp_msgs = 0;
		}
	}

   	/*
   	*	Initialize Client Routing Information to default state.
   	*/
	FD_CLR(client_rt->sd,&MTMReadMask);
	client_rt->sd = DISCONNECTED;
	client_rt->port = DISCONNECTED;
	client_rt->srv_type = DISCONNECTED;
	client_rt->cl_tbl_index = DISCONNECTED;
	client_rt->time_connected = 0;
	client_rt->ip_address[0] = '\0';

	return;
}

void
mtm_alarm_catcher(int sig)
{
/*
#ifdef DEBUG
	fprintf(stdout,"mtm_alarm_catcher: mtm PID %d caught signal %x\n",getpid(),sig);
	fflush(stdout);
#endif
*/
	MTMTimeout.flag = 1;
}






/*
*	add_tcp_client
*
*	Add a tcp client to the MTMTcpClient array
*	Input parameter has this format:
*	nnn.nnn.nnn.nnn/pppp/llll/rrr
*	where nnn.nnn.nnn.nnn is the host address in dot notation,
*	pppp is the port number
*	llll is the length format
*	rrr is the repeat count
*/
void
add_tcp_client(char *param)
{
	char		hostAddress[32];
	char		lengthFormat[32];
	int		portNumber,repeatCount,index;
	st_tcpclient	*temp;

#ifdef DEBUG
	fprintf(stdout,"add_tcp_client: current tcp client count is %d\n",MTMTcpCount);
	fflush(stdout);
#endif

	/*
	*	Allocate memory for TCP client structure
	*/
	temp = (st_tcpclient *)malloc(sizeof(st_tcpclient));
	if (temp == NULL)
	{
		MTM_EFD(errno);
		return;
	}

	/*
	*	Initialize new memory block 
	*/
	memset(temp,0,sizeof(st_tcpclient));
	memset(hostAddress,0,sizeof(hostAddress));
	memset(lengthFormat,0,sizeof(lengthFormat));

	/*
	*	Parse the input param
	*/
	sscanf(param, "%[^/]/%d/%[^/]/%d", 
			hostAddress,
			&portNumber,
			lengthFormat,
			&repeatCount);

	/*
	*	Repeat count should not be > 32 because we only allocate
	*	an array of 32 socket in st_tcpclient. This limit could
	*	be changed later to accomodate more tcp client per host.
	*/
	if (repeatCount > MAX_TCP_CLIENT_SOCKETS)
		repeatCount = MAX_TCP_CLIENT_SOCKETS;

	/*
	*	Set value in new memory block
	*/
	strcpy(temp->hostAddr,hostAddress);
	parse_length(lengthFormat,&temp->length);
	temp->portNum = portNumber;
	temp->maxSd = repeatCount;
	temp->usedSd = 0;
	temp->next = (st_tcpclient *)NULL;
	for (index = 0; index < temp->maxSd; index++)
	{
		temp->clientSd[index] = MTMTcpCount++;
	}

	/*
	*	Insert the new memory block in MTMTCPClient in an
	*	unsorted order.
	*/
	if (MTMTcpClient == (st_tcpclient *)NULL)
		MTMTcpClient = temp;
	else
	{
		temp->next = MTMTcpClient;
		MTMTcpClient = temp;
	}

#ifdef DEBUG
	fprintf(stdout,"add_tcp_client: added client with the following parameters:\n");
	fprintf(stdout,"\t host IP address %s\n",temp->hostAddr);
	fprintf(stdout,"\t port number %d\n",temp->portNum);
	fprintf(stdout,"\t format %c\n",temp->length.format);
	fprintf(stdout,"\t header %c\n",temp->length.header);
	fprintf(stdout,"\t lsize %d\n",temp->length.lsize);
	fprintf(stdout,"\t hsize %d\n",temp->length.hsize);
	fprintf(stdout,"\t lcount %d\n",temp->length.lcount);
	fprintf(stdout,"\t tcount %d\n",temp->length.tcount);
	fprintf(stdout,"\t rcount %d\n",temp->maxSd);
	fflush(stdout);
#endif 
	return;
}




/*
*	tcp_client_connect
*
*	Connects as tcp client.
*
*/
void tcp_client_connect()
{
	int			clientSd, return_code, index, xref;
	char			*ip_address;
	struct sockaddr_in	client_addr;
	struct timeval		time_val;
	struct timezone		time_zone;
	st_tcpclient		*temp;
	char			Msg[MTM_MAXCTRLMSGSIZE];
	char			buffer[200];
	int			msglen = 0;
	int			rc = 0;

#ifdef DEBUG
	fprintf(stdout,"tcp_client_connect: Start of routine\n");
	fflush(stdout);
#endif

	temp = MTMTcpClient;

	/*
	*	Loop thru all possible tcp clients.
	*/
	while (temp != (st_tcpclient *)NULL)
	{
	    /*
	     *	Do a client connect if the current client slot
	     *	has a valid host address and no socket allocated
	     *	to it yet.
	     */
	    if (temp->hostAddr != (char *)NULL)
	    {
		/*
	 	 *	Initialize client address structure
		 */
		memset((char *)&client_addr, 0, sizeof(client_addr));
		client_addr.sin_family = AF_INET;
		client_addr.sin_port = temp->portNum;
		client_addr.sin_addr.s_addr = inet_addr(temp->hostAddr);
		memset(client_addr.sin_zero,0,8);

		/*
		 *	Check individual slot to see if it's connected.
		 */
		for (index = 0; index < temp->maxSd; index++)
		{
		    xref = temp->clientSd[index];
		    if (MTMRoutingTbl[xref].sd == DISCONNECTED)
		    {
			/*
			 *	Set up timer here
			 */
			MTMTimeout.value = MTM_DEFAULT_TIMEOUT;
			sca_SetupTimer((void *)tcp_client_connect, &MTMTimeout, (void *)mtm_alarm_catcher);

			/*
			 *	Perform the connect() call
			 */
			clientSd = sca_connect( (void *)&client_addr, 
						sizeof (struct sockaddr_in),
						&MTMTimeout,
						&return_code);

			/*
			 *	Cancel the timer here
			 */
			sca_CancelTimer((void *)tcp_client_connect,&MTMTimeout);

			/*
			 *	Check for error.
			 */
			if (return_code != SUCCESS)
			{
#ifdef DEBUG
	fprintf(stdout,"tcp_client_connect: failed to connect to host %s, port %d, return code %d\n",temp->hostAddr,temp->portNum,return_code);
	fflush(stdout);
#endif
			    MTM_EFD(return_code);
			    if (clientSd != DISCONNECTED)
				close(clientSd);
			}
			else
			{
#ifdef DEBUG
	fprintf(stdout,"tcp_client_connect: connected to host %s, port %d, socket %d\n",temp->hostAddr,temp->portNum,clientSd);
	fflush(stdout);
#endif
			    /*
			     *	Save connection info
			     */
			    MTMRoutingTbl[xref].sd = clientSd;
			    MTMRoutingTbl[xref].port = client_addr.sin_port;
			    ip_address = inet_ntoa(client_addr.sin_addr);
			    memcpy(MTMRoutingTbl[xref].ip_address,
				   ip_address,IP_ADDR_LEN);
			    gettimeofday(&time_val, &time_zone);
			    MTMRoutingTbl[xref].time_connected = time_val.tv_sec;

			    /*
			     *	Set read mask
			     */
			    FD_SET(clientSd,&MTMReadMask);

			    /*
			     * Send a message to the server
			     */
			    if (msgflag == 1)
			    {
				FILE * MTMMsgFP;
				MTMMsgFP = fopen(MTMMsgFileName,"r");
				for (;;)
				{
				    memset(buffer,0,200);
				    if (fgets(buffer,200,MTMMsgFP) == NULL)
					break;
				    msglen += strlen(buffer);
				    memcpy(Msg,buffer,strlen(buffer));
				}
				fclose(MTMMsgFP);
				/*
				 *       Set up the timer here
				 */
				MTMTimeout.value = 10;
				sca_SetupTimer((void *)tcp_client_connect, &MTMTimeout, (void *)mtm_alarm_catcher);
				/*
				 *       Send message
				 */
				rc = sca_msgsnd(MTMSrvTbl[0].server_type_qid,
						(struct msgbuf *)Msg,
						msglen,
						(int)0,
						&MTMTimeout,
						&return_code);
				/*
				 *       Cancel the timer here
				 */
				sca_CancelTimer((void *)tcp_client_connect, &MTMTimeout);
			    }
			}
		    }
		} /* end of for loop */
	    }
		temp = temp->next;
	} /* end of while loop */

#ifdef DEBUG
	fprintf(stdout,"tcp_client_connect: End of routine\n");
	fflush(stdout);
#endif

	return;
}


/*
*	tcp_client_disconnect
*
*	Disconnects a tcp client.
*
*/
void tcp_client_disconnect()
{
	int		index,xref;
	st_tcpclient	*temp;

#ifdef DEBUG
	fprintf(stdout,"tcp_client_disconnect: Start of routine\n");
	fflush(stdout);
#endif

	temp = MTMTcpClient;

	while (temp != (st_tcpclient *)NULL)
	{
		if (temp->hostAddr != (char *)NULL)
		{
			for (index = 0; index < temp->maxSd; index++)
			{
				xref = temp->clientSd[index];
				/*
				*	Do a client disconnect if the socket is
				*	allocated.
				*/
				if (MTMRoutingTbl[xref].sd != DISCONNECTED)
				{
					close(MTMRoutingTbl[xref].sd);
					mtm_reset_client_data(&MTMRoutingTbl[xref]);
				}
			}
		}
		temp = temp->next;
	}

#ifdef DEBUG
	fprintf(stdout,"tcp_client_disconnect: End of routine\n");
	fflush(stdout);
#endif

	return;
}





/*
*	mtm_pause
*	[module number i.e. Future] [module name]
*
*	Description:
*	Pauses (giving up CPU) until select event occurs or
*	Interrupt occurs.
*
*	Returns:
*	void
*/
void
mtm_pause()
{
	RETURNSTATUS 	rc = SUCCESS;
	register int	i = 0;
	char		msg_flag[MTM_MSG_FLAG_SIZE];
	int		client_count, max_desc;
	SLONG		return_code;
	static int	disable_flag = FALSE;

#ifdef DEBUG
	fprintf(stdout,"mtm_pause: Start of routine\n");
	fflush(stdout);
#endif

	/*
	*   Pause until select event occurs or an interrupt occurs.
	*/
	FD_ZERO(&MTMReadMask);

	/*
	*
	*/

	/*
	*	Did we reach the limit?
	*/
	client_count = connected_clients();
	if (client_count >= MTMMaxClient)
	{
		/*
		*	Don't listen for connection request anymore
		*/
		if (disable_flag == FALSE)
		{
			if ((rc = mtm_disable_sd()) == SUCCESS)
			{
				disable_flag = TRUE;
			}
			else
			{
				rc = mtm_enable_sd();
			}
		}
		max_desc = 0;
	}
	else
	{
		if (disable_flag == TRUE)
		{
			/*
			*	Try to enable the socket
			*/
			if ((rc = mtm_enable_sd()) == SUCCESS)
			{
				disable_flag = FALSE;
			}
		}
		FD_SET(MTMListenSd,&MTMReadMask);
		max_desc = MTMListenSd;
	}

	/*
	*	Always listen on fifo file
	*/
	FD_SET(MTMFifoFd,&MTMReadMask);
	max_desc = MAX(max_desc, MTMFifoFd);

	/*
	*	Always listen on connected sockets
	*/
	for(i=0;i<MTMMaxClient;i++)
	{
		if(MTMRoutingTbl[i].sd != DISCONNECTED)
		{
			FD_SET(MTMRoutingTbl[i].sd,&MTMReadMask);
			max_desc = MAX(max_desc, MTMRoutingTbl[i].sd);
		}
	}

	/*
	*	clear non blocking bit
	*/
	mtm_fcntl (MTMFifoFd, O_NDELAY, 0);

	/*
	*	Set up timer here
	*/
	MTMTimeout.value = MTM_DEFAULT_TIMEOUT;

	sca_SetupTimer((void *)mtm_pause, &MTMTimeout, (void *)mtm_alarm_catcher);

	rc = sca_select(max_desc + 1,
			(fd_set *) &MTMReadMask,
 			(fd_set *) NULL,
 			(fd_set *) NULL,
			&MTMTimeout,
			&return_code);

	/*
	*	Cancel the timer here
	*/
	sca_CancelTimer((void *)mtm_pause, &MTMTimeout);

	/*
	*	Return if error or no activities
	*/
	if (rc <= 0)
	{
		if (return_code != ETIME)
		{
			MTM_EFD(return_code);
		}
		return;
	}

	/*
	*	Categorize activities
	*/
	if(FD_ISSET(MTMListenSd, &MTMReadMask))
		MTMSignalFlags.connection_reqst = TRUE;

	if (FD_ISSET(MTMFifoFd, &MTMReadMask))
	{
		/*
		*	set non blocking bit
		*/
		mtm_fcntl (MTMFifoFd, O_NDELAY, 1);

		while ((rc = read (MTMFifoFd,msg_flag,MTM_MSG_FLAG_SIZE)) > SUCCESS)
		{
			if (!strncmp(msg_flag, MTM_CONTROL_MSG_FLAG, MTM_MSG_FLAG_SIZE))
			{
				MTMSignalFlags.cntrl_msg++;
			}
			else
			if (!strncmp(msg_flag, MTM_REPLY_MSG_FLAG, MTM_MSG_FLAG_SIZE))
			{
				MTMSignalFlags.server_msg++;
			}
			else
				MTM_EFD (MTM_INVALID_CMD);
		}

                if (rc < SUCCESS)
                {
                        /*
                        *       On the Linux i386, we receive error 11 when
                        *       the fifo file is empty. It's not really a
                        *       valid error since there is nothing in
                        *       the fifo file for us to read. If we print
                        *       an error here, it's very misleading.
                        */
                        if (errno != EAGAIN)
                                MTM_EFD (errno);
                }
	}

	for(i=0;i<MTMMaxClient;i++)
	{
		if(MTMRoutingTbl[i].sd != DISCONNECTED)
		{
#ifdef DEBUG
	(void)fprintf(stdout,"mtm_pause: MTMRoutingTbl[%d].sd %d\n",i,MTMRoutingTbl[i].sd);
	(void)fflush(stdout);
#endif
   			if(FD_ISSET(MTMRoutingTbl[i].sd,&MTMReadMask))
				MTMSignalFlags.client_msg = TRUE;
		}
	}

#ifdef DEBUG
	fprintf(stdout,"mtm_pause: end of routine\n");
	fflush(stdout);
#endif

	return;
}
