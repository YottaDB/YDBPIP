%RFIND	;M Utility;Find specified string within selected routines
	;;Copyright(c)1997 Sanchez Computer Associates, Inc.  All Rights Reserved - 03/28/97 07:48:58 - SYSCHENARD
	; ORIG:  Dan S. Russell (2417) - 06 NOV 1989
	;
	; Search a set of routines for a specified string.
	; If display to terminal, highlight string.
	;
	; KEYWORDS:	Routine handling
	;
	;---- Revision History ------------------------------------------------
 	; 03/28/97 - Phil Chenard
	;            Replaced reference to source code extension of .M w/
	;            a lowercase .m.  This will ensure equal handling and
	;            a single version of this routine across all platforms.
	;
 	; 06/17/93 - Dan Russell
	;            Modified U FILE:EXC="" to do only once per file.  Caused
	;            problems if in FOR loop due to GT.M not releasing
	;            memory properly.
	;
	;----------------------------------------------------------------------
	;
START	N (READ)
	W !,"%RFIND search routines for a string",!
	;	
	D ^%RSEL Q:'$G(%ZR)
	;
STRING	S STRING=$$PROMPT^%READ("Search for:  ","") Q:STRING=""
	;
CASE	S X=$$PROMPT^%READ("Ignore case?  Yes=> ","") I X="" S X="Y"
	S IGNCASE="Y"[$E($TR(X,"y","Y"))
	I IGNCASE S STRING=$$UPPER^%ZFUNC(STRING)
	S STRLEN=$L(STRING)
	;
	D ^%SCAIO Q:$G(ER)
	S TERM=($P=IO!(IO=0))
	S (CNTSRCHD,CNTRTNS,CNT)=0
	S DASH="",$P(DASH,"-",IORM)=""
	U 0:(CEN:CTRAP=$C(3):EXC="ZG "_$ZL_":CTRAP^%RFIND":WIDTH=510) W !
	U IO W !!,"Locate string:  ",STRING," in selected routines.",!!
	;
	S RTN=""
RTN	S RTN=$O(%ZR(RTN)) I RTN="" G EXIT
	I 'TERM U 0 W:$X>70 ! W RTN,?$X\10+1*10
	S FILE=%ZR(RTN)_$TR(RTN,"%","_")_".m"		;03/28/97
	S HIT=0,TAG=RTN,OFFSET=0,CNTSRCHD=CNTSRCHD+1
	O FILE:(READ:EXC="G NOOPEN")
	U FILE:EXC=""
	F  U FILE R LINE Q:$ZEOF  D LINE
	C FILE
	G RTN
	;
LINE	; Evaluate each line
	I $P(LINE,$C(9),1)'="" S TAG=$P(LINE,$C(9),1),OFFSET=0
	E  S OFFSET=OFFSET+1
	I IGNCASE S X=$$UPPER^%ZFUNC(LINE)
	E  S X=LINE
	I X'[STRING Q
	S LINE=$$FORMAT^%RO(LINE) ; Convert tabs to spaces
	S X=$$FORMAT^%RO(X)
	U IO
	I 'HIT W !,DASH,!,"^",RTN,! S HIT=1,CNTRTNS=CNTRTNS+1
	I OFFSET W TAG,"+",OFFSET W !
	I 'TERM S CNT=CNT+$L(X,STRING)-1 W X,! Q  ; Not displayed to terminal
	S PTR=1
LOOP	S F=$F(X,STRING,PTR)
	I 'F W $E(LINE,PTR,$L(X)),! Q
	S CNT=CNT+1
	W $E(LINE,PTR,F-STRLEN-1),$$VIDINC^%TRMVT
	W $E(LINE,F-STRLEN,F-1),$$VIDOFF^%TRMVT
	S PTR=F
	G LOOP
	;
CTRAP	; Trap if control-C
	I $G(FILE)'="" C FILE
	I TERM U $P W $$VIDOFF^%TRMVT
	G EXIT
	;
NOOPEN	; Unable to open file
	U IO W !!,"Unable to open file ",FILE," ... search incomplete."
	I 'TERM U $P W !!,"Unable to open file ",FILE," ... search aborted."
	;
EXIT	U IO W !!,CNTSRCHD," routines searched.",!
	W CNTRTNS," routines with a total of ",CNT," occurrences found",!
	I IO'=$P D CLOSE^%SCAIO
	U $P:(EXC="":WIDTH=80)
	Q
