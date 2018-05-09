 ; 
 ; **** Routine compiled from DATA-QWIK Procedure UCGMCONV ****
 ; 
 ; 02/24/2010 18:23 - pip
 ; 
 ;  #PACKAGE framework.psl
 ;  #OPTION ResultClass ON
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
convert(expr,funcs,tok) ; Convert function expression to method
 ;
 N parMap S parMap=$piece(expr,"(",1)_"("
 N pars S pars=$E(expr,$L(parMap)+1,$L(expr)-1)
 ;
 I (pars="") Q expr
 ;
 I ($E(expr,1)="$"),'($E(expr,1,2)="$$") D
 .	;
 .	S parMap=$ZCONVERT($piece(parMap,"(",1),"U")
 .	N f S f="$ASCII,$CHAR,$DATA,$EXTRACT,$FIND,$FNUMBER,$GET,$LENGTH,$ORDER,$PIECE,$QUERY,$RANDOM,$REVERSE,$TRANSLATE"
 .	N y S y=$F("$ASCII,$CHAR,$DATA,$EXTRACT,$FIND,$FNUMBER,$GET,$LENGTH,$ORDER,$PIECE,$QUERY,$RANDOM,$REVERSE,$TRANSLATE",parMap)
 .	;
 .	I y S y=$L($E("$ASCII,$CHAR,$DATA,$EXTRACT,$FIND,$FNUMBER,$GET,$LENGTH,$ORDER,$PIECE,$QUERY,$RANDOM,$REVERSE,$TRANSLATE",1,y-1),",") S parMap=$piece("$ASCII,$CHAR,$DATA,$EXTRACT,$FIND,$FNUMBER,$GET,$LENGTH,$ORDER,$PIECE,$QUERY,$RANDOM,$REVERSE,$TRANSLATE",",",y)_"("
 .	Q 
 ;
 N ftok S ftok=($D(tok)#2)
 ;
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 I 'ftok S pars=$$TOKEN^%ZS(pars,.tok)
 ;
 N atom
 N pos S pos=1 N ptr S ptr=0
 ;
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 F  S atom=$$ATOM^%ZS(pars,.ptr,",",.tok,1) D  I ptr=0 Q 
 .	;
 .	I atom="," S parMap=parMap_"," S pos=pos+1
 .	E  S parMap=parMap_1 S parMap(pos)=atom
 .	Q 
 ;
 S parMap=parMap_")"
 ;
 N record S record=$get(funcs(parMap))
 ;
 I (record="") S record=$$loadFunc^UCDTASYS(parMap,.funcs)
 ;
 N template S template=$piece(record,$char(9),1)
 N method S method=$piece(record,$char(9),2)
 N class S class=$piece(record,$char(9),3)
 N litreset S litreset=$piece(record,$char(9),4)
 ;
 I (template="") Q expr
 ;
 N i
 N object S object=""
 ;
 S pars=""
 S template=$piece($piece(template,"(",2),")",1)
 S parMap=$piece($piece(parMap,"(",2),")",1)
 F i=1:1:$L(parMap,",") I $piece(parMap,",",i) D
 .	;
 .	N pos S pos=$piece(template,",",i)
 .	I pos?1A S pos=$ascii(pos)-55 ; Convert Alpha to Num
 .	I pos=0 S object=parMap(i)
 .	E  S $piece(pars,$char(9),pos)=parMap(i)
 .	Q 
 ;
 ; If the method template itself has parameters, insert them
 I method["(" D
 .	;
 .	N mpars S mpars=$piece(method,"(",2,$L(method))
 .	S mpars=$E(mpars,1,$L(mpars)-1)
 .	;
 .	;   #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 .	S mpars=$$TOKEN^%ZS(mpars,.tok)
 .	S method=$piece(method,"(",1)
 .	;
 .	F i=1:1:$L(mpars,",") I '($piece(mpars,",",i)="") S $piece(pars,$char(9),i)=$piece(mpars,",",i)
 .	Q 
 ;
 I (object="") Q expr ; No object if function!
 ;
 S expr=object
 ;
 ; If the object is an expression enclose it in paranthesis,
 ; except if that is already the case
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 I '$$isGlvn(expr)&'$$isLit^UCGM($$UNTOK^%ZS(expr,tok)) D
 .	I $E(expr,1)="(",$E(expr,$L(expr))=")" Q 
 .	S expr="("_expr_")"
 .	Q 
 ;
 I (class="") S class="String"
 S expr=expr_"."_method_"("_$$vStrRep(pars,$char(9),",",0,0,"")_")"
 ;
 ; FSCW CR11445: Class inherits from ancestor. Cast only needed if 'class'
 ; not an ancester of $$getClass^UCGM(object)
 ;;if $$getClass^UCGM(object) '= class set expr = "{"_class_"}"_expr
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 N objCls S objCls=$$getClass^UCGM(object)
 I (objCls="") S objCls="Object"
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 I class'=objCls,'$$isAncestor^UCGM(class,objCls) S expr="{"_class_"}"_expr
 ;
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 I 'ftok S expr=$$UNTOK^%ZS(expr,tok)
 ;
 I '(litreset="") D
 .	;
 .	;   #ACCEPT CR=27800;Date=2007-10-09;PGM=Frans S.C. Witte;Group=DEPRECATED; use of type()
 .	;
 .	N lvn
 .	N i N j
 .	F i=1:1:$L(litreset,",") D
 ..		S lvn=$piece(litreset,",",i)
 ..		;
 ..		;    #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 ..		F j=level:-1:0 I ($D(type(j,lvn))#2) D setInst^UCGM(lvn,msrc+1,"") Q 
 ..		Q 
 .	Q 
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 D warnGroup^UCGM("FUNCTION","Extrinsic function replaced: "_$$UNTOK^%ZS(expr,tok))
 ;
 Q expr
 ;
 ; ---------------------------------------------------------------------
isGlvn(expr) ; 
 I $E(expr,1)="^" S expr=$E(expr,2,1048575)
 ;
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 I $$isVar^UCGM(expr) Q 1
 ;
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 Q $$isArr^UCGM(expr)
 ;  #OPTION ResultClass ON
vSIG() ; 
 Q "61348^60742^Frans S.C. Witte^9377" ; Signature - LTD^TIME^USER^SIZE
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
