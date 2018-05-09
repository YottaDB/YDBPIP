FORMVAR(VAR,OBJOPT)	;; OOE Form system, 	item definition (PF2)
	;;Copyright(c)2003 Sanchez Computer Associates, Inc.  All Rights Reserved - 03/11/03 16:11:36 - RUSSELL
	;     ORIG:  Frank R. Sanchez (1) - 10/26/88
	;     DESC: Define characteristics of variable objects
	;           [Filename]Data_item or <<Local_Variable>>
	;
	; I18N=QUIT	Excluded from I18N Standards
	; ---------- Revision History ------------------------------------------
	; 07/14/06 - RussellDS - CR22121
	;	     Replaced $A references with $$BSASCII^SQLUTL to ensure
	;	     Unicode compliance.
	;
	; 05/09/06 - RussellDS - CR20967
	;	     Eliminate call to DBSEXEK3 and call DBSWRITE directly.
	;
	; 01/29/03 - Dan Russell - 51351
	;	     Modify EDITOR section to allow blank lines to accomodate
	;	     PSL code.
	;
	;	     Removed direct calls to ^CUVAR global.
	;
	; 08/04/95 - Bob Chiang - 18
	;            Modified the EDITOR section to pass the correct screen
	;            banner information to the DBSWRITE routine.
	;
	; 10/26/94 - Steve Canfield - I18N
	;	     Removed calls to $$^MSG.
	;
	;-----------------------------------------------------------------------
	;
	S py=$$ABSLTY^FORM,px=$$ABSLTX^FORM,ox=$$ORIGIN^FORM
	;
	; 
	S DQP=$G(D(py,ox)) I DQP="",'$D(M(py,ox)) S $P(DQP,dl,5)=""
	;
	I $E(DQP)="#",$G(RID)'="" Q  ; Section Marker
	;
	I DQP="" D TAGONLY Q
	I "@"[$E(DQP),$G(DBOPT)'=5 D TAGONLY Q
	;
	I $$BSASCII^SQLUTL(VIDEO,1)>127 S VIDEO=($$BSASCII^SQLUTL(VIDEO,1)#128)_$E(VIDEO,2,6)
	;
	S %O=1,VPG(1)="Print attributes",VPG(2)="Edit attributes"
	;
	S TABLE=$P(DQP,dl,6)'=""
	S PTRN=$P(DQP,dl,9)'=""
	S DELIM="" I $P(DQP,dl,16) S DELIM=$C($P(DQP,dl,16))
	;
	S EDI(1)=''$P(DQP,dl,13) ; Pre processor flag
	;
	S EDI(2)=''$P(DQP,dl,14) ; Post processor flag
	;
	S EDI(3)=0 I FORMHDG,$P(DQP,dl,1)="" S EDI(3)=1 ; Default heading flag
	;
	S KVAR="K %TAB,VO,VFSN,UX"
	S %PG=1,%PAGE=$O(PAGE(""),-1),%TO=$$TO
	;
VPG	; Page control
	;
	S X=PAGE(%PG),PGM=$P(X,"|",1),EXTANT=$P(X,"|",2)
	S ORIGIN=(BOTMAR-EXTANT)_";"_(RHTMAR-$P(EXTANT,";",2))
	S TOPY=ORIGIN+1,LFTX=$P(ORIGIN,";",2)+1
	;
	D CLRRGN^FORMFUN			; Clear region for item
	;					; definition window
	K RM
	;
	; ---------- Define %fkey for DQ screen entry mode
	;
	N %fkey D ZBINIT^%TRMVT()
	;
	D ^@PGM W BTMPAG
	;
VPG0	;
	;
	I "DFQ"[VFMQ G VER ; Process completed/aborted
	S %PG=%PG+1				; switch page
	G VPG
	;
VER	;
	;
	I RHTMAR=132 D TERM^FORMINIT(133) ;		Reset screen margin
	N I,Z,ZNEW
	S REPAINT=$G(REPAINT)+0
	I VFMQ="Q" G VER0
	;
	; Remove PRE/PP MUMPS code if status changed from Y to N
	;
	F I=13,14 I 'EDI(I-12) S Z=$P(DQP,dl,I) I Z S $P(DQP,dl,I)="" K PP(Z)
	;
	; Set up data item PRE/POST processors
	;
	F EDI=1,2 I EDI(EDI) D EDITOR(EDI)
	;
	; ========== Full screen
	;
	I 'REPAINT G VER0
	;
	D TRMSET^FORMINIT
	I RHTMAR>80 D CI^FORMINIT G VER0
	D CO^FORMINIT
	;
	; ========== Data Window only
VER0	;
	I REPAINT=0 D PUTRGN^FORMFUN(ORIGIN,(EXTANT+1)_";"_($P(EXTANT,";",2)+1),1)
	;
	D TRMSET^FORMINIT
	;
	I VFMQ="Q" Q
	I $D(M(py,ox)) D CLROBJ^FORMFUN(py,ox)
	;
	I $P(DQP,dl,17)>0 S $P(DQP,dl,16)=124 ; Default to |
	;
	X "D OBJ^"_MAINPGM_"(DQP)" ; Define (m) for display
	;
	N BFR
	;
	I $D(M(py,ox)) G VER1
	;
	; New object
	;
	I FORMHDG,EDI(3) D ^FORMHDG(DQP) ; Create heading
	;
	;             Modified to set up default field attributes for screen
	;             banner option (reverse image).
	I $G(SID)'="" D  			; 05/26/93 BC
	.	I $G(vudh) S H=$$HEADER^FORMINIT(vudh) K vudh Q  ; Banner
	.	S H=$$HEADER^FORMINIT(2) ; IBS standard (highlight)
	;
	S M(py,ox)=H
	S ZNEW=1
	;
VER1	;
	S H=$E(M(py,ox),1,6) K M(py,ox)
	I $D(M(py)) D FIT^FORMFUN(py,ox,$L(m))
	I DELIM'="" S $P(DQP,dl,16)=$A(DELIM)
	S M(py,ox)=H_m,D(py,ox)=DQP
	S EDITED=1
	;
	D PUTOBJ^FORMFUN(py,ox)
	;
	X KVAR
	;
	I '$G(ZNEW) G VER2
	;
	I $E(DQP)="#" S PY=PY+1,H=$$HEADER^FORMINIT(128+2) I '$D(VA(H)) D VIDSP^FORMINIT(H)
	;
	; Move cursor 2 spaces to the right or at position 1 for MARKER
	;
	I $E(DQP)="#" S PX=$G(RULER)+1
	E  I $G(RID)'="" S PX=$$RELTVX^FORMCUR+$l(m)+2
	I PX>$G(NUMCOL) S PX=$$RELTVX^FORMCUR		; Cross screen margin
	;
VER2	;
	Q:'$D(BFR)
	S R(BFR)=$$HEADER^FORMBFR W $$MSG^FORM("Object(s) overlayed"_BFR)	; *** BC - 11/02/93
	;
	Q
	;
TAGONLY	; Tag a Literal object for pre-post processor syntax
	;
	S DQP=$$^FORMREAD($E($P(DQP,dl,1),2,99),12,"literal tag: @")
	I DQP="" K D(py,ox) Q  ; Delete a tag
	S D(py,ox)="@"_DQP Q
	;
EDITVAR	; Check data item parameters for errors
	; 
	W $$MSG^FORM("External parameter list not supported",1)		; *** BC - 11/02/93
	Q
	;
EDITOR(OPT)	; Invoke the EDITOR to edit Pre & Post processors
	;
	N I,KEY,MSGTXT,N,WIDTH,VFMQ,Z,%A
	;
	;
	S KEY=+$P(DQP,dl,OPT+12)
	; *** - SMC - 7/94 - Replace formatting of message ID 
	I OPT=1 S MSGTXT="Modify pre-processor"
	E  S MSGTXT="Modify post-processor"
	;
	; *** - BC - Replace DBSMENU with DBSMBAR call
	;
	I KEY,'$$YN^DBSMBAR("",MSGTXT,0) Q  ; Don't invoke the editor
	;
	S WIDTH=80
	S N=""
	F I=1:1 S N=$O(PP(KEY,N)) Q:N=""  S %A(I)=PP(KEY,N) I $L(%A(I))>78 S WIDTH=132
	;
	D TRMRES^FORMINIT
	D ^DBSWRITE("%A",3,22,99999,WIDTH,MSGTXT)
	;
	I VFMQ="Q" G EDITOR1
	;
	S KEY=$O(PP(""),-1)+1
	S Z=1 F I=1:1 Q:'$D(%A(I))  S PP(KEY,Z)=%A(I),Z=Z+1
EDITOR1	;
	I '$D(PP(KEY)) S KEY=""
	S $P(DQP,dl,OPT+12)=KEY
	S REPAINT=1
	Q
	;
PAINT	;
	; Display full screen
	;
	D PUTRGN^FORMFUN() ; Redisplay the screen
	D CLRRGN^FORMFUN ; Clear the display from the box area
	D VREPAINT^@PGM ; Redisplay the prompts and data
	Q
	;
UX(FID,SN,ORIG,CURR,NODE,POS)	; Define update array for related fields
	;
	I '$D(UX(FID,SN)) S UX(FID,SN)=ORIG_"|"_CURR_"|"_$G(NODE)_"|"_$G(POS) Q
	S $P(UX(FID,SN),"|",2)=CURR I $P(UX(FID,SN),"|",1)=CURR K UX(FID,SN)
	Q
	;
LIBRARY()	Q "SYSDEV"
YN(X)	Q $S(X:"Y",1:"N")
TO()	;
	N TO
	I $G(%TO)>1 S TO=%TO
	E  S TO=$$^CUVAR("%TO") I 'TO S TO=60
	Q TO
	;
CUR(Y,X)	Q CSI_Y_";"_X_"H"
	;
ABSLTY(Y)	Q Y+YORIGIN-TOPMAR ; Absolute Y coordinate
ABSLTX(X)	Q X+XORIGIN-LFTMAR ; Absolute X coordinate
RELTVY(Y)	Q Y-YORIGIN+TOPMAR ; Relative Y coordinate
RELTVX(X)	Q X-XORIGIN+LFTMAR ; Relative X coordinate
