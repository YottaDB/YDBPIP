FORMPNT(OPT,IO,COPIES)	;; -  - V5.0 - Print form to output device
	;;Copyright(c)1999 Sanchez Computer Associates, Inc.  All Rights Reserved - 02/24/99 10:06:56 - CHIANG
	;     ORIG:  Frank R. Sanchez (1) - 11/29/88
	;     DESC:  OOE "PRINT" command
	;
	; I18N=QUIT	Excluded from I18N Standards
	; ---------- Revision History ------------------------------------------
	; 07/14/06 - RussellDS - CR20048
	;	     Replaced $A references with $$BSASCII^SQLUTL and $C with
	;	     $$BTYECHAR^SQLUTL to ensure Unicode compliance.
	;
	; 04/26/06 - Allan Mattson - CR20048
	;            Replaced all occurences of $C(155) with $$CSI^%TRMVT in
	;            order to resolve problems with terminal emulation in a
	;            Unicode environment.
	;
        ; 02/23/99  -  Chiang - 31754
        ;              Modified to use +$H (system date) as the input value
        ;              for the ^%ZM date utility.
        ;
        ;              Removed old revision history.
	;----------------------------------------------------------------------
	;
	I $G(COPIES)="" S COPIES=1
	;
	N IOHDG,IORM,IOSL,CONAM,RN,x,y
	;
	; Form layput,OOE keypad layout,HELP documentation
	;
	I $G(OPT)="" S OPT=$$^DBSMBAR(122) I 'OPT Q	; *** BC - Replace DBSMENU call
	;
	I $G(IO)="" W BTMPAG S IO=$$^FORMREAD("",60,"Device: ","U")
	I IO="" S IO=$I W IO
	S ER=0,QUIT=0 S POP=IO D ^SCAIO
	I ER W $$MSG^FORM("Cannot open "_IO) Q		; *** BC - 11/02/93
	;
	I IO=$I W $$REGION^FORMINIT,CLSCREEN
	;
	U IO
	I OPT=2 D HELP G EXIT
	;
	I OPT=3 D DOC G EXIT
	;
	D IMAGE Q
	;
	; Print HELP screen
HELP	;
	N %O,%NOPRMT,ZB,OLNTB,GOLD
	;
	S N="" F  S N=$O(^DBCTL("SYS","%KB",N)) Q:N=""  S ZB(N)=$G(^DBCTL("SYS","FORMKEY",0,^(N)))
	;
	F  S N=$O(key(N)) Q:N=""  S ZB(N)=key(N)
	;
	I $G(SID)'="" S ZB("*KP0")="" ; Remove RW-COM option
	;
	S %NOPRMT=""
	S %O=2 U 0 I $I'=IO S %O=4
	U IO 
	N OLDSID S OLDSID=$G(SID)
	S SID="FORMHLP" D ^USID I PGM="" Q
	D ^@PGM
	S SID=OLDSID
	Q
	;
IMAGE	; Print an image of the screen(WYSIWYG)
	;
	N VO,%O,v1,v2,v3,RH,COPY
	I $G(COPIES)="" S COPIES=1
	S VO=1,%O=4,RH=80
	S x="",y=""
	D IMY G EXIT
	;
	;
IMY	S y=$O(M(y)) I y="" G IMP
IMX	S x=$O(M(y,x)) I x="" G IMY
	;
	S VO=VO+1,X=$E(M(y,x),7,9999),H=$E(M(y,x),1,6)
	I x+$L(x)>RH S RH=x+$L(x) ; Right most object
	S VO(VO)=$$BYTECHAR^SQLUTL(y+1)_$$BYTECHAR^SQLUTL(x)_$$BYTECHAR^SQLUTL($L(X))_H_"0"_($$BSASCII^SQLUTL(H,1)>127)_"0T"_X
	G IMX
	;
IMP	; Print array
	;
	I RH>80 S RH=132
	;
	S X="",$P(X,"q",RH-2)=""
	S VO(1)=$C(1,1)_$$BYTECHAR^SQLUTL(RH)_"000000010T"_"+"_X_"+"
	S VO=VO+1,VO(VO)=$$BYTECHAR^SQLUTL($O(M(""),-1)+2)_$C(1)_$$BYTECHAR^SQLUTL(RH)_"000000010T"_"+"_X_"+" ; Bottom line
	S VO=VO_"|"_VO_"|13"
	;
	F COPY=1:1:COPIES D ^DBSPNT()
	Q
	;
VIDD(X)	; Build video attribute string (New structure)
	;
	S v3=$E(X)=SO,v2=0,v1=0,X=$E(X,2,999)
	;
	I $F(X,7) S v1=v1+1
	I $F(X,1) S v1=v1+2
	I $F(X,4) S v1=v1+4
	I $F(X,5) S v1=v1+8
	Q v1_v2_v3
	;
EXIT	;
	;
	U 0 I IO'=$I D CLOSE^SCAIO
	U ""
	W $$MSG^FORM("Printing complete",1)		; *** BC - 11/02/93
	I IO=$I D TRMSET^FORMINIT,PUTRGN^FORMFUN()
	Q
	;
	; Print HELP documentation
	;
DOC	;
	N RMS,I,ET,X,Z
	;
	S RMS=$$SCAU^%TRNLNM("HELP","FORM.DOC")			;08/17/95
	;
	S Z=$$FILE^%ZOPEN(RMS,"READ",5) I 'Z U 0 W !,"Can't open "_RMS_" file" h 5 q
	;
	F I=1:1 S X=$$^%ZREAD(RMS,.ET) Q:ET  D DOC1
	U IO W #,!
	C RMS,IO
	Q
	;
DOC1	;
	; Remove ESC 1m,4m,22m,24m
	;
	U IO
	I X'[$$CSI^%TRMVT W X,! Q
	;
	F J=1,4,22,24 S K=$$CSI^%TRMVT_J_"m" F L=1:1 Q:X'[K  S X=$P(X,K,1)_$P(X,K,2,99)
	;
	W X,!
	Q
	;
CONVERT(DOCFILE,MATCH)	; 
	;
	N INDEX,ZEOF,X,Y,LEN,LN
	;
	I $G(DOCFILE)="" Q
	I $G(MATCH)="" S MATCH="   "_$$CSI^%TRMVT
	;
	S LEN=$L(MATCH),LN=1
	;
	;
	S X=$$FILE^%ZOPEN(DOCFILE,"READ",5) I 'X Q
	;
	U 0 W !!,"Create OOE on-line help documentation",!
	;
	K ^OOEDOC S ^OOEDOC=$$DAT^%ZM(+$H)	; 02/23/99 bc
	;
	; Read each record and search for the value returned by $$CSI^%TRMVT
	;
	F I=1:1 S X=$$^%ZREAD(DOCFILE,.ZEOF) Q:ZEOF  D INDEX
	;
	C DOCFILE
	Q
	;
INDEX	;
	;
	; Remove FF
	;
	I $E(X)=$C(12) Q
	U 0
	;
	S XX=X
	;
	I $E(X,1,LEN)'=MATCH D SET Q
	;
	; Insert level marker
	;
	F J=1,4,22,24 S K=$$CSI^%TRMVT_J_"m" F L=1:1 Q:X'[K  S X=$P(X,K,1)_$P(X,K,2,99)
	;
	S FUNC=$P($E(X,4,99)," ",1)
	;
	I $D(INDEX(FUNC)) D SET Q
	;
	S INDEX(FUNC)=""
	;
	S LN=1 D SET
	Q
SET	;
	I $G(FUNC)="" Q
	S ^OOEDOC(FUNC,LN)=X,LN=LN+1
	Q
