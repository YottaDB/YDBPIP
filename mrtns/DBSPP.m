DBSPP	;DBSPP;DBS - U - V4.4 - SET UP DQ PRE/POST PROCESSOR LIBRARY
	;;Copyright(c)1996 Sanchez Computer Associates, Inc.  All Rights Reserved - 01/11/96 11:58:27 - CHIANG
	;     ORIG:  BOB CHIANG (8447) - 08/26/87
	;     DESC:  PRE/POST PROCESSOR DEFINITIONS
	;
        ; I18N=QUIT: Exculded from I18N standards.
	;---- Revision History ------------------------------------------------
	; 09/28/04 - RussellDS - CR12334
	;	     Replaced obsoleted calls to ^DBSANS1 with new procedure
	;	     DBSGETID.
	;
	;	     Added parameters to call to COPY^DBSUTL and DEL^DBSUTL.
	;
	; 01/11/96 - Bob Chiang - 17591
	;            Modified LIST section to add the missing QUIT command.
	;
	;-----------------------------------------------------------------------
CREATE	;
	S PID=$$FIND^DBSGETID("DBTBL13",1) Q:PID=""
	S %O=0 
        N SID S SID="DBTBL13"   ; *** XUS 08/09/94
        D ^USID I PGM="" Q
        D ^@PGM I VFMQ="Q" G CREATE
	;  D ^DBSPP9 I VFMQ="Q" G CREATE
	;
	S DBOPT=13,DQFUN="A",ID=PID D ^DBSUTL3 ; Create index file
	D FILE
	G CREATE
	;
MODIFY	;
	S PID=$$FIND^DBSGETID("DBTBL13",0) Q:PID=""
	; Implicit to 
	I $D(^DBTBL(%LIBS,13,PID,-3)) W !!,?20,"Implicit to ",^(-3) H 3 G MODIFY
	S %O=1
        N SID S SID="DBTBL13"   ; *** XUS 08/09/94
        D ^USID I PGM="" Q
        D ^@PGM I VFMQ="Q" G MODIFY
	;
	S DBOPT=13,DQFUN="D",ID=PID D ^DBSUTL3 ; Delete old index file
	;
	D FILE
	S DQFUN="A",ID=PID D ^DBSUTL3 ; Create index file
	;
	G MODIFY
	;
FILE	;
	S ^DBTBL(%LIBS,13,PID)=%A
	S $P(%A(0),"|",15)=$$USERNAM^%ZFUNC,$P(%A(0),"|",3)=+$H
	S MODFLG=+%A(0),$P(%A(0),"|",1)=0 ; MODIFY TEXT FLAG
	S ^(PID,0)=%A(0) ; USER ID & DATE
	;
	K %A(0),%A("PID") S OSEQ=$O(%A(""),-1)
	;
	; UPDATE DOCUMENTATION
	;
	D EDITOR
	;
	I $O(%A(""),-1)<1 X KVAR Q  ; ABORT
	;
	;
	;
	S LSEQ=$O(%A(""),-1) I OSEQ>LSEQ F I=LSEQ:1:OSEQ K ^DBTBL(%LIBS,13,PID,I)
	S SEQ=1 F I=1:1:LSEQ I %A(I)'="" S ^DBTBL(%LIBS,13,PID,SEQ)=%A(I),SEQ=SEQ+1
	X KVAR Q
	;
DELETE	;
	;
	D INIT,DEL^DBSUTL("DBTBL13") Q
	;
COPY	;
	;
	D INIT,COPY^DBSUTL("DBTBL13") Q
	;
LIST	;
	;
	D INIT
	N CNT,IO
	S CNT=$$LIST^DBSGETID("DBTBL13","List",.IO) Q:'CNT
	S %BLK="/,"_IO
	S RID="DBSPPLST" D DRV^URID     ; *** XUS 08/09/94
	Q				; *** 01/11/96
	;
INIT	;
	; PRE/POST PROCESSOR DEFINITION
	; ^DBSPP9
	S RN=$$^MSG("5182"),DBOPT=13
        ;
        N SID S SID="DBTBL13"   ; *** XUS 08/09/94
        D ^USID I PGM="" Q
        S DQSCR="^"_PGM
	Q
INDEX	; INDEX REPORT
	;
	;
	G NEWIDX
	;
%EXT	;
	I '$D(%LIBS) S %LIBS=^CUVAR("%LIBS")
	;
	;
NEWIDX	;
	;
	; REMOVE OLD INDEX INFORMATION
	;
	S PID=0 F I=1:1 S PID=$O(^DBTBL(%LIBS,13,PID)) Q:PID=""  K ^(PID,-2),^(-5),^(-1)
	;
	S ID=0,DBOPT=2
	W !!,"SCREEN",!
NSID	;
	S ID=$O(^DBTBL(%LIBS,2,ID)) I ID="" G RID
	S ON=0
	;
	; DATA ENTRY PRE/POST PROCESSOR
	;
	S X=0 F I=1:1 S X=$O(^DBTBL(%LIBS,2,ID,0,X)) Q:X=""  S P=^(X) D CHK
	S SEQ=0
NSEQ	;
	S SEQ=$O(^DBTBL(%LIBS,2,ID,SEQ)) I SEQ="" G NSID
	S PP=0
NPP	;
	S PP=$O(^DBTBL(%LIBS,2,ID,SEQ,PP)) I PP="" G NSEQ
	S P=^(PP)
	D CHK G NPP
	;
CHK	;
	;
	; ============ D @[PPLIB]    D @[PPLIB]/NQ   D @[PPLIB] ;
	;
	S XP=P
	; D @[
	; D @[
	I P["D @[",P?.E1"D @["1E.E1"]".E S P=$P(P,"@[",2),P=$P(P,"]",1) D SET Q
	I P?." "1"@"1A.AN!(P?." "1"@"1A.AN1"_"1A.AN) S P=$P(P,"@",2) D SET Q
	;I P?.E.1"@["1A.ANP1"]" S P=$P(P,"[",2),P=$P(P,"]",1) D SET Q
	Q
	;
SET	;
	;
	I 'ON W !!,ID,?15 S ON=1
	W XP,$J("",10-$L(XP))
	I $D(^DBTBL(%LIBS,13,P)) S ^DBTBL(%LIBS,13,P,-DBOPT,ID)=""
	;  Invalid pre/post-processor name 
	E  W ?40,$$^MSG("5179"),!,?15
	Q
	;
	;
	; CHECK REPORT REFERENCE
	;
RID	;
	W !!,"REPORT",!!
	S ID=0,DBOPT=5
	;
NRID	;
	S ID=$O(^DBTBL(%LIBS,5,ID)) I ID="" Q
	S ON=0
	;
	; REPORT PRE/POST/DOCUMENTATION SECTION
	;
	S X=50 F I=1:1 S X=$O(^DBTBL(%LIBS,5,ID,X)) Q:X=""!(X'?1N.N)  S P=^(X) D CHK
	;
	; DATA ITEM PRE/POST PROCESSOR
	;
	S KEYS=" "
NRIDK	;
	S KEYS=$O(^DBTBL(%LIBS,5,ID,KEYS)) I KEYS="" G NRID
	S SEQ=""
	S SEQ=100
NRIDS1	;
	S SEQ=$O(^DBTBL(%LIBS,5,ID,KEYS,SEQ)) I SEQ="" G NRIDK
	;
	S I=0 F X=1:1 S I=$O(^DBTBL(%LIBS,5,ID,KEYS,SEQ,I)) Q:I=""  S P=^(I) D CHK
	;
	;
	G NRIDS1
	;
	;
EDITOR	;
	;
	;
	; ~p1- Pre/Post Proc Lib
	S MESSAGE=$$^MSG("5184",PID)
	D ^DBSWRITE("%A",3,22,99999,"",MESSAGE)
	;
	Q
