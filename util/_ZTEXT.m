%ZTEXT	;Library;Text Formatter
	;;Copyright(c)1998 Sanchez Computer Associates, Inc.  All Rights Reserved - 08/03/98 13:18:12 - SIGDAE
	; ORIG: Allan Mattson
	;
	; This routine contains extrinsic functions intended to format text
	; (i.e., center, left and right justify).
	;
	; KEYWORDS: Formatting
	;
	; LIBRARY:
	;     . $$CJ	Center text
	;     . $$LJ	Left justify text
	;     . $$RJ	Right justify text
	;     . $$MC	Mixed case (init caps)
	;
	;---- Revision History ------------------------------------------------
	;
	; 07/29/98 - SIGDAE
	;            Added argument TR to sections LJ and RJ to control
	;            whether the returned string is truncated or not.
	;----------------------------------------------------------------------
	Q
	;
	;----------------------------------------------------------------------
CJ(T,W,P1,P2)	;Public;Center text
	;----------------------------------------------------------------------
	;
	; Center text T in a field W wide, padded with leading character
	; P1 and trailing character P2.
	;
	; KEYWORDS: Formatting
	;
	; ARGUMENTS:
	;     . T	Text string			/TYP=T/REQ/MECH=VAL
	;
	;     . W	Field width			/TYP=N/REQ/MECH=VAL
	;
	;     . P1	Leading pad character		/TYP=T/NOREQ/MECH=VAL
	;						/DFT=" "
	;
	;     . P2	Trailing pad character		/TYP=T/NOREQ/MECH=VAL
	;						/DFT=P1
	;
	; RETURNS:
	;     . $$	Formatted string		/TYP=T
	;
	; EXAMPLE:
	;     $$CJ^%ZTEXT("Test",10,"-")="---Test---"
	;----------------------------------------------------------------------
	;
	I $G(P1)="" S P1=" " ; Default left pad character
	I $G(P2)="" S P2=P1 ; Default right pad character
	I W<1 Q T  ; Invalid width
	I $L(T)'<W Q T  ; Do not truncate, OR no need to pad
	I $L(T)+2>W Q $$LJ(T,W,P1)  ; No room to center, left justify it
	N L1,L2,T1,T2
	S L1=W-$L(T)\2,L2=W-$L(T)-L1
	S T1=$J(" ",L1),T2=$J(" ",L2)
	I P1'=" " S T1=$TR(T1," ",P1)
	I P2'=" " S T2=$TR(T2," ",P2)
	Q T1_T_T2
	;
	;----------------------------------------------------------------------
LJ(T,W,P,TR)	;Public;Left justify text
	;----------------------------------------------------------------------
	;
	; Left justify T in field W wide, padded with trailing character P.
	;
	; KEYWORDS: Formatting
	;
	; ARGUMENTS:
	;     . T	Text string			/TYP=T/REQ/MECH=VAL
	;
	;     . W	Field width			/TYP=N/REQ/MECH=VAL
	;
	;     . P	Trailing pad character		/TYP=T/NOREQ/MECH=VAL
	;						/DFT=" "
	;     . TR	Truncate indicator		/TYP=N/NOREQ/MECH=VAL
	;						/DFT=0
	;
	; RETURNS:
	;     . $$	Formatted string		/TYP=T
	;
	; EXAMPLE:
	;     $$LJ^%ZTEXT("Test",10,"-")="Test------"
	;----------------------------------------------------------------------
	;
	I $G(P)="" S P=" " ; Default pad character
	I $G(TR)="" S TR=0	; Default truncate indicator
	I W<1 Q T  ; Invalid width
	I 'TR,$L(T)>W Q T  	; Do not truncate
	I TR,$L(T)>W Q $E(T,1,W)	; truncate
	N T1
	S T1=$J("",W-$L(T))
	I P'=" " S T1=$TR(T1," ",P)
	Q T_T1
	;
	;----------------------------------------------------------------------
RJ(T,W,P,TR)	;Public; Right justify
	;----------------------------------------------------------------------
	;
	; Right justify T in field W wide, padded with leading character P.
	;
	; KEYWORDS:	Formatting
	;
	; ARGUMENTS:
	;     . T	Text string			/TYP=T/REQ/MECH=VAL
	;
	;     . W	Field width			/TYP=N/REQ/MECH=VAL
	;
	;     . P	Leading pad character		/TYP=T/NOREQ/MECH=VAL
	;						/DFT=" "
	;     . TR	Truncate indicator		/TYP=N/NOREQ/MECH=VAL
	;						/DFT=0
	;
	; RETURNS:
	;     . $$	Formatted string		/TYP=T
	;
	; EXAMPLE:
	;     $$RJ^%ZTEXT("Test",10,"-")="------Test"
	;----------------------------------------------------------------------
	;
	I $G(P)="" S P=" " ; Default pad character
	I $G(TR)="" S TR=0	; Default truncate indicator
	I W<1 Q T  ; Invalid width
	I 'TR,$L(T)>W Q T  	; Do not truncate
	I TR,$L(T)>W Q $E(T,1,W)	; truncate
	N T1
	S T1=$J("",W-$L(T))
	I P'=" " S T1=$TR(T1," ",P)
	Q T1_T
	;
	;----------------------------------------------------------------------
MC(T)	;Public;Mixed case (Init caps)
	;----------------------------------------------------------------------
	;
	; Return string T with mixed case.  The first character of every word
	; will be uppercase and the remainder lowercase.  Some words are
	; actually abbreviations or mnuemonics and will not be converted
	; to mixed case.  'Words' are characters terminated by a space.
	;
	; KEYWORDS:	Formatting
	;
	; ARGUMENTS:
	;     . T	Text string			/TYP=T/REQ/MECH=VAL
	;
	; RETURNS
	;     . $$	Formatted string		/TYP=T
	;
	; EXAMPLE:
	;     $$MC^%ZTEXT("TEST STRING")="Test String"
	;----------------------------------------------------------------------
	;
	I $G(T)="" Q ""
	N C,I,NWORD,WORD,P,X
	;
	S X=$$UPPER^%ZFUNC(T) I $E(T,$L(T))'=" " S X=X_" "
	F P=1:1:$L(X," ") S WORD=$P(X," ",P) D MC1
	I $E(T,$L(T))'=" " S X=$E(X,1,$L(X)-1)
	Q X
	;
MC1	Q:WORD=""  Q:$$MC3(WORD)  S NWORD=""
	F I=1:1:$L(WORD) D MC2
	S $P(X," ",P)=NWORD
	Q
	;
MC2	S C=$E(WORD,I) I "@/&+-("[$E(WORD,I-1)
	E  S C=$$LOWER^%ZFUNC(C)
	S NWORD=NWORD_C
	Q
	;
MC3(X)	; Mixed case exceptions (words not translated to mixed case)
	I ",ACH,ATM,BPS,CD,CIF,CRT,DATA-QWIK,DBS,DDA,DDP,DQ,"[(","_WORD_",") Q 1
	I ",EFD,FDIC,FEP,FHLMC,FMS,FNMA,GLS,GNMA,GT.M,IBS,"[(","_WORD_",") Q 1
	I ",IRA,IRS,ISM,M/VX,MMDA,NSF,PDO,POD,SCA,VMS,"[(","_WORD_",") Q 1
	Q ""
	;
TEST	R !!,"Test phrase:  ",X Q:X=""
	S X=$$MC(X) W !,X
	G TEST 
