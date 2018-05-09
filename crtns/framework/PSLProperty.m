 ; 
 ; **** Routine compiled from DATA-QWIK Procedure PSLProperty ****
 ; 
 ; 02/24/2010 18:22 - pip
 ; 
 ;  #PACKAGE framework.psl
 ;  #CLASSDEF extends=Primitive public delimiter=9
 ;
 ;  #PROPERTYDEF class   class=String public position=2
 ;
 ;  #PROPERTYDEF property   class=String public position=3
 ;
 ;  #PROPERTYDEF dimension   class=String public position=4
 ;
 ;  #PROPERTYDEF accessLevelPROTECTED = -1 class=Number public literal
 ;  #PROPERTYDEF accessLevelPRIVATE   =  0 class=Number public literal
 ;  #PROPERTYDEF accessLevelPACKAGE   =  1 class=Number public literal
 ;  #PROPERTYDEF accessLevelPUBLIC    =  2 class=Number public literal
 ;
 ;  #PROPERTYDEF accessLevel  class=Number public position=5
 ;
 ;  #PROPERTYDEF restrictedNONE     = 0 class=Number public literal
 ;  #PROPERTYDEF restrictedREADONLY = 1 class=Number public literal
 ;  #PROPERTYDEF restrictedLITERAL  = 2 class=Number public literal
 ;
 ;  #PROPERTYDEF restricted   class=Number public position=6
 ;
 ;  #PROPERTYDEF resultClass  class=String public position=7
 ;
 ;  #PROPERTYDEF node   class=String public position=8
 ;
 ;  #PROPERTYDEF position   class=Number public position=9
 ;
 ;  #PROPERTYDEF labelref   class=String public position=10
 ;
 ;  #PROPERTYDEF initialValue  class=String public position=11
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
fromJSON(json) ; return new PSLProperty with properties from json()
 N opd S opd=$$vcdmNew^PSLProperty("PSLProperty")
 ;
 S $P(opd,$C(9),2)=json("class")
 S $P(opd,$C(9),3)=json("property")
 S $P(opd,$C(9),5)=json("accessLevel")
 S $P(opd,$C(9),4)=json("dimension")
 S $P(opd,$C(9),10)=json("labelref")
 S $P(opd,$C(9),8)=json("node")
 S $P(opd,$C(9),9)=json("position")
 S $P(opd,$C(9),6)=json("restricted")
 S $P(opd,$C(9),7)=json("resultClass")
 ;
 I ($D(json("initialValue"))#2) S $P(opd,$C(9),11)=json("initialValue")
 ;
 Q opd
 ;
 ; ---------------------------------------------------------------------
rowPos(prp) ; return position of property
 Q $$vlstPos("1,CLASS,PROPERTY,DIMENSION,ACCESSLEVEL,RESTRICTED,RESULTCLASS,NODE,POSITION,LABELREF,INITIALVALUE",prp,",",1)
 ;
 ; ---------------------------------------------------------------------
getExpr(this,inst,subs,ocd) ; return the (M) expression that represents the property
 N exp N dlm N trm
 ;
 I $P(ocd,$C(9),5)=0 S exp="vobj("_inst S dlm="," S trm=")"
 E  S exp=inst S dlm="(" S trm=""
 ;
 I '($P(this,$C(9),8)="") S exp=exp_dlm_$P(this,$C(9),8) S dlm="," S trm=")"
 I '(subs="") S exp=exp_dlm_subs S trm=")"
 S exp=exp_trm
 ;
 I $P(this,$C(9),9)>0 S exp="$P("_exp_",$C("_$P(ocd,$C(9),4)_"),"_$P(this,$C(9),9)_")"
 ;
 Q exp
 ;
 ; ---------------------------------------------------------------------
hasAccess(this,cc,module) ; does caller have access to this property
 ; cases we can decide ourselves
 I $P(this,$C(9),2)=$P(module,$C(9),2) Q 1
 I $P(this,$C(9),5)=2 Q 1
 I $P(this,$C(9),5)=0 Q 0
 ;
 ; cases we need to ask the class
 N ocd S ocd=$$getPSLClass^PSLCC(.cc,$P(this,$C(9),2))
 I $$inPackage^PSLClass(.module,$P(ocd,$C(9),10)) Q 1 ; package
 Q $$isDescendantOf^PSLClass(.module,.cc,$P(ocd,$C(9),2)) ; protected
 ;
 ; ---------------------------------------------------------------------
toJSON(this,tknzr) ; polymorphism dispatch
 N vC S vC=$P($G(this),$C(9))
 I $D(vPslPoly(vC,"toJSON")) Q $$v0toJSON^@vPslPoly(vC,"toJSON")(.this,.tknzr)
 Q $$v0toJSON(.this,.tknzr)
v0toJSON(this,tknzr) ; Return this property declaration as a JSON object.
 N json S json="{ "
 S json=json_"""class"" : "_$$QADD^%ZS($P(this,$C(9),2),"""")
 S json=json_","_$char(9)_"""property"" : "_$$QADD^%ZS($P(this,$C(9),3),"""")
 S json=json_","_$char(9)_"""accessLevel"" : "_$P(this,$C(9),5)
 S json=json_","_$char(9)_"""dimension"" : "_$$QADD^%ZS($P(this,$C(9),4),"""")
 S json=json_","_$char(9)_"""labelref"" : "_$$addQuotes^PSLTokenizer(.tknzr,$P(this,$C(9),10))
 S json=json_","_$char(9)_"""node"" : "_$$QADD^%ZS($P(this,$C(9),8),"""")
 S json=json_","_$char(9)_"""position"" : "_$P(this,$C(9),9)
 S json=json_","_$char(9)_"""restricted"" : "_$P(this,$C(9),6)
 S json=json_","_$char(9)_"""resultClass"" : "_$$QADD^%ZS($P(this,$C(9),7),"""")
 I '($P(this,$C(9),11)="") D
 .	S json=json_","_$char(9)_"""initialValue"" : "
 .	I $P(this,$C(9),7)="Boolean" S json=json_$S($P(this,$C(9),11):"true",1:"false")
 .	E  I $P(this,$C(9),7)="Number" S json=json_$P(this,$C(9),11)
 .	E  S json=json_$$addQuotes^PSLTokenizer(.tknzr,$P(this,$C(9),11))
 .	Q 
 Q json_" }"
 ;  #OPTION ResultClass ON
vSIG(this) ; polymorphism dispatch
 N vC S vC=$P($G(this),$C(9))
 I $D(vPslPoly(vC,"vSIG")) Q $$v0vSIG^@vPslPoly(vC,"vSIG")(.this)
 Q $$v0vSIG(.this)
v0vSIG(this) ; 
 Q "61461^42881^Frans S.C. Witte^8989" ; Signature - LTD^TIME^USER^SIZE
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
