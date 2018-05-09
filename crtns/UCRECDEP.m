UCRECDEP	;
	;
	; **** Routine compiled from DATA-QWIK Procedure UCRECDEP ****
	;
	; 11/08/2007 14:08 - chenardp
	;
	;
	; *******************************************************************
	; * IMPORTANT NOTE:                                                 *
	; * According to the rules that apply to PSL compiler upgrades,     *
	; * the generated M routine associated with this procedure must be  *
	; * checked into StarTeam and released with the procedure whenever  *
	; * changes are made to this procedure.  The M routine from the     *
	; * crtns directory should be used for this purpose.                *
	; *                                                                 *
	; * The M routine will be loaded to the mrtns directory during      *
	; * upgrades and will then be removed from that directory as part   *
	; * of the upgrade process.  Therefore, other during an upgrade,    *
	; * an mrtns version of this routine should not exist.              *
	; *                                                                 *
	; * Keep these comments as single line to ensure they exist in the  *
	; * generated M code.                                               *
	; *******************************************************************
	;
	Q  ; No entry from top
	;
	; ---------------------------------------------------------------------
default	;
	;
	N oldcols
	;
	D
	.	N $ZT S $ZT="D ZX^UCGMR("_+$O(vobj(""),-1)_","_$ZL_",""vtrap1^"_$T(+0)_""")"
	.	; Routine may not exist yet
	.	;   #ACCEPT Date=10/04/06; Pgm=RussellDS; CR=22719; Group=MISMATCH
	.	S oldcols=$$colsused^UCRECD0
	.	Q 
	;
	D default^UCRECACN("DEP","UCRECD0","PRODDFTD",oldcols)
	;
	Q 
	;
	; ---------------------------------------------------------------------
renew	;
	;
	D upd^UCRECACN("DEP","ROLLOVR",actual(1))
	;
	Q 
	;
vSIG()	;
	Q "60547^69595^Dan Russell^2902" ; Signature - LTD^TIME^USER^SIZE
	;
vtrap1	;	Error trap
	;
	N error S error=$ZS
	;
	S oldcols=""
	Q 
