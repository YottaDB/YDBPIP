TBXRCDM	;Private;DataQwik record map handler
	;;Copyright(c)2002 Sanchez Computer Associates, Inc.  All Rights Reserved - 05/08/02 17:41:11 - KWANL
	; ORIG:	KWANL - 05/07/02
	; DESC:	DataQwik record map handler
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
GETCODE(RDMID,CODE,FILENAME)	; Get object contents
	;-----------------------------------------------------------------------
	;
	I $G(RDMID)="" Q 0_$C(13,10)_$$^MSG(741)
	;
	S FILENAME=RDMID_".RMP"
	Q $$EXTRACT(.CODE,RDMID)
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
	I '$D(^DBTBL(%LIBS,16,OBJECTID)) D  Q MESSAGE
	.	S MESSAGE=1_$C(13,10)_"Create new Record Map Definition in "_CONAME
	;
	; Record Map Definition exists, return user and date modified
	S HEADER=^DBTBL(%LIBS,16,OBJECTID)
	S USER=$P(HEADER,"|",5)
	S DATE=$$^%ZD($P(HEADER,"|",4))
	;
	S MESSAGE="Update Record Map Definition: "_OBJECTID_" Modified by "_USER
	S MESSAGE=MESSAGE_" on "_DATE_" in "_CONAME
	;
	Q 1_$C(13,10)_MESSAGE
	;
	;-----------------------------------------------------------------------
SAVEOBJ(TOK,RDMID,USER)	; Save Record Map Def sent by client
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
	S FILENAME=RDMID_".RMP"
	Q $$LOAD(.CODE,FILENAME,3,USER,+$H,$P($H,",",2))
	;
	;-----------------------------------------------------------------------
CHECK(FILE,RUSER,RDATE,RTIME);	Check date stamp between ^DBTBL and ^dbtbl 
	;	Return 1: if matched
	;	       0: if mismatched
	;-----------------------------------------------------------------------
	;
	N RDMID,EXT,CDATE,CUSER,DDATE,DUSER
	S RDMID=$P(FILE,".",1),EXT=$P(FILE,".",2) 
	;
	S CDATE=$P($G(^DBTBL("SYSDEV",16,RDMID)),%,4)               ; ^DBTBL date stamp 
	S CUSER=$P($G(^DBTBL("SYSDEV",16,RDMID)),%,5) 
	S DDATE=$P($G(^dbtbl("SYSDEV",16,RDMID)),%,4)               ; ^dbtbl date stamp 
	S DUSER=$P($G(^dbtbl("SYSDEV",16,RDMID)),%,5) 
	; 
	Q $$CKDTUSR^TBXDQUTL(DDATE,DUSER,CDATE,CUSER,RDATE,RUSER) 
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
	N RDMID,EXT,SEQ,$ZT,X,PGM,SEQ1,SRC
	S $ZT=$$SETZT^%ZT("ZTL^TBXRCDM")
	S RDMID=$P(FILE,".",1),EXT=$P(FILE,".",2)
	;
	S PGM=$P($G(^DBTBL("SYSDEV",16,RDMID)),"|",2)
	;
	K ^DBTBL("SYSDEV",16,RDMID)
	;
	S SEQ1=$O(CODE(""),-1)
	;update ^DBTBL and insert modified info into the header
	S SEQ="" F  S SEQ=$O(CODE(SEQ)) Q:SEQ=""  D
	. I CODE(SEQ)[("^DBTBL(""SYSDEV"",16,"""_RDMID_""")") D
	..	S:PGM'="" $P(CODE(SEQ),"|",2)=PGM				; restore program name 
	.. 	S $P(CODE(SEQ),"|",4)=DATE
	.. 	I $P(CODE(SEQ),"|",5)[$C(34) S $P(CODE(SEQ),"|",5)=USER_$C(34)
	.. 	E  S $P(CODE(SEQ),"|",5)=USER
	. I (SEQ=SEQ1)&(CODE(SEQ)="") Q
	. S @CODE(SEQ)
	S X=1
	; 
	; if service pack, update ^dbtbl
	I RTYPE=2 D
	. K ^dbtbl("SYSDEV",16,RDMID)
	. S SRC="^DBTBL(""SYSDEV"",16,"""_RDMID_""")"
	. S X=$$CP^TBXDQUTL(SRC,"^dbtbl")
	Q:X=0 "0|Failed to update record map "_RDMID_" in ^dbtbl"
	;
	; setup for DQ compile
	S ^TMPDQC($J,"SYSDEV",16,RDMID)=""
	Q 1
	;
	;-----------------------------------------------------------------------
EXTRACT(CODE,RMDID)	; Extract a record map definition 
	;----------------------------------------------------------------------- 
	; ARGUMENTS: 
	;	. CODE	      Array contains the contents of the file 
	;	. RMDID	      	
	; RETURNS: 
	;       . $$            Success or failure      /TYP=T 
	;                       Success = 1 
	;                       Failure returns 
	;                         "0|Aggregate definition "_ARGID_" does not exist" 
	;			  "0|"_$ZS
	;----------------------------------------------------------------------- 
	; 
	I '$D(^DBTBL("SYSDEV",16,RMDID)) Q "0|Record map definition "_RMDID_" does not exist" 
	; 
	N $ZT
	S $ZT=$$SETZT^%ZT("ZTE^TBXRCDM")
	;
	D CPYARR^TBXDQUTL(.CODE,16,RMDID)
	; 
	Q 1 
	;-----------------------------------------------------------------------
OBSDQW(FILE);	Obsolete a record map definition  
	;-----------------------------------------------------------------------
	; ARGUMENTS:
	;	. FILE		Record map definition to be obsoleted 	/TYP=T   	
	; RETURNS: 
	;       . $$            Success or failure      /TYP=T 
	;                       Success = 1 
	;                       Failure returns 
	;			  "0|"_$ZS
	;-----------------------------------------------------------------------
	;
	N RMDID
	;
	S RMDID=$P(FILE,".",1)
	S ^TMPDQC($J,"SYSDEV",16,RMDID)=-1
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
