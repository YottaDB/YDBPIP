	; I18N=QUIT
	;
	; **** Routine compiled from DATA-QWIK Procedure UCGMCONV ****
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
convert(expr,funcs,tok,commands)	;
	;
	N parMap S parMap=$piece(expr,"(",1)_"("
	N pars S pars=$E(expr,$L(parMap)+1,$L(expr)-1)
	;
	I (pars="") Q expr
	;
	I ($E(expr,1)="$"),'($E(expr,1,2)="$$") D
	.	;
	.	S parMap=$$vStrUC($piece(parMap,"(",1))
	.	N f S f="$ASCII,$CHAR,$DATA,$EXTRACT,$FIND,$FNUMBER,$GET,$LENGTH,$ORDER,$PIECE,$QUERY,$RANDOM,$REVERSE,$TRANSLATE"
	.	N y S y=$F("$ASCII,$CHAR,$DATA,$EXTRACT,$FIND,$FNUMBER,$GET,$LENGTH,$ORDER,$PIECE,$QUERY,$RANDOM,$REVERSE,$TRANSLATE",parMap)
	.	;
	.	I y S y=$L($E("$ASCII,$CHAR,$DATA,$EXTRACT,$FIND,$FNUMBER,$GET,$LENGTH,$ORDER,$PIECE,$QUERY,$RANDOM,$REVERSE,$TRANSLATE",1,y-1),",") S parMap=$piece("$ASCII,$CHAR,$DATA,$EXTRACT,$FIND,$FNUMBER,$GET,$LENGTH,$ORDER,$PIECE,$QUERY,$RANDOM,$REVERSE,$TRANSLATE",",",y)_"("
	.	Q 
	;
	N ftok S ftok=($D(tok)#2)
	I 'ftok S pars=$$TOKEN^%ZS(pars,.tok)
	;
	N atom
	N pos S pos=1 N ptr S ptr=0
	;
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
	N template S template=$piece(record,$C(9),1)
	N method S method=$piece(record,$C(9),2)
	N class S class=$piece(record,$C(9),3)
	N litreset S litreset=$piece(record,$C(9),4)
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
	.	I pos?1A S pos=$A(pos)-55 ; Convert Alpha to Num
	.	I pos=0 S object=parMap(i)
	.	E  S $piece(pars,$C(9),pos)=parMap(i)
	.	Q 
	;
	; If the method template itself has parameters, insert them
	I method["(" D
	.	;
	.	N mpars S mpars=$piece(method,"(",2,$L(method))
	.	S mpars=$E(mpars,1,$L(mpars)-1)
	.	S mpars=$$TOKEN^%ZS(mpars,.tok)
	.	S method=$piece(method,"(",1)
	.	;
	.	F i=1:1:$L(mpars,",") I '($piece(mpars,",",i)="") S $piece(pars,$C(9),i)=$piece(mpars,",",i)
	.	Q 
	;
	I (object="") Q expr ; No object if function!
	;
	S expr=object
	;
	; If the object is an expression enclose it in paranthesis,
	; except if that is already the case
	I '$$isGlvn(expr)&'$$isLit^UCGM($$UNTOK^%ZS(expr,tok)) D
	.	I $E(expr,1)="(",$E(expr,$L(expr))=")" Q 
	.	S expr="("_expr_")"
	.	Q 
	;
	I (class="") S class="String"
	S expr=expr_"."_method_"("_$translate(pars,$C(9),",")_")"
	;
	; FSCW CR11445: Class inherits from ancestor. Cast only needed if 'class'
	; not an ancester of $$getClass^UCGM(object)
	;;if $$getClass^UCGM(object) '= class set expr = "{"_class_"}"_expr
	N objCls S objCls=$$getClass^UCGM(object)
	I (objCls="") S objCls="Object"
	I class'=objCls,'$$isAncestor^UCGM(class,objCls) S expr="{"_class_"}"_expr
	;
	I 'ftok S expr=$$UNTOK^%ZS(expr,tok)
	;
	I '(litreset="") D
	.	;
	.	N lvn
	.	N i N j
	.	F i=1:1:$L(litreset,",") D
	..		S lvn=$piece(litreset,",",i)
	..		F j=level:-1:0 I ($D(type(j,lvn))#2) D setInst^UCGM(lvn,msrc+1,"") Q 
	..		Q 
	.	Q 
	I $get(commands("WARN","FUNCTION")) D WARN^UCGM("Extrinsic function replaced: "_$$UNTOK^%ZS(expr,tok))
	;
	Q expr
	;
isGlvn(expr)	; expression to be checked
	I $E(expr,1)="^" S expr=$E(expr,2,1048575)
	I $$isVar^UCGM(expr) Q 1
	Q $$isArr^UCGM(expr)
	; ----------------
	;  #OPTION ResultClass 0
vStrUC(vObj)	; String.upperCase
	;
	;  #OPTIMIZE FUNCTIONS OFF
	Q $translate(vObj,"abcdefghijklmnopqrstuvwxyz±≥µ∂π∫ªºæø‡·‚„‰ÂÊÁËÈÍÎÏÌÓÔÒÚÛÙıˆ¯˘˙˚¸˝˛","ABCDEFGHIJKLMNOPQRSTUVWXYZ°£•¶©™´¨ÆØ¿¡¬√ƒ≈∆«»… ÀÃÕŒœ–—“”‘’÷ÿŸ⁄€‹›ﬁ")
