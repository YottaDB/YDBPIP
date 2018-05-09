FORMHDR	;; -  - V5.0 - Form system record header
	;;Copyright(c)1997 Sanchez Computer Associates, Inc.  All Rights Reserved - 08/12/97 14:23:17 - NIB
	;     ORIG:  FSANCHEZ - 28 FEB 1990
	;     DESC:  
	;
	; I18N=QUIT	Excluded from I18N Standards
	; ---------- Revision History ------------------------------------------
	; 07/14/06 - RussellDS - CR22121
	;	     Replaced $A references with $$BSASCII^SQLUTL and $C with
	;	     $$BTYECHAR^SQLUTL to ensure Unicode compliance.
	;
	; 08/12/97 - Betty Ni - 25653
        ;            Replaced follows operator "]" with a "]]".
	;
	; 10/26/94 - Steve Canfield - I18N
	;	     Removed calls to $$^MSG.
	;
	; 10/25/93  Bob Chiang - I18N#23
	;
	;           Modified to replace DBSMENU routine calls with DBSMBAR.
	;
	;-----------------------------------------------------------------------
STYLE(LIST)	; ---------- Style option ----------
	;
	S LIST=$G(LIST)
	I LIST[";" S LIST=$TR(LIST,";7145",",1234") ; Convert VT220 escape
	I $E(LIST)="," S LIST=6_LIST I LIST="6," S LIST=6 ; Reset/No attributes
	;
	;
	;F I=1:1:$L(LIST,",") S FN=$P(LIST,",",I) S FN=$$^DBSMENU(.OP,"","",FN),$P(LIST,",",I)=FN I 'FN S LIST="" W:FN]]"" $$MSG^FORM(FN) Q
	;
	; Reverse,Bright,Underline,Blinking,Secret_Mode,Reset
	;
	S LIST=$$^DBSMBAR(118) I LIST="" Q	; *** BC - Style options 10/26/93
	D CHGVDO($$VIADD(LIST,VIDEO),1,LIST)
	;
	Q
	;
VIADD(NA,CA)	; ---------- Add new video attribute to current attr  ----------
	;
	N C
	S C=$$BSASCII^SQLUTL(CA,1)
	;
	I NA[6 S C=C\128*128 ; Reset
	I NA[1,C#2=0 S C=C+1 ; Add reverse
	I NA[2,C\2#2=0 S C=C+2 ; Add highlight
	I NA[3,C\4#2=0 S C=C+4 ; Add Underscore
	I NA[4,C\8#2=0 S C=C+8 ; Add Blinking
	I NA[5,C\16#2=0 S C=C+16 ; Add Secret Mode
	I C\64#2=0 S C=C+64 ; Turn on Bit 7
	Q $$BYTECHAR^SQLUTL(C)
	;
COLOR(C)	; ---------- Change background/Forground colors ----------
	;
	S C=$G(C)
	N FG,BG
	;
	S FG=$P(C," ",1) ; Foreground color
	S BG=$P(C," ",2) ; Background color
	;
	; Black,Red,Green,Yellow,Blue,Magenta,Cyan,White|Foreground
	; Black,Red,Green,Yellow,Blue,Magenta,Cyan,White|Background
	;
	S FG=$$^DBSMBAR(119) I 'FG Q	; *** - BC - Foreground color 10/25/93
	S BG=$$^DBSMBAR(120) I 'BG Q	; *** - BC - Background color 10/25/93
	;
	I FG=""!(BG="") Q
	;
	I FG=BG W $$MSG^FORM("Foreground & Background COLOR cannot be the same",1) Q
	;
	S C=(FG-1*8+BG)
	D CHGVDO($$BYTECHAR^SQLUTL(C),4)
	Q
	;
SIZE(FN)	; ---------- Character font size ----------
	;
	; Normal,Wide,Top_DHDW,Bottom_DHDW|Size:
	;
	N OP
	S OP(1)="Normal|0"
	S OP(2)="Wide|12"
	S OP(3)="Top_DHDW|24"
	S OP(4)="Bottom_DHDW|36"
	;
	S FN=$$^DBSMBAR(121) I 'FN Q	; *** BC - Object Size - 10/26/93
	;
	D CHGVDO($$BYTECHAR^SQLUTL($P(OP(FN),"|",2)),2)
	;
	W $$MSG^FORM("Size attributes assigned")
	Q
	;
GI	; Graphics toggle on
	;
	N H,X
	S H=$E(VIDEO) I H']]"~" S H=$$BYTECHAR^SQLUTL(128+$$BSASCII^SQLUTL(H,1))
	D CHGVDO(H,1)
	;
	S X="" F I=0:1:26 S $P(X," ",I)=GT(0)_$$BYTECHAR^SQLUTL(96+I)_GT(1)_$$BYTECHAR^SQLUTL(96+I)
	D VIDEO^FORM(VIDOF) W BTMPAG,X
	I video']]"~" W GT(0)
	Q
	;
GO	; Graphics toggle off
	;
	N H
	S H=$E(VIDEO) I H]]"~" S H=$$BYTECHAR^SQLUTL($$BSASCII^SQLUTL(H,1)#128)
	D CHGVDO(H,1)
	W $$MSG^FORM("Graphics OFF") Q
	;
GRAPH	;
	I VIDEO]]"~" G GO
	G GI
	;
ASKHDR(H,V)	; ---------- Ask for header information in DECIMAL ----------
	;
	I V["VI" S V=$P(V,"VI",1)_($$BSASCII^SQLUTL(H,1)#128#64)_$P(V,"VI",2)
	I V["GT" S V=$P(V,"GT",1)_($$BSASCII^SQLUTL(H,1)>127)_$P(V,"GT",2)
	Q V
CHGVDO(H,byte,OPT) ; ---------- Change default or selected objects only
	;
	N v
	S v=$E(VIDEO,1,byte-1)_H_$E(VIDEO,byte+1,999)
	I '$D(VA(v)) D VIDSP^FORMINIT(v) ; Add atributes to the display array
	I '$D(P) S VIDEO=v D:STATUS STATUSP^FORMSTAT Q  ; Change default
	;
	N H,NV,Z
	;
	; ---------- Change the video attribute of selected objects -------
	;
	S EDITED=1
	S py="",px=""
	F  S py=$O(P(py)) Q:py=""  F  S px=$O(P(py,px)) Q:px=""  D CS0
	K P
	Q 
CS0	;
	S NV=v
	I $G(OPT)'="" S Z=$E(P(py,px)),NV=$$VIADD(OPT,Z)_$E(NV,2,9)
	;
	S H=$$CS(P(py,px),NV,byte),M(py,px)=H_$E(M(py,px),7,9999)
	I '$D(VA(H)) D VIDSP^FORMINIT(H)
	D PUTOBJ^FORMFUN(py,px)
	Q
	;
CS(string,value,byte)	; ---------- Change <string> at <byte> to <value>
	;
	Q $E(string,1,byte-1)_$E(value,byte)_$E(string,byte+1,9999)
	;
