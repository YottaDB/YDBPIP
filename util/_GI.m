%GI	;M Utility;Global input of %GO output format
	;;Copyright(c)1994 Sanchez Computer Associates, Inc.  All Rights Reserved - 04/28/94 14:59:15 - SYSRUSSELL
	; ORIG:  RUSSELL -  3 NOV 1989
	;
	; Allows input of globals which have been output using %GO format:
	;
	;    Description
	;    Date and time
	;    Global reference  ---}  These two record types
	;    Data              ---}  repeat
	;    ...
	;    Null record
	;
	; Note that MUPIP LOAD is faster and can be used for input of %GO 
	; formatted files.
	;
	; KEYWORDS:	Global handling
	;
	N (READ)
	W !!,"%GI global input.  (Use MUPIP for faster global input)",!
	D READ^%SCAIO Q:ER
	U IO R DESC,DATE
	U 0:(CEN:CTRAP=$C(3):EXC="G CTRAP")
	W !!,"Globals saved on ",DATE,!,"Description:  ",DESC,!
	;
OPT	S OPT=$$PROMPT^%READ("Input option:  ","")
	I "?"[OPT W !!?5,"A - Restore all globals",!?5,"S - Restore selected globals",!?5,"Q - Quit",!! G OPT
	S OPT=$TR(OPT,"asq","ASQ")
	I OPT="Q" G EXIT
	;
LOAD	N $ZT
	S $ZT="ZG "_$ZL_":ERR^%GI"
	S LASTGLOB=""
	U IO
	F  R GLOB Q:GLOB=""!$ZEOF  R DATA D NEW:$P(GLOB,"(",1)'=LASTGLOB I SET S @GLOB=DATA
	U 0 W !!,"Global load complete.",!
	;
EXIT	C IO
	U 0:EXC=""
	Q
	;
NEW	U 0 S LASTGLOB=$P(GLOB,"(",1) W !,LASTGLOB
	I OPT="A" S SET=1 U IO Q
	F  R ?40," Restore?  ",YN Q:$$YNCHK
	U IO Q
	;
YNCHK()	S YN=$TR($E(YN),"yn","YN")
	I YN="Y" S SET=1 Q 1
	I YN="N" S SET=0 Q 1
	W ! Q 0
	;
ERR	U 0 W !!,"Error loading global",!,$P($ZS,",",2,999),!
	G EXIT
	;
CTRAP	U 0 W !!,"Global load interrupted",!
	G EXIT
