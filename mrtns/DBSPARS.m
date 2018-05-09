DBSPARS	;Public; Data item parser
	;;Copyright(c)1997 Sanchez Computer Associates, Inc.  All Rights Reserved - 11/03/97 11:36:16 - CHIANG
	;
	; Convert DQ procedural code into MUMPS code.
	;
        ; I18N=QUIT: Exculded from I18N standards.
	; KEYWORDS:	DATA-QWIK
	;
	; INPUTS:	
	;	.X	Input				/TYP=T/NOREQ/REF=VAL
	;               Use either variable X or ZIPP array for input.
	;	.ZIPP	Input array			/TYP=T/NOREQ/REFARR:R
	;	.PSEQ	Pre/post-processor sequence	/TYP=N/NOREQ/REFARR:RW
	;       .%LIBS	DQ library name
	;
	; RETURNS:
	;	. LOOP	DQ files & data item info	/TYP/T/REFARR:RW
	;	. OM	MUMPS procedural code		/TYP=T/REFARR:W
	;	. RM	Error message			/TYP=T
	;	. ER    Error flag			/TYP=N
	;
	; EXAMPLES:
	;    ----------------------------------------------------------------
	;	      S X=" I [DEP]IRN>12 S [DEP]BOO=1" D ^DBSPARS
	;    Returns:   
	;             OM(1)=" I $P(DEP(57),""|"",1)>12 S $P(DEP(52),""|"",1)=1"
	;    ----------------------------------------------------------------
	;	      S vcscmp=1,X=" I [DEP]IRN>12 S [DEP]BOO=1" D ^DBSPARS
	;    Returns:   
	;             OM(1)=" I vbuf(0,1,"DEP.IRN")>12 S vbuf(0,1,"DEP.BOO")=1"
	;    ----------------------------------------------------------------
	;             S ZIPP(1)="I [DEP]IRN>10 .GOTO. [DEP]LNM"
	;             S ZIPP(2)="I [DEP]IRN<6 .DEFAULT. [DEP]BOO=1"
	;             D ^DBSPARS
	;    Returns:   
	;	      OM(1)=" I $P(DEP(57),""|"",1)>10 D GOTO^DBSMACRO(""[DEP]LNM"") Q"
	;	      OM(2)=" I $P(DEP(57),""|"",1)<6 D DEFAULT^DBSMACRO(""[DEP]BOO"",1,""1"",""0"",""0"")"
	;
	;---- Revision History ------------------------------------------------
	; 11/03/97 - Chiang - 26675
	;            Modified EXIT and PPLIIB sections to support && macro
	;            commands.  Replaced $ZP references with $O.
	;
	;            Removed old revision history.
	;----------------------------------------------------------------------
	;
START	N DLIB,DFID,DILIST,DI,NS,D,PFID,FID,LIB,TEXT,DINAM,zdinam
	;
	K OM,RM,XOM,ZNQ
	;
	S ZP3=201
	I '$D(ZIPP),$G(X)="" S X=" ;"
	I '$D(ZIPP) S ZIPP(1)=X ; SINGLE LINE MODE
	;
	S Z20=0 F Z21=1:1 S Z20=$O(ZIPP(Z20)) Q:Z20=""  S X=ZIPP(Z20) D EXEC
	;
	; Now move the contents of the dilist array into LOOP 
	;
	I $G(LOOP)'="NOLOOP"  D BLDLOOP^DBSLOD(.LOOP,.COMP,.fsn,.comp)
	;
	K ZIPP,X,XDINAM,SVXX,SVZ20,Z20,Z21,ZP3,ZIF,ZNQ,ZUX,PPCMD,OXFL
	Q
EXEC	;
	;
	S SVZ20=Z20,SVXX=X
	D START1
	S Z20=SVZ20
        ;
	Q
	;
START1	;
	S ER=0
	;
	;
	I X?." "1"@"1A.AN!(X?." "1"@"1A.AN1"_"1A.AN) S X=" D @"_"["_$P(X,"@",2)_"]" ; SUPPORT OLD SYNTAX @LIB
	I X?." "1"@["1A.ANP1"]" S X=" D @"_$P(X,"@",2,99)
	I X?." "1"@"1A.ANP1"/NQ" S X="D @"_"["_$P($P(X,"@",2),"/",1)_"]/NQ" ; @[NAME]/NQ
	S OX=X
	I '$D(PSEQ) S PSEQ=1 ; VPO1-VPO99
	;
	D LINE K II,L,X1,X2,X3,XPP,XY
SCAN	;
	I ER Q
	I '$D(XOM) Q
	;
	; TRY TO DECODE AGAIN
	;
	S ZP3=$O(OM(""),-1)+1,%ERR=0
XSCAN	;
	S Z20=$O(XOM(Z20)) I Z20="" G XSCAN1    ;  *** 9/27/94  XUS
	S X=OM(Z20) I $E($P(X," ",2))=";" G XSCAN ; COMMENTS
	S X=OM(Z20) K XOM(Z20) D LINE
	I 'ER G XSCAN
	S OM(Z20)=OM(Z20)_" ; ??  "_RM,ER=0,%ERR=1 G XSCAN
	;
XSCAN1	;
	; Invalid syntax
	I %ERR S ER=1,RM=$$^MSG(1475)
	K %ERR
	;
	;
	;
	K OM1,OX,SVL,XP1,XPP,ZP2
	G SCAN
	;
LINE	; Search Line for [LIB,FID]DI or [FID]DI or FID.DI
	;
	I X?1" ;".E!(X?1AN.AN1" ;".E) S OM(Z20)=X,X=OX G EXIT ; COMMENT LINE
	;
	N DINAM,L,ptr,z
	;
	S SVXX=X,ptr=0
	;
LOOP	;
	;
	F  S DINAM=$$FINDINAM^DBSDD(X,.ptr) Q:DINAM=""  D
	.	;
	.	I $E(X,ptr-$L(DINAM))="^" Q	; ^[DIR,SYS]NAME - MUMPS Network
	.	I $C(34,40,124)[$E(X,ptr) Q
	.	S XDINAM=DINAM
	.	D PARSE^DBSDD(.DINAM,"",.comp,.fsn,"",.vdd)
	.	; Invalid data item syntax - ~p1
	.	I ER S RM=$$^MSG(1303,X) Q
	.	S DILIST(DINAM)=""
	.	;
	.	S zdinam=$P(DINAM,".",2,3)
	.	S DINAM="["_$P(DINAM,".",1)_","_$P(DINAM,".",2)_"]"_$P(DINAM,".",3)
	.	;
	.	; *** BC - Modified to return I(1) if data item is inside the repeat region
	.	;
	.	I $D(ZREPEAT(DINAM)) S NS=$P(NS,"(1)",1)_"(I(1))"_$P(NS,"(1)",2,99)
	.	E  S DINAM="["_%LIBS_","_$P(DINAM,",",2) I $D(ZREPEAT(DINAM)) S NS=$P(NS,"(1)",1)_"(I(1))"_$P(NS,"(1)",2,99)
	.	;
	.	; *** BC - 07/21/94 - New client/server format
	.	I $G(vcscmp) S NS="vbuf("_""""_$P(zdinam,".",1)_""""_",vrec,"_""""_$P(zdinam,".",2)_""""_")"
	.	; ***
	.	S X=$P(X,XDINAM,1)_NS_$P(X,XDINAM,2,99)
	.	S ptr=ptr+$L(NS)-$L(XDINAM)
	;
	S ptr=0
	F  S ptr=$F(X,"@[",ptr) Q:ptr=0  I $L($E(X,1,ptr),"""")#2 D
	.	;
	.	N ptrz
	.	S ptrz=$F(X,"]",ptr) I ptrz=0 Q
	.	S DINAM=$E(X,ptr-1,ptrz-1),ptr=ptrz
	.	I DINAM?1"[^"1E.E1"]" D MPGM Q
	.	I DINAM?1"["1E.E1"]" S ZNQ=$S(X["/NQ":"NQ",1:"") D PPLIB Q
	;
	S OM(Z20)=$S(X'["/NQ":X,1:" ;") S X=OX G EXIT
	;
PPLIB	; @[PPLIB]  PRE/POST PROCESSOR LIBRARY
	;
	I ZNQ="",$D(PSEQ(DINAM)) S X=$P(X,"@"_DINAM,1)_"VPO"_PSEQ(DINAM)_$P(X,"@"_DINAM,2,99) Q
	S XPP=$E(DINAM,2,$L(DINAM)-1)
	; Invalid pre/post-processor library name - ~p1
	I '$D(^DBTBL(%LIBS,13,XPP)) S ER=1,RM=$$^MSG(1425,XPP) Q
	;
	S XP1=0 I ZNQ="" S OM(ZP3+1)="VPO"_PSEQ_" ; user library "_XPP,ZP3=ZP3+1
	S ZLIBS=%LIBS I $D(^DBTBL(%LIBS,13,XPP,-3)) S ZLIBS=^(-3) ; IMPLICIT
	F ZP2=1:1 S XP1=$O(^DBTBL(ZLIBS,13,XPP,XP1)) Q:XP1=""  S TEXT=^(XP1)  D
	.	I TEXT["&&" D				; && MACROO
	..		N in,out
	..		S in(1)=TEXT D ^DBSPARS2("",.in,.out) I ER Q
	..		S TEXT=out(1)
	.	D SET(TEXT)
	I ZNQ="" D SUBNAME
	Q
	;
MPGM	;
	;
	; @[^PGM]   MUMPS ROUTINE
	;
	I $D(PSEQ(DINAM)) S X=$P(X,"@"_DINAM,1)_"VPO"_PSEQ(DINAM)_$P(X,"@"_DINAM,2,99) Q
	S XPP=$E(DINAM,3,$L(DINAM)-1)
	; Invalid program name - ~p1
	I '$$VALID^%ZRTNS(XPP) S ER=1,RM=$$^MSG(1429,XPP) Q
	S XP1=0,OM(ZP3+1)="VPO"_PSEQ_" ; user routine "_XPP,ZP3=ZP3+1
	S FLG=0 K PGM D ^%ZRTNLOD(XPP,"PGM")
	F ZP2=1:1 S XP1=$O(PGM(XP1)) Q:XP1=""  I PGM(XP1)'?1" ;".E!FLG D SET(PGM(XP1))     ;  *** 9/27/94  XUS
	D SUBNAME
	Q
SET(TEXT)	;
	I TEXT="" Q
	S OM(ZP2+ZP3)=TEXT I TEXT?1" ;".E Q
	I OM(ZP2+ZP3)?.E1"["1E.E1"]".E S XOM(ZP2+ZP3)="" ; [FID]DI SYNTAX
	I OM(ZP2+ZP3)?.E1"."4U.U1"."1E.E,OM(ZP2+ZP3)'?1" ;".E S XOM(ZP2+ZP3)="" ; MACRO COMMAND
	I TEXT'?.E1" ;".E S FLG=1
	; Warning - line tag error - ~p1
	I $E(TEXT)="V" S RM=$$^MSG(2967,TEXT)
	Q
	;
	; REPLACE LIBRARY NAME/PROGRAM WITH VPOn
	;
SUBNAME	;
	;
	S OM(ZP2+ZP3+1)=" Q",ZP3=ZP3+ZP2+10
	S OM(195)=" Q" ; 2/15/91 RPT=SCA097
	;
	S X=$P(X,"@"_DINAM,1)_"VPO"_PSEQ_$P(X,"@"_DINAM,2,99)
	S PSEQ(DINAM)=PSEQ,PSEQ=PSEQ+1
	Q
EXIT	;
	K SAVDI,SVX,X1,X2,X3,NS,OS,PO,DILNM,DINAM,AR,DE,DF,DI,XCOMP,ZZXX
	;
	; SPECIAL MACRO COMMAND
	;
	I OM(Z20)'?1" ;".E,OM(Z20)?.E1"."1A.A1".".E K RM S OX=SVXX D ^DBSPARS1
	;
	; Parse && syntax 10/31/97
	;
	I OM(Z20)["&&" D
	.	N in,out
	.	S in(1)=OM(Z20) D ^DBSPARS2("",.in,.out) I ER Q
	.	S OM(Z20)=out(1)
	I $D(RM),RM'="" W !,RM H 2
	;
	Q
	;----------------------------------------------------------------------
TEST	; Private ; Called by DBSTEST routine
	;----------------------------------------------------------------------
	W #
	K (%LIBS,%TO)
	F I=1:1 R !!,"Input: ",X Q:X=""  S ZIPP(I)=X
	;
	D START
	;
	K (OM,ER,RM,X,LOOP,PSEQ,%LIBS,%TO,COMP,DFVBPS,DFV)
	D SYMTBL^%ZWRITE ; Dump symbol table
	W !!,"Press Return to continue or <Q>uit: " R X
	I X="Q"!(X="q") Q
	G TEST
