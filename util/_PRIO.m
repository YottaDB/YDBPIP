%PRIO(%PRIO)	;System;Change priority of current process
	;;Copyright(c)1994 Sanchez Computer Associates, Inc.  All Rights Reserved - 05/05/94 15:27:26 - SYSRUSSELL
	; ORIG:  Dan S. Russell (2417) - 09 Nov 88
	;
	; KEYWORDS:	System services
	;
	; ARGUMENTS:
	;     . %PRIO	Priority requested		/TYP=N/REQ/MECH=VAL
	;----------------------------------------------------------------------
	;
	I $D(%PRIO) D EXT
	Q
	;
	;----------------------------------------------------------------------
EXT	;System;Entry point to set priority with %PRIO defined
	;----------------------------------------------------------------------
	;
	; KEYWORDS:	System Services
	;
	; INPUTS:
	;     . %PRIO	Priority requested
	;----------------------------------------------------------------------
	;
	N X S X=$$SYS^%ZFUNC("SET PROC/PRIO="_%PRIO_"/ID="_$$DECHEX^%ZHEX($J))
	Q
