/*
*	mtmapi.h - Sanchez Message Transport Manager for UNIX
*
*	Copyright(c)1992 Sanchez Computer Associates, Inc.
*	All Rights Reserved
*
*	ORIG:	Sara G. Walters - 02 Mar 1995
*
*	DESC:
*
*   $Id$
*   $Log:	mtmapi.h,v $
 * Revision 1.2  96/03/21  15:04:04  15:04:04  zengf (Fan Zeng)
 * Collapsed directories and replaced signals with fifos.
 * 
 * Revision 1.1  96/02/28  17:31:13  17:31:13  zengf (Fan Zeng)
 * Initial revision
 * 
 * Revision 1.3  95/07/19  14:33:07  14:33:07  rcs ()
 * Bug fixes as a result of MTM System Test
 * 
 * Revision 1.2  95/05/22  14:52:47  14:52:47  sca ()
 * I VMS
 * 
*   $Revision: 1.2 $
*
*/

#ifndef MTMAPI_H
#define MTMAPI_H

void SrvConnect(int,char *,SLONG *,SLONG *);
void SrvDisconnect(int);
void SrvGetMsg(int,STR_DESCRIPTOR *,SLONG,SLONG *);
void SrvReply(int,STR_DESCRIPTOR *,SLONG *);
void ClConnect(int,char *,SLONG *);
void ClDisconnect(int,SLONG *);
void ClExchmsg(int,STR_DESCRIPTOR *,STR_DESCRIPTOR *,SLONG,SLONG *);
void MTMCntrl(int,char *,STR_DESCRIPTOR *,char *,char **,SLONG *);
void MTMRunning(int,char *,SLONG *);
void SrvMTMId(int,char *,STR_DESCRIPTOR *);
void FFlush(int);
#endif
