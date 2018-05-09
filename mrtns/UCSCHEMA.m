	; I18N=QUIT
	;
	; **** Routine compiled from DATA-QWIK Procedure UCSCHEMA ****
	;
	; 09/10/2007 17:31 - chenardp
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
getName	; deprecated method Schema.getTableName(String)
	;
	D WARNDEP^UCGM("Schema.getTableName()")
	S return=$$vMExpr(actual(1)_".extract("_$$QADD^%ZS(reClass,"""")_".length()+1,"_actual(1)_".length())")
	Q 
	;
	; ---------------------------------------------------------------------
getSchCln	;void; method Db.getSchemaColumn(String,String)
	S return="$$getSchCln^UCXDD("_actual(1)_","_actual(2)_")"
	Q 
	;
	; ---------------------------------------------------------------------
getSchTbl	;void; method Db.getSchemaTable(String)
	S return="$$getSchTbl^UCXDD("_actual(1)_")"
	Q 
	;
	; ---------------------------------------------------------------------
getTable	; deprecated method Schema.getTableRecord(String)
	;
	D WARNDEP^UCGM("Schema.getTableRecord() - use Db.getSchemaTable()")
	D getSchTbl
	Q 
	;
	; ---------------------------------------------------------------------
isSchCln	;void; method Db.isSchemaColumn(String,String)
	S return="$$isColumn^UCXDD("_actual(1)_","_actual(2)_")"
	Q 
	;
	; ---------------------------------------------------------------------
isSchTbl	;void; method Db.isSchemaTable(String)
	S return="$$isTable^UCXDD("_actual(1)_")"
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vMExpr(v1)	; PSL.mExpr
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vExp N mcode N tok
	N vFun S vFun=$get(commands("OPTIMIZE","FUNCTIONS"),0)
	S commands("OPTIMIZE","FUNCTIONS")=0
	S mcode="" S v1=$$TOKEN^%ZS(v1,.tok) S vExp=$$valExpr^UCGM(v1,,0)
	S commands("OPTIMIZE","FUNCTIONS")=vFun
	Q vExp
