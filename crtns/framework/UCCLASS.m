 ; 
 ; **** Routine compiled from DATA-QWIK Procedure UCCLASS ****
 ; 
 ; 02/24/2010 18:23 - pip
 ; 
 ;  #PACKAGE framework.psl
 ;  #OPTION  ResultClass ON
 ;
 ; I18N=QUIT
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
 ; ---------------------------------------------------------------------
classNew ; method Class.new ; returns any
  ; BAD USAGE !!
 ;
 N cls S cls=$$QSUB^%ZS(actual(1),"""")
 ;
 D loadClass^PSLCC(.pslPrsr,.cls)
 I '($D(pslPrsr("pslCls",cls))#2) D ERROR^UCGM("Undefined class: "_cls) Q 
 ;
 N ocd S ocd=$$getPSLClass^PSLCC(.pslPrsr,.cls)
 I $P(ocd,$C(9),5)<0 D ERROR^UCGM("Not a class: "_cls) Q 
 I $P(ocd,$C(9),7) D ERROR^UCGM("Illegal reference to abstract class: "_class) Q 
 I $P(ocd,$C(9),8) D ERROR^UCGM("Class is not instantiable: "_class) Q 
 N constr S constr=$P(ocd,$C(9),6)
 S class=cls
 ;
 I (constr="") D  ; Class Definition Module
 .	I $$isRecord^PSLClass(cls)>1 D  I '(constr="") D @constr Q 
 ..		F  D  Q:'(constr="")!($D(pslPrsr("pslMtd",cls_".initialize"))#2) 
 ...			S cls=$P(ocd,$C(9),3)
 ...			S ocd=$$getPSLClass^PSLCC(.pslPrsr,cls)
 ...			S constr=$P(ocd,$C(9),6)
 ...			Q 
 ..		Q 
 .	;
 .	I $P(ocd,$C(9),5)=1,cmd'="set"!(ptr>0) S $ZE="0,"_$ZPOS_","_"%PSL-E-MISMATCH,Class is not instantiable in this context: "_class,$EC=",U1001,"
 .	;
 .	N lvl S lvl=$$newObjSt($get(var))
 .	S return=$$classNewCall^PSLClass(.ocd,postCond,$S(cls'["""":""""_cls_"""",1:$$QADD^%ZS(cls,"""")),"$ST"_$S(lvl>0:-lvl,1:""),$$QADD^%ZS($P(ocd,$C(9),13),""""),$$QADD^%ZS($P(ocd,$C(9),14),""""),actual(2))
 .	Q 
 E  D @constr ; Call class constructor
 ;
 Q 
 ;
 ; ---------------------------------------------------------------------
clsRel(pslPrsr,clsfp,clsap) ; class of actual parameter  /MECH=VAL
 I clsfp="" Q 0
 I clsap="" Q 0
 ;
 I clsfp=clsap!(clsfp="Object") Q 1
 ;
 I $$primRel^UCPRIM(clsfp,clsap) Q 1
 ;
 N ocd
 S ocd=$$getPSLClass^PSLCC(.pslPrsr,clsap) I $$isDescendantOf^PSLClass(.ocd,.pslPrsr,clsfp) Q 1
 S ocd=$$getPSLClass^PSLCC(.pslPrsr,clsfp) I $$isDescendantOf^PSLClass(.ocd,.pslPrsr,clsap) Q 2
 ;
 Q 0
 ;
 ; ---------------------------------------------------------------------
intrinsic ; default constructor for intrinsic classes
 ;
 N ocd S ocd=$$getPSLClass^PSLCC(.pslPrsr,class)
 ;
 I $P(ocd,$C(9),5)=0 D
 .	N lvl S lvl=$$newObjSt($get(var))
 .	S return=$$newObj(class,"$ST"_$S(lvl>0:-lvl,1:""))
 .	Q 
 E  D
 .	I (actual(2)="") S actual(2)=$$QADD^%ZS(actual(2),"""")
 .	S return=actual(2)
 .	Q 
 Q 
 ;
 ; ---------------------------------------------------------------------
isAncestor ; Method Class.isAncestor ; Returns Boolean
 I (actual(1)="") D ERROR^UCGM("Ancestor parameter required") Q 
 I (actual(2)="") D ERROR^UCGM("Descendant parameter required") Q 
 ;
 S return="$$clsIsAnc^UCGMR("_actual(1)_","_actual(2)_")"
 I $$isLit^UCGM(actual(1)),$$isLit^UCGM(actual(2)) D
 .	;   #ACCEPT DATE=10/12/04; PGM=FSCW; CR=11445; GROUP=XECUTE
 .	XECUTE "set return="_return
 .	I (return="") S return=""""""
 .	Q 
 Q 
 ;
 ; ---------------------------------------------------------------------
isClass ; Method Class.isClass ; Returns Boolean
 I $$isNullOrLiteralNull^UCPRIM(actual(1)) D ERROR^UCGM("Class name required") Q 
 ;
 S return="$$clsIsClass^UCGMR("_actual(1)_")"
 I $$isLit^UCGM(actual(1)) D
 .	S return=$$clsIsClass^UCGMR(actual(1))
 .	I (return="") S return=""""""
 .	Q 
 Q 
 ;
 ; ---------------------------------------------------------------------
isDescendant ; Method Class.isDescendant ; Returns Boolean
 I (actual(1)="") D ERROR^UCGM("Descendant parameter required") Q 
 I (actual(2)="") D ERROR^UCGM("Ancestor parameter required") Q 
 ;
 S return="$$clsIsAnc^UCGMR("_actual(2)_","_actual(1)_")"
 I $$isLit^UCGM(actual(1)),$$isLit^UCGM(actual(2)) D
 .	;   #ACCEPT DATE=10/12/04; PGM=FSCW; CR=11445; GROUP=XECUTE
 .	XECUTE "set return="_return
 .	I (return="") S return=""""""
 .	Q 
 Q 
 ;
 ; ---------------------------------------------------------------------
isValid ; Method Class.isValid ; Returns Boolean
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 D WARNDEP^UCGM(2.7,0,"Class.isValid - use Object.exists")
 I $$isNullOrLiteralNull^UCPRIM(actual(1)) D ERROR^UCGM("Reference object required") Q 
 I $E(actual(1),1)="." S actual(1)=$E(actual(1),2,$L(actual(1)))
 ;
 S return="$D("_oLvn_"(+$G("_actual(1)_")))"
 Q 
 ;
 ; ---------------------------------------------------------------------
newObj(class,lvl) ; name of class
 ;
 I '$$hasSubr^UCGM("vClVobj") D
 .	;
 .	N sr S sr=$$vaddSubr("vClVobj","(vSt,vCls)","Create a new object",0)
 .	D addCode^UCPSLSR(sr," N vOid")
 .	D addCode^UCPSLSR(sr,$$cdNewRef("vOid","vCls","vSt","",""))
 .	D addCode^UCPSLSR(sr," Q vOid")
 .	Q 
 ;
 Q "$$vClVobj("_lvl_","""_class_""")"
 ;
 ; ---------------------------------------------------------------------
newObjSt(asntgt) ; assingment target
 I (asntgt="") S $ZE="0,"_$ZPOS_","_"%PSL-E-MISMATCH,Class is not instantiable in this context",$EC=",U1001,"
 N lvl S lvl=$$getLevel^UCGM(asntgt)
 Q "$ST"_$S(lvl>0:-lvl,1:"")
 ;
 ; ---------------------------------------------------------------------
cdNewObj(objInst,objClass) ; object class expression
 N vret
 ;
 S vret=" S "_objInst_"=$O("_"vobj"_"(""""),-1)+1,"_"vobj"_"("_objInst_",-1)="_objClass Q vret
 ;
 ; ---------------------------------------------------------------------
cdNewRef(objInst,objClass,objStack,objDestr,objAdj) ; stack adjustment procedure
 N vret
 ;
 S vret=" S "_objInst_"=$O("_"vobj"_"(""""),-1)+1,"_"vobj"_"("_objInst_",-1)="_$$cdNewExp(objClass,objStack,objDestr,objAdj) Q vret
 ;
 ; ---------------------------------------------------------------------
cdNewExp(objClass,objStack,objDestr,objAdj) ; stack adjustment procedure
 N code S code=objClass_"_$C(9)_"_objStack
 ;
 I (objDestr=""),(objAdj="") Q code
 ;
 S code=code_"_$C(9)"
 I '(objDestr="") S code=code_"_"_objDestr
 I '(objAdj="") S code=code_"_$C(9)_"_objAdj
 ;
 Q code
 ;
 ;  #OPTION ResultClass ON
vSIG() ; 
 Q "61086^28680^Frans S.C. Witte^14245" ; Signature - LTD^TIME^USER^SIZE
 ; ----------------
 ;  #OPTION ResultClass 1
vaddSubr(p1,p2,p3,p4) ; PSL.addSubrou
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 I $get(p4) S:$E(p1,1)'="v" p1="v"_p1 S p1=$$findSubr^UCGM(p1,"")
 E  I $$hasSubr^UCGM(p1) D ERROR^UCGM("Subroutine exists: "_p1) Q p1
 D addSubr^UCGM(p1,p2,p3)
 Q p1
