DBSUTL3	;; -  - V5.0 - DATA ITEM INDEX FILE MAINTENANCE UTILITY
	;;Copyright(c)2001 Sanchez Computer Associates, Inc.  All Rights Reserved - 06/10/01 18:25:25 - SPIER
	;     ORIG:  BOB CHIANG (8447) - 12/02/87
	;     DESC: Data item index file maintenance routine
	;
	;   OUTPUT:
	;
	;         Line Tag  "ENTRY" - build / list index file
	;                   "LIST"  - List partial index file
	;
        ; I18N=QUIT: Exculded from I18N standards.
	;---------- Revision History -------------------------------------------
	;
	; 08/09/06 - KELLYP - CR 21987
	;	     Modified PROC section to check for PSL comments in addition
	;	     to M comments (ARQ 44861 below).  Also modified SCREEN
	;	     section not to process z-named "temp" screens.
	;
	; 07/10/06 - RussellDS - CR22121
	;	     Removed LIST section to eliminate use of $A and $C to make
	;	     Unicode compliant.  Section is not called by any other
	;	     code or function and same functionality is available at
	;	     ENTRY tag to get report.
	;
	; 06/10/01 - SPIER - 44861
	;            Modified PROC section to assure that only the code before the
	;	     ";" is checked.
	;
	; 08/02/00 - SPIER - 41377
	;            Modified BUILD section to under PSL triggers and journals
	;	     comments
	;
	; 11/13/97 - Bob Chiang - 26815
	;            Modified REPORT1 section to include logic to parse Report
	;            Summary definition.
	;            Replaced $ZP references with $O.
	;            Removed old revision history.
	;
	; 12/20/96 - Bob Chinag - 20948
	;            Modified BUILD section to include logic to build data item
	;            cross reference files for Trigger, Index ,Journal and
	;            executive definitions.
	;
	;-----------------------------------------------------------------------
START	; Called by routines FORMDQ2 and FORMDQ5 to update index entries
	;----------------------------------------------------------------------
	; INPUTS:
	;           DBOPT      - DQ FUNCTION  2=screen 5=report 6=QWIK report
	;           ID         - FUNCTION NAME (screen/report/quick report Id)
	;           DQFUN      - FUNCTION (A-ADD D-DELETE)
	; EXAMPLES:
	;
	;    S DBOPT=2,ID="CIFTYP",DQFUN="A"
	;----------------------------------------------------------------------
	D SET
	Q
	;----------------------------------------------------------------------
SCREEN	;  Level 2 (screen definition)
	;----------------------------------------------------------------------
	;
	I '$D(^DBTBL(%LIBS,DBOPT,ID)) Q
	I $E(ID,1)="z" Q	; Don't process temp screens
	S LIB=%LIBS I $G(^(ID,-3))'="" S LIB=^(-3)
	;
	; ---------- Screen Processors
	;
	S x="" F  S x=$O(^DBTBL(LIB,DBOPT,ID,0,x)) Q:x=""  D PROC(^(x))
	;
	S Z=$O(^DBTBL(LIB,DBOPT,ID,""),-1) ; last sequence number
	;
	F I=1:1:Z S ZDINAM=$P($G(^DBTBL(LIB,DBOPT,ID,I)),"|",5) D ADD D
	.	; Field pre/post-processor
	.	;
	.	S x="" F  s x=$O(^DBTBL(LIB,DBOPT,ID,I,x)) Q:x=""  D PROC(^(x))
	D ADDPP
	Q
	;
	;
	;----------------------------------------------------------------------
QUERY	; Level 4 (query definition)
	;----------------------------------------------------------------------
	I '$D(^DBTBL(%LIBS,DBOPT,ID)) Q
	S LIB=%LIBS I $G(^(ID,-3))'="" S LIB=^(-3)
	;
	F I=1:1 Q:'$D(^DBTBL(LIB,DBOPT,ID,I))  D PARSE(^(I))
	Q
	;
	;----------------------------------------------------------------------
REPORT	; Level 5 (report definition)
	;----------------------------------------------------------------------
	;
	I '$D(^DBTBL(%LIBS,DBOPT,ID)) Q
	S LIB=%LIBS I $G(^(ID,-3))'="" S LIB=^(-3)
	;
	S ZLEV=""
	;
REPORT1	;
	S ZLEV=$O(^DBTBL(LIB,DBOPT,ID,ZLEV)) I ZLEV="" Q
	;
	; Sequence By & Query definitions
	;
	I ZLEV?1N.E S X=$P($G(^(ZLEV)),"|",1) D PROC(X)
	;
	S Z=$O(^DBTBL(LIB,5,ID,ZLEV,""),-1) I Z="" G REPORT1
	F I=101:1:Z S ZDINAM=$P(^DBTBL(LIB,DBOPT,ID,ZLEV,I),"|",6) D ADD D
	.	; Field pre/post-processor
	.	;
	.	S x="" F  s x=$O(^DBTBL(LIB,DBOPT,ID,ZLEV,I,x)) Q:x=""  D PROC(^(x))
	S I="" F  s I=$O(^DBTBL(LIB,DBOPT,ID,"@RS",I)) Q:I=""  D PROC(^(I))
	G REPORT1
	;
	;----------------------------------------------------------------------
QUICK	; Level 6 (QWIK report definition)
	;----------------------------------------------------------------------
	I '$D(^DBTBL(%LIBS,DBOPT,ID)) Q
	S LIB=%LIBS I $G(^(ID,-3))'="" S LIB=^(-3)
	;
	S ZFID=$P(^DBTBL(LIB,DBOPT,ID,0),"|",1)
	F I=12:1:17 I $G(^DBTBL(LIB,DBOPT,ID,I))'="" D QUICK1
	F I=1:1:10 I $G(^DBTBL(LIB,DBOPT,ID,I))'="" D PARSE(^(I))
	Q
	;
QUICK1	;
	S Z=^(I)
	I Z?1"@WPS".E Q
	F J=1:1 S ZDINAM=$P(Z,",",J) Q:ZDINAM?." "  D QUICK2
	Q
	;
QUICK2	;
	I ZDINAM?1"["1E.E1"]"1E.E D ADD Q
	;
	F ZA=1:1 S ZF=$P(ZFID,",",ZA) Q:ZF=""  I $D(^DBTBL(%LIBS,1,ZF,9,ZDINAM)) S ZDINAM="["_ZF_"]"_ZDINAM Q
	D ADD
	Q
	;----------------------------------------------------------------------
INDEX	; Level 8 (Index definition)
	;----------------------------------------------------------------------
	N di,i,idx,v
	S idx="" F  S idx=$O(^DBTBL(%LIBS,8,ID,idx)) Q:idx=""  D
	.	S v=$P(^(idx),"|",3)
	.	F i=1:1:$L(v,",") D
	..		S di=$P(v,",",i)
	..		I '((di?1A.AN)!(di?1"%".AN)) Q	; Dummy key
	..		S ^DBINDX(%LIBS,"DI",8,ID,di,idx)=""
	Q
	;----------------------------------------------------------------------
FILER	; Level 7 (Trigger) and level 9 (Journal)
	;----------------------------------------------------------------------
	N gbl,len,pgbl,key,fid,di
	S pgbl="^DBTBL("_""""_%LIBS_""""_","_DBOPT
	S gbl=pgbl_")",len=$L(pgbl)
	;
	n multicomment
	S multicomment=0
	F  S gbl=$Q(@gbl) Q:gbl=""!($E(gbl,1,len)'=pgbl)  S X=@gbl D
	.	I X["/*" S multicomment=1 Q
	.	I multicomment,X'["*/" Q
	.	I multicomment s multicomment=0 Q
	.	S X=$P(X,"//",1)
	.	S ptr=0 F  S dinam=$$FINDINAM^DBSDD(X,.ptr) Q:dinam=""  D
	..		S key=$P(gbl,"""",4)_"-"_$P(gbl,"""",6)
	..		S fid=$P(dinam,".",1),di=$P(dinam,".",2) ; fid.di
        ..              I fid=""!(di="") D  Q
        ...                     I $L(gbl,",")<5 Q              ; Header record
        ...                     W !,gbl,!,X Q	               ; Invalid syntax
	..		S ^DBINDX(%LIBS,"DI",DBOPT,fid,di,key)=""
	..		;W !,key
	Q
	;
	; Add New Entry
	;
ADD	;
	I ZDINAM="" Q
	I ZDINAM["#"!(ZDINAM["&") Q
	I ZDINAM?1"@".E Q
	I ZDINAM["," S ZDINAM="["_$P(ZDINAM,",",2)
	S Z1=$P(ZDINAM,"]",1),Z1=$E(Z1,2,99),Z2=$P(ZDINAM,"]",2)
	I Z1=""!(Z2="") Q
	;
	; Invalid Name [~p1]~p2
	I DQFUN="A",'$D(^DBTBL($$LIB(%LIBS,Z1),1,Z1,9,Z2)) W !,ID,?15,$$^MSG(1408,Z1_"."_Z2),!
	;
	; ---------- Update this index file on HOST only
	;
	I $G(%LOGIN)'="",$P(%LOGID,"|",1)'="HOST" Q
	;
	I DQFUN="A" S ^DBINDX(%LIBS,"DI",DBOPT,Z1,Z2,ID)="" Q
	I DQFUN="D" K ^DBINDX(%LIBS,"DI",DBOPT,Z1,Z2,ID) Q
	Q
	;
LIB(LIB,FL)	;
	N Z1
	I '$D(^DBTBL(LIB)) Q LIB
	;
	S Z1=$P($G(^DBTBL(LIB,1,FL,10)),"|",5) I Z1="" Q LIB
	Q $P($P(Z1,",",1),"[",2)
	;
ADDPP	; Add/Delete PRE/POST-PROCESSOR entry
	;
	I $G(LIB)="" S LIB=%LIBS
	S ON=0
	;
	S X=0 F I=1:1 S X=$O(^DBTBL(LIB,DBOPT,ID,0,X)) Q:X=""  S P=^(X) D CHK
	S SEQ=0
NSEQ	;
	S SEQ=$O(^DBTBL(LIB,DBOPT,ID,SEQ)) I SEQ="" Q      ;  *** 9/27/94  XUS
	S PP=0
NPP	;
	S PP=$O(^DBTBL(LIB,DBOPT,ID,SEQ,PP)) I PP="" G NSEQ
	S P=^(PP)
	D CHK G NPP
	;
CHK	;
	;
	; ============ D @[PPLIB]    D @[PPLIB]/NQ   D @[PPLIB] ;
	;
	S XP=P
	I P?." "1"D @["1E.E1"]".E S P=$P(P,"]",1),P=$P(P,"[",2) D SETPP Q
	I P?." "1"@"1A.AN!(P?." "1"@"1A.AN1"_"1A.AN) S P=$P(P,"@",2) D SETPP Q
	I P?." "1"@["1A.ANP1"]" S P=$P(P,"[",2),P=$P(P,"]",1) D SETPP Q
	Q
	;
	;-----------------------------------------------------------------------
PROC(S)	; Private ; Parse Screen/report processors for [fid]di syntax
	;-----------------------------------------------------------------------
	N x,dinam
	S S=$P(S,";",1)
	S S=$P(S,"//",1)
	D PARSE(S,.dinam)
	S x="" F  S x=$O(dinam(x)) Q:x=""  S ZDINAM=x D ADD
	Q
	;-----------------------------------------------------------------------
PARSE(X,TABLE)	;
	;-----------------------------------------------------------------------
	; Utility routine to parse out data item names
	;
	; X  = input string
	; TABLE () = output array table
	;
	; Example:
	;
	;  S X="abc+[DEP]BAL+100-[CIF]TAXID+[SYSDEV,LN]IRN"
	;  D PARSE(X,.ABC)
	;
	;   Return:  ABC("[DEP]BAL")=""
	;            ABC("[CIF]TAXID")=""
	;            ABC("[SYSDEV,LN]IRN")=""
	;
	N X1,X2,X3,L,II,DINAM,DFID,ER
	S L=1,ER=0
LOOP	;
	S L=$F(X,"[",L) I L=0 Q
	I $E(X,L-2)="^" G LOOP ; ^[DIR,SYS]NAME - NETWORK SYNTAX
	I $E(X,L-2)=$C(34) G LOOP ; "["
	;
	S X1=$E(X,L-1,999) I X1'["]" G LOOP
	S X2=$P(X1,"]",1),X3=$P(X1,"]",2,99)
	S X1=$E(X2,2,99) I X1["[" G LOOP
	S DFID=X1 I DFID["," S DLIB=$P(DFID,",",1),DFID=$P(DFID,",",2)
	F II=1:1:$L(X3) I '(($E(X3,II)="%")!($E(X3,II)?1AN)) S II=II-1 Q
	S DINAM=X2_"]"_$E(X3,1,II)
	I $E(X3,II+1)=$C(34)!($E(X3,II+1)=$C(124))!($E(X3,II+1)=$C(40)) G LOOP
	I $E(X,L-2)="@",DINAM?1"["1E.E1"]"1E.E Q
	;
	I '((DINAM?1"["1A.E1"]"1A.AN)!(DINAM?1"["1A.E1"]%"1A.AN)) G LOOP
	S TABLE(DINAM)=""
	G LOOP
	Q
	;
SETPP	;
	I $G(^DBTBL(%LIBS,13,P,-3))'="" Q  ; Implicit
	;
	I DQFUN="D" K ^DBTBL(%LIBS,13,P,-DBOPT,ID) Q
	;
	I $D(^DBTBL(%LIBS,13,P)) S ^DBTBL(%LIBS,13,P,-DBOPT,ID)=""
	;  Invalid pre/post-processor name 
	E  W !,ID,$$^MSG(8143),P,!
	Q
	;-----------------------------------------------------------
	; Entry point for DQ utility function "DBSUTL3"
	;-----------------------------------------------------------
	;
ENTRY	;
	S OLNTB=35
	;
	S %TAB("%A1")=".%A11"
	S %TAB("%A2")=".%A21"
	S %A1=0,%A2=1
	;
	S %READ="@@%FN,,%A1/REQ,,%A2/REQ,",%FRAME=2	; *** BC - Frame option 09/08/93
	D ^UTLREAD I VFMQ="Q" Q
	;
	I %A1 D ^SCAIO,BUILD
	I %A2 S RID="DBINDX" D DRV^URID    ; *** XUS 08/09/94
	Q
	;
	;-----------------------------------------------------------
	; Rebuild Data Item Index File
	;-----------------------------------------------------------
%EXT	;
	I '$D(%LIBS) S %LIBS=^CUVAR("%LIBS")
	;
BUILD	;
	;
	N OLNTB,%TAB,DQOPT,DBOPT,i
	S i="" F  S i=$O(^DBCTL("SYS","DBOPT",i)) Q:i=""  S DQOPT(i)=^(i)
	;
	S DQOPT("A")="All"
	;
	I $G(IO)="" S IO=$I
	U IO
	F DBOPT=13,2:1:9 D BUILD1		; *** 06/12/96
 	D CLOSE^SCAIO
	Q
	;
BUILD1	;
	S ID=""
	W !!,DQOPT(DBOPT)," Definitions"
	K ^DBINDX(%LIBS,"DI",DBOPT)
	I DBOPT=3!(DBOPT=7)!(DBOPT=9) D FILER Q		; *** 06/12/96
	D BUILD2
	Q
	;
BUILD2	;
	S ID=$O(^DBTBL(%LIBS,DBOPT,ID)) Q:ID=""
	W "." I $X>70 W !
	S DQFUN="A" D SET
	G BUILD2
	Q
SET	;
	N LIB
	I DBOPT=2 D SCREEN Q
	I DBOPT=4 D QUERY Q
	I DBOPT=5 D REPORT Q
	I DBOPT=6 D QUICK Q
	I DBOPT=8 D INDEX Q			; *** 06/13/96
	I DBOPT=13 D QUERY Q
	Q