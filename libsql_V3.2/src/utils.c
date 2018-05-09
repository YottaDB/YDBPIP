/*
*	utils.c - Sanchez Message Transport Manager for UNIX
*
*	Copyright(c)1992 Sanchez Computer Associates, Inc.
*	All Rights Reserved
*
*	ORIG:	Fan Zeng
*
*	DESC:	Miscellanous utilities.
*
*   $Id$
*   $Log:	utils.c,v $
 * Revision 1.3  96/03/21  15:04:25  15:04:25  zengf (Fan Zeng)
 * Collapsed directories and replaced signals with fifos.
 * 
 * Revision 1.2  96/03/13  10:03:37  10:03:37  zengf (Fan Zeng)
 * prepare for removing signals
 * 
 * Revision 1.1  96/02/28  17:31:27  17:31:27  zengf (Fan Zeng)
 * Initial revision
 * 
*	$Revision: 1.3 $
*/


#include <stdio.h>
#include <signal.h>
#include <errno.h>
#include <fcntl.h>
#include <limits.h>
#include <sys/types.h>
#ifdef _AIX
#include <sys/select.h>
#endif
#include "./mtm.h"
#include "./mtmprototypes.h"
#include "./mtmext.h"

/*Date Format*/
char sShortDate[25] = "MM/DD/YYYY";
/*Decimal Format*/
char sDec[2] = ".";
/*Date Delimiter*/
char sDateDelim[2] = "/";

/*
 * DESCRIPTION
 *	lock a region in file
 */
int
mtm_lock_reg (
        int fd,
        int cmd,
        int type,
        off_t offset,
        int whence,
        off_t len)
{
 
        struct flock    lock;
 
        lock.l_type = type;
        lock.l_start = offset;
        lock.l_whence = whence;
        lock.l_len = len;
 
        return ( fcntl (fd, cmd, &lock));
}


void
mtm_get_mtm_pid (char *key_file,
				 SLONG	*mtm_process_id,
				 SLONG	*return_code)
{
	int		fd;


	/* 
	 *	Get the MTM process ID, which is stored in the key file by MTM
	 */
	if ((fd = open (key_file, O_RDONLY)) == FAILURE)
	{
		MTM_LOG(errno);
		*return_code = errno;
		return;
	}

	if (read (fd, (void *) mtm_process_id, sizeof (SLONG)) == FAILURE) 
	{
		MTM_LOG(errno);
		*return_code = errno;
		return;
	}

	if (close (fd) == FAILURE)
	{
		MTM_LOG(errno);
		*return_code = errno;
		return;
	}
 	
	return;
}

/*
 *	mtm_signal
 *
 *	Description:
 *	Reliable version of signal (), using POSIX sigaction ().
 *	Interrupted system calls are restarted automatically. 
 *
 *	Returns:
 *	See man page for function signal.
 */
Sigfunc *
mtm_signal (int signo, Sigfunc *func)
{
	struct sigaction	act, oact;

	act.sa_handler = func;
	sigemptyset (&act.sa_mask);
	act.sa_flags = 0;

#ifdef	SA_RESTART
	act.sa_flags |= SA_RESTART;			/* SVR4, 4.3+BSD */
#endif

	if (sigaction (signo, &act, &oact) < 0)
		return (SIG_ERR);

	return (oact.sa_handler);
}

/*
 *	mtm_signal_intr
 *
 *	Description:
 *	Reliable version of signal (), using POSIX sigaction ().
 *	Interrupted system calls are not restarted.
 *
 *	Returns:
 *	See man page for function signal.
 */
Sigfunc *
mtm_signal_intr (int signo, Sigfunc *func)
{
	struct sigaction	act, oact;

	act.sa_handler = func;
	sigemptyset (&act.sa_mask);
	act.sa_flags = 0;

#ifdef	SA_INTERRUPT
	act.sa_flags |= SA_INTERRUPT;		/* SunOS */
#endif

	if (sigaction (signo, &act, &oact) < 0)
		return (SIG_ERR);

	return (oact.sa_handler);
}


#ifdef DEBUG

#include <stdio.h>
#define MAX_CHAR_PER_LINE 16

void hex_dmp(char *, int);
void chr_dmp(char *, int);

LV(int length, char *msg)
{
	char	hex[MAX_CHAR_PER_LINE];
	char	ch;
	int		count;

	fprintf(stdout,"LV: Message Length %d\n",length);

	memset (hex, 0, MAX_CHAR_PER_LINE);
	count = 0;

	while (length > 0) {
		ch = *msg++;
		hex[count] = ch;
		length--;
		count++;
		if (count == MAX_CHAR_PER_LINE) {
			hex_dmp(hex, count);
			chr_dmp(hex, count);
			count = 0;
			memset (hex, 0, MAX_CHAR_PER_LINE);
		}
	}
	if (count) {
		hex_dmp(hex, count);
		chr_dmp(hex, count);
	}

	fflush(stdout);
}


void hex_dmp(char *msg, int count)
{
	int	i;
	int j;

	for (i = 0; i < count; i++)
			fprintf(stdout, "%02x ", (unsigned char) msg[i]);
	for (j = i; j < MAX_CHAR_PER_LINE; j++)
			fprintf(stdout, "   ");

	fprintf(stdout, "----- ");
}


void chr_dmp(char *msg, int count)
{
	int	i;

	for (i = 0; i < count; i++) {
		if ((msg[i] > 31) && (msg[i] < 127))
			fprintf(stdout, "%c", msg[i]);
		else
			fprintf(stdout, "~");
	}
	fprintf(stdout, "\n");
}

#endif

