TBXRPT	;Private;DataQwik report handler
	;;Copyright(c)2002 Sanchez Computer Associates, Inc.  All Rights Reserved - 05/07/02 13:45:11 - KWANL
	; ORIG:	KWANL - 05/07/02
	; DESC:	DataQwik report handler
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
	; 01/24/2005 KWANL
	;		Change PACKTYPE to MRPC in SAVEOBJ
	;
	; 11/17/2005	KWANL
	;		Replaced reference to ^CUVAR with $$SCAU^%TRNLNM("DDPLOG")
	;        
	; 11/03/2005    KWANL 
	;               Modified the load section to quit properly after adding 
	;               the user name. 
	; 
	;-----------------------------------------------------------------------
GETCODE(RPTID,CODE,FILENAME)	; Get object contents
	;-----------------------------------------------------------------------
	;
	I $G(RPTID)="" Q 0_$C(13,10)_$$^MSG(741)
	;
	S FILENAME=RPTID_".RPT"
	Q $$EXTRACT(.CODE,RPTID)
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
	I '$D(^DBTBL(%LIBS,5,OBJECTID)) D  Q MESSAGE
	.	S MESSAGE=1_$C(13,10)_"Create new Report Definition in "_CONAME
	;
	; Report Definition exists, return user and date modified
	S HEADER=^DBTBL(%LIBS,5,OBJECTID,0)
	S USER=$P(HEADER,"|",15)
	S DATE=$$^%ZD($P(HEADER,"|",3))
	;
	S MESSAGE="Update Report Definition: "_OBJECTID_" Modified by "_USER
	S MESSAGE=MESSAGE_" on "_DATE_" in "_CONAME
	;
	Q 1_$C(13,10)_MESSAGE
	;
	;-----------------------------------------------------------------------
SAVEOBJ(TOK,RPTID,USER)	; Save Report Def sent by client
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
	S FILENAME=RPTID_".RPT"
	Q $$LOAD(.CODE,FILENAME,3,USER,+$H,$P($H,",",2))
	;
	;----------------------------------------------------------------------- 
CHECK(FILE,RUSER,RDATE,RTIME);	Compare date stamp between ^DBTBL and ^dbtbl 
	;-----------------------------------------------------------------------
	; ARGUMENTS: 
	;       . FILE          RMS file name           /TYP=T 
	; RETURNS: 
	;       . $$            Match or Mismatch    /TYP=T 
	;                       Match = 1 
	;                       Mismatch 
	;                         "0|Date Stamp mismatch" 
	;      
	;----------------------------------------------------------------------- 
	; 
	N RPTID,CDATE,CUSER,DDTAE,DUSER 
	S RPTID=$P(FILE,".",1) 
	S CDATE=$P($G(^DBTBL("SYSDEV",5,RPTID,0)),"|",3)               ; ^DBTBL date stamp 
	S CUSER=$P($G(^DBTBL("SYSDEV",5,RPTID,0)),"|",15)
	S DDATE=$P($G(^dbtbl("SYSDEV",5,RPTID,0)),"|",3)               ; ^dbtbl date stamp 
	S DUSER=$P($G(^dbtbl("SYSDEV",5,RPTID,0)),"|",15) 
	; 
	Q $$CKDTUSR^TBXDQUTL(DDATE,DUSER,CDATE,CUSER,RDATE,RUSER) 
	;
	;----------------------------------------------------------------------- 
LOAD(CODE,FILE,RTYPE,USER,DATE,TIME)	; Load a report  
	;-----------------------------------------------------------------------
	; ARGUMENTS: 
	;	. CODE	      Array contains contents of a dataqwik element	
	;	. FILE	      File name				          /TYP=T
	;       . RTYPE       Release type 
	;                       1: fixpack 
	;                       2: service pack 
	;		        3: MRPC
	;       . USER        Last modified user     /TYP=T 
	;       . DATE        Last modified date     /TYP=N 
	;       . TIME        Last modified time     /TYP=N 
	;
	; RETURNS: 
	;       . $$            Success or failure      /TYP=T 
	;                       Success = 1 
	;                       Failure returns 
	;                         "0|Unable to open DEVICE" 
	; 
	;----------------------------------------------------------------------- 
	; 
	N RPTID,RTN,EXT,SEQ,$ZT,X,SRC,SEQ1 
	;
	S $ZT=$$SETZT^%ZT("ZTL^TBXRPT")
	;
	S RPTID=$P(FILE,".",1),EXT=$P(FILE,".",2) 
	;
	S RTN=$P($G(^DBTBL("SYSDEV",5,RPTID,0)),"|",2)                            ; save compiled routine name 
	; 
	K ^DBTBL("SYSDEV",5,RPTID) 
	;
	S SEQ1=$O(CODE(""),-1)
	; update ^DBTBL and insert last modified info into the header
	S SEQ="" F  S SEQ=$O(CODE(SEQ)) Q:SEQ=""  D
	. I CODE(SEQ)[("^DBTBL(""SYSDEV"",5,"""_RPTID_""",0)") D 
	.. S:RTN'="" $P(CODE(SEQ),"|",2)=RTN 			     	  ; restore compiled routine name
	.. S $P(CODE(SEQ),"|",3)=DATE
	.. I $P(CODE(SEQ),"|",15)[$C(34) S $P(CODE(SEQ),"|",15)=USER_$C(34) Q
	.. S $P(CODE(SEQ),"|",15)=USER
	. I (SEQ=SEQ1)&(CODE(SEQ)="") Q
	. S @CODE(SEQ) 
	S X=1
	;
	; if service pack, update ^dbtbl
	I RTYPE=2 D 
	. K ^dbtbl("SYSDEV",5,RPTID)
	. S SRC="^DBTBL(""SYSDEV"",5,"""_RPTID_""")"
	. S X=$$CP^TBXDQUTL(SRC,"^dbtbl")
	Q:X=0 "0|Failed to update report "_RPTID_" in ^dbtbl"
	;
	; setup for DQ compile
	I (RTYPE=1)!(RTYPE=2) D
	. S ^TMPDQC($J,"SYSDEV",5,RPTID)=RTN
	Q 1
	;-----------------------------------------------------------------------
EXTRACT(CODE,RPTID)	; Extract a report definition 
	;----------------------------------------------------------------------- 
	; ARGUMENTS: 
	;	. CODE		Load the dataqwik content into array CODE
	;	. RPTID		Report ID				      	
	; RETURNS: 
	;       . $$            Success or failure      /TYP=T 
	;                       Success = 1 
	;                       Failure returns 
	;                         "0|Report definition "_RPTID_" does not exist" 
	;			  "0|"_$ZS
	;----------------------------------------------------------------------- 
	; 
	I '$D(^DBTBL("SYSDEV",5,RPTID)) Q "0|Report definition "_RPTID_" does not exist" 
	; 
	N $ZT
	S $ZT=$$SETZT^%ZT("ZTE^TBXRPT")
	;
	D CPYARR^TBXDQUTL(.CODE,5,RPTID)
	;	
	Q 1 
	;-----------------------------------------------------------------------
OBSDQW(FILE);	Obsolete a report definition. 
	;-----------------------------------------------------------------------
	; ARGUMENTS: 
	;	. FILE		Report definition to be obsoleted	/TYP=T
	; RETURNS: 
	;       . $$            Success or failure 		/TYP=T
	;                       Success = 1 
	;                       Failure returns 
	;			  "0|"_$ZS
	;----------------------------------------------------------------------- 
	;
	N RPTID
	;
	S RPTID=$P(FILE,".",1)
	S ^TMPDQC($J,"SYSDEV",5,RPTID)=-1
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
