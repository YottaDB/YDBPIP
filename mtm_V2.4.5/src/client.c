/*
*	   client.c - Sanchez Message Transport Client API for UNIX
*
*	   Copyright(c)1992 Sanchez Computer Associates, Inc.
*	   All Rights Reserved
*
*	   ORIG:   Sara G. Walters - xx Jan 1995
*
*	   DESC:   This routine is the Sanchez proprietary UNIX
*
*
*   $Id: client.c,v 1.1 2000/06/01 00:45:35 lyh Exp lyh $
*   $Log:	client.c,v $
 * Revision 2.10  07/01/29  thoniyim ()
 * Modified ClSendMsg() to return the error EFBIG when the request
 * length is greater than MAX_MSG_SIZE
 *
 * Revision 2.9  04/08/17  yurkovicg ()
 * Modified ClGetMsg and ClSendMsg to support >64K messages
 * in a bby MTM.
 *
 * Revision 2.8  00/06/02  13:16:58  13:16:58  lyh ()
 * Changes as a result of porting to other platforms.
 * 
 * Revision 2.7  00/05/04  14:50:37  14:50:37  lyh ()
 * include memory.h for memset() call
 * 
 * Revision 2.6  00/05/04  14:43:46  14:43:46  lyh ()
 * init string cLength in connect section
 * 
 * Revision 2.5  00/03/29  09:34:12  09:34:12  lyh ()
 * Changed length format to pattern matching instead of using option
 * 
 * Revision 2.4  00/03/27  15:55:04  15:55:04  lyh ()
 * wogm release
 * 
 * Revision 2.3  00/03/03  15:07:19  15:07:19  lyh ()
 * Use a common alarm routine
 * 
 * Revision 2.2  00/01/20  13:23:28  13:23:28  lyh ()
 * added client get and send message apis
 * 
 * Revision 2.1  00/01/17  11:16:06  11:16:06  lyh ()
 * storm trooper release
 * 
 * Revision 1.1  00/01/17  11:02:31  11:02:31  lyh ()
 * Initial revision
 * 
 * Revision 1.7  96/04/10  17:20:16  17:20:16  zengf (Fan Zeng)
 * General cleaning up
 * 
 * Revision 1.6  96/03/13  10:03:25  10:03:25  zengf (Fan Zeng)
 * prepare for removing signals
 * 
 * Revision 1.5  96/02/28  17:30:54  17:30:54  zengf (Fan Zeng)
 * Substantially rewrite the APIs
 * 
 * Revision 1.4  95/08/11  14:39:17  14:39:17  rcs ()
 * Final bug fixes
 * 
 * Revision 1.3  95/07/19  14:30:57  14:30:57  rcs ()
 * Bug Fixes as a result of MTM System Test
 * 
 * Revision 1.2  95/05/22  14:52:35  14:52:35  sca ()
 * sgI VMS
 * 
*   $Revision: 2.8 $
*
*/

#include		<ctype.h>
#include		<stdio.h>
#include		<errno.h>
#include		<time.h>
#include		<stdlib.h>
#include		<sys/socket.h>
#include		<sys/types.h>
#include		<sys/select.h>
#include    		<signal.h>
#include    		<sys/ipc.h>
#include		<netinet/in.h>
#include		<netdb.h>
#include		<memory.h>
#include		<scatype.h>
#include		<mtm.h>
#include		<mtmapi.h>

/*
*	timer related functions
*/
extern void sca_SetupTimer(void *, st_timeout *, void *);
extern void sca_CancelTimer(void *, st_timeout *);
extern int sca_AlarmSetup(int);

/*
*	socket related functions
*/
extern int sca_send(SLONG, char *, size_t, int, st_timeout *, SLONG *);
extern int sca_recv(SLONG, char *, size_t, int, st_timeout *, SLONG *);
extern SLONG sca_connect(void *, size_t, st_timeout *, SLONG *);

/*
*	   Declare Statics for the Message Transport Client API
*/
SLONG		MTMClientSd = DISCONNECTED;
char		*ClMsgBuffer = (char *)NULL;
void		cl_signal_catcher(int);
st_length	ClLength;
st_timeout	ClTimeout;

/*
*	   ClConnect:
*
*	   Description:
*	   $ZCall to allow a PROFILE MUMPS client process to connect to a
*	   UNIX Message Transport Monitor on a remote host.
*
*/
void
ClConnect(int count,char *addr,SLONG *return_code)
{
	RETURNSTATUS		rc = SUCCESS;
	struct sockaddr_in	client_addr;
	char			server_ip_address[IP_ADDR_LEN+1];
	short			server_port;
	char			cLength[32];
	int			iSize = 0, iOffset = 0;
	char			cFormat = '\0';
	char			cHeader = '\0';

	*return_code = SUCCESS;

#ifdef DEBUG
	(void)fprintf(stdout,"CLIENT CONNECT:\n");
	(void)fflush(stdout);
#endif

	/*
	*	Set up timer functions
	*/
	ClTimeout.type = sca_AlarmSetup(1);

	/*
	*	Check if client is already connected. If so, disconnect then
	*	re-connect.
	*/
	if(MTMClientSd != DISCONNECTED)
	{
		MTM_LOG(EISCONN);
		(void)close(MTMClientSd);
	}

	/*
	*	   Initialize to defaults.
	*/
	MTMClientSd = DISCONNECTED;
	memset(cLength,0,sizeof(cLength));
	sscanf(addr, "%[^/]/%hd/%s", server_ip_address, &server_port, cLength);

	/*
	*	Parse the length
	*/
	if (parse_length(cLength,&ClLength) == FAILURE)
	{
		*return_code = EINVAL;
		MTM_LOG(*return_code);
		return;
	} 
	
	memset((char *)&client_addr, 0, sizeof(client_addr));
	client_addr.sin_family = AF_INET;
	client_addr.sin_port = htons(server_port);
	client_addr.sin_addr.s_addr = inet_addr(server_ip_address);
	memset(client_addr.sin_zero,0,8);

#ifdef DEBUG
	(void)fprintf(stdout,"\tPort %d\n",client_addr.sin_port);
	(void)fprintf(stdout,"\tIP Address %s\n",server_ip_address);
	(void)fprintf(stdout,"\tLength Format: %c\n",ClLength.format);
	(void)fprintf(stdout,"\tLength Header: %c\n",ClLength.header);
	(void)fprintf(stdout,"\tLength Size: %d\n",ClLength.lsize);
	(void)fprintf(stdout,"\tHeader Size: %d\n",ClLength.hsize);
	(void)fprintf(stdout,"\tLeading Count: %d\n",ClLength.lcount);
	(void)fprintf(stdout,"\tTrailing Count: %d\n",ClLength.tcount);
	(void)fflush(stdout);
#endif

	/*
 	*	Allocate memory for client message buffer
 	*/
	if (ClMsgBuffer == NULL)
		ClMsgBuffer = (char *) malloc (MAX_MSG_SIZE);
	if (ClMsgBuffer == NULL)
	{
		MTM_LOG (errno);
		*return_code = errno;
		return;
	}

	/*
	*	Get a properly connected socket
	*/
	ClTimeout.value = 10;

	sca_SetupTimer((void *)ClConnect, &ClTimeout, (void *)cl_signal_catcher);

	MTMClientSd = sca_connect((void *)&client_addr,
				sizeof(struct sockaddr_in),
				&ClTimeout,
				return_code);

	sca_CancelTimer((void *)ClConnect, &ClTimeout);

	/*
	*	Close socket and release memory if there were any errors.
	*/
	if (*return_code != SUCCESS)
	{
		MTM_LOG(*return_code);

		if (MTMClientSd != DISCONNECTED)
		{
			close(MTMClientSd);
			MTMClientSd = DISCONNECTED;
		}
		if (ClMsgBuffer)
		{
			free(ClMsgBuffer);
			ClMsgBuffer = NULL;
		}
	}

#ifdef DEBUG
	(void)fprintf(stdout,"ClConnect: Socket Descriptor = %d\n",MTMClientSd);
	(void)fflush(stdout);
#endif

	return;
}

/*
*	   ClDisconnect:
*
*	   Description:
*	   $ZCall to allow a PROFILE MUMPS client process to disconnect from a
*	   UNIX Message Transport Monitor on a remote host.
*
*/
void
ClDisconnect(int count,SLONG *return_code)
{
	RETURNSTATUS	rc = SUCCESS;

	*return_code = SUCCESS;

#ifdef DEBUG
	(void)fprintf(stdout,"CLIENT DISCONNECT:\n");
	(void)fflush(stdout);
#endif

	if(MTMClientSd == DISCONNECTED)
	{
		MTM_LOG(ENOTCONN);
		*return_code = ENOTCONN;
		return;
	}

	if(ClMsgBuffer != (char *)NULL)
		free (ClMsgBuffer);
	ClMsgBuffer = NULL;

	if((rc = close(MTMClientSd)) == FAILURE)
	{
		MTM_LOG(errno);
		*return_code = errno;
		return;
	}

#ifdef DEBUG
	(void)fprintf(stdout,"Client %d is Disconnected\n",MTMClientSd);
	(void)fflush(stdout);
#endif

	MTMClientSd = DISCONNECTED;

	return;
}

/*
*	   ClExchmsg:
*
*	   Description:
*	   $ZCall to allow a PROFILE MUMPS client process to exchange
*	   (i.e. send/recv) a message between a client and a server.
*
*/
void
ClExchmsg(	int count,
			STR_DESCRIPTOR *request,
			STR_DESCRIPTOR *reply,
			SLONG timeout,
			SLONG *return_code)
{
	*return_code = SUCCESS;

	ClSendMsg(count, request, timeout, return_code);
	if (*return_code != SUCCESS)
		return;

	ClGetMsg(count, reply, timeout, return_code);

	return;
}

/*
*	   ClSendMsg:
*
*	   Description:
*	   $ZCall to allow a PROFILE MUMPS client process to send
*	   a message between a client and a server.
*
*/
void
ClSendMsg(	int count,
		STR_DESCRIPTOR *request,
		SLONG timeout,
		SLONG *return_code)
{
	RETURNSTATUS	rc = SUCCESS;
	char		len_field[32]; /* a reasonable string length */
	SLONG		msg_length = 0;
	char		*ptr = (char *)NULL;

	if(MTMClientSd == DISCONNECTED)
	{
		MTM_LOG(ENOTCONN);
		*return_code = ENOTCONN;
#ifdef DEBUG
	(void)fprintf(stdout,"ClSendMsg: ENOTCONN\n");
	(void)fflush(stdout);
#endif
		return;
	}

	if (request->length > MAX_MSG_SIZE)
	{
		*return_code = EFBIG;
		MTM_LOG(*return_code);
		return;
	}

	if (ClMsgBuffer == NULL)
		ClMsgBuffer = (char *) malloc (MAX_MSG_SIZE);
	if (ClMsgBuffer == NULL)
	{
		MTM_LOG (errno);
		*return_code = errno;
		return;
	}
	if ((ClLength.lcount == 0) && (ClLength.tcount == 0))
	{
		/*
		*	Build the length before the start of message
		*/
		int len_length;
		
		msg_length = request->length+ClLength.hsize;

		/* 
		 If we are in a standard bby MTM and the message approaches 64K, use special header format. 
		 At this time, only Big Endian is supported, because it is the default header format and the 
		 existing client tools all use Big Endian.
		*/
		if ((ClLength.hsize==2) && (msg_length>65530) && (ClLength.format=='b'))
		{
			/* We don't know entire msg length until header is constructed. */
			msg_length = request->length;
			len_length=mtm_s64klength(len_field, msg_length, &ClLength);
			msg_length+=len_length;
#ifdef DEBUG
	(void)fprintf(stdout,"ClSendMsg: After call to s64k, msg_length is %d and len_length is %d\n",msg_length,len_length);
	(void)fflush(stdout);
#endif
		}
		else 
		{
			msg_length = request->length+ClLength.hsize;
			mtm_slength(len_field, msg_length, &ClLength);
			len_length = ClLength.hsize;
		}

		memcpy(ClMsgBuffer, len_field, len_length);
		(void)memcpy((char *)&ClMsgBuffer[len_length],request->str,msg_length);	
	}
	else
	{
		/*
		*	Length is built in to message
		*/
		msg_length = request->length;
		memcpy(ClMsgBuffer,request->str,msg_length);	
	}

	ptr = ClMsgBuffer;
	ClTimeout.value = timeout;

#ifdef DEBUG
	(void)fprintf(stdout,"ClSendMsg: Send Message\n");
	LV(msg_length, ptr);
	(void)fflush(stdout);
#endif

	sca_SetupTimer((void *)ClSendMsg, &ClTimeout, (void *)cl_signal_catcher);

	rc = sca_send(  MTMClientSd,
					ptr,
					msg_length,
					(int)NULL, &ClTimeout, return_code);

	sca_CancelTimer((void *)ClSendMsg, &ClTimeout);

	if (rc <= 0)
	{
#ifdef DEBUG
	(void)fprintf(stdout,"ClExchmsg: Send errno %d\n",*return_code);
	(void)fflush(stdout);
#endif
		MTM_LOG(*return_code);
	}

	return;
}

/*
*	   ClGetMsg:
*
*	   Description:
*	   $ZCall to allow a PROFILE MUMPS client process to exchange
*	   (i.e. send/recv) a message between a client and a server.
*
*/
void
ClGetMsg(	int count,
			STR_DESCRIPTOR *reply,
			SLONG timeout,
			SLONG *return_code)
{
	RETURNSTATUS	rc = SUCCESS;
	char		len_field[32]; /* a reasonable string length */
	SLONG		msg_length = 0;
	SLONG		bytes_recv = 0;
	SLONG		recv_flags = 0;
	char		*ptr = (char *)NULL;
	char		no_srv_str [MAX_NAME_LEN + 1];
	int		header_size;
	int		len_length = 0;
	int		extended_hdr_flg=0;

	if(MTMClientSd == DISCONNECTED)
	{
		MTM_LOG(ENOTCONN);
		*return_code = ENOTCONN;
		return;
	}

	if (ClMsgBuffer == NULL)
		ClMsgBuffer = (char *) malloc (MAX_MSG_SIZE);
	if (ClMsgBuffer == NULL)
	{
		MTM_LOG (errno);
		*return_code = errno;
		return;
	}

	ClTimeout.value = timeout;

	/*
	*	First, peek for the message size
	*/
	sca_SetupTimer((void *)ClGetMsg, &ClTimeout, (void *)cl_signal_catcher);

	header_size = ClLength.hsize;

	rc = sca_recv(MTMClientSd,
			     len_field,
			     header_size,
			     MSG_PEEK, &ClTimeout, return_code);

	sca_CancelTimer((void *)ClGetMsg, &ClTimeout);

	if (rc<=0) 
	{
#ifdef DEBUG
	fprintf(stdout,
		"ClExchmsg: message header sca_recv rc %d errno %d\n",rc,*return_code);
	(void)sca_fflush(stdout);
#endif
		MTM_LOG(*return_code);
		if ((*return_code == ENOTCONN) || 
		    (*return_code == ECONNRESET) ||
		    (*return_code == ENOMSG) ||
		    (*return_code == EWOULDBLOCK))
		{
#ifdef DEBUG
	fprintf(stdout,
		"ClExchmsg: Disconnect occurred - current socket will be closed\n");
	(void)sca_fflush(stdout);
#endif
			/*
			*	Disconnect has occurred.
			*	Release the socket.
			*/
			(void)close(MTMClientSd);
			MTMClientSd = DISCONNECTED;
		}
		return;
	}

	msg_length = mtm_length (len_field, &ClLength);

	/* 
	 If we are in a standard bby MTM and the message approaches 64K, use special header format. 
	 At this time, only Big Endian is supported, because it is the default header format and the 
	 existing client tools all use Big Endian.
	*/
	if ((header_size==2) && (msg_length==0) && (ClLength.format=='b')) 
	{
		int j;
		char len_read[256];

		/* Using non-standard header format within bby MTM. */
		extended_hdr_flg=1;
		sca_SetupTimer((void *)ClGetMsg, &ClTimeout, (void *)cl_signal_catcher);
		
		/* Get next byte.  It will be the length of the length. */
		/* However, the last read was non-destructive, thus we need to grab 3 bytes total */
		rc = sca_recv(MTMClientSd,
			len_read,
			3,
			MSG_PEEK,
			&ClTimeout,
			return_code);

		sca_CancelTimer((void *)ClGetMsg, &ClTimeout);

		if (rc <= 0) 
		{
			if ((*return_code == ENOTCONN) || 
			    (*return_code == ECONNRESET) ||
			    (*return_code == ENOMSG) ||
			    (*return_code == EWOULDBLOCK) ||
			    (rc == 0))
			{
				/*
				*	Disconnect has occurred.
				*	Release the socket.
				*/
			(void)close(MTMClientSd);
			MTMClientSd = DISCONNECTED;
			}

			return;
		}

		len_length = len_length << 8;
		len_length = len_length | (len_read[2] & 0xFF);

#ifdef DEBUG
	fprintf(stdout,"ClGetMsg: 64k section - len_length is %d\n",len_length);
	fflush(stdout);
#endif

		/* Now read the next len_length bytes for true message size. */

		memset(len_read,0,sizeof(len_read));

		sca_SetupTimer((void *)ClGetMsg, &ClTimeout, (void *)cl_signal_catcher);
		
		rc = sca_recv(MTMClientSd,
			len_read,
			len_length+3,
			MSG_PEEK,
			&ClTimeout,
			return_code);

		sca_CancelTimer((void *)ClGetMsg, &ClTimeout);

		if (rc <= 0) 
		{
			if ((*return_code == ENOTCONN) || 
			    (*return_code == ECONNRESET) ||
			    (*return_code == ENOMSG) ||
			    (*return_code == EWOULDBLOCK) ||
			    (rc == 0))
			{
				/*
				*	Disconnect has occurred.
				*	Release the socket.
				*/
			(void)close(MTMClientSd);
			MTMClientSd = DISCONNECTED;
			}

			return;
		}

		msg_length=0;
		for (j = 0; j < len_length; j++)
		{
			msg_length = msg_length << 8;
			msg_length = msg_length | (len_read[j+3] & 0xFF);
		}

#ifdef DEBUG
	fprintf(stdout,"ClGetMsg: 64k section - msg_length is %d\n",msg_length);
	fflush(stdout);
#endif
	}


#ifdef DEBUG
	(void)fprintf(stdout,"ClGetMsg: After recv rc = %d\n",rc);
	(void)fprintf(stdout,"ClGetMsg: Msg Length %d\n",msg_length);
	(void)fflush(stdout);
#endif

	/*
	*	Return if message length is invalid
	*/
	if (msg_length < header_size)
	{
#ifdef DEBUG
	(void)fprintf(stdout,"ClGetMsg: Invalid message length %d, header length %d\n",msg_length, header_size);
	(void)fflush(stdout);
#endif
		return;
	}

	/*
	*	Now get the message off the socket
	*/
	sca_SetupTimer((void *)ClGetMsg, &ClTimeout, (void *)cl_signal_catcher);

	ptr = ClMsgBuffer;

	rc = sca_recv(	MTMClientSd,
			     	ClMsgBuffer,
			     	msg_length,
			     	recv_flags, &ClTimeout, return_code);

	sca_CancelTimer((void *)ClGetMsg, &ClTimeout);

	if (rc<=0) 
	{
#ifdef DEBUG
	fprintf(stdout,
		"ClExchmsg: message body sca_recv rc %d errno %d\n",rc,*return_code);
	(void)sca_fflush(stdout);
#endif
		MTM_LOG(*return_code);
		if ((*return_code == ENOTCONN) || 
		    (*return_code == ECONNRESET) ||
		    (*return_code == ENOMSG) ||
		    (*return_code == EWOULDBLOCK))
		{
#ifdef DEBUG
	(void)fprintf(stdout,"ClGetMsg: Disconnect occurred - current socket will be closed\n");
	(void)fflush(stdout);
#endif
			/*
			*	Disconnect has occurred.
			*	Release the socket.
			*/
			(void)close(MTMClientSd);
			MTMClientSd = DISCONNECTED;
		}
		return;
	}

	/*
	*	Read is ok, process the message
	*/
	if ((ClLength.lcount == 0) && (ClLength.tcount == 0))
	{
		/*
		*	strip the length from message
		*/
		if (extended_hdr_flg==1)
		{
			reply->str = &ClMsgBuffer[len_length+3];
			/* Remove the non-standard header length from the length of total message. */
			reply->length = msg_length - (len_length+3);
		}
		else
		{
			reply->str = &ClMsgBuffer[header_size];
			reply->length = msg_length - header_size;
		}
	}
	else
	{
		/*
		*	Length is embedded - return the whole enchilada
		*/
		reply->str = ClMsgBuffer;
		reply->length = msg_length;
	}

#ifdef DEBUG
	(void)fprintf(stdout,"ClGetMsg: message contents:\n");
	LV(reply->length,reply->str);
	(void)fflush(stdout);
#endif

	/*
	*	If reply length is 0, we probably have a heartbeat message.
	*	This is allowable under asynchronous mode, so don't bother
	*	to do the string compare here. The strncmp result would
	*	always be 0 (since there is nothing to compare), and the !
	*	will make it non-zero, and then we get the MTM_NO_SRV_TYPE
	*	error.
	*/
	if (reply->length > 0)
	{
		sprintf (no_srv_str, "1%s", MTM_NO_SRV_TYPE_STR);
		if (!strncmp (reply->str, no_srv_str, reply->length))
			*return_code = MTM_NO_SRV_TYPE;
	}

	return;
}


/*
*	cl_signal_catcher
*
*	Description: Process catched signals
*
*	Returns:
*	SUCCESS or FAILURE
*
*/
void
cl_signal_catcher(int sig)
{
#ifdef DEBUG
	fprintf(stdout,"cl_signal_catcher: client PID %d caught signal %x\n",getpid(),sig);
	fflush(stdout);
#endif
	ClTimeout.flag = 1;
}
