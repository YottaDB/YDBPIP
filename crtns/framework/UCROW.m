 ; 
 ; **** Routine compiled from DATA-QWIK Procedure UCROW ****
 ; 
 ; 02/24/2010 18:23 - pip
 ; 
 ;  #PACKAGE framework.psl
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
classNew ; Class constructor for new Row object
 ;
 N varPtr
 ;
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 I ($D(var)#2) S varPtr=$$getNew^UCGM(var,varLevel)
 E  S varPtr=""
 ;
 I (varPtr="") D ERROR^UCGM("Row object can only be asigned to properly declared variable") Q 
 ;
 N del S del=$get(actual(3))
 N list S list=$$buildList(actual(2),.del)
 ;
 I (del=""!(del="""""")) S del=$$getDelCT("") ; not filled by template
 ;
 S struct("Row",subRou,var,varPtr)=del_tab_list
 S postProc("Row")="pp^"_$T(+0)
 ;
 I method="new" S return="$C(-1)" ; Class.new
 Q 
 ;
 ; ---------------------------------------------------------------------
actualPar(tag,parNum) ; Return actual parameter value
 I 'parNum Q ""
 ;
 N return S return="" N tok N z
 N cnt N ptr
 ;
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 S z=$$TOKEN^%ZS($E($piece(tag,"(",2),1,$L(tag)-1),.tok)
 ;
 S cnt=0 S ptr=0
 ;
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 F  S return=$$ATOM^%ZS(z,.ptr,",",.tok) D  Q:ptr=0!(cnt=parNum) 
 .	;
 .	I return="," Q 
 .	S cnt=cnt+1
 .	;
 .	; found type specification, get next atom
 .	;   #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 .	I $E(z,ptr+1)=" " S return=$$ATOM^%ZS(z,.ptr,",",.tok)
 .	Q 
 I ptr=0 Q ""
 Q return
 ;
 ; ---------------------------------------------------------------------
buildList(list,del) ; delimiter
 ;
 I $$isLit^UCGM(list) D
 .	;
 .	S list=$$QSUB^%ZS(list,"""")
 .	;
 .	; Template syntax begins with sentinal character #
 .	I ($E(list,1)="#") D  I ER Q 
 ..		;
 ..		S list=$$template(list,.del)
 ..		S list=$$QSUB^%ZS(list,"""")
 ..		Q 
 .	;
 .	N i
 .	I '(list="") F i=1:1:$L(list,",") D
 ..		;
 ..		N col S col=$piece(list,",",i)
 ..		I '(col=""),($piece(col," ",2)="") S col="String "_col
 ..		S $piece(col," ",2)=$ZCONVERT($piece(col," ",2),"U")
 ..		S $piece(list,",",i)=col
 ..		Q 
 .	;
 .	S list=$S(list'["""":""""_list_"""",1:$$QADD^%ZS(list,""""))
 .	Q 
 ;
 Q list
 ;
getCol ; Get column value
 N vo6
 ;
 S postProc("Row")="pp^"_$T(+0)
 ;
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 N varPtr S varPtr=$$getNew^UCGM(objectName,objectLevel)
 ;
 N list N del
 ;
 N z S z=$get(struct("Row",subRou,objectName,varPtr))
 ;
 S del=$$getDelCT(z) S list=$piece(z,tab,2) ; FSCW CR11984
 ;
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 I (list=""),$$getScope^UCGM(objectName,objectLevel)["FORMAL" D  Q 
 .	;
 .	S struct("Row",subRou,objectName,varPtr,msrc+1)=""
 .	S return=$$getColRt("","","","") ; force vRwGC()
 .	S return=$C(6)_objectName_"."_ref_$C(6)
 .	S class="Primitive"
 .	Q 
 ;
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 I fset D setInst^UCGM(objectName,msrc,"")
 ;
 S vo6=class S return=$$getPos(list,objectName,ref,del,.vo6) S class=vo6
 ;
 Q 
 ;
getPos(list,var,col,del,cls) ; return type of column /NOREQ/MECH=REF:W
 S cls="Primitive" ; default in case of indirection or runtime
 ;
 I ($E(col,1)="@") Q $$getColRt(var,list,col,del) ; Indirection
 ;
 S col=$ZCONVERT(col,"U") ; Case insensitive
 ;
 I '$$isLit^UCGM(list) Q $$getColRt(var,list,col,del) ; Variable
 ;
 S list=$$QSUB^%ZS(list,"""")
 ;
 N y S y=$F(list," "_col)
 I y=0 D ERROR^UCGM("Invalid column reference: "_col) Q """"""
 ;
 N pos S pos=$L($E(list,1,y-$L(col)),",")
 ;
 S cls=$piece($piece(list,",",pos)," ",1) ; Class of column
 ;
 Q "$P("_var_","_del_","_pos_")"
 ;
 ; ---------------------------------------------------------------------
pp ; Post processor for row class, called after program is parsed
 ;
  ; calls(subRou,dcLnr,tag)
 ;
 N cls S cls=pslPrsr("moduleName") N subRou S subRou=cls_"."
 F  S subRou=$order(pslPrsr("pslMtd",subRou)) Q:$piece(subRou,".")'=cls  D
 .	;if subRou["^" quit  // external call, ignore
 .	;
 .	; Skip this subroutine if there aren't Row parameters
 .	N omd S omd=pslPrsr("pslMtd",subRou)
 .	I $P(omd,$C(9),5)'[" Row " Q 
 .	;
 .	N newPtr S newPtr=$P(omd,$C(9),8)
 .	N pubAcc S pubAcc=($P(omd,$C(9),6)>0)
 .	N mtd S mtd=$piece(subRou,".",2)
 .	;
 .	;   #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 .	I $$isNamePSL^UCGM(mtd) Q  ; exclude PSL generated methods
 .	;
 .	N i
 .	F i=1:1:$$getFpCount^PSLMethod(.omd) D
 ..		;
 ..		I $$getFpClass^PSLMethod(.omd,i)'="Row" Q 
 ..		;
 ..		; fp of class Row
 ..		N frmlPar S frmlPar=$$getFpVsig^PSLMethod(.omd,i)
 ..		;
 ..		I pubAcc S struct("Row",mtd,frmlPar,newPtr)=""
 ..		E  D ppsub(subRou,frmlPar,newPtr)
 ..		;
 ..		D patch(mtd,$piece(frmlPar,"("),newPtr)
 ..		Q 
 .	Q 
 ;
 S subRou=""
 F  S subRou=$order(calls(subRou)) Q:(subRou="")  D
 .	;
 .	N callat S callat=""
 .	F  S callat=$order(calls(subRou,callat)) Q:(callat="")  D
 ..		;
 ..		N called S called=""
 ..		F  S called=$order(calls(subRou,callat,called)) Q:(called="")  I (called["Row ") D patchCalls(subRou,callat,called)
 ..		Q 
 .	Q 
 ;
 Q 
 ;
 ; ---------------------------------------------------------------------
patch(subRou,frmlPar,newPtr) ; line where frmlPar is declared
 ;
 N ER S ER=0
 ;
 N z S z=$get(struct("Row",subRou,frmlPar,newPtr))
 ;
 N del S del=$$getDelCT(z)
 N list S list=$piece(z,$char(9),2)
 ;
 ; Build code to parse list and del from Row object
 I (list="") D
 .	;
 .	; Get the formal parameters and patch
 .	;
 .	;   #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 .	S del=$$nxtSym^UCGM() ; Get delimiter variable
 .	;
 .	;   #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 .	S list=$$nxtSym^UCGM() ; get list variable
 .	;
 .	S struct("Row",subRou,frmlPar,newPtr)=del_$char(9)_list
 .	;
 .	;type Number lptr = labels(subRou).codeLine
 .	N code S code=msrc(newPtr)
 .	;
 .	N y S y=$F(code,"("_frmlPar)
 .	I y=0 S y=$F(code,","_frmlPar)
 .	I y=0!'("),"[$E(code,y)) D ERROR^UCGM("Parameter: "_frmlPar_" expected in formal list: "_code) Q 
 .	;
 .	S code=$E(code,1,y-1)_","_del_","_list_$E(code,y,1048575)
 .	S msrc(newPtr)=code
 .	Q 
 ;
 N test S test=$C(6)_frmlPar_"."
 N line S line=0
 F  S line=$order(struct("Row",subRou,frmlPar,newPtr,line)) Q:(line="")  D
 .	;
 .	N y
 .	F  S y=$F(msrc(line),test,0) Q:y=0  D
 ..		N yz S yz=$F(msrc(line),$C(6),y)
 ..		N ref S ref=$E(msrc(line),y,yz-2)
 ..		S ref=$$getPos(list,frmlPar,ref,del)
 ..		S msrc(line)=$E(msrc(line),1,y-$L(test)-1)_ref_$E(msrc(line),yz,1048575)
 ..		Q 
 .	Q 
 ;
 Q 
 ;
 ; ---------------------------------------------------------------------
ppsub(subRou,frmlPar,newPtr) ; Replace column reference tokens
  ; called(tag,subRou,dcLnr)
 ;
 N callat
 N actPar N actPars N actPtr N caller N srtag N r1 N r2
 N omd S omd=pslPrsr("pslMtd",subRou)
 ;
 N parNum S parNum=$$getFpPosition^PSLMethod(.omd,frmlPar)
 ;
 S srtag=$piece(subRou,".",2)_"("
 F  S srtag=$order(called(srtag)) Q:'($E(srtag,1,$L((subRou_"(")))=(subRou_"("))  D
 .	;
 .	S actPar=$$actualPar(srtag,parNum)
 .	;
 .	I (actPar="") S actPar=frmlPar ; Global scope - for now
 .	;
 .	S caller=""
 .	F  S caller=$order(called(srtag,caller)) Q:(caller="")  D
 ..		I caller=subRou Q 
 ..		;
 ..		S callat=""
 ..		F  S callat=$order(called(srtag,caller,callat)) Q:(callat="")  D
 ...			;
 ...			S actPtr=$order(struct("Row",caller,actPar,callat+1),-1)
 ...			;
 ...			I (actPtr="") S r1=""
 ...			E  S r1=$get(struct("Row",caller,actPar,actPtr))
 ...			;
 ...			I '$$isLit^UCGM($piece(r1,$char(9),2)) S r1=""
 ...			;
 ...			I '($D(struct("Row",subRou,frmlPar,newPtr))#2) S struct("Row",subRou,frmlPar,newPtr)=r1 Q 
 ...			;
 ...			S r2=struct("Row",subRou,frmlPar,newPtr)
 ...			;
 ...			; if '(r2.piece($C(9),2) = r1.piece($C(9),2)) set struct("Row",subRou,frmlPar,newPtr) = ""
 ...			I r2'=r1 S struct("Row",subRou,frmlPar,newPtr)=""
 ...			;
 ...			Q 
 ..		Q 
 .	Q 
 ;
 Q 
 ;
 ; ---------------------------------------------------------------------
patchCalls(subRou,callat,called) ; called tag: entryref(type1 ap1, type2 ap2)
 ;
 N actPtr N newPtr N ptr S ptr=0 N parnum S parnum=1 N y
 N actPar N actPars N atom N code N del N frmlPar N label N list N rec N tok
 ;
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 S called=$$TOKEN^%ZS(called,.tok) ; Tokenize it
 ;
 S label=$piece(called,"(",1)
 S actPars=$E(called,$F(called,"("),$L(called)-1)
 ;
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 F  S atom=$$ATOM^%ZS(actPars,.ptr,",",tok) D  I ptr=0 Q 
 .	I atom="," S parnum=parnum+1 Q 
 .	I ptr,atom="Row" D
 ..		;
 ..		;    #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 ..		S actPar=$$ATOM^%ZS(actPars,.ptr,",",tok)
 ..		S rec=""
 ..		;
 ..		I '(label["^") D
 ...			;
 ...			N omd S omd=pslPrsr("pslMtd",pslPrsr("moduleName")_"."_label)
 ...			I $P(omd,$C(9),6)>0 Q 
 ...			;
 ...			S newPtr=$P(omd,$C(9),8)
 ...			;set frmlPars = labels(label).formalList
 ...			;
 ...			S frmlPar=$$getFpVsig^PSLMethod(.omd,parnum)
 ...			S rec=$get(struct("Row",label,frmlPar,newPtr))
 ...			Q 
 ..		;
 ..		I '(rec=""),$$isLit^UCGM($piece(rec,$char(9),2)) Q 
 ..		;
 ..		S actPtr=$order(struct("Row",subRou,actPar,callat+1),-1)
 ..		S rec=$get(struct("Row",subRou,actPar,actPtr))
 ..		;
 ..		S del=$$getDelCT(rec) S list=$piece(rec,$char(9),2)
 ..		;
 ..		S code=msrc(callat)
 ..		S y=$F(code,label_"(",0)
 ..		I y S y=$F(code,actPar,y)
 ..		I y,'(",)"[$E(code,y)) S y=0
 ..		I y,'("(,."[$E(code,y-$L(actPar)-1)) S y=0
 ..		;    #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 ..		I y=0 D warnGroup^UCGM("MISMATCH","Row instance passed to subroutine that does not expect Row: "_called) Q 
 ..		;
 ..		S code=$E(code,1,y-1)_","_del_","_list_$E(code,y,1048575)
 ..		S msrc(callat)=code
 ..		Q 
 .	Q 
 ;
 Q 
 ;
getColRt(rec,list,ref,del) ; property delimiter
 ;
 I '$$hasSubr^UCGM("vRwGC") D
 .	;
 .	N buf S buf=$$vopenBuf("(String vList,String vRef)","Dynamic column position lookup")
 .	D vaddBuff(buf,"")
 .	D vaddBuff(buf,"if vRef.isNull() quit """"")
 .	D vaddBuff(buf,"if vRef.toNumber()>0 quit vRef")
 .	D vaddBuff(buf,"")
 .	D vaddBuff(buf,"set vList = vList.upperCase(), vRef = vRef.upperCase()")
 .	D vaddBuff(buf,"type Number vP = (vList_"","").find("" ""_vRef_"","")")
 .	D vaddBuff(buf,"if vP = 0 set vP = ("",""_vList_"","").find("",""_vRef_"","") if vP = 0 quit """"")
 .	D vaddBuff(buf,"quit vList.extract( 1, vP - vRef.length()).length("","")")
 .	;
 .	D INSERT^UCMETHOD(buf,"vRwGC","String")
 .	K vobj(+$G(buf)) Q 
 ;
 I ($E(ref,1)="@") S ref=$E(ref,2,1048575)
 E  S ref=$S(ref'["""":""""_ref_"""",1:$$QADD^%ZS(ref,""""))
 ;
 Q "$P("_rec_","_del_",$$"_"vRwGC"_"("_list_","_ref_"))"
 ;
getDel ; get the delimiter list of a Row object
 ;
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 N newPtr S newPtr=$$getNew^UCGM(objectName,objectLevel)
 ;
 N rec S rec=$get(struct("Row",subRou,objectName,newPtr))
 ;
 S postProc("Row")="pp^"_$T(+0)
 ;
 S return=$$getDelCT(rec) ; FSCW CR 11984: use $$getDelCT()
 ;
 Q 
 ;
getDelCT(rowDes) ; rowDescriptor (delim tab proplist /REQ/NONULL
 I '($piece(rowDes,$char(9))="") Q $piece(rowDes,$char(9))
 Q "$C(9)"
 ;
getProp ; get the properties list of a Row object
 ;
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 N newPtr S newPtr=$$getNew^UCGM(objectName,objectLevel)
 ;
 N rec S rec=$get(struct("Row",subRou,objectName,newPtr))
 ;
 S postProc("Row")="pp^"_$T(+0)
 I '($piece(rec,$char(9),2)="") S return=$piece(rec,$char(9),2)
 Q 
 ;
setProp ; Set the properties list of a Row object
 ;
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 N newPtr S newPtr=$$getNew^UCGM(objectName,objectLevel)
 ;
 N rec S rec=$get(struct("Row",subRou,objectName,newPtr))
 ;
 N del S del=$piece(rec,$char(9))
 N list S list=$piece(rec,$char(9),2)
 ;
 ; Currently disallow multiple definitions, causes conflicts in post processor
 I '(list="") D ERROR^UCGM("ColumnList definition already exists: "_list) Q 
 ;
 S $piece(rec,$char(9),2)=$$buildList(actual(1),.del)
 S $piece(rec,$char(9))=del
 ;
 S struct("Row",subRou,objectName,newPtr)=rec
 S postProc("Row")="pp^"_$T(+0)
 Q 
 ;
setDel ; Set the delimiter attribute of a Row object
 ;
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 N newPtr S newPtr=$$getNew^UCGM(objectName,objectLevel)
 ;
 N rec S rec=$get(struct("Row",subRou,objectName,newPtr))
 ;
 N del S del=actual(1)
 I (del=""!(del="""""")) S del=$$getDelCT("")
 ;
 I '$$isLit^UCGM(del),$ZCONVERT(del,"U")'?1"$C".A1"("1.N1")" S del="$S("_del_"]"""":"_del_",1:$C(9))"
 ;
 S $piece(rec,$char(9))=del
 S struct("Row",subRou,objectName,newPtr)=rec
 S postProc("Row")="pp^"_$T(+0)
 ;
 Q 
 ;
 ; ---------------------------------------------------------------------
toObject ; method: Row.toClass(Object identifier,String columnMap)
 ; Copy a row to a record
 ;
 N di N table N tok N map
 N name S name=actual(1)
 N xmap S xmap=actual(2)
 ;
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 N newPtr S newPtr=$$getNew^UCGM(objectName,objectLevel)
 N z S z=$get(struct("Row",subRou,objectName,newPtr))
 N delimit S delimit=$piece(z,$char(9))
 N columns S columns=$piece(z,$char(9),2)
 ;
 I (columns="") D ERROR^UCGM("Columns list missing: "_objectName) Q 
 I '$$isLit^UCGM(columns) D ERROR^UCGM("Columns list must be literal: "_objectName) Q 
 I '$$isLit^UCGM(xmap) D ERROR^UCGM("ColumnMap must be literal: "_objectName) Q 
 ;
 I (name="") D ERROR^UCGM("Target object identifier required") Q 
 ;
 N varClass S varClass=$$getAtt^UCGM(name,,1)
 ;
 I (varClass="") D ERROR^UCGM("Target object is not in scope:"_name) Q 
 ;
 N dummy
 I $$isRecord^PSLClass(varClass)>0 S dummy=$$insByOvs^UCREC4OP(subRou,name,"","U")
 ;
 ; Set up one-to-one map between Row object and Record object
 ;
 N i
 ;
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 S z=$$TOKEN^%ZS($$QSUB^%ZS(columns,""""),.tok)
 ;
 F i=1:1:$L(z,",") D
 .	N di S di=$piece(z,",",i)
 .	;
 .	;   #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 .	S di=$ZCONVERT($piece($$UNTOK^%ZS(di,.tok)," ",2),"L")
 .	S map(di)=di
 .	Q 
 ;
 I '(xmap=""!(xmap="""""")) D
 .	N z S z=$$QSUB^%ZS(xmap,"""")
 .	;
 .	F i=1:1:$L(z,",") D
 ..		N ndi N x
 ..		S x=$piece(z,",",i)
 ..		S di=$ZCONVERT($$vStrTrim($piece(x,"=",1),0," "),"L")
 ..		S ndi=$$vStrTrim($piece(x,"=",2),0," ")
 ..		;
 ..		I (di="") D ERROR^UCGM("Invalid map expression: "_x) Q 
 ..		I ($$findPSLProperty^PSLParser(.pslPrsr,.tknzr,varClass_"."_ndi,1)="") D ERROR^UCGM("MISMATCH: Invalid property: "_varClass_"."_ndi) Q 
 ..		S map(di)=ndi
 ..		Q 
 .	Q 
 ;
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 N label S label=$$findSubr^UCGM("vRwTO","")
 ;
 N code S code="(Row vRow,"_varClass_" vObj)"
 ;
 N buf S buf=$$vopenBuf(code,"Copy Row to "_varClass)
 ;
 S z=columns
 ;
 D vaddBuff(buf,"do vRow.setColumns("_z_")")
 D vaddBuff(buf,"do vRow.setDelimiter("_delimit_")")
 S di=""
 F  S di=$order(map(di)) Q:(di="")  D
 .	I (map(di)="") Q 
 .	S code="set vObj."_map(di)_" = vRow."_di
 .	D vaddBuff(buf,code)
 .	Q 
 ;
 D vaddBuff(buf,"quit")
 D INSERT^UCMETHOD(buf,label,"void")
 ;
 S return=label_"(."_objectName_",."_name_")"
 ;
 K vobj(+$G(buf)) Q 
 ;
toRecord ; method: Row.toRecord(Record identifier,String columnMap)
 ; Copy a row to a record
 ;
 N di N table N tok N map
 ;
 N name S name=actual(1)
 N xmap S xmap=actual(2)
 ;
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 N newPtr S newPtr=$$getNew^UCGM(objectName,objectLevel)
 ;
 N z S z=$get(struct("Row",subRou,objectName,newPtr))
 N delimit S delimit=$piece(z,$char(9))
 N columns S columns=$piece(z,$char(9),2)
 ;
 I (columns="") D ERROR^UCGM("Columns list missing: "_objectName) Q 
 ;
 I (name="") D ERROR^UCGM("Record identifier required") Q 
 ;
 N varClass S varClass=$$getAtt^UCGM(name,,1)
 ;type String instExpr = name.instExpr
 ;
 I (varClass="") D ERROR^UCGM("Record object is not in scope:"_name) Q 
 I $$isRecord^PSLClass(varClass)=0 D ERROR^UCGM("Object parameter is not a Record<Class>: "_name) Q 
 ;
 N dummy S dummy=$$insByOvs^UCREC4OP(subRou,name,"","U")
 ;
 ; Set up one-to-one map between Row object and Record object
 ;
 N i
 I $$isLit^UCGM(columns) D
 .	;
 .	;   #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 .	N z S z=$$TOKEN^%ZS($$QSUB^%ZS(columns,""""),.tok)
 .	;
 .	F i=1:1:$L(z,",") D
 ..		;
 ..		N di S di=$piece(z,",",i)
 ..		;
 ..		;    #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 ..		S di=$ZCONVERT($piece($$UNTOK^%ZS(di,.tok)," ",2),"L")
 ..		S map(di)=di
 ..		Q 
 .	Q 
 ;
 I $$isLit^UCGM(xmap),'(xmap=""!(xmap="""""")) D
 .	;
 .	N z S z=$$QSUB^%ZS(xmap,"""")
 .	;
 .	F i=1:1:$L(z,",") D  Q:ER 
 ..		;
 ..		N ndi N x
 ..		S x=$piece(z,",",i)
 ..		S di=$ZCONVERT($$vStrTrim($piece(x,"=",1),0," "),"L")
 ..		S ndi=$$vStrTrim($piece(x,"=",2),0," ")
 ..		;
 ..		;if di.isNull()!ndi.isNull() do PSL.error("Invalid map expression: "_x) quit
 ..		I (di="") D ERROR^UCGM("Invalid map expression: "_x) Q 
 ..		;
 ..		S map(di)=ndi
 ..		;if 'ndi.isNull() kill map(ndi)
 ..		Q 
 .	Q 
 ;
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 N label S label=$$findSubr^UCGM("vRwTR","")
 ;
 N code S code="(Row row,"_varClass_" record"
 ;
 I '$$isLit^UCGM(columns) S code=code_",String columns"
 I '(xmap=""!(xmap="""""")) S code=code_",String xmap"
 ;
 N buf S buf=$$vopenBuf(code_")","Copy Row to"_varClass)
 ;
 S z=columns
 I '$$isLit^UCGM(z) S z="columns"
 ;
 D vaddBuff(buf,"type public "_varClass_" record") ; declare PUBLIC to prevent vosc scope
 D vaddBuff(buf,"do row.setColumns("_z_")")
 D vaddBuff(buf,"do row.setDelimiter("_delimit_")")
 ;
 ;if 'instExpr.isNull() do buf.add("#xecute do setInst^UCGM("_name.addQuotes()_",msrc,"_instExpr.addQuotes()_")")
 ;
 I '$$isLit^UCGM(columns)!('$$isLit^UCGM(xmap)&'(xmap=""!(xmap=""""""))) D
 .	;
 .	D vaddBuff(buf,"type Number i")
 .	D vaddBuff(buf,"type String di")
 .	I $$isLit^UCGM(columns) D vaddBuff(buf,"type literal String columns = "_columns)
 .	;
 .	I '(xmap=""!(xmap="""""")) D  ; Add mapping logic
 ..		;
 ..		D vaddBuff(buf,"type String map()")
 ..		D vaddBuff(buf,"set di = """"")
 ..		D vaddBuff(buf,"for i=1:1:xmap.length("","") set di = xmap.piece("","",i),map(di.piece(""="",1).trim()) = di.piece(""="",2).trim()")
 ..		Q 
 .	;
 .	D vaddBuff(buf,"for i = 1:1:columns.length("","") do {")
 .	D vaddBuff(buf," set di = columns.piece("","",i)")
 .	D vaddBuff(buf," if di["" "" set di = di.piece("" "",2)")
 .	I '(xmap=""!(xmap="""""")) D vaddBuff(buf," if map(di).exists() set di = map(di)")
 .	D vaddBuff(buf," if 'di.isNull() set record.@di = {String}row.piece("_delimit_",i)")
 .	D vaddBuff(buf,"}")
 .	Q 
 ;
 E  D
 .	;
 .	S di=""
 .	F  S di=$order(map(di)) Q:(di="")  D
 ..		;
 ..		I (map(di)="") Q 
 ..		N code S code="set record."_map(di)_" = row."_di
 ..		D vaddBuff(buf,code)
 ..		Q 
 .	Q 
 ;
 D vaddBuff(buf,"quit")
 D INSERT^UCMETHOD(buf,label,"void")
 ;
 S return=label_"(."_objectName_",."_name
 ;
 I '$$isLit^UCGM(columns) S return=return_","_columns
 I '(xmap=""!(xmap="""""")) S return=return_","_xmap
 S return=return_")"
 ;
 K vobj(+$G(buf)) Q 
 ;
 ; ---------------------------------------------------------------------
template(expr,del) ; 
 N tmplcol S tmplcol=""
 N tmpldel
 N tmplrow S tmplrow=$C(-1)
 ;
 S expr=$E(expr,2,1048575) ; Strip #
 ;
 ; If an extrinsic function, execute and return string
 I ($E(expr,1,2)="$$") D
 .	N $ET,$ES,$ZYER S $ZYER="ZE^UCGMR",$ZE="",$EC="",$ET="D:$TL>"_$TL_" rollback^vRuntime("_$TL_") Q:$Q&$ES """" Q:$ES  N voxMrk s voxMrk="_+$O(vobj(""),-1)_" G vCatch1^"_$T(+0)
 .	;   #ACCEPT DATE=4/22/03; PGM=Frank Sanchez; CR=Frank Sanchez;GROUP=XECUTE
 .	XECUTE "S tmplrow="_expr
 .	S tmpldel=$P(tmplrow,$C(9),2)
 .	I '(tmpldel="") S del="$C("_tmpldel_")"
 .	S tmplcol=$$QADD^%ZS($P(tmplrow,$C(9),1),"""")
 .	Q 
 E  D
 .	D ERROR^UCGM("Unsupported template specification")
 .	Q 
 Q tmplcol
 ;
 ; ---------------------------------------------------------------------
toString ; Method: Row.toString(colDel,quoChar,fmtDate,fmtTime,fmtBool)
 ;
 N colDel S colDel=actual(1) ; column separator in result
 N quoChar S quoChar=actual(2) ; add quotes to String types?
 N fmtDate S fmtDate=actual(3) ; output format for Date types
 N fmtTime S fmtTime=actual(4) ; output format for Time types
 N fmtBool S fmtBool=actual(5) ; output format for Boolean types
 ;
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 N newPtr S newPtr=$$getNew^UCGM(objectName,objectLevel)
 ;
 N rec S rec=$get(struct("Row",subRou,objectName,newPtr))
 ;
 N rowDel S rowDel=$$getDelCT(rec)
 N list S list=$piece(rec,$char(9),2)
 ;
 S return=objectName
 ;
 I (colDel=""!(colDel="""""")) S colDel=rowDel
 ;
 N mask
 ;
 I $$isLit^UCGM(list) D
 .	;
 .	S list=$$QSUB^%ZS(list,"""")
 .	;
 .	I '(","_list[",String ") S quoChar=""
 .	I '(","_list[",Date ") S fmtDate=""
 .	I '(","_list[",Time ") S fmtTime=""
 .	I '(","_list[",Boolean ") S fmtBool=""
 .	;
 .	N i
 .	S mask=$E(list,1)
 .	F i=2:1:$L(list,",") S mask=mask_$E($piece(list,",",i),1)
 .	S mask=$S(mask'["""":""""_mask_"""",1:$$QADD^%ZS(mask,""""))
 .	Q 
 ;
 E  S mask=list
 ;
 I (quoChar=""!(quoChar="""""")),(fmtDate=""!(fmtDate="""""")),(fmtTime=""!(fmtTime="""""")),(fmtBool=""!(fmtBool="""""")) D  Q 
 .	;
 .	I '(colDel=rowDel) D
 ..		S return="$TR("_return_","_rowDel_","_colDel_")"
 ..		Q 
 .	Q 
 ;
 N label S label="vRwTS"
 ;
 I '$$hasSubr^UCGM("vRwTS") D
 .	;
 .	N buf S buf=$$vopenBuf("(String row,String rowDel,String mask,String colDel,String quote,String fDate,String fTime,String fBool)","Convert Row to formatted String")
 .	;
 .	D vaddBuff(buf,"")
 .	D vaddBuff(buf,"if mask["" "" do {")
 .	D vaddBuff(buf," type Number i")
 .	D vaddBuff(buf," type String z = mask.extract(1)")
 .	D vaddBuff(buf," for i = 2:1:mask.length("","") set z = z_mask.piece("","",i).extract(1)")
 .	D vaddBuff(buf," set mask = z")
 .	D vaddBuff(buf,"}")
 .	;
 .	D vaddBuff(buf,"type Number y = 0")
 .	D vaddBuff(buf,"if 'fDate.isNull() for  set y = mask.find(""D"",y) quit:y = 0  set row.piece(rowDel,y-1) = ({Date}(row.piece(rowDel,y-1))).toString(fDate)")
 .	D vaddBuff(buf,"if 'fTime.isNull() for  set y = mask.find(""T"",y) quit:y = 0  set row.piece(rowDel,y-1) = ({Time}(row.piece(rowDel,y-1))).toString(fTime)")
 .	;do buf.add("if 'fBool.isNull() for  set y = mask.find(""B"",y) quit:y = 0  set row.piece(rowDel,y-1) = ({Boolean}(row.piece(rowDel,y-1))).toString(fBool)")
 .	D vaddBuff(buf,"if 'quote.isNull() for  set y = mask.find(""S"",y) quit:y = 0  set row.piece(rowDel,y-1) = row.piece(rowDel,y-1).addQuotes(quote)")
 .	D vaddBuff(buf,"")
 .	D vaddBuff(buf,"if '(rowDel = colDel) set row = row.translate(rowDel,colDel)")
 .	D vaddBuff(buf,"quit row")
 .	D INSERT^UCMETHOD(buf,"vRwTS","String")
 .	K vobj(+$G(buf)) Q 
 I (quoChar=""!(quoChar="""""")) S quoChar=""""""
 I (fmtDate=""!(fmtDate="""""")) S fmtDate=""""""
 I (fmtBool=""!(fmtBool="""""")) S fmtBool=""""""
 I (fmtTime=""!(fmtTime="""""")) S fmtTime=""""""
 ;
 S return="$$"_label_"("_objectName_","_rowDel_","_mask_","_colDel_","_quoChar_","_fmtDate_","_fmtTime_","_fmtBool_")"
 Q 
 ;  #OPTION ResultClass ON
vSIG() ; 
 Q "61296^59347^Frans S.C. Witte^39748" ; Signature - LTD^TIME^USER^SIZE
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
vStrTrim(object,p1,p2) ; String.trim
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 I p1'<0 S object=$$RTCHR^%ZFUNC(object,p2)
 I p1'>0 F  Q:$E(object,1)'=p2  S object=$E(object,2,1048575)
 Q object
 ;
vCatch1 ; Error trap
 ;
 N xecEx,$ET,$ES S xecEx=$ZE,$EC="",$ET="Q",$ZE=""
 D ERROR^UCGM("Error in Row template "_expr_": "_xecEx)
 D ZX^UCGMR(voxMrk) Q 
