TBXBATCH	;Private; DATA QWIK Batch Definition handler
	;;Copyright(c)2002 Sanchez Computer Associates, Inc.  All Rights Reserved - 04/04/02 12:29:59 - CHEUNGA
	; ORIG:	JOYCEJ - 10/01/01
	; DESC:	
	;
	;---- Revision History -------------------------------------------------
	; 01/24/2005	KWANL
	;		Change PACKTYPE to MRPC in SAVEOBJ
	;
	;
	;	Jim Joyce - 11/11/2003
	;	Replaced BATCHID with BCHID in section EXTRACT to resolve 
	;	undefined error.
	;
	;-----------------------------------------------------------------------
GETCODE(BCHID,CODE,FILENAME)	; Get object contents
	;-----------------------------------------------------------------------
	;
	I $G(BCHID)="" Q 0_$C(13,10)_$$^MSG(741)
	;
	S FILENAME=BCHID_".BATCH"
	Q $$EXTRACT(.CODE,BCHID)
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
	I '$D(^DBTBL(%LIBS,33,OBJECTID)) D  Q MESSAGE
	.	S MESSAGE=1_$C(13,10)_"Create new Batch Definition in "_CONAME
	;
	; Batch Definition exists, return user and date modified
	S HEADER=^DBTBL(%LIBS,33,OBJECTID)
	S USER=$P(HEADER,"|",4)
	S DATE=$$^%ZD($P(HEADER,"|",3))
	S TIME=$$TIME^%ZD($P(HEADER,"|",5))
	;
	S MESSAGE="Update Batch Definition: "_OBJECTID_" Modified by "_USER
	S MESSAGE=MESSAGE_" on "_DATE_" at "_TIME_" in "_CONAME
	;
	Q 1_$C(13,10)_MESSAGE
	;
	;-----------------------------------------------------------------------
SAVEOBJ(TOK,BCHID,USER)	; Save Batch Def sent by client
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
	S FILENAME=BCHID_".BATCH"
	Q $$LOAD(.CODE,FILENAME,3,USER,+$H,$P($H,",",2))
	;
	;-----------------------------------------------------------------------
save(buf)	; SAVE BUFFER
	;-----------------------------------------------------------------------
	;
	N i,seq,sec,tag,x,j
	F sec="REVHIST","OPEN","SCHINIT","SCHEXEC","SCHPOST","SCHEXIT","THRINIT","THREXEC","EXEC","THREXIT" K ^DBTBL(%LIBS,33,BCHID,sec)
	K sec
	S i="",j="" F  S i=$O(buf(i)) Q:i=""  D
	.	S x=buf(i)
	.	I $E(x,1,11)="---------- " S tag=$E(x,12,20),tag=$P(tag," ",1) I tag'="" S sec=tag,seq=1,j=0 Q  ; Section name
	.	I x'="" S j=1
	.	I 'j,x="" Q				; Remove blank lines
	.	I '$D(sec) Q
	.	S ^DBTBL(%LIBS,33,BCHID,sec,seq)=x,seq=seq+1
	Q
	;
	;----------------------------------------------------------------------- 
CHECK(FILE,RUSER,RDATE,RTIME);	Compare date stamp between ^DBTBL and ^dbtbl 
	;----------------------------------------------------------------------- 
	; ARGUMENTS: 
	;       . FILE          RMS file name           /TYP=T 
	;	. RUSER		Released file last modified user 		
	;	. RDATE		Released file last modified date
	; 	. RTIME		Released file last modified time
	; RETURNS: 
	;       . $$            Match or Failure        /TYP=T 
	;                       Match = 1 
	;                       Failure returns 
	;                         "0|Date Stamp Mistmatch" 
	; 
	;----------------------------------------------------------------------- 
	; 
	N BATCHID,CDATE,CUSER,DDATE,DUSER
	S BATCHID=$P(FILE,".",1)
	S CDATE=$P($G(^DBTBL("SYSDEV",33,BATCHID)),"|",3)
	S CUSER=$P($G(^DBTBL("SYSDEV",33,BATCHID)),"|",4)
	S DDATE=$P($G(^dbtbl("SYSDEV",33,BATCHID)),"|",3)
	S DUSER=$P($G(^dbtbl("SYSDEV",33,BATCHID)),"|",4)
	;
	Q $$CKDTUSR^TBXDQUTL(DDATE,DUSER,CDATE,CUSER,RDATE,RUSER)
	;
	;-----------------------------------------------------------------------
LOAD(CODE,FILE,RTYPE,USER,DATE,TIME)	; Load a Batch definition 
	;----------------------------------------------------------------------- 
	; ARGUMENTS: 
	;	. CODE	      Array contains the contents of the file 
	;       . FILE        File name excluding 
	;       . USER        Last modified user     /TYP=T 
	;       . DATE        Last modified date     /TYP=N 
	;       . TIME        Last modified time     /TYP=N 
	;       . RTYPE       Release type 
	;                     1: Fix Pack 
	;                     2: Service Pack 
	;		      3: MRPC
	; RETURNS: 
	;       . $$            Success or failure      /TYP=T 
	;                       Success = 1 
	;                       Failure returns 
	;			  "0|Failed to update global"
	;----------------------------------------------------------------------- 
	; 
	N $ZT,BCHID,EXT,SEQ,TMPSTR,HEADER,X,%LIBS,SRC,NOHEAD
	S %LIBS="SYSDEV"
	S $ZT=$$SETZT^%ZT("ZTL^TBXBATCH")
	; 
	S BCHID=$P(FILE,".",1),EXT=$P(FILE,".",2)
	;
	S NOHEAD=0
	I CODE(1)'["//DO NOT MODIFY" D
	. S HEADER=$G(^DBTBL("SYSDEV",33,BCHID))
	. S NOHEAD=1
	; 
	I 'NOHEAD S HEADER=$E(CODE(1),18,$L(CODE(1))) 
	;
	S $P(HEADER,"|",3)=DATE
	S $P(HEADER,"|",4)=USER 
	S $P(HEADER,"|",5)=TIME 
	;
	S ^DBTBL("SYSDEV",33,BCHID)=HEADER
	;
	D save(.CODE)
	;
	S X=1
	I RTYPE=2 D
	. K ^dbtbl("SYSDEV",33,BCHID)
	. S SRC="^DBTBL(""SYSDEV"",33,"""_BCHID_""")"
	. S X=$$CP^TBXDQUTL(SRC,"^dbtbl") 
	I (RTYPE=1)!(RTYPE=2) S ^TMPDQC($J,"SYSDEV",33,BCHID)="" 			; Update ^dbtbl
	Q:X=0 "0|"_BCHID_" failed to update ^dbtbl"
	Q 1         
	;
	;-----------------------------------------------------------------------
EXTRACT(CODE,BCHID)	; Extract an aggregate definition 
	;----------------------------------------------------------------------- 
	; ARGUMENTS: 
	;	. CODE	      Array contains the contents of the file 
	;	. ARGID	      	
	; RETURNS: 
	;       . $$            Success or failure      /TYP=T 
	;                       Success = 1 
	;                       Failure returns 
	;                         "0|Batch definition "_ARGID_" does not exist" 
	;----------------------------------------------------------------------- 
	; 
	I '$D(^DBTBL("SYSDEV",33,BCHID)) Q "0|Batch definition "_BCHID_" does not exist" 
	; 
	N $ZT,HEADER,i,j,sec,seq,x,%LIBS
	S $ZT=$$SETZT^%ZT("ZTE^TBXBATCH")
	;
	S HEADER=^DBTBL("SYSDEV",33,BCHID)
	S $P(HEADER,"|",3)="" 
	S $P(HEADER,"|",4)="" 
	S $P(HEADER,"|",5)="" 
	S CODE(1)="//DO NOT MODIFY  "_HEADER 
	S %LIBS="SYSDEV"
	F sec="REVHIST","OPEN","SCHINIT","SCHEXEC","SCHPOST" D load 
	F sec="SCHEXIT","THRINIT","THREXEC","EXEC","THREXIT" D load 
	; 
	Q 1 
	; 
	;-----------------------------------------------------------------------
load	; Load section of batch into code array
	;-----------------------------------------------------------------------
	S CODE($O(CODE(""),-1)+1)="---------- "_sec_$J("",8-$L(sec))_"------ Section marker"
	S CODE($O(CODE(""),-1)+1)=""
	S i="" F  S i=$O(^DBTBL(%LIBS,33,BCHID,sec,i)) Q:i=""  D
	.	S CODE($O(CODE(""),-1)+1)=^DBTBL(%LIBS,33,BCHID,sec,i)
	Q
	;
	;-----------------------------------------------------------------------	
OBSDQW(FILE);	Obsolete a batch definition 
	;-----------------------------------------------------------------------
	;
	N BATCH
	S BATCH=$P(FILE,".",1)
	S ^TMPDQC($J,"SYSDEV",33,BATCH)=-1
	;
	Q 1
	;
	;----------------------------------------------------------------------
ZTL()	; Error trap for load 
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
