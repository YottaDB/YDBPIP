
/*
*	mtmext.h - Sanchez Message Transport Manager for UNIX
*
*	Copyright(c)1992 Sanchez Computer Associates, Inc.
*	All Rights Reserved
*
*	ORIG:	Sara G. Walters - 11 Jan 1995
*
*	DESC:
*
*   $Id$
*   $Log:	mtmext.h,v $
 * Revision 2.4  00/07/06  17:18:00  17:18:00  lyh ()
 * Removed certain restrictions for tcp client (MTM v2.0.1)
 * 
 * Revision 2.3  00/03/30  13:45:02  13:45:02  lyh ()
 * Minor correction
 * 
 * Revision 2.2  00/03/03  15:32:39  15:32:39  lyh ()
 * sand comber release
 * 
 * Revision 2.1  00/01/17  11:18:02  11:18:02  lyh ()
 * storm trooper release
 * 
 * Revision 1.2  99/12/28  11:15:00  11:15:00  lyh ()
 * added 3 new control messages: SENDMSG, GETVER, GETPARAM
 * 
 * Revision 1.1  99/12/27  16:05:20  16:05:20  lyh ()
 * Initial revision
 * 
 * Revision 1.3  96/03/21  15:04:15  15:04:15  zengf (Fan Zeng)
 * Collapsed directories and replaced signals with fifos.
 * 
 * Revision 1.2  96/03/13  10:12:10  10:12:10  zengf (Fan Zeng)
 * prepare for removing signals
 * ,
 * 
 * Revision 1.1  96/02/29  10:29:47  10:29:47  zengf (Fan Zeng)
 * Initial revision
 * 
 * Revision 1.3  95/08/11  14:42:59  14:42:59  rcs ()
 * Benchmark bug fixes
 * 
 * Revision 1.2  95/05/22  15:13:15  15:13:15  sca ()
 * sgI VMS
 * 
*   $Revision: 2.4 $
*
*/

#ifndef 	MTMEXT_H
#define 	MTMEXT_H
#include 	<mtm.h>
#include 	<sys/select.h>

/*
*	Extern Globals for the Message Transport Monitor
*/
extern MTM_SIGNAL_FLAGS 		MTMSignalFlags;
extern MTM_SERVER_TYPE_TABLE		MTMSrvTbl[];
extern MTM_CLIENT_ROUTING_TABLE 	*MTMRoutingTbl;
extern MTM_STATS_TABLE		MTMStatsTbl[];
extern char				*MTMValidClients;
extern SLONG 				MTMControlQid;
extern SLONG 				MTMServerReplyQid;
extern FILE 				*MTMLogFp;
extern int				MTMFifoFd;
extern SLONG 				MTMProcessId;
extern SLONG 				MTMMaxMsgSize;
extern SLONG 				MTMInternetPort;
extern SLONG 				MTMShutDownPending;
extern SLONG 				TotalActiveReqst;
extern SLONG 				TotalActiveSrvs;
extern SLONG 				TotalClientsConnected;
extern char				*MTMMsg;
extern fd_set				MTMReadMask;
extern SLONG				MTMListenSd;
extern SLONG				MTMMaxClient;
extern SLONG				MTMAsyncMode;
extern st_length			MTMLength;
extern st_timeout			MTMTimeout;
extern char				MTMProcessName[MAX_NAME_LEN];
extern char				MTMLogFileName[MAX_NAME_LEN];
extern st_tcpclient			*MTMTcpClient;
extern st_tcpclient			*MTMAsyncClient;
extern int				MTMTcpCount;
extern char				MTMRootIp[IP_ADDR_LEN+1];
extern char				MTMMsgFileName[MAX_NAME_LEN];
extern int				msgflag;

#endif

