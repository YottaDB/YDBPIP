%T	;M Utility;Display or provide internal time in external format
	;;Copyright(c)1994 Sanchez Computer Associates, Inc.  All Rights Reserved - 04/29/94 08:40:20 - SYSRUSSELL
	; ORIG:  Dan S. Russell (2417) - 10/21/88
	;
	; Utility to convert internal clock time into external format HH:MM AM 
	; or HH:MM PM
	;
	; Call from the top to write current time to current device
	;
	; Also contains additional time utilities
	;
	; KEYWORDS:	Date and Time
	;
	; EXAMPLE:
	;	D ^%T
	;
	; LIBRARY:
	;	. $$EXT^%T	- returns time as return value
	;
	;	. INT^%T	- returns current time in %TIM
	;
	W $$EXT
	Q
	;
	;----------------------------------------------------------------------
INT	;M Utility;Return external format of current time in %TIM variable
	;----------------------------------------------------------------------
	;
	; Returns the external format (HH:MM AM/PM) of the current time in %TIM
	;
	; KEYWORDS:	Date and Time
	;
	; RETURNS:
	;	. %TIM		Current time in		/TYP=T
	;			external format
	;
	; EXAMPLE:
	;	D INT^%T
	;
	S %TIM=$$EXT
	Q
	;
	;----------------------------------------------------------------------
EXT(ITIM)	;M Utility;Return external format of current or specified time
	;----------------------------------------------------------------------
	;
	; Returns the external format (HH:MM AM/PM)
	;
	; KEYWORDS:	Date and Time
	;
	; ARGUMENTS:
	;	. ITIM		Time to format		/TYP=C/NOREQ
	;			If not specified, uses current time
	;
	; RETURNS:
	;	. %TIM		Current time in		/TYP=T
	;			external format
	;
	; EXAMPLE:
	;	S time=$$EXT^%T(inttime)
	;
	N %TIM
	I $D(ITIM) S %TIM=","_ITIM
	E  S %TIM=$H
	Q +$$^%ZD(%TIM,12)_$$^%ZD(%TIM,":60 AM")
