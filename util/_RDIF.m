%RDIF	;M Utility;Locate routines differences between two directories
	;;Copyright(c)1994 Sanchez Computer Associates, Inc.  All Rights Reserved - 04/28/94 17:41:08 - SYSRUSSELL
	; ORIG:  Dan Russell (2417) - 02/12/86
	;
	; For two directories containing .M source code, locate routines in one 
	; and not the other as well as any that are different based on either 
	; date and time only or on full compare.
	;
	; This routine also uses data in ^%ZRDIF to determine certain routines 
	; to ignore totally (^%ZRFIF(0,rtn)), and others to print if difference,
	; but print word 'ignore' (^%ZRDIF(1,rtn)).  Only applies to DEV or QA 
	; directories (DEV or QA in physical directory name).
	;
	; KEYWORDS:	Routine handling
	;
	N
	D INT^%T
	W !!,"Locate routines with differences between two directories"
	;
DIR1	W ! S DIR1=$$PROMPT^%READ("      Compare routines in directory:  ","")
	Q:DIR1=""
	I $$NOM(DIR1) G DIR1
DIR2	S DIR2=$$PROMPT^%READ("         With routines in directory:  ","")
	I DIR2="" W ! G DIR1
	I $$NOM(DIR2) G DIR2
	;
	S DATIM=$$PROMPT^%READ("      Compare only on date and time?  Yes=> ","")
	I DATIM="" S DATIM="Y"
	S DATIM=$E($TR(DATIM,"y","Y"))="Y"
	;
	S DIFONLY=$$PROMPT^%READ("Show routines with differences only?  Yes=> ","")
	I DIFONLY="" S DIFONLY="Y"
	S DIFONLY=$E($TR(DIFONLY,"y","Y"))="Y"
	;
	D TWO^%RSEL(DIR1,DIR2) ; Get routine list
	I '$G(%ZR) Q
	;
	W ! D ^%SCAIO
	;
	S PDIR1=$P($ZPARSE(DIR1,"","*"),"*") ; Physical directory name
	S PDIR2=$P($ZPARSE(DIR2,"","*"),"*")
	;
	S DEVQA=(PDIR1_PDIR2["DEV"!(PDIR1_PDIR2["QA"))
	;
	; Set up arrays of routines to skip (SKP) and those to skip, unless differences, then print IGNORE (IGNORE)
	S X="",(SKPMIN,IGNMIN)=8,(SKPMAX,IGNMAX)=0
	F I=1:1 S X=$O(^%ZRDIF(0,X)) Q:X=""  S RTN=$P(X,"*",1) S SKP(RTN)=X["*",L=$L(RTN) S:L<SKPMIN SKPMIN=L S:L>SKPMAX SKPMAX=L
	F I=1:1 S X=$O(^%ZRDIF(1,X)) Q:X=""  S RTN=$P(X,"*",1) S IGNORE(RTN)=X["*",L=$L(RTN) S:L<IGNMIN IGNMIN=L S:L>IGNMAX IGNMAX=L
	;
	U IO D HDR
	U 0 S OUTDEV=$I'=IO
	;
	S ROU="",(CNT,RCNT)=0
ROU	S ROU=$O(%ZR(ROU)) I ROU="" G EXIT
	S RCNT=RCNT+1
	I DEVQA,$$SKIP G ROU ; Skip it
	;
	I OUTDEV U 0 W $J(ROU,10) W:$X>70 !
	S (%L1,%L2,L1,L2)="" ; First two line defaults
	S IN1=PDIR1_ROU_".M" O IN1:(READ:REWIND:EXC="G FILE2")
	U IN1:EXC="G FILE2" R %L1,%L2
	;
FILE2	S IN2=PDIR2_ROU_".M" O IN2:(READ:REWIND:EXC="G CONT")
	U IN2:EXC="G CONT" R L1,L2
	;
CONT	S %DTIM=$$GETDT(%L2),%USER=$$GETUSER(%L2)
	S DTIM=$$GETDT(L2),USER=$$GETUSER(L2)
	;
	S (DATEDIF,BODYDIF)=0
	I %DTIM'=DTIM S DATEDIF=1
	I DATIM G CLOSE:DIFONLY&'DATEDIF,DISP ; Date/time only
	;
	S I=0
	U IN1:(REWIND:EXC="D EOF1") S EOF1=$ZEOF
	U IN2:(REWIND:EXC="D EOF2") S EOF2=$ZEOF
	;
DIFLP	S I=I+1
	I 'EOF1 U IN1 R %L S EOF1=$ZEOF
	I 'EOF2 U IN2 R L S EOF2=$ZEOF
	I EOF1,EOF2 G DIFEND
	I %L=L G DIFLP
	; Ignore first two lines if both comments
	I I<3,$P(%L,$C(9),2)?1";;".E,$P(L,$C(9),2)?1";;".E G DIFLP
	S BODYDIF=1 ; difference
	;
DIFEND	I DIFONLY,'(DATEDIF!BODYDIF) G CLOSE ; No differences, display only if differences
	;
DISP	S DIF=DATEDIF+BODYDIF
	I DEVQA,$$IGNORE G:'DIF CLOSE S %DTIM="Ignore",DTIM=%DTIM
	I DIF S CNT=CNT+1
	U IO I $Y>57 D HDR
	W ROU,?10,%DTIM,?31,%USER,?40,DTIM,?61,USER,?74,$S(DIF:"YES ",1:"no")
	W $S(DATEDIF:"d",1:" "),$S(BODYDIF:"b",1:" "),!
CLOSE	C IN1,IN2
	G ROU
	;
GETDT(LINE)	; Get date and time
	I LINE="" Q "NO ROUTINE"
	S X=$P($P(LINE," - ",2)," (",1) ; Date and time info
	I X["%N" S X=$P($P(X,"%N",2)," ",2,99)
	E  F I=1:1:$L(X) I $E(X,I)?1N S X=$E(X,I,99) Q
	I X="" Q "NO DATE"
	Q X
	;
GETUSER(LINE)	; Get user name
	Q $P(LINE," - ",3)
	;
HDR	U IO W #,"Routine differences between ",PDIR1," and ",PDIR2
	W !?63,$$^%ZD($H)," ",%TIM
	S X=""
	I DIFONLY S X="Display differences only."
	I DATIM S X=X_$S(X="":"",1:"  ")_"Check date and time only."
	I X'="" W !!,X
	W !!,"Routine",?10,PDIR1,?40,PDIR2,?74,"Diff"
	W ! F J=1:1:80 W "-"
	W !
	Q
	;
EXIT	U IO W !!,"Routines compared:  ",RCNT,"  Differences:  ",CNT,!#
	U 0 I IO'=$I W !!,"Routines compared:  ",RCNT,"  Differences:  ",CNT,! D CLOSE^%SCAIO
	Q
	;
NOM(DIR)	; See if any .M source routines in DIR
	N X
	S X=$E(DIR,$L(DIR))
	I X'="]",X'=":" S DIR=DIR_":"
	S X=$ZSEARCH(DIR_"*.M")
	I X'="" Q 0
	W " ... no .M source files in this directory"
	Q 1
	;
SKIP()	; Check to see if should skip routine
	S Z=0
	F I=SKPMIN:1:SKPMAX S X=$E(ROU,1,I) I $G(SKP(X)) S Z=1 Q
	I $D(SKP(ROU)) S Z=1
	Q Z
	;
IGNORE()	; Check to see if want to ignore if no differences, otherwise
	; just print IGNORE
	S Z=0
	F I=IGNMIN:1:IGNMAX S X=$E(ROU,1,I) I $G(IGNORE(X)) S Z=1 Q
	I $D(IGNORE(ROU)) S Z=1
	Q Z
EOF1	S EOF1=1,%L="" Q
EOF2	S EOF2=1,L="" Q
