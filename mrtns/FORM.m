FORM(YLIMIT,XLIMIT)	;; Form system main editor
	;;Copyright(c)1997 Sanchez Computer Associates, Inc.  All Rights Reserved - 08/12/97 13:54:20 - NIB
	;     ORIG:  Frank R. Sanchez (1) - 09/25/88
	;     DESC: General purpose form editor
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
	;----------------------------------------------------------------------
	;
A	I $$NEW^%ZT N $ZT
	S @$$SET^%ZT("ZT^FORM")
	;
	W $$CURPOS
	;
	D ^FORMZB
	;
READ	;
	;
	; ---------- Save current form to disk every 2 minutes
	;
	R *X:120 E  D FILE:fileflag X $G(cmmd("BACKUP")) W $$CURPOS G READ
	;
	;;; R X#1:120 E .... DataTree MUMPS
	;
	I $ZB=$C(127) D FILE:2'[fileflag,DELETE G READ
	;
	D ZB^%ZREAD
	;
	I %fkey="",X'="" D FILE:1'[fileflag,INSERT G READ
	;
	I %fkey="ENT" D FILE:3'[fileflag,LNFEED G READ
	;
	I fileflag D FILE
	;
	I %fkey="CUB" D MOVLF:PX=LFTMAR S PX=PX-1 W MOVLFT G READ
	I %fkey="CUF" D MOVRT:PX=RHTMAR S PX=PX+1 W MOVRHT G READ
	I %fkey="CUU" D MOVUP:PY=TOPMAR S PY=PY-1 W MOVUP G READ
	I %fkey="CUD" D MOVDN:PY=BOTMAR S PY=PY+1 W MOVDN G READ
	;
	D VIDEO(VIDOF)
	;
	I '$D(key(%fkey)) D LOADKEY I  G READ
	;
	I JRNL'="" D JRNL
	X cmmd(key(%fkey)) I ZB="" D TRMRES^FORMINIT Q
	;
	; ---------- New cursor location
	;
	W CSI,PY,";",PX,"H"
	G READ
	;	
LOADKEY	; Load a command into the key(%fkey) array
	;
	N GOLD,FKEY
	S FKEY=%fkey,GOLD="" I $E(FKEY)="*" S GOLD="*",FKEY=$E(FKEY,2,99)
	S X=$G(^DBCTL("SYS","%KB",FKEY))
	I X'="" S X=$G(^DBCTL("SYS","FORMKEY",0,GOLD_X))
	I X="" W $$MSG^FORM("Unmapped special function key ("_%fkey_")") Q
	I '$$PARSCMD^FORMCMD(X) W $$MSG^FORM("Invalid function ("_X_")") Q
	S key(%fkey)=X Q
	;
DELETE	; Delete the character to the right of the cursor
	;
	I 'fileflag D INITDEL Q:'fileflag
	I PX=NXTOBJ D FILE2 Q
	S PX=PX-1
	W ERASE
	S STRING=STRING+1 Q
	;
INSERT	; Insert a character at the current cursor position
	; Unicode note:  X represents a character so continue to use $C
	S X=$C(X) ;;;;;; Remove this line for DataTree MUMPS
	;
	I 'fileflag D INIT Q:'fileflag
	;
	I PX=NXTOBJ D NOINSERT("Object boundary ("_py_","_(NXTOBJ+$L(PUSHCHR))_")") Q
	S STRING=STRING_X
	I PX=RHTMAR D INSERTC Q  ; Insert an additional column
	S PX=PX+1
	I PUSHCHR'="" W SCP,PUSHCHR,RCP
	Q
	;
INSERTC	; Insert a column
	;
	I '$D(M(py)) D FILE1
	S vx=video
	D PANRHT^FORMPAN(1)
	D VIDEO(vx)
	S PX=RHTMAR W $$CURPOS	
	Q
	;
NOINSERT(X)	; ---------- Character insert not allowed, replace original ---
	;
	S vx=video ; Save the current video attributes
	I PUSHCHR'="" W MOVLFT,$E(PUSHCHR)
	E  D PUTCHR(PY,PX)
	W $$MSG(X)
	D VIDEO(vx) ; Restore the correct video attributes 
	W $$CURPOS
	Q
	;
PUTCHR(PY,PX)	; Display a single character
	;
	N ox,py,px
	S py=$$ABSLTY,px=$$ABSLTX,ox=$$ORIGIN
	W $$CURPOS I '$D(M(py,ox)) D VIDEO(VIDOF) W " " Q
	D VIDEO($E(M(py,ox),1,6))
	W $E(M(py,ox),px-ox+1+6) Q
	;
INIT	; Initialize screen control attributes for character insert
	;
	S STRING="",fileflag=1 ; Initialize the character string
	S py=$$ABSLTY,px=$$ABSLTX
	I $D(M(py,px)) S ox=px
	E  S Z=$ZP(M(py,px)),ox=$S(Z="":px,$L(M(py,Z))+Z+1-6>px:Z,1:px)
	S LENGTH=$$LENOBJ
	I $O(M(py,ox))="" G INITA  ; There are no objects to the right
	S Z=ox+LENGTH-px G INITA:'Z ; # bytes between cursor & end of object
	;
INITA	;
	;
	S PUSHCHR=$S(ox+LENGTH>px:$E(M(py,ox),px-ox+7,9999),1:"")
	S v=video D VIDEO($S(LENGTH:$E(M(py,ox),1,6),1:VIDEO))
	I $D(D(py,ox)),$E(D(py,ox))'="@",X'=" " D NOINSERT("Cannot insert in data") S fileflag=0 Q
	I v'=video W MOVLFT,X
	S NXTOBJ=$O(M(py,ox)) I 'NXTOBJ S NXTOBJ=XLIMIT+1
	S NXTOBJ=NXTOBJ-ox-LENGTH+PX Q
	;
INITDEL	; Initialization for delete character
	;
	S STRING=0,fileflag=2
	S py=$$ABSLTY,px=$$ABSLTX,ox=$ZP(M(py,px))+0,LENGTH=$$LENOBJ
	;
	I ox+LENGTH'<px ; Cursor is within an object field
	E  I $D(M(py,px)) S ox=px,LENGTH=$$LENOBJ ; Cursor is on the 1st char
	E  S fileflag=0 D MOVLF:PX=LFTMAR S PX=PX-1 W MOVLFT Q
	;
	D VIDEO($E(M(py,ox),1,6))
	S ERASE=$C(8)_SCP_$E(M(py,ox),px-ox+7,9999) ; Erase char & redraw
	I $$BSASCII^SQLUTL(M(py,ox),1)#2 S ERASE=ERASE_VA(VIDOF)_" "_VA(video)_RCP ; RV video
	E  S ERASE=ERASE_" "_RCP
	;
	S NXTOBJ=$ZP(M(py,ox)) S:NXTOBJ NXTOBJ=NXTOBJ+$L(M(py,NXTOBJ))-6
	S:NXTOBJ<XORIGIN NXTOBJ=XORIGIN S NXTOBJ=NXTOBJ-XORIGIN+LFTMAR
	I PX=NXTOBJ S fileflag=0 Q  ; Can't move
	;
	I $O(M(py,ox))="" Q  ; There are no right hand objects
	S Z=ox+LENGTH-px
	Q
	;
FILE	; file changes to M(array)
	;
	S EDITED=1 ; Edited flag
	I fileflag=1 G FILE1 ; Insert characters
	I fileflag=2 G FILE2 ; Delete characters
	I fileflag=3 G FILE3 ; Insert lines
	I fileflag=4 G FILE4 ; Delete lines
	Q
	;
FILE1	; Insert characters into an object
	;
	S px=px-ox,fileflag=""
	S M=$S(LENGTH:M(py,ox),1:VIDEO) K M(py,ox)
	;
	S Z=$E(M,7,999),Z=$E(Z,1,px)_STRING_$E(Z,px+1,9999)
	I px=0,$E(STRING)=" ",$$BSASCII^SQLUTL(M,1)#2=0 S px=$$SLB(STRING),Z=$E(Z,px,9999) Q:Z=""
	S M(py,ox)=$E(M,1,6)_Z
	I  S xx=ox+px-1,px=ox,ox=xx,yy=py D MOVE ; Spaces were used to move
	I JRNL'="" D FILJRNL
	Q
	;
FILE2	; Delete characters from an object
	;
	S fileflag=""
	S px=px-ox,Z=$E(M(py,ox),7,9999)
	S Z=$E(Z,1,px-STRING)_$E(Z,px+1,9999)
	I Z="" K M(py,ox),D(py,ox),P(py,ox) Q
	S M(py,ox)=$E(M(py,ox),1,6)_Z
	I px-STRING<0 S xx=ox+px-STRING,px=ox,ox=xx,yy=py D MOVE
	I JRNL'="" D FILJRNL
	Q
	;
FILE3	; Insert lines
	;
	S fileflag=""
	;
	I RULER D ROW^FORMRULR(PY-STRING) W $$CURPOS
	;
	S py="",px=""
	F  S py=$ZP(M(py)) Q:py=""!(py<START)  F  S px=$O(M(py,px)) Q:px=""  S yy=py+STRING,ox=px D MOVE
	Q
	;
FILE4	; Remove lines
	;
	S fileflag=""
	;
	S py=START,px="",YORIGIN=YORIGIN-STRING
	I RULER D ROW^FORMRULR(PY) W $$CURPOS
	F  S py=$O(M(py)) Q:py=""  F  S px=$O(M(py,px)) Q:px=""  S yy=py-STRING,ox=px D MOVE
	Q
FILJRNL ; ------------ File text changes to journal ----------
	;
	U JRNL
	S JRNLPYPX=$$ABSLTY_","_$$ABSLTX
	W !,"$ TEXT ",Z," /LOC=",py,",",ox 
	U ""
	Q
	;
MOVE	; Move M(py,px), D(py,px), P(py,px)
	;
	S M(yy,ox)=M(py,px) K M(py,px)
	I $D(D(py,px)) S D(yy,ox)=D(py,px) K D(py,px)
	I $D(P(py,px)) S P(yy,ox)=P(py,px) K P(py,px)
	Q
	;
REMOVE	; Remove selected objects
	;
	D VIDEO(VIDOF)
	I $D(P)>1 D REMOVE^FORMFUN W $$CURPOS Q
	S py=$$ABSLTY
	I $D(M(py)) D REMOVOBJ G REMOVE:$D(P) W $$CURPOS Q
	I $O(M(py))="" Q  ; There is no data at higher coordinates
	I 'fileflag S fileflag=4,STRING=1,START=py
	E  S STRING=STRING+1
	S YORIGIN=YORIGIN+1 W LINDEL D PUTRGN^FORMFUN(BOTMAR_";"_LFTMAR)
	W $$CURPOS Q
	;
REMOVOBJ	; Remove all of the objects on this line
	;
	D SELLIN^FORMSEL("0"),REMOVE^FORMFUN Q
	;
LNFEED	; Line feed
	;
	I PX>LFTMAR S PX=LFTMAR S:PY<BOTMAR PY=PY+1 W $$CURPOS Q
	I $$LNLIMIT W $$MSG("Line limit ("_YLIMIT_")") Q
	;
	W $$CURPOS
	I 'fileflag G LNFEEDA:$O(M($$ABSLTY-1))="" S fileflag=3,STRING=1,START=$$ABSLTY
	E  S STRING=STRING+1
	;
LNFEEDA	;
	;
	I PY<(BOTMAR+TOPMAR*.7) S PY=PY+1 W:fileflag LININS W $$CURPOS Q
	I YORIGIN,YORIGIN+BOTMAR-TOPMAR'<YLIMIT S PY=PY+1 W:fileflag LININS W $$CURPOS Q
	S YORIGIN=YORIGIN+1 W $$CUR(TOPMAR,1),LINDEL,$$CUR(PY-1,1),LININS W $$CURPOS
	Q
	;
LNLIMIT()	; Line limit check
	;
	I $ZP(M(""))+$S(fileflag:STRING,1:0)'<YLIMIT Q 1  ; Object at the line limit
	I $$ABSLTY'<YLIMIT Q 1
	Q 0
	;
DATAERR	; Data item access error
	;
	I X'="" D PUTCHR(PY,PX)
	W $$MSG($P(D(py,ox),"|",1)) Q
	;
MSG(X,P)	; ---------- Print warnings and errors ----------
	;
	U 0 W BTMPAG
	I $$BSASCII^SQLUTL(VIDHL,1)<128 D VIDEO(VIDHL)
	W $E(X,1,80)
	I '$G(P) Q $$CURPOS
	W " ... Press any key to continue " R X#1 W BTMPAG Q ""
	;
ORIGIN()	; Find the object origin that contains these coordinates
	;
	I $D(M(py,px)) Q px  ; Current X coordinate is on the origin
	S Z=$ZP(M(py,px)) ; Back up to the closest previous object
	I Z,$L(M(py,Z))-6+Z>px Q Z  ; Current position is within object range
	Q px  ; This is a new object
	;
VIDEO(v)	; ---------- Correct display and reset <video> ----------
	;
	Q:v=video  ; Display is already set correctly
	S video=v S:v]]"~" v=$$BYTECHAR^SQLUTL($$BSASCII^SQLUTL(v,1)#128)_$E(v,2,6) W VA(v)
	I video]]"~"'=gt s gt='gt W GT(gt) ; Change graphics toggle
	Q
	;
LENOBJ()	; ---------- Return the string length of an object (no header) ---
	;
	I '$D(M(py,ox)) Q 0
	Q $L(M(py,ox))-6
	;

JRNL	; ---------- Write command to a journal file ----------
	;
	N X
	U JRNL
	S X=$$ABSLTY_","_$$ABSLTX
	I $G(JRNLPYPX)'=X W !,"$ GOTO "_X S JRNLPYPX=X
	W !,"$ ",key(ZB) U 0
	Q
ZT	; ---------- Error trap ----------
	;
	D TRMRES^FORMINIT 
	D ET^%ZT("",.error2)
	W $$MSG^FORM($P(error2,",",2,99),1)
	;
	D PUTRGN^FORMFUN() ; Repaint screen
	G A
	;
FK(ZB)	;
	Q $G(%fkey(ZB))
	;
MOVLF	D PANLFT^FORMPAN(1) S PX=PX+1 W $$CURPOS Q
MOVRT	D PANRHT^FORMPAN(1) S PX=PX-1 W $$CURPOS Q
MOVUP	D SCROLLUP^FORMPAN(1) S PY=PY+1 W $$CURPOS Q
MOVDN	D SCROLLDN^FORMPAN(1) S PY=PY-1 W $$CURPOS Q
	;
SLB(X)	N I F I=1:1 Q:$E(X,I)'=" "
	Q I
ABSLTY()	Q PY+YORIGIN-TOPMAR ; Absolute Y coordinate
ABSLTX()	Q PX+XORIGIN-LFTMAR ; Absolute X coordinate
CURPOS()	Q CSI_PY_";"_PX_"H" ; Cursor position to PY,PX
CUR(Y,X)	Q CSI_Y_";"_X_"H" ; Direct cursor address
