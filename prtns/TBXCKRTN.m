TBXCKRTN(ROUTINE,I18N)	
	;;Copyright(c)2002 Sanchez Computer Associates, Inc.  All Rights Reserved - 06/11/02 16:55:01 - SPIER
	;
	; This routine contains all of the code necessary to check a M program for compliance to Sanchez
	; programming standards
	; 
	;-------Revision History -----------------------------------------------
	; 03/28/03 Spier
	; Modified to allow $ZD in routines that strat with "UC" psl compiler
	;
	N ErrChk,CODE,cnt,lcnt,LINE,linErr,LinIdx,LinTxt,err,i,j,seq,TermFlag,X,DIR,FileName
	S ErrChk=0
	S cnt=0
	S TermFlag=0
	S DIR=$$SCAU^%TRNLNM("SPOOL")
	S FileName=$$FILE^%TRNLNM(ROUTINE_".m",DIR) 
	S X=$$FILE^%ZOPEN(FileName,"READ")
	S lcnt=0
	F  S LINE=$$^%ZREAD(FileName,.EOT) q:EOT  S lcnt=lcnt+1,CODE(linecnt)=LINE
	C FileName 
	D EXT(.CODE,FileName,.I18N)
	Q
	;
EXT(CODE,FileName,I18N)	
	N ErrChk,cnt,lcnt,LINE,linErr,LinIdx,LinTxt,err,i,j,seq,TermFlag
	S ErrChk=0
	S cnt=0
	S TermFlag=0
	S lcnt=""                        ; Initialize the Line Counter to 1
	F  s lcnt=$o(CODE(lcnt)) q:lcnt=""  D Main(CODE(lcnt)) 
	D MANUAL
	D RTN53(FileName,.CODE)
	;
	Q
	;DBA4 code	
Main(line)	;
	I $F(line,"I18N=QUIT") S TermFlag=1	; Terminate the job
	I $F(line,"I18N=ON") S TermFlag=0	; Start rechecking
	I $F(line,"I18N=OFF") S TermFlag=2	; Stop Checking
	I TermFlag Q
	S i=$$DBA5(line,.err,1,1,1,1,1,1,ErrChk) Q:i=0	;calling force routine with flags set for all conditons
		; line 		Line is the source line to check
		; .err 		Returned error (By Reference)
		; utlread	Default setup for UTLREAD   (Error Check On)
		; tr		Default setuP for TRANSATOR (Error Check On)
		; rounding	Default setup for ROUNDING  (Error Check On)
		; menubar	Default setup for MENUBAR   (Error Check On)
		; messages	Default setup for MESSAGES  (Error Check On)
		; ScaStndr	Default setup for SCA STNDR (Error Check On)
	U 0
	S ZCHKIT(lcnt,0)=line			;writing source line w/count
	F j=1:1:i D				;looping through err array
	.	S cnt=cnt+1  			;incrementing counter
	.	S ZCHKIT(lcnt,cnt)=err(j)	;writing each error message for the source line
	.	Q				;
	;U FileName				;accessing source RMS file
	Q					; QUIT
MANUAL	I cnt=0 Q
	S seq=$O(I18N(""),-1)+1,I18N(seq)=$g(AnalFile)
	S I18N(seq+1)="-------------------------------------------------------"
	S I18N(seq+2)="",seq=seq+3
	S LinIdx=0			; Set line index to 0
	F  S LinIdx=$O(ZCHKIT(LinIdx)) Q:LinIdx=""  D
		.  S ErrIdx=0		; Set Error Index to 0
		.  S LinTxt=ZCHKIT(LinIdx,ErrIdx)
		.  S I18N(seq)="  "_$TR(LinTxt,$C(9)," "),seq=seq+1
		.  F  S ErrIdx=$O(ZCHKIT(LinIdx,ErrIdx)) Q:ErrIdx=""  D
			..  S LinErr=ZCHKIT(LinIdx,ErrIdx)
			..  S I18N(seq)="        ==> "_LinErr,seq=seq+1
			..  S I18N(seq)="",seq=seq+1
			..  Q
		.  Q
		;
ENDJOB	K ZCHKIT		; Kill scracth global variavles
	Q
	;
	;dba5 code
DBA5(line,err,utlread,tr,rounding,menubars,messages,scastnd,ErrChk)	;;Copyright(c)1994 Sanchez Computer Associates, Inc.  All Rights Reserved - 03/07/94 15:28:23 - RAJUB
	;;Copyright(c)2000 Sanchez Computer Associates, Inc.  All Rights Reserved - 04/20/00 16:15:22 - DOUGHERTYT
	; ORIG:	BS Raju - 01/14/94
	; DESC:	The Enforcer
	;
	; ARGUMENTS:
	;
	;	. line	This is the line of source code to be analyzed
	;		Must be present for routine to run
	;		/TYP=T/REQ/MECH=VAL
	;
	;	. err	This array indicates the type of error found on the line
	;		There can be multiple errors per line of source code
	;		THIS FIELD IS UPDATED SO MUST BE CALLED AS .err
	;	. utlread
	;		0=don't analyze
	;		1=only potential errors
	;		2=all occurances
	;	. tr
	;		0=don't analyze
	;		1=only potential errors
	;		2=all occurances
	;	. rounding
	;		0=don't analyze
	;		1=only potential errors
	;		2=all occurances
	;	. menubars
	;		0=don't analyze
	;		1=only potential errors
	;		2=all occurances
	;	. messages
	;		0=don't analyze
	;		1=only potential errors
	;		2=all occurances
	;	.scastnd
	;		0=don't analyze
	;		1=only potential errors
	;
	; RETURNS:
	;	. err	data to be printed
	;
	;	. quit arguments		
	;		0=failed
	;		cnt=number of records in err array
	;
	; EXAMPLE:
	;	Text of example (line one)
	;
	;
	;-----Revision History-------------------------------------------------
	;
	;-----------------------------------------------------------------------
	; Check input variables
	;-----------------------------------------------------------------------
	N ChainCnt,EnterLev,LoopVar,MsgChain,MsgCnt,QuotLevl,QuotTest,StrgFlag,SubStrg
	N LinErr,LinIdx,LinTxt
	;
	I '$D(line) Q 0				; line must be passed in
	I '$D(utlread) S utlread=0		; initializing variables
	I '$D(tr) S tr=0			; Read all switches check
	I '$D(rounding) S rounding=0		; and set On/Off. If switches
	I '$D(menubars) S menubars=0		; are defined set Off
	I '$D(messages) S messages=0		; 0->Off Non-zero->On
	I '$D(scastnd) S scastnd=0		; 0->Off Non-zero->On
	I '$D(ErrChk) S ErrChk=0		; 0->String with  space
	;					 ; Non-zero->String without space
	;
	;----------------------------------------------------
	; New variables used in main routines
	;----------------------------------------------------
	;
	N e0,e1,e2,e3,e4,e5,e6,e7,e8	; Redefined under error(s) checking
	N cnt,i,found
	S cnt=0
	;----------------------------------------------------
	; Toss Comment Lines out
	;----------------------------------------------------
	N Y
	S Y=0
	F  S Y=$F(line,";",Y) Q:Y=0  I $L($E(line,1,Y-2),$C(34))#2 Q 
	I Y S line=$E(line,1,Y-2)		;keeps non-comment portion
	I line="" Q 0				;quits if line is null
	;----------------------------------------------------
	; Make all uppercase
	;----------------------------------------------------
	S line=$$UPPER^%ZFUNC(line)		;so searches will work
	;----------------------------------------------------
	; Main Decision Tree
	;----------------------------------------------------
	;
	I utlread>0 D utlread			;analyze utlreads
	I tr>0 D tr				;analyze $tr's
	I rounding>0 D rounding			;analyze rounding
	I menubars>0 D menubars			;analyze menubars
	I messages>0 D messages			;analyze messages
	I scastnd>0 D scastnd			;analyze SCA Strandards
	Q cnt					;Quit program with success
	;
	;------------------------------------------------------
writerr(error)		; Write error array
	;------------------------------------------------------
	N i					
	; 
	S found=0				;make sure error not
	F i=cnt:-1 Q:i=0  D			;already in err array
	.	I err(i)=error S found=1
	I found=1 Q				;quit if error present in array
	S cnt=cnt+1				;increments error counter
	S err(cnt)=error			;writes to error array
	Q					;quits
	;
	;-----------------------------------------------------
scastnd		; 'R ', '$N ', and 'W ' but not include 'W $$'
	;	Source code has error if
	;	1. 'R ' Direct read with/without text
	;	2. 'W ' Direct wrtie with/without text
	;	    if $$ fucntion is not used
	;	3. '$N(^ ' Direct read next global insead of $O
	;	4. '????' Marked during modifing the Routine (%ZCHKMSG)
	;-----------------------------------------------------
	; Set up error messages for UTLREAD checking
	;-----------------------------------------------------
	S e0="Illegal->R direct read with/without text"
	S e1="Illegal->W direct write with/without text"
	S e2="Illegal->$N Read next global insead of $O"
	S e3="???? Marked to correct later is still here (%ZCHKMSG)"
	S e4="Naked reference"
	S e5="Illegal->L Logical name reference - use entry in ^%TRNLNM"
	S e6="Illegal->MF- MUMPS Function call - use entry in ^%ZFUNC"
	S e7="Illegal->SP- MUMPS Special variable name - use entry in ^%ZFUNC"
	S e8="Illegal->PC- Platform commands - use entry in ^%OSSCRPT"
	;-----------------------------------------------------
	;
	N TempVar							;Check Tab R
	S TempVar=$C(9)_"R "
	I (line[" R ")!(line[TempVar) D writerr(e0)			;error 1
	S TempVar=$C(9)_"W "						;Check Tab W
	I ((line[" W ")!(line[TempVar))&(line'["W $$") D writerr(e1) 	;error 2
	; Modified following to check "$N(" rather than "$N(^"
	I line["$N(" D writerr(e2)					;error 3
	I line["????" D writerr(e3)					;error 4
	I line["^(" D writerr(e4)					;naked ref
	I line["$ZGETJPI(" D writerr(e6)
	I line["$ZGETSYI(" D writerr(e6)
	I line["$ZGETDVI(" D writerr(e6)
	I line["$ZFILE(" D writerr(e6)
	I line["$ZLKID(" D writerr(e6)
	I line["$ZPARSE(" D writerr(e6)
	I line["$ZPID(" D writerr(e6)
	I line["$ZSEARCH(" D writerr(e6)
	I line["$ZTRNLNM(" D writerr(e6)
	I line["SCAU$",line'[$C(34) D writerr(e5)
	I line["SCA$",line'[$C(34) D writerr(e5)
	I line["SYS$" D writerr(e5)
	Q
	;
	;-----------------------------------------------------
utlread			; utlread analysis
	;	Source code is in error if
	;	1. %TAB is being set directly with upbars
	;	- %TAB contains prompt text
	;	3. %TAB contains /DES
	;	4. %READ contains /DES
	;	5. %READ does not contain @@%FN
	;	6. existence of $$SCATAB
	;-----------------------------------------------------
	; Set up error messages for UTLREAD checking
	;-----------------------------------------------------
	S e0="UTLREAD affected line"
	S e1="%TAB being set directly"
	S e2=""
	S e3="*** %TAB contains /DES  (Fatal I18n error)"
	S e4="*** %READ contains /DES (Fatal I18n error)"
	S e5="%READ does not contain @@%FN"
	S e6="$$SCATAB found"
	;-----------------------------------------------------
	; all occurances first
	;-----------------------------------------------------
	I utlread=2 I (line["%TAB")!(line["%READ=") D writerr(e0) Q
	;
	;-----------------------------------------------------
	; only errors
	;-----------------------------------------------------
	;
	I (line["%TAB(")&(line["|") D writerr(e1)	;error 1
	I (line["%TAB(")&(line["/DES=") D writerr(e3)	;error 3
	I (line["%READ=")&(line["/DES=") D writerr(e4)	;error 4
	;I (line["%READ=")&'(line["@@%FN") D 
	;.	I $L(line,"%READ")=2 D writerr(e5)	;make sure only 1 %READ
	;.	Q					;error 5
	I line["$$SCATAB" D writerr(e6)			;error 6
	Q						;quit back to main
	;
	;-----------------------------------------------------
tr		; $TR Conformance
	;-----------------------------------------------------
	; $TR analysis
	;	Source code is in error if
	;	1. $TR is being used to do upper to lower case
	;		conversion
	;-----------------------------------------------------
	; Set up error messages
	;-----------------------------------------------------
	S e0="$TR affected line"
	S e1="$TR may be performing case conversion"
	;-----------------------------------------------------
	; all occurances first
	;-----------------------------------------------------
	I tr=2 I (line["$TR(")!(line["$$UPPER^%ZFUNC")!(line["$$LOWER^%ZFUNC") D writerr(e0) Q
	;						;list all occurances
	;-----------------------------------------------------
	; only errors
	; this routine has to look at each occurance of $TR in a given
	; source code line, throw out the junk in each parameter, then
	; look at parameters 2 and 3 to determine if there is a string
	; present with alphanumeric characters.  If so, its an error.
	;-----------------------------------------------------
	;
	I (line["$TR") D				;contains $TR
	.   N nbrtr,string,fstring			;newing variables
	.    S nbrtr=$L(line,"$TR(")			;finding out how many occurances of $TR strings are present
	.   F i=2:1:nbrtr D				;for each $TR string
	..	S string=$P(line,"$TR(",i)	;get string
	..	 S fstring=$$Parse(string)	;get final string from original string
	..	I ($$Look($P(fstring,",",2)))!($$Look($P(fstring,",",3))) D writerr(e1)
	..	Q				;quit do
	.    Q					;quit do
	Q					;quit back to main
	;
	;-----------------------------------------------------
Parse(string)	; gets rid of data between ( )
	; end result is the three simple $TR parameters
	;-----------------------------------------------------
	N nest,fstring,i,LineSave			 ;newing variables
	S nest=1					;setting variables
	S fstring=""
	F i=1:1:$L(string) Q:'nest  D				;for each character in the string
	.	I $E(string,i,i)="(" S nest=nest+1 Q	;toss all characters
	.	I $E(string,i,i)=")" S nest=nest-1 Q	;that lie between the
	.	I nest=0 Q				;parentisis
	.	I nest=1 D				;if not between the parentisis
	..		S fstring=fstring_$E(string,i,i);build the final string
	..		Q				
	.	Q
	S LineSave=line			; Save original line
	N begin				 ;Newed begin
	F  S begin=$F(fstring,$C(34))  Q:'begin  D  S line=LineSave
	.	S line=fstring			; transfer fstring to liine
	.	S EnterLev=0			; Set false entering through Parsing
	.	D ChkQuot
	.	S fstring=$E(line,1,begin-2)_"ParsVar"_$E(line,i,$L(line))
	.	Q
	Q fstring				;quit back with final string
	;
	;------------------------------------------------------
Look(trpiece)	;  looks at the final TR piece and determines if it is
	;  a string literal
	;------------------------------------------------------
	N inside
	S inside=""
	I ($E(trpiece,1,1)=$C(34))&($E(trpiece,$L(trpiece),$L(trpiece))=$C(34)) D
	.	S inside=$E(trpiece,2,$L(trpiece)-1)	;striping off quotes
	.	Q
	I inside="" Q 0				;null ok
	I inside?.A Q 1				;must be alpha numberic
	Q 0
	;
	;------------------------------------------------------  
rounding	; Rounding Conformance
	;-----------------------------------------------------
	; Rounding Analysis
	;	Source code is in error if (rounding=1)
	;	1. $J's being used to do monetary rounding
	;	2  $FN's being used to do monetary rounding
	;	Souce code analysis will return (rounding=2)
	;	1.  Source lines with $J and $FN
	;	2.  Source lines with calls to $$SCARND
	;-----------------------------------------------------
	; Set up error messages
	;-----------------------------------------------------
	S e0="Rounding affected line"
	S e1="-W- $J function should be replaced by $$^SCARND() utility"
	S e2="-W- $FN function should be replaced by $$^SCARND() utility"
	;-----------------------------------------------------
	; all occurances first
	;-----------------------------------------------------
	I rounding=2 I (line["$J(")!(line["$FN(")!(line["$$SCARND(") D writerr(e0) Q
	;						;list all occurances
	;-----------------------------------------------------
	; only errors
	; this routine has to look at each occurance of $J and
	; $FN to determine if it is being used for monetary rounding
	;  If it is, it is flaged as an error.
	;-----------------------------------------------------
	;						;Only $J's with three arguments can be use for rounding
	I line["$J(" D					;contains $J
	.	N nbrj,string,fstring
	.	S nbrj=$L(line,"$J(")			;Gets the number of $J phrases
	.	F i=2:1:nbrj D				;For the number of times $J appeared in the source string
	..		S string=$P(line,"$J(",i)	;Get the $J string
	..		S fstring=$$Parse(string)	;rip out all the (...)
	..		I $P(fstring,",",3)="" Q	;must not contain thrid argument to be valid
	..		 D writerr(e1)			;write the error because third argument present
	..		Q
	.	Q
	;
	I line["$FN(" D					;contains $FN
	.	N nbrj,string,fstring
	.	S nbrj=$L(line,"$FN(")			;gets the number of FN phrases in source line
	.	F i=2:1:nbrj D				;For the number of FN phrases
	..		S string=$P(line,"$FN(",i)	;Get the $FN string
	..		S fstring=$$Parse(string)	;rip out the (....)
	..		I $P(fstring,",",3)="" Q	;must not contain thrid argument
	..		D writerr(e2)			;write the error because thrid argument present
	..		Q
	.	Q
	;
	Q
	;
	;------------------------------------------------------  
menubars	; Menubar Conformance
	;-----------------------------------------------------
	; Menubar Analysis
	;	Source code is in error if (menubars=1)
	;	1. using DBSMENU rather than DBSMBAR
	;	Souce code analysis will return (menubars=2)
	;	1.  Source lines with DBSMENU
	;	2.  Source lines with DBSMBARS
	;-----------------------------------------------------
	; Set up error messages
	;-----------------------------------------------------
	S e0="Menu Bar affected line"
	S e1="DBSMENU cannot be used->display"
	;
	;-----------------------------------------------------
	; all occurances first
	;-----------------------------------------------------
	I menubars=2 I (line["DBSMENU")!(line["DBSMBAR") D writerr(e0) Q
	;						;list all occurances
	;-----------------------------------------------------
	; only errors
	;-----------------------------------------------------
	I line["DBSMENU" D writerr(e1)			;contains old menubar program
	Q
	;
	;------------------------------------------------------  
messages	; Messages Conformance
	;-----------------------------------------------------
	; Messages Analysis
	;	Source code is in error if there are any English
	;	language text in hard-coded in the source(messages=1)
	;	1. source code using English Language Phrase
	;	Souce code analysis will return (messages=2)
	;	1.  Source lines with literal values
	;-----------------------------------------------------
	; Set up error messages
	;-----------------------------------------------------
	S e0="Message Literals"
	S e1="*** Language phrases hardcoded"
	S e2="*** Message is not on file for V6.3 (Please send request to Documentation Administrator)"
	S e3="Argument mismatched"
	S e4=" Chain is closed. No way out."
	S e5=" Chain is stoped by last member"
	S e6="Please replace message by -> "
	S e7="Message coding is not standard"
	;
	;-----------------------------------------------------
	; all occurances first
	;-----------------------------------------------------
	I messages=2 I (line["$$^MSG(") D writerr(e0)	;list all occurances
	;-----------------------------------------------------
	; Check if messages coded does exist and arguments match
	;-----------------------------------------------------
	N ErrText,MsgId,MsgLoc,MsgText,MsgArg,ArgCnt
	; 		Message Error/ID/Location/Text/Arguments
	S EnterLev=1	; Set true entering through messages level
	;
	S MsgText=line,MsgLoc=0
	F  S MsgLoc=$F(MsgText,"$$^MSG(",MsgLoc) Q:'MsgLoc  D
	.	I $E(MsgText,MsgLoc)=$C(34) D
		..	S MsgLoc=MsgLoc+1
		..	S MsgText=$E(MsgText,MsgLoc,$L(MsgText))
		..	S MsgId=$P(MsgText,$C(34),1)
		..	;S MsgText=$E(MsgText,2,$L(MsgText))
		..	S QuotTest=1
		..	Q
	.	E  D
		..	S MsgId="",QuotTest=0
		..	F LoopVar=MsgLoc:1:$L(MsgText) D
		...	I '($E(MsgText,LoopVar)?.1n) S LoopVar=$L(MsgText)+2  Q
		...	S MsgId=MsgId_$E(MsgText,LoopVar),MsgLoc=MsgLoc+1 Q
		..	S MsgText=$E(MsgText,MsgLoc-$L(MsgId),$L(MsgText))  Q
	.	D ChainMbr
	.	I ChainCnt=-1 Q
	.	S MsgText=$E(MsgText,$L(MsgId)+2+QuotTest,$L(MsgText))
	.	S MsgArg=$P(MsgText," ",1)
	.	S (MsgCnt,MsgLoc)=0
	.	Q	; Remove this line if arguments checking is required
	.	F  S MsgLoc=$F(ErrText,"~p",MsgLoc) Q:'MsgLoc  D
		..	I $P(MsgArg,",",MsgCnt+1)=""  D writerr(e3)  S MsgLoc=99
		..	S MsgCnt=MsgCnt+1
		..	Q
	.	Q
	;  
	;-----------------------------------------------------
ChkQuot		; only errors
	;-----------------------------------------------------
	N begin,length,quotes,fstring,endq,char,numbq
	;			
	if $$UPPER^%ZFUNC(line)["TYPE RECORD" quit	; psl CACHE	
	S begin=$F(line,$C(34),0) I 'begin Q	;Line must contain quotes 
	S length=$L(line)
	;
	F  D Slide Q:begin'<length
	Q
	;-----------------------------------------------------
ChainMbr	; Find all errors in the chain
	;-----------------------------------------------------
	S MsgChain=MsgId,ChainCnt=0
Recurs		; Recursion step
	I MsgId="" S ErrText=e7  D writerr(ErrText)  Q
	;S dir="/v63paqalx/gbls/mumps.gld"
	;S ErrText=$G(^|dir|STBL("MSG",MsgId))
	S ErrText=$G(^STBL("MSG",MsgId))
	I ErrText="" D
	. 	I ChainCnt=0 S ErrText=MsgChain_e2,ChainCnt=-1  D writerr(ErrText) Q
	.	S ErrText=MsgChain_e5,ChainCnt=-1  D writerr(ErrText) Q
	.	Q
	I ($E(ErrText,1,2)'="~~") D  Q
	.	I (ChainCnt<1) Q
	.	S ErrText=e6_MsgId  D writerr(ErrText)
	.	Q	
	S MsgId=$E(ErrText,3,$L(ErrText))
	S ChainCnt=ChainCnt+1
	I (MsgChain[MsgId) D  Q
	.	S MsgChain=MsgChain_" <- "_MsgId
	.	S ErrText=MsgChain_e4  D writerr(ErrText)
	.	Q
	S MsgChain=MsgChain_" -> "_MsgId  G Recurs
	Q
	;
	;-----------------------------------------------------
Slide	;
	;-----------------------------------------------------
	S quotes=0
	S numbq=0
	S endq=0
	S fstring=""
	F i=begin:1:length Q:endq=1  D
	.	S char=$E(line,i,i)
	.	I char=$C(34) D quotes Q
	.	I endq=0 S fstring=fstring_char
	.	Q
	; fstring is the quoted literal string
	; must check it to see if it contains english lang literal
	; *** 02/18/97 BC
	I ($$Check(fstring)=1)&(EnterLev=1) I line'["^SQL(" D writerr(e1)
	S begin=$F($E(line,i,length),$C(34),0) I 'begin S begin=length Q
	S begin=begin+i-1
	Q
quotes	;-----------------------------------------------------
	N NextQuot		; Find next quotation if any
	S QuotLevl=0		; Multi-level quotations within quotation
	S NextQuot=begin
	F  S numbq=$$numbq()  Q:(numbq#2)!(NextQuot-i=1)!('NextQuot)  D
	.    S NextQuot=$F(line,$C(34),i+numbq)
	.    I NextQuot=0 Q
	.    S i=NextQuot+1,NextQuot=1
	.    S QuotLevl=QuotLevl+1
	.    S fstring=$E(line,begin,i-1)
	.    Q
	S i=i+numbq-1
	;I quotes>numbq S endq=1,fstring="" W quotes_">"_numbq,! Q	;Error, should never occur
	S quotes=numbq-quotes
	I ((QuotLevl=0)&(numbq>1)) D  Q	 ; Just set to blank to bypass
	.	S fstring="  "
	.	S quotes=1,endq=1
	.	Q
	I QuotLevl>0 D  Q		; Multple quotations inside quotation
	.	 S quotes=1
	.	 S endq=1
	.	 S fstring=$E(line,begin,i) Q
	I quotes=1 S endq=1 S fstring=$E(fstring,1,$L(fstring)-1) Q
	Q
numbq()	;-----------------------------------------------------
	n j,numb
	S numb=0
	F j=i:1:length Q:$E(line,j,j)'=$C(34)  D
	.	I $E(line,j,j)=$C(34) D
		..	S numb=numb+1
		..	S fstring=fstring_$E(line,j,j)
		..	Q
	.	Q
	Q numb
	;
	;------------------------------------------------------------
Check(fstring)	; Add checks for literal contents
	; Return with 0 if string does not contain English Language Lit
	;-------------------------------------------------------------
	;	U 0  W fstring,! 		;Debuging tool
	I fstring=" " Q 0		;Spaces
	I fstring["|" Q 0		;Must not contain upbar
	I fstring="" Q 0		;Null string
	I '(fstring?.E1A.E) Q 0		;Must contain at least 1 alpha char
	I fstring?.E1C.E Q 0		;Must not contain control characters
	I fstring?1A Q 0		;Must contain at least 1 space
	I ErrChk=0,fstring'[" " Q 0	;Must contain at least 1 space
	I ErrChk'=0,fstring[" " Q 0	;Must contain at least 1 space
	;
	i fstring["INSERT INTO " Q 0 ; SQL statement
	i fstring["VALUES (" Q 0 ;
	;
	I fstring["S ",$F(fstring,"S ")=3 Q 0	; Find if 'S ' is in the beggining
	I fstring["K ",$F(fstring,"K ")=3 Q 0	; Find if 'K ' is in the beggining
	I fstring["D ",$F(fstring,"D ")=3 Q 0	; Find if 'D ' is in the beggining
	I fstring["I ",$F(fstring,"I ")=3 Q 0	; Find if 'I ' is in the beggining
	; 
	I (fstring["$A(")!(fstring["$C(")!(fstring["$D(")!(fstring["$E(") Q 0
	I (fstring["$F(")!(fstring["$FN(")!(fstring["$G(")!(fstring["$J(") Q 0
	I (fstring["$L(")!(fstring["$N(")!(fstring["$O(")!(fstring["$P(") Q 0
	I (fstring["$Q(")!(fstring["$R(")!(fstring["$S(")!(fstring["$T(") Q 0
	I (fstring["$TR(")!(fstring["$V(") Q 0
	I fstring["^" Q 0
	S StrgFlag=1		; Set False for the following errors
	F LoopVar=2:2:6 S SubStrg=$P(fstring,$C(34),LoopVar) I $L(SubStrg)>1 D
	.	I StrgFlag=1  S StrgFlag=0
	.	I SubStrg="I " Q
	.	I SubStrg=" (" Q
	.	I $E(SubStrg)="?" Q
	.	I $E(SubStrg,1,2)="S " Q
	.	I $E(SubStrg,1,2)="$$" Q
	.	I $E(SubStrg,1,2)=". " Q
	.	S StrgFlag=2
	.	Q
	I StrgFlag'=0  S StrgFlag=1
	Q StrgFlag
	;
	;-------------------------------------------------------------
String(expr,pos)	; Return next quoted string from expression 
	;-------------------------------------------------------------
	;
	S pos=$G(pos)
	S pos=$F(expr,$C(34),pos) I 'pos Q ""
	;
	S y=pos-1
	F  S pos=$F(expr,$C(34),pos) Q:'pos  I $L($E(expr,y,pos-1),"""")#2 S expr=$E(expr,y,pos-1) Q
	I 'pos S pos=$L(expr)
	Q expr
	;
	;dba3 routine	
	;----------------------------------------------------------------------
RTN53(rtn,src);	
	;----------------------------------------------------------------------
	N i,j,v,v1,z,IO,ZEOF
	S IO=rtn
	S rtn=$P(IO,"/",$L(IO,"/"))
	S hist=+$g(hist)
	S i=""
	F  S i=$O(src(i)) q:i=""!(hist)  I 'hist,$$UPPER^%ZFUNC(src(i))["REVISION HISTORY" S hist=i
	;
	I $G(arq),hist D					; Try to locate revision info
	.	F i=hist+1:1:hist+20 I $G(src(i))[arq S hist=0 Q
	.	I hist D ERR(0,IO,"",5.1)
	;
	S j="" F  S j=$O(src(j)) Q:j=""  D
	.	S v=$TR(src(j),$C(9)," ")		; Convert TAB to space
	.	S v1=v
	.	S v=$$UPPER^%ZFUNC(v)			; To uppercase
	.	I v["I18N=" Q
	.	I v[";",$P(v,";",1)?." " Q		; Comment field
	.	F i="S ^ACN(","S $P(^ACN(","S $P(^CIF(","S ^CIF(","S ^CIFH(","S ^HIST(" D
	..		I v[i D ERR(0,rtn,v1,3)		; Global reference
	.	F i="^ADDR(","]ADDR(","^LNOLC(","^MLT(" D
	..		I v[i D ERR(0,rtn,v1,4.1)	; Global reference
	.	I v["NJD^UFRE" D  I ER1 D ERR(0,IO,v1,4)	; UFRE error checking
	..		S ER1=0
	..		I v["ER" Q  			; Current line
	..		I $G(src(j+1))["ER" Q  		; Next line
	..		S ER1=1
	.	I v["D ^UFRE" D ERR(0,IO,v1,14)		; UFRE error checking
	.	I v["$ZD("!(v["^%ZD("),$e(rtn,1,2)'="UC" D ERR(0,IO,v1,5)	; $ZD
	.	D Y2K(v,v1,0,IO)				; ^%ZM - Y2K
	.	I (v["INT^%T")!(v["EXT^%T") D ERR(0,IO,v1,6)	; Date/time
	.	I v["$ZP(",v'["^GBL(",v'[($C(34)_"$ZP") D ERR(0,IO,v1,8.1)	; $ZP -> $O
	.	I v["$N(" D ERR(0,IO,v1,8)		; $N -> $O
	.	I $E(v)'="" S v=$P(v," ",2,999)		; Remove line tag
	.	I v["ZA "!(v["ZD ") I v'["$ZD(" D ERR(0,IO,v1,9)	; ZA,ZD -> L+ ,L-
	.	I v["$$DI^SCATAB" D ERR(0,IO,v1,17)	; *** 01/18/99
	.	I rtn'["OSSCRPT",v["SYS^%ZFUNC(" D ERR(0,IO,v1,5.99)
	.	I v["VOBJ"!(v["vobj"),((rtn'["UC")&(rtn'["SQL")&(rtn'["DBS")&(rtn'["UINDX")&(rtn'["EUROCNV")) D ERR(0,IO,v1,13.1)
	.	I v["SELECT^SQL" D ERR(0,IO,v1,4.31)	; not as efficient as global access 5/23/00
	.	;
	.	I v["$$MON^SCADAT" D  I ER1 D ERR(0,IO,v1,4.03)	; $$XXX^SCADAT(,1
	..		S ER1=0
	..		I v[",1" Q
	..		S ER1=1
	.	I v["$$DAY^SCADAT" D  I ER1 D ERR(0,IO,v1,4.03)	; $$XXX^SCADAT(,1
	..		S ER1=0
	..		I v[",1" Q
	..		S ER1=1
	.	I v["$$YEAR^SCADAT" D  I ER1 D ERR(0,IO,v1,4.03)	; $$XXX^SCADAT(,1
	..		S ER1=0
	..		I v[",1" Q
	..		S ER1=1
	.	I v["$$BOMJD^SCADAT" D  I ER1 D ERR(0,IO,v1,4.03)	; $$XXX^SCADAT(,1
	..		S ER1=0
	..		I v[",1" Q
	..		S ER1=1
	.	I v["$$EOMJD^SCADAT" D  I ER1 D ERR(0,IO,v1,4.03)	; $$XXX^SCADAT(,1
	..		S ER1=0
	..		I v[",1" Q
	..		S ER1=1
	.	I v["$$BOFY^SCADAT" D  I ER1 D ERR(0,IO,v1,4.03)	; $$XXX^SCADAT(,1
	..		S ER1=0
	..		I v[",1" Q
	..		S ER1=1
	.	I v["$$EOFY^SCADAT" D  I ER1 D ERR(0,IO,v1,4.03)	; $$XXX^SCADAT(,1
	..		S ER1=0
	..		I v[",1" Q
	..		S ER1=1
	.	I v["$$BOTY^SCADAT" D  I ER1 D ERR(0,IO,v1,4.03)	; $$XXX^SCADAT(,1
	..		S ER1=0
	..		I v[",1" Q
	..		S ER1=1
	.	I v["$$BOFY^SCADAT" D  I ER1 D ERR(0,IO,v1,4.03)	; $$XXX^SCADAT(,1
	..		S ER1=0
	..		I v[",1" Q
	..		S ER1=1
	.	I v["$$BOYJD^SCADAT" D  I ER1 D ERR(0,IO,v1,4.03)	; $$XXX^SCADAT(,1
	..		S ER1=0
	..		I v[",1" Q
	..		S ER1=1
	.	I v["$$MNAM^SCADAT" D  I ER1 D ERR(0,IO,v1,4.03)	; $$XXX^SCADAT(,1
	..		S ER1=0
	..		I v[",1" Q
	..		S ER1=1
	.	I v["$$DOW^SCADAT" D  I ER1 D ERR(0,IO,v1,4.03)	; $$XXX^SCADAT(,1
	..		S ER1=0
	..		I v[",1" Q
	..		S ER1=1
	.	I v["$$NODM^SCADAT" D  I ER1 D ERR(0,IO,v1,4.03)	; $$XXX^SCADAT(,1
	..		S ER1=0
	..		I v[",1" Q
	..		S ER1=1
	.	I v["$$NODY^SCADAT" D  I ER1 D ERR(0,IO,v1,4.03)	; $$XXX^SCADAT(,1
	..		S ER1=0
	..		I v[",1" Q  
	..		S ER1=1
	.	; V63 standards
	.	I $G(ver)>119 D
	..		i v["$$NEW^%ZT" D ERR(0,IO,v1,4.01)
	..		I v["@$$SET^%ZT" D ERR(0,IO,v1,4.02)
	;
	C IO
	Q
	;
	; FROM dba1
	;----------------------------------------------------------------------
ERR(lev,id,v,msg)	; 
	;----------------------------------------------------------------------
	;
	I $G(errmsg)'="",msg'=errmsg Q		; Display one error type
	I $g(fopt)="Y",msg<5 Q			; Display fatal errors only
	n z
	S errcnt=$g(errcnt)+1
	;
	S z="Routine"
	I lev=1 S z="File"
	I lev="1D" S z="Data Item"
	I lev=2 S z="Screen"
	I lev=3 S z="Exec"
	I lev=5 S z="Report"
	I lev=7 S z="Trigger"
	I lev=25 S z="Procedure"
	I lev=33 S z="batch"
	d write("------------------------------------------------------------------")
	d write($g(version)_" ("_z_") "_id),write("")
	I $G(v)'="" D write(" "_$TR(v,$C(9)," "))
	I $G(fopt)="Y" d write(msg_"  ==>")
	;
	I msg>4.99 S ER=1,RM="Fatal code review error(s)",FATAL=$G(FATAL)+1
	;
	I msg=1.1 D write("-W- Invalid file type 5 (should be 1 or 3)") Q
	I msg=2 D write("-I- Lookup table syntax error (use [FID] syntax)") Q
	I msg=3 D write("-I- Global reference error (use filer or &&SQL to update this global)") Q
	I msg=4 D write("-W- Missing ER checking logic (UFRE utility)") Q
	I msg=4.01 D write("-W- Call to $$NEW^%ZT is no longer necessary") Q
	I msg=4.02 D write("-W- S @$$SET^%ZT should be replaced with S $ZT=$$SETZT^%ZT to improve performance") Q
	I msg=4.03 D write("-W- Call to ^SCADAT should pass second parameter of 1") Q
	I msg=4.1 D write("-W- ^ADDR, ^MLT or ^LNOLC invalid references (V5.2+)") Q
	I msg=4.16 D write("-W- Field size for frequency data type should be 12") 
	I msg=4.2 D write("-W- Invalid expression (host variable referenced)") Q
	I msg=4.3 D write("-I- ^SQL call should be replaced with &&SQL macro command to improve performance") Q
	I msg=4.31 D write("-W- SELECT^SQL is not as efficient as global access") Q
	I msg=4.4 D write("-W- Invalid default value expression (Use $$ function or system variables)") Q
	I msg=4.5 D write("-W- I18n error - "_$G(err(1))) Q
	I msg=4.51 D write("-I- Please review Y2K standard") Q
	I msg=4.6 D write("-W- Missing file definition") Q
	I msg=4.8 D write("-W- Invalid field display attribute (bold)") Q
	I msg=4.9 D write("-W- Screen size should be 80 and not 132") Q
	I msg=4.91 D write("-W- It should not be used in versions v6.1 and above") Q
	I msg=4.93 D write("-W- Replace ^SQL calls with PSL Db.getRecord/select/update/delete methods") Q
	I msg=4.94 D write("-I- Record type should be 1") Q
	I msg=4.95 D write("-W- Total record size > 8000") Q
	I msg=4.96 D write("-W- Invalid data item "_id_" (Z name)") Q
	I msg=4.97 D write("-W- Field size for currency data type should be 12 or 18") Q
	I msg=4.98 D write("-W- Z-named file definitions should be released under a custom sub-system") Q
	;
	; Fatal error (5-20)
	;
	I msg=5 D write("-F- Invalid $ZD or ^%ZD reference --- use $$DAT^%ZM(date,mask) or $$func^SCADAT(date) functions") Q
	I msg=5.1 D write("-F- Missing revision history for ARQ "_$G(arq)) Q
	I msg=5.2 D write("-F- I18n error - "_$G(err(1))) Q
	I msg=5.3 D write("-F- SELECT^SQL call should be replaced with &&SQLSELECT") q
	I msg=5.35 D write("-F- SELECT^SQL should be replaced with  global") Q
	I msg=5.36 D write("-F- $$^CUVAR should be replaced with &&SQLSELECT (non-M)") Q
	I msg=5.99 D write("-F- OS specific command - use ^%OSSCRPT utility")
	I msg=6 D write("-F- Invalid ^%T reference (use $$TIM^%ZM function)") Q
	I msg=7 D write("-F- Length error on date field (should be 10)") Q
	I msg=8 D write("-F- $N reference (use $O syntax)") Q
	I msg=8.1 D write("-F- $ZP reference (use $O(^gbl(...),-1) syntax)") Q
	I msg=9 D write("-F- ZA or ZD reference (use L+ or L- syntax)") Q
	I msg=10.1 D write("-F- Invalid network location (should be 2)") Q
	I msg=10.2 D write("-F- Invalid logging option (should be 1)") Q
	I msg=10.3 D write("-F- Missing Supertype information (should be ACN)") Q
	I msg=10.4 D write("-F- Invalid data item ") Q
	;;I msg=10.41 D write("-F- Invalid data item "_id_" (Z name)") Q
	I msg=10.42 D write("-F- Invalid data item "_id_" (node>999)") Q
	I msg=10.43 D write("-F- Invalid computed expression (nested call)") Q
	I msg=10.5 D write("-F- Invalid computed expression ($D referenced)") Q
	I msg=10.6 D write("-F- Invalid computed expression (global referenced)") Q
	I msg=10.7 D write("-F- Invalid computed expression (foreign table(s) referenced)") Q
	I msg=10.8 D write("-F- Invalid node/computed expression") Q
	I msg=10.9 D write("-F- Invalid data item "_id) Q
	I msg=11.1 D write("-F- Missing access keys") Q
	I msg=11.11 D write("-F- Missing File description") Q
	I msg=11.2 D write("-F- Access key "_id_" should be a required field") Q
	I msg=11.3 D write("-F- "_id_" is in supertype file ACN but missing from DEP file") Q
	I msg=11.4 D write("-F- "_id_" is in supertype file ACN but missing from LN file") Q
	I msg=11.5 D write("-F- "_id_" is in supertype file ACN but missing from DTYPE file") Q
	I msg=11.6 D write("-F- "_id_" is in supertype file ACN but missing from LTYPE file") Q
	I msg=11.7 D write("-F- "_id_" Invalid reference to routine UCIF") Q
	I msg=11.8 D write("-F- "_id_" Invalid reference to routine UACN") Q
	I msg=11.9 D write("-F- Invalid global SET command in DQ screen") Q
	I msg=12 D write("-F- Data item name is a blank field") Q
	I msg=13 D write("-F- Replace ^SQL calls with &&sql macro command") Q
	I msg=13.1 D write("-F- Reference to vobj not allowed") Q
	I msg=14 D write("-F- Use $$NJD^UFRE(JD,FRE,AF,CTL) syntax") Q
	I msg=15 D write("-F- Lookup table syntax error (use [FID] syntax)") Q
	I msg=16 D write("-F- Field size for frequency data type should be 12") Q
	I msg=16.1 D write("-F- Field size for Text data type should be less than 510") Q
	I msg=17 D write("-F- $$^DI^SCATAB should be replaced with prompt table entry") Q
	I msg=18 D write("-F- Invalid Y2K date standard --- use $$func^SCADAT(date) or $$DAT^%ZM(data,mask) utility") Q
	I msg=19 D write("-F- Missing parameter --- use $$DAT^%ZM(+$H) or $$DAT^%ZM(^CUVAR(2))") Q
	I msg=20 D write("-F- Please remove $$LOCK^TTXP2 and UNLOCK^TTXP2 logic") Q
	Q
write(str)	; 
	N seq
	;;W !,str,!
	S seq=$O(coderv(""),-1)+1
	S coderv(seq)=str
	Q
Y2K(v,v1,lev,id)	; 
	N expr,sts 
	S sts=$$ZMCHK(v) 
	I 'sts Q 
	I sts=1 D ERR(lev,$G(id),v1,4.51) Q 
	I sts=2 D ERR(lev,$G(id),v1,18) Q 
	I sts=3 D ERR(lev,$G(id),v1,19)         ; 02/24/99 BC 
	Q 
ZMCHK(v)	; 
	I $TR(v,$C(9)," ")?." "1";".E Q 0       ; comment line 
	I v["$$DAT^%ZM",v'["$$DAT^%ZM(",v'["//" Q 3     ; need argument 
	I v["^SCADAT1" Q 1                      ; verify %DS 
	I v'["$E($$DAT^%ZM(" Q 0                ; no match 
	S expr=$P(v,"$E($$DAT^%ZM(",2)    ; get expression 
	S expr=$P(expr,")",1) 
	I expr[",",expr["""" Q 1                ; Mask included 
	Q 2 
