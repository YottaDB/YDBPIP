 ; 
 ; **** Routine compiled from DATA-QWIK Procedure PSLParser ****
 ; 
 ; 02/24/2010 18:22 - pip
 ; 
 ;  #PACKAGE  framework.psl
 ;  #CLASSDEF extends=PSLCC public
 ;
 ; top-node properties -------------------------------------------------
 ; ---------------------------------------------------------------------
 ;  #PROPERTYDEF methodName  class=String public readonly position=2
 ;
 ;  #PROPERTYDEF lastLine  class=Number private position=3
 ;
 ; ---------------------------------------------------------------------
 ;  #PROPERTYDEF element  class=String public position=4
 ;
 ; node-only properties ------------------------------------------------
 ; ---------------------------------------------------------------------
 ;  #PROPERTYDEF logCounts  class=String private node="logCounts"
 ;
 ; ---------------------------------------------------------------------
 ;  #PROPERTYDEF logfile  class=String public node="logfile"
 ;
 ; ---------------------------------------------------------------------
 ;  #PROPERTYDEF moduleName  class=String public readonly node="moduleName"
 ;
 ; ---------------------------------------------------------------------
 ;  #PROPERTYDEF parseLevel  class=Number node="parseLevel"
 ;   #PROPERTYDEF parseLevelCLASS = 0 public literal
 ;   #PROPERTYDEF parseLevelPSLX  = 1 public literal
 ;   #PROPERTYDEF parseLevelPSL   = 2 public literal
 ;   #PROPERTYDEF parseLevelFULL  = 3 public literal
 ;
 ; ---------------------------------------------------------------------
 ;  #PROPERTYDEF refPrp  class=List readonly node="refPrp"
 ;
 ; ---------------------------------------------------------------------
 ;  #PROPERTYDEF targetComment class=String readonly node="tgtCmt"
 ;
 ; array properties ----------------------------------------------------
 ; ---------------------------------------------------------------------
 ;  #PROPERTYDEF prpExt()  class=String protected node="prpExt"
 ;
 ; ---------------------------------------------------------------------
 ;  #PROPERTYDEF prpXnp(,)  class=String protected node="prpXnp"
 ;
 ; ---------------------------------------------------------------------
 ;  #PROPERTYDEF pslPoly()  class=String protected node="pslPoly"
 ;
 ; ---------------------------------------------------------------------
 ;  #PROPERTYDEF symTab()  class=String private node="symTab"
 ;
 ; ---------------------------------------------------------------------
 ;  #PROPERTYDEF sysmap(,,)  class=String private node="sysmap"
 ;
 ;  #PROPERTYDEF tknTypeEFALSE = -3010 class=Number public literal
 ; keyword false
 ;  #PROPERTYDEF tknTypeETRUE  = -3011 class=Number public literal
 ; keyword true
 ;  #PROPERTYDEF tknTypeEVSIG  = -3012 class=Number public literal
 ; variable signature
 ;  #PROPERTYDEF tknTypeEFPDEC = -3013 class=Number public literal
 ; formal param decl.
 ;  #PROPERTYDEF tknTypeSMTD   = -4000 class=Number public literal
 ; method descriptor
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
 ;
 ; ---------------------------------------------------------------------
initialize(this,initObj) ; constructor
 D reset(.this)
 ;
 S this("moduleName")=initObj
 ;
 Q 
 ;
 ; ---------------------------------------------------------------------
addPostCond(pc,add) ; 
 I (pc="") Q ":"_add
 ;
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 I $$isSingle^UCGM(add) Q pc_"&"_add
 Q pc_"&("_add_")"
 ;
 ; ---------------------------------------------------------------------
getClasses() ; 
 Q "Boolean,ByteString,Cache,Class,Column,Date,Db,DbSet,Error,HTML,IO,List,Memo,Number,Object,Primitive,Record,Reference,ResultSet,Row,RowSet,Runtime,SchemaColumn,SchemaTable,String,Time,TranSet,PSL,PSLBuffer,PSLColumn,PSLExpression,PSLSubrou,PSLTable"
 ;
 ; ---------------------------------------------------------------------
getKwds() ; 
 Q "and,false,final,literal,new,not,or,private,protected,public,static,super,this,true,void"
 ;
 ; ---------------------------------------------------------------------
getRsvd() ; 
 Q ($$getStms()_","_$$getKwds())
 ;
 ; ---------------------------------------------------------------------
getStms() ; 
 Q "catch,do,else,for,hang,halt,if,job,kill,lock,quit,read,set,type,while,write"
 ;
 ; ---------------------------------------------------------------------
addSysmap(this,topic,loc,ref,val) ; polymorphism dispatch
 N vC S vC=$P($G(this),$C(124))
 I $D(vPslPoly(vC,"addSysmap")) D v0addSysmap^@vPslPoly(vC,"addSysmap")(.this,.topic,.loc,.ref,.val) Q
 D v0addSysmap(.this,.topic,.loc,.ref,.val) Q
v0addSysmap(this,topic,loc,ref,val) ; Append val to TAB-delimited this.sysmap(topic,loc,ref)
 S this("sysmap",topic,loc,ref)=$get(this("sysmap",topic,loc,ref))_val_$char(9)
 Q 
 ;
 ; ---------------------------------------------------------------------
findPSLClass(this,tknzr,cid) ; search PSLClass cache for matching name
 D
 .	N $ET,$ES,$ZYER S $ZYER="ZE^UCGMR",$ZE="",$EC="",$ET="D:$TL>"_$TL_" rollback^vRuntime("_$TL_") Q:$Q&$ES """" Q:$ES  N voxMrk s voxMrk="_+$O(vobj(""),-1)_" G vCatch1^"_$T(+0)
 .	N ocid S ocid=$piece(cid,"(")
 .	N ignore S ignore=$$getPSLClass^PSLCC(.this,.cid)
 .	I cid'=ocid D srcWarn(.this,.tknzr,"MISMATCH","Classname is case sensitive: "_ocid)
 .	Q 
 Q cid
 ;
 ; ---------------------------------------------------------------------
findPSLMethod(this,tknzr,mid,nCase) ; search PSLMethod cache for matching instance
 N acls S acls=$piece(mid,".") ; ancestor class iterator
 N amtd S amtd=$piece(mid,".",2) ; ancestor property iterator
 N omtd S omtd=amtd ; original property
 N head
 N rtrn S rtrn="" ; return value
 N ocd
 ;
 F  Q:'((rtrn="")&'(acls=""))  D
 .	S head=acls_"."
 .	; step 1: try in cache, with mtd as supplied
 .	I ($D(this("pslMtd",head_amtd))#2) S rtrn=head_amtd Q 
 .	;
 .	; step 2: ensure class is loaded
 .	I '($D(this("pslCls",acls))#2) D loadClass^PSLCC(.this,acls)
 .	;
 .	; step 3: try in cache, case as requested
 .	S amtd=head
 .	F  S amtd=$order(this("pslMtd",amtd)) Q:'($E(amtd,1,$L(head))=head)  I $$equals^PSLCC($piece(amtd,".",2),omtd,nCase) S rtrn=amtd Q 
 .	;
 .	; setp 4: If not found try ancestor
 .	I (rtrn="") S ocd=this("pslCls",acls) S acls=$P(ocd,$C(9),3) S amtd=omtd
 .	Q 
 ;
 I '(rtrn=""),$piece(rtrn,".",2)'=omtd D srcWarn(.this,.tknzr,"MISMATCH","Methodname is case sensitive: "_omtd)
 Q rtrn
 ;
 ; ---------------------------------------------------------------------
findPSLProperty(this,tknzr,pid,nCase) ; search PSLProperty cache for matching instance
 N acls S acls=$piece(pid,".") ; ancestor class iterator
 N aprp S aprp=$piece(pid,".",2) ; ancestor property iterator
 N oprp S oprp=aprp ; original property
 N head
 N rtrn S rtrn="" ; return value
 N ocd
 ;
 F  Q:'((rtrn="")&'(acls=""))  D
 .	S head=acls_"."
 .	; step 1: try in cache, with prp as supplied
 .	I ($D(this("pslPrp",head_aprp))#2) S rtrn=head_aprp Q 
 .	;
 .	; step 2: ensure class is loaded
 .	I '($D(this("pslCls",acls))#2) D loadClass^PSLCC(.this,acls)
 .	;
 .	; step 3: try in cache, case as requested
 .	S aprp=head
 .	F  S aprp=$order(this("pslPrp",aprp)) Q:'($E(aprp,1,$L(head))=head)  I $$equals^PSLCC($piece(aprp,".",2),oprp,nCase) S rtrn=aprp Q 
 .	;
 .	; setp 4: If not found try ancestor
 .	I (rtrn="") S ocd=this("pslCls",acls) S acls=$P(ocd,$C(9),3) S aprp=oprp
 .	Q 
 I '(rtrn=""),$piece(rtrn,".",2)'=oprp D srcWarn(.this,.tknzr,"MISMATCH","Propertyname is case sensitive: "_oprp)
 Q rtrn
 ;
 ; ---------------------------------------------------------------------
getPackageRoot(this) ; 
 N cls S cls=this("moduleName")
 ;
 I '($D(this("pslCls",cls))#2) Q ""
 ;
 N clsdes S clsdes=this("pslCls",cls)
 Q $$getPackageRoot^PSLClass(.clsdes)
 ;
 ; ---------------------------------------------------------------------
log(this,tknzr,lnr,srn,lvl,grp,msg) ; polymorphism dispatch
 N vC S vC=$P($G(this),$C(124))
 I $D(vPslPoly(vC,"log")) D v0log^@vPslPoly(vC,"log")(.this,.tknzr,.lnr,.srn,.lvl,.grp,.msg) Q
 D v0log(.this,.tknzr,.lnr,.srn,.lvl,.grp,.msg) Q
v0log(this,tknzr,lnr,srn,lvl,grp,msg) ; message text
 N erline1 N erline2 N erline3
 ;
 S:lnr=-1 lnr=tknzr("srcLine")
 S:(srn="") srn=$P(this,"|",2)
 ;
 S erline2="%PSL-"_$E("IWE",lvl)_"-"_grp_": "_msg
 I lnr>0 D
 .	S erline1=tknzr("srcCode",lnr)
 .	S erline3="At source code line: "_lnr
 .	S:'(srn="") erline3=erline3_" in subroutine: "_srn
 .	Q 
 E  S erline1="" S erline3="In module: "_this("moduleName")
 ;
 I '(this("logfile")="") D
 .	N io S io=$$vClVobj($ST,"IO")
 .	S $P(vobj(io,1),"|",3)="APPEND"
 .	S $P(vobj(io,1),"|",1)=this("logfile")
 .	N $ET,$ES,$ZYER S $ZYER="ZE^UCGMR",$ZE="",$EC="",$ET="D:$TL>"_$TL_" rollback^vRuntime("_$TL_") Q:$Q&$ES """" Q:$ES  N voxMrk s voxMrk="_+$O(vobj(""),-1)_" G vCatch2^"_$T(+0)
 .	D open^UCIO(io,$T(+0),"log","io")
 .	D write^UCIO(io,"++++++++++++++++++++++")
 .	D write^UCIO(io,erline1)
 .	D write^UCIO(io,erline2)
 .	D write^UCIO(io,erline3)
 .	D close^UCIO(io)
 .	K vobj(+$G(io)) Q 
 I (this("logfile")="") D
 .	WRITE !,erline1,!
 .	WRITE erline2,!
 .	WRITE erline3,!
 .	Q 
 ;
 N lc S lc=this("logCounts")
 S $piece(lc,"|",lvl)=$piece(lc,"|",lvl)+1 S this("logCounts")=lc
 Q 
 ;
 ; ---------------------------------------------------------------------
srcWarnDep(this,tknzr,depVer,disVer,msg) ; polymorphism dispatch
 N vC S vC=$P($G(this),$C(124))
 I $D(vPslPoly(vC,"srcWarnDep")) D v0srcWarnDep^@vPslPoly(vC,"srcWarnDep")(.this,.tknzr,.depVer,.disVer,.msg) Q
 D v0srcWarnDep(.this,.tknzr,.depVer,.disVer,.msg) Q
v0srcWarnDep(this,tknzr,depVer,disVer,msg) ; report DEPRECATED warning of error
 Q:this("parseLevel")<2 
 Q:this("cs","PSL","Version")<depVer  ; not deprecated at this level
 ;
 I disVer=0 D srcWarn(.this,.tknzr,"DEPRECATED",msg) Q  ; not yet discontinued
 I this("cs","PSL","Version")<disVer D srcWarn(.this,.tknzr,"DEPRECATED",msg) Q 
 ;
 N n S n=$$srcErr(.this,.tknzr,"DEPRECATED",msg,0)
 Q 
 ;
 ; ---------------------------------------------------------------------
toPslx(this,dir) ; polymorphism dispatch
 N vC S vC=$P($G(this),$C(124))
 I $D(vPslPoly(vC,"toPslx")) Q $$v0toPslx^@vPslPoly(vC,"toPslx")(.this,.dir)
 Q $$v0toPslx(.this,.dir)
v0toPslx(this,dir) ; Produce .pslx file in specified directory
 N pslx S pslx=$$vClVobj($ST,"IO")
 N tknzr  D vcdmNew^PSLTokenizer(.tknzr,"PSLTokenizer",pslx)
 S tknzr("charEscape")="\"
 ;
 N cls S cls=this("moduleName")
 N ocd S ocd=this("pslCls",cls)
 N json S json=$$toJSON^PSLClass(.ocd,.tknzr)
 S json=$E(json,1,$L(json)-2) ; strip ' }'
 ;
 S $P(vobj(pslx,1),"|",2)=dir
 S $P(vobj(pslx,1),"|",1)=cls_".pslx"
 S $P(vobj(pslx,1),"|",5)=32767
 S $P(vobj(pslx,1),"|",3)="NEWVERSION"
 ;
 D open^UCIO(pslx,$T(+0),"toPslx","pslx")
 ;
 ;type Number i
 ;do pslx.write( json.piece( 9.char()))
 ;for i = 2:1:json.length(9.char()) do pslx.write( "  "_ json.piece( 9.char(), i))
 D write^UCIO(pslx,json)
 S cls=cls_"."
 ;
 ; write methods array
 N nam S nam=$order(this("pslMtd",cls))
 N omd
 I ($E(nam,1,$L(cls))=cls) D
 .	D write^UCIO(pslx,", ""methods"" : [ ")
 .	S json=""
 .	F  Q:'($E(nam,1,$L(cls))=cls)  D
 ..		S omd=this("pslMtd",nam)
 ..		I $P(omd,$C(9),9)'>$P(this,"|",3) D
 ...			S json=json_$$toJSON^PSLMethod(.omd,.tknzr)
 ...			;do pslx.write( "    "_ json.piece( 9.char()))
 ...			;for i = 2:1:json.length(9.char()) do pslx.write( "      "_ json.piece( 9.char(), i))
 ...			D write^UCIO(pslx,json)
 ...			S json=","_$char(9)
 ...			Q 
 ..		S nam=$order(this("pslMtd",nam))
 ..		Q 
 .	D write^UCIO(pslx,"  ]")
 .	Q 
 ;
 ; write properties array
 N opd
 S nam=$order(this("pslPrp",cls))
 I ($E(nam,1,$L(cls))=cls) D
 .	D write^UCIO(pslx,", ""properties"" : [ ")
 .	S json=""
 .	F  Q:'($E(nam,1,$L(cls))=cls)  D
 ..		S opd=this("pslPrp",nam)
 ..		S json=json_$$toJSON^PSLProperty(.opd,.tknzr)
 ..		;do pslx.write( "    "_ json.piece( 9.char()))
 ..		;for i = 2:1:json.length(9.char()) do pslx.write( "      "_ json.piece( 9.char(), i))
 ..		D write^UCIO(pslx,json)
 ..		S json=","_$char(9)
 ..		S nam=$order(this("pslPrp",nam))
 ..		Q 
 .	D write^UCIO(pslx,"  ]")
 .	Q 
 D write^UCIO(pslx,"}")
 D close^UCIO(pslx)
 K vobj(+$G(pslx)) Q 0
 ;
 ; ---------------------------------------------------------------------
toSysmap(this,target) ; polymorphism dispatch
 N vC S vC=$P($G(this),$C(124))
 I $D(vPslPoly(vC,"toSysmap")) Q $$v0toSysmap^@vPslPoly(vC,"toSysmap")(.this,.target)
 Q $$v0toSysmap(.this,.target)
v0toSysmap(this,target) ; 
 N sysmap
 ;
  K sysmap M sysmap=this("sysmap")
 S sysmap("RTNNAME")=this("moduleName")
 N retval S retval=0
 D
 .	N $ET,$ES,$ZYER S $ZYER="ZE^UCGMR",$ZE="",$EC="",$ET="D:$TL>"_$TL_" rollback^vRuntime("_$TL_") Q:$Q&$ES """" Q:$ES  N voxMrk s voxMrk="_+$O(vobj(""),-1)_" G vCatch3^"_$T(+0)
 .	D ^UCSYSMAP($P(this,"|",4),.target,.sysmap)
 .	Q 
 Q retval
 ;
 ; ---------------------------------------------------------------------
pass0(this,info,parseLevel,tknzr) ; polymorphism dispatch
 N vpc
 N vC S vC=$P($G(this),$C(124))
 I $D(vPslPoly(vC,"pass0")) Q $$v0pass0^@vPslPoly(vC,"pass0")(.this,.info,.parseLevel,.tknzr)
 Q $$v0pass0(.this,.info,.parseLevel,.tknzr)
v0pass0(this,info,parseLevel,tknzr) ; tokenizer /NOREQ
 N modIO S modIO=$$vClVobj($ST,"IO")
 ;
 K this("pslCls"),this("pslCln"),this("pslPrp"),this("pslMtd"),this("pslTbl")
 ;
 I '''$D(tknzr) D  S vpc='''$D(tknzr) K:vpc vobj(+$G(modIO)) Q:vpc -1
 .	Q:'$$locate^UCIO(modIO,this("packageDirs"),":",this("moduleName")_".psl",0) 
 .	;
 .  K tknzr  D vcdmNew^PSLTokenizer(.tknzr,"PSLTokenizer",modIO)
 .	Q 
 E  D rewind^PSLTokenizer(.tknzr)
 ;
 N code
 N tkn N nod
 ;
 D setUcopts^PSLCC(.this,this("ucopts")) ; ensure UCOPTS has been processed
 ;
 I $$isRecord^PSLClass(this("moduleName")) D
 .	;
 .	N clsNm S clsNm=this("moduleName")
 .	;
 .	N td S td=$$getPSLTable^PSLCC(.this,$$tableNameOf^PSLClass(clsNm),0)
 .	;
 .	S this("pslCls",clsNm)=$$recordMod^PSLClass(.td)
 .	S this("cs","Options","ResultClass")=1
 .	Q 
 E  S this("pslCls",this("moduleName"))=$$subColMod^PSLClass(this("moduleName"))
 ;
 S this("parseLevel")=parseLevel
 S tknzr("tknIgnEOL")=0
 F  D  Q:tkn=-1 
 .	D
 ..		N $ET,$ES,$ZYER S $ZYER="ZE^UCGMR",$ZE="",$EC="",$ET="D:$TL>"_$TL_" rollback^vRuntime("_$TL_") Q:$Q&$ES """" Q:$ES  N voxMrk s voxMrk="_+$O(vobj(""),-1)_" G vCatch4^"_$T(+0)
 ..		S tkn=$$nextToken^PSLTokenizer(.tknzr)
 ..		Q:tkn=10  Q:tkn=-1 
 ..		;
 ..		I tkn=-4 D  Q 
 ...			I parseLevel=0 S tkn=-1 Q 
 ...			S nod=$$ps0mtd(.this,.tknzr)
 ...			D treeRemove^PSLTokenizer(.tknzr,nod)
 ...			S tkn=$$skip2EOL^PSLTokenizer(.tknzr)
 ...			Q 
 ..		;
 ..		I tkn'=35 S tkn=$$skip2EOL^PSLTokenizer(.tknzr) Q 
 ..		;
 ..		S tkn=$$nextToken^PSLTokenizer(.tknzr)
 ..		I tkn'=-3 S tkn=$$skip2EOL^PSLTokenizer(.tknzr) Q 
 ..		;
 ..		S code=$ZCONVERT(tknzr("tknValue"),"U")
 ..		I code="CLASSDEF" S nod=$$piCls(.this,.tknzr) Q 
 ..		I code="PACKAGE" S nod=$$piPck(.this,.tknzr) Q 
 ..		;
 ..		I code="OPTION" S nod=$$piOpn(.this,.tknzr) Q 
 ..		I code="PROPERTYDEF" S nod=$$piPrp(.this,.tknzr) Q 
 ..		;
 ..		S tkn=$$skip2EOL^PSLTokenizer(.tknzr)
 ..		Q 
 .	Q 
 ;
 N cls S cls=this("moduleName")
 N ocd S ocd=this("pslCls",cls)
 ;
 I $P(ocd,$C(9),5)>-1,($P(ocd,$C(9),10)="") D log(.this,.tknzr,"","",3,"SYNTAX","Missing #PACKAGE")
 ;
 I parseLevel>0 D
 .	N fpl
 .	;
 .	Q:$P(ocd,$C(9),5)=-1 
 .	;
 .	I $P(ocd,$C(9),5)=3 D log(.this,.tknzr,"","",3,"SYNTAX","Missing #PROPERTYDEF")
 .	;
 .	N ocdanc S ocdanc=$$getPSLClass^PSLCC(.this,$P(ocd,$C(9),3)) N ocdprp
 .	N omd
 .	N opd
 .	N refprps S refprps=""
 .	;
 .	I ($D(this("pslMtd",cls_".initialize"))#2) D
 ..		;
 ..		I $$isRecord^PSLClass(cls)=2 S $ZE="0,"_$ZPOS_","_",initialize method not allowed for Record class descendants",$EC=",U1001,"
 ..		;
 ..		S omd=this("pslMtd",cls_".initialize")
 ..		S fpl=$P(omd,$C(9),5)
 ..		I (fpl="") S $P(ocd,$C(9),12)="i" Q 
 ..		;
 ..		S $P(ocd,$C(9),12)="I"
 ..		I parseLevel>1,$piece(fpl," ",1,2)'="noret Object" D log(.this,.tknzr,$P(omd,$C(9),9),"initialize",3,"MISMATCH","invalid formal parameter initialize("_fpl_")")
 ..		Q 
 .	;
 .	I ($D(this("pslMtd",cls_".finalize"))#2) D
 ..		S $P(ocd,$C(9),12)=$P(ocd,$C(9),12)_"F"
 ..		;
 ..		Q:parseLevel=1 
 ..		S omd=this("pslMtd",cls_".finalize")
 ..		I $P(ocd,$C(9),5)'=0 D log(.this,.tknzr,$P(omd,$C(9),9),"finalize",3,"MISMATCH","Primitive descendants cannot have a finalize() method.")
 ..		S fpl=$P(omd,$C(9),5)
 ..		I (fpl="") Q 
 ..		D log(.this,.tknzr,$P(omd,$C(9),9),"finalize",3,"MISMATCH","finalize("_$translate(fpl,";",",")_") cannot have formal parameter(s)")
 ..		Q 
 .	;
 .	N prp S prp=cls_"."
 .	F  S prp=$order(this("pslPrp",prp)) Q:$piece(prp,".")'=cls  D
 ..		S opd=this("pslPrp",prp)
 ..		I '($P(opd,$C(9),11)=""),$P(opd,$C(9),6)'=2,$P(ocd,$C(9),12)'["P" S $P(ocd,$C(9),12)=$P(ocd,$C(9),12)_"P"
 ..		;
 ..		S ocdprp=$$getPSLClass^PSLCC(.this,$P(opd,$C(9),7)) ; may need to load!
 ..		I $P(ocdprp,$C(9),5)=0 D
 ...			I $P(ocd,$C(9),12)'["R" S $P(ocd,$C(9),12)=$P(ocd,$C(9),12)_"R"
 ...			S refprps=$S((refprps=""):$P(opd,$C(9),3),1:refprps_","_$P(opd,$C(9),3))
 ...			Q 
 ..		Q 
 .	D fillExt^PSLClass(.ocd,.this)
 .	S this("pslCls",cls)=ocd
 .	S this("refPrp")=refprps
 .	Q 
 ;
 ;  #ACCEPT date=2007-05-08; CR=27800; PGM=Frans S.C. Witte; group=BYPASS
 ;*** Start of code by-passed by compiler
 MERGE info("pslCls")=this("pslCls")
 MERGE info("pslMtd")=this("pslMtd")
 MERGE info("pslPrp")=this("pslPrp")
 ;*** End of code by-passed by compiler ***
 ;
 K vobj(+$G(modIO)) Q 0
 ;
 ; ---------------------------------------------------------------------
passClass(this,info) ; polymorphism dispatch
 N vC S vC=$P($G(this),$C(124))
 I $D(vPslPoly(vC,"passClass")) Q $$v0passClass^@vPslPoly(vC,"passClass")(.this,.info)
 Q $$v0passClass(.this,.info)
v0passClass(this,info) ; run class-only-pass of the compiler
 Q $$pass0(.this,.info,0)
 ;
 ; ---------------------------------------------------------------------
passPsl(this,info) ; polymorphism dispatch
 N vC S vC=$P($G(this),$C(124))
 I $D(vPslPoly(vC,"passPsl")) Q $$v0passPsl^@vPslPoly(vC,"passPsl")(.this,.info)
 Q $$v0passPsl(.this,.info)
v0passPsl(this,info) ; extract the equivalent of a psl description (level 2)
 Q $$pass0(.this,.info,2)
 ;
 ; ---------------------------------------------------------------------
passPslx(this,info) ; polymorphism dispatch
 N vC S vC=$P($G(this),$C(124))
 I $D(vPslPoly(vC,"passPslx")) Q $$v0passPslx^@vPslPoly(vC,"passPslx")(.this,.info)
 Q $$v0passPslx(.this,.info)
v0passPslx(this,info) ; extract the equivalent of a pslx description
 Q $$pass0(.this,.info,1)
 ;
 ; ---------------------------------------------------------------------
run(this,tknzr,target) ; polymorphism dispatch
 N vC S vC=$P($G(this),$C(124))
 I $D(vPslPoly(vC,"run")) Q $$v0run^@vPslPoly(vC,"run")(.this,.tknzr,.target)
 Q $$v0run(.this,.tknzr,.target)
v0run(this,tknzr,target) ; 
 ;
 N recClass S recClass=""
 ;
 D setUcopts^PSLCC(.this,this("ucopts")) ; ensure UCOPTS has been processed
 ;
 I $$isRecord^PSLClass(this("moduleName"))=2 D
 .	;
 .	S recClass=this("moduleName")
 .	;
 .	N rb  D vcdmNew^PSLRecordBuilder(.rb,"PSLRecordBuilder",$$tableNameOf^PSLClass(recClass))
 .	;
 .	D build^PSLRecordBuilder(.rb,.tknzr)
 .	Q 
 ;
 N err S err=$$pass0(.this,,2,.tknzr)
 ;
 S this("parseLevel")=3
 S $P(this,"|",3)=tknzr("srcLast")
 D rewind^PSLTokenizer(.tknzr) K target
 ;
 N cls
 F cls="Boolean","ByteString","Date","Memo","Number","String","Time" D loadClass^PSLCC(.this,cls)
 ;
 N dqname
 I '($piece($P(this,"|",4),"~",2)="") D
 .	S dqname="DATA-QWIK "_$piece($P(this,"|",4),"~",2)_" "_$piece($P(this,"|",4),"~")
 .	Q 
 E  I '($piece($P(this,"|",4),"~")="") D
 .	S dqname="code generated by "_$piece($P(this,"|",4),"~")
 .	Q 
 E  S dqname="unknown source"
 D tgtAddCmt(.this,.target,"")
 D tgtAddCmt(.this,.target,"**** Routine compiled from "_dqname_" ****")
 D tgtAddCmt(.this,.target,"")
 D tgtAddCmt(.this,.target,$$cmpStamp^UCXDT25())
 D tgtAddCmt(.this,.target,"")
 ;
 N thisClass S thisClass=this("pslCls",this("moduleName"))
 I $P(thisClass,$C(9),5)=-1 S this("cs","Options","ResultClass")=0
 I this("cs","PSL","Version")<3,'($P(thisClass,$C(9),10)="") S this("cs","PSL","Version")=3
 ;
 ;  #ACCEPT CR=27800;Date=2007-10-09;PGM=Frans S.C.Witte;GROUP=MISMATCH,ACCESS
 N ucgm S ucgm=$$run^UCGM(.this,.tknzr,.target)
 ;
 I $P(thisClass,$C(9),5)>-1 D
 .	;
 .	I (recClass="") D tgtNew(.this,.target) ; insert vcdmNew()
 .	D tgtDes(.this,.target) ; insert vcdmDes()
 .	D tgtAdj(.this,.target) ; insert vcdmAdj()
 .	Q 
 ;
 N lvl N cnt
 N msg S msg="" N lc S lc=this("logCounts")
 F lvl=3,2,1 D
 .	S cnt=$piece(lc,"|",lvl)+$piece(ucgm,"|",lvl)
 .	S msg=msg_cnt_$piece(" informational message, warning, error",",",lvl)
 .	S:cnt'=1 msg=msg_"s" S:lvl>1 msg=msg_", "
 .	S $piece(lc,"|",lvl)=cnt
 .	Q 
 S this("logCounts")=lc S cnt=$piece(this("logCounts"),"|",3)
 I $$getSetting^PSLCC(.this,"PSL","CompileSummary",1) D
 .	S:cnt>0 msg=msg_" ** failed **"
 .	D log(.this,.tknzr,0,"",1,"LIST",msg)
 .	Q 
 Q cnt
 ;
 ; ---------------------------------------------------------------------
ae0class(this,tknzr,cls) ; 
 Q:this("parseLevel")<1 0
 ;
 I ((","_$$getRsvd()_",")[(","_cls_",")) Q 2
 ;
 Q:this("parseLevel")<2 0
 ;
 I '($D(this("pslCls",cls))#2) D loadClass^PSLCC(.this,.cls) I '($D(this("pslCls",cls))#2) Q 3
 N ocd S ocd=this("pslCls",cls)
 I $P(ocd,$C(9),5)=-1 Q 3
 I $P(ocd,$C(9),2)'=cls D srcWarn(.this,.tknzr,"MISMATCH","classname case mismatch "_cls_" shall be "_$P(ocd,$C(9),2)) Q 1
 Q 0
 ;
 ; ---------------------------------------------------------------------
ai0onOff(this,rule,sect,valid) ; semantic actions for rule di0onOff
 N elm N pos
 N val
 N switch
 ;
 S val=$piece(rule,",",1)
 I (",TRUE,ON,1,"[(","_$ZCONVERT(val,"U")_",")) S switch=1
 E  I (",FALSE,OFF,0,"[(","_$ZCONVERT(val,"U")_",")) S switch=0
 E  Q 1
 ;
 I $piece(rule,",",2)="*" S rule=","_valid
 ;
 F elm=2:1:$S((rule=""):0,1:$L(rule,",")) D
 .	S val=$piece(rule,",",elm)
 .	S pos=$$vlstPos(valid,val,",",1)
 .	I pos>0 S this("cs",sect,$piece(valid,",",pos))=switch
 .	Q 
 Q 0
 ;
 ; ---------------------------------------------------------------------
de0lit(this,tknzr) ; #option
 N tkn S tkn=$$nextToken^PSLTokenizer(.tknzr)
 N val S val=tknzr("tknValue")
 ;
 I tkn=-2 Q $$treeAdd^PSLTokenizer(.tknzr,-2,val)
 I tkn=34 Q $$treeAdd^PSLTokenizer(.tknzr,34,val)
 I tkn=-3,val="false" Q $$treeAdd^PSLTokenizer(.tknzr,-3010,"false")
 I tkn=-3,val="true" Q $$treeAdd^PSLTokenizer(.tknzr,-3011,"true")
 ;
 S $ZE="0,"_$ZPOS_","_",invalid literal "_val,$EC=",U1001,"
 Q -1 ; dead code, but needed to indicate end-of-method to compiler
 ;
 ; ---------------------------------------------------------------------
di0onOff(this,tknzr) ; #option
 N rule S rule=""
 N tkn S tkn=0
 ;
 S tkn=$$nextToken^PSLTokenizer(.tknzr)
 I tkn=-3 D
 .	F  D  Q:tkn'=44 
 ..		S rule=rule_tknzr("tknValue")
 ..		S tkn=$$nextToken^PSLTokenizer(.tknzr)
 ..		I tkn=44 S rule=rule_","
 ..		Q 
 .	Q 
 E  I tkn=42 S rule="*" S tkn=$$nextToken^PSLTokenizer(.tknzr)
 ;
 ; special case: #instruction ON
 I tkn=10,(rule="") S rule="*" D pushBack^PSLTokenizer(.tknzr)
 I tkn'=-3,tkn'=-2 S $ZE="0,"_$ZPOS_","_",Invalid setting specification",$EC=",U1001,"
 ;
 S rule=tknzr("tknValue")_","_rule S tkn=$$nextToken^PSLTokenizer(.tknzr)
 S tkn=$$chkEOL^PSLTokenizer(.tknzr)
 ;
 Q $$treeAdd^PSLTokenizer(.tknzr,-1910,rule)
 ;
 ; ---------------------------------------------------------------------
di0qua(this,tknzr) ; 
 N tkn S tkn=$$nextToken^PSLTokenizer(.tknzr)
 I tkn'=-3 Q -1
 ;
 N rule S rule=tknzr("tknValue")
 S tkn=$$nextToken^PSLTokenizer(.tknzr)
 I tkn=61 D
 .	S tkn=$$nextToken^PSLTokenizer(.tknzr)
 .	I tkn'=-2,tkn'=34,tkn'=-3 S $ZE="0,"_$ZPOS_","_",expected literal; found '"_tknzr("tknValue")_"'",$EC=",U1001,"
 .	S rule=rule_","_$$treeAdd^PSLTokenizer(.tknzr,tkn,tknzr("tknValue"))
 .	Q 
 E  D
 .	D pushBack^PSLTokenizer(.tknzr)
 .	S rule=rule_","
 .	Q 
 Q $$treeAdd^PSLTokenizer(.tknzr,-9,rule)
 ;
 ; ---------------------------------------------------------------------
di0quaLst(this,tknzr) ; 
 N rule S rule=""
 ;
 N qual N tkn
 ;
 F  S qual=$$di0qua(.this,.tknzr) Q:qual<0  D
 .	S rule=rule_","_$$treeValue^PSLTokenizer(.tknzr,qual)
 .	D treeRemove^PSLTokenizer(.tknzr,qual) ; remove $$di0qua rule
 .	Q 
 Q $$treeAdd^PSLTokenizer(.tknzr,-1010,$E(rule,2,1048575))
 ;
 ; ---------------------------------------------------------------------
diPrp(this,tknzr) ; #propertydef
 ; property name =======================================================
 N tkn S tkn=$$nextToken^PSLTokenizer(.tknzr)
 I tkn'=-3 S $ZE="0,"_$ZPOS_","_",property-name expected; found "_$$tokenType^PSLTokenizer(tkn),$EC=",U1001,"
 ;
 N rule S rule=tknzr("tknValue") N val
 I '$$isName(.this,rule) S $ZE="0,"_$ZPOS_","_",invalid name "_rule,$EC=",U1001,"
 ;
 ; dimension (optional) ================================================
 S tkn=$$nextToken^PSLTokenizer(.tknzr) S rule=rule_","
 I tkn=40 D  ; array dimension specification
 .	S val="("
 .	F  S tkn=$$nextToken^PSLTokenizer(.tknzr) Q:tkn'=44  S val=val_","
 .	I tkn'=41 S $ZE="0,"_$ZPOS_","_",invalid dimension specification '"_val_tknzr("tknValue")_"'",$EC=",U1001,"
 .	S rule=rule_$$treeAdd^PSLTokenizer(.tknzr,-3012,val_")")
 .	S tkn=$$nextToken^PSLTokenizer(.tknzr)
 .	Q 
 ;
 ; initial value =======================================================
 S rule=rule_","
 I tkn=61 D  ; initial value specification
 .	S val=$$de0lit(.this,.tknzr)
 .	S rule=rule_val
 .	Q 
 E  D pushBack^PSLTokenizer(.tknzr)
 ;
 ; qualifiers ==========================================================
 I tkn'=10 S rule=rule_","_$$di0quaLst(.this,.tknzr)
 ;
 S tkn=$$chkEOL^PSLTokenizer(.tknzr)
 Q $$treeAdd^PSLTokenizer(.tknzr,-2210,rule)
 ;
 ; ---------------------------------------------------------------------
ds0mtd(this,tknzr,tree) ; 
 N rule S rule=""
 N tkn S tkn=-3 ; not tknTypeMTD !! (if no modifiers)
 N atom S atom=tknzr("tknValue")
 ;
 ; access modifiers ====================================================
 F  Q:'(",final,public,private,protected,static,"[(","_$ZCONVERT(atom,"L")_","))  D
 .	I atom'?1.L D:0 srcWarn(.this,.tknzr,"SYNTAX","keywords shall be all lowercase: "_atom) S atom=$ZCONVERT(atom,"L")
 .	N clsdes S clsdes=this("pslCls",this("moduleName"))
 .	I atom="private",($P(clsdes,$C(9),10)="") S atom="public" ; temporary: upgrade "old" private to public
 .	S rule=rule_","_atom
 .	S tkn=$$nextToken^PSLTokenizer(.tknzr)
 .	S atom=tknzr("tknValue")
 .	Q 
 S rule=$$treeAdd^PSLTokenizer(.tknzr,-9,$E(rule,2,1048575))_","
 ;
 ; resultClass =========================================================
 I $get(this("cs","Options","ResultClass"),0) D
 .	I tkn'=-3 S $ZE="0,"_$ZPOS_","_",invalid resultClass '"_atom_"'",$EC=",U1001,"
 .	S rule=rule_atom S tkn=$$nextToken^PSLTokenizer(.tknzr)
 .	S atom=tknzr("tknValue")
 .	Q 
 ;
 ; label ===============================================================
 I tkn=40 D
 .	D pushBack^PSLTokenizer(.tknzr)
 .	N tree S tree=+$piece(rule,",")
 .	N modwords S modwords=$$treeValue^PSLTokenizer(.tknzr,tree)
 .	D treeRemove^PSLTokenizer(.tknzr,tree)
 .	S atom=$piece(modwords,",",$L(modwords,","))
 .	S modwords=$piece(modwords,",",1,$L(modwords,",")-1)
 .	D srcWarn(.this,.tknzr,"DEPRECATED","method name shall not be PSL keyword: "_atom)
 .	S $piece(rule,",")=$$treeAdd^PSLTokenizer(.tknzr,-9,modwords)
 .	S tkn=-3
 .	Q 
 I tkn'=-3,tkn'=-2 S $ZE="0,"_$ZPOS_","_",invalid method name '"_atom_"'",$EC=",U1001,"
 S rule=rule_","_atom_","
 ;
 ; formal parameter list ===============================================
 S tkn=$$nextToken^PSLTokenizer(.tknzr)
 ;
 I tkn=40 D  ; has parameters
 .	N fpl S fpl=""
 .	S tknzr("tknIgnEOL")=1 ; ignore EOL until close-parenthsis
 .	S tknzr("tknIgnCMT")=2 ; ignore all CMT
 .	I $$nextToken^PSLTokenizer(.tknzr)'=41 D
 ..		D pushBack^PSLTokenizer(.tknzr)
 ..		F  D  Q:tkn=41 
 ...			S fpl=$S((fpl=""):$$ds0mtdFp(.this,.tknzr),1:fpl_","_$$ds0mtdFp(.this,.tknzr))
 ...			S tkn=$$nextToken^PSLTokenizer(.tknzr)
 ...			I tkn'=44,tkn'=41 S $ZE="0,"_$ZPOS_","_",comma or close parenthesis expected in method declaration",$EC=",U1001,"
 ...			Q 
 ..		Q 
 .	S rule=rule_$$treeAdd^PSLTokenizer(.tknzr,-9,fpl)
 .	S tknzr("tknIgnEOL")=0
 .	S tknzr("tknIgnCMT")=1 ; ignore block-comment only
 .	Q 
 E  D pushBack^PSLTokenizer(.tknzr)
 ;
 Q $$treeAdd^PSLTokenizer(.tknzr,-4,rule)
 ;
 ; ---------------------------------------------------------------------
ds0mtdFp(this,tknzr) ; 
 ; Default access type of parameter is determined by module type
 N clsdes S clsdes=this("pslCls",this("moduleName"))
 ;
 N tkn S tkn=$$nextToken^PSLTokenizer(.tknzr)
 N rule S rule=tknzr("tknValue")
 I tkn'=-3 S $ZE="0,"_$ZPOS_","_",invalid formal parameter specification '"_rule_"'",$EC=",U1001,"
 ;
 S tkn=$$nextToken^PSLTokenizer(.tknzr)
 I tkn=-3 D
 .	S rule=rule_" "_tknzr("tknValue")
 .	S tkn=$$nextToken^PSLTokenizer(.tknzr)
 .	I tkn=-3 S rule=rule_" "_tknzr("tknValue") S tkn=$$nextToken^PSLTokenizer(.tknzr)
 .	E  S rule=" "_rule
 .	Q 
 E  S rule=" String "_rule
 ;
 ; dimension (optional) ================================================
 I tkn=40 D  ; array dimension specification
 .	S rule=rule_"("
 .	F  S tkn=$$nextToken^PSLTokenizer(.tknzr) Q:tkn'=44  S rule=rule_","
 .	I tkn'=41 S $ZE="0,"_$ZPOS_","_",invalid dimension specification '"_$piece(rule," ",3)_tknzr("tknValue")_"'",$EC=",U1001,"
 .	S rule=rule_")"
 .	Q 
 E  D pushBack^PSLTokenizer(.tknzr)
 ;
 I '(",literal,,noret,ret,"[(","_$piece(rule," ")_",")) S $ZE="0,"_$ZPOS_","_",unexpected access modifier '"_$piece(rule," ")_"' in formal parameter declaration",$EC=",U1001,"
 ;
 I ($piece(rule," ")="") S $piece(rule," ")=$S('($P(clsdes,$C(9),10)=""):"noret",1:"ret")
 E  I $piece(rule," ")="ret",$piece(rule," ",3)["(" S $ZE="0,"_$ZPOS_","_",access modifier 'ret' cannot be applied to array parameter "_$piece(rule," "),$EC=",U1001,"
 ;
 Q $$treeAdd^PSLTokenizer(.tknzr,-3013,rule)
 ;
 ; ---------------------------------------------------------------------
instruction(this,tknzr,ins) ; polymorphism dispatch
 N vC S vC=$P($G(this),$C(124))
 I $D(vPslPoly(vC,"instruction")) Q $$v0instruction^@vPslPoly(vC,"instruction")(.this,.tknzr,.ins)
 Q $$v0instruction(.this,.tknzr,.ins)
v0instruction(this,tknzr,ins) ; instruction name (*1)
 I ins="accept" Q $$skip2EOL^PSLTokenizer(.tknzr)
 E  I ins="bypass" Q $$skip2EOL^PSLTokenizer(.tknzr)
 E  I ins="classdef" Q $$piCls(.this,.tknzr)
 E  I ins="else" Q $$skip2EOL^PSLTokenizer(.tknzr)
 E  I ins="end" Q $$skip2EOL^PSLTokenizer(.tknzr)
 E  I ins="endbypass" Q $$skip2EOL^PSLTokenizer(.tknzr)
 E  I ins="endif" Q $$skip2EOL^PSLTokenizer(.tknzr)
 E  I ins="if" Q $$skip2EOL^PSLTokenizer(.tknzr)
 E  I ins="info" Q $$skip2EOL^PSLTokenizer(.tknzr)
 E  I ins="optimize" Q $$piOpz(.this,.tknzr)
 E  I ins="option" Q $$piOpn(.this,.tknzr)
 E  I ins="package" Q $$piPck(.this,.tknzr)
 E  I ins="porpertydef" Q $$piPrp(.this,.tknzr)
 E  I ins="warn" Q $$skip2EOL^PSLTokenizer(.tknzr)
 E  I ins="while" Q $$skip2EOL^PSLTokenizer(.tknzr)
 E  I ins="xecute" Q $$skip2EOL^PSLTokenizer(.tknzr)
 ;
 Q $$srcErr(.this,.tknzr,"SYNTAX","invalid compiler intstruction '#"_ins_"'",1)
 ;
 ; ---------------------------------------------------------------------
piCls(this,tknzr) ; 
 ; TEMPORARY !!!!
 ;
 N cls S cls=this("moduleName") N qual N val
 N clsdes S clsdes=this("pslCls",cls)
 N dups
 N elm N tkn
 ;
 I $P(clsdes,$C(9),5)>-1 S tkn=$$srcErr(.this,.tknzr,"SYNTAX","duplicate #CLASSDEF",2) Q 0
 ;
 S $P(clsdes,$C(9),11)=1
 S $P(clsdes,$C(9),5)=0
 S $P(clsdes,$C(9),3)="Reference"
 S $P(clsdes,$C(9),4)=124 ; vertical bar
 S $P(clsdes,$C(9),8)=0 ; can be instantiated
 ;
 I $$isRecord^PSLClass(cls)>1 D
 .	N $ET,$ES,$ZYER S $ZYER="ZE^UCGMR",$ZE="",$EC="",$ET="D:$TL>"_$TL_" rollback^vRuntime("_$TL_") Q:$Q&$ES """" Q:$ES  N voxMrk s voxMrk="_+$O(vobj(""),-1)_" G vCatch5^"_$T(+0)
 .	N td S td=$$getPSLTable^PSLCC(.this,$E(cls,7,1048575),0)
 .	S $P(clsdes,$C(9),3)="Record"_$P(td,"|",7)
 .	S dups("extends")=0
 .	S $P(clsdes,$C(9),4)=$P(td,"|",10)
 .	S dups("delimiter")=0
 .	Q 
 ;
 N nod S nod=$$di0quaLst(.this,.tknzr)
 N rule S rule=$$treeValue^PSLTokenizer(.tknzr,nod)
 D treeRemove^PSLTokenizer(.tknzr,nod)
 ;
 F elm=1:2:$S((rule=""):0,1:$L(rule,",")) D
 .	S qual=$piece(rule,",",elm)
 .	S nod=$piece(rule,",",elm+1)
 .	I '(nod="") D
 ..		S val=$$treeValue^PSLTokenizer(.tknzr,nod)
 ..		S tkn=$$treeType^PSLTokenizer(.tknzr,nod)
 ..		D treeRemove^PSLTokenizer(.tknzr,nod)
 ..		Q 
 .	E  S val="" S tkn=0
 .	;
 .	S dups(qual)=($D(dups(qual))#2)
 .	I dups(qual) S tkn=$$srcErr(.this,.tknzr,"SYNTAX","qualifier '"_qual_"' occurs more than once",0) Q 
 .	;
 .	I qual="delimiter" D
 ..		I tkn'=-2 S tkn=$$srcErr(.this,.tknzr,"SYNTAX","delimiter must be a Number",0) Q 
 ..		I +val<0 S tkn=$$srcErr(.this,.tknzr,"SYNTAX","delimiter value cannot be negative",0) Q 
 ..		I '$$vStrIsInt(val) S tkn=$$srcErr(.this,.tknzr,"SYNTAX","delimiter must be an Integer",0) Q 
 ..		S $P(clsdes,$C(9),4)=+val
 ..		Q 
 .	E  I qual="extends" D
 ..		I tkn'=-3 S tkn=$$srcErr(.this,.tknzr,"SYNTAX","invalid extends specification",0) Q 
 ..		S $P(clsdes,$C(9),3)=val
 ..		Q 
 .	E  I qual="public" D
 ..		I '(nod="") S tkn=$$srcErr(.this,.tknzr,"SYNTAX","'public' does not accept a value",0) Q 
 ..		S $P(clsdes,$C(9),11)=2
 ..		Q 
 .	E  S tkn=$$srcErr(.this,.tknzr,"SYNTAX","unknown CLASSDEF qualifier '"_qual_"'",0)
 .	Q 
 ;
 N ext S ext=$P(clsdes,$C(9),3)
 N ocd
 I ext="Object",'$$isClsIntrinsic^UCGMCU(cls) S tkn=$$srcErr(.this,.tknzr,"SYNTAX","class cannot extend Object",0)
 E  I ext="Primitive" S $P(clsdes,$C(9),5)=3
 E  I ext'="Reference",$$isRecord^PSLClass(ext)'=2 D
 .	I $$isClsPslx^UCGMCU(ext),'$$isClsPslx^UCGMCU(cls) S tkn=$$srcErr(.this,.tknzr,"SYNTAX","class cannot extend PSL Intrinsic Class "_ext,0)
 .	;
 .	Q:this("parseLevel")'>0 
 .	I '($D(this("pslCls",ext))#2) D loadClass^PSLCC(.this,ext) I '($D(this("pslCls",ext))#2) S tkn=$$srcErr(.this,.tknzr,"SYNTAX","invalid extends specification",0) Q 
 .	S ocd=this("pslCls",ext)
 .	I $P(ocd,$C(9),5)<0!($P(ocd,$C(9),5)=3) S tkn=$$srcErr(.this,.tknzr,"SYNTAX","class cannot extend "_ext,0)
 .	S $P(clsdes,$C(9),5)=$P(ocd,$C(9),5)
 .	Q 
 ;
 ; CDM Support Version 1 limitation: Do not allow Reference descendants
 I $P(clsdes,$C(9),5)=0,this("parseLevel")>1,'$$isRecord^PSLClass(cls) S tkn=$$srcErr(.this,.tknzr,"SYNTAX","Reference descendants not yet supported",0)
 ;
 I this("parseLevel")=2 D  ; fill prpExt() and prpXnp(,)
 .	N opd
 .	N prp ; property iterator
 .	N nod ; node of property
 .	S ocd=$$getPSLClass^PSLCC(.this,ext)
 .	F  Q:'($P(ocd,$C(9),3)'="Object")  D
 ..		S prp=ext_"."
 ..		F  S prp=$order(this("pslPrp",prp)) Q:$piece(prp,".")'=ext  D
 ...			S opd=this("pslPrp",prp)
 ...			S this("prpExt",$P(opd,$C(9),3))=$P(opd,$C(9),2)
 ...			S nod=$P(opd,$C(9),8) S:(nod="") nod=-1
 ...			S:$P(opd,$C(9),6)'=2 this("prpXnp",nod,prp)=prp
 ...			Q  ; end for each property of this class
 ..		S ext=$P(ocd,$C(9),3) S ocd=$$getPSLClass^PSLCC(.this,ext)
 ..		Q  ; end for each ancestor
 .	Q 
 ;
 S this("pslCls",cls)=clsdes
 ;
 S this("cs","Options","ResultClass")=1
 ;
 S tkn=$$chkEOL^PSLTokenizer(.tknzr)
 Q 0
 ;
 ; ---------------------------------------------------------------------
piOpn(this,tknzr) ; #option
 N nod S nod=$$di0onOff(.this,.tknzr)
 N rule S rule=$$treeValue^PSLTokenizer(.tknzr,nod)
 D treeRemove^PSLTokenizer(.tknzr,nod)
 ;
 I $$ai0onOff(.this,rule,"Options",$$allOptions^UCGMC())'=0 S nod=$$srcErr(.this,.tknzr,"SYNTAX","invalid switch '"_$piece(rule,",",1)_"' in #OPTION",0)
 Q 0
 ;
 ; ---------------------------------------------------------------------
piOpz(this,tknzr) ; #optimize
 N nod S nod=$$di0onOff(.this,.tknzr)
 N rule S rule=$$treeValue^PSLTokenizer(.tknzr,nod)
 D treeRemove^PSLTokenizer(.tknzr,nod)
 ;
 I $$ai0onOff(.this,rule,"OPTIMIZE",$$allOPTIMIZE^UCGMC())'=0 S nod=$$srcErr(.this,.tknzr,"SYNTAX","invalid switch '"_$piece(rule,",",1)_"' in #OPTIMIZE",0)
 Q 0
 ;
 ; ---------------------------------------------------------------------
piPck(this,tknzr) ; #PACKAGE
 N clsdes S clsdes=this("pslCls",this("moduleName"))
 ;
 I '($P(clsdes,$C(9),10)="") Q $$srcErr(.this,.tknzr,"SYNTAX","duplicate #PACKAGE",2)
 ;
 N tkn S tkn=$$nextToken^PSLTokenizer(.tknzr)
 I tkn'=-3 Q $$srcErr(.this,.tknzr,"SYNTAX","name of package expected",2)
 N pck S pck=tknzr("tknValue")
 ;
 F  S tkn=$$nextToken^PSLTokenizer(.tknzr) Q:tkn'=46  D
 .	S tkn=$$nextToken^PSLTokenizer(.tknzr)
 .	I tkn'=-3 S tkn=$$srcErr(.this,.tknzr,"SYNTAX","name of package expected",2)
 .	S pck=pck_"."_tknzr("tknValue")
 .	Q 
 ;
 I $translate(pck,".","9")'?1A.AN Q $$srcErr(.this,.tknzr,"SYNTAX","invalid package name '"_pck_"'",2)
 ;
 N nm S nm=$order(this("pslMtd",this("moduleName")_"."))
 I $piece(nm,".")=this("moduleName") Q $$srcErr(.this,.tknzr,"SYNTAX","#PACKAGE must preceed declarations",2)
 S nm=$order(this("pslPrp",this("moduleName")_"."))
 I $piece(nm,".")=this("moduleName") Q $$srcErr(.this,.tknzr,"SYNTAX","#PACKAGE must preceed declarations",2)
 ;
 S $P(clsdes,$C(9),10)=pck
 S this("pslCls",this("moduleName"))=clsdes
 ;
 S tkn=$$chkEOL^PSLTokenizer(.tknzr)
 Q 0
 ;
 ; ---------------------------------------------------------------------
piPrp(this,tknzr) ; #propertydef
 N cls S cls=this("moduleName")
 N clsmod S clsmod=0
 N clsdes S clsdes=this("pslCls",cls)
 ;
 I $P(clsdes,$C(9),5)<0 S $ZE="0,"_$ZPOS_","_",#PROPERTYDEF without #CLASSDEF",$EC=",U1001,"
 I $piece($order(this("pslMtd",cls_".")),".")=cls S $ZE="0,"_$ZPOS_","_",#PROPERTYDEF after start of method code",$EC=",U1001,"
 ;
 ; Decompose:
 ; valueOf(name) , nodeOf(dimension) , nodeOf(initVal), nodeOf(di0quaLst)
 N nod S nod=$$diPrp(.this,.tknzr)
 N rule S rule=$$treeValue^PSLTokenizer(.tknzr,nod)
 D treeRemove^PSLTokenizer(.tknzr,nod)
 ;
 N prp S prp=$piece(rule,",",1)
 I ($D(this("pslPrp",cls_"."_prp))#2) S $ZE="0,"_$ZPOS_","_",duplicate property name '"_prp_"'",$EC=",U1001,"
 I ($D(this("prpExt",prp))#2) S $ZE="0,"_$ZPOS_","_",property already defined in ancestor class '"_this("prpExt",prp)_"'",$EC=",U1001,"
 ;
 N prpdes S prpdes=$$vcdmNew^PSLProperty("PSLProperty")
 S $P(prpdes,$C(9),2)=cls S $P(prpdes,$C(9),3)=prp
 S $P(prpdes,$C(9),5)=1 ; package access
 S $P(prpdes,$C(9),9)=0 ; no position
 S $P(prpdes,$C(9),6)=0 ; not restricted
 ;
 S nod=$piece(rule,",",2)
 I '(nod="") D
 .	S $P(prpdes,$C(9),4)=$$treeValue^PSLTokenizer(.tknzr,nod)
 .	D treeRemove^PSLTokenizer(.tknzr,nod)
 .	Q 
 ;
 ; initial value =======================================================
 S nod=$piece(rule,",",3)
 N initCls S initCls=""
 I '(nod="") D
 .	N initTyp S initTyp=$piece(tknzr("tknTree",nod),$char(9))
 .	N initVal S initVal=$piece(tknzr("tknTree",nod),$char(9),2)
 .	D treeRemove^PSLTokenizer(.tknzr,nod)
 .	I initTyp=-2 D
 ..		S initCls="Number" S $P(prpdes,$C(9),11)=initVal
 ..		Q 
 .	E  I initTyp=34 D
 ..		S initCls="String" S $P(prpdes,$C(9),11)=$S(initVal'["""":""""_initVal_"""",1:$$QADD^%ZS(initVal,""""))
 ..		Q 
 .	E  I initTyp=-3010 D
 ..		S initCls="Boolean" S $P(prpdes,$C(9),11)=0
 ..		Q 
 .	E  I initTyp=-3011 D
 ..		S initCls="Boolean" S $P(prpdes,$C(9),11)=1
 ..		Q 
 .	; currently de0lit ensures that only one of the above applies
 .	Q 
 ;
 ; qualifiers ==========================================================
 S nod=$piece(rule,",",4)
 N dups
 N elm N tkn
 N qua N val
 N quaLst S quaLst=$$treeValue^PSLTokenizer(.tknzr,nod)
 ;
 D treeRemove^PSLTokenizer(.tknzr,nod)
 ;
 F elm=1:2:$S((quaLst=""):0,1:$L(quaLst,",")) D
 .	S qua=$piece(quaLst,",",elm)
 .	S nod=$piece(quaLst,",",elm+1)
 .	I '(nod="") D
 ..		S val=$$treeValue^PSLTokenizer(.tknzr,nod)
 ..		S tkn=$$treeType^PSLTokenizer(.tknzr,nod)
 ..		D treeRemove^PSLTokenizer(.tknzr,nod)
 ..		Q 
 .	E  S val="" S tkn=0
 .	;
 .	S dups(qua)=($D(dups(qua))#2)
 .	I dups(qua) S tkn=$$srcErr(.this,.tknzr,"SYNTAX","qualifier '/"_qua_"' occurs more than once",0) Q 
 .	;
 .	; class = className ==========================================
 .	I qua="class" D
 ..		I $$ae0class(.this,.tknzr,val)'=0 S tkn=$$srcErr(.this,.tknzr,"SYNTAX","invalid super class '"_val_"'",0) Q 
 ..		S $P(prpdes,$C(9),7)=val
 ..		Q 
 .	; literal ====================================================
 .	E  I qua="literal" D
 ..		I '(val="") S tkn=$$srcErr(.this,.tknzr,"SYNTAX","value ignored for literal='"_val_"'",0)
 ..		I $P(prpdes,$C(9),6)=1 S tkn=$$srcErr(.this,.tknzr,"SYNTAX","'readonly' ignored for 'literal'",0)
 ..		I '($P(prpdes,$C(9),8)="") S tkn=$$srcErr(.this,.tknzr,"SYNTAX","'node' ignored for 'literal'",0) S $P(prpdes,$C(9),8)=""
 ..		I $P(prpdes,$C(9),9)>0 S tkn=$$srcErr(.this,.tknzr,"SYNTAX","'position' ignored for 'literal'",0) S $P(prpdes,$C(9),9)=0
 ..		S $P(prpdes,$C(9),6)=2
 ..		Q 
 .	; node = litval ==============================================
 .	E  I qua="node" D
 ..		I tkn=-2 D
 ...			I val<0 S tkn=$$srcErr(.this,.tknzr,"VALUE","negative node numbers ("_val_") are reserved for PSL",0) Q 
 ...			Q 
 ..		E  I tkn'=34 S tkn=$$srcErr(.this,.tknzr,"VALUE","'node=' must specify a literal value",0) Q 
 ..		I $P(prpdes,$C(9),6)=2 S tkn=$$srcErr(.this,.tknzr,"SYNTAX","'node' is ignored for 'literal'",0) Q 
 ..		S $P(prpdes,$C(9),8)=val
 ..		Q 
 .	; position = intval ==========================================
 .	E  I qua="position" D
 ..		I tkn'=-2 S tkn=$$srcErr(.this,.tknzr,"VALUE","position value must be positive integer",0) Q 
 ..		;
 ..		N pos S pos=val
 ..		I val["."!(pos<1) S tkn=$$srcErr(.this,.tknzr,"VALUE","position must be integer, greater than zero ("_val_")",0) Q 
 ..		I $P(prpdes,$C(9),6)=2 S tkn=$$srcErr(.this,.tknzr,"SYNTAX","'position' is ignored for 'literal'",0) Q 
 ..		I '($P(prpdes,$C(9),4)="") S tkn=$$srcErr(.this,.tknzr,"SYNTAX","'position' is ignored for array property",0) Q 
 ..		I $P(clsdes,$C(9),5)=3 S $P(clsdes,$C(9),5)=2 S clsmod=1
 ..		S $P(prpdes,$C(9),9)=pos
 ..		Q 
 .	; private, protected, public ===============================
 .	E  I qua="private"!(qua="protected")!(qua="public") D
 ..		I $P(prpdes,$C(9),5)'=1 S tkn=$$srcErr(.this,.tknzr,"SYNTAX","conflicting access modifiers",0) Q 
 ..		S $P(prpdes,$C(9),5)=$L($piece(",protected,private,,public,",","_qua_",",1),",")-2
 ..		I '(val="") S tkn=$$srcErr(.this,.tknzr,"SYNTAX","value ignored for /"_qua_"='"_val_"'",0)
 ..		Q 
 .	; readonly ===================================================
 .	E  I qua="readonly" D
 ..		I $P(prpdes,$C(9),6)=2 S tkn=$$srcErr(.this,.tknzr,"SYNTAX","'readonly' ignored for 'literal'",0) Q 
 ..		S $P(prpdes,$C(9),6)=1
 ..		I '(val="") S tkn=$$srcErr(.this,.tknzr,"SYNTAX","value ignored for readonly='"_val_"'",0)
 ..		Q 
 .	; invalid qualifier ===========================================
 .	E  S tkn=$$srcErr(.this,.tknzr,"SYNTAX","unknown PROPERTYDEF qualifier '"_qua_"'",0)
 .	Q 
 ;
 ; the class qualifier is required, except for 'literal', where it can be inferred
 I '($D(dups("class"))#2) D
 .	S $P(prpdes,$C(9),7)=initCls
 .	I '($D(dups("literal"))#2) S tkn=$$srcErr(.this,.tknzr,"SYNTAX","missing 'class' qualifier for "_prp,0)
 .	Q 
 ;
 S nod=$P(prpdes,$C(9),8)
 I '(nod="") D
 .	I $P(clsdes,$C(9),5)'<2,$P(clsdes,$C(9),3)="Primitive" S $P(clsdes,$C(9),5)=1 S clsmod=1 Q 
 .	I $P(clsdes,$C(9),5)=2 S tkn=$$srcErr(.this,.tknzr,"VALUE","'node' not allowed for this class",0) Q 
 .	Q 
 ;
 I this("parseLevel")>1 D  ; Semantic validation
 .	; All classTypes (except if 'literal' property)
 .	Q:$P(prpdes,$C(9),6)=2 
 .	;
 .	I $$isRecord^PSLClass($P(clsdes,$C(9),2)) S tkn=$$srcErr(.this,.tknzr,"SYNTAX","#PROPERTYDEF not allowed for Record descendant",0) Q 
 .	;
 .	N res S res=$P(prpdes,$C(9),7) Q:(res="") 
 .	N pos S pos=$P(prpdes,$C(9),9)
 .	;
 .	I (nod=""),pos=0 S tkn=$$srcErr(.this,.tknzr,"SYNTAX","Either 'node' or 'position' must be specified",0) Q 
 .	;
 .	N ocdres S ocdres=this("pslCls",res)
 .	I $P(ocdres,$C(9),5)=1 S tkn=$$srcErr(.this,.tknzr,"VALUE","class="_res_" is an invalid property type",0) Q 
 .	;
 .	I pos>0,$P(ocdres,$C(9),5)'=3!(",ByteString,Memo,"[(","_res_",")) S tkn=$$srcErr(.this,.tknzr,"VALUE","'class="_res_"' incompatible with 'position'",0) Q 
 .	;
 .	I (nod="") D  ; use -1 as substitute node
 ..		I ($D(this("prpXnp",-1,pos))#2) S tkn=$$srcErr(.this,.tknzr,"VALUE","position already used for "_this("prpXnp",-1,pos),0) Q 
 ..		S this("prpXnp",-1,pos)=prp
 ..		Q 
 .	E  D
 ..		I ($D(this("prpXnp",nod,pos))#2) S tkn=$$srcErr(.this,.tknzr,"VALUE","'node' and 'position' already used for "_this("prpXnp",pos,pos),0) Q 
 ..		S this("prpXnp",nod,pos)=prp
 ..		Q 
 .	;
 .	; Primitive descendants
 .	I $P(clsdes,$C(9),5)'=0 D
 ..		I pos=1,(nod="") S tkn=$$srcErr(.this,.tknzr,"VALUE","node='', position=1 is reserved",0)
 ..		;
 ..		I $P(ocdres,$C(9),5)>1 Q 
 ..		S tkn=$$srcErr(.this,.tknzr,"SYNTAX","Primitive class can only have Primitive properties; 'class'="_$P(prpdes,$C(9),7)_" invalid",0)
 ..		Q  ; end Primitive descendant
 .	Q  ; end parseLevel > this.parseLevelPSLX
 ;
 S this("pslPrp",cls_"."_prp)=prpdes
 I clsmod S this("pslCls",cls)=clsdes
 ;
 S tkn=$$chkEOL^PSLTokenizer(.tknzr)
 Q 0
 ;
 ; ---------------------------------------------------------------------
statement(this,tknzr,stm) ; polymorphism dispatch
 N vC S vC=$P($G(this),$C(124))
 I $D(vPslPoly(vC,"statement")) Q $$v0statement^@vPslPoly(vC,"statement")(.this,.tknzr,.stm)
 Q $$v0statement(.this,.tknzr,.stm)
v0statement(this,tknzr,stm) ; statement name (*1)
 I stm="set" Q $$skip2stm(.this,.tknzr)
 E  I stm="type" Q $$skip2stm(.this,.tknzr)
 E  I stm="if" Q $$skip2stm(.this,.tknzr)
 E  I stm="do" Q $$skip2stm(.this,.tknzr)
 E  I stm="quit" Q $$skip2stm(.this,.tknzr)
 E  I stm="for" Q $$skip2stm(.this,.tknzr)
 E  I stm="kill" Q $$skip2stm(.this,.tknzr)
 E  I stm="else" Q $$skip2stm(.this,.tknzr)
 E  I stm="write" Q $$skip2stm(.this,.tknzr)
 E  I stm="throw" Q $$skip2stm(.this,.tknzr)
 E  I stm="while" Q $$skip2stm(.this,.tknzr)
 E  I stm="catch" Q $$skip2stm(.this,.tknzr)
 E  I stm="lock" Q $$skip2stm(.this,.tknzr)
 E  I stm="read" Q $$skip2stm(.this,.tknzr)
 ;
 E  I stm="new" Q $$skip2stm(.this,.tknzr)
 E  I stm="xecute" Q $$skip2stm(.this,.tknzr)
 ;
 E  I stm="open" Q $$skip2stm(.this,.tknzr)
 E  I stm="use" Q $$skip2stm(.this,.tknzr)
 E  I stm="close" Q $$skip2stm(.this,.tknzr)
 ;
 E  I stm="break" Q $$skip2stm(.this,.tknzr)
 E  I stm="halt" Q $$skip2stm(.this,.tknzr)
 E  I stm="hang" Q $$skip2stm(.this,.tknzr)
 E  I stm="trollback" Q $$skip2stm(.this,.tknzr)
 E  I stm="zbreak" Q $$skip2stm(.this,.tknzr)
 E  I stm="zprint" Q $$skip2stm(.this,.tknzr)
 E  I stm="zshow" Q $$skip2stm(.this,.tknzr)
 E  I stm="zwrite" Q $$skip2stm(.this,.tknzr)
 E  I stm="zwithdraw" Q $$skip2stm(.this,.tknzr)
 E  I stm="zwrite" Q $$skip2stm(.this,.tknzr)
 ;
 Q $$srcErr(.this,.tknzr,"SYNTAX","invalid statement '"_stm_"'",1)
 ;
 ; ---------------------------------------------------------------------
ps0mtd(this,tknzr) ; 
 N cls S cls=this("moduleName")
 N clsdes S clsdes=this("pslCls",cls)
 N tkn N elm
 N mtd N val
 N mtddes S mtddes=$$vcdmNew^PSLMethod("PSLMethod")
 ;
 S $P(mtddes,$C(9),6)=1 ; absent = package
 S $P(mtddes,$C(9),2)=cls
 S $P(mtddes,$C(9),9)=tknzr("srcLine")
 S $P(mtddes,$C(9),12)=0
 S $P(mtddes,$C(9),7)=$S($P(clsdes,$C(9),5)<0:2,1:0)
 ;
 ; Decompose:
 ; nodeOf(modLst) , valueOf(resultClass) , valueOf(name) , nodeOf(ds0fpLst)
 N nod S nod=$$ds0mtd(.this,.tknzr)
 N rule S rule=$$treeValue^PSLTokenizer(.tknzr,nod)
 D treeRemove^PSLTokenizer(.tknzr,nod)
 ;
 ; access modifiers ====================================================
 S nod=$piece(rule,",",1)
 N modLst S modLst=$$treeValue^PSLTokenizer(.tknzr,nod)
 D treeRemove^PSLTokenizer(.tknzr,nod)
 ;
 F elm=1:1:$S((modLst=""):0,1:$L(modLst,",")) D
 .	S val=$piece(modLst,",",elm)
 .	I val="final" D
 ..		I $P(mtddes,$C(9),7)'=0 S tkn=$$srcErr(.this,.tknzr,"SYNTAX","unexpected acess modifier 'final'",0)
 ..		S $P(mtddes,$C(9),7)=1
 ..		Q 
 .	E  I val="static" D
 ..		I $P(mtddes,$C(9),7)'=0 S tkn=$$srcErr(.this,.tknzr,"SYNTAX","unexpected acess modifier 'static'",0)
 ..		S $P(mtddes,$C(9),7)=2
 ..		Q 
 .	E  D
 ..		I $P(mtddes,$C(9),6)'=1 S tkn=$$srcErr(.this,.tknzr,"SYNTAX","duplicate access modifier '"_val_"'",0) Q 
 ..		S $P(mtddes,$C(9),6)=$L($piece(",protected,private,,public,",","_val_",",1),",")-2
 ..		Q 
 .	Q 
 ;
 I ($P(clsdes,$C(9),10)=""),$P(mtddes,$C(9),6)=1 S $P(mtddes,$C(9),6)=0
 ;
 ; resultClass =========================================================
 S val=$piece(rule,",",2)
 I '(val=""),val'="void",$$ae0class(.this,.tknzr,val)'=0 S tkn=$$srcErr(.this,.tknzr,"VALUE","invalid resultClass '"_val_"'",0)
 S $P(mtddes,$C(9),4)=val
 ;
 ; methodName ==========================================================
 S mtd=$piece(rule,",",3)
 I $P(clsdes,$C(9),5)<0 D
 .	Q:mtd?1A.AN  Q:mtd?1"%".AN  Q:mtd?1.N 
 .	S tkn=$$srcErr(.this,.tknzr,"SYNTAX","invalid label "_mtd,0)
 .	Q 
 E  I '$$isName(.this,mtd) S tkn=$$srcErr(.this,.tknzr,"SYNTAX","invalid method name "_mtd,0)
 S $P(mtddes,$C(9),3)=mtd
 ;
 ; formal parameter list ===============================================
 S nod=$piece(rule,",",4)
 ;
 I (nod="") D
 .	I $P(clsdes,$C(9),5)>-1 S tkn=$$srcErr(.this,.tknzr,"SYNTAX","missing formal parameter list in method declaration",0) Q 
 .	S $P(mtddes,$C(9),7)=3 ; or LBAEL (if inside subroutine)
 .	Q 
 E  D
 .	S rule=$$treeValue^PSLTokenizer(.tknzr,nod)
 .	D treeRemove^PSLTokenizer(.tknzr,nod)
 .	N elm
 .	N fpl S fpl="" N names S names=""
 .	N nam
 .	;
 .	F elm=1:1:$S((rule=""):0,1:$L(rule,",")) D
 ..		S nod=$piece(rule,",",elm)
 ..		S val=$$treeValue^PSLTokenizer(.tknzr,nod)
 ..		D treeRemove^PSLTokenizer(.tknzr,nod)
 ..		;
 ..		I this("parseLevel")>1 D
 ...			S val=$$ps0mtdFp(.this,.tknzr,val,"T")
 ...			S nam=$piece($piece(val," ",3),"(")
 ...			I (",super,this,"[(","_nam_",")),$P(clsdes,$C(9),5)>-1 S tkn=$$srcErr(.this,.tknzr,"SYNTAX","invalid formal name '"_nam_"'",0)
 ...			I ((","_names_",")[(","_nam_",")) S tkn=$$srcErr(.this,.tknzr,"SYNTAX","duplicate formal name '"_nam_"'",0)
 ...			S names=$S((names=""):nam,1:names_","_nam)
 ...			Q 
 ..		S fpl=$S((fpl=""):val,1:fpl_";"_val)
 ..		Q 
 .	S $P(mtddes,$C(9),5)=fpl
 .	Q 
 ;
 ; comment after closing ')', but before the end-of-line ===============
 S tkn=$$nextToken^PSLTokenizer(.tknzr)
 I tkn=59 D
 .	S $P(mtddes,$C(9),13)=$$vStrTrim(tknzr("tknValue"),0," ")
 .	Q 
 E  D pushBack^PSLTokenizer(.tknzr)
 ;
 I this("parseLevel")=3 D
 .	; semantic actions to be determined
 .	Q 
 E  D
 .	I ($D(this("pslMtd",cls_"."_mtd))#2) S tkn=$$srcErr(.this,.tknzr,"MISMATCH","duplicate method declaration '"_mtd_"'",0)
 .	E  I ($D(this("pslPrp",cls_"."_mtd))#2) S tkn=$$srcErr(.this,.tknzr,"MISMATCH","method declaration '"_mtd_"' conflicts with property declaration",0)
 .	E  S this("pslMtd",cls_"."_mtd)=mtddes
 .	Q 
 ;
 ; validate against ancestor classes
 I this("parseLevel")=2 D
 .	;
 .	Q:$P(clsdes,$C(9),5)<0 
 .	;
 .	N cd
 .	N md
 .	N ext S ext=$P(clsdes,$C(9),3)
 .	N mtdac S mtdac=$P(mtddes,$C(9),6) N extac
 .	N extok
 .	F  Q:'('(ext=""))  D  S ext=$P(cd,$C(9),3) Q:($D(this("pslPoly",cls_"."_mtd))#2) 
 ..		I '($D(this("pslCls",ext))#2) D loadClass^PSLCC(.this,ext)
 ..		S cd=this("pslCls",ext)
 ..		I ($D(this("pslPrp",ext_"."_mtd))#2) S tkn=$$srcErr(.this,.tknzr,"MISMATCH","method declaration '"_mtd_"' conflicts with property declaration in class "_ext,0)
 ..		Q:'($D(this("pslMtd",ext_"."_mtd))#2) 
 ..		;
 ..		S md=this("pslMtd",ext_"."_mtd)
 ..		S extac=$P(md,$C(9),6)
 ..		S extok=$piece("-1,2;-1,0,2,2;-1,1,2;2",";",extac+2)
 ..		I '((","_extok_",")[(","_mtdac_",")) S tkn=$$srcErr(.this,.tknzr,"MISMATCH","access type '"_$$getAccess^PSLMethod(.mtddes)_"' in "_$P(mtddes,$C(9),3)_" conflicts with with access type '"_$$getAccess^PSLMethod(.md)_"' in "_ext,0)
 ..		I $P(mtddes,$C(9),5)'=$P(md,$C(9),5),mtd'="initialize" D srcWarn(.this,.tknzr,"MISMATCH","method may hide "_ext_"."_mtd)
 ..		I '($D(this("pslPoly",cls_"."_mtd))#2) S this("pslPoly",cls_"."_mtd)=ext
 ..		Q 
 .	Q 
 Q $$treeAdd^PSLTokenizer(.tknzr,-4,mtddes)
 ;
 ; ---------------------------------------------------------------------
ps0mtdFp(this,tknzr,occ,cntxt) ; validate Identifier occurrence
 N pos S pos=$S(cntxt="T":3,1:1)
 N id S id=$piece(occ," ",pos)
 ;
 Q:$E(id,1)'="%" occ
 ;
 N z S z=$get(keywords(id)) Q:(z="") occ
 ;
 N acc S acc=$piece(z,"|",2)
 I acc=-1,cntxt'="E" S acc=$$srcErr(.this,.tknzr,"SYSVAR",id_" is reference-only",0) Q occ
 I acc=1,"SK"[cntxt D srcWarn(.this,.tknzr,"SYSVAR","Modifying system variable: "_id)
 I cntxt="T",$piece(z,"|",3)'=$piece(occ," ",2) S $piece(occ," ",2)=$piece(z,"|",3) D srcWarn(.this,.tknzr,"SYSVAR","cannot modify type "_$piece(z,"|",3)_" of "_id)
 ;
 S id=$piece(z,"|")
 ;
 I cntxt="E",id="EFD",this("cs","Options","$GetEFD") S id="$G(EFD)"
 ;
 I "1,isLvnAliasKeyword" S $piece(occ," ",pos)=id ; replace keyword by variable
 ;
 Q occ
 ;
 ; ---------------------------------------------------------------------
addSymbol(this,name,dim,scope,cls,val) ; 
 N id S id=$order(this("symTab",""),-1)+1
 ;
 S this("symTab",id)=name_$char(9)_dim_$char(9)_scope_$char(9)_cls_$char(9)_val
 Q id
 ;
 ; ---------------------------------------------------------------------
getSuper(this,mid) ; return the ancestor class that implements super.method
 Q $get(this("pslPoly",mid))
 ;
 ; ---------------------------------------------------------------------
isName(this,wrd) ; 
 I ($E(wrd,1)="%") S $E(wrd,1)="Z"
 I wrd'?1A.AN Q 0
 ;
 I ((","_$$getRsvd()_",")[(","_wrd_",")) Q 0
 ;
 Q 1
 ;
 ; ---------------------------------------------------------------------
isStm(this,tkn,wrd) ; 
 I tkn=-3,((","_$$getStms()_",")[(","_$ZCONVERT(wrd,"L")_",")) Q 1
 Q 0
 ;
 ; ---------------------------------------------------------------------
reset(this) ; polymorphism dispatch
 N vC S vC=$P($G(this),$C(124))
 I $D(vPslPoly(vC,"reset")) D v0reset^@vPslPoly(vC,"reset")(.this) Q
 D v0reset(.this) Q
v0reset(this) ; reset all pointers
 S this("logCounts")="0|0|0"
 S this("logfile")=""
 ;
 S $P(this,"|",2)=""
 ;
 S this("parseLevel")=2
 ;
 S this("tgtCmt")=";"
 ;
 K this("cs"),this("prpExt"),this("prpXnp"),this("symTab"),this("sysmap")
 ;
 Q 
 ;
 ; ---------------------------------------------------------------------
skip2stm(this,tknzr) ; 
 Q $$skip2WRD^PSLTokenizer(.tknzr,$$getStms(),1)
 ;
 ; ---------------------------------------------------------------------
srcErr(this,tknzr,grp,msg,skipTo) ; update token pointer indicator (*3)
 D log(.this,.tknzr,-1,"",3,grp,msg)
 ;
 N tkn S tkn=tknzr("tknType")
 ;
 I skipTo=1 S:'$$isStm(.this,tknzr("tknValue")) tkn=$$skip2stm(.this,.tknzr)
 I skipTo=2 S:tkn'=10&(tkn'=-1) tkn=$$skip2EOL^PSLTokenizer(.tknzr)
 Q tkn
 ;
 ; ---------------------------------------------------------------------
srcInfo(this,tknzr,grp,msg) ; message text
 Q:'$get(this("cs","INFO",grp),0) 
 ;
 ;  #ACCEPT date=2007-07-05; CR=27800; PGM=Frans S.C. Witte; group=BYPASS
 ;*** Start of code by-passed by compiler
 quit:$D(this("ACCEPT",tknzr("srcLine")))#2
 quit:$D(this("ACCEPT",tknzr("srcLine"),grp))#2
 ;*** End of code by-passed by compiler ***
 ;
 D log(.this,.tknzr,-1,"",1,grp,msg)
 Q 
 ;
 ; ---------------------------------------------------------------------
srcWarn(this,tknzr,grp,msg) ; message text
 Q:this("parseLevel")<2 
 Q:'$get(this("cs","WARN",grp),0) 
 ;
 ;  #ACCEPT date=2007-07-05; CR=27800; PGM=Frans S.C. Witte; group=BYPASS
 ;*** Start of code by-passed by compiler
 quit:$D(this("ACCEPT",tknzr("srcLine")))#2
 quit:$D(this("ACCEPT",tknzr("srcLine"),grp))#2
 ;*** End of code by-passed by compiler ***
 ;
 D log(.this,.tknzr,-1,"",2,grp,msg)
 Q 
 ;
 ; ---------------------------------------------------------------------
tgtAdd(this,target,code) ; 
 N ln S ln=$order(target(""),-1)+1
 S target(ln)=code
 Q 
 ;
 ; ---------------------------------------------------------------------
tgtAddCmt(this,target,comment) ; 
 D tgtAdd(.this,.target," "_this("tgtCmt")_" "_comment)
 Q 
 ;
 ; ---------------------------------------------------------------------
tgtAdj(this,target) ; 
 ;
 N refprps S refprps=this("refPrp")
 Q:(refprps="") 
 ;
 N cls S cls=this("moduleName")
 N ocd S ocd=this("pslCls",cls)
 N arrprp S arrprp=""
 ;
 D tgtAdd(.this,.target,"vcdmAdj(this,vS) Q:this=0  Q:'$D(vobj(this))")
 D tgtAdd(.this,.target," N vD,vA,vO")
 D tgtAdd(.this,.target," Q:$P(vobj(this,-1),$C(9),2)'>vS")
 ;
 N elm
 N dlm S dlm="" N prp
 N code S code=" F vO="
 N opd
 F elm=1:1:$S((refprps=""):0,1:$L(refprps,",")) D
 .	I '($ZLENGTH(code)+40'>1980) D
 ..		D tgtAdd(.this,.target,code_" D:vO]""""")
 ..		D tgtAdjBlock(.this,.target)
 ..		S code=" F vO=" S dlm=""
 ..		Q 
 .	S prp=$piece(refprps,",",elm)
 .	I prp["(" S arrprp=$S((arrprp=""):prp,1:arrprp_","_prp) Q 
 .	S opd=this("pslPrp",cls_"."_prp)
 .	S code=code_dlm_$$getExpr^PSLProperty(.opd,"this","",.ocd) S dlm=","
 .	Q 
 ;
 I code'=" F vO=" D
 .	D tgtAdd(.this,.target,code_" D:vO]""""")
 .	D tgtAdjBlock(.this,.target)
 .	Q 
 ;
 ; Insert adjustment code for array-of-reference objects
 N dim N lvl N max S max=0
 N hdr N nod N sub
 F elm=1:1:$S((arrprp=""):0,1:$L(arrprp,",")) D
 .	S prp=$piece(arrprp,",",elm)
 .	S opd=this("pslPrp",cls_"."_prp)
 .	S dim=$L($P(opd,$C(9),4),",")
 .	S nod=$P(opd,$C(9),8)
 .	I '(nod=+nod) S nod=$S(nod'["""":""""_nod_"""",1:$$QADD^%ZS(nod,""""))
 .	S hdr="vobj(this,"_nod
 .	I dim>max D
 ..		S code=""
 ..		F max=max+1:1:dim S code=code_" N v"_max_" S v"_max_"="""""
 ..		D tgtAdd(.this,.target,code)
 ..		Q 
 .	S code="" S sub=hdr
 .	F lvl=1:1:dim D
 ..		S sub=sub_",v"_lvl
 ..		S code=code_" F  S v"_lvl_"="_sub_") Q:v"_lvl_"="""" "
 ..		Q 
 .	D tgtAdd(.this,.target,code_" S vO="_sub_") D")
 .	D tgtAdjBlock(.this,.target)
 .	Q 
 ;
 N ext S ext=$$getPSLClass^PSLCC(.this,$P(ocd,$C(9),3))
 I ($P(ext,$C(9),14)="") D tgtAdd(.this,.target," S $P(vobj(this),$C(9),2)=vS ; or decrement here")
 E  D tgtAdd(.this,.target," D "_$P(ext,$C(9),14)_"(.this,vS)")
 D tgtAdd(.this,.target," Q")
 ;
 Q 
 ;
 ; ---------------------------------------------------------------------
tgtAdjBlock(this,target) ; 
 D tgtAdd(.this,.target," . S vD=$G(vobj(vO,-1)),vA=$P(vD,$C(9),4)")
 D tgtAdd(.this,.target," . I vA="""" S:$P(vD,$C(9),2)>vS $P(vobj(vO),$C(9),2)=vS Q")
 D tgtAdd(.this,.target," . D @(vA_""(vO,vS)"")")
 Q 
 ;
 ; ---------------------------------------------------------------------
tgtDes(this,target) ; 
 ;
 N cls S cls=this("moduleName")
 N ocd S ocd=this("pslCls",this("moduleName"))
 I $P(ocd,$C(9),12)'["F",$P(ocd,$C(9),12)'["R" Q 
 ;
 D tgtAdd(.this,.target,"vcdmDes(this) Q:this=0  Q:'$D(vobj(this))")
 I $P(ocd,$C(9),12)["F" D tgtAdd(.this,.target," D finalize(.this)")
 ;
 N elm
 N dlm S dlm="" N prp
 N code S code=" F vO="
 N opd
 N refprps S refprps=this("refPrp")
 N arrprp S arrprp=""
 ;
 I '(refprps="") D
 .	D tgtAdd(.this,.target," N vD,vO,vS")
 .	D tgtAdd(.this,.target," S vS=$P(vobj(this,-1),$C(9),2)")
 .	F elm=1:1:$S((refprps=""):0,1:$L(refprps,",")) D
 ..		I '($ZLENGTH(code)+50'>1980) D
 ...			D tgtAdd(.this,.target,code_" I vO]"""",$P($G(vobj(vO,-1)),$C(9),2)=vS D")
 ...			D tgtDesBlock(.this,.target)
 ...			S code=" F vO="
 ...			Q 
 ..		S prp=$piece(refprps,",",elm)
 ..		I prp["(" S arrprp=$S((arrprp=""):prp,1:arrprp_","_prp) Q 
 ..		S opd=this("pslPrp",cls_"."_prp)
 ..		S code=code_dlm_$$getExpr^PSLProperty(.opd,"this","",.ocd) S dlm=","
 ..		Q 
 .	I code'=" F vO=" D
 ..		D tgtAdd(.this,.target,code_" I vO]"""",$P($G(vobj(vO,-1)),$C(9),2)=vS D")
 ..		D tgtDesBlock(.this,.target)
 ..		Q 
 .	Q 
 ;
 ; Insert destructor code for array-of-reference objects
 N dim N lvl N max S max=0
 N hdr N nod N sub
 F elm=1:1:$S((arrprp=""):0,1:$L(arrprp,",")) D
 .	S prp=$piece(arrprp,",",elm)
 .	S opd=this("pslPrp",cls_"."_prp)
 .	S dim=$L($P(opd,$C(9),4),",")
 .	S nod=$P(opd,$C(9),8)
 .	I '(nod=+nod) S nod=$S(nod'["""":""""_nod_"""",1:$$QADD^%ZS(nod,""""))
 .	S hdr="vobj(this,"_nod
 .	I dim>max D
 ..		S code=""
 ..		F max=max+1:1:dim S code=code_" N v"_max_" S v"_max_"="""""
 ..		D tgtAdd(.this,.target,code)
 ..		Q 
 .	S code="" S sub=hdr
 .	F lvl=1:1:dim D
 ..		S sub=sub_",v"_lvl
 ..		S code=code_" F  S v"_lvl_"="_sub_") Q:v"_lvl_"="""" "
 ..		Q 
 .	D tgtAdd(.this,.target,code_" S vO="_sub_") D:$P($G(vobj(vO,-1)),$C(9),2)=vS")
 .	D tgtDesBlock(.this,.target)
 .	Q 
 ;
 N ext S ext=$$getPSLClass^PSLCC(.this,$P(ocd,$C(9),3))
 I '($P(ext,$C(9),13)="") D tgtAdd(.this,.target," D "_$P(ext,$C(9),13)_"(.this)")
 D tgtAdd(.this,.target," Q")
 ;
 Q 
 ;
 ; ---------------------------------------------------------------------
tgtDesBlock(this,target) ; 
 D tgtAdd(.this,.target," . S vD=$P(vobj(vO,-1),$C(9),3)")
 D tgtAdd(.this,.target," . D:vD]"""" @(vD_""(vO)"") K vobj(vO)")
 Q 
 ;
 ; ---------------------------------------------------------------------
tgtNew(this,target) ; 
 ;
 N cls S cls=this("moduleName")
 N clsdes S clsdes=this("pslCls",cls)
 N mtddes
 N codeInit S codeInit=""
 ;
 D tgtAdd(.this,.target,$$classNewDecl^PSLClass(.clsdes,"vC","vS","vD","vA","vInitObj")_" ; Constructor, called for Class.new()")
 ;
 I $P(clsdes,$C(9),5)'=1 D
 .	D tgtAdd(.this,.target," N this")
 .	Q 
 E  D tgtAdd(.this,.target," N vT S vT=$T")
 ;
 D tgtAdd(.this,.target,$$tgtNewAnc(.this,.clsdes,"vC","vS","vD","vA","vInitObj"))
 ;
 N tgtlvn S tgtlvn=$S($P(clsdes,$C(9),5)=0:"vobj(this",1:"this")
 N tgtsep S tgtsep=$S(tgtlvn["(":",",1:"(")
 N tgtend S tgtend=$S(tgtlvn["(":")",1:"")
 N prp0 S prp0=cls_"." N prp S prp=prp0
 ;
 F  S prp=$order(this("pslPrp",prp)) Q:'($E(prp,1,$L(prp0))=prp0)  D
 .	N prpdes S prpdes=this("pslPrp",prp)
 .	Q:$P(prpdes,$C(9),6)=2  ; literal
 .	;
 .	N initval S initval=$P(prpdes,$C(9),11)
 .	Q:(initval="")  ; no initial value
 .	;
 .	N nod S nod=$P(prpdes,$C(9),8)
 .	N pos S pos=$P(prpdes,$C(9),9)
 .	;
 .	N code S code=tgtlvn
 .	I (nod="") S code=code_tgtend
 .	E  D
 ..		I '(nod=+nod) S nod=$S(nod'["""":""""_nod_"""",1:$$QADD^%ZS(nod,""""))
 ..		S code=code_tgtsep_nod_")"
 ..		Q 
 .	I pos>0 S code="$P("_code_",$C("_$P(clsdes,$C(9),4)_"),"_pos_")"
 .	D tgtAdd(.this,.target," S "_code_"="_initval)
 .	Q 
 ;
 N bFirst S bFirst=1
 N mtd0 S mtd0=cls_"." N mtd S mtd=mtd0
 ;
 I $P(clsdes,$C(9),3)'="Primitive",$P(clsdes,$C(9),3)'="Reference" D
 .	D tgtAdd(.this,.target," I '$D("_"vPslPoly"_"("""_cls_""")) D")
 .	D tgtAdd(.this,.target," . M "_"vPslPoly"_"("""_cls_""")="_"vPslPoly"_"("""_$P(clsdes,$C(9),3)_""")")
 .	S bFirst=0
 .	Q 
 ;
 F  S mtd=$order(this("pslPoly",mtd)) Q:'($E(mtd,1,$L(mtd0))=mtd0)  D
 .	S mtddes=this("pslMtd",mtd)
 .	Q:$P(mtddes,$C(9),7)>1 
 .	Q:$P(mtddes,$C(9),3)="initialize" 
 .	Q:$P(mtddes,$C(9),3)="finalize" 
 .	;
 .	I bFirst D
 ..		D tgtAdd(.this,.target," I '$D("_"vPslPoly"_"("""_cls_""")) D")
 ..		S bFirst=0
 ..		Q 
 .	D tgtAdd(.this,.target," . S "_"vPslPoly"_"("""_cls_""","""_$P(mtddes,$C(9),3)_""")="""_cls_"""")
 .	Q 
 ;
 I ($D(this("pslMtd",cls_".initialize"))#2) D
 .	N mtddes S mtddes=this("pslMtd",cls_".initialize")
 .	N fpInit S fpInit=$P(mtddes,$C(9),5)
 .	I '(fpInit="") S codeInit=" D initialize(.this,.vInitObj)"
 .	E  S codeInit=" D initialize(.this)"
 .	D tgtAdd(.this,.target,codeInit)
 .	Q 
 ;
 I $P(clsdes,$C(9),5)'=1 D
 .	D tgtAdd(.this,.target," Q this")
 .	Q 
 E  D
 .	D tgtAdd(.this,.target," I vT") ; restore $TEST
 .	D tgtAdd(.this,.target," Q")
 .	Q 
 Q 
 ;
 ; ---------------------------------------------------------------------
tgtNewAnc(this,ocd,varCls,varStk,varDtr,varAdj,varIni) ; 
 ;
 N cls S cls=$P(ocd,$C(9),3)
 N ext S ext=this("pslCls",cls)
 N flg S flg=$P(ext,$C(9),12)
 F  Q:'((cls'="Reference")&(cls'="Primitive")&($translate(flg,$translate(flg,"IiP"))=""))  D
 .	S cls=$P(ext,$C(9),3)
 .	S ext=this("pslCls",cls)
 .	S flg=$P(ext,$C(9),12)
 .	Q 
 ;
 I cls="Reference" Q $$cdNewRef^UCCLASS("this",varCls,varStk,varDtr,varAdj)
 I cls="Primitive",$P(ext,$C(9),5)=1 Q " S this(-1)="_varCls
 I cls="Primitive" Q " S this="_varCls
 ;
 N code S code=$$classNewCall^PSLClass(.ext,"",varCls,varStk,varDtr,varAdj,varIni)
 I code[$C(31) Q $piece(code,$C(31))_"this"_$piece(code,$C(31),2)
 Q " S this="_code
 ;  #OPTION ResultClass ON
vSIG(this) ; polymorphism dispatch
 N vC S vC=$P($G(this),$C(124))
 I $D(vPslPoly(vC,"vSIG")) Q $$v0vSIG^@vPslPoly(vC,"vSIG")(.this)
 Q $$v0vSIG(.this)
v0vSIG(this) ; 
 Q "61461^42879^Frans S.C. Witte^108508" ; Signature - LTD^TIME^USER^SIZE
 ; ----------------
 ;  #OPTION ResultClass 1
vlstPos(object,p1,p2,p3) ; List.position
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 I p3 S object=$ZCONVERT(object,"U") S p1=$ZCONVERT(p1,"U")
 S object=p2_object_p2 S p1=p2_p1_p2
 I object'[p1 Q 0
 Q $L($piece(object,p1,1),p2)
 ; ----------------
 ;  #OPTION ResultClass 1
vStrTrim(object,p1,p2) ; String.trim
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 I p1'<0 S object=$$RTCHR^%ZFUNC(object,p2)
 I p1'>0 F  Q:$E(object,1)'=p2  S object=$E(object,2,1048575)
 Q object
 ;
vClVobj(vSt,vCls) ; Create a new object
 ;
 N vOid
 S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)=vCls_$C(9)_vSt
 Q vOid
 ;
vStrIsInt(vStr) ; String.isInteger
 ;
 I vStr=+vStr,vStr'["." Q 1
 Q 0
 ;
vCatch5 ; Error trap
 ;
 N vExTable,$ET,$ES S vExTable=$ZE,$EC="",$ET="Q",$ZE=""
 S tkn=$$srcErr(.this,.tknzr,"MISMATCH","Missing table definition for "_cls,0)
 D ZX^UCGMR(voxMrk) Q 
 ;
vCatch4 ; Error trap
 ;
 N xSntx,$ET,$ES S xSntx=$ZE,$EC="",$ET="Q",$ZE=""
 N xGrp S xGrp=$piece($P(xSntx,",",3),"-",3)
 S:(xGrp="") xGrp="SYNTAX"
 S tkn=$$srcErr(.this,.tknzr,"SYNTAX",$P(xSntx,",",4),2)
 D ZX^UCGMR(voxMrk) Q 
 ;
vCatch3 ; Error trap
 ;
 N xSysmap,$ET,$ES S xSysmap=$ZE,$EC="",$ET="Q",$ZE=""
 D log(.this,,0,"",2,"SYSMAP","Error while saving sysmap data: "_$P(xSysmap,",",4)_","_$P(xSysmap,",",5))
 S retval=-1
 D ZX^UCGMR(voxMrk) Q 
 ;
vCatch2 ; Error trap
 ;
 N xIo,$ET,$ES S xIo=$ZE,$EC="",$ET="Q",$ZE=""
 I $P(xIo,",",3)'["%PSL-E-IOOPEN" D close^UCIO(io)
 S this("logfile")=""
 D ZX^UCGMR(voxMrk) Q 
 ;
vCatch1 ; Error trap
 ;
 N xNotFound,$ET,$ES S xNotFound=$ZE,$EC="",$ET="Q",$ZE=""
 S cid=""
 D ZX^UCGMR(voxMrk) Q 
vcdmNew(this,vC,vInitObj) ; Constructor, called for Class.new()
 N vT S vT=$T
 D vcdmNew^PSLCC(.this,vC)
 I '$D(vPslPoly("PSLParser")) D
 . M vPslPoly("PSLParser")=vPslPoly("PSLCC")
 . S vPslPoly("PSLParser","reset")="PSLParser"
 . S vPslPoly("PSLParser","vSIG")="PSLParser"
 D initialize(.this,.vInitObj)
 I vT
 Q
