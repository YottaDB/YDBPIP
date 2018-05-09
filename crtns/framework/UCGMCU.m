 ; 
 ; **** Routine compiled from DATA-QWIK Procedure UCGMCU ****
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
 ;
 ; ---------------------------------------------------------------------
boot(vDataDir) ; bootstrap the PSL compiler and SQL engine
 ;
 ; Update the current image by ZLINKing the routines that may have been
 ; called before. Do this before generating and ZLINKing UCOPTS
 D linkPreBoot() D bootUCOPTS() D linkList("UCOPTS")
 ;
 ; Boot the remainder of the PSL compiler, SQL engine, and DBS kernel
 N sysList
 N elm
 N unt
 ;
 S sysList=$$getList("Data")
 F elm=1:1:$S((sysList=""):0,1:$L(sysList,",")) D
 .	S unt=$piece(sysList,",",elm)
 .	;
 .	I unt="UCOPTS" Q  ; UCOPTS already compiled separately
 .	;
 .	N co ; compiler options (clean set per call)
 .	;
 .	I '($get(vDataDir)="") S co("boot","datadirectory")=vDataDir
 .	;
 .	D getBootOptions(.co,2) ; use boot restrictionlevel=2
 .	;
 .	D bootCmp(unt,.co)
 .	;
 .	; ZLINK new, environment specific, version (to deal with polluted image)
 .	D linkList(unt)
 .	Q 
 ;
 N comList S comList=$$getList("Compiler")
 F elm=1:1:$S((comList=""):0,1:$L(comList,",")) D
 .	S unt=$piece(comList,",",elm)
 .	I ((","_sysList_",")[(","_unt_",")) Q  ; Data group already done
 .	I '$$isProc^UCXDT25(unt) Q  ; not a DQ procedure
 .	D bootProc(unt)
 .	Q 
 ;
 Q 
 ;
 ; ---------------------------------------------------------------------
bootFWPh2() ; bootstrap phase 2 of the framework
 ;
 N elm
 N unt
 ;
 N phase2BList S phase2BList=$$getList("Phase2B")
 F elm=1:1:$S((phase2BList=""):0,1:$L(phase2BList,",")) D
 .	S unt=$piece(phase2BList,",",elm)
 .	D bootProc(unt) D linkList(unt)
 .	Q 
 ;
 N filerBList S filerBList=$$getList("FilerB")
 F elm=1:1:$S((filerBList=""):0,1:$L(filerBList,",")) D
 .	S unt=$piece(filerBList,",",elm)
 .	D bootFiler(unt,2) D linkList("Record"_unt)
 .	Q 
 ;
 N phase2EList S phase2EList=$$getList("Phase2E")
 F elm=1:1:$S((phase2EList=""):0,1:$L(phase2EList,",")) D
 .	S unt=$piece(phase2EList,",",elm)
 .	D bootProc(unt) D linkList(unt)
 .	Q 
 ;
 N filerEList S filerEList=$$getList("FilerE")
 F elm=1:1:$S((filerEList=""):0,1:$L(filerEList,",")) D
 .	S unt=$piece(filerEList,",",elm)
 .	D bootFiler(unt,2) D linkList("Record"_unt)
 .	Q 
 ;
 ; (re)build the DBSDRVDPL dispatcher
 N bldDrv S bldDrv=$$build^DBSDRV()
 S:(bldDrv="") bldDrv="function buildDBSDRV completed succesfully"
 WRITE bldDrv,!
 ;
 Q 
 ;
 ; ---------------------------------------------------------------------
bootCmp(proc,cco) ; call compiler for bootstrap of a single module
 N src N cfe
 N rtn S rtn=$$getSrc^UCXDT25(proc,.src)
 ;
 Q:rtn="" 
 Q:$D(src)<10 
 ;
 ;do cmpA2F^UCGM( src(), rtn, , ,  cco(,), , .cfe, rtn_"~Procedure")
 S cfe=$$cmpA2F^PSLC(.src,.cco,rtn,,rtn_"~Procedure")
 ;
 I +$get(cfe)>0 Q 
 ;
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 D DEL^%ZRTNDEL($translate(rtn,"%","_"),$$SCAU^%TRNLNM("MRTNS"))
 Q 
 ;
 ; ---------------------------------------------------------------------
bootFiler(table,lvl) ; bootstrap compile a filer
 N co ; compiler options
 N errors
 N mod S mod="Record"_table
 N ucopts
 ;
 D getBootOptions(.co,lvl) ; compile with boot restrictionlevel=lvl
 ;
 S ucopts=$$toUcopts^PSLC("","RecordBoot",.co)
 ;
 S errors=$$run^PSLC("--ucopts="_ucopts_" "_mod)
 ;
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 D DEL^%ZRTNDEL(mod,$$SCAU^%TRNLNM("MRTNS"))
 ;
 D linkList(mod)
 ;
 Q 
 ;
 ; ---------------------------------------------------------------------
bootProc(proc) ; bootstrap compile a procedure
 N co ; compiler options
 ;
 D getBootOptions(.co,1) ; compile with boot restrictionlevel=1
 D bootCmp(proc,.co)
 ;
 Q 
 ;
 ; ---------------------------------------------------------------------
bootUCOPTS() ; procedure to generate routine UCOPTS
 N siteOpts  D vcdmNew^PSLParser(.siteOpts,"PSLParser","") ; values from UCOPTS.ini
 N uc ; UCOPTS source code
 N ln S ln=0 ; source line pointer
 ;
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 D decodeFile^UCGMC($$SCAU^%TRNLNM("DIR"),"UCOPTS.ini",.siteOpts)
 ;
 D ca(.uc,"private UCOPTS( String Options()) // PSL Compiler Environment Options")
 ;
 D ca(.uc," // *******************************************************************")
 D ca(.uc," // * IMPORTANT NOTE:                                                 *")
 D ca(.uc," // * According to the rules that apply to PSL compiler upgrades,     *")
 D ca(.uc," // * this routine is generated by the compiler from the PSL Compiler *")
 D ca(.uc," // * Environemnt Options file $SCAU_DIR/UCOPTS.ini                   *")
 D ca(.uc," // *                                                                 *")
 D ca(.uc," // * To modify environment settings on a permanent basis:            *")
 D ca(.uc," // * 1) change $SCAU_DIR/UCOPT.ini                                   *")
 D ca(.uc," // * 2) call bootUCOPTS^UCGMCU() to rebuild UCOPTS.m                 *")
 D ca(.uc," // *                                                                 *")
 D ca(.uc," // * To modify WARN, OPTIMIZE and Options settings on an incidental  *")
 D ca(.uc," // * basis, ensure that the environment variable $SCAU_UCOPTS names  *")
 D ca(.uc," // * the file that specifies these overwrites.                       *")
 D ca(.uc," // *                                                                 *")
 D ca(.uc," // * Note that you cannot specify incidental overwrites for values   *")
 D ca(.uc," // * to be returned by $$getPslValue().                              *")
 D ca(.uc," // *******************************************************************")
 ;
 N def
 N elm
 N lst
 N ov
 N opt
 N val
 ;
 S def("WARN")=""
 S def("INFO")=""
 S def("OPTIMIZE")=$$allOPTIMIZE^UCGMC()
 S def("Options")=""
 ;
 ; insert lines that specify settings
 F opt="WARN","INFO","OPTIMIZE","Options" D
 .	D ca(.uc," //")
 .	D ca(.uc," // ---- "_(opt_" settings ")_$translate($J("",64-$L((opt_" settings ")))," ","-"))
 .	S lst=$$listSettings^PSLCC(.siteOpts,opt)
 .	I (lst="") D
 ..		D ca(.uc," // None specified, using PSL defaults")
 ..		S ov=def(opt)
 ..		Q 
 .	E  D
 ..		S (ov,val)=""
 ..		F elm=1:1:$S((lst=""):0,1:$L(lst,",")) D
 ...			S val=$piece(lst,",",elm)
 ...			I '$$getSetting^PSLCC(.siteOpts,opt,val) Q 
 ...			I (ov="") S ov=val Q 
 ...			S ov=ov_","_val
 ...			Q 
 ..		Q 
 .	;
 .	D ca(.uc," set Options("_$S(opt'["""":""""_opt_"""",1:$$QADD^%ZS(opt,""""))_") = "_$S(ov'["""":""""_ov_"""",1:$$QADD^%ZS(ov,"""")))
 .	Q 
 ;
 ; #PSL compiler command
 N cmt
 S opt="PSL"
 D ca(.uc," //")
 D ca(.uc," // ----  "_(opt_" settings ")_$translate($J("",64-$L((opt_" settings ")))," ","-"))
 ;
 ; #PSL XyzMask String (default "")
 F val="BooleanMask","DateMask","TimeMask" D
 .	I '$$hasSetting^PSLCC(.siteOpts,opt,val) D
 ..		S ov="" S cmt=" // defer to DBCTLDVFM.MSK at compile time"
 ..		Q 
 .	E  S ov=$$getSetting^PSLCC(.siteOpts,opt,val) S cmt=""
 .	D ca(.uc," set Options("_$S(opt'["""":""""_opt_"""",1:$$QADD^%ZS(opt,""""))_","_$S(val'["""":""""_val_"""",1:$$QADD^%ZS(val,""""))_") = "_$S(ov'["""":""""_ov_"""",1:$$QADD^%ZS(ov,""""))_cmt)
 .	Q 
 ;
 ; #PSL CompileSummary String (default true)
 S val="CompileSummary"
 I '$$hasSetting^PSLCC(.siteOpts,opt,"CompileSummary") D
 .	S ov=1 S cmt=" // using compiler default"
 .	Q 
 E  S ov=$$getSetting^PSLCC(.siteOpts,opt,"CompileSummary") S cmt=""
 D ca(.uc," set Options("_$S(opt'["""":""""_opt_"""",1:$$QADD^%ZS(opt,""""))_","_"""CompileSummary"""_") = "_$S(ov=1:"true",1:"false")_cmt)
 ;
 ; #PSL Version Number (default current compiler version)
 S val="Version"
 I '$$hasSetting^PSLCC(.siteOpts,opt,"Version") D
 .	S ov=$$getPSLVersion^PSLC() S cmt=" // using current compiler version"
 .	Q 
 E  S ov=$$getSetting^PSLCC(.siteOpts,opt,val) S cmt=""
 D ca(.uc," set Options("_$S(opt'["""":""""_opt_"""",1:$$QADD^%ZS(opt,""""))_","_$S(val'["""":""""_val_"""",1:$$QADD^%ZS(val,""""))_") = "_ov_cmt)
 ;
 ; end of #xyz sections
 D ca(.uc," quit")
 ;
 ; add $$charsetName()
 D ca(.uc,"")
 D ca(.uc," // *******************************************************************")
 D ca(.uc,"private charsetName() // return current character set as runtime value")
 D ca(.uc," quit Runtime.charsetName")
 ;
 ; add $$getPslValue()
 N objdef
 N propID S propID="PSL."
 N propName
 N pslProp  D vcdmNew^PSLX(.pslProp,"PSLX","PSL")
 N propDes S propDes=$$vcdmNew^PSLProperty("PSLProperty")
 N rtn
 ;
 D extract^PSLX(.pslProp)
 ;
 D ca(.uc,"")
 D ca(.uc," // *******************************************************************")
 D ca(.uc,"private getPslValue( String property) // return value of PSL.xxxYyyZzz property")
 ;
 D ca(.uc," // ---- PSL.maxCharValue ----")
 D ca(.uc," // This value indicates the maximum value that is allowed in $CHAR().")
 D ca(.uc," // The value depends on the GT.M version and if the GT.M version")
 D ca(.uc," // supports Unicode it also depends on the setting of $ZCHSET.")
 D ca(.uc," // Note that GT.M treats 0x10FFFF and 0x10FFFE as unmapped characters.")
 D ca(.uc," //")
 D ca(.uc," #IF $$rtChset^UCBYTSTR()=""UTF-8""")
 D ca(.uc," if property = ""maxCharValue"" quit 1114109")
 D ca(.uc," #ELSE")
 D ca(.uc," if property = ""maxCharValue"" quit 255")
 D ca(.uc," #END")
 ;
 D ca(.uc," //")
 D ca(.uc," // ---- PSL.maxLineLength ----")
 D ca(.uc," // This value indicates the split value that will be used to determine")
 D ca(.uc," // if a line of M code must be split over multiple lines.")
 D ca(.uc," // For example, assigning a constant with a length close to")
 D ca(.uc," // PSL.maxStringLength to a variable requires multiple lines:")
 D ca(.uc," //     set var = ""FIRST PIECE""")
 D ca(.uc," //     set var = var_""SECOND PIECE""")
 D ca(.uc," // The value leaves room for additional characters such as the")
 D ca(.uc," //     'set var = var_'")
 D ca(.uc," // in the example above.")
 D ca(.uc," //")
 D ca(.uc," #IF $$gtmLevel^UCGM(4)")
 D ca(.uc," if property = ""maxLineLength"" quit 1980")
 D ca(.uc," #ELSE")
 D ca(.uc," if property = ""maxLineLength"" quit 450")
 D ca(.uc," #END")
 ;
 D ca(.uc," //")
 D ca(.uc," // ---- PSL.maxLitLength ----")
 D ca(.uc," // The PSL compiler will try to generate code that uses literal values")
 D ca(.uc," // whenever possible. To prevent the construction of lines that exceed")
 D ca(.uc," // PSL.maxLineLength when multiple long literals occur, the maximum")
 D ca(.uc," // length of such a literal will be limited to PSL.maxLineLength / 4")
 D ca(.uc," //")
 D ca(.uc," #IF $$gtmLevel^UCGM(4)")
 D ca(.uc," if property = ""maxLitLength"" quit 511")
 D ca(.uc," #ELSE")
 D ca(.uc," if property = ""maxLitLength"" quit 255")
 D ca(.uc," #END")
 ;
 D ca(.uc," //")
 D ca(.uc," // ---- PSL.maxNameLength ----")
 D ca(.uc," // This value indicates how many characters are allowed in names.")
 D ca(.uc," // The value applies to names of")
 D ca(.uc," // - local variables (error)")
 D ca(.uc," // - labels (info)")
 D ca(.uc," // - routines (info)")
 D ca(.uc," // The compiler will issue a LENGTH error or information message")
 D ca(.uc," //  when the length of a name exceeds this value")
 D ca(.uc," //")
 D ca(.uc," #IF $$gtmLevel^UCGM(5)")
 D ca(.uc," if property = ""maxNameLength"" quit 31")
 D ca(.uc," #ELSE")
 D ca(.uc," if property = ""maxNameLength"" quit 8")
 D ca(.uc," #END")
 ;
 D ca(.uc," //")
 D ca(.uc," // ---- PSL.maxStringLength ----")
 D ca(.uc," // This value indicates the maximum length that is assumed for local")
 D ca(.uc," // variables. You can use this constant in constructs like")
 D ca(.uc," // String.extract(first,PSL.maxStringLength)")
 D ca(.uc," //")
 D ca(.uc," #IF $$gtmLevel^UCGM(""4.4-004"")")
 D ca(.uc," if property = ""maxStringLength"" quit 1048575")
 D ca(.uc," #ELSE")
 D ca(.uc," if property = ""maxStringLength"" quit 32767")
 D ca(.uc," #END")
 ;
 D ca(.uc," //")
 D ca(.uc," // ---- supplied by UCOPTS.ini ----")
 ;
 F  S propID=$order(pslProp("pslPrp",propID)) Q:$E(propID,1,4)'="PSL."  D
 .	S propName=$E(propID,5,1048575)
 .	I (",maxCharValue,maxLineLength,maxLitLength,maxNameLength,maxStringLength,"[(","_propName_",")) Q  ; not for change
 .	;
 .	S propDes=$$getPSLProperty^PSLCC(.pslProp,propID)
 .	S rtn=$P(propDes,$C(9),10)
 .	I rtn'["getPslValue^UCMETHOD(" Q  ; not a PSL value
 .	;
 .	S objdef=$E(rtn,22,$L(rtn)-1)
 .	S val=$$getSetting^PSLCC(.siteOpts,"DEFINE",propName,objdef)
 .	I '(val=+val) S val=$S(val'["""":""""_val_"""",1:$$QADD^%ZS(val,""""))
 .	D ca(.uc," //")
 .	D ca(.uc," if property = "_$S(propName'["""":""""_propName_"""",1:$$QADD^%ZS(propName,""""))_" quit "_val)
 .	Q 
 D ca(.uc," quit """"")
 ;
 ; generate M routine, using boot restrictionlevel = 3
 N bo
 N cfe
 ;
 D getBootOptions(.bo,3) ; compile with boot restrictionlevel=3
 ;
 S cfe=$$cmpA2F^PSLC(.uc,.bo,"UCOPTS",,"UCOPTS.ini~file")
 ;
 Q 
 ;
 ; ---------------------------------------------------------------------
ca(src,cod) ; Append cod to src()
 S src($order(src(""),-1)+1)=cod
 Q 
 ;
 ; ---------------------------------------------------------------------
date(vStr,vMsk) ; boot-safe String to Date conversion
 N $ET,$ES,$ZYER S $ZYER="ZE^UCGMR",$ZE="",$EC="",$ET="D:$TL>"_$TL_" rollback^vRuntime("_$TL_") Q:$Q&$ES """" Q:$ES  N voxMrk s voxMrk="_+$O(vobj(""),-1)_" G vCatch1^"_$T(+0)
 ;
 Q $$vStrJD(vStr,vMsk)
 ;
 ; ---------------------------------------------------------------------
getBootData(bo) ; boot option array
 ;
 I '($D(bo("boot","datadirectory"))#2) Q 
 ;
 N tbl S tbl="CUVAR"
 ;  #ACCEPT CR=27800;DATE=2007-12-06;PGM=Frans S.C. Witte;GROUP=ACCESS,DEPRECATED
 N ptr S ptr=+$$getBootRws($$SCAU^%TRNLNM("DIR"),tbl_".DAT")
 I ptr'=0 S bo("boot",tbl)=ptr
 ;
 F tbl="STBLSYSKEYWD","STBLPSLFUNSUB" D
 .	;   #ACCEPT CR=27800;DATE=2007-12-06;PGM=Frans S.C. Witte;GROUP=DEPRECATED
 .	S ptr=+$$getBootRws(bo("boot","datadirectory"),tbl_".DAT")
 .	I ptr'=0 S bo("boot",tbl)=ptr
 .	Q 
 Q 
 ;
 ; ---------------------------------------------------------------------
getBootOptions(bo,lvl) ; get the boot options for the specified boot level
 S bo("boot","restrictionlevel")=lvl
 S bo("Options","nolink")=1
 S bo("OPTIMIZE","FUNCTIONS")=0
 ;
 I lvl=3 D  ; Force #PSL section for restrictionlevel 3
 .	S bo("PSL","BooleanMask")="+,-"
 .	S bo("PSL","CompileSummary")=1
 .	S bo("PSL","DateMask")="YEAR-MM-DD"
 .	S bo("PSL","TimeMask")="24:60:SS"
 .	S bo("PSL","Version")=$$getPSLVersion^PSLC()
 .	Q 
 ;
 Q 
 ;
 ; ---------------------------------------------------------------------
getBootRws(dir,file) ; 
 N rws S rws=$$vRwsNew($ST,"",$C(9))
 D
 .	N $ET,$ES,$ZYER S $ZYER="ZE^UCGMR",$ZE="",$EC="",$ET="D:$TL>"_$TL_" rollback^vRuntime("_$TL_") Q:$Q&$ES """" Q:$ES  N voxMrk s voxMrk="_+$O(vobj(""),-1)_" G vCatch2^"_$T(+0)  ; ignore rws.loadFromFile() exception
 .	D vRwsLFF(rws,dir,file,1)
 .	Q 
 I ($O(vobj(rws,""),-1)=0) K vobj(+$G(rws)) Q 0
 Q rws
 ;
 ; ---------------------------------------------------------------------
getGroup(sRtn) ; Return the PSL compiler group to which the routine belongs
 N sGrp
 F sGrp="Insensitive","Dictionary","Upgrade","Data" I ((","_$$getList(sGrp)_",")[(","_sRtn_",")) Q 
 E  S sGrp=""
 Q sGrp
 ;
 ; ---------------------------------------------------------------------
getCapabilities(sSec) ; Return List of capabilities that is supported by this version of PSL
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 I sSec="FUNCTIONS" Q $$initFcts^UCGM()
 I sSec="CLASSES" Q $$getCls("intrinsic")
 I sSec'="KEYWORDS" Q ""
 ;
 N acmd
 N cmd S cmd=""
 N cmdl S cmdl=""
 ;
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 D initCmds^UCGM(.acmd)
 ;
 F  S cmd=$order(acmd(cmd)) Q:(cmd="")  S cmdl=$S((cmdl=""):$ZCONVERT(cmd,"L"),1:cmdl_","_$ZCONVERT(cmd,"L"))
 Q cmdl_","_"literal,private,public,void,final,protected,ret,static"_","_"#ACCEPT,#BREAK,#BYPASS,#ELSE,#END,#ENDIF,#IF,#OPTIMIZE,#WARN,#WHILE,#XECUTE,#INFO,#OPTION,#CLASSDEF,#PACKAGE,#PROPERTYDEF"
 ;
 ; ---------------------------------------------------------------------
getCls(sGrp) ; Return a List of all PSL Intrinsic Classes in the requested group
 ;
 I sGrp="intrinsic" Q "Boolean,ByteString,Cache,Class,Column,Date,Db,DbSet,Error,Integer,IO,List,Memo,Number,Object,Primitive,Record,Reference,ResultSet,Row,SchemaTable,String,Time,PSL,PSLBuffer,PSLColumn,PSLExpression,PSLIdentifier,PSLSubrou,PSLTable,PSLCC,PSLClass,PSLMethod,PSLParser,PSLProperty,PSLTokenizer,PSLX"
 I sGrp="cdm" Q "PSLCC,PSLClass,PSLMethod,PSLParser,PSLProperty,PSLTokenizer,PSLX"
 I sGrp="pslx" Q "Boolean,ByteString,Cache,Class,Column,Date,Db,DbSet,Error,Integer,IO,List,Memo,Number,Object,Primitive,Record,Reference,ResultSet,Row,SchemaTable,String,Time,PSL,PSLBuffer,PSLColumn,PSLExpression,PSLIdentifier,PSLSubrou,PSLTable"
 I sGrp="table" Q "HTML,Schema,TranSet"
 Q ""
 ;
 ; ---------------------------------------------------------------------
isClsCDM(cls) ; 
 Q ((","_$$getCls("cdm")_",")[(","_cls_","))
isClsIntrinsic(cls) ; 
 Q ((","_$$getCls("intrinsic")_",")[(","_cls_","))
isClsPslx(cls) ; 
 Q ((","_$$getCls("pslx")_",")[(","_cls_","))
isClsTable(cls) ; 
 Q ((","_$$getCls("table")_",")[(","_cls_","))
 ;
 ; ---------------------------------------------------------------------
getList(sGrp) ; Return List of PSL compiler routines in specifed group
 ;
 I sGrp="Compiler" Q "UCDBSET,UCERROR,UCGMR,UCIO,UCLIST,UCMEMO,UCMETHOD,UCNUMBER,UCPATCH,UCREF,UCRESULT,UCROW,UCRUNTIM,UCSTAT,UCSTRING,UCTS,UCUTILN,SQLA,SQLAGFUN,SQLBLOB,SQLF,SQLFILER,SQLFUNCS,SQLG,SQLQ,UCCOLSF,UCDBR,UCGMCU,UCIO0,UCPSLSR,UCPSLST,UCREC4OP,UCROWSET,UCTIME,%CHARSET,%DBAPI,%ZM,%ZOPEN,PSLC,PSLCC,PSLClass,PSLMethod,PSLParser,PSLProperty,PSLTokenizer,PSLX,UCGMC,UCGMCONV,UCOBJECT,UCPRIM,UCXOBJ,vNumber,vResultSet,vRuntime,UCCLASS,UCCOLUMN,UCDB,UCGM,UCHTML,UCQRYBLD,UCRECORD,UCUTIL,SQL,SQLCACHE,SQLCMP,SQLCOL,SQLCONV,SQLCRE,SQLDD,SQLJ,SQLM,SQLO,SQLODBC,SQLPROT,SQLTBL,UCDBRT,UCXDD,UCXDT25,DBMAP,DBSDBASE,DBSDF9,DBSDS,DBSDYNRA,DBSMACRO,DBSMEMO,DBSVER,UCSCHEMA,UCOPTS,UCBYTSTR,SQLUTL,UCDATE,UCDTAUTL,DBSDD,DBSDI,UCXCUVAR,UCDTASYS,SQLBUF,UCLREGEN,UCSYSMAP,SQLEFD"
 I sGrp="Data" Q "UCOPTS,UCBYTSTR,SQLUTL,UCDATE,UCDTAUTL,DBSDD,DBSDI,UCXCUVAR,UCDTASYS,SQLBUF,UCLREGEN,UCSYSMAP,SQLEFD"
 I sGrp="Dictionary" Q "UCCLASS,UCCOLUMN,UCDB,UCGM,UCHTML,UCQRYBLD,UCRECORD,UCUTIL,SQL,SQLCACHE,SQLCMP,SQLCOL,SQLCONV,SQLCRE,SQLDD,SQLJ,SQLM,SQLO,SQLODBC,SQLPROT,SQLTBL,UCDBRT,UCXDD,UCXDT25,DBMAP,DBSDBASE,DBSDF9,DBSDS,DBSDYNRA,DBSMACRO,DBSMEMO,DBSVER,UCSCHEMA"
 I sGrp="Filer" Q "DBTBL1,DBTBL1D,DBTBL1F,DBTBL7,DBTBL7D,DBTBL8,DBTBL9,DBTBL9D,DBUTARCHIVE,DBAUDITDEF,DBMAP,DBMAPT,DBMAPIDX,CUVAR,DBSPID,DBTBL0,DBTBL1TBLDOC,DBTBL2,DBTBL2D,DBTBL2PP,DBTBL4,DBTBL4D,DBTBL5D,DBTBL5D1,DBTBL5DGC,DBTBL5H,DBTBL5PR,DBTBL5Q,DBTBL5SQ,DBTBL12,DBTBL13,DBTBL13D,DBTBL14,DBTBL14Q,DBTBL22,DBTBL22C,DBTBL22R,DBTBL25,DBTBL25D,DBTBL33,DBTBL33D,DBACCRTS,DBSFUNC,DBSFUNCUCLS,DBSUCLS,DBSUSER,LOG,LOG1,MPROF,MPROF0,OBJECT,OBJECTMET,OBJECTPROP,SQLCACHE,SQLCUR,SQLFUNC,STBLJRNFUNC,STBLMTBLS,STBLPSLFUNSUB,STBLRESERVED,STBLSYSKEYWD,SYSMAPCALLS,SYSMAPCOMMANDS,SYSMAPLABELS,SYSMAPLITDTA,SYSMAPLITFNC,SYSMAPM,SYSMAPMPROPS,SYSMAPPROPDATA,SYSMAPRTNS,SYSMAPVAR,TMPDQ,UCLREGEN,TMPDQ"
 I sGrp="FilerB" Q "DBTBL1,DBTBL1D,DBTBL1F,DBTBL7,DBTBL7D,DBTBL8,DBTBL9,DBTBL9D,DBUTARCHIVE,DBAUDITDEF,DBMAP,DBMAPT,DBMAPIDX"
 I sGrp="FilerE" Q "CUVAR,DBSPID,DBTBL0,DBTBL1TBLDOC,DBTBL2,DBTBL2D,DBTBL2PP,DBTBL4,DBTBL4D,DBTBL5D,DBTBL5D1,DBTBL5DGC,DBTBL5H,DBTBL5PR,DBTBL5Q,DBTBL5SQ,DBTBL12,DBTBL13,DBTBL13D,DBTBL14,DBTBL14Q,DBTBL22,DBTBL22C,DBTBL22R,DBTBL25,DBTBL25D,DBTBL33,DBTBL33D,DBACCRTS,DBSFUNC,DBSFUNCUCLS,DBSUCLS,DBSUSER,LOG,LOG1,MPROF,MPROF0,OBJECT,OBJECTMET,OBJECTPROP,SQLCACHE,SQLCUR,SQLFUNC,STBLJRNFUNC,STBLMTBLS,STBLPSLFUNSUB,STBLRESERVED,STBLSYSKEYWD,SYSMAPCALLS,SYSMAPCOMMANDS,SYSMAPLABELS,SYSMAPLITDTA,SYSMAPLITFNC,SYSMAPM,SYSMAPMPROPS,SYSMAPPROPDATA,SYSMAPRTNS,SYSMAPVAR,TMPDQ,UCLREGEN,TMPDQ"
 I sGrp="FilerPrep" Q "DBTBL1,DBTBL1D,DBMAP,DBMAPT,DBMAPIDX"
 I sGrp="ForcePrep" Q "TBXDQINT,DBARCHIVE,SQLAUDIT"
 I sGrp="Insensitive" Q "UCDBSET,UCERROR,UCGMR,UCIO,UCLIST,UCMEMO,UCMETHOD,UCNUMBER,UCPATCH,UCREF,UCRESULT,UCROW,UCRUNTIM,UCSTAT,UCSTRING,UCTS,UCUTILN,SQLA,SQLAGFUN,SQLBLOB,SQLF,SQLFILER,SQLFUNCS,SQLG,SQLQ,UCCOLSF,UCDBR,UCGMCU,UCIO0,UCPSLSR,UCPSLST,UCREC4OP,UCROWSET,UCTIME,%CHARSET,%DBAPI,%ZM,%ZOPEN,PSLC,PSLCC,PSLClass,PSLMethod,PSLParser,PSLProperty,PSLTokenizer,PSLX,UCGMC,UCGMCONV,UCOBJECT,UCPRIM,UCXOBJ,vNumber,vResultSet,vRuntime"
 I sGrp="Phase2" Q "PSLRecordBuilder,DBARCHIVE,SQLAUDIT,DBS2PSL,DBS2PSL0,DBS2PSL1,DBS2PSL3,DBS2PSL4,DBS2PSL5,DBSBCH,DBSCMPF,DBSCRT8,DBSDB,DBSDF,DBSDRV,DBSDSMC,DBSDSMP,DBSEDIT,DBSEDT,DBSEXECU,DBSEXEP,DBSFILB,DBSFILER,DBSGETID,DBSINDXZ,DBSINT,DBSLINK,DBSLOD,DBSLOG,DBSLOGIT,DBSMBAR,DBSPARS,DBSPARS1,DBSPARS2,DBSPP,DBSPROC,DBSPROT3,DBSPROT4,DBSQRY,DBSREL,DBSRTN,DBSRW,DBSRW2,DBSRW3,DBSRWQRY,DBSRWUTL,DBSSCR,DBSSCR0,DBSSCR1,DBSSCR3,DBSSCR4,DBSSCR5,DBSTBLA,DBSUTL3,SQLAG,USTMAPDF"
 I sGrp="Phase2B" Q "PSLRecordBuilder"
 I sGrp="Phase2E" Q "DBARCHIVE,SQLAUDIT,DBS2PSL,DBS2PSL0,DBS2PSL1,DBS2PSL3,DBS2PSL4,DBS2PSL5,DBSBCH,DBSCMPF,DBSCRT8,DBSDB,DBSDF,DBSDRV,DBSDSMC,DBSDSMP,DBSEDIT,DBSEDT,DBSEXECU,DBSEXEP,DBSFILB,DBSFILER,DBSGETID,DBSINDXZ,DBSINT,DBSLINK,DBSLOD,DBSLOG,DBSLOGIT,DBSMBAR,DBSPARS,DBSPARS1,DBSPARS2,DBSPP,DBSPROC,DBSPROT3,DBSPROT4,DBSQRY,DBSREL,DBSRTN,DBSRW,DBSRW2,DBSRW3,DBSRWQRY,DBSRWUTL,DBSSCR,DBSSCR0,DBSSCR1,DBSSCR3,DBSSCR4,DBSSCR5,DBSTBLA,DBSUTL3,SQLAG,USTMAPDF"
 I sGrp="Upgrade" Q "UCBYTSTR,UCDATE,UCDTAUTL,UCXCUVAR,SQLUTL,DBSDD,DBSDI"
 Q ""
 ;
 ; ---------------------------------------------------------------------
getComList() ; 
 Q $$getList("Compiler")
getDatList() ; 
 Q $$getList("Data")
getDicList() ; 
 Q $$getList("Dictionary")
getFilerList() ; 
 Q $$getList("Filer")
getFilerPrepList() ; 
 Q $$getList("FilerPrep")
getInsList() ; 
 Q $$getList("Insensitive")
getPhase2List() ; 
 Q $$getList("Phase2")
getUpgList() ; 
 Q $$getList("Upgrade")
 ;
 ; ---------------------------------------------------------------------
info(info) ; 
 N prsr  D vcdmNew^PSLParser(.prsr,"PSLParser",$T(+0))
 D log^PSLParser(.prsr,,0," ",1,"LIST",info)
 Q 
 ;
 ; ---------------------------------------------------------------------
isGroup(grp,rtn) ; Is routine part of the specified PSL compiler group
 Q ((","_$$getList(grp)_",")[(","_rtn_","))
 ;
 ; ---------------------------------------------------------------------
isCompiler(rtn) ; 
 Q $$isGroup("Compiler",rtn)
isData(rtn) ; 
 Q $$isGroup("Data",rtn)
isDictionary(rtn) ; 
 Q $$isGroup("Dictionary",rtn)
isInsensitive(rtn) ; 
 Q $$isGroup("Insensitive",rtn)
isUpgrade(rtn) ; 
 Q $$isGroup("Upgrade",rtn)
 ;
 ; ---------------------------------------------------------------------
linkAll() ; 
 D linkList($$getComList())
 Q 
 ;
 ; ---------------------------------------------------------------------
linkPreBoot() ; 
 D linkList($$getList("Insensitive"))
 D linkList($$getList("Dictionary"))
 D linkList($$getList("Object"))
 D linkList($$getList("Upgrade"))
 Q 
 ;
 ; ---------------------------------------------------------------------
linkList(link) ; 
 N i
 ;
 F i=1:1:$S((link=""):0,1:$L(link,",")) D
 .	N rtn S rtn=$translate($piece(link,",",i),"%","_")
 .	;   #ACCEPT CR=11441; DATE=11/23/04; PGM=FSCW
 .	;*** Start of code by-passed by compiler
 .	if rtn'=$TEXT(+0) ZLINK rtn
 .	;*** End of code by-passed by compiler ***
 .	Q 
 Q 
 ;
 ; ---------------------------------------------------------------------
prep(vRtnDir,vGtmLvl,vChrLvl) ; prepare a bootable version of PSL/SQL/DB for specified target environment
 ;
 D linkAll() ; Ensure an up-to-date image
 ;
 ; Boot the remainder of the PSL compiler, SQL engine, and DBS kernel
 N co ; compiler options
 N comList S comList=$$getList("Compiler")
 N filerPrepList S filerPrepList=$$getList("FilerPrep")
 N forcePrepList S forcePrepList=$$getList("ForcePrep")
 N elm
 ;
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 N dir S dir=$$SCAU^%TRNLNM("DIR")
 N ign
 N io S io=$$vClVobj($ST,"IO")
 N pck S pck=$$packageDirs^PSLC("","")
 N unt
 ;
 I '($get(vRtnDir)="") S co("boot","rtndirectory")=vRtnDir
 ;
 ; adjust gtmlevel if needed
 I ($get(vGtmLvl)="") D
 .	;   #ACCEPT CR=none; Date=2008-01-23; PGM=Frans S.C. Witte;GROUP=BYPASS
 .	;*** Start of code by-passed by compiler
 .	IF $PIECE($ZVERSION,"GT.M V",2)>5.1 SET co("boot","gtmlevel")=5.1
 .	;*** End of code by-passed by compiler ***
 .	Q 
 E  S co("boot","gtmlevel")=vGtmLvl
 ;
 S co("boot","charsetlevel")=$get(vChrLvl) ; unconditionally!
 ;
 D getBootOptions(.co,-1) ; prepare uses boot restrictionlevel=-1
 ;
 N ucopts S ucopts=$$toUcopts^PSLC("","",.co)
 ;
 F elm=1:1:$S((comList=""):0,1:$L(comList,",")) D
 .	S unt=$piece(comList,",",elm)
 .	;
 .	I $$getGroup(unt)="Data" D  ; Data units must be copied here
 ..		I unt="UCOPTS" Q  ; but ignore UCOPTS completely
 ..		I '$$locate^UCIO(io,pck,":",unt_".psl",0) D
 ...			D info("failed to copy "_unt_".psl")
 ...			Q 
 ..		;    #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 ..		E  S ign=$$COPYFIL^%OSSCRPT($P(vobj(io,1),"|",2)_unt_".psl",vRtnDir)
 ..		Q 
 .	E  D  ; units from other groups go through prepCmp()
 ..		N $ET,$ES,$ZYER S $ZYER="ZE^UCGMR",$ZE="",$EC="",$ET="D:$TL>"_$TL_" rollback^vRuntime("_$TL_") Q:$Q&$ES """" Q:$ES  N voxMrk s voxMrk="_+$O(vobj(""),-1)_" G vCatch3^"_$T(+0)
 ..		D prepCmp(unt,.co,ucopts)
 ..		D info("prepared "_unt)
 ..		Q 
 .	Q 
 ;
 F elm=1:1:$S((filerPrepList=""):0,1:$L(filerPrepList,",")) D
 .	S unt="Record"_$piece(filerPrepList,",",elm)
 .	;
 .	N $ET,$ES,$ZYER S $ZYER="ZE^UCGMR",$ZE="",$EC="",$ET="D:$TL>"_$TL_" rollback^vRuntime("_$TL_") Q:$Q&$ES """" Q:$ES  N voxMrk s voxMrk="_+$O(vobj(""),-1)_" G vCatch4^"_$T(+0)
 .	D prepCmp(unt,.co,ucopts)
 .	D info("prepared "_unt)
 .	Q 
 ;
 F elm=1:1:$S((forcePrepList=""):0,1:$L(forcePrepList,",")) D
 .	S unt=$piece(forcePrepList,",",elm)
 .	;
 .	N $ET,$ES,$ZYER S $ZYER="ZE^UCGMR",$ZE="",$EC="",$ET="D:$TL>"_$TL_" rollback^vRuntime("_$TL_") Q:$Q&$ES """" Q:$ES  N voxMrk s voxMrk="_+$O(vobj(""),-1)_" G vCatch5^"_$T(+0)
 .	D prepCmp(unt,.co,ucopts)
 .	D info("prepared "_unt)
 .	Q 
 ;
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 S ign=$$DELETE^%OSSCRPT(ucopts)
 ;
 ; Include .pslx files of Intrinsic Classes in group "pslx"
 N pslxList S pslxList=$$getCls("pslx")
 S dir=$piece($$packageDirs^PSLC("","framework"),":")
 F elm=1:1:$S((pslxList=""):0,1:$L(pslxList,",")) D
 .	S unt=$piece(pslxList,",",elm)
 .	;
 .	;   #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 .	S ign=$$COPYFIL^%OSSCRPT(dir_"/"_unt_".pslx",vRtnDir)
 .	D info("copied "_unt)
 .	Q 
 K vobj(+$G(io)) Q 
 ;
 ; ---------------------------------------------------------------------
prepCmp(unit,cco,ucopts) ; prepare single unit
 N rIo S rIo=$$vClVobj($ST,"IO")
 N dir
 N pck S pck=$$packageDirs^PSLC("","")
 ;
 I '($D(cco("boot","rtndirectory"))#2) S $ZE="0,"_$ZPOS_","_"%PSL-E-PREPARE,missing output directory",$EC=",U1001,"
 ;
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 F dir="CRTNS","MRTNS","PRTNS" I cco("boot","rtndirectory")=$$SCAU^%TRNLNM(dir) S $ZE="0,"_$ZPOS_","_"%PSE-E-PREPARE,cannot use reserved directory,$SCAU_"_dir,$EC=",U1001,"
 I ((":"_pck_":")[(":"_cco("boot","rtndirectory")_":")) S $ZE="0,"_$ZPOS_","_"%PSE-E-PREPARE,cannot use reserved directory,$SCAU_PACKAGES",$EC=",U1001,"
 ;
 I $$isRecord^PSLClass(unit) D  ; RecordTABLE
 .	N err
 .	;
 .	S err=$$run^PSLC("--element="_unit_" --ucopts="_ucopts_" --targetdir="_cco("boot","rtndirectory")_" "_unit)
 .	I err>0 S $ZE="0,"_$ZPOS_","_"%PSL-E-PREPARE,compilation failure(s)",$EC=",U1001,"
 .	;
 .	;   #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 .	S err=$$DELETE^%OSSCRPT(cco("boot","rtndirectory")_"/"_$translate(unit,"%","_")_".o")
 .	Q 
 E  I $$isProc^UCXDT25(unit) D  ; DQ Procedure
 .	N err
 .	I '$$locate^UCIO(rIo,pck,":",unit_".psl",0) S $ZE="0,"_$ZPOS_","_"%PSL-E-NOTFOUND,failed to copy "_unit_".psl",$EC=",U1001,"
 .	;
 .	;   #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 .	S err=$$COPYFIL^%OSSCRPT($P(vobj(rIo,1),"|",2)_unit_".psl",cco("boot","rtndirectory"))
 .	S err=$$run^PSLC(cco("boot","rtndirectory")_"/"_unit_".psl --element --ucopts="_ucopts)
 .	I err>0 S $ZE="0,"_$ZPOS_","_"%PSL-E-PREPARE,compilation failure(s)",$EC=",U1001,"
 .	;
 .	;   #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 .	S err=$$DELETE^%OSSCRPT(cco("boot","rtndirectory")_"/"_$translate(unit,"%","_")_".o")
 .	Q 
 E  D  ; M Routine
 .	N %ZI N %ZR N dst N mrtn S mrtn=$translate(unit,"%","_")
 .	N src N stamp
 .	N ln
 .	;
 .	S %ZI(unit)=""
 .	;   #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 .	D INT^%RSEL
 .	I '($D(%ZR(unit))#2) S $ZE="0,"_$ZPOS_","_"%PSL-E-PREPARE,routine not found",$EC=",U1001,"
 .	;
 .	S $P(vobj(rIo,1),"|",2)=%ZR(unit)
 .	S $P(vobj(rIo,1),"|",1)=mrtn_".m"
 .	S $P(vobj(rIo,1),"|",3)="READ"
 .	S $P(vobj(rIo,1),"|",5)=1048575
 .	;
 .	D
 ..		N $ET,$ES,$ZYER S $ZYER="ZE^UCGMR",$ZE="",$EC="",$ET="D:$TL>"_$TL_" rollback^vRuntime("_$TL_") Q:$Q&$ES """" Q:$ES  N voxMrk s voxMrk="_+$O(vobj(""),-1)_" G vCatch6^"_$T(+0)
 ..		D open^UCIO(rIo,$T(+0),"prepCmp","rIo")
 ..		;    #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 ..		S stamp=$$FILE^%ZFUNC($P(vobj(rIo,1),"|",6),"CDT")
 ..		F ln=1:1 S dst(ln)=$$read^UCIO(rIo)
 ..		Q 
 .	;
 .	I $order(dst(""))="" Q  ; nothing to write
 .	;
 .	N rOutFile S rOutFile=$$vClVobj($ST,"IO")
 .	S $P(vobj(rOutFile,1),"|",2)=cco("boot","rtndirectory")
 .	S $P(vobj(rOutFile,1),"|",1)=mrtn_".m"
 .	S $P(vobj(rOutFile,1),"|",3)="WRITE/NEWV"
 .	S $P(vobj(rOutFile,1),"|",5)=1048575
 .	;
 .	N $ET,$ES,$ZYER S $ZYER="ZE^UCGMR",$ZE="",$EC="",$ET="D:$TL>"_$TL_" rollback^vRuntime("_$TL_") Q:$Q&$ES """" Q:$ES  N voxMrk s voxMrk="_+$O(vobj(""),-1)_" G vCatch7^"_$T(+0)
 .	;
 .	D open^UCIO(rOutFile,$T(+0),"prepCmp","rOutFile")
 .	N lnr N pos
 .	N txt
 .	S dst(1)=$$MDCFirstLine^UCXDT25($translate(dst(1),$char(9)," "),unit,stamp)
 .	F lnr=1:1:$order(dst(""),-1) D
 ..		S txt=$$RTCHR^%ZFUNC($translate(dst(lnr),$char(9)," ")," ")
 ..		I (txt="") Q 
 ..		S pos=$F(txt," ")
 ..		I pos=0 S txt=txt_" " S pos=$L(txt)+1
 ..		I pos<9 S txt=$E(txt,1,pos-2)_$char(9)_$E(dst(lnr),pos,$L(txt))
 ..		;
 ..		D write^UCIO(rOutFile,txt)
 ..		Q 
 .	D close^UCIO(rOutFile)
 .	K vobj(+$G(rOutFile)) Q 
 K vobj(+$G(rIo)) Q 
 ;
 ; ---------------------------------------------------------------------
prepProc(vUnit,vRtnDir,vGtmLvl,vChrLvl) ; prepare a single module for the specified target enviroment
 ;
 N ign
 ;
 ; If element denotes an Intrinsic Class in group "pslx", just copy .pslx
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 I ((","_$$getCls("pslx")_",")[(","_vUnit_",")) S ign=$$COPYFIL^%OSSCRPT($piece($$packageDirs^PSLC("","framework"),":")_"/"_vUnit_".pslx",vRtnDir) D info("copied "_vUnit) Q 
 ;
 ; Set up for perpare of single unit
 N co ; compiler options
 ;
 I '($get(vRtnDir)="") S co("boot","rtndirectory")=vRtnDir
 I '($get(vGtmLvl)="") S co("boot","gtmlevel")=vGtmLvl
 S co("boot","charsetlevel")=$get(vChrLvl) ; unconditionally!
 ;
 D getBootOptions(.co,-1) ; prepare uses boot restrictionlevel=-1
 ;
 N ucopts S ucopts=$$toUcopts^PSLC("","",.co)
 ;
 D
 .	N $ET,$ES,$ZYER S $ZYER="ZE^UCGMR",$ZE="",$EC="",$ET="D:$TL>"_$TL_" rollback^vRuntime("_$TL_") Q:$Q&$ES """" Q:$ES  N voxMrk s voxMrk="_+$O(vobj(""),-1)_" G vCatch8^"_$T(+0)
 .	D prepCmp(vUnit,.co,ucopts)
 .	D info("prepared "_vUnit)
 .	Q 
 ;
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 S ign=$$DELETE^%OSSCRPT(ucopts)
 Q 
 ;
 ; ---------------------------------------------------------------------
prepUCOPTS(file,cs) ; create ucopts override file for prep* calls
 Q:'$D(cs) 
 ;
 N rIO S rIO=$$vClVobj($ST,"IO")
 S $P(vobj(rIO,1),"|",1)=file S $P(vobj(rIO,1),"|",3)="NEWVERSION"
 D open^UCIO(rIO,$T(+0),"prepUCOPTS","rIO")
 N l1 S l1="" N l2 S l2="" N val
 ;
 F  S l1=$order(cs(l1)) Q:(l1="")  D
 .	F  S l2=$order(cs(l1,l2)) Q:(l2="")  D
 ..		I l1="Options" D write^UCIO(rIO," #OPTION "_l2_" "_cs(l1,l2)) Q 
 ..		I (",OPTIMIZE,WARN,INFO,"[(","_l1_",")) D write^UCIO(rIO," #"_l1_" "_l2_" "_cs(l1,l2)) Q 
 ..		S val=cs(l1,l2)
 ..		D write^UCIO(rIO," #DEFINE "_l1_"."_l2_" "_$S((val=+val):val,1:$S(val'["""":""""_val_"""",1:$$QADD^%ZS(val,""""))))
 ..		Q 
 .	Q 
 D close^UCIO(rIO)
 ;
 K vobj(+$G(rIO)) Q 
 ;
 ; ---------------------------------------------------------------------
time(vStr) ; boot-safe String to Time conversion
 Q $$vStrTM(vStr)
 ;  #OPTION ResultClass ON
vSIG() ; 
 Q "61530^32515^Frans S.C. Witte^84080" ; Signature - LTD^TIME^USER^SIZE
 ; ----------------
 ;  #OPTION ResultClass 1
vStrJD(string,mask) ; String.toDate
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 I (string="") Q ""
 ;
 N m N d N y
 ;
 S d=$F(mask,"DD")
 S m=$F(mask,"MM")
 I string?5N Q string
 I '(m&d) Q $$^SCAJD(string,mask)
 S m=$E(string,m-2,m-1) S d=$E(string,d-2,d-1)
 I (m?1.N)'&(d?1.N) Q $$^SCAJD(string,mask)
 ;
 S y=$F(mask,"YEAR")
 I y S y=$E(string,y-4,y-1)
 E  S y=$F(mask,"YY") I y S y=$E(string,y-2,y-1)
 E  Q $$^SCAJD(string,mask)
 ;
 I m<1!(m>12) Q -1
 I y<100 S y=y+$S(y>50:1900,1:2000)
 I (y#4=0)&('(y#100=0)!(y#400=0)) S m=$piece("0,31,60,91,121,152,182,213,244,274,305,335,366",",",m,m+1)
 E  S m=$piece("0,31,59,90,120,151,181,212,243,273,304,334,365",",",m,m+1)
 I $piece(m,",",2)-$piece(m,",",1)<d Q -1
 S d=d+$piece(m,",",1)+((y-1841)*365)
 S d=d+((y-1841)\4)
 S d=d-(((y-1)\100)-18)
 S d=d+(((y-1)\400)-4)
 Q d
 ; ----------------
 ;  #OPTION ResultClass 1
vRwsLFF(vOid,vDir,vFil,vTyp) ; RowSet.loadFromFile
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 N vIO S vIO=$$vClVobj($ST,"IO")
 S $P(vobj(vIO,1),"|",2)=vDir
 S $P(vobj(vIO,1),"|",1)=vFil
 S $P(vobj(vIO,1),"|",3)="READ"
 S $P(vobj(vIO,1),"|",5)=32767
 D open^UCIO(vIO,$T(+0),"vRwsLFF","vIO")
 N vEr
 N vPtr S vPtr=1
 I vTyp=1 D
 .	S vobj(vOid,-3)=$char(9)
 .	S vobj(vOid,-2)=$translate($$^%ZREAD($P(vobj(vIO,1),"|",6),.vEr),$char(9)_$char(10)_$char(13),",")
 .	F vPtr=1:1 S vobj(vOid,vPtr)=$translate($$^%ZREAD($P(vobj(vIO,1),"|",6),.vEr),$char(10)_$char(13)) I vEr Q 
 .	Q 
 K vobj(vOid,vPtr) S vobj(vOid,0)=0
 F  S vPtr=$order(vobj(vOid,vPtr)) Q:vPtr=""  K vobj(vOid,vPtr)
 D close^UCIO(vIO)
 K vobj(+$G(vIO)) Q 
 ; ----------------
 ;  #OPTION ResultClass 1
vStrTM(object) ; String.toTime
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 I (object="") Q ""
 I object["P",object<12 S $piece(object,":",1)=$piece(object,":",1)+12
 E  I object["A",$piece(object,":",1)=12 S $piece(object,":",1)=0
 I object["-"!($piece(object,":",1)>23)!($piece(object,":",2)>59)!($piece(object,":",3)>59) Q ""
 Q $piece(object,":",1)*60+$piece(object,":",2)*60+$piece(object,":",3)
 ;
vClVobj(vSt,vCls) ; Create a new object
 ;
 N vOid
 S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)=vCls_$C(9)_vSt
 Q vOid
 ;
vRwsNew(vS,vCol,vDel) ; new RowSet
 ;
 N vOid S vOid=$$vClVobj(vS,"RowSet")
 S vobj(vOid,0)=0
 S vobj(vOid,-2)=vCol
 S vobj(vOid,-3)=vDel
 Q vOid
 ;
vCatch8 ; Error trap
 ;
 N vEx,$ET,$ES S vEx=$ZE,$EC="",$ET="Q",$ZE=""
 D info("failed to prepare "_vUnit_" >>> "_vEx)
 D ZX^UCGMR(voxMrk) Q 
 ;
vCatch7 ; Error trap
 ;
 N rEx2,$ET,$ES S rEx2=$ZE,$EC="",$ET="Q",$ZE=""
 D close^UCIO(rOutFile)
 S $ZE=rEx2,$EC=",U1001,"
 D ZX^UCGMR(voxMrk) Q 
 ;
vCatch6 ; Error trap
 ;
 N rEx1,$ET,$ES S rEx1=$ZE,$EC="",$ET="Q",$ZE=""
 D close^UCIO(rIo)
 I $P(rEx1,",",3)'["PSL-E-IO" S $ZE=rEx1,$EC=",U1001,"
 D ZX^UCGMR(voxMrk) Q 
 ;
vCatch5 ; Error trap
 ;
 N vEx,$ET,$ES S vEx=$ZE,$EC="",$ET="Q",$ZE=""
 D info("failed to prepare "_unt_" >>> "_vEx)
 D ZX^UCGMR(voxMrk) Q 
 ;
vCatch4 ; Error trap
 ;
 N vEx,$ET,$ES S vEx=$ZE,$EC="",$ET="Q",$ZE=""
 D info("failed to prepare "_unt_" >>> "_vEx)
 D ZX^UCGMR(voxMrk) Q 
 ;
vCatch3 ; Error trap
 ;
 N vEx,$ET,$ES S vEx=$ZE,$EC="",$ET="Q",$ZE=""
 D info("failed to prepare "_unt_" >>> "_vEx)
 D ZX^UCGMR(voxMrk) Q 
 ;
vCatch2 ; Error trap
 ;
 N loadExep,$ET,$ES S loadExep=$ZE,$EC="",$ET="Q",$ZE=""
 D ZX^UCGMR(voxMrk) Q 
 ;
vCatch1 ; Error trap
 ;
 N vErr,$ET,$ES S vErr=$ZE,$EC="",$ET="Q",$ZE=""
 S $ZE="0,"_$ZPOS_","_"%PSL-E-CONVERT,,"_vStr_"~"_vMsk,$EC=",U1001,"
 D ZX^UCGMR(voxMrk) Q 
