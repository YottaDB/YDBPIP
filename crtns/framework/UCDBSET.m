 ; 
 ; **** Routine compiled from DATA-QWIK Procedure UCDBSET ****
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
getRecord ; method DbSet.getRecord ; Returns RecordTABLE record
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
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 D setOpti^UCGM(objectName,objectLevel,0)
 ;
 I $get(ptr) S return=$$propRef(table,atom,.ptr) Q 
 ;
 S class=$$getAtt^UCGM(var,varLevel,1)
 I ("Record"_table)'=class D ERROR^UCGM("Cannot assign: "_"Record"_table_" to: "_class) Q 
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
 D getRec^UCDB(1)
 Q 
 ;
 ; ---------------------------------------------------------------------
propRef(table,objExpr,ptr) ; 
 ;  #ACCEPT CR=27800;Date=2007-10-09;PGM=Frans S.C. Witte;Group=DEPRECATED; use of type()
 ;
 N lvn
 N return S return=""
 ;
 I '($D(type(objectLevel,objectName,"DbSet"))#2) D
 .	I $$topFor^UCPSLST(pslSt)>0 D ERROR^UCGM("DbSet Reference can not be on for/while line") Q 
 .	;
 .	;   #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 .	N lnr S lnr=$$getDcLnr^UCGM()
 .	S lvn="" ; Push scope down
 .	;
 .	;   #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 .	F  S lvn=$order(type(level,lvn)) Q:lvn=""  I $$getNew^UCGM(lvn,level)'<lnr S $piece(type(level,lvn),$char(9),2)=lnr+1
 .	;
 .	;   #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 .	S lvn=$$nxtSym^UCGM
 .	S type(objectLevel,objectName,"DbSet")=lvn
 .	;
 .	;do setScop^UCGM(lvn,level,msrc+1,"NEW")
 .	;do setType^UCGM(lvn,class,level)
 .	;   #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 .	D setScope^UCGM(lvn,"","","NEW","Record"_table)
 .	;   #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
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
 .	;
 .	;   #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 .	D incrLabel^UCGM(return)
 .	;   #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 .	S mcode=$$initLine^UCGM(level)_"N "_var_" S "_var_"="_return
 .	;   #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 .	D ADD^UCGM(mcode)
 .	Q 
 S lvn=type(objectLevel,objectName,"DbSet")
 ;
 S ptr=ptr+1 ; skip dot
 ;
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 N property S property=$$ATOM^%ZS(objExpr,.ptr,".",,1)
 ;
 Q $$curVal^UCCOLUMN(lvn,table,property,0,objExpr,.ptr)
 ;  #OPTION ResultClass ON
vSIG() ; 
 Q "61186^61461^Dan Russell^8689" ; Signature - LTD^TIME^USER^SIZE
