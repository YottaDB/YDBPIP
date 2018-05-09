DBSFRMDE(dft,len,typ,tbl,hlp,dec,min,max,py,px,sec,rsiz)	; 
	;;Copyright(c)1998 Sanchez Computer Associates, Inc.  All Rights Reserved - 07/23/98 09:40:00 - WATSOND
	; 
	; ORIG: CHIANG - 06/15/94 
	; DESC: Input manager for keyboard entry of string data.
	;
	; KEYWORDS:	DATA-QWIK,SCREEN,DATA ENTRY
	;
	; ARGUMENTS:
	;
	;       . dft	Default input string	/TYP=T/REQ/MECH=VAL
	;       . len	Field length		/TYP=N/REQ/MECH=VAL
	;       . typ	DQ data type		/TYP=T/REQ/MECH=VAL
	;       . tbl	Lookup table		/TYP=T/NOREQ/MECH=VAL
	;       . hlp	HELP file reference	/TYP=T/NOREQ/MECH=VAL
	;       . dec	Decimal precision	/TYP=N/NOREQ/MECH=VAL
	;       . min	Minimum value		/TYP=T/NOREQ/MECH=VAL
	;       . max	Maximum value		/TYP=T/NOREQ/MECH=VAL
	;       . px	Location (x-coordinate) /TYP=N/NOREQ/MECH=VAL
	;       . py	Location (y-coordidate) /TYP=N/NOREQ/MECH=VAL
	;       . sec	Secret mode		/TYP=L/NOREQ/MECH=VAL
	;       . rsiz 	Internal size		/TYP=N/NOREQ/MECH=VAL
	;
	; INPUTS:
	;
	;	. %fkey  Function key array			/TYP=N/REQ
	;
	;	. OLNTB	 Used by table lookup & message display	/TYP=N/REQ
	;                to locate the bottom of window (Y*1000+X)
	;
	;       . VPGM   The callback program VREPRNT^@VPGM	/TYP=T/NOREQ
	;                for the screen refresh function.
	;
	; I18N=QUIT: Excluded from I18N standards. 
	;-----------------------------------------------------------------------
	;
	; 12/08/04 - RussellDS - CR13258
	;	     Remove obsolete parameter from call to ^DBSTBL.
	; 01/30/97 - watsond  *** ONSITE PATCH ***
	;            Modified the display section to enable processing of
	;            25 external accounts during CIF create.
	;
	; 08/12/97 - Betty Ni - 25653
	;            Replaced follows operator "]" with a "]]". 
	;
	; 02/04/97 - Bob Chiang - 23697
	;            Modified CUD section to terminate data entry mode when the
	;            user press <down arrow> key and the cursor location is on 
	;            the last line of the repeating region.
	;
	; 02/02/96 - SPIER - 20808
	;            In PUTBUF section, added character check prior to
	;	     condition which treats 0 and null as the same. If
	;            logical is entered as Y,N then the prior command
	;	     would return incorrect results.
	;
	; 12/12/95 - SPIER - arq19651
	;            Modified section PROCESS, when PUP or PDN, the value
	;	     of voff was set incorrectly if up and down arrows
	;	     were used. This caused the screens being displayed to
	;	     jump from 2 to 4 or 3 to 1.
	;
	; 12/05/95 - SPIER - arq19651
	;            Removed the display of page number on the highlighted
	;	     menu on the bottom of the screen. Due to Up and down
	;	     arrows on repeating screens, this value was calculated
	;	     incorrectly( values such as -1).
	;
	; 12/01/95 - SPIER - ARQ20333
	;            Modified change made 11/27 so that if $ format, call
	;	     INT^%ZM only if X is not null.
	;
	; 11/27/95 - Steve Manderbach - ARQ19983
	;	     Modified PUTBUF section to change currency data items
	;	     ($) to their internal format before setting vbuf() array.
	;
	;	     Change line from:  I "DCL"[typ S X=$$INT^%ZM(X,typ)
	;		           to:	I "DCL$"[typ S X=$$INT^%ZM(X,typ)
	;
	; 06/19/95 - Bob Chiang - 10194 - 290
	;            Modified PUTBUF section to treat NULL and 0 the same for
	;            items defined as logical data type.
	;
	; 05/05/95 - Bob Chiang - 220
	;            Modified CUD section to return the correct %TAB pointer
	;           after a CUD (move cursor down by one line) operation.
	; 
	; 03/03/95 - Shaodong Tony Xu - ARQ 290
	;            Clean up the linkage error, remove a call PUPERR^DBSVER.
	;----------------------------------------------------------------------
	;
	I '$D(%TO) N %TO S %TO=$$TODFT^%ZREAD
	;
	S vptr=0,X=dft ;			Initial String Pointer
	S rsiz=$G(rsiz) I 'rsiz S rsiz=len	; *** - BC - Replaced vofl() reference 10/21/93
	;
	k zvrec
	S zvrec=vrec
	F  D read Q:%fkey="ENT"  D PROCESS Q:%fkey="ENT"
	I zvrec'=vrec S vokeys=""
	Q
read	;
	W $$CUP
	I $G(sec) D SECRET G term
	;
	S X=$$TERM^%ZREAD(X,rsiz,.vptr,"_",%TO,0,len,"$N"[typ,1)
	I X?.E1C.E S X=$$CCHR(X)
	I %fkey="" G read
	;
	I %fkey="REM",typ="L" S X=dft W X G read	; Disable REMOVE key
	I %fkey="REM" S X="" D PUTBUF
	;
	I vptr,X'="" S vdsp=$$VDSP ;		String edited, reformat (0/1)
	;
	;----------------------------------------------------------------------
term	; Interpret terminator for function key calls
	;----------------------------------------------------------------------
	;
	I X="?" S %fkey="SEL",X=dft,vptr=0 W $$CUB^%TRMVT,$S(dft="":$$UL(1),1:dft)
	;
	I zbterm[%fkey D:vptr PUTBUF Q
	I %fkey="REM"!(%fkey="INS")!(%fkey="TOP")!(%fkey="BOT")!(%fkey="CUB") Q
	I %fkey="KYB" D KYB G term ;		Keyboard Emulation
	D
	.	I %fkey="DUP" S X=$$DUP(X) Q
	.	I %fkey="SEL" S X=$$TBL(X) Q
	.	I %fkey="FND" S X=$$TBL(X) Q
	.	I %fkey="HLP" D HLP Q
	.	I %fkey="BUF" S X=$$BUF(X) S:"DCL"[typ X=$$EXT^%ZM(X,typ) Q  ; <PF1><REMOVE>
	.	I %fkey="MNU" S X=$$MNU(X) Q
	.	I %fkey="PRN" D PRN Q
	.	I %fkey="DSP" D DSP(1) S %fkey="" Q
	.	;I %fkey="SES" D:$$SES(hlp) DSP(1) Q
	.	I %fkey="RCL" S X=$$RECALL^DBSTSINP(X) Q
	.	I %fkey="BRK" D
	..		N VBRK
	..		;;;;;S VBRK=$$^%ZBREAK
	..		S VBRK="1|B"
	..		I +VBRK D CLOSE X $P(VBRK,"|",2)
	.	I %fkey'="",$D(cmmd(%fkey)) D  Q
	..		N code
	..		S code=cmmd(%fkey),%fkey="ENT"
	..		X code
	.	W $C(7) S %fkey=""
	;
	I $D(RM) D PNTRM ;			Display any messages
	S vdsp=$$VDSP ;				Set formatted display flag
	;
	W $$CUP,$$CS,$E(X,1,len),$$UL(len-$L(X)),$$CR ;	Re-Display String
	;
	G term:%fkey'="" ;			Input terminated
	G read ;	 			Continue in Current String
	;
	;----------------------------------------------------------------------
PUTBUF	; Put the current string in a buffer
	;----------------------------------------------------------------------
	;						; *** 06/19/95 BC
	I typ="L",X'?1A,+X=$$INT^%ZM(X,"L") Q		; Treat NULL and 0 thr same ;2/2/96 MAS
	I typ="$",X'="" S X=$$INT^%ZM(X,typ)		; Internal Format 12-1-95 mas
	I "DCL"[typ S X=$$INT^%ZM(X,typ)		; Internal format
	I X=dft Q					; No change
	;                                               ; Changed back to old data
	I $D(vhis(vfrm,vrec,vdinam)),X=vhis(vfrm,vrec,vdinam) K vhis(vfrm,vrec,vdinam)
	E  S vhis(vfrm,vrec,vdinam)=dft			; Save old data
	D keys						; Missing keys
	S vbuf(vfrm,vrec,vdinam)=X			; New data
	Q
keys	;
	N di,i
	F i=1:1:$L(vkeys,",") D
	.	S di=$P(vkeys,",",i)			; Access key name
	.	I di=vdinam Q				; Current field
	.	I $G(vbuf(vfrm,vrec,di))'="" Q		; Already defined
	.	S vbuf(vfrm,vrec,di)=$G(@di)		; Access key default value	 
	Q
	;
	;----------------------------------------------------------------------
DUP(dft)	; Copy data from previous line or field
	;----------------------------------------------------------------------
	;
	I $G(NI)<2 S %fkey="" Q dft			; Nothing to DUP from
	;						; First repeat field
	I $D(%MOD),$D(%MODOFF),NI'>(%MOD+%MODOFF) S %fkey="" Q dft
	;
	S %fkey="ENT"					; Protect current field
	N I,E4,E5,E67,E8,E9,E12,V,DATA,SN,vhdr		; attributes 4/23/93 BC
	;
	I $G(%MOD)>1,NI-%MOD'<$G(%MODGRP) S N=NI-%MOD ;	DUP from prior record
	E  S N=NI-1 ;					DUP from prior field
	;
	Q $$RESET^DBSFRMCS(N)
	;
	;----------------------------------------------------------------------
MNU(OX)	; Select and process PF3 option
	;----------------------------------------------------------------------
	;
	N I,MASK,OP,%JRNL					; RC 02/09/93
	F I=1,2,5 S MASK(I)=""
	I OX'="" S OP(1)="X=$$^SCACLPBD(NI,.%TAB,.VO,2)" K MASK(1)
	I $D(^TMP(0,$J,"CLPBRD")) S OP(2)="S X=$$^SCACLPBD(NI,.%TAB,.VO,3)" K MASK(2)
	S OP(3)="S X=$$^SCACLPBD(NI,.%TAB,.VO,1)"
	S OP(4)="D FUNCTION^DBSCALC"
	I OX="" S OP(5)="D EHLP^DBSFRMDE(hlp)" K MASK(5)
	I OX="",tbl'="" S OP(6)="D ETBL^DBSFRM(tbl)" K MASK(6)
	;
	S OP=$$^DBSMBAR(5,"",.MASK) I 'OP S %fkey="" Q OX ;	No option selected
	S X=OX X OP(OP)
	;
	D OPEN ;					Reset terminal
	S vdsp=$$VDSP
	I X="" S X=OX,%fkey=""
	E  S %fkey="ENT" I $L(X)>rsiz S X=$E(X,1,rsiz)
	Q X
	;
	;----------------------------------------------------------------------
HLP	; Invoke HELP documentation
	;----------------------------------------------------------------------
	;
	N VPT,VPB,ER
	S VPT=OLNTB\1000+1,VPB=23
	D SEL^DBSHLP(hlp,.VPT,.VPB) S %fkey=""
	I VPT D DSP(VPT)
	Q
	;
	;---------------------------------------------------------------------- 
I18N(phrobj)	; Invoke Interactiv MLD Utility 
	;---------------------------------------------------------------------- 
	; 
	S %fkey="",idx3="",idx5="",v4x=0 
	I $P($G(I(2)),"]",2)'="" D  Q:'v4x 
	. S idx3=$P($P($G(I(2)),"]",1),"[",2)   ; File id 
	. I idx3="*" S v4x=1 Q                  ; Variable field - OK 
	. S idx5=$P($G(I(2)),"]",2)             ; Field id 
	. S v4x=$P($G(^DBTBL("SYSDEV",1,idx3,9,idx5)),"|",27) 
	. I 'v4x S RM=$$^MSG("2050")		; Not valid for extraction
	; 
	D ^I18NCRT(phrobj,.X,idx3,idx5) 
	; 
	Q 
	; 
	;----------------------------------------------------------------------
BUF(OX)	; Recall previous field/record from vhis() table
	;----------------------------------------------------------------------
	;
	N vkey,vseq,vdi,v
	S %fkey=""
	;
	I '$D(vhis(vfrm,vrec,vdinam)) Q OX
	I (vi(1)'?1N1"*") S vptr=1 Q vhis(vfrm,vrec,vdinam)
	; Revover single record
	S vdi="" F  S vdi=$O(vhis(vfrm,vrec,vdi)) Q:vdi=""  D
	.	S v=vhis(vfrm,vrec,vdi)			; Get value from buffer
	.	I vdi=vdinam S vkey=v			; Key field
	.	D DEFAULT^DBSMACRO(vfrm_"."_vdi,v)	; Put it back
	K vhis(vfrm,vrec)				; Remove old history
	S z=$$KEYVAL^DBSFRMCS(vfrm,vrec,vkeys)		; Get key value
	k vsts(vfrm,z)					; Remove status
	S vptr=1 Q vkey
	;
	;----------------------------------------------------------------------
DSPVDFT(NI)	; Display the vdft(array) from position NI
	;----------------------------------------------------------------------
	;
	N X
	I '$D(NI) S NI=""
	F  S NI=$O(vdft(NI)) Q:NI=""  S X=%TAB(NI) W $$PNTFMT($P(vdft(NI),"|",1),$A(X,3),$E(X,6),$A(X)+1,$A(X,2)+1)
	Q
	;
	;----------------------------------------------------------------------
PNTFMT(X,len,typ,py,px)	; Display formatted string
	;----------------------------------------------------------------------
	;
	S X=$E(X,1,len)
	Q $$CUP_$S("TUFLDC"[typ!(X=""):X_$$UL(len-$L(X)),1:$J(X,len))
	;
	;----------------------------------------------------------------------
PNTRM	; Print message at designated location, default to BOP
	;
	; RM=message|LLCCC         screen xy location
	; RM=message|NN            data item location in %TAB sequence
	; RM=message|[FID]DI       data item name in %TAB array
	;----------------------------------------------------------------------
	;
	Q:$D(RM)=0  W $$CLR^%TRMVT(OLNTB\1000+1)
	I $D(RM)#10 D PNTM
	S N="" F  S N=$O(RM(N)) Q:N=""  S RM=RM(N) D PNTM
	K RM
	Q
	;
PNTM	;
	;
	I RM="" Q  ;				No message
	;
	N DL,DY
	;
	I RM["""|""" S DY=$P(RM,"|",3),RM=$P(RM,"|",1,2)
	E  S DY=$P(RM,"|",2),RM=$P(RM,"|",1)
	S DL=0 I DY="" S DY=23000
	;
	I DY?1"-"1N.N S DY=-DY G P0A ; 		First Line
	I DY?1"["1E.E1"]"1E.E D P3 ; 		Message|[FID]DI
	I DY<1000,'$D(%TAB(DY)) S DY=23000 ;	Default to bottom of screen
	;
	S ER=$G(ER) ; TNT
	I 'ER,$G(vexit)>$G(NI),DY>22999 Q  ;	Don't display in fast exit
	;
	I DY<1000,$D(%TAB(DY)) D:RM="" DSPNI(DY) I RM]]"" S X2=%TAB(DY) D P0XY
	S:DY<1 DY=23000
P0A	;
	;
	W $$CUP^%TRMVT(DY#1000+1,DY\1000+1)
	I DY'>OLNTB W $S(DL:$E(RM,1,DL)_$$UL(DL-$L(RM)),1:$E(RM,1,78)) Q
	;
	W $$MSG^%TRMVT($E(RM,1,78),ER,0,DY#1000+1,DY\1000+1)
	S vkill=$G(vkill)_",vline24",vline24=1
	Q
	;
	;----------------------------------------------------------------------
P0XY	; RM()=message|seq  ( %TAB sequence number )
	;----------------------------------------------------------------------
	;
	S DY=$A(X2)*1000+$A(X2,2),DL=$A(X2,3)
	Q
	;
	;----------------------------------------------------------------------
P3	; Logical data item position for DYDX (consider .PROTECT.)
	;----------------------------------------------------------------------
	;
	N I,Z
	S I=""
	F  S I=$O(%TAB(I)) Q:I=""  S Z=$P(%TAB(I),"|",3) S:$E(Z,1,2)="[]" Z="["_DFID_"]"_$E(Z,3,99) I Z[DY S DY=I Q
	Q
	;
	;----------------------------------------------------------------------
DSPNI(NI)	; Display data at to %TAB(NI)  RM="|tab #"
	;----------------------------------------------------------------------
	;
	N V,vhdr,vsiz,vtyp
	S V=$$RESET^DBSFRMCS(NI,"","",.vhdr,.vsiz,.vtyp)
	W $$PNTFMT(V,vsiz,vtyp,$A(vhdr,1),$A(vhdr,2)) Q
	;
	;----------------------------------------------------------------------
KYB	; Display keyboard menu and choose option
	;----------------------------------------------------------------------
	;
	S ZB=$$EMULATE^DBSMBAR I ZB="" S ZB=13,%fkey="ENT" Q
	S %fkey=%fkey(ZB) Q
	;
	;----------------------------------------------------------------------
ETBL(tbl)	; Edit Lookup Table
	;----------------------------------------------------------------------
	;
	I $G(tbl)="" W $$MSG^%TRMVT($$^MSG("1659"))
	Q
	;
	;----------------------------------------------------------------------
EHLP(hlp)	; Edit Help Documentation
	;----------------------------------------------------------------------
	;
	I '$D(^SCATBL(1,"DBSDOCD",%UCLS)) S ER=1,RM=$$^MSG("2032") Q  ; Not Authorized
	;
	N DI,DITEM,DINAM,FDOC,FID,%FID,OP,OPT,PG,X
	;
	S hlp=$$CVTREF^DBSDD(hlp),FID=$P(hlp,".",2),DITEM=$P(hlp,".",3) 
	S OPT="D",%FID=FID
	S FDOC=$G(^DBTBL(%LIBS,1,FID,13))
	;
	D DI1^DBSDOC
	D VREPRNT^@PGM
	Q
	;----------------------------------------------------------------------
TBL(V)	; SELECT or FIND table
	;----------------------------------------------------------------------
	;
	I $G(tbl)="" G NOTBL:typ'="F" S tbl="@TBL^UFRE"
	;
	N E67,VPT,VPB,ER
	S E67=rsiz,VPT=OLNTB\1000+1,VPB=23
	;
	S X=$$^DBSTBL(tbl,$S(vptr:V,1:""),typ,min,max,.VPT,.VPB,hlp)
	;
	I 'vptr,X'=V,X'="" S vptr=$L(X)		; FRS Patch
	;
	I VPT D DSP(VPT)
	I $G(ER) D PNTRM S %fkey="ESC"
	I %fkey="ESC" S X=V,%fkey=""
	I %fkey'="" S %fkey="ENT"
	Q X
	;
NOTBL	W $$MSG^%TRMVT($$^MSG("1659")) S %fkey="" Q V
	;
PRN	N X D ^DBSCRT8D S %fkey="" Q
	;
	;----------------------------------------------------------------------
DSP(VPT)	; Refresh the screen from line VPT
	;----------------------------------------------------------------------
	;
	N V
	D OPEN
	S VPT=$G(VPT) I 'VPT Q
	I VPT=24 Q
	I $D(OLNTB),VPT>(OLNTB\1000) W $$CLR^%TRMVT(VPT) Q
	D VDA^@PGM
	I $G(vtblrtn)'="" X vtblrtn Q
	D ^DBSPNT(VPT)
	Q
	;
	;----------------------------------------------------------------------
REPLACE	; Replace / With
	;----------------------------------------------------------------------
	;
	N A,B,C,OS,RS
	;
	W $$SCRAWOFF^%TRMVT
	;
R1	;
	W $$CUP,$$VIDBLK^%TRMVT,X,$$VIDINC^%TRMVT
	W $$BTM^%TRMVT,$$^MSG("2372")	; "Replace: "
	R OS D ZB^%ZREAD I OS=""!(%fkey="ESC") S %fkey="" G R3
	;
	I OS["..." S A=$P(OS,"...",1),B=$P(OS,"...",2) I $E(B,1)'="." S C=$F(X,A),D=$S(B="":999,1:$F(X,B,C)) I C>0,D>1 S OS=$E(X,C-$L(A),D-1) I D=999 S X=$E(X,1,C-1-$L(A)),OS="END"
	I OS="END"!(OS="end") G R2
	;
	I $F(X,OS)=0 W $C(7) G R1
	W $$CUP,$P(X,OS,1),$$VIDREV^%TRMVT,OS,$$VIDINC^%TRMVT,$P(X,OS,2,99)
R2	W $$BTM^%TRMVT,$$^MSG("2977")	; "With: "
	R RS#rsiz-$L(X)+$L(OS) D ZB^%ZREAD I %fkey="ESC" S %fkey="" G R3
	S X=$P(X,OS,1)_RS_$P(X,OS,2,200)
R3	W $$SCRAWON^%TRMVT,$$BTM^%TRMVT Q
	;
	;
UL(L)	Q $E("_________________________________________________________________________________",1,L)
	;
CCHR(X)	Q $TR(X,$C(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31),"")
	;
OPEN	D TERM^%ZUSE(0,"ECHO/IMAGE/ESCAPE/TERMINATOR=$C(3,9,11,13,16,21,23,127)/TTSYNC/WIDTH=81")
	W $$INSMOFF^%TRMVT			; Turn off insert mode
	Q
CLOSE	D TERM^%ZUSE(0,"ECHO/ESCAPE/NOIMAGE") Q
	;
	;----------------------------------------------------------------------
ZBINIT	; Initialize use parameters for data entry, initialize zbxxx
	;----------------------------------------------------------------------
	;
	D OPEN
	I $D(%fkey)>1 D ZBTERM Q
	;
	I '$D(%KP) S %KP=$$KBL^%TRMVT
	;
	F I=2:2 S X=$P(%KP,"|",I) Q:X=""  S %fkey(X)=$P(%KP,"|",I-1)
	;
ZBTERM	;
	S %fkey(3)="BRK"
	S zbterm=",ENT,CUU,CUD,END,ESC"			; Standard terminators
	I $G(%REPEAT) S zbterm=zbterm_",PUP,PDN" Q	; Allow Prev/Next key
	I $D(%PAGE),%PG<%PAGE S zbterm=zbterm_",PDN"	; in repeat region
	I %PG>1 S zbterm=zbterm_",PUP"
	;
	I $D(RM) D PNTRM
	Q
	;
SECRET	;
	S vptr=1
	D TERM^%ZUSE(0,"NOECHO/NOIMAGE/TERMINATOR=$C(3,9,13,16,21,23)")
	R X D ZB^%ZREAD
	D OPEN
	;
	I zbterm[%fkey Q
	;
	I %fkey="CLR" G secd
	I %fkey="REM" G secd
	I %fkey="HLP" D HLP G secd
	I %fkey="MNU" S X=$$MNU(X) G secd
	I %fkey="PRN" D PRN G secd
	I %fkey="DSP" D DSP(1) W $$CUP G secd
	;;I %fkey="SES" D:$$SES(hlp) DSP(1) G secd
	I %fkey="BRK" D
	.	N VBRK
	.	S VBRK=$$^%ZBREAK
	.	I +VBRK D CLOSE X $P(VBRK,"|",2)
	;
	Do  
	.	I %fkey'="",$D(cmmd(%fkey)) DO  Q
	.	.	N code
	.	.	S code=cmmd(%fkey),%fkey="ENT"
	.	.	X code
	;
	W $C(7)
	;
secd	I $D(RM) D PNTRM ;			Display any messages
	W $$CUP
	G SECRET
	;
VDSP()	I "UN$LDC"[typ,'sec Q 2
	Q 1
	;
CUP()	Q vcsi_py_";"_px_"H"
CS()	Q $C(27)_"7"
CR()	Q $C(27)_"8"
	;
REMAP(fkey,nkey,code)	; Replace Key keyname with code
	;
	N zb
	S zb=$P($P($$KBL^%TRMVT,fkey_"|",2),"|",1)
	;
	I $G(code)="" DO  Q 
	.	S %fkey(zb)=fkey 
	.	I $G(nkey)'="" K cmmd(nkey) 
	;
	S %fkey(zb)=nkey,cmmd(nkey)=code
	Q
	;
	;----------------------------------------------------------------------
PROCESS	; Process function key 
	;----------------------------------------------------------------------
	;
	I %fkey="INS" D insert(vrec) Q			; <Insert> key
	I %fkey="REM",dft="",X="" D remove(vrec) Q	; <Remove> blank record
	;
	I %fkey="CUU" S NI=$$CUU,vexit=$$VEXIT(NI),%fkey="ENT" Q	; Cursor up one field
	I %fkey="CUD" D CUD S %fkey="ENT" Q		; Cursor down
	I %fkey="TOP" D  Q				; <PF1><Prev>
	.	I 'voff!('%REPEAT) Q			; Not valid option
	.	S voff=0,vrec=1 D display Q  		; Display first page
	;
	I %fkey="BOT",$G(%REPEAT) D  Q				; <PF1><Next>
	.	S voff=$O(vbuf(vfrm,""),-1)+%REPEAT-1\%REPEAT-1*%REPEAT
	.	I voff D display Q			; Display last page
	;
	I %fkey="PDN",$G(%REPEAT) D  Q				; <Next> page	
	.	I %O>1,'$D(vbuf(vfrm,voff+%REPEAT+1)) Q	; On the last page now
	.       S vrec=vrec+%REPEAT                     ; New record number 
	.       S voff=voff+%REPEAT-voff1          ; Display data
	.	I vrec#%REPEAT>0 S voff=vrec\%REPEAT*%REPEAT
	.	D display
	;
	I %fkey="PUP",$g(%REPEAT) D  Q			; <Prev> page
	.	I $D(vNOPREV) S ER=1,RM="" Q    ;   XUS 3/3/95$$PUPERR^DBSVER Q  ; Not allowed (NEG)
	.	I vrec#%REPEAT>0 D  I 1
	..		S vrec=vrec-%REPEAT		; New record number
	..		I vrec<1 s vrec=1   		; Top of display
	..		S voff=vrec\%REPEAT*%REPEAT
	.	E  D
	..		N z
	..		I voff=0 Q			; On the firat page
	..		s z=voff-%REPEAT-voff1		; Calc offset
	..		I z<0 Q				; Still on the first page
	..		S voff=z
	..		S vrec=vrec-%REPEAT		; New record number
	.	D display				; Display data
	;
	I %fkey="ESC" S NI=%MAX,vexit=$$VEXIT(%MAX+1)	; <F11> exit key
	;
	I %fkey="END"!(%fkey="PUP")!(%fkey="PDN") S vexit=$$VEXIT(%MAX+1)		; <DO> key
	I %fkey="CUB" S NI=NI-2				; Previous field
	;
	S %fkey="ENT"					; Default for <ENT>
	Q
	;----------------------------------------------------------------------
insert(vrec)	; Insert a blank record at location vrec 
	;----------------------------------------------------------------------
	N i,j,di
	I vi(1)'?1N1"*" S NI=NI-1,%fkey="ENT" Q		; Not on the key field
	S i=$O(vbuf(vfrm,""),-1)				; Find last record
	F j=i:-1:vrec S di="" F  S di=$O(vbuf(vfrm,j,di)) Q:di=""  D
	.	S vbuf(vfrm,j+1,di)=vbuf(vfrm,j,di)	; Push array down
	.	I $D(vhis(vfrm,j,di)) S vhis(vfrm,j+1,di)=vhis(vfrm,j,di)
	.	I j=vrec S vbuf(vfrm,j,di)="" k vhis(vfrm,j,di)	; Clear current record
	W $$LININS^%TRMVT(1)
	D dsp($A(vhdr)_";"_$A(vhdr))
	S dft="",X="",V="",vokeys=""			; Remove key information
	;;D keys
	Q
	;----------------------------------------------------------------------
remove(vrec)	; Remove record at location vrec 
	;----------------------------------------------------------------------
	N i,j,di
	S i=$O(vbuf(vfrm,""),-1)				; Find last record
	F j=vrec:1:i S di="" F  S di=$O(vbuf(vfrm,j,di)) Q:di=""  D
	.	I j=i K vbuf(vfrm,j,di),vhis(vfrm,j,di) Q	; Clear current record
	.	I $D(vbuf(vfrm,j+1,di)) S vbuf(vfrm,j,di)=vbuf(vfrm,j+1,di)		; Push array down
	.	I $D(vhis(vfrm,j+1,di)) S vhis(vfrm,j,di)=vhis(vfrm,j+1,di)
	;;;W $$LINDEL^%TRMVT(1)
	D dsp(vlast)
	Q
	;----------------------------------------------------------------------
display	; Display full page 
	;----------------------------------------------------------------------
	D VDAPNT^@PGM
	S %fkey="",voff1=0
	D showkey
	I '$D(NI) Q          ;1/29/97 
	I NI>$G(%REPEAT) Q   ;1/29/97
	S V=$$RESET^DBSFRMCS(NI,.vbuf,"",.vhdr,.vsiz,.vtyp),X=V ;1/29/97 
	Q
	;----------------------------------------------------------------------
dsp(ln)	; Display region 
	;----------------------------------------------------------------------
	D VPR^@PGM,VDA^@PGM				; Reset VO buffer
	I ln'[";" S ln=ln_";"_vlast
	D ^DBSPNT(ln,2)					; Display Data section
	S %fkey=""					; Cancel key name
	S vgoto=$E(vgoto,2,999)
	Q	
	;----------------------------------------------------------------------
showkey	; Show function key map
	;----------------------------------------------------------------------
	I '$G(%REPEAT) Q				; Not valid option
	N k
	S k(1)="INS",k(2)="REM"			; Status line
	S k(3)="PUP",k(4)="PDN" ; k(5)="TOP",k(6)="BOT"
	W $$SHOWKEY^%TRMVT(.k,"",1,73)
	Q
	;----------------------------------------------------------------------
CUU()	N X
	I vrec>1,$A(vhdr)=vone D  Q NI-1	; Display top line
	.	W $$LININS^%TRMVT(vblk)		; Insert new block
	.	S voff=voff-1,voff1=voff1-1	; Get previous record
	.	I vblk=1 D dsp(vone_";"_vone) Q  
	.	D dsp(vone_";"_(vone+vblk-1))	; Display new block
	;
	I vrec,$G(%REPEAT) S vexit=0 Q NI-vcnt-1
	I $L(vgoto)=1 Q NI-1
	S X=$A(vgoto,2)-1,vgoto=$E(vgoto,3,$L(vgoto)),vexit=0
	Q X
	;----------------------------------------------------------------------
CUD	; Go to first field or same column (repeat region) of the next line
	;----------------------------------------------------------------------
	;
	I NI=0 Q				; .GOTO. command on first prompt
	I '$D(%TAB) S NI=999 Q			; .PROTECT. ALL command on first prompt
	;					;
	I '$G(%REPEAT) Q			; Same as <RETURN> key
	;					; *** 02/04/97
	I $P(%TAB,"|",2)+%REPEAT<22,(NI+$P(%TAB,"|",3)'<%MAX) S NI=%MAX Q
	I $A(vhdr)<$G(vrep) Q			; Outside the repeat region
	I $A(vhdr)+vblk'>vlast S NI=NI+vcnt-1 Q	 ; Move down one block
	I vblk>1 w $$CUD^%TRMVT(1)
	F i=1:1:vblk W !			; Move up one block
	S voff=voff+1,voff1=voff1+1		; Update display buffer pointer
	I $A(vhdr)=vlast S NI=NI-1		; Stay on the same line (last)
	I vblk=1 D dsp(vlast) Q			; Display last line
	D dsp(vlast-1_";"_vlast)		; Display new block
	S NI=NI-1				; *** 05/05/95 BC
	Q
	;----------------------------------------------------------------------
INQ	; Called by screen run-time routine V01Snnn when %O=2 or 3
	;----------------------------------------------------------------------
	N opt,vrec,voff,voff1,vfrm,vdelmenu,vinqmenu,x,zln
	S vdelmenu=159,vinqmenu=157
	S vrec=1,voff=0,voff1=0
	S x=$O(%TAB(""),-1),zln=23-$A(%TAB(x)),x=$P(%TAB(x),"|",3)
	S vfrm=$E($P(x,"]",1),2,99)
	I $G(%REPEAT) I $O(vbuf(vfrm,""),-1)>%REPEAT,%REPEAT>zln S vdelmenu=160,vinqmenu=162
	I %O=2 F  D INQ1 Q:'opt
	I %O=3 F  D DEL1 Q:opt<1
	I %O=3,opt<0 S VFMQ="D"			; Delete action
	Q
INQ1	; 
	S opt=$$^DBSMBAR(vinqmenu)		; Next,Prev,Top,Quit
	I 'opt Q				; <F11>	
	I opt=1 S opt=0 Q			; Quit
	I opt=2 D PRN Q
	;
	I opt=3 S %fkey="PDN"			; Next page
	I opt=4 S %fkey="PUP"			; Prev page
	I opt=5 S %fkey="TOP"			; First page
	I opt=6 S %fkey="BOT"			; Last page
	D PROCESS				; Display data
	Q
DEL1	;
	S opt=$$^DBSMBAR(vdelmenu)		; Next,Prev,Top,Quit
	I 'opt Q				; <F11>	
	I opt=1 S opt=0 Q			; Quit
	I opt=2 S opt=-1 Q			; Delete
	I opt=3 D PRN Q				; Print screen
	I opt=4 S %fkey="PDN"			; Next page
	I opt=5 S %fkey="PUP"			; Prev page
	I opt=6 S %fkey="TOP"			; First page
	I opt=7 S %fkey="BOT"			; Last page
	D PROCESS				; Display data
	Q
	;----------------------------------------------------------------------
	;
VEXIT(XNI)	Q (XNI)_"|"_%fkey
	;
ERROR	Q
