%ZEVENTR	;Private;Read your new events set by %ZEVENT
	;;Copyright(c)1995 Sanchez Computer Associates, Inc.  All Rights Reserved - 11/20/95 17:57:28 - SYSRUSSELL
	; ORIG:  Frank R. Sanchez (2497) - 06/07/87
	;
	;***********************************************************************
	; NOTE:  This utility is no longer used in versions 5.0 and beyond.
	;        The routine must be retained for backwards compatibility.
	;***********************************************************************
	;
	;---- Revision History ------------------------------------------------
	; 05/19/94 - Allan Mattson
	;            Removed the indirection calls to DDPUP^CRT0 and DDPDN^CRT0
	;            to correct an <UNDEFINED> error when entering the native
	;            teller posting screen (function CRT001).
	;----------------------------------------------------------------------
	;
	; ^EVENT(EVENT,E1) = EVENTNAM
	;             ,E1, FUN/UID/LOC) = ""
	;
	;           where E1 = 1-Functions, 2-Users, 3-Locations
	;
	N N,E,E1,X
	;
	I '$D(%EVENT) S %EVENT=""
	S N=$O(^EVENT(%EVENT)) I N="" Q  ; No new events
	S %EVENT=N,E=""
	;
	F E1=1,2,3 D LOOKUP I E]"" D TASK Q
	Q
	;
LOOKUP	; See if you are on the list of subjects
	;
	S X=$D(^EVENT(%EVENT,E1)) I X=0 Q
	S E=^(E1) I X=1 Q  ; All option was used
	I E1=1,$D(%FN),%FN]"",$D(^(E1,%FN)) Q
	I E1=2,$D(%UID),%UID]"",$D(^(E1,%UID)) Q
	I E1=3,$D(TLO),TLO]"",$D(^(E1,TLO)) Q
	S E="" Q
	;
TASK	; Accomplish the task set out to do
	;
	I $E(E)="N" D NETWORK Q
	I $E(E)="B" D BROADCAS Q
	I $E(E)="M" D MAIL Q
	I $E(E)="S" D SPECIAL Q
	Q
	;
NETWORK	; Network option was used
	;
	S %NET=^%ZDDP("%NET")
	I '$D(%FN) S ER="W",RM="Network is "_$S(%NET:"Offline",1:"Online") Q
	Q
	;
BROADCAS	; Broadcast a message
	;
	S RM="Message received from "_$E(E,2,999) D OUTPUT Q
	;
MAIL	; Mail was sent
	;
	S ER="W",RM="You have new mail" Q
	;
SPECIAL	; Special user defined code
	;
	X $E(E,2,999) Q
	;
OUTPUT	;
	I $D(OLNTB) S X=OLNTB\1000
	W $C(27)_"[6n" R X S X=$E($ZB,3,9)
	W $C(27)_"["_$S($D(OLNTB):OLNTB\1000,1:X+1)_";H"_$C(27)_"[J"
	;
OUT1	G OUT2:RM="" W !,$P(RM,"|",1) S RM=$P(RM,"|",2,999) G OUT1
OUT2	W $C(27)_"[24H"_$C(27)_"[J"_$C(27)_"[7m Press RETURN to continue:"
	W $C(7,27)_"[m " R *Z W $C(27)_"["_$E(X,1,$L(X)-1)_"H" Q
