 ; 
 ; **** Routine compiled from DATA-QWIK Procedure DBSDRV ****
 ; 
 ; 02/24/2010 18:21 - pip
 ; 
 ;  #PACKAGE framework
 ;  #OPTION ResultClass ON
 ;
 ; This entry is temporary until PSL generates the leader code
 ;
 ; Display any error and then quit, which will exit back to shell
 N $ET,$ES,$ZYER S $ZYER="ZE^UCGMR",$ZE="",$EC="",$ET="D:$TL>"_$TL_" rollback^vRuntime("_$TL_") Q:$Q&$ES """" Q:$ES  N voxMrk s voxMrk="_+$O(vobj(""),-1)_" G vCatch1^"_$T(+0)
 ;
 ; Need to deal with Java as well
 ;
 ; Set up select system keyword(s)
 ;  #ACCEPT Date=02/22/2009; Pgm=RussellDS; CR=35741; Group=ACCESS
 N %UID S %UID=$$USERNAM^%ZFUNC ; replace with Runtime.username once available
 ;
 N args
 N status
 ;
 ;  #ACCEPT Date=02/22/2009; Pgm=RussellDS; CR=35741; Group=BYPASS
 ;*** Start of code by-passed by compiler
 ; Parse the command line
 do cmdline($ZCMDLINE,.args)
 ;*** End of code by-passed by compiler ***
 ;
 S status=$$run(.args)
 ;
 ;         #ACCEPT Date=02/22/2009; Pgm=RussellDS; CR=35741; Group=BYPASS
 ;*** Start of code by-passed by compiler
 set $ZTRAP="" ZMESSAGE status
 ;*** End of code by-passed by compiler ***
 ;
 Q 
 ;
run(args) ; 
 ;
 N i
 N retStat S retStat=0 ; 0 = success, anything else = failure
 ;
 D
 .	;
 .	N %UCLS N func
 .	N errmsg S errmsg=""
 .	;
 .	N $ET,$ES,$ZYER S $ZYER="ZE^UCGMR",$ZE="",$EC="",$ET="D:$TL>"_$TL_" rollback^vRuntime("_$TL_") Q:$Q&$ES """" Q:$ES  N voxMrk s voxMrk="_+$O(vobj(""),-1)_" G vCatch2^"_$T(+0)
 .	;
 .	N dbsuser,vop1 S dbsuser=$$vRCgetRecord1Opt^RecordDBSUSER(%UID,0,.vop1)
 .	;
 . I ($G(vop1)=0) S retStat=$$errormsg("Invalid user") Q 
 . I $P(dbsuser,$C(124),3) S retStat=$$errormsg("User not allowed access") Q 
 .	;
 .	S %UCLS=$P(dbsuser,$C(124),2)
 .	;
 . I '($D(args(1))#2) S retStat=$$errormsg("No function input") Q 
 .	;
 .	S func=args(1)
 .	;
 .	; Strip first positional argument (function name)
 .	K args(1)
 .	F i=2:1 Q:'($D(args(i))#2)  D
 ..		;
 ..		S args(i-1)=args(i)
 ..		K args(i)
 ..		Q 
 .	;
 .	; Hardcode to allow without table entry or authorization
 .	I (func="buildDBSDRV") S errmsg=$$build(0,.args)
 .	E  D
 ..		;
 ..		N dbsfunc,vop2 S dbsfunc=$$vRCgetRecord1Opt^RecordDBSFUNC(func,0,.vop2)
 ..		;
 ..  I ($G(vop2)=0) S retStat=$$errormsg("Invalid function") Q 
 ..		;
 ..		N dbsfuncucls,vop3 S dbsfuncucls=$$vRCgetRecord1Opt^RecordDBSFUNCUCLS(func,%UCLS,0,.vop3)
 ..		;
 ..  I ($G(vop3)=0) S retStat=$$errormsg("User not authorized for function "_func) Q 
 ..		;
 ..		; Call dispatch
 ..		S errmsg=$$^DBSDRVDSP(func,0,.args)
 ..  Q 
 .	;
 .	I '(errmsg="") S retStat=$$errormsg(errmsg)
 . Q 
 ;
 Q retStat
 ;
rpclpc(rpcReturn,version,function,cmdStr) ; Command string [*]
 ;
 N args
 N retVal S retVal=""
 ;
 I (+version'=+1) Q $$ERRMSG^PBSUTL("Version number of client message is not compatible with server")
 ;
 I (function="") Q $$ERRMSG^PBSUTL("No function specified")
 ;
 I '$$vCaEx1() Q "Function "_function_" not authorized as an MRPC"
 ;
 N scatbl5a,vop1 S scatbl5a=$$vCa3(function,%UCLS,.vop1)
 ;
 ; Determine if authorized for this userclass
 I ($G(vop1)=0),'$$vCaEx2() Q "User is not authorized to execute function "_function
 ;
 D cmdline($get(cmdStr),.args)
 ;
 ; Call dispatch
 S rpcReturn=$$^DBSDRVDSP(function,1,.args)
 ;
 I (rpcReturn="") S rpcReturn=function_" complete" ; Success
 E  S retVal=rpcReturn ; Failure
 ;
 Q retVal
 ;
rpcrun(rpcReturn,version,runable,cmdStr) ; Command string [*]
 ;
 N args
 N runReturn
 N retVal S retVal=""
 ;
 I (+version'=+1) Q $$ERRMSG^PBSUTL("Version number of client message is not compatible with server")
 ;
 I (runable="") Q $$ERRMSG^PBSUTL("No function specified")
 ;
 I '$$vCaEx3() Q "Procedure "_runable_" not authorized as an MRPC"
 ;
 N scatbl5a,vop1 S scatbl5a=$$vCa3(runable,%UCLS,.vop1)
 ;
 ; Determine if authorized for this userclass
 I ($G(vop1)=0),'$$vCaEx4() Q "User is not authorized to execute function "_runable
 ;
 D cmdline($get(cmdStr),.args)
 ;
 ; Call dispatch
 S runReturn=$$runable^DBSDRVDSP(runable,.args)
 ;
 I (runReturn=0) S rpcReturn="Complete" ; Success
 E  D  ; Failure
 .	;
 .	S rpcReturn=""
 .	S retVal="Failure - code "_runReturn
 .	Q 
 ;
 Q retVal
 ;
build(isRPC,args) ; 
 ;
 ; Replace $$TRNLNM once Host or other method is available
 ;  #ACCEPT Date=02/22/2009; Pgm=RussellDS; CR=35741; Group=ACCESS
 ;
 N cls N func N funcs N funcClasses N retVal N runables N runClasses N status
 ;
 N ds,vos1,vos2,vos3 S ds=$$vOpen1()
 ;
 I '$G(vos1) Q "Table DBSFUNC is empty"
 ;
 ; Need to get distinct classes to include static reference
 F  Q:'$$vFetch1()  D
 .	;
 . N dbsfunc,vop1 S vop1=ds,dbsfunc=$$vRCgetRecord1Opt^RecordDBSFUNC(vop1,1,"")
 .	;
 .	S funcs(vop1)=$P(dbsfunc,$C(124),2)
 .	I '($E($P(dbsfunc,$C(124),2),1,2)="$$") S funcClasses($piece($P(dbsfunc,$C(124),2),".",1))=""
 . Q 
 ;
 ; Get runable methods
 N rs,vos4,vos5,vos6 S rs=$$vOpen2()
 ;
 F  Q:'$$vFetch2()  D
 .	;
 . N rpcid S rpcid=rs
 .	;
 .	S runables(rpcid)=""
 .	I ($E(rpcid,$L(rpcid)-4+1,1048575)=".run") S runClasses($piece(rpcid,".",1))=""
 .	Q 
 ;
 N iofile S iofile=$$vClVobj($ST,"IO")
 ;
 S $P(vobj(iofile,1),"|",1)="/home/pip/pip_V02/spool/DBSDRVDSP.tmp"
 S $P(vobj(iofile,1),"|",3)="NEWV"
 ;
 D
 .	N $ET,$ES,$ZYER S $ZYER="ZE^UCGMR",$ZE="",$EC="",$ET="D:$TL>"_$TL_" rollback^vRuntime("_$TL_") Q:$Q&$ES """" Q:$ES  N voxMrk s voxMrk="_+$O(vobj(""),-1)_" G vCatch3^"_$T(+0)
 .	;
 .	D open^UCIO(iofile,$T(+0),"build","iofile")
 .	;
 .	D write^UCIO(iofile," #PACKAGE framework")
 .	D write^UCIO(iofile," #OPTION ResultClass ON")
 .	;
 .	D write^UCIO(iofile,"String DBSDRVDSP(String func, Boolean isRPC, String args())")
 .	D write^UCIO(iofile," // Last compiled:  "_$$vdat2str($P($H,",",1),"MM/DD/YEAR")_" "_$$vtim2str($P($H,",",2),"24:60:SS")_" - "_$$USERNAM^%ZFUNC)
 .	D write^UCIO(iofile,"")
 .	D write^UCIO(iofile," // THIS IS A GENERATED MODULE.  Generated by build^DBSDRV.")
 .	D write^UCIO(iofile,"")
 .	;
 .	S cls=""
 .	F  S cls=$order(funcClasses(cls)) Q:(cls="")  D write^UCIO(iofile," type static "_cls)
 .	;
 .	D write^UCIO(iofile,"")
 .	;
 .	S func=""
 .	F  S func=$order(funcs(func)) Q:(func="")  D
 ..		;
 ..		N method
 ..		;
 ..		S method=funcs(func)
 ..		;
 ..		D write^UCIO(iofile," if (func = "_$S(func'["""":""""_func_"""",1:$$QADD^%ZS(func,""""))_") quit "_method_"(isRPC, args())")
 ..		Q 
 .	;
 .	D write^UCIO(iofile,"")
 .	D write^UCIO(iofile," quit ""Invalid function (""_ func_ "") - dispatcher out of date - please run buildDBSDRV""")
 .	;
 .	; Runable section
 .	D write^UCIO(iofile,"Integer runable(String runable, String args())")
 .	D write^UCIO(iofile,"")
 .	;
 .	S cls=""
 .	F  S cls=$order(runClasses(cls)) Q:(cls="")  D write^UCIO(iofile," type static "_cls)
 .	;
 .	D write^UCIO(iofile,"")
 .	;
 .	S func=""
 .	F  S func=$order(runables(func)) Q:(func="")  D
 ..		;
 ..		N call
 ..		;
 ..		I ($E(func,1,4)="run^") S call="$$"_func
 ..		E  S call=func
 ..		;
 ..		D write^UCIO(iofile," if (runable = "_$S(func'["""":""""_func_"""",1:$$QADD^%ZS(func,""""))_") quit "_call_"(args())")
 ..		Q 
 .	;
 .	D write^UCIO(iofile,"")
 .	D write^UCIO(iofile," quit ""Invalid procedure (""_ runable_ "") - dispatcher out of date - please run buildDBSDRV""")
 .	D close^UCIO(iofile)
 .	Q 
 ;
 ; Build compiled routine
 S status=$$storePsl^PSLC("/home/pip/pip_V02/spool/DBSDRVDSP.tmp","DBSDRVDSP")
 S status=$$run^PSLC("DBSDRVDSP")
 ;
 I (status>0) S retVal="Compile error - new version of DBSDRVDSP not rebuilt"
 E  S retVal=""
 ;
 ;  #ACCEPT Date=02/22/2009; Pgm=RussellDS; CR=35741; Group=ACCESS
 S status=$$DELETE^%OSSCRPT("/home/pip/pip_V02/spool/DBSDRVDSP.tmp")
 ;
 K vobj(+$G(iofile)) Q retVal
 ;
errormsg(errMsg) ; Message associated with failure
 ;
 ; Direct to stderr once we are able to
 WRITE errMsg,!
 ;
 Q 1 ; Error indicator
 ;
cmdline(cmdStr,args) ; Decomposed command line arguments/options
 ;
 N argCnt S argCnt=0
 N elem N tok
 ;
 S cmdStr=$$TOKEN^%ZS(cmdStr,.tok)
 ;
 ; Replace TAB by SPACE and reduce multiple space to single space
 S cmdStr=$$vStrRep($$vStrTrim($translate(cmdStr,$char(9)," "),0," "),"  "," ",0,0,"")
 ;
 F  Q:'('(cmdStr=""))  D
 .	;
 .	S elem=$piece(cmdStr," ",1)
 .	S cmdStr=$piece(cmdStr," ",2,$L(cmdStr))
 .	;
 .	I '($E(elem,1)="-") D
 ..		;
 ..		S argCnt=argCnt+1
 ..		S args(argCnt)=$$QSUB^%ZS($$UNTOK^%ZS(elem,tok),"""")
 ..		Q 
 .	E  I ($E(elem,1,2)="--") D
 ..		;
 ..		N opt S opt=$piece(elem,"=",1)
 ..		N value S value=$piece(elem,"=",2,$L(elem))
 ..		;
 ..		S args($E(opt,3,1048575))=$$QSUB^%ZS($$UNTOK^%ZS(value,tok),"""")
 ..		Q 
 .	Q 
 ;
 Q 
 ;  #OPTION ResultClass ON
vSIG() ; 
 Q "61462^42586^Dan Russell^17121" ; Signature - LTD^TIME^USER^SIZE
 ; ----------------
 ;  #OPTION ResultClass 1
vCaEx1() ; {Cache}%CACHE("SCATBL5").isDefined("SCATBL5","RPCID=:function")
 N vret
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 N vRec,vop1 S vRec=$$vCa4(function,.vop1)
 S vret=$G(vop1)=1 Q vret
 ; ----------------
 ;  #OPTION ResultClass 1
vCaEx2() ; {Cache}%CACHE("SCATBL5A").isDefined("SCATBL5A","RPCID=:function,UCLS='*'")
 N vret
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 N vRec,vop1 S vRec=$$vCa3(function,"*",.vop1)
 S vret=$G(vop1)=1 Q vret
 ; ----------------
 ;  #OPTION ResultClass 1
vCaEx3() ; {Cache}%CACHE("SCATBL5").isDefined("SCATBL5","RPCID=:runable")
 N vret
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 N vRec,vop1 S vRec=$$vCa4(runable,.vop1)
 S vret=$G(vop1)=1 Q vret
 ; ----------------
 ;  #OPTION ResultClass 1
vCaEx4() ; {Cache}%CACHE("SCATBL5A").isDefined("SCATBL5A","RPCID=:runable,UCLS='*'")
 N vret
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 N vRec,vop1 S vRec=$$vCa3(runable,"*",.vop1)
 S vret=$G(vop1)=1 Q vret
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
vCa3(v1,v2,v2out) ; voXN = ({Cache}%CACHE("SCATBL5A").getRecord(SCATBL5A,1)
 ;
 I '$D(%CACHE("SCATBL5A",v1,v2)) D
 .  I $G(%CACHE("SCATBL5A"))>100 KILL %CACHE("SCATBL5A")
 .  S %CACHE("SCATBL5A")=$G(%CACHE("SCATBL5A"))+1
 .  S %CACHE("SCATBL5A",v1,v2)=$$vRCgetRecord1Opt^RecordSCATBL5A(v1,v2,0,.v2out),%CACHE("SCATBL5A",v1,v2,-2)=v2out
 ;
 ;
 E  S v2out=%CACHE("SCATBL5A",v1,v2,-2)
 Q %CACHE("SCATBL5A",v1,v2)
 ;
vCa4(v1,v2out) ; voXN = ({Cache}%CACHE("SCATBL5").getRecord(SCATBL5,1)
 ;
 I '$D(%CACHE("SCATBL5",v1)) D
 .  I $G(%CACHE("SCATBL5"))>100 KILL %CACHE("SCATBL5")
 .  S %CACHE("SCATBL5")=$G(%CACHE("SCATBL5"))+1
 .  S %CACHE("SCATBL5",v1)=$$vRCgetRecord1Opt^RecordSCATBL5(v1,0,.v2out),%CACHE("SCATBL5",v1,-2)=v2out
 ;
 ;
 E  S v2out=%CACHE("SCATBL5",v1,-2)
 Q %CACHE("SCATBL5",v1)
 ;
vClVobj(vSt,vCls) ; Create a new object
 ;
 N vOid
 S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)=vCls_$C(9)_vSt
 Q vOid
 ;
vOpen1() ; FUNC FROM DBSFUNC
 ;
 ;
 S vos1=2
 D vL1a1
 Q ""
 ;
vL1a0 S vos1=0 Q
vL1a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=""
vL1a3 S vos3=$O(^DBSFUNC(vos3),1) I vos3="" G vL1a0
 Q
 ;
vFetch1() ;
 ;
 ;
 I vos1=1 D vL1a3
 I vos1=2 S vos1=1
 ;
 I vos1=0 S ds="" Q 0
 ;
 S ds=$S(vos3=vos2:"",1:vos3)
 ;
 Q 1
 ;
vOpen2() ; RPCID FROM SCATBL5 WHERE RPCID LIKE 'run^%' OR RPCID LIKE '%.run'
 ;
 ;
 S vos4=2
 D vL2a1
 Q ""
 ;
vL2a0 S vos4=0 Q
vL2a1 S vos5=$$BYTECHAR^SQLUTL(254)
 S vos6=""
vL2a3 S vos6=$O(^SCATBL(5,vos6),1) I vos6="" G vL2a0
 I '((vos6]]("run"_$C(93,1114109))&(vos6']]("run^"_$C(1114109))))!(vos6?1"".E1".run")) G vL2a3
 Q
 ;
vFetch2() ;
 ;
 ;
 I vos4=1 D vL2a3
 I vos4=2 S vos4=1
 ;
 I vos4=0 S rs="" Q 0
 ;
 S rs=$S(vos6=vos5:"",1:vos6)
 ;
 Q 1
 ;
vCatch3 ; Error trap
 ;
 N ioerror,$ET,$ES S ioerror=$ZE,$EC="",$ET="Q",$ZE=""
 ;
 I '($P(vobj(iofile,1),"|",6)="") D close^UCIO(iofile)
 ;
 S $ZE=ioerror,$EC=",U1001,"
 D ZX^UCGMR(voxMrk) Q 
 ;
vCatch2 ; Error trap
 ;
 N err,$ET,$ES S err=$ZE,$EC="",$ET="Q",$ZE=""
 ;
 S errmsg=$P(err,",",3)_", "_$P(err,",",2)_", "_$P(err,",",4)
 ;
 I '($P(err,",",5)="") S errmsg=errmsg_$P(err,",",5)
 ;
 S retStat=$$errormsg(errmsg)
 D ZX^UCGMR(voxMrk) Q 
 ;
vCatch1 ; Error trap
 ;
 N err,$ET,$ES S err=$ZE,$EC="",$ET="Q",$ZE=""
 ;
 N retStat
 ;
 N errmsg S errmsg=$P(err,",",3)_", "_$P(err,",",2)_", "_$P(err,",",4)
 ;
 I '($P(err,",",5)="") S errmsg=errmsg_$P(err,",",5)
 ;
 S retStat=$$errormsg(errmsg)
 ;
 ;   #ACCEPT Date=02/22/2009; Pgm=RussellDS; CR=35741; Group=BYPASS
 ;*** Start of code by-passed by compiler
 set $ZTRAP="" ZMESSAGE 2 ; Indicates uncontrolled error
 ;*** End of code by-passed by compiler ***
 D ZX^UCGMR(voxMrk) Q 
