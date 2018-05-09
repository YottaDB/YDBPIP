 ; 
 ; **** Routine compiled from DATA-QWIK Procedure UCDBR ****
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
 Q 
 ;
 ; ---------------------------------------------------------------------
colSub(context,table,column) ; name of column (*3)
 N cd S cd=$$getPslCln^UCXDD(table,column)
 N recInst S recInst=context("Inst")
 N nod S nod=$$getCurNode^UCXDD(cd,0)
 I '(nod="") S context("NODE",table,nod)=$$getCurLvn^UCXDD(cd,recInst)
 ;
 Q $$getCurExpr^UCXDD(cd,recInst,0)
 ;
 ; ---------------------------------------------------------------------
getKey(table,primkey,keyvals,md,hostval,coldes) ; Build primary key WHERE-clause and hostvar list
 ;
 N col ; individual (key)column name
 N extt S extt=table ; external table name
 N k ; interator
 N ptr S ptr=0 ; pointer in calls to $$ATOM^%ZS()
 N val ; individual key value expr
 N where S where="" ; where clause
 ;
 ; variables used to differentiate code depending on md
 N colon N qtpre N qtpost N sep
 ;
 S hostval=""
 ;
 ; If no keyvalues supplied translate tablename and quit ""
 I keyvals="" D MAP^DBMAP(%DB,.table) Q ""
 ;
 ; Set colon, qtpre, qtpost, and sep based on md
 I md=1 S sep="_$C(1)_" S (colon,qtpre,qtpost)=""
 E  S sep="_$C(9)_" S colon=":" S qtpre="$$QADD^%ZS(" S qtpost=",""'"")"
 ;
 F k=1:1:$S((primkey=""):0,1:$L(primkey,",")) D
 .	;   #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 .	S val=$$ATOM^%ZS(keyvals,.ptr,",",,1) I ptr S ptr=ptr+1
 .	S col=$piece(primkey,",",k) S table=extt
 .	S coldes(k)=$$getPslCln^UCXDD(extt,col)
 .	D MAP^DBMAP(%DB,.table,.col)
 .	I k>1 S where=where_" AND " S hostval=hostval_sep
 .	S where=where_col_"="_colon_"V"_k
 .	S hostval=hostval_qtpre_val_qtpost
 .	Q 
 Q where
 ;
 ; ---------------------------------------------------------------------
isDefined(td,where,matchCnt) ; Generate code for vDbEx() of RDB Db.isDefined()
 ;
 N map
 N sr S sr=$$vaddSubr("DbEx","()","EXISTS "_$P(td,"|",1)_" WHERE "_where,1)
 ;
 D addCode^UCPSLSR(sr," N vCurID,vData,vEr,vList,vRm")
 ;
 N intTbl S intTbl=$P(td,"|",1)
 I '(where="") S where=$$where(.intTbl,where,.map)
 ;
 D addCode^UCPSLSR(sr," S vList="_$$RsMsXV^UCDBRT(.map,.where))
 ;
 N sql S sql="SELECT COUNT(*) FROM "_intTbl
 I '(where="") S sql=sql_" WHERE "_where
 I '($ZLENGTH(sql)'>1980) D
 .	D addCode^UCPSLSR(sr," N vSql")
 .	D setLong(.sr,"vSql",sql)
 .	D addCode^UCPSLSR(sr," S vEr=$$SELECT^%DBAPI(0,vSql,$C(9),vList,.vData,.vRm)")
 .	Q 
 E  D addCode^UCPSLSR(sr," S vEr=$$SELECT^%DBAPI(0,"_$S(sql'["""":""""_sql_"""",1:$$QADD^%ZS(sql,""""))_",$C(9),vList,.vData,.vRm)")
 ;
 D addCode^UCPSLSR(sr," I vEr<0 S $ZE=""0,""_$ZPOS_"",%PSL-E-SQLFAIL,""_$TR($G(vRm),$C(10,44),$C(32,126)),$EC="",U1001,""")
 ;
 D addCode^UCPSLSR(sr," Q vData'<"_matchCnt)
 ;
 Q "$$"_sr_"()"
 ;
 ; ---------------------------------------------------------------------
select(select,from,where,orderby,groupby,parlist) ; RDB SELECT when all componetns are known at compile-time
 ;
 N aqual ; qualifiers for SQLPROT
 N dip ; data item protection
 ;
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 I ("/"_parlist)["/PROT" D PARSPAR^%ZS(parlist,.aqual) D getExe^SQLPROT(from,.select,.dip,.aqual)
 ;
 N selmap
 N expr S expr=$$RsDyRT^UCDBRT(select,from,where,orderby,groupby,parlist,.selmap)
 ;
 N sr S sr=$$vaddSubr("Open","(vOff)","New RDB result set",1)
 N openLab S openLab=sr
 ;
 N seq S seq=$E(openLab,6,1048575)
 N fetchLab S fetchLab="vFetch"_seq
 ;
 ;  #ACCEPT GROUP=ACCESS;CR=35741;DATE=2008-10-23;PGM=Frans S.C. Witte
 S return="$$"_openLab_"("_($$getLevel^UCGM(var)-level+1)_")"
 ;
 D selSrOpen(.sr,fetchLab,expr,.dip,.selmap)
 D selSrFetch(.sr,fetchLab,0,.dip)
 D XvClose()
 ;
 N z S z=(msrc+1)_tab_seq
 ;
 ; Store Columnnames and Datatypes for Row class
 ; 02/09/04 - Piece #7 added to fix fetch label problem
 ;
 S $piece(z,tab,4)=selmap("SELNAM")
 S $piece(z,tab,6)=selmap("SELTYP")
 ;
 ;         #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 S $piece(z,tab,7)=$$getScope^UCGM(var)
 S $piece(z,tab,8)=1
 ;
 I ($D(struct("s",subRou,varPtr,var))#2) D
 .	S $piece(z,tab,2)=""
 .	S $piece(z,tab,5)=seq
 .	I $piece(struct("s",subRou,varPtr,var),tab,4)'=selmap("SELNAM") S $piece(z,tab,4)=""
 .	Q 
 S struct("s",subRou,varPtr,var)=z
 Q 
 ;
 ; ---------------------------------------------------------------------
qrySub(context,routine,query,qrySub) ; utility subroutine for the column substitution array of SQL*
 N e N j ; scratch loop vars
 N n S n="" ; loop var for query()
 N expr ; query expression
 N term ; query term
 N colref ; column reference in term
 F  S n=$order(query(n)) Q:(n="")  D
 .	S term=query(n)
 .	F e=1,2 D
 ..		S expr=$piece(term,$char(9),e)
 ..		F j=2:2:$L(expr,$char(1)) D
 ...			S colref=$piece(expr,$char(1),j)
 ...			Q:($D(qrySub(colref))#2) 
 ...			;
 ...			;     #ACCEPT CR=15592;PGM=Frans S.C. Witte;DATE=2005-09-06;GROUP=BYPASS
 ...			;*** Start of code by-passed by compiler
 ...			set qrySub(colref)=$$colSub^@(routine)(.context,$P(colref,"."),$P(colref,".",2))
 ...			;*** End of code by-passed by compiler ***
 ...			Q 
 ..		Q 
 .	Q 
 ;
 Q 
 ;
 ; ---------------------------------------------------------------------
selBoot(select,from,where,orderby,groupby,parlist) ; Db.select(,,,,,"/PSLBOOT")
 ;
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 D warnGroup^UCGM("PSLBOOT","qualifier - please validate against Framework Upgrade Rules")
 ;
 N actual
 S actual(1)=select
 S actual(2)=from
 S actual(3)=where
 S actual(4)=orderby
 S actual(5)=groupby
 S actual(6)=$$QADD^%ZS($$vStrRep($$QSUB^%ZS(parlist,""""),"/PSLBOOT","",0,0,""),"""")
 D select^UCDB
 ;
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 I '$$isLit^UCGM(from) D warnGroup^UCGM("PSLBOOT","invalid /PSLBOOT ignored: FROM must be literal") Q 
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 I from["," D warnGroup^UCGM("PSLBOOT","invalid /PSLBOOT ignored: Only single table allowed") Q 
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 I $translate(from,tab_"(","  ")[" " D warnGroup^UCGM("PSLBOOT","invalid /PSLBOOT ignored: Only single table allowed") Q 
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 I '(where=""!(where="""""")),'$$isLit^UCGM(where) D warnGroup^UCGM("PSLBOOT","invalid /PSLBOOT ignored: WHERE must be literal") Q 
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 I '(orderby=""!(orderby="""""")) D warnGroup^UCGM("PSLBOOT","invalid /PSLBOOT ignored: ORDER BY not allowed") Q 
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 I '(groupby=""!(groupby="""""")) D warnGroup^UCGM("PSLBOOT","invalid /PSLBOOT ignored: GROUP BY not allowed") Q 
 ;
 N bDyn S bDyn='$$isLit^UCGM(select)
 S from=$$QSUB^%ZS(from,"""")
 S where=$$QSUB^%ZS(where,"""")
 ;
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 N varNew S varNew=$$getNew^UCGM(var,varLevel)
 N rsdes S rsdes=struct("s",subRou,varNew,var)
 N sellist S sellist=$piece(rsdes,tab,4)
 N seqpiece S seqpiece=2
 N seqnorm S seqnorm=$piece(rsdes,tab,2)
 I (seqnorm="") S seqpiece=5 S seqnorm=$piece(rsdes,tab,5)
 ;
 N openLab S openLab="vOpen"_(seqnorm+1)
 N seq S seq=$E(openLab,6,1048575)
 N fetchLab S fetchLab="vFetch"_seq
 ;
 N C2R ; column to Row mapping, passed to QUERY^SQLA()
 N OUT ; not used, passed to ^SQLQ()
 N RNG ; not used (passed to ^SQLQ())
 N VDD ; not used, passed to ^SQLQ()
 N WHD ; where-clause decomposition
 N WHM ; where-clause M code, passed from QUERY^SQLA()
 ;
 N exe ; public output from ^SQLQ()
 N vsql ; public output from ^SQLQ() and  QUERY^SQLA()
 N vsub ; public output from ^SQLQ()
 N vxp S vxp=-1 ; public input for QUERY^SQLA()
 N frm S frm=from ; public input for QUERY^SQLA()
 ;
 ; decompose where-clause and construct M code
 I '(where="") D ^SQLQ(where,from,.WHD,.RNG,,,,.VDD,.OUT)
 ;
 N msk S msk=""
 S $piece(msk,1,$order(WHD(""),-1)+1)=""
 ;
 N ctx
 S ctx("Inst")="vR"
 D qrySub(.ctx,"UCROWSET",.WHD,.C2R)
 D QUERY^SQLA(msk,.WHD,.WHM,.C2R,from,,0,0)
 ;
 N ln
 ;
 N bRdb S bRdb=$$RsRdb^UCDBRT(from)
 N fplist S fplist=$S(bDyn:"(vSelect,vOff)",bRdb:"(vOff)",1:"()")
 ;
 ;  #ACCEPT GROUP=ACCESS;CR=35741;DATE=2008-10-23;PGM=Frans S.C. Witte
 S return=$S(bDyn!bRdb:($$getLevel^UCGM(var)-level+1),1:"")
 S return="("_$S(bDyn:select_",",1:"")_return_")"
 ;
 N sr S sr=$$vopenBuf(fplist,"PSLBOOT result set for "_from)
 D vaddBuff(sr,"type public RowSet pslPrsr(,)")
 ;
 D vaddBuff(sr,"#ACCEPT GROUP=BYPASS;CR=27800;PGM=Frans S.C. Witte;Date=2008-03-11")
 D vaddBuff(sr,"#BYPASS")
 I bDyn D
 .	D vaddBuff(sr,"IF '$DATA(pslPrsr(""boot"","""_from_""")) QUIT $$vOpen"_seqnorm_"("_$S(bRdb:"",1:".exe,.vsql,")_"vSelect,"_$S(from'["""":""""_from_"""",1:$$QADD^%ZS(from,""""))_","_$S(where'["""":""""_where_"""",1:$$QADD^%ZS(where,""""))_","""","""","_parlist_",vOff+1)")
 .	Q 
 E  D vaddBuff(sr,"IF '$DATA(pslPrsr(""boot"","""_from_""")) QUIT $$vOpen"_seqnorm_$S(bRdb:"(vOff+1)",1:"()"))
 D vaddBuff(sr,"#ENDBYPASS")
 D vaddBuff(sr,"type RowSet vRws = {RowSet}pslPrsr(""boot"","""_from_""")")
 D vaddBuff(sr,"type Number vOid=$O("_oLvn_"(""""),-1)+1")
 D vaddBuff(sr,"set "_oLvn_"(vOid,-1)=""ResultSet""")
 D vaddBuff(sr,"set "_oLvn_"(vOid,-5)=2")
 D vaddBuff(sr,"set "_oLvn_"(vOid,-2)=""$$"_fetchLab_"^""_$T(+0)")
 D vaddBuff(sr,"set "_oLvn_"(vOid,-3)="_$S(bDyn:"vSelect",1:$S(sellist'["""":""""_sellist_"""",1:$$QADD^%ZS(sellist,""""))))
 D vaddBuff(sr,"set "_oLvn_"(vOid,-4)="_$$QADD^%ZS($piece(rsdes,tab,6),""""))
 D vaddBuff(sr,"set "_oLvn_"(vOid,0)=1")
 ;
 F ln=1:1:$order(exe(""),-1) D vaddBuff(sr,$$selBootReplace(exe(ln),"vOid"))
 ;
 D vaddBuff(sr,"do vRws.beforeFirst()")
 D vaddBuff(sr,"#ACCEPT GROUP=BYPASS;CR=27800;PGM=Frans S.C. Witte;Date=2008-03-11")
 D vaddBuff(sr,"#BYPASS")
 D vaddBuff(sr,"IF $$"_fetchLab_"(vOid) SET "_oLvn_"(vOid,0)=2")
 D vaddBuff(sr,"#ENDBYPASS")
 D vaddBuff(sr,"quit vOid")
 ;
 D INSERT^UCMETHOD(sr,openLab,"ResultSet")
 ;
  K vobj(+$G(sr)) S sr=$$vopenBuf("(Number vOid)","PSLBOOT fetch for "_from)
 D vaddBuff(sr,"type public RowSet pslPrsr(,)")
 D vaddBuff(sr,"#ACCEPT GROUP=BYPASS;CR=27800;PGM=Frans S.C. Witte;Date=2008-03-11")
 D vaddBuff(sr,"#BYPASS")
 D vaddBuff(sr,"IF '$DATA(pslPrsr(""boot"","""_from_""")) QUIT $$vFetch"_seqnorm_"(vOid)")
 D vaddBuff(sr,"#ENDBYPASS")
 D vaddBuff(sr,"if "_oLvn_"(vOid,0)=2 set "_oLvn_"(vOid,0)=1 quit 1")
 D vaddBuff(sr,"type RowSet vRws = {RowSet}pslPrsr(""boot"","""_from_""")")
 D vaddBuff(sr,"type Row vR")
 I (where="") D
 .	D vaddBuff(sr,"set "_oLvn_"(vOid,0) = vRws.next()")
 .	Q 
 E  D
 .	D vaddBuff(sr,"type Boolean vFnd = 0")
 .	D vaddBuff(sr,"while 'vFnd do {")
 .	D vaddBuff(sr,"  if 'vRws.next() set vFnd=1,"_oLvn_"(vOid,0)=0 quit")
 .	D vaddBuff(sr,"  set vR=vRws.getRow()")
 .	;
 .	F ln=1:1:$order(WHM(""),-1) D vaddBuff(sr,"  "_$$selBootReplace(WHM(ln),"vOid"))
 .	D vaddBuff(sr,"  set vFnd=1")
 .	D vaddBuff(sr,"}")
 .	Q 
 N line
 ;
 I $$isLit^UCGM(select) D
 .	D vaddBuff(sr,"set vR = vRws.getRow()")
 .	S line="vR."_$ZCONVERT($piece(sellist,","),"L")
 .	N n
 .	F n=2:1:$L(sellist,",") S line=line_"_9.char()_vR."_$ZCONVERT($piece(sellist,",",n),"L")
 .	D vaddBuff(sr,"set "_oLvn_"(vOid) = "_line)
 .	Q 
 E  D
 .	D vaddBuff(sr,"set vR = vRws.getRow()")
 .	D vaddBuff(sr,"type String vS = vR.toString()")
 .	D vaddBuff(sr,"type String vD = vR.getDelimiter()")
 .	D vaddBuff(sr,"type List vH = vR.getColumns()")
 .	D vaddBuff(sr,"type String vL = """" type Number vP1,vP2 type String vC")
 .	D vaddBuff(sr,"for vP1=1:1:"_select_".length("","") set vC="_select_".piece("","",vP1),vP2=vH.position(vC),vL = vL_9.char()_vS.piece(vD,vP2)")
 .	D vaddBuff(sr,"set "_oLvn_"(vOid) = vL.extract(2, vL.length())")
 .	Q 
 ;
 D vaddBuff(sr,"quit "_oLvn_"(vOid,0)")
 ;
 D INSERT^UCMETHOD(sr,fetchLab,"Boolean")
 ;
 S $piece(struct("s",subRou,varNew,var),tab,seqpiece)=seq
 ;
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 D setOpti^UCGM(var,$$getLevel^UCGM(var),-1)
 S return="$$"_openLab_return
 ;
 K vobj(+$G(sr)) Q 
 ;
 ; ---------------------------------------------------------------------
selBootReplace(code,recInst) ; 
 ;
 N lbl
 N num N p1 N p2
 ;
 I code?.ANP1" I vsql("1.N1")=""""".ANP,(code[" S ER=1,")!(code[" S vsql=-1") D
 .	S code=$piece(code," I vsql(")
 .	I code["$G(" S code=$piece(code,"$G(")_$piece(code,"$G(",2) S code=$E(code,1,$L(code)-1)
 .	Q 
 E  I code["'?.N" S code=";"
 ;
 I code["sqlcur" S code=$$VarSub^UCPATCH(code,"sqlcur",recInst)
 ;
 I code["^DBTMP(%TOKEN" S code=$$VarSub^UCPATCH(code,"^DBTMP(%TOKEN","^DBTMP($J")
 ;
 S p1=0
 F  S p1=$F(code,"vsql(",p1) Q:p1=0  S p2=$F(code,")",p1) Q:p2=0  D
 .	S num=$E(code,p1,p2-2)
 .	S code=$E(code,1,p1-6)_oLvn_"("_recInst_","_num_")"_$E(code,p2,1048575)
 .	Q 
 ;
 I code["S vsql=" D
 .	S num=$piece(code,"S vsql=",2)+1
 .	S code=$piece(code,"S vsql=")_"Q"
 .	I num>0 S $ZE="0,"_$ZPOS_","_"%PSL-E-PSLBOOT,Cannot create /PSLBOOT code",$EC=",U1001,"
 .	Q 
 ;
 I code[",vsql=" D  ; and isAgFunc
 .	S num=""+1
 .	S code=$piece(code,"S vd")_"Q"
 .	I num>0 S $ZE="0,"_$ZPOS_","_"%PSL-E-PSLBOOT,Cannot create /PSLBOOT code",$EC=",U1001,"
 .	Q 
 ;
 Q " "_code
 ;
 ; ---------------------------------------------------------------------
selCdAssign(sr,nType,prot) ; Generate common fetch / open code
 ;
 N retVal
 I nType#10 S retVal="vOid"
 E  S retVal="0"
 ;
 D addCode^UCPSLSR(sr," I vEr=100!(vEr<0) S "_oLvn_"(vOid,0)=0,"_oLvn_"(vOid)="""" D vCloseRDBOpt^vResultSet("_oLvn_"(vOid,1),0) Q:vEr=100 "_retVal_" S $ZE=""0,""_$ZPOS_"",%PSL-E-SQLFAIL,""_$TR($G(vRm),$C(10,44),$C(32,126)),$EC="",U1001,""")
 ;
 I '($order(prot(""))="") D
 .	I nType>9 D
 ..		D addCode^UCPSLSR(sr," N v0 F v0=1:1:$O("_oLvn_"(vOid,.1,""""),-1) X "_oLvn_"(vOid,.1,v0) ;=noOpti")
 ..		D addCode^UCPSLSR(sr," S "_oLvn_"(vOid,.1)=$G(vi)")
 ..		Q 
 .	E  D
 ..		N n S n=""
 ..		F  S n=$order(prot(n)) Q:n=""  D addCode^UCPSLSR(sr," "_prot(n))
 ..		D addCode^UCPSLSR(sr," S "_oLvn_"(vOid,.1)=$G(vi)")
 ..		Q 
 .	Q 
 D addCode^UCPSLSR(sr," S "_oLvn_"(vOid)=vd")
 Q 
 ;
 ; ---------------------------------------------------------------------
selSrFetch(sr,fetchLab,mode,dipx) ; Builds the fetch logic for the select methods
 ;
 D addCode^UCPSLSR(sr," ;")
 D addCode^UCPSLSR(sr,fetchLab_"(vOid) ; Fetch Row for RDB ResulSet")
 ;
 D addCode^UCPSLSR(sr," ;")
 D addCode^UCPSLSR(sr," ;")
 D addCode^UCPSLSR(sr," I "_oLvn_"(vOid,0)=0 Q 0")
 D addCode^UCPSLSR(sr," I "_oLvn_"(vOid,0)=2 S "_oLvn_"(vOid,0)=1 Q 1")
 D addCode^UCPSLSR(sr," N vEr,vRm,vd,vi ;=noOpti")
 ;
 D addCode^UCPSLSR(sr," S vEr=$$FETCH^%DBAPI(0,"_oLvn_"(vOid,1),1,$C(9),.vd,.vRm)")
 D selCdAssign(.sr,mode,.dipx)
 ;
 D addCode^UCPSLSR(sr," Q 1")
 ;
 Q 
 ;
 ; ---------------------------------------------------------------------
selSrOpen(sr,fetchLab,sql,dipx,map) ; 
 ;
 D addCode^UCPSLSR(sr," N vOid")
 ;
 D addCode^UCPSLSR(sr," S vOid=$O("_oLvn_"(""""),-1)+1,"_oLvn_"(vOid,-1)=""ResultSet""")
 D addCode^UCPSLSR(sr," N vCurID,vd,vEr,vi,vList,vRm ;=noOpti")
 ;
 N lvnSql N lvnMap N lvnDpx
 I $E(sql,1)="@" D
 .	S lvnSql=$piece(sql,",",2) S lvnMap=$piece(sql,",",3)
 .	D addCode^UCPSLSR(sr," S @(""vList=""_$$RsMsXV^UCDBRT(."_lvnMap_",."_lvnSql_"))")
 .	Q 
 E  D addCode^UCPSLSR(sr," S vList="_$$RsMsXV^UCDBRT(.map,.sql))
 ;
 I '($ZLENGTH(sql)'>1980) D
 .	D addCode^UCPSLSR(sr," N vSql ;=noOpti")
 .	D setLong(.sr,"vSql",sql)
 .	D addCode^UCPSLSR(sr," S vEr=$$OPENCUR^%DBAPI(0,vSql,$C(9),vList,.vCurID,.vd,.vRm)")
 .	Q 
 E  D addCode^UCPSLSR(sr," S vEr=$$OPENCUR^%DBAPI(0,"_$S($E(sql,1)="@":lvnSql,1:$S(sql'["""":""""_sql_"""",1:$$QADD^%ZS(sql,"""")))_",$C(9),vList,.vCurID,.vd,.vRm)")
 ;
 D addCode^UCPSLSR(sr," S "_oLvn_"(vOid,-5)=1")
 D addCode^UCPSLSR(sr," S "_oLvn_"(vOid,1)=vCurID")
 D addCode^UCPSLSR(sr," I vEr<0 S "_oLvn_"(vOid,0)=0 S $ZE=""0,""_$ZPOS_"",%PSL-E-SQLFAIL,""_$TR($G(vRm),$C(10,44),$C(32,126)),$EC="",U1001,""")
 D addCode^UCPSLSR(sr," S "_oLvn_"(vOid,-2)=""$$"_fetchLab_"^""_$T(+0)")
 I $E(sql,1)="@" D
 .	D addCode^UCPSLSR(sr," S "_oLvn_"(vOid,-3)="_lvnMap_"(""SELNAM"")")
 .	D addCode^UCPSLSR(sr," S "_oLvn_"(vOid,-4)="_lvnMap_"(""SELTYP"")")
 .	;
 .	I '$D(dipx) Q 
 .	S lvnDpx=$piece(sql,",",4)
 .	D addCode^UCPSLSR(sr," I $D("_lvnDpx_") N v0,v1 S v0="""" F v1=1:1 S v0=$O("_lvnDpx_"(v0)) Q:v0=""""  S "_oLvn_"(vOid,.1,v1)="_lvnDpx_"(v0)")
 .	Q 
 E  D
 .	D setLong(.sr,oLvn_"(vOid,-3)",map("SELNAM"))
 .	D setLong(.sr,oLvn_"(vOid,-4)",map("SELTYP"))
 .	Q 
 ;
 D selCdAssign(.sr,$S($E(sql,1)="@":11,1:1),.dipx)
 ;
 D addCode^UCPSLSR(sr," S "_oLvn_"(vOid,0)=2")
 D addCode^UCPSLSR(sr," S vobjCurs(vCurID)=$STACK-$g(vOff)")
 D addCode^UCPSLSR(sr," Q vOid")
 ;
 Q 
 ;
 ; ---------------------------------------------------------------------
setLong(sr,lvn,lulit) ; insert code to assign "long" literal (using multiple code lines)
 N part
 N split
 D splitCode^UCGMC(lulit,0,"",.split)
 ;
 D addCode^UCPSLSR(sr," S "_lvn_"="_$S(split(1)'["""":""""_split(1)_"""",1:$$QADD^%ZS(split(1),"""")))
 F part=2:1:$order(split(""),-1) D addCode^UCPSLSR(sr," S "_lvn_"="_lvn_"_"_$S(split(part)'["""":""""_split(part)_"""",1:$$QADD^%ZS(split(part),"""")))
 Q 
 ;
 ; ---------------------------------------------------------------------
where(table,where,selmap) ; WHERE-clause of single table
 N sqllit
 ;
 N td S td=$$getPslTbl^UCXDD(table,1)
 ;
 N expr S expr=$$RsDyRT^UCDBRT($P(td,"|",3),table,where,"","","",.selmap)
 ;
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 S expr=$$TOKEN^%ZS(expr,.sqllit,"'")
 S expr=$E(expr,$F(expr," FROM "),1048575)
 ;
 S table=$piece(expr," WHERE ")
 ;
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 Q $$UNTOK^%ZS($E(expr,$F(expr," WHERE "),1048575),.sqllit)
 ;
 ; ---------------------------------------------------------------------
XvClose() ; 
 N VCLOSE S VCLOSE=$$XvCloseName()
 ;
 I ($D(methods("Object","killCasc","ResultSet"))#2) Q 
 ;
 ; ResultSet and DbSet use the same procedure
 S methods("Object","killCasc","ResultSet")=VCLOSE
 S methods("Object","killCasc","DbSet")=VCLOSE
 ;
 ; add vClose(oid) to code
 ;type PSLSubrou sr = PSL.addSubrou( VCLOSE, "(vOid)", "Close any ResultSet")
 ;do sr.addCode( " N vEr,vRm")
 ;do sr.addCode( " I $G("_ PSL.oLvn_ "(vOid,-5))=1,"_ PSL.oLvn_ "(vOid,0)'=0 S vEr=$$CLOSECUR^%DBAPI(0,"_ PSL.oLvn_ "(vOid,1),.vRm),"_ PSL.oLvn_ "(vOid,0)=0 I vEr<0 S $ZE=""0,""_$ZPOS_"",%PSL-E-SQLFAIL,""_$TR($G(vRm),$C(10,44),$C(32,126)),$EC="",U1001,""")
 ;do sr.addCode( " Q")
 ;
 Q 
 ;
 ; ---------------------------------------------------------------------
XvCloseC() ; 
 ;
 ;if PSL.subrouExists(VCLOSEC) quit VCLOSEC
 ;
 ;type PSLSubrou sr = PSL.addSubrou(VCLOSEC, "(vState,vCurID)", "Close optimized ResultSet")
 ;do sr.addCode(" N vEr,vRm")
 ;do sr.addCode(" I vState'=0 S vEr=$$CLOSECUR^%DBAPI(0,vCurID,.vRm),vState=0 I vEr<0 S $ZE=""0,""_$ZPOS_"",%PSL-E-SQLFAIL,""_$TR($G(vRm),$C(10,44),$C(32,126)),$EC="",U1001,""")
 ;do sr.addCode(" Q")
 ;
 Q "vCloseRDBOpt^vResultSet"
 ; ---------------------------------------------------------------------
XvCloseName() ; 
 Q "vCloseRDB^vResultSet"
 ;  #OPTION ResultClass ON
vSIG() ; 
 Q "61293^42411^Frans S.C. Witte^46304" ; Signature - LTD^TIME^USER^SIZE
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
