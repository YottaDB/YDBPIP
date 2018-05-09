	; I18N=QUIT
	;
	; **** Routine compiled from DATA-QWIK Procedure UCCOLUMN ****
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
	; ---------------------------------------------------------------------
curVal(oid,property,fset,objExpr,ptr,nest)	;
	;
	; uses commands("WARN","SCOPE")
	;
	N return ; function return value
	;
	N table S table=$$getReTable^UCGM($$getAtt^UCGM(oid,,1))
	;
	I ptr Q $$colProp(oid,property,fset,objExpr,.ptr)
	;
	I $E(property,1)="@" Q $$dynamic(0,oid,table,property,fset)
	;
	I (table="") S $ZS="-1,"_$ZPOS_","_"%PSL-E-DYNAMIC,Dynamic record not supported" X $ZT
	;
	N td S td=$$getPslTbl(table)
	;
	S property=$$getColNm(property)
	I (property="") S $ZS="-1,"_$ZPOS_","_"%PSL-E-REQUIRED,Missing property name" X $ZT
	;
	N ref S ref=table_"."_property
	;
	D addXref^UCGM("P"_fset,ref,oid)
	;
	N cd S cd=$$getPslCln(table,property)
	S class=$$getClass^UCXDD(cd)
	;
	I $$getAtt^UCGM(oid,,3)="LITERAL" Q $$litVal(oid,property,fset)
	;
	N bHasRoot
	N bAudit S bAudit=''$$getAtt^UCGM(oid,$$getLevel^UCGM(oid),12)
	;
	I 'bAudit,((","_$P(pslTbl(table),"|",13)_",")[(","_property_",")),'((","_$P(pslTbl(table),"|",3)_",")[(","_property_",")) S bAudit=1
	;
	N accPos S accPos=$$clnByOvs^UCREC4OP(subRou,oid,cd,bAudit,fset,.bHasRoot)
	I 'bHasRoot,$get(commands("WARN","SCOPE")) D WARN^UCGM("SCOPE: Variable "_oid_" may not have been instantiated")
	;
	I oid["(" D
	.	I fset S return=$$getUpdCode^UCXDD(cd,oid,$C(31),bAudit)
	.	E  S return=$$getCurExpr^UCXDD(cd,oid,0)
	.	Q 
	E  D
	.	N decPos S decPos=$$getDec^UCREC4OP(subRou,oid,accPos)
	.	;
	.	I 'fset S return=$$getCurExpr^UCXDD(cd,decPos,0) Q 
	.	S return=$$clnAsn1^UCREC4OP(decPos,accPos,$C(31))
	.	;
	.	; if td.recordType>1!td.isRdb do setAssign^UCREC4OP( PSL.subRou, oid, 2),setOpti^UCGM(oid, oid.scopeLevel, -1)
	.	I ($P(td,"|",8)'="GTM") D setAssign^UCREC4OP(subRou,oid,1)
	.	I $P(td,"|",4)>1 D setOpti^UCGM(oid,$$getLevel^UCGM(oid),-1)
	.	Q 
	;
	I return[$char(9) D
	.	I ($L((return))'>1980) S return=$translate(return,$char(9),$SELECT(fset:"",1:"_")) Q 
	.	I fset S return=$$longSet(cd,return,bAudit) Q 
	.	S return=$$longGet(cd,return)
	.	Q 
	;
	Q return
	;
	; ---------------------------------------------------------------------
getColNm(cln)	; column name
	I $ascii(cln) Q $$UPCASE^UCGM(cln)
	Q $$QSUB^%ZS($$UNTOK^%ZS(cln,tok),"""")
	;
	; ---------------------------------------------------------------------
getPslCln(tbl,cln)	;
	;
	N voZT set voZT=$ZT
	N ref
	;
	I $ascii(cln) S cln=$$UPCASE^UCGM(cln)
	E  S cln=$$QSUB^%ZS($$UNTOK^%ZS(cln,tok),"""")
	;
	S ref=tbl_"."_cln
	;
	N $ZT S $ZT="D ZX^UCGMR("_+$O(vobj(""),-1)_","_$ZL_",""vtrap1^"_$T(+0)_""")"
	I '($D(pslCln(ref))#2) S pslCln(ref)=$$getPslCln^UCXDD(tbl,cln,.pslTbl)
	Q pslCln(ref)
	;
	; ---------------------------------------------------------------------
getPslTbl(tbl)	; table name
	;
	N voZT set voZT=$ZT
	N $ZT S $ZT="D ZX^UCGMR("_+$O(vobj(""),-1)_","_$ZL_",""vtrap2^"_$T(+0)_""")"
	I '($D(pslTbl(tbl))#2) S pslTbl(tbl)=$$getPslTbl^UCXDD(tbl,0)
	S pslTbl(tbl)=$$tAssert^UCXDD(pslTbl(tbl),1,.pslCln)
	Q pslTbl(tbl)
	;
	; ---------------------------------------------------------------------
longGet(cd,expr)	;
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
	.	I ($L((code))+$L(nxt)+1'>1980) S code=code_"_"_nxt Q 
	.	D addCode^UCPSLSR(sr,code)
	.	S code=" S vV=vV_"_nxt
	.	Q 
	D addCode^UCPSLSR(sr,code)
	D addCode^UCPSLSR(sr," Q")
	;
	Q "$$"_sr_"()"
	;
	; ---------------------------------------------------------------------
longSet(cd,leftexp,rightexp,mode)	;
	N cmt S cmt=$P(cd,"|",1)_"."_$P(cd,"|",2)_".set("_leftexp_","_mode_")"
	;
	N pce
	N sr S sr=$$vaddSubr("CoSet","(vV)",cmt,1)
	N expr S expr=$$getUpdCode^UCXDD(cd,leftexp,"vV",mode)
	;
	F pce=1:1:$L(expr,$char(9)) D addCode^UCPSLSR(sr," "_$piece(expr,$char(9),pce))
	D addCode^UCPSLSR(sr," Q")
	;
	Q " D "_sr_"("_rightexp_")"
	;
	; ---------------------------------------------------------------------
litVal(oid,property,fset)	;
	I fset D ERROR^UCGM("Db class is read-Only under LITERAL scope") Q ""
	;
	N vOid S vOid=$$getExpr^UCGM(oid)
	I vOid="" D ERROR^UCGM("LITERAL scope "_oid_" was not instantiated") Q ""
	;
	N val S val=$$propGet^DBSDYNRA(vOid,property)
	I (val=+val) Q val
	Q $S(val'["""":""""_val_"""",1:$$QADD^%ZS(val,""""))
	;
	; ---------------------------------------------------------------------
colProp(recVar,colnm,fset,propExpr,ptr)	;
	;
	N optr S optr=ptr ; old value of ptr
	N prop ; Column property
	;
	S ptr=ptr+1 ; skip "."
	S prop=$$ATOM^%ZS(propExpr,.ptr,".",,1)
	;
	I $$vStrUC(prop)="CURVAL" Q $$curVal(recVar,colnm,fset,propExpr,.ptr)
	;
	N z S z=$$opGet^UCXOBJ(,"Column",prop,1)
	;
	I (z="") S ptr=optr Q $$curVal(recVar,colnm,fset,"",0)
	;
	I ptr>0,fset D ERROR^UCGM("Column class property is readOnly") Q ""
	;
	S class="Column"
	N colId
	N i
	;
	F i=1:1 S colId="vol"_i Q:$$getNew^UCGM(colId)="" 
	D typeDec^UCGM(colId,class,"PUBLIC")
	;
	S colnm=$$getColNm(colnm) ; standardize name
	Q $$property^UCGM(colId,level,prop,.class,.setVar)
	;
	; ---------------------------------------------------------------------
des	; Property table.column.des ; Return Schema Description
	S return=$$QADD^%ZS($$DES^SQLDD(table_"."_property))
	Q 
	;
	; ---------------------------------------------------------------------
len	; Property table.column.len ; Return Schema Length
	N cd S cd=$$getPslCln(table,property)
	;
	S return=$P(cd,"|",7)
	I (return="") S return=$$QADD^%ZS(return,"""")
	Q 
	;
	; ---------------------------------------------------------------------
typ	; Property table.column.typ ; Return Schema type
	N cd S cd=$$getPslCln(table,property)
	;
	S return=$$QADD^%ZS($P(cd,"|",6),"""")
	Q 
	;
	; ---------------------------------------------------------------------
req	; Property table.column.req ; Return Schema is required
	S return=$$QADD^%ZS($$REQ^SQLDD(table_"."_property))
	Q 
	;
	; ---------------------------------------------------------------------
key	; Property table.column.key ; Return Schema key level (Null if not key)
	;
	N cd S cd=$$getPslCln(table,property)
	I $P(cd,"|",3)["*" S return=$P(cd,"|",4)
	E  S return=""""""
	;
	Q 
	;
	; ---------------------------------------------------------------------
oldVal	; Property table.column.oldVal
	; columnname as used by colProp
	; references commands("WARN","SCOPE")
	; column descriptor cache
	; column descriptor cache
	; recordvar as used by colProp
	;
	N table S table=$$getReTable^UCGM($$getAtt^UCGM(recVar,,1))
	N ref S ref=table_"."_colnm
	N cd S cd=$$caPslCln^UCXDD(.pslCln,ref,.pslTbl)
	N bHasRoot
	N accPos S accPos=$$clnByOvs^UCREC4OP(subRou,recVar,cd,0,0,.bHasRoot)
	;
	I 'bHasRoot,$$getAtt^UCGM(recVar,,3)'="LITERAL",$get(commands("WARN","SCOPE")) D WARN^UCGM("SCOPE: Variable "_recVar_" may not have been instantiated")
	;
	D setOpti^UCGM(recVar,$$getLevel^UCGM(recVar),-1)
	;
	S class=$$getClass^UCXDD(cd)
	S return=$$getOldExpr^UCXDD(cd,recVar,0)
	I return[$char(9) S return=$translate(return,$char(9),"_")
	Q 
	;
	; ---------------------------------------------------------------------
journal	; private ; Property ; table.column.journal
	; columnname as used by colProp
	; recordvar as used by colProp
	;
	S fset=0
	S return=oLvn_"("_recVar_",-400,"""_colnm_""")"
	Q 
	;
	; ---------------------------------------------------------------------
getKey(keys,di)	; Return the key index
	I '((","_keys_",")[(","_di_",")) Q ""
	Q -2-$L($piece((","_keys_","),","_di_",",1),",")
	;
	; ---------------------------------------------------------------------
dynamic(external,var,table,property,fset)	;
	;
	; used to generate next label
	; PSLCoumn cache
	; PSLTable cache
	; used to pass "setProperty"
	;
	N dynamic ; function return value
	N i ; scratch variable
	N nodChk ; node check for type 11 tables
	N varLvl S varLvl=$$getLevel^UCGM(var) ; type level of var
	N bAudit S bAudit=''$$getAtt^UCGM(var,varLvl,12)
	;
	D setOpti^UCGM(var,varLvl,-1)
	D
	.	N $ZT S $ZT="D ZX^UCGMR("_+$O(vobj(""),-1)_","_$ZL_",""vtrap3^"_$T(+0)_""")"
	.	N dummy S dummy=$$insByOvs^UCREC4OP(subRou,var,"","U")
	.	Q 
	S property=$E(property,2,1048575)
	;
	; For now, resolve at runtime
	S class="String"
	;
	I (table=""),fset Q " D propSet^DBSDYNRA("_var_","_property_","_$C(31)_","_bAudit_")"
	I (table="") Q "$$propGet^DBSDYNRA("_var_","_property_")"
	;
	I $E(property,1)="@" Q $E(property,2,$E(property,2,1048575))
	;
	; Track indirection use
	D addXref^UCGM("I"_fset,table,var)
	;
	N td S td=$$getPslTbl(table)
	N comment S comment="Record"_$$vStrUC(table)_"."
	;
	I fset D
	.	I '($P(td,"|",13)="") S bAudit=1
	.	S comment=comment_"setColumn("_bAudit_","_external_")"
	.	Q 
	E  S comment=comment_"getColumn()"
	;
	; Find next label number to use
	; type String label = "vCoInd"
	; for i = 1:1 quit:'append(label_i).data()  quit:append(label_i,2).piece("; ",2)=comment
	; set label = label_ i
	N label S label=$$findSubr^UCGM("vCoInd",comment)
	;
	N fpl S fpl="String vOid, String vCol"
	I fset D
	.	S fpl=fpl_", String vVal"
	.	S dynamic=var_","_property
	.	S struct("setProperty")=label
	.	Q 
	E  S dynamic="$$"_label_"("_var_","_property_")"
	;
	I '$D(append(label)) D
	.	N sr S sr=$$vopenBuf(fpl,comment)
	.	;
	.	; replace next line by vP = PSL.getPSLColumn() once supported
	.	D vaddBuff(sr," type PSLColumn vP = PSL.getPSLColumn("""_table_""",vCol.upperCase())")
	.	D vaddBuff(sr," type String vNod=vP.node")
	.	D vaddBuff(sr," type Number vPos")
	.	;
	.	; if audit/rdb and set, or table has Blob/Memo, dataType is needed
	.	I fset!($P(td,"|",5)["B")!($P(td,"|",5)["M") D vaddBuff(sr," type String vTyp = vP.dataType")
	.	;
	.	D dynKey(td,sr,fset,bAudit)
	.	;
	.	I $P(td,"|",11) D
	..		D vaddBuff(sr," //")
	..		D vaddBuff(sr," type String vCmp=vP.computation")
	..		I 'fset,$P(td,"|",4)=1 D
	...			D vaddBuff(sr," if vCmp'="""" set vCmp=vP.getCurrentExpr(""vOid"",0) quit @vCmp")
	...			Q 
	..		E  I 'fset D
	...			D vaddBuff(sr," if vCmp'="""" do { quit @vCmp")
	...			D vaddBuff(sr,"   type String vpt()")
	...			D vaddBuff(sr,"   do parseCmp^UCXDD( vCmp, .vpt())")
	...			D vaddBuff(sr,"   type Number vCnt = vpt("""").order(-1)")
	...			D vaddBuff(sr,"   type String vVal")
	...			D vaddBuff(sr,"   type Number vElm")
	...			D vaddBuff(sr,"   set vCmp=""""")
	...			D vaddBuff(sr,"   for vElm=2:2:vCnt set vCmp=vCmp_vpt(vElm-1)_($$"_label_"(vOid,vpt(vElm))).addQuotes()")
	...			D vaddBuff(sr,"   set vCmp=vCmp_vpt(vCnt)")
	...			D vaddBuff(sr," }")
	...			Q 
	..		E  D vaddBuff(sr," if vCmp'="""" throw Class.new(""Error"",""%PSL-E-INVALIDREF"")")
	..		Q 
	.	D vaddBuff(sr," //")
	.	D vaddBuff(sr," set vPos = vP.position")
	.	;
	.	I $P(td,"|",4)>1 D dynLd(td,sr,.nodChk)
	.	I ($P(td,"|",5)["B")!($P(td,"|",5)["M") D dynLdBM(td,sr,fset,bAudit)
	.	;
	.	I 'fset D dynGet(td,sr,$get(nodChk))
	.	I fset D dynSet(td,sr,$get(nodChk),bAudit,external)
	.	;
	.	D INSERT^UCMETHOD(sr,label,"")
	.	K vobj(+$G(sr)) Q 
	;
	I fset S struct("setProperty")=label
	;
	Q dynamic
	;
	; ---------------------------------------------------------------------
dynGet(td,sr,check)	;
	;
	N dlm S dlm="$C("_$P(td,"|",10)_")"
	N ftyp S ftyp=$P(td,"|",4)
	;
	D vaddBuff(sr," type String vRet")
	;
	; RDB masterfield retrieval preceeds ordinary column construction
	N mlst S mlst=$P(td,"|",14)
	I '(mlst=""),($P(td,"|",8)'="GTM") D
	.	N code ; masterfield code array
	.	N i N j ; iterators
	.	N mcol ; master column name
	.	N mget ; masterfield retrieval expr
	.	N z ; scratch var
	.	F i=1:1:$S((mlst=""):0,1:$L(mlst,",")) D
	..		S mcol=$piece(mlst,",",i)
	..		S mget=$$rtMfRDB^UCCOLSF($P(td,"|",1),mcol,"vOid")
	..		S z=" if vCol="""_mcol_""" "
	..		D getMf2A^UCCOLSF(mget,"vRet",.code)
	..		S j=$order(code(""),-1)
	..		I j>1 D
	...			D vaddBuff(sr,z_"do { quit vRet")
	...			F j=1:1:j D vaddBuff(sr,"  "_code(j))
	...			D vaddBuff(sr,"}")
	...			Q 
	..		E  D vaddBuff(sr,z_"quit "_$E(code(1),$F(code(1),"vRet="),1048575))
	..		Q 
	.	Q 
	;
	I ftyp=11 D  ; need to include conditional code
	.	D vaddBuff(sr," if "_check_" set vRet="_"vobj"_"(vOid,vNod)")
	.	D vaddBuff(sr," else  set vRet=vobj(vOid)")
	.	Q 
	E  D  ; correct node always known at compile time
	.	N ref
	.	;
	.	I ftyp=1 S ref="vobj"_"(vOid)"
	.	E  S ref="vobj"_"(vOid,vNod)"
	.	D vaddBuff(sr," set vRet="_ref)
	.	Q 
	D vaddBuff(sr," set vRet=vRet.piece("_dlm_",vPos)")
	;
	I '(mlst=""),'($P(td,"|",8)'="GTM") D
	.	N z S z="$$getSf^UCCOLSF(vRet,vP.subfieldTag,vP.subfieldMajor,vP.subfieldMinor,vP.subfieldPosition)"
	.	D vaddBuff(sr," if 'vP.subfieldPosition.isNull() quit $$getSf^UCCOLSF(vRet,vP.subfieldTag,vP.subfieldMajor,vP.subfieldMinor,vP.subfieldPosition)")
	.	Q 
	D vaddBuff(sr," quit vRet")
	Q 
	;
	; ---------------------------------------------------------------------
dynKey(td,sr,fset,bAudit)	;
	N i
	N keys S keys=$P(td,"|",3)
	N z
	;
	; retrieve a key value
	I keys'="",'fset D
	.	S z=" if vNod[""*"" quit "_oLvn_"(vOid,"
	.	I $L(keys,",")=1 S z=z_"-3)"
	.	E  D
	..		;set z=z_"$S("
	..		;for i=1:1:keys.length(",")-1 set z = z_"vCol="""_keys.piece(",",i)_""":-"_(i+2)_","
	..		;set z=z_"1:-"_(i+3)_")"
	..		S z=z_"-vP.position-2)"
	..		Q 
	.	D vaddBuff(sr,z_".get()")
	.	Q 
	;
	; assign to a key value
	I keys'="",fset D
	.	S z=" if vNod[""*"" set vPos="
	.	I $L(keys,",")=1 S z=z_"-3"
	.	E  D
	..		;set z=z_"$S("
	..		;for i=1:1:keys.length(",")-1 set z = z_"vCol="""_keys.piece(",",i)_""":-"_(i+2)_","
	..		;set z=z_"1:-"_(i+3)_")"
	..		S z=z_"-vP.position-2"
	..		Q 
	.	; if Record.setAuditFlag(1), then add code to track change of key column value
	.	I bAudit D
	..		N oldLvn S oldLvn=$$cdOldLvn^UCXDD("vOid","vP.position_""*""","vCol")
	..		S z=z_" set:'"_oldLvn_".exists() "_oldLvn_"=vTyp_""000""_"_oLvn_"(vOid,vPos)"
	..		Q 
	.	I ($P(td,"|",8)'="GTM") D  ; include assignment(s) to -150 for key column
	..		N set150 S set150=$$cdRdbAsn^UCXDD("vOid",""""_$P(td,"|",9)_"""","vP.internalColumn","""0*""","vPos","$$toValMod^UCXDD(vTyp,vP.isNullToZero)")
	..		I $P(td,"|",9)["," D
	...			N t
	...			N setNod N setTbl
	...			F t=1:1:$S(($P(td,"|",9)=""):0,1:$L($P(td,"|",9),",")) D
	....				S setTbl=$piece($P(td,"|",9),",",t)
	....				S setNod=$$tbl2nod^DBMAP(setTbl)
	....				I '(setNod="") S set150=set150_","_$$cdRdbAsn^UCXDD("vOid",""""_setTbl_"""","vP.internalColumn",setNod,"vPos","$$toValMod^UCXDD(vTyp,vP.isNullToZero)")
	....				Q 
	...			Q 
	..		S z=z_" set "_set150
	..		Q 
	.	D vaddBuff(sr,z_" set "_oLvn_"(vOid,vPos)=vVal quit")
	.	Q 
	Q 
	;
	; ---------------------------------------------------------------------
dynLd(td,sr,btmKeyCk)	;
	N ftyp S ftyp=$P(td,"|",4)
	N gbl S gbl=$$getGbl^UCXDD(td,"vOid")
	N keys S keys=$P(td,"|",3)
	N ref S ref=oLvn_"(vOid,vNod)"
	N sublst
	N var S var="vOid"
	;
	I (","_$P(td,"|",15)[",""v") D
	.	D vaddBuff(sr," type String vNd1 = vNod set vNod = vP.getCurrentNode()")
	.	S btmKeyCk="vNod'="""""
	.	S sublst="vNd1"
	.	Q 
	E  D
	.	S btmKeyCk="vNod'="""_$piece(keys,",",$L(keys,","))_""""
	.	S sublst="vNod"
	.	Q 
	;
	I keys="" D  Q  ; can never occur for RDB (td.recordType > 1)
	.	;if 'gbl.endsWith("(") set gbl = gbl_ ","
	.	D vaddBuff(sr," if '"_ref_".data() set "_ref_"="_gbl_sublst_").get()")
	.	Q 
	;
	N z S z=" if "
	I ftyp=11 S z=z_btmKeyCk_","
	S z=z_"'"_ref_".data()"
	I ($P(td,"|",5)["B")!($P(td,"|",5)["M") S z=z_",""MB""'[vTyp"
	D vaddBuff(sr,z_" do {")
	D vaddBuff(sr,"   if '"_oLvn_"(vOid,-2).get() set "_ref_"="""" quit")
	I ($P(td,"|",8)'="GTM") D
	.	D vaddBuff(sr,"   new vData,vEr,vRm")
	.	N z S z="   set vEr=$$SELECT^%DBAPI(0"
	.	S z=z_",""SELECT * FROM ""_ vP.internalTable_ "" where "_keys_"=:v1"""
	.	S z=z_",$C("_$P(td,"|",10)_")"
	.	D vaddBuff(sr,z_",vobj(vOid,-3)_$C("_$P(td,"|",10)_"),.vData,.vRm)")
	.	D vaddBuff(sr,"   if vEr<0 throw Class.new(""Error"",""%PSL-E-SELFAIL"")")
	.	D vaddBuff(sr,"   set "_ref_"=vData")
	.	Q 
	E  D
	.	D vaddBuff(sr,"   set "_ref_"="_gbl_sublst_").get()")
	.	Q 
	D vaddBuff(sr," }")
	;
	Q 
	;
	; ---------------------------------------------------------------------
dynLdBM(td,sr,fset,bAudit)	;
	N BMNODE
	N gbl S gbl=$$getGbl^UCXDD(td,"vOid")
	N gblBM ; Global that contains Blob/Memo
	;
	I $P(td,"|",4)=1,'($P(td,"|",8)'="GTM") D
	.	S BMNODE="vobj(vOid,1,1)"
	.	S gblBM=gbl_"v1)"
	.	Q 
	E  D
	.	S BMNODE="vobj(vOid,vNod,1)"
	.	S gblBM=gbl_"vNod,v1)"
	.	Q 
	;
	I 'fset!(bAudit&($P(td,"|",8)'="GTM")) D
	.	D vaddBuff(sr," if ""MB""[vTyp do {"_$SELECT(fset:"",1:" quit "_BMNODE))
	.	D vaddBuff(sr,"   if "_BMNODE_".exists() quit")
	.	D vaddBuff(sr,"   if 'vobj(vOid,-2).get() set "_BMNODE_"="""" quit")
	.	I ($P(td,"|",8)'="GTM") D
	..		N dlm S dlm="$C("_$P(td,"|",10)_")"
	..		N i
	..		N keys S keys=$P(td,"|",3)
	..		N lst S lst="$$QADD^%ZS(vobj(vOid,-3))"
	..		N whr S whr=" where "_$piece(keys,",")_"=:v1"
	..		N z
	..		F i=2:1:$L(keys,",") D
	...			S whr=whr_" AND "_$piece(keys,",",i)_"=:v"_i
	...			S lst=lst_"_"_dlm_"_"_"$$QADD^%ZS(vobj(vOid,-"_(i-2)_"))"
	...			Q 
	..		D vaddBuff(sr,"   // Incremental load of Blob/Memo")
	..		D vaddBuff(sr,"   new vData,vEr,vList,vRm,vSql")
	..		S z="""SELECT ""_vP.internalColumn_"" FROM ""_vP.internalTable_"""
	..		D vaddBuff(sr,"   set vSql="_"""SELECT ""_vP.internalColumn_"" FROM ""_vP.internalTable_"""_whr_"""")
	..		D vaddBuff(sr,"   set vList="_lst)
	..		D vaddBuff(sr,"   set vEr=$$SELECT^%DBAPI(0,vSql,"_dlm_",vList,.vData,.vRm)")
	..		D vaddBuff(sr,"   if vEr<0 throw Class.new(""Error"",""%PSL-E-SELFAIL"")")
	..		D vaddBuff(sr,"   set "_BMNODE_"=vData")
	..		Q 
	.	E  D
	..		D vaddBuff(sr,"   type String v1,vVal set (v1,vVal)=""""")
	..		D vaddBuff(sr,"   for  set v1="_gblBM_".order() quit:v1.isNull()  set vVal=vVal_"_gblBM)
	..		D vaddBuff(sr,"   set "_BMNODE_"=vVal")
	..		Q 
	.	D vaddBuff(sr," }")
	.	Q 
	Q 
	;
	; ---------------------------------------------------------------------
dynSet(td,sr,check,bAudit,bExtern)	;
	;
	N TBL S TBL=$P(td,"|",1)
	I $$vDbEx1() S bAudit=1
	;
	N BMNODE
	I $P(td,"|",4)=1 S BMNODE="vobj"_"(vOid,1,1)"
	E  S BMNODE="vobj"_"(vOid,vNod,1)"
	;
	N getPce S getPce=".piece($C("_$P(td,"|",10)_"),vPos)"
	N ftyp S ftyp=$P(td,"|",4)
	N bRdb S bRdb=($P(td,"|",8)'="GTM")
	N bBM S bBM=($P(td,"|",5)["B")!($P(td,"|",5)["M")
	N z ; scratch variable
	;
	N curVal
	I ftyp=1 S curVal="vobj"_"(vOid)"
	E  I ftyp=10 S curVal="vobj"_"(vOid,vNod)"
	E  S curVal="$S("_check_":"_"vobj"_"(vOid,vNod),1:"_"vobj"_"(vOid))"
	S curVal=curVal_getPce
	;
	I bExtern!bRdb D vaddBuff(sr," type Boolean vNul = vP.isNullToZero")
	;
	I bExtern D  ; convert external to internal
	.	D vaddBuff(sr," if ""CDLU""[vTyp set vVal=$$INT^%ZM(vVal,vTyp)")
	.	D vaddBuff(sr," if ""$N""[vTyp,'vVal.isNull()!vNul set vVal=+$$INT^%ZM(vVal,vTyp,,vP.precision)")
	.	Q 
	;
	; handle masterfield assignments (identical on RDB and MDB)
	N mlst S mlst=$P(td,"|",14)
	I '(mlst="") D
	.	N i ; iterator
	.	N mcol ; master column name
	.	F i=1:1:$S((mlst=""):0,1:$L(mlst,",")) D
	..		S mcol=$piece(mlst,",",i)
	..		D vaddBuff(sr," if vCol="""_mcol_""" do "_$$setMaster^UCCOLSF($P(td,"|",1),mcol,bAudit)_"(vOid,vVal) quit")
	..		Q 
	.	Q 
	;
	; handle -150 maintenance for RDB
	I bRdb D
	.	N nodExpr S nodExpr=$SELECT(ftyp=1:"""0*""",1:"$S("_check_":vNod,1:""0*"")")
	.	D vaddBuff(sr," set "_$$cdRdbAsn^UCXDD("vOid","vP.internalTable","vP.internalColumn",nodExpr,"vPos","$$toValMod^UCXDD(vTyp,vNul)"))
	.	Q 
	;
	I (ftyp>1)!bAudit D vaddBuff(sr,"type String vOldNod=vP.getOldNode(0)")
	N oldLvn S oldLvn=$$cdOldLvn^UCXDD("vOid","vOldNod","vCol")
	;
	; handle vobj(vOid,-100,vOldNod,vCol) if bAudit
	I bAudit D
	.	N cur
	.	I '(mlst=""),'bRdb D
	..		; additional code to retrieve subfield.oldVal on MDB
	..		D vaddBuff(sr," type String vOld = "_curVal)
	..		S z=$$GETSUB^UCSTRING("vP.subfieldTag","vP.subfieldMajor","vP.subfieldMinor","vP.subfieldPosition","vOld",1)
	..		D vaddBuff(sr," if 'vP.subfieldPosition.isNull() set vOld="_z)
	..		S cur="vOld"
	..		Q 
	.	E  S cur=curVal
	.	;
	.	; exclude -100 maintenance of Blob/Memo on MDB (if present)
	.	I bBM,'bRdb S z="""MB""'[vTyp,"
	.	E  S z=""
	.	S z=" if "_z_"'$D("_oldLvn_")) set "
	.	D vaddBuff(sr,z_oldLvn_"=vTyp_$E(1000+vPos,2,4)_"_cur)
	.	Q 
	;
	; Independent of audit, maintain vobj(vOid,-100,vOldNod), except for type 1 tables
	I ftyp>1 D vaddBuff(sr," set "_$$cdNodChg^UCXDD("vOid","vOldNod")_"=""""")
	;
	; Assignment to Blob/Memo possible without additional processing
	I bBM D vaddBuff(sr," if ""MB""[vTyp set "_BMNODE_"=vVal quit")
	;
	I '(mlst=""),'bRdb D
	.	; additional code to set subfield on MDB
	.	S z=$$PUTSUB^UCSTRING("vVal","vP.subfieldTag","vP.subfieldMajor","vP.subfieldMinor","vP.subfieldPosition",curVal,1)
	.	D vaddBuff(sr," if 'vP.subfieldPosition.isNull() set vVal="_z)
	.	Q 
	;
	; now we are ready to generate the code for the final assignment
	I ftyp=1 D vaddBuff(sr," set "_"vobj"_"(vOid)"_getPce_"=vVal")
	I ftyp=10 D vaddBuff(sr," set "_"vobj"_"(vOid,vNod)"_getPce_"=vVal")
	I ftyp=11 D
	.	D vaddBuff(sr," if "_check_" set "_"vobj"_"(vOid,vNod)"_getPce_"=vVal quit")
	.	D vaddBuff(sr," set "_"vobj"_"(vOid)"_getPce_"=vVal")
	.	Q 
	D vaddBuff(sr," quit")
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
vStrUC(vObj)	; String.upperCase
	;
	;  #OPTIMIZE FUNCTIONS OFF
	Q $translate(vObj,"abcdefghijklmnopqrstuvwxyz±≥µ∂π∫ªºæø‡·‚„‰ÂÊÁËÈÍÎÏÌÓÔÒÚÛÙıˆ¯˘˙˚¸˝˛","ABCDEFGHIJKLMNOPQRSTUVWXYZ°£•¶©™´¨ÆØ¿¡¬√ƒ≈∆«»… ÀÃÕŒœ–—“”‘’÷ÿŸ⁄€‹›ﬁ")
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
	;
vDbEx1()	;	min(1): DISTINCT %LIBS,FID,INDEXNM FROM DBTBL8 WHERE %LIBS='SYSDEV' and FID=:TBL
	;
	N vsql2
	;
	S vsql2=""
	S vsql2=$O(^DBTBL("SYSDEV",8,TBL,vsql2),1) I vsql2="" Q 0
	Q 1
	;
vtrap1	;	Error trap
	;
	N xcpt S xcpt=$ZS
	I $P(xcpt,",",3)["RECNOFL" S $P(xcpt,",",3)="%PSL-E-INVALIDREF" S $P(xcpt,",",5)=ref
	S $ZS=xcpt X voZT
	Q 
	;
vtrap2	;	Error trap
	;
	N xcpt S xcpt=$ZS
	I $P(xcpt,",",3)["RECNOFL" S $P(xcpt,",",3)="%PSL-E-INVALIDREF" S $P(xcpt,",",5)=tbl
	S $ZS=xcpt X voZT
	Q 
	;
vtrap3	;	Error trap
	;
	N errRec S errRec=$ZS
	; ignore insert error
	Q 
