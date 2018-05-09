DBSITEM(FILES,ITEMS,DBSATT,HDROPT,REPTYPE)	;;CREATE DATA ITEM ATTRIBUTES
	;;Copyright(c)1996 Sanchez Computer Associates, Inc.  All Rights Reserved - 08/16/96 15:21:22 - CHIANG
	;     ORIG:  CHIANG - 10/20/89
	;     DESC:  CREATE DATA ITEM ATTRIBUTES CONTROL TABLE
	;
	;    INPUT:  %LIBS,FILES,ITEMS
	;   OUTPUT:  DBSATT(n)=data item | column heading | size | fmt
	;            ER = Error flag   RM = Message
	;
	; I18N=QUIT: Excluded from I18N standards. 
	;
	; FILES    Access files ( primary,secondary,...)    DEP,CIF
	;  
	; ITEMS    Data items ( data item,data item,...)    
	;                                                   
	;            CID,BAL,TAXID,AGE,BAL*IRN/36500@Interest,IRN-
	;
	; DBSATT(n)  DATA ITEM ATTRIBUTES TABLE ( n = item sequence # )
	;
	;            data item|heading|indent|size|format|Function|new line
	;
	;            DBSATT(1)= CID   | Account@Number  | 2 | 12 | N |
	;                  (2)= BAL   | Account@Balance | 2 | 12 | E | SUM
	;                  (3)= TAXID | Tax Id          | 2 | 11 | T |
	;                  (4)= AGE   | Age             | 2 | 3  | N |
	;                  (5)= BAL*IRN/36500 |Interest | 2 | 12 | E | SUM
	;                  (6)= IRN   | Interest@Rate   | 2 | 8  | $5|
	;
	; HDROPT     Column heading option		/TYP=N/NOREQ/MECH=VAL
	;
	;            0 - set up field size based on column header size (v4.0)
	;            1 - set up field size based on file definitions (v4.1)
	;            2 - set heading to NULL
	;
	; REPTYPE    Report Type			/TYP=T/NOREQ/MECH=VAL
	;
	;            REPORT - Columnar report (default)
	;            LABEL  - Mailing Label
	;            FIXED  - Fixed Length Record
	;            EXPORT - Export File Format
	;
	;-------- Revision History ---------------------------------------------
	;
	; 08/16/96 - Bob Chiang - 20948
	;            Modified DECODE1 section to use the display length as the
	;            default field size instead of the maximum field size.
	;
	; 10/27/94 - Bob Chiang - ARQ 18
	;            Removed TEST section from this routine.
	;
	; 10/13/94 - Ying A.C. Liu - I18N
	;            Removed duplicate messages.
	;
	; 08/10/94 - Shaodong Tony Xu - ARQ 14547
	;            Changed the DQ generated routine name.
	;
	; 07/26/94 - Steve Canfield - I18N
	;	     Converted msgid from DQnnnn to nnnn.
	;
	; 12/12/92 - Allan Mattson - I18N#7
	;
	;            Modified return message handling with a call to extrinsic
	;            function $$^MSG(msgid,p1,p2...) for I18N development
	;            (phrase independence).
	;
	;
	; 11/10/92      Bob Chiang (V 4.4-2 1036)
	;               Modified to set up default print format to E for data 
	;               items defined internally as $ (currency).
	;               Added new parameter REPTYPE to support different
	;               report layouts.
	;
	; 09/18/92      Bob Chiang (BHI341)
	;               Modified to insert a missing QUIT command
	;
	; 05/18/92      Bob Chiang (project # BHI)
	;               Change format $ with decimal precision to RDn
	;-----------------------------------------------------------------------
	;
	N (%LIBS,FILES,ITEMS,DBSATT,HDROPT,REPTYPE,ER,RM,CNTFUN)
	;
	S ER=0
	I ITEMS?1"@".E Q
	;
	S HDROPT=$G(HDROPT)
	I $G(REPTYPE)="" S REPTYPE="REPORT"
	;
	I '$D(%LIBS) S %LIBS=$G(^CUVAR("%LIBS"))
	I %LIBS="" D LIBERR Q
	;
	I $G(FILES)="" S FL="" D FLERR Q
	;
	; ========== Identify access files and assign implicit pointer
	;
	F I=1:1 S FL=$P(FILES,",",I) Q:FL=""  S FID(FL)=$$LIB(FL)
	I ER Q
	;
	S COUNT=$L(ITEMS,","),POS=1
	K TAB
	F ICNT=1:1:COUNT S DI=$P(ITEMS,",",ICNT) D DECODE
	Q
	;
DECODE	;
	; ========== Next entry
	;
	I DI?1N.N Q
	K NOSUM,USERHDR,USERSIZE,USERFMT
	S NSEQ=$ZP(DBSATT(""))+1
	;
	; DI@HDR;FMT
	;
	; DI@USERHDG
	;
	I DI?1E.E1"@"1E.E S USERHDR=$P(DI,"@",2,99),DI=$P(DI,"@",1)
	;
	; ========== [FID]DI syntax
	;
	I DI'?1"["1E.E1"]"1E.E G DECODE0
	;
	S FL=$E($P(DI,"]",1),2,99),DI=$P(DI,"]",2)
	I DI?1E.E1"-" S DI=$E(DI,1,$L(DI)-1),NOSUM=1
	S LIB=$$LIB(FL),DATA=$G(^DBTBL(LIB,1,FL,9,DI)) G DECODE1
DECODE0	;
	;
	I DI="" S USERIND=$G(USERIND)+2 Q  ; ,, extra comma
	I $E(DI)="""",$E(DI,$L(DI))="""" D TEXT Q  ; "Text"
	;
	; ========== Locate the correct file for this data item
	;
	S FL=""
	F J=1:1 S FL=$O(FID(FL)) Q:FL=""  I $D(^DBTBL(FID(FL),1,FL,9,DI)) Q
	;
	; ========== Invalid data item name
	;
	I FL="",((DI?1"%".AN)!(DI?1A.AN)) D DIERR Q
	;
	S DATA=$G(^(DI))
	;
	; ========== Computed data item
	;
DECODE1	;
	I DATA="" D COMPUTE Q:ER  G DECODE2
	;
	; ========== Column heading / data item long name
	;
	S LEN=$P(DATA,"|",2)				; *** 08/16/96
	I LEN>132,$P(DATA,"|",19) S LEN=$P(DATA,"|",19)	; Use display length
	S FMT=$P(DATA,"|",9),DEC=$P(DATA,"|",14)
DECODE2	;
	S FUN=""
	I $D(USERHDR) S HDR=USERHDR
	E  S HDR=$P(DATA,"|",22) I HDR="" S HDR=$P(DATA,"|",10)
	;
	I "UF"[FMT S FMT="T"
	I REPTYPE="FIXED" DO
	.	I FMT="$" S FMT="I$"
	.	I FMT="N",'DEC S FMT="IN"
	.	I FMT="N",DEC S FMT="I$"_DEC
	.	I FMT="D" S FMT="ID"
	I REPTYPE="LABEL"!(REPTYPE="REPORT") DO
	.	I FMT="$" S FMT="E",LEN=LEN+2 I '$D(NOSUM) S FUN="SUM"
	.	I FMT="N",DEC S FMT="RD"_DEC
	;
	S INDENT=2 I $G(USERIND) S INDENT=INDENT+USERIND K USERIND
	I $D(TAB) S INDENT=TAB-POS S:INDENT<0 INDENT=0 K TAB
	;
	I $D(USERFMT) S FMT=USERFMT
	I $D(USERSIZE) S LEN=USERSIZE
	;
	S HDR=$E(HDR,1,35)
	I NSEQ=1,INDENT=2 S INDENT=0
	;
	D HDRDFT
	;
	I FUN="","TUFDC"[FMT,'$D(CNTFUN) S FUN="CNT",CNTFUN=""
	I INDENT<0 S INDENT=0
	;
	;---------- Special format for mailing labels
	;
	I REPTYPE="EXPORT" S FUN="",INDENT=0
	I REPTYPE="FIXED" S FUN="",HDR=""
	S SKIP="" I REPTYPE="LABEL" DO
	.	S SKIP=1,INDENT=0,HDR="",FUN=""
	.	I ICNT=COUNT,ICNT<6 S SKIP=6-ICNT
	S DBSATT(NSEQ)=DI_"|"_HDR_"|"_INDENT_"|"_LEN_"|"_FMT_"|"_FUN_"|"_SKIP
	;
	S POS=POS+INDENT+LEN
	D TRACE
	Q
	;
COMPUTE	;
	;
	S OS=$P(DI,"@",1) D ^DBSEXEQ4
	I 'ER S LEN=NLEN,FMT=NFMT,DEC=NDEC Q
	; ??? Invalid data item name ???
	S LEN=1,FMT="T",DEC=0,USERHDR=$$^MSG(1298,$G(RM)),ER=0
	Q
TEXT	; "text"
	;
	S LEN=$L(DI)-2
	S INDENT=2 I NSEQ=1 S INDENT=0
	S DBSATT(NSEQ)=DI_"||"_INDENT_"|"_LEN_"|T",POS=POS+2+LEN
	D TRACE
	Q
	;
LIB(FL)	;
	; Return LIBRARY NAME based on FILE NAME
	;
	I '$D(^DBTBL(%LIBS,1,FL)) D FLERR Q ""
	;
	N X
	S LIB=%LIBS
	S X=$P(^DBTBL(%LIBS,1,FL,10),"|",5)
	I X'="" S LIB=$E($P(X,",",1),2,99)
	Q LIB
	Q
HDRDFT	;
	; Default header
	;
	N Z,Z1,I,X
	I HDROPT=1 Q
	I HDROPT=2 S HDR="" Q
	; Set field length to the size of column heading
	;
	S Z=0,Z1=$L(HDR,"@")
	F I=1:1:Z1 S X=$L($P(HDR,"@",I)) I X>Z S Z=X
	I LEN<Z S LEN=Z
	;
	Q
	;
	; ========== Error Messages
	;
LIBERR	;
	; Invalid library name
	S ER=1,RM=$$^MSG(1388) Q
FLERR	;
	; Invalid file name - ~p1
	S ER=1,RM=$$^MSG(1337,FL) Q
DIERR	;
	; Invalid data item - ~p1
	S ER=1,RM=$$^MSG(1298,DI) Q
	;
TRACE	Q
	W !,DBSATT(NSEQ),?70,POS R X
	Q
	; ========== Entry point for CREATE/MODIFY screen mode
	;
UPDTBL	;
	; format control table maintenence
	;
	N ITEM,ITEMS,FILES,%REPEAT,I,REPTYPE
	;
	S FILES=$P(%A(0),"|",1),REPTYPE=$P(%A(0),"|",20)
	;
	I $D(DBTBL6F),'$D(UX("DBTBL5Q","FLD1")) G UPDTBL1 ; Use orig definition
	;
	K DBTBL6F
	;
	F ITEM=12:1:16 S ITEMS=$G(%A(ITEM)) I ITEM'="" DO
	.	D DBSITEM(FILES,ITEMS,.DBTBL6F,0,REPTYPE)
	;
	; ========== merge definition from file
	;
	D MERGE
UPDTBL1	;
	S UX=1,%REPEAT=$ZP(DBTBL6F(""))
	I %REPEAT<20 D  Q
	.       ; *** XUS 08/10/94 
	.       N OLDSID,OLDPGM S OLDSID=$G(SID),OLDPGM=$G(PGM) 
	.       S SID="DBTBL6F" 
	.       D ^USID I PGM="" Q 
	.       S SID=OLDSID 
	.       D ^@PGM
	;
	S UX=1,%PAGE=%PAGE+1
	S zzREPEAT=%REPEAT,%REPEAT=19 D  Q:"FQ"[VFMQ
	.       ; *** XUS 08/10/94  
	.       N OLDSID,OLDPGM S OLDSID=$G(SID),OLDPGM=$G(PGM)  
	.       S SID="DBTBL6F"  
	.       D ^USID I PGM="" Q  
	.       S SID=OLDSID  
	.       D ^@PGM  
	S %PG=%PG+1,%REPEAT=zzREPEAT-19,%MODS=20 D 
	.       ; *** XUS 08/10/94  
	.       N OLDSID,OLDPGM S OLDSID=$G(SID),OLDPGM=$G(PGM)  
	.       S SID="DBTBL6F"  
	.       D ^USID I PGM="" Q  
	.       S SID=OLDSID  
	.       D ^@PGM  
	;
	Q
	;
FILE	;
	; FILE DATA
	;
	S %REPEAT=$ZP(DBTBL6F(""))
	F I=101:1 Q:'$D(%A(I))  K %A(I)
	F I=1:1:%REPEAT S %A(100+I)=DBTBL6F(I)
	Q
MERGE	;
	N I,X,CNT,J,X1,OLD
	;
	S CNT=$ZP(DBTBL6F(""))
	F I=101:1 Q:'$D(%A(I))  S OLD(I)=%A(I)
	F J=1:1:CNT S X1=$P(DBTBL6F(J),"|",1) D MERGE1 I X'="" S DBTBL6F(J)=X
	;
	Q
MERGE1	;
	;
	S X="",I=0
	F  S I=$O(OLD(I)) Q:I=""  I $P(OLD(I),"|",1)=X1 S X=OLD(I) K OLD(I) Q
	;
	Q
	;
CNVQR	;
	; V 4.1 QWIK REPORT CONVERSION
	;
	; Input variable %LIBS,QRID
	;
	N (%LIBS,QRID)
QA	;
	S %TO=60
	I '$D(%LIBS) S %LIBS=^CUVAR("%LIBS")
	;
	K %A S X=-1 F I=1:1 S X=$O(^DBTBL(%LIBS,6,QRID,X)) Q:X=""!(X>100)  S %A(X)=^(X)
	;
	; Combine node 12-18
	;
	F I=12:1:18 I '$D(%A(I)) S %A(I)=""
	S X="" F I=12:1:18 I %A(I)'="" S:%A(I)'?.E1"," %A(I)=%A(I)_"," S X=X_%A(I)
	;
	F I=12:1:18 S SAV(I)=%A(I),%A(I)=""
	S %A(12)=X
	;
	; Remove &,#,-,@
	;
	S N=1,Z="" K ZSAV
	F I=12:1:18 I SAV(I)'="" D QA1
	I Z'="" S ZSAV(N)=Z
	;
	;
	;
	S FILES=$P(%A(0),"|",1)
	;
	S ITEMS=$G(%A(12)) I ITEMS'="" D DBSITEM(FILES,ITEMS,.DBTBL6F,0)
	;
	D FILE
	;
	F I=12:1:18 S %A(I)=""
	F I=1:1 Q:'$D(ZSAV(I))  S %A(I+11)=ZSAV(I)
	;
	S X=-1 F I=1:1 S X=$O(%A(X)) Q:X=""  S ^DBTBL(%LIBS,6,QRID,X)=%A(X)
	;
	Q
	;
QA1	;
	N X,L,J,Y
	S X=SAV(I)
	S L=$L(X,",")
	F J=1:1:L S Y=$P(X,",",J) D QA2
	;
	Q
QA2	;
	I Y="" Q
	I $E(Y)="#"!($E(Y)="&") Q
	I Y["@" S Y=$P(Y,"@",1)
	I Y?.E1"_" S Y=$E(Y,1,$L(Y)-1)
	I Y[";" S Y=$P(Y,";",1)
	I Y?1"["1E.E1"]"1E.E,Y'["MADDR",Y'["LADDR" S Y=$P(Y,"]",2)
	I $L(Z)+$L(Y)>70 S ZSAV(N)=Z,Z="",N=N+1
	S Z=Z_Y_","
	;
