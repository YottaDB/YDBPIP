%CHARSET	;Library;Character set strings
	;;Copyright(c)1997 Sanchez Computer Associates, Inc.  All Rights Reserved - 03/11/97 08:35:20 - SILVAGNIR
	; ORIG:  Dan S. Russell (2417) - 04/11/94
	;
	; Functions to return proper character set for upper and lower case
	; translations.
	;
	; Replace this routine with an alternate routine if using a different
	; character set.  To replace, do not modify this routine or place
	; a custom routine in SCA$RTNS.  Instead, place the customer version
	; of ^%CHARSET at the front of the search list.
	;
	;----------------------------------------------------------------------
	;
	; 03/11/97 - SILVAGNIR - Added Latin2 Charset Set
	;
	;----------------------------------------------------------------------
	;
	; KEYWORDS:	System services
	;
	; LIBRARY:
	;	. $$UC	- Upper case character set
	;
	;	. $$LC	- Lower case character set
	;
	;----------------------------------------------------------------------
UC()	;Public;Upper case character set
	;----------------------------------------------------------------------
	;
	; Return upper case character set representing the U.S. ASCII 
	; characters A-Z, the DEC supplemental characters $C(192) through
	; $C(221) and the LATIN2 character set.
	;
	; Replace this routine with custom routine if using different
	; character set.
	;
	; KEYWORDS:	System services
	;
	; RETURNS:
	;	. $$		Upper case character set	/TYP=T
	;
	; EXAMPLE:
	;	S UC=$$UC^%CHARSET
	Q $C(65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,161,163,165,166,169,170,171,172,174,175,192,193,194,195,196,197,198,199,200,201,202,203,204,205,206,207,208,209,210,211,212,213,214,216,217,218,219,220,221,222)
	;Q "ABCDEFGHIJKLMNOPQRSTUVWXYZÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏĞÑÒÓÔÕÖ×ØÙÚÛÜİ"
	;
	;----------------------------------------------------------------------
LC()	;Public;Lower case character set
	;----------------------------------------------------------------------
	;
	; Return lower case character set representing the U.S. ASCII 
	; characters a-z, the DEC supplemental characters $C(224) through
	; $C(253) and the LATIN2 charset set.
	;
	; Replace this routine with custom routine if using different
	; character set.
	;
	; KEYWORDS:	System services
	;
	; RETURNS:
	;	. $$		Lower case character set	/TYP=T
	;
	; EXAMPLE:
	;	S LC=$$LC^%CHARSET
	Q $C(97,98,99,100,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,122,177,179,181,182,185,186,187,188,190,191,224,225,226,227,228,229,230,231,232,233,234,235,236,237,238,239,240,241,242,243,244,245,246,248,249,250,251,252,253,254)
	;Q "abcdefghijklmnopqrstuvwxyzàáâãäåæçèéêëìíîïğñòóôõö÷øùúûüı"
