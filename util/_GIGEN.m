%GIGEN	;M Utility;Standard SCA global input from %GOGEN output format
	;;Copyright(c)1994 Sanchez Computer Associates, Inc.  All Rights Reserved - 04/28/94 17:30:48 - SYSRUSSELL
	; ORIG:  Dan S. Russell (2417) - 11 Mar 89
	;
	; Standard SCA global input from %GOGEN format.
	;
	; KEYWORDS:  Global handling
	;
	N (READ)
	W !,"%GIGEN global input."
	W !!,"Input from" D READ^%SCAIO Q:ER
	;
	N $ZT
	S $ZT="ZG "_$ZL_":ERR^%GIGEN"
	S ALL=0
	S X=$$PROMPT^%READ("Transfer entire set of files?  No=> ","")
	I X="" S X="N"
	I $TR($E(X),"y","Y")="Y" S ALL=1
	;
FROM	U IO R HDR ; Null first record
	R TRA I $TR(TRA,"tra","TRA")'?1"TRA".E G DONE
	R FROM,X
	I $E(FROM)'="^" S FROM="^"_FROM
	U 0 W !,TRA,!,"From global:  "
	W $S($E(FROM,$L(FROM))="(":$E(FROM,1,$L(FROM)-1),1:FROM)
	;
	S OLD=FROM,SAME=1
	I $E(FROM,$L(FROM))="," S FROM=$E(FROM,1,$L(FROM)-1)
	S %G=FROM,ER=0
	D GPVER^%G
	I ER!(%DEPTH=2)!ALL!(%G[":") D TOSAME G TR
	;
	; Allow transfer to another global
	S %X=$P(%G,"(",2,999),%GLOB=$P(%G,"(",1)
	D GPMAIN^%G
	I %LOW=-2 D TOSAME G TR
	;
	S OLDER=ER,OLDDEPTH=%DEPTH
	F I=1:1 Q:'$D(%START(I))  I %START(I)="" D TOSAME G TR
	;
TO	S READ("PROMPT")="To global:  "
	S X=$S($E(OLD,$L(OLD))="(":$E(OLD,1,$L(OLD)-1),1:OLD),OX=X
	D ^%READ I X="" G TO
	S TO=X,SAME=$S(X=OX:1,1:0)
	I $E(TO,$L(TO))="," S TO=$E(TO,1,$L(TO)-1)
	S %G=TO,ER=0
	D GPVER^%G
	I ER'=OLDER!(%DEPTH'=OLDDEPTH) W " Invalid" G TO
	S %X=$P(%G,"(",2,256),%GLOB=$P(%G,"(",1)
	D GPMAIN^%G
	I %LOW=-2 W " Invalid" G TO
	;
	F I=1:1 Q:'$D(%START(I))  I %START(I)="" W " Invalid" G TO
	W ! S TO=%G
	;
TR	S Y=$L(FROM)+1 I 'ALL U 0 S X=$$PROMPT^%READ("OK to transfer?  Yes=> ","") I X="" S X="Y"
	I "Y"'[$TR($E(X),"yY"),'ALL G SKIP 
	;
	D READX I DONE G FROM
	;
	R DATA
	S TOP1=$P(TO,"(",1),TOP2=$P(TO,"(",2)
	I FROM_")"=X,TOP2="" S @TOP1=DATA,X="" ; Top level
	E  I X=$P(FROM,"(",1) S @$S(TOP2="":TOP1,1:TO_")")=DATA,X=""
	I $E(FROM,$L(FROM))="(","(,"'[$E(TO,$L(TO)) S TO=TO_"," ; ^XYZ => ^ABC(1,2,3
	I $E(TO,$L(TO))="(","(,"'[$E(FROM,$L(FROM)) S Y=Y+1 ; ^XYZ(1,2,3 => ^ABC(
	I X'="" S X=$S('SAME:TO_$E(X,Y,999),1:X),@X=DATA
	;
LOOP	; Read and set
	D READX I DONE G FROM
	I TO'="",'SAME S X=TO_$E(X,Y,999)
	R DATA S @X=DATA
	G LOOP
	;
READX	U IO R X
	I X="***DONE***" U 0 W !!,"Transfer completed." S DONE=1
	E  S DONE=0
	Q
	;
DONE	U 0 W !,"Done for this set of files."
	I $I'=IO C IO
	Q
	;
TOSAME	W !,"To global ",OLD,!
	S TO=FROM,SAME=1
	Q
	;
SKIP	; Skip this file
	W *7," [Skipping this file]",!
	U IO F I=1:1 R X Q:X="***DONE***"  R DATA
	G FROM
	;
ERR	U 0 W !,$P($ZS,",",2,999),!
	I $G(IO)'="" C IO
	Q
