DBSCMPF(rtn,src,nolink) ; Public, DQ Compiler source code library interface
	;;Copyright(c)1996 Sanchez Computer Associates, Inc.  All Rights Reserved - 04/09/96 10:48:00 - CHIANG
	;
	; Utility to convert prodecural code into a run-time routine.
	;
	; KEYWORDS:   COMPILER
	;
	; ARGUMENTS:
	;
	;   . rtn	Routine name		/TYP=T/MECH=VAL
	;   . src       Source code		/TYP=T/MECH=REFARR:R
	;   . nolink    Skip linking image	/TYP=L/NOREQ/DFT=0/MECH=VAL
	;
	; EXAMPLES:
	;
	;    S x(1)="ZZZ ; test routine"
	;    S x(2)=" Q"
	;    D ^DBSCMP("ZZZ",.x)
	;-----------------------------------------------------------------------
	I $G(rtn)="" Q
	;
	; Substitute each tab character with a single blank space
	;
	S i="" F  S i=$O(src(i)) Q:i=""  S src(i)=$TR(src(i),$c(9)," ")
	D ^%ZRTNCMP(rtn,"src",$G(nolink))
	Q
