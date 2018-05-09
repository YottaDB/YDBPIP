 ; 
 ; **** Routine compiled from DATA-QWIK Procedure UCDB ****
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
 ; * changes are made to this procedure.  The M routine from the     *
 ; * crtns directory should be used for this purpose.                *
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
 ; --------------------------------------------------------------------
addAuditLogCode(operation,buf,td,statement,where) ; WHERE clause
 ;
 N code
 N hostVars S hostVars=""
 ;
 D vaddBuff(buf," type Number vauditLogSeq = 0")
 ;
 ; Build host variable clause
 I (where[":") D
 .	;
 .	; ^SQLQ variables
 .	N exe N vsql N vsub
 .	;
 .	;   #ACCEPT DATE=06/18/2008; PGM=Dan Russell; CR=30801; Group=ACCESS
 .	D ^SQLQ(where,$P(td,"|",1))
 .	;
 .	S hostVars=$get(vsql("hostVars"))
 .	;
 .	I '(hostVars="") D
 ..		;
 ..		D vaddBuff(buf," type String using")
 ..		D vaddBuff(buf," #ACCEPT Date=06/05/2008; Pgm=RussellDS; CR=30801; Group=BYPASS")
 ..		D vaddBuff(buf," #BYPASS")
 ..		D vaddBuff(buf," X "_$$QADD^%ZS(("S using="_hostVars),""""))
 ..		D vaddBuff(buf," #ENDBYPASS")
 ..		Q 
 .	Q 
 ;
 D vaddBuff(buf," type static Record"_$P(td,"|",1))
 ;
 S code=" if Record"_$P(td,"|",1)_".logUserclass("""_operation_""") set vauditLogSeq = $$auditLog^SQLAUDIT("""_operation_""", """_$P(td,"|",1)_""","""_statement_""","
 I (hostVars="") S code=code_""""")"
 E  S code=code_"using)"
 ;
 D vaddBuff(buf,code)
 ;
 Q "vauditLogSeq"
 ;
 ; ---------------------------------------------------------------------
akey2apl(td,var,akeys,sparse,lvpm) ; purpose mapping (*5)   /MECH=REFARR:W
 ;
 N fkeys S fkeys=$P(td,"|",3)
 ;
 I (fkeys="") Q ""
 ;
 N expr ; akeys expression element
 N i ; iterator
 N ptr S ptr=0 ; char pointer in akeys
 N keyNam ; name of key
 N keyNum S keyNum=0 ; key ordinal position
 N xref ; key column cross references
 ;
 I $E(akeys,1)="""" S akeys=$$QSUB^%ZS(akeys,"""")
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 E  D:'(akeys="") warnGroup^UCGM("MISMATCH","Literal parameter expected")
 ;
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 S akeys=$$TOKEN^%ZS(akeys,.tok) ; APPEND to existing !!
 ;
 F i=1:1:$S((fkeys=""):0,1:$L(fkeys,",")) S xref($piece(fkeys,",",i))=i
 ;
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 F  S expr=$$nextExpr^UCGM(akeys,.ptr,tok,1) D  I ptr=0 Q 
 .	;
 .	I expr="",sparse Q  ; missing key
 .	I expr="," Q 
 .	I $ZCONVERT(expr,"U")="AND" Q  ; delimiter
 .	I expr["=" D  ; key=value
 ..		;
 ..		S keyNam=$ZCONVERT($piece(expr,"=",1),"U")
 ..		S expr=$E(expr,$L(keyNam)+2,1048575)
 ..		S keyNum=$get(xref(keyNam))
 ..		I (keyNum="") S $ZE="0,"_$ZPOS_","_"%PSL-E-INVALIDREF, Invalid key column: "_keyNam,$EC=",U1001,"
 ..		Q 
 .	E  D
 ..		;
 ..		S keyNum=keyNum+1
 ..		S keyNam=$piece(fkeys,",",keyNum)
 ..		I (keyNam="") S $ZE="0,"_$ZPOS_","_"%PSL-E-INVALIDREF, Too many access keys",$EC=",U1001,"
 ..		Q 
 .	;
 .	I ($D(lvpm(-keyNum-2))#2) D ERROR^UCGM("Duplicate access key: "_keyNam)
 .	;
 .	K xref(keyNam) ; drop name that has been used
 .	;
 .	I $E(expr,1)="'",$E(expr,$L(expr))="'",$L(expr,"'")=3 S expr=$translate(expr,"'","""")
 .	;
 .	E  I $$hasPatch^UCPATCH(expr)
 .	;
 .	E  I $$hasWrap^UCREC4OP(expr)
 .	;
 .	E  D
 ..		N ER S ER=0
 ..		I $E(expr,1)=":" S expr=$E(expr,2,1048575)
 ..		I expr[(oLvn_"(") Q 
 ..		;    #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 ..		S expr=$$valExpr^UCGM(expr) I ER S $ZE="0,"_$ZPOS_","_"%PSL-E-INVALIDREF, Invalid key value expression for "_keyNam,$EC=",U1001,"
 ..		Q 
 .	;
 .	S lvpm(-keyNum-2)=expr
 .	;   #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 .	I $$isVar^UCGM(expr),$$isVar^UCGM(var) D
 ..		;    #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 ..		N newPtr S newPtr=$$getNew^UCGM(var)
 ..		S patch(-3,subRou,var,newPtr,-2-keyNum)=expr
 ..		Q 
 .	Q 
 ;
 N return S return=""
 N zerror S zerror=""
 ;
 F i=1:1:$S((fkeys=""):0,1:$L(fkeys,",")) D
 .	I ($D(lvpm(-i-2))#2) S return=return_lvpm(-i-2)_"," Q 
 .	I sparse=0 S zerror=zerror_$piece(fkeys,",",i)_"," Q 
 .	I sparse>0 S return=return_""""""
 .	S return=return_","
 .	Q 
 ;
 I '(zerror="") D ERROR^UCGM("Missing actual keys: "_$E(zerror,1,$L(zerror)-1))
 ;
 ; quit $$UNTOK^%ZS( return.extract( 1, return.length() - 1), tok)
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 Q $$UNTOK^%ZS($$RTCHR^%ZFUNC(return,","),tok)
 ;
 ; ---------------------------------------------------------------------
akey2asgn(td,var,akeys,ignNull,lvpm) ; purpose mapping   /MECH=REFARR:W
 ;
 N fkeys S fkeys=$P(td,"|",3)
 ;
 I (fkeys="") Q ""
 ;
 N bHasRoot
 N keyvals
 N accPos N i
 N assignCode N val
 ;
 S keyvals=$$akey2apl(td,var,akeys,1,.lvpm)
 ;
 S assignCode=""
 F i=1:1:$S((fkeys=""):0,1:$L(fkeys,",")) D
 .	;
 .	Q:(ignNull&'($D(lvpm(-i-2))#2)) 
 .	;
 .	I 'ignNull,'($D(lvpm(-i-2))#2) S val=""""""
 .	E  S val=lvpm(-i-2)
 .	;
 .	N cd S cd=$$caPslCln^UCXDD(.pslCln,$P(td,"|",1)_"."_$piece(fkeys,",",i),.pslTbl)
 .	;
 .	S accPos=$$clnByOvs^UCREC4OP(subRou,var,cd,0,1,.bHasRoot)
 .	;
 .	N decPos S decPos=$$getDec^UCREC4OP(subRou,var,accPos)
 .	;
 .	N return S return=$$clnAsn1^UCREC4OP(decPos,accPos,val)
 .	;
 .	S assignCode=assignCode_return
 .	Q 
 ;
 Q assignCode
 ;
 ; ---------------------------------------------------------------------
Cache ; method Cache.getRecord ; Returns Record<Class> object
 ;
 N table S table=actual(1)
 I $E(table,1)="""" S table=$$QSUB^%ZS(table,"""")
 ;
 S class="Record"_table
 ;set PSL.actual(3) = 0
 N clsNew S clsNew=+actual(3)
 S actual(3)=1
 D getRecord
 ;
 N td S td=$$caPslTbl^UCXDD(.pslTbl,table,0)
 N akeys S akeys=$$akey2apl(td,var,actual(2),0)
 N cmmnt S cmmnt="vobj()=({Cache}"_objectName_".getRecord("_table_","_clsNew_")"
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 N label S label=$$findSubr^UCGM("vCa",cmmnt)
 ;
 N lbGetRec S lbGetRec=$piece(return,"(")
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 D incrLabel^UCGM(lbGetRec)
 ;
 N dummy S dummy=$$purByOvs^UCREC4OP(subRou,var,-2)
 ;
 I '$$hasSubr^UCGM(label) D CacheSr(td,1,label,cmmnt,objectName,clsNew,lbGetRec)
 S return="$$"_label_"("_akeys_")"
 ;
 I $$vPSLopti(var)
 ;
 Q 
 ;
 ; ---------------------------------------------------------------------
CacheDef ; method Cache.isDefined
 N tbl S tbl=actual(1)
 I $E(tbl,1)="""" S tbl=$$QSUB^%ZS(tbl,"""")
 ;
 N cmt S cmt="{Cache}"_objectName_".isDefined("_actual(1)_","_actual(2)_")"
 ;
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 N lbl S lbl=$$findSubr^UCGM("vCaEx",cmt)
 ;
 S return="$$"_lbl_"()"
 ;
 I '$$hasSubr^UCGM(lbl) D
 .	N buf S buf=$$vopenBuf("()",cmt)
 .	N ucn S ucn=$piece(objectName,"(")
 .	D vaddBuff(buf," type public Cache "_ucn_"()")
 .	D vaddBuff(buf," type Record"_tbl_" vRec = "_objectName_".getRecord("_actual(1)_","_actual(2)_",1)")
 .	D vaddBuff(buf," quit vRec.getMode() = 1")
 .	;
 .	D INSERT^UCMETHOD(buf,lbl,"Boolean")
 .	K vobj(+$G(buf)) Q 
 ;
 Q 
 ;
 ; ---------------------------------------------------------------------
CacheSr(td,useVobj,label,comment,cacheNm,clsNew,lbGetRec) ; label to use for getRecord
 ;
 N code ; code construction
 N fpl S fpl="" ; formal parameter list
 N fplAudit S fplAudit="" ; formal parameters, including fromDBSet
 N ftype S ftype=$P(td,"|",4) ; record type
 N isArchived S isArchived=0
 N k ; key iterator
 N lvn ; cacheNm(v1,v2,v3)
 N lvn1 ; cacheNm(v1,v2,v3,
 N lvnInit ; cache node for initial load
 N lvpm ; map passed to getRecCode()
 N nodExis S nodExis=$P(td,"|",12) ; exists node
 N nodInit S nodInit=$$getRecPur^UCXDD(td) ; initial node
 N pkl S pkl=$P(td,"|",3) ; primary key columns
 N ucn S ucn=$piece(cacheNm,"(") ; unsubscripted cache name
 N vobjHead ; "vobj(vOid"
 N vobjInit ; vDbN var that holds init node
 ;
 I '($$getArchiveTable^DBARCHIVE(td)="") S isArchived=1
 ;
 F k=1:1:$S((pkl=""):0,1:$L(pkl,",")) D
 .	I k>1 S fpl=fpl_","
 .	S fpl=fpl_"v"_k
 .	S lvpm(k_"*")="v"_k
 .	Q 
 ;
 ; Add fromDBSet parameter
 I '($P(td,"|",8)'="GTM") D
 .	;
 .	I (fpl="") S fplAudit="0"
 .	E  S fplAudit=",0"
 .	Q 
 ;
 I useVobj S vobjHead=oLvn_"(vOid"
 ;
 I ($E(cacheNm,$L(cacheNm))=")") S lvn=$E(cacheNm,1,$L(cacheNm)-1)_","
 E  S lvn=cacheNm_"("
 ;
 S lvn=lvn_fpl_")"
 I ($E(lvn,$L(lvn)-2+1,1048575)="()") S lvn=$E(lvn,1,$L(lvn)-2)
 I ($E(lvn,$L(lvn)-2+1,1048575)=",)") S lvn=$E(lvn,1,$L(lvn)-2)_")"
 ;
 S lvn1=lvn
 ;
 I $E(lvn1,$L(lvn1))=")" S lvn1=$E(lvn1,1,$L(lvn1)-1)_","
 E  S lvn1=lvn1_"("
 ;
 I (nodInit="0*")!(nodInit="") D
 .	S lvnInit=lvn
 .	S vobjInit=$S(useVobj:vobjHead_")",1:lbGetRec)
 .	Q 
 E  I '(nodInit="") D
 .	S lvnInit=lvn1_nodExis_")"
 .	S vobjInit=$S(useVobj:vobjHead_","_nodExis_")",1:"vOid")
 .	Q 
 ;
 S code=fpl
 I clsNew=1,'useVobj S code=$S((code=""):"v2out",1:code_","_"v2out")
 N sr S sr=$$vaddSubr(label,"("_code_")",comment,0)
 ;
 I useVobj D addCode^UCPSLSR(sr," N vOid")
 ;
 ; Add the code to load the record from the db if not in cache
 D addCode^UCPSLSR(sr," I '$D("_lvn_") D")
 I 'useVobj D
 .	S code=""
 .	S:clsNew=0 code="v2out"
 .	S:isArchived code=$S((code=""):"vArch",1:code_","_"vArch")
 .	D:'(code="") addCode^UCPSLSR(sr," .  N "_code)
 .	Q 
 ;do sr.addCode(" .  I $G("_ cacheNm_ ")>"_ PSL.maxCacheSize_ " S "_ ucn_ "="_ ucn_ "-"_ cacheNm_ " KILL "_ cacheNm)
 ;do sr.addCode(" .  S "_ cacheNm_ "=$G("_ cacheNm_ ")+1,"_ ucn_ "=$G("_ ucn_ ")+1")
 D addCode^UCPSLSR(sr," .  I $G("_cacheNm_")>"_100_" KILL "_cacheNm)
 D addCode^UCPSLSR(sr," .  S "_cacheNm_"=$G("_cacheNm_")+1")
 I useVobj D
 .	D addCode^UCPSLSR(sr," .  S vOid="_lbGetRec_"("_fpl_fplAudit_")")
 .	I isArchived D addCode^UCPSLSR(sr," .  S "_lvn1_"-99)="_vobjHead_",-99)")
 .	D addCode^UCPSLSR(sr," .  S "_lvn1_"-2)="_vobjHead_",-2)")
 .	I '(nodInit="") D addCode^UCPSLSR(sr," .  S "_lvnInit_"="_vobjInit)
 .	Q 
 E  D
 .	N fplmod S fplmod=fpl_fplAudit
 .	I (fplmod="") S fplmod=".v2out"
 .	E  S fplmod=fplmod_",.v2out"
 .	S code=" .  S "_lvnInit_"="_lbGetRec_"("_fplmod
 .	I isArchived S code=code_",.vArch),"_lvn1_"-99)=vArch,"_lvn1_"-2)=v2out"
 .	E  S code=code_"),"_lvn1_"-2)=v2out"
 .	D addCode^UCPSLSR(sr,code)
 .	Q 
 ;
 D addCode^UCPSLSR(sr," ;")
 ;
 ; Add the code that creates the object to be returned
 I useVobj D
 .	D addCode^UCPSLSR(sr," E  D")
 .	D addCode^UCPSLSR(sr," . "_$$cdNewObj^UCCLASS("vOid","""Record"_$P(td,"|",1)_""""))
 .	D addCode^UCPSLSR(sr," .  S "_vobjHead_",-2)="_lvn1_"-2)")
 .	I '(pkl="") F k=1:1:$S((pkl=""):0,1:$L(pkl,",")) D addCode^UCPSLSR(sr," .  S "_vobjHead_","_(-2-k)_")=v"_k)
 .	;
 .	I '(nodInit="") D addCode^UCPSLSR(sr," .  S "_vobjInit_"="_lvnInit)
 .	Q 
 ;
 D addCode^UCPSLSR(sr," ;")
 ;
 ; If not Cache.getRecord(,,1), add code that throws %PSL-E-RECNOFL
 ; Else add the code that sets v2out when entry found in cache
 I clsNew=0 D
 .	D addCode^UCPSLSR(sr," I "_lvn1_"-2)=0 S $ZE=""0,""_$ZPOS_"",%PSL-E-RECNOFL,,"_$P(td,"|",1)_""",$EC="",U1001,""")
 .	Q 
 E  I 'useVobj D addCode^UCPSLSR(sr," E  S v2out="_lvn1_"-2)")
 ;
 D addCode^UCPSLSR(sr," Q "_$S(useVobj:"vOid",(nodInit=""):"""""",1:lvnInit))
 ;
 I ftype>1 D
 .	;   #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 .	I ($P(td,"|",8)'="GTM") D warnGroup^UCGM("INTERNAL","Incremental loads will bypass Cache for : "_cacheNm_".getRecord("_$P(td,"|",1)_")") Q 
 .	;
 .	I isArchived S lvpm(-99)=lvn1_"-99)"
 .	;
 .	N gbl S gbl=$$getDataNode^UCXDD(td,"vOid","vn",0,.lvpm,.pslCln)
 .	;
 .	I '(fpl="") S fpl=fpl_","
 .	;
 .	D addCode^UCPSLSR(sr,label_"L("_fpl_"vn) ; Incremental Load "_$P(td,"|",1)_" Cache into "_cacheNm)
 .	;
 .	I ftype=10 D
 ..		D addCode^UCPSLSR(sr," I '$D("_lvn1_"vn)) S "_lvn1_"vn)="_gbl)
 ..		D addCode^UCPSLSR(sr," Q "_lvn1_"vn)")
 ..		Q 
 .	E  D  ; recordType = 11
 ..		D addCode^UCPSLSR(sr," I $D("_lvn1_"vn)) Q "_lvn1_"vn)")
 ..		D addCode^UCPSLSR(sr," N vData S vData="_gbl)
 ..		D addCode^UCPSLSR(sr," I $D("_lvn_") S "_lvn1_"vn)=vData")
 ..		D addCode^UCPSLSR(sr," Q vData")
 ..		Q 
 .	Q 
 Q 
 ;
 ; --------------------------------------------------------------------
delete ; Db.delete(table_name,where_clause,filer_qualifier)
 ;
 N table S table=$ZCONVERT($$QSUB^%ZS(actual(1),""""),"U")
 N where S where=$$QSUB^%ZS(actual(2),"""")
 N qual S qual=$$fileQual("Db.delete",actual(3))
 ;
 N td S td=$$caPslTbl^UCXDD(.pslTbl,table,0)
 ;
 I where[":" S where=$$mapPSLvar(where)
 ;
 N akey S akey=$$sql2akey(td,where)
 ;
 I ($P(td,"|",8)'="GTM"),$P(td,"|",4)>1,'(where="") D delByFiler(td,where,akey,qual) Q 
 ;
 N rights S rights=$$checkAccessRights^UCXDD(td,0)
 ;
 I (((","_rights_",")[",delete,")!((","_rights_",")[",deleteRestrict,")) D delByFiler(td,where,akey,qual) Q 
 I ((","_$$getLogging^UCXDD(td,0)_",")[",delete,") D delByFiler(td,where,akey,qual) Q 
 ;
 N flrLgc S flrLgc=$$getFlrLgc^UCXDD(td,"DELETE",qual,1)
 I '(flrLgc="") D delByFiler(td,where,akey,qual) Q 
 ;
 I ($P(td,"|",8)'="GTM") D delRdb(td,where) Q 
 ;
 N lvpm
 ;
 I '(akey="")!($P(td,"|",3)="") D
 .	N dummy S dummy=$$akey2apl(td,"",akey,0,.lvpm)
 .	N k
 .	;
 .	F k=1:1:$S(($P(td,"|",3)=""):0,1:$L($P(td,"|",3),",")) S lvpm(k_"*")=lvpm(-k-2)
 .	;
 .	;   #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 .	S mcode=$$backup^UCGM(mcode)
 .	S return=$$delMcode(td,.lvpm,postCond)
 .	Q 
 E  D
 .	N comment S comment="DELETE FROM "_$P(td,"|",1)
 .	I '(where="") S comment=comment_" WHERE "_where
 .	;
 .	;   #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 .	N label S label=$$findSubr^UCGM("vDbDe","") ; generate new label
 .	;
 .	S return=label_"()"
 .	;
 .	I $$hasSubr^UCGM(label) Q 
 .	;
 .	N buf S buf=$$vopenBuf("()",comment)
 .	N k
 .	N pkeys S pkeys=$P(td,"|",3)
 .	N line S line=" type Primitive "
 .	N getKeys S getKeys="set "
 .	N setKeys S setKeys="set "
 .	F k=1:1:$S((pkeys=""):0,1:$L(pkeys,",")) D
 ..		S lvpm(k_"*")="v"_k
 ..		I k>1 S line=line_"," S getKeys=getKeys_"," S setKeys=setKeys_","
 ..		S line=line_"v"_k
 ..		S getKeys=getKeys_"v"_k_"=vRs.getCol("_k_")"
 ..		S setKeys=setKeys_"vRec."_$piece(pkeys,",",k)_"=v"_k
 ..		Q 
 .	D vaddBuff(buf,line)
 .	D vaddBuff(buf," do Runtime.start(""CS"")")
 .	;
 .	D vaddBuff(buf," type ResultSet vRs=Db.select("""_pkeys_""","""_$P(td,"|",1)_""","""_where_""")")
 .	D vaddBuff(buf," while vRs.next() do {")
 .	D vaddBuff(buf,"   "_getKeys)
 .	;
 .	D vaddBuff(buf,"   #ACCEPT CR=18163;DATE=2006-01-09;PGM=FSCW;GROUP=BYPASS")
 .	D vaddBuff(buf,"   #BYPASS")
 .	D vaddBuff(buf,$$delMcode(td,.lvpm,""))
 .	D vaddBuff(buf,"   #ENDBYPASS")
 .	D vaddBuff(buf," }")
 .	D vaddBuff(buf," do Runtime.commit()")
 .	D vaddBuff(buf," quit")
 .	;
 .	D INSERT^UCMETHOD(buf,label,"void")
 .	K vobj(+$G(buf)) Q 
 Q 
 ;
 ; --------------------------------------------------------------------
delByFiler(td,where,acckey,qual) ; filer qualifiers ("normalized")
 N sqlstat S sqlstat="DELETE FROM "_$P(td,"|",1)
 I '(where="") S sqlstat=sqlstat_" WHERE "_where
 ;
 N auditParam S auditParam="0"
 ;
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 N label S label=$$findSubr^UCGM("vDbDe","") ; generate new label
 ;
 S return=label_"()"
 ;
 I $$hasSubr^UCGM(label) Q 
 ;
 N buf S buf=$$vopenBuf("()",sqlstat)
 ;
 I $$usingAuditLog^SQLAUDIT S auditParam=$$addAuditLogCode("DELETE",buf,td,sqlstat,where)
 ;
 D vaddBuff(buf," do Runtime.start(""CS"")")
 I (acckey="") D
 .	D vaddBuff(buf," type DbSet vDs=Db.selectDbSet("""_$P(td,"|",1)_""","_$S(where'["""":""""_where_"""",1:$$QADD^%ZS(where,""""))_")")
 .	D vaddBuff(buf," while vDs.next() do {")
 .	D vaddBuff(buf,"   type Record"_$P(td,"|",1)_" vRec = vDs.getRecord("""_$P(td,"|",1)_""")")
 .	D vaddBuff(buf,"   do vRec.setMode(3)")
 .	I '($P(td,"|",8)'="GTM") D
 ..		;
 ..		D addMSaveBypass(buf,$P(td,"|",1),"vRec",qual,auditParam)
 ..		Q 
 .	E  D vaddBuff(buf,"   do vRec.save("_qual_")")
 .	D vaddBuff(buf," }")
 .	Q 
 E  D
 .	;
 .	N code
 .	;
 .	D vaddBuff(buf," type Record"_$P(td,"|",1)_" vRec = Db.getRecord("""_$P(td,"|",1)_""","_acckey_",1)")
 .	;
 .	S code=" if vRec.getMode()=1 do vRec.setMode(3)"
 .	;
 .	I '($P(td,"|",8)'="GTM") D
 ..		;
 ..		D vaddBuff(buf," if vRec.getMode()=1 do vRec.setMode(3) do {")
 ..		D addMSaveBypass(buf,$P(td,"|",1),"vRec",qual,auditParam)
 ..		D vaddBuff(buf,"  }")
 ..		Q 
 .	;
 .	E  D vaddBuff(buf,code_",vRec.save("_qual_")")
 .	Q 
 D vaddBuff(buf," do Runtime.commit()")
 D vaddBuff(buf," quit")
 D INSERT^UCMETHOD(buf,label,"void")
 ;
 K vobj(+$G(buf)) Q 
 ;
 ; --------------------------------------------------------------------
addMSaveBypass(buf,tableName,objRef,qual,auditParam) ; Audit parameter value
 S:(qual="") qual=""""""
 ;
 D vaddBuff(buf,"   #ACCEPT Date=07/09/2008; Pgm=RussellDS; CR=30801; Group=BYPASS")
 D vaddBuff(buf,"   #BYPASS")
 D vaddBuff(buf,"   D vSave^Record"_tableName_"("_objRef_","_qual_","_auditParam_")")
 D vaddBuff(buf,"   #ENDBYPASS")
 ;
 Q 
 ;
 ; --------------------------------------------------------------------
delMcode(td,lvpm,mpc) ; M_postcond (incl ":", or "")
 N code S code=$$getGvn^UCXDD(td,"",.lvpm)
 ;
 I $$isOneNode^UCXDD(td) Q " ZWI"_mpc_" "_code
 ;
 Q " K"_mpc_" "_code
 ;
 ; ---------------------------------------------------------------------
delRdb(td,where) ; where clause (*2)
 N sqlcmt S sqlcmt="DELETE FROM "_$P(td,"|",1) ; SQL delete for comment uses DQ name
 ;
 I '(where="") S sqlcmt=sqlcmt_" WHERE "_where
 ;
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 N label S label=$$findSubr^UCGM("vDbDe","") ; generate new label
 ;
 S return=label_"()"
 ;
 I $$hasSubr^UCGM(label) Q 
 ;
 N buf S buf=$$vopenBuf("()",sqlcmt)
 ;
 ; NOTE: doTrunct is only used to indicate "no WHERE clause" (see intro)
 N doTrunct S doTrunct=(where="")
 ;
 D vaddBuff(buf,"#ACCEPT CR=35741;DATE=2008-09-29;PGM=FSCW;GROUP=BYPASS")
 D vaddBuff(buf,"#BYPASS")
 D vaddBuff(buf,"N vEr,vRm")
 D vaddBuff(buf,"N vTp S vTp=($TL=0) TS:vTp (vobj):transactionid=""CS"" D:vTp "_$$callStart^UCRUNTIM())
 ;
 I doTrunct D  ; Use truncate, if possible
 .	N i
 .	N tables S tables=$P(td,"|",9)
 .	;
 .	; do buf.add( "I 0,$TLEVEL=0 D  Q  ; TRUNCATE requires $TLEVEL=0")
 .	; do buf.add( ". ; Note - this code will not yet execute")
 .	; for i=1:1:tables.count() do buf.add( "."_$select(i>1:" I vEr'<0",1:"")_" S vEr=$$EXECUTE^%DBAPI(0,""TRUNCATE TABLE "_tables.elementAt(i)_""","""","""",.vRm)")
 .	; do buf.add( ". I vEr<0 S $ZE=""0,""_$ZPOS_"",%PSL-E-SQLDELFAIL,""_$TR($G(vRm),$C(10,44),$C(32,126)),$EC="",U1001,""")
 .	; do buf.add( ". ; Note - no commit here, since if $Tlevel=0, we do truncate")
 .	;
 .	F i=1:1:$S((tables=""):0,1:$L(tables,",")) D vaddBuff(buf,$S(i>1:"I vEr'<0",1:"")_" S vEr=$$EXECUTE^%DBAPI(0,""DELETE FROM "_$piece(tables,",",i)_""","""","""",.vRm)")
 .	;
 .	D vaddBuff(buf,"I vEr<0 S $ZE=""0,""_$ZPOS_"",%PSL-E-SQLDELFAIL,""_$TR($G(vRm),$C(10,44),$C(32,126)),$EC="",U1001,""")
 .	Q 
 E  D
 .	N hvMap
 .	N vListCd
 .	N sql S sql="DELETE FROM "_$P(td,"|",9)
 .	N delim S delim=$P(td,"|",10)
 .	;
 .	I '(where="") D
 ..		S where=$$where^UCDBR($P(td,"|",1),where,.hvMap)
 ..		S vListCd=$$RsMsXV^UCDBRT(.hvMap,.where,0,delim)
 ..		S sql=sql_" WHERE "_where
 ..		Q 
 .	E  S vListCd=""""""
 .	;
 .	D vaddBuff(buf," S vEr=$$EXECUTE^%DBAPI(0,"""_sql_""",$C("_delim_"),"_vListCd_",.vRm)")
 .	D vaddBuff(buf," I vEr<0 S $ZE=""0,""_$ZPOS_"",%PSL-E-SQLDELFAIL,""_$TR($G(vRm),$C(10,44),$C(32,126)),$EC="",U1001,""")
 .	Q 
 ;
 ; common exit
 D vaddBuff(buf,"D:vTp "_$$callCommitCS^UCRUNTIM())
 D vaddBuff(buf,"#ENDBYPASS")
 D vaddBuff(buf,"quit")
 ;
 D INSERT^UCMETHOD(buf,label,"void")
 K vobj(+$G(buf)) Q 
 ;
 ; ---------------------------------------------------------------------
fastDel ; void; method Db.fastDelete
 ;
 N checkDelete S checkDelete=0
 N useDelete S useDelete=0
 N allkeys N delkeys
 N akeys N gbl N tok
 N i
 N map
 N td S td=$$caPslTbl^UCXDD(.pslTbl,$$QSUB^%ZS(actual(1),""""),0)
 ;
 S akeys=$$akey2apl(td,"",actual(2),-1,.map)
 ;
 F i=1:1:$S(($P(td,"|",3)=""):0,1:$L($P(td,"|",3),",")) S map(i_"*")=$get(map(-2-i))
 F i=$S(($P(td,"|",3)=""):0,1:$L($P(td,"|",3),",")):-1:1 Q:'(map(i_"*")="")  K map(i_"*")
 S gbl=$$getGvn^UCXDD(td,"",.map)
 ;
 I gbl["()" S gbl=$piece(gbl,"()")
 ;
 ;  #ACCEPT DATE=06/18/2008; PGM=Dan Russell; CR=30801; Group=ACCESS
 S delkeys=$$TOKEN^%ZS($piece(gbl,"(",2,999),.tok)
 ;  #ACCEPT DATE=06/18/2008; PGM=Dan Russell; CR=30801; Group=ACCESS
 S allkeys=$$TOKEN^%ZS($piece($P(td,"|",2),"(",2,999),.tok)
 F i=$S((delkeys=""):0,1:$L(delkeys,","))+1:1:$S((allkeys=""):0,1:$L(allkeys,",")) I $$isLit^UCGM($piece(allkeys,",",i))!($E($piece(allkeys,",",i),1,$L($char(0)))=$char(0)) S useDelete=1 Q 
 ;
 ; If DBTBL1.QID1 is not null, need to use regular delete
 I '($$RsMsQID1^UCDBRT($P(td,"|",1))="") S useDelete=1
 ;
 I 'useDelete,((gbl["(,")!(gbl[",,")) S useDelete=1
 ;
 I 'useDelete D
 .	;
 .	N rights S rights=$$checkAccessRights^UCXDD(td,0)
 .	;
 .	; No WHERE clause
 .	I (actual(2)="") D
 ..		;
 ..		I ((","_rights_",")[",delete,") S checkDelete=1
 ..		E  I ((","_rights_",")[",deleteRestrict,") S useDelete=1
 ..		Q 
 .	;
 .	; WHERE clause, and DELETE or SELECT rights
 .	E  I (((","_rights_",")[",delete,")!((","_rights_",")[",deleteRestrict,")!((","_rights_",")[",select,")!((","_rights_",")[",selectRestrict,")) S useDelete=1
 .	;
 .	; Check audit logging
 .	I ((","_$$getLogging^UCXDD(td,0)_",")[",delete,") S useDelete=1
 .	Q 
 ;
 I (useDelete!($P(td,"|",8)'="GTM")) D
 .	S actual(2)=$$akey2sql($$QSUB^%ZS(actual(2),""""),$P(td,"|",3))
 .	S actual(3)="""/NOJOURNAL/NOTRIGAFT/NOTRIGBEF"""
 .	D delete
 .	Q 
 E  D
 .	;
 .	I gbl[",)" S gbl=$piece(gbl,",)")_")"
 .	;
 .	;   #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 .	S mcode=$$backup^UCGM(mcode)
 .	I checkDelete S return=" S:'$$deleteOK^Record"_$P(td,"|",1)_"("""",%UCLS) $ZE=""0,""_$ZPOS_"",%PSL-E-ACCESS,""_$TR($$^MSG(6754,"""_$P(td,"|",1)_"""),$C(10,44),$C(32,126)),$EC="",U1001,"" "
 .	E  S return=" "
 .	S return=return_"K"_postCond_" "_gbl
 .	Q 
 Q 
 ;
 ; ---------------------------------------------------------------------
fileQual(method,qualarg) ; applicable qualifiers (*2)
 ;
 N par S par=qualarg
 ;
 ; standardize if literal
 I $$isLit^UCGM(par) S par=$$QADD^%ZS($$setPar^UCUTILN("",$ZCONVERT($$QSUB^%ZS(par,""""),"U")),"""")
 ;
 ; APPEND debug settings if applicable
 N debug S debug=$$getSetting^PSLCC(.pslPrsr,"DEBUG","FILEQUAL","")
 ;
 I debug="*"!(debug=method) S par="$$setPar^UCUTILN("_par_",""/VALDD/VALRI"")"
 ;
 S par="$$initPar^UCUTILN("_par_")"
 ;  #ACCEPT CR=22719; DATE=2006-06-23; PGM=FSCW; GROUP=XECUTE
 I $$isLit^UCGM(qualarg)!(qualarg="") XECUTE "set par=$$QADD^%ZS("_par_")"
 ;
 Q par
 ;
 ; ---------------------------------------------------------------------
get1Row ; void; method Db.getOneRow
 ;
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 D WARNDEP^UCGM(2.6,0,"Db.getOneRow")
 ;
 N list S list=$$QSUB^%ZS(actual(1),"""") ; column list
 N table S table=$$QSUB^%ZS(actual(2),"""") ; table name
 N keys S keys=$$QSUB^%ZS(actual(3),"""") ; access keys
 N delim S delim=$S($translate($get(actual(4))," ",""):actual(4),1:9) ; Delimiter
 N td S td=$$caPslTbl^UCXDD(.pslTbl,table,0)
 N buf
 N cmt S cmt="Db.GetOneRow( "_actual(1)_", "_actual(2)_", "_actual(3)_", "_delim_")"
 ;
 I $piece(list," ")="DISTINCT" S list=$piece(list,"DISTINCT ",2)
 S list=$ZCONVERT(list,"U")
 ;
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 N label S label=$$findSubr^UCGM("vDbRow","") ; Get next label
 ;
 I ($P(td,"|",8)'="GTM") D
 .	N k
 .	N pkl S pkl=$P(td,"|",3)
 .	N fpl S fpl="(" N whr S whr=""
 .	;
 .	F k=1:1:$S((pkl=""):0,1:$L(pkl,",")) D
 ..		I k>1 S fpl=fpl_"," S whr=whr_" AND "
 ..		S fpl=fpl_" String v"_k
 ..		S whr=whr_$piece(pkl,",",k)_"=:V"_k
 ..		Q 
 .	;
 .	; create SQL SELECT statement by calling UCDBRT
 .	N map N sql S sql=$$RsDyRT^UCDBRT(list,table,whr,"","","",.map)
 .	N hvl S hvl=$translate($$RsMsXV^UCDBRT(.map,.sql,0,delim),"V","v")
 .	N code S code="type String vData,vRm"
 .	N split
 .	;
 .	S buf=$$vopenBuf(fpl_")",cmt)
 .	I ($ZLENGTH(sql)+80'>1980) D
 ..		S sql=$S(sql'["""":""""_sql_"""",1:$$QADD^%ZS(sql,""""))
 ..		Q 
 .	E  D
 ..		S code=code_",vSql"
 ..		D splitCode^UCGMC(sql,40,"",.split)
 ..		S sql="vSql"
 ..		Q 
 .	;
 .	D vaddBuff(buf,code) ; add declaration
 .	S k=$order(split(""),-1)
 .	I k>1 D
 ..		D vaddBuff(buf," set vSql = "_$S(split(1)'["""":""""_split(1)_"""",1:$$QADD^%ZS(split(1),"""")))
 ..		F k=2:1:k D vaddBuff(buf," set vSql = vSql_ "_$S(split(1)'["""":""""_split(1)_"""",1:$$QADD^%ZS(split(1),"""")))
 ..		Q 
 .	D vaddBuff(buf,"type Number vEr = $$SELECT^%DBAPI(0,"_sql_","_delim_".char(),"_hvl_",.vData,.vRM)")
 .	D vaddBuff(buf,"quit vData")
 .	S return="$$"_label_"("_$$akey2apl(td,"",keys,0)_")"
 .	Q 
 E  D
 .  K vobj(+$G(buf)) S buf=$$vopenBuf("()",cmt)
 .	;
 .	D vaddBuff(buf,"type Record"_table_" vRec = Db.getRecord("""_table_""","""_keys_""",1)")
 .	;
 .	N I
 .	N expr S expr="" N prop
 .	F I=1:1:$L(list,",") D
 ..		I I>1 D
 ...			I I#8=1 D
 ....				I I=9 D
 .....					D vaddBuff(buf,"type String vRow="_expr)
 .....					Q 
 ....				E  D vaddBuff(buf,"set vRow="_expr)
 ....				S expr="vRow"
 ....				Q 
 ...			S expr=expr_"_"_delim_".char()_"
 ...			Q 
 ..		S prop=$piece(list,",",I)
 ..		I prop="" Q 
 ..		;if prop'["." set prop = "vRec."_ prop.lowerCase()
 ..		S expr=expr_"vRec."_$ZCONVERT(prop,"L")
 ..		Q 
 .	;
 .	D vaddBuff(buf,"quit "_expr)
 .	S return="$$"_label_"()"
 .	Q 
 ;
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 D autoERRM^UCGM()
 D INSERT^UCMETHOD(buf,label,"String")
 K vobj(+$G(buf)) Q 
 ;
 ; ---------------------------------------------------------------------
getRecCN(df) ; value of ClassNew parameter
 S df=$$QSUB^%ZS(df,"""")
 Q ''df
 ;
 ; ---------------------------------------------------------------------
getRecord ; method Db.getRecord; returns RecordTABLE
 ;
  ; BAD USAGE !!
 ;
 I ptr D getRecPr Q  ; 7813 - Handle nested property syntax
 ;
 D getRec(0)
 ;
 Q 
 ;
 ; ---------------------------------------------------------------------
getRec(bFromDbSet) ; Building DbSet.getRecord indicator
 ;
 N td S td=$$caPslTbl^UCXDD(.pslTbl,$$QSUB^%ZS(actual(1),""""),0)
 N deflt S deflt=$$getRecCN(actual(3))
 ;
 S return=$$akey2apl(td,var,actual(2),0)
 ;
 I '($P(td,"|",8)'="GTM") D
 .	;
 .	; Null if CUVAR-like with no keys
 .	I '(return="") S return=return_","_bFromDbSet
 .	E  S return=bFromDbSet
 .	Q 
 ;
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 I '((+actual(3)=0)!(+actual(3)=1)) D ERROR^UCGM("Db.getRecord( "_actual(1)_", "_actual(2)_", "_actual(3)_")")
 ;
 S class="Record"_$P(td,"|",1)
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 N scope S scope=$$getScope^UCGM(var,varLevel)
 ;
 I scope="LITERAL" D LitInst(var,$P(td,"|",1),return,deflt,level) Q 
 ;
 ;  #ACCEPT CR=30801;Date=04-06-2008;PGM=RussellDS;Group=DEPRECATED; use of type()
 ;
 I ((","_$$checkAccessRights^UCXDD(td,0)_",")[",updateRestrict,") S $piece(type(level,var),$char(9),12)=1
 ;
 ; Get appropriate method in RecordTABLE
 N comment S comment=oLvn_"()=Db.getRecord("_$P(td,"|",1)_",,"_deflt_")"
 S return=$$getRecSr(td,0,deflt)_"("_return_")"
 ;
 Q 
 ;
 ; ---------------------------------------------------------------------
getRecPr ; Db.getRecord has properties
 ;
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 I fset D ERROR^UCGM("Expression is not updateable") Q 
 ;
 N table S table=$$QSUB^%ZS(actual(1),"""")
 ;
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 N var S var=$$nxtSym^UCGM
 N label S label="vDbGr"_$piece(var,"vo",2) ; Create unique label
 ;
 N buf S buf=$$vopenBuf("()","nested Db.getRecord() using "_var)
 D vaddBuff(buf," type "_"Record"_table_" "_var_"=Db.getRecord("_actual(1)_","_actual(2)_","_actual(3)_")")
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 D vaddBuff(buf," quit "_var_$$UNTOK^%ZS($E(atom,ptr+1,1048575),tok))
 ;
 D INSERT^UCMETHOD(buf,label,"String")
 ;
 S return=label_"()"
 S class="String"
 S ptr=0 ; PUBLIC Number ptr
 ;
 K vobj(+$G(buf)) Q 
 ;
 ; ---------------------------------------------------------------------
getRecSr(td,useOpt,clsNew) ; value of ClassNew parameter (0, 1)
 ;
 ; M-code generation only at this point.  Will need reconsideration for Java
 ;
 N label S label="vRCgetRecord"_clsNew
 ;
 I useOpt S label=label_"Opt"
 ;
 Q "$$"_label_"^Record"_$P(td,"|",1)
 ;
 ; ---------------------------------------------------------------------
getRecSrCode(td,recInst) ; record variable
 ;
 N cd
 N init161 S init161=""
 N set161 S set161=""
 ;
 N auditSelect S auditSelect=0
 N useAudit S useAudit=$$usingAuditLog^SQLAUDIT
 N archref
 N archTbl S archTbl=$$getArchiveTable^DBARCHIVE(td)
 N code
 N accessChecks S accessChecks=$$checkAccessRights^UCXDD(td,0)
 N fkeys S fkeys=$P(td,"|",3)
 N fpl S fpl="" ; formal parameter list (no optimize)
 N fplOpt S fplOpt="" ; formal parameter list (optimize)
 N archParams S archParams="" ; parameters for archive
 N i N j ; iterators
 N maxOpt
 N auditCode S auditCode=" if "
 N loadOpt N loadNoOpt ; load code by getRecCode()
 N loadNod S loadNod="" ; node corresponding to the lvn
 N lvpmNoOpt N lvpmOpt
 N methCode ; method code for each of the methods
 N optRef S optRef=$ZCONVERT($P(td,"|",1),"L")
 N recClass S recClass="Record"_$P(td,"|",1)
 N retVal
 N selectChk S selectChk=0 ; 1 = select, 2 = selectRestrict
 N selErrCode
 ;
 I ((","_accessChecks_",")[",select,") S selectChk=1
 E  I ((","_accessChecks_",")[",selectRestrict,") S selectChk=2
 ;
 I useAudit S auditSelect=((","_$$getLogging^UCXDD(td,0)_",")[",select,")
 ;
 I auditSelect D
 .	;
 .	N isPositiveList
 .	N userclasses
 .	;
 .	I $$shouldLog^SQLAUDIT($P(td,"|",1),"SELECT","log",.userclasses,.isPositiveList) D
 ..		;
 ..		N uclsCheck
 ..		;
 ..		I ($S((userclasses=""):0,1:$L(userclasses,","))=0) S uclsCheck="" ; No check necessary, do them all
 ..		E  I ($S((userclasses=""):0,1:$L(userclasses,","))=1) S uclsCheck="(%UserClass = "_$S(userclasses'["""":""""_userclasses_"""",1:$$QADD^%ZS(userclasses,""""))_")"
 ..		E  S uclsCheck="({List}"_$S(userclasses'["""":""""_userclasses_"""",1:$$QADD^%ZS(userclasses,""""))_").contains(%UserClass)"
 ..		;
 ..		I 'isPositiveList,'(uclsCheck="") S uclsCheck="'"_uclsCheck
 ..		;
 ..		I '(uclsCheck="") S auditCode=auditCode_uclsCheck_", "
 ..		;
 ..		S auditCode=auditCode_"'vfromDbSet set vauditLogSeq = $$auditLog^SQLAUDIT(""SELECT"", """_$P(td,"|",1)_""", ""SELECT * FROM "_$P(td,"|",1)
 ..		Q 
 .	Q 
 ;
 I '(fkeys="") D
 .	;
 .	I auditSelect S auditCode=auditCode_" WHERE "
 .	;
 .	F i=1:1:$S((fkeys=""):0,1:$L(fkeys,",")) D
 ..		S lvpmNoOpt(i_"*")="v"_i
 ..		S lvpmOpt(i_"*")="v"_i
 ..		S fpl=$S((fpl=""):("String v"_i),1:fpl_","_("String v"_i))
 ..		S fplOpt=$S((fplOpt=""):("String v"_i),1:fplOpt_","_("String v"_i))
 ..		S archParams=$S((archParams=""):("v"_i),1:archParams_","_("v"_i))
 ..		S lvpmNoOpt(-2-i)=oLvn_"("_recInst_","_(-2-i)_")"
 ..		;
 ..		I auditSelect D
 ...			;
 ...			N column S column=$piece(fkeys,",",i)
 ...			;
 ...			N cd S cd=$$getPslCln^UCXDD($P(td,"|",1),column)
 ...			;
 ...			I (i>1) S auditCode=auditCode_"_"" AND "
 ...			S auditCode=auditCode_column_"="
 ...			I '(",T,U,F,"[(","_$P(cd,"|",6)_",")) S auditCode=auditCode_"""_ v"_i
 ...			E  S auditCode=auditCode_"'""_ v"_i_"_""'"""
 ...			Q 
 ..		Q 
 .	;
 .	I auditSelect S auditCode=auditCode_", """")"
 .	Q 
 ;
 ; In case using audit logging, add fromDbSet parameter to formal list
 I '($P(td,"|",8)'="GTM") S fpl=$S((fpl=""):"Boolean vfromDbSet",1:fpl_","_"Boolean vfromDbSet") S fplOpt=$S((fplOpt=""):"Boolean vfromDbSet",1:fplOpt_","_"Boolean vfromDbSet")
 ;
 S lvpmNoOpt(-1)=oLvn_"("_recInst_",-1)"
 S lvpmNoOpt(-2)=oLvn_"("_recInst_",-2)"
 ;
 S lvpmOpt(-2)="v2out" S fplOpt=$S((fplOpt=""):("Number "_lvpmOpt(-2)),1:fplOpt_","_("Number "_lvpmOpt(-2)))
 ;
 I '(archTbl="") D
 .	;
 .	S lvpmNoOpt(-99)=oLvn_"("_recInst_",-99)"
 .	S lvpmOpt(-99)="v99out" S fplOpt=$S((fplOpt=""):("String "_lvpmOpt(-99)),1:fplOpt_","_("String "_lvpmOpt(-99)))
 .	Q 
 I ($P(td,"|",8)'="GTM") D
 .	;
 .	S lvpmNoOpt(-152)=oLvn_"("_recInst_",-152)"
 .	S lvpmOpt(-152)="v152out" S fplOpt=$S((fplOpt=""):("String "_lvpmOpt(-152)),1:fplOpt_","_("String "_lvpmOpt(-152))) S fplOpt=$S((fplOpt=""):"Boolean vuse152",1:fplOpt_","_"Boolean vuse152")
 .	Q 
 ;
 S code="public static "
 F i=0,1 S methCode(i)=code_recClass_" vRCgetRecord"_i_"("_fpl_")"
 F i=2,3 S methCode(i)=code_"String vRCgetRecord"_(i-2)_"Opt"_"("_fplOpt_")"
 ;
 F i=0,1 S retVal(i)=recInst S methCode(i)=methCode(i)_$C(9)_" type "_recClass_" "_retVal(i)
 I auditSelect F i=0:1:3 S methCode(i)=methCode(i)_$C(9)_" type Number vauditLogSeq"
 S loadNod=$$getRecPur^UCXDD(td)
 F i=2,3 D
 .	;
 .	I (loadNod="") S retVal(i)=""""""
 .	E  D
 ..		;
 ..		S (lvpmOpt(loadNod),retVal(i))=optRef
 ..		S methCode(i)=methCode(i)_$C(9)_" type String "_retVal(i)
 ..		Q 
 .	Q 
 ;
 ; Provide variable for %UserClass for use under bypass
 I (selectChk>0) D
 .	;
 .	; No access rights for table ~p1
 .	S selErrCode="S $ZE=""0,""_$ZPOS_"",%PSL-E-ACCESS,""_$$^MSG(6754,"""_$P(td,"|",1)_"""),$EC="",U1001,"""
 .	;
 .	F i=0:1:3 S methCode(i)=methCode(i)_$C(9)_" type String vUcls = %UserClass.get()"
 .	Q 
 ;
 ; M implementation - that's all there is for now
 F i=0:1:3 D
 .	;
 .	S methCode(i)=methCode(i)_$C(9)_" #ACCEPT DATE=02/26/2008; PGM=Dan Russell; CR=30801; Group=BYPASS"
 .	S methCode(i)=methCode(i)_$C(9)_" #BYPASS"
 .	;
 .	I ($P(td,"|",8)'="GTM") S methCode(i)=methCode(i)_$C(9)_" N vData,vEr,vRm"
 .	Q 
 ;
 I (selectChk=1) F i=0,2 S methCode(i)=methCode(i)_$C(9)_" I '$$vselectOK(0,vUcls) "_selErrCode
 ;
 F i=0,1 S methCode(i)=methCode(i)_$C(9)_$$getNewCode^UCXDD(td,recInst,1,1)
 ;
 I $$hasSetting^PSLCC(.pslPrsr,"DEBUG","DBIOCOUNT") F i=0:1:3 S methCode(i)=methCode(i)_$C(9)_" D "_$$getSetting^PSLCC(.pslPrsr,"DEBUG","DBIOCOUNT","")_"("""_$P(td,"|",1)_""",""READ"")"
 ;
 ; Initialize archive directory purpose node, get archive key
 I '(archTbl="") D
 .	;
 .	F i=0,1 S methCode(i)=methCode(i)_$C(9)_" S "_lvpmNoOpt(-99)_"="""""
 .	F i=2,3 S methCode(i)=methCode(i)_$C(9)_" S "_lvpmOpt(-99)_"="""""
 .	Q 
 ;
 ; add initial load code - strip any archive reference
 D getRecCode(td,recInst,.lvpmNoOpt,.loadNoOpt,.pslCln)
 D getRecCode(td,1,.lvpmOpt,.loadOpt,.pslCln)
 S maxOpt=$order(loadNoOpt(""),-1)
 I ($order(loadOpt(""),-1)>maxOpt) S maxOpt=$order(loadOpt(""),-1)
 F j=1:1:maxOpt D
 .	;
 .	N archref
 .	;
 .	I ($D(lvpmNoOpt(-99))#2) S archref=lvpmNoOpt(-99)
 .	E  S archref=""
 .	;
 .	I ($D(loadNoOpt(j))#2) F i=0,1 S methCode(i)=methCode(i)_$C(9)_$$vStrRep(loadNoOpt(j),"|"_archref_"|","",0,0,"")
 .	;
 .	I '(archref="") S archref=lvpmOpt(-99)
 .	;
 .	I ($D(loadOpt(j))#2) F i=2,3 S methCode(i)=methCode(i)_$C(9)_$$vStrRep(loadOpt(j),"|"_archref_"|","",0,0,"")
 .	Q 
 ;
 S methCode(0)=methCode(0)_$C(9)_" S "_lvpmNoOpt(-2)_"=1"
 S methCode(1)=methCode(1)_$C(9)_" S "_lvpmNoOpt(-2)_"='$T"
 S methCode(2)=methCode(2)_$C(9)_" S "_lvpmOpt(-2)_"=1"
 S methCode(3)=methCode(3)_$C(9)_" S "_lvpmOpt(-2)_"='$T"
 ;
 ; Append RECNOFL exception, and record mode assignment
 I (archTbl="") D
 .	;
 .	S code="S $ZE=""0,""_$ZPOS_"",%PSL-E-RECNOFL,,"_$P(td,"|",1)_""",$EC="",U1001,"""
 .	S methCode(0)=methCode(0)_$C(9)_" I $T K "_oLvn_"("_recInst_") "_code
 .	S methCode(2)=methCode(2)_$C(9)_" I $T "_code
 .	Q 
 E  D
 .	;
 .	N archKey S archKey=$$getArchiveKey^DBARCHIVE(td,1)
 .	N tdarch S tdarch=$$getPslTbl^UCXDD(archTbl,1)
 .	;
 .	F i=0:1:3 D
 ..		;
 ..		N isClsNew S isClsNew=((i#2)=1)
 ..		N isOpt S isOpt=(i>1)
 ..		;
 ..		S methCode(i)=methCode(i)_$C(9)_" I $T D  ; Try archive"
 ..		S methCode(i)=methCode(i)_$C(9)_" . N vArch"
 ..		;
 ..		S code=" . S vArch=$$getArchiveFile^Record"_$P(td,"|",1)_"("""_$P(td,"|",1)_""",1,"
 ..		S code=code_$piece(archParams,",",1,archKey)_"-1E-10)"
 ..		;
 ..		S methCode(i)=methCode(i)_$C(9)_code
 ..		S code=" . I vArch="""""
 ..		;
 ..		; If not in archive, OK to create new
 ..		I isClsNew S code=code_" Q"
 ..		S methCode(i)=methCode(i)_$C(9)_code
 ..		;
 ..		; Try to load from archive
 ..		F j=1:1:$order(loadNoOpt(""),-1) D
 ...			;
 ...			I isClsNew S code=" ."
 ...			E  S code=" . E "
 ...			;
 ...			; Load code will have ^|vobj(vOid,-99| - replace
 ...			I 'isOpt S code=code_$$vStrRep(loadNoOpt(j),lvpmNoOpt(-99),"vArch",0,0,"")
 ...			E  S code=code_$$vStrRep(loadOpt(j),lvpmOpt(-99),"vArch",0,0,"")
 ...			S methCode(i)=methCode(i)_$C(9)_code
 ...			Q 
 ..		;
 ..		I isClsNew S code=" . ;"
 ..		E  S code=" . I $T K vobj(vOid) S $ZE=""0,""_$ZPOS_"",%PSL-E-RECNOFL,,"_$P(td,"|",1)_""",$EC="",U1001,"""
 ..		S methCode(i)=methCode(i)_$C(9)_code
 ..		;
 ..		; Update archive directory purpose node even if clsNew=1 and
 ..		; no record since this record would have been in archive range
 ..		I 'isOpt S methCode(i)=methCode(i)_$C(9)_" . S "_lvpmNoOpt(-99)_"=vArch"
 ..		E  S methCode(i)=methCode(i)_$C(9)_" . S "_lvpmOpt(-99)_"=vArch"
 ..		;
 ..		; Done earlier and won't change if clsNew = 0
 ..		I (i=3) S methCode(i)=methCode(i)_$C(9)_" . S "_lvpmOpt(-2)_"='$T"
 ..		Q 
 .	Q 
 ;
 F j=1:1:$S((fkeys=""):0,1:$L(fkeys,",")) D
 .	;
 .	F i=0:1:3 D
 ..		;
 ..		I (i<2) S methCode(i)=methCode(i)_$C(9)_" S "_lvpmNoOpt(-2-j)_"=v"_j
 ..		;else  set methCode(i) = methCode(i)_ TAB_ lvpmOpt( -2-j)_ "=v"_ j
 ..		;
 ..		Q:'($P(td,"|",8)'="GTM") 
 ..		Q:(+i'=+1) 
 ..		;
 ..		S cd=$$caPslCln^UCXDD(.pslCln,$P(td,"|",1)_"."_$piece(fkeys,",",j),.pslTbl)
 ..		N updOvh S updOvh=$$getUpdOvh^UCXDD(cd,td,retVal(i),$P(td,"|",16),2)
 ..		S set161=set161_$piece(updOvh,$char(9),2)
 ..		S init161=$$getInitCode^UCXDD(td,retVal(i),0)
 ..		Q 
 .	Q 
 ;
 I '(set161="") D
 .	;
 .	; Use function form if code is too long
 .	I '($ZLENGTH(set161)+20'>1980) D
 ..		;
 ..		S set161=""
 ..		F j=1:1:$S((fkeys=""):0,1:$L(fkeys,",")) D
 ...			;
 ...			S cd=$$caPslCln^UCXDD(.pslCln,$P(td,"|",1)_"."_$piece(fkeys,",",j),.pslTbl)
 ...			N updOvh S updOvh=$$getUpdOvh^UCXDD(cd,td,retVal(1),$P(td,"|",16),3)
 ...			S set161=set161_$piece(updOvh,$char(9),2)
 ...			Q 
 ..		Q 
 .	;
 .	I '(init161="") D
 ..		;
 ..		S methCode(1)=methCode(1)_$C(9)_" I vEr=100 do"
 ..		S methCode(1)=methCode(1)_$C(9)_"  . "_init161
 ..		S methCode(1)=methCode(1)_$C(9)_"  . "_set161
 ..		Q 
 .	E  S methCode(1)=methCode(1)_$C(9)_" I vEr=100 "_set161
 .	;
 .	I '(fkeys="") S methCode(1)=methCode(1)_$C(9)_" E "_$$getUpdKey^UCXDD(td,recInst,.lvpmNoOpt)
 .	Q 
 ;
 I ($P(td,"|",8)'="GTM") D
 .	;
 .	F i=0,1 I '((i=1)&'(set161="")) S methCode(i)=methCode(i)_$C(9)_$$getUpdKey^UCXDD(td,recInst,.lvpmNoOpt)
 .	S methCode(2)=methCode(2)_$C(9)_" I $G(vuse152)"_$$getUpdKey^UCXDD(td,retVal(2),.lvpmOpt)
 .	S methCode(3)=methCode(3)_$C(9)_" E  I $G(vuse152)"_$$getUpdKey^UCXDD(td,retVal(3),.lvpmOpt)
 .	Q 
 ;
 F i=0:1:3 D
 .	;
 .	I (selectChk>0) D
 ..		;
 ..		N recInst
 ..		;
 ..		S code=""
 ..		;
 ..		I (selectChk=1) D  ; select
 ...			;
 ...			S recInst=0 ; Don't need instance for select
 ...			;
 ...			I (i=1) S code=" I "_lvpmNoOpt(-2)_"=1,"
 ...			E  I (i=3) S code=" I "_lvpmOpt(-2)_"=1,"
 ...			Q 
 ..		E  D  ; selectRestrict
 ...			;
 ...			S recInst=retVal(i)
 ...			;
 ...			I ((i=0)!(i=2)) S code=" I "
 ...			E  I (i=1) S code=" I "_lvpmNoOpt(-2)_"=1,"
 ...			E  S code=" I "_lvpmOpt(-2)_"=1,"
 ...			Q 
 ..		;
 ..		I '(code="") D
 ...			;
 ...			I (i<2) S code=code_"'$$vselectOK("_recInst_",vUcls"
 ...			E  S code=code_"'$$vselectOptmOK(vUcls,"_recInst
 ...			;
 ...			I (i>1) F j=1:1:$S((fkeys=""):0,1:$L(fkeys,",")) S code=code_",v"_j
 ...			;
 ...			S code=code_") "_selErrCode
 ...			;
 ...			S methCode(i)=methCode(i)_$C(9)_code
 ...			Q 
 ..		Q 
 .	;
 .	S methCode(i)=methCode(i)_$C(9)_" #ENDBYPASS"
 .	I auditSelect S methCode(i)=methCode(i)_$C(9)_auditCode
 .	; Avoid warning on vOid being undefined
 .	I (i<2) S methCode(i)=methCode(i)_$C(9)_" #ACCEPT DATE=02/26/2008; PGM=Dan Russell; CR=30801; Group=SCOPE"
 .	S methCode(i)=methCode(i)_$C(9)_" quit "_retVal(i)
 .	Q 
 ;
 S code=""
 F i=0:1:3 S code=code_""_$C(9)_methCode(i)_$C(9)
 ;
 Q $E(code,1,$L(code)-1)
 ;
 ; ---------------------------------------------------------------------
getRecCode(tblDes,recInst,lvpm,mcd,clnDes) ; PSLColumn cache /NOREQ/MECH=REFARR:RW
 N fkeys S fkeys=$P(tblDes,"|",3)
 N i
 N nodes ; nodes that need to be pre-loaded
 N qid1code ; code that deals with QID1
 N tbl S tbl=$P(tblDes,"|",1) ; DQ table name
 N vsub ; variable substitutes for SQL engine
 ;
 F i=1:1:$S((fkeys=""):0,1:$L(fkeys,",")) S vsub(tbl_"."_$piece(fkeys,",",i))=$$lvpm^UCXDD(recInst,i_"*",.lvpm)
 ;
 I ($D(lvpm(-1))#2) S nodes(-1)=lvpm(-1)
 N isPc S isPc=0
 I $$getSetting^PSLCC(.pslPrsr,"boot","restrictionlevel",0)<2 S isPc=$$getRecQid1(tblDes,recInst,.lvpm,,.vsub,.nodes,.qid1code)
 K nodes(-1)
 ;
 N base S base=0
 N xnd S xnd=$$getRecPur^UCXDD(tblDes)
 N nod S nod=""
 F  S nod=$order(nodes(nod)) Q:nod=""  D
 .	I nod'=xnd S base=base+1 S mcd(base)=$$getLodCode^UCXDD(tblDes,recInst,nod,1,0,.lvpm)
 .	Q 
 ;
 I '(xnd="") D
 .	N code S code=$$getDataNode^UCXDD(tblDes,recInst,xnd,1,.lvpm)
 .	F i=1:1:$L(code,$char(9)) S mcd(base+i)=$piece(code,$char(9),i)
 .	Q 
 ;
 S base=$order(mcd(""),-1)
 F i=1:1:$get(qid1code) S mcd(base+i)=qid1code(i)
 ;
 N code
 I $D(qid1code)>9,'isPc S code=" E "
 E  S code=""
 I ($P(tblDes,"|",7)="") S base=$order(mcd(""),-1)+1 S mcd(base)=code_$$getExisCode^UCXDD(tblDes,recInst,.lvpm)
 ;
 Q 
 ;
 ; ---------------------------------------------------------------------
getRecQid1(tblDes,recInst,lvpm,ptable,vsub,nodes,mcode) ; generated code /MECH=REAFARR:RW
 N tbl S tbl=$P(tblDes,"|",1) ; DQ table name
 N whr ; result from VIEW^SQLM
 ;
 N join N cmp N fsn N rng N tok N vdd
 N ER S ER=0 N RM S RM="" ; good old error mechanism
 ;
 N rs,vos1,vos2,vos3,vos4  N V1 S V1=tbl S rs=$$vOpen1()
 N isParent S isParent=''$G(vos1)
 I ($D(nodes(-1))#2) D
 .	F  Q:'$$vFetch1()  D
 ..  N ctable S ctable=rs
 ..		N ctd S ctd=$$getPslTbl^UCXDD(ctable,0)
 ..		;
 ..		N dummy S dummy=$$getRecQid1(ctd,recInst,.lvpm,tbl,.vsub,.nodes,.mcode)
 ..		Q 
 .	Q 
 ;
 I ($P(tblDes,"|",8)'="GTM"),($P(tblDes,"|",7)="") Q isParent
 ;
 N vxp S vxp=-1 ; unused, but required by VIEW^SQLM
 D fsn^SQLDD(.fsn,tbl) ; unused, but required by VIEW^SQLM
 D VIEW^SQLM(tbl,.whr,.fsn) I +ER'=0 D ERROR^UCGM($get(RM)) Q isParent
 ;
 I $D(whr)<9 Q isParent
 ;
 N c ; qualified column name
 N cd ; column descriptor
 N i N j N n ; iterators
 N nod ; current node of qcn in whr()
 N z ; scratch, data
 ;
 S n=""
 F  S n=$order(whr(n)) Q:n=""  F i=1,2 D
 .	S z=$piece(whr(n),$char(9),i)
 .	F j=2:2:$L(z,$char(1)) D
 ..		S c=$piece(z,$char(1),j)
 ..		I ($D(vsub(c))#2) Q 
 ..		S cd=$$getPslCln^UCXDD($piece(c,"."),$piece(c,".",2))
 ..		;
 ..		S vsub(c)=$$getCurExpr^UCXDD(cd,recInst,0,.lvpm)
 ..		;
 ..		S nod=$$getCurNode^UCXDD(cd,0)
 ..		I nod'="",nod'<0,'($D(nodes(nod))#2) S nodes(nod)=""
 ..		Q 
 .	Q 
 ;
 N ptr S ptr=$get(mcode) ; skip current data in mcode()
 ;
 D QUERY^SQLA(""_$translate($J("",$order(whr(""),-1)-0)," ",1),.whr,.mcode,.vsub,tbl,,0,0)
 ;
 I ($D(ptable)#2),(mcode>(ptr+1)) D ERROR^UCGM("Child table query (DBTBL1.QID1) invalid") Q isParent
 ;
 F i=ptr+1:1:$get(mcode) D
 .	I mcode(i)[" S vsql=-1" S mcode(i)=$piece(mcode(i)," S vsql=-1")
 .	S mcode(i)=" "_mcode(i)
 .	I i>(ptr+1),$E(mcode(i),1,4)'=" E  " S mcode(i)=" E "_mcode(i)
 .	I '($D(ptable)#2) Q 
 .	;
 .	S mcode(i)=$piece(mcode(i),"'")_$piece(mcode(i),"'",2,999)_" S "_nodes(-1)_"=""Record"_tbl_""""
 .	Q 
 ;
 Q isParent
 ;
 ; ---------------------------------------------------------------------
getSchCln ; void; method Db.getSchemaColumn(String,String)
 S return="$$getSchCln^UCXDD("_actual(1)_","_actual(2)_")"
 Q 
 ;
 ; ---------------------------------------------------------------------
getSchTbl ; void; method Db.getSchemaTable(String)
 S return="$$getSchTbl^UCXDD("_actual(1)_")"
 Q 
 ;
 ; ---------------------------------------------------------------------
hasQual(expr,val) ; qualifiers that shall occur (*2)
 I (expr="") Q 0
 I '$$isLit^UCGM(expr) Q 0
 S expr=$$QSUB^%ZS(expr,"""")
 I expr="" Q 0
 I $E(expr,1)'="/" S expr="/"_expr
 ;
 N qual S qual=expr_"/" ; standardized with trailing "/"
 S expr=$S(expr'["""":""""_expr_"""",1:$$QADD^%ZS(expr,"""")) ; standardized quoted literal
 ;
 I val_"/"=qual Q 1
 ;
 N ret S ret=1
 N i
 ;
 F i=2:1:$L(val,"/") I qual'[("/"_$piece(val,"/",i)_"/") S ret=0 Q 
 ;
 Q ret
 ;
 ; ---------------------------------------------------------------------
insert ; 
 ;
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 D WARNDEP^UCGM(2.6,0,"Db.insert() - use Db.getRecord(,,1) or Class.new() and Record.save()")
 ;
 N table S table=$$QSUB^%ZS(actual(1),"""") ; Table name
 N columns S columns=$$QSUB^%ZS(actual(2),"""") ; Column names
 N values S values=$$QSUB^%ZS(actual(3),"""") ; Column values
 N qual S qual=actual(4) ; filer qualifiers
 N td S td=$$caPslTbl^UCXDD(.pslTbl,table,0)
 ;
 I values[":" S values=$$mapPSLvar(values)
 ;
 N buf S buf=$$vopenBuf("()","INSERT INTO "_table_" "_columns_" VALUES "_values)
 ;
 ; Instantiate a new record
 D vaddBuff(buf,"type Record"_table_" vIns = Class.new(""Record"_table_""")")
 ;
 ; turn change auditing on
 D vaddBuff(buf,"do vIns.setAuditFlag(1)")
 ;
 ; set all columns into the new record as defined by columns and values
 ; parameters of the method
 N nextval S nextval="" N currval S currval="" N prop N value
 N I
 ;
 F I=1:1:$L(columns,",") D
 .	S prop=$piece(columns,",",I)
 .	I prop["." S prop=$piece(prop,".",2)
 .	;
 .	S value=$piece(values,",",I)
 .	I $ZCONVERT(value,"U")["NEXTVAL" S nextval=prop Q 
 .	I $ZCONVERT(value,"U")["CURRVAL" S currval=prop Q 
 .	I ((","_$P(td,"|",3)_",")[(","_prop_",")) S nextval(prop)=value
 .	I $E(value,1)=":" S value=$E(value,2,1048575)
 .	I $E(value,1)="'" S value=""""_$E(value,2,$L(value)-1)_""""
 .	E  I value?.P S value=""""_value_""""
 .	D vaddBuff(buf,"set vIns."_$ZCONVERT(prop,"L")_" = "_value)
 .	Q 
 ;
 I nextval'=""!(currval'="") D
 .	N where S where="" N i S i=""
 .	F  S i=$order(nextval(i)) Q:i=""  S where=where_","_i_"="_nextval(i)
 .	I nextval'="" D vaddBuff(buf,"set vIns."_$ZCONVERT(nextval,"L")_" = Db.nextVal( """_table_""", """_$E(where,2,100)_""")") Q 
 .	D vaddBuff(buf,"set vIns."_$ZCONVERT(currval,"L")_" = Db.currVal( """_table_""", """_$E(where,2,100)_""")")
 .	Q 
 ;
 D vaddBuff(buf,"do vIns.save("_qual_")")
 D vaddBuff(buf,"quit")
 ;
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 D autoERRM^UCGM()
 ;
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 S return=$$findSubr^UCGM("DbIns","") ; Get next tag name
 D INSERT^UCMETHOD(buf,return,"void")
 S return=return_"()"
 K vobj(+$G(buf)) Q 
 ;
 ; ---------------------------------------------------------------------
isDefined ; void; method Db.isDefined
 ;
 N expr
 N from S from=actual(1)
 N where S where=actual(2)
 N count S count=$$QSUB^%ZS(actual(3),"""")
 ;
 ; Determine if dynamic
 F expr=from,where,count I '(expr=""),'$$isLit^UCGM(expr) Q 
 I   D isDefDyn(from,where,count) Q 
 ;
 S from=$$QSUB^%ZS(from,"""")
 S where=$$QSUB^%ZS(where,"""")
 I '(count=""),'(count=+count) D ERROR^UCGM("matchCount must be Number") Q 
 ;
 N table S table=$piece(from,",")
 N td S td=$$caPslTbl^UCXDD(.pslTbl,table,1)
 N fkeys S fkeys=$P(td,"|",3)
 ;
 I $get(isDirctv) D addSysmap^PSLParser(.pslPrsr,"#IF","Db.isDefined",table,$piece(fkeys,",",$S((fkeys=""):0,1:$L(fkeys,","))))
 ;
 ; CUVAR etc. on MBD
 I (fkeys=""),'($P(td,"|",8)'="GTM") S return="$D("_$piece($P(td,"|",2),"(")_")" Q 
 ;
 I where'[" " S where=$$akey2sql(where,fkeys) ; Support legacy key syntax
 ;
 N atom N saveatom N tkeys S tkeys=","_fkeys_","
 N found N ptr S ptr=0
 ;
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 F  S atom=$$ATOM^%ZS(where,.ptr,"=") D  Q:ptr=0 
 .	I atom'="=" S saveatom=$$QSUB^%ZS(atom,"""")_"," Q 
 .	S found=$F(tkeys,saveatom)
 .	;
 .	I found=0 S tkeys="" Q 
 .	S $E(tkeys,found-$L(saveatom),found-2)=""
 .	Q 
 ;
 ; In two-argument form (count not supplied), all keys must be supplied
 I (count=""),$translate(tkeys,",")'="" D ERROR^UCGM("Incorrect number of keys; missing "_$translate(tkeys,","," ")) Q 
 I where[":" S where=$$mapPSLvar(where)
 ;
 I (count="") S count=1
 ;
 I ($P(td,"|",8)'="GTM") S return=$$isDefined^UCDBR(td,where,count) Q 
 ;
 ; MDB code
 ;
 S expr="DISTINCT "_fkeys_" FROM "_from
 ;
 I '(where="") S expr=expr_" WHERE "_where
 ;
 N code N exe N vsql
 N decl S decl="" ; vsqlN vars that need to be declared
 N dline S dline="" ; line that contains M $DATA()
 N label S label=$$vaddSubr("DbEx","()","min("_count_"): "_expr,1)
 ;
  S append(label,-2)="vEx"_$piece(label,"DbEx",2)
 ;
 D addCode^UCPSLSR(label," ; No vsql* lvns needed")
 N declLine S declLine=$O(append(label,""),-1)
 ;
 I count>1 S dline=0 D addCode^UCPSLSR(label," N vCnt S vCnt=0")
 ;
 ;  #ACCEPT DATE=06/18/2008; PGM=Dan Russell; CR=30801; Group=ACCESS
 D SELECT^SQL(expr,"/NOCACHE",,,,,,-1) I ER Q 
 ;
 N codPtr S codPtr=$get(vsql("P"))
 N i
 ;
 I codPtr D
 .  S append(label,-2,0)="Q 0"
 .	;
 .	I count>1,$get(vsql(0))  S append(label,-2,vsql(0))=""
 .	Q 
 ;
 F i=1:1:codPtr D
 .	S code=exe(i)
 .	;
 .	I code["'?.N",code["$$FDAT^%ZM" D addExe^UCPSLSR(label,";") Q 
 .	; SQL code addition of audit logging
 .	I code?1"N vauditseq".E D addExe^UCPSLSR(label,code) Q 
 .	I code?.E1"$G("1U.E D  Q  ; Sub host var
 ..		N lvn S lvn=$piece($piece(code,"$G(",2)," ")
 ..		N n S n=$piece($piece(code,"vsql(",2),")")
 ..		D addExe^UCPSLSR(label,";")
 ..	  S append(label,-3,n)=$E(lvn,1,$L(lvn)-1)
 ..		Q 
 .	I dline="",(code["I '($D(^")!(code["I '$D(^") S dline=$O(append(label,""),-1)+1
 .	E  I code["BYTECHAR^SQLUTL",(+dline=0) S dline=""
 .	E  S dline=0
 .	;
 .	I code["S vd" S i=codPtr Q  ; FSCW: questionable ??
 .	;
 .	D addExe^UCPSLSR(label,code)
 .	Q 
 ;
 ; derive List of lvns to NEW
 N ex
 F i=1:1:+$O(append(label,-3,""),-1) D
 .	S ex=$G(append(label,-3,i))
 .	I ex?1"vsql"1.N S decl=$S((decl=""):ex,1:decl_","_ex)
 .	Q 
 ;
 ; Cannot optimize archive enabled table
 I '($$getArchiveTable^DBARCHIVE(td)="") S dline=0
 ;
 ;if dline>0,decl.isNull() do { quit
 I dline>0,$S((decl=""):0,1:$L(decl,","))<2 D  Q 
 .	S return=$G(append(label,dline))
 .	S return=$piece($piece(return,"I '",2)," Q 0")
 .	;   #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 .	D decrLabel^UCGM(label)
 .	Q 
 ;
 N tag S tag=+$O(append(label,-2,""),-1)
 I count>1,tag=0 D  Q 
 .	S return="0"
 .	;   #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 .	D INFO^UCGM("DEAD","Db.isDefined() always 0; MatchCount '"_count_"' exceeds possible matches ")
 .	Q 
 ;
 I '(decl="")  S append(label,declLine)=" N "_decl
 ;
 S code="Q 1"
 I count>1 S code="S vCnt=vCnt+1 I vCnt="_count_" "_code
 ;
 D addExe^UCPSLSR(label,code)
 ;
 I count>1 D addCode^UCPSLSR(label," G "_$$getTag^UCPSLSR(label,$S($get(vsql(0)):vsql(0),1:codPtr)))
 ;
 S return="$$"_label_"()"
 ;
 Q 
 ;
 ; ---------------------------------------------------------------------
isDefDyn(from,where,count) ; 
 D ERROR^UCGM("Dynamic Db.isDefined() is not supported")
 Q 
 ;
 ; ---------------------------------------------------------------------
isSchCln ; void; method Db.isSchemaColumn(String,String)
 S return="$$isColumn^UCXDD("_actual(1)_","_actual(2)_")"
 Q 
 ;
 ; ---------------------------------------------------------------------
isSchTbl ; void; method Db.isSchemaTable(String)
 S return="$$isTable^UCXDD("_actual(1)_")"
 Q 
 ;
 ; ---------------------------------------------------------------------
keyVal(inc) ; void; Method Db.nextVal, currVal, nextKey, prevKey, and prevVal
 ;
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 I (inc=0)'!(inc=1) D WARNDEP^UCGM(2.7,0,"Db."_$piece("prevVal;nextKey;prevKey",";",$translate(inc,"-")))
 ;
 I inc=-1 S inc=3 ; Force equivalence of Db.prevVal() and Db.prevKey()
 ;
 N table S table=$$QSUB^%ZS(actual(1),"""")
 N td S td=$$caPslTbl^UCXDD(.pslTbl,table,1)
 N rights S rights=$$checkAccessRights^UCXDD(td,0)
 N map
 N akeys S akeys=$$akey2apl(td,"",actual(2),-1,.map)
 ;
 N fkeys S fkeys=$P(td,"|",3)
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 I (fkeys="") D ERROR^UCGM("Invalid method for table: "_table) Q 
 ;
 N acnt S acnt=-$order(map(""))-2 ; ord of last keyvalue
 N useRdb S useRdb=0 ; use RDB method for prevKey
 N k ; key iterator
 ;
 I acnt<1 S acnt=0 I inc=2!(inc=3) N vo49 S vo49="%PSL-E-INVALIDREF: missing accessKey for Db."_method,$ZE="0,"_$ZPOS_","_vo49,$EC=",U1001,"
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 I acnt=$S((fkeys=""):0,1:$L(fkeys,",")),inc=0 S return=map(-acnt-2) D warnGroup^UCGM("DEAD","Db.currVal() with all keys - will assign "_return) Q 
 I acnt=$S((fkeys=""):0,1:$L(fkeys,",")),inc=1 D
 .	;     #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 .	D warnGroup^UCGM("DEAD","Db.nextVal() with all keys - dropped "_$piece($P(td,"|",3),",",acnt)_"="_map(-acnt-2))
 .	K map(-acnt-2) S acnt=acnt-1
 .	I acnt=0 S akeys="" Q 
 .	S akeys=map(-3)
 .	F k=2:1:acnt S akeys=akeys_","_map(-k-2)
 .	Q 
 ;
 I (inc=3),'($$getArchiveTable^DBARCHIVE(td)="") D
 .	;
 .	N tdarch S tdarch=$$getPslTbl^UCXDD($$getArchiveTable^DBARCHIVE(td),1)
 .	;
 .	N archkey S archkey=$$getArchiveKey^DBARCHIVE(tdarch,0)
 .	;
 .	; Not getting to archive key level
 .	I (acnt'<archkey) S useRdb=1
 .	Q 
 ;
 I (((","_rights_",")[",select,")!((","_rights_",")[",selectRestrict,")) S useRdb=1
 ;
 I ($P(td,"|",8)'="GTM")!useRdb D  Q 
 .	N sel ; select clause (with INTERNAL names)
 .	N whr ; where clause (with DQ names)
 .	N cd ; column descriptor
 .	;
 .	I inc=0!(inc=1) D  ; Db.currVal and Db.nextVal
 ..		S cd=$$caPslCln^UCXDD(.pslCln,table_"."_$piece(fkeys,",",acnt+1),.pslTbl)
 ..		S sel="MAX("_$P(cd,"|",17)_")"
 ..		I inc=1,"TUFL"[$P(cd,"|",6) D ERROR^UCGM("Db.nextVal() invalid for data type "_$P(cd,"|",6))
 ..		S whr=""
 ..		Q 
 .	I inc=2 D  ; Db.nextKey
 ..		S cd=$$caPslCln^UCXDD(.pslCln,table_"."_$piece(fkeys,",",acnt),.pslTbl)
 ..		S sel="MIN("_$P(cd,"|",17)_")"
 ..		S whr=$P(cd,"|",2)_">:V"_acnt
 ..		S acnt=acnt-1
 ..		Q 
 .	I inc=3 D  ; Db.prevKey and Db.prevVal
 ..		S cd=$$caPslCln^UCXDD(.pslCln,table_"."_$piece(fkeys,",",acnt),.pslTbl)
 ..		S sel="MAX("_$P(cd,"|",17)_")"
 ..		S whr=$P(cd,"|",2)_"<:V"_acnt
 ..		S acnt=acnt-1
 ..		Q 
 .	;
 .	N fpl S fpl="" ; formal parameter list for sr
 .	N hvmap ; hostvar mapping
 .	;
 .	F k=1:1:acnt D
 ..		I '(whr="") S whr=whr_" AND "
 ..		S whr=whr_$piece(fkeys,",",k)_"=:V"_k
 ..		S fpl=fpl_",V"_k
 ..		Q 
 .	I '(whr="") D
 ..		I ($P(td,"|",8)'="GTM") S whr=" WHERE "_$$where^UCDBR($P(td,"|",1),whr,.hvmap)
 ..		E  S whr=" WHERE "_whr
 ..		Q 
 .	;
 .	N cmt S cmt=$P(td,"|",1)_"."_method_"#"_acnt
 .	;   #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 .	N label S label=$$findSubr^UCGM("vDb",cmt)
 .	;
 .	S return="$$"_label_"("_akeys_")"
 .	I $$hasSubr^UCGM(label) Q 
 .	;
 .	I inc=2!(inc=3) S fpl=fpl_",V"_(acnt+1)
 .	;
 .	N sr S sr=$$vaddSubr(label,"("_$E(fpl,2,1048575)_")",cmt,0)
 .	;
 .	I ($P(td,"|",8)'="GTM") D
 ..		N delim S delim=$P(td,"|",10)
 ..		N vListCd S vListCd=$$RsMsXV^UCDBRT(.hvmap,.whr,0,delim)
 ..		D addCode^UCPSLSR(sr," N vData,vEr,vRm")
 ..		D addCode^UCPSLSR(sr," S vEr=$$SELECT^%DBAPI(0,""SELECT "_sel_" FROM "_$piece($P(td,"|",9),",",1)_whr_""",$C("_delim_"),"_vListCd_",.vData,.vRm)")
 ..		D addCode^UCPSLSR(sr," I vEr<0 S $ZE=""0,""_$ZPOS_"",%PSL-E-SQLFAIL,""_$TR($G(vRm),$C(10,44),$C(32,126)),$EC="",U1001,""")
 ..		Q 
 .	E  D
 ..		D addCode^UCPSLSR(sr," N ER,RM,vData")
 ..		D addCode^UCPSLSR(sr," D SELECT^SQL("""_sel_" FROM "_$piece($P(td,"|",9),",",1)_whr_""",,,.vData)")
 ..		D addCode^UCPSLSR(sr," I $G(ER) S $ZE=""0,""_$ZPOS_"",%PSL-E-SQLFAIL,""_$TR($G(RM),$C(10,44),$C(32,126)),$EC="",U1001,""")
 ..		Q 
 .	I inc=1 D
 ..		D addCode^UCPSLSR(sr," Q vData+1")
 ..		Q 
 .	E  D addCode^UCPSLSR(sr," Q vData")
 .	Q  ; end if RDB
 ;
 ; MDB code
 N ordExt ; $ORDER() extension
 I inc=1 D
 .	S ordExt="),-1)+1" ; nextVal uses backward $order() + 1
 .	N cd S cd=$$caPslCln^UCXDD(.pslCln,table_"."_$piece(fkeys,",",acnt+1),.pslTbl)
 .	I "TUFL"[$P(cd,"|",6) D ERROR^UCGM("Db.nextVal() invalid for data type "_$P(cd,"|",6))
 .	Q 
 E  I inc=2 S ordExt="))" ; nextKey uses forward $order()
 E  S ordExt="),-1)" ; all others use backward $order()
 ;
 ; $$getGbl^UCXDD() requires map(keynum_"*")
 F k=1:1:acnt S map(k_"*")=$get(map(-k-2)) I '($D(map(-k-2))#2) N vo54 S vo54="%PSL-E-INVALIDREF: missing accessKey for Db."_method,$ZE="0,"_$ZPOS_","_vo54,$EC=",U1001,"
 ;
 ; Db.currVal on table with view restriction is handled separately
 I inc=0,'($$RsMsQID1^UCDBRT($P(td,"|",1))="") S return=$$keyValCurr(td,acnt,.map) Q 
 ;
 ; Add extra key for currVal and nextVal
 I inc=0!(inc=1) S map(acnt+1_"*")=""""""
 ;
 I '($$getArchiveTable^DBARCHIVE(td)="") D
 .	;
 .	N tdarch S tdarch=$$getPslTbl^UCXDD($$getArchiveTable^DBARCHIVE(td),1)
 .	;
 .	N archkey S archkey=$$getArchiveKey^DBARCHIVE(tdarch,0)
 .	;
 .	; Not getting to archive key level
 .	I acnt<(archkey-1) Q 
 .	;
 .	; If archkey does not exist or is null, we will use primary
 .	; archive directory, and don't need map(-99)
 .	Q:'($D(map(archkey_"*"))#2) 
 .	Q:map(archkey_"*")="""""" 
 .	;
 .	S map(-99)="$$getArchiveFile^Record"_$P(tdarch,"|",1)_"("
 .	S map(-99)=map(-99)_""""_$P(td,"|",1)_""",0,"
 .	;
 .	F k=1:1:archkey S map(-99)=map(-99)_map(k_"*")_","
 .	S map(-99)=$E(map(-99),1,$L(map(-99))-1)_")"
 .	Q 
 ;
 S return=$$getGbl^UCXDD(td,"",.map)
 S return="$O("_$E(return,1,$L(return)-1)_ordExt
 Q 
 ;
 ; ---------------------------------------------------------------------
keyValCurr(td,acnt,map) ; key value exppresions
 N exe N ER N fsn N RM N vsql N vsub ; used by SQL engine
 ;
 N k
 N whr S whr=$S(acnt>0:$piece($P(td,"|",3),",",1)_"=:V1",1:"")
 F k=2:1:acnt S whr=whr_" AND "_$piece($P(td,"|",3),",",k)_"=:V"_k
 ;
 N sql S sql="DISTINCT "_$piece($P(td,"|",3),",",acnt+1)_" FROM "_$P(td,"|",1)
 I '(whr="") S sql=sql_" WHERE "_whr
 S sql=sql_" ORDER BY "_$piece($P(td,"|",3),",",acnt+1)_" DESC"
 ;  #ACCEPT DATE=06/18/2008; PGM=Dan Russell; CR=30801; Group=ACCESS
 D SELECT^SQL(sql,,,,,,,-2) I $get(ER) D ERROR^UCGM($get(RM)) Q ""
 ;
 N i N ii N keyNum
 N code N vsqlN N keyVar
 ;
 F i=1:1:exe D
 .	S code=exe(i)
 .	I code'["S vsql(" Q 
 .	;
 .	S vsqlN=$piece(code,"=") S vsqlN="vsql("_$piece(vsqlN,"S vsql(",2)
 .	S keyVar=$piece($piece(code,"=",2)," ")
 .	I keyVar=vsqlN Q 
 .	I ($E(keyVar,1,4)="$G(V") D
 ..		S keyNum=+$piece(keyVar,"V",2)
 ..		I keyNum<1!(keyNum>acnt) Q 
 ..		S keyVar=map(keyNum_"*")
 ..		Q 
 .	;
 .	F ii=i+1:1:exe D
 ..		I keyVar["$$ARCHFILE",exe(ii)[vsqlN S exe(ii)=$$vStrRep(exe(ii),vsqlN,keyVar,0,0,"")
 ..		I exe(ii)[vsqlN S exe(ii)=$$VarSub^UCPATCH(exe(ii),vsqlN,keyVar)
 ..		Q 
 .	Q 
 S code=exe(vsql("P"))
 ;
 I code'["=$O(" D ERROR^UCGM("Compiler cannot interpret SQL") Q ""
 I code["vsql(" D ERROR^UCGM("Compiler cannot interpret SQL") Q ""
 ;
 N tok
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 S code=$$TOKEN^%ZS(code,.tok)
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 Q "$O("_$$UNTOK^%ZS($piece($piece(code,"$O(",2),") "),.tok)_")"
 ;
 ; ---------------------------------------------------------------------
LitInst(var,table,akeys,deflt,level) ; current DO level
 ;
 N keys N load N tok N v
 N i
 N td S td=$$caPslTbl^UCXDD(.pslTbl,table,0)
 ;
 S class="Record"_table
 ;
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 S akeys=$$TOKEN^%ZS(akeys,.tok)
 ;
 ;  #ACCEPT CR=27800; DATE=2007-07-19; PGM=FSCW; GROUP=DEPRECATED
 N oid S oid=+$$new^DBSDYNRA(table)
 ;
 I '(akeys="") F i=1:1:$L(akeys,",") D
 .	;   #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 .	S v=$$UNTOK^%ZS($piece(akeys,",",i),.tok)
 .	I '$$isLit^UCGM(v) D ERROR^UCGM("Literal parameter required: "_v) Q 
 .	S vobj(oid,-2-i)=$$QSUB^%ZS(v,"""")
 .	Q 
 ;
 D get^DBSDYNRA(oid,deflt)
 ;
 I level<0 D  ; Pre-code
 .	;
 .	;   #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 .	D setScope^UCGM(var,"","","LITERAL",class)
 .	;
 .	;   #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 .	D typeFldSet^UCGM(var,4,-1) ; Runtime code line
 .	;   #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 .	D typeFldSet^UCGM(var,5,oid) ; "expression"
 .	Q 
 S return=oid
 Q 
 ;
 ; ---------------------------------------------------------------------
rdb(table) ; **** DEPRECATED ****
 I '($D(table)#2) Q $$isRdb^vRuntime()
 Q $$rtIsRdb^UCXDD(table)
 ;
 ; ---------------------------------------------------------------------
select ; method Db.select; returns ResultSet
 N expr N RM N tok
 N ER S ER=0
 N select S select=actual(1)
 N from S from=actual(2)
 N where S where=actual(3)
 N orderby S orderby=actual(4)
 N groupby S groupby=actual(5)
 N parlist S parlist=actual(6)
 ;
 I $$hasQual(.parlist,"/PSLBOOT") D selBoot^UCDBR(select,from,where,orderby,groupby,parlist) Q 
 ;
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 N varPtr S varPtr=$$getNew^UCGM(var,varLevel)
 ;
 F expr=select,from,where,orderby,groupby,parlist I '(expr=""),'$$isLit^UCGM(expr) Q 
 I   D selectDyn(select,from,where,orderby,groupby,parlist) Q 
 ;
 S select=$$QSUB^%ZS(select,"""")
 S from=$$QSUB^%ZS(from,"""")
 I '(where="") S where=$$QSUB^%ZS(where,"""")
 I '(orderby="") S orderby=$$QSUB^%ZS(orderby,"""")
 I '(groupby="") S groupby=$$QSUB^%ZS(groupby,"""")
 I '(parlist="") S parlist=$$QSUB^%ZS(parlist,"""") I $E(parlist,1)'="/" S parlist="/"_parlist
 ;
 I (select="")!(from="") D ERROR^UCGM("Expression expected") Q 
 I where[":" S where=$$mapPSLvar(where) I ER Q 
 ;
 I select="*",$translate(from,"()","  ")'[" JOIN ",from'[" AS " S select=$$RsSelAll^UCDBRT(from)
 ;
 S expr=select_" FROM "_from
 I '(where="") S expr=expr_" WHERE "_where
 I '(orderby="") S expr=expr_" ORDER BY "_orderby
 I '(groupby="") S expr=expr_" GROUP BY "_groupby
 ;
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 S expr=$$SQL^%ZS(expr,.tok)
 ;
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 N untokExp S untokExp=$$UNTOK^%ZS(expr,.tok)
 I ER D ERROR^UCGM("Invalid SQL Syntax ("_untokExp_"), "_$get(RM)) Q 
 ;
 D
 .	N select N from N ref
 .	N i
 .	S select=$piece(expr," FROM ",1)
 .	S from=$piece($piece(expr," FROM ",2)," ",1)
 .	;   #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 .	S from=$$UNTOK^%ZS(from,.tok)
 .	I from["""" S from=$$QSUB^%ZS(from,"""")
 .	;
 .	F i=1:1:$L(select,",") D
 ..		S ref=$piece(select,",",i)
 ..		I ref[" " S ref=$piece(ref," ",1)
 ..		;
 ..		;    #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 ..		S ref=$$UNTOK^%ZS(ref,.tok)
 ..		I ref["""" S ref=$$QSUB^%ZS(ref,"""")
 ..		I ref["."
 ..		E  S ref=from_"."_ref
 ..		;    #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 ..		D addXref^UCGM("P0",ref,"")
 ..		Q 
 .	Q 
 ;
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 I $$getScope^UCGM(var)="LITERAL" D LitOpen^UCRESULT(var,select,from,where,orderby,groupby,parlist) Q 
 ;
 I $$RsRdb^UCDBRT(from) D select^UCDBR(select,from,where,orderby,groupby,parlist) Q 
 ;
 ; MDB only --------------------------------
 N exe N vsql N vsub
 ;
 N i
 N split
 ;
 I untokExp["""" S untokExp=$$QSUB^%ZS(untokExp,"""")
 D splitCode^UCGMC(untokExp,0," ,",.split)
 N openLbl S openLbl=$$vaddSubr("Open","()",split(1),1)
 F i=2:1:$order(split(""),-1) D addCode^UCPSLSR(openLbl," ; "_split(i))
 ;
 S return="$$"_openLbl_"()"
 ;
 N seq S seq=$translate($E(return,8,$L(return)),"()")
 N fetchLbl S fetchLbl="vFetch"_seq
 ;
 ; iteration labels for Db.select() start with vL
  S append(openLbl,-2)="vL"_seq
 ;
 S select=$$RsSelList^UCDBRT(select) ; remainder can use standard version
 ;
 D
 .	N $ET,$ES,$ZYER S $ZYER="ZE^UCGMR",$ZE="",$EC="",$ET="D:$TL>"_$TL_" rollback^vRuntime("_$TL_") Q:$Q&$ES """" Q:$ES  N voxMrk s voxMrk="_+$O(vobj(""),-1)_" G vCatch1^"_$T(+0)
 .	;   #ACCEPT DATE=06/18/2008; PGM=Dan Russell; CR=30801; Group=ACCESS
 .	D SELECT^SQL(expr,"/NOCACHE"_parlist,,,,,.tok,-1)
 .	Q 
 I ER D ERROR^UCGM("Invalid SQL Expression ("_untokExp_"), "_$get(RM)) Q 
 ;
 N ftemp S ftemp=$get(vsql("T"))
 N keyPtr S keyPtr=$get(vsql("K"))
 N codPtr S codPtr=$get(vsql("P"))
 ;
 ;  #ACCEPT CR=22719;DATE=2006-07-27;PGM=Frans S.C. Witte;GROUP=DEPRECATED
 N protect S protect=$D(vsql("prot"))>0 ; Protection enabled
 ;
 I ($D(vsql("GB"))#2) S ftemp=1 S codPtr=$order(exe(""),-1)-1-protect
 ;
 ; determine if aggregate functions are used ;6/12/03
 ;
 N isAgFunc S isAgFunc=0
 ;
 F i=1:1:$L(select,",") I $piece(select,",",i)["(",(",MIN,MAX,COUNT,AVG,SUM,"[(","_$piece($piece(select,",",i),"(")_",")) S isAgFunc=1
 ;
 N z S z=(msrc+1)_$C(9)_seq_$C(9)_ftemp_$C(9)_select
 ;
 S $piece(z,$C(9),6)=$get(vsql("D"))
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 S $piece(z,$C(9),7)=$$getScope^UCGM(var)
 ;
 I ($D(struct("s",subRou,varPtr,var))#2) D
 .	S $piece(z,$C(9),2)=""
 .	S $piece(z,$C(9),5)=seq
 .	;
 .	I $piece(struct("s",subRou,varPtr,var),$C(9),4)'=select S $piece(z,$C(9),4)=""
 .	Q 
 S struct("s",subRou,varPtr,var)=z
 ;
 D addCode^UCPSLSR(openLbl," N vOid")
 ;
 D addCode^UCPSLSR(openLbl," ;")
 N newPtrO S newPtrO=$O(append(openLbl,""),-1)
 ;
 D addCode^UCPSLSR(openLbl," S vOid=$O("_oLvn_"(""""),-1)+1")
 I ftemp D addCode^UCPSLSR(openLbl," K ^DBTMP($J,vOid)")
 ;
 D addCode^UCPSLSR(openLbl," S "_oLvn_"(vOid,0)=2")
 D addCode^UCPSLSR(openLbl," S "_oLvn_"(vOid,-1)=""ResultSet""")
 D addCode^UCPSLSR(openLbl," S "_oLvn_"(vOid,-2)=""$$"_fetchLbl_"^""_$T(+0)")
 ;
 K split
 D splitCode^UCGMC(select,0,"",.split)
 D addCode^UCPSLSR(openLbl," S "_oLvn_"(vOid,-3)="_$S(split(1)'["""":""""_split(1)_"""",1:$$QADD^%ZS(split(1),"""")))
 F i=2:2:$order(split(""),-1) D addCode^UCPSLSR(openLbl," S "_oLvn_"(vOid,-3)="_oLvn_"(vOid,-3)_"_$S(split(i)'["""":""""_split(i)_"""",1:$$QADD^%ZS(split(i),"""")))
 ;
 D addCode^UCPSLSR(openLbl," S "_oLvn_"(vOid,-4)="_$$QADD^%ZS($get(vsql("D")),""""))
 ;
 I codPtr D
 .	D addCode^UCPSLSR(openLbl," D "_$$getTag^UCPSLSR(openLbl,1))
 .  S append(openLbl,-2,1)=""
 .	I $get(vsql(0))  S append(openLbl,-2,vsql(0))=""
 .	Q 
 ;
 D addCode^UCPSLSR(openLbl," Q vOid")
 D addCode^UCPSLSR(openLbl," ;")
 ;
 F i=0:1:keyPtr  S append(openLbl,-3,i)=oLvn_"(vOid,"_i_")"
 ;
 ; Add line that announces end-of-result (using tag 0)
  S append(openLbl,-2,0)=""
 D addCode^UCPSLSR(openLbl,$$getTag^UCPSLSR(openLbl,0)_" S "_oLvn_"(vOid,0)=0 Q")
 ;
 N x
 F i=1:1:codPtr D
 .	S x=exe(i)
 .	;
 .	I ftemp D
 ..		I x["sqlcur" S x=$$VarSub^UCPATCH(x,"sqlcur","vOid")
 ..		I x["^DBTMP(%TOKEN" S x=$$VarSub^UCPATCH(x,"^DBTMP(%TOKEN","^DBTMP($J")
 ..		Q 
 .	;
 .	I x["$$vselectAccess^Record" D
 ..		;
 ..		N tbl S tbl=$piece($piece(x,"^Record",2),"(",1)
 ..		;
 ..		S x=$piece(x," S ER=1",1)_" S $ZE=""0,""_$ZPOS_"",%PSL-E-ACCESS,""_$TR($$^MSG(6754,"""_tbl_"""),$C(10,44),$C(32,126)),$EC="",U1001,"""
 ..		Q 
 .	;
 .	; Strip the following host variable tests (assumes $G() is at the end !!!!)
 .	I x["S ER=1" D
 ..		S x=$piece(x," ",1,2)
 ..		I x["$G(" S x=$piece(x,"$G(",1)_$piece(x,"$G(",2,999) S x=$E(x,1,$L(x)-1)
 ..		Q 
 .	E  I x["'?.N" S x=";"
 .	;
 .	D addExe^UCPSLSR(openLbl,x)
 .	Q 
 ;
 D addExe^UCPSLSR(openLbl,"Q")
 ;
 N hvO S hvO=+$O(append(openLbl,-3,""),-1)
 ;
 D addCode^UCPSLSR(openLbl," ;")
 D addCode^UCPSLSR(openLbl,fetchLbl_"(vOid) ;")
 D addCode^UCPSLSR(openLbl," ;")
 I protect D addCode^UCPSLSR(openLbl," N vd,vi ;=noOpti")
 ;
 D addCode^UCPSLSR(openLbl," ;")
 N newPtrF S newPtrF=$O(append(openLbl,""),-1)
 ;
 I $get(vsql(0)),'$get(vsql("O")) D
 .	D addCode^UCPSLSR(openLbl," I "_oLvn_"(vOid,0)=1 D "_$$getTag^UCPSLSR(openLbl,vsql(0)))
 .	D addCode^UCPSLSR(openLbl," I "_oLvn_"(vOid,0)=2 S "_oLvn_"(vOid,0)=1")
 .	Q 
 D addCode^UCPSLSR(openLbl," ;")
 D addCode^UCPSLSR(openLbl," I "_oLvn_"(vOid,0)=0 S "_oLvn_"(vOid)="""""_$S(ftemp:" K ^DBTMP($J,vOid)",1:"")_" Q 0")
 D addCode^UCPSLSR(openLbl," ;")
 ;
 F i=codPtr+1:1:exe D
 .	S x=exe(i)
 .	I ftemp D
 ..		I x["sqlcur" S x=$$VarSub^UCPATCH(x,"sqlcur","vOid")
 ..		I x["^DBTMP(%TOKEN" S x=$$VarSub^UCPATCH(x,"^DBTMP(%TOKEN","^DBTMP($J")
 ..		Q 
 .	I x["vd",'protect S x=$$VarSub^UCPATCH(x,"vd",oLvn_"(vOid)")
 .	D addExe^UCPSLSR(openLbl,x)
 .	Q 
 ;
 I $$hasSetting^PSLCC(.pslPrsr,"DEBUG","DBIOCOUNT") D addCode^UCPSLSR(openLbl," D "_$$getSetting^PSLCC(.pslPrsr,"DEBUG","DBIOCOUNT","")_"("""_actual(2)_""",""READ"")")
 ;
 I protect D addCode^UCPSLSR(openLbl," S "_oLvn_"(vOid)=vd S "_oLvn_"(vOid,.1)=vi")
 ;
 I $get(vsql("O")) D addCode^UCPSLSR(openLbl," S "_oLvn_"(vOid,0)=0")
 ;
 I hvO>keyPtr,'isAgFunc D
 .	N i
 .	N z
 .	S z="vsql"_(keyPtr+1)
 .	F i=keyPtr+2:1:hvO S z=z_",vsql"_i
 .	;
 .  S append(openLbl,newPtrO)=" N "_z
 .	Q 
 ;
 N hvF S hvF=+$O(append(openLbl,-3,""),-1)
 I 'ftemp,hvF>keyPtr,'isAgFunc D
 .	N i
 .	N z
 .	S z="vsql"_(keyPtr+1)
 .	F i=keyPtr+2:1:hvF S z=z_",vsql"_i
 .	;
 .  S append(openLbl,newPtrF)=" N "_z
 .	Q 
 ;
 D addCode^UCPSLSR(openLbl," ;")
 D addCode^UCPSLSR(openLbl," Q 1")
 Q 
 ;
 ; ---------------------------------------------------------------------
selectDyn(select,from,where,orderby,groupby,parlist) ; Dynamic SQL statement runtime
 ;
 ;  #ACCEPT CR=27800;Date=2007-10-09;PGM=Frans S.C. Witte;Group=DEPRECATED; use of type()
 ;
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 I $$getScope^UCGM(var,varLevel)'="NEW" D ERROR^UCGM("SCOPE: Identifier must be local scope for dynamic SQL:"_var) Q 
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 N varPtr S varPtr=$$getNew^UCGM(var,varLevel)
 ;
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 D warnGroup^UCGM("DYNAMIC","SQL SELECT statement")
 ;
 I where="" S where=""""""
 I orderby="" S orderby=""""""
 I groupby="" S groupby=""""""
 I parlist="" S parlist=""""""
 ;
 N isRdb S isRdb=$$isRdb^vRuntime
 N needM S needM=1 ; assume dynamic MDB code is needed
 N needP S needP=isRdb ; is dynamic RDB code with DIP needed?
 N needR S needR=isRdb ; is dynamic RDB code needed?
 N suffix S suffix=""
 ;
 I isRdb D
 .	D XvClose^UCDBR() ; always need close cursor code
 .	;
 .	I $$isLit^UCGM(from),$$RsRdb^UCDBRT($$QSUB^%ZS(from,"""")) S needM=0
 .	;
 .	I $$isLit^UCGM(parlist),("/"_$$QSUB^%ZS(parlist,""""))'["/PROT" S needP=0
 .	;
 .	I needM+needR+needP>1 Q 
 .	;
 .	I needR S suffix="R" Q 
 .	S suffix="P" Q 
 .	Q 
 ;
 I needM D
 .	N mlvns S mlvns=",exe,sqlcur,vd,vi,vsql,vsub"
 .	N pce
 .	;
 .	F pce=2:1:$L(mlvns,",") D
 ..		N lvn S lvn=$piece(mlvns,",",pce)
 ..		;
 ..		;    #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 ..		I $$getInst^UCGM(lvn) S pce=$L(mlvns,",") D ERROR^UCGM("SCOPE: Dynamic SQL variable already used: "_lvn)
 ..		;    #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 ..		D typeCrea^UCGM(lvn,"String",varPtr,"NEW",msrc+1,"")
 ..		Q 
 .	I varPtr=(msrc+1) D  ; var is instantiated here
 ..		N f S f="N "_var
 ..		I mcode[f S mcode=$piece(mcode,f)_f_mlvns_$piece(mcode,f,2,999)
 ..		Q 
 .	E  D patchNew^UCPATCH(var,mlvns,varPtr)
 .	Q 
 ;
 N z S z=(msrc+1)_$C(9)_0_suffix_$C(9)
 N selExpr
 ;
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 I $$isLit^UCGM(select) D
 .	; select is literal (good!). Able to resolve columns
 .	;   #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 .	I select="""*""",$$isLit^UCGM(from) S select=$$QADD^%ZS($$RsSelAll^UCDBRT($$QSUB^%ZS(from,"""")),"""")
 .	S selExpr=$$RsSelList^UCDBRT(select)
 .	S z=z_$C(9)_selExpr
 .	;
 .	I $L(selExpr)>511 D
 ..		;
 ..		; Use local var if posible
 ..		N expr N lvn
 ..		S lvn="" S expr=$S(selExpr'["""":""""_selExpr_"""",1:$$QADD^%ZS(selExpr,""""))
 ..		;    #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 ..		F  S lvn=$order(type(level,lvn)) Q:lvn=""  I expr=$$getExpr^UCGM(lvn,level) Q 
 ..		;    #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 ..		I '(lvn=""),'($$getScope^UCGM(lvn)="LITERAL") S select=lvn
 ..		Q 
 .	Q 
 E  S selExpr=""
 ;
 I ($D(struct("s",subRou,varPtr,var))#2) D
 .	S $piece(z,$C(9),2)=""
 .	S $piece(z,$C(9),5)=0_suffix
 .	I $piece(struct("s",subRou,varPtr,var),$C(9),4)'=selExpr S $piece(z,$C(9),4)=""
 .	Q 
 S struct("s",subRou,varPtr,var)=z
 ;
 ;  #ACCEPT GROUP=ACCESS;CR=35741;DATE=2008-10-23;PGM=Frans S.C. Witte
 S return="$$"_"vOpen0"_suffix_"("_$S("M"[suffix:".exe,.vsql,",1:"")_select_","_from_","_where_","_orderby_","_groupby_","_parlist_","_($$getLevel^UCGM(var)-level+1)_")"
 ;
 I isRdb,suffix="" D
 .	; Generate general dispatcher
 .	I $$hasSubr^UCGM("vOpen0") Q 
 .	;
 .	N sr S sr=$$vaddSubr("vOpen0","(exe,vsql,vSelect,vFrom,vWhere,vOrderby,vGroupby,vParlist,vOff)","RDB dynamic OPEN CURSOR dispatcher",0)
 .	;
 .	D addCode^UCPSLSR(sr," I '$$RsRdb^UCDBRT(vFrom) Q $$vOpen0M(.exe,.vsql,vSelect,vFrom,vWhere,vOrderby,vGroupby,vParlist,vOff+1)")
 .	D addCode^UCPSLSR(sr," I ""/""_vParlist[""/PROT"" Q $$vOpen0P(vSelect,vFrom,vWhere,vOrderby,vGroupby,vParlist,vOff+1)")
 .	D addCode^UCPSLSR(sr," Q $$vOpen0R(vSelect,vFrom,vWhere,vOrderby,vGroupby,vParlist,vOff+1)")
 .	D addCode^UCPSLSR(sr," ;")
 .	D addCode^UCPSLSR(sr,"vFetch0(vOid) ; RDB dynamic FETCH dispatcher")
 .	D addCode^UCPSLSR(sr," I vobj(vOid,-5)=0 Q $$vFetch0M(vOid)")
 .	D addCode^UCPSLSR(sr," I $D(vobj(vOid,.1))>1 Q $$vFetch0P(vOid)")
 .	D addCode^UCPSLSR(sr," Q $$vFetch0R(vOid)")
 .	Q 
 I needM D
 .	; generate MDB dynamic select as vOpen0/vFetch0 (MDB) or vOpen0M/vFetch0M (RDB)
 .	I isRdb S suffix="M"
 .	;
 .	I $$hasSubr^UCGM("vOpen0"_suffix) Q 
 .	;
 .	N sr S sr=$$vaddSubr("vOpen0"_suffix,"(exe,vsql,vSelect,vFrom,vWhere,vOrderby,vGroupby,vParlist,vOff)","Dynamic MDB ResultSet",0)
 .	;
 .	D addCode^UCPSLSR(sr," N vOid")
 .	D addCode^UCPSLSR(sr," N ER,vExpr,mode,RM,vOpen,vTok S ER=0 ;=noOpti")
 .	D addCode^UCPSLSR(sr," ;")
 .	D addCode^UCPSLSR(sr," S vExpr=""SELECT ""_vSelect_"" FROM ""_vFrom")
 .	D addCode^UCPSLSR(sr," I vWhere'="""" S vExpr=vExpr_"" WHERE ""_vWhere")
 .	D addCode^UCPSLSR(sr," I vOrderby'="""" S vExpr=vExpr_"" ORDER BY ""_vOrderby")
 .	D addCode^UCPSLSR(sr," I vGroupby'="""" S vExpr=vExpr_"" GROUP BY ""_vGroupby")
 .	D addCode^UCPSLSR(sr," S vExpr=$$UNTOK^%ZS($$SQL^%ZS(vExpr,.vTok),vTok)")
 .	D addCode^UCPSLSR(sr," ;")
 .	D addCode^UCPSLSR(sr," S sqlcur=$O("_oLvn_"(""""),-1)+1")
 .	D addCode^UCPSLSR(sr," ;")
 .	D addCode^UCPSLSR(sr," I $$FLT^SQLCACHE(vExpr,vTok,.vParlist)")
 .	;
 .	N code S code=" E  S vOpen=$$OPEN^SQLM(.exe,vFrom,vSelect,vWhere,vOrderby,vGroupby,"
 .	S code=code_"vParlist,"
 .	S code=code_"," ; tok
 .	S code=code_"1," ; mode
 .	S code=code_"," ; vdd
 .	S code=code_"sqlcur)" ; cursor id
 .	S code=code_" I 'ER D SAV^SQLCACHE(vExpr,.vParlist) s vsql=vOpen"
 .	D addCode^UCPSLSR(sr," E  S vOpen=$$OPEN^SQLM(.exe,vFrom,vSelect,vWhere,vOrderby,vGroupby,vParlist,,1,,sqlcur) I 'ER D SAV^SQLCACHE(vExpr,.vParlist) s vsql=vOpen")
 .	;
 .	D addCode^UCPSLSR(sr," I ER S $ZE=""0,""_$ZPOS_"",%PSL-E-SQLFAIL,""_$TR($G(RM),$C(10,44),$C(32,126)),$EC="",U1001,""")
 .	D addCode^UCPSLSR(sr," ;")
 .	D addCode^UCPSLSR(sr," S vOid=sqlcur")
 .	D addCode^UCPSLSR(sr," S "_oLvn_"(vOid,0)=vsql")
 .	D addCode^UCPSLSR(sr," S "_oLvn_"(vOid,-1)=""ResultSet""")
 .	D addCode^UCPSLSR(sr," S "_oLvn_"(vOid,-2)=""$$"_"vFetch0"_suffix_"^""_$T(+0)")
 .	D addCode^UCPSLSR(sr," S "_oLvn_"(vOid,-3)=$$RsSelList^UCDBRT(vSelect)")
 .	D addCode^UCPSLSR(sr," S "_oLvn_"(vOid,-4)=$G(vsql(""D""))")
 .	D addCode^UCPSLSR(sr," S "_oLvn_"(vOid,-5)=0")
 .	D addCode^UCPSLSR(sr," Q vOid")
 .	;
 .	D addCode^UCPSLSR(sr," ;")
 .	;
 .	D addCode^UCPSLSR(sr,"vFetch0"_suffix_"(vOid) ; MDB dynamic FETCH")
 .	;
 .	D addCode^UCPSLSR(sr," ;")
 .	D addCode^UCPSLSR(sr," ; type public String exe(),sqlcur,vd,vi,vsql()")
 .	D addCode^UCPSLSR(sr," ;")
 .	D addCode^UCPSLSR(sr," I vsql=0 S "_oLvn_"(vOid)="""" Q 0")
 .	D addCode^UCPSLSR(sr," S vsql=$$^SQLF(.exe,.vd,.vi,.sqlcur)")
 .	D addCode^UCPSLSR(sr," S "_oLvn_"(vOid)=vd")
 .	D addCode^UCPSLSR(sr," S "_oLvn_"(vOid,0)=vsql")
 .	D addCode^UCPSLSR(sr," S "_oLvn_"(vOid,.1)=$G(vi)")
 .	D addCode^UCPSLSR(sr," Q vsql")
 .	Q 
 ;
 I needP D selectPR("P") ; RDB select with dataprotection
 I needR D selectPR("R") ; RDB select without dataprotection
 Q 
 ;
 ; ---------------------------------------------------------------------
selectPR(suffix) ; support subroutine to generate vOpen0P / vOpen0R
 ;
 I $$hasSubr^UCGM("vOpen0"_suffix) Q 
 ;
 N sr S sr=$$vaddSubr("vOpen0"_suffix,"(vSelect,vFrom,vWhere,vOrderby,vGroupby,vParlist,vOff)","Dynamic RDB ResultSet with"_$piece("out",";",suffix'="P")_" dataprotection",0)
 N dpi
 ;
 D addCode^UCPSLSR(sr," N vExpr,vMap ;=noOpti")
 ;
 I suffix="P" D
 .	D addCode^UCPSLSR(sr," N vDipx I (""/""_vParlist)[""/PROT"" N vQual D PARSPAR^%ZS(vParlist,.vQual),getExe^SQLPROT(vFrom,.vSelect,.vDipx,.vQual) ;=noOpti")
 .	S dpi(1)="; need data protection"
 .	Q 
 ;
 D addCode^UCPSLSR(sr," S vExpr=$$RsDyRT^UCDBRT(vSelect,vFrom,vWhere,vOrderby,vGroupby,vParlist,.vMap)")
 ;
 D selSrOpen^UCDBR(.sr,"vFetch0"_suffix,"@,vExpr,vMap,vDipx",.dpi)
 D selSrFetch^UCDBR(.sr,"vFetch0"_suffix,10,.dpi)
 Q 
 ;
 ; ---------------------------------------------------------------------
selectRecords ; method Db.selectDbSet; returns DbSet
 ;
 I (actual(1)="") D ERROR^UCGM("Table Parameter Required") Q 
 ;
 N td S td=$$caPslTbl^UCXDD(.pslTbl,$$QSUB^%ZS(actual(1),""""),0)
 N keys S keys=$P(td,"|",3)
 ;
 I (keys="") D ERROR^UCGM("Unsupported table in DbSet class: "_$P(td,"|",1)) Q 
 ;
 S actual(6)="" ; no qualifiers
 S actual(5)="" ; no GROUP BY
 S actual(4)=actual(3) ; ORDER BY from 3 to 4
 S actual(3)=actual(2) ; WHERE from 2 to 3
 S actual(2)=actual(1) ; FROM form 1 to 2
 S actual(1)=$$QADD^%ZS(keys,"""") ; SELECT from primaryKeys
 ;
 D select
 S class="DbSet"
 ;
 Q 
 ;
 ; ---------------------------------------------------------------------
sql2akey(td,where) ; 
 N strlits
 N akey
 ;
 I (where="") Q ""
 D
 .	N $ET,$ES,$ZYER S $ZYER="ZE^UCGMR",$ZE="",$EC="",$ET="D:$TL>"_$TL_" rollback^vRuntime("_$TL_") Q:$Q&$ES """" Q:$ES  N voxMrk s voxMrk="_+$O(vobj(""),-1)_" G vCatch2^"_$T(+0)
 .	N col
 .	N key
 .	N pkl S pkl=$P(td,"|",3)
 .	N pred
 .	N prnr
 .	;
 .	S akey=""
 .	;   #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 .	S where=$$TOKEN^%ZS(where,.strlits,"'")
 .	;
 .	F prnr=1:1:$L(where," AND ") D
 ..		S pred=$piece(where," AND ",prnr)
 ..		S col=$$vStrTrim($piece(pred,"="),0," ")
 ..		S pred=$$vStrTrim($E(pred,$F(pred,"="),1048575),0," ")
 ..		;
 ..		I '((","_pkl_",")[(","_col_",")) S $ZE="0,"_$ZPOS_","_"%PSL-E-INTERNAL,not a keycolumn",$EC=",U1001,"
 ..		;    #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 ..		I $$nextExpr^UCGM(pred,0,"",1)'=pred S $ZE="0,"_$ZPOS_","_"%PSL-E-INTERNAL,not a simple predicate",$EC=",U1001,"
 ..		;
 ..		S key(col)=""
 ..		I '(akey="") S akey=akey_","
 ..		S akey=akey_col_"="_pred
 ..		Q 
 .	;
 .	I prnr'=$S((pkl=""):0,1:$L(pkl,",")) S $ZE="0,"_$ZPOS_","_"%PSL-E-INTERNAL,invalid number of predicates",$EC=",U1001,"
 .	F prnr=1:1:$S((pkl=""):0,1:$L(pkl,",")) I '($D(key($piece(pkl,",",prnr)))#2) S $ZE="0,"_$ZPOS_","_"%PSL-E-INTERNAL,missing keycolumn",$EC=",U1001,"
 .	;
 .	;   #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 .	S akey=$$QADD^%ZS($$UNTOK^%ZS(akey,$$sql2psl(strlits)),"""")
 .	Q 
 Q akey
 ;
 ; ---------------------------------------------------------------------
sql2psl(lits) ; translate SQL strlits to PSL strlits
 N elm
 N lit
 ;
 F elm=1:1:$L(lits,$char(1)) D
 .	S lit=$piece(lits,$char(1),elm)
 .	Q:$E(lit,1)'="'" 
 .	S $piece(lits,$char(1),elm)=$$QADD^%ZS($$QSUB^%ZS(lit,"'"),"""")
 .	Q 
 Q lits
 ;
 ; ---------------------------------------------------------------------
update ; void; Db.update(Table_name,column_expr,where_clause,filer_qualifier)
 ;
 N table S table=$$QSUB^%ZS(actual(1),"""") ; Table name
 N updex S updex=$$QSUB^%ZS(actual(2),"""") ; Column expression
 N where S where=$$QSUB^%ZS(actual(3),"""") ; where clause
 N qual S qual=actual(4) ; Run-time qualifiers
 N sqlstat S sqlstat="UPDATE "_table_" SET "_updex
 ;
 I '(where="") S sqlstat=sqlstat_" WHERE "_where
 ;
 N auditParam S auditParam="0"
 ;
 N td S td=$$caPslTbl^UCXDD(.pslTbl,table,0)
 N buf S buf=$$vopenBuf("()",sqlstat)
 ;
 N akey S akey=$$sql2akey(td,where) N indent S indent=""
 N oneRow S oneRow='(akey="")!($P(td,"|",3)="")
 ;
 I $$usingAuditLog^SQLAUDIT D
 .	;
 .	N hostVars S hostVars=where
 .	;
 .	; Add update columns expression to where clause to capture host variables
 .	I '(updex="") D
 ..		;
 ..		N tok N upd
 ..		;
 ..		;    #ACCEPT DATE=06/18/2008; PGM=Dan Russell; CR=30801; Group=ACCESS
 ..		S upd=$$TOKEN^%ZS(updex,.tok)
 ..		;    #ACCEPT DATE=06/18/2008; PGM=Dan Russell; CR=30801; Group=ACCESS
 ..		S upd=$$UNTOK^%ZS($$vStrRep(upd,","," AND ",0,0,""),tok)
 ..		;
 ..		I (hostVars="") S hostVars=upd
 ..		E  S hostVars=hostVars_" AND ("_upd_")"
 ..		Q 
 .	;
 .	S auditParam=$$addAuditLogCode("UPDATE",buf,td,sqlstat,hostVars)
 .	Q 
 ;
 ; Build database set resultset + Db.getDbSet or Db.getRecord()
 I oneRow D
 .	D vaddBuff(buf,"type Record"_table_" vRec = Db.getRecord( """_table_""","_akey_",1)")
 .	D vaddBuff(buf,"quit:vRec.getMode()=0")
 .	Q 
 E  D
 .	S indent="  "
 .	D vaddBuff(buf,"type DbSet vSet = Db.selectDbSet( """_table_""", """_where_""")")
 .	D vaddBuff(buf,"while vSet.next() {")
 .	D vaddBuff(buf,"  type Record"_table_" vRec = vSet.getRecord( """_table_""")")
 .	Q 
 D vaddBuff(buf,indent_"do vRec.setAuditFlag(1)")
 ;
 ; Build code to deal with individual columns being updated
 N I
 N expr N value
 F I=1:1:$L(updex,",") D
 .	S expr=$piece(updex,",",I)
 .	;
 .	S value=$translate($piece(expr,"=",2),":","")
 .	;
 .	I $E(value,1)="'" S value=""""_$E(value,2,$L(value)-1)_""""
 .	E  I value?.P S value=""""_value_""""
 .	;
 .	S expr=$piece(expr,"=",1)
 .	;if $p(expr,"=",1)["." set expr=$p($p(expr,"=",1),".",2)_$p(expr,"=",2)
 .	I expr["." S expr=$piece(expr,".",2)
 .	;
 .	I value?.E1P.E,value'["%",value'["""" D
 ..		N ptr
 ..		N temp
 ..		S temp=value
 ..		S ptr=$F(temp,expr)
 ..		;set value=$s(ptr-$l(expr)=1:"",1:$e(temp,1,ptr-$l(expr)-1))_"vRec."_$e(temp,ptr-$l(expr),1000)
 ..		S value=$E(temp,1,ptr-$L(expr)-1)_"vRec."_$E(temp,ptr-$L(expr),1000)
 ..		Q 
 .	;
 .	;set $p(expr,"=",1)=$$LOWER^%ZFUNC($P(expr,"=",1))
 .	S expr=$ZCONVERT(expr,"L")
 .	;
 .	D vaddBuff(buf,indent_"set vRec."_expr_"="_value)
 .	Q 
 ;
 ; save the data and end the subroutine
 I '($P(td,"|",8)'="GTM") D
 .	;
 .	D addMSaveBypass(buf,table,"vRec",qual,auditParam)
 .	Q 
 E  D vaddBuff(buf,indent_"do vRec.save("_qual_")")
 ;
 I 'oneRow D vaddBuff(buf,"}")
 D vaddBuff(buf,"quit")
 ;
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 D autoERRM^UCGM()
 ;
 ; create label and insert code
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 S return=$$findSubr^UCGM("vDbUpd","") ; Get next tag name
 D INSERT^UCMETHOD(buf,return,"void")
 S return=return_"()"
 ;
 K vobj(+$G(buf)) Q 
 ;
 ; ---------------------------------------------------------------------
akey2sql(akey,fkeys,knum) ; void; access key to SQL whereclause
 N atom N expr N tok N val N where
 N ptr
 ;
 S knum=0 S ptr=0
 ;
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 S expr=$translate($$TOKEN^%ZS(akey,.tok)," ") S where=""
 ;
 ;  #ACCEPT CR=18163; DATE=2005-11-24; PGM=FSCW; GROUP=BYPASS
 ;*** Start of code by-passed by compiler
 ;
 for  set atom=$$ATOM^%ZS(expr,.ptr,",",tok,1) do  if ptr=0 quit
 . ;
 . if atom="," quit
 . set knum=knum+1
 . if atom="" quit
 . if where'="" set where=where_" AND "
 . ;
 . ; FSCW CR11441
 . ; In case the list contains other SQL compare operator, and no
 . ; spaces (eg single condition COLNAME>value)
 . if $tr(atom,"<>")'=atom set where=where_atom quit
 . ;
 . if atom'["=" set atom=$P(fkeys,",",knum)_"="_atom
 . set val=$P(atom,"=",2),val=$$UNTOK^%ZS(val,tok)
 . ; for backward compatibility on hostvars
 . if $E(val)'=":",'("'"[$E(val)),'$$isLit^UCGM(val) set val=":"_val
 . if $E(val)="""" set val=$$QADD^%ZS($$QSUB^%ZS(val,""""),"'")
 . set where=where_$P(atom,"=",1)_"="_val
 ;*** End of code by-passed by compiler ***
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 Q $$UNTOK^%ZS(where,tok)
 ;
 ; ---------------------------------------------------------------------
getGbl(gblref,keyvars) ; void; Return Global reference
 N i N keyNum N ptr
 N gkey N gkeys N ref N return N tok
 ;
 ;  #ACCEPT CR=18163; DATE=2005-11-24; PGM=FSCW; GROUP=BYPASS
 ;*** Start of code by-passed by compiler
 ;
 set gkeys=$$TOKEN^%ZS($P(gblref,"(",2,999),.tok)
 set return=$P(gblref,"(",1)
 ;
 ; ptr is used as character pointer in keyvars.
 set keyNum=0,ptr=0
 if gkeys'="" set return=return_"(" for i=1:1:$L(gkeys,",") do
 . ;
 . set gkey=$$UNTOK^%ZS($P(gkeys,",",i),.tok)
 . if $$isLit^UCGM(gkey) set return=return_gkey_"," quit
 . ;
 . if keyNum,ptr=0 set i=$L(gkeys,",") quit  ; Partial
 . ;
 . set keyNum=keyNum+1
 . ;;if lvn'="" S ref=lvn_keyNum
 . ;;;
 . ;;; FSCW CR14919: need to untokenize literal keys!
 . ;;;;E  S ref=$$ATOM^%ZS(akeys,.ptr,",",tok,1) I ptr S ptr=ptr+1
 . ;;E  S ref=$$ATOM^%ZS(akeys,.ptr,",",tok,0) I ptr S ptr=ptr+1
 . ;
 . ; extract next keyvar, which may be subscripted
 . ; if not yet at end-of-string, skip comma
 . set ref=$$ATOM^%ZS(keyvars,.ptr,",",,1) if ptr set ptr=ptr+1
 . ;;if $E(ref)="'" S ref=""""_$P(ref,"'",2)_""""
 . set return=return_ref_","
 ;
 if $E(return,$L(return))="," set return=$E(return,1,$L(return)-1)_")"
 ;*** End of code by-passed by compiler ***
 Q return
 ;
 ; ---------------------------------------------------------------------
mapPSLvar(expr) ; local String; Map PSL variables into SQL variables
 N i N y
 N addnew N addset N atom N code N class N lvn N tok
 ;
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 S expr=$$TOKEN^%ZS(expr,.tok,"'")
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 S expr=$$TOKEN^%ZS(expr,.tok,"""")
 S y=0 S addnew="" S addset=""
 ;
 ;  #ACCEPT CR=18163; DATE=2005-11-24; PGM=FSCW; GROUP=BYPASS
 ;*** Start of code by-passed by compiler
 for  set y=$F(expr,":",y) quit:y=0  do
 . ;
 . ; FSCW CR14185: All SQL binary operators shall delimit token
 . ;;set atom=$$ATOM^%ZS($E(expr,y,$L(expr)),0,",",tok,1)
 . set atom=$$ATOM^%ZS($E(expr,y,$L(expr)),0,"+-*/|<>=,",tok,1)
 . if $E(atom,$L(atom))=")" for  quit:$L(atom,"(")=$L(atom,")")  set atom=$E(atom,1,$L(atom)-1)
 . if $$isVar^UCGM(atom),'(atom?.e1L.e) quit
 . ;
 . ;;set code=$$valExpr^UCGM(atom,.class,,0)
 . set code=$$valExpr^UCGM(atom,.class)
 . ;
 . ; FRS - 07/01/03 - Add Support for Literal
 . if $$isLit^UCGM(code) do  quit  ; Literal type
 ..  set expr=$E(expr,1,y-2)_$$QSWP^%ZS(code,"""","'")_$E(expr,y+$L(atom),$L(expr))
 ..  set y=y+$L(atom)-$L(code)
 . ;
 . if $$isVar^UCGM(code)&'(code?.e1L.e) do  quit
 ..  set expr=$E(expr,1,y-1)_code_$E(expr,y+$L(atom),$L(expr))
 ..  set y=y+$L(atom)-$L(code)
 . ;
 . for i=1:1 set lvn="V"_i  quit:$$getNew^UCGM(lvn)=""
 . ;;do setScop^UCGM(lvn,level,msrc,"NEW")
 . do setScope^UCGM(lvn,"","","NEW","Primitive")
 . do setInst^UCGM(lvn,$$getDcLnr^UCGM,"")
 . ;
 . set expr=$E(expr,1,y-1)_lvn_$E(expr,y+$L(atom),$L(expr))
 . set y=y-$L(atom)+$L(lvn)
 . ;
 . if addnew="" set addnew=lvn,addset=lvn_"="_code
 . else  set addnew=addnew_","_lvn,addset=addset_","_lvn_"="_code
 ;
 if '(addnew="") d
 . if $e(mcode,$L(mcode))="," set mcode=$e(mcode,1,$l(mcode)-1)_"   "
 . if $e(mcode,$L(mcode)-1)="."!(mcode=$C(9)) set mcode=mcode_"   "
 . set mcode=$E(mcode,1,$L(mcode)-2)_" N "_addnew_" S "_addset_" "_$select(cmd="quit":"",1:$$UPCASE^UCGM($E(cmd))_" ")
 ;*** End of code by-passed by compiler ***
 ;
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 S expr=$$UNTOK^%ZS(expr,.tok)
 Q expr
 ;  #OPTION ResultClass ON
vSIG() ; 
 Q "61473^50060^Frans S.C. Witte^180506" ; Signature - LTD^TIME^USER^SIZE
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
vPSLopti(var) ; PSLIdentifier.optimize()
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 N varLevel S varLevel=$$getLevel^UCGM(var)
 N opti S opti=+$$getAtt^UCGM(var,varLevel,10)
 I opti>msrc S opti=0 D setOpti^UCGM(var,varLevel,0)
 Q opti=0
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
vaddSubr(p1,p2,p3,p4) ; PSL.addSubrou
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 I $get(p4) S:$E(p1,1)'="v" p1="v"_p1 S p1=$$findSubr^UCGM(p1,"")
 E  I $$hasSubr^UCGM(p1) D ERROR^UCGM("Subroutine exists: "_p1) Q p1
 D addSubr^UCGM(p1,p2,p3)
 Q p1
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
vStrTrim(object,p1,p2) ; String.trim
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 I p1'<0 S object=$$RTCHR^%ZFUNC(object,p2)
 I p1'>0 F  Q:$E(object,1)'=p2  S object=$E(object,2,1048575)
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
 ;
vOpen1() ; FID FROM DBTBL1 WHERE %LIBS='SYSDEV' AND PARFID=:V1
 ;
 ;
 S vos1=2
 D vL1a1
 Q ""
 ;
vL1a0 S vos1=0 Q
vL1a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(V1) I vos3="",'$D(V1) G vL1a0
 S vos4=""
vL1a4 S vos4=$O(^DBINDX("SYSDEV","PARFID",vos3,vos4),1) I vos4="" G vL1a0
 Q
 ;
vFetch1() ;
 ;
 ;
 I vos1=1 D vL1a4
 I vos1=2 S vos1=1
 ;
 I vos1=0 S rs="" Q 0
 ;
 S rs=$S(vos4=vos2:"",1:vos4)
 ;
 Q 1
 ;
vCatch2 ; Error trap
 ;
 N xcpt,$ET,$ES S xcpt=$ZE,$EC="",$ET="Q",$ZE=""
 S akey=""
 D ZX^UCGMR(voxMrk) Q 
 ;
vCatch1 ; Error trap
 ;
 N vSQLex,$ET,$ES S vSQLex=$ZE,$EC="",$ET="Q",$ZE=""
 S ER=1 S RM=vSQLex
 D ZX^UCGMR(voxMrk) Q 
