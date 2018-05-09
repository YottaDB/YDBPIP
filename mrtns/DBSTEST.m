DBSTEST	;;PBS -  - V5.0 - QUERY SELECTION MUMPS CODE PARSER 
	;;Copyright(c)1997 Sanchez Computer Associates, Inc.  All Rights Reserved - 08/12/97 14:59:59 - NIB
	;     ORIG: Frank Sanchez (2497)
	;     DESC: General purpose query integrity verification
	;           o Tests for valid arguement syntax
	;           o Tests for valid data items
	;           o Tests for valid comparisons
	;
	;---- Revision history -------------------------------------------------
	; 02/15/07 - RussellDS - CR25356
	;	     Eliminated use of obsoleted routine DBSQRYA.
	;
	; 11/29/05 - RussellDS - CR18065
	;	     Removed use of DBSPARS, which is to be obsoleted.
	;
	; 08/12/97 - Betty Ndi - 25653
        ;            Replace follows operator "]" with a "]]".
	;
        ; 10/17/96 - Bob Chiang - 20948
        ;            Modified to replace node 1-7 references with node 16
        ;            (file access keys).
	;
	; 02/23/96 - SPIER - 20925
	;            Added new utility to display converted DQ queries to SQL
	;
	; 01/29/96 - Bob Chiang - 17591
	;            Modified to remove lookup table test option.  The standard
	;            DBSTEST2 utility now handles all lookup table related
	;            testing.
	;
	; 01/15/95 - Bob Chiang - 17195
	;            Introduced new options to access MSQL test routines.
	;
	;-----------------------------------------------------------------------
	; I18N=QUIT
	;----------------------------------------------------------------------
A	;
	I $G(%LIBS)="" N %LIBS S %LIBS=^CUVAR("%LIBS")
	S OLNTB=50
	;
	S (%A1,%A2,%A4,%A5,%A6,%A7,%A8,%A9,%A10,%A11)=0   
	S %TAB("%A1")="/DES=DATA-QWIK Query Syntax/TYP=L/LEN=1"
        S %TAB("%A2")="/DES=Report Display Format/TYP=L/LEN=1"
        S %TAB("%A4")="/DES=File Relationship/TYP=L/LEN=1"
        S %TAB("%A5")="/DES=DATA-QWIK Utility (UTLREAD,DBSMENU,DBSTBL)/TYP=L/LEN=1"
	S %TAB("%A6")="/DES=SQL Command (Tutorial)/TYP=L/LEN=1"
	S %TAB("%A7")="/DES=SQL SELECT statement (QWIK report)/TYP=L/LEN=1"
	S %TAB("%A8")="/DES=Convert DATA-QWIK Query to SQL/TYP=L/LEN=1"
	;
	S %READ="@@%FN,%A1,%A8,%A2,%A4,%A5,%A6,%A7"
	S %FRAME=2
	D ^UTLREAD I VFMQ="Q" Q
	I %A1 D QUERY G A
	I %A2 D TEST^DBSEXEP G A
	I %A4 D REL G A
	I %A5 D ^DBSTEST1 G A
	I %A6 D ^DBSTEST9 G A				; *** 10/06/95 BC
	I %A7 D ^DBSTESTQ G A				; ***
	I %A8 D CVTQUERY G A				; 2/22/96 MAS
	;
	;
QUERY	;
	;
	D TEST1 I ER Q
	;
QUERYA	;
	D TERM^%ZUSE($I,"WIDTH=81")		; *** 07/29/94 BC
	S OLNTB=5,ER=0,%TO=999,XY="" K Q
	S %NOPRMT="F"
	I '$D(SEQBY) S SEQBY=$S($D(^SEQBY):^SEQBY,1:"")
	;
	S %TAB("QI")=".DBSTEST2"                    ; *** XUS I18N#9 "|255|||||D ^DBSQRY||T"
	K OLNTB S %READ="@@%FN,,@FILES/REV,,QI*10/REQ" D ^UTLREAD
	I '$D(Q) Q
	;
	W $$CLR^%TRMVT(12)
	;
	F NI=1:1 Q:'$D(Q(NI))  K RM D DISPLAY^DBSQRY D
	.	F I=1:1 Q:'$D(RM(I))  W $P(RM(I),"|",1),!
	K RM
	;
	W !,$$MSG^%TRMVT("Complete",1,1) 
	G QUERY
	;
TEST1	;
	S SEQBY="",ER=0 K (%UID,%TO,%LIBS,%FN)
	S X=$S($D(^TMP($J))#10:^($J),1:"")
	; Access File(s): 
	W !!,"Access File(s): "_X_"=> " R FILES S:FILES="" FILES=X I FILES="" S ER=1 Q
	S DFID=$P(FILES,",",1),DLIB=%LIBS,X="" D ^DBSDI G ERR:ER
	I '$D(^DBTBL(LIB,1,FID)) W " ??" G TEST1
	;
	S SEQBY=""
	S AKEYS=^DBTBL(LIB,1,FID,16)				; *** 10/17/96
	F IX=1:1:$L(AKEYS,",") S SEQBY=SEQBY_"["_%LIBS_","_FID_"]"_$P(AKEYS,",",IX)_"|"
	S SEQBY=$E(SEQBY,1,$L(SEQBY)-1),^TMP($J)=FILES
	Q
	;
CVTQUERY;
	; Convert DATA-QWIK query to SQL query
	;
	N %FRAME
	S %FRAME=2
	S SID="DBSQCONV" D ^USID
	D ^@PGM
	Q
	;
	; FILES RELATIONSHIP
	;
REL	;
	; Access File(s): 
	W !!,"Access File(s): " R FILES I FILES="" Q
	D ^DBSFVER
	I ER W !!,RM,! G REL
	K (%FN,LOOP,FILES,%LIBS,MAXFL,XFILE)
	W !!
	D SYMTBL^%ZWRITE ; Write symbol table
	K (%FN,%LIBS)
	G REL
	;
RELQA	;
	U 0 W !!,"File Relationship Verification Report ... Continue (Y/N): " R YN
	;
	I YN="N" Q
	I YN'="Y" G RELQA
	;
	S SID="",%TO=60
	D ^SCAIO
	;
	U 0 W !!,"<S>creen or <R>eport: " R DTYPE I DTYPE="" Q     ; "<S>creen or <R>eport: "
	I '((DTYPE="S")!(DTYPE="R")) Q
	;
	I DTYPE="S" S DTYPE=2
	E  S DTYPE=5
	S SID="",ZSID="Z"
	S LINE="" F I=1:1:40 S LINE=LINE_"-"
	D NREL
	W !!
	D CLOSE^SCAIO
	Q
	;
	;
NREL	;
	K LOOP,COMP,%FID
	S SID=$O(^DBTBL(%LIBS,DTYPE,SID)) I SID=""!(SID]]ZSID) W ! Q    ;  *** 9/27/94  XUS
	S FILES=$P($G(^(SID,0)),"|",1)
	I FILES'["," G NREL
	;
	U IO W !,LINE,!,SID,?20,FILES,!,LINE,!
	D ^DBSFVER
	I $G(ER) U IO W ER,! G NREL
	U IO ZWR LOOP,ER
	G NREL
	;
ERR	;
	W $$BTM^%TRMVT,$$VIDREV^%TRMVT," ",RM," ",$$VIDOFF^%TRMVT Q
	;
CUR	W $$CUPXY^%TRMVT(DX+1,DY+1) Q
IOCP	W $$CLP^%TRMVT Q
IOF	W $$CLEAR^%TRMVT Q
