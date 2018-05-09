GTMDRV	;; - UTL - V3.5 - PROFILE GT.M Production driver front-end
	;;Copyright(c)1991 Sanchez Computer Associates, Inc.  All Rights Reserved -  7 FEB 1991 08:02:03 - SYSRUSSELL
	;     ORIG:  Dan S. Russell (2417) - 16 Dec 88
	;CALLED BY:  
	;    CALLS:  
	; PROJ #'S:  
	;     DESC:  Front-end driver for PROFILE GT.M application.
	;            This routine should be first routine executed in the
	;            image.  It is responsible for setting control-C trapping
	;            and error trapping, as well as any other GT.M specific
	;            needs for Production environments.
	;
	;            It also ZLink's any routines in the directory SCAU$PRTNS
	;            for patched routines.
	;
	;            If not used directly, rename as front-end of image.
	;
	;            Since an image may be called as a "tied" routine or
	;            part of a spawning process using the command line,
	;            if $ZCMDLINE is set, control will be passed to it.
	;            (See, for example, DBSSPAWN).
	;
	;            To use in development mode to allow a small run-time
	;            image, e.g., driver and utilities, as well as
	;            Control-C trapping, use GTMDRVDV which is the same
	;            routine with Control-C trapping set.
	;
	; GLOBALS -
	;     READ:  
	;      SET:  
	;
	;    INPUT:  
	;   OUTPUT:  
	;
START	S $ZT="" ; Force halt on error until PROFILE error trap is set
	D PATCH
	I $ZCMDLINE'="" D @$ZCMDLINE Q  ; Tied call, dispatch to request rtn
	U 0:(CEN:CTRAP=$C(3)) ; Allow control-C interrupt
	G ^SCADRV ; Dispatch to SCA driver
	;
PATCH	; ZLink all routines which are in the SCAU$PRTNS directory
	N RTN,X
	I $$PRTNS^%LNM="" Q  ; No SCAU$PRTNS directory
P1	S RTN=$ZSEARCH($$PRTNS^%LNM("*.M")) Q:RTN=""
	S X=$P(RTN,".M",1) ; Remove .M to prevent new object module
	ZL X
	G P1
