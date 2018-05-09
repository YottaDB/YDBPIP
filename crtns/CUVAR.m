CUVAR(COL)	; Institution Variable Defaults
	;
	; **** Routine compiled from DATA-QWIK Procedure CUVAR ****
	;
	; 12/06/2007 16:14 - chenardp
	;
	N vret
	;
	N DFT N VAL
	;
	I COL="%LIBS" Q "SYSDEV" ; Library Name
	I COL="%CRCD" Q 0 ; System Base Currency Code
	I COL="CO" Q "" ; Company Mnemonic
	I COL="ISO" Q "" ; ISO Number
	;
	N cuvar S cuvar=$$vDb1()
	 S vobj(cuvar,2)=$G(^CUVAR(2))
	I COL="TJD" S vret=$P(vobj(cuvar,2),$C(124),1) K vobj(+$G(cuvar)) Q vret ; System Processing Date
	;
	S DFT=""
	;
	I (COL["|") D
	.	S COL=$piece(COL,"|",1) ; Column Name
	.	S DFT=$piece(COL,"|",2) ; Default Value
	.	Q 
	;
	S VAL=$$vCoInd1(cuvar,COL)
	;
	I (VAL="") K vobj(+$G(cuvar)) Q DFT
	;
	K vobj(+$G(cuvar)) Q VAL
	;
LIST(VLIST)	; Load a list of Institution Variables if not already defined
	;
	 S ER=0
	;
	N I N PC
	N COL
	;
	F I=1:1:$L(VLIST,",") D  Q:ER 
	.	S PC=$piece(VLIST,",",I) ; get piece
	.	S COL=$piece(PC,"|",1) ; get column name
	.	I '$D(@COL) S @COL=$$^CUVAR(COL) ; get value
	.	Q 
	Q 
	;
vSIG()	;
	Q "60087^61013^Dan Russell^1344" ; Signature - LTD^TIME^USER^SIZE
	; ----------------
	;  #OPTION ResultClass 0
vCoInd1(vOid,vCol)	; RecordCUVAR.getColumn()
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vP S vP=$$getPslCln^UCXDD("CUVAR",$$vStrUC(vCol))
	N vNod S vNod=$P(vP,"|",3)
	N vPos
	;
	N vCmp S vCmp=$P(vP,"|",14)
	I vCmp'="" D  Q @vCmp
	.	N vpt
	.	D parseCmp^UCXDD(vCmp,.vpt)
	.	N vCnt S vCnt=$order(vpt(""),-1)
	.	N vVal
	.	N vElm
	.	S vCmp=""
	.	F vElm=2:2:vCnt S vCmp=vCmp_vpt(vElm-1)_$$QADD^%ZS(($$vCoInd1(vOid,vpt(vElm))),"""")
	.	S vCmp=vCmp_vpt(vCnt)
	.	Q 
	;
	S vPos=$P(vP,"|",4)
	I '$D(vobj(vOid,vNod)) S vobj(vOid,vNod)=$get(^CUVAR(vNod))
	N vRet
	S vRet=vobj(vOid,vNod)
	S vRet=$piece(vRet,"|",vPos)
	Q vRet
	; ----------------
	;  #OPTION ResultClass 0
vStrUC(vObj)	; String.upperCase
	;
	;  #OPTIMIZE FUNCTIONS OFF
	Q $translate(vObj,"abcdefghijklmnopqrstuvwxyz±≥µ∂π∫ªºæø‡·‚„‰ÂÊÁËÈÍÎÏÌÓÔÒÚÛÙıˆ¯˘˙˚¸˝˛","ABCDEFGHIJKLMNOPQRSTUVWXYZ°£•¶©™´¨ÆØ¿¡¬√ƒ≈∆«»… ÀÃÕŒœ–—“”‘’÷ÿŸ⁄€‹›ﬁ")
	;
vDb1()	;	vobj()=Db.getRecord(CUVAR,,0)
	;
	N vOid
	S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordCUVAR"
	I '$D(^CUVAR)
	S vobj(vOid,-2)=1
	I $T K vobj(vOid) S $ZS="-1,"_$ZPOS_",%PSL-E-RECNOFL,,CUVAR" X $ZT
	Q vOid
