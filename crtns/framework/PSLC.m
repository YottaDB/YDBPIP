 ; 
 ; **** Routine compiled from DATA-QWIK Procedure PSLC ****
 ; 
 ; 02/24/2010 18:22 - pip
 ; 
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
 ;  #ACCEPT CR=27800;PGM=Frans S.S. Witte;Date=2007-06-11;Group=BYPASS
 ;*** Start of code by-passed by compiler
 IF $$isRdb^vRuntime NEW vE,vM SET vE=$$DBCNCT^%DBAPI($ZTRNLNM("SCAU_DB_INI"),0,.vM) IF vE WRITE vEr," ",vRM,! QUIT
 WRITE $$run($ZCMDLINE),!
 ;*** End of code by-passed by compiler ***
 ;
 Q 
 ;
 ; ---------------------------------------------------------------------
cmdline(sCmdline,aOpts,sArgless,sQuote) ; quote characer, default: double quote
 ;
 N sArg N sOpt
 N nArgs S nArgs=0
 ;
 I ($get(sQuote)="") S sQuote=""""
 S sArgless=$get(sArgless)
 ;
 ; replace TAB by SPACE and reduce multiple space to single space
 S sCmdline=$$vStrRep($$vStrTrim($translate(sCmdline,$char(9)," "),0," "),"  "," ",0,0,sQuote)
 ;
 F  Q:'('(sCmdline=""))  D
 .	S sOpt=$$vStrPce(sCmdline," ",1,1,sQuote)
 .	S sCmdline=$E(sCmdline,$L(sOpt)+2,1048575)
 .	I $E(sOpt,1)'="-" D  ; command argument
 ..		S nArgs=nArgs+1
 ..		S aOpts("$"_nArgs)=sOpt
 ..		Q 
 .	E  I $E(sOpt,2)="-" D  ; --option=value
 ..		N sLongOpt S sLongOpt=$piece(sOpt,"=")
 ..		N sVal S sVal=$E(sOpt,$L(sLongOpt)+2,1048575)
 ..		S aOpts($E(sLongOpt,3,1048575))=$$QSUB^%ZS(sVal,"""")
 ..		Q 
 .	E  D  ; -o and -o value
 ..		N sArgOpt S sArgOpt=$translate(sOpt,"-"_sArgless)
 ..		N sNoArgs S sNoArgs=$translate(sOpt,"-"_sArgOpt)
 ..		N nPos
 ..		;
 ..		F nPos=1:1:$L(sNoArgs) S aOpts($E(sNoArgs,nPos))=""
 ..		;
 ..		I (sArgOpt="") Q 
 ..		I $L(sArgOpt)>1 S sArgOpt=$E(sArgOpt,1) ; and warn?
 ..		;
 ..		S sOpt=$$vStrPce(sCmdline," ",1,1,sQuote)
 ..		S sCmdline=$E(sCmdline,$L(sOpt)+2,1048575)
 ..		S aOpts(sArgOpt)=$$QSUB^%ZS(sOpt,sQuote)
 ..		Q  ; end if (start with dash) - else - else
 .	Q  ; end while 'sCmdline.isNull()
 Q 
 ;
 ; ---------------------------------------------------------------------
cmp0begin(mod,src,commands,log,cma) ; initiated command argument array
 ;
 N del N srcdir S srcdir=$$cmp0dir("")
 ;
 L +PSLC(mod):120 E  S $ZE="0,"_$ZPOS_","_"%PSL-E-LOCK,failed to obtain LOCK on module,"_mod,$EC=",U1001,"
 ;
 ; write src() to cma("$1") in the source directory
 S (cma("$1"),del)=srcdir_mod_".psl"
 N ign S ign=$$fileWrite(del,.src)
 ;
 ; write commands(,) to file srcdir_ %RoutineName_ "_"_ %ProcessID_ ".ini"
 I $D(commands) D
 .	S cma("ucopts")=$$toUcopts(srcdir,$T(+0)_"ucopts",.commands)
 .	S del=del_","_cma("ucopts")
 .	Q 
 ;
 ; If compiler log requested, create and rewrite temporary logfile
 I '($order(log(""))="") D
 .	N rIO S rIO=$$vClVobj($ST,"IO")
 .	S cma("logfile")=srcdir_mod_".log"
 .	S del=del_","_cma("logfile")
 .	;
 .	S $P(vobj(rIO,1),"|",1)=cma("logfile") S $P(vobj(rIO,1),"|",3)="NEWVERSION"
 .	D open^UCIO(rIO,$T(+0),"cmp0begin","rIO") D close^UCIO(rIO)
 .	K vobj(+$G(rIO)) Q 
 Q del
 ;
 ; ---------------------------------------------------------------------
cmp0dir(filename) ; 
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 I (filename="") Q $$TRNLNM^%ZFUNC("SCAU_SPOOL")_"/"
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 I $$PARSE^%ZFUNC(filename,"NAME")_$$PARSE^%ZFUNC(filename,"TYPE")=filename Q ""
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 Q $$PARSE^%ZFUNC(filename,"DIRECTORY")
 ;
 ; ---------------------------------------------------------------------
cmp0end(mod,del,log,cma) ; initiated command argument array
 N ign1
 ;
 I '($order(log(""))="") S ign1=$$fileRead(cma("logfile"),.log)
 ;
 ; remove files (.ini, .log, .psl, .pslx and .m)
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 N ign2 S ign2=$$DELETE^%OSSCRPT(del)
 ;
 L -PSLC(mod)
 Q 
 ;
 ; ---------------------------------------------------------------------
cmp0mod() ; return default fileName
 Q "_"_$J_"_"
 ;
 ; ---------------------------------------------------------------------
cmpA2A(mod,src,commands,dst,log) ; error log
 N cma N ign1
 I (mod="") S mod=$$cmp0mod()
 ;
 N del S del=$$cmp0begin(mod,.src,.commands,.log,.cma)
 ;
 N cmperr S cmperr=$$runCma(.cma,1)
 ;
 ; read the output into dst() and the logfile into log()
 I cmperr=0 D
 .	N file S file=cma("target")_"/"_mod
 .	N mnam S mnam=$translate(file,"%","_")
 .	S del=del_","_file_".pslx,"_mnam_".o"_$$fileRead(mnam_".m",.dst)
 .	Q 
 ;
 D cmp0end(mod,del,.log,.cma)
 Q cmperr
 ;
 ; ---------------------------------------------------------------------
cmpA2F(src,commands,mod,log,PGM) ; substitute for BUILDRTN^UCGM() and cmpA2F^UCGM()
 N cma N ign1
 ;
 N del S del=$$cmp0begin(mod,.src,.commands,.log,.cma)
 ;
 ; compile
 S cma("element")=PGM
 S cma("output")=$$pslRoot()
 N ign2 N cmperr S cmperr=$$runCma(.cma,1)
 ;
 ; if no errors, copy the source file to the target directory
 I cmperr=0 D
 .	I '$get(commands("Options","nolink"),0),'$$zlink(mod) D log(.cma,"%PSL-W-TARGET: Unable to ZLINK "_mod)
 .	;   #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 .	S ign2=$$COPYFIL^%OSSCRPT(cma("$1"),cma("target"))
 .	Q 
 ;
 D cmp0end(mod,del,.log,.cma)
 Q cmperr
 ;
 ; ---------------------------------------------------------------------
drop(module) ; drop module related data
 D delTarget^UCSYSMAP(module)
 ;
 N modIO S modIO=$$vClVobj($ST,"IO")
 I '$$locate^UCIO(modIO,$$packageDirs("",""),":",module_".m",0) K vobj(+$G(modIO)) Q 
 N tgtDir S tgtDir=$P(vobj(modIO,1),"|",2)
 ;
 N dirObj S dirObj=$P(vobj(modIO,1),"|",2)_"obj/"
 ;
 ;  #ACCEPT CR=27800;PGM=Frans S.S. Witte;Date=2007-07-07;Group=BYPASS
 ;*** Start of code by-passed by compiler
 ZSYSTEM "test -d "_dirObj
 IF $ZSYSTEM SET dirObj=tgtDir
 ;*** End of code by-passed by compiler ***
 ;
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 N ign S ign=$$DELETE^%OSSCRPT(tgtDir_module_".psl,"_tgtDir_module_".pslx,"_tgtDir_module_".m,"_dirObj_module_".o")
 ;
 K vobj(+$G(modIO)) Q 
 ;
 ; ---------------------------------------------------------------------
fileRead(file,txt) ; 
 N rIO S rIO=$$vClVobj($ST,"IO")
 ;
 ; read from file
 S $P(vobj(rIO,1),"|",1)=file
 S $P(vobj(rIO,1),"|",3)="READ"
 S $P(vobj(rIO,1),"|",5)=1048575
 ;
 N ln S ln=$order(txt(""),-1)+1
 D
 .	N $ET,$ES,$ZYER S $ZYER="ZE^UCGMR",$ZE="",$EC="",$ET="D:$TL>"_$TL_" rollback^vRuntime("_$TL_") Q:$Q&$ES """" Q:$ES  N voxMrk s voxMrk="_+$O(vobj(""),-1)_" G vCatch1^"_$T(+0)
 .	D open^UCIO(rIO,$T(+0),"fileRead","rIO")
 .	F ln=ln:1 S txt(ln)=$$read^UCIO(rIO)
 .	Q 
 K vobj(+$G(rIO)) Q ","_file
 ;
 ; ---------------------------------------------------------------------
fileWrite(file,txt) ; 
 N rIO S rIO=$$vClVobj($ST,"IO")
 ;
 ; write file
 S $P(vobj(rIO,1),"|",1)=file
 S $P(vobj(rIO,1),"|",3)="NEWVERSION"
 S $P(vobj(rIO,1),"|",5)=1048575
 ;
 N sub S sub=""
 D
 .	N $ET,$ES,$ZYER S $ZYER="ZE^UCGMR",$ZE="",$EC="",$ET="D:$TL>"_$TL_" rollback^vRuntime("_$TL_") Q:$Q&$ES """" Q:$ES  N voxMrk s voxMrk="_+$O(vobj(""),-1)_" G vCatch2^"_$T(+0)
 .	D open^UCIO(rIO,$T(+0),"fileWrite","rIO")
 .	F  S sub=$order(txt(sub)) Q:sub=""  D write^UCIO(rIO,txt(sub))
 .	D close^UCIO(rIO)
 .	Q 
 K vobj(+$G(rIO)) Q ","_file
 ;
 ; --------------------------------------------------------------------
getPSLVersion() ; 
 Q 3.0
 ;
 ; --------------------------------------------------------------------
getPSLMinVersion() ; 
 Q 2.6
 ;
 ; ---------------------------------------------------------------------
log(cma,msg) ; log a message
 ;
 I ($D(cma("logfile"))#2) D
 .	N io S io=$$vClVobj($ST,"IO")
 .	S $P(vobj(io,1),"|",3)="APPEND"
 .	S $P(vobj(io,1),"|",1)=cma("logfile")
 .	N $ET,$ES,$ZYER S $ZYER="ZE^UCGMR",$ZE="",$EC="",$ET="D:$TL>"_$TL_" rollback^vRuntime("_$TL_") Q:$Q&$ES """" Q:$ES  N voxMrk s voxMrk="_+$O(vobj(""),-1)_" G vCatch3^"_$T(+0)
 .	D open^UCIO(io,$T(+0),"log","io")
 .	D write^UCIO(io,"++++++++++++++++++++++")
 .	D write^UCIO(io,msg)
 .	D close^UCIO(io)
 .	K vobj(+$G(io)) Q 
 I '($D(cma("logfile"))#2) D
 .	WRITE !,msg,!
 .	Q 
 Q 
 ;
 ; ---------------------------------------------------------------------
packageDirs(pslRoot,pckList) ; construct the package
 I (pslRoot="") S pslRoot=$$pslRoot()
 ;
 ; use default SCAU_PACKAGES. If empty return SCAU_CRTNS.
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 I (pckList="") S pckList=$$TRNLNM^%ZFUNC("SCAU_PACKAGES") I (pckList="") Q $$TRNLNM^%ZFUNC("SCAU_CRTNS")
 ;
 ; temporary: if list already contains directory return as is
 I pckList["/" Q pckList
 ;
 N packageDirs S packageDirs=""
 N elm
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 F elm=1:1:$L(pckList,":") S packageDirs=$S((packageDirs=""):$$FILE^%TRNLNM($piece(pckList,":",elm),pslRoot),1:packageDirs_":"_$$FILE^%TRNLNM($piece(pckList,":",elm),pslRoot))
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 S packageDirs=$S((packageDirs=""):$$TRNLNM^%ZFUNC("SCAU_CRTNS"),1:packageDirs_":"_$$TRNLNM^%ZFUNC("SCAU_CRTNS"))
 Q packageDirs
 ;
 ; ---------------------------------------------------------------------
pslRoot() ; 
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 Q $$TRNLNM^%ZFUNC("SCAU_CRTNS")
 ;
 ; ---------------------------------------------------------------------
rtThrow(newArg) ; 
 N vo6 S vo6=newArg,$ZE="0,"_$ZPOS_","_vo6,$EC=",U1001,"
 Q  ; dead code
 ;
 ; ---------------------------------------------------------------------
run(cmd) ; 
 N vret
 N cma
 ;
 D cmdline(cmd,.cma,"","'")
 S vret=$$runCma(.cma,0) Q vret
 ;
 ; ---------------------------------------------------------------------
runCma(cma,bFA) ; true if compiling source array
 N vpc
  ; UGH!
 ;
 N pslroot S pslroot=$$pslRoot()
 ;
 N errCount S errCount=0
 ;
 D
 .	N $ET,$ES,$ZYER S $ZYER="ZE^UCGMR",$ZE="",$EC="",$ET="D:$TL>"_$TL_" rollback^vRuntime("_$TL_") Q:$Q&$ES """" Q:$ES  N voxMrk s voxMrk="_+$O(vobj(""),-1)_" G vCatch4^"_$T(+0)
 .	; deal with the source file-name
 .	I '($D(cma("$1"))#2) S $ZE="0,"_$ZPOS_","_"%PSL-E-UNDEF,No source file specified",$EC=",U1001,"
 .	;
 .	;   #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 .	I ($$PARSE^%ZFUNC(cma("$1"),"TYPE")="") S cma("$1")=cma("$1")_".psl"
 .	;
 .	;   #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 .	N sFile S sFile=$$PARSE^%ZFUNC(cma("$1"),"NAME")_$$PARSE^%ZFUNC(cma("$1"),"TYPE")
 .	I $L(sFile,".")>2 S $ZE="0,"_$ZPOS_","_"%PSL-E-MISMATCH,Invalid source file name,"_sFile,$EC=",U1001,"
 .	I sFile'=cma("$1") D
 ..		Q:bFA  Q:'($D(cma("output"))#2) 
 ..		I cma("output")=pslroot S $ZE="0,"_$ZPOS_","_"%PSL-E-MISMATCH,Invalid --output option",$EC=",U1001,"
 ..		Q 
 .	;
 .	N ucopts  D vcdmNew^PSLCC(.ucopts,"PSLCC")
 .	D setUcopts^PSLCC(.ucopts,$get(cma("ucopts"),""))
 .	;
 .	; Instantiate a PSLParser descendant based on the PSL Version
 .	N pslPrsr
 .	I $$getSetting^PSLCC(.ucopts,"PSL","Version")<3  D vcdmNew^PSLParser(.pslPrsr,"PSLParser",$piece(sFile,"."))
 .	E   K pslPrsr  D vcdmNew^PSLParser(.pslPrsr,"PSLParser",$piece(sFile,"."))
 .	;
 .	D loadSettings^PSLCC(.pslPrsr,.ucopts)
 .	;
 .	; deal with the other command line options
 .	;
 .	N elem S elem=$get(cma("element"))
 .	S $P(pslPrsr,"|",4)=elem
 .	;
 .	I ($D(cma("logfile"))#2) S pslPrsr("logfile")=cma("logfile")
 .	;
 .	N pckDirs S pckDirs=$$packageDirs($get(cma("pslroot")),$get(cma("packages")))
 .	;
 .	; locate the source file and instantiate the PSLTokenizer
 .	N modIO S modIO=$$vClVobj($ST,"IO")
 .	;
 .	I '$$locate^UCIO(modIO,pckDirs,":",cma("$1"),0) D
 ..		;
 ..		; "not found" is OK for Record descendants
 ..		I $$isRecord^PSLClass($piece(sFile,"."))=2 D
 ...			;
 ...			S $P(vobj(modIO,1),"|",1)=sFile
 ...			I '($D(cma("output"))#2) S cma("output")=pslroot
 ...			Q 
 ..		E  S $ZE="0,"_$ZPOS_","_"%PSL-E-UNDEF,source file not found,"_sFile,$EC=",U1001,"
 ..		Q 
 .	N tknzr  D vcdmNew^PSLTokenizer(.tknzr,"PSLTokenizer",modIO)
 .	;
 .	; Compile the module
 .	N target
 .	S pslPrsr("packageDirs")=pckDirs
 .	S errCount=$$run^PSLParser(.pslPrsr,.tknzr,.target)
 .	;
 .	I ($get(cma("output"),"-")="") K vobj(+$G(modIO)) Q  ; suppressed
 .	;
 .	; Get the target directory
 .	N targetDir S targetDir=$$targetDir(.pslPrsr,.cma,$P(vobj(modIO,1),"|",2))
 .	;
 .	; If run from array, pass back the target directory
 .	I bFA S cma("target")=targetDir
 .	;
 .	S vpc=errCount>0 K:vpc vobj(+$G(modIO)) Q:vpc  ; compilation failed
 .	;
 .	I $$toPslx^PSLParser(.pslPrsr,targetDir)=0
 .	I '(elem=""),$$getSetting^PSLCC(.pslPrsr,"boot","restrictionlevel",0)<1,$$runSysmap(.target,.pslPrsr,elem)=0
 .	I $$runTgt(.target,pslPrsr("moduleName"),targetDir,$$getSetting^PSLCC(.pslPrsr,"boot","restrictionlevel",0))=0
 .	;
 .	I ($D(cma("savepslgen"))#2) D storePslgen(.tknzr,.cma,targetDir)
 .	K vobj(+$G(modIO)) Q 
 Q errCount
 ;
 ; ---------------------------------------------------------------------
runSysmap(target,pslPrsr,elem) ; store SYSMAP and UCLREGEN
 I $$toSysmap^PSLParser(.pslPrsr,.target)=0
 ;
 I $piece(elem,"~",2)="Procedure" D
 .	N oldsig S oldsig="" N mod S mod=pslPrsr("moduleName")
 .	D
 ..		N $ET,$ES,$ZYER S $ZYER="ZE^UCGMR",$ZE="",$EC="",$ET="D:$TL>"_$TL_" rollback^vRuntime("_$TL_") Q:$Q&$ES """" Q:$ES  N voxMrk s voxMrk="_+$O(vobj(""),-1)_" G vCatch5^"_$T(+0)
 ..		S oldsig=$$vSIG^@mod
 ..		Q 
 .	I oldsig'=$piece(elem,"~",3) D SETRTN^UCLREGEN(mod)
 .	Q  ; end if DQ Procedure
 Q 0
 ;
 ; ---------------------------------------------------------------------
runTgt(target,mod,targetDir,nolink) ; write target source file and compile it
 ;
 N mName S mName=$translate(mod,"%","_")
 N fileIn S fileIn=targetDir_"/"_mName_".m"
 N ign S ign=$$fileWrite(fileIn,.target)
 ;
 N dirOut S dirOut=targetDir_"/obj"
 I 'nolink,$$isCompiler^UCGMCU(mod) S nolink=1
 ;
 ;  #ACCEPT CR=27800;PGM=Frans S.C. Witte;Date=2007-07-07;Group=BYPASS
 ;*** Start of code by-passed by compiler
 ZSYSTEM "test -d "_dirOut
 IF $ZSYSTEM SET dirOut=targetDir
 ZSYSTEM "${GTM_DIST}/mumps -o="_dirOut_"/"_mName_".o "_fileIn
 IF $ZSYSTEM DO rtThrow("%PSL-E-TARGET,target language compile failure")
 ;*** End of code by-passed by compiler ***
 ;
 Q 0
 ;
 ; ---------------------------------------------------------------------
storePsl(file,mod) ; store .psl file in default location
 N srcIo S srcIo=$$vClVobj($ST,"IO")
 S $P(vobj(srcIo,1),"|",1)=file
 ;
 N tknzr  D vcdmNew^PSLTokenizer(.tknzr,"PSLTokenizer",srcIo)
 N prsr  D vcdmNew^PSLParser(.prsr,"PSLParser",mod)
 ;
 S prsr("packageDirs")=$$packageDirs("","")
 ;
 N so N sec S sec="" N val S val=""
 D getBootOptions^UCGMCU(.so,3)
 F  S sec=$order(so(sec)) Q:(sec="")  D
 .	F  S val=$order(so(sec,val)) Q:(val="")  D
 ..		D addSetting^PSLCC(.prsr,sec,val,so(sec,val))
 ..		Q 
 .	Q 
 ;
 N ignPslx  D vcdmNew^PSLX(.ignPslx,"PSLX",mod)
 N err S err=$$pass0^PSLParser(.prsr,.ignPslx,0,.tknzr)
 ;
 I err>0 K vobj(+$G(srcIo)) Q ""
 ;
 N tgt S tgt=$$getPackageRoot^PSLParser(.prsr) S:'(tgt="") tgt=tgt_"/"
 S tgt=$$pslRoot()_"/"_tgt_mod_".psl"
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 N ign S ign=$$COPYFIL^%OSSCRPT(file,tgt)
 ;
 K vobj(+$G(srcIo)) Q tgt
 ;
 ; ---------------------------------------------------------------------
storePslx(file) ; store .pslx file in default location
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 N mod S mod=$$PARSE^%ZFUNC(file,"NAME")
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 N dir S dir=$$PARSE^%ZFUNC(file,"DIRECTORY")
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 N pslx  D vcdmNew^PSLX(.pslx,"PSLX",$$FILE^%TRNLNM(mod,dir))
 ;
 D classOnly^PSLX(.pslx)
 I '($D(pslx("pslCls",mod))#2) Q ""
 ;
 N ocd S ocd=pslx("pslCls",mod)
 N tgt S tgt=$$pslRoot()_"/"_$$getPackageRoot^PSLClass(.ocd)
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 N ign S ign=$$COPYFIL^%OSSCRPT(file,tgt)
 ;
 Q tgt_"/"_mod_".pslx"
 ;
storePslgen(tknzr,cma,targetDir) ; store .pslgen file in requested location
 ;
 N dir S dir=cma("savepslgen")
 N sub S sub=""
 ;
 I (dir="") S dir=targetDir
 ;
 N pslgenIO S pslgenIO=$$vClVobj($ST,"IO")
 ;
 S $P(vobj(pslgenIO,1),"|",1)=cma("$1")_"gen" ; make .pslgen
 S $P(vobj(pslgenIO,1),"|",2)=dir
 S $P(vobj(pslgenIO,1),"|",3)="NEWVERSION"
 S $P(vobj(pslgenIO,1),"|",5)=1048575
 ;
 D
 .	N $ET,$ES,$ZYER S $ZYER="ZE^UCGMR",$ZE="",$EC="",$ET="D:$TL>"_$TL_" rollback^vRuntime("_$TL_") Q:$Q&$ES """" Q:$ES  N voxMrk s voxMrk="_+$O(vobj(""),-1)_" G vCatch6^"_$T(+0)
 .	;
 .	D open^UCIO(pslgenIO,$T(+0),"storePslgen","pslgenIO")
 .	F  S sub=$order(tknzr("srcCode",sub)) Q:(sub="")  D write^UCIO(pslgenIO,tknzr("srcCode",sub))
 .	D close^UCIO(pslgenIO)
 .	Q 
 ;
 K vobj(+$G(pslgenIO)) Q 
 ;
 ; ---------------------------------------------------------------------
toUcopts(srcdir,mod,commands) ; write commands(,) to file srcdir_ mod_ "_"_ %ProcessID_ ".ini"
 N vret
 I (srcdir="") S srcdir=$$cmp0dir("")
 I (mod="") S mod=$$cmp0mod()
 ;
 N rIO S rIO=$$vClVobj($ST,"IO")
 S $P(vobj(rIO,1),"|",1)=srcdir_mod_"_"_$J_".ini" S $P(vobj(rIO,1),"|",3)="NEWVERSION"
 D open^UCIO(rIO,$T(+0),"toUcopts","rIO")
 ;
 N l1 S l1="" N l2 S l2="" N val
 F  S l1=$order(commands(l1)) Q:(l1="")  D
 .	F  S l2=$order(commands(l1,l2)) Q:(l2="")  D
 ..		I l1="Options" D write^UCIO(rIO," #OPTION "_l2_" "_commands(l1,l2)) Q 
 ..		I (",OPTIMIZE,WARN,INFO,"[(","_l1_",")) D write^UCIO(rIO," #"_l1_" "_l2_" "_commands(l1,l2)) Q 
 ..		S val=commands(l1,l2)
 ..		I l1="PSL" D write^UCIO(rIO," #PSL "_l2_" "_$S((val=+val):val,1:$S(val'["""":""""_val_"""",1:$$QADD^%ZS(val,"""")))) Q 
 ..		D write^UCIO(rIO," #DEFINE "_l1_"."_l2_" "_$S((val=+val):val,1:$S(val'["""":""""_val_"""",1:$$QADD^%ZS(val,""""))))
 ..		Q 
 .	Q 
 D close^UCIO(rIO)
 S vret=$P(vobj(rIO,1),"|",1) K vobj(+$G(rIO)) Q vret
 ;
 ; ---------------------------------------------------------------------
targetDir(pslPrsr,cma,default) ; Support function to obtain the target directory
 N targetDir
 I ($D(cma("targetdir"))#2) D
 .	S targetDir=cma("targetdir")
 .	I '($E(targetDir,$L(targetDir))="/") S targetDir=targetDir_"/"
 .	Q 
 E  I ($D(cma("output"))#2) D
 .	S targetDir=cma("output")
 .	I '($E(targetDir,$L(targetDir))="/") S targetDir=targetDir_"/"
 .	S targetDir=targetDir_$$getPackageRoot^PSLParser(.pslPrsr)
 .	Q 
 E  S targetDir=default
 Q targetDir
 ;
 ; ---------------------------------------------------------------------
zlink(mod) ; try to ZLINK the module and tell if it succeeded
 ;  #ACCEPT CR=27800;PGM=Frans S.S. Witte;Date=2007-07-07;Group=BYPASS
 ;*** Start of code by-passed by compiler
 NEW $ZTRAP
 SET $ZTRAP="QUIT 0"
 ZLINK $TRANSLATE(mod,"%","_")
 ;*** End of code by-passed by compiler ***
 Q 1
 ;
 ;  #OPTION ResultClass ON
vSIG() ; 
 Q "61374^48893^Frans S.C. Witte^36063" ; Signature - LTD^TIME^USER^SIZE
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
vCatch6 ; Error trap
 ;
 N xIO,$ET,$ES S xIO=$ZE,$EC="",$ET="Q",$ZE=""
 I $P(xIO,",",3)'["IOOPEN" D close^UCIO(pslgenIO)
 S $ZE=xIO,$EC=",U1001,"
 D ZX^UCGMR(voxMrk) Q 
 ;
vCatch5 ; Error trap
 ;
 N vIgnore,$ET,$ES S vIgnore=$ZE,$EC="",$ET="Q",$ZE=""
 ; ignore all exceptions
 D ZX^UCGMR(voxMrk) Q 
 ;
vCatch4 ; Error trap
 ;
 N xCma,$ET,$ES S xCma=$ZE,$EC="",$ET="Q",$ZE=""
 N txt S txt=$P(xCma,",",3)_": ("_$P(xCma,",",2)_") "_$P(xCma,",",4)
 D log(.cma,txt)
 S errCount=errCount+1
 D ZX^UCGMR(voxMrk) Q 
 ;
vCatch3 ; Error trap
 ;
 N xIo,$ET,$ES S xIo=$ZE,$EC="",$ET="Q",$ZE=""
 I $P(xIo,",",3)'["%PSL-E-IOOPEN" D close^UCIO(io)
 K cma("logfile")
 D ZX^UCGMR(voxMrk) Q 
 ;
vCatch2 ; Error trap
 ;
 N xIO,$ET,$ES S xIO=$ZE,$EC="",$ET="Q",$ZE=""
 I $P(xIO,",",3)'["IOOPEN" D close^UCIO(rIO)
 S $ZE=xIO,$EC=",U1001,"
 D ZX^UCGMR(voxMrk) Q 
 ;
vCatch1 ; Error trap
 ;
 N xIO,$ET,$ES S xIO=$ZE,$EC="",$ET="Q",$ZE=""
 D close^UCIO(rIO)
 D ZX^UCGMR(voxMrk) Q 
