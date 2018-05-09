TBXEXD	;Private;DataQwik export definition handler
	;;Copyright(c)2002 Sanchez Computer Associates, Inc.  All Rights Reserved - 05/08/02 17:41:11 - KWANL
	; ORIG:	KWANL - 05/07/02
	; DESC:	DataQwik export definition handler
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
	;
GETCODE(OBJECTID,CODE,FILENAME)	; Get object contents
	;-----------------------------------------------------------------------
	;
	I $G(OBJECTID)="" Q 0_$C(13,10)_$$^MSG(741)
	;
	S FILENAME=OBJECTID_".EXD"
	Q $$EXTRACT(.CODE,OBJECTID)
	;
	;-----------------------------------------------------------------------
CHECKOBJ(TOK,OBJECTID)	; Return a message for update or create prompt
	;-----------------------------------------------------------------------
	;
	N HEADER,HEADNAME,USER,DATE,TIME,END,CONAME,MESSAGE
	;
	; S CONAME=$$^CUVAR("CONAM")
	S CONAME=$$SCAU^%TRNLNM("DDPLOG")
	;
	S END=$O(^TMP(TOK,""),-1)
	I END="" Q 0_$C(13,10)_"Missing source code"
	;
	I '$D(^DBTBL(%LIBS,17,OBJECTID)) D  Q MESSAGE
	.	S MESSAGE=1_$C(13,10)_"Create new Export Definition in "_CONAME
	;
	; Export Definition exists, return user and date modified
	S HEADER=^DBTBL(%LIBS,17,OBJECTID)
	S USER=$P(HEADER,"|",3)
	S DATE=$$^%ZD($P(HEADER,"|",2))
	;
	S MESSAGE="Update Export Definition: "_OBJECTID_" Modified by "_USER
	S MESSAGE=MESSAGE_" on "_DATE_" in "_CONAME
	;
	Q 1_$C(13,10)_MESSAGE
	;
	;-----------------------------------------------------------------------
SAVEOBJ(TOK,OBJECTID,USER)	; Save Export Def sent by client
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
	S FILENAME=OBJECTID_".EXD"
	Q $$LOAD(.CODE,FILENAME,3,USER,+$H,$P($H,",",2))
	;
	;-----------------------------------------------------------------------
CHECK(FILE,RUSER,RDATE,RTIME);	Check date stamp between ^DBTBL and ^dbtbl 
	;	Return 1: if matched
	;	       0: if mismatched
	;-----------------------------------------------------------------------
	;
	N EXDID,CDATE,CUSER,DDATE,DUSER
	S EXDID=$P(FILE,".",1) 
	S CDATE=$P($G(^DBTBL("SYSDEV",17,EXDID)),%,2)               ; ^DBTBL date stamp 
	S CUSER=$P($G(^DBTBL("SYSDEV",17,EXDID)),%,3)  
	S DDATE=$P($G(^dbtbl("SYSDEV",17,EXDID)),%,2)               ; ^dbtbl date stamp 
	S DUSER=$P($G(^dbtbl("SYSDEV",17,EXDID)),%,3) 
	; 
	Q $$CKDTUSR^TBXDQUTL(DDATE,DUSER,CDATE,CUSER,RDATE,RUSER) 
	;
	;-----------------------------------------------------------------------
LOAD(CODE,FILE,RTYPE,USER,DATE,TIME)	; 
	;-----------------------------------------------------------------------
	; ARGUMENTS: 
	;	. CODE	      
	;       . FILE        RMS file name           /TYP=T 
	;       . RTYPE       Release type 
	;                       1: fixpack 
	;                       2: service pack 
	;		        3: mrpc            
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
	N EXDID,RTN,SEQ,$ZT,X,SRC
	S $ZT=$$SETZT^%ZT("ZTL^TBXEXD")
	S EXDID=$P(FILE,".",1)
	;
	K ^DBTBL("SYSDEV",17,EXDID)
	;
	; update ^DBTBL and insert last modified info into the header
	S SEQ="" F  S SEQ=$O(CODE(SEQ)) Q:SEQ=""  D
	. I CODE(SEQ)[("^DBTBL(""SYSDEV"",17,"""_EXDID_""")") D
	.. S $P(CODE(SEQ),"|",2)=DATE			; restore compiled routine name
	.. I $L(CODE(SEQ),"|")'>3 S $P(CODE(SEQ),"|",3)=USER_$C(34)
	.. I $L(CODE(SEQ),"|")>3 S $P(CODE(SEQ),"|",3)=USER
	. S @CODE(SEQ)
	S X=1
	;
	; if service pack, update ^dbtbl
	I RTYPE=2 D
	. K ^dbtbl("SYSDEV",17,EXDID)
	. S SRC="^DBTBL(""SYSDEV"",17,"""_EXDID_""")"
	. S X=$$CP^TBXDQUTL(SRC,"^dbtbl")
	Q:X=0 "0|Failed to update export definition "_EXDID_" in ^dbtbl"
	;
	Q 1
	;
	;-----------------------------------------------------------------------
EXTRACT(CODE,EXDID)	; Extract an export definition 
	;----------------------------------------------------------------------- 
	; ARGUMENTS: 
	;	. CODE	      Array contains the contents of the file 
	;	. EXDID	      	
	; RETURNS: 
	;       . $$            Success or failure      /TYP=T 
	;                       Success = 1 
	;                       Failure returns 
	;                         "0|Export definition "_EXDID_" does not exist" 
	;			  "0|"_$ZS
	;----------------------------------------------------------------------- 
	; 
	I '$D(^DBTBL("SYSDEV",17,EXDID)) Q "0|Export definition "_EXDID_" does not exist" 
	; 
	N $ZT
	S $ZT=$$SETZT^%ZT("ZTE^TBXEXD")
	;
	D CPYARR^TBXDQUTL(.CODE,17,EXDID)
	;
	Q 1 
	;-----------------------------------------------------------------------
OBSDQW(FILE);	Obsolete a screen definition 
	;-----------------------------------------------------------------------
	;
	N EXDID
	;
	S EXDID=$P(FILE,".",1)
	S ^TMPDQC($J,"SYSDEV",17,EXDID)=-1
	;
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
