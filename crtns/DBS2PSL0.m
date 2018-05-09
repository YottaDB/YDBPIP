DBS2PSL0(dbtbl2,VPT,VPB)	; -  - V7.0 - PSL Screen Compiler
	;
	; **** Routine compiled from DATA-QWIK Procedure DBS2PSL0 ****
	;
	; 11/08/2007 14:07 - chenardp
	;
	;
	S EXTSID=SID
	S VSAV(1)=""
	S VSAV(2)=""
	S Q=$char(34)
	S %="|"
	S QQ=Q_Q
	S (BLKSIZ,DEFV,PXSEQ,PON,ISEQ,%MOD,MAXLN,SAVT,%OFF)=0
	S D=1
	S C=1
	S PFID=""
	S KVAR="kill %TAB,VFSN,VO,VPTBL,vtab"
	;
	; Default all video to 0
	S (VPRV1,VPRV2,VDAV1,VDAV2)=0
	; Literal field, no data type
	S VPRTYP=" "
	; Protection Code for Literals, read only
	S VPRPRO=1
	; Graphics toggle off for data
	S VDAGI=0
	S OLNTB=1001
	N cuvar S cuvar=$$vDb3()
	 S cuvar=$G(^CUVAR("%VN"))
	 S:'$D(vobj(dbtbl2,0)) vobj(dbtbl2,0)=$S(vobj(dbtbl2,-2):$G(^DBTBL(vobj(dbtbl2,-3),2,vobj(dbtbl2,-4),0)),1:"")
	S PGM=$P(vobj(dbtbl2,0),$C(124),2)
	S PRE=$P(vobj(dbtbl2,0),$C(124),4)
	;
	I PGM="" D GTPGM^DBSDS
	S PGM=$TR(PGM,"*","S") D:PGM="" GTPGM^DBSDS S vobj(dbtbl2,-100,0)="",$P(vobj(dbtbl2,0),$C(124),2)=PGM N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" D ^DBTBL2FL(dbtbl2,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/",1) K vobj(dbtbl2,-100) S vobj(dbtbl2,-2)=1 Tcommit:vTp  
	;
	; - Compile Run-Time Program -
	WRITE !!,SID,?11," - ",$$^MSG("5193")," - ",PGM," "
	WRITE $$TIM^%ZM," (",$P(cuvar,$C(124),1),")",!
	;
	D PARLIST(.dbtbl2,.vobjlst,$P(vobj(dbtbl2,0),$C(124),1),.vFID,.vSN) ; Build actual and formal parameter lists.
	I PRE'?.E1"^"1A.AN S PRE=""
	;  S ER=0 D ~p1  I ER Q
	I PRE'="" S PRE=" set ER=0 do "_PRE_"("_vobjlst("actual")_") if ER quit"
	E  S PRE=" "
	 S:'$D(vobj(dbtbl2,0)) vobj(dbtbl2,0)=$S(vobj(dbtbl2,-2):$G(^DBTBL(vobj(dbtbl2,-3),2,vobj(dbtbl2,-4),0)),1:"")
	S PFID=$P(vobj(dbtbl2,0),$C(124),1)
	S TOTOBJ=0 S SEQ=0 S ESEQ=SEQ S %NAMCUR=$P(vobj(dbtbl2,0),$C(124),7)*1000
	D LOAD
	D TABINFO(SID,.ditab)
	S VPROBJ=0
	S VPT=DT(1)\1000 S VPB=DT($order(DT(""),-1))\1000
	Q 
	;
LOAD	; Create DT(SEQ) & %NAMCUR(DINAM) array's
	N dinam N DINAM N x
	S x=""
	S SEQ=0
	N ds,vos1,vos2,vos3,vos4,vos5 S ds=$$vOpen1()
	F  Q:'($$vFetch1())  D
	.	N dbtbl2d S dbtbl2d=$$vDb2($P(ds,$C(9),1),$P(ds,$C(9),2),$P(ds,$C(9),3))
	.	S SEQ=vobj(dbtbl2d,-5)
	.	S dinam=$P(vobj(dbtbl2d),$C(124),5)
	.	S $piece(x,"|",1)=$P(vobj(dbtbl2d),$C(124),1)
	.	S $piece(x,"|",2)=$P(vobj(dbtbl2d),$C(124),2)
	.	S $piece(x,"|",3)=$P(vobj(dbtbl2d),$C(124),3)
	.	S $piece(x,"|",5)=$P(vobj(dbtbl2d),$C(124),5)
	.	S $piece(x,"|",6)=$P(vobj(dbtbl2d),$C(124),6)
	.	S $piece(x,"|",7)=$P(vobj(dbtbl2d),$C(124),7)
	.	S $piece(x,"|",8)=$P(vobj(dbtbl2d),$C(124),8)
	.	S $piece(x,"|",9)=$P(vobj(dbtbl2d),$C(124),9)
	.	S $piece(x,"|",10)=$P(vobj(dbtbl2d),$C(124),10)
	.	S $piece(x,"|",11)=$P(vobj(dbtbl2d),$C(124),11)
	.	S $piece(x,"|",12)=$P(vobj(dbtbl2d),$C(124),12)
	.	S $piece(x,"|",13)=$P(vobj(dbtbl2d),$C(124),13)
	.	S $piece(x,"|",14)=$P(vobj(dbtbl2d),$C(124),14)
	.	S $piece(x,"|",15)=$P(vobj(dbtbl2d),$C(124),15)
	.	S $piece(x,"|",18)=$P(vobj(dbtbl2d),$C(124),18)
	.	S $piece(x,"|",21)=$P(vobj(dbtbl2d),$C(124),21)
	.	S $piece(x,"|",22)=$P(vobj(dbtbl2d),$C(124),22)
	.	S $piece(x,"|",30)=$P(vobj(dbtbl2d),$C(124),30)
	.	S TOTOBJ=TOTOBJ+1
	.	I dinam?1"<<".E1">>" S dinam=$E(($piece(dinam,">>",1)),3,999)
	.	;
	.	; Convert <<VAR,FMT,SIZE,...>> to standard DT()
	.	S DINAM=dinam
	.	; convert <<"TEXT">> to TEXT
	.	I $P(vobj(dbtbl2d),$C(124),11)?1"<<"1E.E1">>" S x=$$VAR(dbtbl2d)
	.	;
	.	I $E(DINAM,1)="[",DINAM?.E1",".E1"]"1E.E S DINAM="["_$piece(DINAM,",",2)
	.	S %NAMCUR(DINAM)=$piece(x,"|",1)
	.	I %NAMCUR,%NAMCUR(DINAM)>%NAMCUR D
	..		S %NAMCUR(DINAM)=%NAMCUR(DINAM)_"+"
	..		S ZREPEAT($piece(x,"|",5))=""
	..		Q 
	.	;
	.	; Null text tags
	.	I $E(DINAM,1)="@",$piece(x,"|",2)["*" S $piece(x,"|",5)=""
	.	S DT(SEQ)=x
	.	K vobj(+$G(dbtbl2d)) Q  ; while
	;
	Q 
	;
VAR(dbtbl2d)	; <<VAR,PMT,FMT,SIZE,TBL,MIN,MAX,DEC>>
	;
	N X N Y N Z
	;
	S (X,Z)=""
	S $piece(X,"|",1)=$P(vobj(dbtbl2d),$C(124),1)
	S $piece(X,"|",2)=$P(vobj(dbtbl2d),$C(124),2)
	S $piece(X,"|",3)=$P(vobj(dbtbl2d),$C(124),3)
	S $piece(X,"|",5)=$P(vobj(dbtbl2d),$C(124),5)
	S $piece(X,"|",6)=$P(vobj(dbtbl2d),$C(124),6)
	S $piece(X,"|",7)=$P(vobj(dbtbl2d),$C(124),7)
	S $piece(X,"|",8)=$P(vobj(dbtbl2d),$C(124),8)
	S $piece(X,"|",9)=$P(vobj(dbtbl2d),$C(124),9)
	S $piece(X,"|",10)=$P(vobj(dbtbl2d),$C(124),10)
	S $piece(X,"|",11)=$P(vobj(dbtbl2d),$C(124),11)
	S $piece(X,"|",12)=$P(vobj(dbtbl2d),$C(124),12)
	S $piece(X,"|",13)=$P(vobj(dbtbl2d),$C(124),13)
	S $piece(X,"|",14)=$P(vobj(dbtbl2d),$C(124),14)
	S $piece(X,"|",15)=$P(vobj(dbtbl2d),$C(124),15)
	S $piece(X,"|",18)=$P(vobj(dbtbl2d),$C(124),18)
	S $piece(X,"|",21)=$P(vobj(dbtbl2d),$C(124),21)
	S $piece(X,"|",22)=$P(vobj(dbtbl2d),$C(124),22)
	S $P(vobj(dbtbl2d),$C(124),30)=$P(vobj(dbtbl2d),$C(124),5)
	S $piece(X,"|",30)=$P(vobj(dbtbl2d),$C(124),30)
	S Y=$P(vobj(dbtbl2d),$C(124),11) S Y=$E(Y,3,$L(Y)-2) ;strip off <<  >>
	I Y?1A.AN!(Y?1"%".AN)!(Y?1A.AN1"("1AN.AN1")") D  Q X
	.	S $piece(X,"|",5)=Y
	.	S $piece(X,"|",11)=""
	.	S $piece(X,"|",2)=$P(vobj(dbtbl2d),$C(124),10)
	.	Q 
	;
	; <<VAR>> or <<$function>> syntax
	I $E(Y,1)="$"!($piece(Y,",",4)="") Q X
	I $piece(Y,",",4)=0 Q $piece(X,"|",1,10)_"|<<"_$piece(Y,",",1)_">>|"_$piece(X,"|",12,99)
	;
	S $piece(Z,"|",5)=$piece(Y,",",1) ; data item name ... replace with var name
	S $piece(Z,"|",11)=$piece(Y,",",2) ; prompt
	S $piece(Z,"|",10)=$piece(Y,",",3) ; typ
	S $piece(Z,"|",3)=$piece(Y,",",4) ; len
	S $piece(Z,"|",13)=$piece(Y,",",5) ; min
	S $piece(Z,"|",14)=$piece(Y,",",6) ; max
	S $piece(Z,"|",15)=$piece(Y,",",7) ; decimal
	I $piece(Y,",",8)>0 S $piece(Z,"|",21)=124 S $piece(Z,"|",22)=$piece(Y,",",8) ; position
	S $piece(Z,"|",6)=$piece(Y,",",9,99) ; table
	S $piece(Z,"|",1)=$piece(X,"|",1) ; location preamble
	S $piece(Z,"|",12)=$piece(X,"|",12) ;required flag
	S $piece(Z,"|",18)=$piece(X,"|",18) ; print edit
	S $piece(Z,"|",2)=$piece(Y,",",3) ;format
	;
	I $$vDbEx1() S $piece(Z,"|",9)=1 ;pre proc
	I $$vDbEx2() S $piece(Z,"|",8)=1 ; post proc
	Q Z
	;
	; ---------- Data item protection
PROT	;
	N X
	;
	I $get(VP(1))'["VPTBL(" Q 
	D TMPD(" //")
	S X=VP(1)_" set VO(@)=$E(VO(@),1,11)_(VP+1)_$E(VO(@),13,99)"
	D TMPD(X)
	D TMPD(" //")
	Q 
	;
TMPD(X)	;
	;
	S D=D+1
	S TMPD(D)=X
	Q 
	;
PARLIST(dbtbl2,vobjlst,FILES,vFID,vSN)	;
	;
	N DLIB N i N LIB N PFID N X
	;
	D REPEAT(.dbtbl2,.vFID,.vSN)
	S vobjlst("actual")=""
	S vobjlst("formal")=""
	S vobjlst("tab")=""
	;
	I FILES'="" D
	.	N fid
	.	S (LIB,DLIB)=%LIBS S PFID=$piece(FILES,",",1)
	.	;
	.	; build actual and formal parameter list.
	.	F i=1:1:$L(FILES,",") D
	..		S fid=$piece(FILES,",",i)
	..		I '($D(fsn(fid))#2) D fsn^DBSDD(.fsn,fid) ; file header info
	..		S vobjlst("actual")=vobjlst("actual")_",."_$piece(fsn(fid),"|",1) ;actual parameter list for all procedure calls
	..		I $E(vobjlst("actual"),$L(vobjlst("actual")))="(" S vobjlst("actual")=$E(vobjlst("actual"),1,$L(vobjlst("actual"))-1)
	..		;
	..		S vobjlst("tab")=vobjlst("tab")_",."_$piece(fsn(fid),"|",1) ;actual parameter list for all procedure calls
	..		I $E(vobjlst("tab"),$L(vobjlst("tab")))="(" S vobjlst("tab")=$E(vobjlst("tab"),1,$L(vobjlst("tab"))-1)
	..		;
	..		S vobjlst("formal")=vobjlst("formal")_",Record"_fid_" "_$piece(fsn(fid),"|",1) ; formal list
	..		I $E(vobjlst("formal"),$L(vobjlst("formal")))="(" S vobjlst("formal")=$E(vobjlst("formal"),1,$L(vobjlst("formal"))-1)
	..		;
	..		I ($D(vFID(fid))#2) D
	...			S vobjlst("formal")=vobjlst("formal")_"()" ; add parens if array of objects
	...			S vobjlst("actual")=vobjlst("actual")_"()" ; add parens if array of objects
	...			Q 
	..		S vobjlst(i)=$piece(fsn(fid),"|",1)_"|"_fid_"|Record"_fid
	..		Q  ; FOR
	.	Q  ; if FILES'="" ..
	;
	S vobjlst("tab")=$E(vobjlst("tab"),2,999) ; strip off comma
	I vobjlst("tab")="." S vobjlst("tab")="" ; set to null if no parameters
	S vobjlst("actual")=$E(vobjlst("actual"),2,999) ; strip off comma
	I vobjlst("actual")="." S vobjlst("actual")="" ; set to null if no parameters
	S vobjlst("formal")=$E(vobjlst("formal"),2,999) ; strip off comma
	Q 
	;
REPEAT(dbtbl2,vFID,vSN)	;
	 S:'$D(vobj(dbtbl2,0)) vobj(dbtbl2,0)=$S(vobj(dbtbl2,-2):$G(^DBTBL(vobj(dbtbl2,-3),2,vobj(dbtbl2,-4),0)),1:"")
	;
	N di N fid N name N sn
	;
	I '$P(vobj(dbtbl2,0),$C(124),7) Q 
	N ds,vos1,vos2,vos3,vos4 S ds=$$vOpen2()
	F  Q:'($$vFetch2())  D
	.	N dbtbl2d S dbtbl2d=$G(^DBTBL($P(ds,$C(9),1),2,$P(ds,$C(9),2),$P(ds,$C(9),3)))
	.	I $P(dbtbl2d,$C(124),1)\1000<$P(vobj(dbtbl2,0),$C(124),7) Q  ; not in repeat region
	.	S name=$P(dbtbl2d,$C(124),5)
	.	I $E(name,1)'="[" Q  ; not a real column name
	.	S fid=$piece(($E(name,2,1048575)),"]",1)
	.	I fid["," S fid=$piece(fid,",",2)
	.	I '($D(fsn(fid))#2) D fsn^SQLDD(.fsn,fid)
	.	S sn=$piece(fsn(fid),"|",1)
	.	I $E(sn,$L(sn))="(" S sn=$E(sn,1,$L(sn)-1)
	.	S vFID(fid)=sn
	.	S vSN(sn)=fid ; file is part of repeat region
	.	S sn=$$vStrUC(sn)
	.	S di=$piece(name,"]",2)
	.	S di=$$vStrUC(di)
	.	S REPEAT(sn_"."_di)="" ; Used in REPEATCK^DBS2PSL4
	.	Q 
	Q 
	;
TABINFO(SID,ditab)	;
	;
	N SEQ S SEQ=1
	;
	K ditab
	;
	N ds,vos1,vos2,vos3 S ds=$$vOpen3()
	;
	F  Q:'($$vFetch3())  D
	.	;
	.	N DI N VAR
	.	;
	.	N dbtbl2d S dbtbl2d=$G(^DBTBL($P(ds,$C(9),1),2,$P(ds,$C(9),2),$P(ds,$C(9),3)))
	.	;
	.	S DI=$P(dbtbl2d,$C(124),5)
	.	S VAR=$P(dbtbl2d,$C(124),11)
	.	;
	.	; If data item reference, remove library and save
	.	I (DI?1"["1E.E1"]"1E.E) S DI="["_$piece(DI,",",2) D
	..		;
	..		I (DI="") S DI=" "
	..		S ditab(DI)=(+$P(dbtbl2d,$C(124),1))_"|"_SEQ
	..		S SEQ=SEQ+1
	..		Q 
	.	;
	.	I (VAR?1"<<"1E.E1">>") D
	..		;
	..		S VAR=$E(VAR,3,$L(VAR)-2)
	..		I ((VAR?1"%"1A.AN)!(VAR?1A.AN)) D
	...			;
	...			I (DI="") S DI=" "
	...			S ditab(DI)=(+$P(dbtbl2d,$C(124),1))_"|"_SEQ
	...			S SEQ=SEQ+1
	...			Q 
	..		Q 
	.	Q 
	;
	Q 
	;
vSIG()	;
	Q "60662^55394^Pete Chenard^10599" ; Signature - LTD^TIME^USER^SIZE
	; ----------------
	;  #OPTION ResultClass 0
vStrUC(vObj)	; String.upperCase
	;
	;  #OPTIMIZE FUNCTIONS OFF
	Q $translate(vObj,"abcdefghijklmnopqrstuvwxyz±³µ¶¹º»¼¾¿àáâãäåæçèéêëìíîïðñòóôõöøùúûüýþ","ABCDEFGHIJKLMNOPQRSTUVWXYZ¡£¥¦©ª«¬®¯ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖØÙÚÛÜÝÞ")
	;
vDb2(v1,v2,v3)	;	vobj()=Db.getRecord(DBTBL2D,,1)
	;
	N vOid
	S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordDBTBL2D"
	S vobj(vOid)=$G(^DBTBL(v1,2,v2,v3))
	I '(v3>0)
	E  I vobj(vOid)="",'$D(^DBTBL(v1,2,v2,v3))
	S vobj(vOid,-2)='$T
	;
	S vobj(vOid,-3)=v1
	S vobj(vOid,-4)=v2
	S vobj(vOid,-5)=v3
	Q vOid
	;
vDb3()	;	voXN = Db.getRecord(CUVAR,,0)
	;
	I '$D(^CUVAR)
	I $T S $ZS="-1,"_$ZPOS_",%PSL-E-RECNOFL,,CUVAR" X $ZT
	Q ""
	;
vDbEx1()	;	min(1): DISTINCT LIBS,SID,SEQ,PSEQ FROM DBTBL2PP WHERE LIBS=:%LIBS AND SID=:SID AND SEQ=:SEQ AND PSEQ=1
	;
	N vsql1
	S vsql1=$G(%LIBS) I vsql1="" Q 0
	;
	;
	S SEQ=+SEQ
	I '($D(^DBTBL(vsql1,2,SID,SEQ,1))#2) Q 0
	Q 1
	;
vDbEx2()	;	min(1): DISTINCT LIBS,SID,SEQ,PSEQ FROM DBTBL2PP WHERE LIBS=:%LIBS AND SID=:SID AND SEQ=:SEQ AND PSEQ=21
	;
	N vsql1
	S vsql1=$G(%LIBS) I vsql1="" Q 0
	;
	;
	S SEQ=+SEQ
	I '($D(^DBTBL(vsql1,2,SID,SEQ,21))#2) Q 0
	Q 1
	;
vOpen1()	;	LIBS,SID,SEQ FROM DBTBL2D WHERE LIBS=:%LIBS AND SID=:SID AND SEQ>:SEQ
	;
	;
	S vos1=2
	D vL1a1
	Q ""
	;
vL1a0	S vos1=0 Q
vL1a1	S vos2=$G(%LIBS) I vos2="" G vL1a0
	S vos3=$G(SID) I vos3="" G vL1a0
	S vos4=$G(SEQ) I vos4="",'$D(SEQ) G vL1a0
	S vos5=0
vL1a5	S vos5=$O(^DBTBL(vos2,2,vos3,vos5),1) I vos5="" G vL1a0
	I '(vos5>vos4&(vos5'="")) G vL1a5
	Q
	;
vFetch1()	;
	;
	;
	I vos1=1 D vL1a5
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S ds=vos2_$C(9)_vos3_$C(9)_$S(vos5=$C(254):"",1:vos5)
	;
	Q 1
	;
vOpen2()	;	LIBS,SID,SEQ FROM DBTBL2D WHERE LIBS=:%LIBS AND SID=:SID AND SEQ>0
	;
	;
	S vos1=2
	D vL2a1
	Q ""
	;
vL2a0	S vos1=0 Q
vL2a1	S vos2=$G(%LIBS) I vos2="" G vL2a0
	S vos3=$G(SID) I vos3="" G vL2a0
	S vos4=0
vL2a4	S vos4=$O(^DBTBL(vos2,2,vos3,vos4),1) I vos4="" G vL2a0
	Q
	;
vFetch2()	;
	;
	;
	I vos1=1 D vL2a4
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S ds=vos2_$C(9)_vos3_$C(9)_$S(vos4=$C(254):"",1:vos4)
	;
	Q 1
	;
vOpen3()	;	LIBS,SID,SEQ FROM DBTBL2D WHERE LIBS='SYSDEV' AND SID=:SID ORDER BY SEQ ASC
	;
	;
	S vos1=2
	D vL3a1
	Q ""
	;
vL3a0	S vos1=0 Q
vL3a1	S vos2=$G(SID) I vos2="" G vL3a0
	S vos3=0
vL3a3	S vos3=$O(^DBTBL("SYSDEV",2,vos2,vos3),1) I vos3="" G vL3a0
	Q
	;
vFetch3()	;
	;
	;
	I vos1=1 D vL3a3
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S ds="SYSDEV"_$C(9)_vos2_$C(9)_$S(vos3=$C(254):"",1:vos3)
	;
	Q 1
