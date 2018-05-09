
/*
*	mtmclnt.c - Sanchez Message Transport Manager for UNIX
*
*	Copyright(c)1992 Sanchez Computer Associates, Inc.
*	All Rights Reserved
*
*	ORIG:	Sara G. Walters - 11 Jan 1995
*
*	DESC:	This file consists of routines that retrieve client requests from
*			the communication channels (sockets) and send them to the
*			message queues of appropriate server types.
*
*
*   $Id: mtmclnt.c,v 1.1 2000/06/01 00:45:35 lyh Exp lyh $
*   $Log:	mtmclnt.c,v $
 * Revision 2.8  05/12/06  paulj ()
 * Modified mtm_client_single_msg method to set the time-in 
 * field in microseconds in the mtm header.This will be used to 
 * the statistics of the request message.
 *
 * Revision 2.7  00/06/20  16:50:29  16:50:29  lyh ()
 * Correct client socket descriptor lookup.
 * 
 * Revision 2.6  00/06/19  17:51:11  17:51:11  lyh ()
 * Correct client count
 * 
 * Revision 2.5  00/06/02  13:22:33  13:22:33  lyh ()
 * Changes as a result of porting to other platform
 * 
 * Revision 2.4  00/03/13  15:16:22  15:16:22  lyh ()
 * Check for valid pointers
 * 
 * Revision 2.3  00/03/13  14:20:42  14:20:42  lyh ()
 * Check pointer to avoid segment violation error
 * 
 * Revision 2.2  00/03/03  15:09:49  15:09:49  lyh ()
 * Use a common alarm routine.
 * 
 * Revision 2.1  00/01/17  11:16:08  11:16:08  lyh ()
 * storm trooper release
 * 
 * Revision 1.2  99/12/27  15:58:13  15:58:13  lyh ()
 * mtm enhancement
 * 
 * Revision 1.1  99/12/20  16:31:29  16:31:29  lyh ()
 * Initial revision
 * 
 * Revision 1.11  96/04/26  15:08:51  15:08:51  zengf (Fan Zeng)
 * core error fix.
 * 
 * Revision 1.10  96/04/25  16:12:57  16:12:57  zengf (Fan Zeng)
 * fix client message bug.
 * 
 * Revision 1.9  96/04/17  15:16:39  15:16:39  zengf (Fan Zeng)
 * Fixed stats.
 * 
 * Revision 1.8  96/04/10  17:24:32  17:24:32  zengf (Fan Zeng)
 * reverse r1.7
 * 
 * Revision 1.6  96/03/13  10:01:32  10:01:32  zengf (Fan Zeng)
 * prepare for removing signals
 * 
 * Revision 1.5  96/02/28  17:27:34  17:27:34  zengf (Fan Zeng)
 * substantially rewrite MTM and the APIs.
 * 
 * Revision 1.4  96/02/05  16:30:11  16:30:11  zengf (Fan Zeng)
 * check in changes made by Sara G. Walters
 * 
 * Revision 1.3  95/07/19  14:16:14  14:16:14  rcs ()
 * Bug fixes as a result of MTM System Test
 * 
 * Revision 1.2  95/05/22  14:49:28  14:49:28  sca ()
 * sgI VMS
 * 
*   $Revision: 2.7 $
*
*/
#include	<ctype.h>
#include	<stdio.h>
#include	<time.h>
#include	<sys/time.h>
#include	<signal.h>
#include	<errno.h>
#include	<string.h>
#include	<stdlib.h>
#include	<sys/msg.h>
#include	<sys/ipc.h>
#include	"scatype.h"
#include	"mtm.h"
#include	"mtmprototypes.h"
#include	"mtmext.h"
#include	"mtmerrno.h"

static RETURNSTATUS mtm_client_single_msg(void);
static RETURNSTATUS update_stbl_entry(MTM_SERVER_TYPE_TABLE *,MTM_MSG_HEADER *, SLONG *);

/*
*	mtm_client_msg
*	[module number i.e. Future] [module name]
*
*	Description:
*	Receives client msgs from MTM Network Receive queue.
*
*	Returns:
*	SUCCESS or FAILURE
*
*/
RETURNSTATUS
mtm_client_msg(void)
{
	int	i;
	/*
	*	Check to see if any client sockets are set
	*/
	for(i=0;i<MTMMaxClient;i++)
	{
		if(MTMRoutingTbl[i].sd != DISCONNECTED)
		{
			if(FD_ISSET(MTMRoutingTbl[i].sd,&MTMReadMask))
			{
				if (mtm_skt_recv(MTMMsg, &MTMRoutingTbl[i]) == SUCCESS)
					mtm_client_single_msg();
			}
		}
	}

	return SUCCESS;
}

static RETURNSTATUS
mtm_client_single_msg(void)
{
	RETURNSTATUS		rc = SUCCESS;
	SLONG 			msg_length = 0;
	MTM_SERVER_TYPE_TABLE	*stbl_entry = (MTM_SERVER_TYPE_TABLE *)NULL;
	MTM_MSG_HEADER		*pHeader;
	SLONG			return_code;
	struct	timeval 	tval;
	struct	timezone 	tzone;
	/*
	*	Check if message header is usable
	*/
	pHeader = (MTM_MSG_HEADER *)MTMMsg;
	if (pHeader == NULL)
	{
		MTM_EFD(EFAULT);
		return FAILURE;
	}

	pHeader->mtype.slot_id = 1;

	/*
	*	Check if table entry is valid
	*/
	stbl_entry = (MTM_SERVER_TYPE_TABLE *)&MTMSrvTbl[pHeader->srv_type];
	if (stbl_entry == NULL)
	{
		MTM_EFD(EFAULT);
		return FAILURE;
	}

	msg_length = pHeader->length + sizeof(MTM_MSG_HEADER);
        if (msg_length > MTMMaxMsgSize)
        {
                MTM_EFD(EFBIG);
                return FAILURE;
        }
#ifdef DEBUG
	fprintf(stdout,"mtm_client_single_msg: Routing message to server\n");
	fprintf(stdout,"\tService Type = %d\n",pHeader->srv_type);
	fprintf(stdout,"\tClient Port = %d\n",pHeader->port);
	fprintf(stdout,"\tClient Sd = %d\n",pHeader->sd);
	fprintf(stdout,"\tService Class QID = %d\n",stbl_entry->server_type_qid);
	fprintf(stdout,"\tMessage Length = %d\n",msg_length);
	LV(msg_length,(char *)MTMMsg);
	fflush(stdout);
#endif

	do
	{
		/*
		*	If Server of this server type is active, send msg
		*/
		if(stbl_entry->active_servers > 0)
		{
			/*
			*	We must update the server's client table.
			*	The reason is that if this is a request, the
			*	server must know how to return the reply.
			*/
			rc = update_stbl_entry(stbl_entry,pHeader,&return_code);

			/*
			*	Check for error
			*/
			if (rc < 0)
			{
#ifdef DEBUG
	fprintf(stdout,"mtm_client_single_msg: Failed update_stbl_entry() call,rc is %d, return_code is %d\n",rc,return_code);
	fflush(stdout);
#endif
				break;
			}

			/*
			*	Set up the timer here
			*/
			MTMTimeout.value = 10;
			sca_SetupTimer((void *)mtm_client_single_msg, &MTMTimeout, (void *)mtm_alarm_catcher);

			/* if mtm_stats_on is TRUE, then set the time-in field 
			*  in mtm header to the current time in microseconds
			*/
			
			if( MTMStatsTbl[pHeader->srv_type].mtm_stats_on == TRUE )
			{
				MTMStatsTbl[pHeader->srv_type].total_server_req++;
				gettimeofday(&tval,&tzone);
				tval.tv_usec = ( tval.tv_sec * 1000 * 1000 ) + tval.tv_usec;
				pHeader->time_in = tval.tv_usec;

			}

			/*
			*	Send message
			*/
			rc = sca_msgsnd(stbl_entry->server_type_qid,
					(struct msgbuf *)MTMMsg,
					msg_length,
					(int)0,
					&MTMTimeout,
					&return_code);
			/*
			*	Cancel the timer here
			*/
			sca_CancelTimer((void *)mtm_client_single_msg, &MTMTimeout);

			/*
			*	Check for error
			*/
			if (rc < 0)
			{
#ifdef DEBUG
	fprintf(stdout,"mtm_client_single_msg: Failed sca_msgsnd() call, rc is %d, return_code is %d\n",rc,return_code);
	fflush(stdout);
#endif
				break;
			}

#ifdef DEBUG
	fprintf(stdout,"mtm_client_single_msg: MTM Stats for server type [%d] : %d",pHeader->srv_type,MTMStatsTbl[pHeader->srv_type].mtm_stats_on);
	fprintf(stdout,"mtm_client_single_msg: pHeader->time_in : %ld",pHeader->time_in);
	fflush(stdout);
#endif

			TotalActiveReqst++;

			/*
			*	At this point everything is ok, set rc
			*	to 0 to indicate no error.
			*/
			rc = 0;
		}
		else
		{
			/*
			*	stbl_entry->active_servers is 0. That means we
			*	can't route the client message to the server.
			*/
#ifdef DEBUG
	fprintf(stdout,"mtm_client_single_msg: Can't find a server to route message to\n");
	fflush(stdout);
#endif
			rc = FAILURE;
			return_code = MTM_NO_ACTIVE_SRVS;
		}

		/*
		*	Nothing else to do. Break here.
		*/
		break;

	} while(0);

	if (rc != 0)
	{
		/*
		*	Stand-in for the server and tell the client
		*	there is a problem with routing the message
		*	to the server. The client message is discarded,
		*	and the client will have to retry at a later time.
		*/
		pHeader->return_code = FAILURE;
		pHeader->reason_code = return_code;
		mtm_skt_send(MTMMsg);
		MTM_EFD(return_code);
		return FAILURE;
	}

	return SUCCESS;
}


/*
*	update_stbl_entry
*
*	Update the server table entry.
*
*/
static RETURNSTATUS 
update_stbl_entry(MTM_SERVER_TYPE_TABLE *stbl_entry,MTM_MSG_HEADER *pHeader, SLONG *return_code)
{
	register int		i,j;
	struct timeval  	time_value;
	struct timezone 	time_zone;

	/*
	*	Check if we have valid input pointers
	*/
	if ((stbl_entry == NULL) || (pHeader == NULL))
	{
		*return_code = EFAULT;
		MTM_EFD(EFAULT);
		return FAILURE;
	}

	/*
	*	Check to see if this client is already in the
	*	Service Table for this server type.
	*/
    	for(i=0;i<MTMMaxClient;i++)
    	{
		if(stbl_entry->cl_tbl[i].sd == pHeader->sd)
			break;
	}
	
	if(i == MTMMaxClient)
	{
	   /*
	    *	Client is not in the Service Table for this 
	    *	server type.
	    *	Find a free slot.
	    */
	   for(i=0;i<MTMMaxClient;i++)
	   {
	   	if(stbl_entry->cl_tbl[i].sd == DISCONNECTED)
		{
		   /*
		    *	Find the entry for this client
		    *	in the Routing Table.
		    */
		   for(j=0;j<MTMMaxClient;j++)
		   {
			if(pHeader->sd == MTMRoutingTbl[j].sd)
			{
			   stbl_entry->cl_tbl[i].port = MTMRoutingTbl[i].port;
			   (void)memcpy(stbl_entry->cl_tbl[i].ip_address, 
					MTMRoutingTbl[j].ip_address, 
					IP_ADDR_LEN);
			   stbl_entry->cl_tbl[i].time_connected = MTMRoutingTbl[j].time_connected;
			   (void)mtm_update_jrnl(REQST_MSG, pHeader->srv_type, 
						(void *)&stbl_entry->cl_tbl[i]);
			   /*
			    *	Need the index into the client table
			    *	in order to clear out client table
			    *	entry when a disconnect occurs.
			    */
			   MTMRoutingTbl[j].cl_tbl_index = i;
			   break;
			}
		   }

		   if(j == MTMMaxClient)
		   {
			/* 
			 *  Can't find client in the client routing table
			 */
			*return_code = EIO;
			return FAILURE;
		   }
		   else
		   {
			/*
			 *	ok to update server table entry
			 */
			stbl_entry->cl_tbl[i].sd = pHeader->sd;
			stbl_entry->total_client_connects++;
        		stbl_entry->current_client_connects++;
			TotalClientsConnected++;
		   }
		   break;
		}
	   }
		
	   if(i == MTMMaxClient)
	   {
		/*
		 *	No free slots available
		 */
		*return_code = MTM_CLIENT_TABLE_FULL;
		return FAILURE;
	   }
	}

	/*
	*	Update server's client statistics
	*/
	gettimeofday (&time_value, &time_zone);
	stbl_entry->cl_tbl[i].recv_time = time_value.tv_sec;
	stbl_entry->cl_tbl[i].microsecs_recv_time = time_value.tv_usec;
	stbl_entry->cl_tbl[i].reqst_msgs++;
	stbl_entry->total_client_reqsts++;
	stbl_entry->cl_tbl[i].state = REQUEST_PENDING;
	(void)mtm_update_jrnl(REQST_MSG, pHeader->srv_type,
                	      (void *)&stbl_entry->cl_tbl[i]);

	return SUCCESS;
}
