	;
	;
	; **** Routine compiled from DATA-QWIK Procedure UCREF ****
	;
	; 09/10/2007 17:31 - chenardp
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
copy	; method Reference.copy; Returns Reference
	;
	N class S class=$$getClass^UCGM(objectName,objectLevel)
	;
	I $$primVar^UCPRIM(class) S return=objectName
	E  S return="$$copy^UCGMR("_objectName_")"
	Q 
	;
equals	;method Reference.equals; Returns boolean
	;
	N class1 N class2
	;
	S class1=$$getClass^UCGM(objectName)
	S class2=$$getClass^UCGM(actual(1))
	;
	I class1'=class2 D ERROR^UCGM("Objects must the same type") Q 
	;
	I $$primVar^UCPRIM(class1) S return="("_objectName_"="_actual(1)_")"
	E  S return="$$equals^UCGMR("_objectName_","_actual(1)_")"
	Q 
	;
getPointer	; method Reference.getPointer; returns Number (integer)
	;
	D WARNDEP^UCGM("Reference.getPointer() - consider using Object.exists()")
	S return="$G("_objectName_")"
	I $$getOpti^UCGM(objectName,objectLevel)>msrc D setOpti^UCGM(objectName,objectLevel,0)
	Q 
	;
getValue	; method Reference.getStoredValue(String tag)
	;
	N class S class=$$getClass^UCGM(objectName,objectLevel)
	;
	I $$primVar^UCPRIM(class) D ERROR^UCGM("Method is invalid for class with primitive implementation") Q 
	I (""""""[actual(1)) D ERROR^UCGM("Tag parameter is required")
	;
	S return="$G("_oLvn_"("_objectName_",-999,"_actual(1)_"))"
	;
	Q 
	;
setValue	; method Reference.setStoredValue(String tag,Object value)
	;
	N class S class=$$getClass^UCGM(objectName,objectLevel)
	;
	; if class.isPrimitive() do PSL.error("Method is invalid for Primitive objects") quit
	;
	I $$primVar^UCPRIM(class) D ERROR^UCGM("Method is invalid for class with primitive implementation") Q 
	I (""""""[actual(1)) D ERROR^UCGM("Tag parameter is required")
	;
	N label S label="vObjStor"
	;
	I '$D(labels("vObjStor")) D
	.	;
	.	N buf S buf=$$vopenBuf("(String object,String p1,String p2)","Object.storeValue")
	.	D vaddBuff(buf,"type Public String "_oLvn)
	.	D vaddBuff(buf,"if object.get().isNull() quit")
	.	D vaddBuff(buf,"set "_oLvn_"(object,-999,p1)=p2.get()")
	.	D vaddBuff(buf,"quit")
	.	D INSERT^UCMETHOD(buf,"vObjStor","")
	.	K vobj(+$G(buf)) Q 
	;
	S return=label_"("_objectName_","_actual(1)_","_actual(2)_")"
	Q 
	;
toString	; method Reference.toString; Returns String
	;
	N class S class=$$getClass^UCGM(objectName,objectLevel)
	;
	I $$primVar^UCPRIM(class) S return=objectName
	E  S return="$$toString^UCGMR("_objectName_")"
	Q 
	;
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
