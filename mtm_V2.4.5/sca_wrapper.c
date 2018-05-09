/*
*	sca_wrapper.c
*
*	Provides wrapper for various system calls.
*
*	ORIG: Hien T. Ly
*
* $Id:$
*
* $Log:	sca_wrapper.c,v $
 * Revision 1.3  00/07/07  12:05:11  12:05:11  lyh ()
 * added return statement in sca_sleep and sca_fflush to resolve compiler
 * warning when porting to other platforms.
 * 
 * Revision 1.2  00/04/06  14:49:50  14:49:50  lyh ()
 * added fnctl.h for open() function
 * 
 * Revision 1.1  00/03/03  15:18:26  15:18:26  lyh ()
 * Initial revision
 * 
*
* $Revision: 1.3 $
*
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <errno.h>

/*
*	Definitions
*/
#define FAILURE		-1
#define MAX_READ_RETRY  5
#define MAX_WRITE_RETRY 5




/*
*	sca_sleep
*
*	A wrapper for the sleep() system call.
*
*/
unsigned int sca_sleep(unsigned int sleep_time)
{
	unsigned int time_remaining;	
	time_remaining = sleep_time;

	do {
		time_remaining = sleep(time_remaining);
	}
	while (time_remaining > 0);

	return time_remaining;
}




/*
*	sca_write
*	A wrapper for the write() system call.
*
*/
ssize_t sca_write(int fdesc, const void *fbuff, size_t fbuff_len)
{
	ssize_t		gtmioStatus; 
	size_t		gtmioBuffLen;
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




/*
*	sca_read
*
*	A wrapper for the read() system call.
*
*/
ssize_t sca_read(int fdesc, void * fbuff, size_t fbuff_len)
{
	ssize_t		gtmioStatus; 
	size_t		gtmioBuffLen; 
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




/*
*	sca_fflush
*
*	A wrapper for the fflush() system call.
*
*/
int sca_fflush (FILE * Stream)
{
	int value;
	
	value = FAILURE;
	errno = EINTR;

	while (value == FAILURE && errno == EINTR) {
		value = fflush (Stream);
	}

	return value;
}




/*
*	sca_open
*
*	A wrapper for the open() system call.
*
*/
int sca_open (  path, oflag, mode )
       const char *path;
       int oflag;
       mode_t mode;
{
	int handle=0;
	do {
		handle = open(path, oflag, mode);
	} while ( (handle==FAILURE) && (errno==EINTR) );

	return handle;
}




/*
*	sca_close
*
*	A wrapper for the close() system call.
*
*/
int sca_close (int FileDescriptor)
{
	int value;

	value = FAILURE;
	errno = EINTR;
	while (value == FAILURE && errno == EINTR) {
		value = close(FileDescriptor);
	}

	return(value);
}





/*
*	sca_fgets
*
*	A wrapper for the fgets() system call.
*
*/
sca_fgets(char *string, int n, FILE *stream)
{
        do {
                fgets(string, n, stream);
        }   while (errno == EINTR);
        return;
}





/*
*	sca_fopen
*
*	A wrapper for the fopen() system call.
*
*/
FILE *sca_fopen(char *file, char *mode)
{
        FILE *fptr = (FILE *)NULL;
 
        do {
                fptr = fopen(file, mode);
        } while (errno == EINTR);
 
 
        return fptr;
}





/*
*	sca_fclose
*
*	A wrapper for the fclose() system call.
*
*/
int sca_fclose(FILE *fptr)
{
	int retval;
	do {
                retval = fclose(fptr);
        } while (errno == EINTR);
 
	return retval;
}
