TBXAGGR	;Private;DataQwik aggregate handler
	;;Copyright(c)2002 Sanchez Computer Associates, Inc.  All Rights Reserved - 05/09/02 15:44:13 - KWANL
	; ORIG:	KWANL - 05/08/02
	; DESC:	DataQwik aggregate handler
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
GETCODE(OBJECTID,CODE,FILENAME)	; Get object contents
	;-----------------------------------------------------------------------
	;
	I $G(OBJECTID)="" Q 0_$C(13,10)_$$^MSG(741)
	;
	S FILENAME=OBJECTID_".AGR"
	Q $$EXTRACT(.CODE,OBJECTID)
	;
	;
	;-----------------------------------------------------------------------
CHECKOBJ(TOK,OBJECTID)	; Return a message for update or create prompt
	;-----------------------------------------------------------------------
	;
	N HEADER,USER,DATE,TIME,END,CONAME,MESSAGE
	;
	; S CONAME=$$^CUVAR("CONAM")
	S CONAME=$$SCAU^%TRNLNM("DDPLOG")
	S END=$O(^TMP(TOK,""),-1)
	I END="" Q 0_$C(13,10)_"Missing source code"
	;
	I '$D(^DBTBL(%LIBS,22,OBJECTID)) D  Q MESSAGE
	.	S MESSAGE=1_$C(13,10)_"Create new Aggregate Definition in "_CONAME
	;
	; Aggregate Definition exists, return user and date modified
	S MESSAGE="Update Aggregate Definition: "_OBJECTID_" Modified in "_CONAME
	;
	Q 1_$C(13,10)_MESSAGE
	;
	;
	;-----------------------------------------------------------------------
SAVEOBJ(TOK,OBJECTID,USER)	; Save Batch Def sent by client
	;-----------------------------------------------------------------------
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
	S FILENAME=OBJECTID_".AGR"
	Q $$LOAD(.CODE,FILENAME,3,USER,+$H,$P($H,",",2))
	;
	;----------------------------------------------------------------------- 
CHECK(FILE,RUSER,RDATE,RTIME);	Compare date stamp between ^DBTBL and ^dbtbl 
	;----------------------------------------------------------------------- 
	; ARGUMENTS: 
	;       . FILE          RMS file name           /TYP=T 
	; RETURNS: 
	;       . $$            Match or Failure        /TYP=T 
	;                       Match = 1 
	;                       Failure returns 
	;                         "0|Date Stamp Mistmatch" 
	; NOTE: No date stamp check for aggregate
	;----------------------------------------------------------------------- 
	; 
	Q 1
	; 
	;----------------------------------------------------------------------- 
LOAD(CODE,FILE,RTYPE,USER,DATE,TIME)	; Load an aggregate definition 
	;----------------------------------------------------------------------- 
	; ARGUMENTS: 
	;	. CODE	      Array contains the contents of the file /TYP=ARR
	;       . FILE        File name 			      /TYP=T		     
	;       . RTYPE       Release type			      /TYP=N
	;                       1: Fix Pack 
	;                       2: Service Pack 
	;		        3: MRPC
	;       . USER        Last modified user     /TYP=T 
	;       . DATE        Last modified date     /TYP=N 
	;       . TIME        Last modified time     /TYP=N 
	; RETURNS: 
	;       . $$            Success or failure      /TYP=T 
	;                       Success = 1 
	;                       Failure returns 
	;			  "0|Failed to update ^dbtbl"
	;----------------------------------------------------------------------- 
	; 
	N $ZT,AGRID,EXT,SEQ,TMPSTR,SRC,X,PGM,SEQ1
	S $ZT=$$SETZT^%ZT("ZTL^TBXAGGR")
	; 
	S AGRID=$P(FILE,".",1),EXT=$P(FILE,".",2),X=1
	; 
	S PGM=$P($G(^DBTBL("SYSDEV",22,AGRID)),"|",4)		; save the program name
	;
	K ^DBTBL("SYSDEV",22,AGRID) 
	;
	S X=1	
	S SEQ1="",SEQ1=$O(CODE(SEQ1),-1)
	S SEQ="" F  S SEQ=$O(CODE(SEQ)) Q:SEQ=""  D
	. 	I CODE(SEQ)[("^DBTBL(""SYSDEV"",22,"""_AGRID_""")") D
	..  	I PGM'="" S $P(CODE(SEQ),"|",4)=PGM	; restore program name
	. I (SEQ=SEQ1)&(CODE(SEQ)="") Q				; to fix the carriage return on windows
	. S @CODE(SEQ)						; Update ^DBTBL
	I RTYPE=2 D 					
	. K ^dbtbl("SYSDEV",22,AGRID)
	. S SRC="^DBTBL(""SYSDEV"",22,"""_AGRID_""")"
	. S X=$$CP^TBXDQUTL(SRC,"^dbtbl") 		; copy ^DBTBL to ^dbtbl
	;
	I (RTYPE=1)!(RTYPE=2) S ^TMPDQC($J,"SYSDEV",22,AGRID)=""			; for DQ compile
	Q:X=0 "0|"_AGRID_" failed to udpate ^dbtbl" 
	Q 1         
	;
	;-----------------------------------------------------------------------
EXTRACT(CODE,AGRID)	; Extract an aggregate definition 
	;----------------------------------------------------------------------- 
	; ARGUMENTS: 
	;	. CODE	      Array contains the contents of the file	/TYP=ARR
	;	. AGRID	      Element name 				/TYP=T	
	; RETURNS: 
	;       . $$            Success or failure 		/TYP=T
	;                       Success = 1 
	;                       Failure returns 
	;                         "0|Aggregate definition "_AGRID" does not exist" 
	;----------------------------------------------------------------------- 
	; 
	I '$D(^DBTBL("SYSDEV",22,AGRID)) Q "0|Aggregate definition "_AGRID_" does not exist" 
	; 
	N $ZT
	S $ZT=$$SETZT^%ZT("ZTE^TBXAGGR")
	;
	D CPYARR^TBXDQUTL(.CODE,22,AGRID)
	; 
	Q 1 
	;
	;-----------------------------------------------------------------------	
OBSDQW(FILE);	Obsolete an aggregate definition 
	;-----------------------------------------------------------------------
	;
	N AGGID
	S AGGID=$P(FILE,".",1)
	S ^TMPDQC($J,"SYSDEV",22,AGGID)=-1
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
