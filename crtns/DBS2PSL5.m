DBS2PSL5	; DBS - U - V7.0 PSL Screen Compiler
	;
	; **** Routine compiled from DATA-QWIK Procedure DBS2PSL5 ****
	;
	; 11/08/2007 14:07 - chenardp
	;
	;
	; TITOVE - initialized variables for the first run through
	I '($D(TMP(1000))#2) S (LINE,LOOP,NS,Q,QQ,SAVDI,XCOMP,XNS,VRSEQ,XR0,XR1,XR7,XR7REG,XR7VAR,XR8,XR9,z,ZXR7)=""
	;
	S XR9=1
	S Q=$char(34)
	S QQ=Q_Q
	S LINE=""
	S LINE="____________________________________________________________"
	;
	I X="" Q 
	S XR0=X
	;
	I '($D(TMP(1000))#2) D
	.	S VRSEQ=0 S XR8=1
	.	I '$$vDbEx1() D
	..		;
	..		; Screen post processor does not contain any code
	..		S TMP(1000,1)=""
	..		S XR8=XR8+1
	..		S TMP(1000,2)=" quit"
	..		S TMP(1000,XR8+1)=""
	..		S TMP(1000,XR8+2)="VSPP"
	..		; TITOVE - PATCH START
	..		; Need to add call to  Required Data Item Def section
	..		S TMP(1000,XR8+3)=""
	..		S TMP(1000,XR8+4)=" do VSPPREQ"_"("_vobjlst("actual")_") if ER quit"
	..		S TMP(1000,XR8+5)=""
	..		S XR8=XR8+6
	..		; TITOVE - PATCH END
	..		Q  ; isDefined
	.	;
	.	S TMP(1000,XR8)=""
	.	S TMP(1000,XR8+1)="VSPPREQ("_vobjlst("formal")_") "
	.	S XR8=XR8+2
	.	S TMP(1000,XR8)=" //"_"_______________________________________________________"
	.	S XR8=XR8+1
	.	S TMP(1000,XR8)=" //  User Defined Required Data Item Definitions"
	.	S XR8=XR8+1
	.	S TMP(1000,XR8)=" //"_"_______________________________________________________"
	.	S TMP(1000,XR8+1)=""
	.	S TMP(1000,XR8+2)=" set ER=0"
	.	;
	.	S XR7=XR8+5
	.	S XR8=XR8+100
	.	Q  ;'$d(TMP(1000)
	;
	S VRSEQ=VRSEQ+1
	S TMP(1000,XR7)=""
	;
	; Reserve next entry for later processing
	;
	S ZXR7=XR7+1
	S z=" for I=%MODS:1:%REPEAT+%MODS-1"
	S XR7VAR=z_" do VR"_VRSEQ_"("_vobjlst("actual")_") if ER set NI=((I-1)*"_%MOD_")+(1+%MODOFF) quit"
	S XR7REG=" do VR"_VRSEQ_"("_vobjlst("actual")_") if ER"
	;
	S TMP(1000,XR7+2)=" quit"
	S XR7=XR7+2
	;
	S TMP(1000,XR8)=""
	S TMP(1000,XR8+1)="VR"_VRSEQ_"("_vobjlst("formal")_") "
	S XR8=XR8+2
	;
	F  S XR1=$piece(XR0,")",XR9) D:XR1="" DONE Q:XR1=""  D
	.	N %I1 N I
	.	N DINAM
	.	;
	.	S XR1=$piece(XR1,"(",2)
	.	N CODE
	.	S CODE=" I "
	.	F %I1=1:1 S DINAM=$piece(XR1,",",%I1) Q:DINAM=""  D REQ(DINAM,.CODE) I ER Q 
	.	;
	.	; Remove , from end of command line
	.	;
	.	S TMP(1000,XR8)=""
	.	S XR8=XR8+1
	.	S TMP(1000,XR8)=" // ("_XR1_")"
	.	S XR8=XR8+1
	.	S CODE=$E(CODE,1,$L(CODE)-1)
	.	I $order(CODE(""))="" S CODE=CODE_" quit"
	.	S TMP(1000,XR8)=""
	.	S XR8=XR8+1
	.	;
	.	S TMP(1000,XR8)=CODE
	.	S XR8=XR8+1
	.	;
	.	F I=1:1 Q:'($D(CODE(I))#2)  S TMP(1000,XR8)=" if "_$E(CODE(I),1,$L(CODE(I))-1) S XR8=XR8+1
	.	I $order(CODE(""))'="" S TMP(1000,XR8-1)=TMP(1000,XR8-1)_" quit"
	.	;
	.	S TMP(1000,XR8)=""
	.	S XR8=XR8+1
	.	S XR9=XR9+1
	.	Q  ; for
	;
	Q  ; end of program
	;
REQ(DINAM,CODE)	;
	;  Default to ON condition ... either DI or DI+
	N DI N LIB N NS N PFID N X1 N XON N Z
	N z
	;
	S XON=1
	I DINAM["-",($piece(DINAM,"-",2,99)="") S DINAM=$piece(DINAM,"-",1) S XON=0
	;
	I DINAM?1"@".E D VAR I 1
	;
	E  D  Q:ER'="" 
	.	N DFID N DLIB N X
	.	S ER=""
	.	I DINAM'?1"["1E.E1"]"1E.E D DEFAULT(DINAM,.DFID) I ER D ERR Q 
	.	S DLIB=%LIBS
	.	S PFID=$get(FILES)
	.	S DFID=$piece(PFID,",",1)
	.	S X=DINAM
	.	D ^DBSDI
	.	I ER D ERR
	.	S DINAM="["_LIB_","_FID_"]"_DI
	.	D ^DBSCHK I ER'="" D ERR Q 
	.	;
	.	; TITOVE - PATCH START
	.	; Convert string such as "$P(fUTBLACC,""|"",43)" into current
	.	; standard reference "fUTBLACC.deprnpbp"
	.	S NS=$E(NS,4,$F(NS,",")-2)_"."_$$vStrLC(DI,0)
	.	; TITOVE - PATCH END
	.	Q 
	;
	S Z=$S(DINAM[",":"["_$piece(DINAM,",",2,3),1:DINAM)
	S NS=$$XLATE(Z)
	; on the screen
	I '($D(%NAMCUR(Z))#2) D ERR Q 
	I %NAMCUR(Z)["+" D
	.	S TMP(1000,ZXR7)=XR7VAR
	.	I NS["." S NS=$piece(NS,".",1)_"(I)."_$piece(NS,".",2)
	.	E  S NS=$piece(NS,"(1)",1)_"(I)"_$piece(NS,"(1)",2,99)
	.	Q 
	E  D
	.	N XNS
	.	Q:($D(TMP(1000,ZXR7))#2) 
	.	S TMP(1000,ZXR7)=XR7REG
	.	S XNS=1
	.	I ($D(%NAMCUR(Z))#2) S XNS=$piece(%NAMCUR(Z),"|",2)
	.	S TMP(1000,ZXR7)=TMP(1000,ZXR7)_" set NI="_XNS_" quit"
	.	Q  ; end else
	;
	S X1=""
	I XON S X1="'"
	;
	I $L(CODE)>200 S z=$order(CODE(""),-1)+1 S CODE(z)=CODE S CODE=" I "
	S CODE=CODE_"("_NS_X1_"="_QQ_"),"
	Q 
	;
XLATE(DINAM)	;
	N col N fid N sn
	;
	I $E(DINAM,1)="@" Q NS
	I DINAM["[" S fid=$E($piece(DINAM,"]",1),2,999)
	S col=$piece(DINAM,"]",2)
	I '($D(fsn(fid))#2) D fsn^SQLDD(.fsn,fid)
	S sn=$piece(fsn(fid),"|",1)
	I $E(sn,$L(sn))="(" S sn=$E(sn,1,$L(sn)-1)
	Q sn_"."_col
	;
	; Add default file id
DEFAULT(DINAM,DFID)	;
	;
	N DLIB N Q N vDINAM N X
	N quit N vTBLNO
	;
	S vDINAM=DINAM
	S vTBLNO=1
	;
	;DEFAULT1 //
	S ER=0
	S quit=0
	F vTBLNO=1:1:$L(FILES,",") D  Q:quit 
	.	S DFID=$piece(FILES,",",vTBLNO)
	.	I DFID'="" D
	..		S DLIB=%LIBS
	..		S X=vDINAM
	..		D ^DBSDI
	..		I ER S ER=0
	..		E  S quit=1
	..		Q  ; if
	.	E  S ER=1 S DFID=$piece(FILES,",",1)
	.	Q  ; for
	Q 
	;
ERR	;
	;
	WRITE !!,DINAM,?5," - Invalid Data Item Set Definition  ( "_XR1_" )",!!
	S ER=1
	Q 
	;
DONE	;
	;
	S XR8=XR8+1
	;
	; TITOVE - removed setting of ER, it is done in VR99 anyway
	S TMP(1000,XR8)=" do VR99 quit"
	S XR8=XR8+1
	S TMP(1000,XR8)=""
	S XR8=XR8+1
	;
	; TITOVE - moved setting of RM one line lower
	S TMP(1000,XR8+1)="VR99 "
	S TMP(1000,XR8+2)=" set RM="_Q_$$^MSG(1768)_Q
	S TMP(1000,XR8+3)=" set ER=1 quit"
	Q 
	;
VAR	;
	N vpc
	N pos N x N Z
	;
	S NS=""
	I '($D(SID)#2) Q 
	S x=0
	N rs,vos1,vos2,vos3,vos4,vos5,vos6 S rs=$$vOpen1()
	S vpc=('$$vFetch1()) Q:vpc 
	S Z=$P(rs,$C(9),2)
	S pos=$P(rs,$C(9),3)
	S NS=$E(($piece(Z,",",1)),3,99)
	I NS[">>" S NS=$piece(NS,">>",1)
	; repeat region
	I %NAMCUR(DINAM)["+" S NS=NS_"(1)"
	I '(pos="") S NS="$P("_NS_","_"""|"""_","_pos_")"
	Q 
	;
vSIG()	;
	Q "60662^55395^Pete Chenard^7178" ; Signature - LTD^TIME^USER^SIZE
	; ----------------
	;  #OPTION ResultClass 0
vStrLC(vObj,v1)	; String.lowerCase
	;
	;  #OPTIMIZE FUNCTIONS OFF
	S vObj=$translate(vObj,"ABCDEFGHIJKLMNOPQRSTUVWXYZ¡£¥¦©ª«¬®¯ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖØÙÚÛÜÝÞ","abcdefghijklmnopqrstuvwxyz±³µ¶¹º»¼¾¿àáâãäåæçèéêëìíîïðñòóôõöøùúûüýþ")
	I v1 S vObj=$$vStrUC($E(vObj,1))_$E(vObj,2,1048575)
	Q vObj
	; ----------------
	;  #OPTION ResultClass 0
vStrUC(vObj)	; String.upperCase
	;
	;  #OPTIMIZE FUNCTIONS OFF
	Q $translate(vObj,"abcdefghijklmnopqrstuvwxyz±³µ¶¹º»¼¾¿àáâãäåæçèéêëìíîïðñòóôõöøùúûüýþ","ABCDEFGHIJKLMNOPQRSTUVWXYZ¡£¥¦©ª«¬®¯ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖØÙÚÛÜÝÞ")
	;
vDbEx1()	;	min(1): DISTINCT LIBS,SID,SEQ,PSEQ FROM DBTBL2PP WHERE LIBS=:%LIBS AND SID=:SID AND SEQ=0 AND PSEQ=21
	;
	N vsql1
	S vsql1=$G(%LIBS) I vsql1="" Q 0
	;
	I '($D(^DBTBL(vsql1,2,SID,0,21))#2) Q 0
	Q 1
	;
vOpen1()	;	NAME,PROMPT,POS FROM DBTBL2D WHERE LIBS=:%LIBS AND SID=:SID AND SEQ>0 AND NAME=:DINAM
	;
	;
	S vos1=2
	D vL1a1
	Q ""
	;
vL1a0	S vos1=0 Q
vL1a1	S vos2=$G(%LIBS) I vos2="" G vL1a0
	S vos3=$G(SID) I vos3="" G vL1a0
	S vos4=$G(DINAM) I vos4="",'$D(DINAM) G vL1a0
	S vos5=0
vL1a5	S vos5=$O(^DBTBL(vos2,2,vos3,vos5),1) I vos5="" G vL1a0
	S vos6=$G(^DBTBL(vos2,2,vos3,vos5))
	I '($P(vos6,"|",5)=vos4) G vL1a5
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
	S rs=$P(vos6,"|",5)_$C(9)_$P(vos6,"|",11)_$C(9)_$P(vos6,"|",22)
	;
	Q 1
