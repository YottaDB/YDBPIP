/*
*	zcall.h - Sanchez Message Transport Manager for UNIX
*
*	Copyright(c)1994 Sanchez Computer Associates, Inc.
*	All Rights Reserved
*
*	ORIG:	Sara G. Walters - 21 Feb 1995
*
*	DESC:
*
*   $Id$
*   $Log:	extcall.h,v $
 * Revision 1.3  06/10/27  thoniyim
 * Added version info.
 *
 * Revision 1.2  96/03/22  16:31:46  16:31:46  zengf (Fan Zeng)
 * more external calls
 * 
 * Revision 1.1  95/07/24  11:26:55  11:26:55  rcs ()
 * Initial revision
 * 
 * Revision 1.3  95/05/22  15:05:43  15:05:43  sca ()
 * I VMS
 * 
 * Revision 1.2  95/05/22  15:02:22  15:02:22  sca ()
 * I VMS
 * 
*   $Revision: 1.2 $
*
*/

#ifndef 	ZCALL_H
#define 	ZCALL_H

#include <scatype.h>

#define TTY 		"TTY"
#define MT			"MT"
#define NODENAME	"NODENAM"
#define DINO		"DINO"
#define MTMPRIV		"MTMPRIV"
#define SPAWN		"DETACH"
#define MTMGRP		"sca"
#define SYSGRP		"sys"
#define DETACH		0
#define NETWORK		1
#define LOCAL		3
#define REMOTE		5

#define VERSION "alerts.sl (Linux - 64 bit) V1.2 Aug 15, 2008"

typedef struct {
	char	login[24];
	char	login_time[24];
	char	job_name[80];
	char	cpu_time[24];
	char	tty[12];
	SLONG	pid;
	SLONG	ppid;
} PROCESSDATA;

/*
*	Prototypes
*/

void
clxfr(int,char *,char *,char *,char *,char *,char *,char *,char *,SLONG *);

void
create_pid_list(SLONG *);

void
diff(int,char *,char *,char *,STR_DESCRIPTOR *,SLONG *);

void
asc2ebc(int,STR_DESCRIPTOR *,STR_DESCRIPTOR *,SLONG *);

void
ebc2asc(int,STR_DESCRIPTOR *,STR_DESCRIPTOR *,SLONG *);

void
expsca(int,STR_DESCRIPTOR *,SLONG,STR_DESCRIPTOR *);

void
extsleep1(int,SLONG);


void
feptfile(int,char *,char *,char *,char *,SLONG *);

void
getcharset(int,SLONG *);

void
getcputime(int,SLONG *,STR_DESCRIPTOR *,SLONG *);

void
getdevclass(int,char *,STR_DESCRIPTOR *,SLONG *);

void
geterminal(int,SLONG *,STR_DESCRIPTOR *,SLONG *);

void
getfileinfo(int,char *,char *,STR_DESCRIPTOR *,SLONG *);

void
getfreeblk(int,char *,SLONG *);

void
getgroup(int,SLONG *,SLONG *);

void
getimage(int,SLONG *,STR_DESCRIPTOR *,SLONG *);

void
getjobtype(int,SLONG *,SLONG *);

void
getlogintime(int,SLONG *,STR_DESCRIPTOR *,SLONG *);

void
getmaxblk(int,char *,SLONG *);

void
getmember(int,SLONG *,STR_DESCRIPTOR *,SLONG *);

void
getnodename(int,STR_DESCRIPTOR *);

void
getparentpid(int,SLONG *,SLONG *,SLONG *);

void
getprcnam(int,SLONG *,STR_DESCRIPTOR *,SLONG *);

void
getprocessid(int,SLONG *);

void
getprocid(int,SLONG *,STR_DESCRIPTOR *,SLONG *);

void
gettime(int,char *);

void
getusername(int,STR_DESCRIPTOR *,SLONG *);

SLONG
job_type(SLONG ,char *,SLONG *);

void
listpids(int,SLONG *,SLONG *);

void
lnx(int,STR_DESCRIPTOR *,SLONG,STR_DESCRIPTOR *);

void
logsca(int,STR_DESCRIPTOR *,SLONG,STR_DESCRIPTOR *);

void
mtmbod(int,char *,char *,char *,SLONG *);

void
mtmeod(int,char *,char *,char *,char *,char *,SLONG *);

void
permissions(int,char *,SLONG *);

void
prunning(int,char *,SLONG *);

void
pwd(int,STR_DESCRIPTOR *,SLONG *);

void
readport(int,STR_DESCRIPTOR *,SLONG *);

void
rtb(int,STR_DESCRIPTOR *,STR_DESCRIPTOR *, SLONG *);

void
rtbar(int,STR_DESCRIPTOR *,STR_DESCRIPTOR *, SLONG *);

void
rtnupdat(int,char *,char *,char *,char *,SLONG *);

void
stfstart(int,char *,char *,SLONG *);

void
stfstop(int,char *,char *,SLONG *);

void
unpack(int,STR_DESCRIPTOR *,SLONG,STR_DESCRIPTOR *);

void
unpack2(int,STR_DESCRIPTOR *,SLONG,SLONG,SLONG,STR_DESCRIPTOR *);

void
validpid(int,SLONG *);

void
pgtm(int,SLONG,SLONG *);

void
xor(int,STR_DESCRIPTOR *,SLONG *);
#endif
