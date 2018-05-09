FORMSEL	;; -  - V 5.0 - FORM system, object selections
	;;Copyright(c)1997 Sanchez Computer Associates, Inc.  All Rights Reserved - 08/12/97 14:26:38 - NIB
	;     ORIG:  Frank R. Sanchez (1) - 11/09/88
	;     DESC:  OOE select objects utility
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
	;-----------------------------------------------------------------------
	N O
	;
	I $G(ANCHOR) G SELNETB ; The select net is activated
	;
	S py=$$ABSLTY^FORM,px=$$ABSLTX^FORM,ox=$$ORIGIN^FORM
	I '$D(M(py,ox)) Q
	I $D(P(py,ox)) D NOSEL(py,ox),PUTOBJ^FORMFUN(py,ox) Q  ; Unselect
	S O=0 D SEL Q
	;
SEL	; ---------- Add an object to the select buffer ----------
	;
	I O=1,'$D(D(py,ox)) Q
	I O=2,$D(D(py,ox)) Q
	S H=$E(M(py,ox),1,6)
	I '$D(P(py,ox)) S P(py,ox)=H ; Save the original header
	;
	S H=$S(H]]"~":$$BYTECHAR^SQLUTL($$BSASCII^SQLUTL(VIDBF,1)+128),1:$E(VIDBF))_$E(H,2,6) ; Change header 
	I '$D(VA(H)) D VIDSP^FORMINIT(H) ; Define header if not already
	S M(py,ox)=H_$E(M(py,ox),7,999) ; Put new header on object
	D PUTOBJ^FORMFUN(py,ox) ; Display object
	Q
	;
NOSEL(py,px)	; ---------- Unselect selected objects ---------- 
	;
	I $D(P(py,px)) S M(py,px)=P(py,px)_$E(M(py,px),7,9999) K P(py,px)
	Q
	;
SELECT(FN)	; ---------- Main SELECT menu ----------
	;
	I $G(ANCHOR) G SELNETB ; The select net is activated
	;
	S py=$$ABSLTY^FORM,px=$$ABSLTX^FORM,ox=$$ORIGIN^FORM
	;
	;
	N OP
	;
	; Net Select,Line Select,Form Select,Column Select,Clear Select
	;
	S FN=$$^DBSMBAR(123) I 'FN Q	; *** BC - Replace DBSMENU call 10/25/93
	W BTMPAG
	;
	; ----------  Branch tag if FN parameter is defined
	;
	I FN=1 D SELGRP("") Q
	I FN=2 D SELLIN("") Q
	I FN=3 D SELALL("") Q
	I FN=4 D SELCOL("") Q
	I FN=5 D SELOFF("") Q
	;
SELCOL(O)	; ---------- Select a column ----------
	;
	S O=$$OPTION($G(O))
	N ox,py,xx
	;
	S ox="",py="",xx=$$ABSLTX^FORM
	;
	F  S py=$O(M(py)) Q:py=""  F  S ox=$O(M(py,ox)) Q:ox=""   I ox'>xx,(ox+$L(M(py,ox))-7'<xx) D SEL
	Q
	;
SELGRP(O)	; ---------- Set anchor point of the net ----------
	;
	I $G(ANCHOR) G SELNETB
	W $$MSG^FORM("Position cursor to opposite corner, Press SELECT")
	S py=$$ABSLTY^FORM,ox=$$ABSLTX^FORM,ANCHOR=py_";"_ox
	D PUTANCH() Q
	;
SELNETB	; Net is at the opposite corner
	;
	N oy,oy,py,px
	;
	W BTMPAG
	D ANCHOF
	S py=$$ABSLTY^FORM,px=$$ABSLTX^FORM
	I oy=py,ox=px Q  ; Nothing selected
	;
	I py>oy S TOPY=oy,BOTY=py
	E  S TOPY=py,BOTY=oy
	;
	I px>ox S LFTX=ox,RHTX=px
	E  S LFTX=px,RHTX=ox
	S O=0 D SELRGNA Q
	;
ANCHOF	; ---------- Remove the anchor object ----------
	;
	N Y,X
	S oy=+ANCHOR,ox=$P(ANCHOR,";",2),Y=$$RELTVY(oy),X=$$RELTVX(ox) K ANCHOR
	I '$$VALID(Y,X) Q
	W $$CUR(Y,X)," " D PUTCHR^FORM(Y,X)
	Q
	;
PUTANCH()	; Display the anchor
	;
	N Y,X
	S Y=$$RELTVY(+ANCHOR),X=$$RELTVX($P(ANCHOR,";",2))
	I '$$VALID(Y,X) Q
	D VIDEO^FORM($$BYTECHAR^SQLUTL($$BSASCII^SQLUTL(VIDBF,1)+128)_$E(VIDBF,2,6)) W $$CUR(Y,X),"a" Q
	;
SELLIN(O)	; ---------- SELECT the objects on this line ----------
	;
	S O=$$OPTION($G(O))
	N ox
	S ox=""
	;
	F  S ox=$O(M(py,ox)) Q:ox=""   D SEL
	Q
	;
SELALL(O)	; ---------- SELECT the objects on this form ----------
	;
	N py,ox
	;
	S O=$$OPTION($G(O)) I O<0 Q
	;
	S py="",ox=""
	;
	F  S py=$O(M(py)) Q:py=""  F  S ox=$O(M(py,ox)) Q:ox=""  D SEL
	Q
	;
SELRGN(ORIGIN,EXTANT,O)	; --------- Select a region of objects ----------
	;
	S O=$$OPTION($G(O))
	D PARSRGN^FORMFUN
	;
SELRGNA	;
	;
	S py=TOPY-1
	F  S py=$O(M(py)) Q:py=""!(py>BOTY)  S ox=$ZP(M(py,LFTX)) F  S ox=$O(M(py,ox)) Q:ox=""!(ox>RHTX)  I ox+$L(M(py,ox))-2-6<RHTX D SEL
	Q
	;
SELOFF(O)	; ---------- Clear the objects in the select buffer ----------
	;
	S O=$$OPTION($G(O))
	;
	S py="",px=""
	F  S py=$O(P(py)) Q:py=""  F  S px=$O(P(py,px)) Q:px=""  S M(py,px)=P(py,px)_$E(M(py,px),7,999) D PUTOBJ^FORMFUN(py,px)
	K P Q
	;
OPTION(O)	; ---------- Validate select option (0,1,2) ----------
	;
	I $G(O)="" Q $$OPTASK
	;
	I $E("DATA",1,$L(O))=O Q 1
	I $E("TITLE",1,$L(O))=O Q 2
	Q 0
	;
OPTASK()	; ---------- Ask for the valid selection option ------------
	;
	; All objects,Data only,Text only
	;
	S FN=$$^DBSMBAR(124)		; *** BC - Replace DBSMENU call 10/25/93
	;
	W BTMPAG
	Q FN-1
	;
CS(string,value,byte)	; ---------- Set <string> at <byte> to <value> ----------
	;
	I '$D(byte) Q $E(value)_$E(string,2,9999)
	Q $E(string,1,byte-1)_$E(value)_$E(string,byte+1,9999)
	;
VALID(Y,X)	Q '(Y<TOPMAR!(Y>BOTMAR)!(X<LFTMAR)!(X>RHTMAR))
	;
RELTVY(Y)	Q Y-YORIGIN+TOPMAR ; Relative Y coordinate
RELTVX(X)	Q X-XORIGIN+LFTMAR ; Relative X coordinate
	;
CUR(Y,X)	Q CSI_Y_";"_X_"H" ; Direct cursor address
