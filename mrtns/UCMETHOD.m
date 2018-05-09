	; I18N=QUIT
	;
	; **** Routine compiled from DATA-QWIK Procedure UCMETHOD ****
	;
	; 09/10/2007 17:31 - chenardp
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
	; ---------------------------------------------------------------------
cmdsRest(cmdsRest)	; array to restore commands() from
	;
	;  #ACCEPT DATE=11/02/04;CR=11445;PGM=FSCW
	;*** Start of code by-passed by compiler
	KILL commands("WARN"),commands("OPTIMIZE")
	MERGE commands("WARN")=cmdsRest("WARN")
	MERGE commands("OPTIMIZE")=cmdsRest("OPTIMIZE")
	;*** End of code by-passed by compiler ***
	;
	Q 
	;
	; ---------------------------------------------------------------------
cmdsSave(cmdsSave)	; array in which commands() is to be saved
	;
	;  #ACCEPT DATE=11/02/04;CR=11445;PGM=FSCW
	;*** Start of code by-passed by compiler
	MERGE cmdsSave("WARN")=commands("WARN")
	MERGE cmdsSave("OPTIMIZE")=commands("OPTIMIZE")
	KILL commands("WARN"),commands("OPTIMIZE")
	;*** End of code by-passed by compiler ***
	;
	S commands("OPTIMIZE","OBJECTS")=$get(cmdsSave("OPTIMIZE","OBJECTS"))
	;
	S commands("OPTIMIZE","FUNCTIONS")=0
	;
	Q 
	;
	; ---------------------------------------------------------------------
INSERT(object,subRou,resCls)	;
	;
	;type public Primitive commands(,)
	;
	N decl
	N savCmds
	;type Boolean savResCl = commands( "Options", "ResultClass").get( false)
	N mtdResCl S mtdResCl='(($get(resCls)=""))
	;
	I (subRou="") D ERROR^UCGM("Subroutine name required") Q 
	;
	I ($D(labels(subRou))#2) Q  ; insert only once
	I mtdResCl S decl=resCls_" "_subRou_vobj(object,1)
	E  S decl=subRou_vobj(object,1)
	S labels(subRou)=$$fromSubrou^UCPSLLR(decl,0,mtdResCl)
	;set labels(subRou).comment = vobj( object, -2)
	;
	;type String l1,l2
	;for l1="WARN","OPTIMIZE" do {
	; set savCmds(l1) = ""
	; set l2 = ""
	; for  set l2 = commands(l1,l2).order() quit:l2=""  if commands(l1,l2) set savCmds(l1) = savCmds(l1).add(l2)
	;}
	;
	D addM2src^UCGM(" // ----------------")
	D addM2src^UCGM(" #OPTION ResultClass "_mtdResCl)
	D addM2src^UCGM(decl) ; Insert declaration
	D addM2src^UCGM(" //")
	D addM2src^UCGM(" #WARN "_$$allWARN^UCGMC()_" OFF")
	D addM2src^UCGM(" #OPTIMIZE FUNCTIONS OFF")
	;
	N ln S ln=1
	;
	F  S ln=$order(vobj(object,ln)) Q:(ln="")  D addM2src^UCGM(vobj(object,ln))
	;
	;do addM2src^UCGM(" #OPTION ResultClass "_ savResCl)
	;for l1="WARN","OPTIMIZE" if 'savCmds(l1).isNull() do addM2src^UCGM( " #"_l1_ " "_ savCmds(l1)_ " ON")
	;
	Q 
	;
	; ---------------------------------------------------------------------
insMet(prefix,missing)	;
	S return=prefix_objectName_","
	N ap
	;
	F ap=1:1:$order(actual(""),-1) D
	.	I missing=-1,(actual(ap)="") S $ZS="-1,"_$ZPOS_","_"%PSL-E-MISSING, missing required argument (#"_ap_")" X $ZT
	.	I missing=1,(actual(ap)="") S actual(ap)=""""""
	.	I ap>1 S return=return_","
	.	S return=return_actual(ap)
	.	Q 
	S return=return_")"
	Q 
	;
	; ---------------------------------------------------------------------
statMet(prefix,missing)	;
	S return=prefix
	N ap
	;
	F ap=1:1:$order(actual(""),-1) D
	.	I missing=-1,(actual(ap)="") S $ZS="-1,"_$ZPOS_","_"%PSL-E-MISSING, missing required argument (#"_ap_")" X $ZT
	.	I missing=1,(actual(ap)="") S actual(ap)=""""""
	.	I ap>1 S return=return_","
	.	S return=return_actual(ap)
	.	Q 
	S return=return_")"
	Q 
	;
	; ---------------------------------------------------------------------
stdCall(prefix,aplist)	;
	N ret S ret=prefix_aplist(1)
	N ap
	;
	F ap=1:1:$order(ap(""),-1) S ret=ret_","_aplist(ap)
	Q ret_")"
	;
	; ---------------------------------------------------------------------
addSubr	; Method: PSL.addSubrou - Add a subroutine
	;
	I '$D(labels("vaddSubr")) D
	.	;
	.	N buf S buf=$$vopenBuf("(String p1,String p2,String p3,Boolean p4)","PSL.addSubrou")
	.	;
	.	D vaddBuff(buf,"type Public PSLLabelRecord labels()")
	.	D vaddBuff(buf,"if p4.get() set p1=$$newLabel^UCGM(p1,.labels)")
	.	D vaddBuff(buf,"else  if labels(p1).exists() do PSL.error(""Subroutine exists: ""_p1) quit p1")
	.	D vaddBuff(buf,"do addSubr^UCGM(p1,p2,p3)")
	.	D vaddBuff(buf,"quit p1")
	.	;
	.	D INSERT^UCMETHOD(buf,"vaddSubr","")
	.	K vobj(+$G(buf)) Q 
	;
	; ensure that a call with 4 parameters is generated
	I (actual(2)="") S actual(2)=""""""
	I (actual(3)="") S actual(3)=""""""
	I (""""""[actual(4)) S actual(4)=0
	;
	S return="$$"_"vaddSubr"_"("_actual(1)_","_actual(2)_","_actual(3)_","_actual(4)_")"
	Q 
	;
	; ---------------------------------------------------------------------
arrayProp	; Method PSL.actual - "array property" actual()
	;
	S return=method_"("_actual(1)_")"
	Q 
	;
	; ---------------------------------------------------------------------
caPslCln	; void
	I (actual(3)="") S return="$$caPslCln^UCXDD("_actual(1)_","_actual(2)_")"
	E  S return="$$caPslCln^UCXDD("_actual(1)_","_actual(2)_","_actual(3)_")"
	Q 
	;
	; ---------------------------------------------------------------------
caPslTbl	; void
	I (actual(3)="") S actual(3)=0
	S return="$$caPslTbl^UCXDD("_actual(1)_","_actual(2)_","_actual(3)_")"
	Q 
	;
	; ---------------------------------------------------------------------
error	; Method: PSL.error - Report a compile-time error
	;
	S return="ERROR^UCGM("_actual(1)_")"
	Q 
	;
	; ---------------------------------------------------------------------
getDbLoad	; PSL.getDbLoad - Return dbLoad record map
	;
	S return="$G(dbLoad("_actual(1)_","_actual(2)_","_actual(3)_"))"
	Q 
	;
	; ---------------------------------------------------------------------
getLabel	; PSL.getLabelRecord - Return label record
	;
	S return="$G(labels("_actual(1)_"))"
	Q 
	;
	; ---------------------------------------------------------------------
getPslCln	; void
	I (actual(3)="") S return="$$getPslCln^UCXDD("_actual(1)_","_actual(2)_")"
	E  D
	.	I $E(actual(3),1)'="." S actual(3)="."_actual(3)
	.	S return="$$getPslCln^UCXDD("_actual(1)_","_actual(2)_","_actual(3)_")"
	.	Q 
	Q 
	;
	; ---------------------------------------------------------------------
getPslTbl	; void
	I (actual(2)="") S actual(2)=1
	S return="$$getPslTbl^UCXDD("_actual(1)_","_actual(2)_")"
	Q 
	;
	; ---------------------------------------------------------------------
getPslValue(default)	; default value (*1)
	;
	I $get(commands("boot","restrictionlevel"))>1 S return=default
	E  S return=$$getPslValue^UCOPTS(ref) I (return="") S return=default
	Q 
	;
	; ---------------------------------------------------------------------
getProp	; Property procedure of class PSL
	;
	I $$getNew^UCGM(ref) D ERROR^UCGM("Object scope is not visible: PSL."_ref) Q 
	;
	S return=ref
	;
	I ref="objectName"!(ref="var") S class="PSLIdentifier"
	E  I ref="return" S class="PSLExpression"
	E  S class="String"
	;
	Q 
	;
	; ---------------------------------------------------------------------
insLine	; PSL.insertLine(PSLcode,line,level)
	; Convert a line of PSL code to M code and insert into program
	; after first comment free line after parameter line.
	;
	N p2 S p2=actual(2)
	I p2="line",'($E(p2,1)=".") S p2="."_p2
	;
	S return="newLine^UCGM("_actual(1)_","_p2_","_actual(3)_")"
	Q 
	;
	; ---------------------------------------------------------------------
isRecord	; PSL.isRecord(String class)
	;
	S return="$$isRecord^UCGM("_actual(1)_")"
	Q 
	;
	; ---------------------------------------------------------------------
isSubr	; Method: PSL.subrExists - Return whether a subroutine exists
	;
	S return="$D(labels("_actual(1)_"))"
	Q 
	;
	; ---------------------------------------------------------------------
mExpr	; PSL.mExpr(expr)
	;
	I '$D(labels("vMExpr")) D
	.	;
	.	N buf S buf=$$vopenBuf("(String v1)","PSL.mExpr")
	.	;
	.	D vaddBuff(buf,"type public Primitive commands(,)")
	.	D vaddBuff(buf,"type String vExp,mcode,tok") ; 'tok' and 'mcode' used as public var by $$valExpr !!!!
	.	D vaddBuff(buf,"type Boolean vFun=commands(""OPTIMIZE"",""FUNCTIONS"").get(0)")
	.	D vaddBuff(buf,"set commands(""OPTIMIZE"",""FUNCTIONS"")=0")
	.	D vaddBuff(buf,"set mcode="""",v1=$$TOKEN^%ZS(v1,.tok),vExp=$$valExpr^UCGM(v1,,0)")
	.	D vaddBuff(buf,"set commands(""OPTIMIZE"",""FUNCTIONS"")=vFun")
	.	D vaddBuff(buf,"quit vExp")
	.	;
	.	D INSERT^UCMETHOD(buf,"vMExpr","")
	.	K vobj(+$G(buf)) Q 
	;
	S return="$$"_"vMExpr"_"("_actual(1)_")"
	;
	Q 
	;
	; ---------------------------------------------------------------------
newVar	; PSL.newVariable
	;
	S return="$$nxtSym^UCGM"
	Q 
	;
	; ---------------------------------------------------------------------
patch	; PSL.patch(String expression) - Replace expression with
	;
	S return="$$patch^UCPATCH(subRou,objectName,objectLevel,"_actual(1)_")"
	Q 
	;
	; ---------------------------------------------------------------------
warn	; Method PSL.warn - Report a compile-time warning
	;
	S return="WARN^UCGM("_actual(1)_")"
	Q 
	;
	; ---------------------------------------------------------------------
openBuff	; Method: PSL.openBuffer - Open a PSL code buffer
	;
	I '$D(labels("vopenBuf")) D
	.	;
	.	N buf S buf=$$vopenBuf("(List v1,String v2)","PSL.openBuffer")
	.	;
	.	D vaddBuff(buf,"type Public String vobj(,)")
	.	D vaddBuff(buf,"type Number vOid")
	.	D vaddBuff(buf,"set vOid=vobj("""").order(-1)+1")
	.	D vaddBuff(buf,"if v1.extract()'=""("",'v1.isNull() set v1=""(""_v1_"")""")
	.	D vaddBuff(buf,"set vobj(vOid,-1)=v1")
	.	D vaddBuff(buf,"set vobj(vOid,-2)=v2")
	.	D vaddBuff(buf,"set vobj(vOid,1)=v1_"" // ""_v2")
	.	D vaddBuff(buf,"quit vOid")
	.	;
	.	D INSERT^UCMETHOD(buf,"vopenBuf","")
	.	K vobj(+$G(buf)) Q 
	;
	S return="$$"_"vopenBuf"_"("_actual(1)_","_actual(2)_")"
	;
	Q 
	;
	; ---------------------------------------------------------------------
addBuff	; Method: PSLBuffer.add - Add code to an existing buffer
	;
	I '$D(labels("vaddBuff")) D
	.	;
	.	N buf S buf=$$vopenBuf("(Number object,String p1)","PSLBuffer.add")
	.	;
	.	D vaddBuff(buf,"type Public String vobj(,)")
	.	D vaddBuff(buf,"type Number line")
	.	D vaddBuff(buf,"set line=vobj(object,"""").order(-1)+1")
	.	D vaddBuff(buf,"set vobj(object,line)="" ""_p1")
	.	D vaddBuff(buf,"quit")
	.	;
	.	D INSERT^UCMETHOD(buf,"vaddBuff","")
	.	K vobj(+$G(buf)) Q 
	;
	S return="vaddBuff"_"("_objectName_","_actual(1)_")"
	;
	Q 
	;
	; ---------------------------------------------------------------------
	;
	; ---------------------------------------------------------------------
getPcClass	; Method: PSLColumn.getClass()
	;
	S return="$$getClass^UCXDD("_objectName_")"
	Q 
	;
	; ---------------------------------------------------------------------
getCurExpr	; Method: PSLColumn.getCurrentExpr(PSLIdentifier,Boolean)
	;
	I (actual(2)="") S actual(2)=0
	S return="$$getCurExpr^UCXDD("_objectName_","_actual(1)_","_actual(2)_")"
	Q 
	;
	; ---------------------------------------------------------------------
getCurLvn	; Method: PSLColumn.getCurrentLvn(PSLIdentifier)
	;
	S return="$$getCurLvn^UCXDD("_objectName_","_actual(1)_")"
	Q 
	;
	; ---------------------------------------------------------------------
getCurNode	; Method: PSLColumn.getCurrentNode(Boolean)
	;
	I (""""""[actual(1)) S actual(1)=0
	S return="$$getCurNode^UCXDD("_objectName_","_actual(1)_")"
	Q 
	;
	; ---------------------------------------------------------------------
getOldExpr	; Method: PSLColumn.getOldExpr(PSLIdentifier,Boolean)
	;
	I (actual(2)="") S actual(2)=0
	S return="$$getOldExpr^UCXDD("_objectName_","_actual(1)_","_actual(2)_")"
	Q 
	;
	; ---------------------------------------------------------------------
getOldLvn	; Method: PSLColumn.getOldLvn(PSLIdentifier)
	;
	S return="$$getOldLvn^UCXDD("_objectName_","_actual(1)_")"
	Q 
	;
	; ---------------------------------------------------------------------
getOldNode	; Method: PSLColumn.getOldNode(Boolean)
	;
	I (""""""[actual(1)) S actual(1)=0
	S return="$$getOldNode^UCXDD("_objectName_","_actual(1)_")"
	Q 
	;
	; ---------------------------------------------------------------------
getPurNode	; Method: PSLColumn.getPurposeNode()
	;
	S return="$$getPurNode^UCXDD("_objectName_")"
	Q 
	;
	; ---------------------------------------------------------------------
getUpdCode	; Method: PSLColumn.getUpdateCode(PSLIdent,PSLExpr,Bool)
	;
	I (actual(3)="") S actual(3)=1
	S return="$$getUpdCode^UCXDD("_objectName_","_actual(1)_","_actual(2)_","_actual(3)_")"
	Q 
	;
	; ---------------------------------------------------------------------
fitsLinLen	; Method: PSLExpression.fitsLineLength( Number extra)
	N xtr
	N pop S pop=1
	;
	I (""""""[actual(1)) S xtr=""
	E  I actual(1)=0 S xtr=""
	E  D
	.	S xtr=$$tokenPush^UCPATCH(actual(1),"Number") S pop=2
	.	I $translate(actual(1),"*/\#")=actual(1) S xtr="+"_xtr Q 
	.	S xtr="+("_xtr_")"
	.	Q 
	;
	S return=$$tokenPop^UCPATCH($$vMExpr("(("_$$tokenPush^UCPATCH(objectName,"PSLExpression")_").toByteString().length() "_xtr_"'> PSL.maxLineLength)"),pop)
	Q 
	;
	; ---------------------------------------------------------------------
isArr	; Method: PSLExpression.isArray
	;
	S return="$$isArr^UCGM("_objectName_")"
	Q 
	;
	; ---------------------------------------------------------------------
isLit	; Method: PSLExpression.isLiteral
	;
	S return="$$isLit^UCGM("_objectName_")"
	Q 
	;
	; ---------------------------------------------------------------------
isVar	; Method: PSLExpression.isVariable
	;
	S return="$$isVar^UCGM("_objectName_")"
	Q 
	;
	; ---------------------------------------------------------------------
toConsta	; Method PSLExpression.toValue
	;
	S return="$$toLit^UCGM("_objectName_")"
	Q 
	;
	; ---------------------------------------------------------------------
getSym(pos)	; PSLIdentifier properties
	;
	I fset D ERROR^UCGM("Identifier table properties are read only")
	;
	N keys S keys=objectName
	I ($E(keys,1,2)="vo") S keys=$$getExpr^UCGM(keys)
	;
	I keys="objectName" S keys="objectName,objectLevel"
	E  I keys="var" S keys="var,varLevel"
	E  S keys=keys_","
	;
	S return="$$getAtt^UCGM("_keys_","_pos_")"
	;
	Q 
	;
	; ---------------------------------------------------------------------
getLevel	; PSLIdentifier.scopeLevel property
	;
	N var S var=objectName
	I ($E(var,1,2)="vo") S var=$$getExpr^UCGM(var)
	;
	S return="$$getLevel^UCGM("_var_")"
	Q 
	;
	; ---------------------------------------------------------------------
opti	; Method: PSLIdentifier.allowOptimize - Allow backfill optimize
	;
	I '$D(labels("vPSLopti")) D
	.	;
	.	N buf S buf=$$vopenBuf("(PSLIdentifier var)","PSLIdentifier.allowOPtimize")
	.	;
	.	D vaddBuff(buf,"type Number varLevel=var.scopeLevel")
	.	D vaddBuff(buf,"type Number opti=var.noPatch")
	.	D vaddBuff(buf,"if opti>PSL.msrc set opti=0 do setOpti^UCGM(var,varLevel,0)")
	.	D vaddBuff(buf,"quit 'opti")
	.	;
	.	D INSERT^UCMETHOD(buf,"vPSLopti","")
	.	K vobj(+$G(buf)) Q 
	;
	S return="$$"_"vPSLopti"_"("_$$getExpr^UCGM(objectName)_")"
	Q 
	;
	; ---------------------------------------------------------------------
addCode	; Method: PSLSubroutine.addCode - add a line of code
	;
	S return="addCode^UCPSLSR("_objectName_","_actual(1)_")"
	Q 
	;
	; ---------------------------------------------------------------------
addExe	; Method: PSLSubroutine.addExe - add a line from exe() to code
	;
	S return="addExe^UCPSLSR("_objectName_","_actual(1)_")"
	Q 
	;
	; ---------------------------------------------------------------------
addLvn	; Method: PSLSubroutine.addLvn - add vsql() replacement
	;
	S mcode=$$backup^UCGM(mcode)
	S return=" S"_postCond_" append("_objectName_",-3,"_actual(1)_")="_actual(2)
	Q 
	;
	; ---------------------------------------------------------------------
addTag	; Method: PSLSubroutine.addTag - add tag to append(,-2)
	;
	S mcode=$$backup^UCGM(mcode)
	I (actual(2)="") S actual(2)=""""""
	S return=" S"_postCond_" append("_objectName_",-2,"_actual(1)_")="_actual(2)
	Q 
	;
	; ---------------------------------------------------------------------
getCode	; Method: PSLSubroutine.getCode - return the code on a line
	;
	S return="$G(append("_objectName_","_actual(1)_"))"
	Q 
	;
	; ---------------------------------------------------------------------
getLine	; Method: PSLSubroutine.getline - return the current line
	;
	S return="$O(append("_objectName_",""""),-1)"
	Q 
	;
	; ---------------------------------------------------------------------
getLvn	; Method: PSLSubroutine.getLvn - return vsql() substitution value
	;
	S return="$G(append("_objectName_",-3,"_actual(1)_"))"
	Q 
	;
	; ---------------------------------------------------------------------
getLvnMax	; Method: PSLSubroutine.getLvnMax - highest number used
	;
	S return="+$O(append("_objectName_",-3,""""),-1)"
	Q 
	;
	; ---------------------------------------------------------------------
getTag	; Method: PSLSubroutine.getTag - return the tag for exe(nr)
	;
	S return="$$getTag^UCPSLSR("_objectName_","_actual(1)_")"
	Q 
	;
	; ---------------------------------------------------------------------
getTagMax	; Method: PSLSubroutine.getTagMax - highest TAG number used
	;
	S return="+$O(append("_objectName_",-2,""""),-1)"
	Q 
	;
	; ---------------------------------------------------------------------
getTagPrefix	; Method: PSLSubroutine.getTagPrefix - prefix used by addExe()
	;
	S return="$G(append("_objectName_",-2))"
	Q 
	;
	; ---------------------------------------------------------------------
insCode	; Method: PSLSubroutine.insCode - Insert code at line
	;
	S mcode=$$backup^UCGM(mcode)
	S return=" S"_postCond_" append("_objectName_","_actual(1)_")="_actual(2)
	Q 
	;
	; ---------------------------------------------------------------------
setTagPrefix	; Method: PSLSubroutine.getTagPrefix - prefix used by addExe()
	;
	S mcode=$$backup^UCGM(mcode)
	S return=" S"_postCond_" append("_objectName_",-2)="_actual(1)
	Q 
	;
	; ---------------------------------------------------------------------
tAssert	; Method: PSLTable.assertLevel(Number,PSLColumn())
	;
	I (actual(1)="") S actual(1)=1
	I (actual(2)="") S return="$$tAssert^UCXDD("_objectName_","_actual(1)_")"
	E  S return="$$tAssert^UCXDD("_objectName_","_actual(1)_","_actual(2)_")"
	Q 
	;
	; ---------------------------------------------------------------------
getArchivable	;Method: PSLTable.getArchivable()
	;
	S return="$$getArchivable^DBARCHIVE("_objectName_")"
	Q 
	;
	; ---------------------------------------------------------------------
getArchiveIncluded	;Method: PSLTable.getArchiveIncluded()
	;
	S return="$$getArchiveIncluded^DBARCHIVE("_objectName_")"
	Q 
	;
	; ---------------------------------------------------------------------
getArchiveKey	;Method: PSLTable.getArchiveKey(Boolean)
	;
	I (actual(1)="") S actual(1)=0
	S return="$$getArchiveKey^DBARCHIVE("_objectName_","_actual(1)_")"
	Q 
	;
	; ---------------------------------------------------------------------
getArchiveSubs	;Method: PSLTable.getArchiveSubs()
	;
	S return="$$getArchiveSubs^DBARCHIVE("_objectName_")"
	Q 
	;
	; ---------------------------------------------------------------------
getArchiveTable	;Method: PSLTable.getArchiveTable()
	;
	S return="$$getArchiveTable^DBARCHIVE("_objectName_")"
	Q 
	;
	; ---------------------------------------------------------------------
getFlrLgc	; Method: PSLTable.getFilerLogic(String,Boolean())
	;
	I (actual(3)="") S actual(3)=0
	S return="$$getFlrLgc^UCXDD("_objectName_","_actual(1)_","_actual(2)_","_actual(3)_")"
	Q 
	;
	; ---------------------------------------------------------------------
getLodCode	; Method: PSLTable.getLoadCode()
	;
	S return="$$getLodCode^UCXDD("_objectName_","_actual(1)_","_actual(2)
	S return=return_","_actual(3)_","_actual(4)
	I '(actual(5)="") S return=return_","_actual(5)
	S return=return_")"
	Q 
	;
	; ---------------------------------------------------------------------
getNewCode	; Method: PSLTable.getNewCode(PSLIdentifier,PSLExpression)
	;
	S return="$$getNewCode^UCXDD("_objectName_","_actual(1)_","_actual(2)_")"
	Q 
	;
	; ---------------------------------------------------------------------
getQuery	; Method: PSLTable.getQuery()
	;
	S return="$$getQuery^UCXDD("_objectName_")"
	Q 
	;
	; ---------------------------------------------------------------------
getSavCode	; Method: PSLTable.getSaveCode()
	;
	S return="$$getSavCode^UCXDD("_objectName_","_actual(1)
	S return=return_","_actual(2)_","_actual(3)
	;if 'PSL.actual(4).isNull() set PSL.return = PSL.return_","_ PSL.actual(4)
	I '(actual(4)="")!'(actual(5)="") S return=return_","_actual(4)
	I '(actual(5)="") S return=return_","_actual(5)
	S return=return_")"
	Q 
	;
	; ---------------------------------------------------------------------
getUpdKey	; Method: PSLTable.getUpdateKey(PSLIdentifier,String())
	;
	S return="$$getUpdKey^UCXDD("_objectName_","_actual(1)
	I '(actual(2)="") S return=return_","_actual(2)
	S return=return_")"
	Q 
	;
	; ---------------------------------------------------------------------
isParent	; Method: PSLTable.isParent()
	;
	S return="$$isParent^UCXDD("_objectName_")"
	Q 
	;
	; ---------------------------------------------------------------------
isOneNode	;Method: PSLTable.isOneNode()
	;
	S return="$$isOneNode^UCXDD("_objectName_")"
	Q 
	;
	; ---------------------------------------------------------------------
tblHasBlob	; property PSLTable.hasBlob: Return 1 if table has Blob
	;
	S return=$$tokenPop^UCPATCH($$vMExpr("("_$$tokenPush^UCPATCH(objectName,"PSLTable")_".dataTypes[""B"")"),1)
	Q 
	;
	; ---------------------------------------------------------------------
tblHasMemo	; property PSLTable.hasMemo: Return 1 if table has Memo
	;
	S return=$$tokenPop^UCPATCH($$vMExpr("("_$$tokenPush^UCPATCH(objectName,"PSLTable")_".dataTypes[""M"")"),1)
	Q 
	;
	; ---------------------------------------------------------------------
tblHasNeg	; property PSLTable.hasNegativeNode: Return 1 if table has node with negative subscript
	;
	S return=$$tokenPop^UCPATCH($$vMExpr("("",""_"_$$tokenPush^UCPATCH(objectName,"PSLTable")_".nodeQuotedList["",""""v"")"),1)
	Q 
	;
	; ---------------------------------------------------------------------
tblIsRdb	; property PSLTable.isRdb: 1 if table stored in RDB
	;
	S return=$$tokenPop^UCPATCH($$vMExpr("("_$$tokenPush^UCPATCH(objectName,"PSLTable")_".database'="""_"GTM"_""")"),1)
	Q 
	;
	; ---------------------------------------------------------------------
tblHasMasf	; property PSLTable.hasMasterfield: Return 1 table has Masterfields
	;
	S return=$$tokenPop^UCPATCH($$vMExpr("'"_$$tokenPush^UCPATCH(objectName,"PSLTable")_".masterfieldList.isNull()"),1)
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vopenBuf(v1,v2)	; PSL.openBuffer
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vOid
	S vOid=$order(vobj(""),-1)+1
	I $E(v1,1)'="(",'(v1="") S v1="("_v1_")"
	S vobj(vOid,-1)=v1
	S vobj(vOid,-2)=v2
	S vobj(vOid,1)=v1_" // "_v2
	Q vOid
	; ----------------
	;  #OPTION ResultClass 0
vaddBuff(object,p1)	; PSLBuffer.add
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N line
	S line=$order(vobj(object,""),-1)+1
	S vobj(object,line)=" "_p1
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vMExpr(v1)	; PSL.mExpr
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vExp N mcode N tok
	N vFun S vFun=$get(commands("OPTIMIZE","FUNCTIONS"),0)
	S commands("OPTIMIZE","FUNCTIONS")=0
	S mcode="" S v1=$$TOKEN^%ZS(v1,.tok) S vExp=$$valExpr^UCGM(v1,,0)
	S commands("OPTIMIZE","FUNCTIONS")=vFun
	Q vExp
