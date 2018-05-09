%ZREAD(DEVICE,ETYP)	;System;Various READ extrinsic functions
	;;Copyright(c)1997 Sanchez Computer Associates, Inc.  All Rights Reserved - 02/25/97 16:11:37 - CHENARD
	; ORIG:  Dan S. Russell (2417) - 11/09/88
	;
	; General READ utility to read from tape or RMS file for GT.M.  An
	; M/VX version also exists.
	;
	; This utility provides for the necessary error handling specific to 
	; GT.M and returns an appropriate error message if an error is 
	; encountered.
	;
	; If code needs to be compiled in-line into a routine for efficiency, 
	; the code from this utility can be compiled and used directly.
	;
	; NOTE - New versions of this routine must always use the same line 
	;        tag scheme, i.e. start with READ and error trap section 
	;        READER, so that compilers know what to look for.
	;
	; NOTE - If compiling into code, do not compile in any line with 
	;        tags SKIP
	;
	; Also provides section TERM to read input from a terminal for general 
	; insert mode and timeout handling.
	;
	; If input is from an RMS file, the TERM section will always return 
	; %fkey as ENT unless an escape sequence is indicated on the line.  
	; This can be done by enter a ~ as the first character on the line, 
	; followed by the mnemonic for the key.  For example, to enter escape,
	; use ~ESC.  This can be the only input on the line.
	;
	; KEYWORDS:	Device handling
	;
	; INPUTS:
	;	. DEVICE	Device from which to read	/TYP=T
	;			Must already be OPEN
	;
	;	. ETYP		Error type if an 		/TYP=T
	;			error is encountered		/MECH=REF:W
	;			Values will be number to 
	;			identify error type, plus
	;			comment, e.g. "End of file"
	;
	;			  0  (no error)
	;			  1|End of file
	;			  2|Device 'device' not open
	;			  3|(Other - specific message)
	;
	; RETURNS:
	;	. $$		Value read			/TYP=T
	;
	; EXAMPLE:
	;	S X=$$^%ZREAD(DEVICE,.ET)
	;
	;----- Revision History -----------------------------------------------
	;
	; 02/25/97 - Phil Chenard
	;            Modified TERM section to use $PRINCIPAL instead of a
	;            null device.  This addresses a potential problem when 
	;            referencing the current device on a READ.
	;
	; 02/17/97 - Bob Chiang
	;            Modified TERM section to accept TAB key as one of the
	;            valid data entry terminators.
	;
	;----------------------------------------------------------------------
	;
	N X
READ	; If compiling code, take from this line on down.  X will read
	;
	S ETYP=0,X=""
	U DEVICE:EXC="G READERR^%ZREAD" R X
	I $ZEOF S ETYP="1|End of file"
SKIP1	Q X ; Return value - If compiling, do not take this line
	;
READERR	; Error trap
	I $ZS["IOEOF" S ETYP="1|End of file"
	E  I $ZS["IONOTOPEN" S ETYP="2|Device "_DEVICE_" not open"
	E  S ETYP="3|"_$P($ZS,",",3)
SKIP2	Q X ; Return X - If compiling, do not take this line
	Q  ; Quit if compiling, or delete this line also for own handling
	;
%STOPLOD	;	Compiler load breakpoint indicator (FRS)
	;
	;----------------------------------------------------------------------
ZB	;System;Returns ZB=<terminator> and %fkey=<function_name>
	;----------------------------------------------------------------------
	;
	; KEYWORDS:	Device handling
	;
	I $I["." S %fkey="ENT" Q		; RMS file
	;
	S %fkey=$$FK($S($L($ZB)<2:$A($ZB),1:$E($ZB,2,99))) Q:%fkey'="ALT"
	N X R X#1 S %fkey=$$FK("*"_$S($L($ZB)<2:$A($ZB),1:$E($ZB,2,99))) Q
	;
FK(ZB)	Q $G(%fkey(ZB))
	;
	;----------------------------------------------------------------------
TERM(STR,LEN,PTR,FIL,TIM,TOF,FLD,NUM,LEFT)	;System;INSERT mode string editor
	;----------------------------------------------------------------------
	;
	; KEYWORDS:	Device handling
	;
	; ARGUMENTS:
	;	. STR	Current string		 		/TYP=T/NOREQ
	;		String must be displayed with		/DEF=""
	;		the cursor on the first character 
	;		of the string.
	;
	;	. LEN	Field length limit			/TYP=N/NOREQ
	;	. PTR	Cursor pointer (Default=End_of_STR).	/DEF=80
	;		This subr. will move the cursor to 
	;		the correct position in the string
	;		(ALWAYS call with the cursor on the 
	;		first character.
	;
	;	. FIL	The fill character			/TYP=T/LEN=1
	;		used to replace rubout char		/NOREQ/DEF=" "
	;
	;	. TIM	Read timeout				/TYP=N/NOREQ
	;							/DEF=$$TODFT
	;
	;	. TOF	Timeout flag				/TYP=L/NOREQ
	;		  0=Handle timeout here,		/DEF=0
	;		  1=return timeout to application
	;		    with %FKEY="TIM"
	;
	;	. FLD	Field size				/TYP=N/NOREQ
	;
	;	. NUM	Numeric field?				/TYP=L/NOREQ
	;							/DEF=0
	;
	;	. LEFT  Enable left arrow key logic		/TYP=L/NOREQ
	;		If the flag is set and the cursor is on
	;		the first character of a field, the
	;               left arrow key will terminate the read
	;		operation and return CUB status in the
	;	        %fkey variable.
	;
	;----------------------------------------------------------------------
	;
	;
	U 0:NOECHO
	;
	I $I["." D  Q $G(STR)			;RMS file
	.	N Z
	.	R Z
	.	I $E(Z)="~" S %fkey=$$UPPER^%ZFUNC($E(Z,2,9))
	.	E  S %fkey="ENT",STR=Z
	;
	;
	; 
	S:'$D(STR) STR="",LEN=80,PTR=1,FIL=" " 	;Default string to null
	S:$G(LEN)="" LEN=80 			;Default field_len to 80
	S:$G(PTR)="" PTR=$L(STR)+1 		;Default char_ptr to field_len+1
	S:'$D(FIL) FIL=" " 			;Default fill_char to space
	S:$G(TIM)="" TIM=$$TODFT 		;Default input timeout
	S:$G(FLD)="" FLD=LEN 			;Field Length
	S:'$D(NUM) NUM=0 			;Numeric Field
	;
	S:$L(STR)+1<PTR PTR=$L(STR)+1 		;If char_ptr beyond field
	I PTR>1 W $$CUF^%TRMVT(PTR-1) 		;Align cursor with char_ptr
	;
	N CSI,CR,CS,O
	S CSI=$$CSI^%TRMVT,CS=$C(27)_"7",CR=$C(27)_"8",O=0
	;
	I PTR=0,STR'="" R *Z:TIM G INSX:'$T D  G INSZB
	.	I Z>31 S STR="",PTR=1 W CS,$$FILL(FLD),CR Q
	;
INSZ	; Read character Z into STR
	;
	I STR="" U 0:ECHO R STR#FLD:TIM U 0:NOECHO S PTR=$L(STR)+1 G INSX:'$T G INSZ:$ZB="" S Z="" G INSZB
	R *Z:TIM E  G INSX
	;
INSZB	I Z>31&(Z'=127) S ZB="" 		;Character entered
	E  S ZB=$S($L($ZB)=1:$A($ZB),$L($ZB)>1:$E($ZB,2,9),1:Z),Z=""
	;
	I ZB=9 S %fkey="ENT" Q STR		; *** 02/17/97 TAB terminator
	I ZB=11 D KYB Q STR			;Keyboard emulation -pmc 6/20/95
	;
	I Z'="" D  G INSZ  			;Insert Character
	.	;
	.	I $L(STR)=LEN W $C(7) Q
	.	S STR=$E(STR,1,PTR-1)_$C(Z)_$E(STR,PTR,LEN),PTR=PTR+1
	.	I PTR>(FLD+O+1) D PANRITE Q
	.	W $C(Z) I $E(STR,PTR,FLD+O)'="" W CS,$E(STR_FIL,PTR,FLD+O),CR
	.	Q
	;
	I ZB=127 D  G INSZ 			;Rubout Character
	.	;
	.	I STR="" Q 
	.	I PTR=0 S PTR=1 I NUM W CS,$E(STR,1,FLD),$$FILL(FLD-$L(STR)),CR
	.	I PTR=1 S STR=$E(STR,2,LEN) W CS,$E(STR_FIL,1,FLD+O),CR Q
	.	S STR=$E(STR,1,PTR-2)_$E(STR,PTR,LEN),PTR=PTR-1
	.	W $C(8),CS,$E(STR_FIL,PTR,FLD+O),CR
	.	Q
	;
	I ZB="[C" D  G INSZ 			;Cursor Forward
	.	;
	.	I PTR=0 S PTR=1 I NUM W CS,$E(STR,1,FLD),$$FILL(FLD-$L(STR)),CR
	.	I PTR>$L(STR) Q
	.	S PTR=PTR+1
	.	I PTR>(FLD+O+1) D PANRITE Q
	.	W CSI,"C" Q
	;
	I ZB="[D",PTR<2,$G(LEFT)		; *** BC - 07/01/94 Cursor Back
	E  I ZB="[D" D  G INSZ			; *** Exit on first character
	.	;
	.	I PTR<2 Q
	.	S PTR=PTR-1
	.	I PTR=O S O=O-1 W CS,$E(STR,O+1,O+FLD),CR Q
	.	W $C(8)
	;
	;
	I ZB=21 D  G INSZ 			;Ctrl-U
	.	;
	.	I PTR>1 W CSI,PTR-1,"D"
	.	S STR=$E(STR,PTR,$L(STR)),PTR=1
	.	W CS,$E(STR,1,FLD),$$FILL(FLD-$L(STR)),CR
	;
	D ZB 					;Define Terminator
	;
	I %fkey="REM" D				;Remove entire field
	.	;
	.	I PTR>1 W CSI,PTR-1,"D"
	.	W CS,$$FILL(FLD),CR
	.	S STR="",PTR=1 Q
	;
	U "":ECHO Q STR
INSX	;
	U "":ECHO
	D TIMEOUT($G(TOF)) I %fkey="TIM" Q STR
	G INSZ
	;
	;----------------------------------------------------------------------
FILL(l)	Q $S(l<0:"",1:$TR($J("",l)," ",FIL)) 		;Fill field with FIL
	;
	;----------------------------------------------------------------------
PANRITE	; Shift the window right one character
	;----------------------------------------------------------------------
	;
	S O=O+1
	W CSI,FLD,"D",$E(STR,O+1,O+FLD)
	Q
	;
	;----------------------------------------------------------------------
TIMEOUT(OPT)	;
	;----------------------------------------------------------------------
	;
	I $G(OPT) S %fkey="TIM" Q  ; Return control to the application
	W $$CPS^%TRMVT
	D RESUME
	W $$CPR^%TRMVT
	S %fkey="ENT"
	Q
	;
	;----------------------------------------------------------------------
RESUME	;
	;----------------------------------------------------------------------
	N X,HALT,PWDENC,PWDTRY,INVALID,VMSOPT,TYPE,USERNAME
	S HALT=$G(^CUVAR("%TOHALT")) I 'HALT S HALT=3600
	W $$MSG^%TRMVT("Terminal response timeout",1,1,1,24,HALT,1)
	I $G(%fkey)="TIM" W $$MSG^%TRMVT("Session halted by timeout",1) H
	I '$D(%UID) Q
	S VMSOPT=$G(^CUVAR("USERNAME"))
	S X=$G(^SCAU(1,%UID)),PWDENC=$P(X,"|",6)
	I PWDENC="" Q
	I '$$VALID^%ZRTNS("SCAENC") Q
	;
	; Get password to continue.  If don't user password due to use of
	; VMS login, get username
	S INVALID="",PWDTRY=3,TYPE="Password"
	I VMSOPT S TYPE="Username",USERNAME=$$USERNAM^%ZFUNC
RESUME1	W $$BTM^%TRMVT,INVALID,"Enter ",TYPE," to continue: "
	I VMSOPT Q:$$USERNAM  		; Username is valid, allow continue
	E  I '$$PWD(30,PWDENC) Q  	; Password is valid, allow continue
	I $G(%fkey)="TIM" W $$MSG^%TRMVT("Session halted",1) H
	S PWDTRY=PWDTRY-1
	I 'PWDTRY W $$MSG^%TRMVT("Invalid "_TYPE_", session halted",1) H
	S INVALID="Invalid ... "
	G RESUME1
	;
	;----------------------------------------------------------------------
PWD(TIM,PWDENC)	; Read the password
	;----------------------------------------------------------------------
	; TIM = timeout
	; PWNENC = encrypted password to compare.
	; Returns 0 if successful, 1 if fails (plus RM)
	;
	I $$NEW^%ZT N $ZT
	S @$$SET^%ZT("PWDET^%ZREAD")
	I $G(PWDENC)="" S RM="Invalid user" Q 1
	D TERM^%ZUSE(0,"NOECHO")
	R X:TIM
	I X="" S %fkey="TIM" 		;Return timeout if null entry or timeout
	S X=$$UPPER^%ZFUNC(X) 		;Password is not case sensitive
	D TERM^%ZUSE(0,"ECHO")
	D ^SCAENC 			;Check encryption
	I ENC=PWDENC Q 0 		;Valid password
	S RM="Invalid password"
	Q 1
	;
	;----------------------------------------------------------------------
PWDET	; Error trap for password input - restore echo
	;----------------------------------------------------------------------
	D TERM^%ZUSE(0,"ECHO")
	S RM="Invalid password (error)"
	Q 1
	;
	;----------------------------------------------------------------------
USERNAM()	; Get username and see if OK to continue
	;----------------------------------------------------------------------
	R X:30 E  S %fkey="TIM" Q 0
	I $$UPPER^%ZFUNC(X)=USERNAME Q 1 ; Valid
	Q 0
	;
	;----------------------------------------------------------------------
TODFT()	Q $S($D(%TO):%TO,1:300)
	;
	;----------------------------------------------------------------------
KYB	; Display keyboard menu and choose option
	;----------------------------------------------------------------------
	; Reset the value of %fkey, based on option selected 
	;
	S ZB=$$EMULATE^DBSMBAR I ZB="" S ZB=13,%fkey="ENT" Q
	S %fkey=%fkey(ZB) 
	Q
	;	

