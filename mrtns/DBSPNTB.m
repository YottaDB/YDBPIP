DBSPNTB	;; -  - V4.0 - Print driver for Burroughs Poll Select terminal
	;;Copyright(c)1994 Sanchez Computer Associates, Inc.  All Rights Reserved - 10/17/94 08:31:59 - XUS
	;     ORIG:  Robert Chiang
	;     DESC:  Print driver for block mode terminal (BPS)
	;
        ; I18N=QUIT: Exculded from I18N standards.
	;----- Revision History -----------------------------------------------
	; 05/17/06 - Allan Mattson - CR20048
	;            Replaced calls to $$UPPER^%ZFUNC with $$UPPER^SCAUTL.
	;
	; 01/18/93 - Dan Russell
	;            Changed calls to PTMPHVT to executes to avoid link
	;            errors where PTMPHVT is not present.  PTMPHVT is currently
	;            considered a custom program and may not always exist.
	;
	; 12/12/92 - Allan Mattson - I18N#7
	;
	;            Modified return message handling with a call to extrinsic
	;            function $$^MSG(msgid,p1,p2...) for I18N development
	;            (phrase independence).
	;----------------------------------------------------------------------
	;
	;
	;
START	I '$D(%PG) N %PG S %PG=1
	I '$D(%PAGE) N %PAGE S %PAGE=%PG+1
	;
	N FMQ S FMQ=$$FMQ,OM=$$DSPSCR
	N X,Y,Z
	;
	; Display sceen; force exit if last page of inquiry screen
	I %O=2,%PG=%PAGE D WRITE("@") X "ZGOTO 1:READ^PTMPHVT"
	D WRITE("`"),READ
	;
MENU	; Validate menu option based upon FMQ.
	S X=$E(MSG,$L(MSG)-1) I %O,X,X'>%PAGE Q
	S Y=0,Z="" F  S Y=$F(FMQ,"<",Y) Q:Y=0  S Z=Z_$E(FMQ,Y)
	; Invalid menu option
	I $F(Z,X)=0 S RM=$$^MSG(1404) N NI S NI=0 D ERROR G MENU
	Q
	;
	;----------------------------------------------------------------------
WRITE(X)	; Write OM to out mailbox
	;----------------------------------------------------------------------
	; X = Control byte
	;	@ = End of transaction
	;	` = More to follow
	;
	S OM=X_OM D WRITVT^%ZPTM
	Q
	;
	;----------------------------------------------------------------------
READ	; Read response from in mailbox
	;----------------------------------------------------------------------
	D READVT^%ZPTM
	;
EXIT	; Reprocess if the transaction was "aborted"
	I $E(IM,1,8)="*Timeout" X "ZGOTO 1:READ^PTMPHVT"
	I $E(IM,1,5)="*Stop" X "ZGOTO 1:reentry^PTMPHVT"
	I $E(IM,6)="*" X "ZGOTO 1:reentry^PTMPHVT"
	I $E(IM,6)="@" X "ZGOTO 1:reentry^PTMPHVT"
	S %IPMODE="NOINT:ORDER MSG/FIXED"
	S MSG=$E(IM,6,$L(IM))
	Q
	;
	;----------------------------------------------------------------------
ERROR	; Error handler (called by ^DBSCRT8)
	;----------------------------------------------------------------------
	S OM=$$EXT(" "_$G(RM)_" ",1,23,1,1,"T")_$J("",76-$L($G(RM)))
	S OM=OM_$$BEL_$$FORM(1)_$$HOME_$$TAB(NI),RM=""
	D WRITE("`")
	D READ
	Q
	;
	;----------------------------------------------------------------------
DSPSCR()	; Build output message to display screen
	;----------------------------------------------------------------------
	N I,OM
	S OM="" F I=1:1:+VO S OM=OM_$$FMT(VO(I))
	Q $$INIT(1,+VO(0))_OM_FMQ_$$FORM(1)_$$HOME
	;
	;----------------------------------------------------------------------
FMT(X)	; Format object
	;----------------------------------------------------------------------
	; Full data item protection (no read/no write)
	I $E(X,12)=3 Q $$CUR($A(X,2)-2,$A(X))_$C(14)_$J("",$A(X,3))_$C(30)
	;
	N Y,Z S Y=""
	I $E(X,12)=1 DO
	.I $A(X,4)#2 S Y=$C(14) Q	; Reverse
	.I $A(X,4)\2#2 S Y=$C(26) Q	; Highlight
	.I $A(X,4)\4#2 S Y=$C(15) Q	; Underline
	.I $A(X,4)\8#2 S Y=$C(24) Q	; Blinking
	;
	S Z=$$CNV($E(X,14,999))
	S Z=$S("$N"[$E(X,13):$J(Z,$A(X,3)),1:Z_$J("",$A(X,3)-$L(Z)))
	;
	I %O>1!($E(X,12)) S:$L(Y) Z=Z_$C(30)
	E  S Z=$S("N$"[$E(X,13):$C(29),1:$C(31))_Z_$C(30)
	;
	Q $$CUR($A(X,2)-$L(Y),$A(X))_Y_Z
	;
	;----------------------------------------------------------------------
EXT(OBJ,DX,DY,VO,PR,FO,FL)	; External call to format object
	;----------------------------------------------------------------------
	; Sample call:	S OM=$$EXT^DBSPNTB(RM,1,23,1,0,"T",1)
	;
	;  Parameters:	OBJ	Object
	;		DX	X cursor position
	;		DY	Y cursor position
	;		VO	Video display attribute
	;		PR	Protection (0 = not protected, 1 = protected)
	;		FO	Field format (req'd if not protected)
	;		FL	Field length (req'd if not protected)
	;
	;
	N X S X=$$CUR(DX,DY)
	;
	I VO#2 S X=X_$C(14)	; Reverse
	I VO\2#2 S X=X_$C(26)	; Highlight
	I VO\4#2 S X=X_$C(15)	; Underline
	I VO\8#2 S X=X_$C(24)	; Blinking
	;
	S OBJ=$$CNV(OBJ)
	I PR Q X_OBJ_$C(30)	; Protected field
	;
	I "N$"[FO S X=X_$C(29)_$J(OBJ,FL)
	E  S X=X_$C(31)_OBJ_$J("",FL-$L(OBJ))
	Q X_$C(30) ; Terminate attributes
	;
	;----------------------------------------------------------------------
BEL()	; Sound bell
	;----------------------------------------------------------------------
	Q $C(7)
	;
	;----------------------------------------------------------------------
CLEAR()	; Clear page and HOME
	;----------------------------------------------------------------------
	Q $C(12)
	;
	;----------------------------------------------------------------------
CLL()	; Clear from present location to to end of line
	;----------------------------------------------------------------------
	Q $C(27,75)
	;
	;----------------------------------------------------------------------
CLP()	; Clear from present location to to end of page
	;----------------------------------------------------------------------
	Q $C(27,74)
	;
	;----------------------------------------------------------------------
CNV(X)	; Translate BPS field delimeters
	;----------------------------------------------------------------------
	Q $TR(X,"[]","<>")
	;
	;----------------------------------------------------------------------
CUR(DX,DY)	; Position cursor
	;----------------------------------------------------------------------
	Q $C(27,34,DX+31,DY+31)
	;
	;----------------------------------------------------------------------
FORM(X)	; Forms mode on (1) / off(0)
	;----------------------------------------------------------------------
	Q $C(27,88-X)
	;
	;----------------------------------------------------------------------
HOME()	; Cursor HOME
	;----------------------------------------------------------------------
	Q $C(20)
	;
	;----------------------------------------------------------------------
INIT(DX,DY)	; Initialize screen
	;----------------------------------------------------------------------
	S:'$G(DX) DX=1 S:'$G(DY) DY=1
	I DX=1,DY=1 Q $$CLEAR
	Q $$CUR(DX,DY)_$$CLP
	;
	;----------------------------------------------------------------------
TAB(NI)	; Tab to specified field number (# tabs = NI - # protected fields - 1)
	;----------------------------------------------------------------------
	N I,X S X="" F I=1:1:NI I $E(%TAB(I),4)'=2 S X=X_$C(9)
	Q $E(X,1,$L(X)-1)
	;
	;----------------------------------------------------------------------
FMQ()	; Construct FMQ prompt
	;----------------------------------------------------------------------
	I '$D(%PG) Q ""
	;
	N FMQ,L
	S FMQ=$S(%PG<1:"",1:" Page "_%PG)
	;
	I %O=0 D %O0
	I %O=1 D %O1
	I %O=2 D %O2
	I %O=3 D %O3
	I %O=4 D %O4
	;
	S FMQ=FMQ_" ",L=$L(FMQ)
	S FMQ=$$EXT(FMQ,1,24,1,1,"T")
	;
	I %O=2,%PG=%PAGE Q FMQ
	S FMQ=FMQ_$$EXT("",L+2,24,0,0,"T",2)
	S FMQ=FMQ_$$EXT(" XMT ",L+6,24,1,1,"T")
	S FMQ=FMQ_$$EXT("",L+12,24,0,0,"T",1)
	Q FMQ
	;
	;----------------------------------------------------------------------
%O0	; %O=0 - Build menu selections for a new record
	;----------------------------------------------------------------------
	I %PG'<1,%PG=%PAGE S FMQ=FMQ_$$%FILE
	S FMQ=FMQ_$$%NEXT_$$%PREV_$$%QUIT
	Q
	;
	;----------------------------------------------------------------------
%O1	; %O=1 - Build menu selections for modify record
	;----------------------------------------------------------------------
	I %PG'<1 S FMQ=FMQ_" of "_%PAGE
	S FMQ=FMQ_$$%NEXT_$$%PREV
	I %PG'<1 S FMQ=FMQ_$$%FILE
	S FMQ=FMQ_$$%QUIT
	Q
	;
	;----------------------------------------------------------------------
%O2	; %O=2 - Build menu selections for display record
	;----------------------------------------------------------------------
	I %PG'<1 S FMQ=FMQ_" of "_%PAGE I %PG=%PAGE S FMQ=FMQ_", End of report" Q
	S FMQ=FMQ_$$%NEXT_$$%PREV_$$%QUIT
	Q
	;
	;----------------------------------------------------------------------
%O3	; %O=3 - Build menu selections for delete record
	;----------------------------------------------------------------------
	I %PG'<1 S FMQ=FMQ_" of "_%PAGE
	S FMQ=FMQ_$$%NEXT_$$%PREV_$$%QUIT_$$%DEL
	Q
	;
	;----------------------------------------------------------------------
%O4	; %O=2 - Build menu selections for display record
	;----------------------------------------------------------------------
	I %PG'<1 S FMQ=FMQ_" of "_%PAGE I %PG=%PAGE S FMQ=FMQ_", End of report"
	S FMQ=FMQ_$$%QUIT
	Q
	;
%DEL()	Q " <D>elete"
%FILE()	Q " <F>ile"
%NEXT()	I %PG<1 Q " <C>ontinue"
	I %PAGE>1,%PG<%PAGE Q " <N>ext"
	Q ""
%PREV()	I %PG>1,$O(VPG("")) Q " <P>revious"
	Q ""
%QUIT()	Q " <Q>uit"
	;
	;----------------------------------------------------------------------
REP()	; Format Data-Qwik report
	;----------------------------------------------------------------------
	; Extrinsic function called by ^SCAVHDG to format print detail
	; Req'd variables:  IORM, PG, PGNO, ZPGNO (see ^SCAVHDG)
	;
	N BEG,END,FMQ,I,OPT,X
	S OPT=0
	;
PNT	D PAGE(PGNO,OPT) S FMQ=$$EOP
	S OM=$$CLEAR_OM_FMQ_$$FORM(1)
	D WRITE("`"),READ S MSG=$$RTB^%ZFUNC($$UPPER^SCAUTL(MSG))
	;
	S X=0 F  S X=$F(FMQ,"<",X) Q:X=0  I MSG=$E(FMQ,X) Q
	I X=0 Q ""
	;
	I MSG="S" S OPT='OPT G PNT
	I MSG="N" Q "NEXT"
	I MSG="P" Q "PREV"
	I MSG="T" Q "TOP"
	Q ""
	;
PAGE(PGNO,OPT)	;
	S BEG=$P(^TMPSOM($J,0,PGNO),"|",1) S:BEG="" BEG=1
	S END=$P($G(^TMPSOM($J,0,PGNO+1)),"|",1)
	S:END="" END=$ZP(^TMPSOM($J,""))+1
	S OM=$$HDG(OPT)
	S L=BEG-1
	;
	F  S L=$O(^TMPSOM($J,L)) Q:L=""!(L=END)  DO
		.S X=^(L),OM=OM_$$DTL(X,OPT)
	Q
	;
HDG(OPT)	; Format page heading
	N I,X,Y S X="" F I=1:1 Q:'$D(vHDG(I))  S Y=vHDG(I) DO
		.I Y?1E.E1"PAGE:".E S Y=$P(Y,"PAGE:",1)_"PAGE:"_$J(PGNO,4)
		.S X=X_$$DTL(Y,OPT)
	Q X
	;
DTL(X,OPT)	; Format detail line
	I OPT S X=$E(X,1,27)_$J("",27-$L(X))_"|"_$E(X,81,132)
	S X=$$CNV($E(X,1,80)) I $L(X)<80 S X=X_$C(13)
	Q X
	;
EOP()	; End of page
	N FMQ S FMQ="Page "_PGNO
	I PN<0 S FMQ=FMQ_", End of report"
	I PN>0 S FMQ=FMQ_" <N>ext"
	I PGNO'=1 S FMQ=FMQ_" <T>op <P>revious"
	I IORM>80 S FMQ=FMQ_" <S>hift "_$S(OPT:"Left",1:"Right")
	S FMQ=FMQ_" <Q>uit ",L=$L(FMQ)
	S FMQ=$$EXT(FMQ,1,24,1,1,"T")
	S FMQ=FMQ_$$EXT("",L+1,24,0,0,"T",2)
	S FMQ=FMQ_$$EXT(" XMT ",L+6,24,1,1,"T")
	S FMQ=FMQ_$$EXT("",L+12,24,0,0,"T",1)
	Q FMQ
	;
	;----------------------------------------------------------------------
TBL(AR)	; Format Data-Qwik table look-up
	;----------------------------------------------------------------------
	;
	N I,N,V,X
	S AR(0)="",N=""
	F I=1:1:vcol S AR(0)=AR(0)_$P(vcol(I),",",3)_$C(9)
	;
	F  S N=$O(AR(N)) Q:N=""  S X(N)="" F I=1:1:vcol S V=$P(AR(N),$C(9),I) DO
		.I "N$"[$P(vcol(I),",",2),$L(V) S V=$J(V,+vcol(I))
		.S X(N)=X(N)_V_$J("",vcol(I)+2-$L(V))
	;
	S FMQ="<C>ontinue ",L=$L(FMQ)
	S FMQ=$$EXT(FMQ,1,24,1,1,"T")
	S FMQ=FMQ_$$EXT("",L+1,24,0,0,"T",2)
	S FMQ=FMQ_$$EXT(" XMT ",L+6,24,1,1,"T")
	S FMQ=FMQ_$$EXT("",L+12,24,0,0,"T",1)
	;
	S OM="" F I=0:1 Q:'$D(X(I))  S OM=OM_$E(X(I),1,78)_$C(13)
	S OM=$$CLEAR_OM_FMQ_$$FORM(1)
	D WRITE("`"),READ
	Q
