%GD	;M Utility;Print global directory
	;;Copyright(c)1994 Sanchez Computer Associates, Inc.  All Rights Reserved - 04/28/94 15:50:29 - SYSRUSSELL
	;
	; Provides global directory - list of valid globals based on $ZGBLDIR
	;
	; KEYWORDS:	Global handling
	; 
	;----------------------------------------------------------------------
	;
	N (%READ)
	;
	N $ZT
	S $ZT="ZG "_$ZL_":ERR^%GD"
	;
	U $P:(CTRAP=$C(3):EXC="ZG "_$ZL_":END^%GD")
	W !,"Global Directory",!
	D GD^%GSEL
	;
END	U $P:(CTRAP="":EXC="")
	Q
	;
ERR	U $P W !,$P($ZS,",",2,999),!
	G END
