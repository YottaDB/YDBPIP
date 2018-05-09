 ; 
 ; **** Routine compiled from DATA-QWIK Procedure UCXDD ****
 ; 
 ; 02/24/2010 18:23 - pip
 ; 
 ;  #PACKAGE framework
 ;  #OPTION ResultClass ON
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
addRdbPos(rdbPos,clnDes) ; column descriptor
 ;
 I $$nodIsKey($P(clnDes,"|",3)) S rdbPos($P(clnDes,"|",18))=clnDes Q 
 I $P(clnDes,"|",15)<2 S rdbPos($P(clnDes,"|",4))=clnDes Q 
 ;
 N dbtbl1d S dbtbl1d=$G(^DBTBL("SYSDEV",1,$P(clnDes,"|",1),9,$P(clnDes,"|",2)))
 N N S N=$P(dbtbl1d,$C(124),1)
 N P S P=$P(dbtbl1d,$C(124),21)
 N rs,vos1,vos2,vos3,vos4,vos5,vos6,vos7  N V1,V2 S V1=$P(clnDes,"|",1),V2=$P(clnDes,"|",2) S rs=$$vOpen1()
 F  Q:'$$vFetch1()  D
 . S clnDes=$$getPslCln($P(clnDes,"|",1),rs)
 .	S rdbPos($P(clnDes,"|",4))=clnDes
 .	Q 
 Q 
 ;
 ; ---------------------------------------------------------------------
caPslCln(cache,PROP,tdc) ; 
 I '($D(cache(PROP))#2) S cache(PROP)=$$getPslCln($piece(PROP,"."),$piece(PROP,".",2),.tdc)
 Q cache(PROP)
 ;
 ; ---------------------------------------------------------------------
caPslTbl(cache,TBL,LVL,cdc) ; PSLColumn cache
 I '($D(cache(TBL))#2) S cache(TBL)=$$getPslTbl(TBL,$get(LVL),.cdc)
 E  I $get(LVL)>0 S cache(TBL)=$$tAssert(cache(TBL),LVL,.cdc)
 Q cache(TBL)
 ;
 ; ---------------------------------------------------------------------
cdNodChg(recInst,node) ; 
 N vret
 ;
 S vret="vobj"_"("_recInst_",-100,"_node_")" Q vret
 ;
 ; ---------------------------------------------------------------------
cdOldLvn(recInst,node,column) ; 
 N vret
 ;
 S vret="vobj"_"("_recInst_",-100,"_node_","_column_")" Q vret
 ;
 ; ---------------------------------------------------------------------
cdRdbAsn(recInst,intCln,nod,pos,dlmStr,getval,mod,RdbCodeForm,isFirst) ; First call (*9)
 ;
 N isUpd S isUpd=(RdbCodeForm<4)
 N isFunc S isFunc=(RdbCodeForm#2=1)
 N noOverlay S noOverlay=(",2,3,6,7,"[(","_RdbCodeForm_","))
 ;
 N cdRdbAsn
 ;
 ; Modify value based on mod
 I (mod=1) S getval="$S("_getval_"="""":"""",1:+"_getval_")"
 E  I (mod=2) E  S getval="+("_getval_")"
 ;
 I 'isFunc D
 .	;
 .	N ref161 S ref161="vobj"_"("_recInst_",-161,"_nod_")"
 .	N ref162 S ref162="vobj"_"("_recInst_",-162,"_nod_")"
 .	;
 .	I isFirst S cdRdbAsn=" N vCc"
 .	E  S cdRdbAsn=""
 .	;
 .	S cdRdbAsn=cdRdbAsn_" S vCc=+"_ref161
 .	;
 .	I 'noOverlay D
 ..		;
 ..		S cdRdbAsn=cdRdbAsn_" S:"_ref161_"["","_intCln_"="" $P("_ref162_","_dlmStr
 ..		I isUpd S cdRdbAsn=cdRdbAsn_",$P("_ref161_","","_intCln_"=:HV"",2)+1)"
 ..		E  S cdRdbAsn=cdRdbAsn_",$L($P("_ref161_","","_intCln_"=""),"","")+1)"
 ..		S cdRdbAsn=cdRdbAsn_"="_getval_",vCc=0"
 ..		S cdRdbAsn=cdRdbAsn_" S:vCc "
 ..		Q 
 .	E  S cdRdbAsn=cdRdbAsn_","
 .	;
 .	S cdRdbAsn=cdRdbAsn_ref161_"="_ref161_"_"","_intCln_"="
 .	I isUpd S cdRdbAsn=cdRdbAsn_":HV""_vCc"
 .	E  S cdRdbAsn=cdRdbAsn_""""
 .	S cdRdbAsn=cdRdbAsn_","_ref162_"="_ref162_"_"_dlmStr_"_"_getval_",$P("_ref161_","","",1)=vCc+1"
 .	Q 
 E  D
 .	;
 .	S cdRdbAsn=" N vX S vX=$$rdbColUpd^UCDBRT("_noOverlay_","_recInst_","_$S(intCln'["""":""""_intCln_"""",1:$$QADD^%ZS(intCln,""""))_","_nod_","_dlmStr_","_getval_")"
 .	;
 .	I 'isUpd S cdRdbAsn=$$vStrRep(cdRdbAsn,"$$rdbColUpd","$$rdbColIns",0,0,"")
 .	Q 
 ;
 Q cdRdbAsn
 ;
 ; ---------------------------------------------------------------------
checkAccessRights(tblDes,fromTable) ; force checking DBACCRTS
 ;
 N checkList S checkList=""
 ;
 I ($P(tblDes,"|",8)'="GTM") Q "" ; Access rights does not apply
 ;
 ; Does not apply during bootstrap
 I ($$getSetting^PSLCC(.pslPrsr,"boot","restrictionlevel",0)>1) Q ""
 ;
 D
 .	;
 .	N table S table=$P(tblDes,"|",1)
 .	;
 .	N $ET,$ES,$ZYER S $ZYER="ZE^UCGMR",$ZE="",$EC="",$ET="D:$TL>"_$TL_" rollback^vRuntime("_$TL_") Q:$Q&$ES """" Q:$ES  N voxMrk s voxMrk="_+$O(vobj(""),-1)_" G vCatch1^"_$T(+0)
 .	;
 .	I fromTable S $ZE="0,"_$ZPOS_","_"%PSL-E-force",$EC=",U1001," ; Force error
 .	;
 .	;   #ACCEPT DATE=05/15/2008; PGM=Dan Russell; CR=30801; Group=BYPASS
 .	;*** Start of code by-passed by compiler
 .	X "S checkList=$$vcheckAccessRights^Record"_table
 .	;*** End of code by-passed by compiler ***
 .	Q 
 ;
 Q checkList
 ;
 ; ---------------------------------------------------------------------
cmpCurNode(nod,pos,typ,tblDes) ; table descriptor
 I nod?1.N1"*" Q -2-pos
 ;
 I $P(tblDes,"|",4)=1 D
 .	I "BM"'[typ S nod=""
 .	Q 
 E  D
 .	I $P(tblDes,"|",4)=11 D  ; Compare node to bottom key
 ..		N keys S keys=$P(tblDes,"|",3)
 ..		I $piece(keys,",",$L(keys,","))=nod S nod=""
 ..		Q 
 .	I nod<0 S nod="v"_(-nod)
 .	;if 'nod.isLiteral(),'nod.isNull(),bQuoted set nod = """"_ nod_ """"
 .	Q 
 ;
 I "BM"[typ S nod=nod_",1"
 Q nod
 ;
 ; ---------------------------------------------------------------------
getChildren(tblDes) ; table descriptor
 ;
 N children S children=""
 ;
 N rs,vos1,vos2,vos3,vos4  N V1 S V1=$P(tblDes,"|",1) S rs=$$vOpen4()
 ;
 F  Q:'$$vFetch4()  S children=$S((children=""):rs,1:children_","_rs)
 ;
 Q children
 ;
 ; ---------------------------------------------------------------------
getClass(clnDes) ; PSLColumn
 N typ S typ=$P(clnDes,"|",6)
 ;
 I "TUF"[typ Q "String"
 Q $piece(",ByteString,Boolean,Date,Memo,Number,Number,Time",",",$F("BLDMN$C",typ))
 ;
 ; ---------------------------------------------------------------------
getCmp(clnDes,recInst,lvpm) ; loc var pur map /NOREQ/MECH=REFARR:R
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
 ..		I $piece(qcn,".")'=$P(clnDes,"|",1) S $ZE="0,"_$ZPOS_","_"%PSL-E-COMPUTE,,invalid qualified name '"_qcn_"' in "_$P(clnDes,"|",1)_"."_$P(clnDes,"|",2),$EC=",U1001,"
 ..		S qcn=$piece(qcn,".",2)
 ..		Q 
 .	S ccd=$$getPslCln($P(clnDes,"|",1),qcn)
 .	I (recInst=+recInst) D clnByCln^UCREC4OP(recInst,clnDes,ccd)
 .	S getval=getval_pt(elm-1)_$$getCurExpr(ccd,recInst,0,.lvpm)
 .	Q 
 ;
 Q getval_pt(cnt)
 ;
 ; ---------------------------------------------------------------------
getCurExpr(clnDes,recInst,bLeft,lvpm) ; loc var pur map /NOREQ/MECH=REFARR:R
 ;
 ; RDB masterfield assignment and retrieval:
 I $P(clnDes,"|",15)=2,bLeft S $ZE="0,"_$ZPOS_","_"%PSL-E-COMPUTE,,Masterfield has no leftexpr "_$P(clnDes,"|",1)_"."_$P(clnDes,"|",2),$EC=",U1001,"
 I $P(clnDes,"|",15)=2 Q $$getMfRDB^UCCOLSF(clnDes,recInst,.lvpm)
 ;
 ; computed column: return computation
 I '($P(clnDes,"|",14)=""),bLeft S $ZE="0,"_$ZPOS_","_"%PSL-E-COMPUTE,,Cannot modify computed data item "_$P(clnDes,"|",1)_"."_$P(clnDes,"|",2),$EC=",U1001,"
 I '($P(clnDes,"|",14)="") Q $$getCmp(clnDes,recInst,.lvpm)
 ;
 N getval S getval=$$getCurLvn(clnDes,recInst,.lvpm)
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
getCurLvn(clnDes,recInst,lvpm) ; loc var pur map /NOREQ/MECH=REFARR:R
 N vret
 ;
 N nod S nod=$$getCurNode(clnDes,1)
 ;
 I (recInst=+recInst) Q $$lvpm(recInst,$$getPurNode(clnDes),.lvpm)
 ;
 I (nod="") S vret="vobj"_"("_recInst_")" Q vret
 ;
 S vret="vobj"_"("_recInst_","_nod_")" Q vret
 ;
 ; ---------------------------------------------------------------------
getCurNode(clnDes,bQuoted) ; do no add quotes
 I 'bQuoted Q $P(clnDes,"|",18)
 ;
 ; quoted ==> need to manipulate
 N nod S nod=$P(clnDes,"|",18)
 ;
 I "BM"[$P(clnDes,"|",6) S nod=$E(nod,1,$L(nod)-2)
 ;
 I '$$isLit^UCGM(nod),'(nod="") S nod=$S(nod'["""":""""_nod_"""",1:$$QADD^%ZS(nod,""""))
 ;
 I "BM"[$P(clnDes,"|",6) S nod=nod_",1"
 ;
 Q nod
 ;
 ; ---------------------------------------------------------------------
getDataNode(tblDes,recInst,node,bNotFound,lvpm,clnDes) ; PSLColumn cache /NOREQ/MECH=REFARR:RW
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
 .	N intt S intt=$$nod2tbl^DBMAP($P(tblDes,"|",8),$P(tblDes,"|",1),node)
 .	N ord ; columnnames by ordinal position
 .	N pkeys S pkeys=$P(tblDes,"|",3)
 .	N sel S sel="*" ; select list (assume SELECT *)
 .	N k S k=$S(pkeys="":0,1:$S((pkeys=""):0,1:$L(pkeys,",")))
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
 ..		N rs,vos1,vos2,vos3,vos4  N V1 S V1=tbl S rs=$$vOpen5()
 ..		F  Q:'$$vFetch5()  D
 ...   S cd=$$caPslCln(.clnDes,tbl_"."_rs)
 ...			S pos=$P(cd,"|",4)
 ...			I (pos="") Q  ; computed, literal, masterfield, ...
 ...			I $P(cd,"|",6)="B" Q 
 ...			I $P(cd,"|",6)="M" Q 
 ...			S ord(pos)=$P(cd,"|",17)
 ...			Q 
 ..		S sel=ord(1) ; no table starts with B/M
 ..		F pos=2:1:$order(ord(""),-1) S sel=sel_","_$get(ord(pos),"NULL")
 ..  Q 
 .	;
 .	I sel'="*" D  ; RDB with blob or memo
 ..		N where S where=$$getWhrKey(tblDes,recInst,2,.lvpm,.hostexpr)
 ..		N sqlstm S sqlstm="SELECT "_sel_" FROM "_intt_where
 ..		;
 ..		S dbref="(0,"""_sqlstm_""",$C("_$P(tblDes,"|",10)_"),"_hostexpr
 ..		I bNotFound S dbref=" S vEr=$$SELECT^%DBAPI"_dbref_",.vData,.vRm),"_$$lvpm(recInst,node,.lvpm)_"=vData I vEr<0 S $ZE=""0,""_$ZPOS_"",%PSL-E-SQLFAIL,""_$TR($G(vRm),$C(10,44),$C(32,126)),$EC="",U1001,"""
 ..		E  S dbref="$$SELECTDATA^%DBAPI"_dbref_")"
 ..		Q 
 .	E  D  ; RDB without blob or memo
 ..		;
 ..		N crsp
 ..		N sqlstm S sqlstm="SELECT * FROM "_intt
 ..		N where S where=$$getWhrKey(tblDes,recInst,1,.lvpm,.hostexpr,.hostcrsp)
 ..		S crsp("WHERE")=$piece(where," WHERE ",2,$L(where))
 ..		S crsp("SQL")=sqlstm_where
 ..		S crsp("HOSTVARS")=hostcrsp
 ..		;
 ..		D
 ...			N $ET,$ES,$ZYER S $ZYER="ZE^UCGMR",$ZE="",$EC="",$ET="D:$TL>"_$TL_" rollback^vRuntime("_$TL_") Q:$Q&$ES """" Q:$ES  N voxMrk s voxMrk="_+$O(vobj(""),-1)_" G vCatch2^"_$T(+0)  ; $$CREATESP failed, code as SELECT
 ...			;
 ...			N spnam S spnam=$$CREATESP^DBSDBASE(intt,"SelectAll",.crsp,0)
 ...			I (hostexpr="") S hostexpr=""""""
 ...			;
 ...			S dbref="(0,"""_spnam_""","_hostexpr_","_k_",$C("_$P(tblDes,"|",10)_")"
 ...			;
 ...			I bNotFound S dbref=" S vEr=$$EXECSP^%DBAPI"_dbref_",.vData,.vRm),"_$$lvpm(recInst,node,.lvpm)_"=vData I vEr<0 S $ZE=""0,""_$ZPOS_"",%PSL-E-SQLFAIL,""_$TR($G(vRm),$C(10,44),$C(32,126)),$EC="",U1001,"""
 ...			E  S dbref="$$EXECUTESP^%DBAPI"_dbref_")"
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
getDbase(db) ; database vendor or ""
 ;
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 I $get(%DB)="" S %DB=$$SCAU^%TRNLNM("DB") I (%DB="") S %DB="GTM"
 ;
 I (db="") Q %DB
 Q db
 ;
 ; ---------------------------------------------------------------------
getDelimiter(delim) ; delimiter value or empty string
 I (delim="") Q 124
 Q +delim
 ;
 ; ---------------------------------------------------------------------
getExisCode(tblDes,recInst,lvpm) ; keyvar map (*3)  /NOREQ/MECH=REFARR:R
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
 I '(nod="")!($P(tblDes,"|",4)=1) Q " I "_$$lvpm(recInst,nod,.lvpm)_"="""",'($D("_gblref_")#2)"
 I $P(tblDes,"|",4)=11 Q " I "_$$lvpm(recInst,nod,.lvpm)_"="""",'$D("_gblref_")"
 ;
 Q " I '$D("_gblref_")"
 ;
 ; ---------------------------------------------------------------------
getFlrLgc(tblDes,oper,qualExp,isPslExp) ; qualExp PSLExpression or String? (*4)
 N logic N qual
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
 I '(("/"_qual_"/")["/NOUCLREGEN/") D
 .	N $ET,$ES,$ZYER S $ZYER="ZE^UCGMR",$ZE="",$EC="",$ET="D:$TL>"_$TL_" rollback^vRuntime("_$TL_") Q:$Q&$ES """" Q:$ES  N voxMrk s voxMrk="_+$O(vobj(""),-1)_" G vCatch3^"_$T(+0)
 .	N call S call="$$vhasLiterals^Record"_$P(tblDes,"|",1)
 .	I @call S logic=$S((logic=""):"UCLREGEN",1:logic_"/"_"UCLREGEN")
 .	Q 
 ;
 I '($P(tblDes,"|",8)'="GTM") D
 .	S tblDes=$$tAssert^UCXDD(tblDes,1) ; need PSLTable.indexList
 .	;
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
 .	N rs7,vos1,vos2,vos3,vos4,vos5  N V1 S V1=$P(tblDes,"|",1) S rs7=$$vOpen6()
 .	F  Q:'$$vFetch6()  D
 ..  I $P(rs7,$C(9),1) S trg("TRIGBEF","INSERT")=1 S trg("TRIGBEF","SAVE")=1
 ..  I $P(rs7,$C(9),2) S trg("TRIGAFT","INSERT")=1 S trg("TRIGAFT","SAVE")=1
 ..  I $P(rs7,$C(9),3) S trg("TRIGBEF","UPDATE")=1 S trg("TRIGBEF","SAVE")=1
 ..  I $P(rs7,$C(9),4) S trg("TRIGAFT","UPDATE")=1 S trg("TRIGAFT","SAVE")=1
 ..  I $P(rs7,$C(9),5) S trg("TRIGBEF","DELETE")=1
 ..  I $P(rs7,$C(9),6) S trg("TRIGAFT","DELETE")=1
 ..		Q 
 .	I '(("/"_qual_"/")["/NOTRIGBEF/"),($D(trg("TRIGBEF",oper))#2) S logic=$S((logic=""):"TRIGBEF",1:logic_"/"_"TRIGBEF")
 .	I '(("/"_qual_"/")["/NOTRIGAFT/"),($D(trg("TRIGAFT",oper))#2) S logic=$S((logic=""):"TRIGAFT",1:logic_"/"_"TRIGAFT")
 . Q 
 ;
 ; Journals
 I '(("/"_qual_"/")["/NOJOURNAL/") D
 .	I (oper="SAVE")!(oper="INSERT")  N V1 S V1=$P(tblDes,"|",1) I $$vDbEx2() S logic=$S((logic=""):"JOURNAL",1:logic_"/"_"JOURNAL") Q 
 .	I (oper="SAVE")!(oper="UPDATE")  N V2 S V2=$P(tblDes,"|",1) I $$vDbEx3() S logic=$S((logic=""):"JOURNAL",1:logic_"/"_"JOURNAL") Q 
 .	I oper="DELETE"  N V3 S V3=$P(tblDes,"|",1) I $$vDbEx4() S logic=$S((logic=""):"JOURNAL",1:logic_"/"_"JOURNAL")
 .	Q 
 ;
 ; VALDD, VALREQ, VALRI, and VALST: only look at explicit exclusion
 I oper'="DELETE" D
 .	N q
 .	F q="VALDD","VALREQ","VALRI","VALST" I '(("/"_qual_"/")[("/"_("NO"_q)_"/")) S logic=$S((logic=""):q,1:logic_"/"_q)
 .	Q 
 ;
 ; CASCADE: If table is referenced, then UPDATE and DELETE may cascade
 I oper'="INSERT" D
 .	I oper="DELETE",($P(tblDes,"|",8)'="GTM") D
 ..		;
 ..		N logCasc S logCasc=0
 ..		N rsCasc,vos6,vos7,vos8,vos9,vos10  N V1 S V1=$P(tblDes,"|",1) S rsCasc=$$vOpen7()
 ..		N tdCasc
 ..		;
 ..		F  Q:'($$vFetch7()&'logCasc)  D
 ...   S tdCasc=$$getPslTbl^UCXDD(rsCasc,1)
 ...			I '($$getFlrLgc(tdCasc,"DELETE",qual)="") S logic=$S((logic=""):"CASCADE",1:logic_"/"_"CASCADE") S logCasc=1
 ...			Q  ; end while rsCasc.next() & 'logCasc
 ..  Q  ; end if RDB DELETE
 .	E   N V1 S V1=$P(tblDes,"|",1) I $$vDbEx5() S logic=$S((logic=""):"CASCADE",1:logic_"/"_"CASCADE")
 .	Q  ; end if not INSERT (= DELETE, SAVE or UPDATE)
 ;
 ; If there are children, consider their filer logic as well
 I $$isParent^UCXDD(tblDes) D
 .	;
 .	N children S children=$$getChildren^UCXDD(tblDes)
 .	N childLogic
 .	N i N j
 .	;
 .	F i=1:1:$S((children=""):0,1:$L(children,",")) D
 ..		;
 ..		N tblChild S tblChild=$$getPslTbl^UCXDD($piece(children,",",i),1)
 ..		;
 ..		S childLogic=$$getFlrLgc^UCXDD(tblChild,oper,qual,0)
 ..		F j=1:1:$S((childLogic=""):0,1:$L(childLogic,"/")) S logic=$S((("/"_logic_"/")[("/"_$piece(childLogic,"/",j)_"/")):logic,1:$S((logic=""):$piece(childLogic,"/",j),1:logic_"/"_$piece(childLogic,"/",j)))
 ..		Q 
 .	Q 
 ;
 Q logic
 ;
 ; ---------------------------------------------------------------------
getGbl(tblDes,recInst,lvpm) ; keyvar map (*3)  /NOREQ/MECH=REFARR:R
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
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
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
 .	;   #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
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
getGvn(tblDes,recInst,lvpm) ; keyvar map (*3)  /NOREQ/MECH=REFARR:R
 N gvn S gvn=$$getGbl(tblDes,recInst,.lvpm)
 S gvn=$E(gvn,1,$L(gvn)-1)
 I gvn["(" Q gvn_")"
 Q gvn
 ;
 ; ---------------------------------------------------------------------
getLodCode(tblDes,recInst,node,mode,bExists,lvpm) ; purposemap (*6)  /NOREQ/MECH=REFARR:R
 ;
 N cd ; column descriptor for blob/memo
 ;
 N pur S pur=node
 I $E(node,1)="*" D
 .	S cd=$$getPslCln($P(tblDes,"|",1),$E(node,2,1048575))
 .	;set node = $$getCurNode(cd, 0)
 .	S node=$P(cd,"|",18)
 .	I '($D(lvpm(pur))#2),'(recInst=+recInst) S pur=node
 .	Q 
 ;
 N code S code=" S" ; return value
 N dbref S dbref="" ; database reference code (DB dep)
 N init161 S init161="" ; node -161/-162 initialization code
 N left S left=$$lvpm(recInst,pur,.lvpm) ; target lvn
 N mdvar S mdvar=$$lvpm(recInst,-2,.lvpm) ; record mode
 N bSel S bSel=(mode=-2)!(mode<0&($P(tblDes,"|",8)'="GTM")) ; Add $S() ?
 ;
 I bExists S code=code_":'$D("_left_")"
 ;
 ; -161/-162 are used for RDB only for update data (see cdRdbAsn^UCXDD)
 I ($D(lvpm(-161))#2) D
 .	;
 .	N nod
 .	;
 .	; Blob/memo node needs to be quotes for -161/-162 use
 .	I +node'=node S nod=$S(node'["""":""""_node_"""",1:$$QADD^%ZS(node,""""))
 .	E  S nod=node
 .	;
 .	;set init161 = oLvn_ "("_ recInst_ ",-161,"_ nod_ ")=1,"
 .	;set init161 = init161_ oLvn_ "("_ recInst_ ",-162,"_ nod_ ")="_ ($$nod2tbl^DBMAP( %DB, tblDes.table, node)).addQuotes()_ ","
 .	S init161=$$lvpm(recInst,-161,.lvpm)_nod_")=1,"
 .	S init161=init161_$$lvpm(recInst,-162,.lvpm)_nod_")="_$$QADD^%ZS($$nod2tbl^DBMAP($P(tblDes,"|",8),$P(tblDes,"|",1),node),"""")_","
 .	Q 
 I mode=0 Q code_" "_init161_left_"="""""
 ;
 S code=code_" "_init161_left_"="
 ;
 I node?.E1",1" D
 .	I ($P(tblDes,"|",8)'="GTM") D  ; RDB code
 ..		N sqlstm S sqlstm="SELECT "_$P(cd,"|",17)_" FROM "_$P(cd,"|",16)
 ..		N nd152 S nd152=$$lvpm(recInst,-152,.lvpm) ; Host variable values list
 ..		N where S where=$$getWhrKey(tblDes,recInst,2)
 ..		S dbref="$$SELECTDATA^%DBAPI(0,"""_sqlstm_where_""",$C("_$P(tblDes,"|",10)_"),"_nd152_")"
 ..		Q 
 .	E  D  ; MDB code
 ..		N gref S gref=$$getGbl(tblDes,recInst,.lvpm)
 ..		N ref
 ..		S code=code_"""""" ; Initialize
 ..		;
 ..		I $P(tblDes,"|",4)=1 S ref=gref_"von)"
 ..		E  S ref=gref_$piece(node,",",1)_",von)"
 ..		;
 ..		I bExists D
 ...			S code=" N von,vol S von="""",vol=$D("_left_") S:'vol "_left_"="""" F  Q:vol"
 ...			I bSel S code=code_"!'"_mdvar S bSel=0
 ...			Q 
 ..		E  D
 ...			S code=code_" N von S von="""" F"
 ...			I bSel S code=code_" Q:'"_mdvar S bSel=0
 ...			Q 
 ..		S code=code_"  S von=$O("_ref_") quit:von=""""  S "_left_"="_left_"_"_ref
 ..		Q 
 .	Q 
 E  S dbref=$$getDataNode(tblDes,recInst,node,0,.lvpm)
 ;
 I bSel S dbref="$S("_mdvar_":"_dbref_",1:"""")"
 Q code_dbref
 ;
 ; ---------------------------------------------------------------------
getLogging(tblDes,fromTable) ; force checking DBACCRTS
 ;
 N logList S logList=""
 ;
 I ($P(tblDes,"|",8)'="GTM") Q "" ; Logging does not apply to RDB
 ;
 ; Does not apply during bootstrap
 I ($$getSetting^PSLCC(.pslPrsr,"boot","restrictionlevel",0)>1) Q ""
 ;
 D
 .	;
 .	N table S table=$P(tblDes,"|",1)
 .	;
 .	N $ET,$ES,$ZYER S $ZYER="ZE^UCGMR",$ZE="",$EC="",$ET="D:$TL>"_$TL_" rollback^vRuntime("_$TL_") Q:$Q&$ES """" Q:$ES  N voxMrk s voxMrk="_+$O(vobj(""),-1)_" G vCatch4^"_$T(+0)
 .	;
 .	I fromTable S $ZE="0,"_$ZPOS_","_"%PSL-E-force",$EC=",U1001," ; Force error
 .	;
 .	;   #ACCEPT DATE=05/15/2008; PGM=Dan Russell; CR=30801; Group=BYPASS
 .	;*** Start of code by-passed by compiler
 .	X "S logList=$$vgetLogging^Record"_table
 .	;*** End of code by-passed by compiler ***
 .	Q 
 ;
 Q logList
 ;
 ; ---------------------------------------------------------------------
getNewCode(tblDes,recInst,mode,bNoNodes) ; runtime code PSLTable.getNewCode()
 ;
 N code S code="" ; return value
 N nod
 ;
 S code=$$cdNewObj^UCCLASS(recInst,"""Record"_$P(tblDes,"|",1)_"""")
 ;set code = code_ ","_ oLvn_ "("_ recInst_ ",-2)="_mode
 ;
 I 'bNoNodes D
 .	S code=code_","_"vobj"_"("_recInst_",-2)="_mode
 .	I $P(tblDes,"|",4)#2>0 S code=code_","_"vobj"_"("_recInst_")="""""
 .	E  D
 ..		N defNod S defNod=$P(tblDes,"|",12)
 ..		I (defNod="") Q 
 ..		I '(defNod=+defNod) S defNod=$S(defNod'["""":""""_defNod_"""",1:$$QADD^%ZS(defNod,""""))
 ..		S code=code_","_"vobj"_"("_recInst_","_defNod_")="""""
 ..		Q 
 .	Q 
 ;
 I ($P(tblDes,"|",8)'="GTM") D
 .	;
 .	N it S it=$$nod2tbl^DBMAP($P(tblDes,"|",8),$P(tblDes,"|",1),"")
 .	N nod S nod="""0*"""
 .	;
 .	S code=code_","_"vobj"_"("_recInst_",-161,"_nod_")=1,"_"vobj"_"("_recInst_",-162,"_nod_")="""_it_""""
 .	;
 .	; init other nodes for mode 0
 .	I (mode=0) S code=code_$$getInitCode^UCXDD(tblDes,recInst,0)
 .	Q 
 Q code
 ;
 ; ---------------------------------------------------------------------
getNewMethodCode(tblDes,methodName) ; method name (*2)
 ;
 N keys S keys=$P(tblDes,"|",3)
 N i
 N recClass S recClass="Record"_$P(tblDes,"|",1)
 N code S code="public static "_recClass_" "_methodName_"()"
 ;
 S code=code_$C(9)_" type "_recClass_" "_"vOid"
 ;
 S code=code_$C(9)_" #ACCEPT DATE=02/26/2008; PGM=Dan Russell; CR=30801; Group=BYPASS"
 S code=code_$C(9)_" #BYPASS"
 ;
 ; M implementation - that's all there is for now
 S code=code_$C(9)_$$getNewCode^UCXDD(tblDes,"vOid",0,0)
 ;
 F i=1:1:$S((keys=""):0,1:$L(keys,",")) D
 .	;
 .	N cd S cd=$$getPslCln^UCXDD($P(tblDes,"|",1),$piece(keys,",",i))
 .	;
 .	S code=code_$C(9)_$$getUpdCode^UCXDD(cd,"vOid","""""",0,2)
 .	Q 
 ;
 I '($P(tblDes,"|",8)'="GTM"),'($$getArchiveTable^DBARCHIVE(tblDes)="") S code=code_$C(9)_" S vobj(vOid,-99)="""""
 ; END M implementation
 ;
 S code=code_$C(9)_" #ENDBYPASS"
 ; Avoid warning on vOid being undefined
 S code=code_$C(9)_" #ACCEPT DATE=02/26/2008; PGM=Dan Russell; CR=30801; Group=SCOPE"
 S code=code_$C(9)_" quit vOid"
 ;
 Q code
 ;
 ; ---------------------------------------------------------------------
getInitCode(tblDes,recInst,bExists) ; include local node exists? (*3)
 ;
 N code S code="" ; return value
 ;
 I ($P(tblDes,"|",8)'="GTM") D
 .	N n
 .	N lvpm N nod N nodes
 .	;
 .	S tblDes=$$tAssert^UCXDD(tblDes,1)
 .	S nodes=$P(tblDes,"|",15)
 .	Q:(nodes="")  ; applies to wide tables only
 .	;
 .	S lvpm(-161)="vobj"_"("_recInst_",-161,"
 .	S lvpm(-162)="vobj"_"("_recInst_",-162,"
 .	;
 .	F n=1:1 S nod=$$vStrPce(nodes,",",n,n,"""") Q:(nod="")  D
 ..		;
 ..		Q:($E(nod,1)="*") 
 ..		;
 ..		S code=code_$$getLodCode^UCXDD(tblDes,recInst,nod,0,bExists,.lvpm)
 ..		Q 
 .	Q 
 Q code
 ;
 ; ---------------------------------------------------------------------
getOldExpr(clnDes,recInst,bLeft) ; leftexpr (1) of rightexpr (0)?
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
getOldLvn(clnDes,recInst) ; 
 Q $$cdOldLvn(recInst,$$getOldNode^UCXDD(clnDes,1),""""_$P(clnDes,"|",2)_"""")
 ;
 ; ---------------------------------------------------------------------
getOldNode(clnDes,bQuoted) ; do no add quotes
 ;
 N nod S nod=$$getCurNode(clnDes,bQuoted)
 I (nod="") S nod="0*" ; top
 E  I +nod<0 S nod=$P(clnDes,"|",4)_"*" ; key
 ;
 I +nod'=nod,$E(nod,1)'="""",bQuoted Q $S(nod'["""":""""_nod_"""",1:$$QADD^%ZS(nod,""""))
 Q nod
 ;
 ; ---------------------------------------------------------------------
getPrimaryKeyWhere(tblDes) ; get WHERE-clause on primary key
 Q $$getWhrKey(tblDes,"vIgnore",2)
 ;
 ; ---------------------------------------------------------------------
getPslCln(TBL,CLN,tblDes) ; (*3)  /MECH=REFARR:RW/NOREQ
 ;
 N dbtbl1d
 N rv S rv=TBL_"|"_CLN
 ;
 D
 .	N $ET,$ES,$ZYER S $ZYER="ZE^UCGMR",$ZE="",$EC="",$ET="D:$TL>"_$TL_" rollback^vRuntime("_$TL_") Q:$Q&$ES """" Q:$ES  N voxMrk s voxMrk="_+$O(vobj(""),-1)_" G vCatch5^"_$T(+0)
 .	S dbtbl1d=$$vRCgetRecord0Opt^RecordDBTBL1D("SYSDEV",TBL,CLN,0,"")
 .	N td S td=$$caPslTbl(.tblDes,TBL,0)
 .	;
 .	S $piece(rv,"|",5)=$P(td,"|",10) ; delimiter
 .	S $piece(rv,"|",6)=$P(dbtbl1d,$C(124),9) ; dataType
 .	S $piece(rv,"|",7)=$P(dbtbl1d,$C(124),2) ; length
 .	S $piece(rv,"|",8)=$P(dbtbl1d,$C(124),14) ; precision
 .	;
 .	N n2z S n2z=$P(dbtbl1d,$C(124),31)
 .	I n2z,"$N"'[$P(dbtbl1d,$C(124),9)!'($P(dbtbl1d,$C(124),5)="") S n2z=0
 .	S $piece(rv,"|",9)=n2z ; isNullToZero
 .	;
 .	I "BM"'[$P(dbtbl1d,$C(124),9) S $piece(rv,"|",14)=$P(dbtbl1d,$C(124),16)
 .	;
 .	;set ret.piece(SEP,15) = $$isSfdMaster(TBL,CLN, dbtbl1d.ismaster)
 .	S $piece(rv,"|",15)=''$P(dbtbl1d,$C(124),17) ; force boolean
 .	;
 .	N node S node=$P(dbtbl1d,$C(124),1) ; assume same for MDB and RDB
 .	;
 .	I ($P(td,"|",8)'="GTM") D
 ..		N intTbl S intTbl=TBL
 ..		N intCln S intCln=CLN
 ..		N pos
 ..		;
 ..		D MAP^DBMAP($P(td,"|",8),.intTbl,.intCln,.pos)
 ..		I intCln["(" S intCln="" ; do not store computations
 ..		I $E(intCln,1)="""" S intCln=$$QSUB^%ZS(intCln,"""")
 ..		;
 ..		N pks S pks=$P(td,"|",3)
 ..		I (pks="") S node="" ; node for CUVAR etc.
 ..		E  I node["*" ; RDB=MDB, no extra processing
 ..		E  I $P(td,"|",4)=11 D  ; node for wide table
 ...			N suffix S suffix=$$tbl2nod^DBMAP(intTbl)
 ...			I suffix?1.N S node=suffix
 ...			E  S node=$piece(pks,",",$S((pks=""):0,1:$L(pks,",")))
 ...			Q 
 ..		E  S node=$piece(pks,",",$S((pks=""):0,1:$L(pks,",")))
 ..		;
 ..		; subfieldXxx will be implied empty if not assigned explicitly
 ..		S $piece(rv,"|",4)=pos ; position
 ..		S $piece(rv,"|",16)=intTbl ; internalTable
 ..		S $piece(rv,"|",17)=intCln ; internalColumn
 ..		;
 ..		I "BM"[$P(dbtbl1d,$C(124),9) S node=pos
 ..		;
 ..		I $piece(rv,"|",15)=1 S $piece(rv,"|",15)=2
 ..		Q 
 .	E  D  ; MDB table
 ..		N pos
 ..		S $piece(rv,"|",10)=$P($P(dbtbl1d,$C(124),18),$C(126),1) ; subfieldTag
 ..		S $piece(rv,"|",11)=$P($P(dbtbl1d,$C(124),18),$C(126),2) ; subfieldMajor
 ..		S $piece(rv,"|",12)=$P($P(dbtbl1d,$C(124),18),$C(126),3) ; subfieldMinor
 ..		S pos=$P($P(dbtbl1d,$C(124),18),$C(126),4)
 ..		I '($P($P(dbtbl1d,$C(124),18),$C(126),1)=""),pos'>0 S pos=1
 ..		S $piece(rv,"|",13)=pos ; subfieldPosition
 ..		S $piece(rv,"|",4)=$P(dbtbl1d,$C(124),21) ; position
 ..		S $piece(rv,"|",16)=TBL ; internalTable
 ..		S $piece(rv,"|",17)=CLN ; internalColumn
 ..		I "BM"[$P(dbtbl1d,$C(124),9),(node="")!($P(td,"|",4)=1) S node=1
 ..		Q 
 .	;
 .	;if td.primaryKeys.isNull() set rv.piece(SEP, 3) = "" // node
 .	;else  set rv.piece(SEP, 3) = node
 .	S $piece(rv,"|",3)=node
 .	I node["*",CLN'=+CLN,$E(CLN,1)'="""" D
 ..		N keys S keys=$P(td,"|",3)
 ..		S $piece(rv,"|",4)=$L($piece((","_keys_","),","_CLN_",",1),",") ; key position
 ..		Q 
 .	; calculate PSLColumn.currentNode
 .	S $piece(rv,"|",18)=$$cmpCurNode($piece(rv,"|",3),$piece(rv,"|",4),$piece(rv,"|",6),td)
 .	Q  ; end do { catch {}
 Q rv
 ;
 ; ---------------------------------------------------------------------
getPslTbl(TBL,LVL,cdc) ; column descriptor cache
 ;
 N rv
 ;
 N rs1 S rs1=$$vOpen10()
 ;
 I '$G(vobj(rs1,0)) S $ZE="0,"_$ZPOS_","_"%PSL-E-RECNOFL,Table not defined,"_TBL,$EC=",U1001,"
 ;
 S rv=$$vFetch10(rs1)
 S rv=""
 ;
 N dbi S dbi=$$rtDbase(TBL)
 N rdb S rdb=(dbi'="GTM")
 ;
 S $piece(rv,"|",16)=""
 ;
 S $piece(rv,"|",1)=TBL ; table
 S $piece(rv,"|",3)=$$sub2cln($P(vobj(rs1),$C(9),1)) ; primaryKeys
 S $piece(rv,"|",6)=$P(vobj(rs1),$C(9),8) ; package
 S $piece(rv,"|",7)=$P(vobj(rs1),$C(9),7) ; parentTable
 S $piece(rv,"|",8)=dbi ; datebase
 S $piece(rv,"|",10)=$$getDelimiter($P(vobj(rs1),$C(9),3)) ; columnDelimiter
 S $piece(rv,"|",16)=$P(vobj(rs1),$C(9),6) ; isAutoLog
 ;
 I rdb D  ; for RDB tables
 .	N intNms S intNms=TBL
 .	D MAP^DBMAP(dbi,.intNms)
 .	S $piece(rv,"|",9)=intNms ; internalNames
 .	I intNms["," S $piece(rv,"|",4)=11
 .	E  S $piece(rv,"|",4)=1 ; recordType
 .	Q 
 E  D  ; for MDB tables
 .	I ($P(vobj(rs1),$C(9),1)="""*""") S $piece(rv,"|",2)=$piece($P(vobj(rs1),$C(9),5),"(")
 .	E  S $piece(rv,"|",2)=$P(vobj(rs1),$C(9),5)
 .	S $piece(rv,"|",4)=$P(vobj(rs1),$C(9),9) ; recordType
 .	S $piece(rv,"|",9)=TBL ; internalNames
 .	S $piece(rv,"|",12)=$P(vobj(rs1),$C(9),4) ; existsNode
 .	Q 
 ;
 I LVL>0 K vobj(+$G(rs1)) Q $$tAssert(rv,LVL,.cdc)
 ;
 K vobj(+$G(rs1)) Q rv
 ;
 ; ---------------------------------------------------------------------
getPurNode(clnDes) ; column descriptor
 I "BM"[$P(clnDes,"|",6) Q "*"_$P(clnDes,"|",2)
 ;
 N nod S nod=$$getCurNode(clnDes,1)
 ;
 I (nod="") Q "0*"
 Q nod
 ;
 ; ---------------------------------------------------------------------
getQuery(tblDes) ; table descriptor
 N vret
 ;
 N dbtbl1,vop1,vop2,vop3 S vop1="SYSDEV",vop2=$P(tblDes,"|",1),dbtbl1=$$vRCgetRecord0Opt^RecordDBTBL1("SYSDEV",vop2,0,"")
  S vop3=$G(^DBTBL(vop1,1,vop2,14))
 ;
 S vret=$P(vop3,$C(124),1) Q vret
 ;
 ; ---------------------------------------------------------------------
getRdbAsn(clnDes,recInst,getval,RdbCodeForm) ; form of code for RDB (*4)
 N ic S ic=$P(clnDes,"|",17)
 ;
 N nod S nod=$$getOldNode^UCXDD(clnDes,1)
 ;
 N pos S pos=$P(clnDes,"|",4)
 I (pos="") S pos=""""""
 ;
 N mod S mod=$$toValMod($P(clnDes,"|",6),$P(clnDes,"|",9))
 N dlmStr
 ;
 I ($P(clnDes,"|",5)<32) S dlmStr="$C("_$P(clnDes,"|",5)_")"
 E  S dlmStr=""""_$char($P(clnDes,"|",5))_""""
 ;
 ; If non-key column the single statement can be returned
 I $P(clnDes,"|",3)'?1.N1"*" Q $$cdRdbAsn(recInst,ic,nod,pos,dlmStr,getval,mod,RdbCodeForm,1)
 ;
 ; For key columns return one assignment per node/wide table
 N td S td=$$getPslTbl($P(clnDes,"|",1),0)
 S pos=$P(clnDes,"|",18)
 N rdbAsn S rdbAsn=$$cdRdbAsn(recInst,ic,"""0*""",pos,dlmStr,getval,mod,RdbCodeForm,1)
 I $P(td,"|",4)>1 D
 .	N n
 .	N it
 .	F n=1:1:$S(($P(td,"|",9)=""):0,1:$L($P(td,"|",9),",")) D
 ..		S it=$piece($P(td,"|",9),",",n)
 ..		S nod=$$tbl2nod^DBMAP(it)
 ..		I '(nod="") S rdbAsn=rdbAsn_$$cdRdbAsn(recInst,ic,nod,pos,dlmStr,getval,mod,RdbCodeForm,0)
 ..		Q 
 .	Q 
 Q rdbAsn
 ;
 ; ---------------------------------------------------------------------
getRdbExpr(clnDes,recInst) ; record instance variable
 N curExp S curExp=$$getCurExpr^UCXDD(clnDes,recInst,0)
 I $P(clnDes,"|",6)="L" Q "''"_curExp
 I $P(clnDes,"|",9) Q "+"_curExp
 I "CDN$"[$P(clnDes,"|",6) Q $S($P(clnDes,"|",18)<0:"+"_curExp,1:"$S("_curExp_"="""":"""",1:+"_curExp_")")
 Q curExp
 ;
 ; ---------------------------------------------------------------------
getRecPur(tblDes) ; table desctiptor descriptor
 I $P(tblDes,"|",4)#2=1 Q "0*"
 ;
 Q $P(tblDes,"|",12)
 ;
 ; ---------------------------------------------------------------------
getSavCode(tblDes,recInst,node,mode,lvpm,rdbCln) ; RDB column descriptors (*6)
 ;
 N cd ; column descriptor
 ;
 N pur S pur=node
 I $E(node,1)="*" D
 .	S cd=$$getPslCln($P(tblDes,"|",1),$E(node,2,1048575))
 .	;set node = $$getCurNode(cd, 0)
 .	S node=$P(cd,"|",18)
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
 ..		N nd152 S nd152=$$lvpm(recInst,-152,.lvpm) ; Host variable values list
 ..		N where S where=$$getWhrKey(tblDes,recInst,2)
 ..		;
 ..		I $P(cd,"|",6)="M",$P(cd,"|",7)<4001 D
 ...			N sqlstm S sqlstm="UPDATE "_$P(cd,"|",16)_" SET "_$P(cd,"|",17)_"="
 ...			S code=" N vRet S vRet=$$EXECUTESQL^%DBAPI("""","""_sqlstm_"""_$$QADD^%ZS("_right_",""'"")_"_where_",$C("_$P(tblDes,"|",10)_"),"_nd152_")"
 ...			Q 
 ..		; Remove " WHERE" for call to LOBUPDATE
 ..		E  S code=" N vRet S vRet=$$LOBUPDATE^%DBAPI(0,"""_$P(cd,"|",16)_""","""_$P(cd,"|",17)_""",$E("_$E(where,7,1048575)_",8,"_1048575_"),"_right_",$C("_$P(tblDes,"|",10)_"),"_nd152_")"
 ..		Q 
 .	; ================ MDB blob / memo ================
 .	E  D
 ..		N eCmd N lCmd N ref
 ..		N step S step=450
 ..		N extr S extr=step-1
 ..		;
 ..		I $$rtChset^UCBYTSTR="M" S eCmd="$E" S lCmd="$L"
 ..		E  S eCmd="$ZE" S lCmd="$ZL"
 ..		;
 ..		I $P(tblDes,"|",4)=1 S ref=gref_"vS1)"
 ..		E  S ref=gref_$piece(node,",")_",vS1)" S code=" K "_gref_$piece(node,",")_")"
 ..		S code=code_" N vS1,vS2 S vS1=0 F vS2=1:"_step_":"_lCmd_"("_right_") S vS1=vS1+1,"_ref_"="_eCmd_"("_right_",vS2,vS2+"_extr_")"
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
 ...			I (node="") D
 ....				;
 ....				N saveLabel N where
 ....				;
 ....				I $$isOneNode^UCXDD(tblDes),'$$isParent^UCXDD(tblDes) S saveLabel="rdbSaveS"
 ....				E  S saveLabel="rdbSaveC"
 ....				;
 ....				S where=$$getWhrKey(tblDes,recInst,2)
 ....				;
 ....				S code=" D "_saveLabel_"^UCDBRT("_recInst_",$C("_$P(tblDes,"|",10)_"),"_$S(where'["""":""""_where_"""",1:$$QADD^%ZS(where,""""))_")"
 ....				Q 
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
 ..		I (+mode'=+1) D
 ...			S codHvI=codHvU
 ...			F pos=1:1:$S(($P(tblDes,"|",3)=""):0,1:$L($P(tblDes,"|",3),",")) D
 ....				I ($D(rdbCln(-pos-2))#2) Q 
 ....				;
 ....				S cd=$$getPslCln($P(tblDes,"|",1),$piece($P(tblDes,"|",3),",",pos))
 ....				S codCol=codCol_", "_$P(cd,"|",17)
 ....				S codVal=codVal_", :HV"_hvn
 ....				S codHvI=codHvI_$char(9)_$$getRdbExpr(cd,recInst)_"_$C("_$P(tblDes,"|",10)_")"
 ....				S hvn=hvn+1
 ....				Q 
 ...			Q 
 ..		I (+mode'=+0) D
 ...			N whrKey S whrKey=$$getWhrKey(tblDes,"",2)
 ...			;
 ...			; Table may have no keys
 ...			I '(whrKey="") S codHvU=codHvU_$char(9)_$$lvpm(recInst,-152,.lvpm)
 ...			S codUpd=codUpd_whrKey
 ...			Q 
 ..		;
 ..		S codCol="INSERT INTO "_sqlstm_" ("_codCol_") VALUES ("_codVal_")"
 ..		S codUpd="UPDATE "_sqlstm_" SET "_codUpd
 ..		;
 ..		I mode=0 S code=$$getSavWr("",codCol,$P(tblDes,"|",10),codHvI)
 ..		E  I mode=1 S code=$$getSavWr("",codUpd,$P(tblDes,"|",10),codHvU)
 ..		E  D
 ...			S code=$$getSavWr(":'("_mdvar_")",codCol,$P(tblDes,"|",10),codHvI)
 ...			S sqlstm=$$getSavWr(":"_mdvar,codUpd,$P(tblDes,"|",10),codHvU)
 ...			I $$wrapFits^UCREC4OP(code_sqlstm,10) S code=code_sqlstm
 ...			E  S code=code_$char(9)_sqlstm
 ...			Q 
 ..		;
 ..		I $L(code,$char(9))>2 S code=" N vS1,vS2"_$char(9)_code
 ..		;
 ..		S code=" N vRet"_code
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
getSavWr(postCond,sql,delim,hvList) ; hostvalue construction list
 I $$wrapFits^UCREC4OP(postCond_sql_delim_hvList,40) Q " S"_postCond_" vRet=$$EXECUTESQL^%DBAPI(0,"_$S(sql'["""":""""_sql_"""",1:$$QADD^%ZS(sql,""""))_",$C("_delim_"),"_$translate(hvList,$char(9),"_")_")"
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
 Q code_$char(9)_" S"_postCond_" vRet=$$EXECUTESQL^%DBAPI(0,vS1,$C("_delim_"),vS2)"
 ;
 ; ---------------------------------------------------------------------
getSchCln(TBL,CLN) ; column name
 ;
 N rv S rv=$$fromPSLColumn($$getPslCln(TBL,CLN))
 N dbtbl1d S dbtbl1d=$$vRCgetRecord0Opt^RecordDBTBL1D("SYSDEV",TBL,CLN,0,"")
 ;
 S $piece(rv,"|",19)=$P(dbtbl1d,$C(124),3) ; default
 S $piece(rv,"|",20)=$P(dbtbl1d,$C(124),4) ; userType
 S $piece(rv,"|",21)=$P(dbtbl1d,$C(124),5) ; lookupTable
 S $piece(rv,"|",22)=$P(dbtbl1d,$C(124),6) ; pattern
 S $piece(rv,"|",23)=$P(dbtbl1d,$C(124),7) ; postProcExpr
 S $piece(rv,"|",24)=$P(dbtbl1d,$C(124),8) ; preProcExpr
 S $piece(rv,"|",25)=$P(dbtbl1d,$C(124),10) ; description
 S $piece(rv,"|",26)=$P(dbtbl1d,$C(124),11) ; internalType
 S $piece(rv,"|",27)=$P(dbtbl1d,$C(124),12) ; minimum
 S $piece(rv,"|",28)=$P(dbtbl1d,$C(124),13) ; maximum
 S $piece(rv,"|",29)=$P(dbtbl1d,$C(124),15) ; isRequired
 S $piece(rv,"|",30)=$P(dbtbl1d,$C(124),19) ; displaySize
 S $piece(rv,"|",31)=$P(dbtbl1d,$C(124),22) ; reportHeader
 S $piece(rv,"|",32)=$P(dbtbl1d,$C(124),23) ; isSerial
 S $piece(rv,"|",33)=$P(dbtbl1d,$C(124),24) ; conversionFlag
 S $piece(rv,"|",34)=$P(dbtbl1d,$C(124),25) ; dateUpdated
 S $piece(rv,"|",35)=$P(dbtbl1d,$C(124),26) ; userUpdated
 S $piece(rv,"|",36)=$P(dbtbl1d,$C(124),27) ; masterDataDictionary
 S $piece(rv,"|",37)=$P(dbtbl1d,$C(124),28) ; isValidForExtraction
 S $piece(rv,"|",38)=$P(dbtbl1d,$C(124),29) ; preProcDataEntry
 S $piece(rv,"|",39)=$P(dbtbl1d,$C(124),30) ; postProcDataEntry
 ;
 I $$getSetting^PSLCC(.pslPrsr,"PSL","Version",$$getPSLVersion^PSLC)>2.6,$P(rv,"|",6)="L",($P(rv,"|",14)="") D
 .	S $piece(rv,"|",29)=1
 .	I ($piece(rv,"|",19)="") S $piece(rv,"|",19)=0
 .	Q 
 Q rv
 ;
 ; ---------------------------------------------------------------------
getSchTbl(TBL) ; name of table
 ;
 N dtd S dtd=$$getPslTbl(TBL,0)
 N rv S rv=$$fromPSLTable(dtd)
 ;
 N rec,vop1,vop2,vop3,vop4,vop5,vop6 S vop1="SYSDEV",vop2=TBL,rec=$$vRCgetRecord0Opt^RecordDBTBL1("SYSDEV",TBL,0,"")
  S vop4=$G(^DBTBL(vop1,1,vop2,12))
  S vop5=$G(^DBTBL(vop1,1,vop2,99))
  S vop3=$G(^DBTBL(vop1,1,vop2,10))
  S vop6=$G(^DBTBL(vop1,1,vop2,100))
 ;
 S $piece(rv,"|",17)=$P(vop4,$C(124),1) ; fileShortName
 S $piece(rv,"|",18)=$P(vop5,$C(124),4) ; verifyPGM
 S $piece(rv,"|",19)=$P(vop5,$C(124),6) ; publishPGM
 S $piece(rv,"|",20)=$P(vop3,$C(124),2) ; systemName
 S $piece(rv,"|",21)=$P(vop3,$C(124),3) ; networkLocation
 S $piece(rv,"|",22)=$P(vop6,$C(124),4) ; dateCreated
 S $piece(rv,"|",23)=$P(vop6,$C(124),8) ; timeCreated
 S $piece(rv,"|",24)=$P(vop6,$C(124),3) ; userCreated
 S $piece(rv,"|",25)=$P(vop6,$C(124),10) ; dateUpdated
 S $piece(rv,"|",26)=$P(vop6,$C(124),11) ; timeUpdated
 S $piece(rv,"|",27)=$P(vop6,$C(124),9) ; userUpdated
 S $piece(rv,"|",31)=$P(rec,$C(124),1) ; description
 ;
 Q $$tAssert(rv,2)
 ;
 ; ---------------------------------------------------------------------
getSfd(TBL,CLN,SFD) ; The subfield definitions (*) /MECH=REFARR:W
 N dbtbl1d,vop1 S dbtbl1d=$$vRCgetRecord1Opt^RecordDBTBL1D("SYSDEV",TBL,CLN,0,.vop1)
 I $G(vop1)=0 Q ""
 ;
 N N S N=$P(dbtbl1d,$C(124),1)
 N P S P=$P(dbtbl1d,$C(124),21)
 N rs,vos1,vos2,vos3,vos4,vos5,vos6,vos7,vos8,vos9,vOid S rs=$$vOpen11()
 N cnt S cnt=0
 F  Q:'$$vFetch11()  S cnt=cnt+1 S SFD(cnt)=$TR(rs,$C(9),"~")
 Q "~String DI,String SFT,Number SFD1, Number SFD2,Number SFP"
 ;
 ; ---------------------------------------------------------------------
getSfdMaster(TBL,CLN) ; column name
 N vret
 N dbtbl1d S dbtbl1d=$G(^DBTBL("SYSDEV",1,TBL,9,CLN))
 I ($P(dbtbl1d,$C(124),18)="") Q "" ; not a subfield
 ;
 N N S N=$P(dbtbl1d,$C(124),1)
 N P S P=$P(dbtbl1d,$C(124),21)
 ;
 N rs,vos1,vos2,vos3,vos4,vos5,vos6,vos7 S rs=$$vOpen12()
 I $$vFetch12() S vret=rs Q vret
 Q ""
 ;
 ; ---------------------------------------------------------------------
getSfdRT() ; Row Template for getSfd
 Q "String DI,String SFT,Number SFD1,Number SFD2,Number SFP"_$char(9)_126
 ;
 ; ---------------------------------------------------------------------
getUpdAudit(clnDes,recInst,getval,fromSQL) ; PSL audit (0) or SQL audit (1)
 N oldlvn S oldlvn=$$getOldLvn(clnDes,recInst)
 N xtra S xtra=""
 N z S z=" S:'$D("_oldlvn_") "_oldlvn_"="""_$P(clnDes,"|",6)_$E((1000+$P(clnDes,"|",4)),2,4)_"""_"
 ;
 I $P(clnDes,"|",3)?1.N1"*" S z=z_"$G("_getval_")"
 E  D
 .	N fmtable
 .	;   #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 .	S fmtable=$$FMTABLE^DBSMACRO($P(clnDes,"|",1)_"."_$P(clnDes,"|",2))
 .	S z=z_getval
 .	I '($P(clnDes,"|",13)="") D
 ..		N d2 S d2=$S($P(clnDes,"|",5)=126:";",1:"~")
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
getUpdCode(clnDes,recInst,value,mode,RdbCodeForm,lvpm) ; loc var pur map /NOREQ/MECH=REFARR:R
 ;
 N bAudit S bAudit=(mode#3)>0
 N td S td=$$getPslTbl($P(clnDes,"|",1),0)
 ;
 I $P(clnDes,"|",15)>0,($P(td,"|",8)'="GTM")!bAudit Q $$setMfXDB^UCCOLSF(clnDes,recInst,value,mode,RdbCodeForm,.lvpm)
 ;
 N getval
 N setval S setval=$$getCurExpr(clnDes,recInst,1,.lvpm)
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
 N code S code=$$getUpdOvh(clnDes,td,recInst,mode,RdbCodeForm)
 ; Split pre and post overhead code
 S code=$piece(code,$char(9),1)_" S "_setval_$piece(code,$char(9),2)
 ;
 Q code
 ;
 ; ---------------------------------------------------------------------
getUpdKey(tblDes,recInst,lvpm) ; purpose mappings (*3)
 ;
 N cd152 S cd152=""
 N keys S keys=$P(tblDes,"|",3)
 N pos
 ;
 I (keys="") Q ""
 ;
 F pos=1:1:$S((keys=""):0,1:$L(keys,",")) D
 .	N cd S cd=$$getPslCln($P(tblDes,"|",1),$piece(keys,",",pos))
 .	N typ S typ=$P(cd,"|",6)
 .	;type String kve = cd.getCurrentLvn( recInst)
 .	N kve S kve=$$lvpm(recInst,pos_"*",.lvpm)
 .	;
 .	;if "FUT"[typ set kve = "$S("_ kve_ "'[""'"":""'""_"_ kve_ "_""'"",1:$$QADD^%ZS("_ kve_ ",""'""))"
 .	;else  set kve = "(+"_ kve_ ")"
 .	I "$CDLN"[typ S kve="(+"_kve_")"
 .	S cd152=cd152_"_"_kve_"_$C("_$P(tblDes,"|",10)_")"
 .	Q 
 ;
 ; Strip leading concatenate character
 Q " S "_$$lvpm(recInst,-152,.lvpm)_"="_$E(cd152,2,1048575)
 ;
 ; ---------------------------------------------------------------------
getUpdOvh(clnDes,td,recInst,mode,RdbCodeForm) ; form of code for RDB (*4)
 ;
 N bAudit S bAudit=(mode#3)>0
 N getval S getval=$$getCurExpr(clnDes,recInst,0)
 ;
 I $P(clnDes,"|",15)>0,($P(td,"|",8)'="GTM")!bAudit S $ZE="0,"_$ZPOS_","_"%PSL-E-NOTSUPPORTED,method not supported for masterfield",$EC=",U1001,"
 ;
 N codePost N codePre
 I (recInst=+recInst) S recInst=$$dec2ovs^UCREC4OP(recInst)
 I ($P(td,"|",8)'="GTM"),mode<3 S codePost=$$getRdbAsn(clnDes,recInst,getval,RdbCodeForm)
 E  S codePost=""
 ;
 ; Code to save column.oldval if audit is on
 I bAudit S codePre=$$getUpdAudit(clnDes,recInst,getval,(mode#3)=2) ; prepend!
 E  S codePre=""
 ;
 ; add code to notify node changed if needed or requested
 I (($P(td,"|",4)>1)&($P(clnDes,"|",18)'<0))!bAudit!$$isParent^UCXDD(td) D
 .	I (codePre="") S codePre=" S "
 .	E  S codePre=codePre_","
 .	S codePre=codePre_$$cdNodChg(recInst,$$getOldNode(clnDes,1))_"="""""
 .	Q 
 ;
 Q codePre_$char(9)_codePost
 ;
 ; ---------------------------------------------------------------------
getWhrKey(tblDes,recInst,md,lvpm,hostval,hostrsp,coldes) ; Column descriptor cache
 N cd ; individual column descriptor
 N cln ; individual (key)column name
 N k ; interator
 N primkey S primkey=$P(tblDes,"|",3)
 N tbl S tbl=$P(tblDes,"|",1) ; external table name
 N val ; individual key value expr
 N where S where=" WHERE " ; where clause (to be returned)
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
isColumn(TBL,CLN) ; column name
 Q ($D(^DBTBL("SYSDEV",1,TBL,9,CLN))#2)
 ;
 ; ---------------------------------------------------------------------
isSfdMaster(TBL,CLN,dicval) ; dictionary value (*3) /NOREQ
 N vret
 ; if value supplied, and not empty, return it
 I '($get(dicval)="") Q dicval
 ;
 ; need to retrieve row
 I '($D(^DBTBL("SYSDEV",1,TBL,9,CLN))#2) Q ""
 N dbtbl1d S dbtbl1d=$$vRCgetRecord0Opt^RecordDBTBL1D("SYSDEV",TBL,CLN,0,"")
 ;
 ; if value specified in dictionary, return it
 I '($P(dbtbl1d,$C(124),17)="") S vret=$P(dbtbl1d,$C(124),17) Q vret
 ;
 ; need to derive ...
 ;if pslPrsr.getSetting("PSL","Version",$$getPSLVersion^PSLC)>2.6 quit 0  // V2.7 and up: NULL = 0
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
 I $$getSetting^PSLCC(.pslPrsr,"boot","restrictionlevel",0)>0 D
 .	S count=0
 .	N rs,vos1,vos2,vos3,vos4,vos5 S rs=$$vOpen13()
 . F  Q:'$$vFetch13()  I $P(rs,$C(9),1)=nod,$P(rs,$C(9),2)=pos S count=count+1
 . Q 
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
isOneNode(tblDes) ; table descriptor
 N td S td=$$tAssert(tblDes,1)
 ;
 I $P(td,"|",4)=1,'($P(td,"|",5)["M"),'($P(td,"|",5)["B") Q 1
 Q 0
 ;
 ; ---------------------------------------------------------------------
isParent(tblDes) ; table descriptor
 N vret
 ;
 N rs,vos1,vos2,vos3,vos4  N V1 S V1=$P(tblDes,"|",1) S rs=$$vOpen14()
 ;
 S vret=''$G(vos1) Q vret
 ;
 ; ---------------------------------------------------------------------
isTable(TBL) ; table name
 Q ($D(^DBTBL("SYSDEV",1,TBL)))
 ;
 ; ---------------------------------------------------------------------
lvpm(recInst,pur,lvpm) ; mapping (*3)      /NOREQ/MECH=REFARR:R
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
mpPslCln(colDes,property) ; PSLColumn property (*2)
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
 S $ZE="0,"_$ZPOS_","_"%PSL-E-INVALIDPROP,"_property,$EC=",U1001,"
 Q "" ; dead code
 ;
 ; ---------------------------------------------------------------------
mpPslTbl(tabDes,property) ; PSLTable property (*2)
 I property="columnDelimiter" Q $P(tabDes,"|",10)
 I property="database" Q $P(tabDes,"|",8)
 I property="dataTypes" Q $P(tabDes,"|",5)
 I property="existsNode" Q $P(tabDes,"|",12)
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
 S $ZE="0,"_$ZPOS_","_"%PSL-E-INVALIDPROP,"_property,$EC=",U1001,"
 Q "" ; dead code
 ;
 ; ---------------------------------------------------------------------
rtCurExpr(TBL,CLN,recInst,bLeft,tblDes,clnDes) ; cache /MECH=REFARR:RW/NOREQ
 N prop S prop=TBL_"."_CLN
 I '($D(clnDes(prop))#2) S clnDes(prop)=$$getPslCln(TBL,CLN,.tblDes)
 I '($D(tblDes(TBL))#2) S tblDes(TBL)=$$getPslTbl(TBL,0)
 ;
 Q $$getCurExpr(clnDes(prop),recInst,bLeft)
 ;
 ; ---------------------------------------------------------------------
rtCurLvn(TBL,CLN,recInst,tblDes,clnDes) ; cache /MECH=REFARR:RW/NOREQ
 N prop S prop=TBL_"."_CLN
 I '($D(clnDes(prop))#2) S clnDes(prop)=$$getPslCln(TBL,CLN,.tblDes)
 I '($D(tblDes(TBL))#2) S tblDes(TBL)=$$getPslTbl(TBL,0)
 ;
 Q $$getCurLvn(clnDes(prop),recInst)
 ;
 ; ---------------------------------------------------------------------
rtCurNode(TBL,CLN,bQuoted,tblDes,clnDes) ; cache /MECH=REFARR:RW/NOREQ
 N prop S prop=TBL_"."_CLN
 I '($D(clnDes(prop))#2) S clnDes(prop)=$$getPslCln(TBL,CLN,.tblDes)
 I '($D(tblDes(TBL))#2) S tblDes(TBL)=$$getPslTbl(TBL,0)
 ;
 Q $$getCurNode(clnDes(prop),bQuoted)
 ;
 ; ---------------------------------------------------------------------
rtDbase(table) ; list of tables
 ;
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 I $get(%DB)="" S %DB=$$SCAU^%TRNLNM("DB") I (%DB="") S %DB="GTM"
 ;
 I ($get(table)="") Q %DB
 ;
  N V1 S V1=$piece(table,",") I ($D(^STBL("MTBLS",V1))#2) Q "GTM"
 Q %DB
 ;
 ; ---------------------------------------------------------------------
rtIsRdb(table) ; list of tables
 Q $$rtDbase(table)'="GTM"
 ;
 ; ---------------------------------------------------------------------
rtLodCode(table,recInst,node,mode,bExists,lvpm) ; purpose mapping
 N td S td=$$getPslTbl(table,0)
 ;
 Q $$getLodCode(td,recInst,node,mode,bExists,.lvpm)
 ;
 ; ---------------------------------------------------------------------
rtOldLvn(TBL,CLN,recInst,tblDes,clnDes) ; cache /MECH=REFARR:RW/NOREQ
 N prop S prop=TBL_"."_CLN
 I '($D(clnDes(prop))#2) S clnDes(prop)=$$getPslCln(TBL,CLN,.tblDes)
 I '($D(tblDes(TBL))#2) S tblDes(TBL)=$$getPslTbl(TBL,0)
 ;
 Q $$getOldLvn(clnDes(prop),recInst)
 ;
 ; ---------------------------------------------------------------------
rtOldNode(TBL,CLN,bQuoted,tblDes,clnDes) ; cache /MECH=REFARR:RW/NOREQ
 N prop S prop=TBL_"."_CLN
 I '($D(clnDes(prop))#2) S clnDes(prop)=$$getPslCln(TBL,CLN,.tblDes)
 I '($D(tblDes(TBL))#2) S tblDes(TBL)=$$getPslTbl(TBL,0)
 ;
 Q $$getOldNode(clnDes(prop),bQuoted)
 ;
 ; ---------------------------------------------------------------------
rtUpdCode(TBL,CLN,recInst,value,bAudit,RdbCodeForm,tblDes,clnDes) ; cache /MECH=REFARR:RW/NOREQ
 N prop S prop=TBL_"."_CLN
 I '($D(clnDes(prop))#2) S clnDes(prop)=$$getPslCln(TBL,CLN,.tblDes)
 I '($D(tblDes(TBL))#2) S tblDes(TBL)=$$getPslTbl(TBL,0)
 ;
 Q $$getUpdCode(clnDes(prop),recInst,value,bAudit,RdbCodeForm)
 ;
 ; ---------------------------------------------------------------------
rtUpdKey(TBL,recInst,tblDes) ; cache /MECH=REFARR:RW/NOREQ
 I '($D(tblDes(TBL))#2) S tblDes(TBL)=$$getPslTbl(TBL,0)
 ;
 Q $$getUpdKey(tblDes(TBL),recInst)
 ;
 ; ---------------------------------------------------------------------
nextSubfield(tbl,nod,pos,cln) ; column name
 ;  #ACCEPT CR=15028;DATE=2005-03-14;PGM=FSCW
 Q $order(^DBINDX("SYSDEV","STR",tbl,nod,pos,cln))
 ;
 ; ---------------------------------------------------------------------
nodIsBM(nod) ; 
 Q ($E(nod,1)="*")!(nod?.E1",1")
 ;
 ; ---------------------------------------------------------------------
nodIsKey(nod) ; 
 Q (nod<0)!((nod?1.N1"*")&(nod'="0*"))
 ;
 ; ---------------------------------------------------------------------
nodIsNeg(nod) ; 
 Q nod?1"""v"1.N1""""
 ;
 ; ---------------------------------------------------------------------
nodIsTop(nod) ; 
 Q nod="0*"!(nod="")
 ;
 ; ---------------------------------------------------------------------
parseCmp(expr,tree) ; parse result (*2) /REFARR:W
 ;
 N atom ; parser atom
 N getval S getval="" ; return value
 N lit ; tokenized literals
 N nr S nr=0 ; token number
 N ptr S ptr=0 ; char ptr
 N skwd ; system keyword value
 ;
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 S expr=$$TOKEN^%ZS(expr,.lit)
 ;
 F  D  Q:ptr=0 
 .	;
 .	;   #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 .	S atom=$$ATOM^%ZS(expr,.ptr,"[]+-*/\#_'=><\*(),!&:?",,1)
 .	;
 .	I atom="[",$E(expr,ptr+1)?1A,$F(expr,"]",ptr) D
 ..		;
 ..		; Fill atom with table name
 ..		S atom=$E(expr,ptr+1,$F(expr,"]",ptr)-2)
 ..		;
 ..		I $translate(atom,"_","0")'?1A.AN S atom="[" Q 
 ..		S ptr=ptr+$L(atom)+1
 ..		;
 ..		;    #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
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
 .	;   #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 .	I $ascii(atom)=0 S getval=getval_$$UNTOK^%ZS(atom,lit) Q 
 .	I $E(atom,1)="$" S getval=getval_atom Q 
 .	;   #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 .	I $$isNum^UCGM(atom) S getval=getval_atom Q 
 .	;
 .	S nr=nr+1 S tree(nr)=getval
 .	S nr=nr+1 S tree(nr)=$ZCONVERT(atom,"U")
 .	S getval=""
 .	Q 
 S nr=nr+1 S tree(nr)=getval
 Q 
 ;
 ; ---------------------------------------------------------------------
stripQuotes(ident,literals) ; M and/or SQL literals /NOREQ
 ;
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 I $E(ident,1)=$char(1) S ident=$$UNTOK^%ZS(ident,literals)
 I $E(ident,1)="""" Q $piece(ident,"""",2)
 Q ident
 ;
 ; ---------------------------------------------------------------------
sub2cln(sublist) ; subscript list
 ;
 N cln N ER ; ER created by TOKEN^%ZS() !!
 N clnlist S clnlist=""
 N sub
 ;
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
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
tAssert(tabDes,LVL,clnDes) ; PSLColumn() cache
  ; "size" of PSLTable
  ; PSLTable.hasComputed
  ; SchemaTable.count
 ;
 I LVL=0 Q tabDes
 I LVL>1,$P(tabDes,"|",28)>0 Q tabDes
 I LVL>0,'($P(tabDes,"|",11)="") Q tabDes
 ;
 N cln ; column name
 N cmp S cmp=0 ; hasComputed?
 N count S count=0 ; column count
 N def ; default value
 N dfl S dfl="" ; defaultList
 N ixl S ixl="" ; indexList
 N key ; ORDERBY iterator
 N mfl S mfl="" ; masterfieldList
 N nod ; node
 N nodes ; array of nodes
 N ndl S ndl="" ; nodeList
 N req ; isRequired?
 N rql S rql="" ; requiredList
 N ordby ; DBTBL8.ORDERBY
 N types S types="" ; dataTypes
 N table S table=$P(tabDes,"|",1)
 ;
 N rs1d,vos1,vos2,vos3,vos4,vos5  N V1 S V1=table S rs1d=$$vOpen15()
 N tdc ; local "cache" for calls ...
 S tdc(table)=tabDes ; ... to $$getPslCln()
 F  Q:'$$vFetch15()  D
 . N rec S rec=rs1d
 .	;
 .	; Don't include literal keys
 .	I $$vStrIsNum($P(rec,$C(9),1)) Q 
 .	I $E($P(rec,$C(9),1),1)="""" Q 
 .	;
 .	S count=count+1
 .	S cln=$P(rec,$C(9),1)
 .	;
 .	I '(types[$P(rec,$C(9),2)) S types=types_$P(rec,$C(9),2)
 .	;
 .	;if $$isSfdMaster(table, cln, rec.ismaster) set mfl = mfl.add( cln)
 .	I $P(rec,$C(9),4) S mfl=$S((mfl=""):cln,1:mfl_","_cln)
 .	;
 .	I cmp=0,'($P(rec,$C(9),3)=""),$P(rec,$C(9),2)'="M" S cmp=1
 .	;
 .	N ref S ref=table_"."_cln
 .	S clnDes(ref)=$$getPslCln(table,cln,.tdc)
 .	S nod=$$getPurNode^UCXDD(clnDes(ref))
 .	;
 .	I +nod'<0,nod'?1.N1"*" S nodes(nod)=""
 .	;
 .	S req=''$P(rec,$C(9),5)
 .	S def=$P(rec,$C(9),6)
 .	;
 .	I $$getSetting^PSLCC(.pslPrsr,"PSL","Version",$$getPSLVersion^PSLC)>2.6,$P(rec,$C(9),2)="L",($P(rec,$C(9),3)="") S req=1 I (def="") S def=0
 .	I req S rql=$S((rql=""):cln,1:rql_","_cln)
 .	I '(def="") S dfl=$S((dfl=""):cln,1:dfl_","_cln)
 .	Q 
 ;
 S nod=-1
 F  S nod=$order(nodes(nod)) Q:nod=""  S ndl=ndl_","_nod
 ;
 N rs8,vos6,vos7,vos8,vos9,vos10  N V2 S V2=table S rs8=$$vOpen16()
 F  Q:'$$vFetch16()  D
 .	;
 .	;   #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 . S ordby=$$TOKEN^%ZS(rs8)
 .	F key=1:1:$L(ordby,",") D
 ..		S cln=$piece(ordby,",",key)
 ..		I cln=+cln Q  ; skip numlit
 ..		I cln[$char(0) Q  ; skip strlit
 ..		I ((","_ixl_",")[(","_cln_",")) Q  ; duplicate
 ..		S ixl=$S((ixl=""):cln,1:ixl_","_cln)
 ..		Q 
 .	Q 
 ;
 N intDes S intDes=tabDes ; TEMP !!!!
 S $piece(intDes,"|",5)=types
 S $piece(intDes,"|",11)=cmp
 S $piece(intDes,"|",13)=ixl
 S $piece(intDes,"|",14)=mfl
 S $piece(intDes,"|",15)=$E(ndl,2,1048575)
 ;
 I LVL>1,$L(intDes,"|")>16 D
 .	S $piece(intDes,"|",28)=count
 .	S $piece(intDes,"|",29)=dfl
 .	S $piece(intDes,"|",30)=rql
 .	Q 
 ;
 Q intDes
 ;
 ; ---------------------------------------------------------------------
toValMod(typ,nul) ; isNullToZero
 Q $S("BFMTU"[typ:0,typ="L"!nul:2,1:1)
 ;
 ; TEMPORARY CLASS MISMATCH HIDERS
fromPSLColumn(cd) ; 
 Q cd
fromPSLTable(td) ; 
 Q td
 ;  #OPTION ResultClass ON
vSIG() ; 
 Q "61397^34727^Frans S.C. Witte^167273" ; Signature - LTD^TIME^USER^SIZE
 ; ----------------
 ;  #OPTION ResultClass 1
vStrRep(object,p1,p2,p3,p4,qt) ; String.replace
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 ;
 I p3<0 Q object
 I $L(p1)=1,$L(p2)<2,'p3,'p4,(qt="") Q $translate(object,p1,p2)
 ;
 N y S y=0
 F  S y=$$vStrFnd(object,p1,y,p4,qt) Q:y=0  D
 .	S object=$E(object,1,y-$L(p1)-1)_p2_$E(object,y,1048575)
 .	S y=y+$L(p2)-$L(p1)
 .	I p3 S p3=p3-1 I p3=0 S y=$L(object)+1
 .	Q 
 Q object
 ; ----------------
 ;  #OPTION ResultClass 1
vStrPce(object,p1,p2,p3,qt) ; String.piece
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 I '($D(p3)#2) S p3=p2
 I '(object[qt)!(qt="") Q $piece(object,p1,p2,p3)
 ;
 I $piece(object,p1,1,p2-1)[qt D  ; find real start
 .	N p N o S o=0
 .	F p=1:1:$L(object,p1) Q:p=(p2+o)  S o=($L($piece(object,p1,1,p),qt)#2=0)+o
 .	S p2=p2+o S p3=p3+o
 .	Q 
 I $piece(object,p1,p2,p3)[qt D  ; find real end
 .	N p N o
 .	F p=p2:1:$L(object,p1) S o=($L($piece(object,p1,p2,p),qt)#2=0) S p3=o+p3 Q:(p=p3)&'o 
 .	Q 
 Q $piece(object,p1,p2,p3)
 ; ----------------
 ;  #OPTION ResultClass 1
vOpen10() ; PSLBOOT result set for DBTBL1
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 ;  #ACCEPT GROUP=BYPASS;CR=27800;PGM=Frans S.C. Witte;Date=2008-03-11
 ;*** Start of code by-passed by compiler
 IF '$DATA(pslPrsr("boot","DBTBL1")) QUIT $$vOpen9()
 ;*** End of code by-passed by compiler ***
 N vRws S vRws=pslPrsr("boot","DBTBL1")
 N vOid S vOid=$O(vobj(""),-1)+1
 S vobj(vOid,-1)="ResultSet"
 S vobj(vOid,-5)=2
 S vobj(vOid,-2)="$$vFetch10^"_$T(+0)
 S vobj(vOid,-3)="ACCKEYS,DBASE,DEL,EXIST,GLREF,LOG,PARFID,PSLPACKAGE,RECTYP"
 S vobj(vOid,-4)="U0T0N0N0T0L0U0T0N0"
 S vobj(vOid,0)=1
 S vobj(vOid,1)=TBL
 S vobj(vRws,0)=0 
 ;  #ACCEPT GROUP=BYPASS;CR=27800;PGM=Frans S.C. Witte;Date=2008-03-11
 ;*** Start of code by-passed by compiler
 IF $$vFetch10(vOid) SET vobj(vOid,0)=2
 ;*** End of code by-passed by compiler ***
 Q vOid
 ; ----------------
 ;  #OPTION ResultClass 1
vFetch10(vOid) ; PSLBOOT fetch for DBTBL1
 N vret
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 ;  #ACCEPT GROUP=BYPASS;CR=27800;PGM=Frans S.C. Witte;Date=2008-03-11
 ;*** Start of code by-passed by compiler
 IF '$DATA(pslPrsr("boot","DBTBL1")) QUIT $$vFetch9(vOid)
 ;*** End of code by-passed by compiler ***
 I vobj(vOid,0)=2 S vobj(vOid,0)=1 Q 1
 N vRws S vRws=pslPrsr("boot","DBTBL1")
 N vR
 N vFnd S vFnd=0
 F  Q:'('vFnd)  D
 .	I '$$vRwsNxt(vRws) S vFnd=1 S vobj(vOid,0)=0 Q 
 .	S vR=$S(vobj(vRws,0)>0:$G(vobj(vRws,vobj(vRws,0))),1:"")
 .	I '($P(vR,vobj(vRws,-3),$$vRwGC(vobj(vRws,-2),"%LIBS"))="SYSDEV") Q 
 .	I '($P(vR,vobj(vRws,-3),$$vRwGC(vobj(vRws,-2),"FID"))=vobj(vOid,1)) Q 
 .	S vFnd=1
 .	Q 
 S vR=$S(vobj(vRws,0)>0:$G(vobj(vRws,vobj(vRws,0))),1:"")
 S vobj(vOid)=$P(vR,vobj(vRws,-3),$$vRwGC(vobj(vRws,-2),"ACCKEYS"))_$char(9)_$P(vR,vobj(vRws,-3),$$vRwGC(vobj(vRws,-2),"DBASE"))_$char(9)_$P(vR,vobj(vRws,-3),$$vRwGC(vobj(vRws,-2),"DEL"))_$char(9)_$P(vR,vobj(vRws,-3),$$vRwGC(vobj(vRws,-2),"EXIST"))_$char(9)_$P(vR,vobj(vRws,-3),$$vRwGC(vobj(vRws,-2),"GLREF"))_$char(9)_$P(vR,vobj(vRws,-3),$$vRwGC(vobj(vRws,-2),"LOG"))_$char(9)_$P(vR,vobj(vRws,-3),$$vRwGC(vobj(vRws,-2),"PARFID"))_$char(9)_$P(vR,vobj(vRws,-3),$$vRwGC(vobj(vRws,-2),"PSLPACKAGE"))_$char(9)_$P(vR,vobj(vRws,-3),$$vRwGC(vobj(vRws,-2),"RECTYP"))
 S vret=vobj(vOid,0) Q vret
 ; ----------------
 ;  #OPTION ResultClass 1
vBtsPslE(vVal) ; ByteString.toPSLExpression
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 N bValid S bValid=0
 D
 .	N $ET,$ES,$ZYER S $ZYER="ZE^UCGMR",$ZE="",$EC="",$ET="D:$TL>"_$TL_" rollback^vRuntime("_$TL_") Q:$Q&$ES """" Q:$ES  N voxMrk s voxMrk="_+$O(vobj(""),-1)_" G vCatch6^"_$T(+0)  ; catch and ignore %GTM-E-BADCHAR exception
 .	S bValid=vVal?.ANP
 .	Q 
 I bValid,(vVal=+vVal) Q vVal
 I bValid Q $S(vVal'["""":""""_vVal_"""",1:$$QADD^%ZS(vVal,""""))
 N vC
 N vE
 I $ZTRANSLATE(vVal,$C(0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,12,18,19,20,21,22,23,24,25,26,27,28,29,30,31,127))?.ANP S vE="$C("_$ZASCII(vVal)
 E  S vE="$ZCH("_$ZASCII(vVal)
 F vC=2:1:$ZLENGTH(vVal) S vE=vE_","_$ZASCII(vVal,vC)
 Q vE_")"
 ; ----------------
 ;  #OPTION ResultClass 1
vStrFnd(object,p1,p2,p3,qt) ; String.find
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 ;
 I (p1="") Q $S(p2<1:1,1:+p2)
 I p3 S object=$ZCONVERT(object,"U") S p1=$ZCONVERT(p1,"U")
 S p2=$F(object,p1,p2)
 I '(qt=""),$L($E(object,1,p2-1),qt)#2=0 D
 .	F  S p2=$F(object,p1,p2) Q:p2=0!($L($E(object,1,p2-1),qt)#2) 
 .	Q 
 Q p2
 ; ----------------
 ;  #OPTION ResultClass 1
vRwGC(vList,vRef) ; Dynamic column position lookup
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 ;
 I (vRef="") Q ""
 I +vRef>0 Q vRef
 ;
 S vList=$ZCONVERT(vList,"U") S vRef=$ZCONVERT(vRef,"U")
 N vP S vP=$F((vList_",")," "_vRef_",")
 I vP=0 S vP=$F((","_vList_","),","_vRef_",") I vP=0 Q ""
 Q $L($E(vList,1,vP-$L(vRef)),",")
 ;
vDbEx1() ; min(1): DISTINCT %LIBS,FID,FKEYS FROM DBTBL1F WHERE FID=:V1
 ;
 N vsql1,vsql3,vsql4
 S vsql1=$$BYTECHAR^SQLUTL(254)
 ;
 S vsql3=""
vEx1a4 S vsql3=$O(^DBTBL(vsql3),1) I vsql3="" Q 0
 S vsql4=""
 S vsql4=$O(^DBTBL(vsql3,19,V1,vsql4),1) I vsql4="" G vEx1a4
 Q 1
 ;
vDbEx2() ; min(1): DISTINCT %LIBS,PRITABLE,JRNID FROM DBTBL9 WHERE %LIBS='SYSDEV' and PRITABLE=:V1 and MODE like '%I%'
 ;
 N vsql1,vsql3,vsql4
 S vsql1=$$BYTECHAR^SQLUTL(254)
 ;
 S vsql3=""
vEx2a4 S vsql3=$O(^DBTBL("SYSDEV",9,V1,vsql3),1) I vsql3="" Q 0
 S vsql4=$G(^DBTBL("SYSDEV",9,V1,vsql3))
 I '($P(vsql4,"|",5)["I") G vEx2a4
 Q 1
 ;
vDbEx3() ; min(1): DISTINCT %LIBS,PRITABLE,JRNID FROM DBTBL9 WHERE %LIBS='SYSDEV' and PRITABLE=:V2 and MODE like '%U%'
 ;
 N vsql1,vsql3,vsql4
 S vsql1=$$BYTECHAR^SQLUTL(254)
 ;
 S vsql3=""
vEx3a4 S vsql3=$O(^DBTBL("SYSDEV",9,V2,vsql3),1) I vsql3="" Q 0
 S vsql4=$G(^DBTBL("SYSDEV",9,V2,vsql3))
 I '($P(vsql4,"|",5)["U") G vEx3a4
 Q 1
 ;
vDbEx4() ; min(1): DISTINCT %LIBS,PRITABLE,JRNID FROM DBTBL9 WHERE %LIBS='SYSDEV' and PRITABLE=:V3 and MODE like '%D%'
 ;
 N vsql1,vsql3,vsql4
 S vsql1=$$BYTECHAR^SQLUTL(254)
 ;
 S vsql3=""
vEx4a4 S vsql3=$O(^DBTBL("SYSDEV",9,V3,vsql3),1) I vsql3="" Q 0
 S vsql4=$G(^DBTBL("SYSDEV",9,V3,vsql3))
 I '($P(vsql4,"|",5)["D") G vEx4a4
 Q 1
 ;
vDbEx5() ; min(1): DISTINCT %LIBS,FID,FKEYS FROM DBTBL1F WHERE TBLREF=:V1
 ;
 N vsql1,vsql3,vsql4,vsql5
 S vsql1=$$BYTECHAR^SQLUTL(254)
 ;
 S vsql3=""
vEx5a4 S vsql3=$O(^DBINDX(vsql3),1) I vsql3="" Q 0
 S vsql4=""
vEx5a6 S vsql4=$O(^DBINDX(vsql3,"FKPTR",V1,vsql4),1) I vsql4="" G vEx5a4
 S vsql5=""
 S vsql5=$O(^DBINDX(vsql3,"FKPTR",V1,vsql4,vsql5),1) I vsql5="" G vEx5a6
 Q 1
 ;
vOpen0(exe,vsql,vSelect,vFrom,vWhere,vOrderby,vGroupby,vParlist,vOff) ; Dynamic MDB ResultSet
 ;
 set sqlcur="checkAccessRights.rs2"
 N ER,vExpr,mode,RM,vOpen,vTok S ER=0 ;=noOpti
 ;
 S vExpr="SELECT "_vSelect_" FROM "_vFrom
 I vWhere'="" S vExpr=vExpr_" WHERE "_vWhere
 I vOrderby'="" S vExpr=vExpr_" ORDER BY "_vOrderby
 I vGroupby'="" S vExpr=vExpr_" GROUP BY "_vGroupby
 S vExpr=$$UNTOK^%ZS($$SQL^%ZS(vExpr,.vTok),vTok)
 ;
 S sqlcur=$O(vobj(""),-1)+1
 ;
 I $$FLT^SQLCACHE(vExpr,vTok,.vParlist)
 E  S vOpen=$$OPEN^SQLM(.exe,vFrom,vSelect,vWhere,vOrderby,vGroupby,vParlist,,1,,sqlcur) I 'ER D SAV^SQLCACHE(vExpr,.vParlist) s vsql=vOpen
 I ER S $ZE="0,"_$ZPOS_",%PSL-E-SQLFAIL,"_$TR($G(RM),$C(10,44),$C(32,126)),$EC=",U1001,"
 ;
 S vos8=vsql
 Q ""
 ;
vFetch0() ; MDB dynamic FETCH
 ;
 ; type public String exe(),sqlcur,vd,vi,vsql()
 ;
 I vsql=0 S rs2="" Q 0
 S vsql=$$^SQLF(.exe,.vd,.vi,.sqlcur)
 S rs2=vd
 S vos8=vsql
 S vos9=$G(vi)
 Q vsql
 ;
vOpen1() ; DI FROM DBTBL1D WHERE %LIBS='SYSDEV' AND FID=:V1 AND DI<>:V2 AND NOD=:N AND POS=:P
 ;
 ;
 S vos1=2
 D vL1a1
 Q ""
 ;
vL1a0 S vos1=0 Q
vL1a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(V1) I vos3="" G vL1a0
 S vos4=$G(V2) I vos4="",'$D(V2) G vL1a0
 S vos5=$G(N) I vos5="",'$D(N) G vL1a0
 S vos6=$G(P)
 S vos7=""
vL1a7 S vos7=$O(^DBINDX("SYSDEV","STR",vos3,vos5,vos6,vos7),1) I vos7="" G vL1a0
 I '(vos7'=vos4) G vL1a7
 Q
 ;
vFetch1() ;
 ;
 ;
 I vos1=1 D vL1a7
 I vos1=2 S vos1=1
 ;
 I vos1=0 S rs="" Q 0
 ;
 S rs=$S(vos7=vos2:"",1:vos7)
 ;
 Q 1
 ;
vOpen11() ; DI,SFT,SFD1,SFD2,SFP FROM DBTBL1D WHERE %LIBS='SYSDEV' AND FID=:TBL AND DI<>:CLN AND NOD=:N AND POS=:P ORDER BY SFT,POS
 ;
 ;
 S vOid=$G(^DBTMP($J))-1,^($J)=vOid K ^DBTMP($J,vOid)
 S vos1=2
 D vL11a1
 Q ""
 ;
vL11a0 S vos1=0 Q
vL11a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(TBL) I vos3="" G vL11a0
 S vos4=$G(CLN) I vos4="",'$D(CLN) G vL11a0
 S vos5=$G(N) I vos5="",'$D(N) G vL11a0
 S vos6=$G(P)
 S vos7=""
vL11a7 S vos7=$O(^DBINDX("SYSDEV","STR",vos3,vos5,vos6,vos7),1) I vos7="" G vL11a14
 I '(vos7'=vos4) G vL11a7
 S vos8=$G(^DBTBL("SYSDEV",1,vos3,9,vos7))
 S vd=$S(vos7=vos2:"",1:vos7)_$C(9)_$$getSf^UCCOLSF($P(vos8,"|",18),"","126","",1)_$C(9)_$$getSf^UCCOLSF($P(vos8,"|",18),"","126","",2)_$C(9)_$$getSf^UCCOLSF($P(vos8,"|",18),"","126","",3)
 S vd=vd_$C(9)_$$getSf^UCCOLSF($P(vos8,"|",18),"","126","",4)
 S vos9=$$getSf^UCCOLSF($P(vos8,"|",18),"","126","",1) S:vos9="" vos9=vos2 S ^DBTMP($J,vOid,1,vos9,vos7)=vd
 G vL11a7
vL11a14 S vos2=""
vL11a15 S vos2=$O(^DBTMP($J,vOid,1,vos2),1) I vos2="" G vL11a0
 S vos3=""
vL11a17 S vos3=$O(^DBTMP($J,vOid,1,vos2,vos3),1) I vos3="" G vL11a15
 Q
 ;
vFetch11() ;
 ;
 ;
 I vos1=1 D vL11a17
 I vos1=2 S vos1=1
 ;
 I vos1=0 S rs="" K ^DBTMP($J,vOid) Q 0
 ;
 S rs=^DBTMP($J,vOid,1,vos2,vos3)
 ;
 Q 1
 ;
vOpen12() ; DI FROM DBTBL1D WHERE %LIBS='SYSDEV' AND FID=:TBL AND NOD=:N AND POS=:P AND SFT IS NULL AND SFP IS NULL
 ;
 ;
 S vos1=2
 D vL12a1
 Q ""
 ;
vL12a0 S vos1=0 Q
vL12a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(TBL) I vos3="" G vL12a0
 S vos4=$G(N) I vos4="",'$D(N) G vL12a0
 S vos5=$G(P)
 S vos6=""
vL12a6 S vos6=$O(^DBINDX("SYSDEV","STR",vos3,vos4,vos5,vos6),1) I vos6="" G vL12a0
 S vos7=$G(^DBTBL("SYSDEV",1,vos3,9,vos6))
 I '($$getSf^UCCOLSF($P(vos7,"|",18),"","126","",1)="") G vL12a6
 I '($$getSf^UCCOLSF($P(vos7,"|",18),"","126","",4)="") G vL12a6
 Q
 ;
vFetch12() ;
 ;
 ;
 I vos1=1 D vL12a6
 I vos1=2 S vos1=1
 ;
 I vos1=0 S rs="" Q 0
 ;
 S vos7=$G(^DBTBL("SYSDEV",1,vos3,9,vos6))
 S rs=$S(vos6=vos2:"",1:vos6)
 ;
 Q 1
 ;
vOpen13() ; NOD,POS FROM DBTBL1D WHERE %LIBS='SYSDEV' AND FID=:TBL
 ;
 ;
 S vos1=2
 D vL13a1
 Q ""
 ;
vL13a0 S vos1=0 Q
vL13a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(TBL) I vos3="" G vL13a0
 S vos4=""
vL13a4 S vos4=$O(^DBTBL("SYSDEV",1,vos3,9,vos4),1) I vos4="" G vL13a0
 Q
 ;
vFetch13() ;
 ;
 ;
 I vos1=1 D vL13a4
 I vos1=2 S vos1=1
 ;
 I vos1=0 S rs="" Q 0
 ;
 S vos5=$G(^DBTBL("SYSDEV",1,vos3,9,vos4))
 S rs=$P(vos5,"|",1)_$C(9)_$P(vos5,"|",21)
 ;
 Q 1
 ;
vOpen14() ; FID FROM DBTBL1 WHERE %LIBS='SYSDEV' AND PARFID=:V1
 ;
 ;
 S vos1=2
 D vL14a1
 Q ""
 ;
vL14a0 S vos1=0 Q
vL14a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(V1) I vos3="",'$D(V1) G vL14a0
 S vos4=""
vL14a4 S vos4=$O(^DBINDX("SYSDEV","PARFID",vos3,vos4),1) I vos4="" G vL14a0
 Q
 ;
vFetch14() ;
 ;
 ;
 I vos1=1 D vL14a4
 I vos1=2 S vos1=1
 ;
 I vos1=0 S rs="" Q 0
 ;
 S rs=$S(vos4=vos2:"",1:vos4)
 ;
 Q 1
 ;
vOpen15() ; DI,TYP,CMP,ISMASTER,REQ,DFT FROM DBTBL1D WHERE %LIBS='SYSDEV' AND FID=:V1
 ;
 ;
 S vos1=2
 D vL15a1
 Q ""
 ;
vL15a0 S vos1=0 Q
vL15a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(V1) I vos3="" G vL15a0
 S vos4=""
vL15a4 S vos4=$O(^DBTBL("SYSDEV",1,vos3,9,vos4),1) I vos4="" G vL15a0
 Q
 ;
vFetch15() ;
 ;
 ;
 I vos1=1 D vL15a4
 I vos1=2 S vos1=1
 ;
 I vos1=0 S rs1d="" Q 0
 ;
 S vos5=$G(^DBTBL("SYSDEV",1,vos3,9,vos4))
 S rs1d=$S(vos4=vos2:"",1:vos4)_$C(9)_$P(vos5,"|",9)_$C(9)_$P(vos5,"|",16)_$C(9)_$P(vos5,"|",17)_$C(9)_$P(vos5,"|",15)_$C(9)_$P(vos5,"|",3)
 ;
 Q 1
 ;
vOpen16() ; ORDERBY FROM DBTBL8 WHERE %LIBS='SYSDEV' AND FID=:V2
 ;
 ;
 S vos6=2
 D vL16a1
 Q ""
 ;
vL16a0 S vos6=0 Q
vL16a1 S vos7=$$BYTECHAR^SQLUTL(254)
 S vos8=$G(V2) I vos8="" G vL16a0
 S vos9=""
vL16a4 S vos9=$O(^DBTBL("SYSDEV",8,vos8,vos9),1) I vos9="" G vL16a0
 Q
 ;
vFetch16() ;
 ;
 ;
 I vos6=1 D vL16a4
 I vos6=2 S vos6=1
 ;
 I vos6=0 S rs8="" Q 0
 ;
 S vos10=$G(^DBTBL("SYSDEV",8,vos8,vos9))
 S rs8=$P(vos10,"|",3)
 ;
 Q 1
 ;
vOpen2() ; TABLENAME FROM DBACCRTS WHERE TABLENAME='DBACCRTS'
 ;
 ;
 S vos1=2
 D vL2a1
 Q ""
 ;
vL2a0 S vos1=0 Q
vL2a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=""
vL2a3 S vos3=$O(^DBACCRTS("DBACCRTS",vos3),1) I vos3="" G vL2a0
 Q
 ;
vFetch2() ;
 ;
 ;
 I vos1=1 D vL2a3
 I vos1=2 S vos1=1
 ;
 I vos1=0 S rs="" Q 0
 ;
 S rs="DBACCRTS"
 ;
 Q 1
 ;
vOpen3() ; DELETERTS,INSERTRTS,SELECTRTS,UPDATERTS FROM DBACCRTS WHERE TABLENAME=:V1 AND USERCLASS='PUBLIC'
 ;
 ;
 S vos4=2
 D vL3a1
 Q ""
 ;
vL3a0 S vos4=0 Q
vL3a1 S vos5=$$BYTECHAR^SQLUTL(254)
 S vos6=$G(V1) I vos6="" G vL3a0
 I '($D(^DBACCRTS(vos6,"PUBLIC"))) G vL3a0
 Q
 ;
vFetch3() ;
 ;
 ;
 ;
 I vos4=0 S rs1="" Q 0
 ;
 S vos4=100
 S vos7=$G(^DBACCRTS(vos6,"PUBLIC"))
 S rs1=$P(vos7,"|",3)_$C(9)_$P(vos7,"|",1)_$C(9)_$P(vos7,"|",4)_$C(9)_$P(vos7,"|",2)
 S vos4=0
 ;
 Q 1
 ;
vOpen4() ; FID FROM DBTBL1 WHERE %LIBS='SYSDEV' AND PARFID=:V1
 ;
 ;
 S vos1=2
 D vL4a1
 Q ""
 ;
vL4a0 S vos1=0 Q
vL4a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(V1) I vos3="",'$D(V1) G vL4a0
 S vos4=""
vL4a4 S vos4=$O(^DBINDX("SYSDEV","PARFID",vos3,vos4),1) I vos4="" G vL4a0
 Q
 ;
vFetch4() ;
 ;
 ;
 I vos1=1 D vL4a4
 I vos1=2 S vos1=1
 ;
 I vos1=0 S rs="" Q 0
 ;
 S rs=$S(vos4=vos2:"",1:vos4)
 ;
 Q 1
 ;
vOpen5() ; DI FROM DBTBL1D WHERE %LIBS='SYSDEV' AND FID=:V1
 ;
 ;
 S vos1=2
 D vL5a1
 Q ""
 ;
vL5a0 S vos1=0 Q
vL5a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(V1) I vos3="" G vL5a0
 S vos4=""
vL5a4 S vos4=$O(^DBTBL("SYSDEV",1,vos3,9,vos4),1) I vos4="" G vL5a0
 Q
 ;
vFetch5() ;
 ;
 ;
 I vos1=1 D vL5a4
 I vos1=2 S vos1=1
 ;
 I vos1=0 S rs="" Q 0
 ;
 S rs=$S(vos4=vos2:"",1:vos4)
 ;
 Q 1
 ;
vOpen6() ; ACTBI,ACTAI,ACTBU,ACTAU,ACTBD,ACTAD FROM DBTBL7 WHERE %LIBS='SYSDEV' AND TABLE=:V1
 ;
 ;
 S vos1=2
 D vL6a1
 Q ""
 ;
vL6a0 S vos1=0 Q
vL6a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(V1) I vos3="" G vL6a0
 S vos4=""
vL6a4 S vos4=$O(^DBTBL("SYSDEV",7,vos3,vos4),1) I vos4="" G vL6a0
 Q
 ;
vFetch6() ;
 ;
 ;
 I vos1=1 D vL6a4
 I vos1=2 S vos1=1
 ;
 I vos1=0 S rs7="" Q 0
 ;
 S vos5=$G(^DBTBL("SYSDEV",7,vos3,vos4))
 S rs7=$P(vos5,"|",2)_$C(9)_$P(vos5,"|",5)_$C(9)_$P(vos5,"|",3)_$C(9)_$P(vos5,"|",6)_$C(9)_$P(vos5,"|",4)_$C(9)_$P(vos5,"|",7)
 ;
 Q 1
 ;
vOpen7() ; FID FROM DBTBL1F WHERE %LIBS='SYSDEV' AND TBLREF=:V1
 ;
 ;
 S vos6=2
 D vL7a1
 Q ""
 ;
vL7a0 S vos6=0 Q
vL7a1 S vos7=$$BYTECHAR^SQLUTL(254)
 S vos8=$G(V1) I vos8="",'$D(V1) G vL7a0
 S vos9=""
vL7a4 S vos9=$O(^DBINDX("SYSDEV","FKPTR",vos8,vos9),1) I vos9="" G vL7a0
 S vos10=""
vL7a6 S vos10=$O(^DBINDX("SYSDEV","FKPTR",vos8,vos9,vos10),1) I vos10="" G vL7a4
 Q
 ;
vFetch7() ;
 ;
 ;
 I vos6=1 D vL7a6
 I vos6=2 S vos6=1
 ;
 I vos6=0 S rsCasc="" Q 0
 ;
 S rsCasc=$S(vos9=vos7:"",1:vos9)
 ;
 Q 1
 ;
vOpen8() ; INSERTLOG,UPDATELOG,DELETELOG,SELECTLOG FROM DBAUDITDEF WHERE TABLENAME=:V1
 ;
 ;
 S vos1=2
 D vL8a1
 Q ""
 ;
vL8a0 S vos1=0 Q
vL8a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(V1) I vos3="" G vL8a0
 S vos4=""
vL8a4 S vos4=$O(^DBAUDITDEF(vos3,vos4),1) I vos4="" G vL8a0
 Q
 ;
vFetch8() ;
 ;
 ;
 I vos1=1 D vL8a4
 I vos1=2 S vos1=1
 ;
 I vos1=0 S rs="" Q 0
 ;
 S vos5=$G(^DBAUDITDEF(vos3,vos4))
 S rs=$P(vos5,"|",1)_$C(9)_$P(vos5,"|",2)_$C(9)_$P(vos5,"|",3)_$C(9)_$P(vos5,"|",4)
 ;
 Q 1
 ;
vOpen9() ; ACCKEYS,DBASE,DEL,EXIST,GLREF,LOG,PARFID,PSLPACKAGE,RECTYP FROM DBTBL1 WHERE %LIBS = 'SYSDEV' AND FID = :TBL
 ;
 N vOid
 ;
 S vOid=$O(vobj(""),-1)+1
 S vobj(vOid,0)=2
 S vobj(vOid,-1)="ResultSet"
 S vobj(vOid,-2)="$$vFetch9^"_$T(+0)
 S vobj(vOid,-3)="ACCKEYS,DBASE,DEL,EXIST,GLREF,LOG,PARFID,PSLPACKAGE,RECTYP"
 S vobj(vOid,-4)="U0T0N0N0T0L0U0T0N0"
 D vL9a1
 Q vOid
 ;
vL9a0 S vobj(vOid,0)=0 Q
vL9a1 S vobj(vOid,1)=$$BYTECHAR^SQLUTL(254)
 S vobj(vOid,2)=$G(TBL) I vobj(vOid,2)="" G vL9a0
 I '($D(^DBTBL("SYSDEV",1,vobj(vOid,2)))) G vL9a0
 Q
 ;
vFetch9(vOid) ;
 ;
 ;
 ;
 I vobj(vOid,0)=0 S vobj(vOid)="" Q 0
 ;
 S vobj(vOid,0)=100
 S vobj(vOid,4)=$G(^DBTBL("SYSDEV",1,vobj(vOid,2),10))
 S vobj(vOid,3)=$G(^DBTBL("SYSDEV",1,vobj(vOid,2),16))
 S vobj(vOid,6)=$G(^DBTBL("SYSDEV",1,vobj(vOid,2),22))
 S vobj(vOid,5)=$G(^DBTBL("SYSDEV",1,vobj(vOid,2),100))
 S vobj(vOid)=$P(vobj(vOid,3),"|",1)_$C(9)_$P(vobj(vOid,4),"|",15)_$C(9)_$P(vobj(vOid,4),"|",1)_$C(9)_$P(vobj(vOid,4),"|",13)_$C(9)_$P(vobj(vOid,5),"|",1)_$C(9)_$P(vobj(vOid,5),"|",5)_$C(9)_$P(vobj(vOid,4),"|",4)_$C(9)_$P(vobj(vOid,6),"|",11)_$C(9)_$P(vobj(vOid,5),"|",2)
 S vobj(vOid,0)=0
 ;
 Q 1
 ;
vRwsNxt(vOid) ; RowSet.next
 ;
 N vLst S vLst=$O(vobj(vOid,""),-1)
 I vobj(vOid,0)'>vLst S vobj(vOid,0)=vobj(vOid,0)+1
 Q vobj(vOid,0)'>vLst
 ;
vStrIsNum(vStr) ; String.isNumber
 ;
 Q vStr=+vStr
 ;
vCatch6 ; Error trap
 ;
 N vEx,$ET,$ES S vEx=$ZE,$EC="",$ET="Q",$ZE=""
 D ZX^UCGMR(voxMrk) Q 
 ;
vCatch5 ; Error trap
 ;
 N xNF,$ET,$ES S xNF=$ZE,$EC="",$ET="Q",$ZE=""
 I '($P(xNF,",",3)="%PSL-E-RECNOFL") Q
 S $P(xNF,",",4)="Undefined column"
 S $P(xNF,",",5)=TBL_"."_CLN
 S $ZE=xNF,$EC=",U1001,"
 D ZX^UCGMR(voxMrk) Q 
 ;
vCatch4 ; Error trap
 ;
 N error,$ET,$ES S error=$ZE,$EC="",$ET="Q",$ZE=""
 ;
 N rs,vos1,vos2,vos3,vos4,vos5  N V1 S V1=$P(tblDes,"|",1) S rs=$$vOpen8()
 ;
 F  Q:'$$vFetch8()  D
 .			;
 .   I ($P(rs,$C(9),1)>0) S logList=$S(((","_logList_",")[",insert,"):logList,1:$S((logList=""):"insert",1:logList_","_"insert"))
 .   I ($P(rs,$C(9),2)>0) S logList=$S(((","_logList_",")[",update,"):logList,1:$S((logList=""):"update",1:logList_","_"update"))
 .   I ($P(rs,$C(9),3)>0) S logList=$S(((","_logList_",")[",delete,"):logList,1:$S((logList=""):"delete",1:logList_","_"delete"))
 .   I ($P(rs,$C(9),4)>0) S logList=$S(((","_logList_",")[",select,"):logList,1:$S((logList=""):"select",1:logList_","_"select"))
 .			Q 
 D ZX^UCGMR(voxMrk) Q 
 ;
vCatch3 ; Error trap
 ;
 N vEx,$ET,$ES S vEx=$ZE,$EC="",$ET="Q",$ZE=""
 ; if call fails (e.g. V6.4) , there are no literals
 D ZX^UCGMR(voxMrk) Q 
 ;
vCatch2 ; Error trap
 ;
 N crspEx,$ET,$ES S crspEx=$ZE,$EC="",$ET="Q",$ZE=""
 D WARN^UCGM("CREATESP failed due to "_$P(crspEx,",",4))
 ;
 S where=$$getWhrKey(tblDes,recInst,2,.lvpm,.hostexpr)
 S sqlstm=sqlstm_where
 I (hostexpr="") S hostexpr=""""""
 ;
 S dbref="(0,"""_sqlstm_""",$C("_$P(tblDes,"|",10)_"),"_hostexpr
 ;
 I bNotFound S dbref=" S vEr=$$SELECT^%DBAPI"_dbref_",.vData,.vRm),"_$$lvpm(recInst,node,.lvpm)_"=vData I vEr<0 S $ZE=""0,""_$ZPOS_"",%PSL-E-SQLFAIL,""_$TR($G(vRm),$C(10,44),$C(32,126)),$EC="",U1001,"""
 E  S dbref="$$SELECTDATA^%DBAPI"_dbref_")"
 D ZX^UCGMR(voxMrk) Q 
 ;
vCatch1 ; Error trap
 ;
 N error,$ET,$ES S error=$ZE,$EC="",$ET="Q",$ZE=""
 ;
 N deleterts N insertrts N selectrts N updaterts
 N right
 ;
 N rs,vos1,vos2,vos3 S rs=$$vOpen2()
 ;
 I '$G(vos1) D ZX^UCGMR(voxMrk) Q  ; Not using access rights
 ;
 N rs1,vos4,vos5,vos6,vos7  N V1 S V1=$P(tblDes,"|",1) S rs1=$$vOpen3()
 ;
 I $$vFetch3() D
 .			;
 .   S deleterts=$P(rs1,$C(9),1)
 .   S insertrts=$P(rs1,$C(9),2)
 .   S selectrts=$P(rs1,$C(9),3)
 .   S updaterts=$P(rs1,$C(9),4)
 .			Q 
 E  S (deleterts,insertrts,selectrts,updaterts)=0
 ;
 F right="INSERT","UPDATE","DELETE","SELECT" D
 .			;
 .			N where S where="TABLENAME='"_$P(tblDes,"|",1)_"' AND "_$E(right,1,3)_"RESTRICT IS NOT NULL"
 .			;
 .			;     #ACCEPT DATE=03/11/2008; PGM=Dan Russell; CR=30801; Group=DYNAMIC
 .			N rs2,vos8,vos9,sqlcur,exe,sqlcur,vd,vi,vsql,vsub S rs2=$$vOpen0(.exe,.vsql,"TABLENAME","DBACCRTS",where,"","","",1)
 .			;
 .   I ''$G(vos8) S checkList=$S((checkList=""):($ZCONVERT(right,"L")_"Restrict"),1:checkList_","_($ZCONVERT(right,"L")_"Restrict"))
 .			E  D
 ..				;
 ..				I (right="INSERT"),(insertrts'>0) S checkList=$S((checkList=""):"insert",1:checkList_","_"insert")
 ..				E  I (right="UPDATE"),(updaterts'>0) S checkList=$S((checkList=""):"update",1:checkList_","_"update")
 ..				E  I (right="DELETE"),(deleterts'>0) S checkList=$S((checkList=""):"delete",1:checkList_","_"delete")
 ..				E  I (right="SELECT"),(selectrts'>0) S checkList=$S((checkList=""):"select",1:checkList_","_"select")
 ..				Q 
 .   Q 
 D ZX^UCGMR(voxMrk) Q 
