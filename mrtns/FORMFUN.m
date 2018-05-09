FORMFUN	; V5.0
	;;Copyright(c)1997 Sanchez Computer Associates, Inc.  All Rights Reserved - 08/12/97 14:22:26 - NIB
	;     ORIG:  Frank R. Sanchez (1) - 10/01/88
	;     DESC:  OOE Utilities
	;
	; I18N=QUIT	Excluded from I18N Standards
	; ---------- Revision History ------------------------------------------
	; 07/14/06 - RussellDS - CR20048
	;	     Replaced $A references with $$BSASCII^SQLUTL and $C with
	;	     $$BTYECHAR^SQLUTL to ensure Unicode compliance.
	;
	; 05/17/06 - Allan Mattson - CR20048
	;            Replaced calls to $$UPPER^%ZFUNC with $$UPPER^SCAUTL.
	;
	;            Deleted pre-1996 revision history.
	;
	; 08/12/97 - Betty Ni - 25653
        ;            Replaced follows operator "]" with a "]]".
	;
	; 09/20/96 - Bob Chiang - 20948
	;            Modified CLRRGN section to replace $C(10) with $$CUD
	;            (Move cursor down) command.
	;-----------------------------------------------------------------------
	;
INSERT(RN,LOC)	; Insert object buffer
	;
	N xx,yy,BFR,OFSETY,OFSETX
	;
	I '$D(R) W $$MSG^FORM("Buffer is empty") Q	; *** BC - 11/02/93
	;
	I $G(RN)="" S RN=$ZP(R("%")) ; 		Default to last buffer
	;
	I $G(LOC)'="" D GOTO^FORMCUR(LOC),XYOFSET^FORMBFR(RN) I 1
	E  S RN=$$^FORMBFR(RN) W BTMPAG
	I RN="" Q
	;
	S EDITED=1
	D INSERTP I '$D(BFR) Q
	;
INSERTB	; ---------- Put header on the buffer ----------
	;
	S oy=$O(R(BFR,"")),R(BFR)=$$HEADER^FORMBFR
	W $$MSG^FORM("Overlayed objects saved into buffer "_BFR)
	Q
	;
INSERTP	S px="",py=""
INSERTY	S py=$O(R(RN,py)) I py="" Q
INSERTX	S px=$O(R(RN,py,px)) I px="" G INSERTY
	;
	S yy=py+OFSETY,xx=px+OFSETX,M=R(RN,py,px),H=$E(M,1,6),M=$E(M,7,9999)
	;
	D FIT(yy,xx,$L($P(M,NUL,1)))
	;
	S M(yy,xx)=H_$P(M,NUL,1)
	I $P(M,NUL,2)'="" S D(yy,xx)=$P(M,NUL,2,99)
	D PUTOBJ(yy,xx) G INSERTX
	;
FIT(py,px,l)	; Check for fit and extract overlaping objects
	;
	I '$D(M(py)) Q  ; There are no objects on this row
	;
	N ox
	S ox=$ZP(M(py,px+1)) I ox,ox+$L(M(py,ox))-6>px D EXTRACT  ; previous object
	S ox=px,l=px+l F  S ox=$O(M(py,ox)) q:ox=""!(ox'<l)  D EXTRACT
	Q
	;
EXTRACT	; Object overlap, extract previous object
	;
	I '$D(BFR) S BFR=$$NEXTBUFR^FORMBFR,xl=ox,xr="" ; Initialize buffer
	D CLROBJ(py,ox) ; Remove the old object
	S:ox<xl xl=ox S:ox+$L(M(py,ox))>xr xr=ox+$L(M(py,ox))
	S R(BFR,py,ox)=M(py,ox)_NUL_$G(D(py,ox))
	K M(py,ox),D(py,ox),P(py,ox)
	Q
	;
TEXT(X,LOC,STYLE,SIZE,COLOR,MARKER)	; Place a string at the current position
	;
	N vv
	I $G(LOC)'="" D GOTO^FORMCUR(LOC)
	S py=$$ABSLTY(PY),px=$$ABSLTX(PX),vv=VIDEO
	;
	I $G(X)="" S X=$$MORE^FORMCMD("Text","LOC/STYLE/SIZE/COLOR") S X=""
	;
	I $G(STYLE)'="" D STYLE^FORMHDR(STYLE)
	I $G(SIZE)'="" D SIZE^FORMHDR(SIZE)
	I $G(COLOR)'="" D COLOR^FORMHDR(COLOR)
	;
	N BFR
	D FIT(py,px,$L(X))
	S PX=PX+$L(X)
	S ox=$ZP(M(py,px+1))
	I ox,ox+$L(M(py,ox))-6=px,$E(M(py,ox),1,6)=VIDEO S X=$E(M(py,ox),7,999)_X,px=ox
	S M(py,px)=VIDEO_X,VIDEO=vv
	D PUTOBJ(py,px)
	I $D(BFR),'$D(inputdev) D INSERTB
	I $G(MARKER)'="" D MARK^FORMCUR(MARKER,py_","_px)
	Q
	;
PUTRGN(ORIGIN,EXTANT,CLR)	; ---------- Display a region of data ----------
	;
	I '$D(ORIGIN) D REFRESH
	I $D(CLR) D CLRRGN
	;
	N py,px,BOTY,TOPY,RHTX,LFTX
	;
	W CUROF
	D PARSRGN
	I RULER,$P(ORIGIN,";",2)=LFTMAR,$P(EXTANT,";",2)=NUMCOL D ROW^FORMRULR(+ORIGIN,+EXTANT)
	;
	S py=TOPY-1
	F  S py=$O(M(py)) Q:py=""!(py>BOTY)  S px=$ZP(M(py,LFTX))-1 F  S px=$O(M(py,px)) Q:px=""!(px>RHTX)  D PUTOBJ(.py,.px,.LFTX,.RHTX)
	;
	I $D(ANCHOR) D PUTANCH^FORMSEL()
	W CURON
	Q
REFRESH	; Reinitialize the display (Margin, Status_line, Ruler, Objects)
	;
	S ORIGIN=TOPMAR_";"_LFTMAR,EXTANT=NUMROW_";"_NUMCOL
	K CLR
	;
	I RHTMAR=80 W $$ST80^FORMINIT ; Set margin to 81 and video display to 80
	E  W $$ST132^FORMINIT ; Set margin to 133 and video display to 132
	;
	I RULER D COL^FORMRULR()
	I STATUS D STATUSP^FORMSTAT
	D TRMSET^FORMINIT
	W $$INSMOFF^%TRMVT		; Turn insert mode off
	Q
	;
	;----------------------------------------------------------------------
CLRRGN	; Clear a region of the screen
	;----------------------------------------------------------------------
	; INPUTS:
	;	ORIGIN		$Y;$X location
	;       EXTANT		y_offset;x_offset
	;
	I $P(ORIGIN,";",2)=LFTMAR,$P(EXTANT,";",2)=NUMCOL W $$CLPAG^FORMINIT(+ORIGIN,ORIGIN+EXTANT) Q
	;
	W $$CUR(+ORIGIN,$P(ORIGIN,";",2)) ; Locate the cursor on the origin
	;
	N X,Y
	S X=CSI_$P(EXTANT,";",2)_"X"		; Delete number of characters
	W X F Y=2:1:EXTANT W $$CUD(1),X		; *** 09/20/96 delete lines
	Q
	;
PUTOBJ(py,px,LFTX,RHTX)	; Display an object
	;
	N yy,xx
	I '$D(LFTX) S LFTX=XORIGIN,RHTX=XORIGIN+RHTMAR-RULER
	;
	S M=M(py,px),X=$E($E(M,7,999),LFTX-px+1,RHTX-px) Q:X=""
	;
	s yy=py-YORIGIN+TOPMAR I yy<TOPMAR!(yy>BOTMAR) Q
	s xx=$S(px<LFTX:LFTX,1:px)-XORIGIN+LFTMAR
	;
	S H=$E(M,1,6) I video'=H D VIDEO(H) ; Change video attributes
	W CSI,yy,";",xx,"H",X Q
	;
VIDEO(H)	; ---------- Change video display attributes ----------
	;
	S video=H 
	S:H]]"~" H=$$CS(H,$$BYTECHAR^SQLUTL($$BSASCII^SQLUTL(H,1)#128)) 
	W VA(H)
	I video]]"~"'=gt s gt='gt W GT(gt)
	Q
	;
PARSRGN	; Create TOPY, LFTX, BOTY, RHTX from ORIGIN & EXTANT
	;
	I '$G(ORIGIN) S ORIGIN=TOPMAR_";"_LFTMAR
	S TOPY=$P(ORIGIN,";",1),LFTX=$P(ORIGIN,";",2)
	;
	I '$G(EXTANT) S EXTANT=(BOTMAR-TOPY+1)_";"_(RHTMAR-LFTX+1)
	S BOTY=TOPY+EXTANT-1,RHTX=LFTX+$P(EXTANT,";",2)
	S TOPY=$$ABSLTY(TOPY),BOTY=$$ABSLTY(BOTY)
	S LFTX=$$ABSLTX(LFTX),RHTX=$$ABSLTX(RHTX)
	Q
	;
MOVLIN(py,LOC)	; Move line (py) to location (LOC)
	;
	N move 
	S move=$$BFRNBR D REMLIN($G(py)) Q:'$D(R(move))
	D INSERT(move,$G(LOC)) K R(move) Q
	;
MOVGRP(LOC)	; Move a group of objects to location (LOC)
	;
	N move
	S move=$$BFRNBR
	I $D(P) D REMOVE I 1
	E  D REMOBJ Q:'$D(R(move))
	D INSERT(move,$G(LOC)) K R(move) Q
	;
REMOVE	; Remove objects in pick array
	;
	I '$D(P) W $$MSG^FORM("Buffer is empty") Q
	;
	D SAVE^FORMBFR(0) ; Save everything in the P(array) to a buffer
	;
	N py,px
	S py="",px=""
	S EDITED=1
	;
	F  S py=$O(P(py)) Q:py=""  F  S px=$O(P(py,px)) Q:px=""  D CLROBJ(py,px) K M(py,px),D(py,px)
	K P Q
	;
CLROBJ(py,px)	; Clear an object from the screen
	;
	N Y,X
	S Y=$$RELTVY(.py),X=$$RELTVX(.px)
	W $$CUR(Y,X),CSI,$L(M(py,px))-6,"X"
	Q
	;
REMOBJ	; Remove the current object
	;
	N py,px,ox
	S py=$$ABSLTY^FORM,px=$$ABSLTX^FORM,ox=$$ORIGIN^FORM
	I '$D(M(py,ox)) Q
	S P(py,ox)=$E(M(py,ox),1,6) D REMOVE Q
	;
REMLIN(py)	; Remove the objects on line (py)
	;
	I '$G(py) S py=$$ABSLTY^FORM ;		Default to current line
	;
	N ox S ox=""
	;
	I $D(P(py)) F  S ox=$O(P(py,ox)) Q:ox=""  D NOSEL^FORMSEL(py,ox)
	;
	N P ; Ignore selected objects that are not on this line
	F  S ox=$O(M(py,ox)) Q:ox=""  S P(py,ox)=$E(M(py,ox),1,6)
	I $D(P) D REMOVE
	Q
	;
KEYPAD	; Display Keyboard MAP
	;
	N V,%O,%NOPRMT,ZB,OLNTB,GOLD,ZMAP
	;
	S N="" F  S N=$O(^DBCTL("SYS","%KB",N)) Q:N=""  S ZB(N)=$G(^DBCTL("SYS","FORMKEY",0,^(N)))
	;
	F  S N=$O(key(N)) Q:N=""  S ZB(N)=key(N)
	;
	I $G(SID)'="" S ZB("*KP0")="" ; Remove RW-COM option
	;
KEYDSP	;
	;
	N OLDSID
	S OLDSID=$G(SID)
	W $$ST80^FORMINIT ; Set margin to 81 and display to 80
	S %O=2,%NOPRMT="",GOLD=0
 	S SID="FORMHLP" 
	D ^USID I PGM="" Q
	D ^@PGM
	S SID=OLDSID
	; D ^FORMHLP
	;
KEYPRMT	;
	;
	D VIDEO^FORM(VIDOF)
	;
	W BTMPAG,"Press any key for HELP on that key, RETURN to exit "
	;
KEYREAD	;
	;
	R X#1 D ZB^%ZREAD
	I %fkey="ENT" D PUTRGN() Q
	;
	I %fkey="" G ERR
	S FUNC=$G(ZB(%fkey)) I FUNC="" G ERR
	;
	G KEYDSP:$$KEYOPT(),KEYPRMT
ERR	;
	W $$MSG^FORM("Unmapped function key",1) G KEYPRMT	; *** BC - 11/02/93
	;
KEYOPT()	;
	N OPT,Z
	;
	S X=$$SCAU^%TRNLNM("HELP","OOE_LEARN."_FUNC)		;08/17/95
	I '$$FILE^%ZOPEN(X,"READ") D HELP(FUNC,1) Q 1
	;
	; menu 116: Documentation,Tutorial
	;
	S OPT=$$^DBSMBAR(116) I 'OPT Q 0	; *** BC - menu option 116 - 10/26/93
	;
	I OPT=1 D HELP(ZB(ZB),1) Q 1
	I OPT=2 D LEARN(ZB(ZB),1) Q 2
	Q
	;
HELP(X,FLAG)	; ---------- Display command documentation ----------
	;
	N OLNTB
	;
	I '$G(FLAG) W $$ST80^FORMINIT U 0 ; Set display to 80 and wait fof GTM 
	S Y=$G(X)
	I Y'="",$D(^OOEDOC(Y)) G HELP1
	;
	S OLNTB=1001 S Y=$$^DBSTBL("^OOEDOC(",Y) I Y="" G HELP2
HELP1	;
	D ^DBSHLP("^OOEDOC("""_Y_""""_",")
HELP2	;
	I '$G(FLAG) D PUTRGN() ; Redisplay the window
	Q
	;
LEARN(X,FLAG)	; ---------- Call training script ----------
	;
	I $G(X)="" S X=$$^FORMREAD("",30,"Learn Command: ") Q:X=""
	S X=$$SCAU^%TRNLNM("HELP","OOE_LEARN."_X)		;08/17/95
	I '$$FILE^%ZOPEN(X,"READ") W $$MSG^FORM("Tutorial not available",1) Q	; *** BC - 11/02/93
	D EXTERNAL^FORMCMD(5,X)
	D PUTRGN() ; Redisplay original screen
	Q
	;
	;
ASKHDR(H,V)	; ---------- Ask for header information in DECIMAL ----------
	;
	I V["VI" S V=$P(V,"VI",1)_($$BSASCII^SQLUTL(H,1)#128#64)_$P(V,"VI",2)
	I V["GT" S V=$P(V,"GT",1)_($$BSASCII^SQLUTL(H,1)>127)_$P(V,"GT",2)
	Q V
	;
CS(string,value,byte)	; ---------- Change <string> at <byte> to <value>
	;
	I '$D(byte) Q $E(value)_$E(string,2,9999)
	Q $E(string,1,byte-1)_$E(value)_$E(string,byte+1,9999)
	;
TR(X)	Q $$UPPER^SCAUTL(X)
	;
	;
BFRNBR()	Q $ZP(R(""))+1 ; The next available buffer
	;
ABSLTY(Y)	Q Y+YORIGIN-TOPMAR ; Absolute Y coordinate
ABSLTX(X)	Q X+XORIGIN-LFTMAR ; Absolute X coordinate
RELTVY(Y)	Q Y-YORIGIN+TOPMAR ; Relative Y coordinate
RELTVX(X)	Q X-XORIGIN+LFTMAR ; Relative X coordinate
CUR(Y,X)	Q CSI_Y_";"_X_"H" ; Direct cursor address
REGION(Y,X)	Q CSI_Y_";"_X_"r" ; Scrolling region
CUD(num)        Q CSI_num_"B"     ; Move cursor down
