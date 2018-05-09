FORMCUR	;; -  - V5.0 - Form system commands for cursor positioning
	;;Copyright(c)1994 Sanchez Computer Associates, Inc.  All Rights Reserved - 10/26/94 16:16:10 - CANFIELDS
	;     Frank R. Sanchez (2497) - 04/30/89
	;
	; I18N=QUIT	Excluded from I18N Standards
	; ---------- Revision History ------------------------------------------
	; 05/17/06 - Allan Mattson - CR20048
	;            Replaced calls to $$UPPER^%ZFUNC with $$UPPER^SCAUTL.
	;
	; 10/26/94 - Steve Canfield - I18N
	;	     Removed calls to $$^MSG.
	;
	; 10/25/93  Bob Chiang - I18N#23
	;
	;           Modified to remove DBSMENU calls in "GETMARK" section.
	;
	;-----------------------------------------------------------------------
	;
FINDM(ZFIND,EXACT,MARKER)	; ---------- Find string in M(array) ----------
	;
	N AR
	S AR="M"
	I '$D(M) Q
	;
	I $G(ZFIND)="" S ZFIND=$$MORE^FORMCMD("FIND","EXACT","Find String: ") I ZFIND="" Q
	G FIND
	;
FINDD(ZFIND,EXACT,MARKER)	; ---------- Find string in D(array) --------
	;
	N AR
	I '$D(D) Q
	S AR="D"
	I $G(ZFIND)="" S ZFIND=$$MORE^FORMCMD("FIND_VAR","EXACT","Find Data: ") I ZFIND="" Q
	G FIND
FIND	;
	;
	N sx,sy,px,py,AS,F
	;
	S F=0,EXACT=$G(EXACT)
	I 'EXACT S ZFIND=$$TR(ZFIND)
	S sy=$ZP(M("")),sx=$ZP(M(sy,""))
	S py=$$ABSLTY^FORM-1,px=$$ABSLTX^FORM
	;
	I AR="M" S AS="$E(M(py,px),7,9999)" ; Image string
	E  S AS="$P(D(py,px),dl,1)" ; Data string
	;
	I 'EXACT S AS="$$TR("_AS_")"
	S AS="S F=$F("_AS_",ZFIND)"
	;
	D FINDPY
	I F G FINDB ; Found between the cursor and EOF
	;
	S sx=$$ABSLTX^FORM,sy=$$ABSLTY^FORM,py="",px=""
	;
	D FINDPY
	;
	I 'F W $$MSG^FORM("String not found") Q
	;
FINDB	; String found, go to it
	;
	I AR="M" S px=px+F-2
	D FRAME
	I $G(MARKER)'="" D MARK(MARKER) ; Set marker
	Q
	;
FINDPY	;
	S py=$O(@AR@(py)) I py="" Q
	;
FINDPX	S px=$O(@AR@(py,px))
	I px=""!(px>sx&(py>sy)) G FINDPY  
	X AS Q:F
	G FINDPX
	;
HOME	; Cursor to 1,1
	;
	S py=1,px=1 D FRAME
	Q
	;
END	; Cursor to RHTMAR & BOTMAR
	;
	I $D(M)<10 S py=1,px=1
	E  S py=$ZP(M("")),px=$ZP(M(py,"")),px=px+$L(M(py,px))-7
	D FRAME
	Q
	;
EOB	; Move to the end of the current object
	;
	S py=$$ABSLTY^FORM,px=$$ABSLTX^FORM,ox=$$ORIGIN^FORM
	I $D(M(py,ox)) S px=ox+$L(M(py,ox))-6
	E  S ox=$O(M(py,px)) I ox S px=ox+$L(M(py,ox))-6
	E  Q
	S PX=$$RELTVX S:PX>RHTMAR PX=RHTMAR
	Q
	;
FTAB	; ---------- Tab forward to the next object on the screen ----------
	;
	I '$D(M) Q
	S px=$$ABSLTX^FORM,py=$$ABSLTY^FORM
	D PUTCHR^FORM(PY,PX)
	F  S px=$O(M(py,px)) Q:px&(px'>(XORIGIN+RHTMAR))  S px=XORIGIN-1 D FTNY Q:py=""
	I '(px&py) Q
	;
TABMOV	; ---------- TAB to the new position and display coordinates ----------
	;
	S PY=$$RELTVY,PX=$$RELTVX
	W $$MSG^FORM("("_py_","_px_")"_$S($D(D(py,px)):" "_$P(D(py,px),dl,1),1:""))
	Q
	;
FTNY	; Get the next Y coordinate
	;
	S py=$O(M(py)) Q:py&(py'>(YORIGIN+NUMROW))
	S py=$O(M(YORIGIN-1)) S:py>(YORIGIN+NUMROW) py="" Q
	;
RTAB	; Tab To the previous filed on the screen
	;
	I '$D(M) Q
	S px=$$ABSLTX^FORM,py=$$ABSLTY^FORM
	D PUTCHR^FORM(.PY,.PX)
	F  S px=$ZP(M(py,px)) Q:(px&(px'<XORIGIN))  S px=XORIGIN+NUMCOL D RTPY Q:py=""
	I '(py&px) Q
	G TABMOV
	;
RTPY	; Gety the previous row with an object on it
	;
	S py=$ZP(M(py)) Q:py&(py'<YORIGIN)
	S py=$ZP(M(YORIGIN+NUMROW+1)) S:py<YORIGIN py="" Q
	;
EOL	; CURPOS to RHTMAR
	;
	I PX<RHTMAR S PX=RHTMAR   ; Move to right margin
	Q
	;
GOTO(X,MARKER)	; Goto CURPOS identified by operator
	;
	I $G(X)="" S X=$$^FORMREAD("",10,"("_$$ABSLTY(PY)_";"_$$ABSLTX(PX)_") Goto: ") Q:X=""
	;
	I X?1A.E S X=$$GETMARK(X) I X="" W $$MSG^FORM("Marker not defined",1) Q
	;
	F I=1:1:$L(X)+1 I ",;:."[$E(X,I) Q
	S py=$E(X,1,I-1),px=$E(X,I+1,999)
	;
	I py="" S py=$$ABSLTY(PY)
	I px="" S px=$$ABSLTX(PX)
	;
	I "+-"[$E(py) S py=$S(py="-":$O(M("")),py="+":$ZP(M("")),1:$$ABSLTY(PY)+py)
	I "+-"[$E(px) S px=$S(px="-":$$LFTX,px="+":$$RHTX,1:$$ABSLTX(PX)+px)
	;
	I py<1 S py=1
	E  I YLIMIT,py>YLIMIT S py=YLIMIT
	;
	I px<1 S px=1
	E  I XLIMIT,px>XLIMIT S px=XLIMIT
	;
	D FRAME
	I $G(MARKER)'="" D MARK(MARKER)
	Q
	;
MARK(X,LOC)	; ---------- Mark a location on the screen ----------
	;
	I $G(X)="" S X=$$^FORMREAD("",20,"Marker name: ") Q:X=""
	I X?1A.AN=0 W $$MSG^FORM("Alpha-Numeric marker only",1) Q
	;
	I $G(LOC)="" S LOC=$$ABSLTY(PY)_","_$$ABSLTX(PX)
	S X=$$TR(X),MARK(X)=LOC
	W $$MSG^FORM("Marker "_X_" set ("_LOC_")")
	Q
	;
GETMARK(X)	; ---------- Decode marker ----------
	;
	S X=$$TR(X)
	I $D(MARK(X)) Q MARK(X)
	;
	N I,OP,Z
	;
	S Z=X
	F I=1:1 S Z=$O(MARK(Z)) Q:$E(Z,1,$L(X))'=X  S OP(I)=Z
	;
	I I=2 S X=OP(1) Q MARK(X) ; One match
	Q ""  ; No matches found		; *** BC - Return error 10/25/93
	;
LFTX()	; Return the leftmost object column
	;
	N I,X,py
	;
	S py=$O(M("")) I py="" Q 1
	S X=$O(M(py,""))
	F  S py=$O(M(py)) Q:py=""  I $O(M(py,""))<X S X=$O(M(py,""))
	Q X
	;
RHTX()	; Return the rightmost object column
	;
	N I,X,py,px
	;
	S py=$O(M("")) I py="" Q 1
	S X=$ZP(M(py,""))
	;
	F  S py=$O(M(py)) Q:py=""  S px=$ZP(M(py,"")) I px,px+$L(M(py,px))>X S X=px+$L(M(py,px))
	Q X-6
	;
FRAME	; Move cursor if in current frame, else move the frame
	;
	N XIN,YIN
	;
	D FRAMCHK I XIN,YIN Q
	S PY=NUMROW\2,PX=NUMCOL\2 ; Locate the cursor in the middle of screen
	D FRAMXIN
	D FRAMCHK I XIN,YIN Q
	D FRAMYIN Q
	;
FRAMCHK	; Check required cursor position relative to the current frame
	;
	S Y=$$RELTVY,X=$$RELTVX
	;
	S YIN=1 I Y<TOPMAR!(Y>BOTMAR) S YIN=0
	S XIN=1 I X<LFTMAR!(X>RHTMAR) S XIN=0
	;
	I YIN,XIN S PY=Y,PX=X  ; New CURPOS is within frame
	I $D(inputdev) W $$CURPOS
	Q
	;
FRAMXIN	S XIN=X-PX I XIN G FRAMERT:XIN>0,FRAMELF
FRAMYIN	S YIN=Y-PY I YIN G FRAMEDN:YIN>0,FRAMEUP
	;
FRAMENEW	; Display new region
	;
	S YORIGIN=YORIGIN+Y-PY I YORIGIN<1 S PY=PY+YORIGIN-1,YORIGIN=1
	S XORIGIN=XORIGIN+X-PX I XORIGIN<1 S PX=PX+XORIGIN-1,XORIGIN=1
	I YLIMIT S X=YORIGIN+NUMROW-YLIMIT I X>0 S PY=PY+X-1,YORIGIN=BOTMAR-NUMROW+1
	I XLIMIT S X=XORIGIN+NUMCOL-XLIMIT I X>0 S PX=PX+X-1,XORIGIN=XLIMIT-NUMCOL+1
	D PUTRGN^FORMFUN()
	Q
	;
FRAMEUP	G FRAMENEW:NUMROW-20<-YIN D SCROLLUP^FORMPAN(-YIN) Q
FRAMEDN	G FRAMENEW:NUMROW-20<YIN D SCROLLDN^FORMPAN(YIN) Q
FRAMELF	G FRAMENEW:NUMCOL-20<-XIN D PANLFT^FORMPAN(-XIN) Q
FRAMERT	G FRAMENEW:NUMCOL-20<XIN D PANRHT^FORMPAN(XIN) Q
	;
CURPOS()	Q CSI_PY_";"_PX_"H"
	;
ABSLTY(Y)	Q Y+YORIGIN-TOPMAR ; Absolute Y coordinate
ABSLTX(X)	Q X+XORIGIN-LFTMAR ; Absolute X coordinate
RELTVY()	Q py-YORIGIN+TOPMAR ; Relative Y coordinate
RELTVX()	Q px-XORIGIN+LFTMAR ; Relative X coordinate
	;
TR(X)	Q $$UPPER^SCAUTL(X)
	;
