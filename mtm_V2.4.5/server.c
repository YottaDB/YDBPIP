/*
*	server.c - Sanchez Message Transport Server API for UNIX
*
*	Copyright(c)1992 Sanchez Computer Associates, Inc.
*	All Rights Reserved
*
*	ORIG:   Sara G. Walters - 22 February 1995
*
*	DESC:   This routine is the Sanchez proprietary UNIX
*
*
*   $Id: server.c,v 1.1 2000/06/01 00:45:35 lyh Exp lyh $
*   $Log:	server.c,v $
 * Revision 2.14  07/01/29  thoniyim ()
 * Modified SrvReply() to return the error EFBIG when the incoming
 * message is greater than MAX_MSG_SIZE
 *
 * Revision 2.13  05/12/06  PaulJ ()
 * Modified SrvGetMsg and SrvReply() to record the time-in and time-out 
 * of the server messages to record the MTM Statistics
 *
 * Revision 2.12  04/08/17  yurkovicg ()
 * Modified SrvReply to process >64K messages in a bby MTM.
 *
 * Revision 2.11  04/06/12  thoniyim ()
 * The message queue creation is changed to use IPC_PRIVATE.
 * MTM now writes the queue id information to a .qid file and
 * the server programs reads the queue info from the .qid file.
 * The user can specify an environment variable, MTM_DIR, with
 * the directory info for the MTM files (.info,.lock,...)
 *
 * Revision 2.10  00/07/07  11:59:42  11:59:42  lyh ()
 * added string.h for strlen() - resolve compiler warning when porting
 * to other platforms.
 * 
 * Revision 2.9  00/07/06  17:18:27  17:18:27  lyh ()
 * Removed certain restrictions for tcp client (MTM v2.0.1)
 * 
 * Revision 2.8  00/06/02  13:34:25  13:34:25  lyh ()
 * Changes as a result of porting to other platforms.
 * 
 * Revision 2.7  00/03/29  09:35:51  09:35:51  lyh ()
 * Changed length format to pattern matching instead of using option
 * 
 * Revision 2.6  00/03/23  10:48:54  10:48:54  lyh ()
 * Set the correct calling function name in cancel timer
 * 
 * Revision 2.5  00/03/14  16:29:50  16:29:50  lyh ()
 * more correction on cancel timer
 * 
 * Revision 2.4  00/03/14  14:13:24  14:13:24  lyh ()
 * Correct parameter in SrvConnect cancel timeout call
 * 
 * Revision 2.3  00/03/13  14:21:39  14:21:39  lyh ()
 * Check pointer to avoid segment violation error
 * 
 * Revision 2.2  00/03/03  15:13:11  15:13:11  lyh ()
 * snad comber release
 * sand comber release
 * 
 * Revision 2.1  00/01/17  11:16:13  11:16:13  lyh ()
 * storm trooper release
 * 
 * Revision 1.1  00/01/17  11:04:09  11:04:09  lyh ()
 * Initial revision
 * 
*
*
*  Revision 1.12  Dec 8, 98  (David Gitlin)
*  In gtm 4.0 a set of library routines are provided which can be called
by external routines. These routines provide several services. We use
the routines which handle timeouts. This allows a timeout to be issued
during a sca_msgrcv call, so the Profile server can return to Profile
and check for events. These routines do not create conflicts in the
same manner that using the unix routines do.
These routines are accessed as follows:
An environment variable "GTM_CALLIN_START" is defined by GTM with the
starting address of a table of procedure addresses. Using this address we
access the 2 and 3 elements of the table to get the the pointer to the
correct procedures. Element 2 is the timer routine, element 3 is the 
cancel timer routine.  In this module we call the pointers to these
procedures "setup_timer" and "cancel_timer". See those pointers for more
information.
*
*IMPORTANT NOTES*
1) This code can only be used with GTM 4.0, it is no longer compatible
with earlier versions of GTM.
2) Inorder for it to work certain modules must be loaded in GTM, these
should be in build 16 or higher. If this routine exits with an error,
saying that "GTM_CALLIN_STAR" is not defined the absence of these
extensions is the most likely cause. Check with Greystone if this happens.
3) This also requires the newest version of shlib.o in the shlib
directory, otherwise it will not timeout.
*
*  Revision 1.11 Sep 20, 98 (David Gitlin)
 * Greystone M v4.0 changed the manner in which it handles signals. As a
 * result, any external routine which makes system calls may find that
 * its behavior has been effected.  Essentially, signal sensitive system
 * calls may be interrupted before successfull completion, producing an
 * unknown state. Two changes were made to handle this. 1) A new
 * object file (/SCA/sca_gtm/shlib/shlib.o) was created with calls
 * such as sca_xxx where xxx is the equivalent system call. For example
 * sca_write, sca_open etc.  These calls handle the signal issue.
 * They were then substituted for the equivalent system call in the
 * source code. 2) The manner in which system calls like printf,
 * which have a variable number of arguments, were called
 * was directly changed in the source code. The changes are noted.
 *
 * Revision 1.11  96/04/17  15:16:48  15:16:48  zengf (Fan Zeng)
 * Fixed stats.
 * 
 * Revision 1.10  96/04/10  17:21:31  17:21:31  zengf (Fan Zeng)
 * General cleaning up
 * 
 * Revision 1.9  96/03/21  15:04:24  15:04:24  zengf (Fan Zeng)
 * Collapsed directories and replaced signals with fifos.
 * 
 * Revision 1.8  96/03/13  10:03:35  10:03:35  zengf (Fan Zeng)
 * prepare for removing signals
 * 
 * Revision 1.7  96/02/28  17:31:25  17:31:25  zengf (Fan Zeng)
 * Substantially rewrite the APIs
 * 
 * Revision 1.6  96/01/22  14:40:15  14:40:15  zengf (Fan Zeng)
 * fixed bug where MTMServerId.server_type_qid is used as a valid after it 
 * was set to DISCONNECTED. modified to use srv_type_qid instead.
 * 
 * Revision 1.5  96/01/19  11:34:50  11:34:50  zengf (Fan Zeng)
 * Modified to use type string * instead of char ** to return a message to
 * mumps program because there could be null characters in the messsage.
 * 
 * Revision 1.4  95/08/11  14:40:25  14:40:25  rcs ()
 * Benchmark bug fixes
 * 
 * Revision 1.3  95/07/19  14:31:10  14:31:10  rcs ()
 * Bug Fixes as a result of MTM System Test
 * 
 * Revision 1.2  95/05/22  14:52:37  14:52:37  sca ()
 * sgI VMS
 * 
*   $Revision: 2.10 $
*
*/

#include	<ctype.h>
#include	<stdio.h>
#include	<errno.h>
#include	<time.h>
#include	<signal.h>
#include	<limits.h>
#include	<sys/ipc.h>
#include	<sys/sem.h>
#include	<sys/socket.h>
#include	<stdlib.h>
#include	<string.h>
#include	"scatype.h"
#include	"mtm.h"
#include	"mtmapi.h"

/*
*	Declare Statics for the Message Transport Server API
*/

typedef struct {
	SLONG	srv_state;
	SLONG   mtm_cntrl_qid;
	SLONG 	reply_qid;
	SLONG   mtm_process_id;
	SLONG   server_type_qid;
	SLONG 	process_slot_id;
	SLONG   client_sd;
	SLONG   client_port;
	SLONG   unix_pid;
	char	process_name[MAX_PARAM1_LEN];
	SLONG   srv_type;
	SLONG	srv_mode;
	char	format;
	char	header;
	SLONG	lsize;
	SLONG	hsize;
	SLONG	lcount;
	SLONG	tcount;
	int	fifo_fd;
} MTM_SERVER_ID;

MTM_SERVER_ID 	MTMServerId;
char 		*SrvMsgBuffer = (char *)NULL;
void 		srv_signal_catcher(int);
void 		exit_signal_catcher(int);
SLONG		MTMAsyncMode;
st_length	SvLength;
st_timeout	SvTimeout;
SLONG		MTMReplyTime=0;
SLONG		MTM_STATS_STARTED = FALSE;

/*
*	timer related functions
*/
extern void sca_SetupTimer(void *, st_timeout *, void *);
extern void sca_CancelTimer(void *, st_timeout *);
extern int sca_AlarmSetup(int);

/*
*	message queue related functions
*/
/*
extern int sca_msgsnd(SLONG, struct msgbuf *, size_t, int, st_timeout *, SLONG *);
extern int sca_msgrcv(SLONG, struct msgbuf *, size_t, long int, int, st_timeout *, SLONG *);
*/

/*
*	SrvConnect:
*	[module number i.e. Future] [module name]
*
*	Description:
*	$ZCall to allow a PROFILE MUMPS server process to connect to a
*	UNIX Message Transport Monitor. This call attaches the calling process
*	to the MTM control message queue and attaches the process to the Request
*	and Reply queues for the specified server type.
*	These queues are created by the MTM during initialization.
*
*	Returns:
*/
void
SrvConnect(int count,
	   char *srv_type_name, 
	   SLONG *id,
	   SLONG *return_code)
{
	RETURNSTATUS    rc = SUCCESS;
	MTM_CNTRL_MSG	msg_buffer;
	char		*ptr;
	register int    i;
	SLONG		mtm_process_id;
	SLONG		timeout = 10;
	key_t		ipc_key;
	char		key_file[_POSIX_PATH_MAX + 1];
	char		fifo_name[_POSIX_PATH_MAX + 1];
	char		qid_file[_POSIX_PATH_MAX + 1];
	STR_DESCRIPTOR	mtm_id;
	int		number_of_sleeps=0;
	int		value;
	FILE *		qid_fp;
        char 		buffer[200];
        char 		option[80];
        char 		cvalue[80];
	char		srvType[50];
	char 		*env_val;
	char		mtm_env[MAX_NAME_LEN];
     
	*return_code = SUCCESS;

	memset(mtm_env,0,MAX_NAME_LEN);
	env_val = getenv ("MTM_DIR");
 
        if (env_val != NULL)
                strcpy (mtm_env, env_val);
        else
                sprintf(mtm_env,"%s",MTM_TMP_DIR);

	SvTimeout.type = sca_AlarmSetup(1);

#ifdef DEBUG
	(void)fprintf(stdout,"SrvConnect\n");
	(void)fflush(stdout);
#endif

	/*
	*	Initialize Static Data to the defaults
	*/
	memset(&msg_buffer, 0, sizeof(msg_buffer));
	MTMServerId.srv_state = DISCONNECTED;
	MTMServerId.mtm_cntrl_qid = DISCONNECTED;
	MTMServerId.reply_qid = DISCONNECTED;
	MTMServerId.server_type_qid = DISCONNECTED;
	MTMServerId.process_slot_id = DISCONNECTED;
	MTMServerId.unix_pid = DISCONNECTED;
	MTMServerId.mtm_process_id = DISCONNECTED;
	MTMServerId.srv_type = DISCONNECTED;

	if(SrvMsgBuffer == (char *)NULL)
		SrvMsgBuffer = (char *) malloc (MAX_MSG_SIZE + sizeof (MTM_MSG_HEADER));
	if(SrvMsgBuffer == (char *)NULL)
	{
		MTM_LOG(0);
		*return_code = rc;
		return;
	}

	if ((mtm_id.str = (char *)malloc (MAX_NAME_LEN)) == NULL)
	{
		MTM_LOG(errno);
		*return_code = errno;
		return;
	}

	SrvMTMId (0, srv_type_name, &mtm_id);

/*dag Sep 18 98 to take care of signal handler conflict in gtm 4.0*/
	do {
		value = sprintf (key_file, "%s/%.*s.lock", mtm_env,mtm_id.length, mtm_id.str);
        }
	while (value == FAILURE && errno == EINTR);

/*dag Sep 18 98 to take care of signal handler conflict in gtm 4.0*/
	do {
		value = sprintf (fifo_name, "%s/%.*s.fifo", mtm_env, mtm_id.length, mtm_id.str);
	}
        while (value < 0 && errno == EINTR);

/* MKT 060104 - qid file */
	do {
		value = sprintf (qid_file, "%s/%.*s.qid", mtm_env,mtm_id.length, mtm_id.str);
        }
	while (value == FAILURE && errno == EINTR);

	free (mtm_id.str);

#ifdef DEBUG
	(void)fprintf(stdout,"SrvConnect : key_file %s\n",key_file); 
	(void)fflush(stdout);
#endif

	/*
	*	Get the MTM Control Queue Id and Reply Queue Id
	*/
/*** MKT 060104 - qid file ***/

	qid_fp = fopen(qid_file,"r");
        if (qid_fp != (FILE *)NULL)
        {
	   for (;;)
           {
              option[0] = '\0';
              cvalue[0] = '\0';
              memset(buffer, 0, 200);
 
              if (fgets(buffer,200,qid_fp) == NULL)
                 break;
 
              if (buffer[0] == '*')
                 continue;
 
              sscanf(buffer,"%[^=]=%s",option,cvalue);

              if (strcmp(option,"Server_Reply_QID") == 0)
              {
                 MTMServerId.reply_qid = strtoul(cvalue,NULL,10);
              }
	      else if (strcmp(option,"Server_Control_QID") == 0)
	      {
                 MTMServerId.mtm_cntrl_qid = strtoul(cvalue,NULL,10);
	      }
	      else if (strcmp(option,"Server_Request_QID0") == 0)
		 break;
           }
        }
        else
        {
	   MTM_LOG(errno);
           *return_code = errno;
           return;
        }
 
	/*
	 * Open fifo as a one way channel to send message to MTM
	 */
	if ((MTMServerId.fifo_fd = sca_open (fifo_name, O_WRONLY)) == FAILURE)
	{
		MTM_LOG(errno);
		*return_code = errno;
		return;
	}

	mtm_get_mtm_pid (key_file, &(MTMServerId.mtm_process_id), return_code);
	if (*return_code != SUCCESS)
		return;

	MTMServerId.srv_state = INITIALIZED;
#ifdef DEBUG
	(void)fprintf(stdout,"SrvConnect: INITIALIZED\n");
	(void)fflush(stdout);
#endif

	MTMServerId.unix_pid = getpid();
	/*
	*	Create the message
	*/
	msg_buffer.cmd = ADDSRV;

/*dag Sep 18 98 to take care of signal handler conflict in gtm 4.0*/ 
	do {
		value = sprintf(	MTMServerId.process_name,
					"Srv_%d",
					MTMServerId.unix_pid);
	}
        while (value < 0 && errno == EINTR);

	(void)strcpy (	msg_buffer.param1, srv_type_name);
	(void)strcpy(	msg_buffer.param2, MTMServerId.process_name);
	
	/*
	 * The message is sent to the MTM process as indicated by 
	 * msg_buffer.header.mtype.unix_pid
	 */
	msg_buffer.header.mtype.unix_pid = MTMServerId.mtm_process_id;	
	msg_buffer.header.pid = MTMServerId.unix_pid;	
	
#ifdef DEBUG
	(void)fprintf(stdout,"SrvConnect: Server type %s\n",msg_buffer.param1);
	(void)fprintf(stdout,"SrvConnect: Server name %s\n",msg_buffer.param2);
	(void)fprintf(stdout,"SrvConnect: Cmd %d\n",msg_buffer.cmd);
	(void)fflush(stdout);
#endif

	/*
	*	Send Add Server Message.
	*/
	SvTimeout.value = timeout;

	sca_SetupTimer((void *)SrvConnect, &SvTimeout, (void *)srv_signal_catcher);

	rc = sca_msgsnd(MTMServerId.mtm_cntrl_qid,
		(struct msgbuf *)&msg_buffer,
		sizeof(MTM_CNTRL_MSG),
		(int)0,
		&SvTimeout,
		return_code);

	sca_CancelTimer((void *)SrvConnect, &SvTimeout);

	if (rc < 0)
	{
		if (*return_code != ETIME)
			MTM_LOG(*return_code);
		return;
	}

	/*
	*	Signal the MTM Process that a service control message is pending.
	*/
#ifdef DEBUG
	(void)fprintf(stdout,	"SrvConnect: Signalling %d\n",
							MTMServerId.mtm_process_id);
	(void)fflush(stdout);
#endif
	if ((rc = sca_write (MTMServerId.fifo_fd,
					MTM_CONTROL_MSG_FLAG,
					MTM_MSG_FLAG_SIZE)) == FAILURE)
	{
		MTM_LOG(errno);
		*return_code = errno;
		return;
	}

	/*
	*	Set up the alarm clock - to go off in MTM_ALARM_TIME
	*	seconds if a message is not received.
   	*
   	*	The signal SIGALRM  will be raised by UNIX
	*	if the alarm clock goes off
   	*/

       /*
	*	Get reply message.
	*/
#ifdef DEBUG
	(void)fprintf(stdout,"SrvConnect: Requesting message for process %d on q %d\n", MTMServerId.unix_pid, MTMServerId.mtm_cntrl_qid);
	(void)fflush(stdout);
#endif

	SvTimeout.value = timeout;

	sca_SetupTimer((void *)SrvConnect, &SvTimeout, (void *)srv_signal_catcher);

	rc = sca_msgrcv(MTMServerId.mtm_cntrl_qid,
		(struct msgbuf *)&msg_buffer,
		sizeof(MTM_MSG_HEADER),
		(long)MTMServerId.unix_pid,
		0,
		&SvTimeout,
		return_code);

	sca_CancelTimer((void *)SrvConnect, &SvTimeout);

	if (rc < 0)
	{
		if (*return_code != ETIME)
			MTM_LOG(*return_code);
		return;
	}

#ifdef DEBUG
	(void)fprintf(stdout,"SrvConnect: message for process %d on q %d\n",
				msg_buffer.header.mtype.unix_pid,
				MTMServerId.mtm_cntrl_qid);
	(void)fflush(stdout);
#endif

	/*
	*	If the first byte of the message is the character 0, SUCCESS
	*/
	if(msg_buffer.header.return_code == SUCCESS)
	{
		MTMServerId.srv_type = msg_buffer.header.srv_type;
		MTMServerId.process_slot_id = msg_buffer.header.slot_id;
		MTMServerId.srv_state = CONNECTED;
		MTMAsyncMode  = msg_buffer.header.srv_mode;
		SvLength.format = msg_buffer.header.format;
		SvLength.header = msg_buffer.header.header;
		SvLength.lsize  = msg_buffer.header.lsize;
		SvLength.hsize  = msg_buffer.header.hsize;
		SvLength.lcount = msg_buffer.header.lcount;
		SvLength.tcount = msg_buffer.header.tcount;

#ifdef DEBUG
	(void)fprintf(stdout,"SrvConnect: CONNECTED\n");
	(void)fprintf(stdout,"SrvConnect: Process Slot id %d - Async mode %d\n",MTMServerId.process_slot_id, MTMAsyncMode);
	(void)fprintf(stdout,"\tformat is %c\n",SvLength.format);
	(void)fprintf(stdout,"\theader is %c\n",SvLength.header);
	(void)fprintf(stdout,"\tlsize is %d\n",SvLength.lsize);
	(void)fprintf(stdout,"\thsize is %d\n",SvLength.hsize);
	(void)fprintf(stdout,"\tlcount is %d\n",SvLength.lcount);
	(void)fprintf(stdout,"\ttcount is %d\n",SvLength.tcount);
	(void)fflush(stdout);
#endif
	}
	else
	{
		*return_code = msg_buffer.header.reason_code;
#ifdef DEBUG
	(void)fprintf(stdout,	"SrvConnect: Return code %d\n",
		msg_buffer.header.return_code);
	(void)fflush(stdout);
#endif
		return;
	}
	
	/*
	*	Get the Service Type Queue Id for this server type.
	*/
	sprintf(srvType,"Server_Request_QID%d\0",MTMServerId.srv_type);

        if (strcmp(option,srvType) == 0)
	{
           MTMServerId.server_type_qid = strtoul(cvalue,NULL,10);
        }
	else {
	   for (;;)
           {
              option[0] = '\0';
              cvalue[0] = '\0';
              memset(buffer, 0, 200);
 
              if (fgets(buffer,200,qid_fp) == NULL)
                 break;
 
              if (buffer[0] == '*')
                 continue;
 
              sscanf(buffer,"%[^=]=%s",option,cvalue);

              if (strcmp(option,srvType) == 0)
	      {
           	 MTMServerId.server_type_qid = strtoul(cvalue,NULL,10);
		 break;
              }
	   }
        }

	fclose(qid_fp);

	*id = MTMServerId.process_slot_id;
	return;
}

/*
*	SrvDisconnect:
*	[module number i.e. Future] [module name]
*
*	Description:
*	$ZCall to allow a PROFILE MUMPS server process to disconnect from a
*	UNIX Message Transport Monitor.
*
*	Returns:
*/
void
SrvDisconnect(int count)
{
	RETURNSTATUS    rc = SUCCESS;
	MTM_CNTRL_MSG  	msg_buffer;
	SLONG		mtm_cntrl_qid;
	SLONG		srv_type_qid;
	SLONG		timeout = 10;
        int             number_of_sleeps=0;
	int		value;
	SLONG		return_code;

#ifdef DEBUG
	(void)fprintf(stdout,"SrvDisconnect:\n");
	(void)fflush(stdout);
#endif
	
	/*
	*	Create the message
	*/
	msg_buffer.cmd = DELSRV;
	msg_buffer.header.srv_type = MTMServerId.srv_type;
	msg_buffer.header.mtype.unix_pid = MTMServerId.mtm_process_id;
	msg_buffer.header.pid = MTMServerId.unix_pid;	
	msg_buffer.header.slot_id = MTMServerId.process_slot_id;
	
/*dag Sep 18 98 to take care of signal handler conflict in gtm 4.0*/ 
	do {
		value = sprintf(msg_buffer.param1, "%d",MTMServerId.process_slot_id);
	}
        while (value < 0 && errno == EINTR);

	/*
	*	Initialize Static Data to the defaults
	*/
	mtm_cntrl_qid = MTMServerId.mtm_cntrl_qid;
	MTMServerId.mtm_cntrl_qid = DISCONNECTED;
	srv_type_qid = MTMServerId.server_type_qid;
	MTMServerId.server_type_qid = DISCONNECTED;
	MTMServerId.process_slot_id = DISCONNECTED;
	
#ifdef DEBUG
	(void)fprintf(stdout,"SrvDisconnect: Server Name %s\n",
						MTMServerId.process_name);
	(void)fprintf(stdout,"SrvDisconnect: Cmd %d\n",msg_buffer.cmd);
	(void)fprintf(stdout,"SrvDisconnect: Process pid %d\n", 
						msg_buffer.header.mtype.unix_pid);
	(void)fflush(stdout);
#endif

	if(SrvMsgBuffer != (char *)NULL)
		free (SrvMsgBuffer);
	SrvMsgBuffer = NULL;

	if (MTMServerId.srv_state != CONNECTED)
		return;

	/*
	*	Send Delete Server Message.
	*/
	SvTimeout.value = timeout;

	sca_SetupTimer((void *)SrvDisconnect, &SvTimeout, (void *)srv_signal_catcher);

	rc = sca_msgsnd(mtm_cntrl_qid,
		(struct msgbuf *)&msg_buffer,
		sizeof(MTM_CNTRL_MSG),
		(int)0,
		&SvTimeout,
		&return_code);

	sca_CancelTimer((void *)SrvDisconnect, &SvTimeout);

	if (rc < 0)
	{
#ifdef DEBUG
	(void)fprintf(stdout,"SrvDisconnect: sca_msgsnd failed %d\n",errno);
	(void)fflush(stdout);
#endif
		MTM_LOG(return_code);
		return;
	}
	
	/*
	*	Signal the MTM Process that a service control message is pending.
	*/
#ifdef DEBUG
	(void)fprintf(stdout,	"SrvDisconnect: Signalling %d \n",
				MTMServerId.mtm_process_id);
	(void)fflush(stdout);
#endif
	if ((rc = sca_write (	MTMServerId.fifo_fd,
				MTM_CONTROL_MSG_FLAG,
				MTM_MSG_FLAG_SIZE)) == FAILURE)
	{
		MTM_LOG(errno);
		return;
	}

	/*
	*	Set up the alarm clock - to go off in MTM_ALARM_TIME
	*	seconds if a message is not received.
	*
   	*	The signal SIGALRM  will be raised by UNIX
	*	if the alarm clock goes off
   	*/

	SvTimeout.value = timeout;

	sca_SetupTimer((void *)SrvDisconnect, &SvTimeout, (void *)srv_signal_catcher);

	rc = sca_msgrcv(mtm_cntrl_qid,
		(struct msgbuf *)&msg_buffer,
		sizeof(MTM_MSG_HEADER),
		(long)MTMServerId.unix_pid,
		0,
		&SvTimeout,
		&return_code);

	sca_CancelTimer((void *)SrvDisconnect, &SvTimeout);

	if (rc < 0)
	{
		MTM_LOG(return_code);
		return;
	}

#ifdef DEBUG
	(void)fprintf(stdout,	"SrvDisconnect: Return code %d\n",
				msg_buffer.header.return_code);
	(void)fprintf(stdout,	"SrvDisconnect: Reason code %d\n",
				msg_buffer.header.reason_code);
	(void)fflush(stdout);
#endif

	close (MTMServerId.fifo_fd);

	MTMServerId.srv_state = DISCONNECTED;

	return;
}
	
/*
*	SrvGetMsg:
*	[module number i.e. Future] [module name]
*
*	Description:
*	$ZCall to allow a PROFILE MUMPS server process to get a client request
*	message for a specific type of server process.
*
*/
void
SrvGetMsg(	int count,
		STR_DESCRIPTOR *msg,
		SLONG timeout,
		SLONG *return_code)
{
	RETURNSTATUS    rc = SUCCESS;
	MTM_MSG_HEADER	*pHeader;
	struct timeval	time_value;
	struct timezone time_zone;
	SLONG wait_time;
#ifdef DEBUG
	(void)fprintf(stdout,"SrvGet\n");
	(void)fflush(stdout);
#endif

	/*
	*	Set up the alarm clock - to go off in timeout
	*	seconds if a message is not received.
	*
   	*	The signal SIGALRM  will be raised by UNIX
	*	if the alarm clock goes off
   	*/


	SvTimeout.value = timeout;

	sca_SetupTimer((void *)SrvGetMsg, &SvTimeout, (void *)srv_signal_catcher);

	rc = sca_msgrcv(MTMServerId.server_type_qid,
		(struct msgbuf *)SrvMsgBuffer,
		(MAX_MSG_SIZE+sizeof(MTM_MSG_HEADER)),
		(long)0,
		0,
		&SvTimeout,
		return_code);


	/* Calculate the current time in microseconds */

	gettimeofday(&time_value,&time_zone);


	sca_CancelTimer((void *)SrvGetMsg, &SvTimeout);

	if(rc < 0)
	{
		if (*return_code != ETIME)
			MTM_LOG(*return_code);
		return;
	}

	*return_code = SUCCESS;

	/*
	*	Check if message header is usable
	*/
	pHeader = (MTM_MSG_HEADER *)SrvMsgBuffer;
	if (pHeader == NULL)
	{
		*return_code = EFAULT;
		MTM_LOG(*return_code);
		return;
	}
	if( pHeader->time_in != 0 )
		MTM_STATS_STARTED = TRUE;
	else
		MTM_STATS_STARTED = FALSE;

	/*   Calculate the wait time for the message in the request queue if the mtm stats on */
	if( MTM_STATS_STARTED )
	{
		MTMReplyTime = 0;
		time_value.tv_usec = (time_value.tv_sec * 1000 * 1000) + time_value.tv_usec;
		MTMReplyTime = time_value.tv_usec - pHeader->time_in;
	}


	pHeader->length = rc;
	MTMServerId.client_sd = pHeader->sd;
	MTMServerId.client_port = pHeader->port;
	
#ifdef DEBUG
	(void)fprintf(stdout,	"SrvGetMsg: Client Sd = %d\n",
						MTMServerId.client_sd); 
	(void)fprintf(stdout,	"SrvGetMsg: Client Port = %d\n",
						MTMServerId.client_port); 
	(void)fprintf(stdout,	"SrvGetMsg: Process Slot = %d\n",
						MTMServerId.process_slot_id); 
	(void)fflush(stdout);
#endif

	msg->str = (SrvMsgBuffer + sizeof(MTM_MSG_HEADER));
	msg->length = pHeader->length - sizeof(MTM_MSG_HEADER);


#ifdef DEBUG
	LV(msg->length,msg->str);
	(void)fflush(stdout);
#endif
	return;
}

/*
*	SrvReply:
*	[module number i.e. Future] [module name]
*
*	Description:
*	$ZCall to allow a PROFILE MUMPS server process to send a reply message
*	to a client.
*
*	Returns:
*/
void SrvReply(	int count,
		STR_DESCRIPTOR *msg,
		SLONG *return_code)
{
	RETURNSTATUS    rc = SUCCESS;
	char 		*msg_buffer = (char *)NULL;
	char 		*ptr = (char *)NULL;
	char		len_str[32]; /* a reasonable string length */
	MTM_MSG_HEADER	*pHeader;
	int len_length = 0;
	int add_length = 0;
	struct timeval	time_value;
	struct timezone time_zone;

#ifdef DEBUG
	(void)fprintf(stdout,"SrvReply: Msg Length = %d\n",msg->length);
	(void)fprintf(stdout,"SrvReply: Msg = %s\n",msg->str);
	(void)fflush(stdout);
	LV(msg->length,msg->str);
#endif

	if (msg->length > MAX_MSG_SIZE)
	{
		*return_code = EFBIG;
		MTM_LOG(*return_code);
		return;
	}

	/*
	*	Allocating memory for the maximum message size.
	*/
	if((msg_buffer = (char *)malloc((msg->length +SvLength.hsize+256
			 +sizeof(MTM_MSG_HEADER)))) == (char *)NULL)
	{
		MTM_LOG(errno);
		*return_code = errno;
		return;
	}

	/*
	*	Check if message header is usable
	*/
	pHeader = (MTM_MSG_HEADER *)msg_buffer;
	if (pHeader == NULL)
	{
		*return_code = EFAULT;
		MTM_LOG(*return_code);
		return;
	}

	/*
	*	Set up the unique message identifier.
	*/
	pHeader->mtype.unix_pid = MTMServerId.mtm_process_id;
	pHeader->pid = MTMServerId.unix_pid;
	pHeader->slot_id = MTMServerId.process_slot_id;
	pHeader->sd = MTMServerId.client_sd;
	pHeader->port = MTMServerId.client_port;
	pHeader->srv_type = MTMServerId.srv_type;
	if (MTMAsyncMode == FALSE)
	{
		if ((SvLength.lcount == 0) && (SvLength.tcount == 0))
			pHeader->length = msg->length + SvLength.hsize + 1;
		else
			pHeader->length = msg->length;
	}
	else
	{
		if ((SvLength.lcount == 0) && (SvLength.tcount == 0))
			pHeader->length = msg->length + SvLength.hsize;
		else
			pHeader->length = msg->length;
	}
	ptr = (msg_buffer + sizeof(MTM_MSG_HEADER));
	if ((SvLength.lcount == 0) && (SvLength.tcount == 0))
	{
		/* 
		 If we are in a standard bby MTM and the message 
		 approaches 64K, use special header format. 
		 At this time, only Big Endian is supported, because it 
		 is the default header format and the existing client 
		 tools all use Big Endian.
		*/
		if ((SvLength.hsize==2) && (msg->length>65530) && (SvLength.format=='b'))
		{
			int s64klen = msg->length;
			if (MTMAsyncMode==FALSE) s64klen++;
				/* We don't know entire msg length until 
				   header is constructed. */
			len_length=mtm_s64klength(len_str, s64klen, &SvLength);
			memcpy(ptr, len_str, len_length);
			ptr+=len_length;
			add_length=len_length-SvLength.hsize;
			pHeader->length+=add_length;
#ifdef DEBUG
	(void)fprintf(stdout,"SrvReply: After call to s64k, len_length is %d\n",len_length);
	(void)fprintf(stdout,"SrvReply: After call to s64k, len_str is\n");
	LV(len_length,len_str);
	(void)fflush(stdout);
#endif
		}
		else 
		{
			mtm_slength(len_str, (SLONG)pHeader->length, &SvLength);
			memcpy(ptr, len_str, SvLength.hsize);
			ptr += SvLength.hsize;
		}
	}
	if (MTMAsyncMode == FALSE)
	{
		*ptr = '0';
		ptr++;
	}
	(void)memcpy(ptr,msg->str,msg->length);

#ifdef DEBUG
	LV(msg->length+len_length,(msg_buffer+sizeof(MTM_MSG_HEADER)));
	(void)fprintf(stdout,	"SrvReply: Msg Length = %d\n",
						pHeader->length);
	(void)fprintf(stdout,	"SrvReply: Service Class = %d\n",
						MTMServerId.srv_type);
	(void)fprintf(stdout,	"SrvReply: Process slot id = %d\n",
						MTMServerId.process_slot_id);
	(void)fprintf(stdout,	"SrvReply: Client Sd = %d\n",
						MTMServerId.client_sd);
	(void)fprintf(stdout,	"SrvReply: Client Port = %d\n",
						MTMServerId.client_port);
	(void)fflush(stdout);
#endif

	SvTimeout.value = 10;

	sca_SetupTimer((void *)SrvReply,&SvTimeout,(void *)srv_signal_catcher);

	/* If mtm stats is on , set the time field in MTM header to the current time in microseconds.
	*  Also set the wait time for the request message to MTMReplyTime.
	*/

	/* Calculate the current time in microseconds */
	if( MTM_STATS_STARTED )
	{
		gettimeofday(&time_value,&time_zone);
		time_value.tv_usec = ( time_value.tv_sec * 1000 * 1000 ) + time_value.tv_usec;
		pHeader->time_in = time_value.tv_usec;
		pHeader->request_time = MTMReplyTime;
	}

	rc = sca_msgsnd(MTMServerId.reply_qid,
		(struct msgbuf *)msg_buffer,
		pHeader->length+sizeof(MTM_MSG_HEADER),
		(int)0,
		&SvTimeout,
		return_code);

	sca_CancelTimer((void *)SrvReply, &SvTimeout);

	(void)free(msg_buffer);

	if (rc < 0)
	{
		if (*return_code != ETIME)
			MTM_LOG(*return_code);
		return;
	}

	/*
	*	Signal the MTM Process that a service reply is pending.
	*/
#ifdef DEBUG
	(void)fprintf(stdout,"SrvReply: signalling MTM %d\n",MTMServerId.mtm_process_id);
	(void)fflush(stdout);
#endif
	if ((rc = sca_write (	MTMServerId.fifo_fd,
				MTM_REPLY_MSG_FLAG,
				MTM_MSG_FLAG_SIZE)) == FAILURE)
	{
		MTM_LOG(errno);
		*return_code = errno;
		return;
	}

	return;
}

	
/*
*	srv_signal_catcher
*	[module number i.e. Future] [module name]
*
*	Description:
*
*	Returns:
*	SUCCESS or FAILURE
*
*/
void
srv_signal_catcher(int sig)
{
#ifdef DEBUG
	fprintf(stdout,"srv_signal_catcher: server PID %d caught signal %x\n",getpid(),sig);
	fflush(stdout);
#endif
	SvTimeout.flag = 1;
}

/*
*	exit_signal_catcher
*	[module number i.e. Future] [module name]
*
*	Description:
*
*	Returns:
*	SUCCESS or FAILURE
*/
void
exit_signal_catcher(int sig)
{
	char cmd[80];
	int  value;
#ifdef DEBUG
	(void)fprintf(stdout,"exit_signal_catcher:%d:server received signal %d\n",getpid(),sig);
	(void)fflush(stdout);
#endif
	switch(sig)
	{
		case SIGQUIT:
		case SIGTERM:
			SrvDisconnect((int)NULL);
/*dag Sep 18 98 to take care of signal handler conflict in gtm 4.0*/ 
			do {
				value = sprintf(cmd,"mupip stop %d",getpid());
			}
        		while (value < 0 && errno == EINTR);
#ifdef DEBUG
	(void)fprintf(stdout,"exit_signal_catcher:cmd %s\n",cmd);
	(void)fflush(stdout);
#endif
			(void)system(cmd);
			break;
		case SIGILL:	/*	Illegal Instruction 		*/
		case SIGIOT:	/*	I/O Trap 			*/
		case SIGFPE: 	/*	Floating Point Exception	*/
		case SIGSEGV:	/*	Segmentation Violation		*/
		case SIGBUS:	/*	Bus Error			*/
		case SIGPIPE:
		default:
			abort();
			/* Dump core and exit */
	}
}




/*
*	SrvMTMId:
*	[module number i.e. Future] [module name]
*
*	Description:	Get the name of the MTM process that is pointed by 
*					environment variable SCA_CS_ST_service_type
*
*	Returns:
*/

void 
SrvMTMId(	int count,
		char *srv_type_name,
		STR_DESCRIPTOR *mtm_id)
{
	char *env_val;
	char env_name [MAX_NAME_LEN];
	char *ptr;
	int  value;
/*dag Sep 18 98 to take care of signal handler conflict in gtm 4.0*/ 
	do {
		value = sprintf (env_name, "%s_%s", MTM_SCA_CS_ST, srv_type_name);
	}
        while (value < 0 && errno == EINTR);

	/*
	 * replace '$' with '_'
	 */
	ptr = env_name;
	while (*ptr != '\0')
	{
		if (*ptr == DOLLAR_SIGN)
			*ptr = UNDERSCORE;
		ptr ++;
	}

#ifdef DEBUG
	(void)fprintf(stdout,"SrvMTMId: env_name %s\n",env_name); 
	(void)fflush(stdout);
#endif

	env_val = getenv (env_name);

	if (env_val != NULL)
		strcpy (mtm_id->str, env_val);
	else
		(mtm_id->str)[0] = '\0';

	mtm_id->length=strlen(mtm_id->str);

	return;
}

#ifdef DEBUG	
void
FFlush(	int count)
{
	(void)fprintf(stdout,"Flushing I/O\n");
	(void)fflush(stdout);
	(void)fflush(stderr);
}
#endif
