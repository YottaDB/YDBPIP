DBSDOC1	;;DBS -  DATA ENTRY SCREEN DOCUMENTATION
	;;Copyright(c)2000 Sanchez Computer Associates, Inc.  All Rights Reserved - 05/15/00 16:03:43 - DOUGANM
	;     ORIG:  CHIANG - 11/1/85
	;     DESC:  DATA QWIK SCREEN DOCUMENTATIONS
	;
        ;  I18N=QUIT: Excluded from I18N standards
	;
	;---------- Revision History -------------------------------------------
	; 09/28/04 - RussellDS - CR12334
	;	     Replaced obsoleted calls to ^DBSANS with new procedure
	;	     DBSGETID.
	;
        ; 05/12/00 - DOUGANM- 39582
        ;            To improve the performance of error handling, cleaned up
        ;            call to $$NEW^%ZT, and removed use of indirection.
	;	     Replaced $ZP reference with $O(^gbl(...),-1) syntax.
	;-----------------------------------------------------------------------
START	;
	K IO
	N CNT
	S CNT=$$LIST^DBSGETID("DBTBL2") Q:'CNT
	;
DOC	;
	;
	W !!,"How Many Copies? 1=>" R XCOPY I XCOPY<1 S XCOPY=1
	W !!,"    Left Margin: 1=>" R TAB S TAB=TAB+0
	S DLIB=%LIBS
	S SID=0 F XYZ=1:1 S SID=$O(^TEMP($J,SID)) Q:SID=""  D EXEC
	K ^TEMP($J)
	W !,#,! U 0 I IO'=$I D CLOSE^SCAIO     ; *** XUS 07/22/94
	Q
	;
EXEC	;
	S SAVL=""
	;-----------------------------------------------------------------------
ENTRY	; Private ; Called by ^DBSDS1 (print screen with documentation
        ;-----------------------------------------------------------------------
	;
	D INIT
	I '$D(IO) D ^SCAIO
	;
	S DES=^DBTBL(DLIB,2,SID),FILES=^DBTBL(DLIB,2,SID,0)
	S PGM=$P(FILES,"|",2),FILES=$P(FILES,"|",1)
	S PFID=$P(FILES,",",1)
	;
	I $D(^DBTBL(DLIB,2,SID,-1)) W !,#,! Q
	;
	I PFID="" S FDES=""
	E  S FDES=^DBTBL(DLIB,1,PFID)
	S DL=DLIB ; Fix this (FRS)
	;
	F COPY=1:1:XCOPY D MPNT
	W #
	Q
	;
MPNT	;
	U IO W #
	; Profile ~p1  System
	S L="Profile "_FDES_" System"
	S H1=L_$J("",71-$L(DES)-$L(L))_" "_DES D HDR
	;
	S %="|",Q=$C(34)
	S SEQ=0,FID=$P(^DBTBL(DLIB,2,SID,0),"|",1),GRP=FID
	S ZZLAS=$O(^DBTBL(DLIB,2,SID,""),-1),ZZLAS=^(ZZLAS) ; last prompt on screen
	S %LOOP=$P(^(0),"|",7)
	;
	D PRINT
	I $D(TBL)#10 D TBLPNT
	Q
	;
PRINT	;
	;
	; PRINT DOCUMENTATION
	;
	N lib,zdesc,Z				; *** 09/28/95 BC
	S zdesc=""				; *** 
NS	;
	S SEQ=$O(DT(SEQ)) I SEQ="" Q
	S X=DT(SEQ) K P
	;
	; REPEAT GROUP
	;
	I %LOOP,X\1000>%LOOP,X>ZZLAS Q  ; second set of repeat data items
	;
	F I=1:1:12 S X(I)=$P(X,"|",I)
	;
	; 4-DEF  5-DI  6-TBL  7-CHK  10-FMT 11-PROMPT 12-REQ 17-COM
	;
	S UVAR=0
	I X(5)?1"@".E S zdesc=X(11) G NS	; *** 09/28/95 BC
	;
	I X(5)?1"@".E S X(10)=$P(X(11),",",3),X(6)=$P(X(11),",",9),X(5)=$E(X(5),2,99)
	I  S X(11)=$P(X(11),",",2),UVAR=1
	S DI=X(5),DFID=PFID
	I DI["[" S DFID=$E($P(DI,"]",1),2,99),DI=$P(DI,"]",2,99)
	I DFID["," S DL=$P(DFID,",",1),DFID=$P(DFID,",",2)
	W !,"  ",$$DESC(zdesc)				; *** 09/28/95 BC
	I $E(X(11),1)=" " S X(11)=$E(X(11),2,999)
	S L=$P(X(11),":",1),SAVL=L
	I X(1)["*" S P(1)="(PROTECTED)"
	I X(12)!(X(12)="Y") S P(12)="(REQUIRED)"
	; FORMAT: ~p1
	I X(7)]]"" S OV=X(7) D DECODE S P(7)="Format: "_NV
	I X(6)]]"" D TBL
	; DATA TYPE: ~p1
	S P(10)="Data Type: "_TYPE(X(10))
	I X(4)]]"" D DEF
	;
	S:$D(P(12)) L=L_"  "_P(12) S:$D(P(1)) L=L_"  "_P(1)
	S L=L_$J("",45-$L(L))_"  Data Item: "
	I 'UVAR S L=L_"["_DFID_"] "_DI D PNT
	I UVAR S L=L_"@["_DFID_"]"_DI D PNT
	S:$D(P(7)) L=P(7) S:$D(P(6)) L=P(6)
	S L=L_$J("",45-$L(L))_"  "_P(10) D PNT
	;
	;---------- Implicit Mode
	;
	S lib=DL,Z=$P($G(^DBTBL(DL,1,DFID,10)),"|",5)
	I Z'="" S lib=$E($P(Z,",",1),2,99)
	S FDOC=$G(^DBTBL(DL,1,DFID,13)),F=0 I FDOC="" G NS ; Invalid Doc file
	;
	I $O(^DBTBL(lib,11,FDOC,DI,0))="" D LF S L=HELP D PNT D LF,LF G NS
	;
	S L="" D PNT
	S N="" F  S N=$O(^(N)) Q:N=""  S F=1,L="   "_^(N) D PNT
	I $Y<56 W !! G NS
	D HDR
	G NS
	;
DEF	;
	I X(4)?1"@".E S X(4)=$E($P(X(4),"(",1),3,99)_" No change"
	; DEFAULT: ~p1
	S P(4)="Default: "_X(4)
	Q
	;
	;
	; DISPLAY TABLE
TBL	;
	N $ZT
	S $ZT=$$SETZT^%ZT("ERR^DBSDOC1")
	;
	I X(6)'["(" S X(6)=""
	S TBL=X(6) I TBL="" Q
	I $D(^DBTBL(DL,1,DFID,9,DI)) S X=^(DI),TBL=$P(X,"|",5) I TBL="" Q
	S:$E(TBL)="^" TBL=$E(TBL,2,99) F  Q:TBL'[""""  S TBL=$P(TBL,"""",1)_$P(TBL,"""",2,99)
	; TABLE: ~p1
	S P(6)="  Table: "_TBL
	I $E(TBL)?1A Q				; *** 09/28/95 BC
	S TBL(TBL)=X(6)
	Q
	;
PNT	;
	I $Y>IOSL D HDR
	W !,L S L=""
	Q
	;
LF	;
	S L="" D PNT
	Q
	;
HDR	;
	U IO W #,!
	W !,H1
	W !,LX,!
	; ~p1  (cont.)
	I F,SAVL]]"" W !,SAVL," (cont.)",! S F=0
	Q
	;
DECODE	;
	S X=1_$C(34)_"-"_$C(34)
	I OV[X S OV=$P(OV,X,1)_"-"_$P(OV,X,2,99) G DECODE
	I OV["!" S OV=$P(OV,"!",1)_"/"_$P(OV,"!",2,99) G DECODE
	;
	S NV="" F K=1:1:$L(OV) S X=$E(OV,K) I "NAU-0123456789&/"[X S NV=NV_X
	Q
	;
TBLPNT	; Print all tables
	;
	I $O(TBL(""))="" Q
	D HDR S TBL=""
	F  S TBL=$O(TBL(TBL)) Q:TBL=""  D TBL1
	Q
	;
TBL1	; Print records in a table
	;
	; TABLE LISTING FOR: ~p1
	S (L,SAVL)="Table listing for: "_TBL,F=0
	I $Y+5<IOSL W !!?3,L,!
	E  D HDR W ! G TBL1
	;
	S N="",GBL=TBL(TBL)_"N)",L=""
	I GBL'[$C(34) Q
	S XGBL=1
	;
	I GBL?.E1",#"1N1"N)" S XGBL=$P(GBL,"#",2)+0,GBL=$P(GBL,"#",1)_"N)"
	;
	N $ZT
	S $ZT=$$SETZT^%ZT("ER^DBSDOC1")
	;
	F I=0:1 S N=$O(@GBL) Q:N=""  D
	.	I $D(^(N))#10=0 Q
	.	S:I#2 L=L_$J("",40-$L(L))
	.	S L=L_$J(N,8)_"  "_$E($P(^(N),"|",XGBL),1,30)
	.	I I#2 S F=1 D PNT
	;
ER	;
	I L]]"" D PNT
	Q
	;
INIT	;
	S IORM=80,CONAM=^CUVAR("CONAM")
	S TYPE("T")="TEXT",TYPE("N")="NUMERIC",TYPE("D")="DATE"
	S TYPE("C")="TIME",TYPE("$")="DOLLAR",TYPE("L")="LOGICAL"
	S TYPE("F")="FREQUENCY",TYPE("U")="TEXT"
	;    No Documentation
	S HELP="<< No Documentation >>"
	S LX="",$P(LX,"-",72)="",SAVL="",F=0
	I '$D(SAVDT) D LOAD
	K TBL
	Q
	;
LOAD	; Load DT(SEQ) from ^DBTBL(DLIB,2,SID,SEQ
	;
	S SEQ=0 K DT
	F  S SEQ=$O(^DBTBL(DLIB,2,SID,SEQ)) Q:SEQ=""  S DT(SEQ)=^(SEQ)
	Q
	;
ERR	;
	Q
	; *** 09/28/95 BC
	;----------------------------------------------------------------------
DESC(x)	; Display field prompt
	;----------------------------------------------------------------------
	I $L(x)<2 S x=$$DES^DBSDD(DFID_"."_DI)	; Data item description
	I $E(x,$L(x))=":" S x=$E(x,1,$L(x)-1)	; Remove :
	F i=1:1:$L(x) I $E(x,i)'=" " Q		; Remove leading blanks
	Q $E(x,i,999)
