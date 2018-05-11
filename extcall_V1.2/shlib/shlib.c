/*
 * Revision 1.1 Dec 8, 98 (David Gitlin)
sca_msgrcv was changed to work in accordance with timers available in
GTM 4.0. This routine uses a flag to determine if the timer that
interrupts the routine is one of ours or a GTM timer. If it is a GTM
timer it ignores it, if it is our timer it exists.
*IMPORTANT NOTE*
This code only works with GTM 4.0 it is no longer compatible with early
versions.
*
 * Revision 1.0 Sep 20, 98 (David Gitlin)
 * Greystone M v4.0 changed the manner in which it handles signals. As a
 * result, any external routine which makes system calls may find that
 * its behavior has been effected.  Essentially, signal sensitive system
 * calls may be interrupted before successfull completion, producing an
 * unknown state. The routines in this library were written to deal with
 * this problem. For any signal sensitve system call, such as write, read
 * an sca_write, sca_read etc, equivalent was created.  The sca_xxx
 * routines are written to handle this issue. They are then substituted
 * for the read, write etc system call in a C based external call. Any
 * external routine that runs under v4.0 or higher of Greystone M should
 * call the routines in this library rather then the system call itself.
 * As the need arises to call signal sensitve system calls that are not in
 * this library a sca_xxx version should be added to the library which
 * handles this issue. The sca_xxx version should then be called in the
 * external routine.
 *
 */

#ifndef  GTMIO_Included
#define  GTMIO_Included
#include "./types.h"

 
/*#include <sys/types.h>*/
#include <unistd.h>
#include <sys/errno.h>
#include <fcntl.h>
#include <sys/ioctl.h>
#include <stdio.h>
#include <sys/stat.h> 
#define MAX_READ_RETRY  5
#define MAX_WRITE_RETRY 5

#endif

unsigned char SrvSignalFlagsLib;
/**************************************************************************/
unsigned int sca_sleep (unsigned int sleep_time) {
	unsigned int time_remaining;	
	time_remaining = sleep_time;

	do {
		time_remaining = sleep(time_remaining);
	}
	while (time_remaining > 0);
}
/**************************************************************************/

ssize_t sca_write
(int fdesc, const void *fbuff, size_t fbuff_len) {

	ssize_t		gtmioStatus; 
	size_t		gtmioBuffLen;
/*	sm_uc_ptr_t 	gtmioBuff; */
        char *          gtmioBuff;
	int		gtmioRetryCount = MAX_WRITE_RETRY; 
	gtmioBuffLen = fbuff_len; 
	gtmioBuff = (char *)(fbuff); 
	do 
        { 
		if (-1 != (gtmioStatus = write(fdesc, gtmioBuff, gtmioBuffLen))) 
	        { 
			gtmioBuffLen -= gtmioStatus; 
			if (0 == gtmioBuffLen) 
			        break; 
			gtmioBuff += gtmioStatus; 
	        } 
		else if (EINTR != errno)
		        break;

        } while (0 < gtmioRetryCount--);
	if (-1 == gtmioStatus) /* Had legitimate error - return it */
		return -1; /*rlen = -1;*/ 
	else 
		return fbuff_len - gtmioBuffLen;
		/*rlen = fbuff_len - gtmioBuffLen;  Return length actually written */
}
/**************************************************************************/

ssize_t sca_read(int fdesc, void * fbuff, size_t fbuff_len)
{
	ssize_t		gtmioStatus; 
	size_t		gtmioBuffLen; 
/*	sm_uc_ptr_t 	gtmioBuff; */
	char *	 	gtmioBuff;
	int	gtmioRetryCount = MAX_READ_RETRY;
	gtmioBuffLen = fbuff_len;
	gtmioBuff = (char *)(fbuff); 
	do
        { 
		if (-1 != (gtmioStatus = read(fdesc, gtmioBuff, gtmioBuffLen)))
	        {
			gtmioBuffLen -= gtmioStatus; 
			if (0 == gtmioBuffLen || 0 == gtmioStatus) 
				break;
			gtmioBuff += gtmioStatus; 
	        } 
		else if (EINTR != errno)
		  break; 
        } while (0 < gtmioRetryCount--); 

	if (-1 == gtmioStatus)	    /* Had legitimate error - return it */ 
		return -1; 
	else 
		return (fbuff_len - gtmioBuffLen); /* Return length actually read */
}
/**************************************************************************/

int  sca_msgsnd (int	     MessageQueueID,
		 const void *MessagePointer,
		 size_t      MessageSize,
		 int	     MessageFlag) {

	int value;

	value = FAILURE;

	while (value == FAILURE) {	
		value  = msgsnd (MessageQueueID,
               	 	 MessagePointer,
               		 MessageSize,
                	 MessageFlag);

		if (value == FAILURE && errno != EINTR)
	            return value;
	        
	}
	
	return value;

} /*sca_msgsnd*/
/**************************************************************************/

int sca_msgrcv (int      MessageQueueID,
		void    *MessagePointer,
		size_t   MessageSize,
		long int MessageType,
		int      MessageFlag) {

	int value;

	value = FAILURE;
/*Set flag to 0. Flag is set to 1 by signale handler defined to handle
signals.*/
        SrvSignalFlagsLib = 0;
	while (value == FAILURE) {	

	       value = msgrcv (MessageQueueID,
                	MessagePointer,
                	MessageSize,
              		MessageType,
               		MessageFlag);

		/* if ((value == FAILURE || value == 0) && errno != EINTR) */

		if (value == 0 || (value == FAILURE && errno != EINTR))
			return value;
                else /*Only exit if timer is one of ours, not GTM timer*/
                   if (SrvSignalFlagsLib == 1)
                       return value;

	}

	return value;
} /*sca_msgrcv*/
/**************************************************************************/
/*
gordon.c
*/

/**************************************************************************/
int sca_fflush (FILE * Stream) {
	int value;
	
	value = FAILURE;
	errno = EINTR;

	while (value == FAILURE && errno == EINTR) {
		value = fflush (Stream);
	}
}
/**************************************************************************/
int sca_open (  path, oflag, mode )
       const char *path;
       int oflag;
       mode_t mode;
{
int handle=0;
do {
   handle = open(path, oflag, mode);
/*
   printf("\nThe file handle is %x\nand the errno is %i",handle,errno);
*/
} while ( (handle==FAILURE) && (errno==EINTR) );
return handle;
}
/**************************************************************************/
int sca_close (int FileDescriptor) {
	int value;

	value = FAILURE;
	errno = EINTR;
	while (value == FAILURE && errno == EINTR) {
		value = close(FileDescriptor);
	}

}
/**********************************************************************/
sca_fgets(char *string, int n, FILE *stream)
 
{
        do {
                fgets(string, n, stream);
        }   while (errno == EINTR);
        return;
}

/**********************************************************************/
FILE *sca_fopen(char *file, char *mode)
{
        FILE *fptr;
 
        do {
                fptr = fopen(file, mode);
        } while (errno == EINTR);
 
 
        return fptr;
}
/**************************************************************************/
int sca_fclose(FILE *fptr)
{
        int retval;
	do {
                retval = fclose(fptr);
        } while (errno == EINTR);
 
        return retval;
}
/**************************************************************************/

