TBXFPP	;Private;DataQwik filer executive definition handler
	;;Copyright(c)2002 Sanchez Computer Associates, Inc.  All Rights Reserved - 05/08/02 13:45:18 - KWANL
	; ORIG:	KWANL - 05/07/02
	; DESC:	DataQwik filer pre_post definition handler
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
	S FILENAME=OBJECTID_".FPP"
	Q $$EXTRACT(.CODE,OBJECTID)
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
	I '$D(^DBTBL(%LIBS,10,OBJECTID)) D  Q MESSAGE
	.	S MESSAGE=1_$C(13,10)_"Create new file pre/post processor in "_CONAME
	;
	; Executive Definition exists
	;
	S MESSAGE="Update file pre/post processor: "_OBJECTID_" Modified by "_USER
	;
	Q 1_$C(13,10)_MESSAGE
	;
	;-----------------------------------------------------------------------
SAVEOBJ(TOK,OBJECTID,USER)	; Save Executive Def sent by client
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
	S FILENAME=OBJECTID_".FPP"
	Q $$LOAD(.CODE,FILENAME,3,USER,+$H,$P($H,",",2))
	;
	;----------------------------------------------------------------------- 
CHECK(FILE,RUSER,RDATE,RTIME);	Compare date stamp between ^DBTBL and ^dbtbl 
	;-----------------------------------------------------------------------
	; ARGUMENTS:	
	;	. FILE		RMS file name		/TYP=T
	; RETURNS:
	;	. $$		Match or Failure	/TYP=T
	;			Match = 1
	;			Failure returns
	;			  "0|Wrong file type"
	;			  "0|Date Stamp Mistmatch"	 
	;-----------------------------------------------------------------------
	; 
	Q 1 
	; 
	;----------------------------------------------------------------------- 
LOAD(CODE,FILE,RTYPE,USER,DATE,TIME)	; Load a filer executive definition 
	;-----------------------------------------------------------------------
	; ARGUMENTS: 
	;	. CODE	      Array contains the contents of the file	/TYP=ARRAY
	;       . FILE        RMS file name            		/TYP=T
	;       . RTYPE       Release Type				/TYP=N 
	; 	        1: Fix Pack
	;                       2: Service Pack 
	;		        3: MRPC
	;       . USER        Last modified user      		/TYP=T
	;       . DATE        Last modified date      		/TYP=N
	;       . TIME        Last modified time      		/TYP=N
	; RETURNS: 
	;       . $$            Success or failure      /TYP=T 
	;                       Success = 1 
	;                       Failure returns 
	;                         "0|Wrong file type" 
	; 
	;----------------------------------------------------------------------- 
	; 
	N FPPID,$ZT,SEQ,X,SRC 
	;	
	S $ZT=$$SETZT^%ZT("ZTL^TBXFPP")
	S FPPID=$P(FILE,".",1) 
	;	
	; remove ^DBTBL
	K ^DBTBL("SYSDEV",10,FPPID) 
	;
	; update ^DBTBL
	S SEQ="" F  S SEQ=$O(CODE(SEQ)) Q:SEQ=""  D
	. S @CODE(SEQ)
	;
	S X=1
	;
	; if service pack update ^dbtbl
	I RTYPE=2 D 
	. k ^dbtbl("SYSDEV",10,FPPID)
	. S SRC="^DBTBL(""SYSDEV"",10,"""_FPPID_""")"
	. S X=$$CP^TBXDQUTL(SRC,"^dbtbl") 
	;
	; setup for DQ compile
	I (RTYPE=1)!(RTYPE=2) S ^TMPDQC($J,"SYSDEV",10,FPPID)=""
	Q:X=0 "0|"_FPPID_" failed to udpate ^dbtbl" 
	Q 1   
	; 
	;-----------------------------------------------------------------------
EXTRACT(CODE,FPPID)	; Extract a filer pre/post-processors 
	;----------------------------------------------------------------------- 
	; ARGUMENTS: 
	;	. CODE		Load the contents of DQ into an array
	;	. EXCID	      	      	
	; RETURNS: 
	;       . $$            Success or failure      /TYP=T 
	;                       Success = 1 
	;                       Failure returns 
	;                         "0|Filer Executive definition "_EXCID_" does not exist" 
	;----------------------------------------------------------------------- 
	;
	N $ZT,SRC,REF
	S $ZT=$$SETZT^%ZT("ZTE^TBXFPP")
	;
	I '$D(^DBTBL("SYSDEV",10,FPPID)) Q "0|Filer pre/post processor does not exist" 
	;
	; copy DQ contents into an array
	D CPYARR^TBXDQUTL(.CODE,10,FPPID)
	;
	Q 1 
	;
	;-----------------------------------------------------------------------
OBSDQW(FILE);	Obsolete a filer pre/post processor 
	;-----------------------------------------------------------------------
	;
	N $ZT
	;
	N FPPID
	S FPPID=$P(FILE,".",1)
	S ^TMPDQC($J,"SYSDEV",10,FPPID)=-1
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
