%GTMCONV	;M Utility;M/VX to GT.M conversion routine
	;;Copyright(c)1994 Sanchez Computer Associates, Inc.  All Rights Reserved - 04/28/94 17:34:32 - SYSRUSSELL
	; ORIG:  Frank R. Sanchez (2497)
	;
	; KEYWORDS:	Conversion
	;
	W !!,"Convert files from M/VX to GT.M",!
	D ^%RSEL Q:'$D(%ZR)
	;
	S $ZT="G ERROR",NFILE=""
	S CONAM=$G(^CUVAR("CONAM")),%ED=$$^%ZD($H),IORM=132,IOSL=60
	S IO="GTMCONV.LOG" O IO:(NEWV)
	W !,"Output report to ",IO D HDG
	;
MASTER	;------------------- Master section -------------------------------
	;
	S NFILE=$O(%ZR(NFILE)) G EXIT:NFILE="" I $E(NFILE,1,3)="GTM" G MASTER
	U 0 W !,NFILE
	S FILE=%ZR(NFILE)_$TR(NFILE,"%","_")_".M"
	I $ZSEARCH(FILE)="" U IO W !," *** ",FILE," not found ***",! G MASTER
	O FILE:(REC=510):1 E  U IO W !," **** ",FILE," currently locked ****",! G MASTER
	S (FLAGA,FLAGB,FLAGC)=0 K X,ERR
	F L=1:1 U FILE R LN Q:$ZEOF  S X(L)=LN D CHECK,ERR:$D(ERR)
	C FILE
	I FLAGA D COMPILE
	G MASTER
ERR	;
	;
	S ERR="",TYPE="",FLAGC=0,LM1=0
	F I=0:0 S ERR=$O(ERR(ERR)) Q:ERR=""  S TYPE=TYPE_ERR_"," D FIX S X(L)=X
	I $E(TYPE,$L(TYPE))="," S TYPE=$E(TYPE,1,$L(TYPE)-1)
	D PNTRPT
	K ERR Q
	;
FIX	;
	S X=X(L)
	S Y=0 F I=0:0 D FIXA Q:'Y
	Q
FIXA	; FLAGA indicates if need to file new version
	; FLAGC indicates if want to see change on report
	I ERR="U" S FLAGC=1 D USE Q:'Y
	I ERR="O" S FLAGC=1 D OPEN Q:'Y
	I ERR="$ZN" S FLAGC=1 D ZN Q:'Y
	I ERR="$ZT" D ZT Q:'Y
	I ERR="B 0" S FLAGC=1 D BREAK Q:'Y
	I ERR="B 1" S FLAGC=1 D BREAK Q:'Y
	I ERR="$ZE" S FLAGC=1 D ZE Q:'Y
	I ERR="^%" D %RTNS Q:'Y
	I ERR="$ZF" S FLAGC=1 D ZF Q:'Y
	I ERR="IO" S FLAGC=1 D IO Q:'Y
	;I ERR="^[" S FLAGC=1 D GLOBAL Q:'Y
	I ERR="ROUTINE" S FLAGC=1 Q:'Y
	I ERR="%SYS" S FLAGC=1 D %SYS Q:'Y
	I ERR="ZI"!(ERR="ZL")!(ERR="ZR")!(ERR="ZS")!(ERR="ZU") S FLAGC=1
	I ERR="$Z" S FLAGC=1
	I ERR="*-" S FLAGC=1
	Q
PNTRPT	; Print report
	; To print all changes, enable next line
	;S FLAGC=1
	I 'FLAGA,'FLAGC Q  ; Don't print
	;
	U IO I ($Y+4)>IOSL D HDG
	I 'FLAGB W !,FILE S FLAGB=1
	W !,?10,$J(L,3),?15,TYPE I $X>20 W !
	W ?20,LN W:LM1 !?20,X(L-.1) W !?20,X,!
	Q
	;
HDG	;
	S RN="GTM SYNTAX CONVERSION"
	S HDG(1)="ROUTINE   LIN  TYPE INTERSYSTEMS / GREYSTONE"
	U IO W #,RN,?120,$$^%ZD($H),!!,HDG(1),!
	F I=1:1:130 W "-"
	W !
	Q
	;
USE	;------------------- USE command conversion --------------------------
	; Handle most popular expressions - transalate to ^%ZUSE
	S OS="U 0:(0:""S"")" I X[OS S NS="D TERM^%ZUSE(0,""NOECHO"")" D CHANGE G USE
	S OS="U $I:(0:""S"")" I X[OS S NS="D TERM^%ZUSE($I,""NOECHO"")" D CHANGE G USE
	S OS="U $I:(0:""A"")" I X[OS S NS="D TERM^%ZUSE($I,""ECHO/ESCAPE"")" D CHANGE G USE
	S OS="U IO:255" I X[OS S NS="D TERM^%ZUSE(IO,""WIDTH=255"")" D CHANGE G USE
	S OS="U $I:2048" I X[OS S NS="D TERM^%ZUSE($I,""WIDTH=510"")" D CHANGE G USE
	S OS="U IO:(132:0)" I X[OS S NS="D TERM^%ZUSE(IO,""WIDTH=132/ECHO"")" D CHANGE G USE
	S OS="U IO:(133:0)" I X[OS S NS="D TERM^%ZUSE(IO,""WIDTH=133/ECHO"")" D CHANGE G USE
	;
	S Y=$F(X,"U ",Y) Q:Y=0
	;
	S Z=$E(X,Y,999),Z=$P(Z," ",1)
	I Z'[":" G USE
	I Z["="!(Z["ES")!(Z["ECHO")!(Z["TERM") G USE ; Already converted
	;
	S OS="U "_Z
	;
	I Z'["(" S WID=$P(Z,":",2) S:$P(Z,":",2)>133 WID=0 S NS="U "_$P(Z,":",1)_$S(WID=0:"",1:":WI="_WID) D CHANGE G USE
	S NS="U "_$P(Z,":",1)_":(WI="
	S WID=$E($P(Z,":",2),2,99)
	I WID=0!(WID>132) S NS="U "_$P(Z,":",1)_":("
	E  S NS=NS_WID
	S OPT=$P(Z,":",3)
	I OPT["""""" S NS=NS_":ES:ECHO"
	I OPT["S" S NS=NS_":NOECHO"
	I OPT["I" S NS=NS_":TERM=$C(0)"
	I OPT["A" S NS=NS_":ES:ECHO"
	I OPT["0" S NS=NS_":ECHO"
	I OPT["1" S NS=NS_":NOECHO"
	I ")"[$P(Z,":",4) S NS=NS_")"
	E  S NS=NS_":TERM="_$P(Z,":",4)
	I NS["(:" S NS=$P(NS,"(:",1)_"("_$P(NS,"(:",2,99)
	D CHANGE G USE
	;
IO	; Some write * and $X problems
	;
	S FLAGA=1
	S Z=$P(X," ",1)
	I Z="IOCL" S X="IOCL W $C(27)_""[K"" S $X=0 Q" Q
	I Z="IOCP" S X="IOCP W $C(27)_""[J"" S $X=0 Q" Q
	I Z="IOF" S X="IOF W $C(27)_""[H""_$C(27)_""[J"" S $X=0,$Y=0 Q" Q
	Q
	;
GLOBAL	;------------------- Extended Global syntax ------------------------
	;
	S FLAGA=1
	S Y=$F(X,"^[",Y) Q:'Y
	S Z=$E(X,Y,999) I $P(Z,"]",1)["," S X=$E(X,1,Y-1)_$P($P(Z,"]",1),",",1)_"]"_$P(Z,"]",2,999)
	G GLOBAL
	;
OPEN	;------------------- OPEN command conversion ------------------------
	K MAG,EXT
	S Y=$F(X,"O ",Y) Q:'Y
	S Z=$E(X,Y,999),Z=$P(Z," ",1)
	I Z'[":" G OPEN
	S ZZ=$E(X,Y-3)
	I '(ZZ=" "!(ZZ=$C(9))) G OPEN ; Avoid R IO Q:IO="" code
	I Z["READ"!(Z["NEWV")!(Z["REC")!(Z["EBC")!(Z["FIX")!(Z["VAR") G OPEN ; Already converted
	;
	S OS="O "_Z
	S NS="O "
	S OPT=$P(Z,":",1)
	I OPT["47" S NS=NS_"""TAPE0:""",MAG=""
	I OPT["48" S NS=NS_"""TAPE1:""",MAG=""
	I OPT["49" S NS=NS_"""TAPE2:""",MAG=""
	I OPT["50" S NS=NS_"""TAPE3:""",MAG=""
	I '$D(MAG) S NS=NS_OPT
	S OPT=$P(Z,":",2)
	I OPT="" G OPEN
	I OPT?.N S EXT=" U "_$P(Z,":",1)_":WI="_OPT G OPENA
	I OPT["W" S NS=NS_$S(OPT["N":":NEWV",1:":NONEWV")_":REC=512"
	I OPT["R",OPT'["W" S NS=NS_":READ"
	I OPT["E" S NS=NS_":EBC"
	I OPT["F" S NS=NS_":FIX"
	I OPT["V" S NS=NS_":VAR"
	I $P(NS,":",2)'["(" S NS=$P(NS,":",1)_":("_$P(NS,":",2,99)
	S OPT=$P($P(Z,":",3),")",1)
	I OPT=""!(Z'[")") S NS=$S(NS["(":NS_")",1:"") G OPENA
	I OPT["S"!(OPT=1) S NS=NS_")",EXT=" U "_$P(Z,":",1)_":NOECHO" G OPENA
	I OPT["A"!(OPT=0) S NS=NS_")",EXT=" U "_$P(Z,":",1)_":(ES:ECHO)" G OPENA
	I '$D(MAG) S NS=NS_"):"_OPT G OPENA
	S NS=NS_":REC="_OPT
	S OPT=$P(Z,":",4)
	I OPT="" S NS=NS_")" G OPENA
	S NS=NS_":BL="_OPT
	S OPT=$P(Z,":",5)
	I OPT="" G OPENA
	S NS=NS_":"_OPT G OPENA
	;
OPENA	;
	I Z[":",$L(Z,":")>2 S Z=$P(Z,":",$L(Z,":")) I Z?1N.N,Z'[")" S NS=NS_":"_Z
	I NS?.E1":()".E S NS=$P(NS,":()",1)_":"_$P(NS,":()",2)
	I $E(NS,$L(NS))=":" S NS=$E(NS,1,$L(NS)-1)
	I $D(EXT) S NS=NS_EXT K EXT
	D CHANGE G OPEN
	;
ZE	;------------------- $ZE command conversion --------------------------
	I $P(X,"$ZE",2)?1AN.E Q  ; Not valid $ZE
	S OS="$ZE",NS="$ZS" D CHANGE Q:X'[OS  G ZE
	Q
%SYS	;------------------- %SYS variable check conversion ------------------
	I X["%SYS=""VAX""" S OS="%SYS=""VAX""",NS="$$^%ZSYS=""GT.M""" D CHANGE
	Q
	;
ZF	; Convert $ZF's to ^%ZFUNC extrinsic function calls
	N VMS
	; 
	S VMS=$$^%ZSYS
	;
	S Z="$ZF(""USERNAME"")" I X[Z S NEWZF="$$USERNAM^%ZFUNC" D ZFC G ZF
	S Z="$ZF(""PRCNAM"")" I X[Z S NEWZF="$$PRCNAM^%ZFUNC" D ZFC G ZF
	S Z=$F(X,"$ZF(") I 'Z Q
	S Z1=$E(X,Z-4,999),Z=$P(Z1,")",1)_")"
	S OPND=$P(Z,",",2,99)
	S OP=$P($P(Z,"""",2),"""",1)
	I OP="FREEBLOCKS" S OP="FREEBLK" G ZFE
	I OP="IMAGENAME" S OP="IMAGENM" G ZFE
	I OP="JOBPRCCNT" S OP="JBPRCNT" G ZFE
	I OP="MAXBLOCK" S OP="MAXBLK" G ZFE
	I OP="READPORT" S OP="READPRT" G ZFE
	I OP="DCL" S OP="SYS" G ZFE
	I "/COS/COSD/ERRCNT/EXP/LNX/LOG/RTB/RTBAR/SIN/SIND/TAN/TAND/XOR/GETDVI/GETJPI/UNPACK/"[("/"_OP_"/") G ZFE
	; Otherwise, not ^%ZFUNC supported function, change to $ZC
	I VMS S NEWZF="$$ZC("""_OP_""","_OPND
	D ZFC G ZF
	;
ZFE	S NEWZF="$$"_OP_"^%ZFUNC("_OPND
	D ZFC G ZF
	;
ZFC	; Change $ZF code
	S FLAGA=1
	S X=$P(X,Z,1)_NEWZF_$P(X,Z,2,999)
	Q
	;
ZT	;------------------- $ZT command conversion --------------------------
	I X["$$NEW^%ZT" Q  ; New code, ignore
	I X["$$SET^%ZT" Q
	I X["N $ZT" Q  ; Already converted
	S (FLAGA,FLAGC)=1
	; 
	; Convert to GT.M specific code - results should be examined
	N CP,Y,Z,ZTLEN,NMX
	S Y=X,X="",ZTPRE=$L("$ZT=")+1
ZT1	S CP=$F(Y,"$ZT=") I CP=0 S X=X_Y Q
	I $E(Y,CP-ZTPRE)="," S X=X_$E(Y,1,CP-ZTPRE-1)_" "
	E  S X=X_$E(Y,1,CP-ZTPRE-2)
	S Y=$E(Y,CP,999)
	I $E(Y)'="""" D ZT10 G ZT1
	S Z=$F(Y,"""",2)
	S NMX=$E(Y,2,Z-2),Y=$E(Y,Z,999)
	I Z=3 S X=X_"S $ZT=""""" G ZT1
	S X=X_"N $ZT S $ZT=""ZG ""_$ZL_"":"_NMX
	I NMX["^" S X=X_""""
	E  S X=X_"^""_$T(+0)"
	G ZT1
ZT10	;
	S NMX="""D ""_"
	S X=X_"N $ZT S $ZT=""ZG ""_$ZL_"":""_"_NMX
	Q
	;
ZN	;------------------- $ZN command conversion --------------------------
	S OS="$ZN",NS="$T(+0)" D CHANGE Q:X'[OS  G ZN
	Q
	;
	;
BREAK	;------------------- Break command conversion ------------------------
	I X["B 0" S OS="B 0",NS="D DISABLE^%ZBREAK" D CHANGE
	I X["B 1" S OS="B 1",NS="D ENABLE^%ZBREAK" D CHANGE
	I X["B 0"!(X["B 1") G BREAK
	Q
	;
%RTNS	;------------------- %Routines - output to check ---------------------
	; If contains ^%, but not one of the following, print it for review
	I X["^%SYSVAR"!(X["^%ZDDP")!(X["^%ZNOREST") Q  ; Globals
	; Routines
	I X["^%RSET"!(X["^%SS")!(X["^%PRIO")!(X["^%ZFREECK") Q
	I X["^%T"!(X["%DIR")!(X["^%ZDISMOU")!(X["^%ZFUNC")!(X["^%ZQUESET") Q
	I X["^%ZINIT"!(X["^%ZMOUNT")!(X["^%ZOPEN")!(X["^%ZREAD") Q
	I X["^%ZRTNCMP"!(X["^%ZRTNLOD")!(X["^%ZT")!(X["^%ZUSE") Q
	I X["^%ZWRITE"!(X["%ZBREAK")!(X["%ZRTNS")!(X["^%ZT") Q
	I X["^%ZEVENT"!(X["^%ZRTNDEL")!(X["^%ZJOB")!(X["^%ZSYS") Q
	I X["^%ZULVSAV" Q
	S FLAGC=1
	Q
	;
CHANGE	;------------------- Change every section ----------------------------
	; OS = Old string   NS = New string   X = Complete line
	; 
	S X=$P(X,OS,1)_NS_$P(X,OS,2,999),FLAGA=1 Q
	;
CHECK	;
	I LN["GT.M" Q  ; Do not convert lines with GT.M embedded
	I $E($P(LN,$C(9),2),1)=";" Q  ; Ignore comment lines
	;
	K ERR S Y=0
	F I=0:0 S Y=$F(LN,"O ",Y) Q:'Y  I Y,$P($E(LN,Y,999)," ",1)[":" S X=$E(LN,Y-3) I X=" "!(X=$C(9)) S X="O" D SAVE Q
	F I=0:0 S Y=$F(LN,"U ",Y) Q:'Y  I Y,$P($E(LN,Y,999)," ",1)[":" S X=$E(LN,Y-3) I X=" "!(X=$C(9)) S X="U" D SAVE Q
	I LN["U 0:(0:" S X="U" D SAVE Q  ; Pick up "U 0:(0:""S"")"_ syntaxes
	I LN["$ZE" S X="$ZE" D SAVE
	I LN["$ZT" S X="$ZT" D SAVE
	I LN["$ZN" S X="$ZN" D SAVE
	I LN["ZI " S X="ZI" D SAVE
	I LN["ZS " S X="ZS" D SAVE
	I LN["ZR " S X="ZR" D SAVE
	I LN["ZL " S X="ZL" D SAVE
	I LN["ZU " S X="ZU" D SAVE
	I LN["B 0" S X="B 0" D SAVE
	I LN["B 1" S X="B 1" D SAVE
	I LN["$ZF" S X="$ZF" D SAVE
	I LN["$Z",LN'["$ZF",LN'["$ZT",LN'["$$^%ZD",LN'["$ZP",LN'["$ZA",LN'["$ZB" S X="$Z" D SAVE
	I LN["^%" S X="^%" D SAVE
	I $P(LN," ",1)["IO" S X=$P(LN," ",1) I X="IOCL"!(X="IOCP")!(X="IOF") S X="IO" D SAVE
	I LN["^[" S X="^[" D SAVE
	I LN["^ROUTINE" S X="ROUTINE" D SAVE
	I LN["%SYS=""" S X="%SYS" D SAVE
	I LN["*-" S X="*-" D SAVE
	Q
	;
SAVE	;
	;
	S ERR(X)="" Q
	;
COMPILE	; Compile new source code file
	;
	U 0 W " .. File"
	S FILE=$P(FILE,";",1)
	O FILE:(NEWV) U FILE
	S N="" F  S N=$O(X(N)) Q:N=""  W X(N),!
	C FILE U 0 W "d"
	Q
EXIT	C IO U 0 W !,"Conversion complete " W $H Q
ERROR	; Error encountered during process, continue
	;
	U IO W !,"*** "_$ZS_" ***",!
	U 0 W !,"*** "_$ZS_" ***"
	W !,"Continue? Y"_$c(8) R Z:10
	I "Yy"[Z ZG 1:MASTER
	G EXIT
