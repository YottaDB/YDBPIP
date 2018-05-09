%VMS	;Library;Invoke selected VMS utilities from PROFILE
	;;Copyright(c)1996 Sanchez Computer Associates, Inc.  All Rights Reserved - 01/20/96 13:28:14 - SYSRUSSELL
	; ORIG:  SYSRUSSELL -  8 MAR 1990
	;
	; Allows calls to selected VMS utilities from within MUMPS and PROFILE.
	; Uses ZSY[stem] under GT.M to allow interrupts.
	;
	; KEYWORDS: System services
	;
	; LIBRARY:
	;     . MAIL	VMS MAIL Utility
	;     . PHONE	VMS PHONE Utility
	;     . DCL	VMS DCL
	;
	;---- Revision History ------------------------------------------------
	; 01/20/95 - Dan Russell
	;            Replace ZSYSTEM calls with $$SYS%$ZFUNC to prevent problems
	;            with captive accounts.
	;
	;----------------------------------------------------------------------
	Q
	;
	;----------------------------------------------------------------------
MAIL	;Public;Invoke VMS MAIL Utility
	;----------------------------------------------------------------------
	;
	; KEYWORDS: System services
	;
	N X
	U 0 W $$CLEAR^%TRMVT			; Clear the screen first
	U 0 S X=$$SYS^%ZFUNC("MAIL")		; U 0 here to flush buffer
	Q
	;
	;----------------------------------------------------------------------
PHONE	;Public;Invoke VMS PHONE Utility
	;----------------------------------------------------------------------
	;
	; KEYWORDS: System services
	;
	N X
	U 0 W $$CLEAR^%TRMVT			; Clear the screen first
	U 0 S X=$$SYS^%ZFUNC("PHONE")		; U 0 here to flush buffer
	Q
	;
	;----------------------------------------------------------------------
DCL	;Public;Invoke VMS DCL
	;----------------------------------------------------------------------
	;
	; KEYWORDS: System services
	;
	U 0 W $$CLEAR^%TRMVT 			; Clear the screen first
	U 0 ZSY					; Must be non-captive
	Q
