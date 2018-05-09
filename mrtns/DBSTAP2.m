DBSTAP2	;; -  - V4.0 - Conversion Template Routine
	;;Copyright(c)2000 Sanchez Computer Associates, Inc.  All Rights Reserved - 04/03/00 15:53:29 - TANY
	;     ORIG:  MATTSON - 08/29/89
	;CALLED BY:
	;    CALLS:
	; PROJ #'S:  
	;     DESC:
	;
	; GLOBALS -
	;     READ:
	;      SET:
	;
	;    INPUT:
	;   OUTPUT:
	;
	;EXT ENTRY:
	;
	;---- Revision History ------------------------------------------------
	; 05/17/06 - Allan Mattson - CR20048
	;            Replaced calls to $$UPPER^%ZFUNC with $$UPPER^SCAUTL.
	;
        ; 04/03/00 - TANY - 37915
        ;            Optimized performance by modifying ^SCADAT1 calls
        ;            to ^SCAJD. Also remove revision history older than
        ;            one year.
        ;----------------------------------------------------------------------
DOL	; Format data type $ (dollar)
	S ZB=$E(DATA,$L(DATA)) I DATA["." S DATA=+DATA Q
	I ZB?1N S DATA=+DATA D DOL2 Q  ; Not zone data
	;
	; Zone data
	S ZBT=$TR(ZB,"{ABCDEFGHI}JKLMNOPQR","01234567890123456789")
	S DIV=100 I DEC S DIV=1 F I=1:1:DEC S DIV=DIV_0
	S DATA=$E(DATA,1,$L(DATA)-1)_ZBT,DATA=DATA/DIV
	I $A(ZB)>73,$A(ZB)'=123 S DATA=-DATA
	S DATA=+DATA
	Q
	;
DOL2	S DIV=100 I DEC S DIV=1 F I=1:1:DEC S DIV=DIV_0
	S DATA=DATA/DIV
	Q
	;
DAT	; Format data type D (date)
	I $E(DATA,1,8)="00/00/00" S DATA="" Q
	S %DS=$$RTB^%ZFUNC(DATA) S %JD=$$^SCAJD(%DS)
	I %JD>0 S DATA=%JD
	Q
	;
LOG	; Format data type L (logical)
	S DATA=$TR(DATA,"YyTtNnFf","11110000")
	Q
	;
UPPER	; Format data type U (Uppercase)
	S DATA=$$RTB^%ZFUNC(DATA),DATA=$$UPPER^SCAUTL(DATA)
	Q
	;
