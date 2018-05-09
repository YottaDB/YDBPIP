
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
*   $Revision: 1.3 $
*
*/

#ifndef 	MTMEXT_H
#define 	MTMEXT_H
#include 	"./mtm.h"
#ifdef _AIX
#include 	<sys/select.h>
#endif

/*
*	Extern Globals for the Message Transport Monitor
*/
extern MTM_SIGNAL_FLAGS 		MTMSignalFlags;
extern MTM_SERVER_TYPE_TABLE	MTMSrvTbl[];
extern MTM_CLIENT_ROUTING_TABLE MTMRoutingTbl[];
extern char						*MTMValidClients;
extern SLONG 					MTMControlQid;
extern SLONG 					MTMServerReplyQid;
extern FILE 					*MTMLogFp;
extern int						MTMFifoFd;
extern SLONG 					MTMProcessId;
extern SLONG 					MTMMaxMsgSize;
extern SSHORT 					MTMInternetPort;
extern SLONG 					MTMShutDownPending;
extern SLONG 					TotalActiveReqst;
extern SLONG 					TotalActiveSrvs;
extern SLONG 					TotalClientsConnected;
extern char						*MTMMsg;
extern fd_set					MTMReadMask;
extern SLONG					MTMListenSd;

#endif

