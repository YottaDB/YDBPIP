 ; 
 ; **** Routine compiled from DATA-QWIK Procedure UCOBJECT ****
 ; 
 ; 02/24/2010 18:23 - pip
 ; 
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
 ; ---------------------------------------------------------------------
data() ; method Object.data; returns Number
 ;  #ACCEPT CR=27800;Date=2007-10-09;PGM=Frans S.C. Witte;Group=DEPRECATED; use of type()
 ;
 S return="$D("_objectVar_")"
 ;
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 N varTyp S varTyp=$$leftSig^UCGM(objectVar)
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 N varLev S varLev=$$getLevel^UCGM(objectVar)
 N nxtTyp S nxtTyp=$order(type(varLev,varTyp))
 ;
 N bArr S bArr=($piece(varTyp,"(")=$piece(nxtTyp,"("))
 I bArr,varTyp["(" D
 .	S varTyp=$E(varTyp,1,$L(varTyp)-1)
 .	S bArr=($E(nxtTyp,1,$L(varTyp))=varTyp)
 .	Q 
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 I 'bArr D WARNDEP^UCGM(2.7,0,objectVar_".data()")
 ;
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 I $$getOpti^UCGM(objectVar,objectLevel)>msrc D setOpti^UCGM(objectVar,objectLevel,0)
 Q 
 ;
 ; ---------------------------------------------------------------------
destroy(inst,level,vsig,pc,mode) ; return code that destroys the supplied inst
 ;
 N cls S cls=$$getAtt^UCGM(vsig,,1)
 N ocd S ocd=$$getPSLClass^PSLCC(.pslPrsr,cls)
 ;
 I $P(ocd,$C(9),5)'=0 Q ""
 ;
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 N code S code="" N isig S isig=$$leftSig^UCGM(inst)
 ;
 I isig'=vsig D
 .	S code=$S(inst["(":","_$E(inst,$F(inst,"("),1048575),1:")")
 .	;
 .	N cmt S cmt="KILL "_isig_" of "_cls_" "_vsig
 .	;
 .	;   #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 .	N lbl S lbl=$$findSubr^UCGM("vKill",cmt)
 .	S code="D"_pc_" "_lbl_"(."_$piece(vsig,"(")_code
 .	;
 .	Q:$$hasSubr^UCGM(lbl) 
 .	;
 .	N fixed S fixed=$L($translate(isig,"(",","),",")
 .	N total S total=$L($translate(vsig,"(",","),",")-2
 .	N fpl S fpl=cls_" v0("_$piece(vsig,"(",2)
 .	N lvn S lvn="v0"
 .	N txt S txt="type String v"_fixed_"="""""
 .	N indent S indent="" N last S last=""
 .	N sl
 .	;
 .	F sl=1:1:fixed-1 D
 ..		S fpl=fpl_", String v"_sl
 ..		S lvn=lvn_$S(sl>1:",",1:"(")_"v"_sl
 ..		Q 
 .	F sl=fixed+1:1:total S txt=txt_",v"_sl_"="""""
 .	;
 .	N buf S buf=$$vopenBuf("( "_fpl_")",cmt)
 .	;
 .	F sl=fixed:1:total D
 ..		D vaddBuff(buf,txt) ; add previous line
 ..		S lvn=lvn_$S(sl>1:",",1:"(")_"v"_sl
 ..		S txt=indent_"for  set v"_sl_"="_lvn_").order() quit:v"_sl_".isNull()  {"
 ..		S indent=indent_"  " S last="} "_last
 ..		Q 
 .	D vaddBuff(buf,txt)
 .	D vaddBuff(buf,indent_"kill "_lvn_")")
 .	D vaddBuff(buf,last)
 .	D vaddBuff(buf,"quit")
 .	;
 .	D INSERT^UCMETHOD(buf,lbl,"void")
 .	K vobj(+$G(buf)) Q 
 E  I (cls="ResultSet")!($$isRecord^PSLClass(cls)>1) S code=" K"_pc_" "_$$patch^UCPATCH(subRou,inst,level,oLvn_"(+$G("_inst_"))")
 E  S code=$$classDestroy^PSLClass(.ocd,pc,inst,mode)
 ;
 Q code
 ;
 ; ---------------------------------------------------------------------
exists ; method Object.exists; returns boolean
 ;
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 N ref S ref=$$TOKEN^%ZS(objectVar)
 ;
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 I $$isVar^UCGM(ref) ; variable ==> OK
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 E  I $$isArr^UCGM(ref) ; array ==> OK
 E  ; check if ref is an arraynode property
 E  D ERROR^UCGM("MISMATCH: Method cannot be applied in this context")
 ;
 N cls S cls=$$getAtt^UCGM(objectName,objectLevel,1)
 I '(cls=""),$P($$getPSLClass^PSLCC(.pslPrsr,cls),$C(9),5)=1 S return="''$D("_objectVar_")"
 E  S return="($D("_objectVar_")#2)"
 ;
 ; if object optimization was turned off for this line, turn it back on
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 I $$getOpti^UCGM(objectVar,objectLevel)>msrc D setOpti^UCGM(objectVar,objectLevel,0)
 Q 
 ;
 ; ---------------------------------------------------------------------
getClass ; method Object.getClass; returns string
 ;
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 D setOpti^UCGM(objectName,objectLevel,-1)
 ;
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 N ocd S ocd=$$getPSLClass^PSLCC(.pslPrsr,$$getClass^UCGM(objectName))
 S return=$$getClassnameExpr^PSLClass(.ocd,objectName)
 ;
 Q 
 ;  #OPTION ResultClass ON
vSIG() ; 
 Q "61061^59085^Frans S.C. Witte^10466" ; Signature - LTD^TIME^USER^SIZE
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
