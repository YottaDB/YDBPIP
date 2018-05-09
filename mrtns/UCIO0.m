	; I18N=QUIT
	;
	; **** Routine compiled from DATA-QWIK Procedure UCIO0 ****
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
open	; method IO.open
	S return="open^UCIO("_objectName_",$T(+0),"""_subRou_""","""_objectName_""")"
	;
	Q 
	;
	; ---------------------------------------------------------------------
read	; method IO.read
	I (actual(1)="") D  ; use exception
	.	;
	.	S return="$$read^UCIO("_objectName_")"
	.	Q 
	E  D  ; use error variable (deprecated)
	.	D WARNDEP^UCGM("IO.read(.ETYP) - use IO.read() and catch Exception")
	.	S return="$$^%ZREAD($P(vobj("_objectName_",1),""|"",6),"_actual(1)_")"
	.	Q 
	;
	Q 
	;
	; ---------------------------------------------------------------------
write	; method IO.write
	I (actual(1)="") D ERROR^UCGM("MISMATCH: data parameter required on IO.write()") Q 
	;
	S return="write^UCIO("_objectName_","_actual(1)
	I '(actual(2)="") S return=return_","_actual(2)
	S return=return_")"
	;
	Q 
