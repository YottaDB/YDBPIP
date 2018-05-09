TBXPPL	;Private;DataQwik pre/post library processor handler
	;;Copyright(c)2002 Sanchez Computer Associates, Inc.  All Rights Reserved - 05/08/02 17:41:11 - KWANL
	; ORIG:	KWANL - 05/07/02
	; DESC:	DataQwik pre/post library processor handler
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
	;
	;-----------------------------------------------------------------------
	; Revision History:
	; 01/24/2005	KWANL
	;		Change PACKTYPE to MRPC in SAVEOBJ
	;	
	; 11/17/2005	KWANL
	;		Replaced reference to ^CUVAR with $$SCAU^%TRNLNM("DDPLOG")
	;	
	;-----------------------------------------------------------------------
GETCODE(PPLID,CODE,FILENAME)	; Get object contents
	;-----------------------------------------------------------------------
	;
	I $G(PPLID)="" Q 0_$C(13,10)_$$^MSG(741)
	;
	S FILENAME=PPLID_".PPL"
	Q $$EXTRACT(.CODE,PPLID)
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
	I '$D(^DBTBL(%LIBS,13,OBJECTID)) D  Q MESSAGE
	.	S MESSAGE=1_$C(13,10)_"Create new pre/post library processor Definition in "_CONAME
	;
	; pre/post library processor Definition exists, return user and date modified
	S HEADER=^DBTBL(%LIBS,13,OBJECTID,0)
	S USER=$P(HEADER,"|",15)
	S DATE=$$^%ZD($P(HEADER,"|",3))
	;
	S MESSAGE="Update pre/post library processor Definition: "_OBJECTID_" Modified by "_USER
	S MESSAGE=MESSAGE_" on "_DATE_" in "_CONAME
	;
	Q 1_$C(13,10)_MESSAGE
	;
	;-----------------------------------------------------------------------
SAVEOBJ(TOK,PPLID,USER)	; Save pre/post library processor Def sent by client
	;
	N SEQ,CODE,FILENAME
	S SEQ=""
	;
	; Load from buffer into CODE array
	F  S SEQ=$O(^TMP(TOK,SEQ)) Q:SEQ=""  S CODE(SEQ)=^TMP(TOK,SEQ)
	;
	; Delete buffer
	K ^TMP(TOK)
	;
	S FILENAME=PPLID_".PPL"
	Q $$LOAD(.CODE,FILENAME,3,USER,+$H,$P($H,",",2))
	;
	;-----------------------------------------------------------------------
CHECK(FILE,RUSER,RDATE,RTIME);	Check date stamp between ^DBTBL and ^dbtbl 
	;	Return 1: if matched
	;	       0: if mismatched
	;-----------------------------------------------------------------------
	;
	N PPLID,CDATE,CUSER,DDATE,DUSER
	S PPLID=$P(FILE,".",1) 
	;
	S CDATE=$P($G(^DBTBL("SYSDEV",13,PPLID,0)),%,3)               ; ^DBTBL date stamp 
	S CUSER=$P($G(^DBTBL("SYSDEV",13,PPLID,0)),%,15) 
	S DDATE=$P($G(^dbtbl("SYSDEV",13,PPLID,0)),%,3)               ; ^dbtbl date stamp 
	S DUSER=$P($G(^dbtbl("SYSDEV",13,PPLID,0)),%,15) 
	; 
	Q $$CKDTUSR^TBXDQUTL(DDATE,DUSER,CDATE,CUSER,RDATE,RUSER) 
	;
	;-----------------------------------------------------------------------
LOAD(CODE,FILE,RTYPE,USER,DATE,TIME)	; 
	;-----------------------------------------------------------------------
	; ARGUMENTS: 
	;	. CODE	      An arrary contains contents of DQ element
	;	. FILE        RMS file name           /TYP=T
	;       . USER        Last modified user     /TYP=T 
	;       . DATE        Last modified date     /TYP=N 
	;       . TIME        Last modified time     /TYP=N 
	;       . RTYPE       Release type 
	;                       1: fixpack 
	;                       2: service pack 
	;		        3: MPRPC
	; RETURNS:
	;       . $$            Success or failure      /TYP=T 
	;                       Success = 1 
	;                       Failure returns 
	;                         "0|Unable to open DEVICE" 
	; 
	;-----------------------------------------------------------------------
	;
	N PPLID,EXT,SEQ,$ZT,X,SEQ1,SRC
	S $ZT=$$SETZT^%ZT("ZTL^TBXPPL")
	S PPLID=$P(FILE,".",1),EXT=$P(FILE,".",2)
	;
	; remove ^DBTBL
	K ^DBTBL("SYSDEV",13,PPLID)
	;
	S SEQ1="",SEQ1=$O(CODE(SEQ1),-1)
	; update ^DBTBL
	S SEQ="" F  S SEQ=$O(CODE(SEQ)) Q:SEQ=""  D
	. I CODE(SEQ)[("^DBTBL(""SYSDEV"",13,"""_PPLID_""",0)") D
	.. S $P(CODE(SEQ),"|",3)=DATE
	.. I $P(CODE(SEQ),"|",15)[$C(34) S $P(CODE(SEQ),"|",15)=USER_$C(34)
	.. E  S $P(CODE(SEQ),"|",15)=USER
	. I (SEQ=SEQ1)&(CODE(SEQ)="") Q
	. S @CODE(SEQ)
	;
	S X=1
	;
	; if service pack, update ^dbtbl
	I RTYPE=2 D
	. K ^dbtbl("SYSDEV",13,PPLID)
	. S SRC="^DBTBL(""SYSDEV"",13,"""_PPLID_""")"
	. S X=$$CP^TBXDQUTL(SRC,"^dbtbl")
	Q:X=0 "0|Failed to update pre/post library processor "_PPLID_" in ^dbtbl"
	;
	; set up for DQ compile
	I (RTYPE=1)!(RTYPE=2) S ^TMPDQC($J,"SYSDEV",13,PPLID)=""
	Q 1
	;
	;-----------------------------------------------------------------------
EXTRACT(CODE,PPLID)	; Extract a pre/post library processor definition 
	;----------------------------------------------------------------------- 
	; ARGUMENTS: 
	;	. CODE		Load DQ into an array.		/TYP=ARR 
	;	. PPLID		Pre/post library processor ID	/TYP=T		      	
	; RETURNS: 
	;       . $$            Success or failure       /TYP=T
	;                       Success = 1 
	;                       Failure returns 
	;                         "0|Pre/post library processor "_PPLID_" does not exist" 
	;			  "0|"_$ZS
	;----------------------------------------------------------------------- 
	; 
	I '$D(^DBTBL("SYSDEV",13,PPLID)) Q "0|Pre/post library processor "_PPLID_" does not exist" 
	; 
	N $ZT
	S $ZT=$$SETZT^%ZT("ZTE^TBXPPL")
	;
	D CPYARR^TBXDQUTL(.CODE,13,PPLID)
	; 
	Q 1 
	;-----------------------------------------------------------------------
OBSDQW(FILE);	obsolete a pre/post library processor 
	;-----------------------------------------------------------------------
	; ARGUMENTS: 
	;	. FILE		Pre/post library processor to be obsoleted	/TYP=ARR 		      	
	; RETURNS: 
	;       . $$            Success or failure       /TYP=T
	;                       Success = 1 
	;                       Failure returns 
	;                         "0|Pre/post library processor "_PPLID_" does not exist" 
	;			  "0|"_$ZS
	;----------------------------------------------------------------------- 
	;
	N PPLID
	;
	S PPLID=$P(FILE,".",1)
	S ^TMPDQC($J,"SYSDEV",13,PPLID)=-1
	;
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
