DBSEXEQ4	;;DBS - U - V4.4 - DQ QUICK REPORT (OUTPUT SECTION)
	;;Copyright(c)1996 Sanchez Computer Associates, Inc.  All Rights Reserved - 08/23/96 14:51:24 - SPIER
	;     ORIG:  BOB CHIANG (8447) - 04/29/87
	;     DESC:  CONVERT VARIABLES INTO DATA ITEM SYNTAX
	;
	;    INPUT:      OS = INPUT STRING         ( BAL*IRN/36500 )
	;             FILES = DATA FILES
	;             %LIBS = LIBRARY NAME
	;             LIB   = BASE FILE LIBRARY NAME
	;   OUTPUT:
	;                NS = CONVERTED STRING    ( [DEP]BAL*[DEP]IRN/36500 )
	;                NFMT = FORMAT ( $,D,C,...)
	;                NLEN = FIELD LENGTH
	;                NDEC = DECIMAL 
	;                ER = ERROR FLAG
	;       FLGPROT(FILE,DI) = COMPUTED OPERATION PROTECTION FLAG
	;
	;
        ; I18N=QUIT: Excluded from I18N standards.
	;---- Revision History ------------------------------------------------
	; 09/28/04 - RussellDS - CR12334
	;	     Replaced obsoleted calls to ^DBSANS with new procedure
	;	     DBSGETID.
	;
	; 08/23/96 - SPIER - 22637
	;            Changed $N to $O
	;
	; 01/03/95 - Ying A.C. Liu - I18N
	;	     Replaced MSG 7979 with MSG 2567.
	;
	; 08/09/94 - Shaodong Tony Xu - ARQ 14547
	;            Changed the DQ generated routine names.
	;
	; 05/27/94 - Bob Chiang - 12395
	;            Modified to remove BREAK command from the routine.
	;
	; 08/17/93 - CHIANG - SCA
	;            Modified to remove $T() commands and replace it with
	;            ^DBCTL("SYS","stat") references.
	;----------------------------------------------------------------------
	;

START	;
	;
	N I,HIT,T,Z,ZZ,ZZZ,%P,NV,OV,X,Q,FMT
	;
	K NS,NFMT,NLEN,NDEC
	;
	S (X,Z)=OS,Q=$C(34),ER=0,FMT=$P(OS,";",2)
	K FLGPROT
	;
	S BI=1,BZ=1 I "=_<>()+-#/*\"[$E(Z,1) S BI=2,BZ=2
	S I=BZ,L=$L(Z)
P1	;
	S X=$E(Z,I) I X="" G P2
	I X=Q S I=$F(Z,Q,I+1),BI=I G P1
	I ":=_<>()+-#/*\,"'[$E(Z,I) S I=I+1 G P1
	S X=$E(Z,BI,I-1),BI=I+1 I (X?1A.AN)!(X?1"%"1AN.AN)!(X?1"["1A.AN1"]"1A.AN) S %P(X)="",I=I+1 G P1
	S I=I+1 G P1
P2	;
	S X=$E(Z,BI,99) I X="" G P3
	I (X?1AP.AN)!(X?1"["1AP.AN1"]"1AP.AN) I X'?1"$".E S %P(X)=""
	;
P3	;
	K BI,BZ,I,L,X,Z
	;
	S NS=OS
	;
	S OV="" F  S OV=$O(%P(OV)) Q:OV=""  D CHANGE
	;
	;
	I FMT="" Q
	S NFMT=$E(FMT,1),NLEN=$E(FMT,2,99)\1
	I FMT[".",$P(FMT,".",2)'=2 S NFMT="RD"_$P(FMT,".",2)
	S NS=$P(NS,";",1)
	Q
	;
CHANGE	;
	; CHANGE DATA ITEM TO STANDARD [FID]DI SYNTAX
	;
	S HIT=0 I OV?1"["1E.AN1"]"1E.AN Q
	F I=1:1 S Z=$P(FILES,",",I) Q:Z=""  D IMPLICIT I $D(^DBTBL(NLIB,1,Z,9,OV)) S HIT=1 Q
	;
	I 'HIT S ER=1 Q
	S NV="["_Z_"]"_OV
	I '$D(NFMT) S NFMT=$P(^(OV),"|",9),NLEN=$P(^(OV),"|",2),NDEC=$P(^(OV),"|",14) G CHANGE1
	;
	I $P(^(OV),"|",2)>NLEN S NLEN=$P(^(OV),"|",2)
	I $P(^(OV),"|",14)>NDEC S NDEC=$P(^(OV),"|",14)
	I $P(^(OV),"|",9)="$" S NFMT="$"
	;
CHANGE1	;
	; data item protection on
	;
	D STATUS^UPID(Z,OV,.ZZZ) I ZZZ S FLGPROT(Z,OV)=""
	;
	S T=1
C	;
	S T=$F(NS,OV,T) Q:T=0
	I $E(NS,T)?1AN G C
	I $E(NS,T-1-$L(OV))?1AN G C
	I $E(NS,1,T-1)?.E1"^"1E.E1"(".E G C ; ^GLOBAL(VAR...)
	S NS=$E(NS,1,T-1-$L(OV))_NV_$E(NS,T,999)
	S T=T+$L(NV)-$L(OV)
	G C
	;
IMPLICIT	;
	S NLIB=%LIBS
	S X=$P(^DBTBL(%LIBS,1,Z,10),"|",5) I X="" Q
	S NLIB=$E($P(X,",",1),2,99)
	Q
	;
TEST	;
	S ER=0
	S LIB=%LIBS
	; FILE(S): 
	W !!,$$^MSG(3479)  R FILES I FILES="" Q
	; STRING DATA: 
	W !!,$$^MSG(7981)  R OS I OS="" Q
	;  SYNTAX ERROR 
	D START W !!,NS,!! I ER W $$^MSG(2567),*7,!
	G TEST
	;
	; --------------------------------------------------------------------
	; QUICK REPORT LIST OPTION
	; --------------------------------------------------------------------
	;
LIST	;
	N CNT,IO
	S CNT=$$LIST^DBSGETID("DBTBL5Q","List",.IO) Q:'CNT
	; QUICK REPORT DEFINITIONS
	S RN=$$^MSG(7980)
LIST1	;
	;
	N RID
	I '$D(%LIBS) N %LIBS S %LIBS=^CUVAR("%LIBS")
	S %BLK="/,"_IO,RID="DBSQRPLST" D DRV^URID    ; *** XUS 08/09/94
	Q
	;
PRINT(QRID)	;
	; ---------- Dislay QWIK report banner page (called by run-time rtn)
	;
	N (ER,%LIBS,IO,IOSL,IOTYP,QRID,IOQ)
	K ^TEMP($J) S ^TEMP($J,QRID)=""
	S %NOCLOSE=1,%NOOPEN=1,%BLK="/,"_QRID,RID="DBSQRPLST" D DRV^URID   ; *** XUS 08/09/94
	K %NOCLOSE
	;
	Q
	;
STATBLD	;
	;
	; BUILD RUN-TIME STAT LOGIC
	;
	; *** BC - Replace $T() references 08/17/93
	;
	F I=1:1 Q:'$D(^DBCTL("SYS","stat",I))  S ^TMP($J,500,I)=^(I)
	;
	S ^TMP($J,490,1)="VSTAT ;"
	;
	F STS=21:1:40 Q:'$D(%A(STS))  S GL=%A(STS) I GL'?."|" D STSDSP
	Q
	;
STSDSP	;
	S VX=$P(GL,"|",5) I VX'["," G STSDSP1
	S $P(GL,"|",2)="N",GL=$P(GL,"|",1,4)
	F Z=1:1 S Z1=$P(VX,",",Z) Q:Z1=""  S GL=GL_"|"_Z1
	;
STSDSP1	;
	K DFID
	;
	S X=$P(GL,"|",1) I X="" S X=$P(GL,"|",4),$P(GL,"|",1)=X
	S DLIB=%LIBS,DFID=PFID D ^DBSDI I ER W !!,RM,! Q
	S $P(GL,"|",3)=DI(9) ; DATA FORMAT TYPE
	S DINAM="["_LIB_","_FID_"]"_DI D ^DBSCHK I ER'="" W " ??",*7 Q  ; *** BC - 05/27/94
	S X1=$E($P(DINAM,",",1),2,99),X2=$P(DINAM,",",2),X2=$P(X2,"]",1)
	S TYP=$P(^DBTBL(X1,1,X2,9,DI),"|",9),NS1=NS
	;
	; ---------- map to sort key name
	;
	I $G(ORDERBY)[DINAM S NS1=$P(DINAM,"]",2)
	;
	I "UFT"'[TYP S NS1=NS1_"+0"
	S X=$P(GL,"|",4),NS="V"
	;
	; ---------- Same data item ?
	;
	I X'=$P(GL,"|",1) D ^DBSDI Q:ER  S DINAM="["_LIB_","_FID_"]"_DI D ^DBSCHK
	;
	I $G(ORDERBY)[DINAM S NS=$P(DINAM,"]",2)
	;
	S ^TMP($J,491,STS)=" S V="_NS1_",V1="_NS_",%STS="_Q_STS_"|"_GL_Q_" D VSTAT0"
	Q
	;
	Q
	;
