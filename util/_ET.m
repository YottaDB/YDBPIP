%ET	;System;GT.M error trap of last resort
	;;Copyright(c)1998 Sanchez Computer Associates, Inc.  All Rights Reserved - 09/17/98 12:11:40 - MATTSON
	;     ORIG:  Dan S. Russell (2417) - 09 Nov 88
	;
	; GT.M last resort error trap.  Dumps data to an RMS file in the case 
	; ^UTLERR fails.  RMS file name = PROFILE_ERROR.LOG, in whatever is
	; current directory.
	;
	; Provided for upward compatiblity with M/VX and ^UTLERR
	;
	; KEYWORDS:	Error trapping
	;
	;----- Revision History -----------------------------------------------
	; 09/17/98 - Allan Mattson
	;            Replaced ZWR with ZSHOW "*" to expand the amount of
	;            information written to the error log (i.e., external
	;            call table entry names, device information, intrinsic
	;            special variables, M locks, M stack, etc.).
	;----------------------------------------------------------------------
	;
	; Set $ZT to halt in the event of an error
	S $ZT="H"
	;
	S %ZIO="PROFILE_ERROR.LOG"
	O %ZIO:NEWV:1 E  Q
	U %ZIO W $H,!
	ZSHOW "*"
	C %ZIO
	;
	U 0 W !!,*7,"Fatal error - ",!,$ZS
	W !,"Trapped in file 'PROFILE_ERROR.LOG'",!
	H
