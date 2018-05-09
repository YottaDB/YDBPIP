%ZTRANS	;Library;Transaction "Fencing"
	;;Copyright(c)1994 Sanchez Computer Associates, Inc.  All Rights Reserved - 05/05/94 09:28:32 - SYSRUSSELL
	; ORIG:  MATTSON - 21 JUN 1990
	;
	; KEYWORDS:	System Services
	;
	; LIBRARY:
	;	. TS	Transaction Start
	;
	;	. TC	Transaction Commit
	;
	Q
	;
	;----------------------------------------------------------------------
TS	;System;Transaction Start
	;----------------------------------------------------------------------
	;
	; Marks the start of a logical transaction within a MUMPS program.  It 
	; is used with a Transaction Commit to "fence" transactions (i.e., 
	; mark the beginning and end).
	;
	; KEYWORDS:	System Services
	;
	; EXAMPLE:
	;	D TS^%ZTRANS
	;
	ZTSTART
	Q
	;
	;----------------------------------------------------------------------
TC	;System;Transaction Commit
	;----------------------------------------------------------------------
	;
	; Marks the end of a logical transaction within a MUMPS program.  It is 
	; used with a Transaction Start to "fence" transactions (i.e., mark 
	; the beginning and end).
	;
	; KEYWORDS:	System Services
	;
	; EXAMPLE:
	;	D TC^%ZTRANS
	;
	ZTCOMMIT
	Q
