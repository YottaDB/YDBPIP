/*
*	mtmsgs.h - Sanchez Message Transport Manager for UNIX
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
*   $Log:	mtmmsgs.h,v $
 * Revision 2.1  00/01/17  11:18:03  11:18:03  lyh ()
 * storm trooper release
 * 
 * Revision 1.1  96/02/29  10:29:50  10:29:50  zengf (Fan Zeng)
 * Initial revision
 * 
 * Revision 1.3  95/08/11  14:43:00  14:43:00  rcs ()
 * Benchmark bug fixes
 * 
 * Revision 1.2  95/05/22  15:13:15  15:13:15  sca ()
 * sgI VMS
 * 
*   $Revision: 2.1 $
*
*/

#ifdef MTMMSGS_H
#define MTMMSGS_H

static char *mtm_msgs[MAX_MSGS] =
	{
		"SCAMTM ERROR:		Invalid reason code.",
		"SCAMTM ERROR:		Received control message with invalid command field.",
		"SCAMTM NOTIFICATION:	Stop command successfully processed.",
		"SCAMTM NOTIFICATION:	Shutdown is pending.",
		"SCAMTM ERROR:		Duplicate connection",
		"SCAMTM ERROR:		Connection attempted. Maximum number of servers already running.",
		"SCAMTM NOTIFICATION:	Server connected successfully.",
		"SCAMTM ERROR:		Received control message with invalid Server ID field.",
		"SCAMTM ERROR:		Server did not Reply to Client Request",
		"SCAMTM NOTIFICATION:	Server disconnected successfully.",
		"SCAMTM NOTIFICATION:	Server journaling is on.",
		"SCAMTM NOTIFICATION:	Server journaling is off.",
		"SCAMTM ERROR:		No journal file exist."
		"SCAMTM NOTIFICATION:	No Servers are currently connected.",
		"SCAMTM NOTIFICATION:	No clients are currently connected.",
		"SCAMTM ERROR:		Received control message with invalid journal flag.",
		"SCAMTM NOTIFICATION:	Client Pending Messages command successfully processed.",
		"SCAMTM NOTIFICATION:	Client Statistics command successfully processed.",
		"SCAMTM NOTIFICATION:	Server Statistics command successfully processed.",
		"SCAMTM NOTIFICATION:	No active servers.",
		"SCAMTM NOTIFICATION:	Received control message with invalid server type field.",
		"SCAMTM ERROR:		Usage: mtm -lLOGFILE  sMAXMSGSIZE -cVALIDCLIENTS.",
		"SCAMTM NOTIFICATION:	MTM startup is successful.",
		"SCAMTM ERROR:		Client state is invalid.",
		"SCAMTM ERROR:		Client Table is full.",
		"SCAMTM ERROR:		Active message table is full.",
		"SCAMTM NOTIFICATION:	MTM startup is successful.",
		"SCAMTM ERROR:		Client Routing Table is full.",
		"SCAMTM NOTIFICATION:	Client is already connected.",
		"SCAMTM ERROR:		Remote host is not configured.",
		"SCAMTM NOTIFICATION:	Client is not connected.",
		"SCAMTM ERROR:		Invalid control message.",
		"SCAMTM ERROR:          All Servers deleted.",
		"SCAMTM ERROR:          Message is too big.",
		"SCAMTM ERROR:          Invalid Message.",
		"SCAMTM NOTIFICATION:   Server disconnected.",
		"SCAMTM ERROR:          Invalid Server Type.",
		"SCAMTM ERROR:          Send Message to Server Failed.",
		"SCAMTM ERROR:          No MTM Process.",
		"SCAMTM ERROR:          Invalid Client Connect."

#endif
