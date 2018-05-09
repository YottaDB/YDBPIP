FORMPAN	;; -  - V3.0 - Form system window panning utilities
	;;Copyright(c)1990 Sanchez Computer Associates, Inc.  All Rights Reserved -  4 MAR 1990 11:05:31 - FSANCHEZ
	;     ORIG:  Frank R. Sanchez (1) - 10/01/88
	;CALLED BY:
	;    CALLS:
	;           
	;     DESC: SCROLLUP(W)	- Scroll window up (W) lines
	;	    SCROLLDN(W)	- Scroll window down (W) lines
	;           PANLFT(W)	- Pan window left (W) columns
	;	    PANRHT(W)	- Pan window right (W) columns
	;
	; GLOBALS - 
	;     READ:
	;      SET:
	;
	;    INPUT:
	;   OUTPUT:
	;
PANLFT(W)	; Pan the screen left W columns <---
	;
	I '$D(W) S W=$P(ST8,"|",7)
	;
	S PX=PX-W,M=W\2+LFTMAR I PX'<M Q  ; Cursor moves within current window
	I XORIGIN=1 S:PX<LFTMAR PX=LFTMAR Q
	S W=M-PX,PX=M
	I XORIGIN-W<1 S PX=PX-W+XORIGIN,W=XORIGIN-1 I PX<LFTMAR S PX=LFTMAR
	I W S MOVE=$$CHRINS(W),XORIGIN=XORIGIN-W,LFTX=LFTMAR D PANMOV
	Q
	;
PANRHT(W)	; Pan the screen right W columns --->
	;
	I '$D(W) S W=$P(ST8,"|",7)
	S PX=PX+W,M=RHTMAR-(W\2) I PX'>M Q  ; Move cursor within the window
	I $$ABSLTX(RHTMAR)=XLIMIT,$$ABSLTX(PX)>XLIMIT S PX=RHTMAR Q
	S W=PX-M,PX=M
	I $$ABSLTX(RHTMAR)+W>XLIMIT S Z=$$RELTVX(XLIMIT)-RHTMAR,PX=PX+W-Z,W=Z
	I W S MOVE=$$CHRDEL(W),XORIGIN=XORIGIN+W,LFTX=RHTMAR-W+1 D PANMOV
	Q
	;
PANMOV	; Move <--- or ----> W columns
	;
	I RULER W $$CUR(TOPMAR-1,RULER+1),MOVE D COL^FORMRULR(LFTX-2,W)
	W $$CUR(TOPMAR,RULER+1),MOVE
	S N=YORIGIN,NN=YORIGIN+NUMROW-1,LL=YORIGIN
	F  S N=$O(M(N)) Q:N=""!(N>NN)  W CSI,N-LL,"B",MOVE S LL=N
	D PUTRGN^FORMFUN(TOPMAR_";"_LFTX,NUMROW_";"_W)
	I STATUS D SHOWTOP
	Q
SCROLLUP(W)	; Scroll up (^) W lines
	;
	I '$D(W) S W=$P(ST8,"|",6)
	;
	S PY=PY-W,M=W\2+TOPMAR I PY'<M Q
	I YORIGIN=1 S:PY<TOPMAR PY=TOPMAR Q
	S W=M-PY,PY=M
	I YORIGIN-W<1 S PY=PY-W+YORIGIN,W=YORIGIN-1
	I W S MOVE=$$LININS(W),YORIGIN=YORIGIN-W,TOPY=TOPMAR D SCROLL
	Q
	;
SCROLLDN(W)	; Scroll down (V) W lines
	;
	I '$D(W) S W=$P(ST8,"|",6)
	;
	S PY=PY+W,M=BOTMAR-(W\2) I PY'>M Q  ; Move cursor within the window
	I $$ABSLTY(BOTMAR)=YLIMIT,$$ABSLTY(PY)>YLIMIT S PY=BOTMAR Q
	S W=PY-M,PY=M
	I $$ABSLTY(BOTMAR)+W>YLIMIT S w=W,W=YLIMIT-$$ABSLTY(BOTMAR),PY=PY+w-W I PY>BOTMAR S PY=BOTMAR
	I W S YORIGIN=YORIGIN+W,MOVE=$$LINDEL(W),TOPY=BOTMAR-W+1 D SCROLL
	Q
	;
SCROLL	;
	;
	W $$CUR(TOPMAR,1),MOVE ; Insert or delete lines
	;
	D PUTRGN^FORMFUN(TOPY_";"_LFTMAR,W_";"_NUMCOL)
	I STATUS D SHOWTOP
	Q
	;
SHOWTOP	; ---------- Display the new TOP LEFT position on the status ----------
	;
	D VIDEO^FORM(VIDRV)
	W $$CUR(BOTMAR+1,6),$E(1000+YORIGIN,2,4),",",$E(1000+XORIGIN,2,4)
	Q
	;
ABSLTY(Y)	Q Y+YORIGIN-TOPMAR ; Absolute Y coordinate
ABSLTX(X)	Q X+XORIGIN-LFTMAR ; Absolute X coordinate
RELTVY(Y)	Q Y-YORIGIN+TOPMAR ; Relative Y coordinate
RELTVX(X)	Q X-XORIGIN+LFTMAR ; Relative X coordinate
CUR(Y,X)	Q CSI_Y_";"_X_"H" ; Direct cursor address
CHRDEL(X)	Q CSI_X_"P"
CHRINS(X)	Q CSI_X_"@"
LININS(X)	Q CSI_X_"L"
LINDEL(X)	Q CSI_X_"M"
