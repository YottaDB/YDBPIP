 ; 
 ; **** Routine compiled from DATA-QWIK Procedure PSLCC ****
 ; 
 ; 02/24/2010 18:22 - pip
 ; 
 ;  #PACKAGE  framework.psl
 ;
 ;  #CLASSDEF extends=Primitive public delimiter=9
 ;
 ; top-node properties -------------------------------------------------
 ;
 ; node-only properties ------------------------------------------------
 ; ---------------------------------------------------------------------
 ;  #PROPERTYDEF packageDirs = "" class=String public node="packageDirs"
 ;
 ; ---------------------------------------------------------------------
 ;  #PROPERTYDEF ucopts = "" class=String public readonly node="ucopts"
 ;
 ; array properties ----------------------------------------------------
 ; ---------------------------------------------------------------------
 ;  #PROPERTYDEF CSSECTIONS = "boot,DEBUG,DEFINE,INFO,OPTIMIZE,Options,PSL,WARN" class=List private literal
 ;  #PROPERTYDEF cs(,)  class=String protected readonly node="cs"
 ;
 ; ---------------------------------------------------------------------
 ;  #PROPERTYDEF pslCln() class=PSLColumn protected readonly node="pslCln"
 ;
 ; ---------------------------------------------------------------------
 ;  #PROPERTYDEF pslCls() class=PSLClass protected readonly node="pslCls"
 ;
 ; ---------------------------------------------------------------------
 ;  #PROPERTYDEF pslMtd() class=PSLMethod protected readonly node="pslMtd"
 ;
 ; ---------------------------------------------------------------------
 ;  #PROPERTYDEF pslPrp() class=PSLProperty protected readonly node="pslPrp"
 ;
 ; ---------------------------------------------------------------------
 ;  #PROPERTYDEF pslTbl() class=PSLTable protected readonly node="pslTbl"
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
equals(s1,s2,nCase) ; 
 I 'nCase Q s1=s2
 I nCase=1 Q $ZCONVERT(s1,"U")=$ZCONVERT(s2,"U")
 I nCase=-1 Q $ZCONVERT(s1,"L")=$ZCONVERT(s2,"L")
 N vo1 S vo1="%PSL-E-Invalid case option "_nCase,$ZE="0,"_$ZPOS_","_vo1,$EC=",U1001,"
 Q ""
 ;
 ; ---------------------------------------------------------------------
tryMLiteral(expr) ; try to replace M expression by its value
 N lit S lit=expr
 D
 .	N $ET,$ES,$ZYER S $ZYER="ZE^UCGMR",$ZE="",$EC="",$ET="D:$TL>"_$TL_" rollback^vRuntime("_$TL_") Q:$Q&$ES """" Q:$ES  N voxMrk s voxMrk="_+$O(vobj(""),-1)_" G vCatch1^"_$T(+0)
 .	;   #ACCEPT PGM=Frans S.C. Witte;date=2007-09-21;CR=27800;GROUP=XECUTE
 .	XECUTE "S lit="_expr
 .	;
 .	; note: order of if-statements is relevant !!
 .	I $L(lit)>511 S lit=expr Q 
 .	I '(lit=+lit) S lit=$S(lit'["""":""""_lit_"""",1:$$QADD^%ZS(lit,""""))
 .	Q 
 Q lit
 ;
 ; ---------------------------------------------------------------------
addSetting(this,section,ident,val) ; Insert or update parser setting
 I (",boot,DEBUG,DEFINE,INFO,OPTIMIZE,Options,PSL,WARN,"[(","_section_",")) S this("cs",section,ident)=val
 Q 
 ;
 ; ---------------------------------------------------------------------
getPSLClass(this,cid) ; return PSLClass instance from cache, load if needed
 S:cid["(" cid=$piece(cid,"(")
 I '($D(this("pslCls",cid))#2) D loadClass(.this,.cid)
 Q this("pslCls",cid)
 ;
 ; ---------------------------------------------------------------------
getPSLColumn(this,cid) ; return PSLColumn from cache, load if needed
 I '($D(this("pslCln",cid))#2) S this("pslCln",cid)=$$getPslCln^UCXDD($piece(cid,"."),$piece(cid,".",2))
 Q this("pslCln",cid)
 ;
 ; ---------------------------------------------------------------------
getPSLMethod(this,mid) ; return existing PSLMethod instance from cache
 Q this("pslMtd",mid)
 ;
 ; ---------------------------------------------------------------------
getPSLProperty(this,pid) ; return existing PSLProperty instance from cache
 Q this("pslPrp",pid)
 ;
 ; ---------------------------------------------------------------------
getPSLTable(this,tid,lvl) ; return PSLTable instance from cache, load and upgrade if needed
 I '($D(this("pslTbl",tid))#2) S this("pslTbl",tid)=$$getPslTbl^UCXDD(tid,lvl)
 S this("pslTbl",tid)=$$tAssert^UCXDD(this("pslTbl",tid),lvl)
 Q this("pslTbl",tid)
 ;
 ; ---------------------------------------------------------------------
getSetting(this,section,ident,def) ; Obtain parser setting
 I (",boot,DEBUG,DEFINE,INFO,OPTIMIZE,Options,PSL,WARN,"[(","_section_",")) Q $get(this("cs",section,ident),def)
 Q def
 ;
 ; ---------------------------------------------------------------------
hasSetting(this,section,ident) ; Does parser have setting?
 I (",boot,DEBUG,DEFINE,INFO,OPTIMIZE,Options,PSL,WARN,"[(","_section_",")) Q ($D(this("cs",section,ident))#2)
 Q 0
 ;
 ; ---------------------------------------------------------------------
listPSLMethod(this,cls) ; return list of all methods of supplied class
 N lst S lst=""
 N iter S iter=cls_"."
 ;
 F  S iter=$order(this("pslMtd",iter)) Q:$piece(iter,".")'=cls  S lst=$S((lst=""):$piece(iter,".",2),1:lst_","_$piece(iter,".",2))
 Q lst
 ;
 ; ---------------------------------------------------------------------
listPSLProperty(this,cls) ; return list of all properties of supplied class
 N lst S lst=""
 N iter S iter=cls_"."
 ;
 F  S iter=$order(this("pslPrp",iter)) Q:$piece(iter,".")'=cls  S lst=$S((lst=""):$piece(iter,".",2),1:lst_","_$piece(iter,".",2))
 Q lst
 ;
 ; ---------------------------------------------------------------------
listSettings(this,section) ; Return List of all elements for which this.hasSetting() returns true
 I '(",boot,DEBUG,DEFINE,INFO,OPTIMIZE,Options,PSL,WARN,"[(","_section_",")) Q ""
 N elm S elm=""
 N lst S lst=""
 F  S elm=$order(this("cs",section,elm)) Q:(elm="")  S lst=$S((lst=""):elm,1:lst_","_elm)
 Q lst
 ;
 ; ---------------------------------------------------------------------
loadClass(this,clsNm) ; 
 ;
 I ($D(this("pslCls",clsNm))#2) Q 
 ;
 N tryNext S tryNext=0
 N clsdes
 ;
 D  ; first look at .pslx file
 .	N $ET,$ES,$ZYER S $ZYER="ZE^UCGMR",$ZE="",$EC="",$ET="D:$TL>"_$TL_" rollback^vRuntime("_$TL_") Q:$Q&$ES """" Q:$ES  N voxMrk s voxMrk="_+$O(vobj(""),-1)_" G vCatch2^"_$T(+0)
 .	N id S id=""
 .	N pslx  D vcdmNew^PSLX(.pslx,"PSLX",clsNm)
 .	S pslx("packageDirs")=this("packageDirs")
 .	;
 .	D extract^PSLX(.pslx)
 .	S clsNm=pslx("moduleName")
 .	S this("pslCls",clsNm)=pslx("pslCls",clsNm)
 .	F  S id=$order(pslx("pslMtd",id)) Q:(id="")  S this("pslMtd",id)=pslx("pslMtd",id)
 .	F  S id=$order(pslx("pslPrp",id)) Q:(id="")  S this("pslPrp",id)=pslx("pslPrp",id)
 .	Q 
 ;
 I tryNext D  ; not found as .pslx file, try OBJECT tables
 .	N rsCls,vos1,vos2,vos3,vos4,vos6,vos5  N V1 S V1=$ZCONVERT(clsNm,"L") S rsCls=$$vOpen1()
 .	I $$vFetch1() D
 ..		; class found in OBJECT, derive the PSLClass values
 ..  N rwCls S rwCls=rsCls
 ..		I $P(rwCls,$C(9),1)'=clsNm S clsNm=$P(rwCls,$C(9),1) Q:($D(this("pslCls",clsNm))#2) 
 ..		;
 ..		S clsdes=$$vcdmNew^PSLClass("PSLClass")
 ..		S $P(clsdes,$C(9),11)=2
 ..		S $P(clsdes,$C(9),10)="framework.psl"
 ..		;
 ..		I $P(rwCls,$C(9),4)=1 D
 ...			N supercls S supercls=$P(rwCls,$C(9),2)
 ...			I supercls="Primitive" S $P(rwCls,$C(9),4)=3
 ...			E  S $P(rwCls,$C(9),4)=2
 ...			Q 
 ..		I ($P(rwCls,$C(9),3)="") S $P(rwCls,$C(9),3)=124
 ..		; CLASS, CONSTRUCTOR, and PROPPROC are mapped by their equal names
 ..		D vRwTO1(.rwCls,.clsdes)
 ..		;
 ..		S this("pslCls",clsNm)=clsdes
 ..		;
 ..		; use OBJECTMET for this.pslMtd()
 ..		N mtddes
 ..		N rsMtd,vos7,vos8,vos9,vos10,vos11  N V2 S V2=clsNm S rsMtd=$$vOpen2()
 ..		F  Q:'$$vFetch2()  D
 ...			S mtddes=$$vcdmNew^PSLMethod("PSLMethod")
 ...			S $P(mtddes,$C(9),6)=2
 ...			S $P(mtddes,$C(9),7)=0
 ...			;
 ...   N rwMtd S rwMtd=rsMtd
 ...			I ($P(rwMtd,$C(9),3)="") S $P(rwMtd,$C(9),3)="void"
 ...			; CLASS and METHOD are mapped by their equal names
 ...			D vRwTO2(.rwMtd,.mtddes)
 ...			S this("pslMtd",clsNm_"."_$P(rwMtd,$C(9),2))=mtddes
 ...			Q 
 ..		;
 ..		; use OBJECTPROP for this.pslPrp()
 ..		N prpdes
 ..		N rsPrp,vos12,vos13,vos14,vos15,vos16  N V3 S V3=clsNm S rsPrp=$$vOpen3()
 ..		F  Q:'$$vFetch3()  D
 ...			S prpdes=$$vcdmNew^PSLProperty("PSLProperty")
 ...			S $P(prpdes,$C(9),5)=2
 ...			;
 ...   N rwPrp S rwPrp=rsPrp
 ...			I ($P(rwPrp,$C(9),7)="") S $P(rwPrp,$C(9),7)=0
 ...			; CLASS, and PROPERTY are mapped by their equal names
 ...			D vRwTO3(.rwPrp,.prpdes)
 ...			S this("pslPrp",clsNm_"."_$P(rwPrp,$C(9),2))=prpdes
 ...			Q 
 ..		S tryNext=0
 ..  Q  ; end clsNm found in OBJECT
 . Q 
 ;
 I tryNext D
 .	Q:$$isRecord^PSLClass(clsNm)<2  ; not Record descendant
 .	;
 .	N td S td=$$getPSLTable(.this,$E(clsNm,7,1048575),0)
 .	;
 .	S this("pslCls",clsNm)=$$recordMod^PSLClass(.td)
 .	Q 
 Q 
 ;
 ; ---------------------------------------------------------------------
loadSettings(this,from) ; Return List of all elements for which this.hasSetting() returns true
  K this("cs") M this("cs")=from("cs")
 Q 
 ;
 ; ---------------------------------------------------------------------
reset(this) ; polymorphism dispatch
 N vC S vC=$P($G(this),$C(9))
 I $D(vPslPoly(vC,"reset")) D v0reset^@vPslPoly(vC,"reset")(.this) Q
 D v0reset(.this) Q
v0reset(this) ; reset all pointers
 K this("cs"),this("pslCls"),this("pslCln"),this("pslMtd"),this("pslPrp"),this("pslTbl")
 S this("ucopts")="" S this("packageDirs")=""
 Q 
 ;
 ; ---------------------------------------------------------------------
setUcopts(this,ucopts) ; 
 N elm
 N grp
 N lst
 N val
 ;
 I $$listSettings(.this,"PSL")'="" Q  ; already set
 ;
 S this("ucopts")=ucopts ; assign value
 ;
 ; Step 1: Compiler call settings are unconditional
 N file S file=this("ucopts")
 I '(file="") D
 .	;   #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 .	N path S path=$$PARSE^%ZFUNC(file,"DIR")
 .	I file[path S file=$E(file,$L(path)+1,1048575)
 .	D decodeFile^UCGMC(path,file,.this)
 .	Q 
 ;
 ; Step 2: User supplied overwrites
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 S file=$$SCAU^%TRNLNM("UCOPTS")
 I '(file="") D
 .	;   #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 .	N path S path=$$PARSE^%ZFUNC(file,"DIR")
 .	I file[path S file=$E(file,$L(path)+1,1048575)
 .	N usrOpts  D vcdmNew^PSLParser(.usrOpts,"PSLParser","")
 .	D decodeFile^UCGMC(path,file,.usrOpts)
 .	F grp="WARN","INFO","OPTIMIZE","Options","PSL","DEBUG","boot" D
 ..		S lst=$$listSettings(.usrOpts,grp)
 ..		F elm=1:1:$S((lst=""):0,1:$L(lst,",")) D
 ...			S val=$piece(lst,",",elm)
 ...			I '($D(this("cs",grp,val))#2) S this("cs",grp,val)=$$getSetting(.usrOpts,grp,val)
 ...			Q 
 ..		Q 
 .	Q 
 ;
 ; Step 3: Environment standard values (no support for boot/DEBUG/PSL)
 I $$getSetting(.this,"boot","restrictionlevel",0)<3 D
 .	N Options
 .	;
 .	D ^UCOPTS(.Options)
 .	F grp="WARN","INFO","OPTIMIZE","Options" D
 ..		S lst=$get(Options(grp))
 ..		F elm=1:1:$S((lst=""):0,1:$L(lst,",")) D
 ...			S val=$piece(lst,",",elm)
 ...			I (val="") Q 
 ...			I '($D(this("cs",grp,val))#2) S this("cs",grp,val)=1
 ...			Q 
 ..		Q 
 .	;
 .	S grp="PSL"
 .	S lst=$$allPSL^UCGMC()
 .	F elm=1:1:$S((lst=""):0,1:$L(lst,",")) D
 ..		S val=$piece(lst,",",elm)
 ..		I '($D(this("cs",grp,val))#2) S this("cs",grp,val)=Options(grp,val)
 ..		Q 
 .	Q 
 ;
 ; Step 4: Force masks
 D masks^UCDTAUTL(.this)
 Q 
 ;
 ;  #OPTION ResultClass ON
vSIG(this) ; polymorphism dispatch
 N vC S vC=$P($G(this),$C(9))
 I $D(vPslPoly(vC,"vSIG")) Q $$v0vSIG^@vPslPoly(vC,"vSIG")(.this)
 Q $$v0vSIG(.this)
v0vSIG(this) ; 
 Q "61461^42873^Frans S.C. Witte^21401" ; Signature - LTD^TIME^USER^SIZE
 ; ----------------
 ;  #OPTION ResultClass 1
vRwTO1(vRow,vObj) ; Copy Row to PSLClass
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 S $P(vObj,$C(9),7)=$P(vRow,$C(9),6)
 S $P(vObj,$C(9),2)=$P(vRow,$C(9),1)
 S $P(vObj,$C(9),6)=$P(vRow,$C(9),5)
 S $P(vObj,$C(9),5)=$P(vRow,$C(9),4)
 S $P(vObj,$C(9),8)=$P(vRow,$C(9),7)
 S $P(vObj,$C(9),4)=$P(vRow,$C(9),3)
 S $P(vObj,$C(9),9)=$P(vRow,$C(9),8)
 S $P(vObj,$C(9),3)=$P(vRow,$C(9),2)
 Q 
 ; ----------------
 ;  #OPTION ResultClass 1
vRwTO2(vRow,vObj) ; Copy Row to PSLMethod
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 S $P(vObj,$C(9),2)=$P(vRow,$C(9),1)
 S $P(vObj,$C(9),13)=$P(vRow,$C(9),7)
 S $P(vObj,$C(9),3)=$P(vRow,$C(9),2)
 S $P(vObj,$C(9),5)=$P(vRow,$C(9),4)
 S $P(vObj,$C(9),4)=$P(vRow,$C(9),3)
 S $P(vObj,$C(9),11)=$P(vRow,$C(9),5)
 S $P(vObj,$C(9),12)=$P(vRow,$C(9),6)
 Q 
 ; ----------------
 ;  #OPTION ResultClass 1
vRwTO3(vRow,vObj) ; Copy Row to PSLProperty
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 S $P(vObj,$C(9),4)=$P(vRow,$C(9),3)
 S $P(vObj,$C(9),2)=$P(vRow,$C(9),1)
 S $P(vObj,$C(9),6)=$P(vRow,$C(9),4)
 S $P(vObj,$C(9),8)=$P(vRow,$C(9),6)
 S $P(vObj,$C(9),9)=$P(vRow,$C(9),7)
 S $P(vObj,$C(9),3)=$P(vRow,$C(9),2)
 S $P(vObj,$C(9),7)=$P(vRow,$C(9),5)
 S $P(vObj,$C(9),10)=$P(vRow,$C(9),8)
 Q 
 ;
vOpen1() ; CLASS,SUPERTYPE,PROPDELIM,ISPRIMITIVE,CONSTRUCTOR,ABSTRACT,NOINSTANT,PROPPROC FROM OBJECT WHERE LOWER( CLASS) = :V1
 ;
 ;
 S vos1=2
 D vL1a1
 Q ""
 ;
vL1a0 S vos1=0 Q
vL1a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(V1) I vos3="" G vL1a0
 S vos4=""
vL1a4 S vos4=$O(^OBJECT(vos4),1) I vos4="" G vL1a0
 I '($$LOWER^UCGMR(vos4)=vos3) G vL1a4
 Q
 ;
vFetch1() ;
 ;
 ;
 I vos1=1 D vL1a4
 I vos1=2 S vos1=1
 ;
 I vos1=0 S rsCls="" Q 0
 ;
 S vos5=$G(^OBJECT(vos4,0))
 S vos6=$G(^OBJECT(vos4))
 S rsCls=$S(vos4=vos2:"",1:vos4)_$C(9)_$P(vos6,"|",1)_$C(9)_$P(vos5,"|",1)_$C(9)_$P(vos6,"|",6)_$C(9)_$P(vos6,"|",3)_$C(9)_$P(vos6,"|",4)_$C(9)_$P(vos6,"|",5)_$C(9)_$P(vos5,"|",2)
 ;
 Q 1
 ;
vOpen2() ; CLASS,METHOD,RETURN,PARAMETERS,ROU,VALLIT,DES FROM OBJECTMET WHERE CLASS = :V2
 ;
 ;
 S vos7=2
 D vL2a1
 Q ""
 ;
vL2a0 S vos7=0 Q
vL2a1 S vos8=$$BYTECHAR^SQLUTL(254)
 S vos9=$G(V2) I vos9="" G vL2a0
 S vos10=""
vL2a4 S vos10=$O(^OBJECT(vos9,1,vos10),1) I vos10="" G vL2a0
 Q
 ;
vFetch2() ;
 ;
 ;
 I vos7=1 D vL2a4
 I vos7=2 S vos7=1
 ;
 I vos7=0 S rsMtd="" Q 0
 ;
 S vos11=$G(^OBJECT(vos9,1,vos10))
 S rsMtd=vos9_$C(9)_$S(vos10=vos8:"",1:vos10)_$C(9)_$P(vos11,"|",1)_$C(9)_$P(vos11,"|",2)_$C(9)_$P(vos11,"|",3)_$C(9)_$P(vos11,"|",9)_$C(9)_$P(vos11,"|",4)
 ;
 Q 1
 ;
vOpen3() ; CLASS,PROPERTY,ARRAY,ISREADONLY,RETURN,NOD,POS,ROUTINE FROM OBJECTPROP WHERE CLASS = :V3
 ;
 ;
 S vos12=2
 D vL3a1
 Q ""
 ;
vL3a0 S vos12=0 Q
vL3a1 S vos13=$$BYTECHAR^SQLUTL(254)
 S vos14=$G(V3) I vos14="" G vL3a0
 S vos15=""
vL3a4 S vos15=$O(^OBJECT(vos14,0,vos15),1) I vos15="" G vL3a0
 Q
 ;
vFetch3() ;
 ;
 ;
 I vos12=1 D vL3a4
 I vos12=2 S vos12=1
 ;
 I vos12=0 S rsPrp="" Q 0
 ;
 S vos16=$G(^OBJECT(vos14,0,vos15))
 S rsPrp=vos14_$C(9)_$S(vos15=vos13:"",1:vos15)_$C(9)_$P(vos16,"|",6)_$C(9)_$P(vos16,"|",8)_$C(9)_$P(vos16,"|",3)_$C(9)_$P(vos16,"|",1)_$C(9)_$P(vos16,"|",2)_$C(9)_$P(vos16,"|",7)
 ;
 Q 1
 ;
vCatch2 ; Error trap
 ;
 N vEx,$ET,$ES S vEx=$ZE,$EC="",$ET="Q",$ZE=""
 S tryNext=1
 D ZX^UCGMR(voxMrk) Q 
 ;
vCatch1 ; Error trap
 ;
 N xAny,$ET,$ES S xAny=$ZE,$EC="",$ET="Q",$ZE=""
 ; ignore any exception that results from the M XECUTE
 D ZX^UCGMR(voxMrk) Q 
vcdmNew(this,vC) ; Constructor, called for Class.new()
 N vT S vT=$T
 S this=vC
 S this("packageDirs")=""
 S this("ucopts")=""
 I vT
 Q
