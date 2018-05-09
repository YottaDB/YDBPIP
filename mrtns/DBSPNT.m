DBSPNT(ORIGIN,OPTION,EXTANT)	;Private;DATA-QWIK screen print driver
	;;Copyright(c)1998 Sanchez Computer Associates, Inc.  All Rights Reserved - 09/21/98 16:54:17 - MATTSON
	; ORIG:  Frank R. Sanchez (2497) - 07/04/89
	;
	; ARGUMENTS:
	;     . ORIGIN   Starting line number (DY;DX)		/TYP=T/NOREQ/MECH=VAL
	;     . OPTION   0=all 1=prompt only  2=data only	/TYP=N/NOREQ/MECH=VAL
	;     . EXTANT   $Y and $X offset (10,30)		/TYP=T/NOREQ/MECH=VAL
	;
	; INPUTS:
	;     . VO     v1|2|3|4|5  v1 = Total # of items
	;                          v2 = Starting # for VDA section
	;			   v3 = Top Line of Window (Origin)
	;			   v4 = Number of lines in Window (Extant)
	;                          v5 = %FRAME Option (origin offset)
	;
	;     . VO(0)  v6|v7       v6 = init screen option
	;                               NULL (all) NN (from line NN) NN:MM
	;
	;                          v7 = init screen attributes
	;                               (clear screen,132 column mode ...)
	;
	;     . VO(seq)            Item control block
	;
	;           FIELD CONTROL BLOCK DEFINITION
	;          ================================
	;
	;     Byte 1    CY     Y cursor address    $C(1-255)
	;     Byte 2    CX     X cursor address    $C(1-255)
	;     Byte 3    LN     Field length        $C(1-255)
	;     Byte 4    VO     Video options       $C(0-255)
	;
	;                      bit 1   -  Reverse video on ( VO#2 )
	;                      bit 2   -  Highlight on     ( VO\2#2 )
	;                      bit 3   -  Underscore on    ( VO\4#2 )
	;                      bit 4   -  Blinking on      ( VO\8#2 )
	;
	;     Byte 5    CA     Character size attributes $C(12 or 24)
	;
	;     Byte 10   SM     Secret mode
	;     Byte 11   GT     Graphics toggle
	;     Byte 12   PR     Field protection flag
	;
	;                      0 - no restriction
	;                      1 - read only (prompts)
	;                      2 - read only ( data item protection )
	;                      3 - full restriction (data item protection)
	;
	;                      This flag is turned on by the data item 
	;                      protection logic or by the screen .PROTECT.
	;                      macro command.
	;
	;     Byte 13   TY     field format type ( TUFLN$DC )
	;     Byte 14-264      Field value
	;
	; EXAMPLES
	;
	;	D ^DBSPNT()		; Called by the DQ form run-time routine to
	;				; display the full screen.
	;       D ^DBSPNT(10)		; Called by the table lookup utility to
	;				; repaint partial screen.
	;       D ^DBSPNT(0,2)		; Called by the .DISPLAY. ALL macro command
	;				; to redisply the screen data (not prompts).
	;
	;---- Revision History ------------------------------------------------
	; 09/20/98 - Allan Mattson - 25662
	;            Removed calls to DBSPNTH (HTML) and DBSPNTPB (Power
	;            Builder).
	;
	;            Deleted older revision history.
	;
	; 08/12/97 - Betty Ni - 25653
        ;            Replaced follows operator "]" with a "]]".
	;
	; 02/14/97 - JIAQ - 23857
	;            Retrofit 23196 to v5.3:	
	;----------------------------------------------------------------------
	;
	I +$P(VO,"|",5)'=0 D TERMSET^SCADRV
	I $G(%OPMODE)'="" D PARSE Q
	I $G(%O)>3 D LP Q
	D VT
	Q
	;
VT	; VT200 display
	;
	N D,GT,V,V99,I,X,CSI,cy,cx,cl,undl
	; 
        S CSI=$$CSI^%TRMVT
        I $G(CRT),'$D(OVR) S undl=$$CBLK(80)
        E  S undl=$$EBLK(80)
	S OPTION=$G(OPTION)+0
	S V99=1,(GT,V)=""
	;
	I $G(ORIGIN)>1 D VTWINDOW,NORMAL Q	; Display a window region
	;
	I OPTION=0 D VTFORM			; Initialize screen
	I OPTION=2 D CLRDAT			; Clear current data from screen
	F I=V99:1:+VO S X=VO(I) D DSPOBJ	; Display objects
	;
NORMAL	; Set All Terminal Attributes back to normal
    	;
	I GT W $$GROFF^%TRMVT ;			Toggle graphics off
	I ($A(V)!$A(V,2)) W $$VIDOFF^%TRMVT ;	Reset video attributes
	Q
	;
DSPOBJ	; Display object
	;
	S D=$E(X,14,999) I D="",%O=2 Q			; Null field
	S cy=$A(X),cx=$A(X,2),cl=$A(X,3)		; Cursor Position
	I $E(X,12)=3 W CSI,cy,";",cx,"H" D VBLK($A(X,3)) Q
	;
	; Display attributes
	I V'=$E(X,4,11) S V=$E(X,4,11) D VIDEO($A(V,1),$A(V,2),$E(X,11))
	I D="" W CSI,cy,";",cx,"H",$E(undl,1,cl) Q
	;
	I $L(D)>cl,cl W CSI,cy,";",cx,"H",$E(D,1,cl-1),$C(14,96,15) Q
	I "$N"[$E(X,13) W CSI,cy,";",cx+cl-$L(D),"H",D Q
	W CSI,cy,";",cx,"H",D
	Q
	;
VIDEO(V1,V2,gt)	; Display Video attributes
	;
	I gt'=GT S GT=gt W $C(15-GT) ; Graphics toggle
	;
	I V2 W $$CHRATT
	;
	I '$D(V(V1)) S V(V1)=$$VIDOOE^%TRMVT(V1)
	W V(V1)
	Q
	;
CHRATT()	; Character size attributes
	;
	I V2=12 Q $C(27)_"#6"
	I V2=24 Q $C(27)_"#3"
	I V2=36 Q $C(27)_"#4"
	Q ""
	;
CLRDAT	; Clear existing data from the screen ( ALL - OPTION=2)
	;
	S V99=$P(VO,"|",2)
	;
	F I=V99:1:+VO D
	.	S X=VO(I),D=$E(X,14,999) I D="",%O<2 Q  ;	Underline
	.	I $L(D)+8>$A(X,3) S VO(I)=VO(I)_$J("",$A(X,3)-$L(D)) Q
	.	W CSI,$A(X),";",$A(X,2),"H",$$CLF($A(X,3))
	Q
	;
VTFORM	; Set screen attributes (clear screen, 80/132 column mode)
	;
	U 0
	I '$D(VO(0)) Q
	I $P(VO(0),"|",2) D
	.	S zcol132=1
	.	W $$SCR132^%TRMVT
	.	D TERM^%ZUSE(0,"WIDTH=133")
	;
	E  I $G(zcol132) k zcol132 W $$SCR80^%TRMVT D TERM^%ZUSE(0,"WIDTH=81")
	I $P(VO(0),"|",1)="" W $$CLEAR^%TRMVT Q			; Clear screen
	I $P($P(VO(0),"|",1),";",2)="" W $$CLR^%TRMVT(+VO(0))	; Clear window
	D FRAME
	Q
	;
VTWINDOW	; Display screen from origin to extant
	;
	N EVPR,EVDA,I,LX,TY,SVDA,SVPE
	;
	S TY=+ORIGIN,LX=$P(ORIGIN,";",2) I 'LX S LX=24
	W $$CLR^%TRMVT(TY,LX)
	D FRAME
	;
	S EVDA=+VO,SVDA=$P(VO,"|",2),SVPR=1,EVPR=SVDA-1
	I VO(EVPR)="" S EVPR=EVPR-1    ;*** XUS
	I SVDA>EVDA S SVDA=EVDA
	;
	S I=$$FINDOBJ(TY,SVPR,EVPR) ; Find starting prompt
	I I F I=I:1:EVPR S X=VO(I) Q:$A(X)>LX  D DSPOBJ ; Display prompts
	S I=$$FINDOBJ(TY,SVDA,EVDA)
	I I F I=I:1:EVDA S X=VO(I) I $A(X)'<TY,$A(X)'>LX D DSPOBJ ; Display data
	Q
	;
FINDOBJ(CY,FROM,TO)	; Find the 1'st occurrance of CY
	;
	I $A(VO(FROM))'<CY Q FROM  ; 1'st object beyond range
   	I $A(VO(TO))<CY Q 0 ; Last object doesn't reach CY
	F FROM=FROM:1:TO I $A(VO(FROM))'<CY Q
	I  Q FROM
	Q 0
	;
	;---------------------------------------------------------------------
LP	; Line printer or RMS file (CTRL/P option)
	;---------------------------------------------------------------------
	;
	N VVO,L,X,I,NVPR,NVDA,EVPR,EVDA,ZVDA,OY
	N vflg,vframe,vorigin,vextant,vln,vtop
	;						; *** BC - 08/30/94
	S vframe=$P(VO,"|",5)				; Frame option
	S vorigin=$P(VO,"|",3)				; Starting line
	S vextant=$P(VO,"|",4)				; Extant
	S vtop=vframe+vorigin				; Top line of the frame
	I vframe S $P(vln,"-",79)=""			; frame border
	S vflg=0
	S VVO=$G(%O)
	I '$D(%PAGE) S %PAGE=1
	;
	I '$D(IO) D ^SCAIO I VVO=5 S %O=5
	U IO I '$D(%NOFF) W #
	;
	I %O=5 S X=$L($G(VSNAME)),L=78-$L($G(VSID))-3
	I  W !,$J("",L-(X*2)\2),$G(VSID)," - " F I=1:1:X W $E(VSNAME,I)," "
	I  W !!!
	;
	S NVPR=0,NVDA=$P(VO,"|",2)-1,EVPR=NVDA,EVDA=+VO,ZVDA=NVDA
	S OY=0
	;
	D LPNO
	;
	I '$D(%PAGE) X KVAR
	;
	;I '$D(%PG) N %PG S %PG=1			; *** 02/24/95 BC
	Q:'$D(%PG)!'$D(%PAGE)
	I %PG<%PAGE S VFMQ="C" Q
	;
	S VFMQ="Q"
	;
	I '$D(%NOCLOSE) S PN=-1 D @IOHDG
	Q
	;
LPNO	; Get the next object
	;
	S N=$$NEXTOBJ I 'N D  W ! Q			; End
	.	I 'vframe Q
	.	I vflg W ?79,"|"			; Finish last line
	.	F I=1:1:vextant-1-CY W !,"|",?79,"|"
	.	W !,"+",vln,"+"				; Complete frame
	D LPPNT G LPNO
	;----------------------------------------------------------------------
LPPNT	;
	S X=VO(N),CY=$A(X)-1,CX=$A(X,2),D=$E(X,14,999)
	I D="",%O=4 Q
	;
	; Convert Graphic to Text data
	;
	I $E(X,11) S D=$$GRPHMAP(D) ; Convert graphic to text
	;
	I OY'=CY D
	.	U IO
	.	I vflg,vframe,CY>vtop W ?79,"|" S vflg=0	; Right border
	.	F I=1:1:CY-OY D  W !				; Skip lines
	..		I 'vframe Q
	..		I I=vtop W "+"_vln_"+"			; Top line
	..		I I>vtop W "|",?79,"|"			; Border
	.	I vframe W "|" S vflg=1				; Next line
	;
	S OY=CY
	I 'vflg,vframe,CY>vtop W "|" S vflg=1			; Left border
	W ?CX-1
	;
	; =============== Blank screen ? (screen definition print option)
	;
	I %O=5,N>ZVDA W $$DBLK($A(X,3)) Q
	;
	I $E(X,12)=3 W $$LBLK($A(X,3)) Q
	I $E(X,10) W $$EBLK($A(X,3)) Q
	;
	; Format $,N data type
	;
	I "$N"[$E(X,13) S D=$J(D,$A(X,3))
	;
	W D
	Q
	;
GRPHMAP(X)	; 
	Q $TR(X,"xqsjklmntuvw","|--+++++++++") ; Translate graphics
	;
NEXTOBJ()	; Get the next object in display order
	;
	S NVPR=NVPR+1,NVDA=NVDA+1
	I NVPR>EVPR,NVDA'>EVDA Q NVDA
	I NVDA>EVDA,NVPR'>EVPR Q NVPR
	I NVPR>EVPR,NVDA>EVDA Q ""
	I VO(NVPR)]]VO(NVDA) S NVPR=NVPR-1 Q NVDA
	S NVDA=NVDA-1 Q NVPR
	;
V5	; %O=5 - Strip data to print blank form
	;
	;N VHDR
	;S VHDR=$P($G(VO),"|",3)+1 I 'VHDR S VHDR=8
	;
	F I=$P(VO,"|",2):1:+VO S VO(I)=$E(VO(I),1,13) ; Strip all data
	G LP
	;
LBLK(L)	Q $E("******************************************************************************************************************",1,L)
DBLK(L)	Q $S(L:$$EBLK(L),1:"<<var>>") 
EBLK(L)	Q $E("__________________________________________________________________________________________________________________________________________________________________________",1,L)
CBLK(L)	Q $E("                                                                                                                                                                          ",1,L)
VBLK(L)	D VIDEO(1,0,0) W $J("",L) D VIDEO(2,0,0) Q  ; 	Protected field
VSEC(L)	I $A(V)!($A(V,2)) W $$VIDOFF^%TRMVT S V="" ;	Secret mode
	W $$EBLK(L)
	Q
	;
	;
OVF(X,fs,rs,fn)	; Record size (rs) larger than field size (fs)
	;         Data entry field number (fn)
	;
	I $G(fn),%O<2 S vofl(fn)=rs ;			Original record size 
	Q X
	;
GRAPH0()	Q $C(15)  ;========== Select/Deselect Special Graphics
	;
CLF(L)	Q CSI_L_"X"
CUR(Y,X)	; Place cursor on line y, column x
	;
	Q CSI_Y_";"_X_"H"  ; Cursor Position for Screens
	;
	;----------------------------------------------------------------------
PARSE	; Parse %OPMODE commands
	;----------------------------------------------------------------------
	; Example:
	;
	;	%OPMODE="DEVICE LP:OUTPUT ""SYS$LOGIN:ABC.LST"""
	;----------------------------------------------------------------------
	N CMD,EXPR,EXPR1,tree,tree1
	D INIT,^DBSINT(%OPMODE,"CMD(") I ER Q
	;
	; Order by NOOUTPUT, OUTPUT, DEVICE, anything else to ensure order 
	; of execution.  If NOOUTPUT, then done!
	;
	S EXPR1=4
	F EXPR=1:1 Q:'$D(tree(EXPR))  D
	.	N X S X=$P(tree(EXPR),"(",1)
	.	I X="NOOUTPUT" S tree1(1)=tree(EXPR)
	.	I X="OUTPUT" S tree1(2)=tree(EXPR)
	.	E  I X="DEVICE" S tree1(3)=tree(EXPR)
	.	E  S tree1(EXPR1)=tree(EXPR),EXPR1=EXPR1+1
	;
	I $D(tree1(1)) Q		; NOOUTPUT
	;
	S EXPR=""
	F  S EXPR=$O(tree1(EXPR)) Q:EXPR=""  D @tree1(EXPR) Q:ER
	Q
	;
	;----------------------------------------------------------------------
DEVICE(TYPE)	;Private;Call a specified device driver
	;----------------------------------------------------------------------
	;
	I TYPE="BU" D ^DBSPNTB Q  	; Burroughs Terminal
	I TYPE="FC" D ^DBSPNTF Q	; Foreign client, FSSP service class
	I TYPE="PC" D ^DBSPNTP Q	; Personal computer
	I TYPE="LP" D LP Q		; Line printer
	I TYPE="VT" D VT Q		; VT
 	Q
	;
	;----------------------------------------------------------------------
NOOUTPUT	;Private;No output
	;----------------------------------------------------------------------
	Q
	;
	;----------------------------------------------------------------------
DEFINE	;Private;Form definition
	;----------------------------------------------------------------------
	;
	n dx,dy,i,j,x
	i $g(PGM)="" q
	i '$d(%PG) n %PG s %PG=0
	;
	k ^TMPDEF($J,%PG)
	s ^TMPDEF($J,%PG)=$g(SID)_"|"_PGM
	;
	i PGM="UTLREAD" d
	.	f i=1:1 q:'$d(%TAB(i))  d
	..		s dy=$A(%TAB(i),1)+1
	..		s dx=$A(%TAB(i),2)+1
	..		f j=1:1 q:'$d(VO(j))  d
	...			i $a($e(VO(j),1))'=dy q
	...			i $a($e(VO(j),2))'=dx q
	...			s x=$$def(%TAB(i),VO(j))
	...			i x'="" s ^TMPDEF($J,%PG,i)=x
	e  d
	.	n %TAB
	.	d VTBL^@PGM
	.	s ofst=$p(VO,"|",2)-1
	.	f i=1:1 q:'$d(%TAB(i))  d
	..		s x=$$def(%TAB(i),VO(i+ofst))
	..		i x'="" s ^TMPDEF($J,%PG,i)=x
	q
	;
def(x,y)	;Private;Object definition
	;
	n blk,col,fTMPDEF,grf,hgh,len,pro,req,row,sec,tbl,typ,und,vo,z
	;
	s nam=$p(x,"|",3)
	s tbl=$p(x,"|",4)
	S req=$e($p(x,"|",1),5)
	;
	; Data type
	s typ=$e(y,13)
	;
	s row=$a($e(y,1))
	s col=$a($e(y,2))
	s len=$a($e(y,3))
	;
	; Video options
	s vo=$a($e(y,4))
	s rev=vo\1#2
	s hgh=vo\2#2
	s und=vo\4#2
	s blk=vo\8#2
	;
	; Secret/graphics/protect flags
	s sec=$e(y,10)
	s grf=$e(y,11)
	s pro=$e(y,12)
	;
 	; Data value
	s val=$e(y,14,999)
	;
	s z=nam_"|"_tbl_"|"_typ_"|"_len_"|"_col_"|"_row_"|"_rev_"|"_hgh
	s z=z_"|"_und_"|"_blk_"|"_sec_"|"_grf_"|"_pro_"|"_val_"|"_req
	q z
	;
	;----------------------------------------------------------------------
OUTPUT(DEVICE)	;Private; Open output device specified in %OPMODE
	;----------------------------------------------------------------------
	;
	; Open output device specified by %OPMODE OUTPUT parameter.  Used in
	; conjunction with DEVICETYPE LP parameter.
	;
	; Also used by SCAIO to enable DQRT service class batch mode report
	; output redirection.
	;
	; ARGUMENTS:
	;	. DEVICE	Output device		/TYP=T
	;
	; INPUT:
	;	. tree1(3)	Device driver type	/TYP=larray
	;
	; RETURNS:
	;	. ER,RM		Standard error info
	;	. IO,IOTYP,etc.	Standard SCAIO info
	;
	;
	S IO=DEVICE K IOTYP
	N %OPMODE		; SCAIO uses %OPMODE to redirect, so hide
	D OPEN^SCAIO
	Q
	;
	;----------------------------------------------------------------------
INIT	; Initialize command line
	;----------------------------------------------------------------------
	;
	S CMD("DEFINITION")="DEFINE"
	S CMD("DEVICETYPE")="DEVICE(1/REQ"
	S CMD("NOOUTPUT")=""
	S CMD("OUTPUT")="OUTPUT(1/REQ"
	Q
	;
	;-----------------------------------------------------------------------
FRAME 	; Display a Frame
	;-----------------------------------------------------------------------
	;
	N origin,extant
	S origin=$P(VO,"|",5) I 'origin Q
	S origin=(origin+$P(VO,"|",3))_";1"
	S extant=$P(VO,"|",4)-origin+1_";79"
	;
	D BOX^%TRMVT(origin,extant)
	Q
