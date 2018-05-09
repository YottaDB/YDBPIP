
/*
*	comm.h - Sanchez Message Transport Manager for UNIX
*
*	Copyright(c)1992 Sanchez Computer Associates, Inc.
*	All Rights Reserved
*
*	ORIG:	Sara G. Walters - 23 Feb 1995
*
*	DESC:
*
*   $Id$
*   $Log:	mtmcomm.h,v $
 * Revision 1.1  96/02/29  10:29:34  10:29:34  zengf (Fan Zeng)
 * Initial revision
 * 
 * Revision 1.2  95/05/22  15:13:14  15:13:14  sca
 * sgI VMS
 * 
*   $Revision: 1.1 $
*
*/

#ifndef 	MTMCOMM_H
#define 	MTMCOMM_H

enum MTM_COMM_ACTION_TYPES 
{
	MTM_COMM_INIT_ACTION,
	MTM_COMM_SEND_ACTION,
	MTM_COMM_RECV_ACTION ,
	MTM_COMM_CONNECT_ACTION 
};

#endif
