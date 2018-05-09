%PCNTRL	;Library;GT.M extrinisic function 
	;;Copyright(c)1994 Sanchez Computer Associates, Inc.  All Rights Reserved
	; ORIG:  Sara G. Walters - 05/30/95
	;
	;
	; KEYWORDS:	System services
	;
	; LIBRARY:
	;
	;	. SLEEP	- 	Takes a process off the run queue for
	;				a specified amount of time.
	;
	Q
	;
	;----------------------------------------------------------------------
SLEEP(TIMEOUT)	;Public; 
	;----------------------------------------------------------------------
	;
	; Pause a process for time specified by Timeout
	;
	; KEYWORDS:	
	;	
	; RETURNS:
	;
	D &extcall.extsleep(TIMEOUT)
	Q
