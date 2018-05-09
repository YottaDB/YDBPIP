FORMRULR	;; -  - V4.2- Form system utilities (Ruler)
	;;Copyright(c)1994 Sanchez Computer Associates, Inc.  All Rights Reserved - 10/26/94 16:46:43 - CANFIELDS
	;     ORIG:  Frank R. Sanchez (1) - 10/01/88
	;     DESC:
	;
	; I18N=QUIT	Excluded from I18N Standards
	; ---------- Revision History ------------------------------------------
	;
	; 10/26/94 - Steve Canfield - I18N
	;	     Removed calls to $$^MSG.
	;----------------------------------------------------------------------
	;
	I RULER G OFF
ON	;
	I RULER Q  ; Already ON
	D ON1
	S:PX+1<RHTMAR PX=PX+2
	S:PY<BOTMAR PY=PY+1
	W $$REGION(TOPMAR,BOTMAR)
	Q
	;
ON1	; Turn the ruler on
	;
	N X,I,NN,LL
	;
	I 'RULER S RULER=2,LFTMAR=3,TOPMAR=TOPMAR+1,NUMCOL=NUMCOL-2,NUMROW=NUMROW-1
	;
	S N=YORIGIN,LL=YORIGIN,NN=YORIGIN+NUMROW-1,MOVE=$$CHRINS(RULER)
	W $$CUR(TOPMAR-1,1),LININS,MOVDN,MOVE
	F  S N=$O(M(N)) Q:N=""!(N>NN)  W CSI,N-LL,"B",MOVE S LL=N
	;
	D COL() ; Output columns
	D ROW() ; Output rows
	Q
	;
COL(LFTX,EXTX,PY)	; Output columns
	;
	N X,Z
	I '$G(LFTX) S LFTX=1
	I '$G(EXTX) S EXTX=RHTMAR-LFTX
	I '$G(PY) S PY=TOPMAR-1
	;
	S Z=XORIGIN+LFTX-2\10*10
	S X="" F I=0:10:EXTX+9 S Z=Z+10,X=X_$E("----+----",1,10-$L(Z))_Z
	S Z=XORIGIN+LFTX-2#10+1
	D VIDEO^FORM(VIDRV)
	W $$CUR(PY,LFTX+RULER),$E(X,Z,RHTMAR-LFTX+Z-RULER) Q
	;
ROW(TOPY,EXTY)	; Output rows
	;
	I '$D(TOPY) S TOPY=TOPMAR
	I '$D(EXTY) S EXTY=BOTMAR-TOPY+1
	;
	D VIDEO^FORM(VIDRV)
	W $$CUR(TOPY,1)
	S TOPY=$$ABSLTY(TOPY),EXTY=TOPY+EXTY-1
	F TOPY=TOPY:1:EXTY-1 W $E(TOPY#100+100,2,3),!
	W $E(EXTY#100+100,2,3)
	Q
	;
OFF	; Turn ruler grid off
	;
	I 'RULER Q  ; Already OFF
	;
	N LL,MOVE,N,NN,X
	S PX=PX-2,PY=PY-1,LFTMAR=LFTMAR-2,TOPMAR=TOPMAR-1,NUMCOL=NUMCOL+2,NUMROW=NUMROW+1
	;
	W $$REGION(TOPMAR,BOTMAR),$$CUR(TOPMAR,LFTMAR)
	W LINDEL
	;
	S X=$C(32,32,13)_CSI_"B",$P(X,X,YORIGIN+NUMROW-1)="" W X
	S N=YORIGIN,LL=N,NN=YORIGIN+NUMROW,MOVE=$$CHRDEL(2),RULER=0
	;
	W $$CUR(TOPMAR,1),MOVE
	F  S N=$O(M(N)) Q:N=""!(N>NN)  W:N-LL CSI,N-LL,"B" W MOVE S LL=N
	;
	D PUTRGN^FORMFUN(BOTMAR_";"_LFTMAR)
	D PUTRGN^FORMFUN(TOPMAR_";"_(RHTMAR-1),NUMROW_";2")
	Q
	;
	;
SELECT	; Select a row
	;
	S y=$$ABSLTY(PY) I $D(ARRAY(y)) K ARRAY(y) S X=VIDRV
	E  S ARRAY(y)="",X=VIDBF
	D VIDEO^FORM(X) W $E(y#100+100,2,3)
	W $$MSG^FORM("Row ",y,$S($D(ARRAY(y)):" Selected",1:" Deleted"))
	Q
	;
ABSLTY(Y)	Q Y+YORIGIN-TOPMAR ; Absolute Y coordinate
ABSLTX(X)	Q X+XORIGIN-LFTMAR ; Absolute X coordinate
RELTVY(Y)	Q Y-YORIGIN+TOPMAR ; Relative Y coordinate
RELTVX(X)	Q X-XORIGIN+LFTMAR ; Relative X coordinate
	;
CUR(Y,X)	Q CSI_Y_";"_X_"H" ; Direct cursor address
REGION(Y,X)	Q CSI_Y_";"_X_"r" ; Scrolling region
CHRDEL(X)	Q CSI_X_"P"
CHRINS(X)	Q CSI_X_"@"
LININS(X)	Q CSI_X_"L"
LINDEL(X)	Q CSI_X_"M"
MOVLFT(X)	Q CSI_X_"D"
MOVUP(X)	Q CSI_X_"A"
