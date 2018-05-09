TBXSCRN	;Private;DataQwik screen handler
	;;Copyright(c)2002 Sanchez Computer Associates, Inc.  All Rights Reserved - 05/08/02 17:41:11 - KWANL
	; ORIG:	KWANL - 05/07/02
	; DESC:	DataQwik screen handler
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
GETCODE(SCRNID,CODE,FILENAME)	; Get object contents
	;-----------------------------------------------------------------------
	;
	I $G(SCRNID)="" Q 0_$C(13,10)_$$^MSG(741)
	;
	S FILENAME=SCRNID_".SCR"
	Q $$EXTRACT(.CODE,SCRNID)
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
	I '$D(^DBTBL(%LIBS,2,OBJECTID)) D  Q MESSAGE
	.	S MESSAGE=1_$C(13,10)_"Create new Screen Definition in "_CONAME
	;
	; Screen Definition exists, return user and date modified
	S HEADER=^DBTBL(%LIBS,2,OBJECTID,0)
	S USER=$P(HEADER,"|",15)
	S DATE=$$^%ZD($P(HEADER,"|",3))
	;
	S MESSAGE="Update Screen Definition: "_OBJECTID_" Modified by "_USER
	S MESSAGE=MESSAGE_" on "_DATE_" in "_CONAME
	;
	Q 1_$C(13,10)_MESSAGE
	;
	;-----------------------------------------------------------------------
SAVEOBJ(TOK,SCRNID,USER)	; Save Screen Def sent by client
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
	S FILENAME=SCRNID_".SCR"
	Q $$LOAD(.CODE,FILENAME,3,USER,+$H,$P($H,",",2))
	;
	;-----------------------------------------------------------------------
CHECK(FILE,RUSER,RDATE,RTIME);	Check date stamp between ^DBTBL and ^dbtbl 
	;	Return 1: if matched
	;	       0: if mismatched
	;-----------------------------------------------------------------------
	;
	N SCRID,CDATE,CUSER,DDATE,DUSER
	S SCRID=$P(FILE,".",1) 
	S CDATE=$P($G(^DBTBL("SYSDEV",2,SCRID,0)),%,3)               ; ^DBTBL date stamp 
	S CUSER=$P($G(^DBTBL("SYSDEV",2,SCRID,0)),%,15)  
	S DDATE=$P($G(^dbtbl("SYSDEV",2,SCRID,0)),%,3)               ; ^dbtbl date stamp 
	S DUSER=$P($G(^dbtbl("SYSDEV",2,SCRID,0)),%,15) 
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
	N SCRID,RTN,SEQ,$ZT,X,SEQ1,SRC
	S $ZT=$$SETZT^%ZT("ZTL^TBXSCRN")
	S SCRID=$P(FILE,".",1)
	;
	S RTN=$P($G(^DBTBL("SYSDEV",2,SCRID,0)),%,2)				; save compiled routine name
	;
	K ^DBTBL("SYSDEV",2,SCRID)
	;
	S SEQ1=$O(CODE(""),-1)
	; update ^DBTBL and insert last modified info into the header
	S SEQ="" F  S SEQ=$O(CODE(SEQ)) Q:SEQ=""  D
	. I CODE(SEQ)[("^DBTBL(""SYSDEV"",2,"""_SCRID_""",0)") D
	.. S:RTN'="" $P(CODE(SEQ),"|",2)=RTN					; restore compiled routine name
	.. S $P(CODE(SEQ),"|",3)=DATE	
	.. I $L(CODE(SEQ),"|")'>15 S $P(CODE(SEQ),"|",15)=USER_$C(34)
	.. I $L(CODE(SEQ),"|")>15 S $P(CODE(SEQ),"|",15)=USER
	. I (SEQ=SEQ1)&(CODE(SEQ)="") Q
	. S @CODE(SEQ)
	S X=1
	;
	; if service pack, update ^dbtbl
	I RTYPE=2 D
	. K ^dbtbl("SYSDEV",2,SCRID)
	. S SRC="^DBTBL(""SYSDEV"",2,"""_SCRID_""")"
	. S X=$$CP^TBXDQUTL(SRC,"^dbtbl")
	Q:X=0 "0|Failed to update screen "_SCRID_" in ^dbtbl"
	;
	; setup for DQ compile
	I (RTYPE=1)!(RTYPE=2) S ^TMPDQC($J,"SYSDEV",2,SCRID)=RTN
	Q 1
	;
	;-----------------------------------------------------------------------
EXTRACT(CODE,SCRID)	; Extract a screen definition 
	;----------------------------------------------------------------------- 
	; ARGUMENTS: 
	;	. CODE	      Array contains the contents of the file 
	;	. SCRID	      	
	; RETURNS: 
	;       . $$            Success or failure      /TYP=T 
	;                       Success = 1 
	;                       Failure returns 
	;                         "0|Screen definition "_SCRID_" does not exist" 
	;			  "0|"_$ZS
	;----------------------------------------------------------------------- 
	; 
	I '$D(^DBTBL("SYSDEV",2,SCRID)) Q "0|Screen definition "_SCRID_" does not exist" 
	; 
	N $ZT
	S $ZT=$$SETZT^%ZT("ZTE^TBXSCRN")
	;
	D CPYARR^TBXDQUTL(.CODE,2,SCRID)
	;
	Q 1 
	;-----------------------------------------------------------------------
OBSDQW(FILE);	Obsolete a screen definition 
	;-----------------------------------------------------------------------
	;
	N SCRID
	;
	S SCRID=$P(FILE,".",1)
	S ^TMPDQC($J,"SYSDEV",2,SCRID)=-1
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
