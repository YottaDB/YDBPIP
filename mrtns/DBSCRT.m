DBSCRT(dft,len,typ,tbl,hlp,dec,min,max,py,px,sec,recsiz)	; 
	;;Copyright(c)2000 Sanchez Computer Associates, Inc.  All Rights Reserved - 02/02/00 11:54:55 - GRAY
	;     ORIG:  Frank R. Sanchez (2497)
	;     DESC:  Input manager for keyboard entry of string data.
	;
	;   PARAMS:  dft - The default input string, expected to be displayed
	;                  with the cursor positioned at the BOF
	;            len - The length of the field
	;            typ - The DATA-QWIK data type (TUFL$NDC)
	;            tbl - Lookup table [TABLE]COLUMN or ^GREF
	;            hlp - HELP file reference [TABLE]COLUMN
	;            dec - Decimal precision
	;            min - minimum value (used for table lookup only)
	;            max - maximum value (used for table lookup only)
	;             px - The row coordinate beginning of field
	;             py - The column coordinate of beginning of field
	;            sec - Field is in secret mode
	;         recsiz - Field internal size (maximum length) *** - BC - 10/21/93
	;
	; EXTERNAL - The following data structures are needed to service
	;            external calls to ^DBSCRT.
	;
	;  %fkey(ZB)=%fkey - function key array, can be initiialized by
	;                  calling ZBINIT^DBSCRT.
	;
	;	   OLNTB - Used by table lookup & message display to
	;                  locate the bottom of window (Y*1000+X)
	;
	;           VPGM - (OPTIONAL) The callback program VREPRNT^@VPGM
	;                  for the screen refresh function.
	;
	;---- Revision History ------------------------------------------------
	; 07/14/06 - RussellDS - CR22121
	;	     Replaced $A references with $$BSASCII^SQLUTL to ensure
	;	     Unicode compliance.
	;
	; 12/08/04 - RussellDS - CR13258
	;	     Remove obsolete parameter from call to ^DBSTBL.
	;
	; 2/2/2000 - GRAY - 32507
	;	     Removed code no longer needed due to the Elimination
	;	     of Teller/Branch Character Interface.
	;
	; 08/11/97 - Betty Ni - 25653
	;            Replaced follows operator "]" with a "]]". 
	;
	; 12/12/95 - SPIER - arq19651
	;            Added vptr to items which must be defined before call
	;	     to DSPPNT. This was not defined in qa since sql release
	;            is not in that version.
	;
	; 12/08/95 - WATSOND - 20404
	;            Modified PNTM to new the variable vlen.  This corrects
	;            a problem where field lenght 1 exceeds when running SCATAPE
	;
	; 12/5/95 - SPIER - arq19651
	;	     In DSP section, do not call DSPLEN if ni is not defined.
	;            In DSPLEN section Added conditional setting of NI to account
	;	     for a situation where %TAB(NI) does not exist, e.g. crtl w
	;	     while on menu prompt. A second test after the reseting
	;	     of NI will leave vptr at its current setting if NI is not
	;	     part of the %TAB array.
	;
	; 11/09/95 - SPIER - 19580
	;            Reset vptr in DSP section when vptr indicates that
	;	     we are off the screen(overflow). DSP always refreshs
	;	     with the first 80 or 132 characters of the screen.
	;	     New label DSPLEN which determines the display size of
	;	     the data being displayed.
	;
	; 02/02/95 - Shaodong Tony Xu - ARQ 290
	;            Modify the PF4 key to create correct UX array.
	;
	; 01/13/95 - Shaodong Tony Xu - ARQ 222
	;            Modify the PF3 Key section to let it work.
	;
	; 10/27/94 - Rich Jefferson
	;	     
	;	     Changed cmmd array to be %cmmd array within REMAP
	;	     subroutine
	;
	;	     Removed hardcoded %fkey TST and TTS
	;
	; 05/23/94 - Dan Russell
	;
	;            Modify handling of interrupts in SECRET section.  Works
	;            with ^%ZBREAK to pass back executable string if break
	;            is allowed.
	;
	;            Also changed DQnnn messages to new nnn messages.
	;
	; 01/26/94 - Allan Mattson - 11702
	;
	;            Modified strip control characters from input.
	;
	; 10/27/93 - Bob Chiang - I18N#7
	;
	;            Modified return message handling with a call to extrinsic
	;            function $$^MSG(msgid,p1,p2...) for I18N development
	;            (phrase independence).
	;
	; 10/21/93 - Bob Chiang - I18N
	;
	;            Modified to replace vofl array (field overflow indicator)
	;	     with a new parameter "recsiz" (argument # 12).
	;
	; 10/10/93 - Frank Prendergast - I18N#18
	;
	; 	     Change call to DBSMBAR from DBSMENU
	;	     Text moved to ^STBL("MBAR")
	;
	; 04/23/93 - Bob Chiang
	;
	;            Modified to correct system loop problem when use PF4
	;            key on a field that is not in the repeat region.
	;
	; 02/09/93 - Bob Chiang
	;
	;            Modified to protect system variable %JRNL at routine
	;               section MNU+3.
	;
	;-----------------------------------------------------------------------
	;   I18N=QUIT : Excluded From I18N Standards 
	;
	I '$D(%TO) N %TO S %TO=$$TODFT^%ZREAD
	;
	S vptr=0,X=dft ;			Initial String Pointer
	S recsiz=$G(recsiz) I 'recsiz S recsiz=len	; *** - BC - Replaced vofl() reference 10/21/93
	;
read	;
	W $$CUP
	I $G(sec) D SECRET G term
	;
	S X=$$TERM^%ZREAD(X,recsiz,.vptr,"_",%TO,0,len,"$N"[typ)
	I X?.E1C.E S X=$$CCHR(X)
	I %fkey="" G read
	;
	I %fkey="REM",typ="L" S X=dft W X G read	; Don't allow REMOVE
	I %fkey="REM" S %fkey="ENT"
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
	I %fkey="KYB" D KYB G term ;		Keyboard Emulation
	D
	.	I %fkey="DUP" S X=$$DUP(X) Q
	.	I %fkey="SEL" S X=$$TBL(X) Q
	.	I %fkey="FND" S X=$$TBL(X) Q
	.	I %fkey="HLP" D HLP Q
	.	I %fkey="BUF" S X=$$BUF(X) Q
	.	I %fkey="MNU" S X=$$MNU(X) Q
	.	I %fkey="PRN" D PRN Q
	.	I %fkey="DSP" D DSP(1) S %fkey="" Q
	.	; I %fkey="SES" D:$$SES(hlp) DSP(1) Q
	.	I %fkey="RCL" S X=$$RECALL^DBSTSINP(X) Q
	.	I %fkey="BRK" D
	..		N VBRK
	..		S VBRK=$$^%ZBREAK
	..		I +VBRK D CLOSE X $P(VBRK,"|",2)
	.	I %fkey'="",$D(%cmmd(%fkey)) D  Q
	..		N code
	..		S code=%cmmd(%fkey),%fkey="ENT"
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
	;
	I X=dft Q
	I '$D(vdft(NI)) S vdft(NI)=X_"|"_dft Q
	I dft'="" F  Q:$P(vdft(NI),"|",1)'=dft  S vdft(NI)=$P(vdft(NI),"|",2,99)
	S vdft(NI)=X_"|"_dft_"|"_vdft(NI)
	Q
	;
	;----------------------------------------------------------------------
DUP(dft)	; Copy data from previous line or field
	;----------------------------------------------------------------------
	;
	N savefid,savesn				;  *** XUS 2/2/95
	S savefid=$G(vfid),savesn=$G(vsn)
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
	D RESET^DBSCRT8(N)
	I savefid'="" S vfid=savefid
	I savesn'="" S vsn=savesn
	Q V
	;
	;----------------------------------------------------------------------
MNU(OX)	; Select and process PF3 option
	;----------------------------------------------------------------------
	;
	N I,MASK,OP,%JRNL					; RC 02/09/93
	F I=1,2,5,6 S MASK(I)=""			; *** XUS 02/12/95
	I OX'="" S OP(1)="S X=$$^SCACLPBD(NI,.%TAB,.VO,2)" K MASK(1)    ;  *** XUS  02/12/95   
	I $D(^TMP(0,$J,"CLPBRD")) S OP(2)="S X=$$^SCACLPBD(NI,.%TAB,.VO,3)" K MASK(2)
	S OP(3)="S X=$$^SCACLPBD(NI,.%TAB,.VO,1)"
	S OP(4)="D FUNCTION^DBSCALC"
	I OX="" S OP(5)="D EHLP^DBSCRT(hlp)" K MASK(5)
	I OX="",tbl="" S OP(6)="D ETBL^DBSCRT(tbl)" K MASK(6)
	E  S OP(6)="D REPLACE^DBSCRT" K MASK(6)     ;  *** XUS 02/12/95
	;
	S OP=$$^DBSMBAR(5,"",.MASK) I 'OP S %fkey="" Q OX ;	No option selected
	S X=OX X OP(OP)
	;
	D OPEN ;					Reset terminal
	S vdsp=$$VDSP
	I X="" S X=OX,%fkey=""
	E  S %fkey="ENT" I $L(X)>recsiz S X=$E(X,1,recsiz)
	Q X
	;
	;----------------------------------------------------------------------
SES(ref)	; Invoke linked function (hyperfunction)
	;----------------------------------------------------------------------
	;
	N status
	;
	S %fkey=""
	S status=$$ATTACH^DBSSPAWN(ref)
	I status'=1 W $$MSG^%TRMVT(status) Q 0
	Q 1
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
BUF(OX)	; Recall previous input(s)
	;----------------------------------------------------------------------
	;
	S %fkey=""
	I '$D(vdft(NI)) S RM=$$^MSG("1902") Q OX
	I OX="",$TR(vdft(NI),"|","")="" Q OX
	F  S X=$P(vdft(NI),"|",1),vdft(NI)=$P(vdft(NI),"|",2,99) Q:X'=OX
	I $P(vdft(NI),"|",$L(vdft(NI),"|")-1)'=OX S vdft(NI)=vdft(NI)_"|"_OX
	S vptr=1 Q X
	Q
	;
	;----------------------------------------------------------------------
DSPVDFT(NI)	; Display the vdft(array) from position NI
	;----------------------------------------------------------------------
	;
	N X
	I '$D(NI) S NI=""
	F  S NI=$O(vdft(NI)) Q:NI=""  S X=$$TAB^DBSCRT8(NI) W $$PNTFMT($P(vdft(NI),"|",1),$$BSASCII^SQLUTL(X,3),$E(X,6),$$BSASCII^SQLUTL(X,1)+1,$$BSASCII^SQLUTL(X,2)+1)
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
	N DL,DY,vlen       ;dmw arq20404 12/8/95
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
	I DY<1000,$D(%TAB(DY)) D:RM="" DSPNI(DY) I RM]]"" S X2=$$TAB^DBSCRT8(DY) D P0XY
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
	S DY=$$BSASCII^SQLUTL(X2,1)*1000+$$BSASCII^SQLUTL(X2,2),DL=$$BSASCII^SQLUTL(X2,3)
	Q
	;
	;----------------------------------------------------------------------
P3	; Logical data item position for DYDX (consider .PROTECT.)
	;----------------------------------------------------------------------
	;
	N I
	S I=""
	F  S I=$O(%TAB(I)) Q:I=""  S Z=$P(%TAB(I),"|",3) S:$E(Z,1,2)="[]" Z="["_DFID_"]"_$E(Z,3,99) I Z[DY S DY=I Q
	Q
	;
	;----------------------------------------------------------------------
DSPNI(NI)	; Display data at to %TAB(NI)  RM="|tab #"
	;----------------------------------------------------------------------
	;
	N I,X,V,vhdr,DATA,E5,E67,E8,E9,E12
	D RESET^DBSCRT8(NI) W $$PNTFMT(V,E67,E8,$$BSASCII^SQLUTL(vhdr,1),$$BSASCII^SQLUTL(vhdr,2)) Q
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
	S E67=recsiz,VPT=OLNTB\1000+1,VPB=23
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
	I $G(NI),$G(vptr) D
	.	N cx				;11/09/95   mas
	.	S cx=$$DSPLEN(NI)		;11/09/95   mas
	.	I vptr>cx S vptr=cx		;11/09/95   mas
	Q
	;
	;----------------------------------------------------------------------
DSPLEN(NI)	;Return length of data display 
	;----------------------------------------------------------------------
	I '$D(%TAB(NI)) N NI S NI=$$BSASCII^SQLUTL($g(vgoto),1)	;12/05/95   mas
	I '$D(%TAB(NI)) Q ""
	Q $$BSASCII^SQLUTL(%TAB(NI),3)			;11/09/95   mas
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
	R RS#recsiz-$L(X)+$L(OS) D ZB^%ZREAD I %fkey="ESC" S %fkey="" G R3
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
	S zbterm=",ENT,CUU,CUD,END,ESC"
	I $D(%PAGE),%PG<%PAGE S zbterm=zbterm_",PDN"
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
	; I %fkey="SES" D:$$SES(hlp) DSP(1) G secd
	I %fkey="BRK" D
	.	N VBRK
	.	S VBRK=$$^%ZBREAK
	.	I +VBRK D CLOSE X $P(VBRK,"|",2)
	;
	Do  
	.	I %fkey'="",$D(%cmmd(%fkey)) DO  Q
	.	.	N code
	.	.	S code=%cmmd(%fkey),%fkey="ENT"
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
	.	I $G(nkey)'="" K %cmmd(nkey) 
	;
	S %fkey(zb)=nkey,%cmmd(nkey)=code
	Q
