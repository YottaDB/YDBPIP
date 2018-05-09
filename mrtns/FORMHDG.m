FORMHDG(DQP,WRAP)	;; -  - V5.0 - Create default headings for data
	;;Copyright(c)1998 Sanchez Computer Associates, Inc.  All Rights Reserved - 03/05/98 13:31:30 - GARBERB
	;     ORIG:  Frank R. Sanchez (2497) - 12/19/88
	;     DESC:  Object heading option
	;
	; I18N=QUIT	Excluded from I18N Standards
	; ---------- Revision History ------------------------------------------
	; 
	; 03/04/98 - GARBERB - ARQ 25871
        ;            Added a line of code at INVERTA so that when inverting text
        ;            the date field does not invert. Also add a missing Quit at
        ;            INVERT+3. Incerted $O in place of $ZP.
	;
	; 10/26/94 - Steve Canfield - I18N
	;	     Removed calls to $$^MSG.
	;
	; 05/25/94 - Steve Canfield - I18N
	;            Replaced embedded messages with a call to extrinsic 
	;            function $$^MSG(msgid,p1,p2...) for phrase independence.
	;	     Also converted msgid from RMnnnn to nnnn.
	;
	; 11/02/93 - Bob Chiang - I18N#7
	;
	;            Modified return message handling with a call to extrinsic
	;            function $$^MSG(msgid,p1,p2...) for I18N development
	;            (phrase independence).
	;
	; 10/25/93  Bob Chiang - I18N#23
	;
	;           Modified to replace DBSMENU routine calls with DBSMBAR.
	;
	; 11/18/92 - Allan Mattson - I18N#7
	;
	;            Modified return message handling with a call to extrinsic
	;            function $$^MSG(msgid,p1,p2...) for I18N development
	;            (phrase independence).
	;-----------------------------------------------------------------------
	N LIB,FID,DI,HDG,P
	;
	S ER=0,X=$P(DQP,dl,1)
	S DI=$P(X,"]",2),X=$E($P(X,"]",1),2,999)
	S LIB=$P(X,",",1),FID=$P(X,",",2) I FID="" S FID=LIB,LIB=""
	I LIB="" D LIBRARY
	;
	Q:LIB=""!(FID="")!(DI="")
	S WRAP=$G(WRAP) ; Automatic wraparound flag
	;
	I +FORMHDG=9 D FORMFRST ; Calculate the heading gap
	I +FORMHDG=1 D ROW(1) Q
	I +FORMHDG=2 D ROW(0) Q
	I +FORMHDG=3 D COL(1) Q
	I +FORMHDG=4 D COL(0) Q
	;
ROW(RJFLG)	; Row headings (Left or Right justified)
	;
	N VIDEO S VIDEO=VIDOF
	S HDG=$$PROMPT I HDG="" G ROWMOV
	I $P(DQP,dl,7)!$P(DQP,dl,8)!(DQP'[dl) S HDG=" "_HDG,VIDEO=VIDRV
	S LX=$L(HDG)
	S hy=$$ABSLTY^FORM-$P(FORMHDG,";",2)
	S hx=$$ABSLTX^FORM-$P(FORMHDG,";",3)
	I RJFLG S hx=hx-LX+1 ; Right justify flag
	I hy<YORIGIN S hy=YORIGIN
	I hx<XORIGIN S hx=XORIGIN ; Before the origin
	I YLIMIT,hy>YLIMIT G WRAP:WRAP S ER=1,RM="Bottom margin ("_YLIMIT_")" Q
	S Z=$O(M(hy,hx+LX),-1) I Z S Z=Z+$L(M(hy,Z))+1-6 I Z>hx S hx=Z
	I hx+LX>ox S ox=hx+LX+1 ; Move the data object to the right
	D FIT^FORMFUN(hy,hx,LX),FILE(HDG,hy,hx,VIDEO)
	;
ROWMOV	; Move down one row
	;
	I YLIMIT,py+1>YLIMIT Q  ; Can't move down any further
	S PY=PY+1 I PY'>BOTMAR Q
	;
	D SCROLLDN^FORMPAN()
	S PY=$$RELTVY^FORMFUN(py)+1
	Q
	;
COL(OPT)	; Create Column headings (Centered or Justified)
	;
	N HDG,LH,LIN,NUMLIN
	S LEN=$P(DQP,dl,3) ; Field length
	S HDG=$$HEADING I HDG="" G COLMOV
	S NUMLIN=$L(HDG,"@") ; Number of heading lines
	S hy=$$ABSLTY^FORM-$P(FORMHDG,";",2)-NUMLIN+1
	I hy<YORIGIN S hy=YORIGIN
	I hy+NUMLIN>py S py=hy+NUMLIN ; Move the data object down one line
	S LH=$L($P(HDG,"@",1))
	F I=2:1:NUMLIN I $L($P(HDG,"@",I))>LH S LH=$L($P(HDG,"@",I))
	I LH>LEN S ox=ox+$S(OPT=0:LH-LEN\2,"RN$E"[$P(DQP,dl,2):LH-LEN,1:0),LEN=LH
	I XLIMIT,ox+LEN>XLIMIT G WRAP:WRAP S ER=1,RM="Right margin ("_XLIMIT_")" Q
	F LIN=1:1:NUMLIN D COLA($P(HDG,"@",LIN)) S hy=hy+1
	;
	;
COLMOV	; Move to a position 2 columns to the right ... wrap at end
	;
	N px
	S px=$$ABSLTX^FORM
	;
	I XLIMIT,px+LEN+2>XLIMIT Q
	;
	S PX=PX+LEN+2 I PX>RHTMAR S PX=RHTMAR Q
	Q
	;
COLA(HDG)	;
	;
	S LX=$L(HDG)
	S hx=$$ABSLTX^FORM-$P(FORMHDG,";",3)
	I OPT=1,"RN$E"[$P(DQP,dl,2) S hx=hx+LEN-LX ; Right justify these
	I OPT=0,LEN S hx=hx+(LEN-LX\2) ; Centered
	I hx<XORIGIN S hx=XORIGIN
	D FIT^FORMFUN(hy,hx,LX),FILE(HDG,hy,hx,VIDOF)
	Q
	;
FILE(X,py,px,H)	; ---------- File HEADER ---------
	;
	S EDITED=1
	S M(py,px)=H_X
	D PUTOBJ^FORMFUN(py,px)
	I $D(P) D SAVE^FORMBFR(0) ; Save objects that were overlayed
	Q
	;
	;
ON(FN)	; TOGGLE HEADING ON
	;
	N OP
	; RT-Justified row,LF-Justified row,Justified Col,Centered Col,Cancel
	;
	S FN=$$^DBSMBAR(117)		; *** BC - menu 117 - 10/26/93
	I 'FN W:FN'="" $$MSG^FORM(FN) Q
	;
	I FN=5 S FORMHDG=""
	E  S FORMHDG="9;"_FN_";"_$$ABSLTY^FORM_";"_$$ABSLTX^FORM
	I FN=3 S FORMHDG="3;3;0"
	I STATUS D STATUSP^FORMSTAT
	Q
	;
CHGCAS()	; Change the case of words
	;
	N py,px
	S py="",px=""
	I '$D(P) W $$MSG^FORM("Select buffer is empty") Q	; *** BC - 11/02/93
	F  S py=$O(P(py)) Q:py=""  F  S px=$O(P(py,px)) Q:px=""  D INVERT
	w $$CURPOS Q
	;
INVERT	; Invert the case of an object
	;
	N ZHIT
	I $D(D(py,px)),$E(D(py,px))'="@"  ; Don't touch data
	N I,II,X,Z,I1,I2
	S X=$E(M(py,px),7,9999)
	F I=1:1:$L(X," ") S Z=$P(X," ",I) D INVERTA S $P(X," ",I)=Z
	S M(py,px)=$E(M(py,px),1,6)_X D PUTOBJ^FORMFUN(py,px) Q
	;
INVERTA	;
	;
	S ZHIT=0
	F I1="CIF","P&I","CUSIP","ID" I Z=I1 S ZHIT=1 Q
	I ZHIT Q
	I Z="mm/dd/yyyy" Q   ;BLG 03/04/98 ARQ 25871,27856
	I $TR(Z,"AEIOUYaeiouy","+")=Z Q  ; There are no vowels
	S I1=2 F I2="A","AN","AND","OF","FOR","THE","OR","a","an","and","of","for","the","or" I Z=I2 S I1=1 Q
	F II=I1:1:$L(Z) S Y=$A(Z,II) I Y>64,Y<123 S Z=$E(Z,1,II-1)_$C(Y+$S(Y>96:-32,1:32))_$E(Z,II+1,9999)
	Q
	;
	;
FORMFRST	; Determine column or row ofsets to place prompts
	N Y,X
	S Y=$$ABSLTY^FORM-$P(FORMHDG,";",3) ; Y axis gap
	S X=$$ABSLTX^FORM-$P(FORMHDG,";",4) ; X axis gap
	S Z=$P(FORMHDG,";",2) ; Heading option
	I Z>2 S X=0 I Y=0 S Y=2 ; Default column headings to 2 lines
	I Z<3 S Y=0 I X=0 S X=2 ; Default row headings to 2 spaces
	S FORMHDG=Z_";"_Y_";"_X Q
	;
	I FN=1 S X="Right justified - Column "_X
	I FN=2 S X="Left justified - Column "_X
	I FN=3 S X="Justified Heading - Line "_Y
	I FN=4 S X="Centered heading - Line "_Y
	W $$MSG^FORM(X) Q
	;
LIBRARY	;
	N X
	S LIB=%LIBS
	S X=$P($G(^DBTBL(%LIBS,1,FID,10)),"|",5) I X="" Q
	;
IMPLICT	;
	S LIB=$P($P(X,",",1),"[",2)
	Q
	;
HEADING()	Q $P($G(^DBTBL(LIB,1,FID,9,DI)),"|",22)
PROMPT()	Q $P($G(^DBTBL(LIB,1,FID,9,DI)),"|",10)_":"
CURPOS()	Q CSI_PY_";"_PX_"H"
WRAP	B  H
