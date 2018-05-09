FORMEXCH	;;DBS - UTL - V5.0 - EDITOR DATA EXCHANGE UTILITY
	;;Copyright(c)1999 Sanchez Computer Associates, Inc.  All Rights Reserved - 02/24/99 10:06:12 - CHIANG
	;     ORIG:  CHIANG - 14 FEB 1990
	;CALLED BY:  SCREEN/REPORT FUNCTION DRIVER (KB 3)
	;     DESC:  OOE IMPORT & EXPORT UTILITY
	;
	; I18N=QUIT	Excluded from I18N Standards
	; ---------- Revision History ------------------------------------------
	;
        ; 02/23/99  -  Chiang - 31754
        ;              Modified to use +$H (system date) as the input value
        ;              for the ^%ZM date utility.
        ;
        ;              Removed old revision history.
	;-----------------------------------------------------------------------
	;
START	;
	;
IMPORT(IO,OVERLAY)	;
	;
	; ln,col $C(0) Display attributes  $C(0) Data Item attributes
	;
	N zzm,zzd,X,Y,DX,DY,POS,VIEDO,MD
	;
	;
	I $G(IO)="*",$G(inputdev)'="" S IO=inputdev G IMPORT1
	;
	I $G(IO)="" S IO=$$^FORMREAD("",99,"Filename: ") Q:IO=""
	;
	D CLOSE^SCAIO    ; *** XUS
	;
	S STS=$$FILE^%ZOPEN(IO,"READ")
	I 'STS W $$MSG^FORM($P(STS,"|",2),1) Q
IMPORT1	;
	S X=$$^%ZREAD(IO,.ER) I ($E(X)="$") C:'$D(inputdev) IO Q
	;
	I X'[$C(0) D CLOSE^SCAIO D ^FORMCONV(IO) Q
	;
	; Overlay current screen ?
	;
	I $G(OVERLAY) S OFF=PY,px=1 G READ
	;
	; Save objects below current cursor position
	;
	S X="",OFF=PY+$G(YORIGIN)-1
	I $G(RULER) S OFF=OFF-1
	;
	S Y=OFF
	F  S Y=$O(M(Y)) Q:Y=""  F  S X=$O(M(Y,X)) Q:X=""  S zzm(Y,X)=M(Y,X) K M(Y,X) I $D(D(Y,X)) S zzd(Y,X)=D(Y,X) K D(Y,X)
	;
	S px=1
READ	;
	S X=$$^%ZREAD(IO,.ET) I ET G RES ; EOF
	I ($E(X)="$")!($A(X)=26) G RES
	;
	S POS=$P(X,$C(0),1),MD=$P(X,$C(0),2,999),VIDEO=$E(MD,1,6),MD=$E(MD,7,999)
	S M=$P(MD,$C(0),1),D=$P(MD,$C(0),2,99)
	I $L(D,$C(0))>12 S $P(D,$C(0),13)="",$P(D,$C(0),14)="" ; Remove PRE/POST PROC
	;
	S DY=+POS+OFF,DX=$P(POS,",",2)
	S M(DY,DX)=VIDEO_M I D'="" S D(DY,DX)=D
	G READ
	;
RES	;
	;
	D CLOSE^SCAIO
	;
	I $G(OVERLAY) G RES1
	;
	; Restore original M() and D()
	;
	S X="",Y="",OFF=DY-PY+1
	F  S Y=$O(zzm(Y)) Q:Y=""  F  S X=$O(zzm(Y,X))  Q:X=""  S M(Y+OFF,X)=zzm(Y,X) I $D(zzd(Y,X)) S D(Y+OFF,X)=zzd(Y,X)
RES1	;
	D PUTRGN^FORMFUN()
	;
	I $G(inputdev)="" D CLOSE^SCAIO Q   ; *** XUS 08/18/94
	U IO
	Q
	;
	; Export data from buffer
	;
EXPORT(IO,BUF)	;
	;
	; IO  = fle name
	; BUF = Buffer number
	;
	N X,Y,STS,OFF,DY,OP
	;
	I $G(BUF)="" S BUF=$O(R(""),-1) ; Last Buffer
	;
	S ^STBL("MBAR",114)="Full Screen,Buffer ~|Export Option:"
	S OP=1,OP(2)=BUF				; *** - BC - Buffer # - 10/25/93
	I BUF'="" S OP=$$^DBSMBAR(114,"","","",.OP) I 'OP Q	; *** menu option
EX1	;
	I $G(IO)="" S IO=$$^FORMREAD("",99,"Filename: ") Q:IO=""
	;
	D CLOSE^SCAIO     ; *** XUS 08/18/94
	S STS=$$FILE^%ZOPEN(IO,"WRITE/NEWV")
	I 'STS W $$MSG^FORM($P(STS,"|",2),1) Q
	;
	; Write Header record
	;
	; 02/23/99 BC
	;
	U IO W " *** OOE export file "_$$DAT^%ZM(+$H)_" "_$$TIM^%ZM_$C(0)_"  Access Files: "_$C(0)_$G(FILES),!
	;
	S X="",Y=""
	;
	I OP=1 F  S Y=$O(M(Y)) Q:Y=""  F  S X=$O(M(Y,X)) Q:X=""  D SAVE
	I OP=2 F  S Y=$O(R(BUF,Y)) Q:Y=""  F  S X=$O(R(BUF,Y,X)) Q:X=""  D SAVE
	U IO W $C(26) ; CTRL/Z (EOF)
	D CLOSE^SCAIO    ; *** XUS 08/18/94
	D MSG
	Q
SAVE	;
	I '$D(OFF) S OFF=Y-1
	S DY=Y-OFF
	U IO I OP=1 W DY_","_X_$C(0)_M(Y,X)_$C(0)_$G(D(Y,X)),! Q
	;
	U IO W DY_","_X_$C(0)_R(BUF,Y,X),!
	Q
	;
MSG	;
	W $$MSG^FORM("Done",1) Q	; *** BC - 11/02/93
	Q
