	; I18N=QUIT
	;
	; **** Routine compiled from DATA-QWIK Procedure UCCLASS ****
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
classNew	; method Class.new ; returns any
	N z
	N cls S cls=$$QSUB^%ZS(actual(1),"""")
	N abstr S abstr=0 N noinst S noinst=0
	N constr
	S class=cls
	;
	I $$isRecord^UCGM(class),class'=reClass D
	.	;
	.	N table S table=$E(class,$L(reClass)+1,$L(class))
	.	;
	.	I '$$isTable^UCXDD(table) D ERROR^UCGM("Invalid DATA-QWIK table: "_table) Q 
	.	;
	.	 N V1 S V1=cls I '($D(^OBJECT(V1))) S cls=reClass
	.	S z=$$vDb2(cls)
	.	S constr=$P(z,$C(124),3)
	.	I (constr="")!(cls=reClass) S constr="new^UCRECORD"
	.	Q 
	E  D
	.	 N V1 S V1=cls I '($D(^OBJECT(V1))) D ERROR^UCGM("Undefined class: "_cls) Q 
	. S z=$$vDb2(cls)
	.	S abstr=$P(z,$C(124),4)
	.	S noinst=$P(z,$C(124),5)
	.	S constr=$P(z,$C(124),3)
	.	Q 
	I ER Q 
	;
	I abstr D ERROR^UCGM("Illegal reference to abstract class: "_class) Q 
	I noinst D ERROR^UCGM("Class is not instantiable: "_class) Q 
	;
	I (constr="") D
	.	I $$primVar^UCPRIM(class) D
	..		I (actual(2)="") S actual(2)=$$QADD^%ZS(actual(2),"""")
	..		S return=actual(2)
	..		Q 
	.	E  S return=$$newObj(class)
	.	Q 
	E  D @constr ; Call class constructor
	Q 
	;
	; ---------------------------------------------------------------------
clsRel(clsfp,clsap)	;
	;
	I clsfp="" S clsfp="Primitive"
	I clsap="" S clsap="Primitive"
	;
	I clsfp=clsap!(clsfp="Object") Q 1
	;
	I $$primDes^UCPRIM(clsfp)>0,$$primDes^UCPRIM(clsap)>0 Q 1
	;
	I $$clsIsAnc^UCGMR(clsfp,clsap) Q 1
	I $$clsIsAnc^UCGMR(clsap,clsfp) Q 2
	Q 0
	;
isAncestor	; Method Class.isAncestor ; Returns Boolean
	I (actual(1)="") D ERROR^UCGM("Ancestor parameter required") Q 
	I (actual(2)="") D ERROR^UCGM("Descendant parameter required") Q 
	;
	S return="$$clsIsAnc^UCGMR("_actual(1)_","_actual(2)_")"
	I $$isLit^UCGM(actual(1)),$$isLit^UCGM(actual(2)) D
	.	;   #ACCEPT DATE=10/12/04; PGM=FSCW; CR=11445
	.	XECUTE "set return="_return
	.	I (return="") S return=""""""
	.	Q 
	Q 
	;
isClass	; Method Class.isClass ; Returns Boolean
	I (""""""[actual(1)) D ERROR^UCGM("Class name required") Q 
	;
	S return="$$clsIsClass^UCGMR("_actual(1)_")"
	I $$isLit^UCGM(actual(1)) D
	.	;   #ACCEPT Date=10/12/04; PGM=FSCW; CR=11445
	.	XECUTE "set return="_return
	.	I (return="") S return=""""""
	.	Q 
	Q 
	;
isDescendant	; Method Class.isDescendant ; Returns Boolean
	I (actual(1)="") D ERROR^UCGM("Descendant parameter required") Q 
	I (actual(2)="") D ERROR^UCGM("Ancestor parameter required") Q 
	;
	S return="$$clsIsAnc^UCGMR("_actual(2)_","_actual(1)_")"
	I $$isLit^UCGM(actual(1)),$$isLit^UCGM(actual(2)) D
	.	;   #ACCEPT DATE=10/12/04; PGM=FSCW; CR=11445
	.	XECUTE "set return="_return
	.	I (return="") S return=""""""
	.	Q 
	Q 
	;
isValid	; Method Class.isValid ; Returns Boolean
	D WARNDEP^UCGM("Class.isValid - use Object.exists")
	I (""""""[actual(1)) D ERROR^UCGM("Reference object required") Q 
	I $E(actual(1),1)="." S actual(1)=$E(actual(1),2,$L(actual(1)))
	;
	S return="$D("_oLvn_"(+$G("_actual(1)_")))"
	Q 
	;
newObj(class)	; name of class
	N label S label="vClNew" ; label to be added if needed
	;
	I '$D(labels("vClNew")) D
	.	;
	.	N sr S sr=$$vaddSubr("vClNew","(vCls)","Create a new object",0)
	.	D addCode^UCPSLSR(sr," N vOid")
	.	D addCode^UCPSLSR(sr,$$cdNewObj("vOid","vCls"))
	.	D addCode^UCPSLSR(sr," Q vOid")
	.	Q 
	;
	Q "$$"_label_"("""_class_""")"
	;
	; ---------------------------------------------------------------------
cdNewObj(objInst,objClass)	;
	N vret
	;
	S vret=" S "_objInst_"=$O("_"vobj"_"(""""),-1)+1,"_"vobj"_"("_objInst_",-1)="_objClass Q vret
	; ----------------
	;  #OPTION ResultClass 0
vaddSubr(p1,p2,p3,p4)	; PSL.addSubrou
	;
	;  #OPTIMIZE FUNCTIONS OFF
	I $get(p4) S p1=$$newLabel^UCGM(p1,.labels)
	E  I ($D(labels(p1))#2) D ERROR^UCGM("Subroutine exists: "_p1) Q p1
	D addSubr^UCGM(p1,p2,p3)
	Q p1
	;
vDb2(v1)	;	voXN = Db.getRecord(OBJECT,,0)
	;
	N z
	S z=$G(^OBJECT(v1))
	I z="",'$D(^OBJECT(v1))
	I $T S $ZS="-1,"_$ZPOS_",%PSL-E-RECNOFL,,OBJECT" X $ZT
	Q z
