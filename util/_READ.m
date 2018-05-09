%READ	;M Utility;Generic Prompting Routine for M Utilities
	;;Copyright(c)1994 Sanchez Computer Associates, Inc.  All Rights Reserved - 10/18/94 19:00:40 - RUSSELL
	; ORIG:  Rick Baldwin
	;
	; Generic read with recall capability for VTnnn terminals
	;
	; INPUTS:
	;	. READ()	Previous input		/TYP=T
	;
	;	. X		Default value		/TYP=T
	;
	; RETURNS:
	;	. X		New value		/TYP=T
	;
	;	. READ()	All input		/TYP=T
	;
	; KEYWORDS:	System services
	;
	;---- Revision History ------------------------------------------------
	;
	; 10/18/94 - Dan Russell
	;            Changed GETSTR1 section to handle GT.M V3.1 R *X.  Now
	;            returns X=27 instead of X=0 on escape sequence input.
	;----------------------------------------------------------------------
	;
	N (READ,X)
	D INIT,PROCESS,EXIT
	Q
	;
	;----------------------------------------------------------------------
PROMPT(PROMPT,DEFAULT)	;M Utility;Generic Prompting Routine for M Utilities
	;----------------------------------------------------------------------
	; Parameter passed version of ^%READ
	;
	; Using this entry point eliminates the use of unnecessary local
	; variables and worrying about the READ() data structure.
	;
	; PROMPT is what the user will see ahead of the data
	; DEFAULT is the default data value to be displayed
	;
	; KEYWORDS:	IO
	;
	; ARGUMENTS:
	;	. PROMPT	Prompt message		/TYP=T
	;
	;	. DEFAULT	Default value		/TYP=T
	;
	; INPUTS:
	;	. READ()	Previous input		/TYP=T
	;
	; RETURNS:
	;	. $$		Input			/TYP=T
	;
	;	. READ()	All input		/TYP=T
	;
	; EXAMPLES:
	;
	;	S VAR=$$PROMPT^%READ("Global ^","")
	;	S VAR=$$PROMPT^%READ("Device: ",$I)
	;	S VAR=$$PROMPT^%READ("Account: ",ACN)
	;
	;
	N X ; Save old value
	S READ("PROMPT")=PROMPT
	S X=DEFAULT
	D ^%READ
	Q X  ; Return value to caller
	;
INIT	;========== Initialize all parameters
	I '$D(X) S X=""
	D INIREAD ; Initialize READ data structure
	D KILLOM ; Initialize I/O buffers
	S STACKNUM=""
	S COLM=$L(READ) ; Current character column, not screen column
	S GOLD=0 ; Key modifier flag
	S STR="" ; Input string
	S OVER=READ("OVER") ; Insert/Overstrike mode saved from last call
	I OVER D OVER
	I 'OVER D INSERT
	S KPAM=READ("KPAM") D IOKPAM ; Set Keypad mode
	D CONTROL,SHOPROM ; Set terminal protocol, display prompt
	Q
	;
INIREAD	;========== Initialize READ data structure
	S READ=X ; Load default input
	I '$D(READ("STACK")) S READ("STACK")=20 ;   Maximum stack size
	I '$D(READ("PROMPT")) S READ("PROMPT")="" ; Prompt buffer
	I '$D(READ("REMOVE")) S READ("REMOVE")="" ; REMOVE buffer
	I '$D(READ("DELETE")) S READ("DELETE")="" ; DELETE buffer
	I '$D(READ("FIND")) S READ("FIND")="" ;     FIND buffer
	I '$D(READ("ZB")) S READ("ZB")=0 ;          Read terminator
	I '$D(READ("OVER")) S READ("OVER")=0 ;      Insert mode
	I '$D(READ("KEY")) S READ("KEY")="" ;       Defined Keys
	I '$D(READ("KPAM")) S READ("KPAM")=0 ;      Numeric Keypad
	Q
	;
STAKSIZ	;========== Returns FIRST, LAST, and NUMBER of stack entries
	; Note: NUMBER will be incorrect if the entries in the stack are not
	; sequentially numbered, but counting every entry can take too much
	; time.
	S FIRST=+$O(READ("STACK","")) ; First command number in the stack
	S LAST=+$ZP(READ("STACK","")) ; Last     "      "    "   "    "
	I (FIRST=LAST)&(FIRST=0) S NUMBER=0 Q  ; Empty stack
	S NUMBER=LAST-FIRST+1
	Q
	;
PROCESS	;========== Process input until <CR>,<DO>, or ^Z
	S DONE=0
	D GETSTR
	I STR'="" D NEWSTR S STR="" ;  Any input?
	S READ("ZB")=ZBF ;  Save ZB for possible external use
	;
	I ZBF=12 D PRINSTK G PROCESS ;  ^L(ist the command stack)
	I ZBF=13 D STACK Q  ;  Done
	I ZBF=16 D PROGRAM G PROCESS ;  ^P(rogram the soft keys)
	I ZBF=20 D TRANS,SHOWIT G PROCESS ;  ^T(ranslate to upper case)
	I ZBF=21 F I=1:1:COLM D DELETE ; ^U
	I ZBF=21 G PROCESS
	I ZBF=23 D SHOWIT G PROCESS ; ^W(rite the command line)
	I ZBF=26 D STACK Q  ;    ^Z, done
	I ZBF=27 D GETKEY Q:DONE  G PROCESS
	I ZBF=127 D DELETE G PROCESS ; DEL
	I ZBF=0 D STACK Q  ; Timed out on the read, or no terminator
	S GOLD=0
	G PROCESS
	;
EXIT	S GOLD=1 D RIGHT ; Put cursor at the end of the input
	S READ("OVER")=OVER ; Save mode
	D ASCII,OVER Q  ; Return settings to a more 'normal' state, quit
	;
STACK	;========== Put READ onto the stack, ready for exit
	S DONE=1,X=READ
	Q:READ=""
	N I,FIRST,LAST,NUMBER
	D STAKSIZ
	I NUMBER=0 S READ("STACK",LAST+1)=READ ; Empty stack?
	E  I READ("STACK",LAST)'=READ S READ("STACK",LAST+1)=READ,NUMBER=NUMBER+1
	I NUMBER>READ("STACK") K READ("STACK",FIRST) ; Stack is full, trim it
	Q
	;
GETSTR	;========== Input handler . . .
	;
	;R STR:90 E  S (ZB,ZBL,ZBF)=0 Q
	;R STR:50000
	N $ZT
	S $ZT="G GETSTRE"
	S (ZB,ZBL,ZBF)=0
	U $P:(NOECHO:CEN:CTRAP=$C(3):EXC="G GETSTRE")
	N X
	S STR=""
GETSTR1	R *X:3600
	E  S (ZB,ZBL,ZBF)=0 G GETSTRE
	I X=27 S X=0 				; GT.M V3.1-1 X returns value
	S ZB=$ZB
	I X,X<32!(X=127) S ZB=$C(X) ; Control characters and rub
	E  I ZB="" S STR=STR_$C(X) W $C(X) G GETSTR1
	S ZBF=$A($E(ZB,1,1)) ; First byte
	S ZBL=$A($E(ZB,$L(ZB))) ; Last byte
	;
GETSTRE	U $P:(ECHO:EXC="")
	Q
	;
GETKEY	;========== Process escape sequences
	D ESCN
	S READ("ZB")=ZB
	I ZB=65 D UP Q
	I ZB=66 D DOWN Q
	I ZB=67 D RIGHT Q
	I ZB=68 D LEFT Q
	I ZB=28 D HELPTXT Q
	I ZB=29 D STACK Q
	I ZB=1 D FIND Q
	I ZB=2 D ALTMODE Q
	I ZB=3 D REMOVE Q
	I ZB=4 D SELECT Q
	I ZB=5 D PREV Q
	I ZB=6 D NEXT Q
	I ZB=80 S GOLD='GOLD Q  ; PF1 (gold) key toggle
	; Is it a defined key?
	N STR
	S STR=$G(READ("KEY",ZB))
	I STR="" Q  ; 
	;
	N TERM
	S TERM=$G(READ("KEY",ZB,"TERM")) ; Terminated string?
	D NEWSTR S STR="" D SHOWIT
	I TERM S (ZB,ZBF)=13 D STACK ; Get ready to exit
	Q
	;
ESCN	;========== For escape sequences only
	;
	I ZBL=126 S ZB=+$E(ZB,3,9) Q  ; Tilda?
	S ZB=ZBL Q
	;
NEWSTR	;========== Insert or replace a character in the READ string.
	I OVER D REPCHAR Q
	D INSCHAR Q
	;
INSCHAR	;========== Insert the character(s) at cursor.
	S READ=$E(READ,1,COLM)_STR_$E(READ,COLM+1,$L(READ))
	S COLM=COLM+$L(STR) Q
	;
REPCHAR	;========== Overwrite the current character(s) with STR
	S READ=$E(READ,1,COLM)_STR_$E(READ,COLM+1+$L(STR),$L(READ))
	S COLM=COLM+$L(STR) Q
	;
UP	;========== Backwards thru the stack
	I GOLD S GOLD=0 S STACKNUM=$O(READ("STACK",""))
	E  S STACKNUM=$ZP(READ("STACK",STACKNUM))
	D UPDOWN Q
	;
DOWN	;========== Forwards thru the stack
	I GOLD S GOLD=0 S STACKNUM=$ZP(READ("STACK",""))
	E  S STACKNUM=$O(READ("STACK",STACKNUM))
	D UPDOWN Q
	;
UPDOWN	;========== Display the current stack entry
	I STACKNUM="" S READ=""
	E  S READ=READ("STACK",STACKNUM)
	D SHOWIT Q
	;
PREV	;========== Goto previous word
	;
	I COLM=0 S GOLD=0 Q  ; No place left to go?
	N CHARS,I,INWORD,ISDEL,DONE
	S INWORD=0 ; No, we're not inside a word...
	S CHARS=0,DONE=0
	F I=COLM-1:-1:0 D PREV1 Q:DONE
	I CHARS<1 Q
	S COLM=COLM-CHARS
	D LEFT0
	Q
PREV1	;=====
	;
	S CHARS=CHARS+1
	S ISDEL=($E(READ,I)'?1AN)
	I 'ISDEL S INWORD=1 Q
	I INWORD S DONE=1
	Q
	;
NEXT	;========== Goto Next word
	I COLM=$L(READ) S GOLD=0 Q  ; No place right to go
	;
	N CHARS,I,INWORD,ISDEL,DONE
	S INWORD=($E(READ,COLM+1)?1AN) ; Are we inside a word...
	S CHARS=-1,DONE=0
	F I=COLM+1:1:$L(READ)+1 D NEXT1 Q:DONE
	I CHARS=0 Q
	S COLM=COLM+CHARS
	D RIGHT0
	Q
NEXT1	;=====
	;
	S CHARS=CHARS+1
	S ISDEL=($E(READ,I)'?1AN)
	I ISDEL,INWORD S INWORD='INWORD Q
	E  I 'ISDEL,'INWORD S DONE=1
	Q
	;
LEFT	;========== Try to move cursor to the left
	I COLM=0 S GOLD=0 Q  ; No place left to go
	N CHARS
	I GOLD S CHARS=COLM,GOLD=0  ; Calculate how far to go
	E  S CHARS=1
	S COLM=COLM-CHARS
LEFT0	S DATA=$C(27)_"["_CHARS_"D" D OM,PRINTOM Q
	;
RIGHT	;========== Try to move cursor to the right
	I COLM=$L(READ) S GOLD=0 Q  ; No place right to go
	N CHARS
	I GOLD S CHARS=$L(READ)-COLM,GOLD=0 ; Calculate how far to go
	E  S CHARS=1
	S COLM=COLM+CHARS
RIGHT0	S DATA=$C(27)_"["_CHARS_"C" D OM,PRINTOM Q
	;
REMOVE	;========== Remove/UnRemove string
	I GOLD G REMOVE1
	I COLM=$L(READ) G REMOVE2
	S FHALF=$E(READ,1,COLM),LHALF=$E(READ,COLM+1,$L(READ))
	S READ=FHALF
	S:LHALF'="" READ("REMOVE")=LHALF
	S DATA=$C(27)_"["_$L(LHALF)_"P" D OM,PRINTOM Q
	;
REMOVE1	; Insert REMOVE buffer at current position.  The cursor stays put.
	Q:READ("REMOVE")=""  ; Nothing to insert
	N OCOLM S OCOLM=COLM N COLM S COLM=OCOLM
	S GOLD=0,STR=READ("REMOVE")
	I $L(STR)+$L(READ)>510 W *7 Q  ; Would be too long, stop here
	D CURSAV,NEWSTR W STR D CURRST Q
	;
REMOVE2	; Remove the first word going backwards
	D PREV ; Go to the previous word...
	Q:COLM=$L(READ)  ; Prevent infinite loop...
	D REMOVE ; Remove this stuff
	Q
	;
FIND	;========== Find a command that contains user specified string
	; Search is CASE-BLIND, going from the current stack number to the
	; beginning of the stack.
	N X,FIND,POS
	I GOLD S GOLD=0 ; Use previous input for search
	E  D TRANS S READ("FIND")=READ,READ("FIND",0)=0 ; Force upper case
	S FIND=READ("FIND")
	Q:FIND=""  ; Can't search for null string
	I STACKNUM'="" G FIND2 ; See if there's more occurrences in this string
FIND1	;
	S STACKNUM=$ZP(READ("STACK",STACKNUM))
	I STACKNUM="" S READ="" D SHOWIT Q  ; No more data to search through
FIND2	;
	S READ=READ("STACK",STACKNUM) D TRANS
	S READ("FIND",0)=$FIND(READ,FIND,READ("FIND",0))
	I 'READ("FIND",0) G FIND1 ; Not in this string, get another
	S READ=READ("STACK",STACKNUM) ; Reset to possibly mixed case text
	D SHOWIT,CUROFF S GOLD=1 D LEFT ; This is a wimpy way of doing it...
	S COLM=READ("FIND",0)-$L(FIND)-1 ; Place cursor at beginning of string
	S CHARS=COLM
	I CHARS>0 D RIGHT0
	Q  ; Found one
	;
SELECT	;========== Select a section of the input string to be removed
	Q  ;  Not yet implemented
	;
DELETE	;========== Delete/UnDelete a single character
	I GOLD G DELETE1
	Q:COLM=0
	I 'OVER D OVER
	W $C(27)_"[1D"_$C(27)_"[1P"
	S READ("DELETE")=$E(READ,COLM) ; Save the character
	S READ=$E(READ,1,COLM-1)_$E(READ,COLM+1,$L(READ))
	S COLM=COLM-1
	I 'OVER D INSERT
	Q
	;
DELETE1	; Insert DELETE buffer at current position
	N OLDOVER S OLDOVER=OVER,OVER=0 D INSERT
	S GOLD=0,STR=READ("DELETE") D NEWSTR W STR
	I OLDOVER'=OVER D ALTMODE
	Q
	;
TRANS	;========== Translate to upper case, redisplay
	S READ=$TR(READ,"abcdefghijklmnopqrstuvwxyz","ABCDEFGHIJKLMNOPQRSTUVWXYZ")
	Q
	;
ALTMODE	;========== Alternate between INSERT and OVERSTRIKE modes
	S OVER='OVER
	I 'OVER W *7 D INSERT Q  ; Bell for insert mode.
	D OVER Q
	;
INSERT	W $C(27)_"[4h" Q  ; Terminal set to insert     mode
OVER	W $C(27)_"[4l" Q  ; Terminal set to overstrike mode
	;
PROGRAM	;========== Program soft keys
	; Note: very sloppy
	D GRAPHIX
	N STR,HEX,X,Y,Z,IO,OPEN,CLEAR,FIRST
	S HEX="" D PROG1,SHOPROM,CONTROL Q
PROG1	;
	N OPROMPT,OREAD
	S OPROMPT=READ("PROMPT"),OREAD=READ
	;
PROG10	S FIRST=1 ; Used for FILE mode
	S CLEAR=1 ; Default, clear only keys as they are defined.
	I $D(IO) S X=IO
	S READ("PROMPT")="<CR> for terminal, or enter an RMS file name: "
	D ^%READ I X="" G PROG19
	S IO=X D OPENNEW Q:'OPEN
	S CLEAR=0 ; Clear all keys first, then define them
	;
PROG19	N COLM,KEY,TASK,I,J,K
	S X=""
PROG2	;
	S KEY=""
	S READ="",COLM=0
	S READ("PROMPT")="Press the function key to be programmed: "
	W ! D SHOPROM,GETSTR
	I ZBF=13 S READ("PROMPT")=OPROMPT,READ=OREAD C:$D(IO) IO Q
	D ESCN
	I ZB<17!(ZB>34) W !,"Only F6 through F20 can be programmed",! G PROG2
	S KEYN=ZB
	S KEY=$S(ZB<22:"F"_(ZB-11),ZB<27:"F"_(ZB-12),ZB=28:"Help",ZB=29:"Do",1:"F"_(ZB-14))
	W KEY D PROG3 G PROG2
	;
PROG3	W !,"Press DO key when you are done progamming the function key:",!
	S READ("PROMPT")="",READ="",X=""
	D SHOPROM,CONTROL
	;
PROG4	D GETSTR
	I ZBF=13 D SHOWCR G PROG4 ; Display the carriage return
	I STR'="" D NEWSTR
	I ZBF=26 G PROGDUN ;  ^Z
	I ZBF=127 D DELETE G PROG4 ; <DEL>
	I ZBF=12 D PRINSTK G PROG4 ; ^L
	I ZBF=20 D TRANS,SHOWIT G PROG4 ; ^T
	D ESCN G:ZB=0 PROG4 ;  Escape sequences
	I ZB=29 G PROGDUN ;  DO key
	I ZB=65 D UP G PROG4
	I ZB=66 D DOWN G PROG4
	I ZB=67 D RIGHT G PROG4
	I ZB=68 D LEFT G PROG4
	I ZB=2 D ALTMODE G PROG4
	I ZB=3 D REMOVE G PROG4
	G PROG4
	;
PROGDUN	;
	D STACK S DONE=0 ; Put command on the stack
	I READ="" S TASK=" cleared"
	E  S TASK=" = "
	I $D(IO) U IO
	S I=READ,K=""
	F J=1:1:$L(I) S:$E(I,J)'=$C(13) K=K_$E(I,J) D:$E(I,J)=$C(13) CR
	W !,KEY_TASK_K_"          "
	S Y=READ
	D HEX S HEX=KEYN_"/"_Y
	; Directly to the terminal?
	I $D(IO),FIRST S FIRST=0 D GRAPHIX W $C(27)_"P"_CLEAR_";1|"_$C(27)_"\" S CLEAR=1
	W $C(27)_"P"_CLEAR_";1|"_HEX_$C(27)_"\"
	I $D(IO) U $P D CONTROL
	Q
	;
HEX	S L=$L(Y),Z=""
	F J=1:1:L S A=$A(Y,J),A1=A\16,A2=A#16 S:A2>9 A2=$C(55+A2) S Z=Z_A1_A2
	S Y=Z
	Q
	;
SHOWCR	;========== Display the CR character
	S STR=STR_$C(13) D NEWSTR S STR=""
	W $C(14)_$C(100)_$C(15) Q
CR	S K=K_$C(14)_$C(100)_$C(15) Q
	;
GRAPHIX	; SPECIAL GRAPHICS AS G1 to display carriage return
	W $C(27)_")0" Q
	;
CURSAV	W $C(27)_"7" Q  ; Save Cursor Position
CURRST	W $C(27)_"8" Q  ; Restore Cursor Position
	;
SHOPROM	W ! D SHOWIT Q
SHOWIT	;========== Display the prompt and the current string
	D:'OVER OVER
	W $C(27)_"[132D"_READ("PROMPT")_READ_$C(27)_"[0K" S COLM=$L(READ)
	D:'OVER INSERT
	Q
	;
PRINSTK	;========== Print the command stack
	N I,J,K
	W !!,"Input stack:",!
	S I=""
	F J=1:1 S I=$O(READ("STACK",I)) Q:I=""  S K=READ("STACK",I) W:K'="" !,"    "_K
	W ! D SHOPROM Q
	;
OPENNEW	;========== Open new RMS file named in IO
	S OPEN=0
	O IO:(WRITE:NEWV):5 E  W !,"Unable to open file "_IO Q
	S OPEN=1 Q
	;
CONTROL	;========== Use all control characters as terminators
	I OVER D OVER
	I 'OVER D INSERT
	; Control Terminators, Breaks enabled
	U $P:(ESCAPE:ECHO:TERM=$C(127)) ; Fix with GT.M 2.5-FT1
	Q
	;========== 'Normal' terminal mode
ASCII	D OVER U $P:(ESCAPE:ECHO:TERM="") Q
	;
HELPTXT	;==========
	W !
	W !," <X] - Delete one character   ^W - Write current line"
	W !,"  ^L - List the input stack   ^P - Program function key(s)"
	W !
	W !," Edit Keys       Function ( * indicates key can be used with <PF1> key )"
	W !,"-----------     --------------------------------------------------------"
	W !,"<Return>        * Process this line"
	W !,"Find            * Search previous input for a specified string"
	W !,"Insert Here       Insert & Overstrike toggle"
	W !,"Remove          * Delete text from the cursor to the end of the line"
	W !,"Prev Screen       Move cursor one word to the left"
	W !,"Next Screen       Move cursor one word to the right"
	W !,"Arrow keys      * Move cursor left, right, up, and down"
	W !
	;
	D SHOPROM Q
	;
	;========== BUFFERED I/O PROCESSING
OM	; Append to OM array
	I 500<($L(DATA)+$L(OM(OM))) D NEXTOM
	S OM(OM)=OM(OM)_DATA,DATA="" Q
	;
NEXTOM	; Next OM subscript.  Print it if there's too many.
	I OM>100 D PRINTOM Q
	S OM=OM+1,OM(OM)="" Q
	;
PRINTOM	; Print OM() and reset it.
	N I,J
	S I="" D CUROFF
	F J=0:0 S I=$O(OM(I)) Q:I=""  W:$L(OM(I)) OM(I)
	D KILLOM,CURON Q
	;
KILLOM	; Reset OM() and DATA.
	K OM S OM=1,OM(OM)="",DATA="" Q
	;=======================================================================
	;
CUROFF	W $C(27)_"[?25l" Q  ; Cursor off
CURON	W $C(27)_"[?25h" Q  ; Cursor on
	;
CURABS	W $C(27)_"["_DY_";"_DX_"H" Q  ; Absolute cursor position
IOCPBOT	W $C(27)_"[0J" Q  ;   Clear page to bottom
IOCPTOP	W $C(27)_"[1J" Q  ;   Clear page to top
IOCPALL	W $C(27)_"[2J" Q  ;   Clear page all
IOCL	W $C(27)_"[2K" Q  ;   Clear line all
IOCLR	W $C(27)_"[0K" Q  ;   Clear line, remaining
IOREV1	W $C(27)_"[7m" Q  ;   Reverse video on
IOREV0	W $C(27)_"[27m" Q  ;   No reverse video
IOSAV	W $C(27)_"7" Q  ;   Save Cursor Position
IORST	W $C(27)_"8" Q  ;   Restore Cursor Position
IOCC	W $C(27)_"["_LEN_"X" Q  ;  Erase next 'LEN' characters
IOKPAM	W $C(27)_$S(KPAM:"=",1:">") Q  ; KeyPad Application Mode
	;
