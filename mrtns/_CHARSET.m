%CHARSET	;Library;Character set strings
	;;Copyright(c)1997 Sanchez Computer Associates, Inc.  All Rights Reserved - 03/11/97 08:35:20 - SILVAGNIR
	; ORIG:  Dan S. Russell (2417) - 04/11/94
	;
	; *********************************************************************
	; IMPORTANT:  Unicode Support
	;
	; Starting with V6.4 (Profile01), this routine should no longer be
	; called by the application.  Upper and lower case conversions
	; should instead be performed using PSL methods String.upper()
	; and String.lower().  Refer to Technical Specification titled
	; 'Unicode Support in Profile Design' for additional details.
	;
	; *********************************************************************
	;
	; Functions to return proper codepoints for upper and lower case
	; conversions.
	;
	; IMPORTANT NOTE FOR CLIENTS USING NON-ASCII CHARACTER SET ENCODING
	;
	; Replace this routine with an alternate routine if using a different
	; character set.  To replace, do not modify this routine or place
	; a custom routine in SCA$RTNS.  Instead, place the customer version
	; of ^%CHARSET at the front of the search list.
	;
	; The strings returned by $$UC() and $$LC() shall be of equal lenght,
	; and $EXTRACT( $$UC(), n) shall correspond to $EXTRACT( $$LC(), n).
	;
	; This Profile core routine is provide codepoints for ISO-8859-2.  To
	; assist clients needing alternative encodings, the following are also
	; provided here.  In order to make use of these, the ISO-8859-2 code
	; should be commented out and the desired code enabled by removing the
	; comments.
	;
	;	ISO-8859-2 - code in the standard version
	;	ISO-8859-1
	;	ISO-8859-15
	;	DEC-MULTINATIONAL
	;
	;----------------------------------------------------------------------
	; 12/16/06 - RussellDS - CR22719
	;	     Updated comments, added ENCODING function, and added other
	;	     code for other encoding.  
	;
	; 05/16/06 - Allan Mattson - CR20047
	;            Added documentation advising that this routine should no
	;            longer be used starting in Profile V6.4.
	;
	; 03/11/97 - SILVAGNIR - Added Latin2 Charset Set
	;
	;----------------------------------------------------------------------
	;
	; KEYWORDS:	System services
	;
	; LIBRARY:
	;	. $$ENCODING	Returns encoding used by %CHARSET
	;
	;	. $$UC		Upper case character set
	;
	;	. $$LC		Lower case character set
	;
	;
	; ***** ISO-8859-2 ***** START
	;----------------------------------------------------------------------
ENCODING()	;Public;Encoding used to name Uppercase and Lowercase characters
	;----------------------------------------------------------------------
	; Notes on ISO-8859-2:
	; This character set maps upper case and lower case characters in the
	; same range as ISO-8859-1, using the same mapping algorithm, but the
	; codepoints in the common range represent different characters.
	; In addition, this character set has some upper case characters in the
	; range 160-175, and some lower case characters in the range 176-192.
	; Like ISO-8859-1, codepoint 223 is mapped to the "sharp s", and has no
	; upper case equivalent.
	;
	; The upper case characters are 161, 163, 165, 166, 169-172, 174, 175,
	; and the ranges 192-214 and 216-222.
	; The lower case characters are 177, 179, 181, 182, 185-188, 190, 191,
	; the ranges 224-246 and 248-254, plus 223 (sharp s).
	; Only codepoint 223 does not have an upper case equivalent in this
	; 8-bit encoding.
	; For characters in the range 161-175 the upper case character and the
	; corresponding lower case character are 16 apart (LC = UC + 16).
	; For the other characters the upper case character and the
	; corresponding lower case character are 32 apart (LC = UC + 32).
	;
	Q "ISO-8859-2"
	;
	;----------------------------------------------------------------------
UC()	;Public;Upper case characters corresponding to lower case characters
	;----------------------------------------------------------------------
	;
	; Return upper case characters representing the U.S. ASCII 
	; characters A-Z, and the ISO-8859-2 (LATIN 2) character set for
	; which there are lower case characters.  This support case
	; conversion only, and does not necessarily provide a full set of
	; upper case characters.
	;
	; Replace this routine with custom routine if using different
	; character set (see comments in routine header)
	;
	; KEYWORDS:	System services
	;
	; RETURNS:
	;	. $$		Upper case character set	/TYP=T
	;
	; EXAMPLE:
	;	S UC=$$UC^%CHARSET
	Q $C(65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,161,163,165,166,169,170,171,172,174,175,192,193,194,195,196,197,198,199,200,201,202,203,204,205,206,207,208,209,210,211,212,213,214,216,217,218,219,220,221,222)
	;
	;----------------------------------------------------------------------
LC()	;Public;Lower case characters corresponding to upper case characters
	;----------------------------------------------------------------------
	;
	; Return lower case characters representing the U.S. ASCII 
	; characters A-Z, and the ISO-8859-2 (LATIN 2) character set for
	; which there are upper case characters.  This support case
	; conversion only, and does not necessarily provide a full set of
	; lower case characters.
	;
	; Replace this routine with custom routine if using different
	; character set (see comments in routine header)
	;
	; KEYWORDS:	System services
	;
	; RETURNS:
	;	. $$		Lower case character set	/TYP=T
	;
	; EXAMPLE:
	;	S LC=$$LC^%CHARSET
	Q $C(97,98,99,100,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,122,177,179,181,182,185,186,187,188,190,191,224,225,226,227,228,229,230,231,232,233,234,235,236,237,238,239,240,241,242,243,244,245,246,248,249,250,251,252,253,254)
	;
	; ***** ISO-8859-2 ***** END
	;
	; ***** IDO-8859-1 ***** START
	;
	;----------------------------------------------------------------------
	;ENCODING()	;Public;Encoding used to name Uppercase and Lowercase characters
	;----------------------------------------------------------------------
	; Notes on ISO-8859-1:
	; The upper case characters are in the range 192-214 and 216-222
	; The lower case characters are in the range 224-246 and 248-254, plus
	; the additional codepoints 223 (sharp s) and 255 (y umlaut).
	; Neither of the last two characters has an uppercase equivalent in this
	; 8-bit encoding.
	; For the other characters the uppercase character and the corresponding
	; lowercase character are 32 apart (LC = UC + 32).
	;
	;quit "ISO-8859-1"
	;
	;----------------------------------------------------------------------
	;UC()	;Public;Upper case character set
	;----------------------------------------------------------------------
	;
	; Return upper case character set representing the U.S. ASCII 
	; characters A-Z, and the ISO-8859-1 (Latin 1) characterset codepoints
	; 192-214 and 216-222.
	;
	; KEYWORDS:	System services
	;
	; RETURNS:
	;	. $$		Upper case character set	/TYP=T
	;
	; EXAMPLE:
	;	S UC=$$UC^%CHARSET
	;Q $C(65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,192,193,194,195,196,197,198,199,200,201,202,203,204,205,206,207,208,209,210,211,212,213,214,216,217,218,219,220,221,222)
	;
	;----------------------------------------------------------------------
	;LC()	;Public;Lower case character set
	;----------------------------------------------------------------------
	;
	; Return lower case character set representing the U.S. ASCII 
	; characters a-z, and the ISO-8859-1 (Latin 1) characterset codepoints
	; 224-246 and 248-254.
	; The codepoints 223 and 255 are lower case characters as well, but do
	; not have an upper case equivalent in this characterset. So they do not
	; participate in case conversions.
	;
	; KEYWORDS:	System services
	;
	; RETURNS:
	;	. $$		Lower case character set	/TYP=T
	;
	; EXAMPLE:
	;	S LC=$$LC^%CHARSET
	;Q $C(97,98,99,100,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,122,224,225,226,227,228,229,230,231,232,233,234,235,236,237,238,239,240,241,242,243,244,245,246,248,249,250,251,252,253,254)
	;
	; ***** ISO-8859-1 ***** END
	;
	; ***** ISO-8859-15 ***** START
	;-----------------------------------------------------------------------
	;ENCODING()	;Public;Encoding used to name Uppercase and Lowercase characters
	;-----------------------------------------------------------------------
	; Notes on ISO-8859-15:
	; This character set inherits all upper case and lower case characters
	; from ISO-8859-1, and adds (the euro sign,) 4 upper case characters and
	; 3 lower case characters.
	; The upper case characters are in the range 192-214 and 216-222, plus
	; the additional codepoints 166 (tied to 168), 180 (tied to 184), 188
	; (tied to 189), and 190 (tied to 255).
	; The lower case characters are in the range 224-246 and 248-254, plus
	; the additional codepoints 168 (tied to 166), 184 (tied to 180), 189
	; (tied to 188), 223 (sharp s) and 255 (tied to 190).
	; Only codepoint 223 does not have an upper case equivalent in this
	; 8-bit encoding.
	; For the other characters the uppercase character and the corresponding
	; lowercase character are 32 apart (LC = UC + 32).
	;
	;quit "ISO-8859-15"
	;
	;-----------------------------------------------------------------------
	;UC()	;Public;Upper case character set
	;-----------------------------------------------------------------------
	;
	; Return upper case character set representing the U.S. ASCII 
	; characters A-Z, and the ISO-8859-15 (Latin 9) characterset codepoints
	; 192-214 and 216-222, 166, 180, 188, and 190.
	;
	; KEYWORDS:	System services
	;
	; RETURNS:
	;	. $$		Upper case character set	/TYP=T
	;
	; EXAMPLE:
	;	S UC=$$UC^%CHARSET
	;Q $C(65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,192,193,194,195,196,197,198,199,200,201,202,203,204,205,206,207,208,209,210,211,212,213,214,216,217,218,219,220,221,222,166,180,188,190)
	;
	;-----------------------------------------------------------------------
	;LC()	;Public;Lower case character set
	;-----------------------------------------------------------------------
	;
	; Return lower case character set representing the U.S. ASCII 
	; characters a-z, and the ISO-8859-15 (Latin 9) character set codepoints
	; 224-246 and 248-254, 168, 184, 189, and 255.
	; The codepoint 223 is a lower case character as well, but does not have
	; an upper case equivalent in this character set. So it does not
	; participate in case conversions.
	;
	; KEYWORDS:	System services
	;
	; RETURNS:
	;	. $$		Lower case character set	/TYP=T
	;
	; EXAMPLE:
	;	S LC=$$LC^%CHARSET
	;Q $C(97,98,99,100,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,122,224,225,226,227,228,229,230,231,232,233,234,235,236,237,238,239,240,241,242,243,244,245,246,248,249,250,251,252,253,254,168,184,189,255)
	;
	; ***** ISO-8859-15 ***** END
	;
	; ***** DEC-MULTINATIONAL ***** START
	;
	;ENCODING()	;Public;Encoding used to name Uppercase and Lowercase characters
	;----------------------------------------------------------------------
	; Notes on DEC-MULTINATIONAL:
	; The upper case characters are in the range 192-207 and 209-221
	; The lower case characters are in the range 224-239 and 241-253, plus
	; the additional codepoint 223 (sharp s).
	; The latter character has an uppercase equivalent in this
	; 8-bit encoding.
	; For the other characters the uppercase character and the corresponding
	; lowercase character are 32 apart (LC = UC + 32).
	;
	;quit "DEC-MULTINATIONAL"
	;
	;----------------------------------------------------------------------
	;UC()	;Public;Upper case character set
	;----------------------------------------------------------------------
	;
	; Return upper case character set representing the U.S. ASCII 
	; characters A-Z, and the DEC Multinational characterset codepoints
	; 192-207 and 209-221.
	;
	; KEYWORDS:	System services
	;
	; RETURNS:
	;	. $$		Upper case character set	/TYP=T
	;
	; EXAMPLE:
	;	S UC=$$UC^%CHARSET
	;Q $C(65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,192,193,194,195,196,197,198,199,200,201,202,203,204,205,206,207,209,210,211,212,213,214,215,216,217,218,219,220,221)
	;
	;----------------------------------------------------------------------
	;LC()	;Public;Lower case character set
	;----------------------------------------------------------------------
	;
	; Return lower case character set representing the U.S. ASCII 
	; characters a-z, , and the DEC Multinational characterset codepoints
	; 224-239 and 241-253.
	; The codepoint 223 is a lower case character as well, but does not
	; have an upper case equivalent in this character set. So it does not
	; participate in case conversions.
	;
	; KEYWORDS:	System services
	;
	; RETURNS:
	;	. $$		Lower case character set	/TYP=T
	;
	; EXAMPLE:
	;	S LC=$$LC^%CHARSET
	;Q $C(97,98,99,100,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,122,224,225,226,227,228,229,230,231,232,233,234,235,236,237,238,239,241,242,243,244,245,246,247,248,249,250,251,252,253)
	;
	; ***** DEC-MULTINATIONAL ***** END