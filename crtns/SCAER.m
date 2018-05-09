SCAER	; Error log report
	;
	; **** Routine compiled from DATA-QWIK Procedure SCAER ****
	;
	; 12/06/2007 16:14 - chenardp
	;
	;
	N scaer
	;
	D PROC
	;
	I $D(scaer) D
	.	;
	.	; Remove all variables and reset symbol table from scaer array
	.	;
	.	;   #ACCEPT Date=10/06/05; Pgm=RussellDS; CR=17397
	.	;*** Start of code by-passed by compiler
	.	kill (scaer)
	.	;*** End of code by-passed by compiler ***
	.	;
	.	S %ZTX=""
	.	F  S %ZTX=$order(scaer(%ZTX)) Q:%ZTX=""  I %ZTX'="%ZTX" S @%ZTX=scaer(%ZTX)
	.	I ($D(scaer("%ZTX"))#2) S %ZTX=scaer("%ZTX")
	.	E  K %ZTX
	.	Q 
	;
	Q 
	;
PROC	; Main processing
	N vpc
	;
	N ER
	N DATE N TJD
	N %fkey N CONAM N ET N IO N %NOBANNER N %NOPRMT N %OPMODE N PGM N PID
	N %READ N RID N RM N %TAB N SCAER N TMP N VFMQ N VIN3 N VIN4 N VIN5 N VIN6 N VIN7 N VIN8 N X
	N DSPVAR N ERSEQ N MUMPS N OLNTB N SEQ
	;
	D ZBINIT^%TRMVT()
	S CONAM="Profile Framework"
	;
	;  #ACCEPT PGM=Erik Scheetz;DAT=12/11/02
	I '($D(%TO)#2) S %TO=60
	;
	N cuvar S cuvar=$$vDb3()
	 S cuvar=$G(^CUVAR(2))
	;
	S TJD=$P(cuvar,$C(124),1)
	;
	S %LIBS="SYSDEV"
	S PID=$J
	;
	S DATE=$P($H,",",1)
	;
	S %TAB("DATE")=".TJD4/HLP=[ERROR]DATE/TBL=[ERROR]DATE:DISTINCT/XPP=D DATEPP^SCAER"
	S %TAB("SEQ")=".SEQ2/TBL=""TMP(/RH=Seq     Error ID         Description""/XPR=D SEQPRE^SCAER"
	;
	S %READ="@@%FN,,DATE/REQ,SEQ/REQ"
	S %NOPRMT="F"
	;
	D ^UTLREAD
	;
	S vpc=(VFMQ="Q") Q:vpc 
	;
	S ERSEQ=$piece(TMP(SEQ)," ",1)
	S ET=$piece(TMP(SEQ),"|",2)
	;
	S (MUMPS,DSPVAR)=0
	S IO=$I
	S VIN3="="_DATE
	S VIN5="="_ERSEQ
	S (VIN4,VIN6,VIN7,VIN8)="ALL"
	;
	S RID="SCAER"
	D ^URID
	I PGM="" D  Q 
	.	S ER=1
	.	S ET="INVLDRPT"
	.	D DSP^UTLERR
	.	Q 
	;
	S (%NOBANNER,SCAER)=1
	;
	D V0^@PGM
	;
	D VAR
	;
	; Reset terminal attributes
	D TERM^%ZUSE(0,"ECHO/ESCAPE/EDIT/NOCHARACTERS/NOIMAGE/WIDTH=80/TERMINATOR=""""")
	WRITE $$SCRAWON^%TRMVT ; Enable auto wrap
	;
	Q 
	;
VAR	; Prompt for variable
	;
	N zexit S zexit=0
	;
	F  Q:'('zexit)  D
	.	; Variable to display or <SEL> for options
	.	WRITE $$LOCK^%TRMVT,$$BTM^%TRMVT,$$^MSG(2938),":  "
	.	S X=$$TERM^%ZREAD()
	.	I X="",%fkey'="SEL" S zexit=1 Q 
	.	;
	.	WRITE $$BTM^%TRMVT
	.	I '(X="?"!($E(X,1)="*")!(%fkey="SEL")) D DISPONE Q 
	.	;
	.	S X=$$^DBSMBAR(169)
	.	;
	.	I X=""!(X=1) Q 
	.	;
	.	I X=2 D ALL Q 
	.	;
	.	I X=3 D  Q 
	..		D LOAD
	..		S zexit=1
	..		Q 
	.	;
	.	I X=4 D OUTPUT Q 
	.	;
	.	I X=5 D STACK Q 
	.	;
	.	Q 
	;
	Q 
	;
DISPONE	; Display single variable
	;
	N HIT S HIT=0
	N ARR N Y N Z
	;
	WRITE $$CUP^%TRMVT(1,23),$$CLL^%TRMVT
	;
	N error9,vop1 S error9=$$vDb4(DATE,ET,ERSEQ,X,.vop1)
	I $G(vop1)=1 D
	.	WRITE X,"=",$P(error9,$C(124),1),!
	.	S HIT=1
	.	Q 
	;
	S Z=X
	I X["""" D
	.	S Z=""
	.	N I
	.	F I=1:1:$L(X) S Y=$E(X,I) S Z=Z_$SELECT(Y'="""":Y,1:Y_Y)
	.	Q 
	;
	S ARR=1_""""_$SELECT(Z'["(":Z_"(",1:Z)_""".E"
	;
	D DISP
	;
	I 'HIT WRITE $$^MSG(2042) ; Not found
	E  WRITE !
	Q 
	;
ALL	; Display all variables
	;
	 S HIT=0
	 S ARR=".E"  S X="#z"
	;
	D DISP
	;
	WRITE !
	Q 
	;
DISP	; Variables display
	;
	N QUIT S QUIT=0
	;
	N rs,vos1,vos2,vos3,vos4,vos5,vos6 S rs=$$vOpen1()
	I '$G(vos1) Q 
	;
	F  Q:'($$vFetch1())  Q:(X'?@ARR)  Q:QUIT  D
	.	WRITE $P(rs,$C(9),1),"=",$$TRCTRL($P(rs,$C(9),2)),!
	.	S HIT=HIT+1
	.	;
	.	I HIT#22=0 D
	..		S QUIT=$$WAIT
	..		I QUIT=0 WRITE $$BTM^%TRMVT
	..		Q 
	.	Q 
	;
	Q 
	;
TRCTRL(X)	; Translate control characters in X to $C(xx) and quote strings
	;
	I '(X?.E1C.E!(X[$char(34))) Q $SELECT(X?1N.N:X,1:$char(34)_X_$char(34))
	;
	N HIT S HIT=0 N I
	N CNTRL S CNTRL="" N L S L=$L(X) N Y S Y="" N Z
	;
	F I=1:1 Q:I>L  D
	.	S Z=$E(X,I)
	.	I Z?1C S CNTRL=1
	.	E  S CNTRL=0
	.	;
	.	I CNTRL D
	..		S Y=Y_$SELECT(I=1:"$C(",'HIT:$char(34)_"_$C(",1:",")_$ascii(Z)
	..		S HIT=HIT+1
	..		Q 
	.	E  D
	..		S Y=Y_$SELECT(I=1:$char(34),HIT:")_"_$char(34),1:"")_$SELECT(Z="""":$char(34),1:"")_Z
	..		S HIT=0
	..		Q 
	.	Q 
	;
	S Y=Y_$SELECT(HIT:")",1:$char(34))
	;
	Q Y
	;
STACK	; Display stack info (plus device and lock info)
	;
	 S X=""
	 S HIT=0
	N I
	;
	F I="#DEVICE","#LOCK","#STACK" D STACK2(I)
	;
	Q 
	;
STACK2(INFO)	;
	;
	N VALUE N VAR1
	N J
	N QUIT S QUIT=0
	;
	I HIT=0 WRITE !
	WRITE !,$E(INFO,2,9)
	;
	F J=1:1 D  Q:QUIT 
	.	S VAR1=INFO_J
	.	;
	.	N error9,vop1
	.	S error9=$$vDb4(DATE,ET,ERSEQ,VAR1,.vop1)
	.	I $G(vop1)=0 S QUIT=1 Q 
	.	;
	.	WRITE ?11,$P(error9,$C(124),1),!
	.	S HIT=HIT+1
	.	;
	.	I HIT#22=0 D
	..		S QUIT=$$WAIT
	..		I QUIT=0 WRITE $$BTM^%TRMVT
	..		Q 
	.	Q 
	;
	Q 
	;
OUTPUT	; Output error
	;
	; So that the variables are nopt redefined by D-Q.
	N %NOBANNER N %NOOPEN N ET
	N DATE
	N DSPVAR N SEQ
	;
	D ^SCAIO
	USE IO
	S %NOOPEN=""
	S DSPVAR=1
	S %NOBANNER=1
	D V0^@PGM
	D CLOSE^SCAIO
	;
	USE 0
	;
	Q 
	;
LOAD	; Load variables
	;
	S %ZTX="#z"
	;
	N rs,vos1,vos2,vos3,vos4,vos5,vos6,vos7 S rs=$$vOpen2()
	I '$G(vos1) Q 
	;
	F  Q:'($$vFetch2())  D
	.	N VAR S VAR=$P(rs,$C(9),1)
	.	S scaer(VAR)=$P(rs,$C(9),2)
	.	Q 
	;
	Q 
	;
RPT	; Call full report
	;
	N ET N PGM N RID
	N ER
	;
	S RID="SCAER"
	D ^URID
	I PGM="" D  Q 
	.	S ER=1 S ET="INVLDRPT"
	.	D DSP^UTLERR
	.	Q 
	;
	D ^@PGM
	Q 
	;
DATEPP	; Date post processor
	;
	N ERCNT
	N DATE1
	;
	Q:X="" 
	S DATE1=$$^SCAJD(X)
	;
	N rs,vos1,vos2,vos3,vos4,vos5 S rs=$$vOpen3()
	I $$vFetch3() S ERCNT=rs
	E  S ERCNT=0
	;
	; No errors logged on ~p1
	I (ERCNT=0) D SETERR^DBSEXECU("ERROR","MSG",1931,$S(DATE1'="":$ZD(DATE1,"MM/DD/YEAR"),1:"")) Q:ER 
	;
	; ~p1 errors logged
	S RM=$$^MSG(3036,ERCNT)
	;
	Q 
	;
SEQPRE	; Sequence pre-processor
	;
	N CNT
	N ZE
	;
	N $ZT S $ZT="D ZX^UCGMR("_+$O(vobj(""),-1)_","_$ZL_",""vtrap1^"_$T(+0)_""")"
	;
	N rs,vos1,vos2,vos3,vos4,vos5,vOid S rs=$$vOpen4()
	;
	S CNT=1
	;
	F  Q:'($$vFetch4())  D
	.	;
	.	N SEQ
	.	;
	.	S ZE=$P(rs,$C(9),3)
	.	I ZE="" S ZE=$P(rs,$C(9),1)
	.	E  S ZE=$piece(ZE,",",1,2)_","_$piece(ZE,",",4)
	.	;
	.	; Remove control characters that affect screen display
	.	S ZE=$translate(ZE,$C(10,11,12,13),"    ")
	.	;
	.	S SEQ=$P(rs,$C(9),2)
	.	S SEQ=SEQ_$J("",15-$L(SEQ))
	.	;
	.	S TMP(CNT)=SEQ_"  "_$E(ZE,1,55)_"|"_$P(rs,$C(9),1)
	.	;
	.	S CNT=CNT+1
	.	Q 
	;
	Q 
	;
WAIT()	;  Wait for user response
	;
	I $$^DBSMBAR(158)=2 Q 1
	Q 0
	;
vSIG()	;
	Q "60338^70891^Dan Russell^8216" ; Signature - LTD^TIME^USER^SIZE
	;
vDb3()	;	voXN = Db.getRecord(CUVAR,,0)
	;
	I '$D(^CUVAR)
	I $T S $ZS="-1,"_$ZPOS_",%PSL-E-RECNOFL,,CUVAR" X $ZT
	Q ""
	;
vDb4(v1,v2,v3,v4,v2out)	;	voXN = Db.getRecord(ERROR9,,1,-2)
	;
	N error9
	S error9=$G(^ERROR(v1,v2,v3,9,v4))
	I error9="",'$D(^ERROR(v1,v2,v3,9,v4))
	S v2out='$T
	;
	Q error9
	;
vOpen1()	;	VAR,VALUE FROM ERROR9 WHERE DATE=:DATE AND ET=:ET AND SEQ=:ERSEQ AND VAR NOT ='~' ORDER BY VAR
	;
	;
	S vos1=2
	D vL1a1
	Q ""
	;
vL1a0	S vos1=0 Q
vL1a1	S vos2=$G(DATE) I vos2="" G vL1a0
	;
	S vos3=$G(ET) I vos3="" G vL1a0
	S vos4=$G(ERSEQ) I vos4="" G vL1a0
	S vos5=""
vL1a6	S vos5=$O(^ERROR(vos2,vos3,vos4,9,vos5),1) I vos5="" G vL1a0
	I '(vos5'="~") G vL1a6
	Q
	;
vFetch1()	;
	;
	I vos1=1 D vL1a6
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S vos6=$G(^ERROR(vos2,vos3,vos4,9,vos5))
	S rs=$S(vos5=$C(254):"",1:vos5)_$C(9)_$P(vos6,"|",1)
	;
	Q 1
	;
vOpen2()	;	VAR,VALUE FROM ERROR9 WHERE DATE=:DATE AND ET=:ET AND SEQ=:ERSEQ AND VAR>:%ZTX ORDER BY VAR
	;
	;
	S vos1=2
	D vL2a1
	Q ""
	;
vL2a0	S vos1=0 Q
vL2a1	S vos2=$G(DATE) I vos2="" G vL2a0
	;
	S vos3=$G(ET) I vos3="" G vL2a0
	S vos4=$G(ERSEQ) I vos4="" G vL2a0
	S vos5=$G(%ZTX) I vos5="",'$D(%ZTX) G vL2a0
	S vos6=vos5
vL2a7	S vos6=$O(^ERROR(vos2,vos3,vos4,9,vos6),1) I vos6="" G vL2a0
	Q
	;
vFetch2()	;
	;
	I vos1=1 D vL2a7
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S vos7=$G(^ERROR(vos2,vos3,vos4,9,vos6))
	S rs=$S(vos6=$C(254):"",1:vos6)_$C(9)_$P(vos7,"|",1)
	;
	Q 1
	;
vOpen3()	;	COUNT(SEQ) FROM ERROR WHERE DATE=:DATE1
	;
	;
	S vos1=2
	D vL3a1
	Q ""
	;
vL3a0	S vos1=0 Q
vL3a1	S vos2=$G(DATE1) I vos2="" G vL3a0
	;
	S vos3=""
vL3a4	S vos3=$O(^ERROR(vos2,vos3),1) I vos3="" G vL3a9
	S vos4=""
vL3a6	S vos4=$O(^ERROR(vos2,vos3,vos4),1) I vos4="" G vL3a4
	S vos5=$G(vos5)+1
	G vL3a6
vL3a9	I $G(vos5)="" S vd="" G vL3a0
	Q
	;
vFetch3()	;
	;
	;
	I vos1=1 D vL3a9
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S rs=$G(vos5)
	S vos5=""
	S vos1=100
	;
	Q 1
	;
vOpen4()	;	ET,SEQ,MUMPSZE FROM ERROR WHERE DATE=:DATE ORDER BY SEQ ASC
	;
	S vOid=$G(^DBTMP($J))-1,^($J)=vOid K ^DBTMP($J,vOid)
	S vos1=2
	D vL4a1
	Q ""
	;
vL4a0	S vos1=0 Q
vL4a1	S vos2=$G(DATE) I vos2="" G vL4a0
	;
	S vos3=""
vL4a4	S vos3=$O(^ERROR(vos2,vos3),1) I vos3="" G vL4a11
	S vos4=""
vL4a6	S vos4=$O(^ERROR(vos2,vos3,vos4),1) I vos4="" G vL4a4
	S vos5=$G(^ERROR(vos2,vos3,vos4,1))
	S vd=$S(vos3=$C(254):"",1:vos3)_$C(9)_$S(vos4=$C(254):"",1:vos4)_$C(9)_$P(vos5,"|",5)
	S ^DBTMP($J,vOid,1,vos4,vos3)=vd
	G vL4a6
vL4a11	S vos2=""
vL4a12	S vos2=$O(^DBTMP($J,vOid,1,vos2),1) I vos2="" G vL4a0
	S vos3=""
vL4a14	S vos3=$O(^DBTMP($J,vOid,1,vos2,vos3),1) I vos3="" G vL4a12
	Q
	;
vFetch4()	;
	;
	;
	I vos1=1 D vL4a14
	I vos1=2 S vos1=1
	;
	I vos1=0 K ^DBTMP($J,vOid) Q 0
	;
	S rs=^DBTMP($J,vOid,1,vos2,vos3)
	;
	Q 1
	;
vtrap1	;	Error trap
	;
	N error S error=$ZS
	S ER=1
	;
	; Either directory or system is invalid
	I $piece(($$ETLOC^%ZT),",",1)="FILE_PROTECTION" S RM=$$^MSG(888) Q 
	;
	; System error
	S RM=$$ETLOC^%ZT_" ... "_$$^MSG(7061)
	;
	Q 
