FORMCONV(IO,DELIM,LINES,OUTPUT)	;; -  - V5.0 - Convert ASCII file to OOE firmat
	;;Copyright(c)1997 Sanchez Computer Associates, Inc.  All Rights Reserved - 08/12/97 13:58:07 - NIB
	;     ORIG:  Frank R. Sanchez (1) - 12/20/89
	;     DESC:
	;
	; I18N=QUIT	Excluded from I18N Standards
	;
	; Unicode note - use of remaining $A and $C instances should be OK in
	; this routine based on how they are used.
	;
	; ---------- Revision History ------------------------------------------
	; 07/18/06 - RussellDS - CR22121
  	;	     Modified to allow calls to FILE^%ZOPEN to consider character
  	;	     set exceptions for Unicode.
  	;
	; 07/14/06 - RussellDS - CR20048
	;	     Replaced $A references with $$BSASCII^SQLUTL and $C with
	;	     $$BTYECHAR^SQLUTL to ensure Unicode compliance.
	;
	; 05/17/06 - Allan Mattson - CR20048
	;            Replaced calls to $$UPPER^%ZFUNC with $$UPPER^SCAUTL.
	;
	;            Deleted pre-1994 revision history.
	;
	; 08/12/97 - Betty Ni - 25653
        ;            Replaced follows operator "]" with a "]]".
	;
	; 10/26/94 - Steve Canfield - I18N
	;	     Removed calls to $$^MSG.
	;
	; 08/16/94 - Shaodong Tony Xu - ARQ 10174
	;            Review and retrofit the privious version bugs resolved.
	;
	; 05/25/94 - Steve Canfield - I18N
	;            Replaced embedded messages with a call to extrinsic 
	;            function $$^MSG(msgid,p1,p2...) for phrase independence.
	;	     Also converted msgid from RMnnnn to nnnn.
	;-----------------------------------------------------------------------
START	;
	N BFR,DATA,I,key,LENGTH,LOC,OK,NAM,NI,PM,PREFIX,PTR,scp,zzm,zzd
	;
	S py=$G(PY)
	I '$D(py) S py=1
	I '$D(px) S px=1
	S DATA=0,LENGTH=0,PREFIX="",NI=""
	S OUTPUT=$G(OUTPUT)
	S DELIM=$G(DELIM)
	S LINES=$G(LINES)
	I LINES="" S LINES=YLIMIT
	I DELIM'="" D INITPAR
	;
	; Filename: 
	I $G(IO)="" S IO=$$^FORMREAD("",99,"Filename: ") Q:IO=""
	;
	I IO="*" S IO=$G(inputdev)
	I $D(inputdev),IO=inputdev S OK=1
	;
	E  D
	.	N CHARSET,PARAMS
	.	S CHARSET=$$CHARSET("START","IO")
	.	I CHARSET="" SET PARAMS="READ"
	.	E  S PARAMS="READ/ICHSET="_CHARSET
	.	S OK=$$FILE^%ZOPEN(IO,PARAMS)
	I 'OK W $$MSG^FORM($P(OK,"|",2),1) Q
	;
	I OUTPUT'="" D
	.	N CHARSET,PARAMS
	.	S CHARSET=$$CHARSET("START","OUTPUT")
	.	I CHARSET="" SET PARAMS="WRITE"
	.	E  S PARAMS="WRITE/OCHSET="_CHARSET
	.	S OK=$$FILE^%ZOPEN(OUTPUT,PARAMS)
	I 'OK W $$MSG^FORM($P(OK,"|",2),1) Q
	;
	W $$MSG^FORM("Converting file "_IO)	; *** BC - 11/02/93
	;
	S VIDEO=VIDOF
	;
	;
	; Save objects below cursor position
	;
	S X="",Y=PY
	F  S Y=$O(M(Y)) Q:Y=""  F  S X=$O(M(Y,X)) Q:X=""  S zzm(Y,X)=M(Y,X) K M(Y,X) I $D(D(Y,X)) S zzd(Y,X)=D(Y,X) K D(Y,X)
	;
	S px=1
	;
	F RECORD=1:1 S LINE=$$^%ZREAD(IO,.ET) Q:ET  D DECODE I RECORD=LINES Q
	;
	S LINES=RECORD ; Number of lines processed
	;
	I IO'=$G(inputdev) D CLOSE^SCAIO     ; *** XUS 08/16/94
	I OUTPUT]]"" C OUTPUT
	U ""
	;
	I $D(KEY) S KEY="" D DINAM,INSERT
	;
	; Restore original M() and D()
	;
	S X="",Y="",OFF=$ZP(M(""))
	F  S Y=$O(zzm(Y)) Q:Y=""  F  S X=$O(zzm(Y,X))  Q:X=""  S M(Y+OFF,X)=zzm(Y,X) I $D(zzd(Y,X)) S D(Y,X)=zzd(Y,X)
	D PUTRGN^FORMFUN()
	S EDITED=1 Q
	Q
	;
DECODE	; Decode this line
	;
	I $D(inputdev),IO=inputdev,$E(LINE)="$" S readahed=LINE,LINES=RECORD Q
	;
	S PTR=1
	I PREFIX'="" S LINE=PREFIX_LINE,PREFIX=""
	E  S py=py+1,px=1
	;
PARSE	;
	U ""
	N I
	S CHAR=$E(LINE,PTR) I CHAR="" D OBJECT:LENGTH Q
	I CHAR=$$BYTECHAR^SQLUTL(27) D ESC G PARSE
	I CHAR=$$BYTECHAR^SQLUTL(155) D CSI G PARSE ; ESC [
	I CHAR=DELIM S DATA=1
	I $A(CHAR)<32 D CTRL G PARSE ; Control character sequence
	I ": "[CHAR,$E(LINE,PTR+1)=" " D OBJECT G PARSE
	S PTR=PTR+1,LENGTH=LENGTH+1
	G PARSE
	;
OBJECT	; Build a data object
	;
	S m=$E(LINE,PTR-LENGTH,PTR-1)
	I $E(LINE,PTR)=":" S m=m_":"
	I m="" G OB1
	;
	I DATA D DATAOBJ G OB1
	;
	I $D(M(py)) D FIT^FORMFUN(py,px,$L(m))
	;
	S M(py,px)=VIDEO_m
	I DELIM'="" G OB1
	I m'?1"<<["1A1.11AN1"]"1.12AN1">>" G OB1
	S X=$E($P(M,">>",1),3,99),DQP=""
	S ER=0 D DIREF^FORMVAR1 I $G(ER) S ER=0 G OB1
	S D(py,px)=DQP
	D OBJ^FORMDQ2(DQP) S M(py,px)=VIDEO_m
	;
OB1	;
	;
	S px=px+$L(m)
	I ": "[$E(LINE,PTR)=0 S LENGTH=0 Q
	F I=PTR+1:1 Q:$E(LINE,I)'=" "
	S px=px+I-PTR,PTR=I,LENGTH=0
	Q
	;
CSI	; Decode command string
	;
	D OBJECT:LENGTH,PARAMS Q
	;
PARAMS	; Decode command parameters & terminator
	;
	N I,TRM,X
	F I=PTR+1:1:$L(LINE) Q:$A(LINE,I)>64
	S X=$E(LINE,PTR+1,I-1),TRM=$E(LINE,I)
	;
	I I=$L(LINE),$A(TRM)<65 S PREFIX=$E(LINE,PTR,I),PTR=I+1 Q
	;
	S PTR=I+1
	;
	I TRM="H" S py=+$P(X,";",1),px=+$P(X,";",2) Q
	I TRM="m" S:$E(X)'=";" X=";"_X D STYLE^FORMHDR(X) ; Change VIDEO
	I TRM="J" Q
	;
	I X="" S X=1 ; Default number parameter
	I TRM="A" S py=py-X Q  ; Up arrow
	I TRM="B" S py=py+X Q  ; Down Arrow
	I TRM="C" S px=px+X Q  ; Left arrow
	I TRM="D" S px=px-X Q  ; Right arrow
	Q
	;
ESC	; $C(27) encountered
	;
	D OBJECT:LENGTH
	S PTR=PTR+1,X=$E(LINE,PTR)
	I X="[" D PARAMS Q
	I X="(" S PTR=PTR+2 Q  ; Graphics toggle
	I X=")" S PTR=PTR+2 Q  ; Graphics toggle
	;
	S PTR=PTR+1
	I X=7 S scp=py_","_px Q
	I X=8 S scp=$G(scp),py=$P(scp,",",1),px=$P(scp,",",2) Q
	Q
	;
CTRL	; Control code encountered
	;
	D OBJECT:LENGTH
	S PTR=PTR+1
	;
	I CHAR=$C(14) D GI^FORMHDR Q  ; (SI) Toggle graphics on
	I CHAR=$C(15) D GO^FORMHDR Q  ; (SO) Toggle graphics off
	I CHAR=$C(8) S px=px-1 I px<1 S px=1 Q  ; (BS) Backspace
	I CHAR=$C(9) S px=px+8 Q  ; (TAB)
	I CHAR=$C(10) S py=py+1 Q  ; (LF) Linefeed
	I CHAR=$C(13) S px=1 Q  ; (CR) Carriage return
	Q
DATAOBJ	;
	S m=$E(m,2,9999),DATA=0
	S KEY=$P(m," ",1),NAM=$P(m," ",2),PAR=$P(m," ",3)
	I $E(NAM)="/" S PAR=NAM,NAM=$P(m," ",3)
	I NAM="" S:"[<"[$E(KEY)!(KEY?1A.AN1"."1A.AN) NAM=KEY
	I '$D(key(KEY)) S LOC(py,px)=KEY,key(KEY)=NAM_PAR
	E  S key(KEY)=key(KEY)_PAR I NAM]]"" S $P(key(KEY),"/",1)=NAM
	Q
DINAM	;
	;
	S KEY=$O(key(KEY)) I KEY="" Q
	S X=key(KEY),VAR=$P(X,"/",1),DQP="",ER=0
	I VAR?1A.AN1"."1A.AN S VAR="["_$P(VAR,".",1)_"]"_$P(VAR,".",2)
	I $E(VAR)="[" S X=VAR D DIREF^FORMVAR1 I ER D ERROR($G(RM)) G DINAM
	I VAR?1"<<"1E.E1">>" S DQP=VAR,$P(DQP,dl,3)=12,$P(DQP,dl,5)="T",$P(DQP,dl,18)="T"
	;
	S ER=1     ;  S ER=$$^SCACMD(key(KEY),.PM)   ; *** XUS 08/16/94
	I ER'="" D ERROR(VAR_", "_ER) G DINAM
	I $P(DQP,dl,18)'=$P(DQP,dl,5) S $P(DQP,dl,8)=1,$P(DQP,dl,7)=0
	S key(KEY)=DQP
	G DINAM
	;
ERROR(E)	; Report errors to output device
	;
	I OUTPUT="" W $$MSG^FORM(E,1) Q
	U OUTPUT W !,E Q
	;
INSERT	; Insert data defined in key(KEY) into correct location
	;
	N m,py,px
	;
	S (py,px)=""
	F  S py=$O(LOC(py)) Q:py=""  F  S px=$O(LOC(py,px)) Q:px=""  S KEY=LOC(py,px),DQP=key(KEY) I DQP[dl X "D OBJ^"_MAINPGM_"(DQP)" S D(py,px)=DQP,M(py,px)=VIDOF_m
	Q
INITPAR	; Initialize data item parameter array
	;
	S PM("LENGTH")="N|||||1|132||DQP|0|3"
	S PM("DECIMAL")="N||||||||DQP|0|4"
	S PM("TYPE")="U||^DBCTL(""SYS"",""DVFM"",||||||DQP|0|5"
	S PM("TABLE")="T||||||||DQP|0|6"
	S PM("REQUIRED")="L||||||||DQP|0|7"
	S PM("PROTECT")="L||||||||DQP|0|8"
	S PM("PATTERN")="T||||||||DQP|0|9"
	S PM("MINIMUM")="N||||||||DQP|0|10"
	S PM("MAXIMUM")="N||||||||DQP|0|11"
	S PM("FORMAT")="U|||||||D PFMT^FORMVAR1|DQP|0|18"
	Q
	;
TR(X)	Q $$UPPER^SCAUTL(X)
	;
CFORMAT	; Check format parameter values for valid entry
	;
	Q
	;
	;----------------------------------------------------------------------
CHARSET(LABEL,INSTNAME)	; Get alternate character set
	;----------------------------------------------------------------------
	N CHARSET
	S CHARSET=""
	I $$VALID^%ZRTNS("UCIOENCD") S CHARSET=$$^UCIOENCD("Routine","DBSDDIMP",LABEL,INSTNAME)
	Q CHARSET