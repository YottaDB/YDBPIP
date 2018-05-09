UCDBSET	;
	;
	; **** Routine compiled from DATA-QWIK Procedure UCDBSET ****
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
getRecord	; method DbSet.getRecord ; Returns RecordTABLE record
	 ; "nested property", object expression
	 ; "nested property", character pointer
	;
	N table S table=$$getAtt^UCGM(objectName,objectLevel,5)
	I '(table="") S table=$$QSUB^%ZS($$getPar^UCPATCH(table,1),"""")
	;
	S actual(1)=$$QSUB^%ZS(actual(1),"""")
	I (actual(1)="") S actual(1)=table
	E  I (table="") S table=actual(1)
	;
	I actual(1)'=table D ERROR^UCGM("Table parameter: "_actual(1)_" does not match: "_table) Q 
	;
	I (table="") D ERROR^UCGM("Table parameter is required") Q 
	;
	D setOpti^UCGM(objectName,objectLevel,0)
	;
	I $get(ptr) S return=$$propRef(table,atom,.ptr) Q 
	;
	S class=$$getAtt^UCGM(var,varLevel,1)
	I (reClass_table)'=class D ERROR^UCGM("Cannot assign: "_reClass_table_" to: "_class) Q 
	;
	N td S td=$$caPslTbl^UCXDD(.pslTbl,table,0)
	N keys S keys=$P(td,"|",3)
	N par S par=""
	;
	I '(keys="") D
	.	N lvn
	.	I $S((keys=""):0,1:$L(keys,","))=1 S lvn=oLvn_"("_objectName_")" S par=$$patch^UCPATCH(subRou,objectName,objectLevel,lvn)
	.	E  D
	..		N k
	..		F k=1:1:$S((keys=""):0,1:$L(keys,",")) S lvn="$P("_oLvn_"("_objectName_"),$C(9),"_k_")" S par=par_","_$$patch^UCPATCH(subRou,objectName,objectLevel,lvn)
	..		S par=$E(par,2,1048575)
	..		Q 
	.	Q 
	;
	S return=""
	S actual(1)=$S(table'["""":""""_table_"""",1:$$QADD^%ZS(table,""""))
	S actual(2)=$S(par'["""":""""_par_"""",1:$$QADD^%ZS(par,""""))
	S actual(3)=1
	;
	D getRecord^UCDB
	Q 
	;
	; ---------------------------------------------------------------------
propRef(table,objExpr,ptr)	;
	;
	N lvn
	N return S return=""
	;
	I '($D(type(objectLevel,objectName,"DbSet"))#2) D
	.	I forLevel>0 D ERROR^UCGM("DbSet Reference can not be on for/while line") Q 
	.	;
	.	N lnr S lnr=$$getDcLnr^UCGM()
	.	S lvn="" ; Push scope down
	.	F  S lvn=$order(type(level,lvn)) Q:lvn=""  I $$getNew^UCGM(lvn,level)'<lnr S $piece(type(level,lvn),$char(9),2)=lnr+1
	.	;
	.	S lvn=$$nxtSym^UCGM
	.	S type(objectLevel,objectName,"DbSet")=lvn
	.	;
	.	;do setScop^UCGM(lvn,level,msrc+1,"NEW")
	.	;do setType^UCGM(lvn,class,level)
	.	D setScope^UCGM(lvn,"","","NEW",reClass_table)
	.	D setInst^UCGM(lvn,lnr,"Db.getRecord("""_table_""",,1)")
	.	D occMark^UCREC4OP()
	.	;
	.	N atom S atom=""
	.	N ptr S ptr=0
	.	N var S var=lvn
	.	N varLevel S varLevel=level
	.	N mcode
	.	;
	.	D getRecord
	.	D incrLabel^UCGM(return)
	.	;
	.	S mcode=$$initLine^UCGM(level)_"N "_var_" S "_var_"="_return
	.	D ADD^UCGM(mcode)
	.	Q 
	S lvn=type(objectLevel,objectName,"DbSet")
	;
	S ptr=ptr+1 ; skip dot
	;
	N property S property=$$ATOM^%ZS(objExpr,.ptr,".",,1)
	;
	Q $$curVal^UCCOLUMN(lvn,property,0,objExpr,.ptr)
	;
vSIG()	;
	Q "60696^30170^Frans S.C. Witte^7340" ; Signature - LTD^TIME^USER^SIZE
