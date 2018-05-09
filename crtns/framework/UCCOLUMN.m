 ; 
 ; **** Routine compiled from DATA-QWIK Procedure UCCOLUMN ****
 ; 
 ; 02/24/2010 18:23 - pip
 ; 
 ;  #PACKAGE framework.psl
 ;  #OPTION  ResultClass ON
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
curVal(oid,tabnm,property,fset,objExpr,ptr) ; char pointer (*5) /MECH=REF:RW
 ;Boolean nest)  // nested?  /NOREC
 ;
 N return ; function return value
 ;
 I '(postCond=""),fset S $ZE="0,"_$ZPOS_","_"%PSL-E-SYNTAX,Postconditional not allowed for Column assignment",$EC=",U1001,"
 ;
 ;type String table = $$getReTable^UCGM( oid.class)
 ;
 I ptr Q $$colProp(oid,tabnm,property,fset,objExpr,.ptr)
 ;
 I $E(property,1)="@" Q $$dynamic(0,oid,tabnm,property,fset)
 ;
 I (tabnm="") S $ZE="0,"_$ZPOS_","_"%PSL-E-DYNAMIC,Dynamic record not supported",$EC=",U1001,"
 ;
 N td S td=$$getPslTbl(tabnm)
 ;
 S property=$$getColNm(property)
 I (property="") S $ZE="0,"_$ZPOS_","_"%PSL-E-REQUIRED,Missing property name",$EC=",U1001,"
 ;
 N ref S ref=tabnm_"."_property
 ;
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 D addXref^UCGM("P"_fset,ref,oid)
 ;
 N cd S cd=$$getPslCln(tabnm,property)
 S class=$$getClass^UCXDD(cd)
 ;
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 I $$getScope^UCGM(oid)="LITERAL" Q $$litVal(oid,property,fset)
 ;
 N bHasRoot
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 N bAudit S bAudit=''$$getAtt^UCGM(oid,$$getLevel^UCGM(oid),12)
 ;
 I fset,'bAudit,((","_$P(pslTbl(tabnm),"|",13)_",")[(","_property_",")),'($P(td,"|",8)'="GTM"),'((","_$P(pslTbl(tabnm),"|",3)_",")[(","_property_",")) D
 .	S bAudit=1
 .	D setNeedVobj^UCREC4OP(subRou,oid,1)
 .	Q 
 ;
 N accPos S accPos=$$clnByOvs^UCREC4OP(subRou,oid,cd,bAudit,fset,.bHasRoot)
 I 'bHasRoot,$$getSetting^PSLCC(.pslPrsr,"WARN","SCOPE",0) D WARN^UCGM("SCOPE: Variable "_oid_" may not have been instantiated")
 ;
 I oid["(" D
 .	I fset S return=$$getUpdCode^UCXDD(cd,oid,$C(31),bAudit,0)
 .	E  S return=$$getCurExpr^UCXDD(cd,oid,0)
 .	Q 
 E  D
 .	N decPos S decPos=$$getDec^UCREC4OP(subRou,oid,accPos)
 .	;
 .	;   #ACCEPT CR=27800; Date=2007-10-11; PGM=Frans S.C. Witte; Group=MISMATCH; passes Number as PSLIdentifier
 .	I 'fset S return=$$getCurExpr^UCXDD(cd,decPos,0) Q 
 .	S return=$$clnAsn1^UCREC4OP(decPos,accPos,$C(31))
 .	;
 .	; if td.recordType>1!td.isRdb do setAssign^UCREC4OP( PSL.subRou, oid, 2),setOpti^UCGM(oid, oid.scopeLevel, -1)
 .	I ($P(td,"|",8)'="GTM") D setAssign^UCREC4OP(subRou,oid,1)
 .	;   #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 .	I $P(td,"|",4)>1 D setOpti^UCGM(oid,$$getLevel^UCGM(oid),-1)
 .	Q 
 ;
 I return[$char(9) D
 .	I ($ZLENGTH(return)'>1980) S return=$translate(return,$char(9),$S(fset:"",1:"_")) Q 
 .	I fset S return=$$longSet(cd,return,bAudit) Q 
 .	S return=$$longGet(cd,return)
 .	Q 
 ;
 Q return
 ;
 ; ---------------------------------------------------------------------
getColNm(cln) ; column name
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 I $ascii(cln) Q $$UPCASE^UCGM(cln)
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 Q $$QSUB^%ZS($$UNTOK^%ZS(cln,tok),"""")
 ;
 ; ---------------------------------------------------------------------
getPslCln(tbl,cln) ; column name
 ;
 N ref
 ;
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 I $ascii(cln) S cln=$$UPCASE^UCGM(cln)
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 E  S cln=$$QSUB^%ZS($$UNTOK^%ZS(cln,tok),"""")
 ;
 S ref=tbl_"."_cln
 ;
 N $ET,$ES,$ZYER S $ZYER="ZE^UCGMR",$ZE="",$EC="",$ET="D:$TL>"_$TL_" rollback^vRuntime("_$TL_") Q:$Q&$ES """" Q:$ES  N voxMrk s voxMrk="_+$O(vobj(""),-1)_" G vCatch1^"_$T(+0)
 I '($D(pslCln(ref))#2) S pslCln(ref)=$$getPslCln^UCXDD(tbl,cln,.pslTbl)
 Q pslCln(ref)
 ;
 ; ---------------------------------------------------------------------
getPslTbl(tbl) ; table name
 ;
 N $ET,$ES,$ZYER S $ZYER="ZE^UCGMR",$ZE="",$EC="",$ET="D:$TL>"_$TL_" rollback^vRuntime("_$TL_") Q:$Q&$ES """" Q:$ES  N voxMrk s voxMrk="_+$O(vobj(""),-1)_" G vCatch2^"_$T(+0)
 I '($D(pslTbl(tbl))#2) S pslTbl(tbl)=$$getPslTbl^UCXDD(tbl,0)
 S pslTbl(tbl)=$$tAssert^UCXDD(pslTbl(tbl),1,.pslCln)
 Q pslTbl(tbl)
 ;
 ; ---------------------------------------------------------------------
longGet(cd,expr) ; 
 N cmt S cmt=$P(cd,"|",1)_"."_$P(cd,"|",2)_".get()"
 ;
 N sr S sr=$$vaddSubr("CoGet","()",cmt,1)
 ;
 D addCode^UCPSLSR(sr," N vV")
 ;
 N code S code="S vV="_$piece(expr,$char(9))
 N nxt
 N pce
 ;
 F pce=2:1:$L(expr,$char(9)) D
 .	S nxt=$piece(expr,$char(9),pce)
 .	I ($ZLENGTH(code)+($ZLENGTH(nxt)+1)'>1980) S code=code_"_"_nxt Q 
 .	D addCode^UCPSLSR(sr,code)
 .	S code=" S vV=vV_"_nxt
 .	Q 
 D addCode^UCPSLSR(sr,code)
 D addCode^UCPSLSR(sr," Q")
 ;
 Q "$$"_sr_"()"
 ;
 ; ---------------------------------------------------------------------
longSet(cd,leftexp,rightexp,mode) ; 
 N cmt S cmt=$P(cd,"|",1)_"."_$P(cd,"|",2)_".set("_leftexp_","_mode_")"
 ;
 N pce
 N sr S sr=$$vaddSubr("CoSet","(vV)",cmt,1)
 N expr S expr=$$getUpdCode^UCXDD(cd,leftexp,"vV",mode,0)
 ;
 F pce=1:1:$L(expr,$char(9)) D addCode^UCPSLSR(sr," "_$piece(expr,$char(9),pce))
 D addCode^UCPSLSR(sr," Q")
 ;
 Q " D "_sr_"("_rightexp_")"
 ;
 ; ---------------------------------------------------------------------
litVal(oid,property,fset) ; set (1) or get (0)
 I fset D ERROR^UCGM("Db class is read-Only under LITERAL scope") Q ""
 ;
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 N vOid S vOid=$$getExpr^UCGM(oid)
 I vOid="" D ERROR^UCGM("LITERAL scope "_oid_" was not instantiated") Q ""
 ;
 N val S val=$$propGet^DBSDYNRA(vOid,property)
 I (val=+val) Q val
 Q $S(val'["""":""""_val_"""",1:$$QADD^%ZS(val,""""))
 ;
 ; ---------------------------------------------------------------------
colProp(recVar,tabnm,colnm,fset,propExpr,ptr) ; character pointer (*5) /MECH=REFNAM:RW
 ;
 N optr S optr=ptr ; old value of ptr
 N ref ; Column property or method
 N name ; the name
 N params ; the parenthesis, and parameters
 ;
 S ptr=ptr+1 ; skip "."
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 S ref=$$ATOM^%ZS(propExpr,.ptr,".",,1)
 S name=$piece(ref,"(")
 ;
 I $ZCONVERT(ref,"U")="CURVAL" Q $$curVal(recVar,tabnm,colnm,fset,propExpr,.ptr)
 ;
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 D initClass^UCGM("Column")
 ;
 N prpid S prpid=$$findPSLProperty^PSLParser(.pslPrsr,.tknzr,"Column."_name,1)
 N mtdid S mtdid=$$findPSLMethod^PSLParser(.pslPrsr,.tknzr,"Column."_name,1)
 ;
 I (prpid=""),(mtdid="") S ptr=optr Q $$curVal(recVar,tabnm,colnm,fset,"",0)
 ;
 S class="Column"
 N colId
 N i
 ;
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 F i=1:1 S colId="vol"_i Q:$$getNew^UCGM(colId)="" 
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 D typeDec^UCGM(colId,class,"PUBLIC")
 ;
 ; Assert: we have either a property or a method
 N return
 I '(prpid="") D
 .	; not supported: property on dynamic columns
 .	I $E(colnm,1)="@" S $ZE="0,"_$ZPOS_","_"%PSL-E-DYNAMIC,Properties and methods not supported on dynamic columns",$EC=",U1001,"
 .	I ptr>0,fset S $ZE="0,"_$ZPOS_","_"%PSL-E-ACCESS,Column class property is readOnly",$EC=",U1001,"
 .	S colnm=$$getColNm(colnm) ; standardize name
 .	;   #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 .	S return=$$property^UCGM(colId,level,ref,fset,.class,.setVar)
 .	Q 
 E  D
 .	;   #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 .	D setInst^UCGM(colId,"",recVar_"."_$$UNTOK^%ZS(colnm,tok),level)
 .	;   #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 .	S return=$$method^UCGM(colId,level,ref,fset,.class,.setVar)
 .	Q 
 Q return
 ;
 ; ---------------------------------------------------------------------
des ; Property table.column.des ; Return Schema Description
 S return=$$QADD^%ZS($$DES^SQLDD(tabnm_"."_property),"""")
 Q 
 ;
 ; ---------------------------------------------------------------------
len ; Property table.column.len ; Return Schema Length
 N cd S cd=$$getPslCln(tabnm,property)
 ;
 S return=$P(cd,"|",7)
 I (return="") S return=$$QADD^%ZS(return,"""")
 Q 
 ;
 ; ---------------------------------------------------------------------
typ ; Property table.column.typ ; Return Schema type
 N cd S cd=$$getPslCln(tabnm,property)
 ;
 S return=$$QADD^%ZS($P(cd,"|",6),"""")
 Q 
 ;
 ; ---------------------------------------------------------------------
req ; Property table.column.req ; Return Schema is required
 S return=$$QADD^%ZS($$REQ^SQLDD(tabnm_"."_property),"""")
 Q 
 ;
 ; ---------------------------------------------------------------------
key ; Property table.column.key ; Return Schema key level (Null if not key)
 ;
 N cd S cd=$$getPslCln(tabnm,property)
 I $P(cd,"|",3)["*" S return=$P(cd,"|",4)
 E  S return=""""""
 ;
 Q 
 ;
 ; ---------------------------------------------------------------------
oldVal ; Property table.column.oldVal
  ; tablename as used by colProp
  ; columnname as used by colProp
  ; column descriptor cache
  ; column descriptor cache
  ; recordvar as used by colProp
 ;
 N ref S ref=tabnm_"."_colnm
 N cd S cd=$$caPslCln^UCXDD(.pslCln,ref,.pslTbl)
 N bHasRoot
 N accPos S accPos=$$clnByOvs^UCREC4OP(subRou,recVar,cd,0,0,.bHasRoot)
 ;
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 I 'bHasRoot,$$getScope^UCGM(recVar)'="LITERAL",$$getSetting^PSLCC(.pslPrsr,"WARN","SCOPE",0) D WARN^UCGM("SCOPE: Variable "_recVar_" may not have been instantiated")
 ;
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 D setOpti^UCGM(recVar,$$getLevel^UCGM(recVar),-1)
 ;
 S class=$$getClass^UCXDD(cd)
 S return=$$getOldExpr^UCXDD(cd,recVar,0)
 I return[$char(9) S return=$translate(return,$char(9),"_")
 Q 
 ;
 ; ---------------------------------------------------------------------
journal ; Property table.column.journal
  ; columnname as used by colProp
  ; recordvar as used by colProp
 ;
 S fset=0
 S return=oLvn_"("_recVar_",-400,"""_colnm_""")"
 D setOpti^UCGM(recVar,$$getLevel^UCGM(recVar),-1)
 Q 
 ;
 ; ---------------------------------------------------------------------
dynamic(external,var,table,property,fset) ; set (1) or get (0)
 ;
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 N varLvl S varLvl=$$getLevel^UCGM(var) ; type level of var
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 N bAudit S bAudit=''$$getAtt^UCGM(var,varLvl,12)
 ;
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 D setOpti^UCGM(var,varLvl,-1)
 D
 .	N $ET,$ES,$ZYER S $ZYER="ZE^UCGMR",$ZE="",$EC="",$ET="D:$TL>"_$TL_" rollback^vRuntime("_$TL_") Q:$Q&$ES """" Q:$ES  N voxMrk s voxMrk="_+$O(vobj(""),-1)_" G vCatch3^"_$T(+0)
 .	N dummy S dummy=$$insByOvs^UCREC4OP(subRou,var,"","U")
 .	Q 
 S property=$E(property,2,1048575)
 ;
 ; For now, resolve at runtime
 S class="String"
 ;
 ; Track indirection use if we know the table
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 I '(table="") D addXref^UCGM("I"_fset,table,var)
 ;
 I fset Q " D propSet^DBSDYNRA("_var_","_property_","_$C(31)_","_bAudit_","_external_")"
 Q "$$propGet^DBSDYNRA("_var_","_property_")"
 ;  #OPTION ResultClass ON
vSIG() ; 
 Q "61348^60532^Frans S.C. Witte^36690" ; Signature - LTD^TIME^USER^SIZE
 ; ----------------
 ;  #OPTION ResultClass 1
vaddSubr(p1,p2,p3,p4) ; PSL.addSubrou
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 I $get(p4) S:$E(p1,1)'="v" p1="v"_p1 S p1=$$findSubr^UCGM(p1,"")
 E  I $$hasSubr^UCGM(p1) D ERROR^UCGM("Subroutine exists: "_p1) Q p1
 D addSubr^UCGM(p1,p2,p3)
 Q p1
 ;
vCatch3 ; Error trap
 ;
 N errRec,$ET,$ES S errRec=$ZE,$EC="",$ET="Q",$ZE=""
 ; ignore insert error
 D ZX^UCGMR(voxMrk) Q 
 ;
vCatch2 ; Error trap
 ;
 N xcpt,$ET,$ES S xcpt=$ZE,$EC="",$ET="Q",$ZE=""
 I $P(xcpt,",",3)["RECNOFL" S $P(xcpt,",",3)="%PSL-E-INVALIDREF" S $P(xcpt,",",5)=tbl
 S $ZE=xcpt,$EC=",U1001,"
 D ZX^UCGMR(voxMrk) Q 
 ;
vCatch1 ; Error trap
 ;
 N xcpt,$ET,$ES S xcpt=$ZE,$EC="",$ET="Q",$ZE=""
 I $P(xcpt,",",3)["RECNOFL" S $P(xcpt,",",3)="%PSL-E-INVALIDREF" S $P(xcpt,",",5)=ref
 S $ZE=xcpt,$EC=",U1001,"
 D ZX^UCGMR(voxMrk) Q 
