TBXLUD	;Private;DataQwik look up table item documentation handler
	;;Copyright(c)2002 Sanchez Computer Associates, Inc.  All Rights Reserved - 05/08/02 17:41:11 - KWANL
	; ORIG:	KWANL - 05/07/02
	; DESC:	DataQwik look up table item documentation handler
	;
	; KEYWORDS:	
	;
	; INPUTS:
	;	. System	
	;
	;	. Data	[ddfile]di
	;
	;	. v1	desc of variable	/TYP=T
	;
	; RETURNS:
	;	. XX	desc of return		/TYP=T
	;
	; RELATED:
	;	. $$func^rtn - description of how related
	;
	; EXAMPLE:
	;	Text of example (line one)
	;-----------------------------------------------------------------------
	; Revision History:
	; 01/24/2005	KWANL
	;		Change PACKTYPE to MRPC in SAVEOBJ
	;
	; 11/17/2005	KWANL
	;		Replaced reference to ^CUVAR with $$SCAU^%TRNLNM("DDPLOG")
	;
	;
	;-----------------------------------------------------------------------
GETCODE(LUDID,CODE,FILENAME)	; Get object contents
	;-----------------------------------------------------------------------
	;
	I $G(LUDID)="" Q 0_$C(13,10)_$$^MSG(741)
	;
	S FILENAME=LUDID_".LUD"
	Q $$EXTRACT(.CODE,LUDID)
	;
	;-----------------------------------------------------------------------
CHECKOBJ(TOK,OBJECTID)	; Return a message for update or create prompt
	;-----------------------------------------------------------------------
	;
	N HEADER,USER,DATE,TIME,END,CONAME,MESSAGE
	;
	; S CONAME=$$^CUVAR("CONAM")
	S CONAME=$$SCAU^%TRNLNM("DDPLOG")
	;
	S END=$O(^TMP(TOK,""),-1)
	I END="" Q 0_$C(13,10)_"Missing source code"
	;
	I '$D(^DBTBL(%LIBS,12,OBJECTID)) D  Q MESSAGE
	.	S MESSAGE=1_$C(13,10)_"Create new Look Up Documentation Definition in "_CONAME
	;
	S MESSAGE="Update Look Up Documentation Definition: "_OBJECTID
	;
	Q 1_$C(13,10)_MESSAGE
	;
	;-----------------------------------------------------------------------
SAVEOBJ(TOK,LUDID,USER)	; Save Look Up Documentation Def sent by client
	;
	N SEQ,CODE,FILENAME
	;
	; Load from buffer into CODE array
	S SEQ="" F  S SEQ=$O(^TMP(TOK,SEQ)) Q:SEQ=""  S CODE(SEQ)=^TMP(TOK,SEQ)
	;
	; Delete buffer
	K ^TMP(TOK)
	;
	S FILENAME=LUDID_".LUD"
	Q $$LOAD(.CODE,FILENAME,3,USER,+$H,$P($H,",",2))
	;
	;-----------------------------------------------------------------------
CHECK(FILE,RUSER,RDATE,RTIME);	Check date stamp between ^DBTBL and ^dbtbl 
	;	Return 1: if matched
	;	       0: if mismatched
	;-----------------------------------------------------------------------
	;
	Q 1 
	;
	;-----------------------------------------------------------------------
LOAD(CODE,FILE,RTYPE,USER,DATE,TIME)	; 
	; ARGUMENTS: 
	;	. CODE	      An arrary contains contents of DQ element
	;	. FILE        RMS file name          /TYP=T
	;	. RTYPE       Release type
	;                       1: fixpack 
	;                       2: service pack 
	;	      	        3: MPRPC
	;       . USER        Last modified user     /TYP=T 
	;       . DATE        Last modified date     /TYP=N 
	;       . TIME        Last modified time     /TYP=N 
	; RETURNS:
	;       . $$            Success or failure      /TYP=T 
	;                       Success = 1 
	;                       Failure returns 
	;                         "0|Unable to open DEVICE" 
	; 
	;-----------------------------------------------------------------------
	;
	N LUDID,EXT,SEQ,$ZT,X,IDX,KEY,SRC
	S $ZT=$$SETZT^%ZT("ZTL^TBXLUD")
	S X=1
	S LUDID=$P(FILE,".",1),EXT=$P(FILE,".",2)
	;
	K ^DBTBL("SYSDEV",12,LUDID)
	S SEQ="" F  S SEQ=$O(CODE(SEQ)) Q:SEQ=""  D
	. I CODE(SEQ)["--------------------------------------- Section marker"  D  Q
	.. S KEY=$P(CODE(SEQ)," ",1)
	.. S IDX=0
	. I (CODE(SEQ)="")&(IDX=0) D  Q
	.. S IDX=IDX+1
	. I (CODE(SEQ)="")&(CODE(SEQ+1)["--------------------------------------- Section marker") Q
	. E  D
	.. S ^DBTBL("SYSDEV",12,LUDID,KEY,IDX)=CODE(SEQ),IDX=IDX+1
	I RTYPE=2 D
	. K ^dbtbl("SYSDEV",12,LUDID)
	. S SRC="^DBTBL(""SYSDEV"",12,"""_LUDID_""")"
	. S X=$$CP^TBXDQUTL(SRC,"^dbtbl")
	Q:X=0 "0|Failed to update lookup table item documentation "_LUDID_" in ^dbtbl"
	I (RTYPE=1)!(RTYPE=2) S ^TMPDQC($J,"SYSDEV",12,LUDID)=""
	Q 1
	;
	;-----------------------------------------------------------------------
EXTRACT(CODE,LUDID)	; Extract a look up table item documentation 
	;----------------------------------------------------------------------- 
	; ARGUMENTS: 
	;	. CODE		Load DQ contents into an array
	;	. LUDID		Look up table item id      	
	; RETURNS: 
	;       . $$            Success or failure      /TYP=T 
	;                       Success = 1 
	;                       Failure returns 
	;                         "0|Lookup table item documenation "_LUDID_" does not exist" 
	;----------------------------------------------------------------------- 
	; 
	I '$D(^DBTBL("SYSDEV",12,LUDID)) Q "0|Lookup table item documentation "_LUDID_" does not exist" 
	; 
	N $ZT,CITM,SEQ,J
	S $ZT=$$SETZT^%ZT("ZTE^TBXLUD")
	;
	S (CITM,SEQ)="",J=0 
	F  S CITM=$O(^DBTBL("SYSDEV",12,LUDID,CITM)) Q:CITM=""  D 
	. I J'=0 S J=J+1,CODE(J)="" 
	. S J=J+1,CODE(J)=CITM_" --------------------------------------- Section marker" 
	. S J=J+1,CODE(J)="" 
	. F  S SEQ=$O(^DBTBL("SYSDEV",12,LUDID,CITM,SEQ)) Q:SEQ=""  D 
	.. S J=J+1,CODE(J)=^DBTBL("SYSDEV",12,LUDID,CITM,SEQ) 
	Q 1 
	;-----------------------------------------------------------------------
OBSDQW(FILE);	Obsolete a look up table item documentation 
	;-----------------------------------------------------------------------
	; ARGUMENTS: 
	;	. FILE		Look up table item id to be obsoleted	/TYP=ARR 	
	; RETURNS: 
	;       . $$            Success or failure       	/TYP=T
	;                       Success = 1 
	;                       Failure returns 
	;                         "0|Lookup table item documenation "_LUDID_" does not exist" 
	;----------------------------------------------------------------------- 
	;
	N NAME,LUDID,KEY
	;
	S NAME=$P(FILE,".",1)
	S LUDID=$P(NAME,"-",1),KEY=$P(NAME,"-",2)
	S ^TMPDQC($J,"SYSDEV",12,LUDID)=-1
	;        ;
	Q 1 
	;
	;----------------------------------------------------------------------
ZTL	; Error trap for load 
	;---------------------------------------------------------------------- 
	; 
	N X
	S X=$ZSTATUS
	S ER=1
	S RM="Failed to load element. "_X 
	; 
	Q 0_"|"_RM 
	; 
	;---------------------------------------------------------------------- 
ZTE	; Error trap for extract 
	;---------------------------------------------------------------------- 
	; 
	N X
	S X=$ZSTATUS
	S ER=1
	S RM="Failed to extract element. "_X
	;
	Q 0_"|"_RM
	;
