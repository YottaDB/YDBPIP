 ; 
 ; **** Routine compiled from DATA-QWIK Procedure UCMETHOD ****
 ; 
 ; 02/24/2010 18:23 - pip
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
 ;
 ; ---------------------------------------------------------------------
INSERT(object,subRou,resCls) ; ResultClass (*3)
  ; temporary use of append()
  ; temporary use of pslPrsr(,)
 ;
 N decl
 N mtdResCl S mtdResCl='($get(resCls)="")
 N ocd S ocd=$$getPSLClass^PSLCC(.pslPrsr,pslPrsr("moduleName"))
 ;
 I (subRou="") D ERROR^UCGM("Subroutine name required") Q 
 ;
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 I $$hasSubr^UCGM(subRou) Q  ; insert only once
 I mtdResCl S decl=resCls_" "_subRou_vobj(object,1)
 E  S decl=subRou_vobj(object,1)
 I $P(ocd,$C(9),5)>-1 S:'mtdResCl decl="String "_decl S decl="static "_decl
 ;
 S append(subRou)=0_$char(9)_vobj(object,-2)
 ;
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 D addM2src^UCGM(" // ----------------")
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 D addM2src^UCGM(" #OPTION ResultClass "_mtdResCl)
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 D addM2src^UCGM(decl) ; Insert declaration
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 D addM2src^UCGM(" //")
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 D addM2src^UCGM(" #WARN "_$$allWARN^UCGMC()_" OFF")
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 D addM2src^UCGM(" #OPTIMIZE FUNCTIONS OFF")
 ;
 N ln S ln=1
 ;
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 F  S ln=$order(vobj(object,ln)) Q:(ln="")  D addM2src^UCGM(vobj(object,ln))
 ;
 Q 
 ;
 ; ---------------------------------------------------------------------
insMet(prefix,missing) ; 
 S return=prefix_objectName_","
 N ap
 ;
 F ap=1:1:$order(actual(""),-1) D
 .	I missing=-1,(actual(ap)="") S $ZE="0,"_$ZPOS_","_"%PSL-E-MISSING, missing required argument (#"_ap_")",$EC=",U1001,"
 .	I missing=1,(actual(ap)="") S actual(ap)=""""""
 .	I ap>1 S return=return_","
 .	S return=return_actual(ap)
 .	Q 
 S return=$$RTCHR^%ZFUNC(return,",")_")"
 Q 
 ;
 ; ---------------------------------------------------------------------
statMet(prefix,missing) ; 
 S return=prefix
 N ap
 ;
 F ap=1:1:$order(actual(""),-1) D
 .	I missing=-1,(actual(ap)="") S $ZE="0,"_$ZPOS_","_"%PSL-E-MISSING, missing required argument (#"_ap_")",$EC=",U1001,"
 .	I missing=1,(actual(ap)="") S actual(ap)=""""""
 .	I ap>1 S return=return_","
 .	S return=return_actual(ap)
 .	Q 
 S return=return_")"
 Q 
 ;
 ; ---------------------------------------------------------------------
stdCall(prefix,aplist) ; 
 N ret S ret=prefix_aplist(1)
 N ap
 ;
 F ap=1:1:$order(ap(""),-1) S ret=ret_","_aplist(ap)
 Q ret_")"
 ;
 ; ---------------------------------------------------------------------
addSubr ; Method: PSL.addSubrou - Add a subroutine
 ;
 I '$$hasSubr^UCGM("vaddSubr") D
 .	;
 .	N buf S buf=$$vopenBuf("(String p1,String p2,String p3,Boolean p4)","PSL.addSubrou")
 .	;
 .	D vaddBuff(buf,"if p4.get() set:p1.extract()'=""v"" p1=""v""_p1 set p1=$$findSubr^UCGM(p1,"""")")
 .	D vaddBuff(buf,"else  if $$hasSubr^UCGM(p1) do PSL.error(""Subroutine exists: ""_p1) quit p1")
 .	D vaddBuff(buf,"do addSubr^UCGM(p1,p2,p3)")
 .	D vaddBuff(buf,"quit p1")
 .	;
 .	D INSERT^UCMETHOD(buf,"vaddSubr","PSLSubrou")
 .	K vobj(+$G(buf)) Q 
 ;
 ; ensure that a call with 4 parameters is generated
 I (actual(2)="") S actual(2)=""""""
 I (actual(3)="") S actual(3)=""""""
 I $$isNullOrLiteralNull^UCPRIM(actual(4)) S actual(4)=0
 ;
 S return="$$"_"vaddSubr"_"("_actual(1)_","_actual(2)_","_actual(3)_","_actual(4)_")"
 Q 
 ;
 ; ---------------------------------------------------------------------
arrayProp ; Method PSL.actual - "array property" actual()
 S return=method_"("_actual(1)_")"
 Q 
 ;
 ; ---------------------------------------------------------------------
caPslCln ; void
 I (actual(3)="") S return="$$caPslCln^UCXDD("_actual(1)_","_actual(2)_")"
 E  S return="$$caPslCln^UCXDD("_actual(1)_","_actual(2)_","_actual(3)_")"
 Q 
 ;
 ; ---------------------------------------------------------------------
caPslTbl ; void
 I (actual(3)="") S actual(3)=0
 S return="$$caPslTbl^UCXDD("_actual(1)_","_actual(2)_","_actual(3)_")"
 Q 
 ;
 ; ---------------------------------------------------------------------
checkAccessRights ; Method: PSLTable.checkAccessRights()
 ;
 S return="$$checkAccessRights^UCXDD("_objectName_","_actual(1)_")"
 Q 
 ;
 ; ---------------------------------------------------------------------
error ; Method: PSL.error - Report a compile-time error
 ;
 S return="ERROR^UCGM("_actual(1)_")"
 Q 
 ;
 ; ---------------------------------------------------------------------
getPslCln ; void
 I (actual(3)="") S return="$$getPslCln^UCXDD("_actual(1)_","_actual(2)_")"
 E  D
 .	I $E(actual(3),1)'="." S actual(3)="."_actual(3)
 .	S return="$$getPslCln^UCXDD("_actual(1)_","_actual(2)_","_actual(3)_")"
 .	Q 
 Q 
 ;
 ; ---------------------------------------------------------------------
getPslTbl ; void
 I (actual(2)="") S actual(2)=1
 S return="$$getPslTbl^UCXDD("_actual(1)_","_actual(2)_")"
 Q 
 ;
 ; ---------------------------------------------------------------------
getPslValue(default) ; default value (*1)
 ;
 I $$getSetting^PSLCC(.pslPrsr,"boot","restrictionlevel",0)>1 S return=default
 E  S return=$$getPslValue^UCOPTS(ref) I (return="") S return=default
 Q 
 ;
 ; ---------------------------------------------------------------------
getProp ; Property procedure of class PSL
 ;
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 I $$getNew^UCGM(ref) D ERROR^UCGM("Object scope is not visible: PSL."_ref) Q 
 ;
 ;  #ACCEPT GROUP=SCOPE,ACCESS;CR=27800;DATE=2007-09-04;PGM=Frans S.C. Witte
 I '(",actual,mcode,postCond,pslTmpLvn,return,fset,level,msrc,objectLevel,varLevel,objectName,objectVar,var,cmd,attrib,class,objectScope,mclass,method,oLvn,pslSt,ref,subRou,tok,"[(","_ref_",")) D warnGroup^UCGM("SCOPE","non-standard PSL property PSL."_ref)
 ;
 S return=ref
 ;
 I (",objectName,objectVar,var,"[(","_ref_",")) S class="PSLIdentifier"
 E  I (",actual,mcode,postCond,pslTmpLvn,return,"[(","_ref_",")) S class="PSLExpression"
 E  I (",fset,level,msrc,objectLevel,varLevel,"[(","_ref_",")) S class="Number"
 E  S class="String"
 ;
 Q 
 ;
 ; ---------------------------------------------------------------------
isSubr ; Method: PSL.subrExists - Return whether a subroutine exists
 ;
 S return="$$hasSubr^UCGM("_actual(1)_")"
 Q 
 ;
 ; ---------------------------------------------------------------------
mExpr ; PSL.mExpr(expr)
 ;
 I '$$hasSubr^UCGM("vMExpr") D
 .	;
 .	N buf S buf=$$vopenBuf("(String v1)","PSL.mExpr")
 .	;
 .	D vaddBuff(buf,"type String vExp,mcode,tok") ; 'tok' and 'mcode' used as public var by $$valExpr !!!!
 .	D vaddBuff(buf,"type Boolean vDep=PSL.getSetting(""WARN"",""DEPRECATED"",0)")
 .	D vaddBuff(buf,"type Boolean vMis=PSL.getSetting(""WARN"",""MISMATCH"",0)")
 .	D vaddBuff(buf,"type Boolean vFun=PSL.getSetting(""OPTIMIZE"",""FUNCTIONS"",0)")
 .	D vaddBuff(buf,"do PSL.addSetting(""WARN"",""DEPRECATED"",0)")
 .	D vaddBuff(buf,"do PSL.addSetting(""WARN"",""MISMATCH"",0)")
 .	D vaddBuff(buf,"do PSL.addSetting(""OPTIMIZE"",""FUNCTIONS"",0)")
 .	D vaddBuff(buf,"set mcode="""",v1=$$TOKEN^%ZS(v1,.tok),vExp=$$valExpr^UCGM(v1,,0)")
 .	D vaddBuff(buf,"do PSL.addSetting(""WARN"",""DEPRECATED"",vDep)")
 .	D vaddBuff(buf,"do PSL.addSetting(""WARN"",""MISMATCH"",vMis)")
 .	D vaddBuff(buf,"do PSL.addSetting(""OPTIMIZE"",""FUNCTIONS"",vFun)")
 .	D vaddBuff(buf,"quit vExp")
 .	;
 .	D INSERT^UCMETHOD(buf,"vMExpr","String")
 .	K vobj(+$G(buf)) Q 
 ;
 S return="$$"_"vMExpr"_"("_actual(1)_")"
 ;
 Q 
 ;
 ; ---------------------------------------------------------------------
newVar ; PSL.newVariable
 ;
 S return="$$nxtSym^UCGM"
 Q 
 ;
 ; ---------------------------------------------------------------------
patch ; PSL.patch(String expression) - Replace expression with
 ;
 S return="$$patch^UCPATCH(subRou,objectName,objectLevel,"_actual(1)_")"
 Q 
 ;
 ; ---------------------------------------------------------------------
warn ; Method PSL.warn - Report a compile-time warning
 ;
 S return="WARN^UCGM("_actual(1)_")"
 Q 
 ;
 ; ---------------------------------------------------------------------
openBuff ; Method: PSL.openBuffer - Open a PSL code buffer
 ;
 I '$$hasSubr^UCGM("vopenBuf") D
 .	;
 .	N buf S buf=$$vopenBuf("(String v1,String v2)","PSL.openBuffer")
 .	;
 .	D vaddBuff(buf,"type public String vobj(,)")
 .	D vaddBuff(buf,"type Number vOid")
 .	D vaddBuff(buf,$$cdNewObj^UCCLASS("vOid","""PSLBuffer"""))
 .	D vaddBuff(buf,"if v1.extract()'=""("",'v1.isNull() set v1=""(""_v1_"")""")
 .	D vaddBuff(buf,"set vobj(vOid,-2)=v1")
 .	D vaddBuff(buf,"set vobj(vOid,-3)=v2")
 .	D vaddBuff(buf,"set vobj(vOid,1)=v1_"" // ""_v2")
 .	D vaddBuff(buf,"quit vOid")
 .	;
 .	D INSERT^UCMETHOD(buf,"vopenBuf","PSLBuffer")
 .	K vobj(+$G(buf)) Q 
 ;
 S return="$$"_"vopenBuf"_"("_actual(1)_","_actual(2)_")"
 ;
 Q 
 ;
 ; ---------------------------------------------------------------------
addBuff ; Method: PSLBuffer.add - Add code to an existing buffer
 ;
 I '$$hasSubr^UCGM("vaddBuff") D
 .	;
 .	N buf S buf=$$vopenBuf("(Number object,String p1)","PSLBuffer.add")
 .	;
 .	D vaddBuff(buf,"type public String vobj(,)")
 .	D vaddBuff(buf,"type Number line")
 .	D vaddBuff(buf,"set line=vobj(object,"""").order(-1)+1")
 .	D vaddBuff(buf,"set vobj(object,line)="" ""_p1")
 .	D vaddBuff(buf,"quit")
 .	;
 .	D INSERT^UCMETHOD(buf,"vaddBuff","void")
 .	K vobj(+$G(buf)) Q 
 ;
 S return="vaddBuff"_"("_objectName_","_actual(1)_")"
 ;
 Q 
 ;
 ; ---------------------------------------------------------------------
getPcClass ; Method: PSLColumn.getClass()
 ;
 S return="$$getClass^UCXDD("_objectName_")"
 Q 
 ;
 ; ---------------------------------------------------------------------
getCurExpr ; Method: PSLColumn.getCurrentExpr(PSLIdentifier,Boolean)
 ;
 I (actual(2)="") S actual(2)=0
 S return="$$getCurExpr^UCXDD("_objectName_","_actual(1)_","_actual(2)_")"
 Q 
 ;
 ; ---------------------------------------------------------------------
getCurLvn ; Method: PSLColumn.getCurrentLvn(PSLIdentifier)
 ;
 S return="$$getCurLvn^UCXDD("_objectName_","_actual(1)_")"
 Q 
 ;
 ; ---------------------------------------------------------------------
getCurNode ; Method: PSLColumn.getCurrentNode(Boolean)
 ;
 I $$isNullOrLiteralNull^UCPRIM(actual(1)) S actual(1)=0
 S return="$$getCurNode^UCXDD("_objectName_","_actual(1)_")"
 Q 
 ;
 ; ---------------------------------------------------------------------
getOldExpr ; Method: PSLColumn.getOldExpr(PSLIdentifier,Boolean)
 ;
 I (actual(2)="") S actual(2)=0
 S return="$$getOldExpr^UCXDD("_objectName_","_actual(1)_","_actual(2)_")"
 Q 
 ;
 ; ---------------------------------------------------------------------
getOldLvn ; Method: PSLColumn.getOldLvn(PSLIdentifier)
 ;
 S return="$$getOldLvn^UCXDD("_objectName_","_actual(1)_")"
 Q 
 ;
 ; ---------------------------------------------------------------------
getOldNode ; Method: PSLColumn.getOldNode(Boolean)
 ;
 I $$isNullOrLiteralNull^UCPRIM(actual(1)) S actual(1)=0
 S return="$$getOldNode^UCXDD("_objectName_","_actual(1)_")"
 Q 
 ;
 ; ---------------------------------------------------------------------
getPurNode ; Method: PSLColumn.getPurposeNode()
 ;
 S return="$$getPurNode^UCXDD("_objectName_")"
 Q 
 ;
 ; ---------------------------------------------------------------------
getUpdCode ; Method: PSLColumn.getUpdateCode(PSLIdent,PSLExpr,Number,Number)
 ;
 I (actual(3)="") S actual(3)=1 ; default: PSL audit
 I (actual(4)="") S actual(4)=0 ; default: in-line update
 S return="$$getUpdCode^UCXDD("_objectName_","_actual(1)_","_actual(2)_","_actual(3)_","_actual(4)_")"
 Q 
 ;
 ; ---------------------------------------------------------------------
fitsLinLen ; Method: PSLExpression.fitsLineLength( Number extra)
 N xtr
 N pop S pop=1
 ;
 I $$isNullOrLiteralNull^UCPRIM(actual(1)) S xtr=""
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
isArr ; Method: PSLExpression.isArray
 ;
 S return="$$isArr^UCGM("_objectName_")"
 Q 
 ;
 ; ---------------------------------------------------------------------
isLit ; Method: PSLExpression.isLiteral
 ;
 S return="$$isLit^UCGM("_objectName_")"
 Q 
 ;
 ; ---------------------------------------------------------------------
isVar ; Method: PSLExpression.isVariable
 ;
 S return="$$isVar^UCGM("_objectName_")"
 Q 
 ;
 ; ---------------------------------------------------------------------
toConsta ; Method PSLExpression.toValue
 ;
 S return="$$toLit^UCGM("_objectName_")"
 Q 
 ;
 ; ---------------------------------------------------------------------
getSym(pos) ; PSLIdentifier properties
 I fset D ERROR^UCGM("Identifier table properties are read only")
 ;
 N keys S keys=objectName
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
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
getLevel ; PSLIdentifier.scopeLevel property
 ;
 N var S var=objectName
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 I ($E(var,1,2)="vo") S var=$$getExpr^UCGM(var)
 ;
 S return="$$getLevel^UCGM("_var_")"
 Q 
 ;
 ; ---------------------------------------------------------------------
opti ; Method: PSLIdentifier.allowOptimize - Allow backfill optimize
 ;
 I '$$hasSubr^UCGM("vPSLopti") D
 .	;
 .	N buf S buf=$$vopenBuf("(String var)","PSLIdentifier.optimize()")
 .	;
 .	D vaddBuff(buf,"type public Integer msrc")
 .	D vaddBuff(buf,"type Integer varLevel=$$getLevel^UCGM(var)")
 .	D vaddBuff(buf,"type Integer opti=+$$getAtt^UCGM(var,varLevel,10)")
 .	D vaddBuff(buf,"if opti>msrc set opti=0 do setOpti^UCGM(var,varLevel,0)")
 .	D vaddBuff(buf,"quit opti=0")
 .	;
 .	D INSERT^UCMETHOD(buf,"vPSLopti","Boolean")
 .	K vobj(+$G(buf)) Q 
 ;
 ;   #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 S return="$$"_"vPSLopti"_"("_objectName_")"
 Q 
 ;
 ; ---------------------------------------------------------------------
addCode ; Method: PSLSubroutine.addCode - add a line of code
 S return="addCode^UCPSLSR("_objectName_","_actual(1)_")"
 Q 
 ;
 ; ---------------------------------------------------------------------
addExe ; Method: PSLSubroutine.addExe - add a line from exe() to code
 S return="addExe^UCPSLSR("_objectName_","_actual(1)_")"
 Q 
 ;
 ; ---------------------------------------------------------------------
addLvn ; Method: PSLSubroutine.addLvn - add vsql() replacement
 ;
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 S mcode=$$backup^UCGM(mcode)
 S return=" S"_postCond_" append("_objectName_",-3,"_actual(1)_")="_actual(2)
 Q 
 ;
 ; ---------------------------------------------------------------------
addTag ; Method: PSLSubroutine.addTag - add tag to append(,-2)
 ;
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 S mcode=$$backup^UCGM(mcode)
 I (actual(2)="") S actual(2)=""""""
 S return=" S"_postCond_" append("_objectName_",-2,"_actual(1)_")="_actual(2)
 Q 
 ;
 ; ---------------------------------------------------------------------
getCode ; Method: PSLSubroutine.getCode - return the code on a line
 ;
 S return="$G(append("_objectName_","_actual(1)_"))"
 Q 
 ;
 ; ---------------------------------------------------------------------
getLine ; Method: PSLSubroutine.getline - return the current line
 ;
 S return="$O(append("_objectName_",""""),-1)"
 Q 
 ;
 ; ---------------------------------------------------------------------
getLogging ; Method: PSLTable.getLogging()
 ;
 S return="$$getLogging^UCXDD("_objectName_","_actual(1)_")"
 Q 
 ;
 ; ---------------------------------------------------------------------
getLvn ; Method: PSLSubroutine.getLvn - return vsql() substitution value
 ;
 S return="$G(append("_objectName_",-3,"_actual(1)_"))"
 Q 
 ;
 ; ---------------------------------------------------------------------
getLvnMax ; Method: PSLSubroutine.getLvnMax - highest number used
 ;
 S return="+$O(append("_objectName_",-3,""""),-1)"
 Q 
 ;
 ; ---------------------------------------------------------------------
getName ; Method: PSLSubroutine.getName - name of subroutine
 S return=objectName
 Q 
 ;
 ; ---------------------------------------------------------------------
getTag ; Method: PSLSubroutine.getTag - return the tag for exe(nr)
 S return="$$getTag^UCPSLSR("_objectName_","_actual(1)_")"
 Q 
 ;
 ; ---------------------------------------------------------------------
getTagMax ; Method: PSLSubroutine.getTagMax - highest TAG number used
 ;
 S return="+$O(append("_objectName_",-2,""""),-1)"
 Q 
 ;
 ; ---------------------------------------------------------------------
getTagPrefix ; Method: PSLSubroutine.getTagPrefix - prefix used by addExe()
 ;
 S return="$G(append("_objectName_",-2))"
 Q 
 ;
 ; ---------------------------------------------------------------------
insCode ; Method: PSLSubroutine.insCode - Insert code at line
 ;
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 S mcode=$$backup^UCGM(mcode)
 S return=" S"_postCond_" append("_objectName_","_actual(1)_")="_actual(2)
 Q 
 ;
 ; ---------------------------------------------------------------------
setTagPrefix ; Method: PSLSubroutine.getTagPrefix - prefix used by addExe()
 ;
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 S mcode=$$backup^UCGM(mcode)
 S return=" S"_postCond_" append("_objectName_",-2)="_actual(1)
 Q 
 ;
 ; ---------------------------------------------------------------------
tAssert ; Method: PSLTable.assertLevel(Number,PSLColumn())
 I (actual(1)="") S actual(1)=1
 I (actual(2)="") S return="$$tAssert^UCXDD("_objectName_","_actual(1)_")"
 E  S return="$$tAssert^UCXDD("_objectName_","_actual(1)_","_actual(2)_")"
 Q 
 ;
 ; ---------------------------------------------------------------------
getArchivable ; Method: PSLTable.getArchivable()
 ;
 I ($$getSetting^PSLCC(.pslPrsr,"boot","restrictionlevel","")=-1)!$$isRdb^vRuntime S return="0" Q 
 S return="$$getArchivable^DBARCHIVE("_objectName_")"
 Q 
 ;
 ; ---------------------------------------------------------------------
getArchiveIncluded ; Method: PSLTable.getArchiveIncluded()
 ;
 I ($$getSetting^PSLCC(.pslPrsr,"boot","restrictionlevel","")=-1)!$$isRdb^vRuntime S return="""""" Q 
 S return="$$getArchiveIncluded^DBARCHIVE("_objectName_")"
 Q 
 ;
 ; ---------------------------------------------------------------------
getArchiveKey ; Method: PSLTable.getArchiveKey(Boolean)
 ;
 I ($$getSetting^PSLCC(.pslPrsr,"boot","restrictionlevel","")=-1)!$$isRdb^vRuntime S return="0" Q 
 I (actual(1)="") S actual(1)=0
 S return="$$getArchiveKey^DBARCHIVE("_objectName_","_actual(1)_")"
 Q 
 ;
 ; ---------------------------------------------------------------------
getArchiveSubs ; Method: PSLTable.getArchiveSubs()
 ;
 I ($$getSetting^PSLCC(.pslPrsr,"boot","restrictionlevel","")=-1)!$$isRdb^vRuntime S return="""""" Q 
 S return="$$getArchiveSubs^DBARCHIVE("_objectName_")"
 Q 
 ;
 ; ---------------------------------------------------------------------
getArchiveTable ; Method: PSLTable.getArchiveTable()
 ;
 I ($$getSetting^PSLCC(.pslPrsr,"boot","restrictionlevel","")=-1)!$$isRdb^vRuntime S return="""""" Q 
 S return="$$getArchiveTable^DBARCHIVE("_objectName_")"
 Q 
 ;
 ; ---------------------------------------------------------------------
getChildren ; Method: PSLTable.getChildren()
 ;
 S return="$$getChildren^UCXDD("_objectName_")"
 Q 
 ;
 ; ---------------------------------------------------------------------
getExisCode ; Method: PSLTable.getExistsCode(PSLIdentifier,String())
 ;
 S return="$$getExisCode^UCXDD("_objectName_","_actual(1)
 I '(actual(2)="") S return=return_","_actual(2)
 S return=return_")"
 Q 
 ;
 ; ---------------------------------------------------------------------
getFlrLgc ; Method: PSLTable.getFilerLogic(String,Boolean())
 ;
 I (actual(3)="") S actual(3)=0
 S return="$$getFlrLgc^UCXDD("_objectName_","_actual(1)_","_actual(2)_","_actual(3)_")"
 Q 
 ;
 ; ---------------------------------------------------------------------
getInitCode ; Method: PSLTable.getInitCode(PSLIdentifier,Boolean)
 ;
 S return="$$getInitCode^UCXDD("_objectName_","_actual(1)_","_actual(2)_")"
 Q 
 ;
 ; ---------------------------------------------------------------------
getLodCode ; Method: PSLTable.getLoadCode()
 S return="$$getLodCode^UCXDD("_objectName_","_actual(1)_","_actual(2)
 S return=return_","_actual(3)_","_actual(4)
 I '(actual(5)="") S return=return_","_actual(5)
 S return=return_")"
 Q 
 ;
 ; ---------------------------------------------------------------------
getNewCode ; Method: PSLTable.getNewCode(PSLIdentifier,PSLExpression,Boolean)
 ;
 I (actual(3)="") S actual(3)="0"
 S return="$$getNewCode^UCXDD("_objectName_","_actual(1)_","_actual(2)_","_actual(3)_")"
 ;
 Q 
 ;
 ; ---------------------------------------------------------------------
getNewMethodCode ; Method: PSLTable.getNewMethodCode(String)
 ;
 S return="$$getNewMethodCode^UCXDD("_objectName_","_actual(1)_")"
 Q 
 ;
 ; ---------------------------------------------------------------------
getPrimaryKeyWhere ; Method: PSLTable.getPrimaryKeyWhere()
 ;
 S return="$$getPrimaryKeyWhere^UCXDD("_objectName_")"
 Q 
 ;
 ; ---------------------------------------------------------------------
getQuery ; Method: PSLTable.getQuery()
 ;
 S return="$$getQuery^UCXDD("_objectName_")"
 Q 
 ;
 ; ---------------------------------------------------------------------
getSavCode ; Method: PSLTable.getSaveCode()
 S return="$$getSavCode^UCXDD("_objectName_","_actual(1)
 S return=return_","_actual(2)_","_actual(3)
 I '(actual(4)="")!'(actual(5)="") S return=return_","_actual(4)
 I '(actual(5)="") S return=return_","_actual(5)
 S return=return_")"
 Q 
 ;
 ; ---------------------------------------------------------------------
getUpdKey ; Method: PSLTable.getUpdateKey(PSLIdentifier,String())
 ;
 S return="$$getUpdKey^UCXDD("_objectName_","_actual(1)
 I '(actual(2)="") S return=return_","_actual(2)
 S return=return_")"
 Q 
 ;
 ; ---------------------------------------------------------------------
isParent ; Method: PSLTable.isParent()
 ;
 S return="$$isParent^UCXDD("_objectName_")"
 Q 
 ;
 ; ---------------------------------------------------------------------
isOneNode ; Method: PSLTable.isOneNode()
 ;
 S return="$$isOneNode^UCXDD("_objectName_")"
 Q 
 ;
 ; ---------------------------------------------------------------------
tblHasBlob ; property PSLTable.hasBlob: Return 1 if table has Blob
 ;
 S return=$$tokenPop^UCPATCH($$vMExpr("("_$$tokenPush^UCPATCH(objectName,"PSLTable")_".dataTypes[""B"")"),1)
 Q 
 ;
 ; ---------------------------------------------------------------------
tblHasMemo ; property PSLTable.hasMemo: Return 1 if table has Memo
 ;
 S return=$$tokenPop^UCPATCH($$vMExpr("("_$$tokenPush^UCPATCH(objectName,"PSLTable")_".dataTypes[""M"")"),1)
 Q 
 ;
 ; ---------------------------------------------------------------------
tblHasNeg ; property PSLTable.hasNegativeNode: Return 1 if table has node with negative subscript
 ;
 S return=$$tokenPop^UCPATCH($$vMExpr("("",""_"_$$tokenPush^UCPATCH(objectName,"PSLTable")_".nodeQuotedList["",""""v"")"),1)
 Q 
 ;
 ; ---------------------------------------------------------------------
tblIsRdb ; property PSLTable.isRdb: 1 if table stored in RDB
 ;
 S return=$$tokenPop^UCPATCH($$vMExpr("("_$$tokenPush^UCPATCH(objectName,"PSLTable")_".database'="""_"GTM"_""")"),1)
 Q 
 ;
 ; ---------------------------------------------------------------------
tblHasMasf ; property PSLTable.hasMasterfield: Return 1 table has Masterfields
 ;
 S return=$$tokenPop^UCPATCH($$vMExpr("'"_$$tokenPush^UCPATCH(objectName,"PSLTable")_".masterfieldList.isNull()"),1)
 Q 
 ;  #OPTION ResultClass ON
vSIG() ; 
 Q "61537^29763^Frans S.C. Witte^48487" ; Signature - LTD^TIME^USER^SIZE
 ; ----------------
 ;  #OPTION ResultClass 1
vopenBuf(v1,v2) ; PSL.openBuffer
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 N vOid
 S vOid=$O(vobj(""),-1)+1 S vobj(vOid,-1)="PSLBuffer"
 I $E(v1,1)'="(",'(v1="") S v1="("_v1_")"
 S vobj(vOid,-2)=v1
 S vobj(vOid,-3)=v2
 S vobj(vOid,1)=v1_" // "_v2
 Q vOid
 ; ----------------
 ;  #OPTION ResultClass 1
vaddBuff(object,p1) ; PSLBuffer.add
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 N line
 S line=$order(vobj(object,""),-1)+1
 S vobj(object,line)=" "_p1
 Q 
 ; ----------------
 ;  #OPTION ResultClass 1
vMExpr(v1) ; PSL.mExpr
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 N vExp N mcode N tok
 N vDep S vDep=$$getSetting^PSLCC(.pslPrsr,"WARN","DEPRECATED",0)
 N vMis S vMis=$$getSetting^PSLCC(.pslPrsr,"WARN","MISMATCH",0)
 N vFun S vFun=$$getSetting^PSLCC(.pslPrsr,"OPTIMIZE","FUNCTIONS",0)
 D addSetting^PSLCC(.pslPrsr,"WARN","DEPRECATED",0)
 D addSetting^PSLCC(.pslPrsr,"WARN","MISMATCH",0)
 D addSetting^PSLCC(.pslPrsr,"OPTIMIZE","FUNCTIONS",0)
 S mcode="" S v1=$$TOKEN^%ZS(v1,.tok) S vExp=$$valExpr^UCGM(v1,,0)
 D addSetting^PSLCC(.pslPrsr,"WARN","DEPRECATED",vDep)
 D addSetting^PSLCC(.pslPrsr,"WARN","MISMATCH",vMis)
 D addSetting^PSLCC(.pslPrsr,"OPTIMIZE","FUNCTIONS",vFun)
 Q vExp
