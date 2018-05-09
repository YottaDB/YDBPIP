DBSUTL	;;DBS - U - V5.0 - DQ DELETE/COPY DEFINITIONS UTILITY
	;;Copyright(c)1999 Sanchez Computer Associates, Inc.  All Rights Reserved - 12/02/99 10:49:41 - DOUGHERTYT
	;     ORIG:  BOB CHIANG (8447) - 03/31/86
	;CALLED BY:  ^DBSDS,^DBSORT,^DBSEXE,^DBSUTL3
	;    CALLS:  ^%TRMVT,^%ZM,^%ZRTNDEL,^DBSDF9,^DBSGETID,^DBSMBAR,^DBSUTL,
	;            ^DBSUTL3,^UTLREAD
	;     DESC: DATA QWIK COPY/DELETE DEFINITION UTILITY
	;           LINE TAG 'COPY' OR 'DEL'
	;
	;    INPUT: DBOPT  - DQ DEFINITION ID (2,5,9) ( I.E  REPORT=5)
	;         : DQSCR  - DEFINITION SCREEN NAME   ( I.E. ^DBSEXE1)
	;         : %LIBS  - LIBRARY NAME
	;
        ; I18N=QUIT: Exculded from I18N standards.
	;---------- Revision History -------------------------------------------
	; 05/17/06 - Allan Mattson - CR20048
	;            Replaced calls to $$UPPER^%ZFUNC with $$UPPER^SCAUTL.
	;
	; 09/28/04 - RussellDS - CR12334
	;	     Replaced obsoleted calls to ^DBSANS1 with new procedure
	;	     DBSGETID.
	;
	;	     Added DQTABLE as parameter for COPY and DEL.  When rewrite
	;	     to PSL, removed the referenced to DBOPT and just use the
	;	     table name.
	;
	; 11/30/99 - Terrie Dougherty - 31126
	;	     Replace direct calls to filer with EXT^DBSFILER as part of 
	;	     the transaction processing to PSL project.
	;	     Removed old revision history.
	;
	;-----------------------------------------------------------------------
START	;
	;
COPY(DQTABLE)	;
	;
	; Code added for now to remove G COPY -- resolve when move to PSL
	N ALLDONE
	S ALLDONE=0
	F  D COPYX Q:ALLDONE
	Q
	;
COPYX	;
	N NAME,DBOPT,FIND,OID,TLIB,DLIB
	;
	;
	I DQTABLE="DBTBL5H" S DBOPT=5
	E  I DQTABLE="DBTBL5Q" S DBOPT=6
	E  S DBOPT=+$P(DQTABLE,"DBTBL",2)
	;
	S X=$$FIND^DBSGETID(DQTABLE,0) I X="" S ALLDONE=1 Q
	;
	S NAME=$G(^DBTBL(%LIBS,1,DQTABLE,16)) I NAME="" S ALLDONE=1 Q
	S NAME=$P(NAME,",",$L(NAME,","))
	S @NAME=X,OID=X
	;
	I DQSCR'="" S %O=2,%NOPRMT="Q" D @DQSCR
	;
	I DBOPT=1 D
	.	;
	.	S DLIB=%LIBS
	.	S Z=$P($G(^DBTBL(%LIBS,1,OID,10)),"|",5)
	.	I Z'="" S DLIB=$E($P(Z,",",1),2,99)
	E  D
	.	S $P(STS,"|",2)="",$P(STS,"|",3)=+$H	
	.	S DES=^DBTBL(%LIBS,DBOPT,OID),STS=$G(^(OID,0))
	.	S DLIB=%LIBS I $D(^(-3)) S DLIB=^(-3)
	;
	N DQREF,OLNTB,Z,I,%TAB
	;
	S TLIB=%LIBS,OLNTB=22020,DQREF=DQTABLE
	S DQREF="["_DQREF_"]"_NAME
	S (FID,SID,QID,RID,QRID,PID,AGID,IDEXCH)=""
	;
	S %READ=DQREF_"/TBL="_$P(DQREF,"]",1)_"]/XPP=D PP^DBSUTL"
	S %READ=%READ_"/TYP=U/DES=To "_^DBCTL("SYS","DBOPT",DBOPT)_" Definition Name"
	;
	S %NOPRMT="F" D ^UTLREAD I VFMQ'="F" S ALLDONE=1 Q
	;
	S DQREF=$P(DQREF,"]",2)
	S NID=@DQREF
	;
	I DBOPT=1 D COPYDD(DLIB,TLIB,OID,NID) Q
	;
	I TLIB'=DLIB S OLDV="["_DLIB_",",NEWV="["_TLIB_","
	;
	S L=""
	I '$D(^DBTBL(TLIB,DBOPT,NID)) S ^DBTBL(TLIB,DBOPT,NID)=DES
	D
	.	I DBOPT=16 S $P(^(NID),"|",2)="" Q	; Data Exchange definition
	.	I DBOPT=22 S $P(^(NID),"|",4)="" Q	; Aggregate definition
	.	S ^DBTBL(TLIB,DBOPT,NID,0)=STS
NX	S L=$O(^DBTBL(DLIB,DBOPT,OID,L)) I L="" D DONE Q
	I $X<75 W "."
	;
	S XL=L
	I TLIB'=DLIB,$$PATTERN(L,DLIB) S XL=$P(L,DLIB,1)_TLIB_$P(L,DLIB,2,99)
	I $D(^(L))=10 G NX1
	S DATA=$G(^(L))
	;
	; remove program name & update DATE information
	;
	I L=0 S $P(DATA,"|",2)="" S $P(DATA,"|",3)=+$H
	I L=0,DBOPT=7 F zx=16,17,19,20 S $P(DATA,"|",zx)="" ; REPORT LINKAGE DEF
	;
	D CONVERT
	;
	S ^DBTBL(TLIB,DBOPT,NID,XL)=DATA
NX1	;
	I $O(^DBTBL(DLIB,DBOPT,OID,L,""))'="" D NXPTR G NX ; NEXT LEVER POINTER
	G NX
	;
NXPTR	;
	S NL=""
	F  S NL=$O(^DBTBL(DLIB,DBOPT,OID,L,NL)) Q:NL=""  D
	.	I $D(^(NL))#10=1 D
	..		S DATA=$G(^DBTBL(DLIB,DBOPT,OID,L,NL)) D CONVERT
	..		S ^DBTBL(TLIB,DBOPT,NID,XL,NL)=DATA
	.	D MORE W "."
	.	I $X>70 W !
	Q
MORE	;
	S NL1=""
	F  S NL1=$O(^DBTBL(DLIB,DBOPT,OID,L,NL,NL1)) Q:NL1=""  D
	.	I $D(^(NL1))#10=1 D
	..		S DATA=^DBTBL(DLIB,DBOPT,OID,L,NL,NL1) D CONVERT
	..		S ^DBTBL(TLIB,DBOPT,NID,XL,NL,NL1)=DATA
	.	D MORE1 W "."
	.	I $X>70 W !
	Q
MORE1	;
	S NL2=""
	F  S NL2=$O(^DBTBL(DLIB,DBOPT,OID,L,NL,NL1,NL2)) Q:NL2=""  D
	.	I $D(^(NL2))#10=0 Q
	.	S DATA=^DBTBL(DLIB,DBOPT,OID,L,NL,NL1,NL2) D CONVERT
	.	S ^DBTBL(TLIB,DBOPT,NID,XL,NL,NL1,NL2)=DATA
	Q
	;
PP	;
	I X="" Q
	; Alphanumeric format only
	I '$$VALIDKEY^DBSGETID(X) S ER=1,RM=$$^MSG(248) Q
	; Already created
	I $D(^DBTBL(TLIB,DBOPT,X)) S ER=1,RM=$$^MSG(252) Q
	D CHANGE^DBSMACRO("TBL","")
	Q
	;
CONVERT	;
	I TLIB=DLIB Q
	I DATA'["[" Q
	I DATA[OLDV S DATA=$P(DATA,OLDV,1)_NEWV_$P(DATA,OLDV,2,99)
	Q
	;
PATTERN(STRING,VALUE)	;
	;
	; Return status  0  -  STRING not contain VALUE (library name in
	;                                                [LIB] OR [LIB,FID]
	;                                                syntax)
	N X
	S X="["_VALUE
	I STRING[X Q 1
	E  Q 0
	;
	;----------------------------------------------------------------------
COPYDD(XLIB,%LIBS,XFID,FID)	; Copy a Data Dictionary definition
	;----------------------------------------------------------------------
	;
	N N,X	
	;
	S ^DBTBL(%LIBS,1,FID)=^DBTBL(XLIB,1,XFID)
	;
	S N=""
	F  S N=$O(^DBTBL(XLIB,1,XFID,N)) Q:N=""  D
	.	S ^DBTBL(%LIBS,1,FID,N)=$G(^(N))
	.	I N=9 S X="" F  S X=$O(^DBTBL(XLIB,1,XFID,9,X)) Q:X=""  D
	..		S ^DBTBL(%LIBS,1,FID,9,X)=^DBTBL(XLIB,1,XFID,9,X)
	;
	; Remove filer name and supertype file name
	;
	S $P(^DBTBL(%LIBS,1,FID,99),"|",2)="" 		; Filer name
	S $P(^DBTBL(%LIBS,1,FID,10),"|",4)="" 		; Supertype file
	;
	D BLDINDX^DBSDF9(FID)				; Build index files
	Q
	;
	;----------------------------------------------------------------------
DEL(DQTABLE)	; Delete a DATA-QWIK Definition
	;----------------------------------------------------------------------
	;
	; Code added for now to remove G DEL -- resolve when move to PSL
	N ALLDONE,DBOPT
	;
	S ALLDONE=0
	I DQTABLE="DBTBL5H" S DBOPT=5
	E  I DQTABLE="DBTBL5Q" S DBOPT=6
	E  S DBOPT=+$P(DQTABLE,"DBTBL",2)
	;
	F  D DELX Q:ALLDONE
	Q
	;
DELX	;
	S OID=$$FIND^DBSGETID(DQTABLE,0) I OID="" S ALLDONE=1 Q
	I DQTABLE="DBTBL2" S SID=OID
        E  I DQTABLE="DBTBL4" S QID=OID
        E  I DQTABLE="DBTBL5H" S RID=OID
        E  I DQTABLE="DBTBL5Q" S QRID=OID
        E  I DQTABLE="DBTBL13" S PID=OID
        ;
	I DQSCR'="" S %O=3 D @DQSCR I VFMQ="Q" S ALLDONE=1 Q
	S RUNPGM=""
	S ZLIBS=$G(^DBTBL(%LIBS,DBOPT,OID,-3)) I ZLIBS="" G DEL0
	I '$D(^DBTBL(ZLIBS,DBOPT,OID)) G DEL1
	; Implicit to Library ~p1 ... Continue
	I '$$YN^DBSMBAR("",$$^MSG(1204,ZLIBS),0) G DELX
	G DEL1	
DEL0	;
	S RUNPGM="" I $D(^DBTBL(%LIBS,DBOPT,OID,0)) S RUNPGM=$P(^(0),"|",2)
	I RUNPGM'?1U.AN S RUNPGM="" ; INVALID PROGRAM NAME
	I RUNPGM="" G DEL1
	; Protected
	I $E(RUNPGM,1,3)="DBS" W $$MSG^%TRMVT($$^MSG(2277),1,1) Q 
	; Warning - application program <~p1> will be deleted
	W $$MSG^%TRMVT($$^MSG(2956,RUNPGM),1)
	;
DEL1	;
	;
	; Delete definition ... Are you sure?
	I $$^DBSMBAR(163)'=2 G DELX
	;
	I DBOPT=1 D  Q					; Delete a file
	.	;
	.	N FID
	.	S FID=OID
	.	D EXT^DBSFILER("DBTBL1",3) Q:ER
	.	; File ~p1 deleted
	.	S RM=$$^MSG(1095,FID) Q
	;
	; Remove Data Item Index File
	;
	S ID=OID,DQFUN="D" D ^DBSUTL3
	;
	; clean up sort file definitions
	;
	I DBOPT'=3 G DEL1A
	;
	S XGBL=$P(^DBTBL(%LIBS,3,OID,0),"|",9),XFID=$P(^(0),"|",10)
	;
	; Delete sort global RllXsss
	;
	I $E(XGBL,1)="R" K @("^"_XGBL)
	;
	; Delete sort file definitions
	;
	I $E(XFID,1)="R" K ^DBTBL(%LIBS,1,XFID)
DEL1A	;
	S XPGM=RUNPGM I XPGM["*" S XPGM=""
	I XPGM=""!(ZLIBS'="") G DEL1B
	;
	S ZPGM=RUNPGM
	;
	D DEL^%ZRTNDEL(RUNPGM)
	;
	; Delete report run-time sort program RllZsss
	;
	I DBOPT=5 S Z=$E(RUNPGM,1,3)_"Z"_$E(RUNPGM,5,8) D DEL^%ZRTNDEL(Z)
	;
	; Delete report run-time stat program RllTsss
	;
	I DBOPT=5 S Z=$E(RUNPGM,1,3)_"T"_$E(RUNPGM,5,8) D DEL^%ZRTNDEL(Z)
	;
DEL1B	;
	W " Done",*7 K ^DBTBL(%LIBS,DBOPT,OID)
	;
	;
	; REMOVE ALL IMPLICIT REFERENCE
	;
	S ZLIBS=""
DEL2	;
	S ZLIBS=$O(^DBTBL(ZLIBS)) Q:ZLIBS=""
	I '$D(^DBTBL(ZLIBS,DBOPT,OID)) G DEL2
	I '$D(^(OID,-3)) G DEL2
	I ^(-3)'=%LIBS G DEL2
	K ^DBTBL(ZLIBS,DBOPT,OID)
	; Library ~p1 ~p2 ~p3 deleted
	W $$MSG^%TRMVT($$^MSG(1607,ZLIBS,^DBCTL("SYS","DBOPT",DBOPT),OID),1,1)
	G DEL2
DONE	;
	;
	I DBOPT=13 K ^DBTBL(TLIB,13,NID,-2)
	;
	; Create field id/data iten name index file
	;
	N %LIBS
	S %LIBS=TLIB
DONE1	;
	H 2 W !
	;
	; Create screen,report linkage
	;
	S DQFUN="A",ID=NID D ^DBSUTL3
	Q
	;
TR	; Translate lower to UPPER case
	S X=$$UPPER^SCAUTL(X)
	Q
