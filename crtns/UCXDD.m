UCXDD	;
	;
	; **** Routine compiled from DATA-QWIK Procedure UCXDD ****
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
addRdbPos(rdbPos,clnDes)	;
	;
	I $$nodIsKey($P(clnDes,"|",3)) S rdbPos($$getCurNode^UCXDD(clnDes,0))=clnDes Q 
	I $P(clnDes,"|",15)<2 S rdbPos($P(clnDes,"|",4))=clnDes Q 
	;
	N dbtbl1d S dbtbl1d=$G(^DBTBL("SYSDEV",1,$P(clnDes,"|",1),9,$P(clnDes,"|",2)))
	N N S N=$P(dbtbl1d,$C(124),1)
	N P S P=$P(dbtbl1d,$C(124),21)
	N rs,vos1,vos2,vos3,vos4,vos5,vos6  N V1,V2 S V1=$P(clnDes,"|",1),V2=$P(clnDes,"|",2) S rs=$$vOpen1()
	F  Q:'($$vFetch1())  D
	.	S clnDes=$$getPslCln($P(clnDes,"|",1),rs)
	.	S rdbPos($P(clnDes,"|",4))=clnDes
	.	Q 
	Q 
	;
	; ---------------------------------------------------------------------
caPslCln(cache,PROP,tdc)	;
	I '($D(cache(PROP))#2) S cache(PROP)=$$getPslCln($piece(PROP,"."),$piece(PROP,".",2),.tdc)
	Q cache(PROP)
	;
	; ---------------------------------------------------------------------
caPslTbl(cache,TBL,LVL)	;
	I '($D(cache(TBL))#2) S cache(TBL)=$$getPslTbl(TBL,$get(LVL))
	Q cache(TBL)
	;
	; ---------------------------------------------------------------------
cdNodChg(recInst,node)	;
	N vret
	;
	S vret="vobj"_"("_recInst_",-100,"_node_")" Q vret
	;
	; ---------------------------------------------------------------------
cdOldLvn(recInst,node,column)	;
	N vret
	;
	S vret="vobj"_"("_recInst_",-100,"_node_","_column_")" Q vret
	;
	; ---------------------------------------------------------------------
cdRdbAsn(recInst,intTbl,intCln,nod,pos,mod)	;
	;
	N cdRdbAsn S cdRdbAsn="vobj"_"("_recInst_",-150,"_nod_","_intCln_")="
	;
	I $$isLit^UCGM(pos) S cdRdbAsn=cdRdbAsn_""""_pos_"|"
	E  S cdRdbAsn=cdRdbAsn_pos_"_""|"
	;
	I $$isLit^UCGM(mod) S cdRdbAsn=cdRdbAsn_mod_"|"
	E  S cdRdbAsn=cdRdbAsn_"""_"_mod_"_""|"
	;
	I $$isLit^UCGM(intTbl) S cdRdbAsn=cdRdbAsn_$$QSUB^%ZS(intTbl,"""")_""""
	E  S cdRdbAsn=cdRdbAsn_"""_"_intTbl
	;
	Q cdRdbAsn
	;
	; ---------------------------------------------------------------------
getClass(clnDes)	; PSLColumn
	N typ S typ=$P(clnDes,"|",6)
	;
	I "TUF"[typ Q "String"
	Q $piece(",Blob,Boolean,Date,Memo,Number,Number,Time",",",$F("BLDMN$C",typ))
	;
	; ---------------------------------------------------------------------
getCmp(clnDes,recInst)	;
	N pt
	;
	; if recInst.isNumber() ...
	;
	D parseCmp($P(clnDes,"|",14),.pt)
	;
	N acc ; dummy to receive $$accByDec
	N cnt S cnt=$order(pt(""),-1) ; number of elements
	N ccd ; descriptor for indiv. elems.
	N elm ; element iterator
	N getval S getval="" ; return value
	N qcn ; qualified columnname, and table
	;
	F elm=2:2:$order(pt(""),-1) D
	.	S qcn=pt(elm)
	.	I qcn["." D
	..		I $piece(qcn,".")'=$P(clnDes,"|",1) S $ZS="-1,"_$ZPOS_","_"%PSL-E-COMPUTE,,invalid qualified name '"_qcn_"' in "_$P(clnDes,"|",1)_"."_$P(clnDes,"|",2) X $ZT
	..		S qcn=$piece(qcn,".",2)
	..		Q 
	.	S ccd=$$getPslCln($P(clnDes,"|",1),qcn)
	.	I (recInst=+recInst) D clnByCln^UCREC4OP(recInst,clnDes,ccd)
	.	S getval=getval_pt(elm-1)_$$getCurExpr(ccd,recInst,0)
	.	Q 
	;
	Q getval_pt(cnt)
	;
	; ---------------------------------------------------------------------
getCurExpr(clnDes,recInst,bLeft)	;
	;
	; RDB masterfield assignment and retrieval:
	I $P(clnDes,"|",15)=2,bLeft S $ZS="-1,"_$ZPOS_","_"%PSL-E-COMPUTE,,Masterfield has no leftexpr "_$P(clnDes,"|",1)_"."_$P(clnDes,"|",2) X $ZT
	I $P(clnDes,"|",15)=2 Q $$getMfRDB^UCCOLSF(clnDes,recInst)
	;
	; computed column: return computation
	I '($P(clnDes,"|",14)=""),bLeft S $ZS="-1,"_$ZPOS_","_"%PSL-E-COMPUTE,,Cannot modify computed data item "_$P(clnDes,"|",1)_"."_$P(clnDes,"|",2) X $ZT
	I '($P(clnDes,"|",14)="") Q $$getCmp(clnDes,recInst)
	;
	N getval S getval=$$getCurLvn(clnDes,recInst)
	;
	; key columns and Blob/Memo are complete
	I $P(clnDes,"|",3)?1.N1"*" Q getval
	I "BM"[$P(clnDes,"|",6) Q getval
	;
	I $P(clnDes,"|",4)>0 S getval="$P("_getval_",$C("_$P(clnDes,"|",5)_"),"_$P(clnDes,"|",4)_")"
	;
	I ($P(clnDes,"|",13)="")!bLeft Q getval
	;
	; rightexpr for subfield (on MDB)
	Q $$getSfMDB^UCCOLSF(getval,$P(clnDes,"|",10),$P(clnDes,"|",11),$P(clnDes,"|",12),$P(clnDes,"|",13))
	;
	; ---------------------------------------------------------------------
getCurLvn(clnDes,recInst)	;
	N vret
	;
	N nod S nod=$$getCurNode(clnDes,1)
	;
	I (recInst=+recInst) Q $$lvpm^UCREC4OP(recInst,$$getPurNode(clnDes),1)
	;
	I (nod="") S vret="vobj"_"("_recInst_")" Q vret
	;
	S vret="vobj"_"("_recInst_","_nod_")" Q vret
	;
	; ---------------------------------------------------------------------
getCurNode(clnDes,bQuoted)	;
	N nod S nod=$P(clnDes,"|",3)
	;
	I nod?1.N1"*" Q -2-$P(clnDes,"|",4)
	;
	N td S td=$$getPslTbl($P(clnDes,"|",1),0)
	I $P(td,"|",4)=1 D
	.	I "BM"'[$P(clnDes,"|",6) S nod=""
	.	Q 
	E  D
	.	I $P(td,"|",4)=11 D  ; Compare node to bottom key
	..		N keys S keys=$P(td,"|",3)
	..		I $piece(keys,",",$L(keys,","))=nod S nod=""
	..		Q 
	.	I nod<0 S nod="v"_(-nod)
	.	I '$$isLit^UCGM(nod),'(nod=""),bQuoted S nod=""""_nod_""""
	.	Q 
	;
	I "BM"[$P(clnDes,"|",6) S nod=nod_",1"
	;
	Q nod
	;
	; ---------------------------------------------------------------------
getDataNode(tblDes,recInst,node,bNotFound,lvpm,clnDes)	;
	;
	N dbref S dbref="" ; database reference code (DB dep)
	;
	I node="0*" S node=""
	;
	I ($P(tblDes,"|",8)'="GTM") D  ; RDB code
	.	;
	.	;type String ER,RM // ER and RM returned by $$RUNSP
	.	N hostexpr ; for call to $$EXECSP^%DBAPI
	.	N hostcrsp ; for call to $$RUNSP^DBSDBASE
	.	N intt S intt=$$nod2tbl^DBMAP(%DB,$P(tblDes,"|",1),node)
	.	N ord ; columnnames by ordinal position
	.	N pkeys S pkeys=$P(tblDes,"|",3)
	.	N sel S sel="*" ; select list (assume SELECT *)
	.	N k S k=$SELECT(pkeys="":0,1:$S((pkeys=""):0,1:$L(pkeys,",")))
	.	;
	.	I (node="") D
	..		S tblDes=$$tAssert(tblDes,1,.clnDes)
	..		I intt?1"W_"1.A1"_" S intt="ACN" ; temp fix
	..		;
	..		I ($P(tblDes,"|",5)["B")'!($P(tblDes,"|",5)["M") Q 
	..		;
	..		N tbl S tbl=$P(tblDes,"|",1)
	..		N pos
	..		N cd
	..		N rs,vos1,vos2,vos3  N V1 S V1=tbl S rs=$$vOpen2()
	..		F  Q:'($$vFetch2())  D
	...			S cd=$$caPslCln(.clnDes,tbl_"."_rs)
	...			S pos=$P(cd,"|",4)
	...			I (pos="") Q  ; computed, literal, masterfield, ...
	...			I $P(cd,"|",6)="B" Q 
	...			I $P(cd,"|",6)="M" Q 
	...			S ord(pos)=$P(cd,"|",17)
	...			Q 
	..		S sel=ord(1) ; no table starts with B/M
	..		F pos=2:1:$order(ord(""),-1) S sel=sel_","_$get(ord(pos),"NULL")
	..		Q 
	.	;
	.	I sel'="*" D  ; RDB with blob or memo
	..		N where S where=$$getWhrKey(tblDes,recInst,2,.lvpm,.hostexpr)
	..		N sqlstm S sqlstm="SELECT "_sel_" FROM "_intt_" WHERE "_where
	..		;
	..		S dbref="(0,"""_sqlstm_""",$C("_$P(tblDes,"|",10)_"),"_hostexpr
	..		I bNotFound S dbref=" S vEr=$$SELECT^%DBAPI"_dbref_",.vData,.vRm),"_$$lvpm(recInst,node,.lvpm)_"=vData I vEr<0 S $ZS=""-1,""_$ZPOS_"",%PSL-E-SQLFAIL,""_$TR($G(vRm),$C(10,44),$C(32,126)) X $ZT"
	..		E  S dbref="$$wrSELECT^UCDBRT"_dbref_")"
	..		Q 
	.	E  D  ; RDB without blob or memo
	..		;
	..		N crsp
	..		N sqlstm S sqlstm="SELECT * FROM "_intt
	..		N where S where=$$getWhrKey(tblDes,recInst,1,.lvpm,.hostexpr,.hostcrsp)
	..		S crsp("WHERE")=where
	..		S crsp("SQL")=sqlstm_$S(where="":"",1:" WHERE "_where)
	..		S crsp("HOSTVARS")=hostcrsp
	..		;
	..		D
	...			N $ZT S $ZT="D ZX^UCGMR("_+$O(vobj(""),-1)_","_$ZL_",""vtrap1^"_$T(+0)_""")"  ; $$CREATESP failed, code as $$wrSELECT
	...			;
	...			N spnam S spnam=$$CREATESP^DBSDBASE(intt,"SelectAll",.crsp,0)
	...			I (hostexpr="") S hostexpr=""""""
	...			;
	...			S dbref="(0,"""_spnam_""","_hostexpr_","_k_",$C("_$P(tblDes,"|",10)_")"
	...			;
	...			I bNotFound S dbref=" S vEr=$$EXECSP^%DBAPI"_dbref_",.vData,.vRm),"_$$lvpm(recInst,node,.lvpm)_"=vData I vEr<0 S $ZS=""-1,""_$ZPOS_"",%PSL-E-SQLFAIL,""_$TR($G(vRm),$C(10,44),$C(32,126)) X $ZT"
	...			E  S dbref="$$wrEXECSP^UCDBRT"_dbref_")"
	...			Q  ; end code protected by catch
	..		Q  ; end RDB without blob or memo
	.	Q  ; end RDB
	E  D  ; MDB code
	.	N gref S gref=$$getGbl(tblDes,recInst,.lvpm)
	.	;
	.	I (node="") S dbref=$E(gref,1,$L(gref)-1)_")"
	.	E  I $E(node,1,2)="""v" S dbref=gref_"-"_$E(node,3,$L(node)-1)_")"
	.	E  S dbref=gref_node_")"
	.	;
	.	S dbref="$G("_dbref_")"
	.	I bNotFound S dbref=" S "_$$lvpm(recInst,node,.lvpm)_"="_dbref
	.	Q 
	;
	Q dbref
	;
	; ---------------------------------------------------------------------
getDbase(db)	; database vendor or ""
	;
	I $get(%DB)="" S %DB=$$SCAU^%TRNLNM("DB") I (%DB="") S %DB="GTM"
	;
	I (db="") Q %DB
	Q db
	;
	; ---------------------------------------------------------------------
getDelimiter(delim)	; delimiter value or empty string
	I (delim="") Q 124
	Q delim
	;
	; ---------------------------------------------------------------------
getExisCode(tblDes,recInst,lvpm)	;
	I ($P(tblDes,"|",8)'="GTM") Q " I vEr=100"
	;
	N gblref S gblref=$$getGbl(tblDes,recInst,.lvpm)
	N nod S nod=$P(tblDes,"|",12)
	;
	I '(nod="") S gblref=gblref_nod_")"
	E  D
	.	S gblref=$E(gblref,1,$L(gblref)-1)
	.	I gblref["(" S gblref=gblref_")"
	.	Q 
	;
	I '(nod="")!($P(tblDes,"|",4)#2=1) Q " I "_$$lvpm(recInst,nod,.lvpm)_"="""",'$D("_gblref_")"
	;
	Q " I '$D("_gblref_")"
	;
	; ---------------------------------------------------------------------
getFlrLgc(tblDes,oper,qualExp,isPslExp)	;
	N logic N qual
	;
	S tblDes=$$tAssert^UCXDD(tblDes,2)
	;
	I $get(isPslExp) D
	.	I $$isLit^UCGM(qualExp) S qual=$$QSUB^%ZS(qualExp,"""")
	.	E  S qual=""
	.	Q 
	E  S qual=qualExp
	;
	I $P(tblDes,"|",16),'(("/"_qual_"/")["/NOLOG/") S logic="LOG"
	E  S logic=""
	;
	I '($P(tblDes,"|",8)'="GTM") D
	.	; If /NOINDEX not specified and index columns: add INDEX
	.	I '(("/"_qual_"/")["/NOINDEX/"),'($P(tblDes,"|",13)="") S logic=$S((logic=""):"INDEX",1:logic_"/"_"INDEX")
	.	;
	.	; If /NOVALFK not specified: add VALFK if the table is
	.	; a referencing table, and the operation is not DELETE
	.	I '(("/"_qual_"/")["/NOVALFK/") D
	..		;if oper'="DELETE", Db.isDefined( "DBTBL1F", "%LIBS='SYSDEV' and FID=:tblDes.table", 1) set logic = logic.add("VALFK","/") quit
	..		I oper'="DELETE"  N V1 S V1=$P(tblDes,"|",1) I $$vDbEx1() S logic=$S((logic=""):"VALFK",1:logic_"/"_"VALFK") Q 
	..		Q 
	.	Q 
	;
	; Triggers
	I '(("/"_qual_"/")["/NOTRIGBEF/")!'(("/"_qual_"/")["/NOTRIGAFT/") D
	.	;
	.	N trg
	.	N rs7,vos1,vos2,vos3,vos4  N V1 S V1=$P(tblDes,"|",1) S rs7=$$vOpen3()
	.	F  Q:'($$vFetch3())  D
	..		I $P(rs7,$C(9),1) S trg("TRIGBEF","INSERT")=1 S trg("TRIGBEF","SAVE")=1
	..		I $P(rs7,$C(9),2) S trg("TRIGAFT","INSERT")=1 S trg("TRIGAFT","SAVE")=1
	..		I $P(rs7,$C(9),3) S trg("TRIGBEF","UPDATE")=1 S trg("TRIGBEF","SAVE")=1
	..		I $P(rs7,$C(9),4) S trg("TRIGAFT","UPDATE")=1 S trg("TRIGAFT","SAVE")=1
	..		I $P(rs7,$C(9),5) S trg("TRIGBEF","DELETE")=1
	..		I $P(rs7,$C(9),6) S trg("TRIGAFT","DELETE")=1
	..		Q 
	.	I '(("/"_qual_"/")["/NOTRIGBEF/"),($D(trg("TRIGBEF",oper))#2) S logic=$S((logic=""):"TRIGBEF",1:logic_"/"_"TRIGBEF")
	.	I '(("/"_qual_"/")["/NOTRIGAFT/"),($D(trg("TRIGAFT",oper))#2) S logic=$S((logic=""):"TRIGAFT",1:logic_"/"_"TRIGAFT")
	.	Q 
	;
	; Journals
	I '(("/"_qual_"/")["/NOJOURNAL/") D
	.	I (oper="SAVE")!(oper="INSERT")  N V1 S V1=$P(tblDes,"|",1) I $$vDbEx2() S logic=$S((logic=""):"JOURNAL",1:logic_"/"_"JOURNAL") Q 
	.	I (oper="SAVE")!(oper="UPDATE")  N V2 S V2=$P(tblDes,"|",1) I $$vDbEx3() S logic=$S((logic=""):"JOURNAL",1:logic_"/"_"JOURNAL") Q 
	.	I oper="DELETE"  N V3 S V3=$P(tblDes,"|",1) I $$vDbEx4() S logic=$S((logic=""):"JOURNAL",1:logic_"/"_"JOURNAL")
	.	Q 
	;
	; VALDD, VALREQ, VALRI, and VALST: only look at explicit exclusion
	I '($P(tblDes,"|",6)=""),oper'="DELETE" D
	.	N q
	.	F q="VALDD","VALREQ","VALRI","VALST" I '(("/"_qual_"/")[("/"_"NO"_q_"/")) S logic=$S((logic=""):q,1:logic_"/"_q)
	.	Q 
	;
	; CASCADE: If table is referenced, then UPDATE and DELETE may cascade
	I oper'="INSERT" D
	.	I oper="DELETE",($P(tblDes,"|",8)'="GTM") D
	..		;
	..		N logCasc S logCasc=0
	..		N rsCasc,vos5,vos6,vos7,vos8  N V1 S V1=$P(tblDes,"|",1) S rsCasc=$$vOpen4()
	..		N tdCasc
	..		;
	..		F  Q:'($$vFetch4()&'logCasc)  D
	...			S tdCasc=$$getPslTbl^UCXDD(rsCasc,1)
	...			I '($$getFlrLgc(tdCasc,"DELETE",.qual)="") S logic=$S((logic=""):"CASCADE",1:logic_"/"_"CASCADE") S logCasc=1
	...			Q  ; end while rsCasc.next() & 'logCasc
	..		Q  ; end if RDB DELETE
	.	E   N V1 S V1=$P(tblDes,"|",1) I $$vDbEx5() S logic=$S((logic=""):"CASCADE",1:logic_"/"_"CASCADE")
	.	Q  ; end if not INSERT (= DELETE, SAVE or UPDATE)
	;
	Q logic
	;
	; ---------------------------------------------------------------------
getGbl(tblDes,recInst,lvpm)	;
	;type literal String oLvn = "vobj"
	;
	N gblref S gblref=$P(tblDes,"|",2)
	N gkey ; individual subscript
	N gkeys ; list of subscripts
	N tok ; literals
	N i ; iterator
	N keynum S keynum=0 ; current key number
	N return
	;
	S gkeys=$$TOKEN^%ZS($piece(gblref,"(",2,999),.tok)
	;
	S gblref=$piece(gblref,"(")_"("
	I ($D(lvpm(-99))#2) S gblref="^|"_$$lvpm(recInst,-99,.lvpm)_"|"_$E(gblref,2,1048575)
	;
	S return=gblref
	;
	I gkeys="" Q return
	;
	F i=1:1:$L(gkeys,",") D
	.	;
	.	S gkey=$$UNTOK^%ZS($piece(gkeys,",",i),.tok)
	.	I $$isLit^UCGM(gkey) S return=return_gkey_"," Q 
	.	;
	.	S keynum=keynum+1
	.	I (recInst=""),'($D(lvpm(keynum_"*"))#2) S i=$L(gkeys) Q 
	.	S return=return_$$lvpm(recInst,keynum_"*",.lvpm)_","
	.	Q 
	;
	Q return
	;
	; ---------------------------------------------------------------------
getGvn(tblDes,recInst,lvpm)	;
	N gvn S gvn=$$getGbl(tblDes,recInst,.lvpm)
	S gvn=$E(gvn,1,$L(gvn)-1)
	I gvn["(" Q gvn_")"
	Q gvn
	;
	; ---------------------------------------------------------------------
getLodCode(tblDes,recInst,node,mode,bExists,lvpm)	;
	;
	N cd ; column descriptor for blob/memo
	;
	N pur S pur=node
	I $E(node,1)="*" D
	.	S cd=$$getPslCln($P(tblDes,"|",1),$E(node,2,1048575))
	.	S node=$$getCurNode(cd,0)
	.	I '($D(lvpm(pur))#2),'(recInst=+recInst) S pur=node
	.	Q 
	;
	N code S code=" S" ; return value
	N dbref S dbref="" ; database reference code (DB dep)
	N left S left=$$lvpm(recInst,pur,.lvpm) ; target lvn
	N mdvar S mdvar=$$lvpm(recInst,-2,.lvpm) ; record mode
	N bSel S bSel=(mode=-2)!(mode<0&($P(tblDes,"|",8)'="GTM")) ; Add $S() ?
	;
	I bExists S code=code_":'$D("_left_")"
	;
	I mode=0 Q code_" "_left_"="""""
	;
	S code=code_" "_left_"="
	;
	I node?.E1",1" D
	.	I ($P(tblDes,"|",8)'="GTM") D  ; RDB code
	..		N sqlstm S sqlstm="SELECT "_$P(cd,"|",17)_" FROM "_$P(cd,"|",16)
	..		N nd151 S nd151=$$lvpm(recInst,-151,.lvpm)
	..		S dbref="$$wrSELECT^UCDBRT(0,"""_sqlstm_"""_"_nd151_",$C("_$P(tblDes,"|",10)_"),"""")"
	..		Q 
	.	E  D  ; MDB code
	..		N gref S gref=$$getGbl(tblDes,recInst,.lvpm)
	..		N ref
	..		S code=code_"""""" ; Initialize
	..		;
	..		I $P(tblDes,"|",4)=1 S ref=gref_"von)"
	..		E  S ref=gref_$piece(node,",",1)_",von)"
	..		S code=code_" N von S von="""" F "
	..		;
	..		I bSel S code=code_" Q:'"_mdvar_" " S bSel=0
	..		;
	..		S code=code_" S von=$O("_ref_") quit:von=""""  S "_left_"="_left_"_"_ref
	..		Q 
	.	Q 
	E  S dbref=$$getDataNode(tblDes,recInst,node,0,.lvpm)
	;
	I bSel S dbref="$S("_mdvar_":"_dbref_",1:"""")"
	Q code_dbref
	;
	; ---------------------------------------------------------------------
getNewCode(tblDes,recInst,mode)	;
	;
	N code S code="" ; return value
	;
	S code=$$cdNewObj^UCCLASS(recInst,"""Record"_$P(tblDes,"|",1)_"""")
	S code=code_","_"vobj"_"("_recInst_",-2)="_mode
	;
	I $P(tblDes,"|",4)#2>0 S code=code_","_"vobj"_"("_recInst_")="""""
	E  D
	.	N defNod S defNod=$P(tblDes,"|",12)
	.	I (defNod="") Q 
	.	I '(defNod=+defNod) S defNod=$S(defNod'["""":""""_defNod_"""",1:$$QADD^%ZS(defNod,""""))
	.	S code=code_","_"vobj"_"("_recInst_","_defNod_")="""""
	.	Q 
	;
	Q code
	;
	; ---------------------------------------------------------------------
getOldExpr(clnDes,recInst,bLeft)	;
	;
	I bLeft Q $$getOldLvn(clnDes,recInst)
	;
	I $P(clnDes,"|",15)>0 Q $$getOfXDB^UCCOLSF(clnDes,recInst)
	;
	N vcur S vcur=$$getCurExpr(clnDes,recInst,0)
	N vold S vold=$$getOldLvn(clnDes,recInst)
	;
	Q "$S($D("_vold_"):$P($E("_vold_",5,9999),$C("_$P(clnDes,"|",5)_")),1:"_vcur_")"
	;
	; ---------------------------------------------------------------------
getOldLvn(clnDes,recInst)	;
	Q $$cdOldLvn(recInst,$$getOldNode^UCXDD(clnDes,1),""""_$P(clnDes,"|",2)_"""")
	;
	; ---------------------------------------------------------------------
getOldNode(clnDes,bQuoted)	;
	;
	N nod S nod=$$getCurNode(clnDes,bQuoted)
	I (nod="") S nod="0*" ; top
	E  I +nod<0 S nod=$P(clnDes,"|",4)_"*" ; key
	;
	I +nod'=nod,$E(nod,1)'="""",bQuoted Q $S(nod'["""":""""_nod_"""",1:$$QADD^%ZS(nod,""""))
	Q nod
	;
	; ---------------------------------------------------------------------
getPslCln(TBL,CLN,tblDes)	;
	;
	N dbtbl1d S dbtbl1d=$$vDb4("SYSDEV",TBL,CLN)
	N td S td=$$caPslTbl(.tblDes,TBL)
	;
	N ret S ret=TBL_"|"_CLN
	;
	S $piece(ret,"|",5)=$P(td,"|",10) ; delimiter
	S $piece(ret,"|",6)=$P(dbtbl1d,$C(124),9) ; dataType
	S $piece(ret,"|",7)=$P(dbtbl1d,$C(124),2) ; length
	S $piece(ret,"|",8)=$P(dbtbl1d,$C(124),14) ; precision
	S $piece(ret,"|",9)=$P(dbtbl1d,$C(124),31) ; isNullToZero
	;
	I "BM"'[$P(dbtbl1d,$C(124),9) S $piece(ret,"|",14)=$P(dbtbl1d,$C(124),16)
	;
	S $piece(ret,"|",15)=$$isSfdMaster(TBL,CLN,$P(dbtbl1d,$C(124),17))
	;
	N node S node=$P(dbtbl1d,$C(124),1) ; assume same for MDB and RDB
	;
	I ($P(td,"|",8)'="GTM") D
	.	N intTbl S intTbl=TBL
	.	N intCln S intCln=CLN
	.	N pos
	.	;
	.	D MAP^DBMAP(%DB,.intTbl,.intCln,.pos)
	.	I intCln["(" S intCln="" ; do not store computations
	.	I $E(intCln,1)="""" S intCln=$$QSUB^%ZS(intCln,"""")
	.	;
	.	N pks S pks=$P(td,"|",3)
	.	I (pks="") S node="" ; node for CUVAR etc.
	.	E  I node["*" ; RDB=MDB, no extra processing
	.	E  I $P(td,"|",4)=11 D  ; node for wide table
	..		N suffix S suffix=$$tbl2nod^DBMAP(intTbl)
	..		I suffix?1.N S node=suffix
	..		E  S node="CID"
	..		Q 
	.	E  S node=$piece(pks,",",$S((pks=""):0,1:$L(pks,",")))
	.	;
	.	; subfieldXxx will be implied empty if not assigned explicitly
	.	S $piece(ret,"|",4)=pos ; position
	.	S $piece(ret,"|",16)=intTbl ; internalTable
	.	S $piece(ret,"|",17)=intCln ; internalColumn
	.	;
	.	I "BM"[$P(dbtbl1d,$C(124),9) S node=pos
	.	;
	.	I $piece(ret,"|",15)=1 S $piece(ret,"|",15)=2
	.	Q 
	E  D  ; MDB table
	.	N pos
	.	S $piece(ret,"|",10)=$P($P(dbtbl1d,$C(124),18),$C(126),1) ; subfieldTag
	.	S $piece(ret,"|",11)=$P($P(dbtbl1d,$C(124),18),$C(126),2) ; subfieldMajor
	.	S $piece(ret,"|",12)=$P($P(dbtbl1d,$C(124),18),$C(126),3) ; subfieldMinor
	.	S pos=$P($P(dbtbl1d,$C(124),18),$C(126),4)
	.	I '($P($P(dbtbl1d,$C(124),18),$C(126),1)=""),pos'>0 S pos=1
	.	S $piece(ret,"|",13)=pos ; subfieldPosition
	.	S $piece(ret,"|",4)=$P(dbtbl1d,$C(124),21) ; position
	.	S $piece(ret,"|",16)=TBL ; internalTable
	.	S $piece(ret,"|",17)=CLN ; internalColumn
	.	I "BM"[$P(dbtbl1d,$C(124),9),(node="")!($P(td,"|",4)=1) S node=1
	.	Q 
	;
	;if td.primaryKeys.isNull() set ret.piece(SEP, 3) = "" // node
	;else  set ret.piece(SEP, 3) = node
	S $piece(ret,"|",3)=node
	I node["*",CLN'=+CLN,$E(CLN,1)'="""" D
	.	N keys S keys=$P(td,"|",3)
	.	S $piece(ret,"|",4)=$L($piece((","_keys_","),","_CLN_",",1),",") ; key position
	.	Q 
	Q ret
	;
	; ---------------------------------------------------------------------
getPslTbl(TBL,LVL)	;
	;
	N rec,vop1,vop2,vop3,vop4,vop5,vop6 S vop1="SYSDEV",vop2=TBL,rec=$$vDb5("SYSDEV",TBL)
	 S vop4=$G(^DBTBL(vop1,1,vop2,16))
	 S vop5=$G(^DBTBL(vop1,1,vop2,99))
	 S vop3=$G(^DBTBL(vop1,1,vop2,10))
	 S vop6=$G(^DBTBL(vop1,1,vop2,100))
	;
	N dbi S dbi=$$rtDbase(TBL)
	N rdb S rdb=(dbi'="GTM")
	;
	N ret S ret=""
	S $piece(ret,"|",16)=""
	;
	S $piece(ret,"|",1)=TBL ; table
	S $piece(ret,"|",3)=$$sub2cln($P(vop4,$C(124),1)) ; primaryKeys
	S $piece(ret,"|",6)=$P(vop5,$C(124),2) ; filerPGM
	S $piece(ret,"|",7)=$P(vop3,$C(124),4) ; parentTable
	S $piece(ret,"|",8)=dbi ; datebase
	S $piece(ret,"|",10)=$$getDelimiter($P(vop3,$C(124),1)) ; columnDelimiter
	S $piece(ret,"|",16)=$P(vop6,$C(124),5) ; isAutoLog
	;
	I rdb D  ; for RDB tables
	.	N intNms S intNms=TBL
	.	D MAP^DBMAP(%DB,.intNms)
	.	S $piece(ret,"|",9)=intNms ; internalNames
	.	I intNms["," S $piece(ret,"|",4)=11
	.	E  S $piece(ret,"|",4)=1 ; recordType
	.	Q 
	E  D  ; for MDB tables
	.	I $P(vop4,$C(124),1)="""*""" S $piece(ret,"|",2)=$piece($P(vop6,$C(124),1),"(")
	.	E  S $piece(ret,"|",2)=$P(vop6,$C(124),1)
	.	S $piece(ret,"|",4)=$P(vop6,$C(124),2) ; recordType
	.	S $piece(ret,"|",9)=TBL ; internalNames
	.	S $piece(ret,"|",12)=$P(vop3,$C(124),13) ; existsNode
	.	Q 
	I LVL>0 S ret=$$tAssert(ret,LVL)
	;
	Q ret
	;
	; ---------------------------------------------------------------------
getPurNode(clnDes)	; column descriptor
	I "BM"[$P(clnDes,"|",6) Q "*"_$P(clnDes,"|",2)
	;
	N nod S nod=$$getCurNode(clnDes,1)
	;
	I (nod="") Q "0*"
	Q nod
	;
getQuery(tblDes)	; table descriptor
	N vret
	;
	N dbtbl1,vop1,vop2,vop3 S vop1="SYSDEV",vop2=$P(tblDes,"|",1),dbtbl1=$$vDb5("SYSDEV",vop2)
	 S vop3=$G(^DBTBL(vop1,1,vop2,14))
	;
	S vret=$P(vop3,$C(124),1) Q vret
	;
	; ---------------------------------------------------------------------
getRdbAsn(clnDes,recInst)	;
	N ic S ic=""""_$P(clnDes,"|",17)_""""
	N it S it=""""_$P(clnDes,"|",16)_""""
	;
	N nod S nod=$$getOldNode^UCXDD(clnDes,1)
	;
	N pos S pos=$P(clnDes,"|",4)
	I (pos="") S pos=""""""
	;
	N mod S mod=$$toValMod($P(clnDes,"|",6),$P(clnDes,"|",9))
	;
	; If non-key column the single statement can be returned
	I $P(clnDes,"|",3)'?1.N1"*" Q $$cdRdbAsn(recInst,it,ic,nod,pos,mod)
	;
	; For key columns return one assignment per node/wide table
	N td S td=$$getPslTbl($P(clnDes,"|",1),1)
	S pos=$$getCurNode^UCXDD(clnDes,0)
	N rdbAsn S rdbAsn=$$cdRdbAsn(recInst,it,ic,"""0*""",pos,mod)
	I $P(td,"|",4)>1 D
	.	N n
	.	F n=1:1:$S(($P(td,"|",9)=""):0,1:$L($P(td,"|",9),",")) D
	..		S it=$piece($P(td,"|",9),",",n)
	..		S nod=$$tbl2nod^DBMAP(it)
	..		I '(nod="") S rdbAsn=rdbAsn_","_$$cdRdbAsn(recInst,""""_it_"""",ic,nod,pos,mod)
	..		Q 
	.	Q 
	Q rdbAsn
	;
	; ---------------------------------------------------------------------
getRdbExpr(clnDes,recInst)	;
	N curExp S curExp=$$getCurExpr^UCXDD(clnDes,recInst,0)
	I $P(clnDes,"|",6)="L" Q "+"_curExp
	I $P(clnDes,"|",9) Q "+"_curExp
	I "CDN$"[$P(clnDes,"|",6) Q $S($$getCurNode^UCXDD(clnDes,0)<0:"+"_curExp,1:"$S("_curExp_"="""":"""",1:+"_curExp_")")
	Q curExp
	;
	; ---------------------------------------------------------------------
getRecCode(tblDes,recInst,lvpm,mcd,clnDes)	;
	N fkeys S fkeys=$P(tblDes,"|",3)
	N i
	N nodes ; nodes that need to be pre-loaded
	N qid1code ; code that deals with QID1
	N tbl S tbl=$P(tblDes,"|",1) ; DQ table name
	N vsub ; variable substitutes for SQL engine
	;
	F i=1:1:$S((fkeys=""):0,1:$L(fkeys,",")) S vsub(tbl_"."_$piece(fkeys,",",i))=$$lvpm(recInst,i_"*",.lvpm)
	;
	I ($D(lvpm(-1))#2) S nodes(-1)=lvpm(-1)
	N isPc S isPc=$$getRecQid1(tblDes,recInst,,.vsub,.nodes,.qid1code)
	K nodes(-1)
	;
	N base S base=0
	N xnd S xnd=$$getRecPur(tblDes)
	N nod S nod=""
	F  S nod=$order(nodes(nod)) Q:nod=""  D
	.	I nod'=xnd S base=base+1 S mcd(base)=$$getLodCode(tblDes,recInst,nod,1,0,.lvpm)
	.	Q 
	;
	I '(xnd="") D
	.	N code S code=$$getDataNode(tblDes,recInst,xnd,1,.lvpm)
	.	F i=1:1:$L(code,$char(9)) S mcd(base+i)=$piece(code,$char(9),i)
	.	Q 
	;
	S base=$order(mcd(""),-1)
	F i=1:1:$get(qid1code) S mcd(base+i)=qid1code(i)
	;
	N code
	I $D(qid1code)>9,'isPc S code=" E "
	E  S code=""
	I ($P(tblDes,"|",7)="") S base=$order(mcd(""),-1)+1 S mcd(base)=code_$$getExisCode(tblDes,recInst,.lvpm)
	;
	Q 
	;
	; ---------------------------------------------------------------------
getRecPur(tblDes)	; table desctiptor descriptor
	I $P(tblDes,"|",4)#2=1 Q "0*"
	;
	Q $P(tblDes,"|",12)
	;
	; ---------------------------------------------------------------------
getRecQid1(tblDes,recInst,ptable,vsub,nodes,mcode)	;
	N tbl S tbl=$P(tblDes,"|",1) ; DQ table name
	N whr ; result from VIEW^SQLM
	;
	N join N cmp N fsn N rng N tok N vdd
	N ER S ER=0 N RM S RM="" ; good old error mechanism
	;
	N rs,vos1,vos2,vos3  N V1 S V1=tbl S rs=$$vOpen5()
	N isParent S isParent=''$G(vos1)
	I ($D(nodes(-1))#2) D
	.	F  Q:'($$vFetch5())  D
	..		N ctable S ctable=rs
	..		N ctd S ctd=$$getPslTbl(ctable,0)
	..		;
	..		N dummy S dummy=$$getRecQid1(ctd,recInst,tbl,.vsub,.nodes,.mcode)
	..		Q 
	.	Q 
	;
	I ($P(tblDes,"|",8)'="GTM"),($P(tblDes,"|",7)="") Q isParent
	;
	N vxp S vxp=-1 ; unused, but required by VIEW^SQLM
	D fsn^SQLDD(.fsn,tbl) ; unused, but required by VIEW^SQLM
	D VIEW^SQLM(tbl,.whr,.fsn) I +ER'=0 D ERROR^UCGM($get(RM)) Q isParent
	;
	I $D(whr)<9 Q isParent
	;
	N c ; qualified column name
	N cd ; column descriptor
	N i N j N n ; iterators
	N nod ; current node of qcn in whr()
	N z ; scratch, data
	;
	S n=""
	F  S n=$order(whr(n)) Q:n=""  F i=1,2 D
	.	S z=$piece(whr(n),$char(9),i)
	.	F j=2:2:$L(z,$char(1)) D
	..		S c=$piece(z,$char(1),j)
	..		I ($D(vsub(c))#2) Q 
	..		S cd=$$getPslCln($piece(c,"."),$piece(c,".",2))
	..		;
	..		S vsub(c)=$$getCurExpr(cd,recInst,0)
	..		;
	..		S nod=$$getCurNode(cd,0)
	..		I nod'="",nod'<0,'($D(nodes(nod))#2) S nodes(nod)=""
	..		Q 
	.	Q 
	;
	N ptr S ptr=$get(mcode) ; skip current data in mcode()
	;
	D QUERY^SQLA(""_$translate($J("",$order(whr(""),-1)-0)," ",1),.whr,.mcode,.vsub,tbl,,0,0)
	;
	F i=ptr+1:1:$get(mcode) D
	.	I mcode(i)[" S vsql=-1" S mcode(i)=$piece(mcode(i)," S vsql=-1")
	.	S mcode(i)=" "_mcode(i)
	.	I i>(ptr+1),$E(mcode(i),1,4)'=" E  " S mcode(i)=" E "_mcode(i)
	.	I '($D(ptable)#2) Q 
	.	;
	.	S mcode(i)=$piece(mcode(i),"'")_$piece(mcode(i),"'",2,999)_" S "_nodes(-1)_"=""Record"_tbl_""""
	.	Q 
	;
	Q isParent
	;
	; ---------------------------------------------------------------------
getSavCode(tblDes,recInst,node,mode,lvpm,rdbCln)	;
	;
	N cd ; column descriptor
	;
	N pur S pur=node
	I $E(node,1)="*" D
	.	S cd=$$getPslCln($P(tblDes,"|",1),$E(node,2,1048575))
	.	S node=$$getCurNode(cd,0)
	.	I '($D(lvpm(pur))#2),'(recInst=+recInst) S pur=node
	.	Q 
	;
	N code S code="" ; return value
	N right S right=$$lvpm(recInst,pur,.lvpm) ; source lvn
	N mdvar S mdvar=$$lvpm(recInst,-2,.lvpm) ; record mode
	N gref S gref=$$getGbl(tblDes,recInst,.lvpm)
	;
	I node?.E1",1" D
	.	; ================ RDB blob / memo ================
	.	I ($P(tblDes,"|",8)'="GTM") D
	..		;
	..		N nd151 S nd151=$$lvpm(recInst,-151,.lvpm)
	..		;
	..		I $P(cd,"|",6)="M",$P(cd,"|",7)<4001 D
	...			N sqlstm S sqlstm="UPDATE "_$P(cd,"|",16)_" SET "_$P(cd,"|",17)_"="
	...			S code=" D wrEXEC^UCDBRT("""","""_sqlstm_"""_$$QADD^%ZS("_right_",""'"")_"_nd151_",$C("_$P(tblDes,"|",10)_"),"""")"
	...			Q 
	..		E  S code=" D wrLOBUPD^UCDBRT(0,"""_$P(cd,"|",16)_""","""_$P(cd,"|",17)_""",$E("_nd151_",8,"_1048575_"),"_right_",$C("_$P(tblDes,"|",10)_"),"""")"
	..		Q 
	.	; ================ MDB blob / memo ================
	.	E  D
	..		N ref
	..		N step S step=450
	..		N extr S extr=step-1
	..		;
	..		I $P(tblDes,"|",4)=1 S ref=gref_"vS1)"
	..		E  S ref=gref_$piece(node,",")_",vS1)" S code=" K "_gref_$piece(node,",")_")"
	..		S code=code_" N vS1,vS2 S vS1=0 F vS2=1:"_step_":$L("_right_") S vS1=vS1+1,"_ref_"=$E("_right_",vS2,vS2+"_extr_")"
	..		Q 
	.	Q 
	E  D
	.	; ================ RDB standard node ================
	.	I ($P(tblDes,"|",8)'="GTM") D
	..		N codCol S codCol="" ; column list for INSERT
	..		N codHvI S codHvI="" ; hostval INSERT list
	..		N codHvU S codHvU="" ; hostval UPDATE list
	..		N codUpd S codUpd="" ; column=value list for UPDATE
	..		N codVal S codVal="" ; value list for INSERT
	..		;
	..		N pos S pos=$order(rdbCln("")) ; position iterator
	..		N hvn S hvn=1 ; hostval number
	..		N hve ; hostvar expression
	..		N sqlstm
	..		;
	..		; no rdbCLn(). Behavior to be specified
	..		I (pos="") D  Q 
	...			I (node="") S code=" D VOBJ^DBSDBASE("_recInst_",$C("_$P(tblDes,"|",10)_"))" Q 
	...			Q 
	..		;
	..		S codCol=$P(rdbCln(pos),"|",17)
	..		S codVal=":HV1"
	..		S codUpd=$P(rdbCln(pos),"|",17)_"=:HV1"
	..		S codHvU=$$getRdbExpr(rdbCln(pos),recInst)_"_$C("_$P(tblDes,"|",10)_")"
	..		S sqlstm=$P(rdbCln(pos),"|",16) ; same for all columns
	..		;
	..		F hvn=2:1 S pos=$order(rdbCln(pos)) Q:(pos="")  D
	...			S codCol=codCol_", "_$P(rdbCln(pos),"|",17)
	...			S codVal=codVal_", :HV"_hvn
	...			S codUpd=codUpd_", "_$P(rdbCln(pos),"|",17)_"=:HV"_hvn
	...			S codHvU=codHvU_$char(9)_$$getRdbExpr(rdbCln(pos),recInst)_"_$C("_$P(tblDes,"|",10)_")"
	...			Q 
	..		;
	..		I mode'=1 D
	...			S codHvI=codHvU
	...			F pos=1:1:$S(($P(tblDes,"|",3)=""):0,1:$L($P(tblDes,"|",3),",")) D
	....				I ($D(rdbCln(-pos-2))#2) Q 
	....				S cd=$$getPslCln($P(tblDes,"|",1),$piece($P(tblDes,"|",3),",",pos))
	....				S hvn=hvn+1
	....				S codCol=codCol_", "_$P(cd,"|",17)
	....				S codVal=codVal_", :HV"_hvn
	....				S codHvI=codHvI_$char(9)_$$getRdbExpr(cd,recInst)_"_$C("_$P(tblDes,"|",10)_")"
	....				Q 
	...			Q 
	..		;
	..		;set codCol = " wrEXEC^UCDBRT(0,""INSERT INTO "_ sqlstm_ " ("_ codCol_ ") VALUES ("_ codVal_ ")"",$C("_ tblDes.columnDelimiter_ "),"_codHvI_")"
	..		;set codUpd = " wrEXEC^UCDBRT(0,""UPDATE "_ sqlstm_ " SET "_codUpd_"""_"_$$lvpm( recInst, -151, .lvpm())_",$C("_ tblDes.columnDelimiter_ "),"_codHvU_")"
	..		S codCol="INSERT INTO "_sqlstm_" ("_codCol_") VALUES ("_codVal_")"
	..		S codUpd="UPDATE "_sqlstm_" SET "_codUpd
	..		;
	..		N updExtnd S updExtnd=$S('($P(tblDes,"|",3)=""):"_"_$$lvpm(recInst,-151,.lvpm),1:"")
	..		;
	..		I mode=0 S code=$$getSavWr("",codCol,"",$P(tblDes,"|",10),codHvI)
	..		E  I mode=1 S code=$$getSavWr("",codUpd,updExtnd,$P(tblDes,"|",10),codHvU)
	..		E  D
	...			S code=$$getSavWr(":'("_mdvar_")",codCol,"",$P(tblDes,"|",10),codHvI)
	...			S sqlstm=$$getSavWr(":"_mdvar,codUpd,updExtnd,$P(tblDes,"|",10),codHvU)
	...			I $$wrapFits^UCREC4OP(code_sqlstm,10) S code=code_sqlstm
	...			E  S code=code_$char(9)_sqlstm
	...			Q 
	..		;
	..		I $L(code,$char(9))>2 S code=" N vS1,vS2"_$char(9)_code
	..		Q 
	.	; ================ MDB standard node ================
	.	E  D
	..		I (node="") S gref=$E(gref,1,$L(gref)-1)
	..		I $E(node,1,2)="""v" S node="-"_$E(node,3,$L(node)-1)
	..		I $P(tblDes,"|",4)=1 D
	...			N td S td=$$tAssert^UCXDD(tblDes,1)
	...			I ($P(td,"|",5)["B")!($P(td,"|",5)["M") S code=" K:$D("_"vobj"_"("_recInst_",1,1)) "_gref_")"
	...			Q 
	..		S code=code_" S "_gref_node_")="_right
	..		Q 
	.	Q  
	Q code
	;
	; ---------------------------------------------------------------------
getSavWr(postCond,sql,updKey,delim,hvList)	;
	I $$wrapFits^UCREC4OP(postCond_sql_updKey_delim_hvList,40) Q " D"_postCond_" wrEXEC^UCDBRT(0,"_$S(sql'["""":""""_sql_"""",1:$$QADD^%ZS(sql,""""))_updKey_",$C("_delim_"),"_$translate(hvList,$char(9),"_")_")"
	;
	N code N aHvl N aSql
	N ln
	;
	; split SQL statement and insert lines into code
	D splitCode^UCGMC(sql,20,"",.aSql)
	S code=" S"_postCond_" vS1="_$S(aSql(1)'["""":""""_aSql(1)_"""",1:$$QADD^%ZS(aSql(1),""""))
	F ln=2:1:$order(aSql(""),-1) S code=code_$char(9)_" S"_postCond_" vS1=vS1_"_$S(aSql(ln)'["""":""""_aSql(ln)_"""",1:$$QADD^%ZS(aSql(ln),""""))
	;
	; split hostval list creation and append lines to code (assume 40 wraps)
	D splitCode^UCGMC(hvList,400,$char(9),.aHvl)
	S code=code_$char(9)_" S"_postCond_" vS2="_$translate(aHvl(1),$char(9),"_")
	;
	F ln=2:1:$order(aHvl(""),-1) S code=$E(code,1,$L(code)-1)_$char(9)_" S"_postCond_" vS2=vS2_"_$translate(aHvl(ln),$char(9),"_")
	;
	Q code_$char(9)_" D"_postCond_" wrEXEC^UCDBRT(0,vS1"_updKey_",$C("_delim_"),vS2)"
	;
	; ---------------------------------------------------------------------
getSchCln(TBL,CLN)	;
	;
	N ret S ret=$$getPslCln(TBL,CLN)
	N dbtbl1d S dbtbl1d=$$vDb4("SYSDEV",TBL,CLN)
	;
	S $piece(ret,"|",18)=$P(dbtbl1d,$C(124),3) ; default
	S $piece(ret,"|",19)=$P(dbtbl1d,$C(124),4) ; userType
	S $piece(ret,"|",20)=$P(dbtbl1d,$C(124),5) ; lookupTable
	S $piece(ret,"|",21)=$P(dbtbl1d,$C(124),6) ; pattern
	S $piece(ret,"|",22)=$P(dbtbl1d,$C(124),7) ; postProcExpr
	S $piece(ret,"|",23)=$P(dbtbl1d,$C(124),8) ; preProcExpr
	S $piece(ret,"|",24)=$P(dbtbl1d,$C(124),10) ; description
	S $piece(ret,"|",25)=$P(dbtbl1d,$C(124),11) ; internalType
	S $piece(ret,"|",26)=$P(dbtbl1d,$C(124),12) ; minimum
	S $piece(ret,"|",27)=$P(dbtbl1d,$C(124),13) ; maximum
	S $piece(ret,"|",28)=$P(dbtbl1d,$C(124),15) ; isRequired
	S $piece(ret,"|",29)=$P(dbtbl1d,$C(124),19) ; displaySize
	S $piece(ret,"|",30)=$P(dbtbl1d,$C(124),22) ; reportHeader
	S $piece(ret,"|",31)=$P(dbtbl1d,$C(124),23) ; isSerial
	S $piece(ret,"|",32)=$P(dbtbl1d,$C(124),24) ; conversionFlag
	S $piece(ret,"|",33)=$P(dbtbl1d,$C(124),25) ; dateUpdated
	S $piece(ret,"|",34)=$P(dbtbl1d,$C(124),26) ; userUpdated
	S $piece(ret,"|",35)=$P(dbtbl1d,$C(124),27) ; masterDataDictionary
	S $piece(ret,"|",36)=$P(dbtbl1d,$C(124),28) ; isValidForExtraction
	S $piece(ret,"|",37)=$P(dbtbl1d,$C(124),29) ; preProcDataEntry
	S $piece(ret,"|",38)=$P(dbtbl1d,$C(124),30) ; postProcDataEntry
	;
	Q ret
	;
	; ---------------------------------------------------------------------
getSchTbl(TBL)	; name of table
	;
	N ret S ret=$$getPslTbl(TBL,0)
	;
	N rec,vop1,vop2,vop3,vop4,vop5,vop6 S vop1="SYSDEV",vop2=TBL,rec=$$vDb5("SYSDEV",TBL)
	 S vop4=$G(^DBTBL(vop1,1,vop2,12))
	 S vop5=$G(^DBTBL(vop1,1,vop2,99))
	 S vop3=$G(^DBTBL(vop1,1,vop2,10))
	 S vop6=$G(^DBTBL(vop1,1,vop2,100))
	;
	S $piece(ret,"|",17)=$P(vop4,$C(124),1) ; fileShortName
	S $piece(ret,"|",18)=$P(vop5,$C(124),4) ; verifyPGM
	S $piece(ret,"|",19)=$P(vop5,$C(124),6) ; publishPGM
	S $piece(ret,"|",20)=$P(vop3,$C(124),2) ; systemName
	S $piece(ret,"|",21)=$P(vop3,$C(124),3) ; networkLocation
	S $piece(ret,"|",22)=$P(vop6,$C(124),4) ; dateCreated
	S $piece(ret,"|",23)=$P(vop6,$C(124),8) ; timeCreated
	S $piece(ret,"|",24)=$P(vop6,$C(124),3) ; userCreated
	S $piece(ret,"|",25)=$P(vop6,$C(124),10) ; dateUpdated
	S $piece(ret,"|",26)=$P(vop6,$C(124),11) ; timeUpdated
	S $piece(ret,"|",27)=$P(vop6,$C(124),9) ; userUpdated
	S $piece(ret,"|",31)=$P(rec,$C(124),1) ; description
	;
	S ret=$$tAssert(ret,2)
	Q ret
	;
	; ---------------------------------------------------------------------
getSfd(TBL,CLN,SFD)	;
	N dbtbl1d,vop1 S dbtbl1d=$$vDb6("SYSDEV",TBL,CLN,.vop1)
	I $G(vop1)=0 Q ""
	;
	N N S N=$P(dbtbl1d,$C(124),1)
	N P S P=$P(dbtbl1d,$C(124),21)
	N rs,vos1,vos2,vos3,vos4,vos5,vos6,vos7,vos8,vOid S rs=$$vOpen6()
	N cnt S cnt=0
	F  Q:'($$vFetch6())  S cnt=cnt+1 S SFD(cnt)=$translate(rs,$C(9),"~")
	Q "~String DI,String SFT,Number SFD1, Number SFD2,Number SFP"
	;
	; ---------------------------------------------------------------------
getSfdMaster(TBL,CLN)	;
	N vret
	N dbtbl1d S dbtbl1d=$G(^DBTBL("SYSDEV",1,TBL,9,CLN))
	I ($P(dbtbl1d,$C(124),18)="") Q "" ; not a subfield
	;
	N N S N=$P(dbtbl1d,$C(124),1)
	N P S P=$P(dbtbl1d,$C(124),21)
	;
	N rs,vos1,vos2,vos3,vos4,vos5,vos6 S rs=$$vOpen7()
	I $$vFetch7() S vret=rs Q vret
	Q ""
	;
	; ---------------------------------------------------------------------
getSfdRT()	; Row Template for getSfd
	Q ("String DI,String SFT,Number SFD1,Number SFD2,Number SFP"_$char(9)_126)
	;
	; ---------------------------------------------------------------------
getUpdAudit(clnDes,recInst,getval,fromSQL)	;
	N oldlvn S oldlvn=$$getOldLvn(clnDes,recInst)
	N xtra S xtra=""
	N z S z=" S:'$D("_oldlvn_") "_oldlvn_"="""_$P(clnDes,"|",6)_$E(((1000+$P(clnDes,"|",4))),2,4)_"""_"
	;
	I $P(clnDes,"|",3)?1.N1"*" S z=z_"$G("_getval_")"
	E  D
	.	N fmtable
	.	S fmtable=$$FMTABLE^DBSMACRO($P(clnDes,"|",1)_"."_$P(clnDes,"|",2))
	.	S z=z_getval
	.	I '($P(clnDes,"|",13)="") D
	..		N d2 S d2=$SELECT($P(clnDes,"|",5)=126:";",1:"~")
	..		S $piece(xtra,$char($P(clnDes,"|",5)),3)=$P(clnDes,"|",10)_d2_$P(clnDes,"|",11)_d2_$P(clnDes,"|",12)_d2_$P(clnDes,"|",13)
	..		Q 
	.	I '(fmtable="") S $piece(xtra,$char($P(clnDes,"|",5)),11)=fmtable
	.	Q 
	;
	I fromSQL S $piece(xtra,$char($P(clnDes,"|",5)),2)=1
	I '(xtra="") S z=z_"_"_$$vBtsPslE(xtra)
	Q z
	;
	; ---------------------------------------------------------------------
getUpdCode(clnDes,recInst,value,mode)	;
	;
	N bAudit S bAudit=(mode#3)>0
	N td S td=$$getPslTbl($P(clnDes,"|",1),0)
	;
	I $P(clnDes,"|",15)>0,($P(td,"|",8)'="GTM")!bAudit Q $$setMfXDB^UCCOLSF(clnDes,recInst,value,mode)
	;
	N getval
	N setval S setval=$$getCurExpr(clnDes,recInst,1)
	;
	I ($P(clnDes,"|",13)="") D
	.	S getval=setval
	.	S setval=setval_"="_value
	.	Q 
	E  D
	.	S getval=$$getCurExpr(clnDes,recInst,0)
	.	S setval=$$setSfMDB^UCCOLSF(setval,value,$P(clnDes,"|",10),$P(clnDes,"|",11),$P(clnDes,"|",12),$P(clnDes,"|",13))
	.	Q 
	;
	N code S code=$$getUpdOvh(clnDes,recInst,getval,mode)
	I code[" S " S code=code_","
	E  S code=code_" S "
	S code=code_setval
	;
	Q code
	;
	; ---------------------------------------------------------------------
getUpdKey(tblDes,recInst,lvpm)	;
	;
	N code S code=""
	N keys S keys=$P(tblDes,"|",3)
	N pos
	;
	I (keys="") Q ""
	;
	F pos=1:1:$S((keys=""):0,1:$L(keys,",")) D
	.	I pos>1 S code=code_"_"" AND "
	.	N cd S cd=$$getPslCln($P(tblDes,"|",1),$piece(keys,",",pos))
	.	N typ S typ=$P(cd,"|",6)
	.	;type String kve = cd.getCurrentLvn( recInst)
	.	N kve S kve=$$lvpm(recInst,pos_"*",.lvpm)
	.	;
	.	I "FUT"[typ S kve="$S("_kve_"'[""'"":""'""_"_kve_"_""'"",1:$$QADD^%ZS("_kve_",""'""))"
	.	E  S kve="(+"_kve_")"
	.	S code=code_$P(cd,"|",17)_"=""_"_kve
	.	Q 
	;
	Q " S "_$$lvpm(recInst,-151,.lvpm)_"="" WHERE "_code
	;
	; ---------------------------------------------------------------------
getUpdOvh(clnDes,recInst,getval,mode)	;
	;
	N bAudit S bAudit=(mode#3)>0
	N td S td=$$getPslTbl($P(clnDes,"|",1),0)
	;
	I $P(clnDes,"|",15)>0,($P(td,"|",8)'="GTM")!bAudit S $ZS="-1,"_$ZPOS_","_"%PSL-E-NOTSUPPORTED,method not supported for masterfield" X $ZT
	;
	N codeAll N codeCond
	I (recInst=+recInst) S recInst=$$dec2ovs^UCREC4OP(recInst)
	I ($P(td,"|",8)'="GTM"),mode<3 S codeAll=" S "_$$getRdbAsn(clnDes,recInst)
	E  S codeAll=""
	;
	; Code to save column.oldval if audit is on
	I bAudit S codeCond=$$getUpdAudit(clnDes,recInst,getval,(mode#3)=2) ; prepend!
	E  S codeCond=""
	;
	; add code to notify node changed if needed or requested
	I (($P(td,"|",4)>1)&($$getCurNode(clnDes,0)'<0))!bAudit D
	.	I (codeAll="") S codeAll=" S "
	.	E  S codeAll=codeAll_","
	.	S codeAll=codeAll_$$cdNodChg(recInst,$$getOldNode(clnDes,1))_"="""""
	.	Q 
	;
	Q codeCond_codeAll
	;
	; ---------------------------------------------------------------------
getWhrKey(tblDes,recInst,md,lvpm,hostval,hostrsp,coldes)	;
	N cd ; individual column descriptor
	N cln ; individual (key)column name
	N k ; interator
	N primkey S primkey=$P(tblDes,"|",3)
	N tbl S tbl=$P(tblDes,"|",1) ; external table name
	N val ; individual key value expr
	N where S where="" ; where clause (to be returned)
	;
	; variables used to differentiate code depending on md
	N colon N sep
	;
	S (hostval,hostrsp)=""
	;
	; If primary key IS NULL quit ""
	I (primkey="") Q ""
	;
	; Set colon, qtpre, qtpost, and sep based on md
	I md=1 S sep="_$C(1)" S colon=""
	E  S sep="_$C("_$P(tblDes,"|",10)_")" S colon=":"
	;
	F k=1:1:$S((primkey=""):0,1:$L(primkey,",")) D
	.	S val="V"_k
	.	S cln=$piece(primkey,",",k)
	.	S cd=$$caPslCln(.coldes,tbl_"."_cln)
	.	I k>1 S where=where_" AND " S hostval=hostval_"_" S hostrsp=hostrsp_","
	.	S where=where_$P(cd,"|",17)_"="_colon_val
	.	S hostrsp=hostrsp_val
	.	S hostval=hostval_$$lvpm(recInst,k_"*",.lvpm)_sep
	.	Q 
	Q where
	;
	; ---------------------------------------------------------------------
isColumn(TBL,CLN)	;
	Q ($D(^DBTBL("SYSDEV",1,TBL,9,CLN))#2)
	;
	; ---------------------------------------------------------------------
isSfdMaster(TBL,CLN,dicval)	;
	N vret
	 ; boot restrictions ...
	;
	; if value supplied, and not empty, return it
	I '($get(dicval)="") Q dicval
	;
	; need to retrieve row
	I '($D(^DBTBL("SYSDEV",1,TBL,9,CLN))#2) Q ""
	N dbtbl1d S dbtbl1d=$$vDb4("SYSDEV",TBL,CLN)
	;
	; if value specified in dictionary, return it
	I '($P(dbtbl1d,$C(124),17)="") S vret=$P(dbtbl1d,$C(124),17) Q vret
	;
	; need to derive ...
	;if %VersionID.get()>6.4 quit 0  // Version 7.0 and up: NULL = 0
	I '($P(dbtbl1d,$C(124),18)="") Q 0 ; subfield, so not a masterfield
	N nod S nod=$P(dbtbl1d,$C(124),1)
	N pos S pos=$P(dbtbl1d,$C(124),21)
	;
	I nod?1.N1"*" Q 0 ; key, so not a masterfield
	I (nod="") Q 0 ; no node (Memo or Blob)
	I (pos="") Q 0 ; no position (???)
	;
	N count S count=-1
	;
	I $get(commands("boot","restrictionlevel"))>0 D
	.	S count=0
	.	N rs,vos1,vos2,vos3,vos4 S rs=$$vOpen8()
	.	F  Q:'($$vFetch8())  I $P(rs,$C(9),1)=nod,$P(rs,$C(9),2)=pos S count=count+1
	.	Q 
	I count>-1 Q (count>1)
	;
	N col1 N col2
	S col1=$$nextSubfield(TBL,nod,pos,"")
	S col2=$$nextSubfield(TBL,nod,pos,CLN)
	;
	I col1'=CLN Q 1 ; Masterfield if CLN is not the first
	I col2'="" Q 1 ; Masterfield if CLN is not the last
	;
	Q 0 ; CLN is fist and last, a.k.a. the only
	;
	; ---------------------------------------------------------------------
isOneNode(tblDes)	; table descriptor
	N td S td=$$tAssert(tblDes,1)
	;
	I $P(td,"|",4)=1,'($P(td,"|",5)["M"),'($P(td,"|",5)["B") Q 1
	Q 0
	;
isParent(tblDes)	; table descriptor
	N vret
	;
	N rs,vos1,vos2,vos3  N V1 S V1=$P(tblDes,"|",1) S rs=$$vOpen9()
	;
	S vret=''$G(vos1) Q vret
	;
	; ---------------------------------------------------------------------
isTable(TBL)	; table name
	Q ($D(^DBTBL("SYSDEV",1,TBL)))
	;
	; ---------------------------------------------------------------------
lvpm(recInst,pur,lvpm)	;
	N vret
	;
	I pur="" S pur="0*"
	;
	I ($D(lvpm(pur))#2) Q lvpm(pur)
	;
	I (recInst=+recInst) Q $$lvpm^UCREC4OP(recInst,pur,1)
	;
	I pur="0*" S vret="vobj"_"("_recInst_")" Q vret
	I pur?1.N1"*" Q $$lvpm(recInst,-2-+pur)
	;
	S vret="vobj"_"("_recInst_","_pur_")" Q vret
	;
	; ---------------------------------------------------------------------
mpPslCln(colDes,property)	;
	I property="column" Q $P(colDes,"|",2)
	I property="computation" Q $P(colDes,"|",14)
	I property="dataType" Q $P(colDes,"|",6)
	I property="delimiter" Q $P(colDes,"|",5)
	I property="internalColumn" Q $P(colDes,"|",17)
	I property="internalTable" Q $P(colDes,"|",16)
	I property="isNullToZero" Q $P(colDes,"|",9)
	I property="length" Q $P(colDes,"|",7)
	I property="masterfieldType" Q $P(colDes,"|",15)
	I property="node" Q $P(colDes,"|",3)
	I property="position" Q $P(colDes,"|",4)
	I property="precision" Q $P(colDes,"|",8)
	I property="subfieldMajor" Q $P(colDes,"|",11)
	I property="subfieldMinor" Q $P(colDes,"|",12)
	I property="subfieldPosition" Q $P(colDes,"|",13)
	I property="subfieldTag" Q $P(colDes,"|",10)
	I property="table" Q $P(colDes,"|",1)
	;
	S $ZS="-1,"_$ZPOS_","_"%PSL-E-INVALIDPROP,"_property X $ZT
	Q 
	;
	; ---------------------------------------------------------------------
mpPslTbl(tabDes,property)	;
	I property="columnDelimiter" Q $P(tabDes,"|",10)
	I property="database" Q $P(tabDes,"|",8)
	I property="dataTypes" Q $P(tabDes,"|",5)
	I property="existsNode" Q $P(tabDes,"|",12)
	I property="filerPGM" Q $P(tabDes,"|",6)
	I property="global" Q $P(tabDes,"|",2)
	I property="hasBlob" Q ($P(tabDes,"|",5)["B")
	I property="hasComputed" Q $P(tabDes,"|",11)
	I property="hasMasterfield" Q '($P(tabDes,"|",14)="")
	I property="hasMemo" Q ($P(tabDes,"|",5)["M")
	I property="indexList" Q $P(tabDes,"|",13)
	I property="internalNames" Q $P(tabDes,"|",9)
	I property="isRdb" Q ($P(tabDes,"|",8)'="GTM")
	I property="masterfieldList" Q $P(tabDes,"|",14)
	I property="primaryKeys" Q $P(tabDes,"|",3)
	I property="parentTable" Q $P(tabDes,"|",7)
	I property="recordType" Q $P(tabDes,"|",4)
	I property="table" Q $P(tabDes,"|",1)
	;
	S $ZS="-1,"_$ZPOS_","_"%PSL-E-INVALIDPROP,"_property X $ZT
	Q 
	;
	; ---------------------------------------------------------------------
rtCurExpr(TBL,CLN,recInst,bLeft,tblDes,clnDes)	;
	N prop S prop=TBL_"."_CLN
	I '($D(clnDes(prop))#2) S clnDes(prop)=$$getPslCln(TBL,CLN,.tblDes)
	I '($D(tblDes(TBL))#2) S tblDes(TBL)=$$getPslTbl(TBL,0)
	;
	Q $$getCurExpr(clnDes(prop),recInst,bLeft)
	;
	; ---------------------------------------------------------------------
rtCurLvn(TBL,CLN,recInst,tblDes,clnDes)	;
	N prop S prop=TBL_"."_CLN
	I '($D(clnDes(prop))#2) S clnDes(prop)=$$getPslCln(TBL,CLN,.tblDes)
	I '($D(tblDes(TBL))#2) S tblDes(TBL)=$$getPslTbl(TBL,0)
	;
	Q $$getCurLvn(clnDes(prop),recInst)
	;
	; ---------------------------------------------------------------------
rtCurNode(TBL,CLN,bQuoted,tblDes,clnDes)	;
	N prop S prop=TBL_"."_CLN
	I '($D(clnDes(prop))#2) S clnDes(prop)=$$getPslCln(TBL,CLN,.tblDes)
	I '($D(tblDes(TBL))#2) S tblDes(TBL)=$$getPslTbl(TBL,0)
	;
	Q $$getCurNode(clnDes(prop),bQuoted)
	;
	; ---------------------------------------------------------------------
rtDbase(table)	; list of tables
	;
	I $get(%DB)="" S %DB=$$SCAU^%TRNLNM("DB") I (%DB="") S %DB="GTM"
	;
	I ($get(table)="") Q %DB
	;
	 N V1 S V1=$piece(table,",") I ($D(^STBL("MTBLS",V1))#2) Q "GTM"
	Q %DB
	;
	; ---------------------------------------------------------------------
rtIsRdb(table)	; list of tables
	;
	Q $$rtDbase($get(table))'="GTM"
	;
	; ---------------------------------------------------------------------
rtLodCode(table,recInst,node,mode,bExists,lvpm)	;
	N td S td=$$getPslTbl(table,0)
	;
	Q $$getLodCode(td,recInst,node,mode,bExists,.lvpm)
	;
	; ---------------------------------------------------------------------
rtOldLvn(TBL,CLN,recInst,tblDes,clnDes)	;
	N prop S prop=TBL_"."_CLN
	I '($D(clnDes(prop))#2) S clnDes(prop)=$$getPslCln(TBL,CLN,.tblDes)
	I '($D(tblDes(TBL))#2) S tblDes(TBL)=$$getPslTbl(TBL,0)
	;
	Q $$getOldLvn(clnDes(prop),recInst)
	;
	; ---------------------------------------------------------------------
rtOldNode(TBL,CLN,bQuoted,tblDes,clnDes)	;
	N prop S prop=TBL_"."_CLN
	I '($D(clnDes(prop))#2) S clnDes(prop)=$$getPslCln(TBL,CLN,.tblDes)
	I '($D(tblDes(TBL))#2) S tblDes(TBL)=$$getPslTbl(TBL,0)
	;
	Q $$getOldNode(clnDes(prop),bQuoted)
	;
	; ---------------------------------------------------------------------
rtUpdCode(TBL,CLN,recInst,value,bAudit,tblDes,clnDes)	;
	N prop S prop=TBL_"."_CLN
	I '($D(clnDes(prop))#2) S clnDes(prop)=$$getPslCln(TBL,CLN,.tblDes)
	I '($D(tblDes(TBL))#2) S tblDes(TBL)=$$getPslTbl(TBL,0)
	;
	Q $$getUpdCode(clnDes(prop),recInst,value,bAudit)
	;
	; ---------------------------------------------------------------------
rtUpdKey(TBL,recInst,tblDes)	;
	I '($D(tblDes(TBL))#2) S tblDes(TBL)=$$getSchTbl(TBL)
	;
	Q $$getUpdKey(tblDes(TBL),recInst)
	;
	; ---------------------------------------------------------------------
nextSubfield(tbl,nod,pos,cln)	;
	;  #ACCEPT CR=15028;DATE=2005-03-14;PGM=FSCW
	Q $order(^DBINDX("SYSDEV","STR",tbl,nod,pos,cln))
	;
	; ---------------------------------------------------------------------
nodIsBM(nod)	;
	Q ($E(nod,1)="*")!(nod?.E1",1")
	;
	; ---------------------------------------------------------------------
nodIsKey(nod)	;
	Q (nod<0)!((nod?1.N1"*")&(nod'="0*"))
	;
	; ---------------------------------------------------------------------
nodIsNeg(nod)	;
	Q nod?1"""v"1.N1""""
	;
	; ---------------------------------------------------------------------
nodIsTop(nod)	;
	Q nod="0*"!(nod="")
	;
	; ---------------------------------------------------------------------
parseCmp(expr,tree)	;
	;
	N atom ; parser atom
	N getval S getval="" ; return value
	N lit ; tokenized literals
	N nr S nr=0 ; token number
	N ptr S ptr=0 ; char ptr
	N skwd ; system keyword value
	;
	S expr=$$TOKEN^%ZS(expr,.lit)
	;
	F  D  Q:ptr=0 
	.	;
	.	S atom=$$ATOM^%ZS(expr,.ptr,"[]+-*/\#_'=><\*(),!&:?",,1)
	.	;
	.	I atom="[",$E(expr,ptr+1)?1A,$F(expr,"]",ptr) D
	..		;
	..		; Fill atom with table name
	..		S atom=$E(expr,ptr+1,$F(expr,"]",ptr)-2)
	..		;
	..		I $translate(atom,"_","0")'?1A.AN S atom="[" Q 
	..		S ptr=ptr+$L(atom)+1
	..		S atom=atom_"."_$$ATOM^%ZS(expr,.ptr,"[]+-*/\#_'=><\*(),!&:?",,1)
	..		Q 
	.	;
	.	I atom="?" D  Q 
	..		N origptr S origptr=ptr
	..		N z
	..		F ptr=ptr+1:1 Q:ptr>$L(expr)  S z=$E(expr,ptr) Q:'(z?1N!(z=".")!(z?1A)!($ascii(z)=0)) 
	..		S ptr=ptr-1
	..		S getval=getval_$E(expr,origptr,ptr)
	..		Q 
	.	I "[]+-*/\#_'=><\*(),!&:?"[atom S getval=getval_atom Q 
	.	I $E(atom,1)="%" S skwd=$$getSysKwd^UCDTAUTL(atom) I '(skwd="") S getval=getval_skwd Q 
	.	;
	.	I $ascii(atom)=0 S getval=getval_$$UNTOK^%ZS(atom,lit) Q 
	.	I $E(atom,1)="$" S getval=getval_atom Q 
	.	I $$isNum^UCGM(atom) S getval=getval_atom Q 
	.	;
	.	S nr=nr+1 S tree(nr)=getval
	.	S nr=nr+1 S tree(nr)=$$vStrUC(atom)
	.	S getval=""
	.	Q 
	S nr=nr+1 S tree(nr)=getval
	Q 
	;
	; ---------------------------------------------------------------------
stripQuotes(ident,literals)	;
	I $E(ident,1)=$char(1) S ident=$$UNTOK^%ZS(ident,literals)
	I $E(ident,1)="""" Q $piece(ident,"""",2)
	Q ident
	;
	; ---------------------------------------------------------------------
sub2cln(sublist)	; subscript list
	N cln
	N clnlist S clnlist=""
	N sub
	;
	S sublist=$$TOKEN^%ZS(sublist)
	F sub=1:1:$L(sublist,",") D
	.	S cln=$piece(sublist,",",sub)
	.	I cln=+cln Q  ; skip numlit
	.	I cln[$char(0) Q  ; skip strlit
	.	I (clnlist="") S clnlist=cln Q 
	.	S clnlist=clnlist_","_cln
	.	Q 
	Q clnlist
	;
	; ---------------------------------------------------------------------
tAssert(tabDes,LVL,clnDes)	;
	 ; "size" of PSLTable
	 ; PSLTable.hasComputed
	 ; SchemaTable.count
	;
	N intDes S intDes=tabDes
	I ((LVL>0)&($piece(intDes,"|",11)=""))!((LVL>1)&($piece(intDes,"|",29)="")) D
	.	;
	.	N cln ; column name
	.	N cmp S cmp=0 ; hasComputed?
	.	N count S count=0 ; column count
	.	N def ; default value
	.	N dfl S dfl="" ; defaultList
	.	N ixl S ixl="" ; indexList
	.	N key ; ORDERBY iterator
	.	N mfl S mfl="" ; masterfieldList
	.	N nod ; node
	.	N nodes ; array of nodes
	.	N ndl S ndl="" ; nodeList
	.	N req ; isRequired?
	.	N rql S rql="" ; requiredList
	.	N ordby ; DBTBL8.ORDERBY
	.	N types S types="" ; dataTypes
	.	N table S table=$P(tabDes,"|",1)
	.	;
	.	N rs1d,vos1,vos2,vos3,vos4  N V1 S V1=table S rs1d=$$vOpen10()
	.	;
	.	N tdc ; local "cache" for calls ...
	.	S tdc(table)=tabDes ; ... to $$getPslCln()
	.	F  Q:'($$vFetch10())  D
	..		N rec S rec=rs1d
	..		;
	..		; Don't include literal keys
	..		I $$vStrIsNum($P(rec,$C(9),1)) Q 
	..		I $E($P(rec,$C(9),1),1)="""" Q 
	..		;
	..		S count=count+1
	..		S cln=$P(rec,$C(9),1)
	..		;
	..		I '(types[$P(rec,$C(9),2)) S types=types_$P(rec,$C(9),2)
	..		;
	..		I $$isSfdMaster(table,cln,$P(rec,$C(9),4)) S mfl=$S((mfl=""):cln,1:mfl_","_cln)
	..		;
	..		I cmp=0,'($P(rec,$C(9),3)=""),$P(rec,$C(9),2)'="M" S cmp=1
	..		;
	..		N ref S ref=table_"."_cln
	..		S clnDes(ref)=$$getPslCln(table,cln,.tdc)
	..		S nod=$$getPurNode^UCXDD(clnDes(ref))
	..		;
	..		I +nod'<0,nod'?1.N1"*" S nodes(nod)=""
	..		;
	..		S req=''$P(rec,$C(9),5)
	..		S def=$P(rec,$C(9),6)
	..		;
	..		I req S rql=$S((rql=""):cln,1:rql_","_cln)
	..		I '(def="") S dfl=$S((dfl=""):cln,1:dfl_","_cln)
	..		Q 
	.	;
	.	S nod=-1
	.	F  S nod=$order(nodes(nod)) Q:nod=""  S ndl=ndl_","_nod
	.	;
	.	N rs8,vos5,vos6,vos7,vos8  N V2 S V2=table S rs8=$$vOpen11()
	.	F  Q:'($$vFetch11())  D
	..		S ordby=$$TOKEN^%ZS(rs8)
	..		F key=1:1:$L(ordby,",") D
	...			S cln=$piece(ordby,",",key)
	...			I cln=+cln Q  ; skip numlit
	...			I cln[$char(0) Q  ; skip strlit
	...			I ((","_ixl_",")[(","_cln_",")) Q  ; duplicate
	...			S ixl=$S((ixl=""):cln,1:ixl_","_cln)
	...			Q 
	..		Q 
	.	;
	.	S $piece(intDes,"|",5)=types
	.	S $piece(intDes,"|",11)=cmp
	.	S $piece(intDes,"|",13)=ixl
	.	S $piece(intDes,"|",14)=mfl
	.	S $piece(intDes,"|",15)=$E(ndl,2,1048575)
	.	;
	.	I LVL>1,$L(intDes,"|")>16 D
	..		S $piece(intDes,"|",28)=count
	..		S $piece(intDes,"|",29)=dfl
	..		S $piece(intDes,"|",30)=rql
	..		Q 
	.	S tabDes=intDes
	.	Q 
	;
	Q tabDes
	;
	; ---------------------------------------------------------------------
toValMod(typ,nul)	;
	Q $S("BFMTU"[typ:0,typ="L"!nul:2,1:1)
	;
vSIG()	;
	Q "60754^20135^Frans S.C. Witte^152601" ; Signature - LTD^TIME^USER^SIZE
	; ----------------
	;  #OPTION ResultClass 0
vBtsPslE(vVal)	; ByteString.toPSLExpression
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N bValid S bValid=0
	D
	.	N $ZT S $ZT="D ZX^UCGMR("_+$O(vobj(""),-1)_","_$ZL_",""vtrap2^"_$T(+0)_""")"  ; catch and ignore %GTM-E-BADCHAR exception
	.	S bValid=(vVal)?.ANP
	.	Q 
	I bValid,$$vStrIsNum((vVal)) Q vVal
	I bValid Q $$QADD^%ZS((vVal),"""")
	N vC
	N vE S vE="$C("_$ascii(vVal)
	F vC=2:1:$L(vVal) S vE=vE_","_$ascii(vVal,vC)
	Q vE_")"
	; ----------------
	;  #OPTION ResultClass 0
vStrUC(vObj)	; String.upperCase
	;
	;  #OPTIMIZE FUNCTIONS OFF
	Q $translate(vObj,"abcdefghijklmnopqrstuvwxyz±≥µ∂π∫ªºæø‡·‚„‰ÂÊÁËÈÍÎÏÌÓÔÒÚÛÙıˆ¯˘˙˚¸˝˛","ABCDEFGHIJKLMNOPQRSTUVWXYZ°£•¶©™´¨ÆØ¿¡¬√ƒ≈∆«»… ÀÃÕŒœ–—“”‘’÷ÿŸ⁄€‹›ﬁ")
	;
vDb4(v1,v2,v3)	;	voXN = Db.getRecord(DBTBL1D,,0)
	;
	N dbtbl1d
	S dbtbl1d=$G(^DBTBL(v1,1,v2,9,v3))
	I dbtbl1d="",'$D(^DBTBL(v1,1,v2,9,v3))
	I $T S $ZS="-1,"_$ZPOS_",%PSL-E-RECNOFL,,DBTBL1D" X $ZT
	Q dbtbl1d
	;
vDb5(v1,v2)	;	voXN = Db.getRecord(DBTBL1,,0)
	;
	N rec
	S rec=$G(^DBTBL(v1,1,v2))
	I rec="",'$D(^DBTBL(v1,1,v2))
	I $T S $ZS="-1,"_$ZPOS_",%PSL-E-RECNOFL,,DBTBL1" X $ZT
	Q rec
	;
vDb6(v1,v2,v3,v2out)	;	voXN = Db.getRecord(DBTBL1D,,1,-2)
	;
	N dbtbl1d
	S dbtbl1d=$G(^DBTBL(v1,1,v2,9,v3))
	I dbtbl1d="",'$D(^DBTBL(v1,1,v2,9,v3))
	S v2out='$T
	;
	Q dbtbl1d
	;
vDbEx1()	;	min(1): DISTINCT %LIBS,FID,FKEYS FROM DBTBL1F WHERE FID=:V1
	;
	N vsql2,vsql3
	;
	S vsql2=""
vEx1a3	S vsql2=$O(^DBTBL(vsql2),1) I vsql2="" Q 0
	S vsql3=""
	S vsql3=$O(^DBTBL(vsql2,19,V1,vsql3),1) I vsql3="" G vEx1a3
	Q 1
	;
vDbEx2()	;	min(1): DISTINCT %LIBS,PRITABLE,JRNID FROM DBTBL9 WHERE %LIBS='SYSDEV' and PRITABLE=:V1 and MODE like '%I%'
	;
	N vsql2,vsql3
	;
	S vsql2=""
vEx2a3	S vsql2=$O(^DBTBL("SYSDEV",9,V1,vsql2),1) I vsql2="" Q 0
	S vsql3=$G(^DBTBL("SYSDEV",9,V1,vsql2))
	I '($P(vsql3,"|",5)["I") G vEx2a3
	Q 1
	;
vDbEx3()	;	min(1): DISTINCT %LIBS,PRITABLE,JRNID FROM DBTBL9 WHERE %LIBS='SYSDEV' and PRITABLE=:V2 and MODE like '%U%'
	;
	N vsql2,vsql3
	;
	S vsql2=""
vEx3a3	S vsql2=$O(^DBTBL("SYSDEV",9,V2,vsql2),1) I vsql2="" Q 0
	S vsql3=$G(^DBTBL("SYSDEV",9,V2,vsql2))
	I '($P(vsql3,"|",5)["U") G vEx3a3
	Q 1
	;
vDbEx4()	;	min(1): DISTINCT %LIBS,PRITABLE,JRNID FROM DBTBL9 WHERE %LIBS='SYSDEV' and PRITABLE=:V3 and MODE like '%D%'
	;
	N vsql2,vsql3
	;
	S vsql2=""
vEx4a3	S vsql2=$O(^DBTBL("SYSDEV",9,V3,vsql2),1) I vsql2="" Q 0
	S vsql3=$G(^DBTBL("SYSDEV",9,V3,vsql2))
	I '($P(vsql3,"|",5)["D") G vEx4a3
	Q 1
	;
vDbEx5()	;	min(1): DISTINCT %LIBS,FID,FKEYS FROM DBTBL1F WHERE TBLREF=:V1
	;
	N vsql2,vsql3,vsql4
	;
	S vsql2=""
vEx5a3	S vsql2=$O(^DBINDX(vsql2),1) I vsql2="" Q 0
	S vsql3=""
vEx5a5	S vsql3=$O(^DBINDX(vsql2,"FKPTR",V1,vsql3),1) I vsql3="" G vEx5a3
	S vsql4=""
	S vsql4=$O(^DBINDX(vsql2,"FKPTR",V1,vsql3,vsql4),1) I vsql4="" G vEx5a5
	Q 1
	;
vOpen1()	;	DI FROM DBTBL1D WHERE %LIBS='SYSDEV' AND FID=:V1 AND DI<>:V2 AND NOD=:N AND POS=:P
	;
	;
	S vos1=2
	D vL1a1
	Q ""
	;
vL1a0	S vos1=0 Q
vL1a1	S vos2=$G(V1) I vos2="" G vL1a0
	S vos3=$G(V2) I vos3="",'$D(V2) G vL1a0
	S vos4=$G(N) I vos4="",'$D(N) G vL1a0
	S vos5=$G(P) I vos5="",'$D(P) G vL1a0
	S vos6=""
vL1a6	S vos6=$O(^DBINDX("SYSDEV","STR",vos2,vos4,vos5,vos6),1) I vos6="" G vL1a0
	I '(vos6'=vos3) G vL1a6
	Q
	;
vFetch1()	;
	;
	;
	I vos1=1 D vL1a6
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S rs=$S(vos6=$C(254):"",1:vos6)
	;
	Q 1
	;
vOpen10()	;	DI,TYP,CMP,ISMASTER,REQ,DFT FROM DBTBL1D WHERE %LIBS='SYSDEV' AND FID=:V1
	;
	;
	S vos1=2
	D vL10a1
	Q ""
	;
vL10a0	S vos1=0 Q
vL10a1	S vos2=$G(V1) I vos2="" G vL10a0
	S vos3=""
vL10a3	S vos3=$O(^DBTBL("SYSDEV",1,vos2,9,vos3),1) I vos3="" G vL10a0
	Q
	;
vFetch10()	;
	;
	I vos1=1 D vL10a3
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S vos4=$G(^DBTBL("SYSDEV",1,vos2,9,vos3))
	S rs1d=$S(vos3=$C(254):"",1:vos3)_$C(9)_$P(vos4,"|",9)_$C(9)_$P(vos4,"|",16)_$C(9)_$P(vos4,"|",17)_$C(9)_$P(vos4,"|",15)_$C(9)_$P(vos4,"|",3)
	;
	Q 1
	;
vOpen11()	;	ORDERBY FROM DBTBL8 WHERE %LIBS='SYSDEV' AND FID=:V2
	;
	;
	S vos5=2
	D vL11a1
	Q ""
	;
vL11a0	S vos5=0 Q
vL11a1	S vos6=$G(V2) I vos6="" G vL11a0
	S vos7=""
vL11a3	S vos7=$O(^DBTBL("SYSDEV",8,vos6,vos7),1) I vos7="" G vL11a0
	Q
	;
vFetch11()	;
	;
	I vos5=1 D vL11a3
	I vos5=2 S vos5=1
	;
	I vos5=0 Q 0
	;
	S vos8=$G(^DBTBL("SYSDEV",8,vos6,vos7))
	S rs8=$P(vos8,"|",3)
	;
	Q 1
	;
vOpen2()	;	DI FROM DBTBL1D WHERE %LIBS='SYSDEV' AND FID=:V1
	;
	;
	S vos1=2
	D vL2a1
	Q ""
	;
vL2a0	S vos1=0 Q
vL2a1	S vos2=$G(V1) I vos2="" G vL2a0
	S vos3=""
vL2a3	S vos3=$O(^DBTBL("SYSDEV",1,vos2,9,vos3),1) I vos3="" G vL2a0
	Q
	;
vFetch2()	;
	;
	;
	I vos1=1 D vL2a3
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S rs=$S(vos3=$C(254):"",1:vos3)
	;
	Q 1
	;
vOpen3()	;	ACTBI,ACTAI,ACTBU,ACTAU,ACTBD,ACTAD FROM DBTBL7 WHERE %LIBS='SYSDEV' AND TABLE=:V1
	;
	;
	S vos1=2
	D vL3a1
	Q ""
	;
vL3a0	S vos1=0 Q
vL3a1	S vos2=$G(V1) I vos2="" G vL3a0
	S vos3=""
vL3a3	S vos3=$O(^DBTBL("SYSDEV",7,vos2,vos3),1) I vos3="" G vL3a0
	Q
	;
vFetch3()	;
	;
	I vos1=1 D vL3a3
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S vos4=$G(^DBTBL("SYSDEV",7,vos2,vos3))
	S rs7=$P(vos4,"|",2)_$C(9)_$P(vos4,"|",5)_$C(9)_$P(vos4,"|",3)_$C(9)_$P(vos4,"|",6)_$C(9)_$P(vos4,"|",4)_$C(9)_$P(vos4,"|",7)
	;
	Q 1
	;
vOpen4()	;	FID FROM DBTBL1F WHERE %LIBS='SYSDEV' AND TBLREF=:V1
	;
	;
	S vos5=2
	D vL4a1
	Q ""
	;
vL4a0	S vos5=0 Q
vL4a1	S vos6=$G(V1) I vos6="",'$D(V1) G vL4a0
	S vos7=""
vL4a3	S vos7=$O(^DBINDX("SYSDEV","FKPTR",vos6,vos7),1) I vos7="" G vL4a0
	S vos8=""
vL4a5	S vos8=$O(^DBINDX("SYSDEV","FKPTR",vos6,vos7,vos8),1) I vos8="" G vL4a3
	Q
	;
vFetch4()	;
	;
	;
	I vos5=1 D vL4a5
	I vos5=2 S vos5=1
	;
	I vos5=0 Q 0
	;
	S rsCasc=$S(vos7=$C(254):"",1:vos7)
	;
	Q 1
	;
vOpen5()	;	FID FROM DBTBL1 WHERE %LIBS='SYSDEV' AND PARFID=:V1
	;
	;
	S vos1=2
	D vL5a1
	Q ""
	;
vL5a0	S vos1=0 Q
vL5a1	S vos2=$G(V1) I vos2="",'$D(V1) G vL5a0
	S vos3=""
vL5a3	S vos3=$O(^DBINDX("SYSDEV","PARFID",vos2,vos3),1) I vos3="" G vL5a0
	Q
	;
vFetch5()	;
	;
	;
	I vos1=1 D vL5a3
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S rs=$S(vos3=$C(254):"",1:vos3)
	;
	Q 1
	;
vOpen6()	;	DI,SFT,SFD1,SFD2,SFP FROM DBTBL1D WHERE %LIBS='SYSDEV' AND FID=:TBL AND DI<>:CLN AND NOD=:N AND POS=:P ORDER BY SFT,POS
	;
	S vOid=$G(^DBTMP($J))-1,^($J)=vOid K ^DBTMP($J,vOid)
	S vos1=2
	D vL6a1
	Q ""
	;
vL6a0	S vos1=0 Q
vL6a1	S vos2=$G(TBL) I vos2="" G vL6a0
	S vos3=$G(CLN) I vos3="",'$D(CLN) G vL6a0
	S vos4=$G(N) I vos4="",'$D(N) G vL6a0
	S vos5=$G(P) I vos5="",'$D(P) G vL6a0
	S vos6=""
vL6a6	S vos6=$O(^DBINDX("SYSDEV","STR",vos2,vos4,vos5,vos6),1) I vos6="" G vL6a12
	I '(vos6'=vos3) G vL6a6
	S vos7=$G(^DBTBL("SYSDEV",1,vos2,9,vos6))
	S vd=$S(vos6=$C(254):"",1:vos6)_$C(9)_$$GET^USUB($P(vos7,"|",18),"","~","",1)_$C(9)_$$GET^USUB($P(vos7,"|",18),"","~","",2)_$C(9)_$$GET^USUB($P(vos7,"|",18),"","~","",3)_$C(9)_$$GET^USUB($P(vos7,"|",18),"","~","",4)
	S vos8=$$GET^USUB($P(vos7,"|",18),"","~","",1) S:vos8="" vos8=$$BYTECHAR^SQLUTL(254) S ^DBTMP($J,vOid,1,vos8,vos6)=vd
	G vL6a6
vL6a12	S vos2=""
vL6a13	S vos2=$O(^DBTMP($J,vOid,1,vos2),1) I vos2="" G vL6a0
	S vos3=""
vL6a15	S vos3=$O(^DBTMP($J,vOid,1,vos2,vos3),1) I vos3="" G vL6a13
	Q
	;
vFetch6()	;
	;
	;
	I vos1=1 D vL6a15
	I vos1=2 S vos1=1
	;
	I vos1=0 K ^DBTMP($J,vOid) Q 0
	;
	S rs=^DBTMP($J,vOid,1,vos2,vos3)
	;
	Q 1
	;
vOpen7()	;	DI FROM DBTBL1D WHERE %LIBS='SYSDEV' AND FID=:TBL AND NOD=:N AND POS=:P AND SFT IS NULL AND SFP IS NULL
	;
	;
	S vos1=2
	D vL7a1
	Q ""
	;
vL7a0	S vos1=0 Q
vL7a1	S vos2=$G(TBL) I vos2="" G vL7a0
	S vos3=$G(N) I vos3="",'$D(N) G vL7a0
	S vos4=$G(P) I vos4="",'$D(P) G vL7a0
	S vos5=""
vL7a5	S vos5=$O(^DBINDX("SYSDEV","STR",vos2,vos3,vos4,vos5),1) I vos5="" G vL7a0
	S vos6=$G(^DBTBL("SYSDEV",1,vos2,9,vos5))
	I '($$GET^USUB($P(vos6,"|",18),"","~","",1)="") G vL7a5
	I '($$GET^USUB($P(vos6,"|",18),"","~","",4)="") G vL7a5
	Q
	;
vFetch7()	;
	;
	;
	I vos1=1 D vL7a5
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S rs=$S(vos5=$C(254):"",1:vos5)
	;
	Q 1
	;
vOpen8()	;	NOD,POS FROM DBTBL1D WHERE %LIBS='SYSDEV' AND FID=:TBL
	;
	;
	S vos1=2
	D vL8a1
	Q ""
	;
vL8a0	S vos1=0 Q
vL8a1	S vos2=$G(TBL) I vos2="" G vL8a0
	S vos3=""
vL8a3	S vos3=$O(^DBTBL("SYSDEV",1,vos2,9,vos3),1) I vos3="" G vL8a0
	Q
	;
vFetch8()	;
	;
	I vos1=1 D vL8a3
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S vos4=$G(^DBTBL("SYSDEV",1,vos2,9,vos3))
	S rs=$P(vos4,"|",1)_$C(9)_$P(vos4,"|",21)
	;
	Q 1
	;
vOpen9()	;	FID FROM DBTBL1 WHERE %LIBS='SYSDEV' AND PARFID=:V1
	;
	;
	S vos1=2
	D vL9a1
	Q ""
	;
vL9a0	S vos1=0 Q
vL9a1	S vos2=$G(V1) I vos2="",'$D(V1) G vL9a0
	S vos3=""
vL9a3	S vos3=$O(^DBINDX("SYSDEV","PARFID",vos2,vos3),1) I vos3="" G vL9a0
	Q
	;
vFetch9()	;
	;
	;
	I vos1=1 D vL9a3
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S rs=$S(vos3=$C(254):"",1:vos3)
	;
	Q 1
	;
vStrIsNum(vStr)	;	String.isNumber
	;
	Q vStr=+vStr
	;
vtrap1	;	Error trap
	;
	N crspEx S crspEx=$ZS
	D WARN^UCGM("CREATESP failed due to "_$P(crspEx,",",4))
	;
	S where=$$getWhrKey(tblDes,recInst,2,.lvpm,.hostexpr)
	I '(where="") S sqlstm=sqlstm_" WHERE "_where
	I (hostexpr="") S hostexpr=""""""
	;
	S dbref="(0,"""_sqlstm_""",$C("_$P(tblDes,"|",10)_"),"_hostexpr
	;
	I bNotFound S dbref=" S vEr=$$SELECT^%DBAPI"_dbref_",.vData,.vRm),"_$$lvpm(recInst,node,.lvpm)_"=vData I vEr<0 S $ZS=""-1,""_$ZPOS_"",%PSL-E-SQLFAIL,""_$TR($G(vRm),$C(10,44),$C(32,126)) X $ZT"
	E  S dbref="$$wrSELECT^UCDBRT"_dbref_")"
	Q 
	;
vtrap2	;	Error trap
	;
	N vEx S vEx=$ZS
	Q 
