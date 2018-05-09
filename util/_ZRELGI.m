%ZRELGI	;Private;Release global input utility
	;;Copyright(c)1994 Sanchez Computer Associates, Inc.  All Rights Reserved - 05/05/94 08:51:29 - SYSRUSSELL
	; ORIG:  Ronky -  1 NOV 1989
	;
	; Utility to read in a %GOGEN RMS file w/o prompts - used by release
	; software
	;  
	N (IO)
	O IO:READ
	;
	N $ZT
	S $ZT="ZG "_$ZL_":ERR^%ZRELGI"
	S ALL=1
	;
FROM	U IO R HDR ; Null first record
	R TRA I $TR(TRA,"tra","TRA")'?1"TRA".E G DONE
	R FROM,X
	I $E(FROM)'="^" S FROM="^"_FROM
	;
	S OLD=FROM
	I $E(FROM,$L(FROM))="," S FROM=$E(FROM,1,$L(FROM)-1)
	S %G=FROM,ER=0
	D GPVER^%G
	S TO=""
	;
TR	S Y=$L(FROM)+1
	;
LOOP	; Read and set
	D READX I DONE G FROM
	R DATA S @X=DATA
	G LOOP
	;
READX	U IO R X
	I X="***DONE***" S DONE=1
	E  S DONE=0
	Q
	;
DONE	C IO
	Q
	;
ERR	U 0 W !,$P($ZS,",",2,999),!
	I $G(IO)'="" C IO
	Q
