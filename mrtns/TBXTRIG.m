TBXTRIG	;Private; DATA QWIK Procedure handler
	;;Copyright(c)2002 Sanchez Computer Associates, Inc.  All Rights Reserved - 05/07/02 17:12:31 - KWANL
	; ORIG:	JOYCEJ - 10/01/01
	; DESC:	
	;
	;-----------------------------------------------------------------------
	; Revision History:
	; 01/24/2005	KWANL
	;		Change PACKTYPE to MRPC in SAVEOBJ
	;
	; 11/17/2005	KWANL
	;		Replaced reference to ^CUVAR with $$SCAU^%TRNLNM("DDPLOG")
	;	
	; 10/17/2002	Lik Kwan
	;		Clean up EXTRACT section.
	;
	;-----------------------------------------------------------------------
GETCODE(OBJECTID,CODE,FILENAME)	
	;-----------------------------------------------------------------------
	;
	N TRIGID,FID
	;
	I $G(OBJECTID)="" Q 0_$C(13,10)_$$^MSG(741)
	;
	S FID=$P(OBJECTID,"-",1),TRIGID=$P(OBJECTID,"-",2,9999)	
	;
	S FILENAME=FID_"-"_TRIGID_".TRIG"
	;
	Q $$EXTRACT(.CODE,FID,TRIGID)
	; 
	;-----------------------------------------------------------------------
CHECKOBJ(TOK,OBJECTID)	
	;-----------------------------------------------------------------------
	;
	N HEADER,USER,DATE,TIME,END,MESSAGE,FID,TRIGID
	;
	; S CONAME=$$^CUVAR("CONAM")
	S CONAME=$$SCAU^%TRNLNM("DDPLOG")
	;
	S FID=$P(OBJECTID,"-",1)
	S TRIGID=$P(OBJECTID,"-",2)
	;
	S END=$O(^TMP(TOK,""),-1)
	I END="" Q 0_$C(13,10)_"Missing source code"
	;
	I '$D(^DBTBL(%LIBS,7,FID,TRIGID)) D  Q MESSAGE
	.       S MESSAGE=1_$C(13,10)_"Create new Trigger in "_CONAME
	;
	; Procedure exists, return user and date modified
	S HEADER=^DBTBL(%LIBS,7,FID,TRIGID)
	S DATE=$$^%ZD($P(HEADER,"|",9))
	S USER=$P(HEADER,"|",10)
	S TIME=$$TIME^%ZD($P(HEADER,"|",11))
	;
	S MESSAGE="Update Trigger: "_FID_"-"_TRIGID_" Modified by "_USER
	S MESSAGE=MESSAGE_" on "_DATE_" at "_TIME_" in "_CONAME
	;
	Q 1_$C(13,10)_MESSAGE
	;
	;-----------------------------------------------------------------------
SAVEOBJ(TOK,OBJECTID,USER)	
	;-----------------------------------------------------------------------
	;
	N CODE,SEQ,FILENAME
	;
	S FID=$P(OBJECTID,"-",1)
	S TRIGID=$P(OBJECTID,"-",2)
	;
	S FILENAME=FID_"-"_TRIGID_".TRIG"
	;
	; Load from buffer into CODE ARRAY
	S SEQ="" F  S SEQ=$O(^TMP(TOK,SEQ)) Q:SEQ=""  S CODE(SEQ)=^TMP(TOK,SEQ)
	;
	K ^TMP(TOK)
	;
	Q $$LOAD(.CODE,FILENAME,3,USER,+$H,$P($H," ",2))
	;
	;-----------------------------------------------------------------------
CHECK(FILE,RUSER,RDATE,RTIME);	Check date stamp between ^DBTBL and ^dbtbl. 
	; If match return 1, 0 otherwise
	;-----------------------------------------------------------------------
	;
	N ELM,TRIG,CDATE,CUSER,DDATE
	S ELM=$P(FILE,"-",1),TRIG=$P($P(FILE,".",1),"-",2)
	S CDATE=$P($G(^DBTBL("SYSDEV",7,ELM,TRIG)),%,9)		; ^DBTBL date stamp
	S CUSER=$P($G(^DBTBL("SYSDEV",7,ELM,TRIG)),%,10)	
	S DDATE=$P($G(^dbtbl("SYSDEV",7,ELM,TRIG)),%,9)		; ^dbtbl date stamp
	S DUSER=$P($G(^dbtbl("SYSDEV",7,ELM,TRIG)),%,10)
	;
	Q $$CKDTUSR^TBXDQUTL(DDATE,DUSER,CDATE,CUSER,RDATE,RUSER)
	;
	;-----------------------------------------------------------------------
LOAD(CODE,FILE,RTYPE,USER,DATE,TIME);	Load a trigger 
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
	; RETURNS: 
	;       . $$          Success or failure      /TYP=T 
	;                       Success = 1 
	;                       Failure returns 
	;                         "0|Unable to open DEVICE" 
	; 
	;----------------------------------------------------------------------- 
	;
	N FID,TRIG,SEQ,$ZT,SRC,X,DESC,HEADER,NOHEAD,SEQ1
	S $ZT=$$SETZT^%ZT("ZTL^TBXTRIG")
	;
	S FID=$P(FILE,"-",1),TRIG=$P($P(FILE,".",1),"-",2,9999)
	;
	S HEADER=$G(^DBTBL("SYSDEV",7,FID,TRIG))
	K ^DBTBL("SYSDEV",7,FID,TRIG)
	;
	S NOHEAD=0,SEQ1=$O(CODE(""),-1)
	; update ^DBTBL and insert last modified info into the header
	S SEQ="" F  S SEQ=$O(CODE(SEQ)) Q:SEQ=""  D
	. I SEQ=1 D  Q
	.. I CODE(1)'["//DO NOT MODIFY" D  Q
	... S NOHEAD=1						; header is not found
	... S ^DBTBL("SYSDEV",7,FID,TRIG,SEQ)=CODE(SEQ)
	.. S $P(CODE(SEQ),"|",1)=$E(CODE(SEQ),18,$L($P(CODE(SEQ),"|",1)))
	.. S $P(CODE(SEQ),"|",9)=DATE,$P(CODE(SEQ),"|",10)=USER,$P(CODE(SEQ),"|",11)=TIME_$C(34)
	.. S ^DBTBL("SYSDEV",7,FID,TRIG)=CODE(SEQ)
	. I (SEQ=SEQ1)&(CODE(SEQ)="") Q
	. I NOHEAD S ^DBTBL("SYSDEV",7,FID,TRIG,SEQ)=CODE(SEQ) Q
	. S ^DBTBL("SYSDEV",7,FID,TRIG,SEQ-1)=CODE(SEQ)
	;
	I NOHEAD D
	. S $P(HEADER,"|",9)=DATE,$P(HEADER,"|",10)=USER,$P(HEADER,"|",11)=TIME_$C(34)
	. S ^DBTBL("SYSDEV",7,FID,TRIG)=HEADER
	;
	S X=1
	;
	; if service pack, udpate ^dbtbl
	I RTYPE=2 D
	. K ^dbtbl("SYSDEV",7,FID,TRIG)
	. S SRC="^DBTBL(""SYSDEV"",7,"""_FID_""","""_TRIG_""")"
	. S X=$$CP^TBXDQUTL(SRC,"^dbtbl")
	Q:X=0 "0|Failed to update trigger "_FID_"."_TRIG_" in ^dbtbl" 
	;
	; setup for DQ compile
	I (RTYPE=1)!(RTYPE=2) S ^TMPDQC($J,"SYSDEV",7,FID_"."_TRIG)=""
	Q 1
	;
	;-----------------------------------------------------------------------
EXTRACT(CODE,FID,TRIG)	; Extract a trigger definition 
	;-----------------------------------------------------------------------
	; ARGUMENTS: 
	;	. CODE		Load a trigger definition into array CODE	/TYP=ARR	
	;	. FID		Trigger file				        /TYP=T
	;       . TRIG 	Trigger						/TYP=N
	; RETURNS: 
	;       . $$ 	Success or failure      			/TYP=T
	;                       Success = 1 
	;                       Failure returns 
	;			  "0|"_$ZS
	;----------------------------------------------------------------------- 
	;
	N INDX,$ZT,HEADER,SEQ
	S $ZT=$$SETZT^%ZT("ZTE^TBXTRIG")
	;
	I '$D(^DBTBL("SYSDEV",7,FID,TRIG)) Q "0|Trigger "_FID_"."_TRIG_" does not exists"
	S HEADER=^DBTBL("SYSDEV",7,FID,TRIG)
	S $P(HEADER,"|",9)="" 
	S $P(HEADER,"|",10)="" 
	S $P(HEADER,"|",11)="" 
	S CODE(1)="//DO NOT MODIFY  "_HEADER
	S SEQ="" F  S SEQ=$O(^DBTBL("SYSDEV",7,FID,TRIG,SEQ)) Q:SEQ=""  D 
	. S CODE($O(CODE(""),-1)+1)=^DBTBL("SYSDEV",7,FID,TRIG,SEQ)  
	; 
	Q 1 
	;-----------------------------------------------------------------------
OBSDQW(FILE);	Obsolete a trigger definition 
	;-----------------------------------------------------------------------
	; ARGUMENTS: 
	;	. FILE		Trigger to be obsoleted		/TYP=ARR	
	; RETURNS: 
	;       . $$ 	Success or failure      	/TYP=T
	;                       Success = 1 
	;                       Failure returns 
	;			  "0|"_$ZS
	;----------------------------------------------------------------------- 
	;
	N NAME,FID,TRIGGER
	;
	S NAME=$P(FILE,".",1)
	S FID=$P(NAME,"-",1),TRIGGER=$P(NAME,"-",2,99999)
	;
	K ^DBTBL("SYSDEV",7,FID,TRIGGER)
	K ^dbtbl("SYSDEV",7,FID,TRIGGER)
	;
	S ^TMPDQC($J,"SYSDEV",7,FID)=""
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
