FORMINIT	;;5.0 - OOE - Initialize form system
	;;Copyright(c)1997 Sanchez Computer Associates, Inc.  All Rights Reserved - 08/12/97 14:24:59 - NIB
	;     ORIG:  Frank R. Sanchez (1) - 10/01/88
	;     DESC:
	;
	; I18N=QUIT	Excluded from I18N Standards
	; ---------- Revision History ------------------------------------------
	; 07/14/06 - RussellDS - CR20028
	;	     Replaced $A references with $$BSASCII^SQLUTL and $C with
	;	     $$BTYECHAR^SQLUTL to ensure Unicode compliance.
	;
	; 05/17/06 - Allan Mattson - CR20048
	;            Replaced calls to $$UPPER^%ZFUNC with $$UPPER^SCAUTL.
	;
	;            Deleted pre-1994 revision history.
	;
	; 08/12/97 - Betty Ni - 25653
        ;            Replaced follows operator "]" with a "]]".
	;
	; 10/26/94 - Steve Canfield - I18N
	;	     Removed calls to $$^MSG.
	;
	; 05/25/94 - Steve Canfield - I18N
	;            Replaced embedded messages with a call to extrinsic 
	;            function $$^MSG(msgid,p1,p2...) for phrase independence.
	;	     Also converted msgid from RMnnnn to nnnn.
	;-----------------------------------------------------------------------
	;
	I $G(%UID)="" S %UID=1,%UCLS="SCA"
	;
	I '$D(YLIMIT) S YLIMIT=255
	I '$D(XLIMIT) S XLIMIT=255
	;
	S LFTMAR=1,TOPMAR=1
	S BOTMAR=23,RHTMAR=80
	;
	S zbtxt="x"
	;
	S N="",fileflag="",GLDKEY="",JRNL=""
	S NUL=$C(0),BEL=$C(7),TAB=$C(9),KBI=0
	;
	S DELETE=127
	S TIMEOUT=60
	;
	D VIDINIT
	D TRMSET
	W $$CLPAG(TOPMAR,BOTMAR)
	Q
	;
REST8	; ---------- Restore terminal states to last used ----------
	;
	I '$D(ST8) S ST8=""
	S YORIGIN=$P(ST8,"|",1) I YORIGIN="" S YORIGIN=1
	S XORIGIN=$P(ST8,"|",2) I XORIGIN="" S XORIGIN=1
	S RULER=$P(ST8,"|",3) ; Ruler toggle
	S VIDEO=$P(ST8,"|",4) I VIDEO[";" S VIDEO=""
	S BUFFERS=$P(ST8,"|",5) I BUFFERS'=+BUFFERS S BUFFERS=10
	S PY=$P(ST8,"|",8) ; Current relative X coordinate
	S PX=$P(ST8,"|",9) ; Current relative Y coordinate
	S FORMHDG=$P(ST8,"|",10) ; Form heading option
	S LASTFID=$P(ST8,"|",11) ; Last file reference
	S STATUS=$P(ST8,"|",12) ; Status line flag
	S RHTMAR=$P(ST8,"|",13) I RHTMAR'=132 S RHTMAR=80
	;
	I STATUS S BOTMAR=BOTMAR-1
	I RULER S LFTMAR=3,TOPMAR=2
	;
	S VIDEO=$$HEADER($P(VIDEO,",",1),$P(VIDEO,",",2),$P(VIDEO,",",3),$P(VIDEO,",",4),$P(VIDEO,",",5),$P(VIDEO,",",6))
	I '$D(VA(VIDEO)) D VIDSP(VIDEO)
	;
	I PX="" S PX=LFTMAR
	I PY="" S PY=TOPMAR
	;
	; ---------- Set default pan values ----------
	;
	S NUMCOL=$$NUMCOL,NUMROW=$$NUMROW
	I '$P(ST8,"|",6) S $P(ST8,"|",6)=NUMROW+1\2 ; Vertical pan
	I '$P(ST8,"|",7) S $P(ST8,"|",7)=NUMCOL+1\2 ; Horizontal pan
	Q
	;
TRMSET	; --------- Initialize session attributes for the editor ----------
	;
	W $C(27),"=" ; 			Turn on the application keypad
	W $C(27),"(B" ; 		Designate Ascii as G0
	W $C(27),")0" ; 		Designate special graphics as G1
	W $$SCRAWOFF^%TRMVT ;		Turn off auto wrap
	W $$LOCK^%TRMVT(TOPMAR,BOTMAR) ; Set scrolling region
	D VIDEO^FORM(VIDOF) ; Reset video attributes
	Q
	;
TRMRES	; ---------- Restore session attributes (Non editor) ----------
	;
	W CSI,"62;1""p"
	W $$ST80 ; Set the screen display to 80 column
	D VIDEO^FORM(VIDOF) ;   Reset video attributes
	D TERM(80) ; Margin=80, Echo, Flush, No_terminator
	W $$LOCK^%TRMVT ;  Clear scrolling region
	Q
	;
	Q
	;
%KB()	;I $G(^DBCTL("SYS","%KB"))'="" Q ^("%KB")
	;Q $C(65,66,67,68,80,81,82,83,28,29,1,2,3,4,5,6)
	;
SET(X)	; Set control variables (VERIFY,BUFFERS,PAN,SCROLL)
	;
	I $G(X)="" S X=$$^FORMREAD("",12,"Variable: ") Q:X=""
	;
	N V
	S X=$$UPPER^SCAUTL(X)
	S V=$P(X,"=",2),X=$P(X,"=",1)
	I V="" S V=X?1"NO".E=0 I V=0 S X=$E(X,3,$L(X))
	;
	I $E("BUFFERS",1,$L(X))=X S BUFFERS=V Q
	I $E("SCROLL",1,$L(X))=X S $P(ST8,"|",6)=V Q
	I $E("PAN",1,$L(X))=X S $P(ST8,"|",7)=V Q
	I $E("FILES",1,$L(X))=X S FILES=V Q
	; DISABLE CAPTURE COMMAND 6/16/92 FCBW131. 
	; I $E("CAPTURE",1,$L(X))=X D CAPTURE^FORMCMD(V) Q
	;
	; 
	W $$MSG^FORM("Unknown set option variable") Q		; *** BC - 11/02/93
	;
VIDINIT	; ---------- Initialize video attribute variables ----------
	;
	S CSI=$$CSI^%TRMVT,ZB=13
	S CLSCREEN=$$CLEAR^%TRMVT ; Clear entire screen
	S CLEOL=$$CLL^%TRMVT ; Clear to end of line
	;
	S SCP=$$CPS^%TRMVT ; Save cursor
	S RCP=$$CPR^%TRMVT ; Restore cursor
	S CURON=$$CUON^%TRMVT ; Turn cursor on
	S CUROF=$$CUOFF^%TRMVT ; Turn cursor off
	S LININS=$$LININS^%TRMVT ; Insert one line
	S LINDEL=$$LINDEL^%TRMVT ; Delete one line
	;
	S MOVLFT=$$CUB^%TRMVT ; Move left one character
	S MOVRHT=$$CUF^%TRMVT ; Move right one character
	S MOVUP=$$CUU^%TRMVT ; Move up one character
	S MOVDN=$$CUD^%TRMVT ; Move down one character
	;
	S VIDOF=$$HEADER() D VIDSP(VIDOF)
	S VIDHL=$$HEADER(2) D VIDSP(VIDHL)
	S VIDBF=$$HEADER(2+8) D VIDSP(VIDBF)
	S VIDRV=$$HEADER(1) D VIDSP(VIDRV)
	;
	S GT(0)=$C(15) ; Graphics off
	S GT(1)=$C(14) ; Graphics on
	S video="",gt=0
	S BTMPAG=$$CUR(BOTMAR+2,1)_CLEOL
	Q
	;
CLPAG(PT,PB)	; ---------- Clear a page or region ----------
	;
	I '$D(PB) S PB=BOTMAR ; Default to the bottom line
	I PB=BOTMAR Q $$CUR(PT,1)_CSI_"J"
	E  Q $$CUR(PT,1)_$$LINDEL(PB-PT+1)_$$LININS(PB-PT+1)
	;
HEADER(video,size,style,color,cpi,lpi)	; ----------- 6byte header -------------
	;
	I '$D(video) S video=0
	I '$D(size) S size=0
	I '$D(style) S style=0
	I '$D(color) S color=0
	I '$D(cpi) S cpi=0
	I '$D(lpi) S lpi=0
	;
	I video\64#2=0 S video=video+64 ; Bit7 is always on
	Q $$BYTECHAR^SQLUTL(+video)_$$BYTECHAR^SQLUTL(+size)_$$BYTECHAR^SQLUTL(+style)_$$BYTECHAR^SQLUTL(+color)_$$BYTECHAR^SQLUTL(+cpi)_$$BYTECHAR^SQLUTL(+lpi)
	;
VIDSP(V)	; ---------- Add new display option to VA array ----------
	;
	I V]]"~" S V=$$BYTECHAR^SQLUTL($$BSASCII^SQLUTL(V,1)#128)_$E(V,2,6) ; Remove graphics toggle
	N v S v=""
	I $$BSASCII^SQLUTL(V,1)#2 S v=v_";7"
	I $$BSASCII^SQLUTL(V,1)\2#2 S v=v_";1"
	I $$BSASCII^SQLUTL(V,1)\4#2 S v=v_";4"
	I $$BSASCII^SQLUTL(V,1)\8#2 S v=v_";5"
	;
	S VA(V)=CSI_v_"m"
	Q
	;
QUIT()	; ---------- QUIT from the current form  ----------
	;
	I '$$EDITED G EXIT1 ; No changes since the last load
	I $D(M)<10 G EXIT1 ; Blank screen
	;
	I '$$YN^DBSMBAR("","Exit without filing changes?",0) S ZB=13 Q	; *** BC - replace DBSMENU call 10/26/93
	;
EXIT1	;
	I $G(JRNL)'="" D CAPTURE^FORMCMD(0)
	I $G(SID)'="",SID?1"z".E K ^DBTBL(%LIBS,2,SID)
	I $G(RID)'="",RID?1"z".E K ^DBTBL(%LIBS,5,RID)
	L
	S ZB="" Q  ; Exited
	;
EDITED()	Q $G(EDITED) ; Current implementation (Don't like it) 
	;
ST8	; Refresh the control status variable
	;
	S $P(ST8,"|",1)=YORIGIN
	S $P(ST8,"|",2)=XORIGIN
	S $P(ST8,"|",3)=RULER
	S $P(ST8,"|",4)=$$BSASCII^SQLUTL(VIDEO,1)_","_$$BSASCII^SQLUTL(VIDEO,2)_","_$$BSASCII^SQLUTL(VIDEO,3)_","_$$BSASCII^SQLUTL(VIDEO,4)_","_$$BSASCII^SQLUTL(VIDEO,5)_","_$$BSASCII^SQLUTL(VIDEO,6)
	S $P(ST8,"|",5)=BUFFERS
	S $P(ST8,"|",8)=PY
	S $P(ST8,"|",9)=PX
	S $P(ST8,"|",10)=FORMHDG
	S $P(ST8,"|",11)=LASTFID
	S $P(ST8,"|",12)=STATUS
	S $P(ST8,"|",13)=RHTMAR
	Q
	;
RM	G CI:RHTMAR=80
CO	;
	S RHTMAR=80,NUMCOL=$$NUMCOL
	D PUTRGN^FORMFUN() S:PX>80 PX=80 Q
CI	;
	S RHTMAR=132,NUMCOL=$$NUMCOL
	D PUTRGN^FORMFUN() Q
	;
ST80()	D TERM(81) Q $$SCR80^%TRMVT ; Set margin to 81 and change video
ST132()	D TERM(133) Q $$SCR132^%TRMVT ; Set margin to 133 and change video 
	;
TERM(WIDTH)	; ----- System dependant use syntax ----- 
	;
	D TERM^%ZUSE(0,"ECHO/WIDTH="_WIDTH)
	;
	Q
	;
	;
CUR(Y,X)	Q CSI_Y_";"_X_"H" ; Direct cursor address
VIDEO(X)	Q CSI_$G(X)_"m" ; Display attributes (REVERSE,HIGHLIGHT,etc)
LININS(X)	Q CSI_X_"L"
LINDEL(X)	Q CSI_X_"M"
REGION(Y,X)	Q CSI_$G(Y)_";"_$G(X)_"r" ; Scrolling region
NUMCOL()	Q RHTMAR-LFTMAR+1
NUMROW()	Q BOTMAR-TOPMAR+1
