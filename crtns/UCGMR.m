UCGMR	;
	;
	; **** Routine compiled from DATA-QWIK Procedure UCGMR ****
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
clsByName(expr)	; Return correct class name of class expr
	Q $$ocClassName^UCXOBJ(expr)
	;
	; ---------------------------------------------------------------------
clsIsClass(c)	; runtime wrapper for Class.isValid
	I c="" Q ""
	Q $$clsByName(c)'=""
	;
	; ---------------------------------------------------------------------
clsIsAnc(a,d)	; runtime wrapper for Class.isAncestor / Class.isDecendant
	I a="" Q ""
	I d="" Q ""
	I $$clsByName(a)="" Q 0
	I $$clsByName(d)="" Q 0
	Q $$ocIsAncestor^UCXOBJ(a,d)
	;
	; ---------------------------------------------------------------------
isClass(expr)	; deprecated ; Return if expr is a class
	Q $$clsByName(expr)'=""
	;
	; ---------------------------------------------------------------------
LOWER(S)	; Return S.lowerCase()
	Q $$vStrLC(S,0)
	;
	; ---------------------------------------------------------------------
UPPER(S)	; Return S.upperCase()
	Q $$vStrUC(S)
	;
	; ---------------------------------------------------------------------
copy(v1)	; MTL runtime for Object.copy()
	N vOid
	;
	;  #ACCEPT CR=22720; Date=2006-08-18; PGM=Frans S.C. Witte; Group=BYPASS
	;*** Start of code by-passed by compiler
	set vOid=$O(vobj(""),-1)+1
	merge vobj(vOid)=vobj(v1)
	;*** End of code by-passed by compiler ***
	;
	Q vOid
	;
	; ---------------------------------------------------------------------
equals(p1,p2)	; MTL runtime for Object.equals()
	N equals
	N z1 N z1e N z2 N z2e
	S z1="vobj("_p1 S z1e=z1 S z1=z1_")"
	S z2="vobj("_p2 S z2e=z2 S z2=z2_")"
	;
	S equals=1
	I $get(@z1)'=$get(@z2) Q 0 ; compare top nodes
	F  S z1=$query(@z1) S z2=$query(@z2) Q:$E(z1,1,$L(z1e))'=z1e  D  I equals=0 Q 
	.	;
	.	I $E(z1,$L(z1e)+1,1048575)'=$E(z2,$L(z2e)+1,1048575) S equals=0
	.	E  I @z1'=@z2 S equals=0
	.	Q 
	Q equals
	;
	; ---------------------------------------------------------------------
toString(p1)	; MTL runtime for Object.toString()
	N return N zo N ze
	S zo="vobj("_p1 S ze=zo S zo=zo_")"
	;
	I ($D(@zo)#2) S return=@zo_$char(9)
	E  S return=""
	;
	F  S zo=$query(@zo) Q:'($E(zo,1,$L(ze))=ze)  S return=return_$E(zo,$L(ze)+2,1048575)_"="""_@zo_""""_$char(9)
	;
	Q $E(return,1,$L(return)-1)
	;
	; ---------------------------------------------------------------------
ZT(voexe,vorefs,voptr)	; MTL Object cleanup error trap
	;  #ACCEPT CR=22720; Date=2006-08-18; PGM=Frans S.C. Witte; Group=BYPASS
	;*** Start of code by-passed by compiler
	for  set voptr=voptr+1 quit:'$data(vobj(voptr))  kill vobj(voptr)
	if vorefs'="" for voptr=1:1:$length(vorefs,",")  kill vobj($get(@$piece(vorefs,",",voptr)))
	xecute $get(voexe)
	;*** End of code by-passed by compiler ***
	;
	Q 
	;
	; ---------------------------------------------------------------------
ZX(voPtr,voGoto,voTag)	; MTL General error handler
	;  #ACCEPT CR=22720; Date=2006-08-18; PGM=Frans S.C. Witte; Group=BYPASS
	;*** Start of code by-passed by compiler
	do @voTag
	if $data(vobj) for  set voPtr=$order(vobj(voPtr)) quit:voPtr=""  kill vobj(voPtr)
	if $get(%ZTPTRAP)'="",$piece($zstatus,",",3)["%GTM-E-TPTIMEOUT" xecute "set %ZTPTRAP="""" "_%ZTPTRAP
	zgoto voGoto-1
	;*** End of code by-passed by compiler ***
	;
	Q  ; will never be reached, but the compiler wants to see it
	;
vSIG()	;
	Q "60747^20115^Frans S.C. Witte^11471" ; Signature - LTD^TIME^USER^SIZE
	; ----------------
	;  #OPTION ResultClass 0
vStrLC(vObj,v1)	; String.lowerCase
	;
	;  #OPTIMIZE FUNCTIONS OFF
	S vObj=$translate(vObj,"ABCDEFGHIJKLMNOPQRSTUVWXYZ°£•¶©™´¨ÆØ¿¡¬√ƒ≈∆«»… ÀÃÕŒœ–—“”‘’÷ÿŸ⁄€‹›ﬁ","abcdefghijklmnopqrstuvwxyz±≥µ∂π∫ªºæø‡·‚„‰ÂÊÁËÈÍÎÏÌÓÔÒÚÛÙıˆ¯˘˙˚¸˝˛")
	I v1 S vObj=$$vStrUC($E(vObj,1))_$E(vObj,2,1048575)
	Q vObj
	; ----------------
	;  #OPTION ResultClass 0
vStrUC(vObj)	; String.upperCase
	;
	;  #OPTIMIZE FUNCTIONS OFF
	Q $translate(vObj,"abcdefghijklmnopqrstuvwxyz±≥µ∂π∫ªºæø‡·‚„‰ÂÊÁËÈÍÎÏÌÓÔÒÚÛÙıˆ¯˘˙˚¸˝˛","ABCDEFGHIJKLMNOPQRSTUVWXYZ°£•¶©™´¨ÆØ¿¡¬√ƒ≈∆«»… ÀÃÕŒœ–—“”‘’÷ÿŸ⁄€‹›ﬁ")
