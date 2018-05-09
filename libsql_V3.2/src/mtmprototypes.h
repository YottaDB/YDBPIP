/*
*	mstprorotypes.h - Sanchez Message Transport Manager for UNIX
*
*	Copyright(c)1992 Sanchez Computer Associates, Inc.
*	All Rights Reserved
*
*	ORIG:	Sara G. Walters - 11 Jan 1995
*
*	DESC:
*
*   $Id$
*   $Log:	mtmprototypes.h,v $
 * Revision 1.3  96/04/25  16:13:24  16:13:24  zengf (Fan Zeng)
 * fix client message bug.
 * 
 * Revision 1.2  96/03/21  15:04:21  15:04:21  zengf (Fan Zeng)
 * Collapsed directories and replaced signals with fifos.
 * 
 * Revision 1.1  96/02/29  10:29:53  10:29:53  zengf (Fan Zeng)
 * Initial revision
 * 
 * Revision 1.1  95/08/11  14:43:02  14:43:02  rcs ()
 * Initial revision
 * 
 * Revision 1.3  95/07/19  14:35:21  14:35:21  rcs ()
 * Bug fixes as a result of MTM testing.
 * 
 * Revision 1.2  95/05/22  15:13:15  15:13:15  sca ()
 * sgI VMS
 * 
*   $Revision: 1.3 $
*
*/

#ifndef MTMPROTOTYPES_H
#define MTMPROTOTYPES_H

#include <fcntl.h>

RETURNSTATUS 	mtm_control_msg(void);
RETURNSTATUS 	mtm_client_msg(void);
RETURNSTATUS 	mtm_server_msg(void);
void			mtm_shutdown(void);
void        	mtm_signal_catcher(int);
void 			mtm_update_jrnl(enum MTM_JRNL_MESSAGES, SLONG, 
								MTM_CLIENT_TABLE *);
Sigfunc *		mtm_signal(int, Sigfunc *);
Sigfunc *		mtm_signal_intr(int, Sigfunc *);
int				mtm_lock_reg(int,int,int,off_t,int,off_t);
SLONG			mtm_get_server_type (char *, short);
void			mtm_fcntl (int, int, int);

RETURNSTATUS mtm_skt_init(void);
RETURNSTATUS mtm_skt_connect(void);
RETURNSTATUS mtm_skt_accept(void);
RETURNSTATUS mtm_skt_recv(char *, MTM_CLIENT_ROUTING_TABLE *);
RETURNSTATUS mtm_skt_send(char *);

#endif
