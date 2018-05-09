UCOBJECT	;
	;
	; **** Routine compiled from DATA-QWIK Procedure UCOBJECT ****
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
data()	; method Object.data; returns Number
	;
	S return="$D("_objectVar_")"
	;
	N varTyp S varTyp=$$objPtr^UCGM(objectVar)
	N varLev S varLev=$$getLevel^UCGM(objectVar)
	N nxtTyp S nxtTyp=$order(type(varLev,varTyp))
	;
	N bArr S bArr=($piece(varTyp,"(")=$piece(nxtTyp,"("))
	I bArr,varTyp["(" D
	.	S varTyp=$E(varTyp,1,$L(varTyp)-1)
	.	S bArr=($E(nxtTyp,1,$L(varTyp))=varTyp)
	.	Q 
	I 'bArr D WARNDEP^UCGM(objectVar_".data()")
	;
	I $$getOpti^UCGM(objectVar,objectLevel)>msrc D setOpti^UCGM(objectVar,objectLevel,0)
	Q 
	;
exists	; method Object.exists; returns boolean
	;
	S return="($D("_objectVar_")#2)"
	;set PSL.return=PSL.mExpr("'($G("_PSL.objectName_").isNull())")
	;
	; if object optimization was turned off for this line, turn it back on
	I $$getOpti^UCGM(objectVar,objectLevel)>msrc D setOpti^UCGM(objectVar,objectLevel,0)
	Q 
	;
getClass	; method Object.getClass; returns string
	;
	N class S class=$$getClass^UCGM(objectName,objectLevel)
	;
	I $$isRecord^UCGM(class) D
	.	D setOpti^UCGM(objectName,objectLevel,1)
	.	S return="$G("_oLvn_"(+$G("_objectName_"),-1))"
	.	Q 
	E  D
	.	S return=$S(class'["""":""""_class_"""",1:$$QADD^%ZS(class,""""))
	.	Q 
	;
	Q 
	;
isPrim	; method Object.isPrimitive()
	;
	N class S class=$$getClass^UCGM(objectName,objectLevel)
	;
	S return=$$primDes^UCPRIM(class)>0
	Q 
	;
vSIG()	;
	Q "60383^25794^Frans S.C. Witte^6012" ; Signature - LTD^TIME^USER^SIZE
