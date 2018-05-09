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
*   $Id: mtmprototypes.h,v 1.1 2000/06/01 00:46:52 lyh Exp lyh $
*   $Log:	mtmprototypes.h,v $
 * Revision 2.5  00/06/02  13:41:52  13:41:52  lyh ()
 * Changes as a result of porting to other platforms.
 * 
 * Revision 2.4  00/03/27  16:10:16  16:10:16  lyh ()
 * wogm release
 * 
 * Revision 2.3  00/03/23  10:54:42  10:54:42  lyh ()
 * added mtm_disable_sd() and mtm_enable_sd() functions
 * 
 * Revision 2.2  00/03/03  15:30:57  15:30:57  lyh ()
 * sand comber release
 * 
 * Revision 2.1  00/01/17  11:18:11  11:18:11  lyh ()
 * storm trooper release
 * 
 * Revision 1.1  99/12/27  16:06:31  16:06:31  lyh ()
 * Initial revision
 * 
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
*   $Revision: 2.5 $
*
*/

#ifndef MTMPROTOTYPES_H
#define MTMPROTOTYPES_H

#include <fcntl.h>
#include <sys/time.h>
#include <sys/msg.h>

RETURNSTATUS 	mtm_control_msg(void);
RETURNSTATUS 	mtm_client_msg(void);
RETURNSTATUS 	mtm_server_msg(void);
void		mtm_shutdown(void);
void        	mtm_signal_catcher(int);
void 		mtm_update_jrnl(enum MTM_JRNL_MESSAGES, SLONG, 
								MTM_CLIENT_TABLE *);
Sigfunc *	mtm_signal(int, Sigfunc *);
Sigfunc *	mtm_signal_intr(int, Sigfunc *);
int		mtm_lock_reg(int,int,int,off_t,int,off_t);
int		connected_clients();
SLONG		mtm_get_server_type (char *, short);
SLONG		mtm_find_any_server();
SLONG		mtm_length(char *, st_length *);
char *		get_version();
void		mtm_fcntl (int, int, int);
void 		mtm_slength(char *, SLONG, st_length *);

RETURNSTATUS 	mtm_skt_init(void);
RETURNSTATUS 	mtm_skt_connect(void);
RETURNSTATUS 	mtm_skt_accept(void);
RETURNSTATUS 	mtm_skt_recv(char *, MTM_CLIENT_ROUTING_TABLE *);
RETURNSTATUS 	mtm_skt_send(char *);
RETURNSTATUS	mtm_skt_active(int);
int		mtm_proc_active(pid_t);
void 		get_proc_st_pcpu(pid_t, char *, float *);
void		mtm_tcp_msg();
void		mtm_alarm_catcher(int);
void		mtm_pause();
int		sca_AlarmSetup(int);
void		sca_SetupTimer(void *, st_timeout *, void *);
void		sca_CancelTimer(void *, st_timeout *);
int		sca_send(SLONG, char *, size_t, int, st_timeout *, SLONG *);
int		sca_recv(SLONG, char *, size_t, int, st_timeout *, SLONG *);
int		sca_select(SLONG, fd_set *, fd_set *, fd_set *, st_timeout *, SLONG *);
void		add_tcp_client(char *);
void		tcp_client_connect();
void		tcp_client_disconnect();
/*
int		sca_msgsnd(SLONG, struct msgbuf *, size_t, int, st_timeout *, SLONG *);
int		sca_msgrcv(SLONG, struct msgbuf *, size_t, long int, int, st_timeout *, SLONG *);
*/
int		mtm_disable_sd();
int		mtm_enable_sd();

#endif
