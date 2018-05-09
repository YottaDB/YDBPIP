%DIR	;M Utility;Return directory reference
	;;Copyright(c)1995 Sanchez Computer Associates, Inc.  All Rights Reserved - 10/13/95 08:20:53 - CHENARD
	;     ORIG:  Dan S. Russell (2417) - 08 Nov 88
	; Call at top to display directory, including current and global 
	; directories, plus routine list
	;
	; Call at INT^%DIR to return %DIR with global directory
	;
	; KEYWORDS:	System utilities
	;
	W !,"            You are in directory:  ",$$CURR
	W !,"        Your global directory is:  ",$ZGBLDIR
	W !,"  Your routine directory list is:  ",$ZROUTINES,!
	Q
	;
	;----------------------------------------------------------------------
INT	;System;Returns current global directory in %DIR
	;----------------------------------------------------------------------
	;
	; KEYWORDS:	System utilities
	;	
	; RETURNS:
	;	. %DIR		Global directory	/TYP=T
	;
	S %DIR=$ZGBLDIR
	Q
	;
	;----------------------------------------------------------------------
CURR()	;System;Return current directory
	;----------------------------------------------------------------------
	;
	; KEYWORDS:	System utilities
	;	
	; RETURNS:
	;	. $$		Current default directory	/TYP=T
	;
	Q $$CDIR^%TRNLNM
	;
