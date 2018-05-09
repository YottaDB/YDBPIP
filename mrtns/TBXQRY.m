TBXQRY	;Private;DataQwik query handler
	;;Copyright(c)2002 Sanchez Computer Associates, Inc.  All Rights Reserved - 05/08/02 17:41:11 - KWANL
	; ORIG:	KWANL - 05/07/02
	; DESC:	DataQwik query handler
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
GETCODE(QRYID,CODE,FILENAME)	; Get object contents
	;-----------------------------------------------------------------------
	;
	I $G(QRYID)="" Q 0_$C(13,10)_$$^MSG(741)
	;
	S FILENAME=QRYID_".QRY"
	Q $$EXTRACT(.CODE,QRYID)
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
	I '$D(^DBTBL(%LIBS,4,OBJECTID)) D  Q MESSAGE
	.	S MESSAGE=1_$C(13,10)_"Create new Query  Definition in "_CONAME
	;
	; Query  Definition exists, return user and date modified
	S HEADER=^DBTBL(%LIBS,4,OBJECTID,0)
	S USER=$P(HEADER,"|",15)
	S DATE=$$^%ZD($P(HEADER,"|",3))
	;
	S MESSAGE="Update Query  Definition: "_OBJECTID_" Modified by "_USER
	S MESSAGE=MESSAGE_" on "_DATE_" in "_CONAME
	;
	Q 1_$C(13,10)_MESSAGE
	;
	;-----------------------------------------------------------------------
SAVEOBJ(TOK,QRYID,USER)	; Save Query  Def sent by client
	;-----------------------------------------------------------------------
	; 
	N SEQ,CODE,FILENAME
	;
	; Load from buffer into CODE array
	S SEQ="" F  S SEQ=$O(^TMP(TOK,SEQ)) Q:SEQ=""  S CODE(SEQ)=^TMP(TOK,SEQ)
	;
	; Delete buffer
	K ^TMP(TOK)
	;
	S FILENAME=QRYID_".QRY"
	Q $$LOAD(.CODE,FILENAME,3,USER,+$H,$P($H,",",2))
	;
	;-----------------------------------------------------------------------
CHECK(FILE,RUSER,RDATE,RTIME);	Check date stamp between ^DBTBL and ^dbtbl 
	;	Return 1: if matched
	;	       0: if mismatched
	;-----------------------------------------------------------------------
	;
	N QRYID,CDATE,CUSER,DDATE,DUSER
	S QRYID=$P(FILE,".",1) 
	;
	S CDATE=$P($G(^DBTBL("SYSDEV",4,QRYID,0)),%,3)               ; ^DBTBL date stamp 
	S CUSER=$P($G(^DBTBL("SYSDEV",4,QRYID,0)),%,15)
	S DDATE=$P($G(^dbtbl("SYSDEV",4,QRYID,0)),%,3)               ; ^dbtbl date stamp 
	S DUSER=$P($G(^dbtbl("SYSDEV",4,QRYID,0)),%,15) 
	; 
	Q $$CKDTUSR^TBXDQUTL(DDATE,DUSER,CDATE,CUSER,RDATE,RUSER) 
	;
	;-----------------------------------------------------------------------
LOAD(CODE,FILE,RTYPE,USER,DATE,TIME)	; Load a query definition 
	;-----------------------------------------------------------------------
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
	N QRYID,EXT,SEQ,$ZT,X,SEQ1,SRC
	S $ZT=$$SETZT^%ZT("ZTL^TBXQRY")
	S QRYID=$P(FILE,".",1),EXT=$P(FILE,".",2)
	;
	K ^DBTBL("SYSDEV",4,QRYID)
	;
	S SEQ1=$O(CODE(""),-1)
	;
	; update ^DBTBL and insert modified info into the header
	S SEQ="" F  S SEQ=$O(CODE(SEQ)) Q:SEQ=""  D
	. I CODE(SEQ)[("^DBTBL(""SYSDEV"",4,"""_QRYID_""",0)") D
	.. S $P(CODE(SEQ),"|",3)=DATE
	.. I $P(CODE(SEQ),"|",15)[$C(34) S $P(CODE(SEQ),"|",15)=USER_$C(34)
	.. E  S $P(CODE(SEQ),"|",15)=USER
	. I (SEQ=SEQ1)&(CODE(SEQ)="") Q
	. S @CODE(SEQ)
	S X=1
	;
	; if service pack, update ^dbtbl
	I RTYPE=2 D
	. K ^dbtbl("SYSDEV",4,QRYID)
	. S SRC="^DBTBL(""SYSDEV"",4,"""_QRYID_""")"
	. S X=$$CP^TBXDQUTL(SRC,"^dbtbl")
	Q:X=0 "0|Failed to update query "_QRYID_" in ^dbtbl"
	;
	; set up for DQ compile
	I (RTYPE=1)!(RTYPE=2) S ^TMPDQC($J,"SYSDEV",4,QRYID)=""
	Q 1
	;
	;-----------------------------------------------------------------------
EXTRACT(CODE,QRYID)	; Extract a query definition 
	;----------------------------------------------------------------------- 
	; ARGUMENTS: 
	;	. CODE		Load the DQ contents into array CODE	/TYP=ARR 
	;	. QRYID	      	Query ID				/TYP=T
	; RETURNS: 
	;       . $$            Success or failure 		/TYP=T
	;                       Success = 1 
	;                       Failure returns 
	;                         "0|Aggregate definition "_ARGID_" does not exist" 
	;----------------------------------------------------------------------- 
	; 
	I '$D(^DBTBL("SYSDEV",4,QRYID)) Q "0|Query definition "_QRYID_" does not exist" 
	; 
	N $ZT
	S $ZT=$$SETZT^%ZT("ZTE^TBXQRY")
	;
	D CPYARR^TBXDQUTL(.CODE,4,QRYID)
	; 
	Q 1 
	;-----------------------------------------------------------------------
OBSDQW(FILE);	Obsolete a query definition 
	;-----------------------------------------------------------------------
	; ARGUMENTS: 
	;	. FILE	      	Query ID to be obsoleted		/TYP=T
	; RETURNS: 
	;       . $$            Success or failure 		/TYP=T
	;                       Success = 1 
	;                       Failure returns 
	;                         "0|"_$SZ 
	;----------------------------------------------------------------------- 
	;
	N QRYID
	S QRYID=$P(FILE,".",1)
	S ^TMPDQC($J,"SYSDEV",4,QRYID)=-1
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
