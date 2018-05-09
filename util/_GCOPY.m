%GCOPY	;M Utility;Utility to copy globals between directories
	;;Copyright(c)1994 Sanchez Computer Associates, Inc.  All Rights Reserved - 04/28/94 15:35:31 - SYSRUSSELL
	; ORIG:  Frank R. Sanchez (2497) - 09/03/87
	;
	; KEYWORDS:	Global handling
	;
START	N (%READ)
	W !!,"Global copy.  Run in the target directory.",!
	W "To copy from another directory, use extended syntax on the from reference.",!
	;
FROM	S FROM=$$PROMPT^%READ("Copy from global:  ","") Q:FROM=""
	I $E(FROM)'="^" S FROM="^"_FROM
	S %G=FROM D GPARSE^%G I ER W "  ",$G(RM) G FROM
	;
	I $E(FROM)'="^" S FROM="^"_FROM
	S ORIGFROM=FROM,LENGTH=$L(FROM)+1
	S X=$ZP(%END(""))
	; Handle end range, ^ABC(1,1:2
	I X'="",%END(X)'="" S X=0 F I=$L(FROM):-1:1 S X=X+1 Q:$E(FROM,I)=":"
	I  S LENGTH=LENGTH-X,FROM=$E(FROM,1,$L(FROM)-X)
	;
	W !
	;
TO	S TO=$$PROMPT^%READ("Copy into global:  ","") Q:TO=""
	I $E(TO,$L(TO))="," S TO=$E(TO,1,$L(TO)-1)
	I $E(TO)="["!($E(TO,2)="[") W " ... extended syntax not allowed." G TO
	S %G=TO D GPVER^%G
	I ER W "  ...invalid" G TO 
	S %X=$P(%G,"(",2,256),%GLOB=$P(%G,"(",1)
	D GPMAIN^%G
	I %LOW=-2 W "  ...invalid" G TO
	;
	F I=1:1 Q:'$D(%START(I))  I %START(I)="" W "  ...invalid" G TO
	S TO=%G
	;
	I $$CHKSAME W "  ... cannot transfer to same global",! G FROM
	;
	S CNT=0
	W !!
	D OUTPUT^%G(ORIGFROM,"X","COPY^%GCOPY")
	W $C(13),?5,"Done   ",!
	G FROM
	;
COPY	; Called from OUTPUT^%G
	S CNT=CNT+1
	I CNT#10=0 W $C(13),?5,$S(CNT#20=0:"       ",1:"Working")
	;
	I CNT=1 D TOP Q
	S X=TO_$E(%NODE,LENGTH,999)
	S @X=%DATA
	Q
	;
TOP	; Handle top level
	S TOP1=$P(TO,"(",1),TOP2=$P(TO,"(",2),X=%NODE
	I FROM_")"=%NODE,TOP2="" S @TOP1=%DATA,X="" ; Top level
	E  I %NODE=$P(FROM,"(",1) S @$S(TOP2="":TOP1,1:TO_")")=%DATA,X=""
	I $E(FROM,$L(FROM))="(","(,"'[$E(TO,$L(TO)) S TO=TO_"," ; ^XYZ => ^ABC(1,2,3
	I $E(TO,$L(TO))="(","(,"'[$E(FROM,$L(FROM)) S LENGTH=LENGTH+1 ; ^XYZ(1,2,3 => ^ABC(
	I X'="" S X=TO_$E(X,LENGTH,999),@X=%DATA
	Q
	;
CHKSAME()	; See if from and to globals are the same
	I $E(ORIGFROM,2)="[" Q 0 ; OK if directory reference, although may point to this directory (!)
	I $P($P(ORIGFROM,"(",1),"^",2)'=$P($P(TO,"(",1),"^",2) Q 0 ; OK
	Q 1 ; Problem
