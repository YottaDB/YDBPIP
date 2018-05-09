UCPRIM	;
	;
	; **** Routine compiled from DATA-QWIK Procedure UCPRIM ****
	;
	; 11/08/2007 14:08 - chenardp
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
get()	; generate code for Prmitive.get
	;
	I $$isLit^UCGM(objectName) S return=objectName
	E  D psl2m(0,1)
	;
	Q 
	;
init()	; initialize compiler structures to handle primitives
	;
	N rs,vos1,vos2,vos3 S rs=$$vOpen1()
	N pclass N supertyp
	;
	F  Q:'($$vFetch1())  D
	.	S pclass=$P(rs,$C(9),1)
	.	S supertyp=$P(rs,$C(9),2)
	.	I supertyp="Primitive" S primtyp(pclass)=2
	.	E  S primtyp(pclass)=$$isAncestor^UCGM("Primitive",pclass)
	.	Q 
	;
	S primtyp("Primitive")=1
	;
	S primtyp("Date","+","Number")="Date"
	S primtyp("Date","-","Number")="Date"
	;
	S primtyp("Time","-","Number")="Time"
	S primtyp("Time","-","Number")="Time"
	;
	Q 
	;
isNull()	; Method Primitive.isNull - Primitive is a null
	I (actual(1)="") S actual(1)=0
	;
	I $$QSUB^%ZS(actual(1),"""") S return="(""""""""""""["_objectName_")"
	E  S return="("_objectName_"="""")"
	;
	I $$isLit^UCGM(objectName) S return=$$toLit^UCSTRING(return)
	;
	Q 
	;
primVar(class)	; is class implemented as primitive value?
	;
	Q ($D(primtyp(class))#2)
	;
primDes(class)	; is class descendent of Primitive?
	;
	Q +$get(primtyp(class))
	;
primNext(class)	; Return the next primitive class
	;
	F  S class=$order(primtyp(class)) Q:class=""  Q:primtyp(class)=2 
	Q class
	;
psl2m(minArg,maxArg)	;
	;
	N ER S ER=0
	N nArg N supArg
	N rwMtd S rwMtd=$$omGet^UCXOBJ(.pslMtd,mclass,method,1)
	N isLit S isLit=$P(rwMtd,$C(124),6)
	;
	I isLit S isLit=$$isLit^UCGM(objectName)
	E  S objectName=objectVar
	;
	F nArg=1:1:minArg D
	.	I (actual(nArg)="") D ERROR^UCGM("method misses required parameters: "_method) Q 
	.	S isLit=isLit&$$isLit^UCGM(actual(nArg))
	.	Q 
	I ER'=0 Q 
	;
	I minArg=0 S minArg=1 ; never check actual(0)
	F nArg=minArg:1:maxArg+1 Q:($get(actual(nArg))="")  S isLit=isLit&$$isLit^UCGM(actual(nArg))
	S supArg=nArg-1
	;
	F nArg=supArg+1:1:maxArg I '(actual(nArg)="") D ERROR^UCGM("method does not support missing parameters: "_method) Q 
	I ER'=0 Q 
	;
	S return="$"_method_"("_objectName
	;
	F nArg=1:1:supArg S return=return_","_actual(nArg)
	S return=return_")"
	;
	I isLit D
	.	N newret
	.	;   #ACCEPT PGM=FSCW; DATE=2004-11-17; CR=11439;GROUP=XECUTE
	.	XECUTE "set newret="_return
	.	I $L(newret)>511 Q 
	.	I (newret=+newret) S return=+newret
	.	E  S return=$S(newret'["""":""""_newret_"""",1:$$QADD^%ZS(newret,""""))
	.	Q 
	Q 
	;
toVal(expr,def)	;
	I (expr=+expr) Q +expr
	;
	;  #ACCEPT CR=11441; PGM=FSCW; DATE=2004-11-17; GROUP=XECUTE
	I $$isStr^UCGM(expr) XECUTE "set def="_expr
	;
	Q def
	;
vSIG()	;
	Q "60528^29024^Frans S.C. Witte^9687" ; Signature - LTD^TIME^USER^SIZE
	;
vOpen1()	;	CLASS,SUPERTYPE FROM OBJECT WHERE ISPRIMITIVE = 1
	;
	;
	S vos1=2
	D vL1a1
	Q ""
	;
vL1a0	S vos1=0 Q
vL1a1	S vos2=""
vL1a2	S vos2=$O(^OBJECT(vos2),1) I vos2="" G vL1a0
	S vos3=$G(^OBJECT(vos2))
	I '(+$P(vos3,"|",6)=1) G vL1a2
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
	S rs=$S(vos2=$C(254):"",1:vos2)_$C(9)_$P(vos3,"|",1)
	;
	Q 1
