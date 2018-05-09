%ZPID(LIST)	;Public;Return list of all processes on system
	;;Copyright(c)1996 Sanchez Computer Associates, Inc.  All Rights Reserved - 03/20/96 08:12:57 - CHENARD
	; ORIG:  RUSSELL - 12 FEB 1990
	;
	; Returns list of all processes currently running.
	; Uses temporary output file SYS$LOGIN:_ZPID_jobno.TMP
	;
	; This file also contains other library calls dealing
	; with processes.
	;
	; KEYWORDS: System services
	;
	; ARGUMENTS:
	;     . LIST	Return list of process info	/TYP=T/MECH=REFARR:W
	;		LIST(dec_pid)=hex_pid|prcnam
	;
	; RETURNS:
	;     . ER	Error flag			/TYP=N/COND
	;     . RM	Error message			/TYP=T/COND
	;
	; EXAMPLE:
	;	D ^%ZPID(.PROCLIST)
	;
	; LIBRARY:
	;     . $$VALID		Is PID valid?
	;     . $$VALIDNM	Is process name valid?
	;
	;---- Revision History ------------------------------------------------
	;
	; 03/15/96 - Phil Chenard
	;            Modify top section of ^%ZPID to use generic call to 
	;            platform specific utility to create the process list.
	;
	; 01/20/95 - Dan Russell
	;            Replace ZSYSTEM calls with $$SYS%$ZFUNC to prevent problems
	;            with captive accounts.
	;
	; 12/22/95 - Phil Chenard
	;            Added a second argument to $$VALID function, indicating 
	;            that the passed PID, the first argument, should first be
	;            translated from Hexadecimal to Decimal.
	;
	;----------------------------------------------------------------------
	K LIST
	;
	S ER=$$PIDLIST^%OSSCRPT(.LIST)
	Q
	;
	;----------------------------------------------------------------------
VALID(PID,vzhex)	;Public;Is PID a valid process on the system?
	;----------------------------------------------------------------------
	;
	; KEYWORDS: System services
	;
	; ARGUMENTS:
	;	. PID	- Decimal process id		/TYP=N/REQ/MECH=VAL
	;
	;	. vzhex - Hexadecimal flag		/TYP=L/NOREQ
	;
	; RETURNS:
	;     . $$	1 if valid, 0 if not		/TYP=L
	;
	; EXAMPLE:
	;	S X=$$VALID(123)
	;----------------------------------------------------------------------
	;
	I $G(vzhex) S PID=$$HEXDEC^%ZHEX(PID)
	N LIST D ^%ZPID(.LIST)
	I $D(LIST(PID)) Q 1
	Q 0
	;
	;----------------------------------------------------------------------
VALIDNM(PRCNAM,PID)	;Public;Is PRCNAM a valid process name on the system?
	;----------------------------------------------------------------------
	;
	; KEYWORDS: System services
	;
	; ARGUMENTS:
	;     . PRCNAM	Process name		/TYP=T/REQ/MECH=VAL
	;     . PID	Process ID		/TYP=T/MECH=REFNAM:W
	;
	; RETURNS:
	;     . $$	1 if valid, 0 if not	/TYP=L
	;
	; EXAMPLE:
	;	S X=$$VALIDNM("SWAPPER",.PID)
	;----------------------------------------------------------------------
	;
	I $G(PRCNAM)="" Q 0
	;
	N LIST D ^%ZPID(.LIST)
	;
	S PID=""
	F  S PID=$O(LIST(PID)) Q:PID=""  I $P(LIST(PID),"|",2)=PRCNAM Q
	I PID'="" Q 1
	Q 0
