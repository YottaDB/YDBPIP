%ZOCTAL	;Public; Decimal/Octal Conversion Utilities
	;;Copyright(c)1994 Sanchez Computer Associates, Inc.  All Rights Reserved - 05/05/94 15:29:09 - SYSRUSSELL
	;     ORIG:  Dan S. Russell (2417) - 10 Nov 88
	;
	; Converts decimal number to octal or octal to decimal
	; Call at top for prompted version.
	;
	; KEYWORDS:	Math
	;
	; LIBRARY:
	;     $$DECOCT - Decimal to octal conversion
	;     $$OCTDEC - Octal to decimal conversion
	;----------------------------------------------------------------------
	;
	N NUM,X
	;
READ	W ! S NUM=$$PROMPT^%READ("Number (end with # for OCTAL):  ","") Q:NUM=""
	I NUM?1N.N W "  ",NUM," decimal is ",$$DECOCT(NUM)," in octal" Q
	I $E(NUM,$L(NUM))'="#" W " ... invalid format" G READ
	;
	S X=$E(NUM,1,$L(NUM)-1)	W "  ",X," octal is ",$$OCTDEC(X)," in decimal"
	Q
	;
	;----------------------------------------------------------------------
DECOCT(DEC)	;Public;Extrinsic function to convert decimal to octal
	;----------------------------------------------------------------------
	;
	; KEYWORDS:	Math
	;
	; ARGUMENTS:
	;     . DEC	Decimal value			/TYP=N/REQ/MECH=VAL
	;
	; RETURNS:
	;     . $$	Octal equivalent		/TYP=N
	;
	; EXAMPLE:
	;     S OCT=$$DECOCT^%ZOCTAL(DEC)
	;----------------------------------------------------------------------
	;
	N OCT S OCT=""
	I DEC=0 Q 0
	;
	F  Q:'DEC  S OCT=DEC#8_OCT,DEC=DEC\8
	Q OCT
	;
	;----------------------------------------------------------------------
OCTDEC(OCT)	;Public;Extrinsic function to convert octal to decimal
	;----------------------------------------------------------------------
	;
	; KEYWORDS:	Math
	;
	;
	; ARGUMENTS:
	;     . OCT	Octal value			/TYP=N/REQ/MECH=VAL
	;
	; RETURNS:
	;     . $$	Decimal equivalent		/TYP=N
	;
	; EXAMPLE:
	;     S DEC=$$OCTDEC^%ZOCTAL(OCT)
	;----------------------------------------------------------------------
	;
	N DEC,I
	;
	S DEC=0 F I=1:1:$L(OCT) S DEC=DEC*8+$E(OCT,I)
	Q DEC
