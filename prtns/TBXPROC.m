TBXPROC	;Private; DATA QWIK Procedure handler
	;;Copyright(c)2002 Sanchez Computer Associates, Inc.  All Rights Reserved - 05/07/02 09:30:38 - KWANL
	; ORIG:	JOYCEJ - 10/01/01
	; DESC:	
	;
	;
	;-----------------------------------------------------------------------
	; Revision History:
	; 01/24/2005	KWANL
	;		Change PACKTYPE to MRPC in SAVEOBJ
	;
	; 11/17/2005	KWANL
	;		Replaced reference to ^CUVAR with $$SCAU^%TRNLNM("DDPLOG")
	;	
	; 09/27/2005	Lik Kwan
	;		Set up procedure type so that they will be processed at 
	;		different phase.
	;
	;-----------------------------------------------------------------------
GETCODE(PROCID,CODE,FILENAME)	
	;-----------------------------------------------------------------------
	;
	N HEADER
	;
	I $G(PROCID)="" Q 0_$C(13,10)_$$^MSG(741)
	;
	S FILENAME=PROCID_".PROC"
	;
	Q $TR($$EXTRACT(.CODE,PROCID),"|",$C(13,10))
	;
	;-----------------------------------------------------------------------
CHECKOBJ(TOK,PROCID)	
	;-----------------------------------------------------------------------
	;
	N HEADER,USER,DATE,END,MESSAGE,CONAME
	;
	; S CONAME=$$^CUVAR("CONAM")
	S CONAME=$$SCAU^%TRNLNM("DDPLOG")
	;
	S END=$O(^TMP(TOK,""),-1)
	I END="" Q 0_$C(13,10)_"Missing source code"
	;
	I '$D(^DBTBL(%LIBS,25,PROCID)) D  Q MESSAGE
	.       S MESSAGE=1_$C(13,10)_"Create new Procedure in "_CONAME
	;
	; Procedure exists, return user and date modified
	S HEADER=^DBTBL(%LIBS,25,PROCID)
	S USER=$P(HEADER,"|",4)
	S DATE=$$^%ZD($P(HEADER,"|",3))
	S TIME=$$TIME^%ZD($P(HEADER,"|",5))
	;
	S MESSAGE="Update Procedure: "_PROCID_" Modified by "_USER
	S MESSAGE=MESSAGE_" on "_DATE_" at "_TIME_" in "_CONAME
	;
	Q 1_$C(13,10)_MESSAGE
	;
	;-----------------------------------------------------------------------
SAVEOBJ(TOK,PROCID,USER)	
	;-----------------------------------------------------------------------
	;
	N HEADER,SEQ,FILENAME
	;
	S SEQ="" F  S SEQ=$O(^TMP(TOK,SEQ)) Q:SEQ=""  S CODE(SEQ)=^TMP(TOK,SEQ)
	;
	K ^TMP(TOK)
	;
	S FILENAME=PROCID_".PROC"
	Q $TR($$LOAD(.CODE,FILENAME,3,USER,+$H,$P($H,",",2)),"|",$C(13,10))
	;
	;-----------------------------------------------------------------------
CHECK(FILE,RUSER,RDATE,RTIME);	Compare ^DBTBL and ^dbtbl.  
	; If match return 1, 0 otherwise
	;-----------------------------------------------------------------------
	;
	N PROC,CDATE,CUSER,DDATE,DUSER
	S PROC=$P(FILE,".",1)
	S CDATE=$P($G(^DBTBL("SYSDEV",25,PROC)),%,3)               ; ^DBTBL date stamp 
	S CUSER=$P($G(^DBTBL("SYSDEV",25,PROC)),%,4)
	S DDATE=$P($G(^dbtbl("SYSDEV",25,PROC)),%,3)               ; ^dbtbl date stamp 
	S DUSER=$P($G(^dbtbl("SYSDEV",25,PROC)),%,4)
	;
	Q $$CKDTUSR^TBXDQUTL(DDATE,DUSER,CDATE,CUSER,RDATE,RUSER)
	; 
	;-----------------------------------------------------------------------
LOAD(CODE,FILE,RTYPE,USER,DATE,TIME);	Load a procedure definition 
	;-----------------------------------------------------------------------
	; ARGUMENTS:
	;	. CODE		
	;       . FILE        RMS file name           /TYP=T 
	;       . RTYPE       Release type
	;	              1: fixpack
	;		      2: service pack
	;		      3: MRPC
	;       . USER        Last modified user     /TYP=T 
	;       . DATE        Last modified date     /TYP=N 
	;       . TIME       Last modified time     /TYP=N
	; RETURNS: 
	;       . $$            Success or failure      /TYP=T 
	;                       Success = 1 
	;			Failure returns
	;                         "0|Unable to open DEVICE" 
	;-----------------------------------------------------------------------
	;
	N IDX,PROC,STATUS,$ZT,SRC,X,HEADER,NOHEAD,SEQ1
	;
	S $ZT=$$SETZT^%ZT("ZTL^TBXPROC")
	;
	S PROC=$P(FILE,".",1) 
	;
	S HEADER=$G(^DBTBL("SYSDEV",25,PROC))
	K ^DBTBL("SYSDEV",25,PROC) 
	;
	S NOHEAD=0,SEQ1="",SEQ1=$O(CODE(SEQ1),-1)					
	S IDX="" F  S IDX=$O(CODE(IDX)) Q:IDX=""  D
	. I IDX=1 D  Q 
	.. I CODE(1)'["//DO NOT MODIFY" D  Q
	...	S NOHEAD=1						; 1st line is not a header
	...	S ^DBTBL("SYSDEV",25,PROC,IDX)=CODE(IDX)
	.. S $P(CODE(IDX),"|",3)=DATE,$P(CODE(IDX),"|",4)=USER,$P(CODE(IDX),"|",5)=TIME 
	.. S ^DBTBL("SYSDEV",25,PROC)=$E(CODE(IDX),18,$L(CODE(IDX)))
	. I (IDX=SEQ1)&(CODE(IDX)="") Q					; fix carriage return 
	. I NOHEAD S ^DBTBL("SYSDEV",25,PROC,IDX)=CODE(IDX) Q 
	. S ^DBTBL("SYSDEV",25,PROC,IDX-1)=CODE(IDX)
	I NOHEAD D
	. S $P(HEADER,"|",3)=DATE,$P(HEADER,"|",4)=USER,$P(HEADER,"|",5)=TIME
	. S ^DBTBL("SYSDEV",25,PROC)=HEADER
	;
	S X=1
	I RTYPE=2 D 
	. K ^dbtbl("SYSDEV",25,PROC)
	. S SRC="^DBTBL(""SYSDEV"",25,"""_PROC_""")"
	. S X=$$CP^TBXDQUTL(SRC,"^dbtbl")
	; 
	; S ^TMPDQC($J,"SYSDEV",25,PROC)=""
	;
	; 09/27/2005. Check procedure type
	I (RTYPE=1)!(RTYPE=2) D
	. I $D(^TMPDQS($J,"phase1","procedure",FILE)) S ^TMPDQS($J,"phase1")=1
	. E  I $D(^TMPDQS($J,"phase2","procedure",FILE)) S ^TMPDQS($J,"phase2")=1
	. E  S ^TMPDQC($J,"SYSDEV",25,PROC)=""
	;
	Q:X=0 "0|Failed to update procedure "_PROC_" in dbtbl"
	Q 1
	;
	;-----------------------------------------------------------------------
EXTRACT(CODE,PROC);	Extract a procedure definition into an array 
	;-----------------------------------------------------------------------
	; ARGUMENTS:
	;	. CODE		Load a procedure definition into an array	/TYP=ARR				
	;	. PROC		Procedure definition				/TYP=T
	; RETURNS: 
	;       . $$            Success or failure 			/TYP=T
	;                       Success = 1 
	;			Failure returns
	;                         "0|"_$ZS 
	;-----------------------------------------------------------------------
	;
	N IDX,HEADER,SEQ,$ZT
	;
	S $ZT=$$SETZT^%ZT("ZTE^TBXPROC")
	;
	I '$D(^DBTBL("SYSDEV",25,PROC)) Q "0|Procedure definition does not exists"
	S HEADER=^DBTBL("SYSDEV",25,PROC)
	S $P(HEADER,"|",3)=""
	S $P(HEADER,"|",4)=""
	S $P(HEADER,"|",5)=""
	S CODE(1)="//DO NOT MODIFY  "_HEADER
	S SEQ="" F  S SEQ=$O(^DBTBL("SYSDEV",25,PROC,SEQ)) Q:SEQ=""  D 
	.       S CODE($O(CODE(""),-1)+1)=^DBTBL("SYSDEV",25,PROC,SEQ) 
	; 
	Q 1 
	;
	;-----------------------------------------------------------------------
OBSDQW(FILE);	Obsolete a procedure definition 
	;-----------------------------------------------------------------------
	; ARGUMENTS:				
	;	. FILE		Procedure definition to be obsoleted	/TYP=T
	; RETURNS: 
	;       . $$            Success or failure 		/TYP=T
	;                       Success = 1 
	;			Failure returns
	;                         "0|"_$ZS 
	;-----------------------------------------------------------------------
	;
	N PROCID
	;
	S PROCID=$P(FILE,".",1)
	S ^TMPDQC($J,"SYSDEV",25,PROCID)=-1
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
