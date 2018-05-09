DBSCALC	;DBSCALC; Calculator Program
	;;Copyright(c)2000 Sanchez Computer Associates, Inc.  All Rights Reserved - 05/15/00 15:27:12 - DOUGANM
	;
	;
	;=======================================================================
	;                       Keypad display interface
	;=======================================================================
	;----Revision History --------------------------------------------------
	;
        ; 05/12/00 - DOUGANM- 39582
        ;            To improve the performance of error handling, cleaned up
        ;            call to $$NEW^%ZT, and removed use of indirection.
	;	     Replaced $ZP reference with $O(^gbl(...),-1) syntax.
	;
	; 12/09/94 - Janet An
	; 	     Modified MSG 7889. $$CUR should not be the parameter
	;	     of $$^MSG.
	;	     Replaced READ statment with ^UTLREAD.
	;
	; 08/04/94 - Fan Zeng - ARQ 10174
	;            Replaced "Q ;" with "Q  ;".
	;     
	;-----------------------------------------------------------------------
        ;   I18N=QUIT : Excluded From I18N Standards
KEYPAD	;
	; This interface will display the keypad on the screen.
	; Note that only the area used by the calculator is cleared.
	;
	NEW (X,OX,OY,%LIBS)
	S %O=1
	I '$D(OX) S OX=63 ; Offset X, position keypad flush to right margin
	I '$D(OY) S OY=0 ;  Offset Y
	;
	S DSP("W")=15 ; Maximum length of output, fits within keypad
	S DSP("X")=OX+1 ; Display column
	S DSP("Y")=OY+8 ; Display line
	D DSPINIT ; Initialize calculation parameters
	;
	S MEM("Y")=OY+21 ; Memory displayed at...
	S MEM("X")=OX+1
	D MEMINIT ; Initialize memory parameters
	;
	D TIMINIT ; Initialize time parameters
	;
	S TAPE=0 ; No, do not process tape commands
	;
	D PAINT ; Paint keypad display
	D TIMSHOW ; Display current time
	D DSPSHOW ; Display current number
	D MEMSHOW ; Display current memory
	D DRIVER ; Calculations
	D EXIT ; Clean up
	Q
	;
	;=======================================================================
	;                   Teller Posting Screen Interface
	;=======================================================================
TELLER(FIRST,LAST,WIDTH,TAPE)	;
	; Line 24 is reserved for error messages
	; 
	N (FIRST,LAST,WIDTH,TAPE,%LIBS) ; Don't clobber anybody elses variables
	;
	S %O=1
	I '$D(FIRST) N FIRST S FIRST=1 ; First line of display region
	I '$D(LAST) N LAST S LAST=23 ; Last line of display region
	;I '$D(WIDTH) N WIDTH S WIDTH=20 ; Maximum length of output
	I '$D(TAPE) N TAPE S TAPE=1 ; Default, no tape display
	I FIRST<1 S FIRST=1
	I LAST>23 S LAST=23
	D ERASE(FIRST,LAST) ; Clear calculator area
	;
	I WIDTH<10 S WIDTH=10 ; Reasonable?
	I WIDTH>40 S WIDTH=40
	;
	S TIME=0 ; No time display
	;
	D DSPINIT ; Initialize calculation parameters
	S DSP("Y")=LAST-1
	S DSP("X")=2
	S DSP("W")=WIDTH
	S DSP("H")=1 ; One line
	D BOX(DSP("Y"),DSP("X"),DSP("W"),DSP("H"))
	;
	D MEMINIT ; Initialize memory parameters
	S MEM("Y")=LAST-1 ; Memory displayed at...
	S MEM("X")=24
	S MEM("W")=WIDTH
	S MEM("H")=1 ; One line
	D BOX(MEM("Y"),MEM("X"),MEM("W"),MEM("H"))
	;
	D HELPINIT ; Initialize help parameters
	D TAPINIT ; Initialize tape parameters, dependant on DSP array
	D TAPSHOW ; Display tape
	D DSPSHOW ; Display current number
	D MEMSHOW ; Display current memory
	;
	D DRIVER ; Calculations
	D ERASE(FIRST,LAST) ; Clear calculator area
	D EXIT ; Clean up
	Q X  ; Return last displayed number
	;
TAPADD(OP,NUM)	;========== Add evaluation to contents of the tape
	;
	Q:'TAPE  ; Disabled
	Q:'TAPE("ON")  ; Turned off
	;
	I TAPE("NEXT")=TAPE("MAX") D TAPFULL Q
	;
	N I,X,Y2
	I OP="" S OP=" "
	S TAPE("LIST",TAPE("NEXT"))=OP_"|"_NUM
	S TAPE("NEXT")=TAPE("NEXT")+1
	S TAPE("SP")="" ; Reset tape starting print location
	;
TAPSHOW	;========== Display contents of the tape
	;
	Q:'TAPE  ; Disabled
	Q:TAPE("H")<1  ; Can't display it
	S X="",$P(X," ",TAPE("W")+1)=""	
	S TAPE("STOP")=TAPE("Y")+TAPE("H")-1
	F I=TAPE("Y"):1:TAPE("Y")+TAPE("H")-1 W $$CUR(I,2),X
	S TAPE("START")=TAPE("STOP")-TAPE("NEXT")+2
	I TAPE("START")>TAPE("STOP") Q
	S N=TAPE("SP")
	F I=TAPE("STOP"):-1:TAPE("STOP")-TAPE("H")+1 S N=$O(TAPE("LIST",N),-1) Q:N=""  W $$CUR(I,2)_$P(TAPE("LIST",N),"|",1)_" "_$$FMT($P(TAPE("LIST",N),"|",2),DSP("W")-2) 
	Q
	;
	; Tape is full: you must clear it
TAPFULL	D SHOWRM($$^MSG(7886)) Q
TAPBOX	D BOX(TAPE("Y"),TAPE("X"),TAPE("W"),TAPE("H")) Q
	;
TAPCLR	;========== Clear contents of the tape
	Q:'TAPE  ; Disabled
	;
	K TAPE("LIST")
	S TAPE("NEXT")=1
	S TAPE("SP")=""
	D TAPBOX
	; Tape cleared
	D SHOWRM($$^MSG(7884))
	Q
	;
TAPPRT	;========== Print contents of the tape
	Q:'TAPE  ; Disabled
	I DSP!RESULT D TAPADD("=",$S(RESULT:RESULT,DSP:DSP))
	; Tape is empty
	I TAPE("NEXT")=1 D SHOWRM($$^MSG(7885)) Q
	N (TAPE,DSP)
	W $$SILENT0()_$$CUR(24,1)_$$IOCC(132) ; Clear this line
	; Print Tape on Device: 
	S OLNTB=20010
	S %TAB("TAP")=".TAP"
	S %READ="TAP"
	D ^UTLREAD
	W $$SILENT1()_$$CUR(24,1)_$$IOCC(132) ; Clear this line
	I X="" Q  ; Didn't want to print
	S ER=0,%EXT=1,ZB=13
	; Invalid device ~p1
	D ^SCAIO I ER D SHOWRM($$^MSG(7879,X)) Q
	; Error opening device ~p1
	D OPEN^SCAIO I ER D SHOWRM($$^MSG(7878,X)) Q
	U IO
	F I=1:1:TAPE("NEXT")-1 D TAPPRT1
	D CLOSE^SCAIO
	; Tape printing complete
	D SHOWRM($$^MSG(7888))
	;
TAPPRT0	;
	Q
	;
TAPPRT1	S OP=$P(TAPE("LIST",I),"|",1)
	S NUM=$P(TAPE("LIST",I),"|",2)
	W !,OP_" "_$$FMT(NUM,DSP("W"))
	Q
	;
TAPTGL	;========== Toggle tape on/off
	Q:'TAPE  ; Disabled
	;
	S TAPE("ON")='TAPE("ON")
	;
	; Tape is ~p1
	D SHOWRM($$^MSG(7887,$S(TAPE("ON"):"on ",1:"off")))
	Q
	;
TAPINIT	;========== Initialize all tape parameters
	;
	S TAPE=1 ; Yes, process tape commands
	S TAPE("MAX")=999 ; Maximum number of entries
	S TAPE("NEXT")=1 ; Next available tape entry number
	S TAPE("PS")=0 ; This is the $n starting point to display the tape
	; this changes if PREV or NEXT screen are used
	K TAPE("LIST") ; Empty list
	;
	; Window height is set to the maximum amount of room allowed by
	; the line range, minus 3 lines for the result display, minus 2 lines
	; for the tape window border.
TAPINITH	;
	S TAPE("H")=LAST-FIRST+1-3-2 ; Can be less than one!
	S TAPE("W")=DSP("W") ; Need room for operator display
	S TAPE("Y")=FIRST+1 ; First line in tape window
	S TAPE("X")=2 ; Left Justify 
	;
	S TAPE("ON")=1 ; Initially, saves calculations
	D TAPBOX
	Q
PREV	; Init TAPE("SP") for prior transactions
	S Y=$O(TAPE("LIST",TAPE("SP")),-1)-$S(FIRST=8:8,1:3)
	I $D(TAPE("LIST",Y)) S TAPE("SP")=Y+1
	S Y=$S(FIRST=8:8,1:3) I TAPE("SP")<Y S TAPE("SP")=Y
	D TAPSHOW
	Q
NEXT	S X=$O(TAPE("LIST",TAPE("SP")))
	I X,$D(TAPE("LIST",X)) S TAPE("SP")=TAPE("SP")+$S(FIRST=8:9,1:4)
	D TAPSHOW
	Q
	;
DSPINIT	;========== Initialize all calculation parameters
	;
	S DSP("DEC")=0 ; Default precision
	S DSP=0 ; Edit this string
	S DSP("FMT")="" ; How to display formatted number
	S RESULT=DSP
	F I=1,2 S OPERAND(I)=0 ; Operands
	S OPER="" ; Operation
	K CONSTANT
	;
	S ERROR=0 ; Error flag
	S ZB=0 ; Read terminator
	W $$SILENT1() ; Silent mode on
	Q
	;
EXIT	;========== Reset parameters, terminal
	; Erase screen, no silent mode, cursor home
	W $$IOSCROLL(1,24)_$$SILENT0()_$$CUR(21,1)
	S X=$S(ZB'=23:RESULT,1:"")  ; Return value
	Q
	;
DRIVER	;==========
	S OZB="" ; used for gold key processing
	S LZB=$G(ZB)
	;
DRIVER1	D GETKEY ; Get next keystroke
	I ZB>111&(ZB<122) D DIGIT(ZB-112+48) G DRIVER ; Keypad digit
	I ZB=23 Q  ; F11, Escape
	I ZB=80 S OZB=1 G DRIVER1 ; Gold key processing
	I ZB=28 D HELP G DRIVER ; Help key for new screen display and text
	I ZB=29 Q  ; Do key to exit
	;
	I ERROR D DSPCLR ; Get ready to display a new number
	;
	I KEY="," D DSPFMT G DRIVER ; Enable/disable comma format
	I KEY="." D DSPPREC G DRIVER ; Set display precision
	;
	;
	I ZB=110 D DECIMAL G DRIVER ; Decimal point
	I ZB=108 D NEGATE G DRIVER ; Negate current value
	;
	; Note: UP and DOWN keys must be changed to TAPE DISPLAY keys.
	I ZB=65 D UPMEM G DRIVER ; Up arrow
	I ZB=66 D DNMEM G DRIVER ; Down arrow
	I ZB=67 D DELETE G DRIVER ; Right arrow
	I ZB=68 D DELETE G DRIVER ; Left  arrow
	;
	I ZB=1 G DRIVER ; Find key, will be financial calculator key
	I ZB=2 G DRIVER ; Insert key, will be 'save display in function key'
	I ZB=3 D DSPCLR G DRIVER ; Remove key, like 'clear entry'
	I ZB=4 D DSPPREC G DRIVER ; Select key, define decimal precision
	I ZB=5 D PREV G DRIVER ; Prev screen key, will scroll tape display
	I ZB=6 D NEXT G DRIVER ; Next screen key, will scroll tape display
	;
	I ZB=24 G DRIVER ; F12, Tape print not supported
	I ZB=25 D TAPPRT G DRIVER ; F13, Prints tape
	I ZB=26 D TAPCLR G DRIVER ; F14, Tape clear
	;
	I ZB=31 D ADDMEM G DRIVER ; F17 key, add to memory
	I ZB=32 D SUBMEM G DRIVER ; F18 key, subtract from memory
	I ZB=33 D GETMEM G DRIVER ; F19 key, retrieve from memory
	I ZB=34 D PUTMEM G DRIVER ; F20 key, put into memory
	;
	I ZB=81 D PERCENT G DRIVER ; Keypad Comma key, percentage
	;
	I ZB=279 S DISPLAY=$G(DISPLAY) D CW G DRIVER ; Control-W
	I ZB=(256+18) D RESET G DRIVER ; Control-R
	;
	I ",77,109,82,83,"[(","_LZB_",")&(",77,109,82,83,"[(","_ZB_",")),LZB-ZB G SKIP
	;
	; The constant is killed whenever an editing function is performed
	; on the EDIT variable, such as adding a digit or decimal point.
	;
	; If the constant is defined, use it
	; else  use the edit number
	;
	I $D(CONSTANT) S OPERAND(2)=CONSTANT
	E  S OPERAND(2)=DSP
	;
	; Data evaluation
	D TAPADD(OPER,OPERAND(2)) ; Add to tape
	I OPER'="" D EVAL I ERROR D TAPADD("E","") G DRIVER
	S OPERAND(1)=DSP
	;
	; Save a new constant
	I '$D(CONSTANT) S CONSTANT=OPERAND(2)
	;
	D DSPSHOW
	;
SKIP	; come here if only trying to change the operation
	S OPER=""
	;
	; Set oper for next pass through
	; Setting the DSP number to zero starts a new number
	I ZB=77 S OPER="+",DSP=0 G DRIVER
	I ZB=109 S OPER="-",DSP=0 G DRIVER
	I ZB=82 S OPER="*",DSP=0 G DRIVER
	I ZB=83 S OPER="/",DSP=0 G DRIVER
	;
	; Ignore all unknown terminators
	G DRIVER
	;
	;
	;=======================================================================
	;                     Data editing routines
	;=======================================================================
	;
DIGIT(D)	;========== Try to add a digit to the display string
	;
	; Convert the terminator code to the ascii value of that digit.
	; Don't allow leading zeroes.
	;
	K CONSTANT
	I (D=48)&(DSP="0") Q
	I $L(DSP)=DSP("W") Q  ; No more room
	I DSP="0" S DSP=$C(D)
	E  S DSP=DSP_$C(D)
	S RESULT=DSP
	;
	; Display data exactly as entered with trailing zeroes
	D RAW($FN(DSP,DSP("FMT"),$L($P(DSP,".",2))))
	Q
	;
DECIMAL	;========== Display a period in the DSP number
	;
	K CONSTANT
	Q:DSP["."  ; Already got one
	Q:$L(DSP)=DSP("W")  ; Too big
	S DSP=DSP_"."
	S RESULT=DSP
	D RAW($FN(DSP,DSP("FMT"),$L($P(DSP,".",2))))
	Q
	;
NEGATE	;========== Negate the current display
	;
	K CONSTANT
	I 'DSP S DSP=RESULT
	I $E(DSP)="-" S DSP=$E(DSP,2,$L(DSP))
	E  I $L(DSP)<DSP("W") S DSP="-"_DSP
	I DSP="-" S DSP=0
	D DSPSHOW
	Q
	;
DELETE	;========== Delete a digit from the display
	K CONSTANT
	S DSP=$E(DSP,1,$L(DSP)-1)
	I DSP="-" S DSP=0
	D DSPSHOW
	Q
	;
	;
PERCENT	;========== Evaluate a percentage
	; The operator is not saved
	N OPER S OPER="%"
	D EVAL
	D DSPSHOW
	K CONSTANT
	Q
	;
DSPSHOW	;========== Format and display DSP 
	;
	I $L(DSP)>DSP("W")!($L($$EDIT(DSP))>DSP("W")) D DSPOVER
	W $$CUR(DSP("Y"),DSP("X"))_$$FMT(DSP,DSP("W"))
	S RESULT=DSP
	Q
	;
DSPOVER	;========== DSP over/under flow error
	;
	Q:$E(DSP)="."  ; Not underflow, just rounding error
	; Display underflow
	I DSP<1 D SHOWRM($$^MSG(7876))
	; Display overflow
	I DSP'<1 D SHOWRM($$^MSG(7875))
	S OPER=""
	K CONSTANT
	S OPERAND(1)=0
	S OPERAND(2)=0
	S DSP=0
	Q
	;
DSPFMT	;========== Toggle comma display
	;
	I DSP("FMT")="" S DSP("FMT")=","
	E  S DSP("FMT")=""
	D DSPSHOW ; Redisplay number
	D MEMSHOW ; Redisplay memory
	Q
	;
FMT(N,W)	;========== Format and justify N
	;
	S N=$$EDIT(N)
	I $L(N)>W S N=$E(N,1,W)
	S N=$J(N,W)
	S RESULT=DSP
	Q N
	;
EDIT(N)	;========== Format N with required precision
	;
	I DSP("DEC") S N=$FN(N,DSP("FMT"),DSP("DEC"))
	E  S N=$FN(N,DSP("FMT"))
	Q N
	;
RAW(N)	;========== Display raw data in the window
	;
	; This can cause a discrepancy between the display and the edit
	; string.
	S N=$J(N,DSP("W"))
	I $L(N)>DSP("W") S N=$E(N,1,DSP("W"))
	W $$CUR(DSP("Y"),DSP("X"))_N
	Q
	;
RESET	;========== Reset display, memory, time, etc.
	D TAPCLR ; Clear already displays the empty tape
	D DSPCLR,DSPSHOW
	D MEMCLR,MEMSHOW
	D TIMSHOW
	S OPER=""
	S OPERAND(1)=0
	S OPERAND(2)=0
	K CONSTANT
	S ERROR=0
	Q
	;
DSPPREC	;========== Set precision for display
	;
	N X
	;
SETPR1	W $$SILENT0()_$$CUR(24,1)_$$IOCC(132) ; Clear this line
	;  Select decimal precision (0 - ~p1) : 
	W $$^MSG(7873,(DSP("W")-1))
	R X I X="" W DSP("DEC") G SETPR2
	I X'?.N G SETPR1 ; Not numeric
	I '(X<DSP("W")) G SETPR1 ; Too big
	I X<0 G SETPR1 ; Too small
	S DSP("DEC")=X
	;
SETPR2	W $$SILENT1()_$$CUR(24,1)_$$IOCC(132)
	D DSPSHOW,MEMSHOW
	Q
	;
DSPCLR	;========== RESET ALL VARIABLES IN THE DISPLAY.
	;
	W $$CUR(DSP("Y"),DSP("X"))_$$IOCC(DSP("W"))
	S DSP=0
	S RESULT=DSP
	D DSPSHOW
	S ERROR=0
	D SHOWRM("")
	I OZB D DSPINIT
	Q
	;
	;=======================================================================
	;
EVAL	;========== Perform arithmetic functions on the 2 operands
	;
EVAL1	I OPER="%" S X="S DSP=DSP/100"
	E  S X="S DSP=OPERAND(1)"_OPER_"OPERAND(2)"
	S OLDZT=$ZT N $ZT
	S $ZT=$$SETZT^%ZT("EVALET^DBSCALC")
	X X
EVAL2	S RESULT=DSP
	Q
	;
EVALET	;===== Evaluation error trap
	;
	S $ZT=OLDZT
	S ERROR=1
	S DSP=0,RESULT=DSP
	D DSPSHOW
	S OPER="",OPERAND(1)=0,OPERAND(2)=0
	;
	N ERR D ET^%ZT(.ERR)
	; Divide by zero
	I ERR="DIVIDE_BY_ZERO" D SHOWRM($$^MSG(7877)) Q
	I ERR="MAXSTRING" D SHOWRM("Overflow") Q
	I ERR="MAXNUMBER" D SHOWRM("Overflow") Q
	; Mumps error: ~p1
	D SHOWRM($$^MSG(7882,ERR))
	Q
	;
	;=======================================================================
	;                         Memory functions
	;=======================================================================
	;
MEMINIT	;========== All necessary memory variables
	;
	S MEM=1 ; Memory enabled
	S MEM("MAX")=10 ; Maximum memories
	S MEM("STR")="" ; Current memory display
	D MEMCLR ; Clear memory
	Q
	;
MEMSHOW	;========== Show contents of the current memory register
	Q:'MEM  ; Disabled
	;  Memory ~p1 
	S MEM("STR")=$$^MSG(7872,$J(MEM,2)) ; Memory label
	W $$CUR(MEM("Y")-1,MEM("X"))_MEM("STR")
	W $$CUR(MEM("Y"),MEM("X"))_$$FMT(MEM(MEM),DSP("W"))
	Q
	;
MEMCLR	;========== Clear Memory Registers, Point to First
	Q:'MEM  ; Disabled
	F MEM=1:1:MEM("MAX") S MEM(MEM)=0
	S MEM=1
	Q
	;
DNMEM	;========== Decrement Memory Index
	Q:'MEM  ; Disabled
	S MEM=MEM-1
	I MEM<1 S MEM=MEM("MAX")
	D MEMSHOW
	Q
	;
UPMEM	;========== Increment Memory Index
	Q:'MEM  ; Disabled
	S MEM=MEM+1
	I MEM>MEM("MAX") S MEM=1
	D MEMSHOW
	Q
	;
PUTMEM	;========== Store in Current Memory
	Q:'MEM  ; Disabled
	S MEM(MEM)=$S(DSP:DSP,1:+$G(RESULT))
	D MEMSHOW
	Q
	;
GETMEM	;========== Get from Current Memory
	Q:'MEM  ; Disabled
	S DSP=MEM(MEM)
	S RESULT=DSP
	D DSPSHOW
	Q
	;
ADDMEM	;========== Add to Current Memory
	Q:'MEM  ; Disabled
	S MEM(MEM)=MEM(MEM)+$S(DSP:DSP,1:+$G(RESULT))
	; Memory overflow
	I $L(MEM(MEM))>DSP("W") S MEM(MEM)=0 D SHOWRM($$^MSG(7880))
	D MEMSHOW
	Q
	;
SUBMEM	;========== Subtract from Current Memory
	Q:'MEM  ; Disabled
	S MEM(MEM)=MEM(MEM)-$S(DSP:DSP,1:+$G(RESULT))
	; Memory underflow
	I $L(MEM(MEM))>DSP("W") S MEM(MEM)=0 D SHOWRM($$^MSG(7881))
	D MEMSHOW
	Q
	;=======================================================================
	;
ERROR	;========== Clear status
	;
	N X
	S DSP=0
	S RESULT=DSP
	F X=1,2 S OPERAND(X)=0
	S OPER=""
	K CONSTANT
	Q
	;
ERASE(F,L)	;========== Display region
	;
	N DY
	F DY=F:1:L W $$CUR(DY,1)_$$IOCC(132)
	Q
	;
PAINT	;========== Draw the keypad
	;
	D ERASE(1,24)
	W $$GRAPH1()
	;
	W $C(27)_"["_(OY+01)_";"_OX_"Hlqqqqqqqqqqqqqqqk"
	W $C(27)_"["_(OY+02)_";"_OX_"Hx               x"
	W $C(27)_"["_(OY+03)_";"_OX_"Hmqqqqqqqqqqqqqqqj"
	W $C(27)_"["_(OY+04)_";"_OX_"Hlqqqwqqqwqqqwqqqk"
	W $C(27)_"["_(OY+05)_";"_OX_"Hx"_$C(15)_"Add"_$C(14)_"x"_$C(15)_"Sub"_$C(14)_"x"_$C(15)_"Get"_$C(14)_"x"_$C(15)_"Put"_$C(14)_"x"
	W $C(27)_"["_(OY+06)_";"_OX_"Hx"_$C(15)_"Mem"_$C(14)_"x"_$C(15)_"Mem"_$C(14)_"x"_$C(15)_"Mem"_$C(14)_"x"_$C(15)_"Mem"_$C(14)_"x"
	W $C(27)_"["_(OY+07)_";"_OX_"Hmqqqvqqqvqqqvqqqj"
	W $C(27)_"["_(OY+08)_";"_OX_"H"
	W $C(27)_"["_(OY+09)_";"_OX_"Hlqqqwqqqwqqqwqqqk"
	W $C(27)_"["_(OY+10)_";"_OX_"Hx + x - x * x / x"
	W $C(27)_"["_(OY+11)_";"_OX_"Htqqqnqqqnqqqnqqqu"
	W $C(27)_"["_(OY+12)_";"_OX_"Hx 7 x 8 x 9 x"_$C(15)_"Neg"_$C(14)_"x"
	W $C(27)_"["_(OY+13)_";"_OX_"Htqqqnqqqnqqqnqqqu"
	W $C(27)_"["_(OY+14)_";"_OX_"Hx 4 x 5 x 6 x"_$C(15)_" % "_$C(14)_"x"
	W $C(27)_"["_(OY+15)_";"_OX_"Htqqqnqqqnqqqnqqqu"
	W $C(27)_"["_(OY+16)_";"_OX_"Hx 1 x 2 x 3 x"_$C(15)_"Ent"_$C(14)_"x"
	W $C(27)_"["_(OY+17)_";"_OX_"Htqqqvqqqnqqqu   x"
	W $C(27)_"["_(OY+18)_";"_OX_"Hx 0     x . x   x"
	W $C(27)_"["_(OY+19)_";"_OX_"Htqqqqqqqvqqqvqqqu"
	W $C(27)_"["_(OY+20)_";"_OX_"Hx               x"
	W $C(27)_"["_(OY+21)_";"_OX_"Hx               x"
	W $C(27)_"["_(OY+22)_";"_OX_"Hmqqqqqqqqqqqqqqqj"
	;
	W $$GRAPH0()
	Q
	;
TIMINIT	;========== Allow time stamp display
	S TIME=1 ; Yes, display time
	S TIME("Y")=OY+2,TIME("X")=OX+1 ; Time display
	Q
	;
TIMSHOW	;========== SHOW DATE AND TIME STAMP
	Q:'TIME
	N (TIME)
	S %TIM=$$TIM^%ZM		; *** BC - replace ^%T with ^%ZM
	W $$IOSAV()_$$CUR(TIME("Y"),TIME("X"))_"   "_%TIM_$$IORST()
	Q
	;
GETKEY	;========== Read input
	R KEY#1:15 E  D TIMSHOW G GETKEY
	;
	S ZB=$ZB
	;
	; Allow upper row numbers to be treated the same as the numeric
	; keypad.
	;I KEY>47&(KEY<58) S ZB=KEY-48+112 Q
	I KEY>47,KEY<58 D DIGIT(KEY) G GETKEY
	;
	; Map control characters into 256 + ascii code
	I $L(ZB)=1 S ZB=$A($E(ZB))+256 Q
	;
	S ZBL=$A($E(ZB,$L(ZB))) ; Last character
	;
	; For function keys only
	I ZBL=126 S ZB=+$E(ZB,3,9)
	E  S ZB=ZBL
	Q
	;
FUNCTION	;; line tag call from the driver
	S FIRST=15 ;
	S X=$$TELLER(.FIRST,22,20,1)
	D REPAINT:(%FN'="CRT001"&(%FN'="CAL001")) Q
REPAINT	N X
	I FIRST'=8 D VW^@PGM Q  ; Help was not entered
	W $$IOCPB() D VREPRNT^@PGM Q  ; Help was entered
	;
SILENT1()	D LOCTRM Q $$CUR0()_$$KPAM1()  ; Silent mode
SILENT0()	D USRTRM Q $$CUR1()_$$KPAM0()  ; Not silent mode
	;
LOCTRM	D TERM^%ZUSE(0,"NOECHO/BREAK") Q
USRTRM	D TERM^%ZUSE(0,"ECHO/TERMINATOR=$C(13)/ESCAPE") Q
	;
WID	;========== Set screen width
	;
	I SWID=80 W $$S80() Q
	I SWID=132 W $$S132() Q
	Q
	;
S80()	Q $C(27)_"[?3l"
S132()	Q $C(27)_"[?3h"
	;
KPAM1()	Q $C(27)_"="  ;========== Keypad Application Mode
KPAM0()	Q $C(27)_">"
	;
INSERT()	Q $C(27)_"[4h"  ;========== Insert/Overstrike Mode
OVER()	Q $C(27)_"[4l"
	;
CUR0()	Q $C(27)_"[?25l"  ;========== Cursor On/Off
CUR1()	Q $C(27)_"[?25h"
	;
BOX(Y,X,W,H)	;========== Draw box, with the inside of the box cleared
	Q:H<1  ; Nothing to display
	Q:W<1  ; Ditto
	N (Y,X,W,H)
	;
	W $$IOSAV()_$$GRAPH1()
	S $P(BLANK," ",W+1)="" ; Blank line
	S $P(HORIZ,"q",W+1)="" ; Horizontal line
	W $$CUR(Y-1,X-1)_"l"_HORIZ_"k"
	F Y=Y:1:Y+H-1 W $$CUR(Y,X-1)_"x"_BLANK_"x"
	W $$CUR(Y+1,X-1)_"m"_HORIZ_"j"
	W $$GRAPH0()_$$IORST()
	Q
	;
GRAPH0()	Q $C(15)  ;========== Select/Deselect Special Graphics
GRAPH1()	Q $C(27)_"(B"_$C(27)_")0"_$C(14)
	;
	;
SHOWRM(TEXT)	;========== Display message at bottom of screen
	W $$IOSAV()_$$CUR(24,1)
	I TEXT'="" W $$IOREV1()_" "_TEXT_" "_$$IOREV0() S ERROR=1
	I TEXT="" S ERROR=0
	W $$IOCLE()_$$IORST()
	Q
HELPINIT	; create ZB array for support keys
	S LIBR="SCAU$HELP:CALC.HLB"
	S ZB(80)="GOLD",ZB(29)="DO"
	S ZB("29G")="EXIT",ZB(200)="COMMA"
	S ZB(300)="PRECISION" F I=112:1:121 S ZB(I)="DIGIT_"_$C(I-112+48)
	S ZB(110)="DECIMAL_PT",ZB(108)="NEGATE"
	S ZB(65)="SCROLL_UP",ZB(66)="SCROLL_DOWN"
	S ZB(67)="REMOVE",ZB(68)=ZB(67),ZB(3)="CLEAR_ENTRY"
	S ZB("3G")="CLEAR",ZB(4)=ZB(300),ZB(5)="TAPE_UP"
	S ZB(6)="TAPE_DN",ZB(25)="PRINT",ZB(26)="TAPE"
	S ZB(31)="ADD_MEMORY",ZB(32)="SUB_MEMORY"
	S ZB(33)="GET_MEMORY",ZB(34)="PUT_MEMORY"
	S ZB(81)="PERCENTAGE",ZB(77)="ADDITION"
	S ZB(109)="SUBTRACTION",ZB(82)="MULTIPICATION",ZB(83)="DIVISION"
	Q
HELP	;========== Process the HELP key
	S SID="CALCHELP",DISPLAY=0 D ^USID I PGM="" Q
	K %NOFORM,%NODATA
	I FIRST'=8 D VPR^@PGM,VDA^@PGM,^DBSPNT()
	; ~Press the key you want help on, HELP to redisplay the Key Pad.: 
H1	W $$CUR(23,1)_$$IOCC(78)_$$CUR(23,1)_$$^MSG(7889)
	D GETKEY
	I ZB=269,KEY="" G H2 ; Return
	I ZB=28 S FIRST=8 D:DISPLAY VPR^@PGM,VDA^@PGM,^DBSPNT() S DISPLAY=0 G H1 ; Help key for new screen display and text
	I KEY="," S ZB=200 ; Enable/disable comma format
	I KEY="." S ZB=300 ; Set display precision
	;  Unmapped key 
	I '$D(ZB(ZB)) W $$^MSG(7874) R X:3 G H1
	;
	S X=$$HELP^%ZFUNC(ZB(ZB),LIBR)
	S DISPLAY=1 ;
	G H1 ;
H2	W $$CUR(23,1)_$$IOCC(78)
	I DISPLAY D VPR^@PGM,VDA^@PGM,^DBSPNT()
	S FIRST=8 D TAPINITH
	D BOX(DSP("Y"),DSP("X"),DSP("W"),DSP("H"))
	D BOX(MEM("Y"),MEM("X"),MEM("W"),MEM("H"))
	S SRESULT=RESULT
	D TAPSHOW ; Display tape
	I SRESULT S SDSP=DSP,DSP=SRESULT
	D DSPSHOW ; Display current number
	I SRESULT S DSP=SDSP,RESULT=SRESULT
	K SDSP,SRESULT
	D MEMSHOW ; Display current memory
	Q  ;
CW	W $$CUR(23,1)_$$IOCC(78)
	I DISPLAY D VPR^@PGM,VDA^@PGM,^DBSPNT()
	D TAPINITH
	D BOX(DSP("Y"),DSP("X"),DSP("W"),DSP("H"))
	D BOX(MEM("Y"),MEM("X"),MEM("W"),MEM("H"))
	S SRESULT=RESULT
	D TAPSHOW ; Display tape
	I SRESULT S SDSP=DSP,DSP=SRESULT
	D DSPSHOW ; Display current number
	I SRESULT S DSP=SDSP,RESULT=SRESULT
	K SDSP,SRESULT
	D MEMSHOW ; Display current memory
	Q  ;
CUR(Y,X)	;========== Place cursor on line y, column x
	Q $C(27)_"["_Y_";"_X_"H"  ; Cursor Position
	;
IOSCROLL(L1,L2)	;========== Set scrolling region
	I L2<L1 Q ""  ; No region
	Q $C(27)_"["_L1_";"_L2_"r"
	;
IOCLE()	Q $C(27)_"[0K"  ; Clear Line, Cursor to E-O-L
IOCLB()	Q $C(27)_"[1K"  ; Clear Line, Cursor to B-O-L
IOCL()	Q $C(27)_"[2K"  ; Clear Line
IOCPE()	Q $C(27)_"[0J"  ; Clear Page, Cursor to B-O-P
IOCPB()	Q $C(27)_"[1J"  ; Clear Page, Cursor to T-O-P
IOCP()	Q $C(27)_"[2J"  ; Clear Page
	;
IOCC(N)	Q $C(27)_"["_N_"X"  ; Clear N characters
	;
IOSAV()	Q $C(27)_"7"  ;   Save cursor
IORST()	Q $C(27)_"8"  ;   Restore cursor
	;
IOREV0()	Q $C(27)_"[27m"  ; Reverse video off
IOREV1()	Q $C(27)_"[7m"  ;  Reverse video on
	;
IOUND0()	Q $C(27)_"[24m"  ; Underline off
IOUND1()	Q $C(27)_"[4m"  ;  Underline on
	;
