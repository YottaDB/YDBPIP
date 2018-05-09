FORMZB	;; -  - V4.2 - 
	;;Copyright(c)1994 Sanchez Computer Associates, Inc.  All Rights Reserved - 10/26/94 17:06:48 - CANFIELDS
	;     ORIG:  CHIANG - 28 FEB 1991
	;     DESC:  
	;
	; I18N=QUIT	Excluded from I18N Standards
	; ---------- Revision History ------------------------------------------
	; 07/14/06 - RussellDS - CR22121
	;	     Replaced $A references with $$BSASCII^SQLUTL and $C with
	;	     $$BTYECHAR^SQLUTL to ensure Unicode compliance.
	;
	; 10/26/94 - Steve Canfield - I18N
	;	     Removed calls to $$^MSG.
	;----------------------------------------------------------------------
	;
ZBINIT	;
	N X,I,J,ZB,KEYNAM
	D VT ; VT220 mode
	;
	I $G(^CUVAR("PC")) D PC ; Special keys for PC only
	;
	S I=0 F  S I=$O(X(I)) Q:I=""  F J=1:2 S X=$P(X(I),"|",J) Q:X=""  D SETFKEY
	D OPEN
	Q
SETFKEY ;
	S KEYNAM=$P(X(I),"|",J),ZB=$P(X(I),"|",J+1)
	;
	S %fkey(ZB)=KEYNAM,%fkey("*"_ZB)="*"_KEYNAM
	;
	S ^DBCTL("SYS","%KB",KEYNAM)=ZB,^("*"_KEYNAM)="*"_ZB
	Q
PC	;
	I ^("PC")=1 D PCAT Q
	I ^("PC")=2 D PCXT Q
	Q
	;----------------------------------------------------------------------
PCAT	; AT (286/386) with limited keyboard
	;----------------------------------------------------------------------
	;
	; ---------- ESC = ESC  F9=HLP  END=DO  (DATA-QWIK)
	;
	S X(9)="ESC|27|HLP|[20~|END|[4~"
	;
	; ---------- F6=KP0  F7=KPE  (OOE FUNCTION/OPTION DEF/LAYOUT)
	;
	S X(10)="KP0|[17~|*KP0|*[17~|KPE|[18~|*KPE|*[18~"
	Q
	;----------------------------------------------------------------------
PCXT	; XT with extended keyboard
	;----------------------------------------------------------------------
	;
	; ---------- ESC = ESC  F6=HLP  F7=KPE  F8=END F9-F12 (arrow keys)
	;
	S X(9)="ESC|27|HLP|[17~|KPE|[18~|END|[19~|*KPE|*[18~"
	;
	S X(10)="CUU|[20~|CUD|[21~|CUB|[26~|CUF|[28~"
	;
	Q
VT	;
	; ---------- Arrow keys and PF1-PF4  F6-F10
	;
	S X(1)="CUU|[A|CUD|[B|CUF|[C|CUB|[D|ALT|OP|PF2|OQ|PF3|OR|PF4|OS"
	S X(2)="F6|[17~|F7|[18~|F8|[19~|F9|[20~|F10|[21~"
	;
	; ---------- F11-F14 , HELP , DO , F17-F20
	;
	S X(3)="ESC|[23~|F12|[24~|F13|[25~|F14|[26~|HLP|[28~|END|[29~"
	S X(4)="F17|[31~|F18|[32~|F19|[33~|F20|[34~"
	;
	; ---------- FIND , INSERT , REMOVE , SELECT , PREV SCR , NEXT SCR
	;
	S X(5)="FND|[1~|INS|[2~|REM|[3~|SEL|[4~|PUP|[5~|PDN|[6~"
	;
	; ---------- CTRL/C , TAB , ENTER , CTRL/P , CTRL/W
	;
	S X(6)="BRK|3|TAB|9|ENT|13|PRN|16|DSP|23"
	;
	; ---------- Numeric Keypad
	;
	S X(7)="KP0|Op|KP1|Oq|KP2|Or|KP3|Os|KP4|Ot|KP5|Ou"
	S X(8)="KP6|Ov|KP7|Ow|KP8|Ox|KP9|Oy|KP,|Ol|KP-|Om|KP.|On|KPE|OM"
	Q
	;
	;----------------------------------------------------------------------
ZB	; Returns ZB=<terminator> and %fkey=<function_name>
	;----------------------------------------------------------------------
	;
	S %fkey=$$FK($S($L($ZB)<2:$$BSASCII^SQLUTL($ZB,1),1:$E($ZB,2,99))) Q:%fkey'="ALT"
	N X R X#1 S %fkey="*"_$$FK($S($L($ZB)<2:$$BSASCII^SQLUTL($ZB,1),1:$E($ZB,2,99))) Q
	;
FK(ZB)	;
	Q $G(%fkey(ZB))
	;
OPEN	;
	;
	; ---------- TAB , RETURN , CTRL/P , CTRL/W , DEL
	;
	S Z="ECHO/ESCAPE/NOEDIT/NOIMAGE/TERMINATOR=$C(9,13,16,23,127)"
	D TERM^%ZUSE(0,Z)
	Q
TEST	;
	;
	D ZBINIT
	;
	W $$KPAPP^%TRMVT ; Application keypad on
	;;W $C(155)_"?1h" ; disable cursor keys
	;
	U 0 W !!,"Press function key",!!
	;
	F I=1:1 R X#1 S ZB=$ZB D TEST1 W !,Z D ZB W "  ",%fkey,!
	Q
TEST1	;
	S Z="" F I=1:1:$L(ZB) S ZZ=$$BSASCII^SQLUTL(ZB,I) S Z=Z_$S(ZZ<32:ZZ_" ",1:$$BYTECHAR^SQLUTL(ZZ))
	Q
