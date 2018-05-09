/* Define macros to do our IO and restart as appropriate 
 *
 * LSEEKREAD	Performs an lseek followed by read and sets global variable to warn off
 *		async IO routines.
 * LSEEKWRITE	Same as LSEEKREAD but for WRITE.
 * DOREADRC	Performs read, returns code 0 if okay, otherwise returns errno.
 * DOREADRL     Performs read but returns length read or -1 if errno is set.
 * DOREADRLTO	Same as DOREADRL but has a timeout flag to poll on interrupts.
 * DOWRITE	Performs write with no error checking/return.
 * DOWRITERC	Performs write, returns code 0 if okay, otherwise returns errno.
 * DOWRITERL	Performs write but returns length written or -1 if errno is set.
 */

#ifndef GTMIO_Included
#define GTMIO_Included

#include <sys/types.h>

#define MAX_READ_RETRY 5
#define MAX_WRITE_RETRY 5

#define LSEEKREAD(fdesc, fptr, fbuff, fbuff_len, rc) \
{ \
	GBLREF	int4 lseekIoInProgress; \
	ssize_t	gtmioStatus; \
	int	gtmioRetryCount = MAX_READ_RETRY; \
	lseekIoInProgress = TRUE; \
	do \
	{ \
		if ((off_t)-1 != lseek(fdesc, (off_t)(fptr), SEEK_SET)) \
	        { \
			gtmioStatus = read(fdesc, fbuff, fbuff_len); \
			if (0 == gtmioStatus)	/* Eof? */ \
			        break; \
	        } \
		else \
			gtmioStatus = -1; \
		if (-1 == gtmioStatus && EINTR != errno) \
		        break; \
	} while (gtmioStatus != fbuff_len && 0 < gtmioRetryCount--); \
	lseekIoInProgress = FALSE; \
	if (-1 == gtmioStatus)	    	/* Had legitimate error - return it */ \
		rc = errno; \
	else if (gtmioStatus != fbuff_len) \
		rc = -1;		/* Something kept us from reading what we wanted */ \
	else \
	        rc = 0; \
}

#define LSEEKWRITE(fdesc, fptr, fbuff, fbuff_len, rc) \
{ \
	GBLREF	int4 lseekIoInProgress; \
	ssize_t	gtmioStatus; \
	int	gtmioRetryCount = MAX_WRITE_RETRY; \
	lseekIoInProgress = TRUE; \
	do \
	{ \
		if ((off_t)-1 != lseek(fdesc, (off_t)(fptr), SEEK_SET)) \
			gtmioStatus = write(fdesc, fbuff, fbuff_len); \
		else \
			gtmioStatus = -1; \
		if (-1 == gtmioStatus && EINTR != errno) \
		        break; \
	} while (gtmioStatus != fbuff_len && 0 < gtmioRetryCount--); \
	lseekIoInProgress = FALSE; \
	if (-1 == gtmioStatus)	    	/* Had legitimate error - return it */ \
		rc = errno; \
	else if (gtmioStatus != fbuff_len) \
		rc = -1;		/* Something kept us from writing what we wanted */ \
	else \
	        rc = 0; \
}

#define DOREADRC(fdesc, fbuff, fbuff_len, rc) \
{ \
	ssize_t		gtmioStatus; \
	size_t		gtmioBuffLen; \
	sm_uc_ptr_t 	gtmioBuff; \
	int		gtmioRetryCount = MAX_READ_RETRY; \
	gtmioBuffLen = fbuff_len; \
	gtmioBuff = (sm_uc_ptr_t)(fbuff); \
	do \
        { \
		if (-1 != (gtmioStatus = read(fdesc, gtmioBuff, gtmioBuffLen))) \
	        { \
			gtmioBuffLen -= gtmioStatus; \
			if (0 == gtmioBuffLen || 0 == gtmioStatus) \
				break; \
			gtmioBuff += gtmioStatus; \
	        } \
		else if (EINTR != errno) \
			break; \
        } while (0 < gtmioRetryCount--); \
	if (-1 == gtmioStatus)	    	/* Had legitimate error - return it */ \
		rc = errno; \
	else if (0 != gtmioBuffLen) \
		rc = -1;		/* Something kept us from reading what we wanted */ \
	else \
	        rc = 0; \
}

#define DOREADRL(fdesc, fbuff, fbuff_len, rlen) \
{ \
	ssize_t		gtmioStatus; \
	size_t		gtmioBuffLen; \
	sm_uc_ptr_t 	gtmioBuff; \
	int	gtmioRetryCount = MAX_READ_RETRY; \
	gtmioBuffLen = fbuff_len; \
	gtmioBuff = (sm_uc_ptr_t)(fbuff); \
	do \
        { \
		if (-1 != (gtmioStatus = read(fdesc, gtmioBuff, gtmioBuffLen))) \
	        { \
			gtmioBuffLen -= gtmioStatus; \
			if (0 == gtmioBuffLen || 0 == gtmioStatus) \
				break; \
			gtmioBuff += gtmioStatus; \
	        } \
		else if (EINTR != errno) \
		  break; \
        } while (0 < gtmioRetryCount--); \
	if (-1 == gtmioStatus)	    		/* Had legitimate error - return it */ \
		rlen = -1; \
	else \
		rlen = fbuff_len - gtmioBuffLen; 	/* Return length actually read */ \
}

#define DOREADRLTO(fdesc, fbuff, fbuff_len, toflag, rlen) \
{ \
	ssize_t		gtmioStatus; \
	size_t		gtmioBuffLen; \
	sm_uc_ptr_t	gtmioBuff; \
	int	gtmioRetryCount = MAX_READ_RETRY; \
	gtmioBuffLen = fbuff_len; \
	gtmioBuff = (sm_uc_ptr_t)(fbuff); \
	do \
        { \
		if (-1 != (gtmioStatus = read(fdesc, gtmioBuff, gtmioBuffLen))) \
	        { \
			gtmioBuffLen -= gtmioStatus; \
			if (0 == gtmioBuffLen || 0 == gtmioStatus) \
				break; \
			gtmioBuff += gtmioStatus; \
	        } \
		else if (EINTR != errno || toflag) \
		  break; \
        } while (0 < gtmioRetryCount--); \
	if (-1 == gtmioStatus)	    		/* Had legitimate error - return it */ \
		rlen = -1; \
	else \
		rlen = fbuff_len - gtmioBuffLen; 	/* Return length actually read */ \
}

#define DOWRITE(fdesc, fbuff, fbuff_len) \
{ \
	ssize_t		gtmioStatus; \
	size_t		gtmioBuffLen; \
	sm_uc_ptr_t 	gtmioBuff; \
	int		gtmioRetryCount = MAX_WRITE_RETRY; \
	gtmioBuffLen = fbuff_len; \
	gtmioBuff = (sm_uc_ptr_t)(fbuff); \
	do \
        { \
		if (-1 != (gtmioStatus = write(fdesc, gtmioBuff, gtmioBuffLen))) \
	        { \
			gtmioBuffLen -= gtmioStatus; \
			if (0 == gtmioBuffLen) \
				break; \
			gtmioBuff += gtmioStatus; \
	        } \
		else if (EINTR != errno) \
		  break; \
        } while (0 < gtmioRetryCount--); \
	/* GTMASSERT? */ \
}

#define DOWRITERC(fdesc, fbuff, fbuff_len, rc) \
{ \
	ssize_t		gtmioStatus; \
	size_t		gtmioBuffLen; \
	sm_uc_ptr_t	gtmioBuff; \
	int		gtmioRetryCount = MAX_WRITE_RETRY; \
	gtmioBuffLen = fbuff_len; \
	gtmioBuff = (sm_uc_ptr_t)(fbuff); \
	do \
        { \
		if (-1 != (gtmioStatus = write(fdesc, gtmioBuff, gtmioBuffLen))) \
	        { \
			gtmioBuffLen -= gtmioStatus; \
			if (0 == gtmioBuffLen) \
				break; \
			gtmioBuff += gtmioStatus; \
	        } \
		else if (EINTR != errno) \
		  break; \
        } while (0 < gtmioRetryCount--); \
	if (-1 == gtmioStatus)	    	/* Had legitimate error - return it */ \
		rc = errno; \
	else if (0 != gtmioBuffLen) \
		rc = -1;		/* Something kept us from writing what we wanted */ \
	else \
	        rc = 0; \
}

#define DOWRITERL(fdesc, fbuff, fbuff_len, rlen) \
{ \
	ssize_t		gtmioStatus; \
	size_t		gtmioBuffLen; \
	sm_uc_ptr_t 	gtmioBuff; \
	int		gtmioRetryCount = MAX_WRITE_RETRY; \
	gtmioBuffLen = fbuff_len; \
	gtmioBuff = (sm_uc_ptr_t)(fbuff); \
	do \
        { \
		if (-1 != (gtmioStatus = write(fdesc, gtmioBuff, gtmioBuffLen))) \
	        { \
			gtmioBuffLen -= gtmioStatus; \
			if (0 == gtmioBuffLen) \
			        break; \
			gtmioBuff += gtmioStatus; \
	        } \
		else if (EINTR != errno) \
		        break; \
        } while (0 < gtmioRetryCount--); \
	if (-1 == gtmioStatus)	    		/* Had legitimate error - return it */ \
		rlen = -1; \
	else \
		rlen = fbuff_len - gtmioBuffLen;  	/* Return length actually written */ \
}

#endif
