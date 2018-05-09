TBXEXC	;Private;DataQwik filer executive definition handler
	;;Copyright(c)2002 Sanchez Computer Associates, Inc.  All Rights Reserved - 05/08/02 13:45:18 - KWANL
	; ORIG:	KWANL - 05/07/02
	; DESC:	DataQwik filer executive definition handler
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
	;-----------------------------------------------------------------------
	;-----------------------------------------------------------------------
GETCODE(EXCID,CODE,FILENAME)	; Get object contents
	;-----------------------------------------------------------------------
	;
	I $G(EXCID)="" Q 0_$C(13,10)_$$^MSG(741)
	;
	S FILENAME=EXCID_".EXC"
	Q $$EXTRACT(.CODE,EXCID)
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
	I '$D(^DBTBL(%LIBS,3,OBJECTID)) D  Q MESSAGE
	.	S MESSAGE=1_$C(13,10)_"Create new Executive Definition in "_CONAME
	;
	; Executive Definition exists, return user and date modified
	S HEADER=^DBTBL(%LIBS,3,OBJECTID)
	S USER=$P(HEADER,"|",4)
	S DATE=$$^%ZD($P(HEADER,"|",3))
	S TIME=$$TIME^%ZD($P(HEADER,"|",5))
	;
	S MESSAGE="Update Executive Definition: "_OBJECTID_" Modified by "_USER
	S MESSAGE=MESSAGE_" on "_DATE_" at "_TIME_" in "_CONAME
	;
	Q 1_$C(13,10)_MESSAGE
	;
	;-----------------------------------------------------------------------
SAVEOBJ(TOK,EXCID,USER)	; Save Executive Def sent by client
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
	S FILENAME=EXCID_".EXC"
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
	N EXCID,CDATE,CUSER,DDATE,DUSER 
	S EXCID=$P(FILE,".",1) 
	S CDATE=$P($G(^DBTBL("SYSDEV",3,EXCID)),%,3)               ; ^DBTBL date stamp 
	S CUSER=$P($G(^DBTBL("SYSDEV",3,EXCID)),%,4)
	S DDATE=$P($G(^dbtbl("SYSDEV",3,EXCID)),%,3)               ; ^dbtbl date stamp 
	S DUSER=$P($G(^dbtbl("SYSDEV",3,EXCID)),%,4) 
	; 
	Q $$CKDTUSR^TBXDQUTL(DDATE,DUSER,CDATE,CUSER,RDATE,RUSER) 
	;
	;----------------------------------------------------------------------- 
LOAD(CODE,FILE,RTYPE,USER,DATE,TIME)	; Load a filer executive definition 
	;-----------------------------------------------------------------------
	; ARGUMENTS: 
	;	. CODE	      Array contains the contents of the file	/TYP=ARRAY
	;       . FILE        RMS file name            		/TYP=T
	;       . RTYPE       Release Type				/TYP=N 
	; 	      1: Fix Pack
	;                     2: Service Pack 
	;		      3: MRPC
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
	N EXCID,LINE,STATUS,$ZT,SEQ,X,SEQ1,SRC 
	;	
	S $ZT=$$SETZT^%ZT("ZTL^TBXEXEC")
	S EXCID=$P(FILE,".",1) 
	;
	; Remove ^DBTBL
	K ^DBTBL("SYSDEV",3,EXCID) 
	;
	S SEQ1="",SEQ1=$O(CODE(SEQ1),-1)
	;
	; update ^DBTBL
	; update the last modified date-time stamp and user on the first record
	S SEQ="" F  S SEQ=$O(CODE(SEQ)) Q:SEQ=""  D
	. I SEQ=1 D  Q
	.. S $P(CODE(SEQ),"|",3)=DATE,$P(CODE(SEQ),"|",4)=USER,$P(CODE(SEQ),"|",5)=TIME
	.. S ^DBTBL("SYSDEV",3,EXCID)=$E(CODE(SEQ),18,$L(CODE(SEQ)))
	. E  D
	.. I (SEQ1=SEQ)&(CODE(SEQ)="") Q
	.. S ^DBTBL("SYSDEV",3,EXCID,SEQ-1)=CODE(SEQ)
	;
	S X=1
	; 
	; if service pack update ^dbtbl
	I RTYPE=2 D 
	. K ^dbtbl("SYSDEV",3,EXCID)
	. S SRC="^DBTBL(""SYSDEV"",3,"""_EXCID_""")"
	. S X=$$CP^TBXDQUTL(SRC,"^dbtbl") 
	;
	; for DQ compile
	I (RTYPE=1)!(RTYPE=2) S ^TMPDQC($J,"SYSDEV",3,EXCID)=""
	Q:X=0 "0|"_EXCID_" failed to udpate ^dbtbl" 
	Q 1   
	; 
	;-----------------------------------------------------------------------
EXTRACT(CODE,EXCID)	; Extract an aggregate definition 
	;----------------------------------------------------------------------- 
	; ARGUMENTS: 
	;	. CODE	      Array contains the contents of the file 
	;	. EXCID	      	      	
	; RETURNS: 
	;       . $$            Success or failure      /TYP=T 
	;                       Success = 1 
	;                       Failure returns 
	;                         "0|Filer Executive definition "_EXCID_" does not exist" 
	;----------------------------------------------------------------------- 
	;
	N HEADER,$ZT,IDX
	S $ZT=$$SETZT^%ZT("ZTE^TBXEXEC")
	;
	I '$D(^DBTBL("SYSDEV",3,EXCID)) Q "0|Filer executive definition does not exist" 
	;
	; remove the last modified information from the header
	S HEADER=^DBTBL("SYSDEV",3,EXCID) 
	S $P(HEADER,"|",3)="" 
	S $P(HEADER,"|",4)="" 
	S $P(HEADER,"|",5)="" 
	;
	; add the contents into an array
	S CODE(1)="//DO NOT MODIFY  "_HEADER
	S IDX="" F  S IDX=$O(^DBTBL("SYSDEV",3,EXCID,IDX)) Q:IDX=""  D 
	. S CODE($O(CODE(""),-1)+1)=^DBTBL("SYSDEV",3,EXCID,IDX) 
	; 
	Q 1 
	;-----------------------------------------------------------------------
OBSDQW(FILE)	
	;-----------------------------------------------------------------------
	;
	N EXCID
	S EXCID=$P(FILE,".",1)
	S ^TMPDQC($J,"SYSDEV",3,EXCID)=-1
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
