DBSTAPIN	;; -  - V3.5 - Compile Conversion Routine from ^CNVTBL layout
	;;Copyright(c)2000 Sanchez Computer Associates, Inc.  All Rights Reserved - 04/03/00 16:10:29 - TANY
	;     ORIG:  Allan R. Mattson (6915) - 08/28/89
	;     DESC:
        ; I18N=QUIT: Exculded from I18N standards.
	;
	; GLOBALS - ^DBTBL(%LIB,9,^ACN,^ADDR,^CIF
	;     READ: ^DBTBL(%LIB,9
	;      SET: ^ACN,^ADDR,^CIF
	;
	;    INPUT: Tape created by distributor from DBTBL based file
	;                 layout (DBSREC).
	;   OUTPUT:
	;
	;---- Revision History ------------------------------------------------
	; 04/03/00 - TANY - 37915
        ;            Optimized performance by modifying ^SCADAT1 calls
        ;            to ^SCAJD. Also remove revision history older than
        ;            one year.
	;
	;----------------------------------------------------------------------
	;
	Q
	;
ENT	S REC=$$^%ZREAD(DEVICE,.ER) D HEADER I ER Q
	S RTB="$$RTB^%ZFUNC(DATA)"
	S PGMNAM="T"_($J#100000)
	K ^TMP($J)
	;
	; Compiling run-time conversion routine 
	U 0 W !!,$$^MSG(8107) D ^%T
	S PGMID=0 D ^%ZRTNLOD("DBSTAP1","^TMP($J,0"),BUILD
	S PGMID="" D CMPRTN
	;
	; Conversion started 
	U 0 W !!,$$^MSG(8108) D ^%T W !
	S PGM=PGMNAM_0 D ^@PGM
	S PGMID="" D DELRTN
	K ^TMP($J)
	Q
	;
HEADER	; Header record - determine global name based on FILEID
	S FILEID=$E(REC,2,9),FILEID=$$RTB^%ZFUNC(FILEID)
	;
	S CONAM=$E(REC,12,51),CONAM=$$RTB^%ZFUNC(CONAM)
	S DATE=$E(REC,92,99),DATE=$$RTB^%ZFUNC(DATE)
	S EFD=$$^SCAJD(DATE)
	;
	; File ID is 
	U 0 W !!,$$^MSG(8110)_""_FILEID_""""
	; Company ID is 
	W !,$$^MSG(8106)_""_CONAM_""""
	; Effective date is 
	W !,$$^MSG(8109),DATE
	;
	; File name on tape does not match - 
	I FILEID'=FN W !!,$$^MSG(8111),FILEID," - ",FN
	S ER=0
	;
	; OK to continue?  
CONT	N MSG,X
	S MSG=$$^MSG(8113)  
	S X=$$^DBSMBAR(1,"","",1)
	I X=1 Q
	D EXIT^DBSTAP1
	S ER=1 Q
	Q
	;
BUILD	; Build routine
	F I="CIFS","LNBIL0","LNBIL1" S CMPFIL(I)=""
	S (FN,FNUM,RECID,RECNUM)=""
	;
FN	S FN=$O(^CNVTBL(FILEID,FN)) I FN="" Q
	I FN="LNBIL0"!(FN="LNBIL1") G FN
	I '$D(^DBTBL(%LIBS,1,FN)) G FN
	D KEYS S X=" Q" D CMPLIN
	S FNUM=FNUM+1
	S FN(FN)=FNUM
	S KEY=""
	;
RECID	S RECID=$O(^CNVTBL(FILEID,FN,RECID)) I RECID="" G FN
	I "23"'[RECID G RECID
	;
RECNUM	S RECNUM=$O(^CNVTBL(FILEID,FN,RECID,RECNUM)) I RECNUM="" G RECID
	I FN="LN" S PGMID=RECNUM ; Required to avoid <STORE> errors
	E  S PGMID=0
	;
	S X=FNUM_RECID_RECNUM_" S DATA=REC,DATA="_RTB_" I DATA="""" Q" D CMPLIN
	S TSEQ=3,(NOD,XNOD)="" D TSEQ
	I RECID=2,$L(NOD) D CMPSET
	I RECID=2,'$D(^CNVTBL(FILEID,FN,2,1,5)) D CMPKEY
	S X=" Q" D CMPLIN
	G RECNUM
	;
TSEQ	S TSEQ=$O(^CNVTBL(FILEID,FN,RECID,RECNUM,TSEQ)) I TSEQ="" Q
	S D=^(TSEQ),DI=$P(D,"|",1)
	I $D(KEY(DI)) G TSEQ
	I DI="FILL" G TSEQ
	;
	S X=$G(^DBTBL(%LIBS,1,FN,9,DI))
	;
	; Invalid data item ~p1
	I X="" U 0 W !,$$^MSG(1298),!,"   ["_FN_"]"_DI_" - "_$P(D,"|",8) G TSEQ
	S NOD=$P(X,"|",1),POS=$P(X,"|",21) S:POS="" POS=1
	;
	I RECID=2,$L(NOD),NOD'=XNOD D:$L(XNOD) CMPSET D CMPINI S XNOD=NOD
	I $L(NOD) S $P(D,"|",9)=NOD,$P(D,"|",10)=POS D CMP G TSEQ ; Mapped
	I $L($P(X,"|",16)),$D(CMPFIL(FN)) D CMP G TSEQ ; Computed
	U 0 W !,"Node not defined in ^DBTBL for ["_FN_"]"_DI
	G TSEQ
	;
KEYS	; Define key level(s)
	S GBL=^DBTBL(%LIBS,1,FN,0),GBL="^"_GBL_"("
	K KEYS S X=FN_" ;" D CMPLIN
	;
	Q:'$D(^CNVTBL(FILEID,FN,1,1))  
	S KEY=0,KEYIDS=$P($G(^DBTBL(%LIBS,1,FN,16)),"|",1) D K1	; SMM 02/12/97
	I FN="DEP"!(FN="LN") S X=" S ^XCNV(XSEQ,CID)=""""" D CMPLIN
	I OPTION=1 S X=" S RECOF=$D("_$E(GBL,1,$L(GBL)-1)_"))" D CMPLIN
	Q
	;
K1	S KEY=KEY+1,KEYID=$P(KEYIDS,",",KEY) I KEYID="" Q	; SMM 02/12/97
	F V=1:1 I $P(^CNVTBL(FILEID,FN,1,1,V),"|",1)=KEYID D K2 Q
	G K1
	;
K2	S GBL=GBL_KEYID_","
	S KEY(KEYID)=""
	S D=^(V) D CMP
	Q
	;
CMP	; Compile executable MUMPS code
	S FMT=$P(D,"|",2),BEG=$P(D,"|",6),END=BEG+$P(D,"|",4)-1
	S X=" S DATA=$E(REC,"_BEG_","_END_"),DATA="_RTB_" I $L(DATA)"
	;
	; Format data
	I FMT="$" S X=X_" S DEC="_+$P(D,"|",5)_" D DOL"
	E  I FMT="N" S X=X_" S DATA=+DATA"
	E  I FMT="D" S X=X_" D DAT"
	E  I FMT="L" S X=X_" D LOG"
	E  I FMT="U" S X=X_" D UPPER"
	;
	I KEY S:KEYID'?.N&(KEYID'["""") X=X_" S "_KEYID_"=DATA"
	;
	; Update string
	E  I $L(NOD) S X=X_" S $P(STRING,"_"""|"""_","_POS_")=DATA ; "_DI
	E  S X=X_" S $P(STRING,"_"""|"""_","_POS_")=DATA ; "_DI
	;
CMPLIN	; Compile a line
	S L=$O(^TMP($J,PGMID,""),-1)+1
	S ^TMP($J,PGMID,L)=X
	Q
	;
CMPINI	; Compile global init
	I RECID=3 Q
	N X S X=" ;" D CMPLIN
	N X S X=$S($D(KEY(NOD)):$E(GBL,1,$L(GBL)-1),1:GBL_NOD)
	S X=" S STRING=$G("_X_"))"
	D CMPLIN
	Q
	;
CMPSET	; Compile global SET
	I RECID=3 Q
	N X S X=$S($D(KEY(XNOD)):$E(GBL,1,$L(GBL)-1),1:GBL_XNOD)
	S X=" I $L(STRING) S "_X_")=STRING"
	D CMPLIN
	Q
	;
CMPKEY	; Compile global SET at key level (no data to the right side of '=')
	N X S X=$E(GBL,1,$L(GBL)-1)
	S X=" S "_X_")=$G("_X_"))"
	D CMPLIN
	Q
	;
CMPRTN	; Compile routine(s)
	S PGMID=$O(^TMP($J,PGMID)) I PGMID="" Q
	D ^%ZRTNLOD("DBSTAP2","^TMP($J,PGMID","","",1)
	D ^%ZRTNCMP(PGMNAM_PGMID,"^TMP($J,"_PGMID)
	G CMPRTN
	;
DELRTN	; Delete compiled routine(s)
	S PGMID=$O(^TMP($J,PGMID)) I PGMID="" Q
	D DEL^%ZRTNDEL(PGMNAM_PGMID)
	G DELRTN
