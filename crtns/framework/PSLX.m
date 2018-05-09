 ; 
 ; **** Routine compiled from DATA-QWIK Procedure PSLX ****
 ; 
 ; 02/24/2010 18:22 - pip
 ; 
 ;  #PACKAGE  framework.psl
 ;
 ;  #CLASSDEF extends=PSLCC public delimiter=9
 ;
 ; ---------------------------------------------------------------------
 ;  #PROPERTYDEF moduleName  class=String public readonly node="moduleName"
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
 S this("moduleName")=initObj
 ;
 Q 
 ;
 ; ---------------------------------------------------------------------
classOnly(this) ; extract only the class-descriptor
 ;
 N modIO S modIO=$$vClVobj($ST,"IO")
 N usePsl S usePsl=$$usePsl(.this,modIO)
 I usePsl D  K:usePsl vobj(+$G(modIO)) Q:usePsl 
 .	D
 ..		N $ET,$ES,$ZYER S $ZYER="ZE^UCGMR",$ZE="",$EC="",$ET="D:$TL>"_$TL_" rollback^vRuntime("_$TL_") Q:$Q&$ES """" Q:$ES  N voxMrk s voxMrk="_+$O(vobj(""),-1)_" G vCatch1^"_$T(+0)
 ..		D classPsl(.this)
 ..		Q 
 .	Q 
 ;
 N tknzr  D vcdmNew^PSLTokenizer(.tknzr,"PSLTokenizer",modIO)
 S tknzr("tknIgnEOL")=1
 ;
 N json N name N value
 N tkn S tkn=-1
 ;
 I $$nextToken^PSLTokenizer(.tknzr)'=123 S $ZE="0,"_$ZPOS_","_"%PSL-E-INVALID, invalid source descriptor file for '"_this("moduleName")_"'",$EC=",U1001,"
 ;
 F  Q:'(tkn'=125)  D
 .	S tkn=$$nextToken^PSLTokenizer(.tknzr)
 .	I tkn=-1 S $ZE="0,"_$ZPOS_","_"%PSL-E-INVALID,Unxpected end-of-file in "_this("moduleName")_".pslx",$EC=",U1001,"
 .	S name=tknzr("tknValue")
 .	I tkn'=34 S $ZE="0,"_$ZPOS_","_"%PSL-E-INVALID,class-descriptor-name expected in "_this("moduleName")_".pslx; found "_name,$EC=",U1001,"
 .	;
 .	I $$nextToken^PSLTokenizer(.tknzr)'=58 S $ZE="0,"_$ZPOS_","_"%PSL-E-INVALID,':' expected in "_this("moduleName")_".pslx; found '"_tknzr("tknValue")_"'",$EC=",U1001,"
 .	;
 .	; The "properties" or "methods" arrays indiacte the end of the search
 .	I name="properties" S tkn=125 Q 
 .	I name="methods" S tkn=125 Q 
 .	;
 .	S tkn=$$nextToken^PSLTokenizer(.tknzr) S value=tknzr("tknValue")
 .	I tkn=-3 D
 ..		I value="true" S value=1
 ..		E  I value="false" S value=0
 ..		E  S $ZE="0,"_$ZPOS_","_"%PSL-E-INVALID,unknown class-descriptor-value '"_value_"' in "_this("moduleName")_".pslx",$EC=",U1001,"
 ..		Q 
 .	E  I tkn'=34,tkn'=-2 S $ZE="0,"_$ZPOS_","_"%PSL-E-INVALID,unknown class-descriptor-value '"_value_"' in "_this("moduleName")_".pslx",$EC=",U1001,"
 .	S json(name)=value
 .	;
 .	S tkn=$$nextToken^PSLTokenizer(.tknzr)
 .	I tkn'=44,tkn'=125 S $ZE="0,"_$ZPOS_","_"%PSL-E-INVALID,Unxpected token '"_tknzr("tknValue")_"' in "_this("moduleName")_".pslx",$EC=",U1001,"
 .	Q 
 ;
 S this("pslCls",json("class"))=$$fromJSON^PSLClass(.json)
 K vobj(+$G(modIO)) Q 
 ;
 ; ---------------------------------------------------------------------
extract(this) ; extract the descriptors
 ;
 N modIO S modIO=$$vClVobj($ST,"IO")
 N usePsl S usePsl=$$usePsl(.this,modIO)
 I usePsl D  K:usePsl vobj(+$G(modIO)) Q:usePsl 
 .	D
 ..		N $ET,$ES,$ZYER S $ZYER="ZE^UCGMR",$ZE="",$EC="",$ET="D:$TL>"_$TL_" rollback^vRuntime("_$TL_") Q:$Q&$ES """" Q:$ES  N voxMrk s voxMrk="_+$O(vobj(""),-1)_" G vCatch2^"_$T(+0)
 ..		D fromPsl(.this)
 ..		Q 
 .	Q 
 ;
 N tknzr  D vcdmNew^PSLTokenizer(.tknzr,"PSLTokenizer",modIO)
 S tknzr("tknIgnEOL")=1
 S tknzr("charEscape")="\"
 S tknzr("charSymbol")="=:,[]{}"
 ;
 N json N name N value
 N tkn S tkn=-1
 ;
 I $$nextToken^PSLTokenizer(.tknzr)'=123 S $ZE="0,"_$ZPOS_","_"%PSL-E-INVALID, invalid source descriptor file for '"_this("moduleName")_"'",$EC=",U1001,"
 ;
 F  Q:'(tkn'=125)  D
 .	S tkn=$$nextToken^PSLTokenizer(.tknzr)
 .	I tkn=-1 S $ZE="0,"_$ZPOS_","_"%PSL-E-INVALID,Unxpected end-of-file in "_this("moduleName")_".pslx",$EC=",U1001,"
 .	S name=tknzr("tknValue")
 .	I tkn'=34 S $ZE="0,"_$ZPOS_","_"%PSL-E-INVALID,class-descriptor-name expected in "_this("moduleName")_".pslx; found "_name,$EC=",U1001,"
 .	;
 .	I $$nextToken^PSLTokenizer(.tknzr)'=58 S $ZE="0,"_$ZPOS_","_"%PSL-E-INVALID,':' expected in "_this("moduleName")_".pslx; found '"_tknzr("tknValue")_"'",$EC=",U1001,"
 .	I name="properties" D
 ..		I $$nextToken^PSLTokenizer(.tknzr)'=91 S $ZE="0,"_$ZPOS_","_"%PSL-E-INVALID,'[' expected in "_this("moduleName")_".pslx; found '"_tknzr("tknValue")_"'",$EC=",U1001,"
 ..		F  D  Q:tkn=93 
 ...			S tkn=$$extrPrp(.this,.tknzr)
 ...			I tkn'=44,tkn'=93 S $ZE="0,"_$ZPOS_","_"%PSL-E-INVALID,']' or ',' expected in "_this("moduleName")_".pslx; found '"_tknzr("tknValue")_"'",$EC=",U1001,"
 ...			Q 
 ..		Q 
 .	E  I name="methods" D
 ..		I $$nextToken^PSLTokenizer(.tknzr)'=91 S $ZE="0,"_$ZPOS_","_"%PSL-E-INVALID,'[' expected in "_this("moduleName")_".pslx; found '"_tknzr("tknValue")_"'",$EC=",U1001,"
 ..		F  D  Q:tkn=93 
 ...			S tkn=$$extrMtd(.this,.tknzr)
 ...			I tkn'=44,tkn'=93 S $ZE="0,"_$ZPOS_","_"%PSL-E-INVALID,']' or ',' expected in "_this("moduleName")_".pslx; found '"_tknzr("tknValue")_"'",$EC=",U1001,"
 ...			Q 
 ..		Q 
 .	E  D
 ..		S tkn=$$nextToken^PSLTokenizer(.tknzr) S value=tknzr("tknValue")
 ..		I tkn=-3 D
 ...			I value="true" S value=1
 ...			E  I value="false" S value=0
 ...			E  S $ZE="0,"_$ZPOS_","_"%PSL-E-INVALID,unknown class-descriptor-value '"_value_"' in "_this("moduleName")_".pslx",$EC=",U1001,"
 ...			Q 
 ..		E  I tkn'=34,tkn'=-2 S $ZE="0,"_$ZPOS_","_"%PSL-E-INVALID,unknown class-descriptor-value '"_value_"' in "_this("moduleName")_".pslx",$EC=",U1001,"
 ..		S json(name)=value
 ..		Q 
 .	S tkn=$$nextToken^PSLTokenizer(.tknzr)
 .	I tkn'=44,tkn'=125 S $ZE="0,"_$ZPOS_","_"%PSL-E-INVALID,Unxpected token '"_tknzr("tknValue")_"' in "_this("moduleName")_".pslx",$EC=",U1001,"
 .	Q 
 ;
 S this("pslCls",json("class"))=$$fromJSON^PSLClass(.json)
 K vobj(+$G(modIO)) Q 
 ;
 ; ---------------------------------------------------------------------
fromTarget(this) ; 
 ;
 N modIO S modIO=$$vClVobj($ST,"IO")
 N %ZI N %ZR N src
 ;
 S %ZI(this("moduleName"))=""
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 D INT^%RSEL
 N dir S dir=$get(%ZR(this("moduleName")))
 ;
 I (dir="") S $ZE="0,"_$ZPOS_","_"%PSL-E-UNDEF,module '"_this("moduleName")_"' not found",$EC=",U1001,"
 ;
 S $P(vobj(modIO,1),"|",2)=dir
 S $P(vobj(modIO,1),"|",1)=$translate(this("moduleName"),"%","_")_".m"
 S $P(vobj(modIO,1),"|",3)="READ"
 S $P(vobj(modIO,1),"|",5)=1980+1
 ;
 D
 .	N $ET,$ES,$ZYER S $ZYER="ZE^UCGMR",$ZE="",$EC="",$ET="D:$TL>"_$TL_" rollback^vRuntime("_$TL_") Q:$Q&$ES """" Q:$ES  N voxMrk s voxMrk="_+$O(vobj(""),-1)_" G vCatch3^"_$T(+0)
 .	D open^UCIO(modIO,$T(+0),"fromTarget","modIO")
 .	;
 .	N cls S cls=this("moduleName") N code N decl N declDoc N fp N fpl N fplDoc
 .	N ln N fpn
 .	;
 .	S this("pslCls",cls)=$$nativeMod^PSLClass(cls)
 .	;
 .	F ln=1:1 D
 ..		S code=$translate($$read^UCIO(modIO),$char(9)_$char(10)_$char(13)," ")
 ..		Q:$E(code,1)=" " 
 ..		;
 ..		S decl=$piece(code," ")
 ..		;
 ..		N mtddes S mtddes=$$vcdmNew^PSLMethod("PSLMethod")
 ..		;
 ..		S $P(mtddes,$C(9),6)=2
 ..		S $P(mtddes,$C(9),2)=cls
 ..		S $P(mtddes,$C(9),8)=0
 ..		S $P(mtddes,$C(9),12)=0
 ..		S $P(mtddes,$C(9),3)=$piece(decl,"(")
 ..		S $P(mtddes,$C(9),7)=3
 ..		;
 ..		I $L(code,";")>2 D
 ...			S declDoc=$$vStrTrim($piece(code,";",2),0," ")
 ...			S $P(mtddes,$C(9),13)=$$vStrTrim($piece(code,";",3,$L(code,";")),0," ")
 ...			Q 
 ..		E  S declDoc="" S $P(mtddes,$C(9),13)=$$vStrTrim($piece(code,";",2),0," ")
 ..		;
 ..		I '(declDoc="") D
 ...			S fpl=$piece(declDoc,"(")
 ...			Q:(fpl="") 
 ...			F fpn=1:1:$L(fpl," ") D
 ....				S fp=$piece(fpl," ",fpn)
 ....				I ((","_"protected,private,package,public"_",")[(","_fp_",")) D
 .....					S:fp="package" fp="public"
 .....					S $P(mtddes,$C(9),6)=$L($piece((","_"protected,private,,public"_","),","_fp_",",1),",")-2
 .....					Q 
 ....				I ((","_$$getCls^UCGMCU("PSLX")_",")[(","_fp_","))!(fp="void") S $P(mtddes,$C(9),4)=fp
 ....				Q 
 ...			Q 
 ..		;
 ..		I decl["(" D
 ...			S $P(mtddes,$C(9),7)=2
 ...			S decl=$E(decl,$F(decl,"("),$L(decl)-1)
 ...			Q:(decl="") 
 ...			;
 ...			S fplDoc=$S((declDoc["("):$E(declDoc,$F(declDoc,"("),$L(declDoc)-1),1:"")
 ...			S fp=$piece(fplDoc,",") S fpl=$S((fp=""):"ret String ",1:$$vStrTrim(fp,0," ")_" ")_$piece(decl,",")
 ...			F fpn=2:1:$L(decl,",") S fp=$piece(fplDoc,",",fpn) S fpl=fpl_";"_$S((fp=""):"ret String ",1:$$vStrTrim(fp,0," ")_" ")_$piece(decl,",",fpn)
 ...			S $P(mtddes,$C(9),5)=fpl
 ...			Q 
 ..		;
 ..		S this("pslMtd",cls_"."_$P(mtddes,$C(9),3))=mtddes
 ..		Q 
 .	Q 
 ;
 K vobj(+$G(modIO)) Q 
 ;
 ; ---------------------------------------------------------------------
classPsl(this) ; 
 ;
 ; instantiate a new PSLParser and pass packageDirs
 N psl  D vcdmNew^PSLParser(.psl,"PSLParser",this("moduleName"))
 S psl("packageDirs")=this("packageDirs")
 ;
 N err S err=$$passClass^PSLParser(.psl,.this)
 Q 
 ;
 ; ---------------------------------------------------------------------
extrMtd(this,tknzr) ; 
 N json
 N tkn S tkn=$$extrObj(.this,.tknzr,.json)
 ;
 S this("pslMtd",json("class")_"."_json("method"))=$$fromJSON^PSLMethod(.json)
 ;
 Q tkn
 ;
 ; ---------------------------------------------------------------------
extrObj(this,tknzr,json) ; 
 ;
 N tkn S tkn=-1
 N name N value
 ;
 I $$nextToken^PSLTokenizer(.tknzr)'=123 S $ZE="0,"_$ZPOS_","_"%PSL-E-INVALID,'{' expected for descriptor in "_this("moduleName")_".pslx",$EC=",U1001,"
 ;
 F  Q:'(tkn'=125)  D
 .	S tkn=$$nextToken^PSLTokenizer(.tknzr)
 .	I tkn=-1 S $ZE="0,"_$ZPOS_","_"%PSL-E-INVALID,Unxpected end-of-file in "_this("moduleName")_".pslx",$EC=",U1001,"
 .	S name=tknzr("tknValue")
 .	I tkn'=34 S $ZE="0,"_$ZPOS_","_"%PSL-E-INVALID,method-descriptor-name expected in "_this("moduleName")_".pslx; found "_name,$EC=",U1001,"
 .	;
 .	I $$nextToken^PSLTokenizer(.tknzr)'=58 S $ZE="0,"_$ZPOS_","_"%PSL-E-INVALID,':' expected in "_this("moduleName")_".pslx; found '"_tknzr("tknValue")_"'",$EC=",U1001,"
 .	;
 .	S tkn=$$nextToken^PSLTokenizer(.tknzr) S value=tknzr("tknValue")
 .	I tkn=-3 D
 ..		I value="true" S value=1
 ..		E  I value="false" S value=0
 ..		E  S $ZE="0,"_$ZPOS_","_"%PSL-E-INVALID,unknown descriptor-value '"_value_"' in "_this("moduleName")_".pslx",$EC=",U1001,"
 ..		Q 
 .	E  I tkn'=34,tkn'=-2 S $ZE="0,"_$ZPOS_","_"%PSL-E-INVALID,unknown descriptor-value '"_value_"' in "_this("moduleName")_".pslx",$EC=",U1001,"
 .	S json(name)=value
 .	S tkn=$$nextToken^PSLTokenizer(.tknzr)
 .	I tkn'=44,tkn'=125 S $ZE="0,"_$ZPOS_","_"%PSL-E-INVALID,Unxpected token '"_tknzr("tknValue")_"' in "_this("moduleName")_".pslx",$EC=",U1001,"
 .	Q 
 Q $$nextToken^PSLTokenizer(.tknzr)
 ;
 ; ---------------------------------------------------------------------
extrPrp(this,tknzr) ; 
 N json
 N tkn S tkn=$$extrObj(.this,.tknzr,.json)
 ;
 S this("pslPrp",json("class")_"."_json("property"))=$$fromJSON^PSLProperty(.json)
 ;
 Q tkn
 ;
 ; ---------------------------------------------------------------------
usePsl(this,modIO) ; 
 N vpc
 N pckDirs S pckDirs=this("packageDirs")
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 I $$PARSE^%ZFUNC(this("moduleName"),"NAME")=this("moduleName"),(pckDirs="") D
 .	S pckDirs=$$packageDirs^PSLC("","")
 .	S this("packageDirs")=pckDirs
 .	Q 
 ;
 I '$$locate^UCIO(modIO,pckDirs,":",this("moduleName")_".pslx",1) Q 1
 ;
 S this("moduleName")=$piece($P(vobj(modIO,1),"|",1),".")
 ;
 N usePsl S usePsl=0
 ;
 ; no .psl file in that directory
 N pslIO S pslIO=$$vClVobj($ST,"IO")
 S vpc='$$locate^UCIO(pslIO,$P(vobj(modIO,1),"|",2),":",this("moduleName")_".psl",0) K:vpc vobj(+$G(pslIO)) Q:vpc 0
 ;
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 N stPslx S stPslx=$$FILE^%ZFUNC($P(vobj(modIO,1),"|",2)_$P(vobj(modIO,1),"|",1),"CDT")
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 N stPsl S stPsl=$$FILE^%ZFUNC($P(vobj(pslIO,1),"|",2)_$P(vobj(pslIO,1),"|",1),"CDT")
 ;
 I +stPsl=+stPslx K vobj(+$G(pslIO)) Q +$piece(stPsl,",",2)>+$piece(stPslx,",",2)
 ;
 K vobj(+$G(pslIO)) Q +stPsl>+stPslx
 ;
 ; ---------------------------------------------------------------------
fromPsl(this) ; 
 ;
 ; instantiate a new PSLParser and set its packageDirs property
 N psl  D vcdmNew^PSLParser(.psl,"PSLParser",this("moduleName"))
 S psl("packageDirs")=this("packageDirs")
 ;
 N err S err=$$passPslx^PSLParser(.psl,.this)
 Q:err=0 
 ;
 I err=-1 D fromTarget(.this) Q 
 ;
 S $ZE="0,"_$ZPOS_","_"%PSL-E-UNDEF,cannot extract description for module '"_this("moduleName")_"' not found",$EC=",U1001,"
 Q  ; dead code
 ;  #OPTION ResultClass ON
vSIG(this) ; polymorphism dispatch
 N vC S vC=$P($G(this),$C(9))
 I $D(vPslPoly(vC,"vSIG")) Q $$v0vSIG^@vPslPoly(vC,"vSIG")(.this)
 Q $$v0vSIG(.this)
v0vSIG(this) ; 
 Q "61461^42885^Frans S.C. Witte^18873" ; Signature - LTD^TIME^USER^SIZE
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
vCatch3 ; Error trap
 ;
 N xIO,$ET,$ES S xIO=$ZE,$EC="",$ET="Q",$ZE=""
 D close^UCIO(modIO)
 D ZX^UCGMR(voxMrk) Q 
 ;
vCatch2 ; Error trap
 ;
 N vEx,$ET,$ES S vEx=$ZE,$EC="",$ET="Q",$ZE=""
 S usePsl=0 ; indicate failure
 S $P(vobj(modIO,1),"|",1)=this("moduleName")_".pslx"
 D ZX^UCGMR(voxMrk) Q 
 ;
vCatch1 ; Error trap
 ;
 N vEx,$ET,$ES S vEx=$ZE,$EC="",$ET="Q",$ZE=""
 S usePsl=0 ; indicate failure
 S $P(vobj(modIO,1),"|",1)=this("moduleName")_".pslx"
 D ZX^UCGMR(voxMrk) Q 
vcdmNew(this,vC,vInitObj) ; Constructor, called for Class.new()
 N vT S vT=$T
 D vcdmNew^PSLCC(.this,vC)
 I '$D(vPslPoly("PSLX")) D
 . M vPslPoly("PSLX")=vPslPoly("PSLCC")
 . S vPslPoly("PSLX","vSIG")="PSLX"
 D initialize(.this,.vInitObj)
 I vT
 Q
