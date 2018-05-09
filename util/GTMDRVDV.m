GTMDRVDV	;Private;PROFILE GT.M development mode driver front-end
	;;Copyright(c)1995 Sanchez Computer Associates, Inc.  All Rights Reserved - 02/15/95 11:45:39 - SYSRUSSELL
	; ORIG:  Dan S. Russell (2417) - 16 Dec 88
	;
	; Front-end driver for PROFILE GT.M application.  This routine should 
	; be first routine executed in the image.  It will place a programmer 
	; in direct mode, but with an image and PRTNS relinked.
	;
	; It also ZLink's any routines in the directory SCAU$PRTNS for patched 
	; routines.
	;
	; If not used directly, rename as front-end of image.
	;
	; Since an image may be called as a "tied" routine or part of a 
	; spawning process using the command line, if $ZCMDLINE is set, 
	; control will be passed to it.  (See, for example, DBSSPAWN).
	;
	; Use GTMDRV for Production environments.  Does not set Control-C
	; trapping for debugging.
	;
	;---- Revision History ------------------------------------------------
	;
	; 02/15/95 - Dan Russell
	;            Modified to not call SCADRV.  Goes directly to direct mode.
	;
	;----------------------------------------------------------------------
	;
	;
START	S $ZT="" ; Force halt on error until PROFILE error trap is set
	D PATCH
	I $E($ZCMDLINE)="^" G TIED
	U 0:(CEN:CTRAP=$C(3,25)) S $ZT="B" F  B  ; Direct mode
	Q
	;
TIED	; Provide ability to run a "tied" program through command line input
	; See SCA$RTNS:TIED_PGM.COM
	;
	U 0:(CTRAP=$C(3,25))
	S $ZT=""
	D @$ZCMDLINE ; Format for command line is ^rtn or tag^rtn
	Q
	;
PATCH	; ZLink all routines which are in the SCAU$PRTNS directory
	N RTN,X
	I $$PRTNS^%LNM="" Q  ; No SCAU$PRTNS directory
P1	S RTN=$ZSEARCH($$PRTNS^%LNM("*.M")) Q:RTN=""
	S X=$P(RTN,".M",1) ; Remove .M to prevent new object module
	ZL X
	G P1
