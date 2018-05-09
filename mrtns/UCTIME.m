	; I18N=QUIT
	;
	; **** Routine compiled from DATA-QWIK Procedure UCTIME ****
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
toString	; method Time.toString(String mask)
	;
	N mask S mask=actual(1)
	;
	I (""""""[mask) S mask=$S(commands("mask","Time")'["""":""""_commands("mask","Time")_"""",1:$$QADD^%ZS(commands("mask","Time"),""""))
	;
	S return=""
	;
	I $$isLit^UCGM(mask),$$isLit^UCGM(objectName) D
	.	;
	.	; both values are literal, resolve at compile time
	.	S return=$$QADD^%ZS($ZD(","_$$QSUB^%ZS(objectName,""""),$$QSUB^%ZS(mask,"""")),"""")
	.	Q 
	E  S return="$ZD("",""_"_objectName_","_mask_")"
	Q 
