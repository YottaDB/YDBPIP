 ; 
 ; **** Routine compiled from unknown source ****
 ; 
 ; 02/11/2009 16:02 - pip
 ; 
ZUCBOOTT ; PSL Bootstrap Utilities - Target site
 WRITE !!,$T(+1),!!
 ;
 WRITE "The public subroutines of this routine will help prepare the",!
 WRITE "current GT.M and the possibly associated RDB environment for",!
 WRITE "initial environment creation. This will destroy all data and",!
 WRITE "most of the routines !!",!!
 ;
 WRITE "Do not call these entry points unless you are sure they do",!
 WRITE "what you intended.",!!
 ;
 WRITE "run^ZUCBOOTT() can be called from GT.M, including the GT.M",!
 WRITE "direct mode shell, as:",!
 WRITE "  do run^ZUCBOOTT(options)",!!
 ;
 WRITE "SHELL^ZUCBOOTT can be called from a unix command shell as:",!
 WRITE "  mumps -run SHELL^ZUCBOOTT options",!!
 ;
 N lnr
 N lnc
 N run S run="" ; trick compiler (it thinks run is a variable)
 F lnr=1:1 S lnc=$$vStrTrim($translate($T(run+lnr),$char(9)," "),0," ") Q:$E(lnc,1)'=";"  D
 .	I ($E(lnc,1,3)="; -") WRITE ?2,$E(lnc,2,1048575),! Q 
 .	WRITE ?4,$E(lnc,2,1048575),!
 .	Q 
 Q 
 ;
 ; ---------------------------------------------------------------------
addKeep(keep,sDir,sFile) ; name of file
 N rIo S rIo=$$vClVobj($ST,"IO")
 S $P(vobj(rIo,1),"|",2)=sDir
 S $P(vobj(rIo,1),"|",1)=sFile
 S $P(vobj(rIo,1),"|",3)="READ"
 S $P(vobj(rIo,1),"|",5)=32767
 ;
 D open^UCIO(rIo,$T(+0),"addKeep","rIo")
 ;
 D
 .	N $ET,$ES,$ZYER S $ZYER="ZE^UCGMR",$ZE="",$EC="",$ET="D:$TL>"_$TL_" rollback^vRuntime("_$TL_") Q:$Q&$ES """" Q:$ES  N voxMrk s voxMrk="_+$O(vobj(""),-1)_" G vCatch1^"_$T(+0)
 .	;
 .	N line
 .	N pslSupplied S pslSupplied=$$getPslList()
 .	N rtn
 .	;
 .	; Record.bypassSave() does not provide TP for dynamic instances
 .	F  D
 ..		S line=$$read^UCIO(rIo) ; will throw eof exception
 ..		S rtn=$piece(line,",")
 ..		I $E(rtn,1)="""" S rtn=$$QSUB^%ZS(rtn,"""")
 ..		;
 ..		I $E(rtn,1)="%" Q 
 ..		I rtn[" " Q 
 ..		;if pslSupplied.contains( rtn) quit
 ..		;
 ..		S keep=$S(((","_keep_",")[(","_rtn_",")):keep,1:$S((keep=""):rtn,1:keep_","_rtn))
 ..		Q 
 .	Q 
 K vobj(+$G(rIo)) Q $S(((","_keep_",")[",UCGMCU,"):keep,1:$S((keep=""):"UCGMCU",1:keep_","_"UCGMCU"))
 ;
 ; ---------------------------------------------------------------------
bootFrom(bootdir) ; bootstrap directory
 ; Step 1 ==============================================================
 N elm
 N mod N savZROU N txt
 N psl
 ;
 ;  #ACCEPT DATE=2007-07-10;CR=27800;PGM=FSCW;GROUP=BYPASS;REASON=$ZROUTINES
 ;*** Start of code by-passed by compiler
 SET savZROU=$ZROUTINES
 IF $PIECE($ZROUTINES," ")'=bootdir SET $ZROUTINES=bootdir_" "_$ZROUTINES
 ;*** End of code by-passed by compiler ***
 ;
 ; Step 2 ==============================================================
 N ign S ign=$$COPYFIL^%OSSCRPT(bootdir_"/*.m",$$SCAU^%TRNLNM("MRTNS"))
 ;
 ; step 3 ==============================================================
 S psl=$$getCls^UCGMCU("pslx")
 F elm=1:1:$S((psl=""):0,1:$L(psl,",")) D
 .	S mod=$piece(psl,",",elm)
 .	N $ET,$ES,$ZYER S $ZYER="ZE^UCGMR",$ZE="",$EC="",$ET="D:$TL>"_$TL_" rollback^vRuntime("_$TL_") Q:$Q&$ES """" Q:$ES  N voxMrk s voxMrk="_+$O(vobj(""),-1)_" G vCatch2^"_$T(+0)
 .	S txt=mod_".pslx copied to "_$$storePslx^PSLC(bootdir_"/"_mod_".pslx")
 .	WRITE txt,!
 .	Q 
 ;
 ; Step 4 ==============================================================
 S psl=$$getList^UCGMCU("Compiler")
 ;
 F elm=1:1:$S((psl=""):0,1:$L(psl,",")) D
 .	S mod=$piece(psl,",",elm)
 .	N $ET,$ES,$ZYER S $ZYER="ZE^UCGMR",$ZE="",$EC="",$ET="D:$TL>"_$TL_" rollback^vRuntime("_$TL_") Q:$Q&$ES """" Q:$ES  N voxMrk s voxMrk="_+$O(vobj(""),-1)_" G vCatch3^"_$T(+0)
 .	WRITE $$bootLoad(mod,bootdir)," loaded into DBTBL25*",!
 .	;
 .	S txt=mod_".psl copied to "_$$storePsl^PSLC(bootdir_"/"_mod_".psl",mod)
 .	WRITE txt,!
 .	Q 
 ;
 ; Step 5 ==============================================================
 ;  #ACCEPT DATE=2007-07-10;CR=27800;PGM=FSCW;GROUP=BYPASS;REASON=$ZROUTINES
 ;*** Start of code by-passed by compiler
 IF $ZROUTINES'=savZROU SET $ZROUTINES=savZROU
 ZLINK "UCGMCU"
 ;*** End of code by-passed by compiler ***
 ;
 ; Step 6 ==============================================================
 D linkAll^UCGMCU() D boot^UCGMCU()
 Q 
 ;
 ; =====================================================================
bootAll(sDataDir) ; .DAT file directory
 ;
 D boot^UCGMCU($get(sDataDir))
 D bootPhs2()
 Q 
 ;
 ; =====================================================================
bootPhs2() ; Perform a Phase2 bootstrap
 ;  #ACCEPT CR=none;Date=2006-10-17;PGM=Frans S.C. Witte;Group=GLOBAL
 K ^TMPDQS($J)
 ;
 D ^TBXDQINT
 ;
 N elm S elm=""
 ;
 ;  #ACCEPT CR=none;Date=2006-10-17;PGM=Frans S.C. Witte;Group=GLOBAL
 F  S elm=$order(^TMPDQS($J,"phase2","procedure",elm)) Q:(elm="")  D bootProc^UCGMCU($piece(elm,"."))
 ;
 ;  #ACCEPT CR=none;Date=2006-10-17;PGM=Frans S.C. Witte;Group=GLOBAL
 F  S elm=$order(^TMPDQS($J,"phase2","filer",elm)) Q:(elm="")  D COMPILE^DBSFILB($piece(elm,"."))
 ;
 ;  #ACCEPT CR=none;Date=2006-10-17;PGM=Frans S.C. Witte;Group=GLOBAL
 K ^TMPDQS($J)
 ;
 Q 
 ;
 ; =====================================================================
bootDat(tbl,dir) ; load .DAT file into table using DBSDYNRA for DBI
 ; ---------------------------------------------------------------------
 TS (vobj):transactionid="CS"
 ;
 D ^SQL("DELETE FROM "_tbl)
 ;
 N rec S rec=$$new^DBSDYNRA(tbl)
 ;
 N rIo S rIo=$$vClVobj($ST,"IO")
 S $P(vobj(rIo,1),"|",1)=tbl_".DAT"
 S $P(vobj(rIo,1),"|",2)=dir
 S $P(vobj(rIo,1),"|",5)=32767
 S $P(vobj(rIo,1),"|",3)="READ"
 ;
 D open^UCIO(rIo,$T(+0),"bootDat","rIo")
 ;
 N sHdr S sHdr=$$read^UCIO(rIo)
 N sDat
 N nC
 ;
 D
 .	N $ET,$ES,$ZYER S $ZYER="ZE^UCGMR",$ZE="",$EC="",$ET="D:$TL>"_$TL_" rollback^vRuntime("_$TL_") Q:$Q&$ES """" Q:$ES  N voxMrk s voxMrk="_+$O(vobj(""),-1)_" G vCatch4^"_$T(+0)
 .	F  D
 ..		S sDat=$$read^UCIO(rIo)
 ..		F nC=1:1:$L(sHdr,$char(9)) D propSet^DBSDYNRA(rec,$piece(sHdr,$char(9),nC),$piece(sDat,$char(9),nC))
 ..		;do bypassSave^DBSDYNRA(rec)
 ..		;do rec.setMode(0)
 ..		Q 
 .	Q 
  TC:$TL 
 ;
 K vobj(+$G(rIo)),vobj(+$G(rec)) Q 
 ;
 ; =====================================================================
bootLoad(mod,dir) ; load .psl file into DBTBL25 and DBTBL25D
 N vTp
 ; ---------------------------------------------------------------------
 TS (vobj):transactionid="CS"
 ;
 N dq25,vop1,vop2,vop3 S vop2="SYSDEV",vop1=mod,dq25=$$vRCgetRecord1Opt^RecordDBTBL25("SYSDEV",mod,0,.vop3)
 ;
 I $G(vop3) D
 .	I $P(dq25,$C(124),2)'=mod S $ZE="0,"_$ZPOS_","_"%PSL-E-MISMATCH, names don't match",$EC=",U1001,"
 .	 N V1 S V1=mod D vDbDe1()
 .	Q 
 E  D
 .  S $P(dq25,$C(124),2)=mod
 .  S $P(dq25,$C(124),9)=1
 .  S $P(dq25,$C(124),1)="loaded by "_$T(+0)
 .	Q 
  S $P(dq25,$C(124),3)=$P($H,",",1)
  S $P(dq25,$C(124),5)=$P($H,",",2)
 ;
 N rIO S rIO=$$vClVobj($ST,"IO")
 S $P(vobj(rIO,1),"|",1)=dir_"/"_mod_".psl"
 S $P(vobj(rIO,1),"|",3)="READ"
 S $P(vobj(rIO,1),"|",5)=1980+1
 ;
 D open^UCIO(rIO,$T(+0),"bootLoad","rIO")
 ;
 N line,vop4,vop5,vop6,vop7 S line="",vop7=0 S vop6="SYSDEV" S vop5=mod S vop4=1
 N hdr
 ;
 D
 .	N $ET,$ES,$ZYER S $ZYER="ZE^UCGMR",$ZE="",$EC="",$ET="D:$TL>"_$TL_" rollback^vRuntime("_$TL_") Q:$Q&$ES """" Q:$ES  N voxMrk s voxMrk="_+$O(vobj(""),-1)_" G vCatch5^"_$T(+0)
 .	;
 .	; see if first line is the header-line
 .	S hdr=$$read^UCIO(rIO)
 .	I $E(hdr,1,18)["DO NOT MODIFY" D
 ..	  S $P(dq25,$C(124),1)=$E($piece(hdr,"|"),18,$L(hdr))
 ..	  S $P(dq25,$C(124),9)=+$piece(hdr,"|",9)
 ..		Q 
 .	E  D
 ..	  S $P(line,$C(12),1)=hdr
 ..		S vop7=0 S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" S ^DBTBL(vop6,25,vop5,vop4)=line S vop7=1 TC:vTp  
 ..	  S vop4=2
 ..		Q 
 .	;
 .	F  D
 ..	  S $P(line,$C(12),1)=$$read^UCIO(rIO)
 ..		S vop7=0 S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" S ^DBTBL(vop6,25,vop5,vop4)=line S vop7=1 TC:vTp  
 ..	  S vop4=vop4+1
 ..		Q 
 .	Q 
 S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" S ^DBTBL(vop2,25,vop1)=$$RTBAR^%ZFUNC(dq25) S vop3=1 TC:vTp  
  TC:$TL 
 ;
 K vobj(+$G(rIO)) Q mod
 ;
 ; -------------------------------------------------------------------------
cmdline(sCmdline,aOpts,sArgless,sQuote) ; quote characer, default: double quote
 ;
 N sArg N sOpt
 N nArgs S nArgs=0
 ;
 I ($get(sQuote)="") S sQuote=""""
 S sArgless=$get(sArgless)
 ;
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
 .	E  D  ; -o value
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
cmp(m,name,dir) ; 
 ;
 N IO S IO=$$FILE^%TRNLNM(name_".m",dir)
 I $$FILE^%ZOPEN(IO,"NEWVERSION",0,32767) D
 .	USE IO
 .	N sub S sub=""
 .	F  S sub=$order(m(sub)) Q:sub=""  WRITE m(sub),!
 .	CLOSE IO
 .	;
 .	N DIR S DIR=dir ; required by COMPILE^%ZRTNCMP
 .	N RTN S RTN=name ; required by COMPILE^%ZRTNCMP
 .	D COMPILE^%ZRTNCMP
 .	Q 
 Q 
 ;
 ; ---------------------------------------------------------------------
cuvals(cuvals) ; cuvals(name) = value (*1) /MECH=REFARR:W
 N rIo S rIo=$$vClVobj($ST,"IO")
 S $P(vobj(rIo,1),"|",2)=$$SCAU^%TRNLNM("DIR")
 S $P(vobj(rIo,1),"|",1)="CUVAR.DAT"
 S $P(vobj(rIo,1),"|",3)="READ"
 S $P(vobj(rIo,1),"|",5)=32767
 ;
 D open^UCIO(rIo,$T(+0),"cuvals","rIo")
 ;
 N hdr S hdr=$$read^UCIO(rIo)
 N dat S dat=$$read^UCIO(rIo)
 ;
 D close^UCIO(rIo)
 ;
 N cnr
 F cnr=1:1:$L(hdr,$char(9)) S cuvals($piece(hdr,$char(9),cnr))=$piece(dat,$char(9),cnr)
 K vobj(+$G(rIo)) Q 
 ;
 ; ---------------------------------------------------------------------
cuvar(cuvals) ; cuvals(name) = value (*1) /MECH=REFARR:RW
 ;
 N col S col="" ; column name iterator
 N ln S ln=0 ; line number in src()
 N src ; CUVAR.proc source code
 ;
 ; force values for %LIBS (unconditionally) and %VN (conditionally)
 S cuvals("%LIBS")="SYSDEV"
 I '($D(cuvals(%VN))#2),($D(%VN)#2) S cuvals("%VN")=%VN
 ;
 ; create routine and .DAT file by iterating over the array
 S ln=ln+1 S src(ln)="CUVAR(col) ; bootstrap version"
 ;
 F  S col=$order(cuvals(col)) Q:col=""  D
 .	S ln=ln+1
 .	S src(ln)=" IF col="""_col_""" QUIT """_cuvals(col)_""""
 .	Q 
 S ln=ln+1 S src(ln)=" IF col[""|"" QUIT $PIECE(col,""|"",2)"
 S ln=ln+1 S src(ln)=" QUIT """""
 ;
 D cmp(.src,"CUVAR",$$SCAU^%TRNLNM("CRTNS"))
 ;
 Q 
 ;
 ; ---------------------------------------------------------------------
dataImp(tbl,dir) ; 
 N file S file=$$vClVobj($ST,"IO")
 ;
 ; set file characterisitcs and open
 S $P(vobj(file,1),"|",2)=dir
 S $P(vobj(file,1),"|",1)=tbl_".DAT"
 S $P(vobj(file,1),"|",3)="READ"
 S $P(vobj(file,1),"|",5)=32767
 D open^UCIO(file,$T(+0),"dataImp","file")
 ;
 N collist S collist=$$read^UCIO(file)
 ;
 N $ET,$ES,$ZYER S $ZYER="ZE^UCGMR",$ZE="",$EC="",$ET="D:$TL>"_$TL_" rollback^vRuntime("_$TL_") Q:$Q&$ES """" Q:$ES  N voxMrk s voxMrk="_+$O(vobj(""),-1)_" G vCatch6^"_$T(+0)
 ;
 N line
 N rec
 N colnr
 N colnm
 ;
 ; Record.bypassSave() does not provide TP for dynamic instances
 TS (vobj):transactionid="BA"
 F  D
 .	S line=$$read^UCIO(file) ; will throw eof exception
 .  K vobj(+$G(rec)) S rec=$$vReNew($ST,tbl)
 .	;
 .	F colnr=1:1:$L(collist,$char(9)) S colnm=$piece(collist,$char(9),colnr)  D propSet^DBSDYNRA(rec,colnm,$piece(line,$char(9),colnr),0,0)
 .	;
 .	D bypassSave^DBSDYNRA(rec)
 .	Q 
 K vobj(+$G(file)),vobj(+$G(rec)) Q 
 ;
 ; ---------------------------------------------------------------------
delGbl(keep) ; Globals to keep
 N %ZG ; %GSEL input and output
 ;
 S %ZG="*" D CALL^%GSEL
 ;
 N gbl S gbl=""
 F  S gbl=$order(%ZG(gbl)) Q:gbl=""  D
 .	I $E(gbl,2)="%" Q 
 .	;
 .	I ((","_keep_",")[(","_$E(gbl,2,1048575)_",")) Q  ; Excluded
 .	;
 .	;   #ACCEPT DATE=2005-10-18;CR=15592;PGM=FSCW;REASON=KILL @var
 .	K @gbl
 .	Q 
 Q 
 ;
 ; ---------------------------------------------------------------------
delRtn(keep,bMrtns) ; Keep routines in MRTNS?
 N %ZI ; %RSEL input selection
 N %ZR ; %RSEL output
 N CRTNS S CRTNS=$$PARSE^%ZFUNC($$FILE^%TRNLNM("x.y",$$SCAU^%TRNLNM("CRTNS")),"DIR")
 N MRTNS S MRTNS=$$PARSE^%ZFUNC($$FILE^%TRNLNM("x.y",$$SCAU^%TRNLNM("MRTNS")),"DIR")
 N PRTNS S PRTNS=$$PARSE^%ZFUNC($$FILE^%TRNLNM("x.y",$$SCAU^%TRNLNM("PRTNS")),"DIR")
 ;
 S keep=$S(((","_keep_",")[",ORACON,"):keep,1:$S((keep=""):"ORACON",1:keep_","_"ORACON"))
 ;
 S %ZI("*")="" D INT^%RSEL
 ;
 N pslSupplied S pslSupplied=$$getPslList()
 N rtn S rtn=""
 F  S rtn=$order(%ZR(rtn)) Q:rtn=""  D
 .	I rtn=$T(+0) Q 
 .	I $E(rtn,1)="%" Q 
 .	I ((","_pslSupplied_",")[(","_rtn_",")) Q 
 .	;
 .	N file S file=%ZR(rtn)_rtn_".m"
 .	N path S path=$$PARSE^%ZFUNC(file,"DIR")
 .	;
 .	I ((","_keep_",")[(","_rtn_",")) Q  ; Excluded by routinename
 .	I bMrtns,path=MRTNS Q  ; Excluded by location
 .	;
 .	; standard derived routine: delete
 .	I path=PRTNS D DEL^%ZRTNDEL(rtn) Q 
 .	I path=MRTNS D DEL^%ZRTNDEL(rtn) Q 
 .	I path=CRTNS D DEL^%ZRTNDEL(rtn) D DELFILE^%ZRTNDEL(path_rtn_".proc") Q 
 .	;
 .	WRITE path_rtn," not deleted",!
 .	Q 
 Q 
 ;
 ; ---------------------------------------------------------------------
getPslList() ; 
 N psl S psl=$$getList^UCGMCU("Insensitive")
 S psl=psl_","_$$getList^UCGMCU("Dictionary")
 S psl=psl_","_$$getList^UCGMCU("Object")
 S psl=psl_","_$$getList^UCGMCU("Upgrade")
 Q psl
 ;
 ; ---------------------------------------------------------------------
msg() ; 
 N src
 N ln S ln=0
 ;
 S ln=ln+1 S src(ln)="MSG(nr,p1) ; bootstrap version"
 S ln=ln+1 S src(ln)=" NEW msg SET msg=""Message #""_nr_"" in bootstrap mode"""
 S ln=ln+1 S src(ln)=" IF $DATA(p1)#2 SET msg=msg_""; p1=""_$$QADD^%ZS(p1,$CHAR(34))"
 S ln=ln+1 S src(ln)=" QUIT msg"
 ;
 D cmp(.src,"MSG",$$SCAU^%TRNLNM("CRTNS"))
 Q 
 ;
 ; ---------------------------------------------------------------------
noiso() ; 
 N src
 N ln S ln=0
 ;
 S ln=ln+1 S src(ln)="NOISO ; bootstrap version"
 S ln=ln+1 S src(ln)=" QUIT"
 ;
 D cmp(.src,"NOISO",$$SCAU^%TRNLNM("CRTNS"))
 Q 
 ;
 ; ---------------------------------------------------------------------
run(ZCMDLINE) ; command line options
 ;
 ; The following options are supported:
 ; --%VN=versionid
 ; Specifies the Profile version at the target.
 ; If not supplied, CUVAR.%VN of the site where ZUCBOOTT itself was
 ; compiled will be used.
 ;
 ; --cuvar
 ; Do not generate a boot version of routine CUVAR, but use the
 ; existing version. Supply this option only if:
 ; * the target environment contains a routine CUVAR, and
 ; * the version of CUVAR is for the correct database backend
 ;
 ; --global=globalname1,globalname2
 ; Specifies the names of the globals that shall not be KILLed.
 ; Specify names without the leading '^'.
 ; There is no need to include %-globals, because they will never
 ; be killed.
 ;
 ; -l
 ; Local reboot only. Do not delete any routine from MRTNS and do
 ; not delete any of the PSL/SQL/DQ routines called in phase 1 or
 ; phase 2. This option forces --cuvar --msg --noiso
 ;
 ; --msg
 ; Do not generate a boot version of routine MSG, but use the
 ; existing version. Supply this option only if:
 ; * the target environment contains a routine MSG, and
 ; * the version of MSG is for the correct database backend
 ;
 ; --noiso
 ; Do not generate a boot version of routine NOISO, but use the
 ; existing version. Supply this option only if:
 ; * the target environment contains a routine CUVAR, and
 ; * the version of NOISO is for the correct database backend
 ;
 ; --routine=fullfilename1.csv,fullfilename2.csv
 ; Specifies the names of the files that contain the routines that
 ; shall not be deleted. Each file shall contain lines with comma
 ; separated values, with the routine name in the first column.
 ; Note that the xxx.rzl.csv files created by ZUCBOOTA meet these
 ; criteria.
 ; The filename shall include the full path.
 ;
 N cmds ; command line options (decomposed)
 N elm ; List iterator
 N file ; filename
 N path ; directory path to file
 N %VN ; version number
 ;
 ; get command line options
 D cmdline(ZCMDLINE,.cmds,"l")
 ;
 ; get rid of unsupported options
 N opt S opt=""
 F  S opt=$order(cmds(opt)) Q:opt=""  D
 .	I (",%VN,cuvar,global,l,msg,noiso,routine,"[(","_opt_",")) Q 
 .	WRITE "Unknown option "_opt,!
 .	K cmds(opt)
 .	Q 
 ;
 ; no (valid) options, may be unintended call
 Q:$D(cmds)'=10 
 ;
 ; standardize options
 S cmds("l")=($D(cmds("l"))#2)
 ;
 S %VN=$get(cmds("%VN"),"7.0")
 ;
 N keepFiles S keepFiles=$get(cmds("routine")) ; List of filenames
 N keepRtns S keepRtns="" ; List of routines
 ;
 F elm=1:1:$S((keepFiles=""):0,1:$L(keepFiles,",")) D
 .	S file=$piece(keepFiles,",",elm)
 .	S path=$$PARSE^%ZFUNC(file,"DIR")
 .	I file[path S file=$E(file,$L(path)+1,1048575)
 .	S keepRtns=$$addKeep(keepRtns,path,file)
 .	Q 
 ;
 I cmds("l") D
 .	N cmp S cmp=$$getPslList()
 .	F elm=1:1:$S((cmp=""):0,1:$L(cmp,",")) S keepRtns=$S(((","_keepRtns_",")[(","_$piece(cmp,",",elm)_",")):keepRtns,1:$S((keepRtns=""):$piece(cmp,",",elm),1:keepRtns_","_$piece(cmp,",",elm)))
 .	F opt="cuvar","msg","noiso" S cmds(opt)=""
 .	Q 
 ;
 ; cannot boot from a really empty environment !!
 I (keepRtns="") WRITE "%PSL-W-ABORT: No routines to save -- unable to boot",! Q 
 ;
 I '($D(cmds("cuvar"))#2) D
 .	WRITE "%PSL-I-CREATE: routine CUVAR",!
 .	N cuvar
 .	D cuvals(.cuvar)
 .	D cuvar(.cuvar)
 .	Q 
 I '($D(cmds("msg"))#2) WRITE "%PSL-I-CREATE: routine MSG",! D msg()
 I '($D(cmds("noiso"))#2) WRITE "%PSL-I-CREATE: routine NOISO",! D noiso()
 ;
 ; CUVAR, MSG, and NOISO are needed as present (original or new)
 S keepRtns=$S(((","_keepRtns_",")[",CUVAR,"):keepRtns,1:$S((keepRtns=""):"CUVAR",1:keepRtns_","_"CUVAR"))
 S keepRtns=$S(((","_keepRtns_",")[",MSG,"):keepRtns,1:$S((keepRtns=""):"MSG",1:keepRtns_","_"MSG"))
 S keepRtns=$S(((","_keepRtns_",")[",NOISO,"):keepRtns,1:$S((keepRtns=""):"NOISO",1:keepRtns_","_"NOISO"))
 ;
 ; If at least one required routine is missing,
 ; then abort before deleting anything.
 N bAbort S bAbort=0
 F elm=1:1:$S((keepRtns=""):0,1:$L(keepRtns,",")) S file=$piece(keepRtns,",",elm) I '$$VALID^%ZRTNS(file) WRITE "missing routine ",file,".m",! S bAbort=1
 I bAbort WRITE "%PSL-W-ABORT: Missing required routine",! Q 
 ;
 WRITE "%PSL-I-DELETE: removing globals",!
 D delGbl($get(cmds("global")))
 ;
 WRITE "%PSL-I-DELETE: deleting routines",!
 D delRtn(keepRtns,cmds("l"))
 ;
 WRITE "%PSL-I-OK: environment ready for initial install",!
 Q 
 ;
 ; ---------------------------------------------------------------------
SHELL ; 
 ;  #ACCEPT DATE=2005-10-18;CR=15592;PGM=FSCW;GROUP=BYPASS;REASON=$ZCMDLINE
 ;*** Start of code by-passed by compiler
 DO run($ZCMDLINE)
 ;*** End of code by-passed by compiler ***
 Q 
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
vDbDe1() ; DELETE FROM DBTBL25D WHERE %LIBS='SYSDEV' and PROCID = :V1
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 N v1 N v2 N v3
 TS (vobj):transactionid="CS"
 N vRs,vos1,vos2,vos3,vos4 S vRs=$$vOpen1()
 F  Q:'$$vFetch1()  D
 .	S v1=$P(vRs,$C(9),1) S v2=$P(vRs,$C(9),2) S v3=$P(vRs,$C(9),3)
 .	;     #ACCEPT CR=18163;DATE=2006-01-09;PGM=FSCW;GROUP=BYPASS
 .	;*** Start of code by-passed by compiler
 .	ZWI ^DBTBL(v1,25,v2,v3)
 .	;*** End of code by-passed by compiler ***
 .	Q 
  TC:$TL 
 Q 
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
vOpen1() ; %LIBS,PROCID,SEQ FROM DBTBL25D WHERE %LIBS='SYSDEV' AND PROCID = :V1
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
vL1a4 S vos4=$O(^DBTBL("SYSDEV",25,vos3,vos4),1) I vos4="" G vL1a0
 Q
 ;
vFetch1() ;
 ;
 ;
 I vos1=1 D vL1a4
 I vos1=2 S vos1=1
 ;
 I vos1=0 S vRs="" Q 0
 ;
 S vRs="SYSDEV"_$C(9)_vos3_$C(9)_$S(vos4=vos2:"",1:vos4)
 ;
 Q 1
 ;
vReNew(vS,vTbl) ; new Record
 ;
 new vT,vXcode
 set vT=$$getPslTbl^UCXDD(vTbl,0)
 set vXcode=$$getNewCode^UCXDD(vT,"vOid",0,0) xecute vXcode
 quit vOid
 ;
vCatch6 ; Error trap
 ;
 N ioErr,$ET,$ES S ioErr=$ZE,$EC="",$ET="Q",$ZE=""
 I $P(ioErr,",",3)="%PSL-E-IOEOF" D
 .	  TC:$TL 
 .		Q 
 E   TRO:$TL>0 
 D close^UCIO(file)
 D ZX^UCGMR(voxMrk) Q 
 ;
vCatch5 ; Error trap
 ;
 N xIO,$ET,$ES S xIO=$ZE,$EC="",$ET="Q",$ZE=""
 D close^UCIO(rIO)
 I $P(xIO,",",3)'="%PSL-E-IOEOF"  TRO:$TL>0  S $ZE=xIO,$EC=",U1001,"
 D ZX^UCGMR(voxMrk) Q 
 ;
vCatch4 ; Error trap
 ;
 N xIo,$ET,$ES S xIo=$ZE,$EC="",$ET="Q",$ZE=""
 D close^UCIO(rIo)
 I $P(xIo,",",3)'="%PSL-E-IOEOF"  TRO:$TL>0  S $ZE=xIo,$EC=",U1001,"
 D ZX^UCGMR(voxMrk) Q 
 ;
vCatch3 ; Error trap
 ;
 N vEx,$ET,$ES S vEx=$ZE,$EC="",$ET="Q",$ZE=""
 WRITE mod," NOT loaded (",$P(vEx,",",3),": ",$P(vEx,",",4),")",!
 D ZX^UCGMR(voxMrk) Q 
 ;
vCatch2 ; Error trap
 ;
 N vEx,$ET,$ES S vEx=$ZE,$EC="",$ET="Q",$ZE=""
 WRITE mod,".pslx NOT copied (",$P(vEx,",",3),": ",$P(vEx,",",4),")",!
 D ZX^UCGMR(voxMrk) Q 
 ;
vCatch1 ; Error trap
 ;
 N ioErr,$ET,$ES S ioErr=$ZE,$EC="",$ET="Q",$ZE=""
 D close^UCIO(rIo)
 D ZX^UCGMR(voxMrk) Q 
