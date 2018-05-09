DBSQA	;DBSQA;DBS - U - DATA-QWIK QA UTILITY
	;;Copyright(c)2003 Sanchez Computer Associates, Inc.  All Rights Reserved - 02/13/03 17:54:50 - RUSSELL
	;     ORIG:  BOB CHIANG (8447) - 06/01/88
	;     DESC:
	;
	; I18N=QUIT: Exculded from I18N standards. 
	;---- Revision History ------------------------------------------------
	; 01/13/03 - Dan Russell - 51351
	;	     Replace call to ^DBSEXESO with new ^DBSRWUTL.  Removed 
	;	     direct calls to ^CUVAR global.
	;
	;	     Modified calls to SYS^%FUNC to avoid TrackWare issues.
	;
	;	     Removed all code except INTEGRIT section.
	;
	;	     Removed old change history.
	;
	;-----------------------------------------------------------------------
	;
INTEGRIT	;
	N ZHDR,IO,RTNDIR,LINE,LIBS,OPT,DQOPT,ID,LASTSEQ,SEQ,name,opt
	K ^TMP($J)
	;
	I $G(%FN)="" S %FN="DBSQA"
	S IO=$I,%TAB("IO")=$$IO^SCATAB()
	S %TAB("RTNDIR")=".RTNDIR1"
	S RTNDIR=$$SCAU^%TRNLNM("CRTNS")	; *** 12/13/97
	S %READ="@@%FN,,IO/REQ,RTNDIR/REQ/PROT",%FRAME=2
	D ^UTLREAD I VFMQ="Q" Q
	;
	D OPEN^SCAIO U IO
	;
	S LINE="_" F I=1:1:76 S LINE=LINE_"_"
	S LIBS=""
	;
	S opt("S")=2,opt("R")=5,opt("Q")=6,opt("X")=16,opt("P")=18
	S name(1)="Filer",name(2)="Screen",name(3)="Executive",name(5)="Report"
	S name(6)="QWIK Report",name(16)="Data Exchange"
	S name(18)="Stored Procedure",name(22)="Aggregate",name(25)="Procedure"
	;
	S LIBS=%LIBS
	F opt=1,3,22,25,"S","R","Q","X","P" D INTEG
	W !!
	D CLOSE^SCAIO
	Q
INTEG	;
	S DQOPT=$S($D(opt(opt)):opt(opt),1:opt)		; DQ level
	S name=name(DQOPT)				; Description
	;
	S LASTSEQ=+$G(^DBTBL(LIBS,0,opt))		; Last Seq Assigned
	;
	W !!,LINE,!,?20,name
	;  
	I LASTSEQ W ?40,"Last Sequence Number Assigned ",LASTSEQ
	W !,LINE,!
	;
	S ID="" F  S ID=$O(^DBTBL(LIBS,DQOPT,ID)) Q:ID=""  D CHK,CHK1
	K ^TMP($J)
	Q
CHK	;
	I '$D(^DBTBL(LIBS,DQOPT,ID)) Q			;
	I DQOPT=1 S PGM=$P($G(^DBTBL(ID,99)),"|",2),DATE=$P($G(^(10)),"|",10) Q
	I DQOPT=3!(DQOPT=25) S PGM=$P(^(ID),"|",2),DATE=$P(^(ID),"|",3) Q
	I DQOPT=16 S PGM=$P(^(ID),"|",2),DATE=$P(^(ID),"|",4) Q
	I DQOPT=18 S PGM=$P(^(ID),"|",1),DATE=$P(^(ID),"|",6) Q
	I DQOPT=22 S PGM=$P(^(ID),"|",4),DATE="" Q
	; level 2,5,6 (screen,report,QWIK)
	S PGM=$P($G(^DBTBL(LIBS,DQOPT,ID,0)),"|",2),DATE=$P($G(^(0)),"|",3) Q
	Q
CHK1	;
	I PGM="",DQOPT=1 Q				; Filer name
	I "Zz"[$E(ID,1),PGM="" Q			; Backup - skipped
	I PGM="" D MSG5 Q
	S X=$$SCAU^%TRNLNM("CRTNS",PGM_".m") 
	S X=$ZSEARCH(X) I X="" D MSG4 Q
	;
	I DQOPT=18 S SEQ=$E(PGM,2,8)			; Stored procedure
	E  S SEQ=$E(PGM,5,8)
	I LASTSEQ,SEQ>LASTSEQ D MSG2			; Invalid sequence
	;
	I '$D(^TMP($J,PGM)) S ^TMP($J,PGM,ID)="" Q
	;
	S ^TMP($J,PGM,ID)=""				; Duplicate name
	;
	W ! S NAME="" F  S NAME=$O(^(NAME)) Q:NAME=""  D MSG3
	W !
	Q
	;
MSG	W !,?10,ID,?25,$$DAT^%ZM(DATE)
	Q
	;
MSG2	D MSG W ?37,PGM,?48,"Invalid Routine Sequence Number"
	Q
	;
MSG3	W !,?10,NAME,?25,$$DAT^%ZM(DATE),?37,PGM,?48,"Duplicate Routine Name"
	Q
	;
MSG4	D MSG W ?37,PGM,?48,"Invalid Routine Name"
	Q
	;
MSG5	D MSG W ?37,PGM,?48,"Missing Routine Name"
	Q
