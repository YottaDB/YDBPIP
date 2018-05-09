/*
*	mtmcntrl.c - Sanchez Message Transport Manager for UNIX
*
*	Copyright(c)1992 Sanchez Computer Associates, Inc.
*	All Rights Reserved
*
*	ORIG:	Dan Russell - Design and implementation of original 
*	Message Transport Manager for VMS
*	ORIG:	Sara G. Walters - 11 Jan 1995
*
*	DESC:
*
*   $Id: mtmcntrl.c,v 1.1 2000/06/01 00:45:35 lyh Exp lyh $
*   $Log:	mtmcntrl.c,v $
 * Revision 2.14  07/02/12  thoniyim ()
 * Modified mtm_start_stats() to return MTM_STATS_RUNNING, if the stats
 * are already running. Modified mtm_get_stats() to check if stats are 
 * available to display. Modified mtm_start_stats(), mtm_stop_stats() and
 * mtm_get_stats() to check if cHeader->param1 is null.
 *
 * Revision 2.13  05/12/06  paulj ()
 * Added three more control messages(STARTSTAT/STOPSTAT/GETSTAT)
 * to handle MTM Stats requests
 *
 * Revision 2.12  00/07/07  11:57:35  11:57:35  lyh ()
 * added string.h for strlen() - resolve compiler warning when porting
 * to other platforms.
 * 
 * Revision 2.11  00/07/06  17:17:38  17:17:38  lyh ()
 * Removed certain restrictions for tcp client (MTM v2.0.1)
 * 
 * Revision 2.10  00/06/02  13:24:10  13:24:10  lyh ()
 * Changes as a result of porting to other platforms.
 * 
 * Revision 2.9  00/05/22  11:55:57  11:55:57  lyh ()
 * Fix LV parameters in mtm_send_reply DEBUG section as a result of S80 testing
 * 
 * Revision 2.8  00/04/06  14:54:26  14:54:26  lyh ()
 * added RECORD_DELIMITER in mtm_sv_clean section
 * 
 * Revision 2.7  00/03/30  13:41:33  13:41:33  lyh ()
 * Minor correction
 * 
 * Revision 2.6  00/03/29  09:34:58  09:34:58  lyh ()
 * Changed length format to pattern matching instead of using option
 * 
 * Revision 2.5  00/03/27  15:56:18  15:56:18  lyh ()
 * wogm release
 * 
 * Revision 2.4  00/03/13  14:52:00  14:52:00  lyh ()
 * Minor change in jounalling condition
 * 
 * Revision 2.3  00/03/13  14:20:54  14:20:54  lyh ()
 * Check pointer to avoid segment violation error
 * 
 * Revision 2.2  00/03/03  15:10:48  15:10:48  lyh ()
 * sand comber release
 * 
 * Revision 2.1  00/01/17  11:16:09  11:16:09  lyh ()
 * storm trooper release
 * 
 * Revision 1.4  99/12/29  16:28:20  16:28:20  lyh ()
 * modified mtm_send_msg and got it to work
 * 
 * Revision 1.3  99/12/28  13:21:28  13:21:28  lyh ()
 * redo mtm_get_version section
 * 
 * Revision 1.2  99/12/28  11:13:37  11:13:37  lyh ()
 * added 3 new control messages: SENDMSG, GETVER, GETPARAM
 * 
 * Revision 1.1  99/12/27  15:59:04  15:59:04  lyh ()
 * Initial revision
 * 
 * Revision 1.9  96/04/24  12:54:47  12:54:47  zengf (Fan Zeng)
 * Fix bug in which server stats are not zero-ed out.
 * 
 * Revision 1.7  96/04/10  17:21:23  17:21:23  zengf (Fan Zeng)
 * General cleaning up
 * 
 * Revision 1.6  96/03/13  10:02:10  10:02:10  zengf (Fan Zeng)
 * prepare for removing signals
 * 
 * Revision 1.5  96/02/28  17:28:07  17:28:07  zengf (Fan Zeng)
 * substantially rewrite MTM and the APIs.
 * 
 * Revision 1.4  96/02/05  16:36:48  16:36:48  zengf (Fan Zeng)
 * check in changes made by Sara G. Walters
 * 
 * Revision 1.3  95/07/19  14:16:26  14:16:26  rcs ()
 * Bug fixes as a result of MTM System Test
 * 
 * Revision 1.2  95/05/22  14:49:29  14:49:29  sca ()
 * sgI VMS
 * 
*   $Revision: 2.12 $
*
*/

#include	<ctype.h>
#include	<stdio.h>
#include	<errno.h>
#include	<time.h>
#include	<sys/time.h>
#include	<signal.h>
#include	<sys/ipc.h>
#include	<sys/msg.h>
#include	<string.h>
#include	"./scatype.h"
#include	"./mtm.h"
#include	"./mtmerrno.h"
#include	"./mtmext.h"

/*
*	Prototypes for static Functions
*/
static void mtm_stop(void);

static void mtm_add_server(void);

static void mtm_delete_server(void);

static void mtm_reject_clients(SLONG);

static void mtm_jrnl(void);

static void mtm_jrnl_on(SLONG);

static void mtm_jrnl_off(SLONG);

static void mtm_pending_msg(void);

static void mtm_clstat_msg(void);

static void mtm_svstat_msg(void);

static void mtm_send_reply(MTM_MSG_HEADER *);

static time_t mtm_time_elapsed(time_t);

static void mtm_find_zombies(SLONG);

static void mtm_send_msg(void);

static void mtm_get_version(void);

static void mtm_get_param(void);

static void mtm_sv_clean(void);

static void mtm_stats(void);

static void mtm_start_stats(void);

static void mtm_stop_stats(void);

static void mtm_get_stats(void);

int clean_stbl_entry(MTM_SERVER_TYPE_TABLE *, int *, int *, int *, int *);

void reset_server_entry(MTM_PROCESS_TABLE *);

/*
*	mtm_control_msg
*	[module number i.e. Future] [module name]
*
*	Description:
*	Receives and Parses an MTM control msg, 
*	then calls the correct control function.
*
*	Returns:
*	SUCCESS or FAILURE
*/
RETURNSTATUS
mtm_control_msg(void)
{
	RETURNSTATUS 	rc = SUCCESS;
	char 		*ptr = (char *)NULL;
	int register	i;
	MTM_MSG_HEADER	notification;
	SLONG		return_code;
	MTM_CNTRL_MSG	*cHeader;

	/*
	*	Loop until all control msgs are read off of the Server control queue.
	*/
	for(;;)
	{
		/*
		*	Initialize in case of failure
		*/
		notification.return_code = FAILURE;

		/*
		*	Set up the alarm here
		*/
		MTMTimeout.value = 10;

		sca_SetupTimer((void *)mtm_control_msg, &MTMTimeout, (void *)mtm_alarm_catcher);

		/*
		*	Receive control message
		*/
		rc = sca_msgrcv(MTMControlQid,
				(struct msgbuf *)MTMMsg,
				sizeof(MTM_CNTRL_MSG),
				(long)MTMProcessId,
				(int)IPC_NOWAIT,
				&MTMTimeout,
				&return_code);

		/*
		*	Cancel the timer here
		*/
		sca_CancelTimer((void *)mtm_control_msg, &MTMTimeout);

		/*
		*	Check for error
		*/
		if (rc <= 0)
		{
			if (return_code != ENOMSG)
			{
				MTM_EFD(return_code);
				return FAILURE;
			}
			return SUCCESS;
		}

		/*
		*	Check if control message header is usable
		*/
		cHeader = (MTM_CNTRL_MSG *)MTMMsg;
		if (cHeader == NULL)
		{
			notification.reason_code = EFAULT;
			MTM_EFD(notification.reason_code);
			(void)mtm_send_reply(&notification);
			return FAILURE;
		}

		/*
		*	At this point we have a valid control message.
		*/
		if((cHeader->cmd != STOP) 
			&& (cHeader->cmd != ADDSRV) 
			&& (cHeader->cmd != GETPARAM)
			&& (cHeader->cmd != GETVER)
			&& (TotalActiveSrvs == 0))
		{
			notification.reason_code = MTM_NO_ACTIVE_SRVS;
			MTM_EFD(notification.reason_code);
			(void)mtm_send_reply(&notification);
		}
		else
		{
			switch(cHeader->cmd)
			{
				case STOP:
					(void)mtm_stop();
					break;
				case ADDSRV:
					(void)mtm_add_server();
					break;
				case DELSRV:
					(void)mtm_delete_server();
					break;
				case FIND_ZOMBIES:
					(void)mtm_find_zombies((SLONG)TRUE);
					break;
				case JRNL:
					(void)mtm_jrnl();
					break;
				case PEND:
					(void)mtm_pending_msg();
					break;
				case CLSTAT:
					(void)mtm_clstat_msg();
					break;
				case SVSTAT:
					(void)mtm_svstat_msg();
					break;
				case SENDMSG:
					(void)mtm_send_msg();
					break;
				case GETVER:
					(void)mtm_get_version();
					break;
				case GETPARAM:
					(void)mtm_get_param();
					break;
				case SVCLEAN:
					(void)mtm_sv_clean();
					break;
				case STARTSTAT:
					(void)mtm_start_stats();
					break;
				case STOPSTAT:
					(void)mtm_stop_stats();
					break;
				case GETSTAT:
					(void)mtm_get_stats();
					break;
				default:
					notification.reason_code= MTM_INVALID_CMD;
					MTM_EFD(notification.reason_code);
					(void)mtm_send_reply(&notification);
					return FAILURE;
   			}
		}
	}
	return SUCCESS;
}

/*
*	mtm_stop
*	[module number i.e. Future] [module name]
*
*	Description:
*	Shutsdown the Message Transport Layer.
*	Replies to server on success or failure.
*	Writes errors and logging to required files.
*
*	Returns:
*
*/
static void
mtm_stop(void)
{
	MTM_MSG_HEADER	notification;
	MTM_CNTRL_MSG	*cHeader;

	notification.return_code = SUCCESS;
	notification.reason_code= MTM_STOP_COMMAND_PROCESSED;
	(void)mtm_send_reply(&notification);

	/*
	*	Pause to enable application time to
	*	retrieve reply message.
	*/
	sleep(1);

	/*
	*	Check if control message header is usable.
	*	Even if it's unusable, we'll have to continue with the
	*	shutdown command.
	*/
	cHeader = (MTM_CNTRL_MSG *)MTMMsg;
	if (cHeader == NULL)
	{
		MTM_EFD(EFAULT);
		MTMShutDownPending = TRUE;
		return;
	}

	/*
	*	Examine the first param, which defines the type of shutdown
	*	- immediate or controlled.
	*/
	if( cHeader->param1[0] == STOP_IMMEDIATE)
		(void)mtm_shutdown();
	else
		MTMShutDownPending = TRUE;
}

/*
*	mtm_add_server
*	[module number i.e. Future] [module name]
*
*	Description:
*	Adds a server to the Message Transport Layer.
*	Replies to server on success or failure.
*	Writes errors and logging to required files.
*
*	A new server proc is registering.  Reject it if in shutdown mode or
*	if maximum number of srv has been reached.
*
*	If the server proc is already connect, simply return the same ID.
*
*	Otherwise:
*	If first proc of this type server type, create msg queue
*	and create entry in proc table, assign a proc slot id and
*	set up the server connect information table entries.
*
*
*	Returns:
*	void
*/
static void
mtm_add_server(void)
{
	RETURNSTATUS		rc = SUCCESS;
	char 			*proc_name = (char *)NULL;
	SLONG   		pid;
	SLONG 			q_key;
	register int 		i;
	SLONG 			next_slot = -1;
	struct msqid_ds 	q_data;
	MTM_MSG_HEADER		notification;
	MTM_SERVER_TYPE_TABLE 	*srv_tbl_entry = (MTM_SERVER_TYPE_TABLE *)NULL;
	struct timeval		time_val;
	struct timezone		time_zone;
	SLONG			srv_type;
	time_t			cal_time;
	MTM_CNTRL_MSG	*cHeader;
	MTM_MSG_HEADER	*pHeader;

	(void)mtm_find_zombies((SLONG)FALSE);

	/*
	*	Initialize notification header.
	*/
	notification.return_code = FAILURE;

	/*
	*	Check if control message header is usable
	*/
	cHeader = (MTM_CNTRL_MSG *)MTMMsg;
	if (cHeader == NULL)
	{
		notification.reason_code = EFAULT;
		MTM_EFD(notification.reason_code);
		(void)mtm_send_reply(&notification);
		return;
	}

	/*
	 * look up the server type from the server type name
	 */
	if ( (srv_type = mtm_get_server_type(cHeader->param1, TRUE))
				== FAILURE)
	{
		notification.reason_code= MTM_NO_SRV_TYPE;
		MTM_EFD(notification.reason_code);
		(void)mtm_send_reply(&notification);
		return;
  	}

	notification.srv_type = srv_type;

	/*
	*	Get the time
	*/
	gettimeofday (&time_val, &time_zone);

	/*
	*	Get the UNIX process Id
	*	The header.pid field in the msg buffer is set by the server 
	*	proc when it is issuing a connect reqst.
	*/
	pHeader = (MTM_MSG_HEADER *)MTMMsg;
	if (pHeader == NULL)
	{
		notification.reason_code = EFAULT;
		MTM_EFD(notification.reason_code);
		(void)mtm_send_reply(&notification);
		return;
	}

	pid = pHeader->pid;

#ifdef DEBUG
	(void)fprintf(stdout,"mtm_add_server: Process id %d\n",pid);
	(void)fprintf(stdout,"mtm_add_server: Server type %d\n",srv_type);
	(void)fflush(stdout);
#endif

	/*
	*	Log a message
	*/
	if (MTMLogFp != NULL)
	{
		time(&cal_time);
		fprintf(MTMLogFp, "************************************\n");
		fprintf(MTMLogFp, "Adding Server for Process PID: %d\n", pid);
		fprintf(MTMLogFp, "                 Current Time: %s\n", ctime(&cal_time));
		fprintf(MTMLogFp, "			Total Active Servers: %d\n", MTMSrvTbl[srv_type].active_servers);
		fflush(MTMLogFp);
	}

   	if (MTMShutDownPending == TRUE)
	{
		notification.reason_code= MTM_SHUTDOWN_PENDING;
		MTM_EFD(notification.reason_code);
		(void)mtm_send_reply(&notification);
		return;
  	}

	srv_tbl_entry = &MTMSrvTbl[srv_type];

   	/* 	
	*	Check to see if the server process is already connect.  If same
	* 	server send error msg indicating duplicate connection.
	*/
   	for (i=0; i<MAX_SRV_PROCESSES; ++i)
	{
		if (srv_tbl_entry->proc_tbl[i].state == IN_USE &&
			(srv_tbl_entry->proc_tbl[i].pid == pid))
		{
			/*
			*	Already connected, simply return the same server slot id.
			*/
  			notification.return_code = SUCCESS;
			notification.reason_code= SUCCESS;
			notification.slot_id = i + 1;
			(void)mtm_send_reply(&notification);
			return;
		}
		else
		{
			/*
			*	Find a free slot in the proc table for this server type
			*/
			if((srv_tbl_entry->proc_tbl[i].state == FREE) 
				&& (next_slot == -1))
				next_slot = i;
		}
	}

	if (next_slot == -1)
	{
		notification.reason_code= MTM_TOOMANY;
		MTM_EFD(notification.reason_code);
		(void)mtm_send_reply(&notification);
		return;
  	}

   	if(srv_tbl_entry->active_servers >= MAX_SRV_PROCESSES)
	{
		notification.reason_code= MTM_TOOMANY;
		MTM_EFD(notification.reason_code);
		(void)mtm_send_reply(&notification);
		return;
	}

	if(MTMSrvTbl[srv_type].time_stats_started == 0)
		MTMSrvTbl[srv_type].time_stats_started = time_val.tv_sec;
						
	srv_tbl_entry->active_servers++;

	TotalActiveSrvs++;

	/* Update MTM Stats table if stats is on for the server type */

	if(MTMStatsTbl[srv_type].mtm_stats_on == TRUE)
	{
		if(MTMStatsTbl[srv_type].active_servers == 0)
		{
			MTMStatsTbl[srv_type].active_servers == srv_tbl_entry->active_servers;
			strcpy(MTMStatsTbl[srv_type].srv_type_name,srv_tbl_entry->srv_type_name);
		}
		else 
		{
			if(MTMStatsTbl[srv_type].active_servers < srv_tbl_entry->active_servers )
				MTMStatsTbl[srv_type].active_servers = srv_tbl_entry->active_servers;
		}
	}

	/*
	*	The variable next_slot (i.e. [next_slot]) is the index 
	*	into the proc table
	*/
	srv_tbl_entry->proc_tbl[next_slot].pid = pid;
	(void)strcpy(srv_tbl_entry->proc_tbl[next_slot].process_name,
				cHeader->param2);
	srv_tbl_entry->proc_tbl[next_slot].time_connected = time_val.tv_sec;
	srv_tbl_entry->proc_tbl[next_slot].state = IN_USE;
	srv_tbl_entry->proc_tbl[next_slot].srv_type = srv_type;

  	notification.return_code = SUCCESS;
	notification.reason_code= SUCCESS;
	notification.slot_id= next_slot+1;
	notification.srv_mode = MTMAsyncMode;
	notification.format = MTMLength.format;
	notification.header = MTMLength.header;
	notification.lsize  = MTMLength.lsize;
	notification.hsize  = MTMLength.hsize;
	notification.lcount = MTMLength.lcount;
	notification.tcount = MTMLength.tcount;
	notification.length = sizeof(notification);

	(void)mtm_send_reply(&notification);

	/*
	*	Log another message
	*/
	if (MTMLogFp != NULL)
	{
		cal_time = srv_tbl_entry->proc_tbl[next_slot].time_connected;
		fprintf(MTMLogFp, "Added Server Slot ID: %d\n", next_slot);
		fprintf(MTMLogFp, "          Server PID: %d\n", pid);
		fprintf(MTMLogFp, "      Time Connected: %s\n", ctime(&cal_time));
		fprintf(MTMLogFp, "			Server Type: %s\n", MTMSrvTbl[srv_type].srv_type_name);
		fprintf(MTMLogFp, "Total Active Servers: %d\n", MTMSrvTbl[srv_type].active_servers);
		fprintf(MTMLogFp, "************************************\n");
		fflush(MTMLogFp);
	}

}

/*
*	mtm_delete_server
*	[module number i.e. Future] [module name]
*
*	Description:
*	Deletes a server from the Message Transport Layer.
*	Replies to server on success or failure.
*	Writes errors and logging to required files.
*
*	Requested to delete a specific server ID.
*
*	If this is the existing proc of a server type and msgs are pending
*	on the Server control queue for this server type, signal the proc
*	and wait for the reply. 
*	If reply(s) not received in timeout period, write error
*	msg.
*	If reply(s) received, send reply(s) to the MTM Process.
*
*	Otherwise, if the no msgs on server queue and any reqsts are pending,
*	write error msg.
*
*	Clear the entry in the MTMSrvTbl[].proc_tbl entry.
*
*	If this is the last proc of this type server type, delete the
*	msg queue, clear the Server Table entry for this server type.
*
*	Returns:
*	void
*/
static void
mtm_delete_server(void)
{
	RETURNSTATUS			rc = SUCCESS;
	struct msqid_ds			q_data;
	MTM_MSG_HEADER			notification;
	MTM_SERVER_TYPE_TABLE *srv_tbl_entry = (MTM_SERVER_TYPE_TABLE *)NULL;
	SLONG				slot_id;
	time_t				cal_time;
	MTM_CNTRL_MSG		*cHeader;
	MTM_MSG_HEADER		*pHeader;

	/*
	*	Initialize notification header.
	*/
	notification.return_code = FAILURE;

	/*
	*	Check if control message header is usable
	*/
	cHeader = (MTM_CNTRL_MSG *)MTMMsg;
	if (cHeader == NULL)
	{
		notification.reason_code = EFAULT;
		MTM_EFD(notification.reason_code);
		(void)mtm_send_reply(&notification);
		return;
	}

	/*
	*	The server id is the the process slot id in the process table.
	*	It was assigned to the process when it was added as 
	*	a server.
	*/
	slot_id = atoi (cHeader->param1) - 1;

#ifdef DEBUG
	(void)fprintf(stdout,"mtm_delete_server: Process slot id %d\n",slot_id);
	(void)fflush(stdout);
#endif
   	if((slot_id < 0) || (slot_id >= MAX_SRV_PROCESSES))
	{
		notification.reason_code= MTM_INVALID_SRVID;
		MTM_EFD(notification.reason_code);
		(void)mtm_send_reply(&notification);
		return;
   	}

	/*
	*	Check if MTM message header is usable
	*/
	pHeader = (MTM_MSG_HEADER *)MTMMsg;
	if (pHeader == NULL)
	{
		notification.reason_code = EFAULT;
		MTM_EFD(notification.reason_code);
		(void)mtm_send_reply(&notification);
		return;
	}
	srv_tbl_entry = &MTMSrvTbl[pHeader->srv_type];

	/*
	*	Log a message
	*/
	if (MTMLogFp != NULL)
	{
		cal_time = srv_tbl_entry->proc_tbl[slot_id].time_connected;
		fprintf(MTMLogFp, "************************************\n");
		fprintf(MTMLogFp, "Deleting Server Slot ID: %d\n", slot_id);
		fprintf(MTMLogFp, "             Server PID: %d\n",srv_tbl_entry->proc_tbl[slot_id].pid);
		fprintf(MTMLogFp, "         Time Connected: %s\n", ctime(&cal_time));
		fflush(MTMLogFp);
	}

	/*
	*	If no servers are active for this type server type - send error.
	*/
	if(srv_tbl_entry->active_servers == 0)
	{
		notification.reason_code= MTM_INVALID_SRVID;
		MTM_EFD(notification.reason_code);
		(void)mtm_send_reply(&notification);
		return;
	}

	/*
	*	If this is the last existing proc of this server type and
	*	there are client reqsts pending on the service queue, wait the proc
	*	to complete the outstanding reqsts.
	*/
	if(srv_tbl_entry->active_servers == 1)
	{
		if((rc = msgctl(srv_tbl_entry->server_type_qid,
						IPC_STAT,
						(struct msqid_ds *)&q_data)) == FAILURE)
		{
			notification.reason_code= errno;
			MTM_EFD(notification.reason_code);
			(void)mtm_send_reply(&notification);
			return;
		}

		if(q_data.msg_qnum > 0)
		{
			/*
			*	Messages exist on the queue. Wait MTM_PAUSE seconds before
			*	delete the server.
			*
			*	When the last server of a specific type is deleted, 
			*	send no server type msg to	any clients with msgs 
			*	in the queue.
			*/
			sleep(MTM_PAUSE);
			(void)mtm_reject_clients(srv_tbl_entry->server_type_qid);
		}
	}

	srv_tbl_entry->active_servers--;
	if(srv_tbl_entry->active_servers < 0)
		srv_tbl_entry->active_servers = 0;

	TotalActiveSrvs--;
	if(TotalActiveSrvs < 0)
		TotalActiveSrvs = 0;

	/*
	*	Clear the proc slot in the Server Table
	*/
	srv_tbl_entry->proc_tbl[slot_id].state = FREE;
	srv_tbl_entry->proc_tbl[slot_id].pid = DISCONNECTED;
	srv_tbl_entry->proc_tbl[slot_id].time_connected = 0;

	notification.return_code = SUCCESS;
	notification.reason_code= SUCCESS;
	(void)mtm_send_reply(&notification);

	/*	If this is the last server of this type, 
	*	clear the server entry in the server table,
	* 	respond with no server msg for any pending msgs for this server
	* 	type.
	*/
	if(srv_tbl_entry->active_servers == 0)
	{
		if(srv_tbl_entry->active_requests > 0)
			(void)mtm_reject_clients(srv_tbl_entry->server_type_qid);
		srv_tbl_entry->time_stats_started = 0;
		srv_tbl_entry->active_servers = 0;
		srv_tbl_entry->current_client_connects = 0;
		srv_tbl_entry->total_client_connects = 0;
		srv_tbl_entry->active_requests = 0;
		srv_tbl_entry->total_client_reqsts = 0;
		srv_tbl_entry->total_server_resps= 0;
		srv_tbl_entry->total_resp_time = 0;
		srv_tbl_entry->min_resp_time = MIN_RESP_DEFAULT;
		srv_tbl_entry->max_resp_time = 0;
		if(srv_tbl_entry->jrnl_on == TRUE)
			(void)fclose(srv_tbl_entry->jrnl_fd);
		srv_tbl_entry->jrnl_fd = (FILE *)NULL;
		srv_tbl_entry->jrnl_on = FALSE;
		srv_tbl_entry->srv_type_name[0] = '\0';
	}

	/*
	*	Log another message
	*/
	if (MTMLogFp != NULL)
	{
		time(&cal_time);
		fprintf(MTMLogFp, "Deleted Server Slot ID: %d \n", slot_id);
		fprintf(MTMLogFp, "          Current Time: %s\n", ctime(&cal_time));
		fprintf(MTMLogFp, "************************************\n");
		fflush(MTMLogFp);
	}

	return;
}

/*
*	mtm_reject_clients
*	[module number i.e. Future] [module name]
*
*	Description:
*	Sends a rejection messages to all clients.
*
*	Returns:
*/
static void
mtm_reject_clients(SLONG server_qid)
{
	MTM_SERVER_TYPE_TABLE *srv_tbl_entry = (MTM_SERVER_TYPE_TABLE *)NULL;
	for(;;)
	{
		/*	Send Message */
			break;
	}
}

/*
*	mtm_jrnl
*	[module number i.e. Future] [module name]
*
*	Description:
*	Receives and Parses an MTM JRNL msg, then calls the
*	jrnl (i.e. on/off) function.
*
*	Returns:
*	void
*
*/
static void
mtm_jrnl(void)
{
	RETURNSTATUS	rc = SUCCESS;
	register int	i;
	char 			jrnling_flag;
	MTM_MSG_HEADER	notification;
	SLONG			srv_type = 0;
	char			te[20];
	MTM_CNTRL_MSG	*cHeader;

	notification.return_code= FAILURE;

	/*
	*	Check if control message header is usable
	*/
	cHeader = (MTM_CNTRL_MSG *)MTMMsg;
	if (cHeader == NULL)
	{
		notification.reason_code = EFAULT;
		MTM_EFD(notification.reason_code);
		(void)mtm_send_reply(&notification);
		return;
	}

	if (cHeader->param2[0] == '*')
		srv_type = ALL;
	else 
	{
		srv_type = mtm_get_server_type(cHeader->param2,FALSE);

		/*
		*	If no servers are active this type server type - send error.
		*	Except in the case of ALL.
		*/
		if (srv_type == FAILURE)
		{
			notification.reason_code= MTM_INVALID_SRVID;
			MTM_EFD(notification.reason_code);
			(void)mtm_send_reply(&notification);
			return;
		}
	}

	/*
	*	First param (i.e. byte) in the param list
	*	is the jrnling on/off flag
	*/
	jrnling_flag = cHeader->param1[0];

	switch(jrnling_flag)
	{
		case JRNL_ON:
			(void)mtm_jrnl_on(srv_type);
			break;
		case JRNL_OFF:
			(void)mtm_jrnl_off(srv_type);
			break;
		default:
			notification.reason_code= MTM_JRNL_FLAG_INVALID;
			MTM_EFD(notification.reason_code);
			(void)mtm_send_reply(&notification);
	}

	return;
}

/*
*	mtm_jrnl_on
*	[module number i.e. Future] [module name]
*
*	Description:
*
*	Turn jrnling on, to server type specified (* = ALL), to file
*	specified.  If jrnling is already on for a server type, it will
*	remain on to the original file.  If * (ALL) reqst, turn on even if
*	server type is not yet active.
*
*	Returns:
*	void
*
*/
static void
mtm_jrnl_on(SLONG srv_type)
{
	RETURNSTATUS	rc = SUCCESS;
	MTM_MSG_HEADER	notification;
   	time_t  		time_value;
	int	register	i = 0;
	FILE			*jrnl_fd;
	MTM_CNTRL_MSG	*cHeader;

	/*
	*	Check if control message header is usable
	*/
	cHeader = (MTM_CNTRL_MSG *)MTMMsg;
	if (cHeader == NULL)
	{
		notification.return_code= FAILURE;
		notification.reason_code = EFAULT;
		MTM_EFD(notification.reason_code);
		(void)mtm_send_reply(&notification);
		return;
	}

#ifdef DEBUG
	(void)fprintf(stdout,"mtm_jrnl_on: Parameter 3 %s\n",cHeader->param3);
	(void)fflush(stdout);
#endif

	if(srv_type == ALL)
	{
		if ((jrnl_fd = fopen(MTMSrvTbl[srv_type].jrnl_name,"a")) == NULL)
		{
			notification.return_code = FAILURE;
			notification.reason_code = errno;
  		}
		else
		{
			for(i=0;i<MAX_SRV_TYPES;i++)
				if (MTMSrvTbl[i].jrnl_on != TRUE) 
				{
					MTMSrvTbl[i].jrnl_on = TRUE;
					MTMSrvTbl[i].jrnl_fd = jrnl_fd;
				}
			notification.return_code = SUCCESS;
			notification.reason_code = MTM_JRNL_ON;
		}
	}
	else
	{
		if((MTMSrvTbl[srv_type].jrnl_on == TRUE))
		{
			notification.return_code = SUCCESS;
			notification.reason_code = MTM_JRNL_ON;
		}

		(void)strcpy(MTMSrvTbl[srv_type].jrnl_name,
					cHeader->param3);
		
		if ((MTMSrvTbl[srv_type].jrnl_fd = fopen(MTMSrvTbl[srv_type].jrnl_name,"a")) == NULL)
		{
			notification.return_code = FAILURE;
			notification.reason_code = errno;
  		}
		else
		{
			notification.return_code = SUCCESS;
			notification.reason_code = MTM_JRNL_ON;
			MTMSrvTbl[srv_type].jrnl_on = TRUE;
   			time_value = time(NULL);
   			(void)fprintf(MTMSrvTbl[srv_type].jrnl_fd,"\n\n%s",ctime(&time_value));
			(void)fprintf(	MTMSrvTbl[srv_type].jrnl_fd,
							"- Journal turned on for server type %s to %s\n",
							MTMSrvTbl[srv_type].srv_type_name,
							MTMSrvTbl[srv_type].jrnl_name);
			(void)fflush(MTMSrvTbl[srv_type].jrnl_fd);
		}
	
	}

	MTM_EFD(notification.reason_code);
	(void)mtm_send_reply(&notification);
}

/*
*	mtm_jrnl_off
*	[module number i.e. Future] [module name]
*
*	Description:
*
*	Turn jrnling off, to server type specified (* = ALL).  Only
*	close the file if no server types are using it.
*
*	Returns:
*	void
*
*/
static void
mtm_jrnl_off(SLONG srv_type)
{
	RETURNSTATUS	rc = SUCCESS;
	MTM_MSG_HEADER	notification;
   	time_t  		time_value;
	int	register	i = 0;

	if(srv_type == ALL)
	{
		for(i=0;i<MAX_SRV_TYPES;i++)
		{
			notification.reason_code = SUCCESS;
			notification.reason_code= MTM_JRNL_OFF;
			MTMSrvTbl[i].jrnl_on = FALSE;
			MTMSrvTbl[i].jrnl_fd = (FILE *)NULL;
		}
	}
	else
	{
		if((MTMSrvTbl[srv_type].jrnl_on == TRUE))
		{
   			time_value = time(NULL);
   			(void)fprintf(MTMSrvTbl[srv_type].jrnl_fd,"\n%s",ctime(&time_value));

			(void)fprintf(	MTMSrvTbl[srv_type].jrnl_fd,
							" - Journal turned off for server type %s",
							MTMSrvTbl[srv_type].srv_type_name);
			(void)fclose(MTMSrvTbl[srv_type].jrnl_fd);
			notification.reason_code = SUCCESS;
			notification.reason_code= MTM_JRNL_OFF;
			MTMSrvTbl[srv_type].jrnl_on = FALSE;
			MTMSrvTbl[srv_type].jrnl_fd = (FILE *)NULL;
		}
		else
		{
			notification.return_code = FAILURE;
			notification.reason_code= MTM_NO_JRNL;
		}
	}

	MTM_EFD(notification.reason_code);
   	(void)mtm_send_reply(&notification);
}

/*
*	mtm_update_jrnl
*	[module number i.e. Future] [module name]
*
*	Description:
*
*	Update server type journal file (if open) with the request or reply
*	message as specified by message type.
*
*	Returns:
*	void
*
*/
void mtm_update_jrnl(	enum MTM_JRNL_MESSAGES 	msg_type,
				SLONG	srv_type,
				MTM_CLIENT_TABLE	*client)
{
   	time_t  time_value;
	char 	*msg = (char *)NULL;
	int		i = 0;
	int    stop;
	MTM_MSG_HEADER	*pHeader;

	/*
	*	Check if message header is usable
	*/
	pHeader = (MTM_MSG_HEADER *)MTMMsg;
	if (pHeader == NULL)
	{
		MTM_EFD(EFAULT);
		return;
	}

#ifdef DEBUG
	(void)fprintf(stdout,"mtm_update_jrnl: msg_type %d\n",msg_type);
	(void)fflush(stdout);
#endif
	if(MTMSrvTbl[srv_type].jrnl_on == TRUE)
	{ 
#ifdef DEBUG
	(void)fprintf(stdout,"mtm_update_jrnl: Journal File is Opened\n");
	(void)fflush(stdout);
#endif
   		time_value = time(NULL);
   		fprintf(MTMSrvTbl[srv_type].jrnl_fd,"\n%s",ctime(&time_value));


		switch(msg_type)
		{
			case REQST_MSG:
#ifdef DEBUG
	(void)fprintf(stdout,
		" - Request message from address %s, port %d, to server type %s\n",
		client->ip_address,
		client->port,
		MTMSrvTbl[srv_type].srv_type_name);
	(void)fflush(stdout);
#endif
				(void)fprintf(	MTMSrvTbl[srv_type].jrnl_fd,
						" - Request message from address %s, port %d, to server type %s\n",
						client->ip_address,
						client->port,
						MTMSrvTbl[srv_type].srv_type_name);
				msg=(char *)(MTMMsg + sizeof(MTM_MSG_HEADER));
				msg[pHeader->length] = '\0';
				msg++;
				i=0;
				stop = pHeader->length;
				(void)fprintf(MTMSrvTbl[srv_type].jrnl_fd,"\n");
				for (i=0;i<stop;i++)
				{
					if (msg[i] >= ' ')
						(void)fprintf(MTMSrvTbl[srv_type].jrnl_fd," %c",msg[i]);
					else
						(void)fprintf(MTMSrvTbl[srv_type].jrnl_fd," .%d.",msg[i]);
				}
				(void)fprintf(MTMSrvTbl[srv_type].jrnl_fd,"\n\n");
				for (i=0;i<stop;i++)
					(void)fprintf(MTMSrvTbl[srv_type].jrnl_fd," %d ",msg[i]);
				(void)fprintf(MTMSrvTbl[srv_type].jrnl_fd,"\n");
				break;
			case RESP_MSG:
#ifdef DEBUG
	(void)fprintf(stdout,
		" - Reply message from server type %s to address %s, %d\n",
		MTMSrvTbl[srv_type].srv_type_name,
		client->ip_address,
		client->port);
	(void)fflush(stdout);
#endif
				(void)fprintf(	MTMSrvTbl[srv_type].jrnl_fd,
						" - Reply message from server type %s to address %s, %d\n",
						MTMSrvTbl[srv_type].srv_type_name,
						client->ip_address,
						client->port);
				msg=(char *)(MTMMsg + sizeof(MTM_MSG_HEADER));
				msg[pHeader->length] = '\0';
				msg++;
				i=0;
				stop = pHeader->length;
				(void)fprintf(MTMSrvTbl[srv_type].jrnl_fd,"\n");
				for (i=0;i<stop;i++)
				{
					if (msg[i] >= ' ')
						(void)fprintf(MTMSrvTbl[srv_type].jrnl_fd," %c",msg[i]);
					else
						(void)fprintf(MTMSrvTbl[srv_type].jrnl_fd," .%d.",msg[i]);
				}
				(void)fprintf(MTMSrvTbl[srv_type].jrnl_fd,"\n\n");
				for (i=0;i<stop;i++)
					(void)fprintf(MTMSrvTbl[srv_type].jrnl_fd," %d ",msg[i]);
				(void)fprintf(MTMSrvTbl[srv_type].jrnl_fd,"\n");
				break;
		}
		(void)fflush(MTMSrvTbl[srv_type].jrnl_fd);
	}
}

/*
*	mtm_pending_msg
*	[module number i.e. Future] [module name]
*
*	Description:
*	Construct and send a reply for all server typees indicating if they have
*	msgs pending and the wait time so far.  Format for each msg:
*
*	  ID | Server type | Process name | connect time |
*	  Client waiting if msg pending | wait time
*
*	Total reply is a series of these msgs, one for each connect
*	server, separated by <FS>
*
*
*	Returns:
*	void
*
*/
static
void mtm_pending_msg(void)
{
	register int 		i,j,k;
	char			*ptr = (char *)NULL;
	SLONG			msg_size = 0;
	time_t			time_elapsed;
	MTM_MSG_HEADER		*notification = (MTM_MSG_HEADER *)NULL;

	/*
	*	Check if message header is usable
	*/
	notification = (MTM_MSG_HEADER *)MTMMsg;
	if (notification == NULL)
	{
		MTM_EFD(EFAULT);
		return;
	}

	/*
	*	Initialize in case of failure.
	*/
	notification->return_code = FAILURE;

	/*
	*	Determine size of buffer required for message
	*/
	for(i=0;i<MAX_SRV_TYPES;i++)
	{
		if(MTMSrvTbl[i].active_servers > 0)
				msg_size += MTM_STR_LEN;

		for(j=0;j<MTMMaxClient;j++)
		{
        		if(MTMSrvTbl[i].cl_tbl[j].state == REQUEST_PENDING)
				msg_size += MTM_STR_LEN;
		}
	}

    	if(msg_size == 0)
	{
		notification->reason_code= MTM_NO_SRV_CONNECTED;
		MTM_EFD(notification->reason_code);
		(void)mtm_send_reply(notification);
		return;
	}
	else if(msg_size > MTMMaxMsgSize)
	{
		notification->reason_code= EMSGSIZE;
		MTM_EFD(notification->reason_code);
		(void)mtm_send_reply(notification);
		return;
	}

	(void)memset((char *)(MTMMsg+sizeof(MTM_MSG_HEADER)),
				0,
				MAX_MSG_SIZE);
	ptr = (char *)(MTMMsg+sizeof(MTM_MSG_HEADER));

	for(i=0;i<MAX_SRV_TYPES;i++)
	{
		if(MTMSrvTbl[i].active_servers > 0)
		{
			for(j=0;j<MAX_SRV_PROCESSES;j++)
			{
				time_elapsed = 
					mtm_time_elapsed(MTMSrvTbl[i].proc_tbl[j].time_connected);

				if(MTMSrvTbl[i].proc_tbl[j].state == IN_USE)
				{
					if(ptr[0] == '\0')
						(void)sprintf(ptr,"%d|%d|%s|%d",
								j,
								i,
								MTMSrvTbl[i].proc_tbl[j].process_name,
								time_elapsed * 1000);
					else
						(void)sprintf(ptr,"%s%d|%d|%s|%d",
								ptr,
								j,
								i,
								MTMSrvTbl[i].proc_tbl[j].process_name,
								time_elapsed * 1000);
	
					/*
					*	Put the info for clients with pending messages
					*	into the message.
					*/
					for(k=0;k<MTMMaxClient;k++)
					{
        				if((MTMSrvTbl[i].cl_tbl[k].srv_pid == MTMSrvTbl[i].proc_tbl[j].pid)
        					&& (MTMSrvTbl[i].cl_tbl[k].state == REQUEST_PENDING))
						{
							time_elapsed = 
							mtm_time_elapsed(MTMSrvTbl[i].cl_tbl[j].recv_time);
							(void)sprintf(	ptr,
									"%s|%d/%s|%d",
									ptr,
									MTMSrvTbl[i].cl_tbl[j].port,
									MTMSrvTbl[i].cl_tbl[j].ip_address,
									time_elapsed * 1000);
						}
					}
					(void)sprintf(ptr,"%s%c",ptr,RECORD_DELIMITER);
				}
			}
		}
	}

	ptr = (char *)(MTMMsg+sizeof(MTM_MSG_HEADER));
	notification->length = strlen(ptr);
	notification->return_code = SUCCESS;
	notification->reason_code = MTM_PEND;
	(void)mtm_send_reply(notification);
}

/*
*	mtm_clstat_msg
*	[module number i.e. Future] [module name]
*
*	Description:
*
*	Construct and send a reply with statistics for all clients that
*	are connected.  The reply msg consists of the following fields,
*	separated by <FS>:
*
*	  number of currently connect clients
*	  max number of clients connect to date
*	  client specific info separated by up-bars "|":
*		client id
*		total connect time (in milliseconds)
*		time since last msg (in milliseconds)
*		number of reqst msgs
*		number of reply msgs
*		reqst active indicator (0=no,1=in queue,2=at server)
*		server id if reqst active indicator = 2
*	  repeat client info for each client connect
*
*	Returns:
*	void
*
*/
static void 
mtm_clstat_msg(void)
{
   	RETURNSTATUS	rc = SUCCESS;
   	register int	i,j;
	SLONG		msg_size = 0;
	SLONG		current_connected = 0;
	char		reqst_active;
	char		*ptr = (char *)NULL;
	MTM_MSG_HEADER	*notification = (MTM_MSG_HEADER *)NULL;
	struct msqid_ds q_data;
	time_t		time_connected;
	time_t		recv_time;

	/*
	*	Check if message header is usable
	*/
	notification = (MTM_MSG_HEADER *)MTMMsg;
	if (notification == NULL)
	{
		MTM_EFD(EFAULT);
		return;
	}

	/*
	*	Initialize in case of failure.
	*/
	notification->return_code = FAILURE;

	/*
	*	Determine the size required for the message buffer
	*/

	/*
	*	one byte for current connected, 
	*	one byte for total connected per server type
	*/
	for(i=0;i<MAX_SRV_TYPES;i++)
	{
		/*
		*	Determine number of clients currently 
		*	connected and total connected.
		*/
		current_connected += MTMSrvTbl[i].current_client_connects;
	}

	msg_size = (current_connected*MTM_STR_LEN);

	if(msg_size == 0)
	{
		if(TotalClientsConnected == 0)
		{
			notification->reason_code= MTM_NO_CL_CONNECTED;
			MTM_EFD(notification->reason_code);
			(void)mtm_send_reply(notification);
			return;
		}
		else
			msg_size = MTM_STR_LEN;
	}
	else if(msg_size > MTMMaxMsgSize)
	{
		notification->reason_code= EMSGSIZE;
		MTM_EFD(notification->reason_code);
		(void)mtm_send_reply(notification);
		return;
	}

	(void)memset((char *)(MTMMsg+sizeof(MTM_MSG_HEADER)),
				0,
				MAX_MSG_SIZE);
	ptr = (char *)(MTMMsg+sizeof(MTM_MSG_HEADER));

	/*
	*	Build the message
	*/
	(void)sprintf(ptr,"%d%c%d%c",current_connected, RECORD_DELIMITER,
				TotalClientsConnected, RECORD_DELIMITER);

	for(i=0;i<MAX_SRV_TYPES;i++)
	{
		for(j=0;j<MTMMaxClient;j++)
		{
			if(MTMSrvTbl[i].cl_tbl[j].state != DISCONNECTED)
			{
				switch(MTMSrvTbl[i].cl_tbl[j].state)
				{
					case REQUEST_PENDING:
						if((rc = msgctl(MTMSrvTbl[i].server_type_qid,
								IPC_STAT,
								(struct msqid_ds *)&q_data)) == FAILURE)
						{
							notification->reason_code = errno;
							MTM_EFD(notification->reason_code);
							(void)mtm_send_reply(notification);
							return;
						}

						if(q_data.msg_qnum > 0)
							reqst_active = '1';
						else
							reqst_active = '2';
						break;
					case CONNECTED:
						reqst_active = '0';
						break;
					default:
						notification->reason_code = errno;
						MTM_EFD(notification->reason_code);
						(void)mtm_send_reply(notification);
						return;
				}

				time_connected =
					mtm_time_elapsed(MTMSrvTbl[i].cl_tbl[j].time_connected);

				recv_time =
					mtm_time_elapsed(MTMSrvTbl[i].cl_tbl[j].recv_time);

				if(ptr[0] == '\0')
				{
					sprintf(ptr,"%d/%s|%d|%d|%d|%d|%c|%d",
						MTMSrvTbl[i].cl_tbl[j].port,
						MTMSrvTbl[i].cl_tbl[j].ip_address,
						time_connected * 1000,
						recv_time * 1000,
						MTMSrvTbl[i].cl_tbl[j].reqst_msgs,
						MTMSrvTbl[i].cl_tbl[j].resp_msgs,
						reqst_active,
						i);
				}
				sprintf(ptr,"%s%d/%s|%d|%d|%d|%d|%c|%d",
					ptr,
					MTMSrvTbl[i].cl_tbl[j].port,
					MTMSrvTbl[i].cl_tbl[j].ip_address,
					time_connected * 1000,
					recv_time * 1000,
					MTMSrvTbl[i].cl_tbl[j].reqst_msgs,
					MTMSrvTbl[i].cl_tbl[j].resp_msgs,
					reqst_active,
					i);
#ifdef DEBUG
	(void)fprintf(stdout,"mtm_clstat_msg: port %d ip %s\n",
					MTMSrvTbl[i].cl_tbl[j].port,
					MTMSrvTbl[i].cl_tbl[j].ip_address);
	(void)fprintf(stdout,"mtm_clstat_msg: reqsts %d resp %d\n",
					MTMSrvTbl[i].cl_tbl[j].reqst_msgs,
					MTMSrvTbl[i].cl_tbl[j].resp_msgs);
	(void)fprintf(stdout,"mtm_clstat_msg: i %d\n",i);
	(void)fprintf(stdout,"mtm_clstat_msg: j %d\n",j);
	(void)fflush(stdout);
#endif
				(void)sprintf(ptr,"%s%c",ptr,RECORD_DELIMITER);
			}
		}
	}

	ptr = (char *)(MTMMsg+sizeof(MTM_MSG_HEADER));
	notification->length = strlen(ptr);
	notification->return_code = SUCCESS;
	notification->reason_code = MTM_CLSTAT;
 	(void)mtm_send_reply(notification);
}

/*
*	mtm_svstat_msg
*	[module number i.e. Future] [module name]
*
*	Description:
*	Construct and send a reply with statistics for all server types that
*	are active.  Format for each msg is the following information
*	separated by up-bars (|).  Total reply is these msgs separated
*	by <FS> characters.
*
*	  type
*	  total time (in milliseconds) server type has been active
*	  number of active srv
*	  number of client reqst msgs
*	  number of client resp msgs
*	  average resp time (in milliseconds)
*	  minimum resp time (in milliseconds)
*	  maximum resp time (in milliseconds)
*
*	Returns:
*	void
*
*/
static void
mtm_svstat_msg(void)
{
   	register int		i,j;
	SLONG			msg_size = 0;
	float			average_resp_time = 0;
	float			min_resp_time = 0;
	float			max_resp_time = 0;
	char			*ptr = (char *)NULL;
	MTM_MSG_HEADER		*notification = (MTM_MSG_HEADER *)NULL;
	time_t			time_elapsed;
	short			clear_counter;
	char			slot_state, server_state, process_state;
	float			cpu_time;
	MTM_PROCESS_TABLE	*temp;
	MTM_CNTRL_MSG		*cHeader;

	/*
	*	Check if control message header is usable
	*/
	cHeader = (MTM_CNTRL_MSG *)MTMMsg;
	if (cHeader == NULL)
	{
		MTM_EFD(EFAULT);
		return;
	}

	if  ( cHeader->param1[0] == ZERO_COUNTERS)
		clear_counter = 1;
	else
		clear_counter = 0;

	notification = (MTM_MSG_HEADER *)MTMMsg;
	if (notification == NULL)
	{
		MTM_EFD(EFAULT);
		return;
	}

	/*
	*	Initialize in case of failure.
	*/
	notification->return_code = FAILURE;

	/*
	*	Determine the size of the message buffer
	*/
	for(i=0;i<MAX_SRV_TYPES;i++)
	{
		if (MTMSrvTbl[i].active_servers > 0)
		{
			msg_size += MAX_SRV_PROCESSES * MTM_STR_LEN;
		}
	}

	if(msg_size == 0)
	{
		notification->reason_code= MTM_NO_SRV_CONNECTED;
		MTM_EFD(notification->reason_code);
		(void)mtm_send_reply(notification);
		return;
	}
	else if(msg_size > MTMMaxMsgSize)
	{
		notification->reason_code= EMSGSIZE;
		MTM_EFD(notification->reason_code);
		(void)mtm_send_reply(notification);
		return;
	}

	(void)memset((char *)(MTMMsg+sizeof(MTM_MSG_HEADER)),
				0,
				MAX_MSG_SIZE);
	ptr = (char *)(MTMMsg+sizeof(MTM_MSG_HEADER));
   	for (i=0; i<MAX_SRV_TYPES; ++i)
	{
		if (MTMSrvTbl[i].active_servers > 0)
		{
			if((MTMSrvTbl[i].total_resp_time > 0)
				&& (MTMSrvTbl[i].total_server_resps > 0))
			{
				average_resp_time =
				(MTMSrvTbl[i].total_resp_time/MTMSrvTbl[i].total_server_resps);
			}

			if(MTMSrvTbl[i].min_resp_time != MIN_RESP_DEFAULT)
				min_resp_time = MTMSrvTbl[i].min_resp_time;
			else
				min_resp_time = 0;
			if(min_resp_time < 0)
				min_resp_time = 0;


			if(MTMSrvTbl[i].max_resp_time > 0)
				max_resp_time = MTMSrvTbl[i].max_resp_time;

			time_elapsed =
				mtm_time_elapsed(MTMSrvTbl[i].time_stats_started);

			if(ptr[0] == '\0')
			{
				sprintf(ptr,"%s|%d|%d|%d|%d|%f|%f|%f",
					MTMSrvTbl[i].srv_type_name,
					time_elapsed * 1000,
					MTMSrvTbl[i].active_servers,
					MTMSrvTbl[i].total_client_reqsts,
					MTMSrvTbl[i].total_server_resps,
					average_resp_time * 1000,	
					min_resp_time * 1000,
					max_resp_time * 1000);
			}
			else
			{
				(void)sprintf(	ptr,"%s%s|%d|%d|%d|%d|%f|%f|%f",
						ptr,
						MTMSrvTbl[i].srv_type_name,
						time_elapsed * 1000,
						MTMSrvTbl[i].active_servers,
						MTMSrvTbl[i].total_client_reqsts,
						MTMSrvTbl[i].total_server_resps,
						average_resp_time * 1000,	
						min_resp_time * 1000,
						max_resp_time * 1000);
			}
			(void)sprintf(ptr,"%s%c",ptr,RECORD_DELIMITER);

			/*
			*	Loop through each server process and format
			*	a record like this:
			*	Server nnn PID=yyyyyy|time elapsed since server
			*	connected|SLOT=?|SERVER=?|STATUS=?|CPU=??????||
			*/
			temp = MTMSrvTbl[i].proc_tbl;
			for (j=0; j<MAX_SRV_PROCESSES; j++)
			{
				if (temp[j].pid != DISCONNECTED)
				{
					slot_state = (temp[j].state == IN_USE ? 'U' : 'F');
					server_state = (temp[j].srv_state == PAUSE ? 'P' : 'B');
					get_proc_st_pcpu(temp[j].pid, &process_state, &cpu_time);
					time_elapsed = mtm_time_elapsed(temp[j].time_connected);
					sprintf(ptr,"%sSrv%d=%d|%d|%c|%c|%c|%f||%c",
						ptr,
						j,
						temp[j].pid,
						time_elapsed * 1000,
						slot_state,
						server_state,
						process_state,
						cpu_time,
						RECORD_DELIMITER);	
				}
			}
		}

		if (clear_counter)
		{
			MTMSrvTbl[i].time_stats_started = 0;
			MTMSrvTbl[i].total_client_reqsts = 0;
			MTMSrvTbl[i].total_server_resps = 0;
			MTMSrvTbl[i].total_resp_time = 0;
			MTMSrvTbl[i].min_resp_time = MIN_RESP_DEFAULT;
			MTMSrvTbl[i].max_resp_time = 0;
		}
	}

	ptr = (char *)(MTMMsg+sizeof(MTM_MSG_HEADER));
	notification->length = strlen(ptr);
	notification->return_code = SUCCESS;
	notification->reason_code = MTM_SVSTAT;
 	(void)mtm_send_reply(notification);
}

/*
*	(void)mtm_send_reply
*	[module number i.e. Future] [module name]
*
*	Description:
*	Sends a control message reply to the queue specified in the message.
*
*	Returns:
*	void
*
*/
static void
mtm_send_reply(MTM_MSG_HEADER *notification)
{
	RETURNSTATUS	rc = SUCCESS;
	SLONG		msg_length = 0;
	char		*ptr;
	SLONG		return_code;
	MTM_MSG_HEADER	*pHeader;

	/*
	*	Check if message header is usable
	*/
	pHeader = (MTM_MSG_HEADER *)MTMMsg;
	if (pHeader == NULL)
	{
		MTM_EFD(EFAULT);
		return;
	}

	/*
	*	Send server reply to a control message.
	*/

	ptr = (char *)(MTMMsg+sizeof(MTM_MSG_HEADER));
	notification->mtype.unix_pid = pHeader->pid;
	notification->pid = MTMProcessId;
	msg_length = sizeof(MTM_MSG_HEADER);

	if((notification->reason_code == MTM_SVSTAT)
		|| (notification->reason_code == MTM_CLSTAT)
		|| (notification->reason_code == MTM_GETVER)
		|| (notification->reason_code == MTM_GETPARAM)
		|| (notification->reason_code == MTM_SVCLEAN)
		|| (notification->reason_code == MTM_PEND)
		|| (notification->reason_code == MTM_GETSTAT))
	{
		msg_length += notification->length;
	}

#ifdef DEBUG
	fprintf(stdout,"mtm_send_reply: reply to control message\n");
	fflush(stdout);
	LV(strlen(ptr),ptr);
#endif

	/*
	*	Set up the timer here
	*/
	MTMTimeout.value = 10;

	sca_SetupTimer((void *)mtm_send_reply, &MTMTimeout, (void *)mtm_alarm_catcher);

	rc = sca_msgsnd(MTMControlQid,
			(struct msgbuf *)notification,
			msg_length,
			(int)NULL,
			&MTMTimeout,
			&return_code);

	sca_CancelTimer((void *)mtm_send_reply, &MTMTimeout);

	if (rc < 0)
	{
		notification->return_code = FAILURE;
		notification->reason_code = return_code;
		MTM_EFD(notification->reason_code);
		return;
	}
#ifdef DEBUG
	(void)fprintf(stdout,"mtm_send_reply: Sending Reply to %d\n",
			notification->mtype.unix_pid);
	(void)fflush(stdout);
#endif

	return;
}

/*
*	(void)mtm_time_elapsed
*	[module number i.e. Future] [module name]
*
*	Description:
*
*	Returns:
*	void
*
*/
static
time_t mtm_time_elapsed(time_t time_value)
{
	struct timeval	time_now;
	struct timezone	time_zone;

	gettimeofday(&time_now, &time_zone);
	return (time_now.tv_sec - time_value);
}

static void
mtm_find_zombies(SLONG send_reply)
{
	RETURNSTATUS 	rc = SUCCESS;
	register int	i,j;
	FILE 		*fd = (FILE *)NULL;
	char 		cmd[MAX_CMD_LEN];
	MTM_MSG_HEADER 	notification;

	if(send_reply == TRUE)
	{
		notification.return_code = SUCCESS;
		notification.reason_code = SUCCESS;
	}
	for(i=0;i<MAX_SRV_TYPES;i++)
	{
		for(j=0;j<MAX_SRV_PROCESSES;j++)
		{
			if(MTMSrvTbl[i].proc_tbl[j].pid > 0)
			{
				/* 
				 * Check if process is still alive. This does always always
				 * work as expect because Unix systems recycle process ID after
				 * some amount of time
				 */
				rc = kill (MTMSrvTbl[i].proc_tbl[j].pid, 0);
				if (rc == -1 && errno == ESRCH)		
				{
					/*
					*	Clear the proc slot in the Server Table
					*/
					MTMSrvTbl[i].proc_tbl[j].state = FREE;
					MTMSrvTbl[i].proc_tbl[j].srv_state = PAUSE;
					MTMSrvTbl[i].proc_tbl[j].srv_type = i;
					MTMSrvTbl[i].proc_tbl[j].pid = DISCONNECTED;
					MTMSrvTbl[i].proc_tbl[j].time_connected = 0;
	
					MTMSrvTbl[i].active_servers--;
					if (MTMSrvTbl[i].active_servers < 0)
						MTMSrvTbl[i].active_servers = 0;

					TotalActiveSrvs--;
					if (TotalActiveSrvs < 0)
						TotalActiveSrvs = 0;
				}
	
			}
		}
	}

	if(send_reply == TRUE)
		(void)mtm_send_reply(&notification);

	return;
}



/*
*	(void)mtm_send_msg
*	[module number i.e. Future] [module name]
*
*	Description:
*	Sends an unsolicited message to client. (Only available in asynchronous
*	mode.)
*
*	Returns:
*	void
*
*/
static void
mtm_send_msg(void)
{
   	RETURNSTATUS	rc = SUCCESS;
	SLONG		msg_size = 0;
	MTM_MSG_HEADER	*notification = (MTM_MSG_HEADER *)NULL;
	char 		*msg;
	char		len_str[32];	/* a reasonable length size */
	MTM_CNTRL_MSG	*cHeader;
	MTM_MSG_HEADER	*pHeader;
	int		index,xref,msg_sent;
	st_tcpclient	*temp;
	int		default_mode = FALSE;

	/*
	*	Check if message header is usable
	*/
	notification = (MTM_MSG_HEADER *)MTMMsg;
	if (notification == NULL)
	{
		MTM_EFD(EFAULT);
		return;
	}

	/*
	*	Initialize in case of failure.
	*/
	notification->return_code = FAILURE;

	/*
	*	This function is available in asynchronous mode only.
	*/
	if (MTMAsyncMode == FALSE)
	{
		notification->reason_code= MTM_SEND_FAILED;
		MTM_EFD(notification->reason_code);
		(void)mtm_send_reply(notification);
		return;
	}

	/*
	*	Do we even have a valid control message?
	*/
	cHeader = (MTM_CNTRL_MSG *)MTMMsg;
	if (cHeader == NULL)
	{
		notification->reason_code= EFAULT;
		MTM_EFD(notification->reason_code);
		(void)mtm_send_reply(notification);
		return;
	}

	/*
	*	Message format:
	*	param1 has the host IP address
	*	param2 has the host port number
	*	param3 has the actual message
	*/
	msg_size = cHeader->param3Length;

	/*
	*	Check if message length would exceed limit
	*/
	if(msg_size > MTMMaxMsgSize)
	{
		notification->reason_code= EMSGSIZE;
		MTM_EFD(notification->reason_code);
		(void)mtm_send_reply(notification);
		return;
	}

	/*
	*	Build the message - consisting of:
	*	MTM header + length + actual message
	*	Exception: if the length is embedded, we'll send:
	*	MTM header + actual message
	*/
	msg = (char *)malloc(sizeof(MTM_MSG_HEADER)+MTMLength.hsize+msg_size);
	if (msg == NULL)
	{
		notification->reason_code= MTM_SEND_FAILED;
		MTM_EFD(notification->reason_code);
		(void)mtm_send_reply(notification);
		return;
	}

	pHeader = (MTM_MSG_HEADER *)msg;
	if (pHeader == NULL)
	{
		notification->reason_code= EFAULT;
		MTM_EFD(notification->reason_code);
		(void)mtm_send_reply(notification);
		return;
	}

	/*
	*	Check if we already have such host ip and port number
	*	already connected. Then we will use one of the connected
	*	socket to send the message. If we fail on a socket for
	*	any reason, we will attempt to use the next available socket.
	*/

#ifdef DEBUG
	(void)fprintf(stdout,"cHeader->param1 = %s\n",cHeader->param1);
	(void)fprintf(stdout,"cHeader->param2 = %s\n",cHeader->param2);
	(void)fprintf(stdout,"cHeader->param3 = %s\n",cHeader->param3);
	fflush(stdout);
#endif
	if ((cHeader->param1[0] == '\0') && (cHeader->param2[0] == '\0'))
		default_mode = TRUE;
	msg_sent = FALSE;
	temp = MTMAsyncClient;
	while (temp != (st_tcpclient *)NULL)
	{
		/*
		*	Do we have the same host?
		*/
		if ((default_mode == TRUE) ||
			((strcmp(temp->hostAddr,cHeader->param1) == 0) &&
			 (temp->portNum == atoi(cHeader->param2))))
		{
			/*
			*	Do we have any socket available?
			*/
			for (index = 0; index < temp->maxSd; index++)
			{
				xref = temp->clientSd[index];
				if (MTMRoutingTbl[xref].sd != DISCONNECTED)
				{
					/*
					*	Yep, found one. Try it
					*/
					pHeader->sd = MTMRoutingTbl[xref].sd;
					pHeader->port = MTMRoutingTbl[xref].port;
					pHeader->length = msg_size + MTMLength.hsize;
					if (MTMLength.lcount == 0)
					{
						mtm_slength(len_str, (SLONG)(msg_size + MTMLength.hsize), &MTMLength);
						memcpy(&msg[sizeof(MTM_MSG_HEADER)], len_str, MTMLength.hsize);
						memcpy(&msg[sizeof(MTM_MSG_HEADER)+MTMLength.hsize], cHeader->param3, msg_size);
					}
					else
					{
						memcpy(&msg[sizeof(MTM_MSG_HEADER)], cHeader->param3, msg_size);
					}

					/*
					*	Send the message to client. 
					*/
#ifdef DEBUG
	(void)fprintf(stdout,"Before mtm_skt_send\n");
	(void)fprintf(stdout,"msg = %s\n",msg);
	fflush(stdout);
#endif
					rc = mtm_skt_send(msg);
					if (rc == SUCCESS)
					{
						msg_sent = TRUE;
						break;
					}
				}
			}
		}
		if (msg_sent)
			break;
		else
			temp = temp->next;
	}

	/*
	*	Reply to the server whether message was sent or not.
	*/
	if (msg_sent)
	{
		notification->return_code = SUCCESS;
		notification->reason_code = MTM_SENDMSG;
	}
	else
	{
		notification->reason_code= MTM_SEND_FAILED;
		MTM_EFD(notification->reason_code);
	}
	notification->length = 0;
 	(void)mtm_send_reply(notification);

	return;

}


/*
*	(void)mtm_get_version
*	[module number i.e. Future] [module name]
*
*	Description:
*	Sends the MTM version information to the calling program.
*
*	Returns:
*	void
*
*/
static void
mtm_get_version(void)
{
	char		*ptr = (char *)NULL;
	MTM_MSG_HEADER	*notification = (MTM_MSG_HEADER *)NULL;
	char		*temp;
	int		temp_length = 0;
	int		version_length = 0;

	/*
	*	Check if control message header is usable
	*/
	notification = (MTM_MSG_HEADER *)MTMMsg;
	if (notification == NULL)
	{
		MTM_EFD(EFAULT);
		return;
	}

	/*
	*	Initialize in case of failure.
	*/
	notification->return_code = FAILURE;

	ptr = (char *)(MTMMsg+sizeof(MTM_MSG_HEADER));
	memset(ptr, 0, MTMMaxMsgSize);

	/*
	*	Get the MTM version. It is set up as an array of
	*	strings in mtmutils.c. Here, we simply concatenate
	*	all the strings (separated by '|') and return the
	*	whole array as just one string.
	*/
	for (;;)
	{
		temp = get_version();
		if (temp != NULL)
		{
			temp_length = strlen(temp);
			if (version_length + temp_length <= MTMMaxMsgSize)
			{
				memcpy(&ptr[version_length], temp, temp_length);
				version_length += temp_length;
				ptr[version_length++] = PROFILE_DELIMITER;
			}
		}
		else
			break;
	}

	/*
	*	Replace the last '|' (PROFILE_DELIMITER) with '\0'
	*	and adjust the length by 1 byte.
	*/
	if (version_length > 0)
		ptr[--version_length] = '\0';

	/*
	*	Check if version length would exceed the MTM
	*	maximum message size.
	*/
	if(version_length > MTMMaxMsgSize)
	{
		notification->reason_code= EMSGSIZE;
		MTM_EFD(notification->reason_code);
		(void)mtm_send_reply(notification);
		return;
	}

	/*
	*	Send the version string
	*/
	notification->length = version_length;
	notification->return_code = SUCCESS;
	notification->reason_code = MTM_GETVER;
 	(void)mtm_send_reply(notification);
}



/*
*	(void)mtm_get_param
*	[module number i.e. Future] [module name]
*
*	Description:
*	Sends the MTM startup parameters to the calling program.
*
*	Returns:
*	void
*
*/
static void
mtm_get_param(void)
{
	char		*ptr = (char *)NULL;
	MTM_MSG_HEADER	*notification = (MTM_MSG_HEADER *)NULL;

	/*
	*	Check if control message header is usable
	*/
	notification = (MTM_MSG_HEADER *)MTMMsg;
	if (notification == NULL)
	{
		MTM_EFD(EFAULT);
		return;
	}

	/*
	*	Initialize in case of failure.
	*/
	notification->return_code = FAILURE;

	ptr = (char *)(MTMMsg+sizeof(MTM_MSG_HEADER));
	memset(ptr, 0, MTMMaxMsgSize);

	/*
	*	The MTM parameters to be returned:
	*	"Process Name|Log File|Max Msg Size|Valid Client|
	*	Max Client|Port Number|Async Mode|Length Format|
	*	Header Flag|Length Size|Header Size|Leading Count|
	*	Trailing Count"
	*/
	sprintf(ptr,"%s|%s|%d|%s|%d|%d|%d|%c|%c|%d|%d|%d|%d",
			MTMProcessName,
			MTMLogFileName,
			MTMMaxMsgSize,
			MTMValidClients,
			MTMMaxClient,
			MTMInternetPort,
			MTMAsyncMode,
			MTMLength.format,
			MTMLength.header,
			MTMLength.lsize,
			MTMLength.hsize,
			MTMLength.lcount,
			MTMLength.tcount);

#ifdef DEBUG
	(void)fprintf(stdout,"\nptr = %s\n",ptr);
        fflush(stdout);
#endif

	/*
	*	Check if resulting string length would exceed the MTM
	*	maximum message size.
	*/
	if(strlen(ptr) > MTMMaxMsgSize)
	{
		notification->reason_code= EMSGSIZE;
		MTM_EFD(notification->reason_code);
		(void)mtm_send_reply(notification);
		return;
	}

	/*
	*	Send the version string
	*/
	notification->length = strlen(ptr);
	notification->return_code = SUCCESS;
	notification->reason_code = MTM_GETPARAM;
 	(void)mtm_send_reply(notification);
}





/*
*	(void)mtm_sv_clean
*	[module number i.e. Future] [module name]
*
*	Description:
*	Removes inactive or zombie server table entries in MTM.
*
*	Returns:
*	void
*
*/
static void
mtm_sv_clean(void)
{
	int		sv_type;
	MTM_SERVER_TYPE_TABLE *stbl_entry;
	char		*ptr = (char *)NULL;
	MTM_MSG_HEADER	*notification = (MTM_MSG_HEADER *)NULL;
	int		rc, active_count, inactive_count, zombie_count;
	int		msg_size = 0;

#ifdef DEBUG
	fprintf(stdout,"mtm_sv_clean: Start of routine\n");
	fflush(stdout);
#endif

	/*
	*	Check if control message header is usable
	*/
	notification = (MTM_MSG_HEADER *)MTMMsg;
	if (notification == NULL)
	{
		MTM_EFD(EFAULT);
		return;
	}

	/*
	*	Initialize in case of failure.
	*/
	notification->return_code = FAILURE;

	/*
	*	Determine the size of the message buffer
	*/
	for(sv_type = 0; sv_type < MAX_SRV_TYPES; sv_type++)
	{
		if (MTMSrvTbl[sv_type].active_servers > 0)
		{
			msg_size += MAX_SRV_PROCESSES * MTM_STR_LEN;
		}
	}

	if(msg_size == 0)
	{
		notification->reason_code= MTM_NO_SRV_CONNECTED;
		MTM_EFD(notification->reason_code);
		(void)mtm_send_reply(notification);
		return;
	}
	else if(msg_size > MTMMaxMsgSize)
	{
		notification->reason_code= EMSGSIZE;
		MTM_EFD(notification->reason_code);
		(void)mtm_send_reply(notification);
		return;
	}

	ptr = (char *)(MTMMsg+sizeof(MTM_MSG_HEADER));
	memset(ptr, 0, MTMMaxMsgSize);

	/*
	*
	*/
	for (sv_type = 0; sv_type < MAX_SRV_TYPES; sv_type++)
	{
		stbl_entry = &MTMSrvTbl[sv_type];

		/*
		*	Check if pointer is valid
		*/
		if (stbl_entry == NULL)
		{
			MTM_EFD(EFAULT);
			continue;
		}

		if (stbl_entry->active_servers > 0)
		{
			/*
			*	Clean server table entry
			*/
			if ((clean_stbl_entry(stbl_entry, 
				&active_count, 
				&inactive_count, 
				&zombie_count,
				&rc)) == SUCCESS)
			{
				/*
				*	Store the results
				*/
				if (ptr[0] == '\0')
					sprintf(ptr,"%s|%d|%d|%d|%d",
						stbl_entry->srv_type_name,
						sv_type,
						active_count,
						inactive_count,
						zombie_count);
				else
					sprintf(ptr,"%s%s|%d|%d|%d|%d",
						ptr,
						stbl_entry->srv_type_name,
						sv_type,
						active_count,
						inactive_count,
						zombie_count);
			}
			(void)sprintf(ptr,"%s%c",ptr,RECORD_DELIMITER);
		}
	}

	ptr = (char *)(MTMMsg+sizeof(MTM_MSG_HEADER));
#ifdef DEBUG
	fprintf(stdout,"mtm_sv_clean: reply is %s\n",ptr);
	fflush(stdout);
#endif
	notification->length = strlen(ptr);
	notification->return_code = SUCCESS;
	notification->reason_code = MTM_SVCLEAN;
 	(void)mtm_send_reply(notification);

#ifdef DEBUG
	fprintf(stdout,"mtm_sv_clean: End of routine\n");
	fflush(stdout);
#endif
}





/*
*	clean_stbl_entry
*
*	Returns the number of active servers associated with this server
*	table entry.
*
*/
int clean_stbl_entry(MTM_SERVER_TYPE_TABLE *stbl_entry, int *active_count, int *inactive_count, int *zombie_count, int *return_code)
{
	int 			index;
	int			active_flag;
	int			rc;
	pid_t			srv_pid;
	time_t			cal_time;
	MTM_PROCESS_TABLE 	*pServer;

#ifdef DEBUG
	fprintf(stdout,"clean_stbl_entry: Start of routine\n");
	fflush(stdout);
#endif

	/*
	*	Init return value
	*/
	*active_count = 0;
	*inactive_count = 0;
	*zombie_count = 0;
	*return_code = SUCCESS;
	
	/*
	*	Check if we have a valid pointer
	*/
	if (stbl_entry == NULL)
	{
		*return_code = EFAULT;
		MTM_EFD(*return_code);
		return FAILURE;
	}

	/*
	*	Check for the obvious
	*/
	if (stbl_entry->active_servers <= 0)
	{
		*return_code = MTM_NO_ACTIVE_SRVS;
		return FAILURE;
	}

	/*
	*	There would be a number of servers attached to this server
	*	table entry. Loop through and see if they are still alive.
	*	(Almost like mtm_find_zombie function)
	*/
	for (index = 0; index < MAX_SRV_PROCESSES; index++)
	{
		pServer = &stbl_entry->proc_tbl[index];

		/*
		*	Check for valid pointer
		*/
		if (pServer == NULL)
		{
			MTM_EFD(EFAULT);
			continue;
		}

		srv_pid = pServer->pid;
		if (srv_pid > 0)
		{
			/*
			*	Check if pid is still active
			*/
			active_flag = mtm_proc_active(srv_pid);
			if (active_flag == TRUE)
			{
				*active_count = *active_count + 1;
			}
			else if (active_flag == FALSE)
			{
				/*
				*	Server process must have terminated
				*	improperly. That means it didn't call
				*	function SrvDisconnect() function.
				*	The MTM has no idea why it's not there
				*	anymore. Clean up this entry....
				*/
				reset_server_entry(pServer);
				*inactive_count = *inactive_count + 1;
			}
			else
			{
				/*
				*	Process is neither active nor inactive.
				*	It must be a zombie. Oh, no!!!
				*/
				rc = kill(srv_pid, 0);
				if (rc == -1 && errno == ESRCH)
					reset_server_entry(pServer);
				*zombie_count = *inactive_count + 1;
			}
		}
	}

#ifdef DEBUG
	fprintf(stdout,"\tactive count = %d\n",*active_count);
	fprintf(stdout,"\tinactive count = %d\n",*inactive_count);
	fprintf(stdout,"\tzombie count = %d\n",*zombie_count);
	fflush(stdout);
#endif

	/*
	*	At this point, we should match active server count.
	*	If not, we probably cleaned up some slots. So update
	*	the sever table entry active server count.
	*/
	if (*active_count != stbl_entry->active_servers)
	{
		stbl_entry->active_servers = *active_count;

		/*
		*	Log a message
		*/
		time(&cal_time);
		fprintf(MTMLogFp,"\nxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx\n");
		fprintf(MTMLogFp,"active_server_count: Not all attached server processes are running\n");
		fprintf(MTMLogFp,"\tCurrent time: %s",ctime(&cal_time));
		fprintf(MTMLogFp,"\tActive processes count: %d\n",*active_count);

		fprintf(MTMLogFp,"\tInactive processes count: %d\n",*inactive_count);
		fprintf(MTMLogFp,"\tZombie processes count: %d\n",*zombie_count);
		fprintf(MTMLogFp,"\tServer table is cleaned up. MTM will continue as normal");
		fprintf(MTMLogFp,"\nxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx\n");
		fflush(MTMLogFp);
		stbl_entry->active_servers = *active_count;
	}

	if (*active_count == 0)
	{
		/*
		*	No server process active
		*/
		*return_code = MTM_NO_ACTIVE_SRVS;

		/*
		*	Decrease number of active service types
		*/
		TotalActiveSrvs--;
		if (TotalActiveSrvs < 0)
			TotalActiveSrvs = 0;
	}

#ifdef DEBUG
	fprintf(stdout,"clean_stbl_entry: End of routine\n");
	fflush(stdout);
#endif

	return(SUCCESS);
}




/*
*	reset_server_entry
*
*	Mark the server slot as inactive
*
*/
void reset_server_entry(MTM_PROCESS_TABLE *srv_entry)
{
	srv_entry->state = FREE;
	srv_entry->srv_state = PAUSE;
	srv_entry->pid = DISCONNECTED;
	srv_entry->time_connected = 0;
}

/*
* Start the MTM Statisics for the Server Type 
*/

static void
mtm_start_stats()
{
	MTM_MSG_HEADER	notification;
   	time_t  	time_value;
	int register	i = 0;
	MTM_CNTRL_MSG	*cHeader;
	SLONG 		srv_type = FAILURE;

	/*
	*	Check if control message header is usable
	*/
	cHeader = (MTM_CNTRL_MSG *)MTMMsg;
	if (cHeader == NULL)
	{
		notification.return_code= FAILURE;
		notification.reason_code = EFAULT;
		MTM_EFD(notification.reason_code);
		(void)mtm_send_reply(&notification);
		return;
	}

	if (cHeader->param1[0] == '\0')
	{
                notification.return_code= FAILURE;
                notification.reason_code = MTM_NO_SRV_TYPE;
                MTM_EFD(notification.reason_code);
                (void)mtm_send_reply(&notification);
                return;
	}

#ifdef DEBUG
	(void)fprintf(stdout,"mtm_stats_on: Parameter 1: %s\n",cHeader->param1);
	(void)fprintf(stdout,"mtm_stats_on: Parameter 2: %s\n",cHeader->param2);
	(void)fflush(stdout);
#endif

	if (cHeader->param1[0] == '*')
		srv_type = ALL;
	else 
	{
		srv_type = mtm_get_server_type(cHeader->param1,FALSE);

		/*
		 * If no servers are active this type server type - send error.
		 * Except in the case of ALL.
		 */
		if (srv_type == FAILURE)
		{
			notification.return_code= FAILURE;
			notification.reason_code= MTM_NO_SRV_TYPE;
			MTM_EFD(notification.reason_code);
			(void)mtm_send_reply(&notification);
			return;
		}
	}

	if(srv_type == ALL)
	{
		notification.return_code = FAILURE;
		for (i=0; i< MAX_SRV_TYPES; i++)
		{
			if(MTMStatsTbl[i].mtm_stats_on != TRUE )
			{
				MTMStatsTbl[i].mtm_stats_on = TRUE;
				time_value = time(NULL);
				strftime(MTMStatsTbl[i].start_time,TIME_STR_LEN,"%I:%M:%S %p",localtime(&time_value));
				strcpy(MTMStatsTbl[i].srv_type_name,MTMSrvTbl[i].srv_type_name);
				MTMStatsTbl[i].active_servers = MTMSrvTbl[i].active_servers;

				/* Clean up the other fields and set defaults */ 
				MTMStatsTbl[i].end_time[0] = '\0';
				MTMStatsTbl[i].total_server_reply = 0;
				MTMStatsTbl[i].min_reply_time = 0;
				MTMStatsTbl[i].max_reply_time = 0;
				MTMStatsTbl[i].avg_reply_time = 0.0;
				MTMStatsTbl[i].total_server_req = 0;
				MTMStatsTbl[i].min_req_time = 0;
				MTMStatsTbl[i].max_req_time = 0;
				MTMStatsTbl[i].avg_req_time = 0.0;
				
				notification.return_code = SUCCESS;
				notification.reason_code = MTM_STATS_ON;
			}
			else
				notification.reason_code = MTM_STATS_RUNNING;
		}
	}
	else
	{
		if(MTMStatsTbl[srv_type].mtm_stats_on != TRUE )
		{
			MTMStatsTbl[srv_type].mtm_stats_on = TRUE;
			time_value = time(NULL);
			strftime(MTMStatsTbl[srv_type].start_time,TIME_STR_LEN,"%I:%M:%S %p",localtime(&time_value));
			strcpy(MTMStatsTbl[srv_type].srv_type_name,MTMSrvTbl[srv_type].srv_type_name);
			MTMStatsTbl[srv_type].active_servers = MTMSrvTbl[srv_type].active_servers;

			/* Clean up the other fields and set defaults */ 
			MTMStatsTbl[srv_type].end_time[0] = '\0';
			MTMStatsTbl[srv_type].total_server_reply = 0;
			MTMStatsTbl[srv_type].min_reply_time = 0;
			MTMStatsTbl[srv_type].max_reply_time = 0;
			MTMStatsTbl[srv_type].avg_reply_time = 0.0;
			MTMStatsTbl[srv_type].total_server_req = 0;
			MTMStatsTbl[srv_type].min_req_time = 0;
			MTMStatsTbl[srv_type].max_req_time = 0;
			MTMStatsTbl[srv_type].avg_req_time = 0.0;

			notification.return_code = SUCCESS;
			notification.reason_code = MTM_STATS_ON;
		}
		else
		{
			notification.return_code = FAILURE;
			notification.reason_code = MTM_STATS_RUNNING;
		}
	}
	if (notification.return_code == FAILURE)
		MTM_EFD(notification.reason_code);

	(void)mtm_send_reply(&notification);
	return;
}
static void
mtm_stop_stats()
{
	MTM_MSG_HEADER	notification;
   	time_t  	time_value;
	int register	i = 0;
	MTM_CNTRL_MSG	*cHeader;
	SLONG 		srv_type;

	/*
	*	Check if control message header is usable
	*/
	cHeader = (MTM_CNTRL_MSG *)MTMMsg;
	if (cHeader == NULL)
	{
		notification.return_code = FAILURE;
		notification.reason_code = EFAULT;
		MTM_EFD(notification.reason_code);
		(void)mtm_send_reply(&notification);
		return;
	}

        if (cHeader->param1[0] == '\0')
        {
                notification.return_code= FAILURE;
                notification.reason_code = MTM_NO_SRV_TYPE;
                MTM_EFD(notification.reason_code);
                (void)mtm_send_reply(&notification);
                return;
        }
 
	if (cHeader->param1[0] == '*')
		srv_type = ALL;
	else 
	{
		srv_type = FAILURE;
		for(i=0;i<MAX_SRV_TYPES;i++)
		{
			if (strcmp (MTMStatsTbl[i].srv_type_name, cHeader->param1) == 0)
			{
				srv_type = i;
				break;
			}
		}
		/*
		 * If no servers are active this type server type - send error.
		 * Except in the case of ALL.
		 */
		if (srv_type == FAILURE)
		{
			notification.return_code = FAILURE;
			notification.reason_code = MTM_NO_SRV_TYPE;
			MTM_EFD(notification.reason_code);
			(void)mtm_send_reply(&notification);
			return;
		}
	}
	if(srv_type == ALL)
	{
		notification.return_code = FAILURE;
		for(i=0;i<MAX_SRV_TYPES;i++)
		{
                        if(MTMStatsTbl[i].mtm_stats_on == TRUE )
                        {
				MTMStatsTbl[i].mtm_stats_on = FALSE;
				time_value = time(NULL);
				strftime(MTMStatsTbl[i].end_time,TIME_STR_LEN,"%I:%M:%S %p",localtime(&time_value));
		
				notification.return_code = SUCCESS;
				notification.reason_code = MTM_STATS_OFF;
			}
			else
				notification.reason_code = MTM_NO_STATS;
		}
	}
	else
	{
		if(MTMStatsTbl[srv_type].mtm_stats_on == TRUE)
		{
			MTMStatsTbl[srv_type].mtm_stats_on = FALSE;
			time_value = time(NULL);
			strftime(MTMStatsTbl[srv_type].end_time,TIME_STR_LEN,"%I:%M:%S %p",localtime(&time_value));
			notification.return_code = SUCCESS;
			notification.reason_code = MTM_STATS_OFF;
		}
		else
		{
			notification.return_code = FAILURE;
			notification.reason_code = MTM_NO_STATS;
		}
	}
	if (notification.return_code == FAILURE)
		MTM_EFD(notification.reason_code);

   	(void)mtm_send_reply(&notification);
	return;
}

static void 
mtm_get_stats()
{
	register int	i,j;
	SLONG		msg_size = 0;
	char		*ptr = (char *)NULL;
	MTM_MSG_HEADER	*notification = (MTM_MSG_HEADER *)NULL;
	MTM_CNTRL_MSG	*cHeader;
	SLONG 		srv_type;

	notification = (MTM_MSG_HEADER *)MTMMsg;
	if (notification == NULL)
	{
		notification->return_code= FAILURE;
		notification->reason_code= EFAULT;
		MTM_EFD(EFAULT);
                (void)mtm_send_reply(notification);
		return;
	}

	/*
	*	Check if control message header is usable
	*/
	cHeader = (MTM_CNTRL_MSG *)MTMMsg;
	if (cHeader == NULL)
	{
		notification->return_code= FAILURE;
		notification->reason_code= EFAULT;
		MTM_EFD(EFAULT);
                (void)mtm_send_reply(notification);
		return;
	}

        if (cHeader->param1[0] == '\0')
        {
		notification->return_code= FAILURE;
		notification->reason_code= MTM_NO_SRV_TYPE;
                MTM_EFD(MTM_NO_SRV_TYPE);
                (void)mtm_send_reply(notification);
                return;
        }
 
	if (cHeader->param1[0] == '*')
		srv_type = ALL;
	else 
	{
		srv_type = FAILURE;
		for(i=0;i<MAX_SRV_TYPES;i++)
		{
			if (MTMStatsTbl[i].srv_type_name[0] != '\0')
			{
				if (strcmp (MTMStatsTbl[i].srv_type_name, cHeader->param1) == 0)
				{
					srv_type = i;
					break;
				}
			}
		}
	}

	/*
	 * If no servers are active or no stats available - send error.
	 */
	if (srv_type == FAILURE)
	{
		notification->return_code= FAILURE;
		notification->reason_code= MTM_NO_SRV_TYPE;
		MTM_EFD(MTM_NO_SRV_TYPE);
		(void)mtm_send_reply(notification);
		return;
	}

	/*
	*	Initialize in case of failure.
	*/
	notification->return_code = FAILURE;

	(void)memset((char *)(MTMMsg+sizeof(MTM_MSG_HEADER)),
				0,
				MAX_MSG_SIZE);

	ptr = (char *)(MTMMsg+sizeof(MTM_MSG_HEADER));

	if(srv_type == ALL)
	{
	   	for (i=0; i<MAX_SRV_TYPES; ++i)
		{
                        if (MTMStatsTbl[i].srv_type_name[0] == '\0')
				notification->reason_code = MTM_NO_STATS;
			else
                        {
			    if(ptr[0] == '\0')
			    {
				(void)sprintf(ptr,"%s|%ld|%s|%s|%ld|%ld|%ld|%f|%ld|%ld|%ld|%f",
					MTMStatsTbl[i].srv_type_name,
					MTMStatsTbl[i].active_servers,
					MTMStatsTbl[i].start_time,
					MTMStatsTbl[i].end_time,
					MTMStatsTbl[i].total_server_reply,
					MTMStatsTbl[i].min_reply_time,
					MTMStatsTbl[i].max_reply_time,	
					MTMStatsTbl[i].avg_reply_time,
					MTMStatsTbl[i].total_server_req,
					MTMStatsTbl[i].min_req_time,
					MTMStatsTbl[i].max_req_time,	
					MTMStatsTbl[i].avg_req_time);

			    }
			    else
			    {
				(void)sprintf(ptr,"%s%s|%ld|%s|%s|%ld|%ld|%ld|%f|%ld|%ld|%ld|%f",
					ptr,
					MTMStatsTbl[i].srv_type_name,
					MTMStatsTbl[i].active_servers,
					MTMStatsTbl[i].start_time,
					MTMStatsTbl[i].end_time,
					MTMStatsTbl[i].total_server_reply,
					MTMStatsTbl[i].min_reply_time,
					MTMStatsTbl[i].max_reply_time,	
					MTMStatsTbl[i].avg_reply_time,
					MTMStatsTbl[i].total_server_req,
					MTMStatsTbl[i].min_req_time,
					MTMStatsTbl[i].max_req_time,	
					MTMStatsTbl[i].avg_req_time);
			    }
			    (void)sprintf(ptr,"%s%c",ptr,RECORD_DELIMITER);
			    notification->return_code = SUCCESS;
			}
		}
	}
	else
	{
                if (MTMStatsTbl[srv_type].srv_type_name[0] == '\0')
			notification->reason_code = MTM_NO_STATS;
		else
		{
			(void)sprintf(ptr,"%s|%ld|%s|%s|%ld|%ld|%ld|%f|%ld|%ld|%ld|%f",
			MTMStatsTbl[srv_type].srv_type_name,
			MTMStatsTbl[srv_type].active_servers,
			MTMStatsTbl[srv_type].start_time,
			MTMStatsTbl[srv_type].end_time,
			MTMStatsTbl[srv_type].total_server_reply,
			MTMStatsTbl[srv_type].min_reply_time,
			MTMStatsTbl[srv_type].max_reply_time,	
			MTMStatsTbl[srv_type].avg_reply_time,
			MTMStatsTbl[srv_type].total_server_req,
			MTMStatsTbl[srv_type].min_req_time,
			MTMStatsTbl[srv_type].max_req_time,	
			MTMStatsTbl[srv_type].avg_req_time);
			(void)sprintf(ptr,"%s%c",ptr,RECORD_DELIMITER);
			notification->return_code = SUCCESS;
		}
	}

	if (notification->return_code == SUCCESS)
	{
		ptr = (char *)(MTMMsg+sizeof(MTM_MSG_HEADER));
		notification->length = strlen(ptr);
		notification->reason_code = MTM_GETSTAT;
	}
	else
		MTM_EFD(notification->reason_code);

 	(void)mtm_send_reply(notification);
	return;
}

