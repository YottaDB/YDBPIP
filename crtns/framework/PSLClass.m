 ; 
 ; **** Routine compiled from DATA-QWIK Procedure PSLClass ****
 ; 
 ; 02/24/2010 18:22 - pip
 ; 
 ;  #PACKAGE framework.psl
 ;  #CLASSDEF extends=Primitive public delimiter=9
 ;
 ;  #PROPERTYDEF class  class=String public position=2
 ;
 ;  #PROPERTYDEF extends  class=String public position=3
 ;
 ;  #PROPERTYDEF delimiter = 124 class=Number public position=4
 ;
 ;  #PROPERTYDEF classTypeNATIVE = -2 class=Number public literal
 ;  #PROPERTYDEF classTypeNOCLASS = -1 class=Number public literal
 ;  #PROPERTYDEF classTypeREFERENCE =  0 class=Number public literal
 ;  #PROPERTYDEF classTypePRIMITIVE =  1 class=Number public literal
 ;  #PROPERTYDEF classTypePRIM0NODE =  2 class=Number public literal
 ;  #PROPERTYDEF classTypePRIM0PROP =  3 class=Number public literal
 ;
 ;  #PROPERTYDEF classType  class=Number public position=5
 ;
 ;  #PROPERTYDEF constructor class=String public position=6
 ;
 ;  #PROPERTYDEF isAbstract  class=Boolean public position=7
 ;
 ;  #PROPERTYDEF isNoInstance class=Boolean public position=8
 ;
 ;  #PROPERTYDEF propProc  class=String public position=9
 ;
 ;  #PROPERTYDEF package  class=String public position=10
 ;
 ;  #PROPERTYDEF accessLevelPACKAGE   =  1 class=Number public literal
 ;  #PROPERTYDEF accessLevelPUBLIC    =  2 class=Number public literal
 ;
 ;  #PROPERTYDEF accessLevel  class=String public position=11
 ;
 ;  #PROPERTYDEF flagMTDFIN    =  "F" class=String literal
 ;  #PROPERTYDEF flagMTDINI0   =  "i" class=String literal
 ;  #PROPERTYDEF flagMTDINI1   =  "I" class=String literal
 ;  #PROPERTYDEF flagPRPINIT   =  "P" class=String literal
 ;  #PROPERTYDEF flagPRPREF    =  "R" class=String literal
 ;
 ;  #PROPERTYDEF flags   class=String position=12
 ;
 ;  #PROPERTYDEF destructor   class=String position=13
 ;
 ;  #PROPERTYDEF adjustor   class=String position=14
 ;
 ;  #PROPERTYDEF multiRefNONE  = 0  class=Number public literal
 ;  #PROPERTYDEF multiRefDEFER = 1  class=Number public literal
 ;  #PROPERTYDEF multiRefNOW   = 2  class=Number public literal
 ;
 ;  #PROPERTYDEF recordPREFIX     = "Record" class=String public literal
 ;  #PROPERTYDEF recordISRECORD   = 1  class=Number public literal
 ;  #PROPERTYDEF recordDESCENDANT = 2  class=Number public literal
 ;
 ;  #PROPERTYDEF PRIMITIVECLASS = "Primitive" class=String public literal
 ;  #PROPERTYDEF RECORDCLASS    = "Record"  class=String public literal
 ;  #PROPERTYDEF REFERENCECLASS = "Reference" class=String public literal
 ;  #PROPERTYDEF ROOTCLASS      = "Object"  class=String public literal
 ;
 ;  #PROPERTYDEF ADJUSTORLABEL    = "vcdmAdj" class=String public literal
 ;  #PROPERTYDEF CONSTRUCTORLABEL = "vcdmNew" class=String public literal
 ;  #PROPERTYDEF DESTRUCTORLABEL  = "vcdmDes" class=String public literal
 ;
 ;  #PROPERTYDEF LEFTEXMARK = 31   class=Number private literal
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
fromJSON(json) ; return new PSLClass with properties from json()
 N ocd S ocd=$$vcdmNew^PSLClass("PSLClass")
 ;
 S $P(ocd,$C(9),2)=json("class")
 S $P(ocd,$C(9),11)=json("accessLevel")
 S $P(ocd,$C(9),5)=json("classType")
 S $P(ocd,$C(9),6)=json("constructor")
 S $P(ocd,$C(9),4)=json("delimiter")
 S $P(ocd,$C(9),3)=json("extends")
 S $P(ocd,$C(9),7)=json("isAbstract")
 S $P(ocd,$C(9),8)=json("isNoInstance")
 S $P(ocd,$C(9),10)=json("package")
 S $P(ocd,$C(9),9)=json("propProc")
 ;
 S $P(ocd,$C(9),14)=$get(json("adjustor"))
 S $P(ocd,$C(9),13)=$get(json("destructor"))
 S $P(ocd,$C(9),12)=$get(json("flags"))
 ;
 Q ocd
 ;
 ; ---------------------------------------------------------------------
isRecord(cls) ; Return if the class is a record class
 I cls="Record" Q 1
 ;
 I ($E(cls,1,6)="Record"),$$isTable^UCXDD($E(cls,7,1048575)) Q 2
 Q 0
 ;
 ; ---------------------------------------------------------------------
nativeMod(clsNm) ; 
 N clsdes S clsdes=$$subColMod(clsNm)
 ;
 S $P(clsdes,$C(9),5)=-2
 ;
 Q clsdes
 ;
 ; ---------------------------------------------------------------------
recordMod(td) ; 
 ;
 N clsdes S clsdes=$$vcdmNew^PSLClass("PSLClass")
 ;
 S $P(clsdes,$C(9),11)=2
 S $P(clsdes,$C(9),2)="Record"_$P(td,"|",1)
 S $P(clsdes,$C(9),5)=0
 S $P(clsdes,$C(9),6)="classNew^DBSDYNRA"
 S $P(clsdes,$C(9),4)=$P(td,"|",10)
 S $P(clsdes,$C(9),3)="Record"_$P(td,"|",7)
 S $P(clsdes,$C(9),7)=0
 S $P(clsdes,$C(9),8)=0
 ;
 I '($P(td,"|",6)="") S $P(clsdes,$C(9),10)=$P(td,"|",6)
 E  S $P(clsdes,$C(9),10)="profile.psl"
 ;
 Q clsdes
 ;
 ; ---------------------------------------------------------------------
rowPos(prp) ; return position of column in Row
 Q $$vlstPos("1,CLASS,EXTENDS,DELIMITER,CLASSTYPE,CONSTRUCTOR,ISABSTRACT,ISNOINSTANCE,PROPPROC,PACKAGE,ACCESSLEVEL,FLAGS,DESTRUCTOR,ADJUSTOR",prp,",",1)
 ;
 ; ---------------------------------------------------------------------
subColMod(clsNm) ; 
 N clsdes S clsdes=$$vcdmNew^PSLClass("PSLClass")
 ;
 S $P(clsdes,$C(9),11)=2
 S $P(clsdes,$C(9),2)=clsNm
 S $P(clsdes,$C(9),4)=-1
 S $P(clsdes,$C(9),5)=-1
 S $P(clsdes,$C(9),7)=0
 S $P(clsdes,$C(9),8)=1
 ;
 Q clsdes
 ;
 ; ---------------------------------------------------------------------
tableNameOf(clsNm) ; 
 I $$isRecord(clsNm)=0 S $ZE="0,"_$ZPOS_","_"%PSL-E-MISMATCH,not a Record descendant,"_clsNm,$EC=",U1001,"
 Q $E(clsNm,7,1048575)
 ;
 ; ---------------------------------------------------------------------
classDestroy(this,expPcd,objInst,multiRef) ; polymorphism dispatch
 N vret
 N vC S vC=$P($G(this),$C(9))
 I $D(vPslPoly(vC,"classDestroy")) Q $$v0classDestroy^@vPslPoly(vC,"classDestroy")(.this,.expPcd,.objInst,.multiRef)
 Q $$v0classDestroy(.this,.expPcd,.objInst,.multiRef)
v0classDestroy(this,expPcd,objInst,multiRef) ; return code to destroy an instance of this class
 I $P(this,$C(9),5)>1 Q ""
 I $P(this,$C(9),5)=1 Q " K"_expPcd_" "_objInst
 ;
 I multiRef=1 S vret=" S vobjDfer=vobjDfer_"",""_$G("_objInst_")" Q vret
 ;
 ; code for PSLClass.multiRefNONE --------------------------------------
 N objref S objref="vobj(+$G("_objInst_"))"
 N code S code=" K"_expPcd_" "_objref
 I $$isRecord($P(this,$C(9),2))>0 Q code
 ;
 I ((","_$$getCls^UCGMCU("pslx")_",")[(","_$P(this,$C(9),2)_",")),$P(this,$C(9),2)'="Reference" D
 .	I '($P(this,$C(9),13)="") S code=" D"_expPcd_" "_$P(this,$C(9),13)_"(+$G("_objInst_"))"_code Q 
 .	I $P(this,$C(9),3)="Object" S code="" Q 
 .	Q 
 E  D
 .	N objdtr S objdtr="$P($G(vobj(+$G("_objInst_"),-1),$C(9),2)"
 .	I (expPcd="") S expPcd=":("
 .	E  S expPcd=expPcd_"&("
 .	;
 .	I $P(this,$C(9),12)["F" S code=" D"_expPcd_"$D("_objref_")) @("_objdtr_")_""("_objInst_")"")"_code Q 
 .	;
 .	S code=" D"_expPcd_objdtr_"]"""") @("_objdtr_")_""("_objInst_")"")"_code
 .	Q 
 Q code
 ;
 ; ---------------------------------------------------------------------
classNewCall(this,expPcd,varCls,varStk,varDtr,varAdj,varIni) ; polymorphism dispatch
 N vC S vC=$P($G(this),$C(9))
 I $D(vPslPoly(vC,"classNewCall")) Q $$v0classNewCall^@vPslPoly(vC,"classNewCall")(.this,.expPcd,.varCls,.varStk,.varDtr,.varAdj,.varIni)
 Q $$v0classNewCall(.this,.expPcd,.varCls,.varStk,.varDtr,.varAdj,.varIni)
v0classNewCall(this,expPcd,varCls,varStk,varDtr,varAdj,varIni) ; return code for Class.new(,) occurrence for this class
 N code N dlm
 I $P(this,$C(9),5)=1 D
 .	S code=" D"_expPcd_" "_"vcdmNew"_"^"_$P(this,$C(9),2)_"(."_$char(31)
 .	S dlm=","
 .	Q 
 E  D
 .	S code="$$"_"vcdmNew"_"^"_$P(this,$C(9),2)_"("
 .	S dlm=""
 .	Q 
 ;
 I $P(this,$C(9),5)=0 S code=code_dlm_varStk_","_varDtr_","_varAdj S dlm=","
 ;
 I $P(this,$C(9),5)<3 S code=code_dlm_varCls S dlm=","
 ;
 I $P(this,$C(9),12)["I" S code=code_dlm_varIni I (varIni="") S $ZE="0,"_$ZPOS_","_"%PSL-E-MISMATCH, Class.new("_$$QADD^%ZS($P(this,$C(9),2),"""")_") requires initObject",$EC=",U1001,"
 ;
 Q code_")"
 ;
 ; ---------------------------------------------------------------------
classNewDecl(this,varCls,varStk,varDtr,varAdj,varIni) ; polymorphism dispatch
 N vC S vC=$P($G(this),$C(9))
 I $D(vPslPoly(vC,"classNewDecl")) Q $$v0classNewDecl^@vPslPoly(vC,"classNewDecl")(.this,.varCls,.varStk,.varDtr,.varAdj,.varIni)
 Q $$v0classNewDecl(.this,.varCls,.varStk,.varDtr,.varAdj,.varIni)
v0classNewDecl(this,varCls,varStk,varDtr,varAdj,varIni) ; Return the M declaration of the constuctor for this class
 N code S code="vcdmNew"_"(" N dlm S dlm=""
 ;
 I $P(this,$C(9),5)=1 S code=code_"this" S dlm=","
 ;
 I $P(this,$C(9),5)=0 S code=code_dlm_varStk_","_varDtr_","_varAdj S dlm=","
 ;
 I $P(this,$C(9),5)<3 S code=code_dlm_varCls S dlm=","
 ;
 I $P(this,$C(9),12)["I" S code=code_dlm_varIni I (varIni="") S $ZE="0,"_$ZPOS_","_"%PSL-E-MISMATCH, Class.new("_$$QADD^%ZS($P(this,$C(9),2),"""")_") requires initObject",$EC=",U1001,"
 ;
 Q code_")"
 ;
 ; ---------------------------------------------------------------------
fillExt(this,prsr) ; polymorphism dispatch
 N vC S vC=$P($G(this),$C(9))
 I $D(vPslPoly(vC,"fillExt")) D v0fillExt^@vPslPoly(vC,"fillExt")(.this,.prsr) Q
 D v0fillExt(.this,.prsr) Q
v0fillExt(this,prsr) ; Fill property values that may be inherited from ancestor
 N dtr S dtr=$P(this,$C(9),13)
 I (dtr="") D
 .	N adj S adj=""
 .	I $P(this,$C(9),12)["R" S dtr="vcdmDes"_"^"_$P(this,$C(9),2) S adj="vcdmAdj"_"^"_$P(this,$C(9),2)
 .	I (dtr=""),$P(this,$C(9),12)["F" S dtr="vcdmDes"_"^"_$P(this,$C(9),2)
 .	;
 .	I (adj="") D  ; not needed for this class
 ..		N ext S ext=$$getPSLClass^PSLCC(.prsr,$P(this,$C(9),3))
 ..		S adj=$P(ext,$C(9),14)
 ..		I (dtr="") S dtr=$P(ext,$C(9),13)
 ..		Q 
 .	S $P(this,$C(9),13)=dtr
 .	S $P(this,$C(9),14)=adj
 .	Q 
 N flg S flg=$P(this,$C(9),12)
 I '(flg["I") D
 .	N ext S ext=$$getPSLClass^PSLCC(.prsr,$P(this,$C(9),3))
 .	I ($P(ext,$C(9),12)["I") S $P(this,$C(9),12)=$translate(flg,"i")_"I"
 .	Q 
 Q 
 ;
 ; ---------------------------------------------------------------------
getClassnameExpr(this,inst) ; polymorphism dispatch
 N vC S vC=$P($G(this),$C(9))
 I $D(vPslPoly(vC,"getClassnameExpr")) Q $$v0getClassnameExpr^@vPslPoly(vC,"getClassnameExpr")(.this,.inst)
 Q $$v0getClassnameExpr(.this,.inst)
v0getClassnameExpr(this,inst) ; Return the expession that returns the classname (at runtime)
 I $P(this,$C(9),5)=3 Q $$QADD^%ZS($P(this,$C(9),2),"""")
 I $P(this,$C(9),5)=0 Q "$P($G("_oLvn_"(+$G("_inst_"),-1)),$C(9))"
 Q "$P($G("_inst_"),$C("_$P(this,$C(9),4)_"))"
 ;
 ; ---------------------------------------------------------------------
getPackageRoot(this) ; Return the package root of the class
 N pck S pck=$piece($P(this,$C(9),10),".")
 ;
 Q pck
 ;
 ; ---------------------------------------------------------------------
inPackage(this,pck) ; Is the supplied package equal to or a super package of this.package
 I $P(this,$C(9),10)=pck Q 1
 Q ($E($P(this,$C(9),10),1,$L((pck_".")))=(pck_"."))
 ;
 ; ---------------------------------------------------------------------
isDescendantOf(this,prsr,anc) ; Does this class or one of its ancestors extend anc
 I (anc="Object")!(anc=$P(this,$C(9),3)) Q 1
 I (anc=$P(this,$C(9),2))!($P(this,$C(9),5)<0) Q 0
 I ($P(this,$C(9),2)="Object")!($P(this,$C(9),3)="Object") Q 0
 ;
 N ocd S ocd=this
 ;
 F  S ocd=$$getPSLClass^PSLCC(.prsr,$P(ocd,$C(9),3)) Q:($P(ocd,$C(9),3)=anc)!($P(ocd,$C(9),3)="Object") 
 ;
 Q $P(ocd,$C(9),3)'="Object"
 ;
 ; ---------------------------------------------------------------------
toJSON(this,tknzr) ; polymorphism dispatch
 N vC S vC=$P($G(this),$C(9))
 I $D(vPslPoly(vC,"toJSON")) Q $$v0toJSON^@vPslPoly(vC,"toJSON")(.this,.tknzr)
 Q $$v0toJSON(.this,.tknzr)
v0toJSON(this,tknzr) ; Return this class descriptor as a JSON object
 N json S json="{ "
 S json=json_"""class"" : "_$$QADD^%ZS($P(this,$C(9),2),"""")
 S json=json_","_$char(9)_"""accessLevel"" : "_$P(this,$C(9),11)
 S json=json_","_$char(9)_"""adjustor"" : "_$$QADD^%ZS($P(this,$C(9),14),"""")
 S json=json_","_$char(9)_"""classType"" : "_$P(this,$C(9),5)
 S json=json_","_$char(9)_"""constructor"" : "_$$addQuotes^PSLTokenizer(.tknzr,$P(this,$C(9),6))
 S json=json_","_$char(9)_"""delimiter"" : "_$P(this,$C(9),4)
 S json=json_","_$char(9)_"""destructor"" : "_$$QADD^%ZS($P(this,$C(9),13),"""")
 S json=json_","_$char(9)_"""extends"" : "_$$QADD^%ZS($P(this,$C(9),3),"""")
 S json=json_","_$char(9)_"""flags"" : "_$$QADD^%ZS($P(this,$C(9),12),"""")
 S json=json_","_$char(9)_"""isAbstract"" : "_$S($P(this,$C(9),7):"true",1:"false")
 S json=json_","_$char(9)_"""isNoInstance"" : "_$S($P(this,$C(9),8):"true",1:"false")
 S json=json_","_$char(9)_"""package"" : "_$$QADD^%ZS($P(this,$C(9),10),"""")
 S json=json_","_$char(9)_"""propProc"" : "_$$addQuotes^PSLTokenizer(.tknzr,$P(this,$C(9),9))
 Q json_" }"
 ;  #OPTION ResultClass ON
vSIG(this) ; polymorphism dispatch
 N vC S vC=$P($G(this),$C(9))
 I $D(vPslPoly(vC,"vSIG")) Q $$v0vSIG^@vPslPoly(vC,"vSIG")(.this)
 Q $$v0vSIG(.this)
v0vSIG(this) ; 
 Q "61461^42874^Frans S.C. Witte^24981" ; Signature - LTD^TIME^USER^SIZE
 ; ----------------
 ;  #OPTION ResultClass 1
vlstPos(object,p1,p2,p3) ; List.position
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 I p3 S object=$ZCONVERT(object,"U") S p1=$ZCONVERT(p1,"U")
 S object=p2_object_p2 S p1=p2_p1_p2
 I object'[p1 Q 0
 Q $L($piece(object,p1,1),p2)
vcdmNew(vC) ; Constructor, called for Class.new()
 N this
 S this=vC
 S $P(this,$C(9),4)=124
 Q this
