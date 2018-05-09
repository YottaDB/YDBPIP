%ZG	;M Utility;SCA extended Mumps Global list
	;;Copyright(c)1994 Sanchez Computer Associates, Inc.  All Rights Reserved - 05/05/94 13:42:18 - SYSRUSSELL
	; ORIG:  Frank R. Sanchez - 11/27/87
	;
	; KEYWORDS:	Global handling
A	;
	N $ZT,%,%P,%I,%E,%E1,%IQ,%F,%K,%PA,%ST
	S $ZT="ZG "_$ZL_":ZT^%ZG"
	U 0:(CTRAP=$C(3))
	I $D(%BLK) S %X=$P(%BLK,"/,",2,999) K %BLK
	E  S READ("PROMPT")="Global ^",X="" D ^%READ S %X=X Q:%X=""
	I %X="?" D HELP G A
	I %X="??" D ^%GD G A
	S %EZ=1,%="/" D PARSE I '$D(%P) W !,*7,"  Invalid input syntax" G A
	F %I=$L(%P(1)):-1:0 Q:$E(%P(1),%I)'=" "  S %P(1)=$E(%P(1),1,%I-1)
	S %XG=$P(%P(1),"(",1)_"(",%X=$P(%P(1),"(",2,999),%PA=$G(%P(2))
	I $E(%XG)'="^" S %XG="^"_%XG
	S %="," D PARSE
	S %LK=0 I $D(%P) F %I=1:1:%P D %K I %K'="" S %K(%I)=%K_" "
	;
B	;
	I %PA="?" S %PA=$$PROMPT^%READ("Parameters:  ","") G B
	I %PA'="" S %ER=0 D %PARAM I %ER D ERR G A
	D C,ERR:%ER G A
	;
C	;
	S %ER=0
	S X=$G(%PA(15)),ER=0 S:X="" X=0 D ^%SCAIO Q:ER
	I $D(%PA(7)) D INT^%T U IO W %PA(7),!,"Global output "_$$^%ZD($H,2)_" "_%TIM K %PA(16)
	I $D(%PA(12)) D DINAM Q:%ER  ; Logical data item name
	I $D(%PA(9)) D INDEX  ; Save into index file 
	I $D(%PA(4)) D DELIM Q:%ER  ; Search for specific fields
	I $D(%PA(19)) F %I=0:1:3 S %ST(%I)=0 ; Accumulate statistics
	I $D(%PA(3)) S %CNT=1 ; Stop after record number
	I $D(%PA(6)) D FINDA ; Find a string
	I $D(%PA(18)) D REPLACA Q:%ER  ; Replace Expr#1 with Expr#2
	I $D(%PA(1)) S %XG=$E(%XG,2,999) ; Local array
	I $D(%PA(22)) S IOSL=0 ; Verify switch is on
	I $D(%PA(16)) S:'$D(IOSL) IOSL=22 U IO W # ; Page mode
	E  S IOSL=0
	K %X U IO W ! S %X=0 D LOADV,STAT Q
	;
LOADV	; Build an executable string
	;
	K %F
	S %X=%X+1,%XV="%X"_%X,%XL=%XG
	I %X>1 F I=1:1:%X-1 S X=@("%X"_I) S:X'=+X X=""""_X_"""" S %XL=%XL_X_","
	S %XR=%XL_%XV_")",%XL(%X)=%XL
	;
	I $D(%K(%X)) S %X(%X)=%K(%X) ; This key level specifically defined
	E  S %X(%X)="S "_%XV_"="""" F %I=0:0 S "_%XV_"=$O("_%XR_") Q:"_%XV_"=""""  "
	I $G(%PA(3)) S %X(%X)=%X(%X)_"Q:%CNT>"_%PA(3)_"  "
	I %X=%LK S %X(%X)=%X(%X)_"S X=$D("_%XR_") I X#10 S %K="_%XV_",%D="_%XR_" D WR"
	E  S %X(%X)=%X(%X)_"S X=$D("_%XR_"),%K="_%XV_" S:(X#10) %D="_%XR_$S(%LK:"",1:" D WR:(X#10)")_" D:X>1 LOADV"
	X %X(%X) S %X=%X-1 S:%X %XL=%XL(%X) K %F
	Q
%K	; Special handling at this key level
	;
	S %ER=0,%K=%P(%I) N %P
	S:$E(%K,$L(%K))=")" %K=$E(%K,1,$L(%K)-1),%LK=%I Q:%K=""
	S %XL=%XG F %II=1:1:%I-1 S %XL=%XL_"%X"_%II_","
	I $E(%K,$L(%K))="*" S %K=$E(%K,1,$L(%K)-1),%K="S %X"_%I_"="_%K_" F %I=0:0 S %X"_%I_"=$O("_%XL_"%X"_%I_")) Q:$E(%X"_%I_",1,"_$L(%K)_")'="_%K_" " Q
	S %=":",%X=%K D PARSE I $D(%P(2)) S %K="S %X"_%I_"=$ZP("_%XL_%P(1)_")) F %I=0:0 S %X"_%I_"=$O("_%XL_"%X"_%I_")) Q:%X"_%I_"=""""!(%X"_%I_$S(%P(2)=+%P(2):">",1:"]")_"("_%P(2)_")) " Q
	I %K=+%K S %K="S %X"_%I_"="_%K Q
	I $F(%K,"""",2)>$L(%K) S %K="S %X"_%I_"="_%K Q
	I $E(%K)'="""" X "S %K="_%K S %K="S %X"_%I_"="""_%K_"""" Q
	Q
	;
WR	; Write to output device
	;
	I %K'=+%K S %K=""""_%K_""""
	I '$D(%PA) G WRO
	I $D(%PA(19)) S %ST(0)=%ST(0)+1,%ST=$L(%XL)+$L(%XV) S:%ST>%ST(1) %ST(1)=%ST S %ST=$L(%D) S:%ST>%ST(2) %ST(2)=%ST S %ST(3)=%ST(3)+%ST
	I $D(%PA(4)) X %PA(4)
	I $D(%PA(3)) S %CNT=%CNT+1
	I $D(%PA(6)) X %PA(6) E  Q
	I $D(%PA(9)) S @(%PA(9)_$P(%XL,"(",2)_%K_")")=%D
	I $D(%PA(18)) G REPLACE
	I $D(%PA(7)) G WRG
	;
WRO	; Write output string
	;
	I '$D(%F) S %F=$L(%XL) W %XL
	W ?%F,%K_")="_%D,!
	I IOSL,$Y>IOSL D HDG
	Q
	;
WRG	; Global output format
	;
	U IO W %XL_%K_")",!,%D,! Q
	Q
	;
DELIM	; Delimiter separated fields
	;
	I $D(%PA(18)) S %ER=1 W !,*7,"REPLACE with delimiter is not supported" Q
	;
	S %X=%PA(4),%=" " D PARSE I %P=1 S %P=2,%P(2)=1
	S %X="S %D=" F %I=1:1 Q:'$P(%P(2),",",%I)  S %X=%X_"$P(%D,"""_%P(1)_""","_$P(%P(2),",",%I)_")_"",""_"
	S %PA(4)=$E(%X,1,$L(%X)-5) Q
	;
DINAM	; Data Qwik Data item
	;
	U $P I '$G(%TO) S %TO=60
	S PREFIX=$E($P(%XG,"]",1),2,999)
	I PREFIX="" S %M="Missing [FILE] syntax",%ER=1 Q
	S %XG=$P($P(%XG,"]",2,999),"(",1)
	I %XG="" S %M="Missing data item name",%ER=1 Q
	S DLIB=$S($D(%LIBS):%LIBS,1:$G(^CUVAR("%LIBS"))),PREFIX=PREFIX_"]"
	F %I=1:1 S X=$P(%XG,",",%I) Q:X=""  S X=PREFIX_X D ^DBSDI Q:ER  D DINAB
	I '$D(%PA(4)) S %ER=1 Q
	I $G(RM)'="" S %M=RM,%ER=1
	Q:%ER
	W ! S %XG="^"_^DBTBL(LIB,1,FID,0)_"("
	F %I=1:1 S X=$G(^(%I)) Q:X=""  I (X=+X!($E(X)="""")) S %P(%I)=X D %K S %K(%I)=%K_" "
	I %X=+%X!($E(%X)="""") S %P(%I)=%X_")" D %K S %K(%I)=%K_" "
	Q
	;
DINAB	; Build output string
	;
	I $D(DI)<10 S %ER=1 Q
	I %I=1 S %X=DI(1),%PA(4)=$C(DI(20))_" "_DI(21)
	W !,X,?15,$E(DI(10),1,20),?37,"Type="_DI(9),", Length=",$J(DI(2),2),", Node=",$J(DI(1),3),", Del=",$C(DI(20)),", Pos=",DI(21)
	E  I DI(1)'=%X S %M="All fields must be on the same node "_%X,%ER=1 Q
	E  S %PA(4)=%PA(4)_","_DI(21)
	Q
	;
INDEX	; Save into index file
	;
	I $P(%PA(9),"(",2)'="",$E(%PA(9),$L(%PA(9)))'="," S %PA(9)=%PA(9)_","
	I %PA(9)'["(" S %PA(9)=%PA(9)_"("
	Q
REPLACA	; Build replace logic
	;
	F %II=1:1 S %X=$G(%PA(18,%II)) Q:%X=""  D REPLACB Q:%ER
	Q
REPLACB	;
	;
	S %=" " D PARSE
	I '$D(%P(1)) S %ER=1,%M="Replace expression #1 not defined" Q
	I '$D(%P(2)) S %P(2)=""
	I %P(1)=%P(2) S %ER=1,%M="Cannot replace with the same string" Q
	S %RP(%II,1)=%P(1),%RP(%II,2)=%P(2)
	S %PA(6)=$S($D(%PA(6)):%PA(6)_"&",1:"I ")_"(%D["""_%P(1)_""")"
	Q
REPLACE	; Replace every Expr#1 with Expr#2
	;
	S %E=%D
	F %II=1:1 Q:'$D(%RP(%II))  F %I=0:0 Q:%E'[%RP(%II,1)  S %E=$P(%E,%RP(%II,1),1)_%RP(%II,2)_$P(%E,%RP(%II,1),2,999)
	K %F D WRO W ?%F,%K_")="""_%E_"""",!!
	I $D(%PA(22)) U $P R "Verified? (Y/N): ",X W !! S X=$TR(X,"ny","NY") Q:X="N"  I X'="Y" G REPLACE
	I $D(%PA(7)) G WRG
	S @(%XL_%K_")")=%E Q
	;
HDG	;
	;
	I $I[IO W !,"Press RETURN to continue or CTRL-C: " R X
	U IO W !#! K %F Q
	;
	;
PARSE	; Parse reference for special cases
	;
	K %P N %I,%E,%IQ
	S %P=1,%E1=1,%IQ=0,%EZ=$G(%EZ)
	F %I=1:1 S %E=$E(%X,%I) Q:%E=""  S:%E="""" %IQ='%IQ I %E=%,'%IQ S %P(%P)=$E(%X,%E1,%I-1),%E1=%I+1,%P=%P+1 I %EZ,%P>%EZ Q
	I %E1'=%I S %P(%P)=$E(%X,%E1,9999) I %P(%P)="" K %P(%P)
	K %EZ I $D(%P)<10 K %P
	Q
	;
%PARAM	;
	;
	S:$E(%PA)="/" %PA=$E(%PA,2,999)
	F %II=1:1 S %E=$P(%PA,"/",%II) Q:%E=""  D %PARAMA
	Q
	;
%PARAMA	;
	;
	F %I=1:1 Q:$A(%E,%I)<65
	S %D=$E(%E,1,%I-1) I %D="" W *7,"  Missing parameter "_%D S %ER=1 Q
	D TR
	I $F("|ARRAY|COUNT|DELIMIT|EXACT|FIND|GO|INDEX|LOGIC|MATCH|PAGE|OUTPUT|REPLACE|STATISTICS|VERIFY","|"_%D) D %PARAMB Q
	S %M="Invalid parameter "_%D,%ER=1 Q
	;
%PARAMB	;
	N %X S %X=$A(%D)-64
	I $E(%D)="F" S %PA(%X,$ZP(%PA(%X,""))+1)=$E(%E,$L(%D)+1,999) Q
	I $E(%D)="R" S %PA(%X,$ZP(%PA(%X,""))+1)=$E(%E,$L(%D)+2,999) Q
	S %PA(%X)=$E(%E,$L(%D)+2,999) Q
	Q
	;
TR	;
	S %D=$TR(%D,"abcdefghijklmnopqrstuvwxyz","ABCDEFGHIJKLMNOPQRSTUVWXYZ") Q
	;
FINDA	; Build find xecutable string
	;
	S %PM=$G(%PA(13)) I %PM'="" S %D=%PM D TR S %PM=%D
	S %PM=$S(%PM="NOTAND":"'&",%PM="NOTOR":"'!",%PM="OR":"!",1:"&"),%II=0,%PA(6)=""
	F %I=1:1 S %E=$G(%PA(6,%I)) Q:%E=""  D FINDB
	S:%II=0 %PA(5)="" S %PA(6)=$S($D(%PA(5)):"",1:"D TR ")_"I "_$E(%PA(6),2,999) Q
	;
FINDB	;
	N %I
	S %C=$E(%E),%X=$E(%E,2,999),%="," D PARSE Q:'$D(%P)
	S:"= "[%C %C="["
	;
	F %I=1:1 S %D=$G(%P(%I)) Q:%D=""  D:'$D(%PA(5)) TR S %PA(6)=%PA(6)_%PM_"(%D"_%C_""""_%D_""")" S:%D?.E1A.E %II=1
	Q
	;
ERR	; Display error
	;
	I $G(%M)'="" W !,*7,%M,! Q
	K %M Q
	;
ZT	; Error processing
	;
	I $P($ZS,",",3)["CRTL" W !,$P($ZS,",",2,999),!!
	D STAT:$D(%ST)
	G A
	;
STAT	; Print statistics
	;
	I $D(%PA(7)) U IO W !! U $P
	I '$D(%ST) G END
	;
	W !!,"Total records: "_$J($FN(%ST(0),","),12),?43,"Maximum key length: "_$J(%ST(1)+1,3)
	W !,"Total bytes: "_$J($FN(%ST(3),","),14),?40,"Maximum record length: ",$J(%ST(2),3)
	W !
END	;
	U $P I IO'=$I D CLOSE^%SCAIO
	Q
	;
HELP	; HELP for output parameters
	;
	W !!,"GLOBAL OUTPUT PARAMETER QUALIFIERS (?? FOR A GLOBAL DIRECTORY)",!
	W !,"/OUTPUT   Output device             [OUTPUT=Device]"
	W !,"/COUNT    Stop after record number  [COUNT=Number]"
	W !,"/FIND     Find string               [FIND=Exprn#1, ... Exprn#n]"
	W !,"/REPLACE  Replace string            [REPLACE=Exprn#1 Exprn#2]"
	W !,"/GO       Global output format      [GO=Description]"
	W !,"/DELIMIT  Field delimiter           [DEL=Delimiter Pos#1, ... Pos#n]"
	W !,"/INDEX    Save into index file      [INDEX=Filename]"
	W !
	W !,"/LOGICAL  Logical data item name"
	W !,"/EXACT    Exact match on upper and lower case"
	W !,"/MATCH    Match record type (AND, OR, NOTAND, NOTOR) used with FIND"
	W !,"/VERIFY   Verify REPLACE qualifier (Y/N/Q)"
	W !,"/PAGE     Form feed at page break (Prompt on VT)"
	W !,"/STAT     Total records, Max key length, Max data length, Total bytes"
	W !,"/ARRAY    List local array"
	W !
	Q
