FORMSTAT	;; -  - V4.1 - Form system status line display
	;;Copyright(c)1994 Sanchez Computer Associates, Inc.  All Rights Reserved - 10/26/94 16:49:19 - CANFIELDS
	;     ORIG:  Frank R. Sanchez (1) - 10/01/88
	;     DESC: 
	;
	; I18N=QUIT	Excluded from I18N Standards
	; ---------- Revision History ------------------------------------------
	; 07/14/06 - RussellDS - CR22121
	;	     Replaced $A references with $$BSASCII^SQLUTL to ensure
	;	     Unicode compliance.
	;
	; 10/26/94 - Steve Canfield - I18N
	;	     Removed calls to $$^MSG.
	;
STATUS	; -------------- Toggle status on/off --------------------
	;
	I STATUS G OFF
ON	;
	I STATUS Q  ; Already ON
	S STATUS=1,BOTMAR=BOTMAR-1,NUMROW=NUMROW-1
	I PY>BOTMAR S PY=BOTMAR D SCROLLDN^FORMPAN(1)
	;
	W $$REGION^FORMINIT(TOPMAR,BOTMAR)
	;
STATUSP	; ---------- Print status line information ------------
	;
	N X,Z
	;
	S X="Top: "_$E(1000+YORIGIN,2,4)_","_$E(1000+XORIGIN,2,4)_" | "
	S:$$BSASCII^SQLUTL(VIDEO,1)<128 X=X_"No " S X=X_"Graphics | "
	S:$$BSASCII^SQLUTL(VIDEO,1)#128#64=0 X=X_"No " S X=X_"Video | "
	S Z=+FORMHDG I Z=9 S Z=+$P(FORMHDG,";",2)
	S X=X_$S(Z=1:"Right Justified",Z=2:"Left Justified",Z=3:"Justified Column",Z=4:"Centered Column",1:"Headings Off")
	;
	S X=X_$J("",80-$L(X))
	D VIDEO^FORM(VIDRV) W $$CUR(BOTMAR+1,1),CLEOL,X
	Q
	;
OFF	; ---------- Turn off status and redisplay line ----------
	;
	W BTMPAG 
	S STATUS="",BOTMAR=BOTMAR+1,NUMROW=NUMROW+1,py=$$ABSLTY^FORM 
	W $$CLPAG^FORMINIT(BOTMAR),$$REGION^FORMINIT(TOPMAR,BOTMAR) 
	; 
	I BOTMAR+YORIGIN-2<YLIMIT D PUTRGN^FORMFUN(BOTMAR_";"_LFTMAR)
	E  I YORIGIN>1 S PY=TOPMAR D SCROLLUP^FORMPAN(1)
	;
	S PY=py-YORIGIN+TOPMAR
	Q
	;
RESET(O)	; ---------- Turn off Headings, Style, Graphics ----------
	; 
	S FORMHDG="" ; Heading Option Off
	S VIDEO=VIDOF D VIDEO^FORM(VIDOF) ; Style and graphics Off
	I STATUS D STATUSP
	W $$MSG^FORM("Headings, Style, & Graphics are off")
	Q
	;
CUR(Y,X)	Q CSI_Y_";"_X_"H" ; Direct cursor address
