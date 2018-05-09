SQLBLOB	;Private ; Library functions to mamage binary field
	;;Copyright(c)2002 Sanchez Computer Associates, Inc.  All Rights Reserved - 10/28/02 13:54:27 - RUSSELL
	; ORIG:	CHIANG - 09/10/96
	; DESC:	Binary field utility
	;
	; KEYWORDS: BLOB,BINARY,PICTURE,SIGNATURE
	;
     	; LIBRARY:
	;       . PARSE     - Return internal expression of a binary field
        ;       . READ      - Return binary field data
	;----------------------------------------------------------------------
	;----Revision History---------------------------------------------------
	;
	; 10/28/02 - Dan Russell - 49794
	;	     Modified PARSE section to return string in format
	;	     compatible with changes to SQLDD for computeds.
	;
	; 10/08/01 - CHENARDP - 46480
	;	     Corrects a problem with BLOB data retrieval in PARSE
	;	     section.
	;
	; 08/01/01 - CHENARDP - 46480
	;	     Modified parse section to return ref in the format of
	;	     "^GBL(KEY1,node)" instead of "^GBL(KEY1)".  This corrects
	;	     an error retrieving blob data via SQL.
	;
	; 12/15/97 - SPIER - 26982
	;            Modified Q in PARSE to return value of null rather
	;	     then nothing from this extrinisic function.
	;
	;----------------------------------------------------------------------
READ(ref)	; BLOB internal reference (^gbl(key1,key2,...)
	;----------------------------------------------------------------------
	; ARGUMENTS:
	;
	;	. ref	Global reference	/TYP=T/REQ/MECH=VAL
	;
	; EXAMPLES:
	;
	;	S data=$$READ^SQLBLOB("^CIFPIC(123,3")
	;----------------------------------------------------------------------
	;
	N blob,seq,v
	S blob="",seq=""
	S ref=ref_",seq)"			; Full ref ^gbl(key,...,seq)
	F  S seq=$O(@ref) Q:seq=""  D
	.	S v=^(seq)			; Each 450-byte block
	.	S blob=blob_v			; Build single string
	Q blob
	;
	;----------------------------------------------------------------------
PARSE(dinam)	; Return internal reference format for a binary field
	;----------------------------------------------------------------------
	; ARGUMENTS:
	;
	;	. dinam		Data item name	/TYP=T/TBL=[DBTBL1D]/MECH=VAL
	;
	; EXAMPLES:
	;
	;      $$PARSE^SQLBLOB("CIFPIC") returns
	;
	;      ($$READ^SQLBLOB("^CIFPIC("_ACN))
	;
	;      $$PARSE^SQLBLOB("CIFSIG") returns
	;
	;      ($$READ^SQLBLOB("^CIFSIG("_ACN))
	;
	;----------------------------------------------------------------------
	N del,fid,fsn,gbl,i,key,keys,nod,q,ref
	S fid=$P(dinam,".",1)			; File name
   	D fsn^SQLDD(.fsn,fid)	  	 	; File attributes
	I $G(ER) Q ""				;12/15/97 mas
	S gbl=$P(fsn(fid),"|",2)		; Global reference
	S keys=$P(gbl,"(",2),gbl=$P(gbl,"(",1)  ; Access keys
	S ref="",q="""",del=q_","_q
	F i=1:1:$L(keys,",") D
	.       S key=$P(keys,",",i)    	; regular data item name
	.	; "str" dummy key
	.       I '($E(key)?1A!($E(key)="%")),$E(key)=q S key=q_q_key_q_q
	.	s ref=ref_"_"_key_"_"_del
	.       ;S ref=ref_key_"_"_del_"_"
	S ref=$E(ref,1,$L(ref)-$l(del)-1) 	; Convert to function
	S nod=$$NOD^SQLDD(dinam)
	;
	i nod'="" s ref="($$READ^SQLBLOB("_q_gbl_"("_q_ref_"_"_q_","_nod_q_"))"
	e  s ref="($$READ^SQLBLOB("_q_gbl_"("_q_ref_"))"
	Q ref
