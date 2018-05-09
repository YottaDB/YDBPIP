%ZSHELL	;%ZSHELL; MUMPS Command Line Editor
	;;Copyright(c)1989 Sanchez Computer Associates, Inc.  All Rights Reserved - 29 DEC 1989 12:42:23 - BALDWIN
	;
	N zzz ; Input command
	S zzz="" ; Default command value
	I '$D(READ("RD")) S READ("RD")=$$MRTNS^%LNM ; Directory for routines
	I '$D(READ("TRAP")) S READ("TRAP")=""
	D PROMPT,ABORT Q
	;
PROMPT	;========== Ask for commands
	N $ZT S $ZT="B"
PROMPT1	;
	I $G(READ("TRAP"))'="" S $ZT=READ("TRAP") ; Default is 'Break'
	; Unwind calling stack to this level, and Goto tag ZT
	E  S $ZT="ZGOTO "_$ZLEVEL_":ZT^%ZSHELL"
	U $P:NOEDIT
	S zzz=""
	S zzz=$$PROMPT^%READ(($ZL-2)_"> ",zzz)
	Q:READ("ZB")=26  ; Control-Z, exit from the shell
	G:zzz="" PROMPT1 ; No input, don't execute
	D ANSI W !
	;
	I $G(READ("IO","OPEN")) U $G(READ("IO")) ; Redirect output?
	; Extended commands:
	I $$EXTEND(.zzz) ; Can modify it, so pass by address, ignore status
	I $G(READ("HIDE"))'="" S zzz="N "_READ("HIDE")_" "_zzz ; Hide variables?
	D EXE ; Execute the command
	U $P:NOEDIT
	G PROMPT1
	;
ZT	;===== Default error trap
	D ANSI W !
	S READ("ertyp")=$$ETLOC^%ZT ; Get error type and location
	; Note: GT.M specific error handling
	I READ("ertyp")["INTERRUPT" G PROMPT1 ; Interrupt?
	I READ("ertyp")["NOROUTINE" W $P($ZS,",",4) G PROMPT1 ; Missing routine
	I READ("ertyp")["NOLINE" W $P($ZS,",",4) G PROMPT1 ; Missing tag
	I READ("ertyp")["STACKCRIT" W $P($ZS,",",4) Q  ; Framestack error, quit now
	D ZTDSP
	G PROMPT1
	;
EXE	X zzz Q  ;
	;
ZTDSP	;==========
	N PGM,TAG,OFFSET,HIGH,LOW,I,A,B,ZE,ERROR,DSP
	S ZE=$ZS
	S ERROR=$P(ZE,",",2)
	S PGM=$P($P(ZE,"^",2),",",1)
	S TAG=$P($P(ZE,",",2),"^",1)
	S OFFSET=+$P(TAG,"+",2)
	S TAG=$P(TAG,"+",1)
	; Was it an error in the execution string?
	I TAG="EXE"&(PGM="%ZSHELL") W " "_zzz,!,$P(ZE,",",4) Q
	I TAG=PGM!(TAG="") S LOW=OFFSET,HIGH=OFFSET
	E  S LOW=OFFSET-2,HIGH=OFFSET+2 ; Give a frame of reference around error
	I LOW<0 S LOW=0 ; Don't go back further than the tag
	S A=" -> ",B="    " ; Will point to error
	W B_$P(ZE,",",2)_": "_$P(ZE,",",4),!
	I PGM'="" S PGM="^"_PGM
	S DSP="W:LOW'=0 B_$T("_TAG_PGM_"),! W ! F I=LOW:1:HIGH W $S(I'=OFFSET:B,1:A)_$T("_TAG_"+I"_PGM_"),!"
	X DSP
	Q
	;=======================================================================
	;
EXTEND(zzz)	;========== Extended Command Processing
	;
	N zstatus
	S zstatus=-1
EXT	; Process next extended command
	; If a routine recognizes itself by command, it will remove that
	; command and any parameters from "zzz", and we'll go back to try the
	; next string.
	;
	S zstatus=zstatus+1 ; Increment command counter
	I $L(zzz)=0 Q zstatus  ; No more input to process?
	;
	I $$ASK(.zzz) G EXT ; Prompt for a variable?
	I $$DATE(.zzz) G EXT ; Convert Date to string?
	I $$EDIT(.zzz) G EXT ; Jump into the editor?
	I $$EXAM(.zzz) G EXT ; Examine variable(s)?
	I $$FIND(.zzz) G EXT ; Find variables which contain specific values?
	I $$FUNC(.zzz) G EXT ; Show a function from ^SCATBL?
	I $$HELP(.zzz) G EXT ; Command help?
	I $$HIDE(.zzz) G EXT ; Hide variables?
	I $$LINE(.zzz) G EXT ; Source Code Manipulation?
	I $$LINK(.zzz) G EXT ; Source Code Manipulation?
	I $$LOAD(.zzz) G EXT ; 'Load' a default program?
	I $$OUTPUT(.zzz) G EXT ; Redirect Output to a device?
	I $$PRINT(.zzz) G EXT ; Print some text
	I $$RFIND(.zzz) G EXT ; Find some text?
	I $$ROUDIR(.zzz) G EXT ; Routine Directory?
	I $$SHOW(.zzz) G EXT ; Show variable(s)?
	I $$TRAP(.zzz) G EXT ; Enable/disable error trap?
	I $$VMS(.zzz) G EXT ; VMS command?
	I $$WIDTH(.zzz) G EXT ; Toggle screen width?
	I $$WRITE(.zzz) G EXT ; Argumentless Write?
	; Didn't recognize the current command
	Q zstatus  ; Return # commands recognized
	;
	;=======================================================================
	;
FIND(zzz)	;========== Find Variables and Values
	;
	; Search the symbol table for subscript values and data which match the
	; input pattern.  Uses the remainder of the input line as the pattern.
	;
	N zzz1,%lev,%name,%data,%
	I '$$MATCH(zzz,"FIND",2) Q 0  ; Not a FIND command
	S zzz1=$P(zzz," ",2,999) ; Strip off this command
	S zzz=""
	N zzz ; Hide the input variable
	I zzz1="" ZWRITE  Q 1  ; Just dump the symbol table and quit
	S zzz1="*"_zzz1_"*" ; Universal wildcard: can appear anywhere
	S zzz1=$$WILDCARD(zzz1) ; Translate to a PATTERN match
	;
	; % is the variable name
	; %(n) is the subscript value for level N
	S %="%"
	S %lev=-1
	;
FIND1	;===== Find the next variable...
	;
	X "N %lev,%name,%data,zzz1 S %=$O(@%)" ; Have to hide our variables
	;
	I %="" Q 1  ; Done with the table?
	I %="%" G FIND1 ; Ignore the percent variable...
	S %lev=-1
	;
FIND2	;=====
	S %lev=%lev+1 ; Step down one level
	S %(%lev)="" ; start with null subscript
	;
FIND3	;=====
	S %name=$$NAME(%,.%,%lev) ; Construct name
	I %lev=0 G FIND30 ; First level, don't order
	S %(%lev)=$O(@%name) ; Get next reference at this level
	I %(%lev)="" G FIND4 ; No more data at this level?
	S %name=$$NAME(%,.%,%lev) ; Construct name
	;
FIND30	;
	S %data=$G(@%name)
	I %name?@zzz1!(%data?@zzz1) W !,%name_" = "_%data
	I $D(@%name)>1 G FIND2 ; Descendant data?  Go down one more level
	I %lev'=0 G FIND3
	;
FIND4	;=====
	;
	S %lev=%lev-1
	I %lev<1 G FIND1 ; Back at the top?  Get next variable...
	S %name=$$NAME(%,.%,%lev) ; Construct name with new subscript value...
	G FIND3 ; Loop through previous level...
	;=======================================================================
	;
EXAM(zzz)	;========== Examine Variable(s)
	;
	N zzz0,zzz1,zzz2,zzz3,zzz4,zzz5,zzz6,zzz7
	;
	S zzz1=$$UC($P(zzz," ",1))
	I '$$MATCH(zzz,"EXAMINE",2) Q 0  ; Not an EXAMINE command?
	D PARSE(.zzz," ",2,.zzz0,.zzz1)
	I zzz1="" ZWR  Q 1  ; Just dump the symbol table and quit
	S zzz2=$L(zzz1,",") ; How many variables?
	F zzz3=1:1:zzz2 D EXAM1
	Q zzz3  ; Return the number of successful examines performed.
	;
EXAM1	;===== Singe variable examination
	;
	N zzz4,zzz5,zzz6,zzz7
	S zzz4=$P(zzz1,",",zzz3)
	S zzz7=0 ; NOT a negated pattern match
	; Translate to a PATTERN match, and allow negated logic
	S zzz5=$$WILDCARD(zzz4,.zzz7)
	;
	N %
	S %="%"
	; Loop thru the symbol table.
	F zzz6=0:0 S %=$O(@%) Q:%=""  D EXAM2
	Q
	;
EXAM2	;===== Does it match the pattern?
	;
	I 'zzz7,%'?@zzz5 Q  ; Fails to match the pattern
	I zzz7,%?@zzz5 Q  ; Matches the pattern, BUT looking for non-match
	X "N ("_%_") ZWR" ; Dump that symbol
	Q  ; Go back for more
	;=======================================================================
	;
ROUDIR(zzz)	;========== Routine Directory with Wildcard
	;
	N (zzz,READ)
	;
	S zzz1=$$UC($P(zzz," ",1))
	I '$$MATCH(zzz,"RD",2) Q 0  ; Not a Routine Directory command?
	D PARSE(.zzz," ",2,.zzz0,.zzz1)
	S zzz2=$L(zzz1,",") ; How many patterns
	F zzz3=1:1:zzz2 D ROUDIR1
	Q 1
	;
ROUDIR1	;===== Single routine examination
	;
	S zzz4=$P(zzz1,",",zzz3)
	ZSY "DIR "_$G(READ("RD"))_zzz4 ;
	Q
	;=======================================================================
	;
EDIT(zzz)	;========== Edit a routine
	;
	N (zzz,READ)
	I '$$MATCH(zzz,"EDIT",2) Q 0  ; Not an Edit command?
	D PARSE(.zzz," ",2,.zzz0,.zzz1)
	I zzz1="" S zzz1=$G(READ("LOAD")) ; Use default program
	I zzz1'="" S READ("LOAD")=zzz1
	ZEDIT zzz1
	ZLINK $TR(zzz1,"%","_")
	Q 1
	;=======================================================================
	;
LOAD(zzz)	;========== 'Load' a Program: Actually sets default program
	;
	N (zzz,READ)
	I '($$MATCH(zzz,"LOAD",3)!$$MATCH(zzz,"ZLOAD",2)) Q 0  ; Not a Load command?
	D PARSE(.zzz," ",2,.zzz0,.zzz1)
	S READ("LOAD")=zzz1
	Q 1
	;
LINK(zzz)	;========== Link a Program
	;
	N (zzz,READ)
	I '($$MATCH(zzz,"LINK",2)!$$MATCH(zzz,"ZLINK",3)) Q 0  ; Not a Link command?
	D PARSE(.zzz," ",2,.zzz0,.zzz1)
	S READ("LOAD")=zzz1
	I zzz1["%" S zzz1=$TR(zzz1,"%","_") ; Percent to underscore
	ZLINK zzz1
	Q 1
	;
	;=======================================================================
	;
WRITE(zzz)	;========== Argumentless WRITE
	;
	N zzz0,zzz1,zzz2
	I '$$MATCH(zzz,"WRITE",1) Q 0  ; Not a Write command?
	S zzz1=$P(zzz," ",2)
	I zzz1'="" Q 0  ; Not an argumentless write?
	S zzz=$P(zzz,2,999)
	S zzz2=""
	I $G(READ("HIDE"))'="" S zzz2="N "_READ("HIDE")
	S zzz2="N zzz1,zzz2 "_zzz2
	I zzz1="" X zzz2_" ZWRITE  " Q 1
	X zzz2_" WRITE "_zzz1
	Q 1
	;
	;=======================================================================
	;
SHOW(zzz)	;========== Show Variable(s)
	;
	N zzz0,zzz1,zzz2,zzz3
	I '$$MATCH(zzz,"SHOW",2) Q 0  ; Not a Show command?
	D PARSE(.zzz," ",2,.zzz0,.zzz1)
	I zzz1="" Q 1  ; Can't show nothing, can we?
	S zzz2=$L(zzz1,",") ; How many variables?
	F zzz3=1:1:zzz2 D SHOW1($P(zzz1,",",zzz3))
	Q 1
	;
SHOW1(zzz)	;========== Show A Single Variable
	;
	Q:zzz=""  ; No variable
	W !," "_zzz ; Print the name
	I '$D(@zzz) W " does not exist" Q  ; Exists?
	W " Length="_$L($G(@zzz))
	I $D(@zzz)>9 W ", has descendant data"
	W !," "_zzz_"="_$G(@zzz),! ;
	Q
	;=======================================================================
	;
ASK(zzz)	;========== Prompt For Variable Value
	;
	N zzz0,zzz1
	I '$$MATCH(zzz,"ASK",1) Q 0  ; Not an Ask command?
	D PARSE(.zzz," ",2,.zzz0,.zzz1)
	I zzz1="" Q 1  ; Can't ask for nothing, can we?
	S @zzz1=$G(@zzz1)
	S @zzz1=$$PROMPT^%READ(zzz1_": ",@zzz1)
	Q 1
	;=======================================================================
	;
HIDE(zzz)	;========== Hide Variable(s)
	;
	; Example: HIDE var1,var2  will add var1 and var2 to the HIDE list
	;          HIDE -          will remove all variables from the HIDE list
	;          HIDE            will display the HIDE list
	;
	N zzz0,zzz1,zzz2,zzz3,zzz4,zzz5
	I '$$MATCH(zzz,"HIDE",2) Q 0  ; Not a Hide command?
	D PARSE(.zzz," ",2,.zzz0,.zzz1)
	I zzz1="",$G(READ("HIDE"))="" W "There are no hidden variables",! Q 1
	I zzz1="" W "Hidden variables: "_$G(READ("HIDE")),! Q 1  ; Display the list
	I zzz1="-" K READ("HIDE") W "Hidden variables are now visible",! Q 1
	S zzz2=$L(zzz1,",") ; How many variables?
	I $E(zzz1)="-" S zzz3=0,zzz1=$E(zzz1,2,$L(zzz1)) ; Remove minus sign
	E  S zzz3=1 ; Will be adding to the list
	S zzz5=$G(READ("HIDE"))
	F zzz4=1:1:zzz2 D HIDE1($P(zzz1,",",zzz4)) ; 
	S READ("HIDE")=zzz5 ; Save the HIDE list for later use
	Q 1
	;
HIDE1(zzz)	;========== Hide A Single Variable
	;
	Q:zzz=""  ; No variable
	I zzz5="" S zzz5=zzz ; First in the list?
	E  S zzz5=zzz5_","_zzz ; Add to the list
	Q
	;=======================================================================
	;
TRAP(zzz)	;========== Set/Clear Error Trap
	;
	N (zzz,READ)
	I '$$MATCH(zzz,"TRAP",2) Q 0  ; Not a Trap command?
	S zzz1=$P(zzz," ",2,999) ; Uses remainder of input line
	S zzz="" ; Show that we've used the whole line
	I zzz1="" W !,"Trap: "_$ZT Q 1  ; Show the current trap
	E  I zzz1="1" S NEWZT="" ; Force enabled trap
	E  I zzz1="0" S NEWZT="B" ; Force disabled trap
	E  S NEWZT=zzz1
	S READ("TRAP")=NEWZT
	I zzz1="0" W !,"Error trap disabled",! Q 1
	I zzz1="1" W !,"Error trap enabled",! Q 1
	W !,"Error trap set to "_NEWZT,!
	Q 1
	;=======================================================================
	;
WIDTH(zzz)	;========== Toggle screen width 80/132
	;
	N (zzz,READ)
	I '$$MATCH(zzz,"SW",2) Q 0  ; Not a Set Width command?
	D PARSE(.zzz," ",2,.zzz0,.zzz1)
	I '$D(READ("WIDTH")) S READ("WIDTH")=80 ; 
	I zzz1="" S zzz1=$S(READ("WIDTH")=80:132,1:80) ; Toggle width?
	I zzz1'=80&(zzz1'=132) Q 1  ; Invalid parameter?  Return without changing
	S READ("WIDTH")=zzz1 ; Save the new setting
	I zzz1=80 S char="l"
	E  S char="h"
	W $C(27)_"[?3"_char ; Sequence to change screen width
	Q 1
	;=======================================================================
	;
DATE(zzz)	;========== Display a Julian Date as a String
	;
	N zzz0,zzz1
	I '$$MATCH(zzz,"DATE",2) Q 0  ; Not a Date command?
	D PARSE(.zzz," ",2,.zzz0,.zzz1)
	I zzz1="" W $$^%ZD(+$H),! Q 1  ; Show the current date
	I zzz1?.E1"$H".E X "S zzz1="_zzz1 ; $H referenced, maybe with formula
	E  I zzz1'?1N.N S zzz1=$G(@zzz1) ; A variable specified?
	I zzz1="" W "Input date not defined",! Q 1
	W $$^%ZD(zzz1),!
	Q 1
	;=======================================================================
	;
OUTPUT(zzz)	;========== Define a default Output Device
	;
	N (zzz,READ)
	I '$$MATCH(zzz,"OUTPUT",2) Q 0  ; Not an output command?
	D PARSE(.zzz," ",2,.zzz0,.zzz1)
	I '$$OPEN(zzz1) Q 1  ; Can't open for some reason
	U $G(READ("IO"))  ; It's open, so use it
	Q 1
	;
	;=======================================================================
	;
LINE(zzz)	;========== Program Source Manipulations
	;
	N (zzz,READ)
	S zzz1=$$UC($P(zzz," ",1))
	I $L(zzz1)<2 Q 0  ; Need 2 characters to avoid ambiguity
	I zzz1=$E("LC",1,$L(zzz1)) S cmd="LC" G LINE1 ; Line Count command?
	I zzz1=$E("LT",1,$L(zzz1)) S cmd="LT" G LINE1 ; Line Tag command?
	I zzz1=$E("CE",1,$L(zzz1)) S cmd="CE" G LINE1 ; Comment Extraction command?
	Q 0
	;
LINE1	;===== It's a valid command: process it
	;
	N I
	D PARSE(.zzz," ",2,.zzz0,.zzz1)
	S SP=$C(32),SC=$C(59),Q=$C(34) ; Space, Semi-colon, and Quote characters
	I zzz1="" S zzz2=$G(READ("LOAD")) ; No program specified, use default
	E  S zzz2=zzz1
	I zzz2'="" S zzz2="^"_zzz2
	S x="F zzz3=0:1 S X=$T(+zzz3"_zzz2_") Q:'$L(X)  "
	;
	I cmd="LC" S x=x_"S zzz4=zzz4+$L(X) I $E(X)'=SP S zzz5=zzz5+1"
	I  S zzz4=0 ; Length (in bytes)
	I  S zzz5=0 ; Number of line tags
	;
	I cmd="LT" S x=x_"I $E(X)'=SP W X,!" ; Extract Line Tag Lines?
	;
	I cmd="CE" S x=x_"X xx" ; Comment extraction? Needs more Xecutes
	I  S xx="S IQ=0 F I=$L(X):-1:1 S J=$E(X,I) X xxx" ; Loop backwards thru text
	I  S xxx="S:J=Q IQ='IQ I J=SC,'IQ X xxxx" ; A non-quoted semi-colon?
	I  S xxxx="W !,$P(X,SP,1)_SP_$E(X,I+1,$L(X)) S I=0" ; Print line tag
	;
	X x
	I cmd="LT" Q 1  ; Nothing more to do with line tags
	I cmd="LC" W !,$FN(zzz3,",")_" lines, "_$FN(zzz4,",")_" bytes, "_$FN(zzz5,",")_" tags in "_zzz2
	Q 1
	;=======================================================================
	;
RFIND(zzz)	;========== Find a string in a Routine
	;
	; Search is CASE-BLIND
	N (zzz,READ)
	I '$$MATCH(zzz,"RFIND",2) Q 0  ; Not an RFind command?
	S zzz1=$P(zzz," ",2,999) ; Use the entire remaining string
	S zzz="" ; Show we used the entire line
	;
	S SP=$C(32),SC=$C(59),Q=$C(34) ; Space, Semi-colon, and Quote characters
	; If it doesn't contain any pattern matching characters, turn it into
	; a universal wildcard pattern.
	I zzz1'["*"&(zzz1'["?") S zzz1="*"_zzz1_"*"
	S zzz1=$$UC($$WILDCARD(zzz1)) ; Translate into pattern match, upper-case
	S zzz2=$G(READ("LOAD")); Grab the current program
	I zzz2'="" S zzz2="^"_zzz2
	S zzz4=0 ; Number of matches
	S x=""
	; Loop through the text
	S x=x_"F zzz3=1:1 S X=$T(+zzz3"_zzz2_") Q:'$L(X)  "
	S x=x_"X xx" ;
	S xx="I $$UC^%ZSHELL(X)?@zzz1 X xxx" ; This line contains the search string?
	S xxx="S zzz4=zzz4+1 W !,$J(zzz3,3)_SP_X" ; Print line number with it
	X x
	Q 1
	;=======================================================================
	;
PRINT(zzz)	;========== Print some Source Code 
	;
	N (zzz,READ)
	; Not an PRINT command?
	I ('$$MATCH(zzz,"PRINT",1))&('$$MATCH(zzz,"ZPRINT",1)) Q 0
	D PARSE(.zzz," ",2,.zzz0,.STR) ; Parse command string
	D PLR(STR,.FTAG,.FOFF,.PGM,.TTAG,.TOFF) ; Parse the label string
	X "ZPRINT "_FTAG_FOFF_PGM_":"_TTAG_TOFF
	Q 1
	;=======================================================================
	;
PLR(STR,FTAG,FOFF,PGM,TTAG,TOFF)	;========== Parse Label Range
	;
	N (STR,FTAG,FOFF,PGM,TTAG,TOFF,READ)
	;
	I STR'[":" S TTAG="",TOFF="+0" G PLR1 ; No range, possibly a TAG+X^PGM
	S TMP=$P(STR,":",2)
	S STR=$P(STR,":",1) ; Trim back string
	I TMP["-" S DELIM="-"
	E  I TMP["+" S DELIM="+"
	E  S DELIM=""
	I DELIM'="" S TTAG=$P(TMP,DELIM,1),TOFF=DELIM_$P(TMP,DELIM,2)
	E  S TTAG=TMP,TOFF="+0"
	;
PLR1	; Got the 'to' pieces set, now get the 'from' parts
	;
	I STR'["^" S PGM=$G(READ("LOAD"))
	E  S PGM="^"_$P(STR,"^",2),STR=$P(STR,"^",1)
	I STR["-" S DELIM="-"
	E  I STR["+" S DELIM="+"
	E  S DELIM=""
	I DELIM'="" S FTAG=$P(STR,DELIM,1),FOFF=DELIM_$P(STR,DELIM,2)
	E  S FTAG=STR,FOFF="+0"
	;
	; New program becomes the default
	I PGM'="",$G(READ("LOAD"))'=PGM S READ("LOAD")=PGM
	I TTAG="" S TTAG=FTAG ;
	I PGM'="",PGM'["^" S PGM="^"_PGM
	Q
	;
FUNC(zzz)	;========== Show a Function Definition
	;
	N (zzz,READ) ; 
	I '$$MATCH(zzz,"FUNCTION",2) Q 0  ; Not a Function command?
	D PARSE(.zzz," ",2,.zzz0,.zzz1)
	S zzz2=$L(zzz1,",") ; How many functions?
	F zzz3=1:1:zzz2 D FUNC1
	Q 1
	;
FUNC1	;===== Look for a function (with wildcard)
	;
	S zzz4=$P(zzz1,",",zzz3) ; Extract this function
	S zzz5=$$WILDCARD(zzz4,0,.zzz8) ; Translate to wildcard
	S zzz6="" ;
	F zzz7=0:1 S zzz6=$O(^SCATBL(1,zzz6)) Q:zzz6=""  D FUNC2
	Q  ; Done with this loop
	;
FUNC2	;===== Check the pattern match
	;
	I zzz6'?@zzz5 Q  ; 
	S zzz7=$G(^SCATBL(1,zzz6))
	W !,$J(zzz6,12)_"  ( Calls "_$P(zzz7,"|",4)_" ) "_$P(zzz7,"|",1)
	Q  ; Done with this entry
	;
VMS(zzz)	;========== Try VMS DCL command
	N (zzz)
	I '$$MATCH(zzz,"$",1) Q 0  ; Not start with $ ?
	S zzz=$E(zzz,2,$L(zzz)) ; Strip dollar sign
	F I=0:0 Q:$E(zzz)'=" "  S zzz=$E(zzz,2,$L(zzz))
	ZSY zzz ; Spawn the subprocess
	S zzz=""
	Q 1
	;
UC(T)	Q $TR(T,"abcdefghijklmnopzrstuvwxyz","ABCDEFGHIJKLMNOPQRSTUVWXYZ")
	;
ABORT	D ANSI Q
ANSI	U $P:(ESCAPE:ECHO) Q  ; ANSI protocol ?
	;
OPEN(DEVICE)	;========== Attempt to Open DEVICE for Output
	;
	; 1. If the device is already open, return true
	; 2. If another device is already open, close it
	; 3. If the open fails, return false
	; 4. If the open succeeds, save the device name in READ("IO")
	;
	N (DEVICE,READ)
	; The 'Logical' device name is saved for comparison
	I $G(READ("IO","LOGNAM"))=$G(DEVICE) Q 1  ; Already open?  Return now
	I $G(READ("IO","OPEN")) D CLOSE(READ("IO")) ; Close old device
	;
	I DEVICE="" U $P K READ("IO") Q 1  ; No device specified?  Ok, too.
	;
	; Prepare to call SCAIO for device handling...
	S ZB=13,%EXT=1,ER=0,RM="",X=$G(DEVICE)
	D ^SCAIO
	I ER K READ("IO") Q 0  ; Failed validation, return false
	S IOPAR="WRITE/NEWV"
	D OPEN^SCAIO
	I ER K READ("IO") Q 0  ; Failed open, return false
	S READ("IO")=IO ; Save the PHYSICAL device name here
	S READ("IO","LOGNAM")=$G(DEVICE) ; Save the LOGICAL device name here
	S READ("IO","OPEN")=1 ; Indicate that it's already open
	Q 1  ; All's well
	;
CLOSE(DEVICE)	;========== Attempt to Close DEVICE
	;
	N (DEVICE,READ)
	;
	C DEVICE ; Close it
	S READ("IO","OPEN")=0 ; Show READ structure that it's closed
	Q  ; All's well
	;
WILDCARD(IN,NEGATE,MIN)	;========== Make an executable Pattern Matcher
	;
	; Uses VMS-style wildcards:
	;   Asterisk matches any characters
	;   Question Mark matches any single character
	;   NEGATE flag must be passed by address if a single quote can be
	;     used to negate a pattern.
	;   A minimum value is returned in MIN which can be used to start an
	;   ordering loop.
	;
	N (IN,NEGATE,MIN)
	S MIN=$G(MIN) ; Not required
	;
	I $E(IN)="'" S NEGATE=1,IN=$E(IN,2,$L(IN)) ; Strip off quote char
	E  S NEGATE=0 ; False
	S QUOTE=$C(34) ; Quote character
	S INQUOTE=0 ; 'Inside-a-quote' indicator
	S WASQUOTE=0 ; 'Previous-char-was-a-quote' indicator
	S OUT="" ; Output string
	S T="" ; Temporary holding, build string literals
	S X="" ; Current character
	;
	F I=1:1:$L(IN)+1 S X=$E(IN,I) D WILD1
	Q OUT
	;
WILD1	;=====
	;
	I X'=QUOTE S:'WASQUOTE WASQUOTE=0 G WILD10 ; Not a quote ?
	I INQUOTE S INQUOTE=0,WASQUOTE=1 Q
	; Not in a quote, and the previous character was a closing quote...
	I WASQUOTE S INQUOTE=1 G WILD10 ; Literal quote condition?
	;
	; Not in a quote, and the previous character was not a quote...
	E  S WASQUOTE=1,INQUOTE=1 Q  ; Ignore this character...
	;
WILD10	;
	I X="*",'INQUOTE D WILD2(".E") Q  ; Asterisk = "Any Number of Anything"
	I X="?",'INQUOTE D WILD2("1E") Q  ; Question mark = "One Anything"
	I X="" D WILD2("") Q  ; The last call will append the pattern trailer
	I X=QUOTE S X=X_X ; Must double all quotes
	S T=T_X ; Construct the literal string
	Q
	;
WILD2(PAT)	;=====
	;
	I OUT="",T'="" S MIN=T ; Set minimum for loops
	; Add PAT into output string
	I T'="" S OUT=OUT_"1"_QUOTE_T_QUOTE ; Search for "One occurrence of the String"
	S OUT=OUT_PAT ; Append the wildcard pattern
	S T="" ; Clear the temporary
	Q
	;
PARSE(STR,DELIM,COUNT,P1,P2,P3,P4)	;========== Parse Command String
	;
	; Trims COUNT strings from the beginning of STR and
	; returns P1 through Pcount pieces.
	N I
	F I=1:1:COUNT S @("P"_I)=$P(STR,DELIM,I)
	S STR=$P(STR,DELIM,COUNT+1,$L(STR,DELIM)) ; Throw away COUNT pieces
	Q  ; Done
	;
MATCH(STR,CMD,MINLEN)	;========== Verify if STR begins with CMD
	;
	N zzz1
	S zzz1=$$UC($P(STR," ",1)) ; Force upper case
	I $L(zzz1)<MINLEN Q 0  ; Not long enough?
	Q (zzz1=$E(CMD,1,$L(zzz1)))  ; Return logical value
	;
NAME(OBJECT,SUBS,LEVEL)	;========== Returns full array/global reference
	;
	N zzz,I
	I $G(OBJECT)="" Q ""  ; No object?
	I $G(LEVEL)=0 Q OBJECT  ; Reference only top level?
	S zzz=OBJECT_"("_$$QUOTE(SUBS(1))
	F I=2:1:LEVEL S zzz=zzz_","_$$QUOTE(SUBS(I))
	Q zzz_")"
	;
QUOTE(IN)	; Quote a string (if necessary)
	;
	I $G(IN)?1N.N Q IN  ; Doesn't need quotes?
	E  Q $C(34)_$G(IN)_$C(34)  ; Does need quotes
	;
HELP(zzz)	;========== Print Command Help
	;
	I '$$MATCH(zzz,"HELP",2) Q 0  ; Not a help command
	S zzz=$P(zzz," ",2,999)
	;
	W !," Shell commands (may be abbreviated):",!
	;
	W "$ DCL command",!
	W "  Passes the command to DCL for execution",!!
	;
	W "Ask variable",!
	W "  Prompts you for a string to be stored in the specified variable",!
	W "  Uses the current contents as the default value",!
	W "  All command-line editing features are available",!!
	;
	W "Date [expression]",!
	W "  Prints the expression as a date string, or ",!
	W "  Prints the current date",!!
	;
	W "Edit [routine]",!
	W "  Invokes the editor for the routine specified",!!
	;
	W "Examine pattern1[,pattern2]",!
	W "  Prints the contents of variables whose names match the wildcard",!
	W "  pattern(s) specified",!!
	;
	W "Find pattern",!
	W "  Prints variables whose name, subscripts, or data match the"
	W "  pattern specified",!!
	;
	W "Function pattern",!
	W "  Displays all functions in the SCATBL whose names match the",!
	W "  pattern specified.  Display includes the description and the ",!
	W "  program called by function",!!
	;
	W "Hide variable",!
	W "  Adds the specified variable to a list which is NEWed before",!
	W "  a command is executed in the shell",!!
	;
	W "LC [program]",!
	W "  Prints the Line Count for the specified program, the total",!
	W "  number of characters, and the number of line tags within it",!!
	;
	W "LT [program]",!
	W "  Prints all Line Tags within the specified program",!!
	;
	W "CE [program]",!
	W "  Prints only the comments extracted from the program",!!
	;
	W "Link [program] or Zlink [program]",!
	W "  Forces GT.M to link the specified programs",!!
	;
	W "Load [program] or Zload [program]",!
	W "  Sets the default program name for subsequent commands",!!
	;
	W "Output [device]",!
	W "  Opens the specified device for output access, or closes the",!
	W "  last device referenced with the Output command if no device",!
	W "  was specified",!!
	;
	W "Print [tag^routine:tag+offset]",!
	W "  Allows backward compatability with old Print command, with some",!
	W "  added functionality.  Uses the program Loaded previously.",!!
	;
	W "Rfind pattern",!
	W "  Searches the default program for text which matches the pattern",!!
	;
	W "RD pattern",!
	W "  Displays the contents of Routine Directory which match the",!
	W "  pattern",!!
	;
	W "Show variable1[,variable2]",!
	W "  Displays the length, the data, and the absence or presence of",!
	W "  descendant data for the variables",!!
	;
	W "Trap commands",!
	W "  Sets the error trapping variable to the commands you specify",!!
	;
	W "SW 80 or SW 132 or SW",!
	W "  Sets the screen width to 80 or 132 columns, or toggles the",!
	W "  width if not specified",!!
	;
	W "Write",!
	W "  Argumentless write is supported",!!
	Q 1  ; Signal all ok
