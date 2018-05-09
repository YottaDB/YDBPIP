DBSEXEP	;;DBS - REP - V5.0 -  COMPILE REPORT INTO MUMPS CODE
	;;Copyright(c)1997 Sanchez Computer Associates, Inc.  All Rights Reserved - 08/12/97 14:52:02 - NIB
	;     ORIG:  FRANK SANCHEZ  9/15/86
	;
	; COMPILE FORMAT DEFINITIONS INTO MUMPS CODE
	;
	; KEYWORDS:	DATA-QWIK
	;
	; INPUTS:
	;	. L	Field length		/TYP=N/REQ/MECH=VAL
	;       . TYP	Format type		/TYP=T/REQ/MECH=VAL
	; 	. DEC	Decimal precision	/TYP=N/REQ/MECH=VAL
	;
	; RETURNS:
	;	. P3    MUMPS code              /TYP=T
	;
	; EXAMPLES:
	;	S L=12,TYP="$",DEC=2     Returns: P3=$J(V,12,2)
	;       S L=12,TYP="E",DEC=2              P3=$J($FN(V,",",2),12)
	;       S L=12,TYP="D"                    P3=$J($$DAT^%ZM(V),12)
	;
	;---- Revision History ------------------------------------------------
	; 08/30/06 - RussellDS - CR22720
	;	     Replaced call to $$UPPER^SCAUTL with $$UPPER^UCGMR to
	;	     avoid bootstrap issues.
	;
	; 05/17/06 - Allan Mattson - CR20048
	;            Replaced calls to $$UPPER^%ZFUNC with $$UPPER^SCAUTL.
	;
	;            Deleted pre-1996 revision history.
	;
	; 08/11/97 - Betty Ni - 25653
        ;            Replaced follows operator "]" with a "]]".
	;
	; 02/09/96 - Bob Chiang - 21064
	;            Added error checking on RDn (round to n decimal position)
	;            format to only accept an integer or NULL after the RD
	;            format.
	;-----------------------------------------------------------------------
        ;  I18N=QUIT: Excluded from I18N standards
START	;
	S P2=$G(P(2)),P3="V"
	;
	N RND,JUS,EDT,NEG,ZRO,X,z,ZL,DRCR,Q,P4
	S ZL=L
	; Use field length of 0 to indicate the raw data format
	I TYP="T",L=0 S L=9999				; *** - 07/18/95 BC
	I TYP="RI,N"!(TYP="N,RI") S TYP="RI"		; *** - 03/20/95 BC
	I TYP="T,JR"!(TYP="JR,T") S TYP="JR",DEC=""	; *** - BC - Disable decimal logic 09/17/93
	S DRCR=0 I TYP["DRCR" S DRCR=1 DO
	.	S L=L-3				; Reserve for DR/CR message
	.	I TYP="DRCR" S TYP="E" Q
	.	S TYP=$P(TYP,",DRCR",1)
	S ER=0,z=","_TYP,RM=""
	;
	I TYP="TW" S P3="V" Q
	;
	S NEG=$$FIND(.z,"N")
	S JUS=$$FIND(.z,"J")
	S ZRO=$$FIND(.z,"Z") I ZRO="ZS" S ZRO="+V=0:$J("""","_L_")"
	;
	S RND=$$FIND(.z,"R")
	;							    ; Check valid syntax
	I RND'="",$P(RND,"RD",2)'?.N S ER=1,RM=$$^MSG(1350,RND) Q  ; *** 02/09/96
	I RND'="" S DEC=$P(RND,"RD",2)+0 I JUS="" S JUS="JR"
	;
	S z=$E(z,2,999)
	;
	I z["EM" S P3="$$MSK^%ZM(V,"""_$E(z,3,999)_""")" Q
	;
	I z="E",RND="" s DEC=2
	;
	I z="$,E"!(z="N,E")!(z="E,N")!(z="E,$") S z="E"
	;
	I z["," D  Q
	.	D DATE I "V"'[P3 Q		; *** - BC - Check date format 10/20/93
	.	; Unexpected parameter ~p1
	.	S ER=1,RM=$$^MSG(2814,z),P3="" Q
	;
	I $G(^DBCTL("SYS","RFMT","$"))'["%ZM","$"[z,NEG'="" S z=NEG,NEG=""
	;
	I z'="",$D(^DBCTL("SYS","RFMT",z)) DO
	.	;
	.	; Desc | conversion | suppress DEC | suppress JUS
	.	;
	.	S X=^(z)
	.	I JUS="",$P(X,"|",4)'="" S JUS="J"_$P(X,"|",4) ;Default justification
	.	I $P(X,"|",3),RND="" S DEC="" ;	Suppress Decimal
	.	I $P(X,"|",4) S JUS=""			; Suppress Justification
	.	S P3=$P(X,"|",2) I P3="" S P3="V" Q	; Low Level Format call
	.	I z="N",'DEC S P3="$J(glvn,len)"	; change to $J(V,LEN)
	.	I P3["len" S P3=$$replace(P3,"len",+L),ZL=""
	.	I P3["dec" S P3=$$replace(P3,"dec",+DEC),DEC=""
	.	S P3=$$replace(P3,"glvn","V")
	;
	I P3="V" D DATE,IMAGE 		; Date Mask or Image *** - BC - 10/20/93
	;
	I NEG'="" S P3=$$NEG(P3)
	I TYP="U" S P3="$$UPPER^UCGMR("_P3_")"
	I TYP="L" Q
	;
	I ZL="" G START1
	I JUS="JR" DO
	.	I DEC="" S P3="$J("_P3_","_+L_")" Q
	.	I +DEC=0,TYP="N" S P3="$J("_P3_","_+L_")" Q
	.	S P3="$J("_P3_","_+L_","_+DEC_")" Q
	;
	I JUS="JC" S P3="$$CTR^%ZM("_P3_","_+L_")"
	;
	I JUS="JL",L S P3=P3_"_$J("_""""""_","_L_"-$L("_P3_"))"	; *** 09/06/95 BC
START1	;
	I RND'="" S Z=$$ROUND(RND) S P3=$$replace(P3,"V",Z)
	;
	I ZRO'="" S P3="$S("_ZRO_",1:"_P3_")"
	;
	I 'DRCR Q
	S Q="""",P4=$P(P3,"(V",1)_"(-V"_$P(P3,"(V",2,99)
	S P3="$S(V<0:"_P4_"_"_Q_" CR"_Q_",V>0:"_P3_"_"_Q_" DR"_Q_",1:"_P3_"_"_Q_"   "_Q_")"
	Q
	;
	;-----------------------------------------------------------------------
DATE	; Date Format error checking *** - BC - 10/20/93
	;-----------------------------------------------------------------------
	;
	N v,x,I,ok,del
	S v=z,ok=1
	I z="" S P3="V" Q
	F del=",","/","-" S v=$TR(v,del," ")	; Convert , to blanks first
	F I=1:1:$L(v," ") D  I $G(ER) Q		; Check each date format type
	.	S x=$P(v," ",I) I x="" Q
	.	S x="|"_x_"|"
	.	I "|DD|DAY|MM|MON|YY|YEAR|ML|MS|DL|DS|"'[x S ok=0 Q
	I ok S P2="",P3="$$DAT^%ZM(V,"""_z_""")" Q
	Q
	;----------------------------------------------------------------------
IMAGE	; Image formats
	;----------------------------------------------------------------------
	I z="IN"!(z="INS") S P2="",P3="$E(10E30"_"_V,"_(33-L)_"+$L(V),99)"
	I z="INS" S P3="$$SGN^%ZM("_P3_")" Q
	;
	I z="I$"!(z="I$S") S P2="",P3="$E(10E30"_"_(V*100\1),"_(33-L)_"+$L(V*100\1),99)"
	I z="I$S" S P3="$$SGN^%ZM("_P3_")" Q
	;
	I z?1"I$"1N.N S P2="",P3="$E(10E30"_"_(V*10E"_($P(z,"$",2)-1)_"\1),"_(33-L)_"+$L(V*10E"_($P(z,"$",2)-1)_"\1),99)"
	I z?1"I$S"1N.N S P2="",P3="$E(10E30"_"_(V*10E"_($P(z,"S",2)-1)_"\1),"_(33-L)_"+$L(V*10E"_($P(z,"S",2)-1)_"\1),99)"
	I  S P3="$$SGN^%ZM("_P3_")" Q
	Q
	;
	;----------------------------------------------------------------------
ROUND(RND)	; Round value
	;----------------------------------------------------------------------
	;
	S DEC="" ; 					Override decimal
	;
	I RND="RM" Q "$S(V<0:V-500000,1:V+500000)\1000000"
	I RND="RK" Q "$S(V<0:V-500,1:V+500)\1000"
	I RND="RH" Q "$S(V<0:V-50,1:V+50)\100"
	I RND="RT" S DEC=0 Q "$S(V<0:V-5,1:V+5)\10"
	I RND="RI" S DEC=0 Q "V"
	I RND["RD" S DEC=$E(RND,3,99) Q "V"
	Q "V"
	;
	;----------------------------------------------------------------------
NEG(P3)	; Patch P3 for Negative numbers
	;----------------------------------------------------------------------
	;
	S NEG=$TR($E(NEG,2),"R","T")
	;
	N I,p,n,pl,pt
	;
	I P3["$$NUM^%ZM" DO  Q P3
	.	D PARAMS(.P3,.p,3)
	.	I p(3)="" S P3="$FN("_p(1)_","""_NEG_""","_+p(2)_")" Q
	.	;
	.	I """.,"[$E(p(3),1,3),"PR"[$E(p(3),4) S P3="$FN("_p(1)_","""_$E(p(3),4)_$E(p(3),3)_""","_+p(2)_")" Q
	.	;
	.	I $E(p(3))="""" DO  Q
	..	S p(3)=$E(p(3),2,$L(p(3))-1)
	..	I $L(p(3))=1 S p(3)=p(3)_"9"
	..	S P3="$$NUM^%ZM("_p(1)_","_+p(2)_","""_p(3)_NEG_""")" Q
	.	;
	.	S P3="$$PATNUM^%ZM("_p(1)_","_+p(2)_","_p(3)_",""%%"_NEG_""")"
	;
	I P3["$FN" DO  Q P3
	.	S p1=$P(P3,"$FN",1),p2=$P(P3,"$FN",2,99)
	.	S p3=$P(p2,")",2,99),p2=$P(p2,")",1)
	.	S p2=$P(p2,",",1)_","""_NEG_"""_"_$P(p2,",",2,99)
	.	S P3=p1_"$FN"_p2_")"_p3
	;
	I $E(P3,1,3)="$J("  D PARAMS(.P3,.p,3) Q "$J($FN("_p(1)_","""_NEG_""","_+p(3)_"),"_+p(2)_")"
	;
	I NEG="D" S P3="$S(V<0:$J(-"_P3_",0,"_+DEC_")_"" DR"",1:$J("_P3_",0,"_+DEC_")_""   "")"
	I NEG="C" S P3="$S(V<0:$J(-"_P3_",0,"_+DEC_")_"" CR"",1:$J("_P3_",0,"_+DEC_")_""   "")"
	Q P3
	;
	;----------------------------------------------------------------------
PARAMS(X,p,n)	; Extract parameters from the string X and put them
	;	  into the array list.
	;
	;			Eg: S X="$J($FN(V,"P",2),12,2)"
	;			    D PARAMS(.X..p,2)
	;
	;			    X=$J($FN(V,"P",2))
	;			    p(1)=12   p(2)=2	
	;
	;----------------------------------------------------------------------
	;
	N I,P
	;
	I $E(X,$L(X))'=")" Q
	S X=$E(X,1,$L(X)-1)
	;
	F P=$L(X,")")-1:-1:0 I $L($P(X,")",P+1,99),"""")#2 Q
	S P=$P($P(X,")",P+1,999),"(",2,99)
	;
	F I=1:1:n S p(I)=""
	S n=1 F I=1:1:$L(P,",") S:p(n)'="" p(n)=p(n)_"," S p(n)=p(n)_$P(P,",",I) I $L(p(n),"""")#2 S n=n+1 I '$D(p(n)) Q
	Q
	;
	;----------------------------------------------------------------------
FIND(flist,fopt)	; Find the last occurence of option in flist
	;----------------------------------------------------------------------
	;
	N Y,YE,X
	S Y=0,X="",fopt=","_fopt
	;
	F  S Y=$F(flist,fopt,Y) Q:'Y  DO
	.	S YE=$F(flist,",",Y) I 'YE S YE=$L(flist)+2
	.	I Y+2>YE Q
	.	S X=$E(flist,Y-1,YE-2)
	.	S flist=$E(flist,1,Y-3)_$E(flist,YE-1,999),Y=Y-3
	Q X
	;----------------------------------------------------------------------
PP	; Screen Input Post processor
	;----------------------------------------------------------------------
	;
	I X["RD"!(X["I$")!(X["I$S") S I(3)="" Q
	I X["DD"!(X["MM")!(X["YY")!(X["MON")!(X["YEAR")!(X["DAY")!(X["ML")!(X["MS")!(X["DL")!(X["DS") S I(3)="" Q
	;
	I X'["," Q
	;
	N J,Z
	S I(3)=""
	F J=1:1 S Z=$P(X,",",J) Q:Z=""  I '$D(^DBCTL("SYS","RFMT",Z)) S ER=1 Q
	; Invalid format ~p1
	I ER S RM=$$^MSG(1350,Z)
	Q
	;
	;----------------------------------------------------------------------
EXT(NEW)	; Replace V with value NEW
	;----------------------------------------------------------------------
	;
	; Example:
	;              L=12,TYP="$",DEC=2,NEW="abc(1)"
	;
	;              EXT^DBSEXEP(NEW) return P3 = $J(abc(1),12,2)
	;
	I L="" S L=0
	D START
	;
	S P2=$$replace(P2,"V",NEW)
	S P3=$$replace(P3,"V",NEW)
	Q
	;
	;----------------------------------------------------------------------
fmt(flist,glvn,len,dec,fmt)	; Format a string for compilers
	;----------------------------------------------------------------------
	;
	;	      flist :== format list   eg: ZS,E
	;	       glvn :== glvn reference
	;		len :== Field Length (0-999)
	;		dec :== Decimal Precision
	;
	I $G(glvn)="" S glvn="V"
	I $G(flist)="" Q glvn
	I $G(len)="" S len=$L(@glvn)		; *** BC - 01/05/94
	I $G(dec)="" S dec=0
	;
	I flist="N",+dec=0 Q glvn
	;
	N x,z
	 ;
	; ---------- Screen def , report def , default to Text
	;
	S fmt(flist)=$P($G(^DBCTL("SYS","DVFM",flist)),"|",2)
	;
	I fmt(flist)="" D  Q glvn
	.	;
	.	N L,TYP,DEC,P2,P3
	.	S L=len,TYP=flist,DEC=dec D DBSEXEP
	.	S glvn=$$replace(P3,"V",glvn)
	;
	S z=fmt(flist) ;		Low Level Format call
	I z["len" S z=$$replace(z,"len",len)	
	I z["dec" S z=$$replace(z,"dec",dec)
	;
	s x="$J(glvn,0,0)" I z[x S z=$$replace(z,x,"glvn")
	I glvn'="glvn" S z=$$replace(z,"glvn",glvn)
	;
	Q z
	;
	;----------------------------------------------------------------------
replace(z,ov,nv)	; replace all occurrences of ov w/ nv in z
	;----------------------------------------------------------------------
	;
	N y
	S y=0
	F  S y=$F(z,ov,y) Q:y=0  S z=$E(z,1,y-$L(ov)-1)_nv_$E(z,y,$L(z)),y=y+$L(nv)-$L(ov)
	Q z
	;-----------------------------------------------------------------------
TEST	; Private ; Test routine called by DBSTEST
	;-----------------------------------------------------------------------
	K OLNTB,%TAB,RM,ER
	S (P2,P3)=""
	S %TAB("A(1)")=".A31/TBL=^DBCTL(""SYS"",""RFMT"",/XPP=D PP^DBSEXEP"
	S %TAB("A(2)")=".A32"
	S %TAB("A(3)")=".A33"
	S %TAB("A(4)")=".A34"
	;
	S %READ="A(1)/REQ,A(2)/REQ,A(4)/REQ,A(3)/NOREQ",%NOPRMT="F",%FRAME=1
	D ^UTLREAD I VFMQ="Q" Q
	;
	S TYP=A(1),V=A(2),DEC=A(3),(L,LEN)=A(4)
	;
	D START
	I ER W $$MSG^%TRMVT($G(RM),"",1) G TEST	; *** - BC - Display error message
	;
	I P2]]"" S X=P2_" S V="_P3
	E  S X="S V="_P3
	W !!!,V X X W !,V
	W !!,X
	W $$MSG^%TRMVT("","",1)
	G TEST
	;
QA	;
	N %LIBS,RID,KEY,FMT
	D ^SCAIO
	K ^TMP($J)
	S %LIBS="SYSDEV",RID="",SEQ=""
	F  S RID=$O(^DBTBL(%LIBS,5,RID)) Q:RID=""  D
	.	S KEY="@RS"
	.	F  S KEY=$O(^DBTBL(%LIBS,5,RID,KEY)) Q:KEY=""  D
	..		S SEQ=100 F  S SEQ=$O(^DBTBL(%LIBS,5,RID,KEY,SEQ)) Q:SEQ=""  D
	...			S FMT=$P(^(SEQ),"|",4)
	...			I FMT'="" S ^TMP($J,FMT)=""
QA1	;
	I $G(IO)="" S IO=0
	U IO W !!
	S FMT="" F  S FMT=$O(^TMP($J,FMT)) Q:FMT=""  D
	.	S L=12,TYP=FMT,DEC=0 I TYP["$"!(TYP["E") S DEC=2
	.	D START
	.	W !,FMT I $G(RM)'="" W ?40,RM Q
	.	W ?20,P2,?30,P3
	W !
	C IO
	Q
