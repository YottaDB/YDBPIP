%D	;M Utility;Print or provide current date
	;;Copyright(c)1994 Sanchez Computer Associates, Inc.  All Rights Reserved - 04/28/94 14:15:32 - SYSRUSSELL
	; ORIG:  Dan S. Russell (2417) - 10/21/88
	;
	; Utility to print or provide current date as DD MMM YY.  This utility
	; is primarily used by other % routines to format the current system
	; date (+$H).  Application calls should not be made into ^%D because
	; of formatting issues related to internationalization.  Application
	; programs should instead call the appropriate functions within ^%ZM.
	;
	; Call D ^%D to write date to current device
	; Call at D INT^%D to return %DAT = date
	; Call by S X=$$EXT^%D for extrinsic function
	;
	; KEYWORDS: Date and Time
	;----------------------------------------------------------------------
	;
	W $$EXT
	Q
	;
	;----------------------------------------------------------------------
INT	;M Utility;Return formatted system date in %DAT
	;----------------------------------------------------------------------
	;
	; KEYWORDS: Date and Time
	;
	; RETURNS:
	;     . %DAT	Current system date		/TYP=T
	;----------------------------------------------------------------------
	;
	S %DAT=$$EXT
	Q
	;
	;----------------------------------------------------------------------
EXT()	;M Utility;Extrinsic function call to format system date
	;----------------------------------------------------------------------
	;
	; KEYWORDS: Date and Time
	;
	; RETURNS:
	;     . $$	Current system date		/TYP=T
	;----------------------------------------------------------------------
	;
	Q $$^%ZD(+$H,"DD-MON-YY")
