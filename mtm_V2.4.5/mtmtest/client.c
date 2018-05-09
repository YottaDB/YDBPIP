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
 *   $Id$
 *   $Log:	client.c,v $
 * Revision 1.8  2000/02/08 Subodh Chavan 
 * Fixed problem in clexchange where sqlstmt more than 255 characters was not 
 * terminated properly.
 *
 * Revision 1.7  96/04/10  17:20:16  17:20:16  zengf (Fan Zeng)
 * General cleaning up
 * 
 * Revision 1.6  97/08/1   David Gitlin
 * Fixed problem where clexchange was not reading the entire message off of
 * the socket when large messages were sent. Add a while loop to the recv
 * statement
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
*   $Revision: 1.8 $
*
*/

#include		<ctype.h>
#include		<stdio.h>
#include		<errno.h>
#include		<sys/time.h>
#include		<stdlib.h>
#include		<string.h>
#include		<sys/socket.h>
#include		<sys/types.h>
#ifdef _HPUX
	#include		<sys/select.h>
#endif
#include    		<signal.h>
#include    		<sys/ipc.h>
#include		<netinet/in.h>
#include		<netdb.h>
#include		"./scatype.h"
#include		"./mtm.h"
#include		"./mtmapi.h"

/*
*	   Declare Statics for the Message Transport Client API
*/
SLONG 	MTMClientSd = DISCONNECTED;
SLONG 	ClAttachedMem = FALSE;
char 	*ClMsgBuffer = (char *)NULL;
void	(*ClSaveSigAlrm)();
void     cl_signal_catcher(int);

/*
*	   MTM_read_select:
*
*	   Description:
*	   Block waiting for I/O in select, which has a time limit built in,
*	   instead of blocking in a call to read or write.
*
*/
int 
MTM_read_select (int fd, int sec)
{
	fd_set		rset;
	struct timeval tv;
	int iRetVal = 0;

	FD_ZERO (&rset);
	FD_SET (fd, &rset);

	tv.tv_sec = sec;
	tv.tv_usec = 0;

	/* < 0 for error, 0 for timeout and > 0 if descriptor is available */
	iRetVal = select (fd + 1, &rset, NULL, NULL, &tv);
#ifdef DEBUG	
	printf ("\nMTM_read_select : %d\n", iRetVal);
#endif
	return iRetVal;
}

/*
*	   MTM_write_select:
*
*	   Description:
*	   Block waiting for I/O in select, which has a time limit built in,
*	   instead of blocking in a call to read or write.
*
*/
int 
MTM_write_select (int fd, int sec)
{
	fd_set		rset;
	struct timeval tv;
	int iRetVal = 0;

	FD_ZERO (&rset);
	FD_SET (fd, &rset);

	tv.tv_sec = sec;
	tv.tv_usec = 0;

	/* < 0 for error, 0 for timeout and > 0 if descriptor is available */
	iRetVal = select (fd + 1, NULL, &rset, NULL, &tv);
#ifdef DEBUG	
	printf ("\nMTM_write_select : %d\n", iRetVal);
#endif
	return iRetVal;
}

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
	struct protoent		*protocol_data;
	SLONG				memseg_id;
	SLONG				optbuff;
	char				server_ip_address[IP_ADDR_LEN+1];
	short				server_port;

	*return_code = SUCCESS;

#ifdef DEBUG
	(void)fprintf(stdout,"CLIENT CONNECT:\n");
	(void)fflush(stdout);
#endif

	if(MTMClientSd != DISCONNECTED)
	{
#ifdef DEBUG
		MTM_LOG(EISCONN);
#endif
		(void)close(MTMClientSd);
	}

	/*
	*	   Initialize to defaults.
	*/
	MTMClientSd = DISCONNECTED;

	/*
	 *	Allocate memory for client message buffer
	 */
	if (ClMsgBuffer == NULL)
		ClMsgBuffer = (char *) malloc (MAX_MSG_SIZE);
	if (ClMsgBuffer == NULL)
	{
#ifdef DEBUG
		MTM_LOG (errno);
#endif
		*return_code = errno;
		return;
	}

	/*
	*	Get the protocol number
	*/
	protocol_data = getprotobyname("TCP");

	if((MTMClientSd = socket(AF_INET, 
							SOCK_STREAM, 
							protocol_data->p_proto)) == FAILURE)
	{
#ifdef DEBUG
		MTM_LOG(errno);
#endif
		*return_code = errno;
		return;
	}

	if((rc = setsockopt(MTMClientSd, 
						SOL_SOCKET, 
						SO_REUSEADDR,
						(char *)&optbuff,
						sizeof(optbuff))) == FAILURE)
	{
#ifdef DEBUG
		MTM_LOG(errno);
#endif
		*return_code = errno;
		return;
	}

	sscanf(addr, "%[^/]/%hd", server_ip_address, &server_port);
	memset((char *)&client_addr, 0, sizeof(client_addr));
	client_addr.sin_family = AF_INET;
	client_addr.sin_port = htons(server_port);
	client_addr.sin_addr.s_addr = inet_addr(server_ip_address);
	memset(client_addr.sin_zero,0,8);

#ifdef DEBUG
	(void)fprintf(stdout,"Port %d\n",client_addr.sin_port);
	(void)fprintf(stdout,"IP Address %s\n",server_ip_address);
	(void)fflush(stdout);
#endif

	if((rc = connect(MTMClientSd,
			(void *)&client_addr,
			sizeof(struct sockaddr_in))) == FAILURE)
	{
#ifdef DEBUG
		MTM_LOG(errno);
#endif
        /*ADDED BY DAG TO INSURE SOCKET IN KNOWN STATE IF PROBLEM ARISES*/
		(void)close(MTMClientSd);  
	        MTMClientSd = DISCONNECTED;
		*return_code = errno;
	}

#ifdef DEBUG
	(void)fprintf(stdout,"Socket Descriptor = %d\n",MTMClientSd);
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
#ifdef DEBUG
		MTM_LOG(ENOTCONN);
#endif
		*return_code = ENOTCONN;
		return;
	}

	if(ClMsgBuffer != (char *)NULL)
		free (ClMsgBuffer);
	ClMsgBuffer = NULL;

	if((rc = close(MTMClientSd)) == FAILURE)
	{
#ifdef DEBUG
		MTM_LOG(errno);
#endif
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
ClExchmsg(int count,
	  STR_DESCRIPTOR *request,
	  STR_DESCRIPTOR *reply,
	  SLONG timeout,
  	  SLONG *return_code)
{
	RETURNSTATUS	rc = SUCCESS;
	unsigned char	len_field[MTM_LEN_FIELD_SIZE];
	SSHORT			msg_length = 0;
	SSHORT			bytes_recv = 0;
	SSHORT			save_timeout;
	SLONG			recv_flags = 0;
	SLONG			block_mode = TRUE;
	MTM_MSG_HEADER	mtm_msg_header;
	char			*ptr = (char *)NULL;
	char			no_srv_str [MAX_NAME_LEN + 1];
	int			size_read_sofar; /*dg*/
	STR_DESCRIPTOR          dummyrec;
	char			dummy_buff[150];

	if(MTMClientSd == DISCONNECTED)
	{
		*return_code = ENOTCONN;
#ifdef DEBUG
 	MTM_LOG(ENOTCONN);
	(void)fprintf(stdout,"ClExchmsg: ENOTCONN\n");
	(void)fflush(stdout);
#endif
		return;
	}
	if (ClMsgBuffer == NULL)
		ClMsgBuffer = (char *) malloc (MAX_MSG_SIZE);
	if (ClMsgBuffer == NULL)
	{
#ifdef DEBUG
		MTM_LOG (errno);
#endif
		*return_code = errno;
		return;
	}

	save_timeout = timeout;
	if(request->length > 285){
		msg_length = request->length+MTM_LEN_FIELD_SIZE
					+MTM_LEN_FIELD_SIZE;
	}
	else{
		msg_length = request->length+MTM_LEN_FIELD_SIZE;
	}
	ClMsgBuffer[0] = msg_length/256;
   	ClMsgBuffer[1] = msg_length%256;
	(void)memcpy((char *)&ClMsgBuffer[2],request->str,msg_length);	
	ptr = ClMsgBuffer;

#ifdef DEBUG
	(void)fprintf(stdout,"ClExchmsg: Send Message\n");
	LV(msg_length, request->str);
	(void)fflush(stdout);
#endif

	/* Three ways of setting timeout
	 * (1) Call alarm, which generates SIGALRM signal. This solution is not thread-safe
	 * (2) Block waiting for I/O in select.
	 * (3) Use SO_RCVTIMEOUT and SO_SNDTIMEOUT but it is not yet supported on all UNIX platforms.
	 * We will be using option (2) - SS
	 * MTM_write_select returns 0 for timeout, -1 for error and > 0 for the number of descriptors available
	 */

	if (MTM_write_select (MTMClientSd, timeout) <= 0) {
#ifdef DEBUG
	(void)fprintf(stdout,"MTM_write_select error\n"/*,sig*/);
	(void)fflush(stdout);
#endif
		logging (NULL, (unsigned char *)"Error in MTM_write_select");
		return;				
	}

	if((rc = send(  MTMClientSd,
					ptr,
					msg_length,
					(int)NULL)) == FAILURE)
	{
#ifdef DEBUG
	(void)fprintf(stdout,"ClExchmsg: errno %d\n",errno);
	(void)fflush(stdout);
		MTM_LOG(errno);
#endif
		*return_code = errno;

		return;
	}

#ifdef OUT_OF_BAND_DATA
	/*
	*	   Check for out of band data
	*/
	if((rc = ioctl(	MTMClientSd,
			SIOCATMARK,
			(int *)&recv_flags)) != SUCCESS)
	{
#ifdef DEBUG
		MTM_LOG(errno);
#endif
		*return_code = errno;
		return;
	}

	if(recv_flags)
		recv_flags = MSG_OOB;
	else
		recv_flags = 0;
#endif


	dummyrec.str=dummy_buff;
	dummyrec.length=0;
        sprintf (dummy_buff,"\nERRDEBUG Right before network read, timeout %d: \n",timeout);
        logging (&dummyrec, dummy_buff);

	/* Implementing timeout using option (2) as above - SS
	 * MTM_read_select returns 0 for timeout, -1 for error and > 0 for the number of descriptors available
	 *
	 */
	
	if (MTM_read_select (MTMClientSd, timeout) <= 0) {
#ifdef DEBUG
	(void)fprintf(stdout,"MTM_read_select error\n"/*,sig*/);
	(void)fflush(stdout);
#endif
		logging (NULL, (unsigned char *)"Error in MTM_read_select");
		return;				
	}

	/*
	*dg1	First get the message bytes
	*/
	if((rc = recv(MTMClientSd,
			     (char *)len_field,
			     MTM_LEN_FIELD_SIZE,
			     recv_flags)) <= SUCCESS)
	{
#ifdef DEBUG
	(void)fprintf(stdout,"ClExchmsg: Recv rc %d errno %d\n",rc,errno);
	(void)fflush(stdout);
#endif
		if (rc == 0)
		{
#ifdef DEBUG
	(void)fprintf(stdout,"ClExchmsg: Disconnect occurred\n");
	(void)fflush(stdout);
#endif
			/*
			*	Disconnect has occurred.
			*	Release the socket.
			*/
			(void)close(MTMClientSd);
			MTMClientSd = DISCONNECTED;
#ifdef DEBUG
			MTM_LOG(ENOTCONN);
#endif
			*return_code = ENOTCONN;
		}
		else
		{
#ifdef DEBUG
			MTM_LOG(errno);
#endif
			*return_code = errno;
		}
		return;
	}


	msg_length = MTM_LENGTH (len_field);
#ifdef DEBUG
	(void)fprintf(stdout,"ClExchmsg: After recv rc = %d\n",rc);
	(void)fprintf(stdout,"ClExchmsg: Msg Length %d\n",msg_length);
	(void)fflush(stdout);
#endif


	/*
	*dg2	Now get the SCA message
	*/
	size_read_sofar = 0;
	ptr = ClMsgBuffer;
	while (size_read_sofar < msg_length-MTM_LEN_FIELD_SIZE) {
	/* Implementing timeout using option (2) as above - SS
	 * MTM_read_select returns 0 for timeout, -1 for error and > 0 for the number of descriptors available
	 *
	 */
	
	if (MTM_read_select (MTMClientSd, timeout) <= 0) {
#ifdef DEBUG
	(void)fprintf(stdout,"MTM_read_select error\n"/*,sig*/);
	(void)fflush(stdout);
#endif
		logging (NULL, (unsigned char *)"Error in MTM_read_select");
		return;				
	}
	if((rc = recv(	MTMClientSd,
			     	ptr+size_read_sofar,
			     	msg_length-MTM_LEN_FIELD_SIZE,
			     	recv_flags)) <= SUCCESS)
	{
#ifdef DEBUG
	(void)fprintf(stdout,"ClExchmsg: Recv rc %d errno %d\n",rc,errno);
	(void)fflush(stdout);
#endif
		if (rc == 0)
		{
#ifdef DEBUG
	(void)fprintf(stdout,"ClExchmsg: Disconnect occurred\n");
	(void)fflush(stdout);
#endif
			/*
			*	Disconnect has occurred.
			*	Release the socket.
			*/

#ifdef DEBUG
			MTM_LOG(ENOTCONN);
#endif
			(void)close(MTMClientSd);
			MTMClientSd = DISCONNECTED;
			*return_code = ENOTCONN;
			return;
		}
		else
		{
#ifdef DEBUG
			MTM_LOG(errno);
#endif
			*return_code = errno;
		}
		return;
	}
	size_read_sofar += rc;
	}/*END OF WHILE DG*/


	reply->str = ClMsgBuffer;
	reply->length = msg_length - MTM_LEN_FIELD_SIZE;
#ifdef DEBUG
	(void)fprintf(stdout,"ClExchmsg: reply %x\n",reply->str);
	(void)fprintf(stdout,"ClExchmsg: ClMsgBuffer %x\n",ClMsgBuffer);
	 LV(reply->length,reply->str);
	(void)fflush(stdout);
#endif

	sprintf (no_srv_str, "1%s", MTM_NO_SRV_TYPE_STR);
	if (!strncmp (reply->str, no_srv_str, reply->length))
		*return_code = MTM_NO_SRV_TYPE;
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
	(void)fprintf(stdout,"cl_signal_catcher:Server received signal %d\n",sig);
	(void)fprintf(stdout,"cl_signal_catcher:Server Process id %d\n",getpid());
	(void)fflush(stdout);
#endif
	switch(sig)
	{
		case SIGALRM:
			if(mtm_signal_intr(SIGALRM,ClSaveSigAlrm) == SIG_ERR)
			{
#ifdef DEBUG
				MTM_LOG(errno);
#endif
				return;
			}
			alarm(0);	/*	Clear the alarm clock 	*/
			break;
	}
}
