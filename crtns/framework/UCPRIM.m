 ; 
 ; **** Routine compiled from DATA-QWIK Procedure UCPRIM ****
 ; 
 ; 02/24/2010 18:23 - pip
 ; 
 ;
 ;  #PACKAGE framework.psl
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
get() ; generate code for Prmitive.get
 ;
 I $$isLit^UCGM(objectName) S return=objectName
 E  D psl2m(0,1)
 ;
 Q 
 ;
 ; ---------------------------------------------------------------------
init() ; initialize compiler structures to handle primitives
 ;
 S primtyp("Date","+","Number")="Date"
 S primtyp("Date","-","Number")="Date"
 ;
 S primtyp("Time","+","Number")="Time"
 S primtyp("Time","-","Number")="Time"
 ;
 Q 
 ;
 ; ---------------------------------------------------------------------
isNotNull() ; Method Blob/Column/Date/Memo/String/Time.isNotNull - Primitive is a null
 D isNull()
 I return="0" S return="1"
 E  I return="1" S return="0"
 E  S return="'"_return
 Q 
 ;
 ; ---------------------------------------------------------------------
isNullOrLiteralNull(val) ; Runtime implementation used by isNull method
 Q (val=""!(val=""""""))
 ;
 ; ---------------------------------------------------------------------
isNull() ; Method String/Date/.../Primitive.isNull - Primitive is a null
 N vo6,vo7
 N specialNull ;if true, two double quotes count as null
 ;
 ;by default, do not treat the string consisting of two quotes as null
 I (actual(1)="") S specialNull=0
 E  S specialNull=$$QSUB^%ZS(actual(1),"""")
 ;
 ; Handle Column.isNull()
 I $$getAtt^UCGM(objectName,objectLevel,1)="Column" D
 .	;Use valExpr to replace the column reference with the column's curVal.
 .	;Tokenize objectName before sending to valExpr, untokenize after
 .	N lexpr
 .	;   #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 . S vo6=tok S lexpr=$$TOKEN^%ZS($$getAtt^UCGM(objectName,objectLevel,5),.vo6,"") S tok=vo6
 .	;   #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 .	S lexpr=$$valExpr^UCGM(lexpr)
 .	;   #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 . S vo7=tok S lexpr=$$UNTOK^%ZS(lexpr,.vo7) S tok=vo7
 .	S objectName=lexpr
 .	Q 
 ;
 I specialNull D
 .	;For a simple expression, use the following as we can refer to
 .	;objectName twice without side-effects.
 .	;For non-simples, use the runtime implementation to avoid side-effects of evaluating
 .	;the expression twice in something like expr="" ! expr=""""""
 .	;   #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 .	I $$isSimple^UCGM(objectName) S return="("_objectName_"=""""!("_objectName_"=""""""""""""))"
 .	E  S return="$$isNullOrLiteralNull^UCPRIM("_objectName_")"
 .	Q 
 E  S return="("_objectName_"="""")"
 ;
 I $$isLit^UCGM(objectName) S return=$$toLit^UCSTRING(return)
 ;
 Q 
 ;
 ; ---------------------------------------------------------------------
setNull() ; Method Primdesc.setNull - set the Primitive descendant to null
 N vo11
 ;
 I $$getAtt^UCGM(objectName,objectLevel,1)="Column" D
 .	I postCond'="" S $ZE="0,"_$ZPOS_","_"%PSL-E-POSTCOND: Post conditional on Column.setNull() not allowed.",$EC=",U1001,"
 .	;
 .	N ptr S ptr=0
 .	N lexpr ;rec.col
 .	N lvar N lcls ; instance variable and its class
 .	;   #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 . S vo11=tok S lexpr=$$TOKEN^%ZS($$getAtt^UCGM(objectName,objectLevel,5),.vo11,"") S tok=vo11
 .	;
 .	;   #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 .	S lvar=$piece(lexpr,".",1) S lcls=$$getClass^UCGM(lvar)
 .	S return=$$curVal^UCCOLUMN(lvar,$$tableNameOf^PSLClass(lcls),$piece(lexpr,".",2),1,"",.ptr)
 .	S return=$$vStrRep(return,$char(31),"""""",0,0,"")
 .	;
 .	S class="void"
 .	Q 
 E  D
 .	N assignable
 .	;   #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 .	S assignable=$$isVar^UCGM(objectName)!$$isArr^UCGM(objectName)!($$isObj^UCGM(objectName)&(objectName'["("))
 .	I 'assignable D
 ..		S $ZE="0,"_$ZPOS_","_"%PSL-E-SETNULL: Can only use setNull on a variable or property",$EC=",U1001,"
 ..		Q 
 .	;
 .	I postCond="" D
 ..		;    #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 ..		D setInst^UCGM(objectName,"","""""",level)
 ..		Q 
 .	E  D
 ..		;    #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 ..		D setInst^UCGM(objectName,"","",level)
 ..		Q 
 .	S return=" S"_postCond_" "_objectName_"="""""
 .	Q 
 ;
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 S mcode=$$backup^UCGM(mcode)
 ;
 Q 
 ;
 ; ---------------------------------------------------------------------
prim2prim(tt) ; "code generator" for Xxx.toYyy()
 S class=tt S return=objectName
 ;
 Q 
 ;
 ; ---------------------------------------------------------------------
primRel(cls1,cls2) ; 
 I (",Boolean,ByteString,Date,Integer,List,Memo,Number,Primitive,String,Time,PSLExpression,"[(","_cls1_",")),(",Boolean,ByteString,Date,Integer,List,Memo,Number,Primitive,String,Time,PSLExpression,"[(","_cls2_",")) Q 1
 ;
 I cls1="String" Q (",PSLColumn,PSLTable,SchemaColumn,SchemaTable,"[(","_cls2_","))
 I cls2="String" Q (",PSLColumn,PSLTable,SchemaColumn,SchemaTable,"[(","_cls1_","))
 ;
 Q 0
 ;
 ; ---------------------------------------------------------------------
primStr(pslPrsr,sCls) ; is class implemented as a single String?
 ;
 Q:(sCls="") 0
 Q $P($$getPSLClass^PSLCC(.pslPrsr,sCls),$C(9),5)>1
 ;
 ; ---------------------------------------------------------------------
primVal(pslPrsr,sCls) ; is class implemented as a primitive value (PRIM0PROP)
 ;
 Q:(sCls="") 0
 Q $P($$getPSLClass^PSLCC(.pslPrsr,sCls),$C(9),5)=3
 ;
 ; ---------------------------------------------------------------------
primVar(pslPrsr,sCls) ; is class implemented as primitive value?
 ;
 Q:sCls="" 0 ; empty class does not use primitive vars
 ;
 Q $P($$getPSLClass^PSLCC(.pslPrsr,sCls),$C(9),5)>0
 ;
 ; ---------------------------------------------------------------------
 ;private primDes( String class)    // is class descendent of Primitive?
 ;type public String pslPrsr(,)
 ;
 ;quit:class="" 0  // empty class does not descent from Primitive
 ;
 ;type Number val = $$getPSLClass^PSLParser( pslPrsr(,), class).classType - 1
 ;quit $SELECT(val'<0:val,1:0)
 ;
 ; ---------------------------------------------------------------------
psl2m(minArg,maxArg) ; maximum number of arguments /REQ/MECH=VAL
 ;
 N mid S mid=$$findPSLMethod^PSLParser(.pslPrsr,.tknzr,mclass_"."_method,0)
 N allowLit S allowLit=0
 I '(mid="") S allowLit=$P(pslPrsr("pslMtd",mid),$C(9),12)
 D mtd2m(method,allowLit,minArg,maxArg)
 Q 
 ;
 ; ---------------------------------------------------------------------
mtd2m(mname,isLit,minArg,maxArg) ; maximum number of arguments /REQ/MECH=VAL
 ;
 N ER S ER=0
 N nArg N supArg
 ;
 I isLit S isLit=$$isLit^UCGM(objectName)
 E  S objectName=objectVar
 ;
 F nArg=1:1:minArg D
 .	I (actual(nArg)="") D ERROR^UCGM("method misses required parameters: "_mname) Q 
 .	S isLit=isLit&$$isLit^UCGM(actual(nArg))
 .	Q 
 I ER'=0 Q 
 ;
 I minArg=0 S minArg=1 ; never check actual(0)
 F nArg=minArg:1:maxArg+1 Q:($get(actual(nArg))="")  S isLit=isLit&$$isLit^UCGM(actual(nArg))
 S supArg=nArg-1
 ;
 F nArg=supArg+1:1:maxArg I '(actual(nArg)="") D ERROR^UCGM("method does not support missing parameters: "_mname) Q 
 I ER'=0 Q 
 ;
 S return="$"_mname_"("_objectName
 ;
 F nArg=1:1:supArg S return=return_","_actual(nArg)
 S return=return_")"
 ;
 I isLit D
 .	N newret
 .	;   #ACCEPT PGM=FSCW; DATE=2004-11-17; CR=11439;GROUP=XECUTE
 .	XECUTE "set newret="_return
 .	I $L(newret)>511 Q 
 .	I '(newret=+newret) S return=$S(newret'["""":""""_newret_"""",1:$$QADD^%ZS(newret,"""")) Q 
 .	S return=newret
 .	Q 
 Q 
 ;
 ; ---------------------------------------------------------------------
toVal(expr,def) ; default if not lit. /REQ/MECH=VAL
 I (expr=+expr) Q +expr
 ;
 ;  #ACCEPT CR=11441; PGM=FSCW; DATE=2004-11-17; GROUP=XECUTE,ACCESS
 I $$isStr^UCGM(expr) XECUTE "set def="_expr
 ;
 Q def
 ;  #OPTION ResultClass ON
vSIG() ; 
 Q "61436^42425^Frans S.C. Witte^19331" ; Signature - LTD^TIME^USER^SIZE
 ; ----------------
 ;  #OPTION ResultClass 1
vStrRep(object,p1,p2,p3,p4,qt) ; String.replace
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 ;
 I p3<0 Q object
 I $L(p1)=1,$L(p2)<2,'p3,'p4,(qt="") Q $translate(object,p1,p2)
 ;
 N y S y=0
 F  S y=$$vStrFnd(object,p1,y,p4,qt) Q:y=0  D
 .	S object=$E(object,1,y-$L(p1)-1)_p2_$E(object,y,1048575)
 .	S y=y+$L(p2)-$L(p1)
 .	I p3 S p3=p3-1 I p3=0 S y=$L(object)+1
 .	Q 
 Q object
 ; ----------------
 ;  #OPTION ResultClass 1
vStrFnd(object,p1,p2,p3,qt) ; String.find
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 ;
 I (p1="") Q $S(p2<1:1,1:+p2)
 I p3 S object=$ZCONVERT(object,"U") S p1=$ZCONVERT(p1,"U")
 S p2=$F(object,p1,p2)
 I '(qt=""),$L($E(object,1,p2-1),qt)#2=0 D
 .	F  S p2=$F(object,p1,p2) Q:p2=0!($L($E(object,1,p2-1),qt)#2) 
 .	Q 
 Q p2
