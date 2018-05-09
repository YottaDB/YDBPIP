%RD	;M Utility;Routine directory
	;;Copyright(c)1994 Sanchez Computer Associates, Inc.  All Rights Reserved - 04/28/94 17:39:31 - SYSRUSSELL
	; ORIG:  RUSSELL -  1 NOV 1989
	;
	; Display routine directory
	;
	; D ^%RD is interactive based on .M files
	; D OBJ^%RD is interactive based on .OBJ files
	;
	; KEYWORDS:	Routine handling
	;
	N %ZE S %ZE=".M" D START Q
	;----------------------------------------------------------------------
OBJ	;M Utility;Routine directory based on .OBJ files
	;----------------------------------------------------------------------
	;
	; KEYWORDS:	Routine handling
	;
	N %ZE S %ZE=".OBJ" D START Q
	;
START	N $ZT
	S $ZT="ZG "_$ZL_":ERR^%RD"
	U $P:(CEN:CTRAP=$C(3))
	W !,"Routine Directory",!
	D RD^%RSEL
	;
END	U $P:(CTRAP="":EXC="")
	Q
	;
ERR	U $P
	I $P($ZS,",",3)'["CTRAP" W !,$P($ZS,",",2,999),!
	K %ZR
	G END
