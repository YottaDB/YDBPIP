/*
*	mtmerrno.h - Sanchez Message Transport Manager for UNIX
*
*	Copyright(c)1992 Sanchez Computer Associates, Inc.
*	All Rights Reserved
*
*	ORIG:	Dan Russell - Design and implementation of original Message Transport Manager for VMS
*	ORIG:	Sara G. Walters - 11 Jan 1995
*
*	DESC:
*
*   $Id$
*   $Log:	mtmerrno.h,v $
 * Revision 1.1  96/02/29  10:29:43  10:29:43  zengf (Fan Zeng)
 * Initial revision
 * 
 * Revision 1.3  95/08/11  14:42:57  14:42:57  rcs ()
 * Benchmark bug fixes
 * 
 * Revision 1.2  95/05/22  15:13:14  15:13:14  sca ()
 * sgI VMS
 * 
*   $Revision: 1.1 $
*
*/

#ifndef MTMERRNO_H
#define MTMERRNO_H

#define MAX_MSGS						40
#define MTM_INVALID_CMD					-1
#define MTM_STOP_COMMAND_PROCESSED		-2
#define MTM_SHUTDOWN_PENDING			-3
#define MTM_DUPPRCNM					-4
#define MTM_TOOMANY						-5
#define MTM_ADDSRV						-6
#define MTM_INVALID_SRVID				-7
#define MTM_NOSRV_REPLY					-8
#define MTM_DELSRV						-9
#define MTM_JRNL_ON						-10
#define MTM_JRNL_OFF					-11
#define MTM_NO_JRNL						-12
#define MTM_NO_SRV_CONNECTED			-13
#define MTM_NO_CL_CONNECTED				-14
#define MTM_JRNL_FLAG_INVALID			-15
#define MTM_PEND						-16
#define MTM_CLSTAT						-17
#define MTM_SVSTAT						-18
#define MTM_NO_ACTIVE_SRVS				-19
#define MTM_INVALID_SRVCLASS			-20
#define MTM_INVALID_CMD_OPTIONS			-21
#define MTM_MTM_STARTUP					-22
#define MTM_INVALID_CLIENT_STATE		-23
#define MTM_ACTIVE_MSG_TABLE_FULL		-24
#define MTM_CLIENT_TABLE_FULL			-25
#define MTM_COMM_STARTUP				-26
#define MTM_CLIENT_ROUTING_TABLE_FULL	-27
#define MTM_CLIENT_CONNECTED			-28
#define MTM_REMOTE_HOST_NOT_CONFIGURED	-29
#define MTM_CLIENT_NOT_CONNECTED		-30
#define MTM_INVALID_CNTRL_MSG			-31
#define MTM_ALL_DELSRV					-32
#define MTM_MSG_TOO_BIG					-33
#define MTM_INVALID_MSG					-34
#define MTM_SERVER_DISCONNECTED			-35
#define MTM_NO_SRV_TYPE					-36
#define MTM_NO_SRV_TYPE_STR				"CS_NOSVTYP"
#define MTM_SEND_FAILED					-37
#define MTM_NO_MTM						-38
#define MTM_INVALID_CLIENT_CONNECT		-39
#define MTM_STARTUP_MSG 				-40

#define MTM_ERR_MSG_BYTE   				'1'

#endif
