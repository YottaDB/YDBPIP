%ZCTRLC	;System;Trap routine for control-C
	;;Copyright(c)1994 Sanchez Computer Associates, Inc.  All Rights Reserved - 05/04/94 21:37:30 - SYSRUSSELL
	; ORIG:  Frank Sanchez
	;
	; Under GT.M provides programmers with a control-C interrupt capability.
	;
	; ** FOR DEBUGGING and DEVELOPMENT PURPOSES ONLY **
	; *** NOT TO BE USED IN PRODUCTION ENVIRONMENTS ***
	;            
	; Calling at top will set up device 0 to use this routine for 
	; control-C trapping for programmers.
	;
	; Trapping occurs at line TRAP.
	;
	; When in direct mode D ^%ZCTRLC to set trap
	;
	; KEYWORDS:	System Services
	;
SET	; Set control-C trap for device 0
	U 0:(CEN:CTRAP=$C(3):EXC="D TRAP^%ZCTRLC")
	Q
	;
TRAP	; Trap section when control-C encountered
	N $ZT
	S $ZT="G ERROR^"_$T(+0)
	N %ctrlcx,%ctrlcy,%ctrlczp
	S %ctrlczp=$P($ZS,",",2) ; Get tag^rtn where interrupt occurred
	U 0
	I $D(OLNTB) S %ctrlcy=OLNTB\1000 ; See if lock region
	E  S %ctrlcy=15 ; Otherwise, set to bottom
	I %ctrlcy>15 s %ctrlcy=15
	W $C(27)_"["_(%ctrlcy+1)_"H"_$C(27)_"[J" ; Erase to end of screen
	W $C(27)_"["_(%ctrlcy+2)_"H"_$C(27)_"[7m Control-C encountered ",%ctrlczp
	W $C(27)_"[m" ; Turn off video attributes
	W $C(27)_"["_(%ctrlcy+3)_"H" S $Y=%ctrlcy+3
	ZP @%ctrlczp
	S %ctrlcy=$Y
	W $C(27)_"["_%ctrlcy_";r" ; Lock region
	W $C(27)_"["_(%ctrlcy-1)_"H" ; Position cursor
	S $ZT="ZG "_$ZL_":ZT^"_$T(+0) ; Set error trap in case of Xecute error
	;
INPUT	; Read commands in c-trap mode
	S %ctrlcx=$$PROMPT^%READ("CTRLC> ","")
	I %ctrlcx="" G INPUT
	I %ctrlcx="?" W "  (Enter command, or B for direct mode, Q to quit)"
	I  W !,"         (Quiting will resume execution at beginning of the interrupted line)" G INPUT
	I "qQ"[%ctrlcx D CLEAR G EXIT ; Quit out of c-trap
	I "hH"[%ctrlcx D CLEAR ; Clear lock region before halt
	I $TR($E(%ctrlcx,1,2),"u","U")="U ","qQ"[$E(%ctrlcx,$L(%ctrlcx)) D CLEAR U $P(%ctrlcx," ",2) G EXIT ; Use specified device then exit
	I $TR($E(%ctrlcx,1,2),"d","D")="D ",%ctrlcx'["^" S %ctrlcx=%ctrlcx_"^"_$P(%ctrlczp,"^",2)
	W ! X %ctrlcx G INPUT
	;
ZT	; Error in executable command string
	W !,$P($ZS,",",2,999)
	G INPUT
	;
ERROR	; Error in early section
	W !,$P($ZS,",",2,999)
	Q
	;
CLEAR	; Clear screen lock region
	W $C(27)_"["_%ctrlcy_";H" ; Position cursor
	W $C(27)_"[J"_$C(27)_"[r" ; Clear lock region, and unlock
	W $C(27)_"["_%ctrlcy_";H" ; Position cursor
	Q
	;
EXIT	Q
	;
TEST	; Entry test linetag
	U 0:(CEN:CTRAP=$C(3):EXC="D TRAP^%ZCTRLC")
	R !,"Type control-C to test",X
	Q
