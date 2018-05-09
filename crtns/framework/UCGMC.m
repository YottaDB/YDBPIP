 ; 
 ; **** Routine compiled from DATA-QWIK Procedure UCGMC ****
 ; 
 ; 02/24/2010 18:23 - pip
 ; 
 ;  #PACKAGE framework.psl
 ;  #OPTION  ResultClass ON
 ;
UCGMC(cmd,m2src,lptr,str,ptr,tok) ; 
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
 S cmd=$E(cmd,2,1048575)
 ;
 I cmd="ACCEPT" Q $$ACCEPT(.m2src,lptr,str,.ptr,tok)
 I cmd="BYPASS" Q $$BYPASS(.m2src,.lptr,.ptr)
 I cmd="CLASSDEF" Q $$ignore(str,.ptr,tok)
 I cmd="IF" Q $$IF(.m2src,.lptr,str,.ptr,tok)
 I cmd="ELSE",fCompile>0 Q $$ELSE(.m2src,.lptr,.ptr)
 I cmd="END",fCompile>0 Q $$END(.ptr)
 I cmd="ENDIF",fCompile>0 Q $$END(.ptr)
 I cmd="OPTIMIZE" Q $$OPTIMIZE(str,.ptr,tok)
 I cmd="OPTION" Q $$OPTION(str,.ptr,tok)
 I cmd="PACKAGE" Q $$ignore(str,.ptr,tok)
 I cmd="PROPERTYDEF" Q $$ignore(str,.ptr,tok)
 I cmd="WARN" Q $$WARN(str,.ptr,tok)
 I cmd="INFO" Q $$INFO(str,.ptr,tok)
 I cmd="WHILE" Q $$WHILE(.m2src,.lptr,str,.ptr,tok)
 I cmd="XECUTE" Q $$XECUTE(str,.ptr,tok)
 ;
 D ERROR^UCGM("Unexpected compiler command: "_cmd)
 S ptr=0
 Q "; "_str
 ;
 ; ---------------------------------------------------------------------
ignore(str,ptr,tok) ; 
 S ptr=0
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 Q "; "_$$UNTOK^%ZS(str,tok)
 ;
 ; ---------------------------------------------------------------------
ACCEPT(m2src,lptr,str,ptr,tok) ; Accept a warning and quiet the compiler
 ;
 N atom S atom="" N kwd N return
 N val
 N elm N llptr S llptr=$order(m2src(lptr))
 ;
 F  S return=$$getExpr(str,.ptr,tok,"") Q:(return="")  S atom=atom_return Q:ptr=0 
 ;
 F kwd="DATE","PGM" D
 .	S val=$piece($piece($piece((";"_atom),";"_kwd_"=",2),";",1),"=",1)
 .	;
 .	;   #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 .	I (val="") D warnGroup^UCGM("SYNTAX","Accept requires "_kwd_" field")
 .	Q 
 ;
 I pslPrsr("cs","PSL","Version")'<2.7 D
 .	S val=$piece($piece($piece((";"_atom),";CR=",2),";",1),"=",1)
 .	I (val="") D
 ..		N dat S dat=$piece($piece($piece((";"_atom),";DATE=",2),";",1),"=",1)
 ..		I dat?.E1P4N S dat=$E(dat,$L(dat)-3,1048575)
 ..		E  I dat?4N1P.E S dat=$E(dat,1,4)
 ..		I dat?4N,+dat<2005 Q 
 ..		;
 ..		;    #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 ..		D warnGroup^UCGM("SYNTAX","Accept requires CR field")
 ..		Q 
 .	Q 
 ;
 S ptr=0
 S val=$ZCONVERT($piece($piece($piece((";"_atom),";GROUP=",2),";",1),"=",1),"U")
 I (val="") S pslPrsr("ACCEPT",llptr)=""
 E  F elm=1:1:$S((val=""):0,1:$L(val,",")) S pslPrsr("ACCEPT",llptr,$piece(val,",",elm))=""
 ;
 Q "; "_str
 ;
 ; ---------------------------------------------------------------------
BYPASS(m2src,lptr,ptr) ; Bypass the M++ compiler
 N init
 N mcode
 N stop S stop=0
 ;
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 D warnGroup^UCGM("BYPASS","Embedded M code bypassing compiler")
 ;
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 S init=$$initLine^UCGM(level)
 ;
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 D ADD^UCGM(init_";*** Start of code by-passed by compiler")
 ;
 F  Q:'('stop)  S lptr=$order(m2src(lptr)) Q:lptr=""  D
 .	;
 .	S mcode=m2src(lptr)
 .	I $ZCONVERT(mcode,"U")["#ENDBYPASS" S stop=1 Q 
 .	S mcode=init_$$vStrTrim($translate(mcode,$char(9)," "),-1," ")
 .	;
 .	;   #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 .	D ADD^UCGM(mcode)
 .	Q 
 ;
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 D resetType^UCGM() ; Invalidate assignments to Primitives
 ;
 S ptr=0
 Q ";*** End of code by-passed by compiler ***"
 ;
 ; ---------------------------------------------------------------------
IF(m2src,lptr,str,ptr,tok) ; Process #IF
 ;
 N atom N cmdDel
 N cmdNum
 N isTrue
 ;
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 S atom=$$ATOM^%ZS(str,.ptr,";",,1)
 ;
 ; Find any extrinsic functions ($$) used in #IF
 I atom["$$" D
 .	N fatom N func
 .	N fptr
 .	;
 .	S fptr=0
 .	F  D  Q:fptr=0 
 ..		;    #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 ..		S fatom=$$ATOM^%ZS(atom,.fptr,"+-*/\#_'=><[]&!?",,1)
 ..		Q:$E(fatom,1,2)'="$$" 
 ..		S func=$piece(fatom,"(",1)
 ..		S func=$E(func,3,1048575)
 ..		D addSysmap^PSLParser(.pslPrsr,"#IF","FUNC",func,"")
 ..		Q 
 .	Q 
 S cmdDel=$S(ptr:$E(str,ptr+1),1:"") S cmdNum=0
 ;
 N ER S ER=0
 ;
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 S atom=$$condBool^UCGM(atom) I ER Q ""
 ;
 D
 .	N $ET,$ES,$ZYER S $ZYER="ZE^UCGMR",$ZE="",$EC="",$ET="D:$TL>"_$TL_" rollback^vRuntime("_$TL_") Q:$Q&$ES """" Q:$ES  N voxMrk s voxMrk="_+$O(vobj(""),-1)_" G vCatch1^"_$T(+0)
 .	;
 .	;   #ACCEPT DATE=20060314;PGM=FSCW;CR=20280;GROUP=XECUTE
 .	XECUTE ("S isTrue="_atom)
 .	;
 .	I 'isTrue S ptr=0 ; Don't process the rest of the line
 .	;
 .	I isTrue S struct(7,subRou)=lptr
 .	I '(cmdDel=" ") D  ; #IF/#END[IF] block
 ..		;
 ..		S fCompile=fCompile+1
 ..		S fCompile(fCompile)=isTrue_$char(9)_lptr
 ..		;
 ..		I 'isTrue D skip(.m2src,.lptr,"#IF")
 ..		Q 
 .	Q 
 ;
 Q ""
 ;
 ; ---------------------------------------------------------------------
INFO(str,ptr,tok) ; 
 ;
 N all S all=$$allINFO
 N atom S atom=$$getExpr(str,.ptr,tok,$$allWARN)
 N switch S switch=$$getSwitch(str,.ptr,tok,1)
 ;
 D setCmds("INFO",atom,switch,all,.pslPrsr)
 ;
 S ptr=0
 Q ""
 ;
 ; ---------------------------------------------------------------------
ELSE(m2src,lptr,ptr) ; 
 ;
 I $piece(fCompile(fCompile),$char(9)) D skip(.m2src,.lptr,"#ELSE")
 ;
 Q ""
 ;
 ; ---------------------------------------------------------------------
END(ptr) ; Process #END or #ENDIF
 ;
 K fCompile(fCompile)
 ;
 S fCompile=fCompile-1
 S ptr=0
 ;
 Q ""
 ;
 ; ---------------------------------------------------------------------
OPTIMIZE(str,ptr,tok) ; 
 ;
 N all S all=$$allOPTIMIZE
 N atom S atom=$$getExpr(str,.ptr,tok,all)
 N switch S switch=$$getSwitch(str,.ptr,tok,1)
 ;
 D setCmds("OPTIMIZE",atom,switch,all,.pslPrsr)
 ;
 S ptr=0
 Q "; "_str
 ;
 ; ---------------------------------------------------------------------
OPTION(str,ptr,tok) ; 
 ;
 N all S all=$$allOptions
 ;
 D
 .	N $ET,$ES,$ZYER S $ZYER="ZE^UCGMR",$ZE="",$EC="",$ET="D:$TL>"_$TL_" rollback^vRuntime("_$TL_") Q:$Q&$ES """" Q:$ES  N voxMrk s voxMrk="_+$O(vobj(""),-1)_" G vCatch2^"_$T(+0)
 .	N clsdes S clsdes=$$getPSLClass^PSLCC(.pslPrsr,pslPrsr("moduleName"))
 .	I $P(clsdes,$C(9),5)>-1 S all=$piece(all,",ResultClass")_$piece(all,",ResultClass",2)
 .	Q 
 ;
 N atom S atom=$$getExpr(str,.ptr,tok,all)
 N switch S switch=$$getSwitch(str,.ptr,tok,1)
 ;
 D setCmds("Options",atom,switch,all,.pslPrsr)
 ;
 S ptr=0
 Q "; "_str
 ;
 ; ---------------------------------------------------------------------
WARN(str,ptr,tok) ; 
 ;
 N all S all=$$allWARN
 N atom S atom=$$getExpr(str,.ptr,tok,all)
 N switch S switch=$$getSwitch(str,.ptr,tok,1)
 ;
 D setCmds("WARN",atom,switch,all,.pslPrsr)
 ;
 S ptr=0
 Q ""
 ;
 ; ---------------------------------------------------------------------
WHILE(m2src,lptr,str,ptr,tok) ; Process #WHILE
 ;
 N expr
 N ER N i N lptrb N lptre
 ;
 ; condition as PSL expression
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 N atom S atom=$$ATOM^%ZS(str,.ptr,";",tok)
 N cmdDel S cmdDel=$S(ptr:$E(str,ptr+1),1:"")
 N cmdNum S cmdNum=0
 ;
 S (lptrb,lptre)=lptr
 ;
 I cmdDel="" S fCompile=fCompile+1 D skip(.m2src,.lptre,"#WHILE")
 ;
 N bQuit S bQuit=0
 ;
 F i=1:1:1000 D  I bQuit Q 
 .	;
 .	S ER=0
 .	;   #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 .	S expr=$$condBool^UCGM(atom) I ER S bQuit=1 Q 
 .	;
 .	D
 ..		N $ET,$ES,$ZYER S $ZYER="ZE^UCGMR",$ZE="",$EC="",$ET="D:$TL>"_$TL_" rollback^vRuntime("_$TL_") Q:$Q&$ES """" Q:$ES  N voxMrk s voxMrk="_+$O(vobj(""),-1)_" G vCatch3^"_$T(+0)
 ..		;    #ACCEPT DATE=20060314;PGM=FSCW;CR=20280;GROUP=XECUTE
 ..		XECUTE "I "_expr
 ..		E  S bQuit=1 Q 
 ..		;
 ..		S lptr=lptrb
 ..		;
 ..		;    #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 ..		I (lptr=lptre) D line^UCGM($E(m2src(lptr),ptr+1,1980)) Q 
 ..		;
 ..		;    #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 ..		F  S lptr=$order(m2src(lptr)) Q:(lptr'<lptre)  D line^UCGM(m2src(lptr)) I ER Q 
 ..		Q 
 .	Q 
 S lptr=lptre
 ;
 S ptr=0
 Q ""
 ;
 ; ---------------------------------------------------------------------
XECUTE(str,ptr,tok) ; xecute a string in the compiler
 I $$getSetting^PSLCC(.pslPrsr,"boot","restrictionlevel",0)>0 S ptr=0 Q ""
 ;
 ;  #ACCEPT DATE=2006-03-14;PGM=FSCW;CR=20280;GROUP=ACCESS,XECUTE
 XECUTE $$UNTOK^%ZS($E(str,ptr+2,1048575),tok)
 S ptr=0
 ;
 Q ""
 ;
 ; ---------------------------------------------------------------------
DEFINE(prsr,str,ptr,tok) ; #DEFINE [section.]name value
 ;
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 N name S name=$$ATOM^%ZS(str,.ptr,"",tok)
 N sect S sect="DEFINE"
 ;
 I name["." S sect=$piece(name,".") S name=$E(name,$F(name,"."),1048575)
 I '(",boot,DEBUG,DEFINE,"[(","_sect_",")) D ERROR^UCGM("Invalid section '"_sect_"'") S ptr=0
 I '$$isVar^UCGM(name) D ERROR^UCGM("Variable name expected") S ptr=0
 ;
 N expr S expr=""
 N atom N atomsect
 F  Q:'(ptr>0)  D
 .	;   #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 .	S atom=$$ATOM^%ZS(str,.ptr,"+-*/\#_'!&()",tok)
 .	I "+-*/\#_'!&()"[atom S expr=expr_atom Q 
 .	I $$isLit^UCGM(atom) S expr=expr_atom Q 
 .	S atomsect=sect
 .	I atom["." S atomsect=$piece(atom,".") S atom=$E(atom,$F(atom,"."),1048575)
 .	I atomsect'=sect D ERROR^UCGM("Invalid section '"_atomsect_"'") S ptr=0 Q 
 .	I '$$hasSetting^PSLCC(.prsr,sect,atom) D ERROR^UCGM("Invalid experession element: "_atom) S ptr=0 Q 
 .	S expr=expr_$$getSetting^PSLCC(.prsr,sect,atom)
 .	Q 
 ;
 ;  #ACCEPT Date=2006-04-25; PGM=FSCW; CR=20280; Group=XECUTE
 XECUTE "set expr="_expr
 D addSetting^PSLCC(.prsr,sect,name,expr)
 ;
 Q 
 ;
 ; ---------------------------------------------------------------------
PSL(prsr,str,ptr,tok) ; #PSL settingName value
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 N name S name=$$ATOM^%ZS(str,.ptr,"",tok)
 ;
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 I (name="")!$$isComment(name) D warnGroup^UCGM("MISMATCH","missing settingName in #PSL") Q 
 ;
 N value S value=""
 ;
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 I ptr>0 S value=$$ATOM^%ZS(str,.ptr,"",tok)
 ;
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 I (value="")!$$isComment(value) D warnGroup^UCGM("MISMATCH","missing value in #PSL") Q 
 I value="true" S value=1
 E  I value="false" S value=0
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 E  I '$$isLit^UCGM(value) D warnGroup^UCGM("MISMATCH","Invalid #PSL String value '"_value_"'") Q 
 I '(value=+value) S value=$$QSUB^%ZS(value,"""")
 ;
 ; check settingName and value
 N all S all=$$allPSL()
 N pos S pos=$$vlstPos(all,name,",",1)
 ;
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 I pos=0 D warnGroup^UCGM("MISMATCH","Invalid #PSL settingName '"_name_"'") Q 
 I '((","_all_",")[(","_name_",")) D
 .	;   #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 .	D warnGroup^UCGM("MISMATCH","#PSL settingName ("_name_") is case sensitive")
 .	S name=$piece(all,",",pos)
 .	Q 
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 I $$hasSetting^PSLCC(.prsr,"PSL",name) D warnGroup^UCGM("MISMATCH","Ignored duplicate #PSL "_name) Q 
 ;
 I name="BooleanMask" D
 .	;   #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 .	I '(value=""),$L(value,",")'=2!(value["'")!(value["""") D warnGroup^UCGM("MISMATCH","Invalid #PSL BooleanMask value '"_value_"'") Q 
 .	;
 .	D addSetting^PSLCC(.prsr,"PSL","BooleanMask",value)
 .	Q 
 E  I name="CompileSummary" D
 .	;   #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 .	I '(",0,1,"[(","_value_",")) D warnGroup^UCGM("MISMATCH","Invalid #PSL CompileSummary value '"_value_"'") Q 
 .	;
 .	D addSetting^PSLCC(.prsr,"PSL","CompileSummary",value)
 .	Q 
 E  I name="DateMask" D
 .	N $ET,$ES,$ZYER S $ZYER="ZE^UCGMR",$ZE="",$EC="",$ET="D:$TL>"_$TL_" rollback^vRuntime("_$TL_") Q:$Q&$ES """" Q:$ES  N voxMrk s voxMrk="_+$O(vobj(""),-1)_" G vCatch4^"_$T(+0)  ; if exception is thrown, the mask is invalid
 .	N ign
 .	I '(value="") S ign=$$vdat2str($P($H,",",1),value)
 .	;
 .	D addSetting^PSLCC(.prsr,"PSL","DateMask",value) ; seems OK !
 .	Q 
 E  I name="TimeMask" D
 .	N $ET,$ES,$ZYER S $ZYER="ZE^UCGMR",$ZE="",$EC="",$ET="D:$TL>"_$TL_" rollback^vRuntime("_$TL_") Q:$Q&$ES """" Q:$ES  N voxMrk s voxMrk="_+$O(vobj(""),-1)_" G vCatch5^"_$T(+0)  ; if exception is thrown, the mask is invalid
 .	N ign
 .	I '(value="") S ign=$$vtim2str($P($H,",",2),value)
 .	;
 .	D addSetting^PSLCC(.prsr,"PSL","TimeMask",value) ; seems OK !
 .	Q 
 E  I name="Version" D
 .	N minVersion S minVersion=$$getPSLMinVersion^PSLC()
 .	N pslVersion S pslVersion=$$getPSLVersion^PSLC()
 .	;
 .	;   #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 .	I '(value=+value) D warnGroup^UCGM("MISMATCH","invalid #PSL Version value '"_value_"'") Q 
 .	;   #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 .	I value<minVersion D warnGroup^UCGM("MISMATCH","#PSL Version cannot be less than "_minVersion) Q 
 .	;   #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 .	I value>pslVersion D warnGroup^UCGM("MISMATCH","#PSL Version cannot be greater than "_pslVersion) Q 
 .	;
 .	D addSetting^PSLCC(.prsr,"PSL","Version",value)
 .	Q 
 ;
 Q 
 ;
 ; ---------------------------------------------------------------------
allINFO() ; return list of all possible INFO options
 Q $$allWARN
 ;
 ; ---------------------------------------------------------------------
allOPTIMIZE() ; return list of all possible OPTIMIZE options
 Q "FUNCTIONS,OBJECTS"
 ;
 ; ---------------------------------------------------------------------
allOptions() ; return list of all possible Option options
 Q "$GetEFD,AutoPublicERRM,nolink,ResultClass"
 ;
 ; ---------------------------------------------------------------------
allPSL() ; return list of all possible PSL commands
 Q "BooleanMask,CompileSummary,DateMask,TimeMask,Version"
 ;
 ; ---------------------------------------------------------------------
allWARN() ; return list of all possible WARN options
 Q "ACCESS,BYPASS,DATABASE,DEAD,DEPRECATED,DYNAMIC,FUNCTION,GLOBAL,LENGTH,MISMATCH,PRECEDENCE,PSLBOOT,READ,RECEXISTS,SCOPE,SYNTAX,SYSVAR,XECUTE"
 ;
 ; ---------------------------------------------------------------------
decode(pslPrsr,line) ; decompose a line
 ;
 ; declare and hide PUBLIC vars of all #command implementations
 N fCompile N RM N struct
 N ER
 ;
 N ptr S ptr=0
 N tok
 ;
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 S line=$$TOKEN^%ZS(line,.tok)
 ;
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 N cmd S cmd=$ZCONVERT($$ATOM^%ZS(line,.ptr,";"),"U")
 ;
 I $$isComment(cmd) Q 
 I (",#INFO,#OPTIMIZE,#OPTION,#WARN,"[(","_cmd_",")) S cmd=$$UCGMC(cmd,,0,line,ptr,tok) Q 
 ;
 I cmd="#DEFINE" D DEFINE(.pslPrsr,line,ptr,tok) Q 
 I cmd="#PSL" D PSL(.pslPrsr,line,ptr,tok) Q 
 ;
 Q 
 ;
 ; ---------------------------------------------------------------------
decodeFile(sDir,sFil,prsr) ; decompose a file
 N rIO S rIO=$$vClVobj($ST,"IO")
 S $P(vobj(rIO,1),"|",2)=sDir
 S $P(vobj(rIO,1),"|",1)=sFil
 S $P(vobj(rIO,1),"|",3)="READ"
 ;
 N subRou S subRou=$P(vobj(rIO,1),"|",6) ; subRou for PSL.error()
 N lptr ; line pointer for PSL.error()
 D
 .	N $ET,$ES,$ZYER S $ZYER="ZE^UCGMR",$ZE="",$EC="",$ET="D:$TL>"_$TL_" rollback^vRuntime("_$TL_") Q:$Q&$ES """" Q:$ES  N voxMrk s voxMrk="_+$O(vobj(""),-1)_" G vCatch6^"_$T(+0)
 .	D open^UCIO(rIO,$T(+0),"decodeFile","rIO")
 .	F lptr=1:1 D decode(.prsr,$translate($$read^UCIO(rIO),$char(9)," "))
 .	Q 
 K vobj(+$G(rIO)) Q 
 ;
 ; ---------------------------------------------------------------------
defOPTIMIZE() ; return list of default OPTIMIZE options
 Q $$allOPTIMIZE()
 ;
 ; ---------------------------------------------------------------------
replaceAndNotOr(src) ; replace keywords and/or/not
 ;
 Q:$$getSetting^PSLCC(.pslPrsr,"PSL","Version")<3 src
 ;
 N cd N ct N kw N lc N rc
 N c1 S c1=1048575+2 N c2 S c2=1048575+2 N wc
 ;
 I (src["//") S c1=$F(src,"//")
 I (src[";") S c2=$F(src,";")
 I c1<c2 S cd=$E(src,1,c1-2)
 E  S cd=$E(src,1,c2-2)
 S ct=$E(src,$L(cd)+1,1048575)
 ;
 F wc=1:1:3 D
 .	S kw=$piece("and,not,or",",",wc) Q:cd'[kw 
 .	F lc=" ",")" I (cd[(lc_kw)) D
 ..		F rc=" ","(" I (cd[(lc_kw_rc)) S cd=$$vStrRep(cd,lc_kw_rc,lc_$piece("&,',!",",",wc)_rc,0,0,"")
 ..		Q 
 .	Q 
 Q cd_ct
 ;
 ; ---------------------------------------------------------------------
SetLit(mcode,atom,expr) ; value to assign
 D
 .	N $ET,$ES,$ZYER S $ZYER="ZE^UCGMR",$ZE="",$EC="",$ET="D:$TL>"_$TL_" rollback^vRuntime("_$TL_") Q:$Q&$ES """" Q:$ES  N voxMrk s voxMrk="_+$O(vobj(""),-1)_" G vCatch7^"_$T(+0)
 .	I '($ZLENGTH(expr)+7'>1980) S expr=$$bigExpr(expr)
 .	;   #ACCEPT DATE=20060314;PGM=FSCW;CR=20280;GROUP=XECUTE
 .	E  XECUTE ("S expr="_expr)
 .	Q 
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 D setInst^UCGM(atom,"",$$vBtsPslE(expr))
 ;
 Q $E(mcode,1,$L(mcode)-2)
 ;
 ; ---------------------------------------------------------------------
splitCode(expr,extra,at,split) ; chunks
 N y
 ;
 F  D  Q:(expr="") 
 .	S y=$L($ZSUBSTR(expr,1,1980-extra))
 .	;
 .	I '(at=""),y<$L(expr) F y=y:-1:247 Q:at[$E(expr,y) 
 .	;
 .	S split($order(split(""),-1)+1)=$E(expr,1,y)
 .	S expr=$E(expr,y+1,1048575)
 .	Q 
 Q 
 ;
 ; ---------------------------------------------------------------------
bigExpr(expr) ; Execute an expression that's bigger than the M line length !!
 N tok N vox
 N sub
 ;
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 S expr=$$TOKEN^%ZS(expr,.tok)
 F  Q:'(expr[$char(0))  D
 .	S sub=$order(vox(""),-1)+1
 .	;
 .	;   #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 .	S vox(sub)=$$UNTOK^%ZS($char(0)_$piece(expr,$char(0),2)_$char(0),tok)
 .	S vox(sub)=$$QSUB^%ZS(vox(sub),"""")
 .	S expr=$piece(expr,$char(0),1)_"vox("_sub_")"_$piece(expr,$char(0),3,9999)
 .	Q 
 ;
 ;  #ACCEPT DATE=2006-03-14;PGM=FSCW;CR=20280;GROUP=XECUTE
 XECUTE ("S expr="_expr)
 ;
 Q expr
 ;
 ; ---------------------------------------------------------------------
getExpr(str,ptr,tok,dft) ; Return expression value
 I ptr=0 Q dft ; Default expression
 ;
 N atom
 ;
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 S atom=$ZCONVERT($$ATOM^%ZS(str,.ptr,"",tok),"U")
 ;
 I $$isComment(atom) D  ; Hit a comment, use default
 .	;
 .	I ptr=0 S ptr=$L(str)
 .	S ptr=ptr-$L(atom)-1
 .	S atom=dft
 .	Q 
 Q atom
 ;
 ; ---------------------------------------------------------------------
getSwitch(str,ptr,tok,dft) ; Return switch value
 N atom S atom=$$getExpr(str,.ptr,tok,dft)
 ;
 I atom=0!(atom=1)
 E  I atom="ON" S atom=1
 E  I atom="OFF" S atom=0
 E  D ERROR^UCGM("Unknown Compiler Switch: "_atom)
 ;
 Q atom
 ;
 ; ---------------------------------------------------------------------
isComment(expr) ; 
 Q (expr=";")!(expr="//")!(expr="/*")
 ;
 ; ---------------------------------------------------------------------
setCmds(cls,vals,switch,valid,cmds) ; output array (*5)
 N elm N pos
 N val
 ;
 I vals="*" S vals=valid
 ;
 F elm=1:1:$S((vals=""):0,1:$L(vals,",")) D
 .	S val=$piece(vals,",",elm)
 .	S pos=$$vlstPos(valid,val,",",1)
 .	I pos>0 D addSetting^PSLCC(.cmds,cls,$piece(valid,",",pos),switch)
 .	Q 
 Q 
 ;
 ; ---------------------------------------------------------------------
skip(m2src,lptr,cmd) ; 
 ;
 N atom N rec N tok
 N ptr N stop S stop=fCompile
 ;
 F  S lptr=$order(m2src(lptr)) Q:lptr=""  D  I (fCompile<stop)!(stop=0) Q 
 .	;
 .	S ptr=1
 .	;
 .	;   #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 .	S rec=$$TOKEN^%ZS($translate(m2src(lptr),$char(9)," "),.tok)
 .	;
 .	;   #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 .	S atom=$ZCONVERT($$ATOM^%ZS(rec,.ptr,";",.tok),"U")
 .	;
 .	I atom="#END" S atom=$$END(.ptr) Q  ; #END
 .	I atom="#ENDIF" S atom=$$END(.ptr) Q  ; #ENDIF
 .	I atom="#ELSE",fCompile=stop S stop=0 Q 
 .	I atom="#IF" D  ; Nested #IF
 ..		;    #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 ..		S atom=$$ATOM^%ZS(rec,.ptr,";",tok)
 ..		I ptr=0!($E(rec,ptr+1)'=" ") S fCompile=fCompile+1
 ..		Q 
 .	Q 
 ;
 I (lptr="") S lptr=$order(m2src(""),-1) D ERROR^UCGM("Missing #END")
 Q 
 ;  #OPTION ResultClass ON
vSIG() ; 
 Q "61111^17292^Frans S.C. Witte^41613" ; Signature - LTD^TIME^USER^SIZE
 ; ----------------
 ;  #OPTION ResultClass 1
vStrTrim(object,p1,p2) ; String.trim
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 I p1'<0 S object=$$RTCHR^%ZFUNC(object,p2)
 I p1'>0 F  Q:$E(object,1)'=p2  S object=$E(object,2,1048575)
 Q object
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
vdat2str(vo,mask) ; Date.toString
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 I (vo="") Q ""
 I (mask="") S mask="MM/DD/YEAR"
 N cc N lday N lmon
 I mask="DL"!(mask="DS") D  ; Long or short weekday
 .	;    #ACCEPT PGM=FSCW;DATE=2007-03-30;CR=27800;GROUP=GLOBAL
 .	S cc=$get(^DBCTL("SYS","DVFM")) ; Country code
 .	I (cc="") S cc="US"
 .	;    #ACCEPT PGM=FSCW;DATE=2007-03-30;CR=27800;GROUP=GLOBAL
 .	S lday=$get(^DBCTL("SYS","*DVFM",cc,"D",mask))
 .	S mask="DAY" ; Day of the week
 .	Q 
 I mask="ML"!(mask="MS") D  ; Long or short month
 .	;    #ACCEPT PGM=FSCW;DATE=2007-03-30;CR=27800;GROUP=GLOBAL
 .	S cc=$get(^DBCTL("SYS","DVFM")) ; Country code
 .	I (cc="") S cc="US"
 .	;    #ACCEPT PGM=FSCW;DATE=2007-03-30;CR=27800;GROUP=GLOBAL
 .	S lmon=$get(^DBCTL("SYS","*DVFM",cc,"D",mask))
 .	S mask="MON" ; Month of the year
 .	Q 
 ;  #ACCEPT PGM=FSCW;DATE=2007-03-30;CR=27800;GROUP=BYPASS
 ;*** Start of code by-passed by compiler
 set cc=$ZD(vo,mask,$G(lmon),$G(lday))
 ;*** End of code by-passed by compiler ***
 Q cc
 ; ----------------
 ;  #OPTION ResultClass 1
vtim2str(vo,vm) ; Time.toString
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 I (vo="") Q ""
 I (vm="") S vm="24:60:SS"
 N cc
 ;  #ACCEPT PGM=FSCW;DATE=2007-03-30;CR=27800;GROUP=BYPASS
 ;*** Start of code by-passed by compiler
 SET cc=$ZDATE(","_vo,vm)
 ;*** End of code by-passed by compiler ***
 Q cc
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
vBtsPslE(vVal) ; ByteString.toPSLExpression
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 N bValid S bValid=0
 D
 .	N $ET,$ES,$ZYER S $ZYER="ZE^UCGMR",$ZE="",$EC="",$ET="D:$TL>"_$TL_" rollback^vRuntime("_$TL_") Q:$Q&$ES """" Q:$ES  N voxMrk s voxMrk="_+$O(vobj(""),-1)_" G vCatch8^"_$T(+0)  ; catch and ignore %GTM-E-BADCHAR exception
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
 ;
vClVobj(vSt,vCls) ; Create a new object
 ;
 N vOid
 S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)=vCls_$C(9)_vSt
 Q vOid
 ;
vCatch8 ; Error trap
 ;
 N vEx,$ET,$ES S vEx=$ZE,$EC="",$ET="Q",$ZE=""
 D ZX^UCGMR(voxMrk) Q 
 ;
vCatch7 ; Error trap
 ;
 N xLit,$ET,$ES S xLit=$ZE,$EC="",$ET="Q",$ZE=""
 D setProperty^UCERROR(.xLit,3,"LITERAL")
 S $ZE=xLit,$EC=",U1001,"
 D ZX^UCGMR(voxMrk) Q 
 ;
vCatch6 ; Error trap
 ;
 N xIO,$ET,$ES S xIO=$ZE,$EC="",$ET="Q",$ZE=""
 I $P(xIO,",",3)'["OPEN" D close^UCIO(rIO)
 D ZX^UCGMR(voxMrk) Q 
 ;
vCatch5 ; Error trap
 ;
 N xmask,$ET,$ES S xmask=$ZE,$EC="",$ET="Q",$ZE=""
 ;    #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 D warnGroup^UCGM("MISMATCH","Invalid #PSL TimeMask value '"_value_"'")
 D ZX^UCGMR(voxMrk) Q 
 ;
vCatch4 ; Error trap
 ;
 N xmask,$ET,$ES S xmask=$ZE,$EC="",$ET="Q",$ZE=""
 ;    #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 D warnGroup^UCGM("MISMATCH","Invalid #PSL DateMask value '"_value_"'")
 D ZX^UCGMR(voxMrk) Q 
 ;
vCatch3 ; Error trap
 ;
 N whileEx,$ET,$ES S whileEx=$ZE,$EC="",$ET="Q",$ZE=""
 D ERROR^UCGM("Runtime exception in #WHILE: "_whileEx)
 S bQuit=1
 D ZX^UCGMR(voxMrk) Q 
 ;
vCatch2 ; Error trap
 ;
 N xClsdes,$ET,$ES S xClsdes=$ZE,$EC="",$ET="Q",$ZE=""
 ; ignore exception on clsdes (eg dummy or null moduleName)
 D ZX^UCGMR(voxMrk) Q 
 ;
vCatch1 ; Error trap
 ;
 N ifEx,$ET,$ES S ifEx=$ZE,$EC="",$ET="Q",$ZE=""
 D ERROR^UCGM(" Runtime exception in #IF: "_ifEx)
 D ZX^UCGMR(voxMrk) Q 
