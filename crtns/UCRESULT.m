UCRESULT	;
	;
	; **** Routine compiled from DATA-QWIK Procedure UCRESULT ****
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
	; ---------------------------------------------------------------------
isEmpty	; method ResultSet.isEmpty; returns Logical
	;
	S return="'$G(vobj("_objectName_",0))"
	;
	I $$vPSLopti(objectName) S return=$$patch^UCPATCH(subRou,objectName,objectLevel,return)
	Q 
	;
	; ---------------------------------------------------------------------
getRecord	; method DbSet.getRecord; returns Record<class>, classed by identifier
	;
	N keys N lvn N par N table
	;
	S class=$$getAtt^UCGM(var,varLevel,1)
	I '$$isRecord^UCGM(class) D ERROR^UCGM("Invalid identifier class: "_class) Q 
	;
	S table=$$getReTable^UCGM(class)
	;
	I '($D(fsn(table))#2) D fsn^SQLDD(.fsn,table) I ER Q 
	;
	S keys=$piece(fsn(table),"|",3) S par=""
	;
	I (keys="")
	E  I $L(keys,",")=1 S par=":vobj("_objectName_")"
	;
	E  D
	.	;
	.	N i
	.	F i=1:1:$L(keys,",") S par=par_",:$P(vobj("_objectName_"),$C(9),"_i_")"
	.	S par=$E(par,2,1048575)
	.	Q 
	;
	S actual(1)=$S(table'["""":""""_table_"""",1:$$QADD^%ZS(table,""""))
	S actual(2)=$S(par'["""":""""_par_"""",1:$$QADD^%ZS(par,""""))
	S actual(3)=1
	;
	D getRecord^UCDB
	D setOpti^UCGM(var,varLevel,0)
	Q 
	;
	; ---------------------------------------------------------------------
getRow	; method ResultSet.getRow; returns Row
	;
	I ptr D  Q  ; Nested reference
	.	;
	.	N ptr S ptr=0 ; Stop loop
	.	N varLevel S varLevel=level
	.	N var S var=$$nxtSym^UCGM
	.	;
	.	S pslTmpLvn=var ; tell caller
	.	S type(varLevel,var)="Row"_tab_(msrc+1)_tab_"NEW"_tab_(msrc+1)_tab
	.	D getRow
	.	Q 
	;
	 ; Signal from getRowProt
	;
	N del S del=$get(actual(1)) ; absent if PROTECT=1
	N list S list=$get(actual(2)) ; absent if PROTECT=1
	;
	I (del="") S del="$C(9)"
	;
	I (list=""),($D(var)#2) D  ; Default to SELECT
	.	;
	.	N newPtr
	.	N attrib N select N record
	.	;
	.	S newPtr=$$getAtt^UCGM(objectName,objectLevel,2)
	.	;   #ACCEPT DATE=4/22/03; PGM=Frank Sanchez; CR=Frank Sanchez
	.	S record=$get(struct("s",subRou,newPtr,objectName))
	.	S select=$piece(record,tab,4)
	.	S attrib=$piece(record,tab,6)
	.	;
	.	S list=$piece(select," FROM ",1)
	.	;
	.	I '(list="") D
	..		N i
	..		F i=1:1:$L(list,",") D
	...			;
	...			N att N col
	...			;
	...			S col=$piece(list,",",i)
	...			S att=$E(attrib,((i-1)*2)+1)
	...			;
	...			I "TUF"[att S att="String"
	...			E  S att=$piece("Blob,Boolean,Date,Memo,Number,Number,Time",",",$F("BLDMN$C",att)-1)
	...			;
	...			S $piece(list,",",i)=att_" "_col
	...			Q 
	..		S list=$S(list'["""":""""_list_"""",1:$$QADD^%ZS(list,""""))
	..		Q 
	.	E  D
	..		S list=$$getRowRt
	..		I $$vPSLopti(objectName) D setOpti^UCGM(objectName,objectLevel,-1)
	..		Q 
	.	Q 
	;
	I '(list=""),($D(var)#2) D
	.	;
	.	S actual(3)=del
	.	S actual(2)=list
	.	D classNew^UCROW
	.	Q 
	;
	I $$getAtt^UCGM(objectName,objectLevel,3)="LITERAL" D  Q 
	.	;
	.	I del="$C(9)" D ERROR^UCGM("<tab> delimiter is illegal") Q 
	.	;
	.	;   #ACCEPT DATE=4/22/03; PGM=Frank Sanchez; CR=Frank Sanchez
	.	S return=$get(type(objectLevel,objectName,0))
	.	;
	.	;   #ACCEPT DATE=4/22/03; PGM=Frank Sanchez; CR=Frank Sanchez
	.	XECUTE "S del="_del
	.	S return=$$vStrRep(return,$char(9),del,0,0,"")
	.	S return=$$QADD^%ZS(return,"""")
	.	Q 
	;
	S return="vobj("_objectName_")"
	I ($D(PROTECT)#2) S return="$G("_$E(return,1,$L(return)-1)_",.1))"
	;
	I '(del="$C(9)") S return="$TR("_return_",$C(9),"_del_")"
	;
	I $$vPSLopti(objectName) S return=$$patch^UCPATCH(subRou,objectName,objectLevel,return)
	;
	;if PSL.class="Row",PSL.var.exists() set PSL.class=PSL.var.class
	;
	Q 
	;
	; ---------------------------------------------------------------------
getRowRt()	; Generate subroutine to get Row.getColumns() at runtime
	; ---------------------------------------------------------------------
	;
	I '$D(labels("vRsRowGC")) D
	.	;
	.	N buf S buf=$$vopenBuf("(List vNms,String vTps)","Runtime ResultSet.getRow().getColumns()")
	.	;
	.	D vaddBuff(buf,"type Public String vobj(,)")
	.	D vaddBuff(buf,"")
	.	D vaddBuff(buf,"type Number vL="""",vN,vO,vT")
	.	D vaddBuff(buf,"for vO=1:1:vNms.count() {")
	.	D vaddBuff(buf,"  set vN=vNms.elementAt(vO)")
	.	D vaddBuff(buf,"  set vT=vTps.extract((vO-1)*2+1)")
	.	D vaddBuff(buf,"  if ""TUF""[vT S vT=""String""")
	.	D vaddBuff(buf,"  else  set vT=""Blob,Boolean,Date,Memo,Number,Number,Time"".piece("","",""BLDMN$C"".find(vT)-1)")
	.	D vaddBuff(buf,"  set vL.piece("","",v0)=vT_"" ""_vN")
	.	D vaddBuff(buf,"}")
	.	D vaddBuff(buf,"quit vL")
	.	;
	.	D INSERT^UCMETHOD(buf,"vRsRowGC","")
	.	K vobj(+$G(buf)) Q 
	Q "$$"_"vRsRowGC"_"("_oLvn_"("_objectName_",-3),"_oLvn_"("_objectName_",-4))"
	;
	; ---------------------------------------------------------------------
getCol	; method ResultSet.getCol; returns String
	;
	N newPtr
	N del
	;
	N colExpr S colExpr=actual(1)
	I (colExpr="") D ERROR^UCGM("Column parameter required")
	;
	S newPtr=$$getAtt^UCGM(objectName,objectLevel,2)
	;#ACCEPT DATE=4/22/03; PGM=Frank Sanchez; CR=Frank Sanchez
	N record S record=$get(struct("s",subRou,newPtr,objectName))
	N colList S colList=$piece($piece(record,tab,4)," FROM ")
	;
	S return="vobj("_objectName
	;
	I ($D(PROTECT)#2) S return="$E($G("_return_",.1)),"
	E  S return="$P("_return_"),$C(9),"
	;
	I (colList="")&(colExpr'?1N.N)!$$isVar^UCGM(colExpr) D  Q 
	.	;
	.	S return=return_$$getColRt_colExpr_"))"
	.	D setOpti^UCGM(objectName,objectLevel,1)
	.	Q 
	;
	I colExpr'?1N.N D  I ER Q 
	.	;
	.	S colExpr=$$vStrUC($$QSUB^%ZS(colExpr,""""))
	.	;
	.	N i S i=$L($piece((","_colList_","),","_colExpr_",",1),",")
	.	I i>0 S colExpr=i
	.	E  D ERROR^UCGM("Column expression: "_colExpr_" is not in the select list: "_colList)
	.	Q 
	;
	I '(colList=""),colExpr,colExpr>$L(colList,",") D ERROR^UCGM("Column reference ("_colExpr_") is greater than selected columns ("_$L(colList,",")_")") Q 
	;
	I $$getAtt^UCGM(objectName,objectLevel,3)="LITERAL" D  Q 
	.	;
	.	;#ACCEPT DATE=4/22/03; PGM=Frank Sanchez; CR=Frank Sanchez
	.	S return=$get(type(objectLevel,objectName,0))
	.	S return=$piece(return,tab,colExpr)
	.	S return=$$QADD^%ZS(return,"""")
	.	Q 
	;
	S return=return_colExpr_")"
	;
	I colExpr=1,'(colList=""),'(colList[",") D
	.	;
	.	I '$$vPSLopti(objectName) Q 
	.	S return="vobj("_objectName
	.	I ($D(PROTECT)#2) S return="$G("_return_",.1)"
	.	S return=$$patch^UCPATCH(subRou,objectName,objectLevel,return_")")
	.	Q 
	;
	E  I $$vPSLopti(objectName) S return=$$patch^UCPATCH(subRou,objectName,objectLevel,return)
	;
	Q 
	;
	; ---------------------------------------------------------------------
getColProt	; method ResultSet.getColProt; returns String
	;
	N PROTECT S PROTECT="" ; Used by getCol
	D getCol
	Q 
	;
	; ---------------------------------------------------------------------
getColRt()	; Return column position at runtime
	;
	I '$D(labels("vRsGetCol")) D
	.	;
	.	N buf S buf=$$vopenBuf("(Number object,Number column)","Runtime ResultSet.getCol()")
	.	;
	.	D vaddBuff(buf,"type Public String vobj(,)")
	.	D vaddBuff(buf,"")
	.	D vaddBuff(buf,"if column.isNull() quit """"")
	.	D vaddBuff(buf,"if column quit column")
	.	D vaddBuff(buf,"")
	.	D vaddBuff(buf,"type List select = {List}(vobj(object,-3).piece("" FROM ""))")
	.	D vaddBuff(buf,"type Number pos = select.position(column,"","")")
	.	D vaddBuff(buf,"quit pos")
	.	;
	.	D INSERT^UCMETHOD(buf,"vRsGetCol","")
	.	K vobj(+$G(buf)) Q 
	Q "$$"_"vRsGetCol"_"("_objectName_","
	;
	; ---------------------------------------------------------------------
getRowProt	; method ResultSet.getRowProt; returns String
	;
	N PROTECT S PROTECT="" ; Used by getRow
	D getRow
	Q 
	;
	; ---------------------------------------------------------------------
fetch	; method ResultSet.next; returns Logical
	;
	N newPtr N seq
	N record
	;
	I $$getAtt^UCGM(objectName,objectLevel,3)="LITERAL" D LitFetch Q 
	;
	S newPtr=$$getAtt^UCGM(objectName,objectLevel,2)
	;
	;#ACCEPT DATE=4/22/03; PGM=Frank Sanchez; CR=Frank Sanchez
	S record=$get(struct("s",subRou,newPtr,objectName))
	;
	S seq=$piece(record,tab,2)
	;
	I '(seq="") D  Q 
	.	;
	.	S return="$$vFetch"_seq_"("_objectName_")"
	.	I $$vPSLopti(objectName) S return=$$patch^UCPATCH(subRou,objectName,objectLevel,return)
	.	Q 
	;
	S postProc("fetch")="ppFetch^"_$T(+0)
	S struct("fetch",subRou,msrc,objectName)=""
	S return="$$vFetch("_objectName_")"
	;
	Q 
	;
	; ---------------------------------------------------------------------
LitFetch	; ResultSet.next for Literal scope
	;
	N sqlsta
	N cursor N sqldta
	;
	; [FRS] generate invalid error
	;set cursor={String}(PSL.objectName).upperCase()
	;
	S cursor=objectName
	S cursor=$$vStrUC(cursor)
	D FETCH^SQL(cursor,,.sqlsta,.sqldta) Q:ER 
	S return=sqlsta
	I return=100 S return=0
	S type(objectLevel,objectName,0)=sqldta
	Q 
	;
	; ---------------------------------------------------------------------
ppFetch	; Post processor for fetch methods
	;
	N lr
	N line
	N call N calledBy N frmlList N frmlObj N label N subRou
	;
	S subRou="" S line="" S frmlObj=""
	;
	F  S subRou=$order(struct("fetch",subRou)) Q:(subRou="")  D
	.	;
	.	S label=$piece(subRou,"(",1)
	.	;
	.	I '($D(labels(label))#2) Q  ; not enough data
	.	I $P(labels(label),$C(9),2)>0 Q  ; public or private
	.	;
	.	S lr=labels(label)
	.	S label=label_"("
	.	S call=$order(called(label))
	.	I '($E(call,1,$L(label))=label) Q  ; no calls
	.	;
	.	S calledBy=$order(called(call,""))
	.	I (calledBy="") Q  ; no calls
	.	I '($order(called(call,calledBy))="") Q  ; multiple
	.	;
	.	N f2a
	.	N actList S actList=$E(call,$F(call,"("),$L(call)-1)
	.	N ap N fp N p
	.	F p=1:1:$L(actList,",") D
	..		S ap=$piece(actList,",",p)
	..		I $piece(ap," ")'="ResultSet",$piece(ap," ")'="DbSet" Q 
	..		;
	..		I $$getFpClass^UCPSLLR(lr,p)'=$piece(ap," ") Q  ; type mismatch
	..		S ap=$piece(ap," ",2) I (ap="") Q  ; no class (ap)
	..		S f2a($$getFpVsig^UCPSLLR(lr,p))=$piece(ap," ",2)
	..		Q 
	.	;
	.	F  S line=$order(struct("fetch",subRou,line)) Q:(line="")  D
	..		F  S frmlObj=$order(struct("fetch",subRou,line,frmlObj)) Q:frmlObj=""  D
	...			I '($D(f2a(frmlObj))#2) Q  ; not mapped
	...			D fetchPatch(subRou,calledBy,line,frmlObj,f2a(frmlObj))
	...			Q 
	..		Q 
	.	Q 
	;
	I $order(struct("fetch",""))="" Q 
	;
	N list N var N z
	S (line,subRou,var)=""
	;
	F  S subRou=$order(struct("s",subRou)) Q:(subRou="")  D
	.	F  S line=$order(struct("s",subRou,line)) Q:(line="")  D
	..		F  S var=$order(struct("s",subRou,line,var)) Q:(var="")  D
	...			S z=struct("s",subRou,line,var)
	...			I $piece(z,tab,2) S list($piece(z,tab,2))=""
	...			Q 
	..		Q 
	.	Q 
	;
	N i
	;
	N sr S sr=$$vaddSubr("vFetch","(vRs)","Runtime fetch",0)
	D addCode^UCPSLSR(sr," new vPgm,vTag")
	D addCode^UCPSLSR(sr," set vPgm=$TEXT(+0),vTag=vobj(vRs,-2)")
	;
	F i=1:1 Q:'($D(labels("vOpen"_i))#2)  I '($D(list(i))#2) D
	.	;
	.	N tag S tag="vFetch"_i
	.	D addCode^UCPSLSR(sr," if vTag=(""$$"_tag_"^""_vPgm) quit $$"_tag_"(vRs)")
	.	Q 
	;
	; Label is not in current routine, xecute the call
	D addCode^UCPSLSR(sr," xecute ""set vTag=""_vTag_""(vRs)""")
	D addCode^UCPSLSR(sr," quit vTag")
	;
	Q 
	;
	; ---------------------------------------------------------------------
fetchPatch(subRou,calledBy,line,frmlObj,actObj)	;
	;
	N mcode N p1 N p2 N rec
	;
	S mcode=$get(msrc(line+1)) I (mcode="") Q  ; some kinda bug!!!
	;
	;set actObj=frmlObj    // Init to global
	;
	;set z=$order(struct("s",calledBy,"")) if z.isNull() quit
	;set actObj=$order(struct("s",calledBy,z,"")) if actObj.isNull() quit
	;
	N count S count=0
	N z S z=""
	F  S z=$order(struct("s",calledBy,z)) Q:(z="")  D
	.	I '($D(struct("s",calledBy,z,actObj))#2) Q 
	.	S count=count+1
	.	S rec=struct("s",calledBy,z,actObj)
	.	Q 
	I count'=1 Q 
	;
	K struct("fetch",subRou,line,frmlObj)
	;
	;set rec=struct("s",calledBy,z,actObj)
	;
	S p1="$$vFetch("_frmlObj_")" S p2="$$vFetch"_$piece(rec,$char(9),2)_"("_frmlObj_")"
	;
	I '(p2[p1) F  Q:'(mcode[p1)  S mcode=$piece(mcode,p1,1)_p2_$piece(mcode,p1,2,$L(mcode))
	S msrc(line+1)=mcode
	Q 
	;
	; ---------------------------------------------------------------------
bchPatch	;  Patch logic to link open and fetch code for batch defs
	;
	Q 
	;
vSIG()	;
	Q "60731^49520^Frans S.C. Witte^24639" ; Signature - LTD^TIME^USER^SIZE
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
vStrUC(vObj)	; String.upperCase
	;
	;  #OPTIMIZE FUNCTIONS OFF
	Q $translate(vObj,"abcdefghijklmnopqrstuvwxyz±³µ¶¹º»¼¾¿àáâãäåæçèéêëìíîïðñòóôõöøùúûüýþ","ABCDEFGHIJKLMNOPQRSTUVWXYZ¡£¥¦©ª«¬®¯ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖØÙÚÛÜÝÞ")
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
