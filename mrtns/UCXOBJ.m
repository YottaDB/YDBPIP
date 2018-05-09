	; I18N=QUIT
	;
	; **** Routine compiled from DATA-QWIK Procedure UCXOBJ ****
	;
	; 09/10/2007 17:32 - chenardp
	;
	; *******************************************************************
	; * IMPORTANT NOTE:                                                 *
	; * According to the rules that apply to PSL compiler upgrades,     *
	; * the generated M routine associated with this procedure must be  *
	; * checked into StarTeam and released with the procedure whenever  *
	; * changes are made to this procedure.                             *
	; *                                                                 *
	; * The M routine will be loaded to the mrtns directory during      *
	; * upgrades and will then be removed from that directory as part   *
	; * of the upgrade process.  Therefore, other than during an        *
	; * upgrade an mrtns version of this routine should not exist.      *
	; *                                                                 *
	; * Keep these comments as single line to ensure they exist in the  *
	; * generated M code.                                               *
	; *******************************************************************
	Q 
	;
	;  #OPTION ResultClass ON
	;
	; ---------------------------------------------------------------------
ocAll(caOC)	; class cache (*1) /MECH=REFARR:RW
	N dummy
	;
	N rs,vos1,vos2 S rs=$$vOpen1()
	F  Q:'($$vFetch1())  S dummy=$$ocGet(.caOC,rs,0)
	Q 
	;
	; ---------------------------------------------------------------------
ocAncestor(cls)	; class name (*1)
	;
	I cls="Object" Q ""
	;
	N return S return=""
	;
	I $$ocIsRecord(cls),cls'="Record" D
	.	S return=$E(cls,7,1048575)
	.	N td S td=$$getPslTbl^UCXDD(return,1)
	.	S return="Record"_$P(td,"|",7)
	.	Q 
	E  D
	.	N rs,vos1,vos2,vos3  N V1 S V1=cls S rs=$$vOpen2()
	.	I $$vFetch2() S return=rs
	.	Q 
	I return="" S return="Object" ; implied ancestor
	Q return
	;
	; ---------------------------------------------------------------------
ocClassName(CLS)	; class name (*1)
	N vret
	I ($D(^OBJECT(CLS))) Q CLS
	I $$ocIsRecord(CLS)>0 Q CLS
	;
	N rs,vos1,vos2,vos3  N V1 S V1=$$vStrUC(CLS) S rs=$$vOpen3()
	I $$vFetch3()
	;
	S vret=rs Q vret
	;
	; ---------------------------------------------------------------------
ocGet(caOC,CLS,nCase)	;
	;
	I '($D(caOC(CLS))#2) D
	.	I nCase D
	..		N UP S UP=$$vStrUC(CLS)
	..		N rs,vos1,vos2,vos3,vos5,vos4 S rs=$$vOpen4()
	..		;
	..		I '$$vFetch4(),$$ocIsRecord(CLS)=0 S $ZS="-1,"_$ZPOS_","_"%PSL-E-CLASS,class '"_CLS_"' not found" X $ZT
	..		;
	..		I CLS'=$P(rs,$C(9),1) D
	...			S CLS=$P(rs,$C(9),1)
	...			D warnGroup^UCGM("MISMATCH","Classname is case sensitive: "_CLS)
	...			Q 
	..		S caOC(CLS)=$translate(rs,$C(9),"|")
	..		Q 
	.	E  D
	..		N rs,vos6,vos7,vos9,vos8 S rs=$$vOpen5()
	..		I '$$vFetch5(),$$ocIsRecord(CLS)=0 S $ZS="-1,"_$ZPOS_","_"%PSL-E-CLASS,class '"_CLS_"' not found" X $ZT
	..		S caOC(CLS)=$translate(rs,$C(9),"|")
	..		Q 
	.	Q 
	Q caOC(CLS)
	;
	; ---------------------------------------------------------------------
ocIsRecord(cls)	; class name (*1)
	;
	I cls="Record" Q 1
	;
	I $E(cls,1,6)="Record",$$isTable^UCXDD($E(cls,7,1048575)) Q 2
	Q 0
	;
	; ---------------------------------------------------------------------
ocIsAncestor(a,d)	;
	I d="Object" Q 0
	;
	F  S d=$$ocAncestor(d) Q:a=d!(d="") 
	Q '(d="")
	;
	; ---------------------------------------------------------------------
ocRowDef()	; return Row.getColumns() for OBJECTMET data
	Q ("CLASS,SUPERTYPE,CONSTRUCTOR,ABSTRACT,NOINSTANT,ISPRIMITIV,ISNOPOINTER,PROPDELIM,PROPPROC"_$char(9)_124)
	;
	; ---------------------------------------------------------------------
omAll(caOM,cls,caOC)	;
	;
	; Step 1: Method declarations from source code
	N clsRow S clsRow=$$ocGet(.caOC,cls,0)
	I '($P(clsRow,$C(124),3)=""),$P(clsRow,$C(124),3)'["^" D omFromSrc(.caOM,cls,$P(clsRow,$C(124),3))
	;
	; Step 2: Method declarations from OBJECTMET
	N dummy
	N rs,vos1,vos2,vos3  N V1 S V1=cls S rs=$$vOpen6()
	F  Q:'($$vFetch6())  S dummy=$$omLoad(.caOM,cls,rs)
	;
	Q 
	;
	; ---------------------------------------------------------------------
omFromSrc(caOM,cls,proc)	;
	Q:(proc="") 
	;
	N lbls
	;
	N src
	N rtn S rtn=$$getSrc^UCXDT25(proc,.src,0)
	;
	Q:rtn'=proc 
	;
	D getLblRec^UCPSLLR(.src,"",0,.lbls)
	;
	N mtd S mtd=""
	F  S mtd=$order(lbls(mtd)) Q:(mtd="")  D
	.	I mtd=rtn Q  ; routine entry = constructor
	.	N lr S lr=lbls(mtd)
	.	N cls1 S cls1=$$getFpClass^UCPSLLR(lr,1)
	.	I cls1'=cls Q 
	.	;
	.	N fpn
	.	N fpl S fpl=$$getFp^UCPSLLR(lr,2)
	.	F fpn=3:1:$$getFpCount^UCPSLLR(lr) S fpl=fpl_","_$$getFp^UCPSLLR(lr,fpn)
	.	;
	.	N rw S rw=$C(-1)
	.	S $P(rw,$C(124),1)=cls
	.	S $P(rw,$C(124),2)=mtd
	.	S $P(rw,$C(124),3)=$P(lr,$C(9),3)
	.	S $P(rw,$C(124),4)=fpl
	.	S $P(rw,$C(124),6)=0
	.	S caOM(cls,mtd)=rw
	.	Q 
	;
	Q 
	;
	; ---------------------------------------------------------------------
omGet(caOM,cls,mtd,nCase,caOC)	;
	N acls S acls=cls ; ancestor class iterator
	N amtd S amtd=mtd ; ancestor property iterator
	N ret S ret="" ; return value
	N UPMTD S UPMTD=$S(nCase:$$vStrUC(mtd),1:mtd) ; cased values of property
	;
	F  Q:'(((ret="")&'(acls="")))  D
	.	; step 1: try in cache, with mtd as supplied
	.	I ($D(caOM(acls,amtd))#2) S ret=caOM(acls,amtd) Q 
	.	;
	.	; step 2: ensure all methods for this class are present
	.	I ($order(caOM(acls,""))="") D omAll(.caOM,acls,.caOC)
	.	;
	.	; step 3: try in cache, case as requested
	.	S amtd=""
	.	F  S amtd=$order(caOM(acls,amtd)) Q:(amtd="")  I $$equals(amtd,UPMTD,nCase) S ret=caOM(acls,amtd) Q 
	.	;
	.	; step 4: If not found try ancestor
	.	I (ret="") S acls=$$ocAncestor(acls) S amtd=mtd
	.	Q 
	;
	I '(ret="") D
	.	I amtd'=mtd D
	..		S mtd=amtd
	..		D warnGroup^UCGM("MISMATCH","Methodname is case sensitive: "_mtd)
	..		Q 
	.	Q 
	;
	Q ret
	;
	; ---------------------------------------------------------------------
omLoad(caOM,CLS,MTD)	;
	;
	N rs,vos1,vos2,vos3,vos4 S rs=$$vOpen7()
	;
	I '$$vFetch7() Q ""
	;
	N rw S rw=rs
	I ($P(rw,$C(9),3)="") S $P(rw,$C(9),3)="void"
	;
	S caOM(CLS,MTD)=$translate(rw,$C(9),"|")
	;
	Q caOM(CLS,MTD)
	;
	; ---------------------------------------------------------------------
omRowDef()	; return Row.getColumns() for OBJECTMET data
	Q ("CLASS,METHOD,RETURN,PARAMETERS,ROU,VALLIT"_$char(9)_124)
	;
	; ---------------------------------------------------------------------
omTryPrim(caOM,cls,mtd,caOC)	;
	;
	N elm N nCase
	N pcls N retval S retval=""
	;
	; try case sensitive before case in-sensitive for selected PRIMITIVEs
	F nCase=0,1 D  Q:'(retval="") 
	.	F elm=1:1:4 D  Q:'(retval="") 
	..		S pcls=$piece("String,Number,Date,Time",",",elm)
	..		S retval=$$omGet(.caOM,pcls,mtd,nCase,.caOC)
	..		Q 
	.	Q 
	;
	I '(retval="") D warnGroup^UCGM("MISMATCH","Cast expression to class: "_pcls_"."_mtd)
	;
	Q retval
	;
	; ---------------------------------------------------------------------
opAll(caOP,cls)	;
	N dummy
	;
	N rs,vos1,vos2,vos3  N V1 S V1=cls S rs=$$vOpen8()
	F  Q:'($$vFetch8())  S dummy=$$opLoad(.caOP,cls,rs)
	Q 
	;
	; ---------------------------------------------------------------------
opGet(caOP,cls,prp,nCase)	;
	N acls S acls=cls ; ancestor class iterator
	N aprp S aprp=prp ; ancestor property iterator
	N ret S ret="" ; return value
	N UPPRP S UPPRP=$S(nCase:$$vStrUC(prp),1:prp) ; cased value
	;
	F  Q:'(((ret="")&'(acls="")))  D
	.	; step 1: try in cache, with prp as supplied
	.	I ($D(caOP(acls,aprp))#2) S ret=caOP(acls,aprp) Q 
	.	;
	.	; step 2: ensure all methods for this class are present
	.	I ($order(caOP(acls,""))="") D opAll(.caOP,acls)
	.	;
	.	; step 3: try in cache, case as requested
	.	S aprp=""
	.	F  S aprp=$order(caOP(acls,aprp)) Q:(aprp="")  I $$equals(aprp,UPPRP,nCase) S ret=caOP(acls,aprp) Q 
	.	;
	.	; setp 4: If not found try ancestor
	.	I (ret="") S acls=$$ocAncestor(acls) S aprp=prp
	.	Q 
	;
	I '(ret="") D
	.	I aprp'=prp D
	..		S prp=aprp
	..		D warnGroup^UCGM("MISMATCH","Propertyname is case sensitive: "_prp)
	..		Q 
	.	Q 
	;
	Q ret
	;
	; ---------------------------------------------------------------------
opLoad(caOP,CLS,PRP)	;
	;
	N rs,vos1,vos2,vos3,vos4 S rs=$$vOpen9()
	;
	I '$$vFetch9() Q ""
	;
	S caOP(CLS,PRP)=$translate(rs,$C(9),"|")
	;
	Q caOP(CLS,PRP)
	;
	; ---------------------------------------------------------------------
opRowDef()	; return Row.getColumns() for OBJECTPROP data
	Q ("CLASS,PROPERTY,RETURN,NOD,POS,ROUTINE,ISREADONLY,ARRAY"_$char(9)_124)
	;
	; ---------------------------------------------------------------------
equals(s1,s2,nCase)	;
	I 'nCase Q s1=s2
	I nCase=1 Q $$vStrUC(s1)=$$vStrUC(s2)
	I nCase=-1 Q $$vStrLC(s1,0)=$$vStrLC(s2,0)
	N vo8 S vo8="%PSL-E-Invalid case option "_nCase,$ZS=($L($P(vo8,","),"-")=3*-1)_","_$ZPOS_","_vo8 X $ZT
	Q ""
	; ----------------
	;  #OPTION ResultClass 0
vStrUC(vObj)	; String.upperCase
	;
	;  #OPTIMIZE FUNCTIONS OFF
	Q $translate(vObj,"abcdefghijklmnopqrstuvwxyz±≥µ∂π∫ªºæø‡·‚„‰ÂÊÁËÈÍÎÏÌÓÔÒÚÛÙıˆ¯˘˙˚¸˝˛","ABCDEFGHIJKLMNOPQRSTUVWXYZ°£•¶©™´¨ÆØ¿¡¬√ƒ≈∆«»… ÀÃÕŒœ–—“”‘’÷ÿŸ⁄€‹›ﬁ")
	; ----------------
	;  #OPTION ResultClass 0
vStrLC(vObj,v1)	; String.lowerCase
	;
	;  #OPTIMIZE FUNCTIONS OFF
	S vObj=$translate(vObj,"ABCDEFGHIJKLMNOPQRSTUVWXYZ°£•¶©™´¨ÆØ¿¡¬√ƒ≈∆«»… ÀÃÕŒœ–—“”‘’÷ÿŸ⁄€‹›ﬁ","abcdefghijklmnopqrstuvwxyz±≥µ∂π∫ªºæø‡·‚„‰ÂÊÁËÈÍÎÏÌÓÔÒÚÛÙıˆ¯˘˙˚¸˝˛")
	I v1 S vObj=$$vStrUC($E(vObj,1))_$E(vObj,2,1048575)
	Q vObj
	;
vOpen1()	;	CLASS FROM OBJECT
	;
	;
	S vos1=2
	D vL1a1
	Q ""
	;
vL1a0	S vos1=0 Q
vL1a1	S vos2=""
vL1a2	S vos2=$O(^OBJECT(vos2),1) I vos2="" G vL1a0
	Q
	;
vFetch1()	;
	;
	;
	I vos1=1 D vL1a2
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S rs=$S(vos2=$$BYTECHAR^SQLUTL(254):"",1:vos2)
	;
	Q 1
	;
vOpen2()	;	SUPERTYPE FROM OBJECT WHERE CLASS=:V1
	;
	;
	S vos1=2
	D vL2a1
	Q ""
	;
vL2a0	S vos1=0 Q
vL2a1	S vos2=$G(V1) I vos2="" G vL2a0
	I '($D(^OBJECT(vos2))) G vL2a0
	Q
	;
vFetch2()	;
	;
	;
	I vos1=0 Q 0
	;
	S vos1=100
	S vos3=$G(^OBJECT(vos2))
	S rs=$P(vos3,"|",1)
	S vos1=0
	;
	Q 1
	;
vOpen3()	;	CLASS FROM OBJECT WHERE UPPER(CLASS) = :V1
	;
	;
	S vos1=2
	D vL3a1
	Q ""
	;
vL3a0	S vos1=0 Q
vL3a1	S vos2=$G(V1) I vos2="" G vL3a0
	S vos3=""
vL3a3	S vos3=$O(^OBJECT(vos3),1) I vos3="" G vL3a0
	I '($$UPPER^%ZFUNC(vos3)=vos2) G vL3a3
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
	S rs=$S(vos3=$$BYTECHAR^SQLUTL(254):"",1:vos3)
	;
	Q 1
	;
vOpen4()	;	CLASS,SUPERTYPE,CONSTRUCTOR,ABSTRACT,NOINSTANT,ISPRIMITIVE,ISNOPOINTER,PROPDELIM,PROPPROC FROM OBJECT WHERE UPPER(CLASS) = :UP
	;
	;
	S vos1=2
	D vL4a1
	Q ""
	;
vL4a0	S vos1=0 Q
vL4a1	S vos2=$G(UP) I vos2="" G vL4a0
	S vos3=""
vL4a3	S vos3=$O(^OBJECT(vos3),1) I vos3="" G vL4a0
	I '($$UPPER^%ZFUNC(vos3)=vos2) G vL4a3
	Q
	;
vFetch4()	;
	;
	I vos1=1 D vL4a3
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S vos4=$G(^OBJECT(vos3,0))
	S vos5=$G(^OBJECT(vos3))
	S rs=$S(vos3=$$BYTECHAR^SQLUTL(254):"",1:vos3)_$C(9)_$P(vos5,"|",1)_$C(9)_$P(vos5,"|",3)_$C(9)_$P(vos5,"|",4)_$C(9)_$P(vos5,"|",5)_$C(9)_$P(vos5,"|",6)_$C(9)_$P(vos5,"|",7)_$C(9)_$P(vos4,"|",1)_$C(9)_$P(vos4,"|",2)
	;
	Q 1
	;
vOpen5()	;	CLASS,SUPERTYPE,CONSTRUCTOR,ABSTRACT,NOINSTANT,ISPRIMITIVE,ISNOPOINTER,PROPDELIM,PROPPROC FROM OBJECT WHERE CLASS = :CLS
	;
	;
	S vos6=2
	D vL5a1
	Q ""
	;
vL5a0	S vos6=0 Q
vL5a1	S vos7=$G(CLS) I vos7="" G vL5a0
	I '($D(^OBJECT(vos7))) G vL5a0
	Q
	;
vFetch5()	;
	;
	;
	I vos6=0 Q 0
	;
	S vos6=100
	S vos8=$G(^OBJECT(vos7,0))
	S vos9=$G(^OBJECT(vos7))
	S rs=vos7_$C(9)_$P(vos9,"|",1)_$C(9)_$P(vos9,"|",3)_$C(9)_$P(vos9,"|",4)_$C(9)_$P(vos9,"|",5)_$C(9)_$P(vos9,"|",6)_$C(9)_$P(vos9,"|",7)_$C(9)_$P(vos8,"|",1)_$C(9)_$P(vos8,"|",2)
	S vos6=0
	;
	Q 1
	;
vOpen6()	;	METHOD FROM OBJECTMET WHERE CLASS = :V1
	;
	;
	S vos1=2
	D vL6a1
	Q ""
	;
vL6a0	S vos1=0 Q
vL6a1	S vos2=$G(V1) I vos2="" G vL6a0
	S vos3=""
vL6a3	S vos3=$O(^OBJECT(vos2,1,vos3),1) I vos3="" G vL6a0
	Q
	;
vFetch6()	;
	;
	;
	I vos1=1 D vL6a3
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S rs=$S(vos3=$$BYTECHAR^SQLUTL(254):"",1:vos3)
	;
	Q 1
	;
vOpen7()	;	CLASS,METHOD,RETURN,PARAMETERS,ROU,VALLIT FROM OBJECTMET WHERE CLASS = :CLS AND METHOD = :MTD
	;
	;
	S vos1=2
	D vL7a1
	Q ""
	;
vL7a0	S vos1=0 Q
vL7a1	S vos2=$G(CLS) I vos2="" G vL7a0
	S vos3=$G(MTD) I vos3="" G vL7a0
	I '($D(^OBJECT(vos2,1,vos3))#2) G vL7a0
	Q
	;
vFetch7()	;
	;
	;
	I vos1=0 Q 0
	;
	S vos1=100
	S vos4=$G(^OBJECT(vos2,1,vos3))
	S rs=vos2_$C(9)_vos3_$C(9)_$P(vos4,"|",1)_$C(9)_$P(vos4,"|",2)_$C(9)_$P(vos4,"|",3)_$C(9)_$P(vos4,"|",9)
	S vos1=0
	;
	Q 1
	;
vOpen8()	;	PROPERTY FROM OBJECTPROP WHERE CLASS = :V1
	;
	;
	S vos1=2
	D vL8a1
	Q ""
	;
vL8a0	S vos1=0 Q
vL8a1	S vos2=$G(V1) I vos2="" G vL8a0
	S vos3=""
vL8a3	S vos3=$O(^OBJECT(vos2,0,vos3),1) I vos3="" G vL8a0
	Q
	;
vFetch8()	;
	;
	;
	I vos1=1 D vL8a3
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S rs=$S(vos3=$$BYTECHAR^SQLUTL(254):"",1:vos3)
	;
	Q 1
	;
vOpen9()	;	CLASS,PROPERTY,RETURN,NOD,POS,ROUTINE,ISREADONLY,ARRAY FROM OBJECTPROP WHERE CLASS = :CLS AND PROPERTY = :PRP
	;
	;
	S vos1=2
	D vL9a1
	Q ""
	;
vL9a0	S vos1=0 Q
vL9a1	S vos2=$G(CLS) I vos2="" G vL9a0
	S vos3=$G(PRP) I vos3="" G vL9a0
	I '($D(^OBJECT(vos2,0,vos3))#2) G vL9a0
	Q
	;
vFetch9()	;
	;
	;
	I vos1=0 Q 0
	;
	S vos1=100
	S vos4=$G(^OBJECT(vos2,0,vos3))
	S rs=vos2_$C(9)_vos3_$C(9)_$P(vos4,"|",3)_$C(9)_$P(vos4,"|",1)_$C(9)_$P(vos4,"|",2)_$C(9)_$P(vos4,"|",7)_$C(9)_$P(vos4,"|",8)_$C(9)_$P(vos4,"|",6)
	S vos1=0
	;
	Q 1
