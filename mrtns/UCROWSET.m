	; I18N=QUIT
	;
	; **** Routine compiled from DATA-QWIK Procedure UCROWSET ****
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
classNew	; Class constructor for new RowSet object
	;
	I '$D(labels("vRwsNew")) D
	.	N sr S sr=$$vaddSubr("vRwsNew","(vCol,vDel)","new RowSet",0)
	.	D addCode^UCPSLSR(sr," N vOid S vOid="_$$newObj^UCCLASS("RowSet"))
	.	D addCode^UCPSLSR(sr," S "_oLvn_"(vOid,0)=0")
	.	D addCode^UCPSLSR(sr," S "_oLvn_"(vOid,-2)=vCol")
	.	D addCode^UCPSLSR(sr," S "_oLvn_"(vOid,-3)=vDel")
	.	D addCode^UCPSLSR(sr," Q vOid")
	.	Q 
	;
	N del S del="$C(9)"
	I (actual(2)="") S actual(2)=""""""
	N list S list=$$buildList^UCROW(actual(2),.del)
	;
	S return="$$"_"vRwsNew"_"("_list_","_del_")"
	;
	Q 
	;
	; ---------------------------------------------------------------------
befFir	; RowSet.beforeFirst()
	S mcode=$E(mcode,1,$L(mcode)-$L(postCond)-2)
	S mcode=mcode_"S"_postCond_" "_oLvn_"("_objectName_",0)=0"
	S return=" "
	Q 
	;
	; ---------------------------------------------------------------------
getRow	; method ResultSet.getRow; returns Row
	;
	I ptr D  Q  ; Nested reference
	.	;
	.	N ptr S ptr=0 ; Stop loop
	.	N varLevel S varLevel=level
	.	N var S var=$$nxtSym^UCGM
	.	;
	.	S varPtr=varPtr-1 ; Reset the var counter
	.	S type(varLevel,var)="Row"_tab_(msrc+1)_tab_"NEW"_tab_(msrc+1)_tab
	.	D getRow
	.	Q 
	;
	I ($D(var)#2) D
	.	;
	.	S actual(3)=oLvn_"("_objectName_",-3)"
	.	S actual(2)=oLvn_"("_objectName_",-2)"
	.	D classNew^UCROW
	.	Q 
	;
	N cursor S cursor=oLvn_"("_objectName_",0)"
	S return="$S("_cursor_">0:$G("_oLvn_"("_objectName_","_cursor_")),1:"""")"
	;
	Q 
	;
	; ---------------------------------------------------------------------
isEmpty	; RowSet.isEmpty()
	S return="($O("_oLvn_"("_objectName_",""""),-1)=0)"
	Q 
	;
	; ---------------------------------------------------------------------
ldFrFile	; RowSet.loadFromFile()
	I (actual(1)="") S actual(1)=""""""
	I (actual(2)="") D ERROR^UCGM("RowSet.loadFromFile: Filename required")
	I (""""""[actual(3)) S actual(3)=1
	;
	D resetProps^UCGM(objectName)
	;
	S return="vRwsLFF"
	;
	I '$D(labels(return)) D
	.	;
	.	N buf S buf=$$vopenBuf("(String vOid, String vDir, String vFil, Number vTyp)","RowSet.loadFromFile")
	.	;
	.	D vaddBuff(buf,"type IO vIO = Class.new(""IO"")")
	.	D vaddBuff(buf,"set vIO.directory = vDir")
	.	D vaddBuff(buf,"set vIO.fileName = vFil")
	.	D vaddBuff(buf,"set vIO.openParams = ""READ""")
	.	D vaddBuff(buf,"set vIO.recordSize = 32767")
	.	D vaddBuff(buf,"do vIO.open()")
	.	;
	.	D vaddBuff(buf,"type Number vEr")
	.	D vaddBuff(buf,"type Number vPtr = 1")
	.	;do buf.add("if vTyp=0 do {")
	.	;do buf.add("  for vPtr=1:1 set "_ PSL.oLvn_"(vOid,vPtr) = vIO.read(.vEr)) if vEr quit")
	.	;do buf.add("}")
	.	D vaddBuff(buf,"if vTyp=1 do {")
	.	D vaddBuff(buf,"  set "_oLvn_"(vOid,-3) = 9.char()")
	.	D vaddBuff(buf,"  set "_oLvn_"(vOid,-2) = vIO.read(.vEr).translate(9.char()_10.char()_13.char(),"","")")
	.	D vaddBuff(buf,"  for vPtr=1:1 set "_oLvn_"(vOid,vPtr) = vIO.read(.vEr).translate(10.char()_13.char()) if vEr quit")
	.	D vaddBuff(buf,"}")
	.	D vaddBuff(buf,"kill "_oLvn_"(vOid,vPtr) set "_oLvn_"(vOid,0) = 0")
	.	D vaddBuff(buf,"for  set vPtr="_oLvn_"(vOid,vPtr).order() quit:vPtr=""""  kill "_oLvn_"(vOid,vPtr)")
	.	D vaddBuff(buf,"do vIO.close()")
	.	D vaddBuff(buf,"quit")
	.	;
	.	D INSERT^UCMETHOD(buf,return,"")
	.	K vobj(+$G(buf)) Q 
	;
	S return=return_"("_objectName_","_actual(1)_","_actual(2)_","_actual(3)_")"
	;
	Q 
	;
	; ---------------------------------------------------------------------
next	; RowSet.next()
	S return="vRwsNxt"
	;
	I '$D(labels(return)) D
	.	N sr S sr=$$vaddSubr(return,"(vOid)","RowSet.next",0)
	.	D addCode^UCPSLSR(sr," N vLst S vLst=$O("_oLvn_"(vOid,""""),-1)")
	.	D addCode^UCPSLSR(sr," I "_oLvn_"(vOid,0)'>vLst S "_oLvn_"(vOid,0)="_oLvn_"(vOid,0)+1")
	.	D addCode^UCPSLSR(sr," Q "_oLvn_"(vOid,0)'>vLst")
	.	Q 
	S return="$$"_return_"("_objectName_")"
	Q 
	;
	; ---------------------------------------------------------------------
colSub(context,table,column)	;
	Q $get(context("Inst"),"vR")_"."_$$vStrLC(column,0)
	; ----------------
	;  #OPTION ResultClass 0
vaddSubr(p1,p2,p3,p4)	; PSL.addSubrou
	;
	;  #OPTIMIZE FUNCTIONS OFF
	I $get(p4) S p1=$$newLabel^UCGM(p1,.labels)
	E  I ($D(labels(p1))#2) D ERROR^UCGM("Subroutine exists: "_p1) Q p1
	D addSubr^UCGM(p1,p2,p3)
	Q p1
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
	; ----------------
	;  #OPTION ResultClass 0
vStrLC(vObj,v1)	; String.lowerCase
	;
	;  #OPTIMIZE FUNCTIONS OFF
	S vObj=$translate(vObj,"ABCDEFGHIJKLMNOPQRSTUVWXYZ¡£¥¦©ª«¬®¯ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏĞÑÒÓÔÕÖØÙÚÛÜİŞ","abcdefghijklmnopqrstuvwxyz±³µ¶¹º»¼¾¿àáâãäåæçèéêëìíîïğñòóôõöøùúûüış")
	I v1 S vObj=$$vStrUC($E(vObj,1))_$E(vObj,2,1048575)
	Q vObj
	; ----------------
	;  #OPTION ResultClass 0
vStrUC(vObj)	; String.upperCase
	;
	;  #OPTIMIZE FUNCTIONS OFF
	Q $translate(vObj,"abcdefghijklmnopqrstuvwxyz±³µ¶¹º»¼¾¿àáâãäåæçèéêëìíîïğñòóôõöøùúûüış","ABCDEFGHIJKLMNOPQRSTUVWXYZ¡£¥¦©ª«¬®¯ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏĞÑÒÓÔÕÖØÙÚÛÜİŞ")
