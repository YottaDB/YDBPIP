 ; 
 ; **** Routine compiled from DATA-QWIK Procedure PSLMethod ****
 ; 
 ; 02/24/2010 18:22 - pip
 ; 
 ;  #PACKAGE  framework.psl
 ;  #CLASSDEF extends=Primitive public delimiter=9
 ;
 ;  #PROPERTYDEF class   class=String public position=2
 ;  #PROPERTYDEF method   class=String public position=3
 ;  #PROPERTYDEF resultClass  class=String public position=4
 ;  #PROPERTYDEF formalList   class=List public position=5
 ;
 ;  #PROPERTYDEF accessLevelPROTECTED = -1 class=Number public literal
 ;  #PROPERTYDEF accessLevelPRIVATE   =  0 class=Number public literal
 ;  #PROPERTYDEF accessLevelPACKAGE   =  1 class=Number public literal
 ;  #PROPERTYDEF accessLevelPUBLIC    =  2 class=Number public literal
 ;
 ;  #PROPERTYDEF accessLevel  class=Number public position=6
 ;
 ;  #PROPERTYDEF methodTypeINSTANCE = 0 class=Number public literal
 ;  #PROPERTYDEF methodTypeFINAL = 1 class=Number public literal
 ;  #PROPERTYDEF methodTypeSTATIC = 2 class=Number public literal
 ;  #PROPERTYDEF methodTypeNOFPL = 3 class=Number public literal
 ;  #PROPERTYDEF methodTypeLABEL = 4 class=Number public literal
 ;
 ;  #PROPERTYDEF methodType   class=Number public position=7
 ;
 ;  #PROPERTYDEF codeLine   class=Number public position=8
 ;
 ;  #PROPERTYDEF sourceLine   class=Number public position=9
 ;
 ;  #PROPERTYDEF targetLine   class=Number public position=10
 ;
 ;  #PROPERTYDEF methodProc   class=String public position=11
 ;
 ;  #PROPERTYDEF inLiteral   class=Boolean public position=12
 ;
 ;  #PROPERTYDEF comment   class=String public position=13
 ;
 ;  #PROPERTYDEF FPBYLITERAL = "literal" class=String public literal
 ;  #PROPERTYDEF FPBYRETURN  = "ret" class=String public literal
 ;  #PROPERTYDEF FPBYVALUE   = "noret" class=String public literal
 ;
 ;  #PROPERTYDEF POLYDISPATCH = "vPslPoly" class=String public literal
 ;
 ;  #PROPERTYDEF STACKFPN = "vcdmS"  class=String private literal
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
fromJSON(json) ; return new PSLMethod with properties from json()
 N omd S omd=$$vcdmNew^PSLMethod("PSLMethod")
 ;
 S $P(omd,$C(9),2)=json("class")
 S $P(omd,$C(9),3)=json("method")
 S $P(omd,$C(9),4)=json("resultClass")
 S $P(omd,$C(9),5)=json("formalList")
 S $P(omd,$C(9),6)=json("accessLevel")
 S $P(omd,$C(9),7)=json("methodType")
 S $P(omd,$C(9),11)=json("methodProc")
 S $P(omd,$C(9),12)=json("inLiteral")
 S $P(omd,$C(9),13)=json("comment")
 ;
 Q omd
 ;
 ; ---------------------------------------------------------------------
rowPos(prop) ; return position of column in Row
 Q $$vlstPos("1,CLASS,METHOD,RESULTCLASS,FORMALLIST,ACCESSLEVEL,METHODTYPE,CODELINE,SOURCELINE,TARGETLINE,METHODPROC,INLITERAL,COMMENT",prop,",",1)
 ;
 ; ---------------------------------------------------------------------
getAccess(this) ; Return the access modifier of the method
 N acc S acc=$P(this,$C(9),6)
 I acc=2 Q "public"
 I acc=0 Q "private"
 I acc=-1 Q "protected"
 Q "" ; accessLevelPACKAGE
 ;
 ; ---------------------------------------------------------------------
getCall4M(this,inst,args,module,prsr) ; Return the M code for a call to this method in an M environment
 N call S call=$P(this,$C(9),3)
 N dlm S dlm="("
 N n S n=$order(args(""),-1)
 N resCls S resCls=$P(this,$C(9),4)
 N ocd S ocd=$$getPSLClass^PSLCC(.prsr,$P(this,$C(9),2))
 ;
 I $P(this,$C(9),2)'=module S call=call_"^"_$P(this,$C(9),2)
 ;
 I $P(this,$C(9),7)>2 Q call ; no formallist
 ;
 I $P(this,$C(9),7)'>1 D
 .	I inst="super" D
 ..		S call="v0"_$P(this,$C(9),3)_"^"_$$getSuper^PSLParser(.prsr,module_"."_$P(this,$C(9),3))
 ..		S inst="this"
 ..		Q 
 .	I $P(ocd,$C(9),5)'=0,$P(ocd,$C(9),5)'=3 S inst="."_inst
 .	S call=call_"("_inst S dlm=","
 .	Q 
 ;
 I resCls'="void" D
 .	S call="$$"_call
 .	S ocd=$$getPSLClass^PSLCC(.prsr,resCls)
 .	I '($P(ocd,$C(9),14)="") S call=call_dlm_"$ST" S dlm=","
 .	Q 
 ;
 N fpl S fpl=$P(this,$C(9),5)
 F n=1:1:n D
 .	S ocd=$$getPSLClass^PSLCC(.prsr,$$getFpClass(.this,n))
 .	;
 .	I $P(ocd,$C(9),5)'=3,$P(ocd,$C(9),5)'=0,$E(args(n),1)'=".",$$isName^PSLParser(.prsr,args(n)) S args(n)="."_args(n)
 .	S call=call_dlm_args(n) S dlm=","
 .	I '($P(ocd,$C(9),14)="") S call=call_",$ST"
 .	Q 
 ;
 I dlm="(" S call=call_dlm
 Q $$RTCHR^%ZFUNC(call,",")_")"
 ;
 ; ---------------------------------------------------------------------
getDecl4M(this,prsr) ; Return method declaration for M
 N decl S decl=$P(this,$C(9),3)
 N dlm S dlm="("
 N resCls S resCls=$P(this,$C(9),4)
 N ocd
 ;
 I $P(this,$C(9),7)>2 Q decl_" ; "_$P(this,$C(9),13) ; no formallist
 ;
 I $P(this,$C(9),7)'>1 S decl=decl_"(this" S dlm="," ; append instance var
 ;
 I resCls'="void",'(resCls="") D
 .	S ocd=$$getPSLClass^PSLCC(.prsr,resCls)
 .	I '($P(ocd,$C(9),14)="") S decl=decl_dlm_"vcdmS"_"0" S dlm=","
 .	Q 
 ;
 N n
 N fpl S fpl=$P(this,$C(9),5)
 F n=1:1:$S((fpl=""):0,1:$L(fpl,";")) D
 .	S decl=decl_dlm_$piece($piece($piece(fpl,";",n)," ",3),"(") S dlm=","
 .	Q:$$getFpAccess(.this,n)'="ret" 
 .	S ocd=$$getPSLClass^PSLCC(.prsr,$$getFpClass(.this,n))
 .	I '($P(ocd,$C(9),14)="") S decl=decl_","_"vcdmS"_n
 .	Q 
 ;
 I dlm="(" S decl=decl_dlm
 S decl=decl_") ; "_$P(this,$C(9),13)
 ;
 I $P(this,$C(9),7)=0,$P(this,$C(9),6)'=0 D
 .	N lbl S lbl=$piece(decl,"(")
 .	N poly S poly=$piece(decl," ;")
 .	N apl S apl="(.this" ; turn all fps into pass-by-return aps
 .	I (poly[",") D
 ..		F n=2:1:$L(poly,",") S apl=apl_",."_$piece(poly,",",n)
 ..		Q 
 .	E  S apl=apl_")"
 .	N pre N post
 .	S ocd=$$getPSLClass^PSLCC(.prsr,$P(this,$C(9),2))
 .	;
 .	I $P(this,$C(9),4)="void" S pre=" D v0" S post=" Q"
 .	E  S pre=" Q $$v0" S post=""
 .	;
 .	S poly=poly_" ; polymorphism dispatch"
 .	S poly=poly_$char(10)_" N vC S vC="_$$getClassnameExpr^PSLClass(.ocd,"this")
 .	S poly=poly_$char(10)_" I $D("_"vPslPoly"_"(vC,"""_$P(this,$C(9),3)_"""))"_pre_lbl_"^@"_"vPslPoly"_"(vC,"""_$P(this,$C(9),3)_""")"_apl_post
 .	S poly=poly_$char(10)_pre_lbl_apl_post
 .	S decl=poly_$char(10)_"v0"_decl
 .	Q 
 Q decl
 ;
 ; ---------------------------------------------------------------------
getFp(this,pos) ; 
 Q $piece($P(this,$C(9),5),";",pos)
 ;
 ; ---------------------------------------------------------------------
getFpAccess(this,pos) ; 
 N fp S fp=$piece($P(this,$C(9),5),";",pos)
 Q $piece(fp," ")
 ;
 ; ---------------------------------------------------------------------
getFpClass(this,pos) ; 
 Q $piece($piece($P(this,$C(9),5),";",pos)," ",2)
 ;
 ; ---------------------------------------------------------------------
getFpCount(this) ; PSL Method descriptor (*1)
 I $P(this,$C(9),7)>2 Q -1 ; no formallist
 ;type String fpl = this.formalList
 ;if fpl.isNull() quit 0
 ;quit fpl.length(";")
 Q $S(($P(this,$C(9),5)=""):0,1:$L($P(this,$C(9),5),";"))
 ;
 ; ---------------------------------------------------------------------
getFpPosition(this,sig) ; Return position of formal parameter name or signature in formalList
 N fpl S fpl=$P(this,$C(9),5)
 I (fpl="") Q 0
 ;
 N p1 S p1=0
 F  S p1=$F(fpl," "_sig,p1) Q:$E(fpl,p1)?1P  Q:p1=0 
 ;
 I p1=0 Q 0 ; signature not found
 Q $L($E(fpl,1,p1-1),";")
 ;
 ; ---------------------------------------------------------------------
getFpVsig(this,pos) ; 
 Q $piece($piece($P(this,$C(9),5),";",pos)," ",3)
 ;
 ; ---------------------------------------------------------------------
hasAccess(this,cc,module) ; does caller have access to this method
 ; cases we can decide ourselves
 I $P(this,$C(9),2)=$P(module,$C(9),2) Q 1
 I $P(this,$C(9),6)=2 Q 1
 I $P(this,$C(9),6)=0 Q 0
 ;
 ; cases we need to ask the class
 N ocd S ocd=$$getPSLClass^PSLCC(.cc,$P(this,$C(9),2))
 I $$inPackage^PSLClass(.module,$P(ocd,$C(9),10)) Q 1 ; package
 Q $$isDescendantOf^PSLClass(.module,.cc,$P(ocd,$C(9),2)) ; proteced
 ;
 ; ---------------------------------------------------------------------
toJSON(this,tknzr) ; polymorphism dispatch
 N vC S vC=$P($G(this),$C(9))
 I $D(vPslPoly(vC,"toJSON")) Q $$v0toJSON^@vPslPoly(vC,"toJSON")(.this,.tknzr)
 Q $$v0toJSON(.this,.tknzr)
v0toJSON(this,tknzr) ; Produre JSON version of descriptor
 N json S json="{ "
 S json=json_"""class"" : "_$$QADD^%ZS($P(this,$C(9),2),"""")
 S json=json_","_$char(9)_"""method"" : "_$$QADD^%ZS($P(this,$C(9),3),"""")
 S json=json_","_$char(9)_"""resultClass"" : "_$$QADD^%ZS($P(this,$C(9),4),"""")
 S json=json_","_$char(9)_"""formalList"" : "_$$QADD^%ZS($P(this,$C(9),5),"""")
 S json=json_","_$char(9)_"""methodProc"" : "_$$addQuotes^PSLTokenizer(.tknzr,$P(this,$C(9),11))
 S json=json_","_$char(9)_"""inLiteral"" : "_$S($P(this,$C(9),12):"true",1:"false")
 S json=json_","_$char(9)_"""accessLevel"" : "_$P(this,$C(9),6)
 S json=json_","_$char(9)_"""methodType"" : "_$P(this,$C(9),7)
 S json=json_","_$char(9)_"""comment"" : "_$$addQuotes^PSLTokenizer(.tknzr,$P(this,$C(9),13))
 Q json_" }"
 ;
 ; ---------------------------------------------------------------------
typeDecl(this,clsdes) ; Add declarations of formal parameters to type(,) array
 N fpn
 N fpl S fpl=$P(this,$C(9),5)
 N cls N dups N fp N fps N var
 ;
 ; add formal parameters to type(,)
 F fpn=1:1:$S((fpl=""):0,1:$L(fpl,";")) D
 .	S fp=$piece(fpl,";",fpn)
 .	S fps=$ZCONVERT($piece(fp," "),"U") S:fps="NORET" fps=""
 .	S cls=$piece(fp," ",2)
 .	S var=$piece(fp," ",3)
 .	I ($D(dups($piece(var,"(")))#2) D ERROR^UCGM("Parameter "_var_" is multiply defined")
 .	;
 .	;   #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 .	D typeDec^UCGM(var,cls,"FORMAL"_fps) D trackNam^UCGM(var)
 .	I $$isRecord^PSLClass(cls),$piece(fp," ")'="ret" D setAssign^UCREC4OP(subRou,var,-1)
 .	S dups($piece(var,"("))=""
 .	Q 
 ;
 ; add this to type() if this is an instance method
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 I $P(this,$C(9),7)'>1 D typeDec^UCGM("this",$P(this,$C(9),2),"FORMALRET")
 ;
 Q 0
 ;  #OPTION ResultClass ON
vSIG(this) ; polymorphism dispatch
 N vC S vC=$P($G(this),$C(9))
 I $D(vPslPoly(vC,"vSIG")) Q $$v0vSIG^@vPslPoly(vC,"vSIG")(.this)
 Q $$v0vSIG(.this)
v0vSIG(this) ; 
 Q "61461^42876^Frans S.C. Witte^20231" ; Signature - LTD^TIME^USER^SIZE
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
 Q this
