/*
*	sigutils.c
*
*	Copyright(c)1992 Sanchez Computer Associates, Inc.
*	All Rights Reserved
*
*
*	DESC:	UNIX System calls
*
*   $Id$
*   $Log:	utils.c,v $
 * Revision 1.1  95/07/24  11:26:19  11:26:19  rcs ()
 * Initial revision
 * 
 * Revision 1.2  95/05/22  15:01:53  15:01:53  sca ()
 * sgI VMS
 * 
*   $Revision: 1.1 $
*
*/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <signal.h>
#include <time.h>
#include <sys/stat.h>
#include "extcall.h"

void
textsleep(int count,SLONG timeout)
{
	signal(SIGUSR1,quit);
	/*
	*	Sleep for timeout
	*/
	sleep(timeout);	

	return;
}

void
quit()
{
	exit();
}

void
sendsig(int count,SLONG pid,SLONG signalno)
{
	/*
	*	Send specified signal to process	
	*/
	kill(pid,signalno);

	return;
}
