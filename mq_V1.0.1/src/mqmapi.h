/*****************************************************************************
*
*	mqmapi.h
*
*	Copyright(c)2000 Sanchez Computer Associates, Inc.
*	All Rights Reserved
*
*	Description: Sanchez MQSeries API M External Calls for UNIX
*
* $Author: lyh $
*
* $Date: 2000/11/08 20:06:12 $
*
* $Id: mqmapi.h,v 1.1 2000/11/08 20:06:12 lyh Exp lyh $
*
* $Log: mqmapi.h,v $
 * Revision 1.1  2000/11/08  20:06:12  lyh
 * Initial revision
 *
*
* $Revision: 1.1 $
*
*****************************************************************************/

#ifndef MQMAPI_H
#define MQMAPI_H

void SrvConnect(int,char *,SLONG *,SLONG *);
void SrvDisconnect(int);
void SrvGetMsg(int,STR_DESCRIPTOR *,char *,SLONG,SLONG *);
void SrvReply(int,STR_DESCRIPTOR *,STR_DESCRIPTOR *,SLONG *);
void ClConnect(int,char *,SLONG *,SLONG *);
void ClDisconnect(int,SLONG,SLONG *);
void ClExchmsg(int,STR_DESCRIPTOR *,STR_DESCRIPTOR *,STR_DESCRIPTOR *,char *,SLONG,SLONG,SLONG *);
void ClSend(int,STR_DESCRIPTOR *,STR_DESCRIPTOR *,SLONG,SLONG *);
void psconnect(int,SLONG *,SLONG *);
void psdisconnect(int,SLONG *,SLONG *);
void pub(int,STR_DESCRIPTOR *,STR_DESCRIPTOR *,SLONG,SLONG *);
/***
void SrvGetMsg(int,STR_DESCRIPTOR *,SLONG,SLONG *);
void SrvReply(int,STR_DESCRIPTOR *,SLONG *);
void ClExchmsg(int,STR_DESCRIPTOR *,STR_DESCRIPTOR *,SLONG,SLONG,SLONG *);
void ClSend(int,STR_DESCRIPTOR *,SLONG,SLONG *);
***/
#endif
