 ; 
 ; **** Routine compiled from DATA-QWIK Procedure UCSCHEMA ****
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
getName ; deprecated method Schema.getTableName(String)
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 D WARNDEP^UCGM(2.6,3,"Schema.getTableName() - use Record.getTable()")
 S return=$$vMExpr(actual(1)_".extract(7,"_actual(1)_".length())")
 Q 
 ;
 ; ---------------------------------------------------------------------
getTable ; deprecated method Schema.getTableRecord(String)
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 D WARNDEP^UCGM(2.6,3,"Schema.getTableRecord() - use Db.getSchemaTable()")
 D getSchTbl^UCDB
 Q 
 ;
 ; ---------------------------------------------------------------------
newTable ; deprecated method Schema.createTable()
 I $$isRdb^vRuntime D ERROR^UCGM("Schema.createTable() not supported for RDB") Q 
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 D WARNDEP^UCGM(2.6,3,"Schema.createTable() - use predefined tables")
 ;
 N table S table=$piece(actual(1),"""",2)
 ;
 N keys S keys=actual(2)
 I $E(keys,1)="""" S keys=$E(keys,2,$L(keys)-1) ; Remove "
 S keys=$$QSUB^%ZS(keys,"""")
 ;
 N columns S columns=actual(3)
 I $E(columns,1)="""" S columns=$E(columns,2,$L(columns)-1)
 ;
 N global S global=actual(4)
 I $E(global,1)="""" S global=$E(global,2,$L(global)-1)
 I global="" S global="ZBCHTMP"
 I $L(global)>8 D ERROR^UCGM("Global name cannot exceed 8 characters") Q 
 ;
 ;  #ACCEPT DATE=2006-03-14;PGM=FSCW;CR=20280;GROUP=BYPASS
 ;*** Start of code by-passed by compiler
 if $D(^DBTBL("SYSDEV",1,table)) D  I ER Q
 . N USER
 . S USER=$P(^DBTBL("SYSDEV",1,table,10),"|",11)
 . I USER=""!(USER="ZZZZZZ") Q
 . S RM="Invalid table name "_table
 . S ER=1 Q
 K ^DBTBL("SYSDEV",1,table)
 S ^DBTBL("SYSDEV",1,table,0)=global ; Global
 S ^(10)="124|PBS|0||||||||ZZZZZZ|5"
 S ^(12)="f"_table   ; File short name
 S ^(13)="",^(22)="",^(99)=""
 S ^(16)=keys    ; Access keys
 S ^(100)="^"_global_"("_keys_"|1||0" ; Global refenence, record type
 S ^(102)=keys
 ;
 S lastkey=$P(keys,",",$L(keys,","))
 F i=1:1:$L(keys,",") D   ; Access keys
 . S di=$P(keys,",",i)
 . S ^DBTBL("SYSDEV",1,table,9,di)=i_"*|20|||||||T||S|||2|0|||||124|"
 I columns'="" F i=1:1:$L(columns,",") D  ; 12/16/98 BC
 . S di=$P(columns,",",i)
 . S ^DBTBL("SYSDEV",1,table,9,di)=lastkey_"|20|||||||T||S|||2|0|||||124|"_i
 ;*** End of code by-passed by compiler ***
 Q 
 ;
 ; ---------------------------------------------------------------------
delTable ; method Schema.deleteTable()
 I $$isRdb^vRuntime D ERROR^UCGM("Schema.deleteTable() not supported for RDB") Q 
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 D WARNDEP^UCGM(2.6,3,"Schema.deleteTable() - use predefined tables")
 N table S table=$piece(actual(1),"""",2)
 I (table="") Q 
 ;
 N sts
 ;
 ;  #ACCEPT DATE=2006-03-14;PGM=FSCW;CR=20280;GROUP=BYPASS
 ;*** Start of code by-passed by compiler
 S sts=$G(^DBTBL("SYSDEV",1,table,10))
 ;
 ; Dummy file without audit information (created by createTable method)
 I $P(sts,"|",10)=""&($P(sts,"|",11)=""!($P(sts,"|",11)="ZZZZZZ"))&($P(sts,"|",12)=5) K ^DBTBL("SYSDEV",1,table) Q
 ;*** End of code by-passed by compiler ***
 D ERROR^UCGM("Invalid table name")
 Q 
 ;  #OPTION ResultClass ON
vSIG() ; 
 Q "61058^29762^Frans S.C. Witte^7238" ; Signature - LTD^TIME^USER^SIZE
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
