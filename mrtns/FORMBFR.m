FORMBFR(B)	;; -  - V5.0 - Form system buffer management
	;;Copyright(c)1997 Sanchez Computer Associates, Inc.  All Rights Reserved - 08/12/97 13:55:38 - NIB
	;     ORIG:  Frank R. Sanchez (1) - 11/03/88
	;
	; I18N=QUIT	Excluded from I18N Standards
	; ---------- Revision History ------------------------------------------
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
	;
	I $G(B)="" S B=$ZP(R("")) I B="" G EXIT ; Get the last buffer
	;
	I '$D(R(B)) W $$MSG^FORM("Buffer "_B_" doesn't exist",1) G EXIT
	;
	N BUFCUP,CLR,RHTX,OX,OY,EX,EY,px,py,yy
	;
	D WRITMSG
	;
SELECT	;
	;
	D XYOFSET(B)
	;
	D VIDEO^FORM(VIDBF) ; Buffer video display
	;
	S RHTX=XORIGIN+RHTMAR-RULER
	S py=0,px=0,CLR=0
	F  S py=$O(R(B,py)) Q:py=""  F  S px=$O(R(B,py,px)) Q:px=""  D PUTOBJ(py,px)
	;
SELREAD	; Read operator control of buffer placement/selection
	;
	I '$D(move) D:video'=VIDOF VIDEO^FORMFUN(VIDOF) W BUFCUP,B,RCP
	;
	R X#12 I X'="",'$D(move) G SELECT:'$D(R(X)) S B=X D REDRAW G SELECT
	;
	D ZB^%ZREAD
	;
	I %fkey="CUF",PX<RHTMAR S PX=PX+1 D REDRAW G SELECT
	I %fkey="CUB",PX>LFTMAR,OX>LFTMAR S PX=PX-1 D REDRAW G SELECT
	I %fkey="CUD",PY<BOTMAR S PY=PY+1 D REDRAW G SELECT
	I %fkey="CUU",PY>TOPMAR,OY>TOPMAR S PY=PY-1 D REDRAW G SELECT
	I %fkey="HLP" D HELP^FORMFUN("INSERT"),WRITMSG G SELECT
	I %fkey="ENT" G EXIT ; Past buffer
	;
	I $D(move) W BEL G SELREAD ; Other buffer commands are not allowed
	;
	I %fkey="PDN" S B=$O(R(B)) S:B="" B=$O(R(B)) D REDRAW G SELECT
	I %fkey="PUP" S B=$ZP(R(B)) S:B="" B=$ZP(R("")) D REDRAW G SELECT
	;
	I %fkey="PF4" S B="" G EXIT  ; Temporarily copy this buffer
	I %fkey="ESC" D REDRAW S B="" G EXIT ; Quit without pasting
	;
	W BEL G SELREAD
	;
EXIT	;
	I video'=VIDOF D VIDEO^FORMFUN(VIDOF)
	W CURON
	I $G(JRNL)'="" U JRNL W " /LOC=",$$ABSLTY(PY),",",$$ABSLTX(PX) U ""
	Q B
	;
REDRAW	; Repaint the screen with the original objects
	;
	N LM,RM
	;
	D:video'=VIDOF VIDEO^FORMFUN(VIDOF)
	F I=1:1:CLR D REDRAB
	Q
	;
REDRAB ; ---------- Redraw the original object ----------
	;
	W CLR(I),SCP
	S X=$P(CLR(I),CSI,2,3) ; Remove leading CSI
	S py=$$ABSLTY(+X)
	I '$D(M(py)) Q  ; There are no objects on this line 
	;
	S px=$$ABSLTX(+$P(X,";",2))
	S LM=px,RM=px+$P(X,CSI,2)-1
	S px=$ZP(M(py,px))-1
	F  S px=$O(M(py,px)) Q:px=""!(px>RM)  D REDRAWC
	Q
REDRAWC	;
	;
	S Z=$E(M(py,px),7,9999),H=$E(M(py,px),1,6)
	S Z=$E(Z,LM-px+1,RM-px+1) I Z="" Q
	W RCP I px>LM W CSI,px-LM,"C"
	I H'=video D VIDEO^FORMFUN(H)
	W Z
	Q
	;
WRITMSG ;  ---------- Write the bottom line message ----------
	;
	W CUROF,BTMPAG D VIDEO^FORM(VIDOF)
	;
	I $D(move) W "Use arrow keys to move, ",VA(VIDHL),"RETURN",VA(VIDOF)," to INSERT" Q
	;
	W "Insert buffer ",CSI,"6CPress "
	W VA(VIDHL),"RETURN",VA(VIDOF)," to INSERT, "
	W VA(VIDHL),"PF4",VA(VIDOF)," to MASK, "
	W VA(VIDHL),"F11",VA(VIDOF)," to QUIT"
	S BUFCUP=CSI_(BOTMAR+1+STATUS)_";15H"_SCP_CSI_"5X"
	Q
	;
	;
PUTOBJ(py,px)	; Display an object
	;
	S X=R(B,py,px),py=OFSETY+py,px=OFSETX+px
	I X]]"~"'=gt S gt='gt W GT(gt)
	S X=$E($P($E(X,7,9999),NUL,1),XORIGIN-px+1,RHTX-px) Q:X=""
	;
	S yy=py-YORIGIN+TOPMAR I yy<TOPMAR!(yy>BOTMAR) Q
	;
	S yy=CSI_yy_";"_($S(px<XORIGIN:XORIGIN,1:px)-XORIGIN+LFTMAR)_"H"
	W yy,X S CLR=CLR+1,CLR(CLR)=yy_CSI_$L(X)_"X"
	Q
	;
SAVE(CLEAR)	; Save the current selection list P( into a buffer R(R,py,px)
	;
	I '$D(P) W $$MSG^FORM("Extract buffer is empty") Q
	;
	N ox,oy,py,px,xl,xr,I,J
	;
	S R=$$NEXTBUFR
	;
	I R>10 S J=$O(R("")) F I=J:1:R-10  K R(I)
	;
	S oy=$O(P("")),xl=$O(P(oy,"")),xr="",px="",py=""
	;
	F  S py=$O(P(py)) Q:py=""  F  S px=$O(P(py,px)) Q:px=""  S R(R,py,px)=P(py,px)_$E(M(py,px),7,999)_NUL_$G(D(py,px)) S:px<xl xl=px S:$L(M(py,px))+px>xr xr=px+$L(M(py,px))
	;
	S R(R)=$$HEADER
	I CLEAR D SELOFF^FORMSEL(0)
	;I '$D(move) W $$MSG^FORM("Buffer "_R_" extracted")
	Q
BUFCLR(B)	; ---------- Clear buffers ----------
	;
	I '$D(R) Q
	I $G(B)'="",$D(R(B)) K R(B) W $$MSG^FORM("Buffer "_B_" removed") Q
	;
	N I
	F I=0:1 S B=$O(R("")) Q:B=""!(B]]"@")  K R(B)
	W $$MSG^FORM(I_" Buffers removed")
	Q
	;
BUFCOP(X)	; ---------- Copy buffer (OLD) into buffer (New) ----------
	;
	I $G(X)="" S X=$$^FORMREAD("","","Name [Buffer]: ") I X="" Q
	;
	S T=$P(X," ",1),F=$P(X," ",2)
	I T="" S T=F I T="" Q
	;
	I F="" S F=$ZP(R("@")) ; Default to the last numeric buffer
	;
	I '$D(R(F)) W $$MSG^FORM("Buffer "_F_" Doesn't exist",1) Q
	;
	K R(T) ; Clear contents of new buffer if they are there
	S R(T)=R(F) ; Copy the header from the old to new buffer
	;
	N py,px
	S py="",px=""
	;
	F  S py=$O(R(F,py)) Q:py=""  F  S px=$O(R(F,py,px)) Q:px=""  S R(T,py,px)=R(F,py,px)
	;
	K R(F) ; Delete the original buffer
	;
	W $$MSG^FORM("Buffer "_F_" copied to "_T)
	Q
	;
HEADER()	; Create a buffer header
	;
	Q xl_"|"_(xr-6)_"|"_-$$ABSLTY^FORM_"|"_-$$ABSLTX^FORM_"|"_$G(ZB)
	;
NEXTBUFR()	; Assign the next buffer, wrap around after 20
	;
	Q $ZP(R("%"))+1
	;
XYOFSET(B)	; Determine px axis ofset (X) and Y axis ofset for buffer insert
	;
	S Z=R(B)
	S OFSETY=$P(Z,"|",3)+PY+YORIGIN-TOPMAR
	S OFSETX=$P(Z,"|",4)+PX+XORIGIN-LFTMAR
	;
	S OY=$O(R(B,""))+OFSETY I OY<1 S OFSETY=OFSETY-OY+1,PY=PY-OY+1,OY=1
	S OX=Z+OFSETX I OX<1 S OFSETX=OFSETX-OX+1,PX=PX-OX+1,OX=1
	;
	S EY=$ZP(R(B,""))+OFSETY-OY
	S EX=$P(Z,"|",2)+OFSETX-OX
	;
	I OY+EY>YLIMIT S OFSETY=OFSETY+YLIMIT-OY-EY,OY=YLIMIT-EY
	I OX+EX>XLIMIT S OFSETX=OFSETX+XLIMIT-OX-EX,OX=XLIMIT-EX
	;
	S OY=OY-YORIGIN+TOPMAR I OY<TOPMAR S EY=EY+OY-TOPMAR,OY=TOPMAR
	S OX=OX-XORIGIN+LFTMAR I OX<LFTMAR S EX=EX+OX-LFTMAR,OX=LFTMAR
	;
	S ORIGIN=OY_";"_OX,EXTANT=EY_";"_EX
	Q
	;
INPUTDEV ; ---------- Remote entry ----------
	;
	N X
	S X=$$READAHED^FORMCMD Q:X=""
	I '$D(RN) S RN=X
	E  S POS=X Q
	S X=$$READAHED^FORMCMD Q:X=""
	S POS=X
	Q
BUFMGR(OP)	;
	;
	I $O(R(""))="" W $$MSG^FORM("Extract buffer is empty") Q
	;
	; "Rename_Buffer,Clear_Buffer"
	;
	S OP=$$^DBSMBAR(112) I 'OP Q	; *** - BC - Menu option 112 - 10/25/93
	I OP=1 D BUFCOP() Q
	I OP=2 D BUFCLR() Q
	Q
	;
CURPOS()	Q CSI_PY_";"_PX_"H" ; Current Cursor position
ABSLTY(Y)	Q Y+YORIGIN-TOPMAR ; Absolute Y coordinate
ABSLTX(X)	Q X+XORIGIN-LFTMAR ; Absolute X coordinate
RELTVY(Y)	Q Y-YORIGIN+TOPMAR ; Relative Y coordinate
RELTVX(X)	Q X-XORIGIN+LFTMAR ; Relative X coordinate
