%ZHEX	;M Utility;Hex Conversion Utilities
	;;Copyright(c)1994 Sanchez Computer Associates, Inc.  All Rights Reserved - 04/26/94 17:48:24 - SYSRUSSELL
	; ORIG:  Dan S. Russell (2417) - 10 Nov 88
	;
	; Converts decimal number to hex or hex to decimal
	;
	; Call at top for prompted version and display of results.
	;
	; KEYWORDS:	Formatting
	;
	; LIBRARY:
	;	. $$DECHEX - converts decimal to hex
	;
	;	. $$HEXDEC - converst hex to decimal
	;
START	; Prompted section
	N NUM,X
READ	W ! S NUM=$$PROMPT^%READ("Number (end with # for HEX):  ","") Q:NUM=""
	I NUM?1N.N W "  ",NUM," decimal is ",$$DECHEX(NUM)," in hex" Q
	I $E(NUM,$L(NUM))="#" S X=$E(NUM,1,$L(NUM)-1) W "  ",X," hex is ",$$HEXDEC(X)," in decimal" Q
	W " ... invalid format" G READ
	;
	;----------------------------------------------------------------------
DECHEX(DEC)	;Public;Convert decimal to hex
	;----------------------------------------------------------------------
	;
	; KEYWORDS:	Formatting
	;
	; ARGUMENTS:
	;	. DEC		Decimal number		/TYP=N
	;
	; RETURNS:
	;	. $$		Hex equivalent		/TYP=T
	;
	; EXAMPLE:
	;	S X=$$DECHEX^%ZHEX(123) then X="7B"
	;
	N HEX 
	S HEX=""
	F  Q:'DEC  S HEX=$E("0123456789ABCDEF",DEC#16+1)_HEX,DEC=DEC\16
	Q HEX
	;
	;----------------------------------------------------------------------
HEXDEC(HEX)	;Public;Convert hex to decimal
	;----------------------------------------------------------------------
	;
	; KEYWORDS:	Formatting
	;
	; ARGUMENTS:
	;	. HEX		Hex number		/TYP=T
	;
	; RETURNS:
	;	. $$		Decimal equivalent	/TYP=N
	;
	; EXAMPLE:
	;	S X=$$HEXDEC^%ZHEX("7B") then X=123
	;
	N DEC,I,X,Y
	S DEC=0,X=$TR(HEX,"abcdef","ABCDEF")
	F I=1:1:$L(X) S Y=$F("0123456789ABCDEF",$E(X,I)) Q:'Y  S DEC=DEC*16+(Y-2)
	Q DEC
