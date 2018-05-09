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
*   $Id: utils.c,v 1.1 2000/06/01 00:45:35 lyh Exp lyh $
*   $Log:	utils.c,v $
 * Revision 3.0 04/08/17 yurkovicg
 * Added mtm_s64klength function for bby messages over 64K in size.
 * 
 * Revision 2.9  00/07/07  12:02:11  12:02:11  lyh ()
 * added string.h for strlen()
 * replaced MTM_LOG(MTM_INVALID_MSG) with MTM_LOG(EFAULT)
 * This will resolve compiler warning when porting to other platforms.
 * 
 * Revision 2.8  00/06/02  13:37:06  13:37:06  lyh ()
 * Changes as a result of porting to other platforms.
 * 
 * Revision 2.7  00/05/23  09:57:17  09:57:17  lyh ()
 * Linux port - changed the "OR" operation in section mtm_length from
 * length = length | temp[i]
 * to
 * length = length | (temp[i] & 0xFF)
 * The i386 is a bit wacky in doing the logical operation. Assume that
 * length = 0x100
 * temp[i]= 0x92
 * then length | temp[i] should be 0x192
 * However, on the i386 length | temp[i] = 0xffffff92
 * It must have used the 1 in 0x100 as a sign bit in the conversion process.
 * 
 * Revision 2.6  00/03/30  13:43:11  13:43:11  lyh ()
 * Minor correction
 * 
 * Revision 2.5  00/03/29  09:36:01  09:36:01  lyh ()
 * Changed length format to pattern matching instead of using option
 * 
 * Revision 2.4  00/03/23  10:51:52  10:51:52  lyh ()
 * Added packed decimal, left justified, space filled in mtm_length() and
 * mtm_slength() functions
 * 
 * Revision 2.3  00/03/13  14:52:26  14:52:26  lyh ()
 * Check for invalid pointers
 * 
 * Revision 2.2  00/03/03  15:13:56  15:13:56  lyh ()
 * sand comber release
 * 
 * Revision 2.1  00/01/17  11:16:28  11:16:28  lyh ()
 * storm trooper release
 * 
 * Revision 1.1  99/12/27  16:00:58  16:00:58  lyh ()
 * Initial revision
 * 
*  Revision 1.11  98/09/20  (David Gitlin)
 * Greystone M v4.0 changed the manner in which it handles signals. As a
 * result, any external routine which makes system calls may find that
 * its behavior has been effected.  Essentially, signal sensitive system
 * calls may be interrupted before successfull completion, producing an
 * unknown state. Two changes were made to handle this. 1) A new
 * object file (/SCA/sca_gtm/shlib/shlib.o) was created with calls
 * such as sca_xxx where xxx is the equivalent system call. For example
 * sca_write, sca_open etc.  These calls handle the signal issue.
 * They were then substituted for the equivalent system call in the
 * source code. 2) The manner in which system calls like printf,
 * which have a variable number of arguments, were called
 * was directly changed in the source code. The changes are noted.
 *
 * Revision 1.3  96/03/21  15:04:25  15:04:25  zengf (Fan Zeng)
 * Collapsed directories and replaced signals with fifos.
 * 
 * Revision 1.2  96/03/13  10:03:37  10:03:37  zengf (Fan Zeng)
 * prepare for removing signals
 * 
 * Revision 1.1  96/02/28  17:31:27  17:31:27  zengf (Fan Zeng)
 * Initial revision
 * 
*	$Revision: 2.9 $
*/

#include <math.h>		/* for pow() function */
#include <stdio.h>
#include <signal.h>
#include <errno.h>
#include <fcntl.h>
#include <limits.h>
#include <sys/types.h>
#include <sys/select.h> 
#include <stdlib.h>
#include <string.h>
#include "mtm.h"
#include "mtmprototypes.h"
#include "mtmext.h"

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
	if ((fd = sca_open (key_file, O_RDONLY)) == FAILURE)
	{
		MTM_LOG(errno);
		*return_code = errno;
		return;
	}

	if (sca_read (fd, (void *) mtm_process_id, sizeof (SLONG)) == FAILURE) 
	{
		MTM_LOG(errno);
		*return_code = errno;
		return;
	}

	if (sca_close (fd) == FAILURE)
	{
		MTM_LOG(errno);
		*return_code = errno;
		return;
	}
 	
	return;
}

/*
*	mtm_length
*
*	Converts a literal length string to numeric length.
*	Before calling mtm_length, you have to be sure that
*	string a is at least l->hsize in length.
*	Otherwise, it's very easy to get SIGSEGV error.
*
*/
SLONG mtm_length(char *a, st_length *l)
{
	SLONG length = 0;
	int i;
	char temp[32];

	/*
	*	Check for valid input pointer
	*/
	if ((a == NULL) || (l == NULL))
	{
		MTM_LOG(EFAULT);
		return(-1);
	}

#ifdef DEBUG
	fprintf(stdout,"mtm_length: Start of routine\n");
	LV(l->hsize,a);
#endif

	/*
	*	Make a local copy of input string
	*	Shift left the number of leading "don't care" characters.
	*/
	memset(temp,0,sizeof(temp));
	memcpy(temp,&a[l->lcount],l->lsize);

	switch (l->format)
	{
	   case 'l':
		/* little endian */
		for (i = l->lsize-1; i >= 0; i--)
		{
			length = length << 8;
			length = length | (temp[i] & 0xFF);
		}
		break;
	   case 'b':
		/* big endian */
		for (i = 0; i < l->lsize; i++)
		{
			length = length << 8;
			length = length | (temp[i] & 0xFF);
		}
		break;
	   case 'p':
	   case 'd':
		/* packed decimal */
		length = atoi(temp);
		break;
	   default:
		/* should not be here */
		break;
	}

	/*
	*	Make an adjustment to the overall message length if
	*	the header length wasn't included.
	*/
	if (l->header != 'y')
		length += l->hsize;

#ifdef DEBUG
	fprintf(stdout,"mtm_length: end - length is %d\n",length);
	fflush(stdout);
#endif

	return(length);
}

/*
*	mtm_slength
*
*	Converts a numeric length to a literal string.
*	Do not call mtm_slength if leading or trailing count is other than 0.
*	It's assumed that the application will format the
*	length by itself.
*	Also, be sure that string a is at least l->size in
*	length. Otherwise, it's very easy to get SIGSEGV error.
*
*/
void mtm_slength(char *a, SLONG length, st_length *l)
{
	SLONG temp;
	int i;

	/*
	*	Check for valid input pointer
	*/
	if ((a == NULL) || (l == NULL))
	{
		MTM_LOG(EFAULT);
		return;
	}

	/*
	*	Make an adjustment to the overall message length
	*	if the header length is not to be included
	*/
	if (l->header != 'y')
		length -= l->hsize;

	if (length < 0)
	{
		/*
		*	We can't do a negative length
		*/
		/* MTM_LOG(MTM_INVALID_MSG); */
		MTM_LOG(EFAULT);
		return;
	}

#ifdef DEBUG
	fprintf(stdout,"mtm_slength: start - length is %d\n",length);
	fflush(stdout);
#endif

	memset(a, 0, l->hsize);

	switch (l->format)
	{
	   case 'l':
		/* little endian */
		for (i = l->hsize-1; i >= 0; i--)
		{
			temp = (SLONG)pow((double)2, (double)8*i);
			a[i] = 0xFF & (int)(length/temp);
			length = length % temp;
		}
		break;
	   case 'b':
		/* big endian */
		for (i = 0; i < l->hsize; i++)
		{
			temp = (SLONG)pow((double)2, (double)(8*(l->hsize-i-1)));
			a[i] = 0xFF & (int)(length/temp);
			length = length % temp;
		}
		break;
	   case 'p':
		/* packed decimal, right justified, zero filled */
		for (i=0; i < l->hsize; i++)
		{
			temp = (SLONG)pow((double)10, (double)(l->hsize-i-1));
			a[i] = '0' + (int)(length/temp);
			length = length % temp;
		}
		break;
	   case 'd':
		/* packed decimal, left justified, space filled */
		memset(a, ' ', l->hsize);
		sprintf(a,"%-d",length);
		temp = strlen(a);
		a[temp]= ' ';
		break;
	   default:
		/* should not be here */
		break;
	}

#ifdef DEBUG
	fprintf(stdout,"mtm_slength: end\n");
	LV(l->hsize, a);
	fflush(stdout);
#endif

	return;
}


/*
*	mtm_s64klength
*
*	Converts a numeric length to a literal string for 64k IBS messages.
*	Do not call mtm_s64klength if leading or trailing count is other than 0.
*	It's assumed that the application will format the length by itself.
*	Also, be sure that string a is at least l->size in
*	length. Otherwise, it's very easy to get SIGSEGV error.
*
*/
int mtm_s64klength(char *a, SLONG length, st_length *l)
{
	SLONG temp;
	int i;
	int len_length=2;
	int prot_length;

	/*
	*	Check for valid input pointer
	*/
	if ((a == NULL) || (l == NULL))
	{
		MTM_LOG(EFAULT);
		return;
	}

	/*
	*	Make an adjustment to the overall message length
	*	if the header length is not to be included
	*/
	if (l->header != 'y')
		length -= l->hsize;

	if (length < 0)
	{
		/*
		*	We can't do a negative length
		*/
		/* MTM_LOG(MTM_INVALID_MSG); */
		MTM_LOG(EFAULT);
		return;
	}

#ifdef DEBUG
	fprintf(stdout,"mtm_slength: start - length is %d\n",length);
	fflush(stdout);
#endif

	/* Add 3 byte leader to length */
	length+=3;

	/* 
	 Now add 2 for minimum length of length. This is for protection
	 of the length calculation near the cusp of powers of 2.
	*/
	prot_length=length+2;

	/* First determine how many bytes we need for the length */
	for (i=2; i<256; i++)
	{
		long itemp = (long)pow((double)256,(double)i);
		if (((int)((prot_length+i)/itemp))>=1) continue;
		len_length = i;
		break;
	}

#ifdef DEBUG
	fprintf(stdout,"mtm_s64klength: len_length is %d\n",len_length);
	fflush(stdout);
#endif

	/* Allocate enough memory for complete header */
	memset(a, 0, len_length+3);
	/* First two bytes are 0x00; third byte is length of length */
	a[2]=len_length;

	/* 
	 The length of the entire message should now include the 
	 number of bytes being used to indicate the total length.  Got it?
	*/
	length+=len_length; 

	/* Create length in string format - big Endian */
	for (i = 0; i < len_length; i++)
	{
	  temp = (SLONG)pow((double)2, (double)(8*(len_length-i-1)));
	  a[i+3] = 0xFF & (int)(length/temp);
	  length = length % temp;
	}

#ifdef DEBUG
	fprintf(stdout,"mtm_slength: end\n");
	LV(len_length+3, a);
	fflush(stdout);
#endif

	return(len_length+3);
}


/*
*	parse_length
*
*	Format the header length used by MTM.
*	Rule:
*	x means throw away this character
*	b means big endian
*	l means little endian
*	p means packed decimal, right justified, zero filled
*	d means packed decimal, left justified, space filled
*	y means the header length is counted in the message length
*	n means the header length is not counted in the message length
*	Example:
*	bby	This is the "normal" MTM mode where we use big endian
*		and the header length is included in the message length
*	xppppxn	This means the header length is 6. We normally throw away
*		the first and last character in length calculation. The
*		header length is not included in the message length.
*
*	Assume: input is a properly terminate string.
*		Otherwise, strlen won't work.
*
*/
int parse_length(char *a, st_length *l)
{
	int	index;
	int	inputLength;
	int	more;
	char	ch;
	int	rc = SUCCESS;

	inputLength = strlen(a);

	/*
	*	Check for valid pointer
	*/
	if (l == NULL)
	{
		fprintf(stdout,"parse_length: Invalid pointer passed in from %s, line %d\n",__FILE__,__LINE__);
		fflush(stdout);
		return FAILURE;
	}

	/*
	*	Default
	*/
	if (inputLength == 0)
	{
		l->format = 'b';
		l->header = 'y';
		l->lsize  = MTM_LEN_FIELD_SIZE;
		l->hsize  = l->lsize;
		l->lcount = 0;
		l->tcount = 0;
		return SUCCESS;
	}

	/*
	*	Figure out the format first
	*/
	l->format = '\0';
	for (index = 0; index < inputLength; index++)
	{
		ch = a[index];
		switch(ch)
		{
			case 'b':
			case 'l':
			case 'p':
			case 'd':
				l->format = ch;
				break;
			default:
				break;
		}
		/*
		*	If we have format defined, break the loop
		*/
		if (l->format != '\0')
			break;
	}

	/*
	*	Must have length format to continue
	*/
	if (l->format == '\0')
		return FAILURE;

	/*
	*	Figure out how long is the length used in calculation
	*/
	l->lsize = 0;
	for (index = 0; index < inputLength; index++)
	{
		ch = a[index];
		if (ch == l->format)
		{
			l->lsize = l->lsize + 1;
		}
	}

	/*
	*	Can't continue if length is undefined
	*/
	if (l->lsize == 0)
		return FAILURE;

	/*
	*	Figure out inclusive or non-iclusive mode
	*/
	l->header = '\0';
	for (index = 0; index < inputLength; index++)
	{
		ch = a[index];
		switch(ch)
		{
			case 'y':
			case 'n':
				l->header = ch;
			default:
				break;
		}
	}

	/*
	*	Default is inclusive
	*/
	if (l->header == '\0')
		l->header = 'y';

	/*
	*	Figure out leading "don't care" characters
	*/
	l->lcount = 0;
	more = TRUE;
	for (index = 0; index < inputLength; index++)
	{
		ch = a[index];
		switch(ch)
		{
			case 'x':
				l->lcount = l->lcount + 1;
				break;
			default:
				more = FALSE;
				break;
		}
		/*
		*	No more leading "don't care" characters, break the loop
		*/
		if (more == FALSE)
			break;
	}

	/*
	*	Figure out trailing "don't care characters
	*/
	l->tcount = 0;
	more = TRUE;
	for (index = inputLength - 1; index >= 0; index--)
	{
		ch = a[index];
		switch(ch)
		{
			case 'x':
				l->tcount = l->tcount + 1;
				break;
			case 'y':
			case 'n':
				break;
			default:
				more = FALSE;
				break;
		}
		/*
		*	No more trailing "don't care" characters, break the loop
		*/
		if (more == FALSE)
			break;
	}

	/*
	*	Header length is the sum of cLength, lcount, tcount
	*/
	l->hsize = l->lsize + l->lcount + l->tcount;

#ifdef DEBUG
	fprintf(stdout,"parse_length: input string %s\n",a);
	fprintf(stdout,"\tformat is %c\n",l->format);
	fprintf(stdout,"\tinclusive flag is %c\n",l->header);
	fprintf(stdout,"\theader size is %d\n",l->hsize);
	fprintf(stdout,"\tlength size is %d\n",l->lsize);
	fprintf(stdout,"\tleading count is %d\n",l->lcount);
	fprintf(stdout,"\ttrailing count is %d\n",l->tcount);
	fflush(stdout);
#endif

	return SUCCESS;
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

LV(SLONG length, char *msg)
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

