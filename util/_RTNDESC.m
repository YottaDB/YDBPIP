%RTNDESC	;M Utility;Print routine descriptions and beginning comment lines
	;;Copyright(c)1994 Sanchez Computer Associates, Inc.  All Rights Reserved - 04/29/94 08:23:35 - SYSRUSSELL
	; ORIG:  Frank R. Sanchez (2497) - 12/29/86
	;
	; Prints the header comment lines or descriptions only for selected 
	; list of routines.
	;
	; Comment line option stops at first non-comment line or at first line 
	; with a line tag, after top of routine.
	;
	; Description print requires standard SCA routine layout
	;
	; KEYWORDS:	Routine handling, Documentation
	;
START	N (READ)
	W !!,"Print routine beginning comment lines or only descriptions.",!
	D ^%RSEL I '$G(%ZR) Q
	;
	S X=$$PROMPT^%READ("Print only descriptions?  Yes=> ","") I X="" S X="Y"
	S DESC=$TR($E(X),"y","Y")="Y"
	;
	D ^%SCAIO W !
	;
	S LINE="",$P(LINE,"-",81)=""
	U IO W !,"Routine "
	W $S(DESC:"descriptions",1:"beginning comment lines")
	W " on ",$$^%ZD($H)," at ",$$EXT^%T,!
	;
	U 0:(CEN:CTRAP=$C(3):EXC="ZG "_$ZL_":EXIT^%RTNDESC")
	S ROU=""
ROU	S ROU=$O(%ZR(ROU)) I ROU="" G EXIT
	I IO'=$P U 0 W:$X>70 ! W ROU,?$X\10+1*10
	S FILE=$TR(%ZR(ROU)_ROU_".M","%","_"),(DESCON,QUIT)=0
	U IO
	I IO'=$P,$Y>(IOSL-6) W #
	W !,LINE,!
	I 'DESC W $ZPARSE(FILE),!!
	O FILE:(READ:REWIND:EXC="G NORTN"):1 E  G NORTN
	F L=1:1 U FILE:EXC="G EOF" R LIN Q:$ZEOF  D PNT Q:QUIT
	C FILE
	G ROU
	;
PNT	; Print the line
	I $E($P(LIN,$C(9),2))'=";" S QUIT=1 Q  ; At end of comments
	S LIN=$$FORMAT^%RO(LIN) ; Remove tabs
	I L>1,$E(LIN)'=" " S QUIT=1 Q  ; Line tag after line one
	;
	U IO
	I IO'=$P,$Y>(IOSL-4) W #,ROU," ...continued",!!
	I 'DESC W LIN,! Q
	;
	; Printing description only
	I L=1 W ROU,?9,$P(LIN,"-",4),!! Q  ; Header line
	I 'DESCON Q:LIN'["DESC:"  S DESCON=1,LIN=";"_$P(LIN,"DESC:",2,99) Q:LIN?1";"." "  ; At DESC start
	I LIN["; GLOBALS -" S QUIT=1 Q  ; End of DESC section
	S LIN=$P(LIN,";",2,99)
	F I=1:1:$L(LIN) Q:$E(LIN,I)'=" "  ; Strip leading blanks
	W ?10,$E(LIN,I,$L(LIN)),!
	Q
	;
NORTN	W ROU,"  NO ROUTINE .M FILE" G ROU
EOF	C FILE G ROU
EXIT	C $G(FILE)
	I $D(IO),IO'=$P D CLOSE^%SCAIO
	U 0:(EXC="")
	Q
