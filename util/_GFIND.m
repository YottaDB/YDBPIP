%GFIND	;M Utility;Find specified string within global
	;;Copyright(c)1994 Sanchez Computer Associates, Inc.  All Rights Reserved - 04/28/94 15:35:54 - SYSRUSSELL
	; ORIG:  Dan S. Russell (2417) - 06 NOV 1989
	;
	; Search a global for a specified string.  If display to terminal, 
	; highlight string.
	;
	; Allows selection of portions or ranges of global nodes (ala %G).
	;
	; KEYWORDS:	Global handling
	;
START	N (READ)
	W !,"%GFIND search global for a string",!!
	;	
GLOBAL	S GBL=$$PROMPT^%READ("Global:  ","")
	I GBL="" Q
	D VALID^%G(GBL) I ER U 0 W "  ",RM S ER=0 G GLOBAL
	;
STRING	S STRING=$$PROMPT^%READ("Search for:  ","")
	I STRING="" G GLOBAL
	;
CASE	S X=$$PROMPT^%READ("Ignore case?  Yes=> ","") I X="" S X="Y"
	S IGNCASE="Y"[$E($TR(X,"y","Y"))
	I IGNCASE S STRING=$$UPPER^%ZFUNC(STRING)
	S STRLEN=$L(STRING)
	;
	D ^%SCAIO Q:$G(ER)
	S TERM=($P=IO!(IO=0))
	S (CNTNODES,CNT)=0
	U 0:(CEN:CTRAP=$C(3):EXC="ZG "_$ZL_":CTRAP^%GFIND":WIDTH=510)
	U IO W !
	D OUTPUT^%G(GBL,"X","SEARCH^%GFIND")
	;
EXIT	U IO W !!,CNTNODES," nodes with a total of ",CNT," occurrences found",!
	I IO'=$P D CLOSE^%SCAIO
	U $P:(EXC="":WIDTH=80)
	Q
	;
CTRAP	; Trap if control-C
	I TERM U $P W $$VIDOFF^%TRMVT
	G EXIT
	;
SEARCH	; Check each node and data for string, if find, display
	; ORIGX is case sensitive, X is all upper case
	N X,I,ORIGX,F
	S ORIGX=%NODE_"="_%DATA
	I IGNCASE S X=$$UPPER^%ZFUNC(ORIGX)
	E  S X=ORIGX
	Q:X'[STRING
	S CNTNODES=CNTNODES+1
	I 'TERM S CNT=CNT+$L(X,STRING)-1 W X,! Q ; Not displayed to terminal
	S PTR=1
LOOP	S F=$F(X,STRING,PTR)
	I 'F W $E(ORIGX,PTR,$L(X)),! Q
	S CNT=CNT+1
	W $E(ORIGX,PTR,F-STRLEN-1),$$VIDINC^%TRMVT
	W $E(ORIGX,F-STRLEN,F-1),$$VIDOFF^%TRMVT
	S PTR=F
	G LOOP
