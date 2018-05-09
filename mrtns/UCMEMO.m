UCMEMO	;Method Library; Memo - Memo class
	;;Copyright(c)1999 Sanchez Computer Associates, Inc.  All Rights Reserved - 12/27/99 13:12:59 - FSANCHEZ
	; ORIG: FSANCHEZ - 08/10/1999
	; DESC: Library of Memo methods
	;
	; KEYWORDS: 
	;
	; I18N=QUIT
	;---- Revision History ------------------------------------------------
	;	FSANCHEZ -12/23/99 35208
	;
	;-----------------------------------------------------------------------
toString	;method Memo.toString ; returns String cast of memo
	;-----------------------------------------------------------------------
	;
	S return="$TR("_objectName_",$C(9,10,13),""   "")"
	Q
	;
error	;
	D ERROR^UCGM("Expression expected")
	Q
