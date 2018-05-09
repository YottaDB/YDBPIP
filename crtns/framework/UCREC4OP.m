 ; 
 ; **** Routine compiled from DATA-QWIK Procedure UCREC4OP ****
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
 ; ---------------------------------------------------------------------
accByDec(decPos,subscr,expr,bAudit,nAssign,bHasRoot) ; root INS? /NOREQ/MECH=REFNAM:W
 ;
 N decOvs S decOvs=dbAcc("*","*",decPos)
 N sr S sr=$piece(decOvs,$C(9))
 N nam S nam=$piece(decOvs,$C(9),2)
 ;
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 N ins S ins=$$getClass^UCGM(nam_$$leftSig^UCGM(subscr))
 S $piece(ins,$C(9),2)=decPos
 S $piece(ins,$C(9),5)=expr
 S $piece(ins,$C(9),11)=nAssign
 S $piece(ins,$C(9),12)=bAudit
 ;
 N pos S pos=$$dbAccSet(sr,nam_subscr,ins,0)
 S dbAcc("*","@",pos)=sr_$C(9)_nam
 ;
 I nAssign>0 S dbAcc("+",decPos,pos)=""
 ;
 N insLst S insLst=$$findIns(sr,nam,pos,.bHasRoot)
 I (insLst="") S insLst=","
 S $piece(dbAcc(sr,nam,pos),$C(9),4)=insLst
 ;
 Q pos
 ;
 ; ---------------------------------------------------------------------
accByOvs(sr,ovs,expr,bAudit,nAssign,bHasRoot) ; root INS? /NOREQ/MECH=REFNAM:W
 N nam S nam=$piece(ovs,"(")
 ;
 Q $$accByDec($$findDec(sr,nam),$E(ovs,$L(nam)+1,1048575),expr,bAudit,nAssign,.bHasRoot)
 ;
 ; ---------------------------------------------------------------------
clnAsn1(dec,acc,value) ; 
 ;
 I dec>0 S dbAcc("+",dec,acc)=""
 ;
 Q $$wrap(acc_"="_value)
 ;
 ; ---------------------------------------------------------------------
clnByCln(dec,cdouter,cdinner) ; inner column descriptor (*3)
 ;
 N acc S acc=""
 N des S des=dbAcc("*","*",dec)
 N srn S srn=$piece(des,$C(9),1)
 N nam S nam=$piece(des,$C(9),2)
 N qcn S qcn=$P(cdouter,"|",1)_"."_$P(cdouter,"|",2)
 ;
 F  S acc=$order(dbAcc(srn,nam,acc),-1) Q:acc=""  Q:$piece(dbAcc(srn,nam,acc),$C(9),5)=qcn 
 I acc="" D ERROR^UCGM("INTERNAL: column access for "_qcn_" not found") Q 
 ;
 N accInner S accInner=acc
 S qcn=$P(cdinner,"|",1)_"."_$P(cdinner,"|",2)
 F  S accInner=$order(dbAcc(srn,nam,accInner)) Q:accInner=""  Q:$piece(dbAcc(srn,nam,accInner),$C(9),5)=qcn 
 I '(accInner="") Q 
 ;
 S nam=nam_$piece(dbAcc(srn,nam,acc),$C(9),16)
 S acc=$$clnByOvs(srn,nam,cdinner,0,0)
 ;
 I $E($P(cdinner,"|",14),1,2)="$$" S dbAcc("*","$$",acc)=$P(cdinner,"|",14)
 ;
 Q 
 ;
 ; ---------------------------------------------------------------------
clnByOvs(sr,ovs,cd,bAudit,bAssign,bHasRoot) ; root INS? /NOREQ/MECH=REFNAM:W
 ;
 N nam S nam=$piece(ovs,"(")
 N dec S dec=$$findDec(sr,nam)
 N dummy S dummy=$$lvpm(dec,$$getPurNode^UCXDD(cd),1)
 ;
 Q $$accByDec(dec,$E(ovs,$L(nam)+1,1048575),$P(cd,"|",1)_"."_$P(cd,"|",2),bAudit,bAssign,.bHasRoot)
 ;
 ; ---------------------------------------------------------------------
dec2ovs(decPos) ; declaration position
 ;
 N nam S nam=$piece(dbAcc("*","*",decPos),$C(9),2)
 ;
 Q nam_$piece(dbAcc($piece(dbAcc("*","*",decPos),$C(9)),nam,decPos),$C(9),16)
 ;
 ; ---------------------------------------------------------------------
decByOvs(sr,ovs) ; 
 ;
 N isChild S isChild=0
 ;
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 N ins S ins=$$getClass^UCGM(ovs)
 ;
 N tblName S tblName=$E(ins,7,1048575)
 ;
 I '(tblName="") D
 .	;
 .	N td S td=$$caPslTbl^UCXDD(.pslTbl,tblName,0)
 .	;
 .	S isChild='($P(td,"|",7)="")
 .	Q 
 ;
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 N scope S scope=$$getScope^UCGM(ovs)
 S $piece(ins,$C(9),3)=scope
 ;
 S $piece(ins,$C(9),10)=''$$getAtt^UCGM(ovs,,10)!isChild
 ;
 I (",FORMAL,FORMALRET,LITERAL,PUBLIC,"[(","_scope_",")) S $piece(ins,$C(9),10)=1
 ;
 N pos S pos=$$dbAccSet(sr,ovs,ins,scope="PUBLIC")
 S dbAcc("*","*",pos)=sr_$C(9)_$piece(ovs,"(")
 Q pos
 ;
 ; ---------------------------------------------------------------------
findDec(sr,ovs) ; object variable signature (*2)
 ;
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 N dp S dp=$$getNew^UCGM(ovs)+1
 ;
 S ovs=$piece(ovs,"(")
 ;
 I $order(dbAcc(sr,ovs,""))="" N vo3 S vo3="%PSL-E-INTERNAL no declaration found for "_ovs_" in "_sr,$ZE="0,"_$ZPOS_","_vo3,$EC=",U1001,"
 ;
 N found S found=0
 F  Q:'(found'!(dp=""))  D
 .	S dp=$order(dbAcc(sr,ovs,dp),-1) Q:(dp="") 
 .	N data S data=dbAcc(sr,ovs,dp)
 .	;
 .	I '$$isDoScope($piece(data,$C(9),7),$$getDo^UCPSLST(pslSt)) Q 
 .	;
 .	S found=$$isDec(data,dp)
 .	Q 
 I found Q dp
 ;
 S dp=$get(dbAcc)+1
 F  Q:'(found'!(dp=""))  D
 .	S dp=$order(dbAcc(sr,ovs,dp),-1)
 .	I (dp="") N vo4 S vo4="%PSL-INTERNAL no declaration found for "_ovs_" in "_sr,$ZE="0,"_$ZPOS_","_vo4,$EC=",U1001,"
 .	;
 .	N data S data=dbAcc(sr,ovs,dp)
 .	;
 .	I '$$isDoScope($piece(data,$C(9),7),$$getDo^UCPSLST(pslSt)) Q 
 .	;
 .	S found=$$isDec(data,dp)
 .	Q 
 ;
 Q dp
 ;
 ; ---------------------------------------------------------------------
forceMode(sr,ovs,mode) ; insert or update mode
 ;
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 I $$getScope^UCGM(ovs)="NEW" D ERROR^UCGM("Method can not be applied to local scope object: "_ovs) Q 
 ;
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 I $$getScope^UCGM(ovs)="LITERAL" D ERROR^UCGM("Method can not be applied to literal scope object: "_ovs) Q 
 ;
 N dummy S dummy=$$vPSLopti(ovs) ; side effect: set optimize
 N expr S expr=$S(mode=0:"Class.new()",1:".getRecord(,,0)")
 N dec S dec=$$findDec(sr,ovs)
 ;
 S ovs=$piece(ovs,"(")
 I '($piece(dbAcc(sr,ovs,dec),$C(9),13)="") D ERROR^UCGM("RecordMode already "_$piece("CREATE;UPDATE",";",mode+1)_"ONLY") Q 
 ;
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 D typeFldSet^UCGM(ovs,5,expr)
 ;
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 D typeFldSet^UCGM(ovs,13,mode)
 ;
 S $piece(dbAcc(sr,ovs,dec),$C(9),13)=mode
 ;
 Q 
 ;
 ; ---------------------------------------------------------------------
getDec(sr,ovs,pos) ; position
 ;
 Q $piece(dbAcc(sr,$piece(ovs,"("),pos),$C(9),2)
 ;
 ; ---------------------------------------------------------------------
getOptApl(td,decPos) ; 
 ;
 N xnods S xnods=""
 ;
 I ($D(dbAcc("*",decPos,-2))#2) S xnods=xnods_"."_dbAcc("*",decPos,-2)
 E  S xnods=xnods_""""""
 ;
 I '($$getArchiveTable^DBARCHIVE(td)="") D
 .	;
 .	I ($D(dbAcc("*",decPos,-99))#2) S xnods=xnods_",."_dbAcc("*",decPos,-99)
 .	E  S xnods=xnods_","""""
 .	Q 
 ;
 I ($P(td,"|",8)'="GTM") D
 .	;
 .	I ($D(dbAcc("*",decPos,-152))#2) S xnods=xnods_",."_dbAcc("*",decPos,-152)_",1"
 .	E  S xnods=xnods_","""",0"
 .	Q 
 ;
 ;if td.primaryKeys.isNull() set xnods = xnods.extract( 2, xnods.length())
 ;
 Q xnods
 ;
 ; ---------------------------------------------------------------------
hasWrap(data) ; arbitrary data
 ;
 I data'[$C(7) Q 0
 Q $L(data,$C(7))=$L(data,$C(8))
 ;
 ; ---------------------------------------------------------------------
insByDec(decPos,subscr,expr,imd) ; 
 ;
 N decOvs S decOvs=dbAcc("*","*",decPos)
 N sr S sr=$piece(decOvs,$C(9))
 N nam S nam=$piece(decOvs,$C(9),2)
 N dec S dec=dbAcc(sr,nam,decPos)
 N cls
 ;
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 I subscr?1"(".","1")" Q:$piece(dec,$C(9),3)'["FORMAL" "" Q:(decPos\1)'=$$getDcLnr^UCGM() ""
 ;
 I (expr="") S cls=""
 E  I ($E(expr,1,6)="Class.") S cls="Class"
 E  I ($E(expr,1,3)="Db.") S cls="Db"
 E  D
 .	N tl
 .	;
 .	;   #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 .	N exp S exp=$$TOKEN^%ZS(expr,.tl)
 .	;
 .	;   #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 .	N lvn S lvn=$$UNTOK^%ZS($piece(exp,"."),.tl)
 .	S cls=$$getAtt^UCGM(lvn,,1)
 .	Q 
 ;
 N ins S ins=cls
 ;
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 N scope S scope=$$getScope^UCGM(nam)
 S $piece(ins,$C(9),2)=decPos
 S $piece(ins,$C(9),3)=scope
 S $piece(ins,$C(9),5)=expr
 ;
 N insPos S insPos=$$dbAccSet(sr,nam_subscr,ins,0)
 S dbAcc("*","=",insPos)=sr_$C(9)_nam
 S dbAcc("=",decPos,insPos)=""
 ;
 I '(cls="") D
 .	I $piece(ins,$C(9),3)="FORMAL" S $ZE="0,"_$ZPOS_","_"%PSL-E-READONLY, Formal parameter '"_nam_"' cannot be instantiated",$EC=",U1001,"
 .	D setAssign(sr,nam,0)
 .	Q 
 ;
 N forBlock S forBlock=$$getForBlock^UCPSLST(pslSt,$piece(dec,$C(9),7))
 I '(forBlock="") D
 .	N ap S ap=insPos
 .	F  S ap=$order(dbAcc(sr,nam,ap),-1) Q:ap=""  Q:ap'>decPos  D
 ..		N opt S opt=dbAcc(sr,nam,ap)
 ..		I $$isIns(opt) Q  ; skip INS
 ..		I $$isDec(opt,ap) Q  ; skip DEC
 ..		I $piece(opt,$C(9),2)'=decPos Q  ; different DEC
 ..		I '$$isDoScope(forBlock,$piece(opt,$C(9),7)) Q 
 ..		;
 ..		; this ACC is in the same FOR block as INS
 ..		N insLst S insLst=$piece(opt,$C(9),4)
 ..		S dbAcc("@",insPos,ap)=decPos
 ..		S $piece(dbAcc(sr,nam,ap),$C(9),4)=$S((insLst=""):insPos,1:insPos_","_insLst)
 ..		Q 
 .	Q 
 ;
 S $piece(dbAcc(sr,nam,insPos),$C(9),13)=$S('(imd=""):imd,1:$$getInstMode(dbAcc(sr,nam,insPos)))
 Q insPos
 ;
 ; ---------------------------------------------------------------------
insByOvs(sr,ovs,expr,imd) ; 
 N nam S nam=$piece(ovs,"(")
 Q $$insByDec($$findDec(sr,nam),$E(ovs,$L(nam)+1,1048575),expr,imd)
 ;
 ; ---------------------------------------------------------------------
occMark() ; 
 S dbAcc("*","<=","=")=$get(dbAcc,0) ; save current position
 Q 
 ;
 ; ---------------------------------------------------------------------
isWrap(data) ; arbitrary data
 ;
 I $E(data,1)=$C(7),$E(data,$L(data))=$C(8) Q 1
 Q 0
 ;
 ; ---------------------------------------------------------------------
lvpm(decPos,pur,bIns) ; insert new value (*3)
 ;
 I (pur="") S pur="0*" ; sync with UCXDD !!!!
 ;
 I ($D(dbAcc("*",decPos,pur))#2) Q dbAcc("*",decPos,pur)
 ;
 I pur?1.N1"*",pur'="0*" Q $$lvpm(decPos,-2-+pur,bIns)
 ;
 I 'bIns Q ""
 ;
 N pos S pos=$$createPos()
 S dbAcc("*",decPos,pur)=$$wrap(pos)
 S dbAcc("*","<",pos)=decPos_$C(9)_pur
 Q dbAcc("*",decPos,pur)
 ;
 ; ---------------------------------------------------------------------
optNload(mp1,bOpti,ldMode) ; incremental load mode (*3)
 ;
 N ldMap ; load map
 N ldMap2 ; load map, version 2
 N lvMap ; purPos-to-lvn map
 ;
 ; Step 1: Build code to calculate values of complex computeds only once
 ; This code impacts incremental loading
 N acc S acc=0
 F  S acc=$order(dbAcc("*","$$",acc)) Q:acc=""  D cmp2pur(acc,.mp1)
 ;
 ; Step 2: Build the incremental load map (insensitive to optimize)
 I ldMode=0 S ldMode=$S($$isRdb^vRuntime:2,1:1)
 D ldMap(ldMode,.ldMap2)
 ;
 ; Step 3: try to optimize access to records
 N dec S dec=0
 F  Q:'('(dec=""))  D
 .	S dec=$order(dbAcc("*","*",dec))
 .	I (dec="") Q 
 .	;
 .	D decSav(dec,.lvMap)
 .	I bOpti D decOpt(dec,.mp1)
 .	Q 
 ;
 ; Step 4: add purPos-to-lvn map for all nodes
 D lvMap(.lvMap)
 ;
 ; Step 5: insert incremental load code and convert for pass 2
 D load(.mp1,.ldMap2,.lvMap)
 ;
 ; Step 6: replace placeholders by real M code
 N dln S dln=0
 S acc=0
 ;
 F  S dln=$order(mp1(dln)) Q:(dln="")  S mp1(dln)=$$pur2M(mp1(dln),.lvMap)
 ;
 ; Step 7: replace placeholders in append(,)
 N sr S sr=""
 F  S sr=$order(dbAcc("*sr*","*",sr)) Q:(sr="")  D
 .	S dln=0
 .	F  S dln=$order(append(sr,dln)) Q:(dln="")  S append(sr,dln)=$$pur2M(append(sr,dln),.lvMap)
 .	Q 
 ;
 Q 
 ;
 ; ---------------------------------------------------------------------
paNeedVobj(srn,nam,decLine) ; declaration line
 ;
 N dp S dp=decLine+1
 N found S found=0
 F  Q:'(dp>decLine&'found)  D
 .	S dp=$order(dbAcc(srn,nam,dp),-1) Q:(dp="") 
 .	N data S data=dbAcc(srn,nam,dp)
 .	S found=$$isDec(dbAcc(srn,nam,dp),dp)
 .	Q 
 ;
 I found Q $piece(dbAcc(srn,nam,dp),$C(9),10)
 Q 1 ; not found assumes need vobj()
 ;
 ; ---------------------------------------------------------------------
purByDec(decPos,subscr,pur,bHasRoot) ; root INS? /NOREQ/MECH=REFNAM:W
 ;
 N decOvs S decOvs=dbAcc("*","*",decPos)
 N sr S sr=$piece(decOvs,$C(9))
 N nam S nam=$piece(decOvs,$C(9),2)
 ;
 N ins S ins=$$getAtt^UCGM(nam,,1)
 S $piece(ins,$C(9),2)=decPos
 S $piece(ins,$C(9),5)=$$lvpm(decPos,pur,1)
 ;
 N pos S pos=$$dbAccSet(sr,nam_subscr,ins,0)
 ;
 N insLst S insLst=$$findIns(sr,nam,pos,.bHasRoot)
 I (insLst="") S insLst=","
 S $piece(dbAcc(sr,nam,pos),$C(9),4)=insLst
 S dbAcc("*","@",pos)=sr_$C(9)_nam
 ;
 Q $piece(ins,$C(9),5)
 ;
 ; ---------------------------------------------------------------------
purByOvs(sr,ovs,pur,bHasRoot) ; root INS? /NOREQ/MECH=REFNAM:W
 N nam S nam=$piece(ovs,"(")
 ;
 Q $$purByDec($$findDec(sr,nam),$E(ovs,$L(nam)+1,1048575),pur,.bHasRoot)
 ;
 ; ---------------------------------------------------------------------
savByDec(decPos,subscr,expr) ; Record.save() subroutine call
 ;
 N decOvs S decOvs=dbAcc("*","*",decPos)
 N sr S sr=$piece(decOvs,$C(9))
 N nam S nam=$piece(decOvs,$C(9),2)
 ;
 N ins S ins=$$getAtt^UCGM(nam,,1)
 S $piece(ins,$C(9),2)=decPos
 S $piece(ins,$C(9),4)="^" ; $$isIns() assumes ""==> ins
 S $piece(ins,$C(9),15)=expr
 ;
 N pos S pos=$$dbAccSet(sr,nam_subscr,ins,0)
 S dbAcc("^",decPos,pos)=sr_$C(9)_nam
 ;
 Q $$wrap(pos)
 ;
 ; ---------------------------------------------------------------------
savByOvs(sr,ovs,expr) ; 
 N nam S nam=$piece(ovs,"(")
 ;
 Q $$savByDec($$findDec(sr,nam),$E(ovs,$L(nam)+1,1048575),expr)
 ;
 ; ---------------------------------------------------------------------
setAssign(sr,ovs,assign) ; assignment (0, 1, 2)
 ;
 N nam S nam=$piece(ovs,"(")
 N dec S dec=$$findDec(sr,nam)
 ;
 N des S des=dbAcc(sr,nam,dec)
 N cur S cur=$piece(des,$C(9),11)
 ;
 I assign>cur!(cur="") D
 .	S $piece(dbAcc(sr,nam,dec),$C(9),11)=assign
 .	I assign>1 S $piece(dbAcc(sr,nam,dec),$C(9),10)=1
 .	Q 
 Q 
 ;
 ; ---------------------------------------------------------------------
setInsCall(sr,ovs,ins,call) ; occurrence call
 ;
 S $piece(dbAcc(sr,$piece(ovs,"("),ins),$C(9),15)=$translate(call,$C(9),$char(10))
 Q 
 ;
 ; ---------------------------------------------------------------------
setScope(sr,ovs,scope) ; scope
 D setDecVal(sr,ovs,3,scope)
 Q 
 ;
 ; ---------------------------------------------------------------------
setNeedVobj(sr,ovs,need) ; need vobj?
 D setDecVal(sr,ovs,10,need)
 Q 
 ;
 ; ---------------------------------------------------------------------
srAdd(sr) ; PSLSubrou instance with wrap
 ;
 S dbAcc("*sr*","*",sr)=""
 ;
 Q 
 ;
 ; ---------------------------------------------------------------------
stripWrap(wrap) ; data for which isWrap returned true
 Q $E(wrap,2,$L(wrap)-1)
 ;
 ; ---------------------------------------------------------------------
wrap(value) ; position
 ;
 Q $C(7)_value_$C(8)
 ;
 ; ---------------------------------------------------------------------
wrapFits(code,reserve) ; additional charactes
 ;
 Q ($ZLENGTH(code)+($L(code,$C(7))*10+reserve)'>1980)
 ;
 ; ---------------------------------------------------------------------
clnAsn2(mp1,RdbCodeForm) ; form of code for RDB (*2)
 ;
 N eq S eq=$F(mp1,"=")
 N acc S acc=$E(mp1,1,eq-2)
 ;
 N des S des=dbAcc("*","@",acc)
 N srn S srn=$piece(des,$C(9))
 N nam S nam=$piece(des,$C(9),2)
 ;
 S des=dbAcc(srn,nam,acc)
 N dec S dec=$piece(des,$C(9),2) ; declaration position
 N prop S prop=$piece(des,$C(9),5) ; table.column
 N mode S mode=$piece(des,$C(9),12) ; audit mode
 N subs S subs=$piece(des,$C(9),16) ; subscripts at access
 ;
 N ovs S ovs=$S((subs=""):dec,1:nam_subs)
 ;
 N cd S cd=$$caPslCln^UCXDD(.pslCln,prop,.pslTbl)
 ;
 I $piece(dbAcc(srn,nam,dec),$C(9),11)=1 S mode=mode+3
 ;
 N code S code=$$getUpdCode^UCXDD(cd,ovs,$E(mp1,eq,1048575),mode,RdbCodeForm)
 ;
 I code[$char(9) D
 .	I ($ZLENGTH(code)'>1980) S code=$$vStrRep(code,$char(9),"",0,0,"") Q 
 .	S code=$$longSet^UCCOLUMN(cd,ovs,$E(mp1,eq,1048575),mode)
 .	Q 
 Q code
 ;
 ; ---------------------------------------------------------------------
cmp2pur(acc,mp1) ; pass 1 code (*2)  /MECH=REFARR:RW
 ;
 N des S des=dbAcc("*","@",acc)
 N srn S srn=$piece(des,$C(9))
 N nam S nam=$piece(des,$C(9),2)
 ;
 S des=dbAcc(srn,nam,acc)
 N qcn S qcn=$piece(des,$C(9),5)
 N cd S cd=$$caPslCln^UCXDD(.pslCln,qcn,.pslTbl)
 N dec S dec=$piece(des,$C(9),2)
 ;  #ACCEPT CR=27800; Date=2007-10-11; PGM=Frans S.C. Witte; Group=MISMATCH; passes Number as PSLIdentifier
 N cmp S cmp=$$getCurExpr^UCXDD(cd,dec,0)
 ;
 N pur S pur=$$purByAcc(acc,"~"_$piece(qcn,".",2))
 ;
 N code S code=mp1(acc\1)
 N at S at=$F(code,cmp)
 N sub S sub=$L(cmp)+1
 ;
 F  Q:'(at>0)  S code=$E(code,1,at-sub)_pur_$E(code,at,1048575) S at=$F(code,cmp,at)
 S mp1(acc\1)=code
 S dbAcc("*","<$$",$$stripWrap(pur))=cmp
 Q 
 ;
 ; ---------------------------------------------------------------------
createPos(line) ; Target pass 1 line   /NOREQ
 ;
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 N val S val=$S(($D(line)#2):line,1:$$getDcLnr^UCGM())
 ;
 I $get(dbAcc)'>val S dbAcc=val
 ;
 S val=val+1
 I dbAcc<val S dbAcc=dbAcc+1E-5 Q dbAcc
 ;
 N max S max=$order(dbAcc("*","@",val),-1)
 N pos
 N typ
 ;
 F typ="=","*","<" S pos=$order(dbAcc("*",typ,val),-1) I pos>max S max=pos
 ;
 I val-max>1 Q val-1+1E-5
 Q max+1E-5
 ;
 ; ---------------------------------------------------------------------
dbAccSet(sr,ovs,data,ovrMd) ; override mode (*4)
 ;
 N nam S nam=$piece(ovs,"(")
 N pos
 ;
 I ovrMd=0 D
 .	S $piece(data,$C(9),6)=level
 .	S $piece(data,$C(9),7)=$$getDo^UCPSLST(pslSt)
 .	S $piece(data,$C(9),8)=$$getIf^UCPSLST(pslSt)
 .	S $piece(data,$C(9),9)=$$getFor^UCPSLST(pslSt)
 .	;
 .	;   #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 .	S $piece(data,$C(9),14)=$$getScLnr^UCGM()
 .	;
 .	S pos=$$createPos()
 .	Q 
 E  D
 .	S pos=$$botDo^UCPSLST(pslSt)
 .	S $piece(data,$C(9),6)=0
 .	S $piece(data,$C(9),7)=pos
 .	S $piece(data,$C(9),8)=0
 .	S $piece(data,$C(9),9)=0
 .	;
 .	;   #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 .	S $piece(data,$C(9),14)=$$getScLnr^UCGM()
 .	;
 .	S pos=$$createPos(pos)
 .	Q 
 ;
 I (sr?1"selectOptmOK"1.N) D
 .	;
 .	I ($piece(data,$C(9),1)=("Record"_$ZCONVERT(ovs,"U"))),($E($piece(data,$C(9),3),1,6)="FORMAL") D
 ..		;
 ..		S $piece(data,$C(9),10)=0
 ..		S $piece(data,$C(9),3)="NEW"
 ..		Q 
 .	;
 .	E  I ($piece(data,$C(9),1)=""),($E($piece(data,$C(9),3),1,6)="FORMAL") D
 ..		;
 ..		S $piece(data,$C(9),1)="Db"
 ..		S $piece(data,$C(9),3)="NEW"
 ..		Q 
 .	Q 
 ;
 S $piece(data,$C(9),16)=$E(ovs,$L(nam)+1,1048575)
 S dbAcc(sr,nam,pos)=data
 Q pos
 ;
 ; ---------------------------------------------------------------------
decNew(var,code,lvnList) ; local variables to be NEWed (*3)
 N txt S txt="N "_var ; text to find (var as first in NEW)
 ;
 I code'[txt S txt=","_var
 ;
 I code'[txt D ERROR^UCGM("INTERNAL: cannot find declaration for "_var)
 ;
 Q $piece(code,txt)_txt_lvnList_$piece(code,txt,2,999)
 ;
 ; ---------------------------------------------------------------------
decOpt(dec,mp1) ; pass 1 code
 ;
 N decDes S decDes=dbAcc("*","*",dec) ; descriptor
 N ovs S ovs=$piece(decDes,$C(9),2) ; object var
 N srn S srn=$piece(decDes,$C(9)) ; subroutine
 ;
 S decDes=dbAcc(srn,ovs,dec)
 ;
 N optOvr S optOvr=0
 I (srn?1"selectOptmOK"1.N),($piece(decDes,$C(9),1)=("Record"_$ZCONVERT(ovs,"U"))) S optOvr=1
 ;
 I +$piece(decDes,$C(9),10)'=0 Q  ; need vobj()
 I $piece(decDes,$C(9),3)'="NEW" D paSetVobj(srn,ovs,dec,0) Q  ; NEW scope only
 I $piece(decDes,$C(9),1)="Record" D paSetVobj(srn,ovs,dec,1) Q  ; abstract
 I '($piece(decDes,$C(9),16)="") D paSetVobj(srn,ovs,dec,0) Q  ; array
 I ($order(dbAcc("=",dec,""))="") D paSetVobj(srn,ovs,dec,0) Q  ; no instantiations
 ;
 I $piece(decDes,$C(9),11)=2 D paSetVobj(srn,ovs,dec,1) Q  ; .save() needs vobj()
 ;
 N td S td=$$caPslTbl^UCXDD(.pslTbl,$$tableNameOf^PSLClass($piece(decDes,$C(9))),0)
 ;
 N i ; iterator
 N kilLst S kilLst="" ; purpose lvns that need to be killed
 N lvn ; single lvn
 N lvnLst S lvnLst="" ; all lvns
 N nod ; node iterator
 N nodInc ; incremental load node
 ;
 S td=$$tAssert^UCXDD(td,1) ; need hasBlob / hasMemo
 ;
 S nod=$$getRecPur^UCXDD(td)
 ;
 S nodInc=$order(dbAcc("*",dec,-1))
 I nodInc=nod S nodInc=$order(dbAcc("*",dec,nodInc))
 ;
 I optOvr D
 .	N pk S pk=$P(td,"|",3)
 .	;
 .	F i=1:1:$S((pk=""):0,1:$L(pk,",")) S dbAcc("*",dec,-2-i)="vkey"_i
 .	Q 
 ;
 I '(nodInc="") D
 .	N dummy
 .	I ($P(td,"|",8)'="GTM"),($P(td,"|",5)["B")!($P(td,"|",5)["M") D decOptLv(dec,-152,srn,.lvnLst)
 .	;
 .	N pk S pk=$P(td,"|",3)
 .	;
 .	F i=1:1:$S((pk=""):0,1:$L(pk,",")) D
 ..		I 'optOvr D decOptLv(dec,-2-i,srn,.lvnLst)
 ..		Q  
 .	Q  
 ;
 ; If table is archived, allocate lvn for -99.
 I '($$getArchiveTable^DBARCHIVE(td)="") D decOptLv(dec,-99,srn,.lvnLst)
 ;
 I (nod="") S nod=$order(dbAcc("*",dec,-1))
 ;
 I '(nod="") S dbAcc("*",dec,nod)=ovs S nod=""
 ;
 F  S nod=$order(dbAcc("*",dec,nod)) Q:(nod="")  D
 .	I '$$isWrap(dbAcc("*",dec,nod)) Q 
 .	D decOptLv(dec,nod,srn,.lvnLst)
 .	S kilLst=$S((kilLst=""):dbAcc("*",dec,nod),1:kilLst_","_dbAcc("*",dec,nod))
 .	Q 
 ;
 I ($P(td,"|",8)'="GTM"),$piece(decDes,$C(9),11)>0 D
 .	I '($D(dbAcc("*",dec,-152))#2) D decOptLv(dec,-152,srn,.lvnLst)
 .	S kilLst=$S((kilLst=""):dbAcc("*",dec,-152),1:kilLst_","_dbAcc("*",dec,-152))
 .	Q 
 S $piece(decDes,$C(9),15)=kilLst S dbAcc(srn,ovs,dec)=decDes
 ;
 I '(lvnLst="") D
 .	;
 .	I 'optOvr S mp1(dec\1)=$$decNew(ovs,mp1(dec\1),lvnLst)
 .	E  D
 ..		;
 ..		N lnr S lnr=$order(mp1((dec\1)+1),-1)+1E-3
 ..		;
 ..		S mp1(lnr)=" N "_$E(lvnLst,2,1048575)
 ..		Q 
 .	Q 
 ;
 N apl ; actual parameter list
 N head ; code preceding $$lbl(apl)
 N ins S ins=0 ; instantiation iterator
 N insCls ; instantiator class
 N insCnt ; instantiation count for current line
 N insCod ; code line of instantiation
 N insDes ; instantiation descriptor
 N insPrv S insPrv=ins-1 ; previous instantiation
 N lbl ; label
 N tail ; code following $$lbl(apl)
 N tsl ; tokenized string literals
 ;
 F  Q:'('(ins=""))  D
 .	S ins=$order(dbAcc("=",dec,ins))
 .	I (ins="") Q 
 .	;
 .	I (ins\1)>(insPrv\1) S insCnt=0 ; on different line
 .	S insCnt=insCnt+1
 .	S insPrv=ins
 .	;
 .	;   #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 .	S insCod=$$TOKEN^%ZS(mp1(ins\1),.tsl)
 .	D insCode(insCod,ovs,insCnt,.lbl,.apl,.head,.tail)
 .	;
 .	S insDes=dbAcc(srn,ovs,ins)
 .	S insCls=$piece(insDes,$C(9))
 .	;
 .	I (insCls="") D pass2Err(dec,"INTERNAL: unexpected optimize for "_ovs) Q 
 .	I optOvr ; Already dealt with optimization override
 .	E  I $$isRecord^PSLClass(insCls)>0 S insCod=$$insOptCp(td,srn,ovs,ins,insDes,lbl,.apl,head,tail)
 .	E  I insCls="Cache" S insCod=$$insOptCa(td,srn,ovs,ins,insDes,lbl,.apl,head,tail)
 .	E  I insCls="Class" S insCod=$$insOptCl(td,srn,ovs,ins,insDes,lbl,.apl,head,tail)
 .	E  I insCls="Db" S insCod=$$insOptDb(td,srn,ovs,ins,insDes,lbl,.apl,head,tail)
 .	E  I insCls="DbSet" S insCod=$$insOptDs(td,srn,ovs,ins,insDes,lbl,.apl,head,tail)
 .	E  D pass2Err(ins,"INTERNAL: unexpected intantiator class '"_insCls_"' for "_ovs_"="_$piece(insDes,$C(9),5))
 .	;
 .	;   #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 .	S mp1(ins\1)=$$UNTOK^%ZS(insCod,.tsl)
 .	Q 
 Q 
 ;
 ; ---------------------------------------------------------------------
decOptLv(dec,nod,srn,lvnLst) ; list of lvns   /MECH=REFNAM:RW
 ;
 N lvn S lvn=$$getSym^UCPATCH(srn,"vop")
 S lvnLst=lvnLst_","_lvn
 S dbAcc("*",dec,nod)=lvn
 Q 
 ;
 ; ---------------------------------------------------------------------
decSav(dec,lvmap) ; local variable map
 ;
 N decDes S decDes=dbAcc("*","*",dec) ; descriptor
 N ovn S ovn=$piece(decDes,$C(9),2) ; object var
 N srn S srn=$piece(decDes,$C(9)) ; subroutine
 ;
 S decDes=dbAcc(srn,ovn,dec)
 ;
 I $piece(decDes,$C(9),11)<1 Q  ; not an assignment
 ;
 N td S td=$$caPslTbl^UCXDD(.pslTbl,$$tableNameOf^PSLClass($piece(decDes,$C(9))),0)
 ;
 I '($P(td,"|",8)'="GTM") Q  ; Applies to RDB only
 ;
 N bDirect S bDirect=$$isOneNode^UCXDD(td)&($piece(decDes,$C(9),11)=1)
 N ins S ins=0 N rmd S rmd="" N exs S exs=""
 ;
 F  Q:'('(ins="")&bDirect)  D
 .	S ins=$order(dbAcc("=",dec,ins))
 .	I (ins="") Q 
 .	;
 .	D ins2me(ins,.rmd,.exs) ; update rmd and exs
 .	;
 .	I (",Cache,Class,Db,DbSet,"[(","_$piece(dbAcc(srn,ovn,ins),$C(9))_",")) Q 
 .	;
 .	S bDirect=0
 .	Q 
 ;
 N code
 N sav S sav="" ; save iterator
 ;
 I 'bDirect D
 .	N saveLabel N where
 .	;
 .	I $$isOneNode^UCXDD(td),'$$isParent^UCXDD(td) S saveLabel="rdbSaveS"
 .	E  S saveLabel="rdbSaveC"
 .	;
 .	S where=$$getPrimaryKeyWhere^UCXDD(td)
 .	;
 .	S code=$piece(decDes,$C(9),16)
 .	I '(code="") S code=$C(9)
 .	S code=" D "_saveLabel_"^UCDBRT("_ovn_code_",$C("_$P(td,"|",10)_"),"_$S(where'["""":""""_where_"""",1:$$QADD^%ZS(where,""""))_")"
 .	S $piece(dbAcc(srn,ovn,dec),$C(9),11)=2 ; set assignMode
 .	S $piece(dbAcc(srn,ovn,dec),$C(9),10)=1 ; set needVobj
 .	Q 
 E  D
 .	S code=$$decSavCode(td,dec,rmd)
 .	;
 .	N reserve S reserve=200
 .	S:($D(dbAcc("*",dec,-152))#2) reserve=$S(($P(td,"|",3)=""):0,1:$L($P(td,"|",3),","))*66+reserve
 .	I code'[$char(9),$$wrapFits(code,reserve) Q 
 .	;
 .	N sr S sr=$$vaddSubr("ReSv","()","SQL for "_ovn_".save()",1)
 .	N ln
 .	F ln=1:1:$L(code,$char(9)) D addCode^UCPSLSR(sr,$piece(code,$char(9),ln))
 .	D addCode^UCPSLSR(sr," Q")
 .	D srAdd(.sr)
 .	S code=" D "_sr_"()"
 .	Q 
 ;
 F  S sav=$order(dbAcc("^",dec,sav)) Q:(sav="")  D
 .	I code'[$C(9) S lvmap(sav)=code Q 
 .	S lvmap(sav)=$piece(code,$C(9))_$piece(dbAcc(srn,ovn,sav),$C(9),16)_$piece(code,$C(9),2)
 .	Q 
 ;
 Q 
 ;
 ; ---------------------------------------------------------------------
decSavCode(td,dec,rmd) ; record mode, passed to $$getSavCode
 ;
 N acc ; access iterator
 N accDes ; access descriptor
 N clnByPos ; column descriptor by position
 N code ; direct SQL code
 N expr ; occurrence expression
 N pos ; position
 ;
 S acc=0
 F  Q:'('(acc=""))  D
 .	S acc=$order(dbAcc("+",dec,acc)) Q:(acc="") 
 .	S accDes=$$getByPos("@",acc)
 .	S expr=$piece(accDes,$C(9),5)
 .	Q:'$$expIsCln(expr)  ; not a column
 .	Q:+$piece(accDes,$C(9),11)=0  ; not assigned
 .	;
 .	D addRdbPos^UCXDD(.clnByPos,$$caPslCln^UCXDD(.pslCln,expr,.pslTbl))
 .	Q 
 ;
 I ($order(clnByPos(""))="") D
 .	I ($P(td,"|",3)="") D pass2Err(dec,"RDBSAVEFAIL: No columns to INSERT or UPDATE ") Q 
 .	D addRdbPos^UCXDD(.clnByPos,$$caPslCln^UCXDD(.pslCln,$P(td,"|",1)_"."_$piece($P(td,"|",3),",",1),.pslTbl))
 .	Q 
 S code=$$getSavCode^UCXDD(td,dec,"",rmd,,.clnByPos)
 ;
 Q code
 ;
 ; ---------------------------------------------------------------------
expIsCln(expr) ; expression
 I ($E(expr,$L(expr)-2+1,1048575)="()") Q 0
 I $$isWrap(expr) Q 0
 Q 1
 ;
 ; ---------------------------------------------------------------------
findIns(sr,nam,pos,hasRoot) ; root instance found? /MECH=REFNAM:W
 ;
 N acc S acc=dbAcc(sr,nam,pos)
 N accDec S accDec=$piece(acc,$C(9),2)
 N accDo S accDo=$piece(acc,$C(9),7)
 N dp S dp=dbAcc("*","<=","=")+1E-5
 N insLst S insLst=""
 S hasRoot=0
 ;
 F  Q:'('(dp=""))  D
 .	S dp=$order(dbAcc(sr,nam,dp),-1)
 .	Q:(dp="") 
 .	;
 .	N data S data=dbAcc(sr,nam,dp)
 .	;
 .	Q:$piece(data,$C(9),2)'=accDec  ; different dec
 .	Q:'($D(dbAcc("=",$piece(data,$C(9),2),dp))#2) 
 .	;
 .	S dbAcc("@",dp,pos)=accDec
 .	S insLst=$S((insLst=""):dp,1:insLst_","_dp)
 .	;
 .	I $piece(data,$C(9),13)="U" Q 
 .	I $$isDoScope($piece(data,$C(9),7),accDo) S hasRoot=1 S dp="" Q 
 .	Q 
 Q insLst
 ;
 ; ---------------------------------------------------------------------
findXDes(pos) ; position value
 ;
 N xdes S xdes=""
 N typ
 ;
 F typ="@","=","*" I ($D(dbAcc("*",typ,pos))#2) D  Q 
 .	S xdes=dbAcc("*",typ,pos)
 .	N srn S srn=$piece(xdes,$C(9))
 .	N nam S nam=$piece(xdes,$C(9),2)
 .	S xdes=typ_$C(9)_xdes_$C(9)_dbAcc(srn,nam,pos)
 .	Q 
 ;
 Q xdes
 ;
 ; ---------------------------------------------------------------------
getByPos(typ,pos) ; position value
 ;
 N des S des=dbAcc("*",typ,pos)
 N srn S srn=$piece(des,$C(9))
 N nam S nam=$piece(des,$C(9),2)
 ;
 Q dbAcc(srn,nam,pos)
 ;
 ; ---------------------------------------------------------------------
getInstMode(des) ; Instantiation descriptor
 ;
 N imd S imd=$piece(des,$C(9),13)
 ;
 I '(imd="") Q imd
 ;
 N exp S exp=$piece(des,$C(9),5)
 N cls S cls=$piece(des,$C(9))
 ;
 ; Cache.getRecord() and DbSet.getRecord() ==> 1
 I (",Cache,DbSet,"[(","_cls_",")) Q 1
 ;
 ; Class.new() ==> 0
 I cls="Class" Q 0
 ;
 ; Db.getRecord() ==> either -1 or 1
 I cls="Db" Q $S(+$$getPar^UCPATCH(exp,3)=1:-1,1:1)
 ;
 ; Record.copy(), same class ==> -2, different class ==> 0
 I $$isRecord^PSLClass(cls)>0 D  Q imd
 .	N dec S dec=$$getByPos("*",$piece(des,$C(9),2))
 .	S imd=$S($piece(dec,$C(9))=cls:"I",1:0)
 .	Q 
 Q -2
 ;
 ; ---------------------------------------------------------------------
ins2me(ins,rmd,exs,call) ; cache.getRecord call
 ;
 I rmd=-2 Q  ; Sorry, it won't get better
 ;
 I (exs="") S exs=0
 E  S exs=1
 ;
 N insDes S insDes=$$getByPos("=",ins)
 N imd S imd=$piece(insDes,$C(9),13)
 ;
 I imd="I" S imd=-2 ; do not yet chase inheritance tree
 ;
 I $piece(insDes,$C(9))="Cache" S call=$piece(insDes,$C(9),15)
 ;
 I rmd=imd Q 
 I imd="U" S exs=1 Q 
 I imd=-2 S rmd=-2 S exs=1 Q 
 I (rmd="") S rmd=imd Q 
 ;
 I rmd=0!(imd=0) S rmd=-2 S exs=1 Q 
 S rmd=-1
 Q 
 ;
 ; ---------------------------------------------------------------------
insApa2Apl(apa) ; actual parameter array
 N apl S apl=""
 N i
 F i=1:1:$order(apa(""),-1) S apl=apl_","_apa(i)
 Q $E(apl,2,1048575)
 ;
 ; ---------------------------------------------------------------------
insCode(mp1,ovs,occ,lbl,apl,head,tail) ; code following $$lbl(apl)
 ;
 N del S del="S "_ovs_"="
 N exp
 N apn N ptr
 N ER S ER=0 ; required by nextExpr^UCGM()
 ;
 S head=$piece(mp1,del,1,occ)
 S tail=$E(mp1,$L(head)+$L(del)+1,1048575)
 ;
 F ptr=1:1:$L(tail,")") S exp=$piece(tail,")",1,ptr)_")" Q:$L(exp,"(")=$L(exp,")") 
 S tail=$E(tail,$L(exp)+1,1048575)
 ;
 S lbl=$E($piece(exp,"("),3,$L(exp))
 S exp=$E(exp,$L(lbl)+4,$L(exp)-1)
 ;
 K apl ; in case caller provided a "used" array
 I (exp="") Q 
 ;
 S apn=0 S ptr=0
 ;
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 F  S del=$$nextExpr^UCGM(exp,.ptr,"",1,0) D  Q:'ptr 
 .	I del="," Q 
 .	S apn=apn+1 S apl(apn)=del
 .	Q 
 Q 
 ;
 ; ---------------------------------------------------------------------
insOptAA(decPos,apl) ; actual parameter list
 ;
 N asn S asn=""
 N key
 N nod
 ;
 F key=1:1:$order(apl(""),-1) D
 .	S nod=-key-2
 .	I '($D(dbAcc("*",decPos,nod))#2) Q 
 .	I '($D(apl(key))#2) Q  ; absent optional key
 .	S asn=asn_","_dbAcc("*",decPos,nod)_"="_apl(key)
 .	Q 
 Q asn
 ;
 ; ---------------------------------------------------------------------
insOptAP(decPos,apl) ; actual parameter list /MECH=REFARR:RW
 ;
 N asn S asn=""
 N key
 N nod
 N val
 ;
 F key=1:1:$order(apl(""),-1) D
 .	S nod=-key-2
 .	I '($D(dbAcc("*",decPos,nod))#2) Q 
 .	I '($D(apl(key))#2) Q  ; absent optional key
 .	S val=apl(key)
 .	S asn=asn_dbAcc("*",decPos,nod)_"="_val_","
 .	I $$isVar^UCGM(val) Q  ; don't replace VAR
 .	I $$isLit^UCGM(val) Q  ; don't replace literal
 .	I $E(val,1)=$char(0),$E(val,$L(val))=$char(0),$E(val,2,$L(val)-1)?1.N Q  ; tokenized literal
 .	;
 .	;   #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 .	I $$isSys^UCGM(val) Q  ; don't replace M svn
 .	S apl(key)=dbAcc("*",decPos,nod)
 .	Q 
 Q asn
 ;
 ; ---------------------------------------------------------------------
insOptCa(td,srn,ovs,ins,insDes,lbl,apl,head,tail) ; code following S ovs=$$lbl(apl)
 ;
 N lnr S lnr="" ; line number iterator in append(,)
 N vdbCod ; line in append(,)
 N vdbApl ; actual list of $$vDbN() in append(,)
 N vdbDes ; "instantiation" descriptor for vDb in append
 N vdbLbl ; label of $$vRCgetRecord() in append(,)
 ;
 F  S lnr=$order(append(lbl,lnr)) Q:lnr=""  D
 .	I append(lbl,lnr)'["vRCgetRecord" Q 
 .	D insCode(" S vOid=$$"_"vRCgetRecord"_$piece(append(lbl,lnr),"vRCgetRecord",2),"vOid",1,.vdbLbl,.vdbApl)
 .	;
 .	S vdbDes=insDes
 .	S $piece(vdbDes,$C(9),5)="Db.getRecord("""_$P(td,"|",1)_""","""",1)"
 .	;
 .	S vdbCod=$$insOptDb(td,lbl,"vOid",ins,vdbDes,vdbLbl,.vdbApl,"","")
 .	;
 .	S vdbLbl=$piece($piece(vdbCod,"vOid=",2),"(")
 .	S lnr=999
 .	Q 
 ;
 N expr S expr=$piece(insDes,$C(9),5)
 N tsl
 N dflt S dflt=$$getRecCN^UCDB($$getPar^UCPATCH(expr,3))
 ;
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 S expr=$piece($$TOKEN^%ZS(expr,.tsl),".getRecord(")
 ;
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 S expr=$$UNTOK^%ZS(expr,.tsl)
 ;
 N cmt S cmt="voXN = ({Cache}"_expr_".getRecord("_$P(td,"|",1)_","_dflt_")"
 ;
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 N p2lbl S p2lbl=$$findSubr^UCGM("vCa",cmt)
 ;
 I '$$hasSubr^UCGM(p2lbl) D CacheSr^UCDB(td,0,p2lbl,cmt,expr,dflt,vdbLbl)
 ;
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 D decrLabel^UCGM(lbl) ; decrement reference count old label
 ;
 N dec S dec=$piece(insDes,$C(9),2)
 ;
 S head=head_"S "_$$insOptAP(dec,.apl)
 S p2lbl="$$"_p2lbl_"("_$$insApa2Apl(.apl)
 ;
 ;set p2lbl = p2lbl_ $$getOptApl(td, dec)
 I dflt=1 S:'($E(p2lbl,$L(p2lbl))="(") p2lbl=p2lbl_"," S p2lbl=p2lbl_"."_dbAcc("*",dec,-2)
 ;
 S p2lbl=p2lbl_")"
 ;
 D setInsCall(srn,ovs,ins,p2lbl)
 ;
 N xnods S xnods=""
 I dflt=0,($D(dbAcc("*",dec,-2))#2) S xnods=","_dbAcc("*",dec,-2)_"=1"
 ;
 Q head_ovs_"="_p2lbl_xnods_tail
 ;
 ; ---------------------------------------------------------------------
insOptCl(td,srn,ovs,ins,insDes,lbl,apl,head,tail) ; code following S ovs=$$lbl(apl)
 ;
 N dec S dec=$piece(insDes,$C(9),2)
 N xnods S xnods=""
 I ($D(dbAcc("*",dec,-2))#2) S xnods=","_dbAcc("*",dec,-2)_"=0"
 ;
 Q head_"S "_ovs_"="""""_$$insOptAA(dec,.apl)_xnods_tail
 ;
 ; ---------------------------------------------------------------------
insOptCp(td,srn,ovs,ins,insDes,lbl,apl,head,tail) ; code following S ovs=$$lbl(apl)
 ;
 N cod ; code line being modified
 N decPos S decPos=$piece(insDes,$C(9),2)
 N ln ; line iterator
 ;
 F ln=1:1 Q:$E($translate(append(lbl,ln),$char(9)," "),1)'=" " 
 ;
 S cod=append(lbl,ln)
 I $piece(cod,";",2)[" to: " D
 .	N fnd S fnd=oLvn_"(vOid"
 .	;
 .	F  S ln=$order(append(lbl,ln)) Q:ln=""  D  S append(lbl,ln)=cod
 ..		;
 ..		S cod=append(lbl,ln)
 ..		;
 ..		I cod["Q vOid" S cod=" Q vRec" Q 
 ..		;
 ..		I cod'[fnd Q 
 ..		;
 ..		I cod["S vOid=" S cod=" ;"_cod Q 
 ..		I cod[("S "_fnd_")=") S cod=" ;"_cod Q 
 ..		;
 ..		I cod[(fnd_",-") D
 ...			;
 ...			N nod S nod=$piece($piece(cod,fnd_",",2),")")
 ...			;
 ...			I nod["-150" Q 
 ...			;
 ...			N lvn S lvn=$$lvpm(decPos,nod,0)
 ...			;
 ...			I lvn="" S cod=" ;"_cod Q 
 ...			;
 ...			S cod=" S "_lvn_"="_$piece(cod,"=",2,99)
 ...			Q  
 ..		Q  
 .	Q  
 E  D
 .	S ln=ln+1 S append(lbl,ln)=" ;"
 .	;
 .	N nod S nod="" ; purpose node iterator
 .	N expr ; vobj(v1,nod) (= source)
 .	N lvn ; target lvn
 .	N quitNod S quitNod="" ; node for function return
 .	;
 .	F  S nod=$order(dbAcc("*",decPos,nod)) Q:nod=""  D
 ..		S lvn=dbAcc("*",decPos,nod)
 ..		I lvn=ovs S quitNod=nod Q 
 ..		I nod?1.N1"*" Q  ; key-as-parameter mapping
 ..		;
 ..		S cod=" S "_lvn_"="
 ..		S expr=oLvn_"(v1,"_nod_")"
 ..		I nod<0 S cod=cod_oLvn_"(v1,"_nod_")"
 ..		E  I $E(nod,1)="~" S cod=cod_oLvn_"(v1,-300,"_$$QADD^%ZS($E(nod,2,1048575),"""")_")"
 ..		E  I $E(nod,1)="*" D  ; blob or memo
 ...			S ln=ln+1 S append(lbl,ln)=$$getLodCode^UCXDD(td,"v1",nod,-1,1)
 ...			N cd S cd=$$caPslCln^UCXDD(.pslCln,$P(td,"|",1)_"."_$E(nod,2,1048575))
 ...			S cod=cod_$$getCurLvn^UCXDD(cd,"v1")
 ...			Q 
 ..		E  S cod=cod_"$S($D("_expr_"):"_expr_",1:"_$$getDataNode^UCXDD(td,"v1",nod,0)_")"
 ..		;
 ..		S ln=ln+1 S append(lbl,ln)=cod
 ..		Q 
 .	;
 .	I (quitNod="") S quitNod=$$getRecPur^UCXDD(td)
 .	I (quitNod="") S cod=" Q """""
 .	E  I quitNod="0*" S cod=" Q "_oLvn_"(v1)"
 .	E  S expr=oLvn_"(v1,"_quitNod_")" S cod=" Q $S($D("_expr_"):"_expr_",1:"_$$getDataNode^UCXDD(td,"v1",quitNod,0)_")"
 .	;
 .	S ln=ln+1 S append(lbl,ln)=cod
 .	;
 .	F ln=ln+1:1 Q:'($D(append(lbl,ln))#2)  K append(lbl,ln)
 .	Q  
 ;
 Q head_"S "_ovs_"=$$"_lbl_"("_apl(1)_")"_tail
 ;
 ; ---------------------------------------------------------------------
insOptDb(td,srn,ovs,ins,insDes,lbl,apl,head,tail) ; code following S ovs=$$lbl(apl)
 ;
 I '($E(lbl,1,12)="vRCgetRecord") D pass2Err(ins,"Unexpected label '"_lbl_"' for Db.getRecord()") Q ""
 ;
 N expr S expr=$piece(insDes,$C(9),5)
 N dflt S dflt=$$getRecCN^UCDB($$getPar^UCPATCH(expr,3))
 N i
 N mcode S mcode=head
 ;
 S mcode=mcode_"S "
 ;
 N decPos S decPos=$piece(insDes,$C(9),2)
 N nod S nod=$order(dbAcc("*",decPos,""))
 ;
 I dflt=1,nod'<0,$$checkAccessRights^UCXDD(td,0)'["select",'$$hasSetting^PSLCC(.pslPrsr,"DEBUG","DBIOCOUNT") S mcode=mcode_ovs_"="_$$insOptNoVDB(td,decPos,.apl)
 E  D
 .	;
 .	N xnods S xnods=$$getOptApl(td,decPos)
 .	N optparams S optparams=$$insOptAP(decPos,.apl)
 .	N aparams S aparams=$$insApa2Apl(.apl)
 .	;
 .	I (aparams="") S aparams=xnods
 .	E  S aparams=aparams_","_xnods
 .	;
 .	S mcode=mcode_optparams_ovs_"=$$"_$piece(lbl,"^",1)_"Opt^"_$piece(lbl,"^",2)_"("_aparams_")"
 .	Q 
 ;
 Q mcode_tail
 ;
 ; ---------------------------------------------------------------------
insOptDs(td,srn,ovs,ins,insDes,lbl,apl,head,tail) ; code following S ovs=$$lbl(apl)
 ;
 N decPos S decPos=$piece(insDes,$C(9),2)
 N mcode N mid
 ;
 I ($D(dbAcc("*",decPos,-152))#2)!$$hasSetting^PSLCC(.pslPrsr,"DEBUG","DBIOCOUNT") Q $$insOptDb(td,srn,ovs,ins,insDes,lbl,.apl,head,tail)
 I ($D(dbAcc("*",decPos,-2))#2) S tail=","_dbAcc("*",decPos,-2)_"=1"_tail
 ;
 I '($E(lbl,1,12)="vRCgetRecord") D pass2Err(ins,"Unexpected label '"_lbl_"' for DbSet.getRecord()") Q ""
 ;
 ; Transform before build aparams
 S mid=$$insOptAP(decPos,.apl)
 ;
 N xnods S xnods=$$getOptApl(td,decPos)
 N optparams S optparams=$$insOptAP(decPos,.apl)
 N aparams S aparams=$$insApa2Apl(.apl)
 ;
 I (aparams="") S aparams=xnods
 E  S aparams=aparams_","_xnods
 ;
 Q head_"S "_mid_ovs_"=$$"_$piece(lbl,"^",1)_"Opt^"_$piece(lbl,"^",2)_"("_aparams_")"_tail
 ;
 ; ---------------------------------------------------------------------
insOptNoVDB(td,decPos,apl) ; pass 1 actual parameter list
 N vret
 N i
 N lvpm
 N nod S nod=$$getRecPur^UCXDD(td)
 ;
 ; No initial load: assign empty string
 I (nod="") Q """"""
 ;
 ; build key purpose nodes that use actual parameters
 F i=1:1:$order(apl(""),-1) S lvpm(i_"*")=apl(i)
 ;
 S vret=$$getDataNode^UCXDD(td,decPos,nod,0,.lvpm) Q vret
 ;
 ; ---------------------------------------------------------------------
isAutoLoad(purPos) ; Purpose identifier
 ;
 N data S data=dbAcc("*","<",purPos)
 N pur S pur=$piece(data,$C(9),2)
 ;
 I $piece(data,$C(9),2)?1.N1"*" Q 1 ; top node and keys AutoLoad
 I +pur<0 Q 1 ; other neg nodes are AutoLoad
 I pur?.E1","1.N Q 0 ; blob/memo never AutoLoad
 ;
 N decPos S decPos=$piece(data,$C(9))
 S data=dbAcc("*","*",decPos)
 ;
 N sr S sr=$piece(data,$C(9))
 N nam S nam=$piece(data,$C(9),2)
 ;
 S data=dbAcc(sr,nam,decPos)
 ;
 N tbl S tbl=$$tableNameOf^PSLClass($piece(data,$C(9)))
 ;
 N td S td=$$caPslTbl^UCXDD(.pslTbl,tbl,0)
 ;
 I $P(td,"|",4)'=10 Q 0
 ;
 Q pur=$P(td,"|",12)
 ;
 ; ---------------------------------------------------------------------
isDec(data,pos) ; the position value
 ;
 N dpd S dpd=$piece(data,$C(9),2)
 ;
 I (dpd="") Q 1 ; standard dec
 I dpd=pos Q 1 ; combined dec/ins
 Q 0
 ;
 ; ---------------------------------------------------------------------
isDoScope(outer,inner) ; inner scope odState
 I inner=outer Q 1
 ;
 N diff S diff=$L(inner)-$L(outer)
 I $E(inner,diff)="," Q ($E(inner,$L(inner)-$L(outer)+1,1048575)=outer)
 Q 0
 ;
 ; ---------------------------------------------------------------------
isIns(data) ; dbAcc(,,) data string
 ;
 I ($piece(data,$C(9),2)="") Q 0 ; standard dec
 Q ($piece(data,$C(9),4)="") ; standard ins
 ;
 ; ---------------------------------------------------------------------
ldMap(ldMode,ldMap) ; incremental load mapping (*2)
 ;
 N acc N accMin N elm N pur
 N accDes N accState N data N expr N nod N ovs N sr
 N load4 ; first round, four level map
 ;
 S acc=""
 F  S acc=$order(dbAcc("*","@",acc)) Q:acc=""  D
 .	S data=dbAcc("*","@",acc)
 .	S sr=$piece(data,$C(9)) S ovs=$piece(data,$C(9),2)
 .	S expr=$piece(dbAcc(sr,ovs,acc),$C(9),5)
 .	I '$$isWrap(expr) D  ; not yet wrapped
 ..		I '$$expIsCln(expr) Q 
 ..		;
 ..		N cd S cd=$$caPslCln^UCXDD(.pslCln,expr,.pslTbl)
 ..		;
 ..		I '($P(cd,"|",14)="") Q 
 ..		;
 ..		I $P(cd,"|",15)=2 D
 ...			N sfd
 ...			N dummy S dummy=$$getSfd^UCXDD($P(cd,"|",1),$P(cd,"|",2),.sfd)
 ...			N sf S sf=sfd(1)
 ...			S cd=$$getPslCln^UCXDD($P(cd,"|",1),$P(sf,$C(126),1))
 ...			Q 
 ..		;
 ..		; tbd: if keycolumn AND assignment AND MDB table
 ..		; AND possibly existing node, force load positions for
 ..		; all data purpose nodes if existing node.
 ..		;
 ..		S nod=$$getCurNode^UCXDD(cd,1)
 ..		I nod?.E1","1.N S nod="*"_$P(cd,"|",2)
 ..		S expr=$$lvpm($piece(dbAcc(sr,ovs,acc),$C(9),2),nod,1)
 ..		Q 
 .	;
 .	I '$$isWrap(expr) Q  ; not a purPos (eg computed)
 .	S pur=$E(expr,2,$L(expr)-1)
 .	;
 .	I $$isAutoLoad(pur) Q  ; discard if AutoLoad node
 .	;
 .	S accDes=dbAcc(sr,ovs,acc)
 .	S accState=$$new^UCPSLST($piece(accDes,$C(9),7),$piece(accDes,$C(9),8),$piece(accDes,$C(9),9))
 .	I $$topFor^UCPSLST(accState) D pop^UCPSLST(.accState)
 .	I $$topIf^UCPSLST(accState) D pop^UCPSLST(.accState)
 .	;
 .	I $$ldMapMode(ldMode,sr,ovs,accDes)=1 D ldMap4Ins(.load4,pur,acc,$$getDo^UCPSLST(accState),$piece(accDes,$C(9),4)) Q 
 .	D ldMap4Acc(.load4,pur,acc,$$getDo^UCPSLST(accState),$piece(accDes,$C(9),4))
 .	Q 
 ;
 N pos N s1 S s1=""
 ;
 F  S s1=$order(load4(s1)) Q:(s1="")  D
 .	I ($D(dbAcc("*","=",s1))#2) S pos=$$ldMap1Ins(.ldMap,.load4,s1)
 .	E  S pos=$$ldMap1Acc(.ldMap,.load4,s1)
 .	;
 .	S pur=$piece($piece(ldMap(pos),$C(9),4),",")
 .	N dec S dec=$piece(dbAcc("*","<",pur),$C(9))
 .	I $piece(ldMap(pos),$C(9))=-2 S expr=$$lvpm(dec,-2,1)
 .	;
 .	N des S des=$$getByPos("*",dec)
 .	N td S td=$$caPslTbl^UCXDD(.pslTbl,$$tableNameOf^PSLClass($piece(des,$C(9))),1)
 .	;
 .	I '($$getArchiveTable^DBARCHIVE(td)="") S expr=$$lvpm(dec,-99,1)
 .	;
 .	I '$$isRdb^vRuntime Q  ; no extras for MDB inc load
 .	;
 .	I '($P(td,"|",8)'="GTM") Q  ; MDB table in RDB environment
 .	;
 .	I $piece(ldMap(pos),$C(9))=-1 S expr=$$lvpm(dec,-2,1)
 .	I ($P(td,"|",5)["B")!($P(td,"|",5)["M") S expr=$$lvpm(dec,-2,1) S expr=$$lvpm(dec,-152,1) Q 
 .	Q 
 ;
 Q 
 ;
 ; ---------------------------------------------------------------------
ldMap1Acc(ldMap,load4,pur) ; purpose position
 ;
 N acc N accLine N cc N cci N des N des2 N exs N ins N pos N rmd N srn
 N stk N load2
 ;
 S (acc,stk,ins)=""
 F  S stk=$order(load4(pur,stk)) Q:stk=""  D
 .	F  S acc=$order(load4(pur,stk,acc)) Q:acc=""  D
 ..		F  S ins=$order(load4(pur,stk,acc,ins)) Q:ins=""  S load2(acc,ins)=""
 ..		Q 
 .	Q 
 ;
 S (acc,exs,rmd)=""
 S pos=$piece(dbAcc("*","<",pur),$C(9))
 S des=$piece(dbAcc("*","*",pos),$C(9)) ; subroutine and var
 ;
 F  S acc=$order(load2(acc)) Q:acc=""  D
 .	S (pos,accLine)=acc\1
 .	F  S pos=$order(ldMap(pos)) Q:(pos\1)'=accLine  Q:$get(dbAcc("*","@",pos))=des 
 .	;
 .	I (pos\1)'=accLine S pos=acc
 .	;
 .	I ($D(ldMap(pos))#2) S ldMap(pos)=ldMap(pos)_","_pur Q 
 .	;
 .	;set (rmd,exs,cc,cci,ins)=""
 .	S (cc,cci,ins)=""
 .	F  Q:'(rmd'=-2)  S ins=$order(load2(acc,ins)) Q:ins=""  D ins2me(ins,.rmd,.exs,.cc) I (cci=""),'(cc="") S cci=ins
 .	;
 .	S ldMap(pos)=rmd_$C(9)_exs_$C(9)_cci_$C(9)_pur
 .	Q 
 Q pos
 ;
 ; ---------------------------------------------------------------------
ldMap1Ins(ldMap,load4,ins) ; instatiation position
 ;
 N cci N exs S exs="" N rmd S rmd="" N pur S pur=""
 N cc S cc="" N purList S purList=""
 D ins2me(ins,.rmd,.exs,.cc)
 ;
 F  S pur=$order(load4(ins,pur)) Q:(pur="")  S purList=purList_","_pur
 ;
 I '(cc="") S cc=ins
 S ldMap(ins)=rmd_$C(9)_exs_$C(9)_cc_$C(9)_$E(purList,2,1048575)
 ;
 Q ins
 ;
 ; ---------------------------------------------------------------------
ldMap4Acc(purByDo,pur,acc,accDo,insList) ; applicable instantiations
 ;
 N accMin S accMin=$order(purByDo(pur,accDo,acc),-1)
 ;
 I (accMin="") S accMin=acc
 ;
 N elm
 F elm=1:1:$S((insList=""):0,1:$L(insList,",")) D
 .	N ins S ins=$piece(insList,",",elm)
 .	N cls S cls=$piece($$getByPos("=",ins),$C(9))
 .	;
 .	I $$isRecord^PSLClass(cls)>0 Q 
 .	;
 .	N outer S outer=0 ; start with non-NULL value !!
 .	N loadDo S loadDo=accDo ; assume in supplied block
 .	N loadPos S loadPos=$S(ins<accMin:accMin,1:acc)
 .	F  Q:'('(outer=""))  D
 ..		S outer=$order(purByDo(pur,outer))
 ..		I '$$isDoScope(outer,accDo) Q 
 ..		N outerMin S outerMin=$order(purByDo(pur,outer,acc),-1)
 ..		I outerMin>ins S loadDo=outer S loadPos=outerMin S outer=""
 ..		Q 
 .	;
 .	I (loadPos\1)=(ins\1),loadPos>ins D
 ..		N insDes S insDes=$$getByPos("=",ins)
 ..		I ($piece(insDes,$C(9),5)="") Q 
 ..		D pass2Warn(ins,"DATABASE","Instantiation and access on same line may cause unexpected results for "_$piece(dbAcc("*","=",ins),$C(9),2))
 ..		Q 
 .	;
 .	S accMin=$order(purByDo(pur,loadDo,loadPos\1))
 .	I (loadPos\1)=(accMin\1),loadPos'=accMin S loadPos=accMin
 .	;
 .	S purByDo(pur,loadDo,loadPos,ins)=""
 .	Q 
 Q 
 ;
 ; ---------------------------------------------------------------------
ldMap4Ins(insByPur,pur,acc,accDo,insList) ; applicable instantiations
 ;
 N elm
 F elm=1:1:$S((insList=""):0,1:$L(insList,",")) D
 .	N ins S ins=$piece(insList,",",elm)
 .	N cls S cls=$piece($$getByPos("=",ins),$C(9))
 .	;
 .	I $$isRecord^PSLClass(cls)>0 Q 
 .	;
 .	S insByPur(ins,pur,acc,accDo)=""
 .	Q 
 Q 
 ;
 ; ---------------------------------------------------------------------
ldMapMode(ldMode,srn,nam,accDes) ; 
 ;
 I ldMode=2 Q 2
 ;
 ; supplied ldMode = 1 for all code below
 N decDes S decDes=dbAcc(srn,nam,$piece(accDes,$C(9),2))
 ;
 I $piece(decDes,$C(9),3)="PUBLIC" Q 2 ; PUBLIC = at acc
 ;
 ; check for conditional instantiations
 N insList S insList=$piece(accDes,$C(9),4)
 N elm N ins
 N insDes
 F elm=1:1:$S((insList=""):0,1:$L(insList,",")) S ins=$piece(insList,",",elm) S insDes=dbAcc(srn,nam,ins) I $E($piece(insDes,$C(9),8),1) S ldMode=2 Q 
 I ldMode=2 Q 2 ; conditional ins.
 ;
 I $piece(decDes,$C(9),3)'["FORMAL" Q 1 ; not FORMAL
 ;
 ; scope = FORMAL for all code below
 I '($piece(decDes,$C(9),16)="") Q 2 ; subscripted = at acc
 I $piece(decDes,$C(9),11)<0 Q 1 ; local = at ins
 I ($piece(decDes,$C(9),11)="") Q 1 ; no ins, implied local
 ;
 Q 2 ; don't take the risc
 ;
 ; ---------------------------------------------------------------------
load(mp1,load,pp2lv) ; purPos-to-localVar map (*3)
 ;
 N occ S occ="" ; occurrence position iterator
 ;
 F  S occ=$order(load(occ)) Q:occ=""  D
 .	I ($D(dbAcc("*","=",occ))#2) D loadIns(.mp1,occ,load(occ),.pp2lv) Q 
 .	D loadAcc(.mp1,occ,load(occ),.pp2lv)
 .	Q 
 Q 
 ;
 ; ---------------------------------------------------------------------
loadAcc(mp1,acc,occDes,pp2lv) ; purpose-to-lvn map
 ;
 ; decompose occDes
 N rmd S rmd=$piece(occDes,$C(9),1)
 N exs S exs=$piece(occDes,$C(9),2)
 N caIns S caIns=$piece(occDes,$C(9),3) ; ins of Cache.getRec
 N purLst S purLst=$piece(occDes,$C(9),4)
 ;
 N accDes S accDes=dbAcc("*","@",acc) ; access index
 N srt S srt=$piece(accDes,$C(9)) ; subroutine
 N nam S nam=$piece(accDes,$C(9),2) ; object variable
 ;
 S accDes=dbAcc(srt,nam,acc) ; access descriptor
 N dec S dec=$piece(accDes,$C(9),2) ; declaration position
 ;
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 N dots S dots=$$initLine^UCGM($piece(accDes,$C(9),6))
 ;
 N tbl S tbl=$$tableNameOf^PSLClass($piece(accDes,$C(9)))
 ;
 I '($D(pslTbl(tbl))#2) S pslTbl(tbl)=$$getPslTbl^UCXDD(tbl,0)
 ;
 ; create lvpm() based on this access position and purpose list
 ; tbd
 N lvpm
 ;
 N subs S subs=$piece(accDes,$C(9),16)
 I '(subs="") D loadLvpm(.lvpm,dec,subs)
 ;
 D loadXnodes(srt,nam,dec,subs,($P(pslTbl(tbl),"|",8)'="GTM"),.pp2lv,.lvpm)
 ;
 N cod
 N elm
 N lnr S lnr=$order(mp1(acc\1),-1)
 ;
 F elm=1:1:$S((purLst=""):0,1:$L(purLst,",")) D
 .	S cod=$$loadCode(dec,$piece(purLst,",",elm),rmd,exs,caIns,.lvpm)
 .	S lnr=lnr+1E-3
 .	S mp1(lnr)=dots_$$pur2M(cod,.pp2lv,.lvpm)
 .	Q 
 ;
 Q 
 ;
 ; ---------------------------------------------------------------------
loadCmp(dec,pur,rmd,exs,lvpm) ; dbAcc(,,) override values (*3)
 ;
 N node S node=$piece(dbAcc("*","<",pur),$C(9),2)
 N left S left=$$pass2lvpm(dec,node,.lvpm)
 ;
 N code S code=" S"
 I exs S code=code_":'$D("_left_")#2"
 S code=code_" "_left_"="
 ;
 I rmd=0 Q code_""""""
 ;
 Q code_dbAcc("*","<$$",pur)
 ;
 ; ---------------------------------------------------------------------
loadCode(dec,pur,rmd,exs,cacheIns,lvpm) ; purpose-to-lvn map
 ;
 N decIdx S decIdx=dbAcc("*","*",dec)
 N code
 N node S node=$piece(dbAcc("*","<",pur),$C(9),2)
 N ovs S ovs=$piece(decIdx,$C(9),2)
 N srn S srn=$piece(decIdx,$C(9))
 N tbl S tbl=$$tableNameOf^PSLClass($piece(dbAcc(srn,ovs,dec),$C(9)))
 ;
 I '($D(pslTbl(tbl))#2) S pslTbl(tbl)=$$getPslTbl^UCXDD(tbl,0)
 ;
 N td S td=pslTbl(tbl)
 I $$nodIsBM^UCXDD(node)!$$nodIsNeg^UCXDD(node)!($P(td,"|",8)'="GTM") S cacheIns=""
 I rmd=0,($P(td,"|",8)'="GTM"),$P(td,"|",4)=11 S code=" ; node "_node_" already created by Cleass.new()"
 E  I $E(node,1)="~" S code=$$loadCmp(dec,pur,rmd,exs,.lvpm)
 ;  #ACCEPT CR=27800;Date=2007-10-11;PGM=Frans S.C. Witte;Group=MISMATCH; passes Number as PLSIdentifier
 E  I (cacheIns="") S code=$$getLodCode^UCXDD(td,dec,node,rmd,exs,.lvpm)
 E  D
 .	N left S left=$$pass2lvpm(dec,node,.lvpm) ; target lvn
 .	N expr S expr=$piece(dbAcc(srn,ovs,cacheIns),$C(9),15)
 .	I $E(expr,1)'="$" S expr="$$"_expr
 .	;
 .	I expr?1"$$vCa"1.N1"()" S expr=$piece(expr,"(")_"L("_node_")"
 .	E  D
 ..		N keys S keys=$P(td,"|",3)
 ..		N k
 ..		S expr=$piece(expr,"(")_"L("
 ..		F k=1:1:$S((keys=""):0,1:$L(keys,",")) S expr=expr_$$pass2lvpm(dec,k_"*",.lvpm)_","
 ..		S expr=expr_node_")"
 ..		Q 
 .	;
 .	S code=" S"
 .	I exs S code=code_":'$D("_left_")"
 .	S code=code_" "_left_"="
 .	;
 .	I rmd<0 S code=code_"$S("_$$pass2lvpm(dec,-2,.lvpm)_":"_expr_",1:"""")"
 .	E  S code=code_expr
 .	Q 
 Q code
 ;
 ; ---------------------------------------------------------------------
loadIns(mp1,ins,occDes,pp2lv) ; purpose-to-lvn map
 ;
 ; decompose occDes
 N rmd S rmd=$piece(occDes,$C(9),1)
 N exs S exs=$piece(occDes,$C(9),2)
 N caIns S caIns=$piece(occDes,$C(9),3) ; ins of Cache.getRec
 N purLst S purLst=$piece(occDes,$C(9),4)
 ;
 N insDes S insDes=dbAcc("*","=",ins) ; instance index
 N srt S srt=$piece(insDes,$C(9)) ; subroutine
 N nam S nam=$piece(insDes,$C(9),2) ; object variable
 ;
 S insDes=dbAcc(srt,nam,ins) ; instance descriptor
 N dec S dec=$piece(insDes,$C(9),2) ; declaration position
 N lvl S lvl=$piece(insDes,$C(9),6)
 ;
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 N dots S dots=$$initLine^UCGM(lvl)
 ;
 N tbl S tbl=$piece(insDes,$C(9))
 I $$isRecord^PSLClass(tbl) D  ; table can be derived from insDes
 .	S tbl=$$tableNameOf^PSLClass(tbl)
 .	Q 
 E  D  ; need to look at declaration
 .	S tbl=$$tableNameOf^PSLClass($piece(dbAcc(srt,nam,dec),$C(9)))
 .	Q 
 ;
 I '($D(pslTbl(tbl))#2) S pslTbl(tbl)=$$getPslTbl^UCXDD(tbl,0)
 ;
 ; create lvpm() based on this access position and purpose list
 ; tbd
 N lvpm
 ;
 N subs S subs=$piece(insDes,$C(9),16)
 I '(subs="") D loadLvpm(.lvpm,dec,subs)
 ;
 N lnr S lnr=(ins\1)+1
 ;
 N ln1 S ln1=$order(mp1(ins\1))
 N needSrn S needSrn=$E($translate(mp1(ln1),$char(9)_" "),1,lvl+1)?."."
 ;
 I needSrn D
 .	I $piece(insDes,$C(9),3)'="PUBLIC" Q  ; not PUBLIC
 .	N occ S occ=$order(dbAcc(srt,nam,ins),-1)
 .	I occ'=$piece(insDes,$C(9),2) Q  ; not the decl.
 .	;
 .	; can insert code before instantiation
 .	S lnr=lnr-1 S needSrn=0
 .	Q 
 ;
 I needSrn D pass2Warn(ins,"DATABASE","Cannot insert incremental load code after instantiation")
 ;
 D loadXnodes(srt,nam,dec,subs,($P(pslTbl(tbl),"|",8)'="GTM"),.pp2lv,.lvpm)
 ;
 N cod
 N elm
 ;
 S lnr=$order(mp1(lnr),-1) ; last line after ins\1
 F elm=1:1:$S((purLst=""):0,1:$L(purLst,",")) D
 .	;
 .	S cod=$$loadCode(dec,$piece(purLst,",",elm),rmd,exs,caIns,.lvpm)
 .	S lnr=lnr+1E-3
 .	S mp1(lnr)=dots_$$pur2M(cod,.pp2lv,.lvpm)
 .	Q 
 ;
 Q 
 ;
 ; ---------------------------------------------------------------------
loadLvpm(lvpm,dec,subs) ; subscript expression to append
 ;
 N des ; scratch data
 N left ; leftexpr to use
 N n ; key ordinal iterator
 N nam ; subscripted object var
 N nod S nod="" ; purpose node iterator
 N nodLvpm ; node in lvpm()
 N ovs ; object variable
 N srn ; subroutine
 N tbl ; table name
 N td ; table descriptor (from cache)
 ;
 S des=dbAcc("*","*",dec)
 S srn=$piece(des,$C(9))
 S ovs=$piece(des,$C(9),2)
 S nam=ovs_subs
 S des=dbAcc(srn,ovs,dec)
 S tbl=$$tableNameOf^PSLClass($piece(des,$C(9)))
 S td=$$caPslTbl^UCXDD(.pslTbl,tbl,0)
 ;
 F  S nod=$order(dbAcc("*",dec,nod)) Q:nod=""  D
 .	S left=dbAcc("*",dec,nod)
 .	;
 .	; complex computeds don't go through $$lvpm^UCXDD()
 .	I $E(nod,1)="~" S lvpm(nod)=oLvn_"("_nam_",-300,"_$$QADD^%ZS($E(nod,2,1048575),"""")_")" Q 
 .	;
 .	; if not wrapped, and not subscripted, use as defined
 .	I '$$isWrap(left),(subs="") S lvpm(nod)=left Q 
 .	;
 .	I $E(nod,1)="*" D
 ..		N cd S cd=$$caPslCln^UCXDD(.pslCln,tbl_$translate(nod,"*","."),.pslTbl)
 ..		S nodLvpm=$$getCurNode^UCXDD(cd,0)
 ..		Q 
 .	E  S nodLvpm=nod
 .	;
 .	S lvpm(nodLvpm)=$$lvpm^UCXDD(nam,nodLvpm)
 .	Q 
 ;
 F n=-2,-152 I '($D(lvpm(n))#2) S lvpm(n)=$$lvpm^UCXDD(nam,n)
 I '($$getArchiveTable^DBARCHIVE(td)="") S lvpm(-99)=$$lvpm^UCXDD(nam,-99)
 F n=1:1:$S(($P(td,"|",3)=""):0,1:$L($P(td,"|",3),",")) I ($D(lvpm(n_"*"))#2) S lvpm(n_"*")=$$lvpm^UCXDD(nam,n_"*")
 ;
 Q 
 ;
 ; ---------------------------------------------------------------------
loadXnodes(srt,nam,dec,subs,isRdb,pp2lv,lvpm) ; create the extra nodes (-99, -161, and -162)
 ;
 N cod
 ;
 ; If archived (purpose node -99), set lvpm to ensure extended reference
 I ($D(dbAcc("*",dec,-99))#2) S cod=dbAcc("*",dec,-99) S lvpm(-99)=$S($$isWrap(cod):pp2lv($$stripWrap(cod)),1:cod)
 ;
 ; If using vobj and is RDB, set up map for -161/-162 as signal to
 ; getLodCode^UCXDD to create those nodes
 Q:'$piece(dbAcc(srt,nam,dec),$C(9),10) 
 Q:'isRdb 
 ;
 S lvpm(-161)=oLvn_"("_nam_subs_",-161,"
 S lvpm(-162)=oLvn_"("_nam_subs_",-162,"
 ;
 Q 
 ;
 ; ---------------------------------------------------------------------
lvMap(map) ; purPos to lvn map   /MECH=REFARR:W
 ;
 N dec S dec="" ; declaration position
 N des ; scratch data
 N n ; key ordinal iterator
 N nam ; object variable
 N nod S nod="" ; purpose node iterator
 N nodLvpm ; purpose node for $$lvpm^UCXDD()
 N pur ; purpose position
 N srn ; subroutine
 N tbl ; table name
 N td ; table descriptor (from cache)
 ;
 F  S dec=$order(dbAcc("*",dec)) Q:'(dec=+dec)  D
 .	;
 .	S des=dbAcc("*","*",dec)
 .	S srn=$piece(des,$C(9))
 .	S nam=$piece(des,$C(9),2)
 .	S des=dbAcc(srn,nam,dec)
 .	S tbl=$$tableNameOf^PSLClass($piece(des,$C(9)))
 .	;
 .	I '(tbl="") S td=$$caPslTbl^UCXDD(.pslTbl,tbl,0)
 .	;
 .	F  S nod=$order(dbAcc("*",dec,nod)) Q:nod=""  D
 ..		S pur=dbAcc("*",dec,nod)
 ..		;
 ..		; if not wrapped, skip
 ..		I '$$isWrap(pur) Q 
 ..		;
 ..		S pur=$$stripWrap(pur)
 ..		;
 ..		; if already defined, don't overwrite
 ..		I ($D(map(pur))#2) Q 
 ..		;
 ..		; complex computeds don't go through $$lvpm^UCXDD()
 ..		I $E(nod,1)="~" S map(pur)=oLvn_"("_nam_",-300,"_$$QADD^%ZS($E(nod,2,1048575),"""")_")" Q 
 ..		;
 ..		I $E(nod,1)="*" D  ; Translate *BM to "real" node
 ...			N cd S cd=$$caPslCln^UCXDD(.pslCln,tbl_$translate(nod,"*","."),.pslTbl)
 ...			S nodLvpm=$$getCurNode^UCXDD(cd,0)
 ...			; may need to ensure that -152 node is defined ???
 ...			Q 
 ..		E  S nodLvpm=nod
 ..		;
 ..		S map(pur)=$$lvpm^UCXDD(nam,nodLvpm)
 ..		Q 
 .	;
 .	I '(tbl="") F n=1:1:$S(($P(td,"|",3)=""):0,1:$L($P(td,"|",3),",")) I '($D(dbAcc("*",dec,n_"*"))#2),'($D(dbAcc("*",dec,-n-2))#2) S dbAcc("*",dec,n_"*")=$$lvpm^UCXDD(nam,n_"*")
 .	Q 
 Q 
 ;
 ; ---------------------------------------------------------------------
paSetVobj(srn,ovs,dec,bWarn) ; warning needed?
 ;
 N decDes S decDes=dbAcc(srn,ovs,dec)
 Q:$piece(decDes,$C(9),10) 
 ;
 S $piece(dbAcc(srn,ovs,dec),$C(9),10)=1
 I bWarn D pass2Warn(dec,"INTERNAL","possible vobj() memory leak for "_ovs_" in "_srn)
 ;
 Q 
 ;
 ; ---------------------------------------------------------------------
pass2Err(pos,msg) ; PSL error message
 ;
 N xdes S xdes=$$findXDes(pos)
 ;
 N ER S ER="" ; set by PSL.error()
 N lptr ; source line poiter expected by WARN^UCGM()
 N subRou ; name of subroutine expected by WARN^UCGM()
 N tok S tok="" ; referenced in WARN^UCGM() if msg[$C(0)
 ;
 I (xdes="") S subRou=" " S lptr=0
 E  D
 .	N desX S desX=$piece(xdes,$C(9),2,3)
 .	N desD S desD=$piece(xdes,$C(9),4,$L(xdes,$C(9)))
 .	S subRou=$piece(desX,$C(9))
 .	S lptr=$piece(desD,$C(9),14)
 .	Q 
 D ERROR^UCGM(msg)
 Q 
 ;
 ; ---------------------------------------------------------------------
pass2lvpm(decPos,node,lvpm) ; overrides (*3)
 ;
 I (node="") S node="0*" ; sync with UCXDD !!!!
 ;
 I ($D(lvpm(node))#2) Q lvpm(node)
 ;
 ; key purpose node fall-back has higher precedence than dbAcc(,,key_"*)
 I node?1.N1"*",node'="0*",($D(lvpm(-2-+node))#2) Q lvpm(-2-+node)
 ;
 I ($D(dbAcc("*",decPos,node))#2) Q dbAcc("*",decPos,node)
 ;
 ; needed as fall-back for a non-existant dbAcc( "*", decPos, key_"*")
 I node?1.N1"*",node'="0*" Q $$pass2lvpm(decPos,-2-+node,.lvpm)
 ;
 Q $$lvpm^UCXDD($piece(dbAcc("*","*",decPos),$C(9),2),node)
 ;
 ; ---------------------------------------------------------------------
pass2Warn(pos,grp,msg) ; PSL warning message
 ;
 N xdes S xdes=$$findXDes(pos)
 ;
 N ER S ER="" ; set by PSL.error()
 N lptr ; source line poiter expected by WARN^UCGM()
 N subRou ; name of subroutine expected by WARN^UCGM()
 N tok S tok="" ; referenced in WARN^UCGM() if msg[$C(0)
 ;
 I (xdes="") S subRou=" " S lptr=0
 E  D
 .	N desX S desX=$piece(xdes,$C(9),2,3)
 .	N desD S desD=$piece(xdes,$C(9),4,$L(xdes,$C(9)))
 .	S subRou=$piece(desX,$C(9))
 .	S lptr=$piece(desD,$C(9),14)
 .	Q 
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 D warnGroup^UCGM(grp,msg)
 Q 
 ;
 ; ---------------------------------------------------------------------
pur2M(code,map,override) ; override the map() entries
 ;
 N acc N b N e N q
 N RdbCodeForm S RdbCodeForm=0
 N node N wrap
 N origcode
 ;
 S origcode=code
 ;
 F b=$F(code,$C(7)):0 Q:b=0  D
 .	S e=b
 .	F  S e=$F(code,$C(8),e) Q:$L($E(code,1,e-1),$C(7))=$L($E(code,1,e-1),$C(8)) 
 .	;
 .	S wrap=$E(code,b,e-2)
 .	I (wrap=+wrap) D
 ..		I '($D(dbAcc("*","<",wrap))#2) S wrap=map(wrap) Q 
 ..		S node=$piece(dbAcc("*","<",wrap),$C(9),2)
 ..		I '($D(map(wrap))#2) D
 ...			N dec S dec=$piece(dbAcc("*","<",wrap),$C(9))
 ...			I '$$isWrap(dbAcc("*",dec,node)) S map(wrap)=dbAcc("*",dec,node)
 ...			Q 
 ..		I ($D(map(wrap))#2)'!($D(override(node))#2) S (code,wrap)="" Q 
 ..		S wrap=$get(override(node),map(wrap))
 ..		Q 
 .	E  D
 ..		S wrap=$$pur2M(wrap,.map,.override)
 ..		I $$vStrIsNum($piece(wrap,"=")) S wrap=$$clnAsn2(wrap,RdbCodeForm)
 ..		Q 
 .	;
 .	S code=$E(code,1,b-2)_wrap_$E(code,e,1048575)
 .	S b=$F(code,$C(7))
 .	;
 .	; Try again
 .	I (RdbCodeForm=0),'($ZLENGTH(code)'>1980) D
 ..		;
 ..		S code=origcode
 ..		S b=$F(code,$C(7))
 ..		S RdbCodeForm=1
 ..		Q 
 .	Q 
 Q code
 ;
 ; ---------------------------------------------------------------------
purByAcc(accPos,pur) ; purpose value
 ;
 N decOvs S decOvs=dbAcc("*","@",accPos)
 N sr S sr=$piece(decOvs,$C(9))
 N nam S nam=$piece(decOvs,$C(9),2)
 ;
 N des S des=dbAcc(sr,nam,accPos)
 ;
 N decPos S decPos=$piece(des,$C(9),2)
 S $piece(des,$C(9),5)=$$lvpm(decPos,pur,1)
 ;
 N pos S pos=$$createPos(accPos\1)
 ;
 S dbAcc(sr,nam,pos)=des
 S dbAcc("*","@",pos)=sr_$C(9)_nam
 ;
 Q $piece(des,$C(9),5)
 ;
 ; ---------------------------------------------------------------------
setDecVal(sr,ovs,field,val) ; value to assign
 ;
 N nam S nam=$piece(ovs,"(")
 N dec S dec=$$findDec(sr,nam)
 S $piece(dbAcc(sr,nam,dec),$C(9),field)=$translate(val,$C(9),$char(10))
 ;
 Q 
 ;  #OPTION ResultClass ON
vSIG() ; 
 Q "61473^50064^Frans S.C. Witte^181216" ; Signature - LTD^TIME^USER^SIZE
 ; ----------------
 ;  #OPTION ResultClass 1
vPSLopti(var) ; PSLIdentifier.optimize()
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 N varLevel S varLevel=$$getLevel^UCGM(var)
 N opti S opti=+$$getAtt^UCGM(var,varLevel,10)
 I opti>msrc S opti=0 D setOpti^UCGM(var,varLevel,0)
 Q opti=0
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
vaddSubr(p1,p2,p3,p4) ; PSL.addSubrou
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 I $get(p4) S:$E(p1,1)'="v" p1="v"_p1 S p1=$$findSubr^UCGM(p1,"")
 E  I $$hasSubr^UCGM(p1) D ERROR^UCGM("Subroutine exists: "_p1) Q p1
 D addSubr^UCGM(p1,p2,p3)
 Q p1
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
 ;
vStrIsNum(vStr) ; String.isNumber
 ;
 Q vStr=+vStr
