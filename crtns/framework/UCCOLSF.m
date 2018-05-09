 ; 
 ; **** Routine compiled from DATA-QWIK Procedure UCCOLSF ****
 ; 
 ; 02/24/2010 18:23 - pip
 ; 
 ;  #PACKAGE framework.psl
 ;  #OPTION  ResultClass ON
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
getMaster(recInst,TBL,CLN) ; column name of masterfield
 N sf
 N fields ; exchange String(), and cast as Row
 N dummy S dummy=$$getSfd^UCXDD(TBL,CLN,.fields)
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 D setOpti^UCGM(recInst,$$getLevel^UCGM(recInst),1) ; optimize off
 ;
 N comment S comment="Record"_TBL_".get"_CLN_"()"
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 N label S label=$$findSubr^UCGM("vCoMfG",comment)
 ;
 I '$$hasSubr^UCGM(label) D
 .	;
 .	N buf S buf=$$vopenBuf("(Record"_TBL_" vRec)",comment)
 .	D vaddBuff(buf," type String vMas = """"")
 .	N cnt
 .	F cnt=1:1:$order(fields(""),-1) D
 ..		S sf=fields(cnt)
 ..		N col S col=$P(sf,$C(126),1)
 ..		N tag S tag=""""_$P(sf,$C(126),2)_""""
 ..		N line S line=" set vMas = vMas.putSub( vRec."_$ZCONVERT(col,"L")_","_tag
 ..		;
 ..		N asc S asc=$P(sf,$C(126),3)
 ..		I (asc="") S line=line_","""""
 ..		E  S line=line_",$C("_asc_")"
 ..		S asc=$P(sf,$C(126),4)
 ..		I (asc="") S line=line_","""""
 ..		E  S line=line_",$C("_asc_")"
 ..		;
 ..		D vaddBuff(buf,line_","_$P(sf,$C(126),5)_")")
 ..		Q 
 .	D vaddBuff(buf," quit vMas")
 .	D INSERT^UCMETHOD(buf,label,"String")
 .	K vobj(+$G(buf)) Q 
 Q "$$"_label_"("_recInst_")"
 ;
 ; ---------------------------------------------------------------------
getMf2A(getval,vMas,code) ; code array (*3) /REFARR:W
 N i ; iterator
 N ln S ln=0 ; line counter for code()
 N sub ; TAB delimited sub-expression
 ;
 N head S head=""
 N tail S tail=""
 I $E(getval,1,2)="$$" D
 .	S head=$piece(getval,"(")_"(" S tail=")"
 .	S getval=$E(getval,$L(head)+1,$L(getval)-1)
 .	Q 
 E  I $E(getval,1)="(" D
 .	S head="(" S tail=")"
 .	S getval=$E(getval,2,$L(getval)-1)
 .	Q 
 ;
 N line S line=" set "_vMas_"="_$piece(getval,$char(9))
 ;
 F i=2:1:$L(getval,$char(9)) D
 .	S sub=$piece(getval,$char(9),i)
 .	I '($ZLENGTH(sub)+$ZLENGTH(line)'>1980) D
 ..		S ln=ln+1
 ..		S code(ln)=line
 ..		S line=" set "_vMas_"="_vMas
 ..		Q 
 .	S line=line_"_"_sub
 .	Q 
 S ln=ln+1
 ;
 I '(head="") S line=" set "_vMas_"="_head_$E(line,$F(line,"="),1048575)_tail
 S code(ln)=line
 Q 
 ;
 ; ---------------------------------------------------------------------
getMfdTp(sft,sfd1,sfd2,sfp) ; position   /NONUL
 I (sft=""),(sfd1="") Q 1
 I (sft="") Q 2
 Q 3
 ;
 ; ---------------------------------------------------------------------
getMfORC(cd) ; masterfield column descriptor
 I $P(cd,"|",15)=0 Q ""
 ;
 N sf
 N tn S tn=$P(cd,"|",1)
 N fields ; exchange String(), and cast as Row
 N dummy S dummy=$$getSfd^UCXDD(tn,$P(cd,"|",2),.fields)
 ;
 S sf=fields(1)
 N tp S tp=$$getMfdTp($P(sf,$C(126),2),$P(sf,$C(126),3),$P(sf,$C(126),4),$P(sf,$C(126),5))
 N sep1
 ;
 I tp=1 S sep1="" ; $E()
 E  S sep1="'"_$char($P(sf,$C(126),3))_"' || " ; $P()
 ;
 N cnt ; position iterator
 N getval S getval="" ; function return value
 N sfexp ; subfield retrieval expression
 N tdc ; PSLTable cache
 N byTnP ; byTnP(sft,sfp)=column
 ;
 D sortSfd(.fields,.byTnP)
 ;
 I tp=3 D
 .	N cn ; column name
 .	N sep2 ; subfieldMinor
 .	N tag S tag="" ; tag under construction
 .	N tagval ; delimited subfields for current tag
 .	;
 .	F  S tag=$order(byTnP(tag)) Q:tag=""  D
 ..		S cnt=$order(byTnP(tag,""))
 ..		S sep2="'"_$char(+$piece(byTnP(tag,cnt),"|",2))_"' || "
 ..		S tagval=""
 ..		F cnt=1:1:$order(byTnP(tag,""),-1) D
 ...			I '($D(byTnP(tag,cnt))#2) S sfexp="''"
 ...			E  D
 ....				S cn=$piece(byTnP(tag,cnt),"|")
 ....				S cd=$$getPslCln^UCXDD(tn,cn,.tdc)
 ....				S sfexp=tn_"."_cn
 ....				Q 
 ...			I '(tagval="") S tagval=tagval_" || "_sep2
 ...			S tagval=tagval_sfexp
 ...			Q 
 ..		I cnt>1 S tagval="("_tagval_")"
 ..		I '(getval="") S getval=getval_" || "
 ..		S getval=getval_"CASE WHEN "_tagval
 ..		S getval=getval_" IS NULL THEN '' ELSE "
 ..		S getval=getval_$E(sep1,1,2)_tag
 ..		S getval=getval_$E(sep2,2,1048575)
 ..		S getval=getval_tagval_" END"
 ..		Q 
 .	S getval="SUBSTR( "_getval_", 2)"
 .	Q 
 E  D
 .	;
 .	F cnt=1:1:$order(byTnP(" ",""),-1) D
 ..		I '($D(byTnP(" ",cnt))#2) S sfexp="''"
 ..		E  D
 ...			S cd=$$getPslCln^UCXDD(tn,byTnP(" ",cnt),.tdc)
 ...			S sfexp=tn_"."_byTnP(" ",cnt)
 ...			Q 
 ..		I '(getval="") S getval=getval_" || "_sep1
 ..		S getval=getval_sfexp
 ..		Q 
 .	S getval="("_getval_")"
 .	Q 
 ;
 Q getval
 ;
 ; ---------------------------------------------------------------------
getMfRDB(cd,recInst,lvpm) ; loc var pur map /NOREQ/MECH=REFARR:R
 Q $$getXfXDB(cd,recInst,2,.lvpm)
 ;
 ; ---------------------------------------------------------------------
getObjMet ; RecordTBL.getClm
 ;
 N table S table=$$tableNameOf^PSLClass(class)
 N column S column=$ZCONVERT($E(method,4,$L(method)),"U")
 ;
 S return=$$getMaster(objectName,table,column)
 Q 
 ;
 ; ---------------------------------------------------------------------
getOfXDB(cd,recInst) ; record instance variable
 Q $$getXfXDB(cd,recInst,1)
 ;
 ; ---------------------------------------------------------------------
getOldVal(recInst,TBL,CLN) ; column name of masterfield
 N sf
 N fields ; exchange String(), and cast as Row
 N dummy S dummy=$$getSfd^UCXDD(TBL,CLN,.fields)
 ;
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 D setOpti^UCGM(recInst,$$getLevel^UCGM(recInst),1) ; turn off object optimization
 ;
 N comment S comment="Record"_TBL_".old"_CLN_"()"
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 N label S label=$$findSubr^UCGM("vCoMfO",comment)
 ;
 I '$$hasSubr^UCGM(label) D
 .	;
 .	N buf S buf=$$vopenBuf("(Record"_TBL_" vRec)",comment)
 .	N sc S sc=$$getPslCln^UCXDD(TBL,CLN)
 .	N node S node=$P(sc,"|",3)
 .	I node'=+node S node=$S(node'["""":""""_node_"""",1:$$QADD^%ZS(node,""""))
 .	S node="vobj"_"(vRec,-100,"_node_","_$S(CLN'["""":""""_CLN_"""",1:$$QADD^%ZS(CLN,""""))_")"
 .	; tbd: if already calculated return without recalculting again
 .	D vaddBuff(buf," if "_node_".exists() quit "_node)
 .	D vaddBuff(buf," type String vMas = """"")
 .	N cnt
 .	F cnt=1:1:$order(fields(""),-1) D
 ..		S sf=fields(cnt)
 ..		N col S col=$P(sf,$C(126),1)
 ..		N tag S tag=""""_$P(sf,$C(126),2)_""""
 ..		N line S line=" set vMas = vMas.putSub( vRec."_$ZCONVERT(col,"L")_".oldVal,"_tag
 ..		;
 ..		N asc S asc=$P(sf,$C(126),3)
 ..		I (asc="") S line=line_","""""
 ..		E  S line=line_",$C("_asc_")"
 ..		S asc=$P(sf,$C(126),4)
 ..		I (asc="") S line=line_","""""
 ..		E  S line=line_",$C("_asc_")"
 ..		;
 ..		D vaddBuff(buf,line_","_$P(sf,$C(126),5)_")")
 ..		Q 
 .	D vaddBuff(buf," set "_node_" = vMas // store calculated value for multiple retrievals")
 .	D vaddBuff(buf," quit vMas")
 .	D INSERT^UCMETHOD(buf,label,"String")
 .	K vobj(+$G(buf)) Q 
 Q "$$"_label_"("_recInst_")"
 ;
 ; ---------------------------------------------------------------------
getSf(master,sft,sfd1,sfd2,sfp) ; position   /NONUL
 N tp S tp=$$getMfdTp(sft,sfd1,sfd2,sfp)
 I tp=1 Q $E(master,sfp) ; type 1: $EXTRACT()
 I tp=2 Q $piece(master,$char(sfd1),sfp) ; type 2: $PIECE()
 ;
 ; TYPE 3: TAG-delimited
 Q $piece($piece($piece(($char(sfd1)_master),$char(sfd1)_sft_$char(sfd2),2),$char(sfd1)),$char(sfd2),sfp)
 ;
 ; ---------------------------------------------------------------------
getSfMDB(master,sft,sfd1,sfd2,sfp) ; PSLCoumn.subfieldPosition
 N tp S tp=$$getMfdTp(sft,sfd1,sfd2,sfp)
 ;
 I tp=1 Q "$E("_master_","_sfp_")" ; $E()
 I tp=2 Q "$P("_master_",$C("_sfd1_"),"_sfp_")" ; $P()
 ;
 ; TYPE 3: TAG-delimited
 Q "$P($P($P($C("_sfd1_")_"_master_",$C("_sfd1_")_"""_sft_"""_$C("_sfd2_"),2),$C("_sfd1_")),$C("_sfd2_"),"_sfp_")"
 ;
 ; ---------------------------------------------------------------------
getXfXDB(mcd,recInst,oldOrCur,lvpm) ; loc var pur map /NOREQ/MECH=REFARR:R
 ;
 I $P(mcd,"|",15)=0 Q ""
 ;
 N sf
 N tn S tn=$P(mcd,"|",1)
 N fields ; exchange String(), and cast as Row
 N dummy S dummy=$$getSfd^UCXDD(tn,$P(mcd,"|",2),.fields)
 ;
 S sf=fields(1)
 N tp S tp=$$getMfdTp($P(sf,$C(126),2),$P(sf,$C(126),3),$P(sf,$C(126),4),$P(sf,$C(126),5))
 N sep1
 ;
 I tp=1 S sep1="" ; $E()
 E  S sep1=""""_$char($P(sf,$C(126),3))_"""_" ; $P()
 ;
 N cnt ; position iterator
 N getval S getval="" ; function return value
 N scd ; subfield PSLColumn instance
 N sfexp ; subfield retrieval expression
 N tdc ; PSLTable cache
 N byTnP ; byTnP(sft,sfp)=column
 ;
 D sortSfd(.fields,.byTnP)
 ;
 I tp=3 D
 .	N cn ; column name
 .	N sep2 ; subfieldMinor
 .	N tag S tag="" ; tag under construction
 .	N tagval ; delimited subfields for current tag
 .	;
 .	F  S tag=$order(byTnP(tag)) Q:tag=""  D
 ..		S cnt=$order(byTnP(tag,""))
 ..		S sep2=""""_$char($piece(byTnP(tag,cnt),"|",2))_"""_"
 ..		S tagval=""
 ..		F cnt=1:1:$order(byTnP(tag,""),-1) D
 ...			I '($D(byTnP(tag,cnt))#2) S sfexp=""""""
 ...			E  D
 ....				S cn=$piece(byTnP(tag,cnt),"|")
 ....				S scd=$$getPslCln^UCXDD(tn,cn,.tdc)
 ....				I oldOrCur=1 S sfexp=$$getOldExpr^UCXDD(scd,recInst,0)
 ....				I oldOrCur=2 S sfexp=$$getCurExpr^UCXDD(scd,recInst,0)
 ....				Q 
 ...			I '(tagval="") S tagval=tagval_"_"_sep2
 ...			S tagval=tagval_sfexp
 ...			Q 
 ..		I '(getval="") S getval=getval_$C(9)
 ..		S getval=getval_"$S("_tagval_"'?."_$E(sep2,1,3)_":"
 ..		S getval=getval_$E(sep1,1,2)_tag
 ..		S getval=getval_$E(sep2,2,4)_tagval
 ..		S getval=getval_",1:"""")"
 ..		Q 
 .	Q 
 E  D
 .	;
 .	F cnt=1:1:$order(byTnP(" ",""),-1) D
 ..		I '($D(byTnP(" ",cnt))#2) S sfexp=""""""
 ..		E  D
 ...			S scd=$$getPslCln^UCXDD(tn,byTnP(" ",cnt),.tdc)
 ...			I oldOrCur=1 S sfexp=$$getOldExpr^UCXDD(scd,recInst,0)
 ...			I oldOrCur=2 S sfexp=$$getCurExpr^UCXDD(scd,recInst,0)
 ...			Q 
 ..		I '(getval="") S getval=getval_$C(9)
 ..		I cnt>1 S getval=getval_sep1
 ..		S getval=getval_sfexp
 ..		Q 
 .	;
 .	I tp=2 S getval="$$RTCHR^%ZFUNC("_getval_","_$E(sep1,1,$L(sep1)-1)_")"
 .	E  S getval="("_getval_")"
 .	Q 
 ;
 Q getval
 ;
 ; ---------------------------------------------------------------------
rtGetMf(TBL,CLN,recInst) ; RecordTBL instance variable
 N sf
 N fields ; exchange String(), and cast as Row
 N dummy S dummy=$$getSfd^UCXDD(TBL,CLN,.fields)
 ;
 N masVal S masVal=""
 N cnt
 F cnt=1:1:$order(fields(""),-1) D
 .	S sf=fields(cnt)
 .	N col S col=$P(sf,$C(126),1)
 .	;
 .	N cd S cd=$$getPslCln^UCXDD(TBL,col)
 .	N nod S nod=$$getCurNode^UCXDD(cd,0)
 .	N pos S pos=$P(cd,"|",4)
 .	N dlm S dlm=$P(cd,"|",5)
 .	;
 .	N subVal
 .	I (nod="") S subVal=$piece(vobj(recInst),$char(dlm),pos)
 .	E  S subVal=$piece(vobj(recInst,nod),$char(dlm),pos)
 .	;
 .	N sfd1 S sfd1=$P(sf,$C(126),3) I sfd1>0 S sfd1=$char(sfd1)
 .	N sfd2 S sfd2=$P(sf,$C(126),4) I sfd2>0 S sfd2=$char(sfd2)
 .	;
 .	S masVal=$$vStrPSUB(masVal,subVal,$P(sf,$C(126),2),sfd1,sfd2,$P(sf,$C(126),5))
 .	Q 
 Q masVal
 ;
 ; ---------------------------------------------------------------------
rtGetSf(TBL,CLN,recInst) ; RecordTBL instance variable
 N cd S cd=$$getPslCln^UCXDD(TBL,CLN)
 N nod S nod=$$getCurNode^UCXDD(cd,0)
 N master
 ;
 I (nod="") S master=$piece(vobj(recInst),$char($P(cd,"|",5)),$P(cd,"|",4))
 E  S master=$piece(vobj(recInst,nod),$char($P(cd,"|",5)),$P(cd,"|",4))
 ;
 Q $$getSf(master,$P(cd,"|",10),$P(cd,"|",11),$P(cd,"|",12),$P(cd,"|",13))
 ;
 ; ---------------------------------------------------------------------
rtMfORC(TBL,CLN) ; masterfield column name
 N cd S cd=$$getPslCln^UCXDD(TBL,CLN)
 Q $$getMfORC(cd)
 ;
 ; ---------------------------------------------------------------------
rtMfRDB(TBL,CLN,recInst) ; 
 N cd S cd=$$getPslCln^UCXDD(TBL,CLN)
 Q $$getMfRDB(cd,recInst)
 ;
 ; ---------------------------------------------------------------------
setMaster(TBL,CLN,bAudit) ; Audit flag
 N fields ; exchange String(), and cast as Row
 N dummy S dummy=$$getSfd^UCXDD(TBL,CLN,.fields)
 ;
 N comment S comment="Record"_TBL_".set"_CLN_"("_bAudit_")"
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 N label S label=$$findSubr^UCGM("vCoMfS",comment)
 ;
 I '$$hasSubr^UCGM(label) D
 .	;
 .	N buf S buf=$$vopenBuf("(Record"_TBL_" vRec, String vVal)",comment)
 .	;
 .	N cd S cd=$$getPslCln^UCXDD(TBL,CLN)
 .	N code S code=$$setMfXDB(cd,"vRec","vVal",bAudit)
 .	N cnt
 .	F cnt=1:1:$L(code,$char(9)) D vaddBuff(buf,$piece(code,$char(9),cnt))
 .	;
 .	D vaddBuff(buf,"quit")
 .	D INSERT^UCMETHOD(buf,label,"void")
 .	K vobj(+$G(buf)) Q 
 Q label
 ;
 ; ---------------------------------------------------------------------
setMfXDB(cd,recInst,newval,mode,RdbCodeForm,lvpm) ; loc var pur map /NOREQ/MECH=REFARR:R
 ;
 N bAudit S bAudit=(mode#3)>0
 N cdsf ; subfield column descriptor
 N cnt ; subfield iterator
 N col ; column name
 N fields ; exchange String(), and cast as Row
 N recVar ; variable name (if recInst.isNumber())
 N rightval ; rightexpr to extract sf from new mf
 N setMf S setMf="" ; return value
 N sfp ; subfield position
 N dummy S dummy=$$getSfd^UCXDD($P(cd,"|",1),$P(cd,"|",2),.fields)
 N sf
 N td S td=$$getPslTbl^UCXDD($P(cd,"|",1),0)
 ;
 I (recInst=+recInst) S recVar=$$dec2ovs^UCREC4OP(+recInst)
 E  S recVar=recInst
 ;
 I '$$isVar^UCGM(newval),($P(td,"|",8)'="GTM") S setMf=" N vSetMf S vSetMf="_newval S newval="vSetMf"
 I '($P(td,"|",8)'="GTM"),bAudit S setMf=setMf_" N vSetMf S vSetMf="_$$getCurExpr^UCXDD(cd,recVar,0)
 ;
 F cnt=1:1:$order(fields(""),-1) D
 .	S sf=fields(cnt)
 .	S col=$P(sf,$C(126),1)
 .	S cdsf=$$getPslCln^UCXDD($P(cd,"|",1),col)
 .	S sfp=$P(sf,$C(126),5) I (sfp="") S sfp=1
 .	;
 .	I ($P(td,"|",8)'="GTM") D
 ..		I '(setMf="") S setMf=setMf_$C(9)
 ..		S rightval=$$getSfMDB(newval,$P(sf,$C(126),2),$P(sf,$C(126),3),$P(sf,$C(126),4),sfp)
 ..		S setMf=setMf_$$getUpdCode^UCXDD(cdsf,recInst,rightval,mode,RdbCodeForm)
 ..		Q 
 .	E  I bAudit D
 ..		S rightval=$$getSfMDB("vSetMf",$P(sf,$C(126),2),$P(sf,$C(126),3),$P(sf,$C(126),4),sfp)
 ..		S rightval=$$getUpdAudit^UCXDD(cdsf,recVar,rightval,mode#3=2)
 ..		I '(setMf="") S setMf=setMf_$C(9)
 ..		S setMf=setMf_rightval
 ..		Q 
 .	Q 
 I '($P(td,"|",8)'="GTM") D
 .	I '(setMf="") S setMf=setMf_$C(9)
 .	S setMf=setMf_" S "_$$getCurExpr^UCXDD(cd,recVar,1)_"="_newval_","_$$cdNodChg^UCXDD(recVar,$$getOldNode^UCXDD(cd,1))_"="""""
 .	Q 
 ;
 Q setMf
 ;
 ; ---------------------------------------------------------------------
setObjMet ; RecordTBL.setCln
 ;
 N table S table=$$tableNameOf^PSLClass(class)
 N column S column=$ZCONVERT($E(method,4,$L(method)),"U")
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 N isAudit S isAudit=$$getAtt^UCGM(objectName,,12)
 ;
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 D setOpti^UCGM(objectName,,-1) ; turn off object optimization
 ;
 S return=$$setMaster(table,column,isAudit)_"("_objectName_","_actual(1)_")"
 Q 
 ;
 ; ---------------------------------------------------------------------
setSf(master,subval,sft,sfd1,sfd2,sfp) ; subfield position
 I (sft=""),(sfd1="") S $E(master,sfp)=subval Q master
 ;
 N d1 S d1=$char(sfd1)
 I (sft="") S $piece(master,d1,sfp)=subval Q master
 ;
 N d2 S d2=$char(sfd2)
 I (master="") S $piece(master,d2,sfp)=subval Q sft_d2_master
 ;
 N field S field=$piece($piece((d1_master),d1_sft_d2,2),d1)
 I '(field="") D  ; code to remove "old" value
 .	N z S z=d1_sft_d2_field
 .	S master=$piece((d1_master),z)_$piece((d1_master),z,2)
 .	I $E(master,1)=d1 S master=$E(master,2,1048575)
 .	Q 
 S $piece(field,d2,sfp)=subval
 I (master="") Q sft_d2_field
 Q master_d1_sft_d2_field
 ;
 ; ---------------------------------------------------------------------
setSfMDB(master,newval,sft,sfd1,sfd2,sfp) ; PSLCoumn.subfieldPosition
 N code S code=""
 ;
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 I $$isVar^UCGM(master)!$$isArr^UCGM(master) D
 .	; type 1: $EXTRACT()
 .	I (sft=""),(sfd1="") S code="$E("_master_","_sfp_")="_newval
 .	;
 .	; type 2: $PIECE()
 .	I (sft="") S code="$P("_master_",$C("_sfd1_"),"_sfp_")="_newval
 .	Q 
 I '(code="") Q code
 ;
 ; TYPE 3: TAG-delimited, or master not directly assignable
 N d1 S d1=sfd1
 N d2 S d2=sfd2
 I (d1="") S d1=""""""
 I (d2="") S d2=""""""
 Q master_"=$$setSf^UCCOLSF("_master_","_newval_","""_sft_""","_d1_","_d2_","_sfp_")"
 ;
 ; ---------------------------------------------------------------------
sortSfd(sfd,byTnP) ; byTnP(sft,sfp)=columnname [| sft2]
 ;
 N cnt
 N sf
 N sfp
 N sft
 N sfd2
 F cnt=1:1:$order(sfd(""),-1) D
 .	S sf=sfd(cnt)
 .	S sfp=$P(sf,$C(126),5) I (sfp="") S sfp=1
 .	S sft=$P(sf,$C(126),2)
 .	I (sft="") S sft=" " S sfd2=""
 .	E  S sfd2="|"_$P(sf,$C(126),4)
 .	S byTnP(sft,sfp)=$P(sf,$C(126),1)_sfd2
 .	Q 
 Q 
 ;  #OPTION ResultClass ON
vSIG() ; 
 Q "61233^52291^Dan Russell^36588" ; Signature - LTD^TIME^USER^SIZE
 ; ----------------
 ;  #OPTION ResultClass 1
vopenBuf(v1,v2) ; PSL.openBuffer
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 N vOid
 S vOid=$O(vobj(""),-1)+1 S vobj(vOid,-1)="PSLBuffer"
 I $E(v1,1)'="(",'(v1="") S v1="("_v1_")"
 S vobj(vOid,-2)=v1
 S vobj(vOid,-3)=v2
 S vobj(vOid,1)=v1_" // "_v2
 Q vOid
 ; ----------------
 ;  #OPTION ResultClass 1
vaddBuff(object,p1) ; PSLBuffer.add
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 N line
 S line=$order(vobj(object,""),-1)+1
 S vobj(object,line)=" "_p1
 Q 
 ; ----------------
 ;  #OPTION ResultClass 1
vStrPSUB(object,ins,tag,del1,del2,pos) ; String.putSub passing Strings
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 I (pos="") S pos=1
 I (tag=""),(del1="") S $E(object,pos)=ins Q object
 I $L(del1)>1 S $ZE="0,"_$ZPOS_","_"%PSL-E-STRPUTSUB",$EC=",U1001,"
 I (tag="") S $piece(object,del1,pos)=ins Q $$RTCHR^%ZFUNC(object,del1)
 I (del2="") S del2=del1
 I $L(del2)>1 S $ZE="0,"_$ZPOS_","_"%PSL-E-STRPUTSUB",$EC=",U1001,"
 I del1=del2,pos>1 S $ZE="0,"_$ZPOS_","_"%PSL-E-STRPUTSUB",$EC=",U1001,"
 I (object="") S $piece(object,del2,pos)=ins Q tag_del2_object
 N field S field=$piece($piece((del1_object),(del1_tag_del2),2),del1,1)
 I '(field="") D
 .	N z S z=del1_tag_del2_field
 .	S object=$piece((del1_object),z,1)_$piece((del1_object),z,2)
 .	I $E(object,1)=del1 S object=$E(object,2,1048575)
 .	Q 
 S $piece(field,del2,pos)=ins
 I (object="") Q tag_del2_field
 Q object_del1_tag_del2_field
