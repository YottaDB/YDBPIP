%ISSPL	;Private;Dummy routine for M/VX compatibility
	;;Copyright(c)1995 Sanchez Computer Associates, Inc.  All Rights Reserved - 02/20/95 10:42:04 - SYSRUSSELL
	; ORIG:  RUSSELL -  1 NOV 1989
	;
	; Used by M/VX for spooler.  Provided under GT.M to avoid link errors 
	; from ^SCAIO
	;
	; Need line tags for:
	;
	; VALID to return ER and RM
	; CLOSE (if valid) to close spool device top entry handles opening
	;
	; KEYWORDS:	Device handling
	;
	;---- Revision History ------------------------------------------------
	;
	; 02/20/95 - Dan Russell
	;            Added OPEN line tag.
	;
	;----------------------------------------------------------------------
	;
	Q
	;
VALID	; Indicate not valid under GT.M
	S ER=1,RM="Not valid under GT.M"	
	Q
	;
OPEN	; Open spool device, if appropriate
	Q
	;
CLOSE	; Close spool device, if appropriate (e.g. C 2 under M/VX)
	Q
