
/*
*	mtmserver.c - Sanchez Message Transport Manager for UNIX
*
*	Copyright(c)1992 Sanchez Computer Associates, Inc.
*	All Rights Reserved
*
*	ORIG:	Sara G. Walters - 11 Jan 1995
*
*	DESC:
*
*
*   $Id: mtmserver.c,v 1.1 2000/06/01 00:45:35 lyh Exp lyh $
*   $Log:	mtmserver.c,v $
 * Revision 2.5  05/12/06  paulj ()
 * Modified mtm_server_msg method to update the MTM Stats table 
 * if the mtm_stats_on is TRUE
 *
 * Revision 2.4  00/06/02  13:29:44  13:29:44  lyh ()
 * Changes as a result of porting to other platforms.
 * 
 * Revision 2.3  00/03/13  14:21:30  14:21:30  lyh ()
 * Check pointer to avoid segment violation error
 * 
 * Revision 2.2  00/03/03  15:12:09  15:12:09  lyh ()
 * sand comber release
 * 
 * Revision 2.1  00/01/17  11:16:12  11:16:12  lyh ()
 * storm trooper release
 * 
 * Revision 1.1  99/12/27  16:00:09  16:00:09  lyh ()
 * Initial revision
 * 
 * Revision 1.3  95/07/19  14:16:29  14:16:29  rcs ()
 * Bug fixes as a result of MTM System Test
 * 
 * Revision 1.2  95/05/22  14:49:31  14:49:31  sca ()
 * sgI VMS
 * 
*   $Revision: 2.4 $
*
*/
#include	<ctype.h>
#include	<stdio.h>
#include	<time.h>
#include	<sys/time.h>
#include	<errno.h>
#include	<sys/ipc.h>
#include	<sys/msg.h>
#include	"./scatype.h"
#include	"./mtm.h"
#include	"./mtmprototypes.h"
#include	"./mtmext.h"
#include	"./mtmerrno.h"

/*
*	mtm_server_msg
*	[module number i.e. Future] [module name]
*
*	Description:
*	Processes a server reply msg and sets up the MTMSrvTbl with the
*	necessary management and statistical tracking data.
*
*	Returns:
*	SUCCESS or FAILURE
*/
RETURNSTATUS
mtm_server_msg(void)
{
	RETURNSTATUS 	rc = SUCCESS;
	register int	i = 0;
	float		resp_time = 0;
	struct timeval	time_value;
	struct timezone time_zone;
	int		srv_type;
	SLONG		return_code;
	MTM_MSG_HEADER	*pHeader;
	SLONG wait_time;


	/*
	*	Loop until all reply msgs are read off of the Server receive queue.
	*/
	for(;;)
	{
		/*
		*	Set timer here
		*/
		MTMTimeout.value = 10;
		sca_SetupTimer((void *)mtm_server_msg, &MTMTimeout, (void *)mtm_alarm_catcher);

		/*
		*	Receive message on reply queue
		*/
		rc = sca_msgrcv(MTMServerReplyQid,
				(struct msgbuf *)MTMMsg,
				MTMMaxMsgSize,
				0,
				IPC_NOWAIT,
				&MTMTimeout,
				&return_code);

		/* Calculate the current time in microseconds to find out 
		*  the wait time for the message in the queue
		*/

		gettimeofday(&time_value,&time_zone);
		time_value.tv_usec = (time_value.tv_sec * 1000 * 1000) + time_value.tv_usec;

		/*
		*	Cancel timer here
		*/
		sca_CancelTimer((void *)mtm_server_msg, &MTMTimeout);

		/*
		*	Check for error
		*/
		if (rc <= 0)
		{
			if(return_code != ENOMSG)
			{
				MTM_EFD(return_code);
				if (return_code == E2BIG)
					continue;
				return FAILURE;
			}
			break;
		}
		else
		{
			/*
			*	Check if message header is usable
			*/
			pHeader = (MTM_MSG_HEADER *)MTMMsg;
			if (pHeader == NULL)
			{
				MTM_EFD(EFAULT);
				return FAILURE;
			}
#ifdef DEBUG
	(void)fprintf(stdout,"mtm_server_msg: Msg Length rc %d len %d\n",
						rc,
						pHeader->length);
	LV(rc,MTMMsg);
#endif
			pHeader->return_code = SUCCESS;
			/*
			*	Send server reply msg to the MTM Process.
			*/
			if (mtm_skt_send(MTMMsg) == FAILURE)
			{
				continue;
			}

			TotalActiveReqst--;

			srv_type = pHeader->srv_type;
#ifdef DEBUG
	fprintf(stdout,"mtm_server_msg: Service Class %d\n", srv_type);
	(void)fflush(stdout);
#endif

			/* Update the MTM Stats table*/

			if(MTMStatsTbl[srv_type].mtm_stats_on == TRUE )
			{
				wait_time = (SLONG)time_value.tv_usec - pHeader->time_in;
				MTMStatsTbl[srv_type].total_server_reply++;
				if ( MTMStatsTbl[srv_type].min_reply_time > wait_time || MTMStatsTbl[srv_type].min_reply_time == 0)
					MTMStatsTbl[srv_type].min_reply_time = wait_time;
				if ( MTMStatsTbl[srv_type].max_reply_time < wait_time )
					MTMStatsTbl[srv_type].max_reply_time = wait_time;
				MTMStatsTbl[srv_type].avg_reply_time = (float)MTMStatsTbl[srv_type].avg_reply_time * ( MTMStatsTbl[srv_type].total_server_reply -1 );
				MTMStatsTbl[srv_type].avg_reply_time = (float)( MTMStatsTbl[srv_type].avg_reply_time + wait_time) / MTMStatsTbl[srv_type].total_server_reply;
				if ( MTMStatsTbl[srv_type].min_req_time > pHeader->request_time || MTMStatsTbl[srv_type].min_req_time == 0)
					MTMStatsTbl[srv_type].min_req_time = pHeader->request_time;
				if ( MTMStatsTbl[srv_type].max_req_time < pHeader->request_time )
					MTMStatsTbl[srv_type].max_req_time = pHeader->request_time;
				MTMStatsTbl[srv_type].avg_req_time = (float)MTMStatsTbl[srv_type].avg_req_time * ( MTMStatsTbl[srv_type].total_server_req -1 );
				MTMStatsTbl[srv_type].avg_req_time = (float)( MTMStatsTbl[srv_type].avg_req_time + pHeader->request_time) / MTMStatsTbl[srv_type].total_server_req;
			}


			/*
			*	Find the client table entry
			*/
			for(i=0;i<MTMMaxClient;i++)
			{
				if(MTMSrvTbl[srv_type].cl_tbl[i].sd == pHeader->sd)
				{
					MTMSrvTbl[srv_type].cl_tbl[i].srv_pid = 0; 
					break;
				}
			}
			if(i == MTMMaxClient)
			{
				MTM_EFD(MTM_CLIENT_NOT_CONNECTED);
				return FAILURE;
			}

			(void)mtm_update_jrnl(	RESP_MSG,
						srv_type,
						(void *)&MTMSrvTbl[srv_type].cl_tbl[i]);

			/*
			*	Set up the Statistical data for the 
			*	Servers on a per client basis
			*/
			MTMSrvTbl[srv_type].cl_tbl[i].resp_msgs++;
			MTMSrvTbl[srv_type].total_server_resps++;

			/*
			*	Get the time
			*/
			gettimeofday (&time_value, &time_zone);
			resp_time = time_value.tv_sec -
					MTMSrvTbl[srv_type].cl_tbl[i].recv_time;
			resp_time += (time_value.tv_usec -
					MTMSrvTbl[srv_type].cl_tbl[i].microsecs_recv_time)/1000000.0;

#ifdef DEBUG
	(void)fprintf(stdout,"mtm_server_msg: resp_time %f\n", resp_time);
	fflush(stdout);
#endif
			
			/*	Total resp time	*/
			MTMSrvTbl[srv_type].cl_tbl[i].total_resp_time += resp_time;
			MTMSrvTbl[srv_type].total_resp_time += resp_time;

			/*	Minimum resp time	*/
			if(resp_time < MTMSrvTbl[srv_type].cl_tbl[i].min_resp_time)
				MTMSrvTbl[srv_type].cl_tbl[i].min_resp_time = resp_time;

			/*	Max resp time	*/
			if(resp_time > MTMSrvTbl[srv_type].cl_tbl[i].max_resp_time)
				MTMSrvTbl[srv_type].cl_tbl[i].max_resp_time = resp_time;

			if(resp_time < MTMSrvTbl[srv_type].min_resp_time)
				MTMSrvTbl[srv_type].min_resp_time = resp_time;

			/*	Max resp time	*/
			if(resp_time > MTMSrvTbl[srv_type].max_resp_time)
				MTMSrvTbl[srv_type].max_resp_time = resp_time;

			MTMSrvTbl[srv_type].cl_tbl[i].state = CONNECTED;
		}
	}

	return SUCCESS;
}
