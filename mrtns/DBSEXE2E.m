DBSEXE2E	;;DBS - U - V4.2 - /QL COMMAND PROCESSOR ; 17 Apr 89  9:47 AM - 8447
	;;Copyright(c)1996 Sanchez Computer Associates, Inc.  All Rights Reserved - 06/21/96 14:37:21 - CHIANG
	;     ORIG:  BOB CHIANG (8447) - 02/06/89
	;     DESC:  /QL  COMMAND PROCESSOR( quick layout )
	;
	;  I18N=QUIT: Excluded from I18N standards 
	;---- Revision History ------------------------------------------------
	; 06/21/96 - Bob Chiang - 20948
	;            Modified to remove DQ level 20 references.
	;
	; 10/27/94 - Bob Chiang - ARQ 18
	;            Removed calls to $$^MSG.
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
START	;
	;---------------------------------------------------------------------
QL(INPUT,QBOPT,TAPEFMT)	;
	;
	; ------------------------------------------------------------------
	; Build Detail lines /QL
	; ------------------------------------------------------------------
	;
	; ===== Issue this command from access key levels section only !!
	;
	;  Invalid report section for this command
	I GRP?1"@".E D IOBP W $$^MSG(7974) R X:10 Q
	;
	S CURGRP=$G(GRP)
	;
	N LIB,FID,DI,NF,LEN,FMT,DESC,TAB,LINE,ER,RM,XDINAM,XSEQ,DTL,%TAB,ER,RM,DBOPT,QRID,NXSEQ,Y1,ZMSG1,DEC,GRP,I,ZL,ZF,CNT,DIHDR,FID,DFID,COLHDR
	;
	; ~p1Access file(s): ~p2
	S ZMSG1=$$^MSG(7975,$J("",23),FILES)
	S ZMSG1=ZMSG1_$J("",80-$L(ZMSG1))
	;
	S PFID=$P(FILES,",",1)
	;
	; ===== Access source LIB and FID
	;
	D ^DBSIMP(%LIBS,FILES,.ZLIB,.ZFID,.ER) I ER Q
	;
	S QBOPT=$G(QBOPT)
	S OLNTB=10040
	;
	F I=1:1:6 S DTL(I)=""
	S DTL(1)=INPUT,VFMQ="F"
	;
	; ===== Fixed length tape format ?
	;
	S TAPEFMT=$G(TAPEFMT)
	I 'TAPEFMT I $P(^DBTBL(%LIBS,5,RID,0),"|",8),$P(^(0),"|",6)>999 S TAPEFMT=1
	;
	S GRP=CURGRP
	;
	S LSEQ=$ZP(^DBTMP(PIO,GRP,""))+1
	I LSEQ<101 S LSEQ=101,LINE=5,^DBTMP(PIO,GRP,0)="3,1,3" ; 2nd of detail
	E  S LINE=$P(^DBTMP(PIO,GRP,0),",",1)+2
	S TAB=1
	;
	;
QD1	;
	;
	;
	; ===== Delete old definitions from this report section
	;
	S X=100 F I=1:1 S X=$O(^DBTMP(PIO,GRP,X)) Q:X=""  K ^(X)
	;
	S NXSEQ=$$SEQUENCE(GRP)
	;
	; ===== Process user input 
	;
	F XYZ=1:1:6 I DTL(XYZ)'="" D DETAIL(DTL(XYZ))
	;
	; ===== Adjust detail region
	;
	S $P(^DBTMP(PIO,GRP,0),",",2)=LINE-^DBTMP(PIO,GRP,0)-1
	;
	I CURGRP=GRP S WINDOW=1
	;
	; ===== Quick build option on ?
	;
	I QBOPT D QB^DBSEXE2C Q
	;
	;
	; ===== Copy ^DBTMP(PIO,GRP =>> ^DBTBL(%LIBS,5,RID,GRP
	;
	S DBOPT=5 D VER^DBSEXE5
	;
	Q
	;
DETAIL(DTL)	;
	;
	;
	;
	;F I=1:1:20 S X=$P(FILES,",",I) Q:X=""  S FID(I)=X,LIB(I)=%LIBS S Y=$P(^DBTBL(%LIBS,1,X,10),"|",5) I Y'="" S LIB(I)=$E($P(Y,",",1),2,99)
	;
	F I=1:1:20 S X=$P(FILES,",",I) Q:X=""  D ^DBSIMP(%LIBS,X,.ZL,.ZF,.ER) S FID(I)=ZF,LIB(I)=ZL
	;
	S NF=I-1
	;
	S XSEQ=LSEQ-1 ; Last sequence # before change
	;
	S CNT=$L(DTL,",")
	F Z=1:1:CNT S DI=$P(DTL,",",Z) D DETAIL1
	Q
	;
DETAIL1	;
	;
	I DI="" S TAB=TAB+2 Q  ; extra spaces
	;
	; ----- "text"
	;
	I $E(DI)=$C(34),$E(DI,$L(DI))=$C(34)
	;
	I  S DESC=$E(DI,2,$L(DI)-1),LEN=$L(DESC),FMT="T",DINAM="@"_NXSEQ,DI="@"
	;
	I  D DTLSET S TAB=TAB+$L(DESC)+2,NXSEQ=NXSEQ+1 Q
	;
	; ----- form feed #
	;
	I DI="#" S LINE=LINE+1,TAB=1 Q  ; form feed
	;
	; ----- tab option &n
	;
	I DI?1"&"1N.N S TAB=$E(DI,2,99)+0 Q  ; New tab location
	;
	;
	; ============= computed operation @ column heading ; format
	;
	;                    Expression @ heading ; fmt len . dec
	;
	I DI?1E.E1"@".E S ZZ1=$P(DI,"@",1),ZZ2=$P(DI,"@",2),ZZ3=$P(DI,";",2),DI=ZZ1,COLHDR=$P(ZZ2,";",1)
	;
	I DI?1E.E1"-" S DI=$P(DI,"-",1) ; Suppress totals DI-
	;
	;
	;
	N XLIB,XFID
	;
	I DI["[" G DETAIL1X
	;
	; Invalid data items
	S OS=DI D ^DBSEXEQ4 I ER S RM=$$^MSG(1300,$G(OS)) Q
	S DI=NS
	;
DETAIL1X	;
	;
	S ER=0 F I="*","/","\","+","-","_","#","(",")" I DI[I S ER=1 Q
	;
	; ---- Computed operation
	;
	I 'ER G DETAIL1B
	;
	S LEN=NLEN,FMT=NFMT,DINAM="@"_NXSEQ,NXSEQ=NXSEQ+1,DESC=DI,DI="@" S:FMT="$" FMT="E" D DTLSET S TAB=TAB+LEN+2 Q
	;
	I ZZ3="" G DETAIL1A
	;
	S FMT=$E(ZZ3,1),LEN=$E(ZZ3,2,9)\1,ZDEC=$P(ZZ3,".",2)
	I ZDEC'=2,FMT="$" S FMT="RD"_ZDEC
	I 'ZDEC,FMT="$" S FMT="E"
	;
	;
DETAIL1A	;
	;
	D DTLSET S TAB=TAB+LEN+2,ER=0 Q
	;
DETAIL1B	;
	;
	I DI'["[" G DETAIL2
	;
	;
	S XFID=$E($P(DI,"]",1),2,99),DI=$P(DI,"]",2)
	;
	D ^DBSIMP(%LIBS,XFID,.XLIB,.XFID,.ER)
	;
	; Invalid data item - ~p1
	I ER S RM=$$^MSG(1298,DI) Q
	;
	; Invalid data item - ~p1
	I '$D(^DBTBL(XLIB,1,XFID,9,DI)) S ER=1,RM=$$^MSG(1298,DI) Q
	G DETAIL3
	;
DETAIL2	;
	S ER=1 F I=1:1:NF I $D(^DBTBL(LIB(I),1,FID(I),9,DI)) S ER=0 Q
	; Invalid data item name - ~p1
	I ER S RM=$$^MSG(1300,DI) Q
	S XLIB=LIB(I),XFID=FID(I)
	;
DETAIL3	;
	;
	S LEN=$P(^(DI),"|",2),FMT=$P(^(DI),"|",9),DESC=$P(^(DI),"|",10),DEC=$P(^(DI),"|",14)
	;
	; Default format
	;
	D FORMAT(.FMT,DEC,TAPEFMT)
	;
	S DINAM="["_XLIB_","_XFID_"]"_DI
	;
	; Duplicate name - ~p1
	I $D(XDINAM(DINAM)) S ER=1,RM=$$^MSG(871,DINAM) Q
	;
	D DTLSET ; create record
	;
	S XDINAM(DINAM)="" ; New data items added
	;
	S TAB=TAB+LEN+2 ; reserve space for next prompt
	;
	Q
	;
	; Default format for report and tape format
	;
FORMAT(FMT,DEC,TAPEFMT)	;
	;
	; FMT - input format
	;
	; DEC - decimal precision
	;
	; TAPEFMT - tape format indicator
	;
	;
	I '$D(DEC) S DEC=2
	I '$D(TAPEFMT) S TAPEFMT=0
	;
	I TAPEFMT G FORMATP
	;
	I FMT="$",DEC=2 S FMT="E" Q  ; change to edited format
	I FMT="$",DEC'=2 S FMT="RD"_DEC Q  ; decimal precision
	I FMT="U" S FMT="T"
	I FMT="F" S FMT="T"
	Q
	;
	; Fixed length tape format ID,IN,I$
	;
FORMATP	;
	I FMT="N" S FMT="IN" Q  ; IN
	I FMT="$",DEC>2 S FMT="I$"_DEC Q  ; I$n
	I FMT="$" S FMT="I$S" Q  ; I$S
	I FMT="D" S FMT="ID" Q  ; ID
	I FMT="U"!(FMT="F") S FMT="T" Q
	Q
	;
DTLSET	;
	S X=LINE*1000+TAB_"|"_DI_"|"_LEN_"|"_FMT_"||"_DINAM_"|"_DESC_"|"_$P($G(COLHDR),"|",1)
	K COLHDR
	;
	S ^DBTMP(PIO,GRP,LSEQ)=X,LSEQ=LSEQ+1
	Q
	;
	;
KILL(GRP,ID)	;
	; ---------------------------------------------------------------
	; Delete old data first
	; ---------------------------------------------------------------
	;
	; ID = ch (column header)
	;      ph (page header)
	;      grp (group header & trailer)
	;      rs  (report summary)
	;
	S X=100 F I=1:1 S X=$O(^DBTMP(PIO,GRP,X)) Q:X=""  I "@"_ID=$P(^(X),"|",2) K ^(X)
	;
	Q
	;
	; Locate next highest dummy sequence # in GRP page definitions
	;
SEQUENCE(GRP)	;
	;
	N SEQ
	S X=100 F I=1:1 S X=$O(^DBTMP(PIO,GRP,X)) Q:X=""  D SEQ1
	;
	S SEQ=$G(SEQ)+1
	Q SEQ
	;
SEQ1	;
	S Y=$P(^(X),"|",6) I Y'?1"@"1N.N Q
	I '$D(SEQ) S SEQ=0
	I $E(Y,2,99)>SEQ S SEQ=$E(Y,2,99)+0
	Q
IOBP	W $$BTM^%TRMVT Q
H1	W $$VIDREV^%TRMVT Q
H2	W $$VIDINC^%TRMVT Q
H0	W $$VIDOFF^%TRMVT Q
	;
	;
