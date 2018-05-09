	; I18N=QUIT
	;
	; **** Routine compiled from DATA-QWIK Procedure UCDB ****
	;
	; 09/10/2007 17:32 - chenardp
	;
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
	; ---------------------------------------------------------------------
akey2apl(td,var,akeys,sparse,lvpm)	;
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
	S akeys=$$TOKEN^%ZS(akeys,.tok) ; APPEND to existing !!
	;
	F i=1:1:$S((fkeys=""):0,1:$L(fkeys,",")) S xref($piece(fkeys,",",i))=i
	;
	F  S expr=$$nextExpr^UCGM(akeys,.ptr,tok,1) D  I ptr=0 Q 
	.	;
	.	I expr="",sparse Q  ; missing key
	.	I expr="," Q 
	.	I $$vStrUC(expr)="AND" Q  ; delimiter
	.	I expr["=" D  ; key=value
	..		;
	..		S keyNam=$$vStrUC($piece(expr,"=",1))
	..		S expr=$E(expr,$L(keyNam)+2,1048575)
	..		S keyNum=$get(xref(keyNam))
	..		I (keyNum="") S $ZS="-1,"_$ZPOS_","_"%PSL-E-INVALIDREF, Invalid key column: "_keyNam X $ZT
	..		Q 
	.	E  D
	..		;
	..		S keyNum=keyNum+1
	..		S keyNam=$piece(fkeys,",",keyNum)
	..		I (keyNam="") S $ZS="-1,"_$ZPOS_","_"%PSL-E-INVALIDREF, Too many access keys" X $ZT
	..		Q 
	.	;
	.	I ($D(lvpm(-keyNum-2))#2) D ERROR^UCGM("Duplicate access key: "_keyNam)
	.	;
	.	K xref(keyNam) ; drop name that has been used
	.	;
	.	I $E(expr,1)="'",$E(expr,$L(expr))="'",$L(expr,"'")=3 S expr=$translate(expr,"'","""")
	.	;
	.	E  I $E(expr,1)=tab,$E(expr,$L(expr))=tab,$L(expr,tab)=3
	.	;
	.	E  I $$hasWrap^UCREC4OP(expr)
	.	;
	.	E  D
	..		I $E(expr,1)=":" S expr=$E(expr,2,1048575)
	..		I expr[(oLvn_"(") Q 
	..		S expr=$$valExpr^UCGM(expr) I ER S ptr=0
	..		Q 
	.	;
	.	S lvpm(-keyNum-2)=expr
	.	I $$isVar^UCGM(expr),$$isVar^UCGM(var) D
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
	Q $$UNTOK^%ZS($$RTCHR^%ZFUNC(return,","),tok)
	;
	; ---------------------------------------------------------------------
Cache	; method Cache.getRecord ; Returns Record<Class> object
	;
	N table S table=actual(1)
	I $E(table,1)="""" S table=$$QSUB^%ZS(table,"""")
	;
	S class=reClass_table
	;set PSL.actual(3) = 0
	N clsNew S clsNew=+actual(3)
	S actual(3)=1
	D getRecord
	;
	N td S td=$$caPslTbl^UCXDD(.pslTbl,table,0)
	N akeys S akeys=$$akey2apl(td,var,actual(2),0)
	N cmmnt S cmmnt="vobj()=({Cache}"_objectName_".getRecord("_table_","_clsNew_")"
	N label S label=$$findSubr^UCGM("vCa",cmmnt)
	;
	N lbGetRec S lbGetRec=$piece(return,"(")
	D incrLabel^UCGM(lbGetRec)
	;
	N dummy S dummy=$$purByOvs^UCREC4OP(subRou,var,-2)
	;
	I '$D(labels(label)) D CacheSr(td,1,label,cmmnt,objectName,clsNew,lbGetRec)
	S return="$$"_label_"("_akeys_")"
	;
	I $$vPSLopti(var)
	;
	Q 
	;
	; ---------------------------------------------------------------------
CacheDef	; method Cache.isDefined
	N tbl S tbl=actual(1)
	I $E(tbl,1)="""" S tbl=$$QSUB^%ZS(tbl,"""")
	;
	N cmt S cmt="{Cache}"_objectName_".isDefined("_actual(1)_","_actual(2)_")"
	;
	N lbl S lbl=$$findSubr^UCGM("vCaEx",cmt)
	;
	S return="$$"_lbl_"()"
	;
	I '$D(labels(lbl)) D
	.	N buf S buf=$$vopenBuf("()",cmt)
	.	N ucn S ucn=$piece(objectName,"(")
	.	D vaddBuff(buf," type public Cache "_ucn_"()")
	.	D vaddBuff(buf," type Record"_tbl_" vRec = "_objectName_".getRecord("_actual(1)_","_actual(2)_",1)")
	.	D vaddBuff(buf," quit vRec.getMode() = 1")
	.	;
	.	D INSERT^UCMETHOD(buf,lbl,"")
	.	K vobj(+$G(buf)) Q 
	;
	Q 
	;
	; ---------------------------------------------------------------------
CacheSr(td,useVobj,label,comment,cacheNm,clsNew,lbGetRec)	;
	;
	N code ; code construction
	N fpl S fpl="" ; formal parameter list
	N ftype S ftype=$P(td,"|",4) ; record type
	N isArchived S isArchived=0
	N k ; key iterator
	N lvn ; cacheNm(v1,v2,v3)
	N lvn1 ; cacheNm(v1,v2,v3,
	N lvnInit ; cache node for initial load
	N lvpm ; map passed to getRecCode^UCXDD()
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
	.	S vobjInit=$SELECT(useVobj:vobjHead_")",1:lbGetRec)
	.	Q 
	E  I '(nodInit="") D
	.	S lvnInit=lvn1_nodExis_")"
	.	S vobjInit=$SELECT(useVobj:vobjHead_","_nodExis_")",1:"vOid")
	.	Q 
	;
	S code=fpl
	I clsNew=1,'useVobj S code=$S(((code)=""):"v2out",1:(code)_","_"v2out")
	N sr S sr=$$vaddSubr(label,"("_code_")",comment,0)
	;
	I useVobj D addCode^UCPSLSR(sr," N vOid")
	;
	; Add the code to load the record from the db if not in cache
	D addCode^UCPSLSR(sr," I '$D("_lvn_") D")
	I 'useVobj D
	.	S code=""
	.	S:clsNew=0 code="v2out"
	.	S:isArchived code=$S(((code)=""):"vArch",1:(code)_","_"vArch")
	.	D:'(code="") addCode^UCPSLSR(sr," .  N "_code)
	.	Q 
	D addCode^UCPSLSR(sr," .  I $G("_cacheNm_")>"_100_" S "_ucn_"="_ucn_"-"_cacheNm_" KILL "_cacheNm)
	D addCode^UCPSLSR(sr," .  S "_cacheNm_"=$G("_cacheNm_")+1,"_ucn_"=$G("_ucn_")+1")
	I useVobj D
	.	D addCode^UCPSLSR(sr," .  S vOid="_lbGetRec_"("_fpl_")")
	.	I isArchived D addCode^UCPSLSR(sr," .  S "_lvn1_"-99)="_vobjHead_",-99)")
	.	D addCode^UCPSLSR(sr," .  S "_lvn1_"-2)="_vobjHead_",-2)")
	.	I '(nodInit="") D addCode^UCPSLSR(sr," .  S "_lvnInit_"="_vobjInit)
	.	Q 
	E  D
	.	;
	.	S code=" .  S "_lvnInit_"="_lbGetRec_"("_$S(((fpl)=""):".v2out",1:(fpl)_","_".v2out")
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
	.	D addCode^UCPSLSR(sr," I "_lvn1_"-2)=0 S $ZS=""-1,""_$ZPOS_"",%PSL-E-RECNOFL,,"_$P(td,"|",1)_""" X $ZT")
	.	Q 
	E  I 'useVobj D addCode^UCPSLSR(sr," E  S v2out="_lvn1_"-2)")
	;
	D addCode^UCPSLSR(sr," Q "_$SELECT(useVobj:"vOid",(nodInit=""):"""""",1:lvnInit))
	;
	I ftype>1 D
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
delete	; Db.delete(table_name,where_clause,filer_qualifier)
	;
	N table S table=$$vStrUC($$QSUB^%ZS(actual(1),""""))
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
	N flrLgc S flrLgc=$$getFlrLgc^UCXDD(td,"DELETE",qual,1)
	I '($P(td,"|",6)=""),'(flrLgc="") D delByFiler(td,where,akey,qual) Q 
	I '(flrLgc=""),flrLgc'="LOG" D ERROR^UCGM("Cannot generate inline DELETE code for /"_$translate(flrLgc,",","/")) Q 
	;
	I ($P(td,"|",8)'="GTM") D delRdb(td,where,akey) Q 
	;
	N lvpm
	;
	I '(akey="")!($P(td,"|",3)=""),(flrLgc="") D
	.	N dummy S dummy=$$akey2apl(td,"",akey,0,.lvpm)
	.	N k
	.	;
	.	F k=1:1:$S(($P(td,"|",3)=""):0,1:$L($P(td,"|",3),",")) S lvpm(k_"*")=lvpm(-k-2)
	.	;
	.	S mcode=$$backup^UCGM(mcode)
	.	S return=$$delMcode(td,.lvpm,postCond)
	.	Q 
	E  D
	.	N comment S comment="DELETE FROM "_$P(td,"|",1)
	.	I '(where="") S comment=comment_" WHERE "_where
	.	;
	.	N label S label=$$findSubr^UCGM("vDbDe","") ; generate new label
	.	;
	.	S return=label_"()"
	.	;
	.	I $D(labels(label)) Q 
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
	.	I '(flrLgc="") D
	..		D vaddBuff(buf," type Record"_$P(td,"|",1)_" vRec=Class.new(""Record"_$P(td,"|",1)_""")")
	..		D vaddBuff(buf," do vRec.setMode(3)")
	..		Q 
	.	;
	.	D vaddBuff(buf," type ResultSet vRs=Db.select("""_pkeys_""","""_$P(td,"|",1)_""","""_where_""")")
	.	D vaddBuff(buf," while vRs.next() do {")
	.	D vaddBuff(buf,"   "_getKeys)
	.	;
	.	I '(flrLgc="") D
	..		D vaddBuff(buf,"   "_setKeys)
	..		D vaddBuff(buf,"   #ACCEPT CR=21101;DATE=2006-05-11;PGM=FSCW;GROUP=DEPRECATED")
	..		D vaddBuff(buf,"   do ^DBSLOGIT(vRec.getPointer(),3)")
	..		Q 
	.	;
	.	D vaddBuff(buf,"   #ACCEPT CR=18163;DATE=2006-01-09;PGM=FSCW;GROUP=BYPASS")
	.	D vaddBuff(buf,"   #BYPASS")
	.	D vaddBuff(buf,$$delMcode(td,.lvpm,""))
	.	D vaddBuff(buf,"   #ENDBYPASS")
	.	D vaddBuff(buf," }")
	.	D vaddBuff(buf," do Runtime.commit()")
	.	D vaddBuff(buf," quit")
	.	;
	.	D INSERT^UCMETHOD(buf,label,"")
	.	K vobj(+$G(buf)) Q 
	Q 
	;
	; --------------------------------------------------------------------
delByFiler(td,where,acckey,qual)	;
	N comment S comment="DELETE FROM "_$P(td,"|",1)
	I '(where="") S comment=comment_" WHERE "_where
	;
	N label S label=$$findSubr^UCGM("vDbDe","") ; generate new label
	;
	S return=label_"()"
	;
	I $D(labels(label)) Q 
	;
	N buf S buf=$$vopenBuf("()",comment)
	;
	D vaddBuff(buf," do Runtime.start(""CS"")")
	I (acckey="") D
	.	D vaddBuff(buf," type DbSet vDs=Db.selectDbSet("""_$P(td,"|",1)_""","_$S(where'["""":""""_where_"""",1:$$QADD^%ZS(where,""""))_")")
	.	D vaddBuff(buf," while vDs.next() do {")
	.	D vaddBuff(buf,"   type Record"_$P(td,"|",1)_" vRec = vDs.getRecord("""_$P(td,"|",1)_""")")
	.	D vaddBuff(buf,"   do vRec.setMode(3)")
	.	D vaddBuff(buf,"   do ^"_$P(td,"|",6)_"(vRec,"_qual_",1)")
	.	D vaddBuff(buf," }")
	.	Q 
	E  D
	.	D vaddBuff(buf," type Record"_$P(td,"|",1)_" vRec = Db.getRecord("""_$P(td,"|",1)_""","_$S(acckey'["""":""""_acckey_"""",1:$$QADD^%ZS(acckey,""""))_",1)")
	.	D vaddBuff(buf," if vRec.getMode()=1 do vRec.setMode(3),^"_$P(td,"|",6)_"(vRec,"_qual_",1)")
	.	Q 
	D vaddBuff(buf," do Runtime.commit()")
	D vaddBuff(buf," quit")
	D INSERT^UCMETHOD(buf,label,"")
	;
	K vobj(+$G(buf)) Q 
	;
	; --------------------------------------------------------------------
delMcode(td,lvpm,mpc)	;
	N code S code=$$getGvn^UCXDD(td,"",.lvpm)
	;
	I $$isOneNode^UCXDD(td) Q " ZWI"_mpc_" "_code
	;
	Q " K"_mpc_" "_code
	;
	; ---------------------------------------------------------------------
delRcode(td,where,doTrunct,delBuf)	;
	D vaddBuff(delBuf,"#ACCEPT CR=21101;DATE=2006-05-11;PGM=FSCW;GROUP=BYPASS")
	D vaddBuff(delBuf,"#BYPASS")
	;
	I doTrunct D  ; Use truncate, if possible
	.	N i
	.	N tables S tables=$P(td,"|",9)
	.	;
	.	D vaddBuff(delBuf,"N vEr,vRm")
	.	;
	.	; do delBuf.add( "I 0,$TLEVEL=0 D  Q  ; TRUNCATE requires $TLEVEL=0")
	.	; do delBuf.add( ". ; Note - this code will not yet execute")
	.	; for i=1:1:tables.count() do delBuf.add( "."_$s(i>1:" I vEr'<0",1:"")_" S vEr=$$EXECUTE^%DBAPI(0,""TRUNCATE TABLE "_tables.elementAt(i)_""","""","""",.vRm)")
	.	; do delBuf.add( ". I vEr<0 S $ZS=""-1,""_$ZPOS_"",%PSL-E-SQLDELFAIL,""_$TR($G(vRm),$C(10,44),$C(32,126)) X $ZT")
	.	; do delBuf.add( ". ; Note - no commit here, since if $Tlevel=0, we do truncate")
	.	;
	.	F i=1:1:$S((tables=""):0,1:$L(tables,",")) D vaddBuff(delBuf,$S(i>1:"I vEr'<0",1:"")_" S vEr=$$EXECUTE^%DBAPI(0,""DELETE FROM "_$piece(tables,",",i)_""","""","""",.vRm)")
	.	;
	.	D vaddBuff(delBuf,"I vEr<0 S $ZS=""-1,""_$ZPOS_"",%PSL-E-SQLDELFAIL,""_$TR($G(vRm),$C(10,44),$C(32,126)) X $ZT")
	.	Q 
	E  D
	.	N hvMap
	.	N vListCd
	.	N sql S sql="DELETE FROM "_$P(td,"|",9)
	.	;
	.	D vaddBuff(delBuf,"N vEr,vRm")
	.	;
	.	I '(where="") D
	..		S where=$$where^UCDBR($P(td,"|",1),where,.hvMap)
	..		S vListCd=$$RsMsXV^UCDBRT(.hvMap,.where)
	..		S sql=sql_" WHERE "_where
	..		Q 
	.	E  S vListCd=""""""
	.	;
	.	D vaddBuff(delBuf," S vEr=$$EXECUTE^%DBAPI(0,"""_sql_""",$C(9),"_vListCd_",.vRm)")
	.	D vaddBuff(delBuf," I vEr<0 S $ZS=""-1,""_$ZPOS_"",%PSL-E-SQLDELFAIL,""_$TR($G(vRm),$C(10,44),$C(32,126)) X $ZT")
	.	Q 
	Q 
	;
	; ---------------------------------------------------------------------
delRdb(td,where,akeys)	;
	N sqlcmt S sqlcmt="DELETE FROM "_$P(td,"|",1) ; SQL delete for comment uses DQ name
	;
	I '(where="") S sqlcmt=sqlcmt_" WHERE "_where
	;
	N label S label=$$findSubr^UCGM("vDbDe","") ; generate new label
	;
	S return=label_"()"
	;
	I $D(labels(label)) Q 
	;
	N buf S buf=$$vopenBuf("()",sqlcmt)
	;
	; Case A) Delete single row with LOG ----------------
	I $P(td,"|",16),'(akeys="") D
	.	D vaddBuff(buf,"do Runtime.start(""CS"")")
	.	D vaddBuff(buf,"type Record"_$P(td,"|",1)_" vRec=Class.new(""Record"_$P(td,"|",1)_""","_$S(akeys'["""":""""_akeys_"""",1:$$QADD^%ZS(akeys,""""))_")")
	.	D vaddBuff(buf,"do vRec.setMode(3)")
	.	D vaddBuff(buf,"#ACCEPT CR=21101;DATE=2006-05-11;PGM=FSCW;GROUP=DEPRECATED")
	.	D vaddBuff(buf,"do ^DBSLOGIT(vRec.getPointer(),3)")
	.	;
	.	D delRcode(td,where,0,buf)
	.	;
	.	D vaddBuff(buf,"#ENDBYPASS")
	.	D vaddBuff(buf,"do Runtime.commit()")
	.	Q 
	;
	; Case B) Delete multiple rows with LOG ----------------
	I $P(td,"|",16),(akeys="") D
	.	;
	.	N k
	.	N pkeys S pkeys=$P(td,"|",3)
	.	N setKeys S setKeys="set "
	.	;
	.	F k=1:1:$S((pkeys=""):0,1:$L(pkeys,",")) D
	..		I k>1 S setKeys=setKeys_","
	..		S setKeys=setKeys_"vRec."_$piece(pkeys,",",k)_"=vRs.getCol("_k_")"
	..		Q 
	.	;
	.	D vaddBuff(buf,"do Runtime.start(""CS"")")
	.	D vaddBuff(buf,"type Record"_$P(td,"|",1)_" vRec=Class.new(""Record"_$P(td,"|",1)_""","_$S(akeys'["""":""""_akeys_"""",1:$$QADD^%ZS(akeys,""""))_")")
	.	D vaddBuff(buf,"do vRec.setMode(3)")
	.	D vaddBuff(buf,"type ResultSet vRs=Db.select("""_pkeys_""","""_$P(td,"|",1)_""","_$S(where'["""":""""_where_"""",1:$$QADD^%ZS(where,""""))_")")
	.	D vaddBuff(buf,"while vRs.next() do {")
	.	D vaddBuff(buf,"   "_setKeys)
	.	D vaddBuff(buf,"   #ACCEPT CR=21101;DATE=2006-05-11;PGM=FSCW;GROUP=DEPRECATED")
	.	D vaddBuff(buf,"   do ^DBSLOGIT(vRec.getPointer(),3)")
	.	D vaddBuff(buf,"}")
	.	;
	.	D delRcode(td,where,0,buf)
	.	;
	.	D vaddBuff(buf,"#ENDBYPASS")
	.	D vaddBuff(buf,"do Runtime.commit()")
	.	Q 
	;
	; Case C) Delete without LOG ----------------
	I '$P(td,"|",16) D
	.	; NOTE: doTrunct is only used to indicate "no WHERE clause" (see intro)
	.	N doTrunct S doTrunct=((where=""))
	.	;
	.	N labelc
	.	D CommitC^UCRUNTIM(.labelc) ; need to commit explicitly
	.	;
	.	D delRcode(td,where,doTrunct,buf)
	.	;
	.	D vaddBuff(buf,"I ($Tlevel=0) D "_labelc)
	.	D vaddBuff(buf,"#ENDBYPASS")
	.	Q 
	;
	; common exit
	D vaddBuff(buf,"quit")
	;
	D INSERT^UCMETHOD(buf,label,"")
	K vobj(+$G(buf)) Q 
	;
	; ---------------------------------------------------------------------
fastDel	; void; method Db.fastDelete
	;
	N akeys
	N gbl
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
	; If there were literal keys (that are now missing), do regular delete
	I (gbl["(,")!(gbl[",,")!($P(td,"|",8)'="GTM") D
	.	S actual(2)=$$akey2sql($$QSUB^%ZS(actual(2),""""),$P(td,"|",3))
	.	S actual(3)="""/NOJOURNAL/NOTRIGAFT/NOTRIGBEF"""
	.	D delete
	.	Q 
	E  D
	.	;
	.	I gbl[",)" S gbl=$piece(gbl,",)")_")"
	.	;
	.	S mcode=$$backup^UCGM(mcode)
	.	S return=" K"_postCond_" "_gbl
	.	Q 
	Q 
	;
	; ---------------------------------------------------------------------
fileQual(method,qualarg)	;
	;
	N par S par=qualarg
	;
	; standardize if literal
	I $$isLit^UCGM(par) S par=$$QADD^%ZS($$setPar^UCUTILN("",$$vStrUC($$QSUB^%ZS(par,""""))),"""")
	;
	; PREPEND command("SQLPARS") defaults (backward comp. w. p01_rel03_01)
	I '($get(commands("SQLPARS"))="") S par="$$setPar^UCUTILN("""_commands("SQLPARS")_""",par)"
	;
	; APPEND debug settings if applicable
	N debug S debug=$get(commands("DEBUG"))
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
getList	; method Db.getList returns String (comma separated list of matches)
	D ERROR^UCGM("Invalid method: Db.getList") Q 
	;
	; ---------------------------------------------------------------------
getRecCN(df)	; value of ClassNew parameter
	S df=$$QSUB^%ZS(df,"""")
	Q ''df
	;
	; ---------------------------------------------------------------------
getRecord	; method Db.getRecord; returns RecordTABLE
	N vo21
	;
	I ptr D getRecPr Q  ; 7813 - Handle nested property syntax
	;
	N td S td=$$caPslTbl^UCXDD(.pslTbl,$$QSUB^%ZS(actual(1),""""),0)
	N deflt S deflt=$$getRecCN(actual(3))
	;
	S return=$$akey2apl(td,var,actual(2),0)
	;
	I deflt<0 D warnGroup^UCGM("INTERNAL","Db.getRecord( "_actual(1)_", "_actual(2)_", "_actual(3)_")")
	;
	S class=reClass_$P(td,"|",1)
	N scope S scope=$$getAtt^UCGM(var,varLevel,3)
	;
	I scope="LITERAL" S vo21=level D LitInst(var,$P(td,"|",1),return,deflt,.vo21) S level=vo21 Q 
	;
	; find a matching vDbN() subroutine (or create a new one).
	N comment S comment=oLvn_"()=Db.getRecord("_$P(td,"|",1)_",,"_deflt_")"
	N label S label=$$findSubr^UCGM("vDb",comment)
	S return="$$"_label_"("_return_")"
	;
	I '$D(labels(label)) D getRecSr(td,"vOid",label,comment,deflt)
	;
	Q 
	;
	; ---------------------------------------------------------------------
getRecPr	; Db.getRecord has properties
	;
	I fset D ERROR^UCGM("Expression is not updateable") Q 
	;
	N table S table=$$QSUB^%ZS(actual(1),"""")
	;
	N var S var=$$nxtSym^UCGM
	N label S label="vDbGr"_$P(var,"vo",2) ; Create unique label
	;
	N buf S buf=$$vopenBuf("()","nested Db.getRecord() using "_var)
	D vaddBuff(buf," type "_reClass_table_" "_var_"=Db.getRecord("_actual(1)_","_actual(2)_","_actual(3)_")")
	D vaddBuff(buf," quit "_var_$$UNTOK^%ZS($E(atom,ptr+1,1048575),tok))
	;
	D INSERT^UCMETHOD(buf,label,"")
	;
	S return=label_"()"
	S class="String"
	S ptr=0
	;
	K vobj(+$G(buf)) Q 
	;
	; ---------------------------------------------------------------------
getRecSr(td,recInst,label,comment,clsNew)	;
	;
	N archRef S archRef="" ; archive reference
	N archTbl S archTbl=$$getArchiveTable^DBARCHIVE(td)
	N code
	N fkeys S fkeys=$P(td,"|",3)
	N fpl S fpl="" ; formal parameter list
	N i ; iterator
	N load ; load code by getRecCode^UCXDD
	N loadNod S loadNod="" ; node corresponding to the lvn
	N lvn ; scratch local var name
	N lvpm ; map passed to getRecCode^UCXDD()
	N useVobj S useVobj='(recInst=+recInst)
	N retVal
	;
	I '(fkeys="") D
	.	F i=1:1:$S((fkeys=""):0,1:$L(fkeys,",")) D
	..		I i>1 S fpl=fpl_","
	..		S fpl=fpl_"v"_i S lvpm(i_"*")="v"_i
	..		I useVobj S lvpm(-2-i)=oLvn_"("_recInst_","_(-2-i)_")"
	..		;else  set lvn=$$lvpm^UCREC4OP( recInst,-2-i, 0) if 'lvn.isNull() set lvpm(-2-i) = lvn
	..		Q 
	.	Q 
	;
	I useVobj D
	.	S lvpm(-1)=oLvn_"("_recInst_",-1)"
	.	S lvpm(-2)=oLvn_"("_recInst_",-2)"
	.	I ($P(td,"|",8)'="GTM") S lvpm(-151)=oLvn_"("_recInst_",-151)"
	.	Q 
	E  F i=-2,-99,-151 D
	.	I ($$lvpm^UCREC4OP(recInst,i,0)="") Q 
	.	S lvpm(i)="v"_(-i)_"out" S fpl=$S((fpl=""):lvpm(i),1:fpl_","_lvpm(i))
	.	Q 
	;
	N sr S sr=$$vaddSubr(label,"("_fpl_")",comment,0)
	;
	I useVobj S retVal=recInst S code=" N "_retVal
	E  D
	.	S loadNod=$$getRecPur^UCXDD(td)
	.	I (loadNod="") S retVal="""""" S code=""
	.	E  S (lvpm(loadNod),retVal)=$$lvpm^UCREC4OP(recInst,loadNod) S code=" N "_retVal
	.	Q 
	;
	I ($P(td,"|",8)'="GTM") S code=code_" N vData,vEr,vRm"
	D addCode^UCPSLSR(sr,code)
	I useVobj D addCode^UCPSLSR(sr,$$cdNewObj^UCCLASS(recInst,"""Record"_$P(td,"|",1)_""""))
	;
	I $$hasPSLSetting^UCGM("DEBUG","DBIOCOUNT") D addCode^UCPSLSR(sr," D "_$$getPSLSetting^UCGM("DEBUG","DBIOCOUNT")_"("""_$P(td,"|",1)_""",""READ"")")
	;
	; Initialize archive directory purpose node, get archive key
	I '(archTbl="") D
	.	;
	.	I '($D(lvpm(-99))#2) S lvpm(-99)="vobj(vOid,-99)"
	.	S archRef=lvpm(-99)
	.	;
	.	S code=" S "_archRef_"="""""
	.	;
	.	D addCode^UCPSLSR(sr,code)
	.	Q 
	;
	; add initial load code - strip any archive reference
	D getRecCode^UCXDD(td,recInst,.lvpm,.load,.pslCln)
	F i=1:1:$order(load(""),-1) D addCode^UCPSLSR(sr,$$vStrRep(load(i),"|"_archRef_"|","",0,0,""))
	;
	I ($D(lvpm(-2))#2) D addCode^UCPSLSR(sr," S "_lvpm(-2)_"="_$SELECT(clsNew:"'$T",1:"1"))
	;
	; Append RECNOFL exception, and record mode assignment
	I (archTbl="") D
	.	I clsNew=1 S code=" ;"
	.	E  D
	..		S code=" I $T "
	..		I useVobj S code=code_"K "_oLvn_"("_recInst_") "
	..		I clsNew=-1 S code=code_"Q """""
	..		E  S code=code_"S $ZS=""-1,""_$ZPOS_"",%PSL-E-RECNOFL,,"_$P(td,"|",1)_""" X $ZT"
	..		Q 
	.	D addCode^UCPSLSR(sr,code)
	.	Q 
	E  D
	.	;
	.	N archKey S archKey=$$getArchiveKey^DBARCHIVE(td,1)
	.	N tdarch S tdarch=$$getPslTbl^UCXDD(archTbl,1)
	.	;
	.	D addCode^UCPSLSR(sr," I $T D  ; Try archive")
	.	D addCode^UCPSLSR(sr," .  N vArch")
	.	S code=" .  S vArch=$$ARCHFILE^"_$P(tdarch,"|",6)_"("""_$P(td,"|",1)_""",1,"
	.	I archKey>1 S code=code_$piece(fpl,",",1,archKey-1)_","
	.	S code=code_$piece(fpl,",",archKey)_"-1E-10)"
	.	D addCode^UCPSLSR(sr,code)
	.	S code=" .  I vArch="""""
	.	;
	.	; If not in archive, OK to create new
	.	I clsNew=1 S code=code_" Q"
	.	D addCode^UCPSLSR(sr,code)
	.	;
	.	; Try to load from archive
	.	F i=1:1:$order(load(""),-1) D
	..		;
	..		I clsNew=1 S code=" . "
	..		E  S code=" .  E "
	..		;
	..		; Load code will have ^|vobj(vOid,-99| - replace
	..		S code=code_$$vStrRep(load(i),archRef,"vArch",0,0,"")
	..		D addCode^UCPSLSR(sr,code)
	..		Q 
	.	;
	.	; Ignore possibility of clsNew = -1 (check with Frans if OK)
	.	I clsNew=1 S code=" .  ;"
	.	E  S code=" .  I $T K vobj(vOid) S $ZS=""-1,""_$ZPOS_"",%PSL-E-RECNOFL,,"_$P(td,"|",1)_""" X $ZT"
	.	D addCode^UCPSLSR(sr,code)
	.	;
	.	; Update archive directory purpose node even if clsNew=1 and
	.	; no record since this record would have been in archive range
	.	S code=" .  S "_archRef_"=vArch"
	.	D addCode^UCPSLSR(sr,code)
	.	;
	.	; Done earlier and won't change if clsNew = 0
	.	I clsNew=1,($D(lvpm(-2))#2) D addCode^UCPSLSR(sr," .  S "_lvpm(-2)_"="_$SELECT(clsNew:"'$T",1:"1"))
	.	Q 
	;
	; code to assign keys, and -150/-151 for Rdb
	N cd
	N set150 S set150=""
	;type String set151 = ""
	N typ
	F i=1:1:$S((fkeys=""):0,1:$L(fkeys,",")) D
	.	I ($D(lvpm(-2-i))#2) D addCode^UCPSLSR(sr," S "_lvpm(-2-i)_"=v"_i)
	.	;
	.	I '($P(td,"|",8)'="GTM") Q 
	.	;
	.	I i>1  I useVobj S set150=set150_","
	.	;
	.	S cd=$$caPslCln^UCXDD(.pslCln,$P(td,"|",1)_"."_$piece(fkeys,",",i),.pslTbl)
	.	S typ=$P(cd,"|",6)
	.	;
	.	; B, and M do not occur in key
	.	; F, U, and T map to character type
	.	; $, C, D, L, and N map to numeric type
	.	;if "FUT"[typ set typ = "$$QADD^%ZS(v"_ i_ ",""'"")"
	.	;else  set typ = "(+v"_ i_ ")"
	.	;
	.	;set set151 = set151_ cd.internalColumn_ "=""_"_ typ
	.	;
	.	; -150 maintained only if using vobj()
	.	I useVobj S set150=set150_$$getRdbAsn^UCXDD(cd,retVal)
	.	Q 
	;
	I clsNew,'(set150="") D
	.	D addCode^UCPSLSR(sr," I vEr=100 S "_set150)
	.	S code=" E "
	.	Q 
	E  S code=""
	;
	;if 'set151.isNull(),lvpm(-151).exists() do sr.addCode( code_ " S "_ lvpm(-151)_ "="" WHERE "_ set151)
	I ($D(lvpm(-151))#2),'(fkeys="") D addCode^UCPSLSR(sr,code_$$getUpdKey^UCXDD(td,recInst,.lvpm))
	;
	D addCode^UCPSLSR(sr," Q "_retVal)
	Q 
	;
	; ---------------------------------------------------------------------
getSchTab	; method Db.getSchemaTable(String tablename)
	S return="$$getSchema^UCSCHEMA("_actual(1)_")"
	Q 
	;
	; ---------------------------------------------------------------------
hasQual(expr,val)	;
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
isDefined	; void; method Db.isDefined
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
	I '(count=""),'$$vStrIsNum((count)) D ERROR^UCGM("matchCount must be Number") Q 
	;
	N table S table=$piece(from,",")
	N td S td=$$caPslTbl^UCXDD(.pslTbl,table,1)
	N fkeys S fkeys=$P(td,"|",3)
	;
	I $get(isDirctv) S sysmap("#IF","Db.isDefined",table)=$piece(fkeys,",",$S((fkeys=""):0,1:$L(fkeys,",")))
	;
	; CUVAR etc. on MBD
	I (fkeys=""),'($P(td,"|",8)'="GTM") S return="$D("_$piece($P(td,"|",2),"(")_")" Q 
	;
	I where'[" " S where=$$akey2sql(where,fkeys) ; Support legacy key syntax
	;
	N atom N saveatom N tkeys S tkeys=","_fkeys_","
	N found N ptr S ptr=0
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
	D SELECT^SQL(expr,"/NOCACHE",,,,,,-1) I ER Q 
	;
	N codPtr S codPtr=$get(vsql("P"))
	N i
	;
	I codPtr D
	. S append(label,-2,0)="Q 0"
	.	;
	.	I count>1,$get(vsql(0)) S append(label,-2,vsql(0))=""
	.	Q 
	;
	F i=1:1:codPtr D
	.	S code=exe(i)
	.	I code["'?.N",code["$$FDAT^%ZM" D addExe^UCPSLSR(label,";") Q 
	.	I code?.E1"$G("1U.E D  Q  ; Sub host var
	..		N lvn S lvn=$piece($piece(code,"$G(",2)," ")
	..		N n S n=$piece($piece(code,"vsql(",2),")")
	..		D addExe^UCPSLSR(label,";")
	..	 S append(label,-3,n)=$E(lvn,1,$L(lvn)-1)
	..		Q 
	.	;
	.	; Line below must be synced with code generated by SQL engine
	.	I dline="",(code["I '($D(^")!(code["I '$D(^") S dline=$O(append(label,""),-1)+1
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
	I dline>0,(decl="") D  Q 
	.	S return=$G(append(label,dline))
	.	S return=$piece($piece(return,"I '",2)," Q 0")
	.	D decrLabel^UCGM(label)
	.	Q 
	;
	N tag S tag=+$O(append(label,-2,""),-1)
	I count>1,tag=0 D  Q 
	.	S return="0"
	.	D INFO^UCGM("DEAD","Db.isDefined() always 0; MatchCount '"_count_"' exceeds possible matches ")
	.	Q 
	;
	I '(decl="") S append(label,declLine)=" N "_decl
	;
	S code="Q 1"
	I count>1 S code="S vCnt=vCnt+1 I vCnt="_count_" "_code
	;
	D addExe^UCPSLSR(label,code)
	;
	I count>1 D addCode^UCPSLSR(label," G "_$$getTag^UCPSLSR(label,$SELECT($get(vsql(0)):vsql(0),1:codPtr)))
	;
	S return="$$"_label_"()"
	;
	Q 
	;
	; ---------------------------------------------------------------------
isDefDyn(from,where,count)	;
	D ERROR^UCGM("Dynamic Db.isDefined() is not supported")
	Q 
	;
	; ---------------------------------------------------------------------
LitInst(var,table,akeys,deflt,level)	;
	;
	N keys N load N tok N v
	N i
	N td S td=$$caPslTbl^UCXDD(.pslTbl,table,0)
	;
	S class=reClass_table
	;
	S akeys=$$TOKEN^%ZS(akeys,.tok)
	;
	S return=$$new^DBSDYNRA(table)
	;
	I '(akeys="") F i=1:1:$S((akeys=""):0,1:$L(akeys,",")) D
	.	S v=$$UNTOK^%ZS($piece(akeys,",",i),.tok)
	.	I '$$isLit^UCGM(v) D ERROR^UCGM("Literal parameter required: "_v) Q 
	.	S vobj(return,-2-i)=$$QSUB^%ZS(v,"""")
	.	Q 
	;
	D get^DBSDYNRA(return,deflt)
	;
	I level<0 D  ; Pre-code
	.	;
	.	D setScope^UCGM(var,"","","LITERAL",class)
	.	;
	.	S $piece(type(level,var),tab,4)=-1 ; Runtime code line
	.	S $piece(type(level,var),tab,5)=return
	.	Q 
	Q 
	;
	; ------------------------------------------------------------------
LitOpen(expr,qual)	;
	N apar ; OPEN^SQL expects array, not list
	N sqlsta N sqldta N sqlcnt N sqlind ; passed to OPEN^SQL
	;
	S expr=var_" AS SELECT "_expr
	;
	D PARSPAR^%ZS(qual,.apar)
	D OPEN^SQL(expr,.apar,.sqlsta,.sqldta,.sqlcnt,.sqlind)
	;
	S return=$get(sqlsta)
	;
	Q 
	;
	; ---------------------------------------------------------------------
keyVal(inc)	; void; Method Db.nextVal, currVal, nextKey, prevKey, and prevVal
	;
	I (inc=0)'!(inc=1) D WARNDEP^UCGM("Db."_$PIECE("prevVal;nextKey;prevKey",";",$TR(inc,"-")))
	;
	I inc=-1 S inc=3 ; Force equivalence of Db.prevVal() and Db.prevKey()
	;
	N table S table=$$QSUB^%ZS(actual(1),"""")
	N td S td=$$caPslTbl^UCXDD(.pslTbl,table,1)
	N map
	N akeys S akeys=$$akey2apl(td,"",actual(2),-1,.map)
	;
	N fkeys S fkeys=$P(td,"|",3)
	I (fkeys="") D ERROR^UCGM("Invalid method for table: "_table) Q 
	;
	N acnt S acnt=-$order(map(""))-2 ; ord of last keyvalue
	N useRdb S useRdb=0 ; use RDB method for prevKey
	N k ; key iterator
	;
	I acnt<1 S acnt=0 I inc=2!(inc=3) N vo32 S vo32="%PSL-E-INVALIDREF: missing accessKey for Db."_method,$ZS=($L($P(vo32,","),"-")=3*-1)_","_$ZPOS_","_vo32 X $ZT
	I acnt=$S((fkeys=""):0,1:$L(fkeys,",")),inc=0 S return=map(-acnt-2) D warnGroup^UCGM("DEAD","Db.currVal() with all keys - will assign "_return) Q 
	I acnt=$S((fkeys=""):0,1:$L(fkeys,",")),inc=1 D
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
	.	N label S label=$$findSubr^UCGM("vDb",cmt)
	.	;
	.	S return="$$"_label_"("_akeys_")"
	.	I $D(labels(label)) Q 
	.	;
	.	I inc=2!(inc=3) S fpl=fpl_",V"_(acnt+1)
	.	;
	.	N sr S sr=$$vaddSubr(label,"("_$E(fpl,2,1048575)_")",cmt,0)
	.	;
	.	I ($P(td,"|",8)'="GTM") D
	..		N vListCd S vListCd=$$RsMsXV^UCDBRT(.hvmap,.whr)
	..		D addCode^UCPSLSR(sr," N vData,vEr,vRm")
	..		D addCode^UCPSLSR(sr," S vEr=$$SELECT^%DBAPI(0,""SELECT "_sel_" FROM "_$piece($P(td,"|",9),",",1)_whr_""",$C(9),"_vListCd_",.vData,.vRm)")
	..		D addCode^UCPSLSR(sr," I vEr<0 S $ZS=""-1,""_$ZPOS_"",%PSL-E-SQLFAIL,""_$TR($G(vRm),$C(10,44),$C(32,126)) X $ZT")
	..		Q 
	.	E  D
	..		D addCode^UCPSLSR(sr," N ER,RM,vData")
	..		D addCode^UCPSLSR(sr," D SELECT^SQL("""_sel_" FROM "_$piece($P(td,"|",9),",",1)_whr_""",,,.vData)")
	..		D addCode^UCPSLSR(sr," I $G(ER) S $ZS=""-1,""_$ZPOS_"",%PSL-E-SQLFAIL,""_$TR($G(RM),$C(10,44),$C(32,126)) X $ZT")
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
	F k=1:1:acnt S map(k_"*")=$get(map(-k-2)) I '($D(map(-k-2))#2) N vo37 S vo37="%PSL-E-INVALIDREF: missing accessKey for Db."_method,$ZS=($L($P(vo37,","),"-")=3*-1)_","_$ZPOS_","_vo37 X $ZT
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
	.	I (acnt<(archkey-1)) Q 
	.	;
	.	; If archkey does not exist or is null, we will use primary
	.	; archive directory, and don't need map(-99)
	.	Q:'($D(map(archkey_"*"))#2) 
	.	Q:map(archkey_"*")="""""" 
	.	;
	.	S map(-99)="$$ARCHFILE^"_$P(tdarch,"|",6)_"("
	.	S map(-99)=map(-99)_""""_$P(td,"|",1)_""",0,"
	.	;
	.	F k=1:1:archkey S map(-99)=map(-99)_map(k_"*")_","
	.	S map(-99)=$E(map(-99),1,$L(map(-99))-1)_")"
	.	Q 
	;
	S return=$$getGbl^UCXDD(td,"",.map)
	S return="$O("_$E(return,1,$L(return)-1)_ordExt
	;
	Q 
	;
	; ---------------------------------------------------------------------
keyValCurr(td,acnt,map)	;
	N exe N ER N fsn N RM N vsql N vsub ; used by SQL engine
	;
	N k
	N whr S whr=$SELECT(acnt>0:$piece($P(td,"|",3),",",1)_"=:V1",1:"")
	F k=2:1:acnt S whr=whr_" AND "_$piece($P(td,"|",3),",",k)_"=:V"_k
	;
	N sql S sql="DISTINCT "_$piece($P(td,"|",3),",",acnt+1)_" FROM "_$P(td,"|",1)
	I '(whr="") S sql=sql_" WHERE "_whr
	S sql=sql_" ORDER BY "_$piece($P(td,"|",3),",",acnt+1)_" DESC"
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
	..		I exe(ii)[vsqlN S exe(ii)=$$varSub^UCPATCH(exe(ii),vsqlN,keyVar)
	..		Q 
	.	Q 
	S code=exe(vsql("P"))
	;
	I code'["=$O(" D ERROR^UCGM("Compiler cannot interpret SQL") Q ""
	I code["vsql(" D ERROR^UCGM("Compiler cannot interpret SQL") Q ""
	;
	N tok
	S code=$$TOKEN^%ZS(code,.tok)
	Q "$O("_$$UNTOK^%ZS($piece($piece(code,"$O(",2),") "),.tok)_")"
	;
	; ---------------------------------------------------------------------
procPar(fsn,sparse)	;
	;
	N table S table=$get(actual(1))
	N akeys S akeys=$get(actual(2))
	;
	I $E(table,1)="""" S table=$$QSUB^%ZS(table,"""")
	I $E(akeys,1)="""" S akeys=$$QSUB^%ZS(akeys,"""")
	;
	N td S td=$$caPslTbl^UCXDD(.pslTbl,table,1)
	;
	S actual(1)=table
	S actual(2)=$$akey2apl(td,$get(var),akeys,sparse)
	;
	I return'="" S return=return_"("_actual(2)_")"
	;
	I '($D(fsn(table))#2) D fsn^SQLDD(.fsn,table)
	;
	Q 
	;
	; ---------------------------------------------------------------------
rdb(table)	; deprecated Boolean
	Q $$rtIsRdb^UCXDD($get(table))
	;
	; ---------------------------------------------------------------------
select	; method Db.select; returns ResultSet
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
	N varPtr S varPtr=$$getAtt^UCGM(var,varLevel,2)
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
	S expr=$$SQL^%ZS(expr,.tok)
	N untokExp S untokExp=$$UNTOK^%ZS(expr,.tok)
	I ER D ERROR^UCGM("Invalid SQL Syntax ("_untokExp_"), "_$get(RM)) Q 
	;
	D
	.	N select N from N ref
	.	N i
	.	S select=$piece(expr," FROM ",1)
	.	S from=$piece($piece(expr," FROM ",2)," ",1)
	.	S from=$$UNTOK^%ZS(from,.tok)
	.	I from["""" S from=$$QSUB^%ZS(from,"""")
	.	;
	.	F i=1:1:$L(select,",") D
	..		S ref=$piece(select,",",i)
	..		I ref[" " S ref=$piece(ref," ",1)
	..		S ref=$$UNTOK^%ZS(ref,.tok)
	..		I ref["""" S ref=$$QSUB^%ZS(ref,"""")
	..		I ref["."
	..		E  S ref=from_"."_ref
	..		D addXref^UCGM("P0",ref,"")
	..		Q 
	.	Q 
	;
	I $$getAtt^UCGM(var,varLevel,3)="LITERAL" D LitOpen(untokExp,parlist) Q 
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
	.	N $ZT S $ZT="D ZX^UCGMR("_+$O(vobj(""),-1)_","_$ZL_",""vtrap1^"_$T(+0)_""")"
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
	S $piece(z,$C(9),7)=$$getAtt^UCGM(var,varLevel,3)
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
	. S append(openLbl,-2,1)=""
	.	I $get(vsql(0)) S append(openLbl,-2,vsql(0))=""
	.	Q 
	;
	D addCode^UCPSLSR(openLbl," Q vOid")
	D addCode^UCPSLSR(openLbl," ;")
	;
	F i=0:1:keyPtr S append(openLbl,-3,i)=oLvn_"(vOid,"_i_")"
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
	..		I x["sqlcur" S x=$$varSub^UCPATCH(x,"sqlcur","vOid")
	..		I x["^DBTMP(%TOKEN" S x=$$varSub^UCPATCH(x,"^DBTMP(%TOKEN","^DBTMP($J")
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
	D addCode^UCPSLSR(openLbl," I "_oLvn_"(vOid,0)=0"_$S(ftemp:" K ^DBTMP($J,vOid)",1:"")_" Q 0")
	D addCode^UCPSLSR(openLbl," ;")
	;
	F i=codPtr+1:1:exe D
	.	S x=exe(i)
	.	I ftemp D
	..		I x["sqlcur" S x=$$varSub^UCPATCH(x,"sqlcur","vOid")
	..		I x["^DBTMP(%TOKEN" S x=$$varSub^UCPATCH(x,"^DBTMP(%TOKEN","^DBTMP($J")
	..		Q 
	.	I x["vd",'protect S x=$$varSub^UCPATCH(x,"vd",oLvn_"(vOid)")
	.	D addExe^UCPSLSR(openLbl,x)
	.	Q 
	I protect D addCode^UCPSLSR(openLbl," S "_oLvn_"(vOid)=vd S "_oLvn_"(vOid,.1)=vi")
	;
	I $get(vsql("O")) D addCode^UCPSLSR(openLbl," S "_oLvn_"(vOid,0)=0")
	;
	I hvO>keyPtr,'isAgFunc D
	.	N i,z
	.	S z="vsql"_(keyPtr+1)
	.	F i=keyPtr+2:1:hvO S z=z_",vsql"_i
	.	;
	. S append(openLbl,newPtrO)=" N "_z
	.	Q 
	;
	N hvF S hvF=+$O(append(openLbl,-3,""),-1)
	I 'ftemp,hvF>keyPtr,'isAgFunc D
	.	N i,z
	.	S z="vsql"_(keyPtr+1)
	.	F i=keyPtr+2:1:hvF S z=z_",vsql"_i
	.	;
	. S append(openLbl,newPtrF)=" N "_z
	.	Q 
	;
	D addCode^UCPSLSR(openLbl," ;")
	D addCode^UCPSLSR(openLbl," Q 1")
	Q 
	;
	; ---------------------------------------------------------------------
selectDyn(select,from,where,orderby,groupby,parlist)	;local void; Dynamic SQL statement runtime
	;
	I $$getScope^UCGM(var,varLevel)'="NEW" D ERROR^UCGM("SCOPE: Identifier must be local scope for dynamic SQL:"_var) Q 
	N varPtr S varPtr=$$getAtt^UCGM(var,varLevel,2)
	;
	D warnGroup^UCGM("DYNAMIC","SQL SELECT statement")
	;
	I where="" S where=""""""
	I orderby="" S orderby=""""""
	I groupby="" S groupby=""""""
	I parlist="" S parlist=""""""
	;
	N isRdb S isRdb=$$rtIsRdb^UCXDD()
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
	..		I $$getInst^UCGM(lvn) S pce=$L(mlvns,",") D ERROR^UCGM("SCOPE: Dynamic SQL variable already used: "_lvn)
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
	I $$isLit^UCGM(select) D
	.	; select is literal (good!). Able to resolve columns
	.	S selExpr=$$RsSelList^UCDBRT(select)
	.	S z=z_$C(9)_selExpr
	.	;
	.	I $L(selExpr)>511 D
	..		;
	..		; Use local var if posible
	..		N expr,lvn
	..		S lvn="" S expr=$S(selExpr'["""":""""_selExpr_"""",1:$$QADD^%ZS(selExpr,""""))
	..		F  S lvn=$order(type(level,lvn)) Q:lvn=""  I expr=$$getExpr^UCGM(lvn,level) Q 
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
	S return="$$"_"vOpen0"_suffix_"("_$SELECT("M"[suffix:".exe,.vsql,",1:"")_select_","_from_","_where_","_orderby_","_groupby_","_parlist_")"
	;
	I isRdb,suffix="" D
	.	; Generate general dispatcher
	.	I $D(labels("vOpen0")) Q 
	.	;
	.	N sr S sr=$$vaddSubr("vOpen0","(exe,vsql,vSelect,vFrom,vWhere,vOrderby,vGroupby,vParlist)","RDB dynamic OPEN CURSOR dispatcher",0)
	.	;
	.	D addCode^UCPSLSR(sr," I '$$RsRdb^UCDBRT(vFrom) Q $$vOpen0M(.exe,.vsql,vSelect,vFrom,vWhere,vOrderby,vGroupby,vParlist)")
	.	D addCode^UCPSLSR(sr," I ""/""_vParlist[""/PROT"" Q $$vOpen0P(vSelect,vFrom,vWhere,vOrderby,vGroupby,vParlist)")
	.	D addCode^UCPSLSR(sr," Q $$vOpen0R(vSelect,vFrom,vWhere,vOrderby,vGroupby,vParlist)")
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
	.	I $D(labels("vOpen0"_suffix)) Q 
	.	;
	.	N sr S sr=$$vaddSubr("vOpen0"_suffix,"(exe,vsql,vSelect,vFrom,vWhere,vOrderby,vGroupby,vParlist)","Dynamic MDB ResultSet",0)
	.	;
	.	D addCode^UCPSLSR(sr," N vOid")
	.	D addCode^UCPSLSR(sr," N ER,vExpr,mode,RM,vTok S ER=0 ;=noOpti")
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
	.	N code S code=" E  S vsql=$$OPEN^SQLM(.exe,vFrom,vSelect,vWhere,vOrderby,vGroupby,"
	.	S code=code_"vParlist,"
	.	S code=code_"," ; tok
	.	S code=code_"1," ; mode
	.	S code=code_"," ; vdd
	.	S code=code_"sqlcur)" ; cursor id
	.	S code=code_" I 'ER D SAV^SQLCACHE(vExpr,.vParlist)"
	.	D addCode^UCPSLSR(sr," E  S vsql=$$OPEN^SQLM(.exe,vFrom,vSelect,vWhere,vOrderby,vGroupby,vParlist,,1,,sqlcur) I 'ER D SAV^SQLCACHE(vExpr,.vParlist)")
	.	;
	.	D addCode^UCPSLSR(sr," I ER S $ZS=""-1,""_$ZPOS_"",%PSL-E-SQLFAIL,""_$TR($G(RM),$C(10,44),$C(32,126)) X $ZT")
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
	.	D addCode^UCPSLSR(sr," I vsql=0 Q 0")
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
selectPR(suffix)	; "P" for RS with dp, "R" for RS without DP
	;
	I $D(labels("vOpen0"_suffix)) Q 
	;
	N sr S sr=$$vaddSubr("vOpen0"_suffix,"(vSelect,vFrom,vWhere,vOrderby,vGroupby,vParlist)","Dynamic RDB ResultSet with"_($piece("out",";",suffix'="P"))_" dataprotection",0)
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
	D selSrOpen^UCDBR(sr,"vFetch0"_suffix,"@,vExpr,vMap,vDipx",.dpi)
	D selSrFetch^UCDBR(sr,"vFetch0"_suffix,10,.dpi)
	Q 
	;
	; ---------------------------------------------------------------------
selectRecords	; method Db.selectDbSet; returns DbSet
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
	S actual(1)=$S(keys'["""":""""_keys_"""",1:$$QADD^%ZS(keys,"""")) ; SELECT from primaryKeys
	;
	D select
	S class="DbSet"
	;
	Q 
	;
	; ---------------------------------------------------------------------
sql2akey(td,where)	;
	;type String exe(),hostvar(),subkey(),vdd() // exported by $$WHERE
	;type String ER="",RM    // still uses ER/RM
	;type public String tok
	N strlits
	;
	N akey
	;
	I (where="") Q ""
	D
	.	N $ZT S $ZT="D ZX^UCGMR("_+$O(vobj(""),-1)_","_$ZL_",""vtrap2^"_$T(+0)_""")"
	.	N col
	.	N key
	.	N pkl S pkl=$P(td,"|",3)
	.	N pred
	.	N prnr
	.	;
	.	S akey=""
	.	S where=$$TOKEN^%ZS(where,.strlits,"'")
	.	;
	.	F prnr=1:1:$L(where," AND ") D
	..		S pred=$piece(where," AND ",prnr)
	..		S col=$$vStrTrim($piece(pred,"="),0," ")
	..		S pred=$$vStrTrim($E(pred,$F(pred,"="),1048575),0," ")
	..		;
	..		I '((","_pkl_",")[(","_col_",")) S $ZS="-1,"_$ZPOS_","_"%PSL-E-INTERNAL,not a keycolumn" X $ZT
	..		I $$nextExpr^UCGM(pred,0,"",1)'=pred S $ZS="-1,"_$ZPOS_","_"%PSL-E-INTERNAL,not a simple predicate" X $ZT
	..		;
	..		S key(col)=""
	..		I '(akey="") S akey=akey_","
	..		S akey=akey_col_"="_pred
	..		Q 
	.	;
	.	I prnr'=$S((pkl=""):0,1:$L(pkl,",")) S $ZS="-1,"_$ZPOS_","_"%PSL-E-INTERNAL,invalid number of predicates" X $ZT
	.	F prnr=1:1:$S((pkl=""):0,1:$L(pkl,",")) I '($D(key($piece(pkl,",",prnr)))#2) S $ZS="-1,"_$ZPOS_","_"%PSL-E-INTERNAL,missing keycolumn" X $ZT
	.	;
	.	S akey=$$UNTOK^%ZS(akey,$$sql2psl(strlits))
	.	Q 
	Q akey
	;
	; ---------------------------------------------------------------------
sql2psl(lits)	; strlit tokens as produced by $$TOKEN^%ZS()
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
	;-----------------------------------------------------------------------
akey2sql(akey,fkeys,knum)	;private void; access key to SQL whereclause
	;-----------------------------------------------------------------------
	; ARGUMENTS:
	; . akey = the access key
	; This function supports the following styles:
	; * COLUMNNAME=:HOSTVAR
	; * COLUMNNAME=:HOSTVAR simpleExprTail
	; * COLUMNNAME='literal'
	; * COLUMNNAME="literal" (discouraged)
	; * COLUMNNAME=HOSTVAR (deprecated)
	; * HOSTVAR (deprecated)
	; . fkeys = ordered list of key columns
	; . knum = optional variable that will receive the number of keys in
	; akey. The caller can use this variable to detect if all keys
	; were included.
	;
	; OUTPUTS:
	; . $$ = the SQL whereclause that corresponds to the access key.
	; . knum = number of keys in akey
	;
	N atom,expr,ptr,tok,val,where
	;
	;  #ACCEPT CR=18163; DATE=2005-11-24; PGM=FSCW; GROUP=BYPASS
	;*** Start of code by-passed by compiler
	set knum=0,ptr=0
	set expr=$tr($$TOKEN^%ZS(akey,.tok)," "),where=""
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
	Q $$UNTOK^%ZS(where,tok)
	;
	; ---------------------------------------------------------------------
get1Row	; void; method Db.getOneRow ; returns single row
	N del,fkeys,fset,keys,i,list,objectName,objectLevel,table
	;  #ACCEPT CR=18163; DATE=2005-11-24; PGM=FSCW; GROUP=BYPASS
	;*** Start of code by-passed by compiler
	;
	I '$D(actual(1))!'$D(actual(2)) D ERROR^UCGM("Expression expected") Q
	do WARNDEP^UCGM("Db.getOneRow")
	set list=$$QSUB^%ZS(actual(1))   ; column list
	set table=$$QSUB^%ZS(actual(2))   ; table name
	set keys=$$QSUB^%ZS(actual(3))   ; access keys
	set delim=$S($tr($G(actual(4))," ",""):actual(4),1:9)  ; Delimiter
	;
	new seq
	;;do addM2src^UCGM(" #ACCEPT DATE=6/23/03; PGM=Mark Spier; CR=Frank Sanchez")
	;;do addM2src^UCGM(" quit")
	set label=$$newLabel^UCGM("Row",.labels) ; Get next label
	do addM2src^UCGM(" #OPTION ResultClass 0")
	do addM2src^UCGM("v"_label_"()")
	do addM2src^UCGM(" #WARN SCOPE 0")
	set expr=" type Record"_table_" getRow=Db.getRecord("""_table_""","""_keys_""",1)"
	do addM2src^UCGM(expr)
	do addM2src^UCGM(" type String data=""""")
	;
	; select DISTINCT columns
	if $P(list," ",1)="DISTINCT" S list=$P(list,"DISTINCT ",2),distinct=1
	set list=$$UPPER^%ZFUNC(list)   
	;
	for I=1:1:$L(list,",") do
	. set prop=$p(list,",",I)
	. if prop="" do addM2src^UCGM(" set data=data_$C("_delim_")") quit
	. if prop'["." set prop="getRow."_$$LOWER^%ZFUNC(prop)
	. set expr=" set data=data_$C("_delim_")_"_prop
	. do addM2src^UCGM(expr)
	D addM2src^UCGM(" quit data.extract(2,data.length())")
	; function call
	S return="$$v"_label_"()"
	;
	do autoERRM^UCGM()
	;
	;*** End of code by-passed by compiler ***
	Q 
	;
	; ---------------------------------------------------------------------
getGbl(gblref,keyvars)	; void; Return Global reference
	N gkey,gkeys,i,keyNum,ptr,ref,return,tok
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
append(code,label)	;
	D append^UCGM(code,label)
	Q 
	;
	; ---------------------------------------------------------------------
mapPSLvar(expr)	;local String; Map PSL variables into SQL variables
	N atom,code,class,i,lvn,new,set,tok,y
	;  #ACCEPT CR=18163; DATE=2005-11-24; PGM=FSCW; GROUP=BYPASS
	;*** Start of code by-passed by compiler
	;
	set expr=$$TOKEN^%ZS(expr,.tok,"'")
	set expr=$$TOKEN^%ZS(expr,.tok,"""")
	set y=0,new="",set=""
	;
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
	. if new="" set new=lvn,set=lvn_"="_code
	. else  set new=new_","_lvn,set=set_","_lvn_"="_code
	;
	if '(new="") d
	. if $e(mcode,$L(mcode))="," S mcode=$e(mcode,1,$l(mcode)-1)_"   "
	. if $e(mcode,$L(mcode)-1)="."!(mcode=$C(9)) S mcode=mcode_"   "
	. set mcode=$E(mcode,1,$L(mcode)-2)_" N "_new_" S "_set_" "_$S(cmd="QUIT":"",1:$E(cmd)_" ")
	;
	set expr=$$UNTOK^%ZS(expr,.tok)
	;*** End of code by-passed by compiler ***
	Q expr
	;
	; ---------------------------------------------------------------------
insert	; void; Db.insert(Table_name,column_list,colum_value,filer_qualifier)
	;  #ACCEPT CR=18163; DATE=2005-11-24; PGM=FSCW; GROUP=BYPASS
	;*** Start of code by-passed by compiler
	new columns,expr,I,label,par,table,value,values,z,zpar
	;;if '$d(actual(1))!('$d(actual(2)))!('$D(actual(3))) D error^UCDB Q
	do WARNDEP^UCGM("Db.insert() - use Db.getRecord(,,1) or Class.new() and Record.save()")
	;
	; Filer run-time qualifier
	set par=$$fileQual("Db.update",actual(4))
	;
	set table=$$QSUB^%ZS(actual(1))    ; Table name
	set columns=$$QSUB^%ZS(actual(2))   ; Column list
	set values=$$QSUB^%ZS(actual(3))   ; Column values
	;
	if values[":" set values=$$mapPSLvar^UCDB(values)
	;
	; get next label and insert into code
	set label=$$newLabel^UCGM("Ins",.labels)  ; Get next tag name
	set label="vvIns"_$E(label,5,8)
	set return=label
	do addM2src^UCGM(" #OPTION ResultClass 0")
	do addM2src^UCGM(label_"  //INSERT")
	do addM2src^UCGM(" #WARN SCOPE 0")
	;;do addM2src^UCGM(" new X") ;FSCW CR12564: removed again (see CR7240)
	;
	; Instantiate a new record
	set expr=" type Record"_table_" insRow=Class.new(""Record"_table_""")"
	do addM2src^UCGM(expr)
	;
	; set all columns into the new record as defined by columns and values
	; parameters of the method
	new nextval,currval
	set (currval,nextval)=""
	if '$D(fsn(table)) do fsn^SQLDD(.fsn,table)
	for I=1:1:$L(columns,",") do
	. set prop=$p(columns,",",I)
	. if prop["." set prop=$p(prop,".",2)
	. ;values needs to be tokenized
	. set value=$p(values,",",I)
	. if $$UPPER^%ZFUNC(value)["NEXTVAL" set nextval=prop quit
	. if $$UPPER^%ZFUNC(value)["CURRVAL" set currval=prop quit
	. if $p(fsn(table),"|",3)[prop set nextval(prop)=value
	. if $E(value)=":" set value=$e(value,2,100)
	. if $E(value)="'" set value=""""_$e(value,2,$l(value)-1)_""""
	. else  if value?.P set value=""""_value_""""
	. new expr
	. set expr=prop
	. if '$$ISSFD(table,.expr,value,"insRow") set expr=" set insRow."_$$LOWER^%ZFUNC(prop)_"="_value
	. do addM2src^UCGM(expr)
	; 
	if nextval'=""!(currval'="") do
	. new where,i
	. set (where,i)=""
	. for  set i=$O(nextval(i)) quit:i=""  set where=where_","_i_"="_nextval(i)
	. if nextval'="" do addM2src^UCGM(" set insRow."_$$LOWER^%ZFUNC(nextval)_"=Db.nextVal("""_table_""","""_$e(where,2,100)_""")") quit
	. do addM2src^UCGM(" set insRow."_$$LOWER^%ZFUNC(currval)_"=Db.currVal("""_table_""","""_$e(where,2,100)_""")")
	; save the data using the filer if one exists in order to use all
	; triggers and journals
	do addM2src^UCGM(" do insRow.save("_par_")")
	do addM2src^UCGM(" quit ")
	;
	do autoERRM^UCGM()
	;
	;*** End of code by-passed by compiler ***
	Q 
	;
	; ---------------------------------------------------------------------
update	; void; Db.update(Table_name,column_expr,where_clause,filer_qualifier)
	;  #ACCEPT CR=18163; DATE=2005-11-24; PGM=FSCW; GROUP=BYPASS
	;*** Start of code by-passed by compiler
	new expr,I,label,par,setexpr,sql,src,table,where
	;
	set par=$$fileQual("Db.update",actual(4)) ; Run-time qualifier
	;
	set table=$$QSUB^%ZS(actual(1))   ; Table name
	set setexpr=$$QSUB^%ZS(actual(2))  ; Column expression
	set where=$$QSUB^%ZS(actual(3))   ; where clause
	;
	new fsn
	do fsn^SQLDD(.fsn,table) if ER do ERROR^UCGM($G(RM)) quit
	;
	; create label
	set label=$$newLabel^UCGM("Sql",.labels) ; Get next tag name
	set label="vUpd"_$E(label,5,8)
	set return=label
	do addM2src^UCGM(" #OPTION ResultClass 0")
	do addM2src^UCGM(label)
	do addM2src^UCGM(" #WARN SCOPE 0")
	;;do addM2src^UCGM(" new X") ;FSCW CR12564: removed again (see CR7240)
	;
	; Build database set resultset
	set expr=" type DbSet updset=Db.selectDbSet("""_table_""","""_where_""")"
	do addM2src^UCGM(expr)
	;
	do addM2src^UCGM(" while updset.next() do {")
	set expr=" type Record"_table_"  updRow=updset.getRecord("""_table_""")"
	do addM2src^UCGM(expr)
	do addM2src^UCGM(" do updRow.setAuditFlag(1)")
	;
	; Build code to deal with individual columns being updated
	new expr,value
	for I=1:1:$L(setexpr,",") do
	. set expr=$p(setexpr,",",I)
	. set value=$TR($p(expr,"=",2),":","")
	. if $E(value)="'" set value=""""_$e(value,2,$l(value)-1)_""""
	. else  if value?.P set value=""""_value_""""
	. set expr=$p(expr,"=",1)
	. if $p(expr,"=",1)["." set expr=$p($p(expr,"=",1),".",2)_$p(expr,"=",2)
	.       if value?.E1P.E,value'["%",value'["""" do
	..              new ptr,temp
	..              set temp=value
	..              set ptr=$f(temp,expr)
	..              set value=$s(ptr-$l(expr)=1:"",1:$e(temp,1,ptr-$l(expr)-1))_"updRow."_$e(temp,ptr-$l(expr),1000)
	. set $p(expr,"=",1)=$$LOWER^%ZFUNC($P(expr,"=",1))
	. if $e($p(expr,"=",2),1)="'" set $p(expr,"=",2)=""""_$e($p(expr,"=",2),2,$l($p(expr,"=",2))-1)_""""
	. if '$$ISSFD(table,.expr,value,"updRow") set expr=" set updRow."_expr_"="_value
	. do addM2src^UCGM(expr)
	;
	; save the data and end the subroutine 
	do addM2src^UCGM(" do updRow.save("_par_")")
	do addM2src^UCGM(" }")
	do addM2src^UCGM(" quit ")
	;
	do autoERRM^UCGM()
	;*** End of code by-passed by compiler ***
	Q 
	;
	; ---------------------------------------------------------------------
ISSFD(table,expr,value,mode)	;local Boolean;
	;  #ACCEPT CR=18163; DATE=2005-11-24; PGM=FSCW; GROUP=BYPASS
	;*** Start of code by-passed by compiler
	new ddpexpr,frm,fsn,sfd,vdd,x
	set ddexpr=$$UPPER^%ZFUNC(table_"."_expr)
	set table=$$UPPER^%ZFUNC(table)
	set X=$$DI^SQLDD(ddexpr,.frm,.vdd,.fsn)
	if ER quit 0
	set sfd=$$SFD^SQLDD("",.X)
	if sfd="" quit 0
	new di,node,pos,quit
	set node=$$NOD^SQLDD(ddexpr,.X)
	set pos=$$POS^SQLDD(ddexpr,.X)
	set di=""
	set quit=0
	F  S di=$O(^DBINDX("SYSDEV","STR",table,node,pos,di)) Q:di=""  D  Q:quit
	. if $P(^DBTBL("SYSDEV",1,table,9,di),"|",18)'="" Q
	. set quit=1
	if di="" quit 0
	set di=$$LOWER^%ZFUNC(di)
	set expr=" set X="_mode_"."_di
	set expr=expr_",$P(X,"""_$C($P(sfd,"~",2))_""","_$p(sfd,"~",4)_")"_"="_value
	set expr=expr_","_mode_"."_di_"=X"
	;*** End of code by-passed by compiler ***
	Q 1
	; ----------------
	;  #OPTION ResultClass 0
vStrUC(vObj)	; String.upperCase
	;
	;  #OPTIMIZE FUNCTIONS OFF
	Q $translate(vObj,"abcdefghijklmnopqrstuvwxyz±³µ¶¹º»¼¾¿àáâãäåæçèéêëìíîïðñòóôõöøùúûüýþ","ABCDEFGHIJKLMNOPQRSTUVWXYZ¡£¥¦©ª«¬®¯ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖØÙÚÛÜÝÞ")
	; ----------------
	;  #OPTION ResultClass 0
vPSLopti(var)	; PSLIdentifier.allowOPtimize
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N varLevel S varLevel=$$getLevel^UCGM(var)
	N opti S opti=$$getAtt^UCGM(var,varLevel,10)
	I opti>msrc S opti=0 D setOpti^UCGM(var,varLevel,0)
	Q 'opti
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
vaddSubr(p1,p2,p3,p4)	; PSL.addSubrou
	;
	;  #OPTIMIZE FUNCTIONS OFF
	I $get(p4) S p1=$$newLabel^UCGM(p1,.labels)
	E  I ($D(labels(p1))#2) D ERROR^UCGM("Subroutine exists: "_p1) Q p1
	D addSubr^UCGM(p1,p2,p3)
	Q p1
	; ----------------
	;  #OPTION ResultClass 0
vStrRep(object,p1,p2,p3,p4,qt)	; String.replace
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
	;  #OPTION ResultClass 0
vStrTrim(object,p1,p2)	; String.trim
	;
	;  #OPTIMIZE FUNCTIONS OFF
	I p1'<0 S object=$$RTCHR^%ZFUNC(object,p2)
	I p1'>0 F  Q:$E(object,1)'=p2  S object=$E(object,2,1048575)
	Q object
	; ----------------
	;  #OPTION ResultClass 0
vStrFnd(object,p1,p2,p3,qt)	; String.find
	;
	;  #OPTIMIZE FUNCTIONS OFF
	;
	I (p1="") Q $SELECT(p2<1:1,1:+p2)
	I p3 S object=$$vStrUC(object) S p1=$$vStrUC(p1)
	S p2=$F(object,p1,p2)
	I '(qt=""),$L($E(object,1,p2-1),qt)#2=0 D
	.	F  S p2=$F(object,p1,p2) Q:p2=0!($L($E(object,1,p2-1),qt)#2) 
	.	Q 
	Q p2
	;
vStrIsNum(vStr)	;	String.isNumber
	;
	Q vStr=+vStr
	;
vtrap1	;	Error trap
	;
	N vSQLex S vSQLex=$ZS
	S ER=1 S RM=vSQLex
	Q 
	;
vtrap2	;	Error trap
	;
	N xcpt S xcpt=$ZS
	S akey=""
	Q 
