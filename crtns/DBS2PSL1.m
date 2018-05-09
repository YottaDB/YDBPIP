 ; 
 ; **** Routine compiled from DATA-QWIK Procedure DBS2PSL1 ****
 ; 
 ; 02/24/2010 18:21 - pip
 ; 
DBS2PSL1(dbtbl2) ; DBSDS5A DBS - U - V7.0 PSL Screen Compiler
 ;
 N I
 N X
 ;
  S:'$D(vobj(dbtbl2,0)) vobj(dbtbl2,0)=$S(vobj(dbtbl2,-2):$G(^DBTBL(vobj(dbtbl2,-3),2,vobj(dbtbl2,-4),0)),1:"")
 S TMPC(1)=" set VO="_""""_(+VPROBJ)_"||13|"_$P(vobj(dbtbl2,0),$C(124),18)_""""
 S C(1)=" kill VSCRPP,REQ,%TAB,%MOD,%MODOFF,%MODGRP,%REPREQ,vtab"
 S C(2)=" set %MAX="_(+SAVT)_",VPT="_VPT_",VPB="_VPB
 I $P(vobj(dbtbl2,0),$C(124),8)<2 S C(3)=$S($P(vobj(dbtbl2,0),$C(124),7):" set OLNTB=VPB*1000",1:" set OLNTB="_OLNTB)
 E  S C(3)=" set:'OLNTB.exists() OLNTB=0 if VPB*1000>OLNTB set OLNTB=VPB*1000"
 I ($D(RPTPR)#2) D RPTPR(.dbtbl2)
 I ($D(RPTDA)#2) D RPTDA(.dbtbl2)
 S VDAOBJ=VPROBJ+1
 F I=2:1:D S X=TMPD(I) D OBJ1(X,I)
  S:'$D(vobj(dbtbl2,0)) vobj(dbtbl2,0)=$S(vobj(dbtbl2,-2):$G(^DBTBL(vobj(dbtbl2,-3),2,vobj(dbtbl2,-4),0)),1:"")
 I $get(RPTPR)="" S TMPD(1)=" set VO="""_(VDAOBJ-1)_"|"_(VPROBJ+1)_"|13|"_$P(vobj(dbtbl2,0),$C(124),18)_""""
 K XR,ZREPEAT D ^DBS2PSL3(.dbtbl2)
 Q 
 ;
RPTPR(dbtbl2) ; Repeating prompts logic
  S:'$D(vobj(dbtbl2,0)) vobj(dbtbl2,0)=$S(vobj(dbtbl2,-2):$G(^DBTBL(vobj(dbtbl2,-3),2,vobj(dbtbl2,-4),0)),1:"")
 N X
 ;
 S X=" set VO=VO+"_(RPTPR-1)_",DY=DY+"_(VPB+1-$P(vobj(dbtbl2,0),$C(124),7))
 D ADDC(X)
 Q 
 ;
RPTDA(dbtbl2) ; Clean up coding for repeating data items
  S:'$D(vobj(dbtbl2,0)) vobj(dbtbl2,0)=$S(vobj(dbtbl2,-2):$G(^DBTBL(vobj(dbtbl2,-3),2,vobj(dbtbl2,-4),0)),1:"")
 N I
 N REGION N X N Y
 ;
 S VDAOBJ=VPROBJ+1
 S D=$order(TMPD(""),-1)
 I $get(RPTPR)="" S TMPD(1)=" set VX="_VPROBJ
 E  D
 .	S TMPD(1)=" set VX=$P(VO,""|"",2)"
 .	S C=0 F I=2:1:D D
 ..		S X=TMPD(I)
 ..		S Y=$F(X,"(@)")
 ..		I Y S TMPD(I)=$E(X,1,Y-3)_"VX+"_C_$E(X,Y-1,999) S C=C+1
 ..		Q 
 .	Q 
 I $P(vobj(dbtbl2,0),$C(124),5)="A" S C(1)=C(1)_" set %REPREQ=%REPEAT*"_%MOD
 E  I $P(vobj(dbtbl2,0),$C(124),5)>0 S C(1)=C(1)_" set %REPREQ="_(($P(vobj(dbtbl2,0),$C(124),5)*%MOD)+%OFF)
 S REGION=VPB-$P(vobj(dbtbl2,0),$C(124),7)
 I '($D(RPTCNT)#2) S RPTCNT=0
 S D=D+1 S TMPD(D)=" set DY=DY+"_(REGION+1)_",VX=VX+"_(RPTCNT-1)
 S C(1)=C(1)_" set %MODGRP="_(REGION+1)
 S C(2)=" set %MODOFF="_%OFF_",%MOD="_%MOD_",%MAX=(%MOD*%REPEAT)+%MODOFF,VPT="
 S C(2)=C(2)_VPT_",VPB="_($P(vobj(dbtbl2,0),$C(124),7)-1)_"+"_$S(REGION:"(%REPEAT*"_(REGION+1)_")",1:"%REPEAT")
 S C(2)=C(2)_",BLKSIZ=("_(BLKSIZ-RPTBLK)_"*%REPEAT)+"_RPTBLK
 Q 
 ;
OBJ1(X,I) ; 
 ; data item protection
 N Z
 N Y
 ;
 I X["VPTBL" S Z=1 D OBJ2(.X,Z) S TMPD(I)=X Q 
 ; convert VO(@) to next sequence number VO(n)
 S Y=$F(X,"(@)") I 'Y Q 
 S TMPD(I)=$E(X,1,Y-3)_VDAOBJ_$E(X,Y-1,999) S VDAOBJ=VDAOBJ+1
 Q 
 ;
OBJ2(X,Z) ; 
 ;   Replace variable %MOD with constant
 N quit
 N Y
 ;
 S quit=0
 F  Q:quit  D
 .	S VPTBL=1
 .	I X["@%MOD" S X=$piece(X,"@%MOD",1)_%MOD_$piece(X,"@%MOD",2,99)
 .	;
 .	S Y=$F(X,"(@)",Z) I 'Y S quit=1 Q 
 .	S X=$E(X,1,Y-3)_(VDAOBJ-1)_$E(X,Y-1,999)
 .	Q 
 Q 
 ;
ADDC(P) ; Add prompt lines of code
 ;
 S C=C+1
 S TMPC(C)=P
 Q 
 ;
PP ; Merge post processor into compiled program
 N EXTSID N NN N OM N Z
 N N
 ;
 S EXTSID=SID
 S Z=1
 S NN=PP+19
 K OM
 N ds,vos1,vos2,vos3,vos4,vos5,vos6,vos7 S ds=$$vOpen1()
 F  Q:'$$vFetch1()  D
 .	N code,pseq
 . N dbtbl2pp,vop1 S vop1=$P(ds,$C(9),4),dbtbl2pp=$$vRCgetRecord1Opt^RecordDBTBL2PP($P(ds,$C(9),1),$P(ds,$C(9),2),$P(ds,$C(9),3),vop1,1,"")
 .	S pseq=vop1
 .	S code=$P(dbtbl2pp,$C(12),1)
 .	S OM(pseq)=code
 . Q  ; while ...
 ;
 D PPLIB^DBS2PSL4(.OM) ; parse for PP Libs
 ;
 S PXSEQ=PXSEQ+1
 S PON=PON+1 S TMP("PO",PON)="VP"_PXSEQ_"("_vobjlst("formal")_") //"
 S N="" F  S N=$order(OM(N)) Q:N=""  S PON=PON+1 S TMP("PO",PON)=OM(N)
 S PP="do VP"_PXSEQ_"^"_PGM_"("_vobjlst("tab")_")"
 Q 
 ;
VARSUB(dbtbl2) ; Build correct variable syntax V
 ;
 N I N V N var N X N Y
 ;
 S V="" S Y=0 S X=P(11) S P(11)=""
 F  D  Q:Y=0 
 .	S Y=$F(X,"<<",Y) Q:Y=0 
 .	I $piece($E(X,Y+1,999),"<<",1)[">>" D
 ..		S var=$piece($E(X,Y,999),">>",1)
 ..		S X=$E(X,1,Y-3)_"""_"_$$DGET(var,.dbtbl2)
 ..		S X=X_"_"""_$piece($E(X,Y+1,999),">>",2,99)
 ..		Q 
 .	Q 
 ;
 S NS=""""_X_""""
 ; remove ""_
 I $E(NS,1,3)="""""_" S NS=$E(NS,4,999)
 ; REMOVE _""
 I $E(NS,$L(NS)-2,999)="_""""" S NS=$E(NS,1,$L(NS)-3)
 S FID="" S VDACX=CX S PF="" S PRO=1 S VDAV1=VPRV1
 I (P(10)="$")!(P(10)="N") Q 
 S P(10)="T"
 Q 
 ;
DGET(X,dbtbl2) ; Insert $G() around variable references
 ;
 N Y
 N I
 ;
 I X[",%,",$L($piece(X,",%,",1),"""")#2 S X=$piece(X,",%,",1)_",""|"","_$piece(X,",%,",2,99)
 ;
 ; Global or /0
 I X?.E1"^".E!(X?.E1"/".E) Q "$S(%ProcessMode=5:"""",1:"_X_")"
 ;
 F I=1:1 S Y=$E(X,I) Q:Y=""  D
 .	;
 .	I '(Y?1A!(Y="%")) Q 
 .	I "+-*/\#&!_(:,><"'[$E(X,I-1) Q 
 .	I $L($E(X,1,I),"""")#2=0
 .	I $E(X,I-3,I-1)="$G(" Q 
 .	I $E(X,I-3,I-1)="$O(" Q 
 .	I $E(X,I-4,I-1)="$O(" Q 
 .	D VAR(.dbtbl2,.X,.I)
 .	Q 
 Q X
 ;
VAR(dbtbl2,X,I) ; Place $G() around variables
  S:'$D(vobj(dbtbl2,0)) vobj(dbtbl2,0)=$S(vobj(dbtbl2,-2):$G(^DBTBL(vobj(dbtbl2,-3),2,vobj(dbtbl2,-4),0)),1:"")
 ;
 N ar N II N lvn N nlvn N z
 ;
 I vobject Q 
 ;
 S ar=$S($P(vobj(dbtbl2,0),$C(124),7)&(CY'<$P(vobj(dbtbl2,0),$C(124),7)):"rptlvns(lvn)",1:"lvns(lvn)")
 ;
 ;  #ACCEPT DATE=10/01/03;PGM=Pete Chenard;CR=UNKNOWN;GROUP=SYNTAX
 I $E(X,I,1048575)'["(" S lvn=$piece($E(X,I,1048575),",",1) S:'$D(@ar) @ar=lvn Q 
 S II=I
 F I=I+1:1:$L(X)+1 Q:$E(X,I)'?1AN 
 I $E(X,I)="(" F  S I=$F(X,")",I) Q:'I  S z=$E(X,II,I-1) I $L(z,"(")=$L(z,")") Q 
 I I=0 S I=$L(X)+1
 ;
 ; Strip lvn from string
 S lvn=$E(X,II,I-1)
 ;
 ; Not an array
 I lvn'["(" S:'$D(@ar) @ar=lvn Q 
 S nlvn=$get(@ar)
 I nlvn="" S lvns=$get(lvns)+1 S nlvn="v"_lvns S @ar=nlvn
 S X=$E(X,1,II-1)_nlvn_$E(X,I,1048575)
 S I=I+$L(lvn)-$L(nlvn)
 Q 
 ;  #OPTION ResultClass ON
vSIG() ; 
 Q "60662^55394^Pete Chenard^6293" ; Signature - LTD^TIME^USER^SIZE
 ;
vOpen1() ; LIBS,SID,SEQ,PSEQ FROM DBTBL2PP WHERE LIBS='SYSDEV' AND SID=:SID AND SEQ=:SEQ AND PSEQ BETWEEN :PP AND :NN
 ;
 ;
 S vos1=2
 D vL1a1
 Q ""
 ;
vL1a0 S vos1=0 Q
vL1a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(SID) I vos3="" G vL1a0
 S vos4=$G(SEQ)
 S vos4=+vos4
 S vos5=$G(PP)
 S vos6=$G(NN)
 S vos7=vos5
 I $D(^DBTBL("SYSDEV",2,vos3,vos4,vos7)),'(vos7>vos6) G vL1a10
vL1a9 S vos7=$O(^DBTBL("SYSDEV",2,vos3,vos4,vos7),1) I vos7=""!(vos7>vos6) G vL1a0
vL1a10 Q
 ;
vFetch1() ;
 ;
 ;
 I vos1=1 D vL1a9
 I vos1=2 S vos1=1
 ;
 I vos1=0 S ds="" Q 0
 ;
 S ds="SYSDEV"_$C(9)_vos3_$C(9)_vos4_$C(9)_$S(vos7=vos2:"",1:vos7)
 ;
 Q 1
