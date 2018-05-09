FORMCMD(X)	;; -  - V5.0 - Command line interpretor
	;;Copyright(c)1997 Sanchez Computer Associates, Inc.  All Rights Reserved - 08/12/97 13:56:28 - NIB
	;     ORIG:  Frank R. Sanchez (1) - 07/29/89
	;     DESC:  
	;	
	;	I18N=QUIT	;Exclude this routine from I18N standards
	;
	; Unicode note - use of $A and $C is correct in this routine as used for
	; tracking of terminators.
	;
	;---------- Revision History -------------------------------------------
	; 07/14/06 - RussellDS - CR20028
	;	     Eliminated use of $C(255).
	;
	; 05/17/06 - Allan Mattson - CR20048
	;            Replaced calls to $$UPPER^%ZFUNC with $$UPPER^SCAUTL.
	;
	; 08/12/97 - Betty Ni - 25653
        ;            Replaced follows operator "]" with a "]]".
	;
	; 08/17/95 - Phil Chenard - 13005
	;            Replace platform specific calls to system logical names
	;            with generic call to platform specific utility to return
	;            the user's home directory name, $$HOME^%TRNLNM.
	;
	; 10/26/94 - Jagannath Rao Chapyala - ARQ 18
	;	     Fetched the pre I18N version from CMS and added code so 
	; 	     as to exclude this routine from I18N standards.
	;
	; 10/25/93  Bob Chiang - I18N#23
	;
	;           Modified to replace DBSMENU routine calls with DBSMBAR.
	;-----------------------------------------------------------------------
	;
	I $G(X)="" S X=$$^FORMREAD("",99,"Command: ","T") Q:X=""
	;
	X $$PARSE(X) Q
	;
SCRIPT(inputdev,WAIT,VERIFY)	; ---------- RMS Command script file ----------
	;
	N OPEN,SX,SY,Z,readahed
	;
	I $G(inputdev)="" S inputdev=$$MORE("SCRIPT","WAIT/VERIFY") Q:inputdev=""
	S inputdev=$$DEFIO(inputdev,"SCRIPT")
	C inputdev
	S OPEN=$$FILE^%ZOPEN(inputdev,"READ")
	I 'OPEN W $$MSG^FORM($P(OPEN,"|",2)) Q
	;
	S WAIT=$G(WAIT) ; Timeout between commands
	I $G(VERIFY)="" S VERIFY=0 ; Display prompts
	;
	F record=1:1 S X=$$^%ZREAD(inputdev,.ZEOF) Q:ZEOF  U "" D VERIFY
	C inputdev
	;
	W $$MSG^FORM("Script "_inputdev_" Loaded") Q
	;
VERIFY	; --------- Display and execute the script file ----------
	;
	I "$"'[$E(X) W $$MSG^FORM("Invalid command "_X,1) Q
	F I=2:1:$L(X) Q:$A(X,I)'=32  ; Strip all leading blanks
	I VERIFY,$E(X,I+1)'="" W $$MSG^FORM("Script "_record_" "_X) 
	I WAIT R Z:WAIT
	I fileflag D FILE^FORM ; File flag is set
	;
	I "!"'[$E(X,I) X $$PARSE($E(X,I,9999))
	I $D(readahed) S X=readahed K readahed G VERIFY
	Q
	;
READAHED()	; ---------- Read the next record from a file ----------
	;
	N X
	S record=record+1
	S X=$$^%ZREAD(inputdev,.ZEOF) I ZEOF Q ""
	U ""
	I $E(X)'="$" Q X
	S readahed=X Q ""
	;
DEFIO(X,T)	; ---------- Build default IO ----------
	;
	I X'[".",$D(T) S X=X_"."_T
	I X'[":",X'["]",X'["$" S X=$$HOME^%TRNLNM(X)	;08/17/95 
	Q X
	;
WAIT(TO,COMMENT,VERIFY,PERM)	; ------------- Wait a prescribed number of second ------
	;
	S:$G(TO)="" TO=60 S WAIT=TO
	I $G(COMMENT)'="" W $$MSG^FORM(COMMENT) R X:WAIT
	I $G(VERIFY)="" S VERIFY=0
	Q
	;
EXTERNAL(DBOPT,SCRIPT)	; ----------Execute scripts externally ----------
	;
	N (DBOPT,SCRIPT,%TO,%LIBS,%UID)
	;
	I $G(DBOPT)="" Q
	D ^FORMINIT,^FORMDQ2B(DBOPT)
	D SCRIPT($G(SCRIPT))
	D TRMRES^FORMINIT
	Q
	;
CAPTURE(IO)	; ---------- Capture all Lines into file ----------
	;
	I JRNL'="" U JRNL W ! C JRNL ; Close the current file
	I IO=0 W $$MSG^FORM("Capture file "_JRNL_" closed") S JRNL="" Q
	;
	N OPEN
	I $G(IO)="" S IO=$$^FORMREAD("",80,"Device: ") Q:IO=""
	S IO=$$DEFIO(IO,"SCRIPT")
	S OPEN=$$FILE^%ZOPEN(IO,"WRITE/NEWV")
	I 'OPEN W $$MSG^FORM($P(OPEN,"|",2),1) S JRNL="" Q
	;
	S JRNL=IO,JRNLDYDX=""
	U JRNL
	;
	W "$ RESET"
	U ""
	;
	W $$MSG^FORM("Capture file "_JRNL_" opened")
	Q
	;
PARSE(X)	; ----------- Parse this string ----------
	;
	N ARG,C,CMMD,F,I,LIST,OK,OX,P,PP,Y,YY
	;
	S OX=X
	I $P(X," ",1)?1A.E=0 D REPEAT I X="" Q X ; Check for repeating syntax
	D BLDZPZC
	;
	S ER=0,Y=0
	F ARG=1:1 S YY=$$TERM(Y,"|") Q:YY=0  D ARG Q:ER  S Y=YY
	I ER Q ""
	;
	S X=OX ; Set X back to the original string
	S F=$G(F)_ARG(1) F I=2:1:(ARG-1) S F=F_" "_ARG(I)
	Q F
	;
BLDZPZC	; ------------ Build terminator location variables ZC & ZP ----------
	;
	N Q
	;
	S Q=0,ZC="|",ZP=$C(0)
	;
	F I=1:1 S Y=$E(X,I) Q:Y=""  S:Y="""" Q='Q I 'Q," |/"[Y S:$E(X,I+1)=Y X=$E(X,1,I-1)_$E(X,I+1,999),I=I-1,Y="" S:Y]"" ZC=ZC_Y,ZP=ZP_$C(I)
	S ZP=ZP_$C($L(X)+1)
	Q
	;
ARG	; ---------- Create the executable string ----------
	;
	S P=$$TERM(Y," /|")
	I P<Y D ERROR("Missing command",Y) Q
	S C=$E(X,Y+1,P-1) ; Extract command name partial
	S OK=$$PARSCMD(C) I 'OK D ERROR(OK,Y+1,P-1) Q
	S CODE=cmmd(CMMD),LIST=$G(qlfy(CMMD))
	S:C'=CMMD OX=$P(OX,C,1)_CMMD_$P(OX,C,2,999) ; Insert command in string
	;
	I P=YY S ARG(ARG)=CODE Q  ; No parameters
	I CODE'["(" D ERROR("Unexpected Parameter",P+1,YY-1) Q
	;
	; --------- Initialize all the parameters to "" -----------
	;
	S PARAMS="""""" I LIST]]"" F I=1:1:$L(LIST,"/") S PARAMS=PARAMS_$C(0,34,34)
	;
	F  Q:P=YY  D PARAMS("") Q:ER  S P=PP ; Insert parameters by position
	;
	I ER=0 S ARG(ARG)=$P(CODE,"(",1)_"("_$TR(PARAMS,$C(0),",")_")"
	Q
	;
PARAMS(PT)	; ---------- Verify parameters and insert into PARAMS ----------
	;
	S PP=$$TERM(P,PT) ; Parameter terminator position
	I " "[$E(X,P) Q:" /|"[$E(X,P+1)  D PRINPAR G PARAMB ; Extract principle
	I LIST="" D ERROR("Unexpected Parameters",P+1,PP-1) Q
	;
	N NAM,VAL
	;
	S NAM=$$UPCASE($P($E(X,P+1,PP-1),"=",1)),VAL=$P($E(X,P+1,PP-1),"=",2)
	I VAL="" S VAL=$S($E(NAM,1,2)="NO":0,1:1) I VAL=0 S NAM=$E(NAM,3,999)
	;
	F PN=1:1:$L(LIST,"/") I $E($P(LIST,"/",PN),1,$L(NAM))=NAM S PN=PN+1 Q
	E  D ERROR("Invalid parameter ("_LIST_")",P+1,PP-1) Q
	;
PARAMB	; Remove single quotes,  double remaining and insert parameter
	;
	I $D(vars) S vars(PN)=VAL Q
	;
	I $P(PARAMS,$C(0),PN)'="""""" D ERROR("Duplicate parameter",P+1,PP-1) Q
	S $P(PARAMS,$C(0),PN)=""""_$$STRIP(VAL)_"""" Q
	;
PRINPAR	; Extract the principle (1st) parameter
	;
	S PN=1,VAL=$E(X,P+1,PP-1) Q:$E(X,PP)'=" "
	F  S P=PP,PP=$$TERM(PP) S:PP-P>1 VAL=VAL_" "_$E(X,P+1,PP-1) Q:$E(X,PP)'=" "
	Q
	;
PARSCMD(C)	; ---------- Get the code from the command table ----------
	;
	S C=$$UPCASE(C)
	;
	I $D(cmmd(C)) S CMMD=C Q 1 ; Command already loaded
	I $D(^DBCTL("SYS","FORMCMD",C)) S CMMD=C D GETCMD Q 1
	;
	S Z=C
	S CMMD=$O(cmmd(Z)) I $E(CMMD,1,$L(C))=C
	E  S CMMD=$O(^(Z)) I $E(CMMD,1,$L(C))=C
	E  Q "Invalid command"
	;
	I $E($O(cmmd(CMMD)),1,$L(C))=C Q $$AMBGUS
	I $E($O(^(CMMD)),1,$L(C))=C Q $$AMBGUS
	;
	I $D(cmmd(CMMD)) Q 1
	D GETCMD Q 1
	;
GETCMD	; ---------- Load the command from disk ----------
	;
	S cmmd(CMMD)=^DBCTL("SYS","FORMCMD",CMMD)
	I $P(cmmd(CMMD),"|",2)'="" S qlfy(CMMD)=$P(cmmd(CMMD),"|",2),cmmd(CMMD)=$P(cmmd(CMMD),"|",1)
	Q
	;
AMBGUS()	; --------- Ambigious command ----------
	;
	I $D(inputdev) Q "Ambigious command"
	;
	N OP,I,X
	;
	S CMMD=Z
	F  S CMMD=$O(^DBCTL("SYS","FORMCMD",CMMD)) Q:$E(CMMD,1,$L(C))'=C  I '$D(cmmd(CMMD)) D GETCMD
	S CMMD=Z
	F I=1:1 S CMMD=$O(cmmd(CMMD)) Q:$E(CMMD,1,$L(C))'=C  S OP(I)=CMMD
	;
	S CMMD=$$^DBSMBAR(29,"","","",.OP) I 'CMMD Q ""		; *** BC - replace DBSMENU call 10/26/93
	S CMMD=OP(CMMD)
	Q 1
	;
TERM(Y,T)	; ---------- Returns next position of T in string X starting at Y
	;
	S Y=$F(ZP,$C(Y)) I Y=0 Q 0 ; Starting position wasn't found
	I $G(T)="" Q $A(ZP,Y) ; Terminate with any
	F Y=Y:1:$L(ZP) I T[$E(ZC,Y) Q
	I  Q $A(ZP,Y)
	Q 0
	;
MORE(command,vars,prompt)	; Read arguement & parameters for command
	;
	I $G(command)="" D MSG^FORM("Missing command parameter",1) Q ""
	I $G(prompt)="" S prompt=command_": "
	S command=$$UPCASE(command)
	;
	N X
	S X=$$^FORMREAD("",80-$L(prompt),prompt)
	I X="" W $$MSG^FORM("Parameter required",1) Q ""
	;
	N LIST,P,PP,PARAMS,YY,ZP,ZC
	;
	D BLDZPZC
	I '$D(cmmd(command)),'$$PARSCMD(command) D ERROR("Invalid command",Y+1,P-1) Q
	S LIST=$G(qlfy(command)),ER=0,P=0,PARAMS="",YY=$L(X)+1
	;
	F  Q:P=YY  D PARAMS("/") Q:ER  S P=PP ; Insert parameters by position
	I ER Q ""
	I $G(vars)'="" F I=1:1:$L(vars,"/") S @$P(vars,"/",I)=$G(vars(I+1))
	Q vars(1)
	;
REPEAT	; ---------- Decode prefix for repeating commands ----------
	;
	S F=$P(X," ",1),X=$P(X," ",2,999) I X="" Q
	I F=+F S F="N cycle F cycle=1:1:"_+F_" " Q
	I F="*" S F="N cycle,cycles S cycles=$$^FORMREAD("""",2,"""_$TR(X,"""","'")_", Repeat? "") F cycle=1:1:cycles " Q
	S X=F_X Q
	;
ERROR(ERROR,PB,PE)	; ---------- Interpreter error at byte location PB-PE
	;
	S ER=1
	I ERROR="" Q
	I '$D(PE) S PE=PB
	;
	W BTMPAG,VA(VIDOF),"E-",ERROR,", ",$E(X,1,PB-1) ; String up to error
	W VA(VIDHL),$E(X,PB,PE) ; Write error highlighted
	W VA(VIDOF),$E(X,PE+1,999) ; String after error
	S video=VIDOF Q
	;
UPCASE(X)	Q $$UPPER^SCAUTL(X)
	;
STRIP(X)	; Change " to
	;
	N Y
	;
	S Y=0
	F  S Y=$F(X,"""",Y) Q:'Y  S:$E(X,Y)'="""" X=$E(X,1,Y-2)_$E(X,Y,999),Y=Y-1 S Y=Y+1
	Q X
CURPOS()	Q CSI_$G(PY)_";"_$G(PX)_"H"
