%ZRCALLS(RTNS)	;M Utility;Determine Routine Calls
	;;Copyright(c)1995 Sanchez Computer Associates, Inc.  All Rights Reserved - 02/15/95 16:33:20 - SYSRUSSELL
	; ORIG:  CHENARD - 30 JAN 1991
	;
	; Based on the routine that is passed, this utility will identify all 
	; other routine calls made by the original and any others that have 
	; been called.
	;
	; KEYWORDS:	Routine handling
	;
	; ARGUMENTS:
	;	. RTNS	- Routine list serving as the starting point for 
	;		  determining all subsequent calls.
	;					/TYP=T/REQ/MECH=REFARR
 	;		
	; RETURNS:
	;	. %ZI	- array of all routines that are called by
	;	     	  the input array RTNS.  This can then be used
	;		  to call off to the routine utility %RSEL to 
	;		  resolve routine location.
	;			 
	; EXAMPLE:
	;	D ^%ZRCALLS(.RTNS)
	;	D ^%ZRCALLS("SCADRV")	;resolves all routines called by SCADRV
	;
	;
	;-----Revision History-------------------------------------------------
	;
	;
	;----------------------------------------------------------------------
	N X,RTN
	I $$NEW^%ZT N $ZT
	S @$$SET^%ZT("ZT^%ZRCALLS")
	;
LOOP	F  S X="" S X=$O(RTNS(X)) Q:X=""  D ROUCHK(X)
	Q
	;
	;----------------------------------------------------------------------
ROUCHK(RTN)	;Private;Check for routine linkages
	;----------------------------------------------------------------------
	I $D(%ZI(RTN)) Q   ; already been checked.
	N TMP,FILE
	;
	; Load the routine into temporary array
	; Once a routine is checked, add it to the new list
	; Once a routine is checked for all calls, remove it
	;
	D ^%ZRTNLOD(RTN,"TMP($J,0,"""_RTN_""",")
	D SCAN S %ZI(RTN)=""
	K RTNS(RTN)
	Q
	;
	;----------------------------------------------------------------------
SCAN	;Private;Search each line of the loaded routine 
	;----------------------------------------------------------------------
	; This subroutine searches each line of code from the loaded program 
	; for references to other routines
	;
	N LINE,%X
	S LINE=""
	F  S LINE=$O(TMP($J,0,RTN,LINE)) Q:LINE=""  D
	.	S %X=TMP($J,0,RTN,LINE) 
	.	D FIND
	Q
	;
	;----------------------------------------------------------------------
FIND	;Private;Look for the up arrow, indicating a possible routine call
	;----------------------------------------------------------------------
	I %X'["^" Q    ; no routine call at all
	N PTR,CMT
	I $E($P(%X," ",2))=";" Q   		; don't scan comment lines
	S PTR=0,CMT=0
	S CMT=$F(%X,";",CMT)       		; find a comment character
	F  S PTR=$F(%X,"^",PTR) Q:PTR=0  D PTR  ; PTR is first position past ^
	Q
	;
PTR	I CMT,PTR>CMT Q   ; Ignore if the pointer is found after a comment
	N X,DATA,I
	;
	; Ignore if the first position is not alpha or "%"
	S DATA=$E(%X,PTR) I DATA'?1A,DATA'?1"%" 
	;
	; Construct string, not to exceed eight character program name size
	F I=1:1:7 S X=$E(%X,PTR+I) Q:X'?1AN  S DATA=DATA_X
	;
	; If it's already been checked and included in output or
	; it's already been located by either another routine or
	; somewhere above in the current routine, then quit.
	I $D(RTNS(DATA)) Q
	I $D(%ZI(DATA)) Q
	;
	; Check if the string is a MUMPS routine or a MUMPS global file
	S X=$E(%X,PTR-2) I X'?1AN,X'=",",X'="%",X'="$",X'=" " Q
	I X="="!(X="+")!(X="]")!(X="(") Q
	S X=$E(%X,PTR+$L(DATA)) Q:X="="
	I '$$VALID^%ZRTNS(DATA) Q
	S RTNS(DATA)=RTN
	Q
	;
	;----------------------------------------------------------------------
ZT	;
	D ZE^UTLERR
	Q
