FORMDQ5C	; V 5.0
	;;Copyright(c)2003 Sanchez Computer Associates, Inc.  All Rights Reserved - 02/13/03 11:38:52 - RUSSELL
	;     ORIG:  CHIANG - 09/29/89
	;     DESC:  OOE RW functions
	;
	; I18N=QUIT	Excluded from I18N Standards
	; ---------- Revision History ------------------------------------------
	; 12/14/05 - RussellDS - CR18400
	;	     Remove obsolete call to MPLCT^DBSDI.
	;
	;	     Remove old revision history.
	;
	;-----------------------------------------------------------------------
	;
DEF(OP)	;
	;
	N %O,%READ,%TAB,FID,LIB,LIBS,OLNTB,VFMQ,I,RM,ZB,ZZII
	;
	K ER,RM
	S OP(1)="Control_Page|CTL^FORMDQ5C"
	S OP(2)="Order_By_Page|SEQPAG^FORMDQ5C"
	S OP(3)="Prompts/Query|QUERY^DBSRWDRV"
	S OP(4)="Statistics|STAT^DBSRWDRV"
	S OP(5)="User_Routines|KEYS^DBSRWDRV"
	;
	; Control_Paqe,Order_By_Page,Prompts/Query,Statistics,User_Routines|<<$G(OP)>>
	;
	S OP=$$^DBSMBAR(108)	; *** BC - menu option 106 - 10/25/93
	;
	I 'OP W:OP'="" $$MSG^FORM(OP) Q
	;
	S LIBS=%LIBS
	S %O=1,PIO=$I
	;
	D @$P(OP(OP),"|",2) I '$G(OP) Q
	D RESET
	Q
RESET	;
	D TRMSET^FORMINIT
	;
	I $G(RHTMAR)="" S RHTMAR=$P(^DBTBL(%LIBS,5,RID,0),"|",5)
	I RHTMAR>80 D CI^FORMINIT Q
	E  D CO^FORMINIT
	Q
CTL	;
	S %O=1,LIBS=%LIBS
        ; *** XUS 08/10/94 
        N OLDSID,OLDPGM S OLDSID=$G(SID),OLDPGM=$G(PGM) 
        S SID="DBTBL5H" 
        D ^USID I PGM="" Q 
        S SID=OLDSID 
        D ^@PGM 
        S PGM=OLDPGM 
	;
	I VFMQ="Q" Q
	;
	S Z=$P($G(^DBTBL(%LIBS,5,RID,0)),"|",1)
	S ^DBTBL(%LIBS,5,RID,0)=%A(0),FILES=$P(%A(0),"|",1)
	;
	S ^DBTBL(%LIBS,5,RID)=%A
	;
	; Any changes to ACCESS FILES ?
	;
	I FILES=Z Q
	;
	; Display SEQBY page
	;
	D SEQPAG
	;
	Q
	;
SEQPAG	;
	S FILES=$P(^DBTBL(%LIBS,5,RID,0),"|",1)
	I $G(SEQBY)'="" G SEQPAG1
	;
	S (PFID,FID)=$P(FILES,",",1)
	;
	S DLIB=%LIBS,DFID=$P(FILES,",",1),LIB=DLIB,FID=DFID
	S SEQBY="" F IX=1:1:10 Q:$G(^DBTBL(LIB,1,FID,IX))=""  S SEQBY=SEQBY_"["_%LIBS_","_FID_"]"_^(IX)_"|"
	S SEQBY=$E(SEQBY,1,$L(SEQBY)-1)
	;
SEQPAG1	;
	;
        ; *** XUS 08/10/94 
        N OLDSID,OLDPGM S OLDSID=$G(SID),OLDPGM=$G(PGM) 
        S SID="DBTBL5H1" 
        D ^USID I PGM="" Q 
        S SID=OLDSID 
        D ^@PGM 
        S PGM=OLDPGM 
	I VFMQ="Q" Q
	S ^DBTBL(%LIBS,5,RID,0)=%A(0)	; *** BC - Control page information
	S Z=1
	F I=1:1:10 K ^DBTBL(%LIBS,5,RID,I) I $P($G(%A(I)),"|",1)'="" S ^(Z)=%A(I),Z=Z+1
	;
	; Integrity checker
	;
	N ZSEQ,X,Y,Z,FL,FILES
	;
	; Access Files
	;
	S FILES=$P(^DBTBL(%LIBS,5,RID,0),"|",1)
	F I=1:1 S X=$P(FILES,",",I) Q:X=""  S FL(X)=""
	;
	; Sequency_By information
	;
	F I=1:1:10 S X=$P($G(^DBTBL(%LIBS,5,RID,I)),"|",1) Q:X=""  S ZSEQ("["_($P(X,",",2)))=""
	;
	; Remove invalid report section marker
	;
	S X="",Y=""
	F  S Y=$O(D(Y)) Q:Y=""  F  S X=$O(D(Y,X)) Q:X=""  D MRKCHK
	;
	; ---------- *** BC - 12/23/93 - Reset marker information after any
	;                                ORDERBY changes
	D FILE				; Save current layout to disk
	K M,D
	D LOAD^FORMDQ5(RID)		; Load definition
	Q
	;
MRKCHK	;
	S Z=$P(D(Y,X),$C(0),1),Z1=Z
	I Z'["[" Q
	;
	I $E(Z)'="#" G MRKCHK1
	;
	S Z=$P($E(Z,2,99),"-",1)
	;
	I '$D(ZSEQ(Z)) K D(Y,X),M(Y,X)
	Q
MRKCHK1	;
	S Z=$E($P(Z,"]",1),2,99)
	I Z="" Q
	I Z["," S Z=$P(Z,",",2) ; Remove library reference
	I '$D(FL(Z)) W $$MSG^FORM("Invalid data item - "_Z1,1)		; *** BC - 11/02/93
	;	
	Q
	;
QL(INPUT,OPTION)	;
	N %TAB,OLNTB,%READ,ITEMS,ZZII,Y,X,FF,FID,FILE,LIB,RM,ZB,KEY,SEQ,TAPEOPT,QBOPT
	;
	U 0 S PIO=$I,INPUT=$G(INPUT)
	S X=$O(^DBTBL(%LIBS,5,RID,11),-1),GRP=$P(^(X),"|",1)
	S FILES=$P(^(0),"|",1)
	;
	K ^DBTMP($I)
	;
	; "Report,Label/Notice,Fixed_Length"
	S OPTION=$$^DBSMBAR(111) I 'OPTION Q	; *** BC - menu option 111 - 10/25/93
	;
	I $G(INPUT)="" S INPUT=$$^FORMREAD("",60,FILES_": ","U") I INPUT="" Q
	;
	W CLSCREEN
	;
	S QBOPT=1 I OPTION>1 S QBOPT=0
	S TAPEFMT=0 I OPTION=3 S TAPEFMT=1
	;
	I OPTION'=2 G QL0
	I INPUT["#" G QL0
	;
	; Insert LF between each item
	;
	S X="",ZC=$L(INPUT,",") F I=1:1:ZC S X=X_$P(INPUT,",",I)_",#,"
	S INPUT=$E(X,1,$L(X)-3)
	;
QL0	;
	D QL^DBSEXE2E(INPUT,QBOPT,TAPEFMT)
	;
	S SEQ=999999
QL1	;
	S SEQ=$O(^DBTBL(%LIBS,5,RID,SEQ)) I SEQ="" G QL2
	I SEQ'?1N.N K ^(SEQ)
	G QL1
	;
	; ========== Copy into report definition
QL2	;
	S KEY="",SEQ=""
	;
QL3	;
	S KEY=$O(^DBTMP(PIO,KEY)) I KEY="" G QL5
QL4	;
	S SEQ=$O(^DBTMP(PIO,KEY,SEQ)) I SEQ="" G QL3
	S X=^(SEQ) I $P(X,"|",2)="@ch" D QL6
	S ^DBTBL(%LIBS,5,RID,KEY,SEQ)=X
	G QL4
	;
QL5	;
	;
	K D,M
	D LOAD^FORMDQ5(RID),PUTRGN^FORMFUN()
	D RESET^FORMDQ5D
	Q
	;
QL6	;
	;
	S T=$P(X,"|",7) F I=1:1 Q:$E(T,I)'=" "
	S T=$E(T,I,999)
	F J=$L(T):-1:1 I $E(T,J)'=" " Q
	S T=$E(T,1,J)
	S $P(X,"|",3)=$L(T)
	S $P(X,"|",1)=X+I-1
	S $P(X,"|",7)=T
	Q
	Q
FUNC(OP)	;
	S OP(1)="Save|SAVE^FORMDQ5C"
	S OP(2)="Compile|COMPILE^FORMDQ5C(RID),RESET^FORMDQ5C"
	S OP(3)="Run|RUN^FORMDQ5C(RID)"
	S OP(4)="Execute|EXECUTE^FORMDQ5C(RID)"		; 05/04/93 BC
	S OP(5)="Print|PRINT^FORMDQ5C(RID)"
	S OP(6)="List|LIST^FORMDQ5C(RID)"
	S OP(7)="OOE_Exit|EXIT^FORMDQ5C"
	S OP(8)="Import Data|IMPORT^FORMEXCH()"
	S OP(9)="Export Data|EXPORT^FORMEXCH()"
	;
	S OP=$$^DBSMBAR(109) I 'OP Q	; *** - BC - menu 109 - 10/25/93
	;
	D @$P(OP(OP),"|",2)
	Q
	;
BACKUP	;
	D FILE
	;
	Q
SAVE	;
	I $$SAVE^FORMDQ5()
	Q
RUN(RID)	; Run a report from the editor
	;
	;
	D FILE
	N %O,KEY,ZB,ZZII,CMMD,zzRID,PGM,IO,TJD
	;
	;
	S XLIB=%LIBS I $D(^DBTBL(%LIBS,5,RID,-3)) S XLIB=^(-3)
	S RN=^DBTBL(XLIB,5,RID),PGM=$P(^(RID,0),"|",2)
	I '$D(CONAM) S CONAM=$$^CUVAR("CONAM")
	I PGM'="",$$VALID^%ZRTNS(PGM)
	E  D COMPILE(RID)
	;
	I $G(TJD)="" S TJD=$$^CUVAR("TJD")
	;
	D RUN1,RESET
	Q
RUN1	;
	N D,M,DBTBL5,PP,cmmd,key,FILES		; Save OOE internal variables
	;
	D ^@PGM
	;
	Q
COMPILE(RID)	; ---------- Compile Report ----------
	;
	D IOF,FILE,COMPILE1,MSG
	;
	Q
COMPILE1	;
	;
	;
	N (RID,%LIBS)
	D ^DBSRW(RID)
	;
	Q
	;
EXECUTE(RID)	; ---------- Compile and Run ----------   05/04/93 BC
	;
	D COMPILE(RID) I $G(ER) Q
	D RUN(RID)
	Q
	;
PRINT(RID)	;
	;
	D IOSEL I ER Q
	D IMAGE^FORMPNT
	Q
	;
LIST(RID)	;
	D FILE
	;
	K ^TEMP($J) S ^TEMP($J,RID)=""
	N SAVIO,RID,LIBS,%BLK,PGM,IO
	D IOSEL I ER Q
	;
	S RID="DBSRPTLST" D ^URID I PGM="" Q
	S %BLK="/,"_IO D ^@PGM
	;
	D MSG
	I SAVIO'="" Q
	D RESET
	Q
IOSEL	;
	; REPORT DEFINITION
	S RN="REPORT DEFINITION"
	S IOHDG="^SCAV100"
	I '$D(CONAM) S CONAM=$$^CUVAR("CONAM")
	I '$D(%TIM) S %TIM=$$TIM^%ZM		; 
	I '$D(%ED) S %ED=$$DAT^%ZM(+$H)		; 02/23/99 BC
	;
	U 0 S IO=$$^FORMREAD("",60,"Device: ","U") S SAVIO=IO
	I IO="" S IO=$I W IO W $$REGION^FORMINIT,CLSCREEN
	;
	S ER=0,QUIT=0 S POP=IO D ^SCAIO
	I ER W $$MSG^FORM("Cannot open "_IO) Q		; *** BC - 11/02/93
	;
	Q
	;
MSG	;
	W $$MSG^FORM("Done",1)			; *** BC - 11/02/93
	Q
EXIT	;
	I $$SAVE^FORMDQ5("1")<1 S ZB=13 L  Q	; *** - BC - Exit message 10/25/93
	S ZPGM=$P(^DBTBL(%LIBS,5,RID,0),"|",2)
	S OPGM=$P(^DBTBL(%LIBS,5,$E(RID,2,99),0),"|",2)
	K ^DBTBL(%LIBS,5,RID) ; Delete the temporary copy
	I ZPGM'="",ZPGM'=OPGM D DEL^%ZRTNDEL(ZPGM) ; Delete V program
	;
	L
	S ZB="" Q
	Q
FILE	;
	K DBTBL5
	;
	N N,Z
	;
	S N="" 
	F  S N=$O(^DBTBL(%LIBS,5,RID,N)) Q:N=""  S:$D(^(N))#10 DBTBL5(N)=^(N) D FILE1
	;
	S DBTBL5=^DBTBL(%LIBS,5,RID)
	;
	D ^FORMDQ5A
	Q
FILE1	;
	S Z=""
	F  S Z=$O(^DBTBL(%LIBS,5,RID,N,Z)) Q:Z=""!(Z>99)  D FILE2
	Q
FILE2	;
	; RF,SL,SF
	;
	I Z=25!(Z=26)!(Z=27) Q
	S DBTBL5(N,Z)=^(Z)
	Q
IOF	W CLSCREEN,CSI_"1;1H" Q
	
